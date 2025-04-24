import 'dart:ffi';
import 'package:ffi/ffi.dart';

class RustImpl {
  final DynamicLibrary dylib;

  RustImpl(this.dylib);

  void Function(Pointer<Utf8>, Pointer<Utf8>) get _saveNoteToDisk =>
      dylib.lookupFunction<
        Void Function(Pointer<Utf8>, Pointer<Utf8>),
        void Function(Pointer<Utf8>, Pointer<Utf8>)
      >('save_note_to_disk');

  Pointer<Utf8> Function(Pointer<Utf8>) get _loadNoteFromDisk =>
      dylib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>)
      >('load_note_from_disk');

  Pointer<Utf8> Function(Pointer<Utf8>) get encryptText => dylib.lookupFunction<
    Pointer<Utf8> Function(Pointer<Utf8>),
    Pointer<Utf8> Function(Pointer<Utf8>)
  >('encrypt_text');

  //
  Pointer<Utf8> Function() get _listNoteTitles =>
      dylib.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
        'list_note_titles',
      );

  Future<List<String>> listNoteTitles() async {
    final resultPtr = _listNoteTitles();
    final rawString = resultPtr.toDartString();
    malloc.free(resultPtr);

    return rawString.split(';').where((e) => e.isNotEmpty).toList();
  }
  //
  
  Future<void> saveNoteToDisk(String noteTitle, String noteContent) async {
    final titlePtr = noteTitle.toNativeUtf8();
    final contentPtr = noteContent.toNativeUtf8();
    _saveNoteToDisk(titlePtr, contentPtr);
    malloc.free(titlePtr);
    malloc.free(contentPtr);
  }

  Future<String> loadNoteFromDisk(String noteTitle) async {
    final titlePtr = noteTitle.toNativeUtf8();
    final resultPtr = _loadNoteFromDisk(titlePtr);
    final content = resultPtr.toDartString();
    malloc.free(titlePtr);
    malloc.free(resultPtr);
    return content;
  }

  String encryptMessage(String message) {
    final textPointer = message.toNativeUtf8();
    final encryptedPointer = encryptText(textPointer);
    final encryptedMessage = encryptedPointer.toDartString();
    malloc.free(textPointer);
    malloc.free(encryptedPointer);
    return encryptedMessage;
  }
}
