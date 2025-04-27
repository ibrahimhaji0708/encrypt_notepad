import 'package:flutter/material.dart';
import 'package:flutter_ui/api_interface.dart'; // wherever you put your Rust API

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _noteTitles;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() {
    _noteTitles = api.listNoteTitles();
  }

  void _refreshNotes() {
    setState(() {
      _fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () async {
                // Navigate to editor
                final result = await Navigator.pushNamed(context, '/editor');

                // After coming back from editor, refresh notes
                if (result == true) {
                  _refreshNotes();
                }
              },
              child: const Text('Create New Note'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _noteTitles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading notes: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notes available.'));
                } else {
                  final notes = snapshot.data!;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(notes[index]),
                          onTap: () {
                            // ontapped read contents of the note 
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
