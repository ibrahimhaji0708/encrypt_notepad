import 'package:flutter/material.dart';
//
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final dylib = Platform.isLinux
    ? DynamicLibrary.open('rust/target/release/librust.so') 
    : throw UnsupportedError("only linux is supported for now..");

class RustImpl {
  final DynamicLibrary dylib;

  RustImpl(this.dylib);

  Pointer<Utf8> Function(Pointer<Utf8>) get encryptText => dylib
      .lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('encrypt_text');

  String encryptMessage(String message) {
    final textPointer = message.toNativeUtf8();
    final encryptedPointer = encryptText(textPointer);
    final encryptedMessage = encryptedPointer.toDartString();

    malloc.free(textPointer);
    malloc.free(encryptedPointer);

    return encryptedMessage;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> result = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Encrypted Notepad')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'enter message'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final encrypted = await encryptMessage(controller.text);
                  result.value = encrypted;
                },
                child: Text('Encrypt'),
              ),
              ValueListenableBuilder(
                valueListenable: result,
                builder: (context, value, _) => Text('Encrypted: $value'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> encryptMessage(String message) async {
    final api = RustImpl(dylib);
    return api.encryptMessage(message);
  }
}
