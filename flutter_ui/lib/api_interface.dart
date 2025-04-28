import 'dart:ffi';
// import 'package:ffi/ffi.dart';
// import 'dart:io';
import 'bridge_generated.dart';

// Initialize Rust API
late final RustImpl api;

// linux
// void initRustApi() {
//   try {
//     final dylibPath = '/home/ibrahim/code/Rust_lang/encrypt_notepad/rust/target/release/librust.so';
//     final dylib = DynamicLibrary.open(dylibPath);

//     api = RustImpl(dylib);
//     print('Rust dynamic library loaded successfully from $dylibPath.');
//   } catch (e) {
//     print('Failed to load Rust dynamic library: $e');
//     rethrow;
//   }
// }

//android
void initRustApi() {
  try {
    final dylib = DynamicLibrary.open("assets/librust.so");
    api = RustImpl(dylib);
    print('Rust dynamic library loaded successfully.');
  } catch (e) {
    print('Failed to load Rust dynamic library: $e');
    rethrow;
  }
}
