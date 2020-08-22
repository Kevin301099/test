import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker/file_picker.dart';

import 'file_picker_cross.dart';

/// Implementation of file selection dialog delegating to platform-specific implementations
Future<Map<String, Uint8List>> selectSingleFileAsBytes(
    {FileTypeCross type, String fileExtension}) async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
    return await selectFilesMobile(type: type, fileExtension: fileExtension);
  } else {
    return await selectFilesDesktop(type: type, fileExtension: fileExtension);
  }
}

/// Implementation of file selection dialog delegating to platform-specific implementations
Future<String> pickSingleFileAsPath(
    {FileTypeCross type, String fileExtension}) async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
    return await saveFileMobile(type: type, fileExtension: fileExtension);
  } else {
    return await saveFileDesktop(type: type, fileExtension: fileExtension);
  }
}

/// Implementation of file selection dialog using file_chooser for desktop platforms
Future<Map<String, Uint8List>> selectFilesDesktop(
    {FileTypeCross type, String fileExtension}) async {
  FileChooserResult file = await showOpenPanel(
      allowedFileTypes: (parseExtension(fileExtension) == null)
          ? null
          : [
              FileTypeFilterGroup(
                  label: 'files', fileExtensions: parseExtension(fileExtension))
            ]);
  String path = file.paths[0];
  return {path: await _readFileByte(path)};
}

/// Implementation of file selection dialog using file_chooser for desktop platforms
Future<String> saveFileDesktop(
    {FileTypeCross type, String fileExtension}) async {
  FileChooserResult file = await showSavePanel(
      allowedFileTypes: (parseExtension(fileExtension) == null)
          ? null
          : [
              FileTypeFilterGroup(
                  label: 'files', fileExtensions: parseExtension(fileExtension))
            ]);
  String path = file.paths.isEmpty ? "" : file.paths[0];
  return path;
}

Future<Uint8List> _readFileByte(String filePath) async {
  Uri myUri = Platform.isWindows
      ? Uri.file(filePath, windows: true)
      : Uri.parse(filePath);
  File audioFile = new File.fromUri(myUri);
  Uint8List bytes;
  await audioFile.readAsBytes().then((value) {
    bytes = Uint8List.fromList(value);
  }).catchError((onError) {
    print('Exception Error while reading file from path:' + onError.toString());
  });
  return bytes;
}

/// Implementation of file selection dialog using file_picker for mobile platforms
Future<Map<String, Uint8List>> selectFilesMobile(
    {FileTypeCross type, String fileExtension}) async {
  File file = await FilePicker.getFile(
      type: _fileTypeCrossParse(type),
      allowedExtensions: parseExtension(fileExtension));
  return {file.path: file.readAsBytesSync()};
}

Future<String> saveFileMobile(
    {FileTypeCross type, String fileExtension}) async {
  throw UnimplementedError('Unsupported Platform for file_picker_cross');
}

/// Parsing various valid HTML/JS file type declarations into valid ones for file_picker
dynamic parseExtension(String fileExtension) {
  return (fileExtension != null &&
          fileExtension.replaceAll(',', '').trim().isNotEmpty)
      ? fileExtension.split(',').map<String>((e) => e.trim()).toList()
      : null;
}

FileType _fileTypeCrossParse(FileTypeCross type) {
  FileType accept;
  switch (type) {
    case FileTypeCross.any:
      accept = FileType.any;
      break;
    case FileTypeCross.audio:
      accept = FileType.audio;
      break;
    case FileTypeCross.image:
      accept = FileType.image;
      break;
    case FileTypeCross.video:
      accept = FileType.video;
      break;
    case FileTypeCross.custom:
      accept = FileType.custom;
      break;
  }
  return accept;
}
