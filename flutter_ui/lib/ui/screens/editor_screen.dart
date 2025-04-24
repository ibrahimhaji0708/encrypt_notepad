import 'package:flutter/material.dart';
import '../../api_interface.dart';

class EditorScreen extends StatefulWidget {
  final String? noteTitle;

  const EditorScreen({super.key, this.noteTitle});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteTitle != null) {
      _loadNote(widget.noteTitle!);
    }
  }

  Future<void> _loadNote(String title) async {
    setState(() => _isLoading = true);
    try {
      final content = await api.loadNoteFromDisk(title);
      _titleController.text = title;
      _contentController.text = content;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load note: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNote() async {
  final title = _titleController.text.trim();
  final content = _contentController.text.trim();

  print("Saving note: Title = $title, Content = $content");

  if (title.isEmpty || content.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Title and content cannot be empty')),
    );
    return;
  }

  setState(() => _isLoading = true);
  try {
    await api.saveNoteToDisk(title, content);
    if (context.mounted) Navigator.pop(context, true); // Return with "note saved"
  } catch (e) {
    print("Error saving note: $e");  // Additional debugging log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save note: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          ElevatedButton(
            onPressed: _saveNote,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Write your note here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
