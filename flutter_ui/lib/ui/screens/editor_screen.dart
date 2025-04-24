import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _title = "untitled";

  void _renameNote() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController =
            TextEditingController(text: _title);
        return AlertDialog(
          title: Text('Rename Note'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'enter a new title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _title = titleController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_title.txt');
    await file.writeAsString(_controller.text);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: GestureDetector(
          onTap: _renameNote,
          child: Text(_title),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          decoration: InputDecoration.collapsed(hintText: 'Start writing...'),
        ),
      ),
    );
  }
}
