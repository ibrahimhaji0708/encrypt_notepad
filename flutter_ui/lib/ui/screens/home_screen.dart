import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((file) => file.path.endsWith('.txt')).toList();
    setState(() {
      notes = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Encrypted Notepad')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final name = notes[index].path.split('/').last.replaceAll('.txt', '');
          return ListTile(title: Text(name));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditorScreen()),
          );
          if (result == true) _loadNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
