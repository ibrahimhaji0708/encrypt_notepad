// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.10.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `base64_encode`, `ensure_directory_exists`, `initialize`, `notes_dir`, `xor_encrypt_decrypt`

Future<bool> saveNoteToDisk({required String title, required String content}) =>
    RustLib.instance.api.crateApiSaveNoteToDisk(title: title, content: content);

Future<String> loadNoteFromDisk({required String title}) =>
    RustLib.instance.api.crateApiLoadNoteFromDisk(title: title);

Future<String> listNoteTitles() =>
    RustLib.instance.api.crateApiListNoteTitles();

Future<void> deleteNoteFromDisk({required String title}) =>
    RustLib.instance.api.crateApiDeleteNoteFromDisk(title: title);

Future<String> encryptText({required String text}) =>
    RustLib.instance.api.crateApiEncryptText(text: text);
