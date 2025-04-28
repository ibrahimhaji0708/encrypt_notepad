import 'package:flutter/material.dart';

import 'api_interface.dart';
import 'ui/screens/editor_screen.dart';
import 'ui/screens/home_screen.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  initRustApi();
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
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          elevation: 4,
        ),
        scaffoldBackgroundColor: Colors.grey[200],
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepPurple,
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.deepPurpleAccent),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/editor': (context) => const EditorScreen(initialContent: '', initialTitle: '',),
      },
    );
  }
}
