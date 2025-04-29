// Auto generated file, do not modify..

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class RustImpl {
  final DynamicLibrary dylib;

  RustImpl(this.dylib);

  late final void Function(Pointer<Utf8>, Pointer<Utf8>) _saveNoteToDisk = dylib
      .lookupFunction<
          Void Function(Pointer<Utf8>, Pointer<Utf8>),
          void Function(Pointer<Utf8>, Pointer<Utf8>)>('save_note_to_disk');

  late final Pointer<Utf8> Function(Pointer<Utf8>) _loadNoteFromDisk = dylib
      .lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('load_note_from_disk');

  late final Pointer<Utf8> Function() _listNoteTitles = dylib.lookupFunction<
      Pointer<Utf8> Function(), Pointer<Utf8> Function()>('list_note_titles');

  late final void Function(Pointer<Utf8>) _freeString = dylib.lookupFunction<
      Void Function(Pointer<Utf8>), void Function(Pointer<Utf8>)>('free_string');

  late final Pointer<Utf8> Function(Pointer<Utf8>) _encryptText = dylib
      .lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('encrypt_text');

  Future<void> saveNoteToDisk(String noteTitle, String noteContent) async {
    final titlePtr = noteTitle.toNativeUtf8();
    final contentPtr = noteContent.toNativeUtf8();
    
    try {
      _saveNoteToDisk(titlePtr, contentPtr);
    } finally {
      calloc.free(titlePtr);
      calloc.free(contentPtr);
    }
  }

  Future<String> loadNoteFromDisk(String noteTitle) async {
    final titlePtr = noteTitle.toNativeUtf8();
    
    try {
      final resultPtr = _loadNoteFromDisk(titlePtr);
      if (resultPtr.address == 0) {
        return ''; 
      }
      
      final content = resultPtr.toDartString();
      _freeString(resultPtr); // Use Rust's free function instead of malloc.free
      return content;
    } catch (e) {
      print('Error loading note: $e');
      return '';
    } finally {
      calloc.free(titlePtr);
    }
  }

  Future<List<String>> listNoteTitles() async {
    try {
      final resultPtr = _listNoteTitles();
      if (resultPtr.address == 0) {
        return [];
      }
      
      final rawString = resultPtr.toDartString();
      _freeString(resultPtr);
      return rawString.split(';').where((e) => e.isNotEmpty).toList();
    } catch (e) {
      print('Error listing note titles: $e');
      return [];
    }
  }

  String encryptMessage(String message) {
    final textPointer = message.toNativeUtf8();
    
    try {
      final encryptedPointer = _encryptText(textPointer);
      if (encryptedPointer.address == 0) {
        return '';
      }
      
      final encryptedMessage = encryptedPointer.toDartString();
      _freeString(encryptedPointer);
      return encryptedMessage;
    } catch (e) {
      print('Error encrypting message: $e');
      return '';
    } finally {
      calloc.free(textPointer);
    }
  }

  void freeString(Pointer<Utf8> ptr) {
    if (ptr.address != 0) {
      _freeString(ptr);
    }
  }
}