import 'package:flutter/material.dart';
//
// import 'dart:ffi';
// import 'dart:io';
// import 'package:ffi/ffi.dart';

import 'ui/screens/home_screen.dart';

// final dylib = Platform.isLinux
//     ? DynamicLibrary.open('rust/target/release/librust.so') 
//     : throw UnsupportedError("only linux is supported for now..");


// class RustImpl {
//   final DynamicLibrary dylib;

//   RustImpl(this.dylib);

//   Pointer<Utf8> Function(Pointer<Utf8>) get encryptText => dylib
//       .lookupFunction<
//           Pointer<Utf8> Function(Pointer<Utf8>),
//           Pointer<Utf8> Function(Pointer<Utf8>)>('encrypt_text');

//   String encryptMessage(String message) {
//     final textPointer = message.toNativeUtf8();
//     final encryptedPointer = encryptText(textPointer);
//     final encryptedMessage = encryptedPointer.toDartString();

//     malloc.free(textPointer);
//     malloc.free(encryptedPointer);

//     return encryptedMessage;
//   }
// }
//error in code , fix later

void main() {
  runApp(const EncryptedNotepadApp());
}

class EncryptedNotepadApp extends StatelessWidget {
  const EncryptedNotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypted Notepad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

  // Future<String> encryptMessage(String message) async {
  //   final api = RustImpl(dylib);
  //   return api.encryptMessage(message);
  // }
