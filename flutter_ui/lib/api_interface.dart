import 'dart:ffi';
import 'dart:io';
import 'bridge_generated.dart';

DynamicLibrary loadRustLib() {
  try {
    if (Platform.isLinux) {
      return DynamicLibrary.open(
        '${Directory.current.path}/rust/target/release/librust.so',
      );
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open(
        '${Directory.current.path}/rust/target/release/librust.dylib',
      );
    } else if (Platform.isWindows) {
      return DynamicLibrary.open(
        '${Directory.current.path}\\rust\\target\\release\\rust.dll',
      );
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  } catch (e) {
    print("Failed to load Rust dynamic library: $e");
    rethrow;
  }
}


final api = RustImpl(loadRustLib());

//remove if error init 
Future<String> encryptMessage(String message) async {
    // final api = RustImpl(dylib);
    return api.encryptMessage(message);
  }