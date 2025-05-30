import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_ui/ui/screens/editor_screen.dart';
import 'package:flutter_ui/ui/screens/home_screen.dart';
import 'package:flutter_ui/bridge_generated.dart/frb_generated.dart' as bridge;

final dylibPath =
    'native/target/release/librust_lib_notepad.so';
final dylib = DynamicLibrary.open(dylibPath);

Future<void> main() async {
  await bridge.RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
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
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D1B69),
        scaffoldBackgroundColor: const Color(0xFF171738),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6247AA),
          secondary: const Color(0xFF81559B),
          surface: const Color(0xFF1F1B2C),
          error: Colors.redAccent,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF29214F),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D1B69), 
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6247AA), 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF9D84C7), 
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF242042), 
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6247AA), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFABB2BF)),
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFF9D84C7)),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/editor': (context) => const EditorScreen(initialContent: '', initialTitle: ''),
      },
    );
  }
}