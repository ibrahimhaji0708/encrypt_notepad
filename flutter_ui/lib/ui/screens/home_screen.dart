import 'package:flutter/material.dart';
import 'package:flutter_ui/api_interface.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<String>> _noteTitles;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  // String? _lastDeletedNoteTitle;
  // String? _lastDeletedNoteContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _fetchNotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchNotes() {
    setState(() => _isLoading = true);
    _noteTitles = api.listNoteTitles().whenComplete(() {
      setState(() => _isLoading = false);
    });
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encrypted Notes',
          style: TextStyle(letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
            tooltip: 'Refresh Notes',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FadeTransition(opacity: _animation, child: child);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Hero(
                tag: 'create_button',
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/editor',
                            );
                            if (result == true) {
                              _refreshNotes();
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'CREATE NEW NOTE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<String>>(
                        future: _noteTitles,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading notes',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${snapshot.error}'),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.note_alt_outlined,
                                    size: 80,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No notes yet',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create your first encrypted note!',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final notes = snapshot.data!;
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final noteTitle = notes[index];
                                return Dismissible(
                                  key: Key(noteTitle),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    color: Colors.redAccent,
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  dismissThresholds: const {
                                    DismissDirection.endToStart: 0.6,
                                  },
                                  confirmDismiss: (direction) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete "$noteTitle"?'),
                                          content: const Text(
                                            'This action cannot be undone and the note will be permanently deleted.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('CANCEL'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                              child: const Text('DELETE'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    setState(() => _isLoading = true);
                                    try {
                                      await api.deleteNoteFromDisk(noteTitle);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('$noteTitle deleted'),
                                            behavior: SnackBarBehavior.floating,
                                            action: SnackBarAction(
                                              label: 'UNDO',
                                              onPressed: () {
                                                _refreshNotes();
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error deleting note: $e',
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        _refreshNotes();
                                      }
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () async {
                                        setState(() => _isLoading = true);
                                        try {
                                          final content = await api
                                              .loadNoteFromDisk(noteTitle);
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => EditorScreen(
                                                      initialTitle: noteTitle,
                                                      initialContent: content,
                                                    ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                _refreshNotes();
                                              }
                                            });
                                          }
                                        } finally {
                                          setState(() => _isLoading = false);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.note_rounded),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                noteTitle,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.lock, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
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
      ),
    );
  }
}
