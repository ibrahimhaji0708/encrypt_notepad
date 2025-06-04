import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ui/bridge_generated.dart/frb_generated.dart' as bridge;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ui/bridge_generated.dart/frb_generated.dart';

class EditorScreen extends StatefulWidget {
  final String initialTitle;
  final String initialContent;

  const EditorScreen({
    super.key,
    this.initialTitle = '',
    this.initialContent = '', //
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;
  bool _isEncrypted = false;
  bool _hasChanges = false;
  bool _isSaving = false;
  late FocusNode _titleFocus;
  late FocusNode _contentFocus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _titleFocus = FocusNode();
    _contentFocus = FocusNode();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    if (widget.initialTitle.isEmpty) {
      Future.microtask(() => _titleFocus.requestFocus());
    }
  }

  void _onTextChanged() {
    final titleChanged = _titleController.text != widget.initialTitle;
    final contentChanged = _contentController.text != widget.initialContent;
    if ((titleChanged || contentChanged) != _hasChanges) {
      setState(() {
        _hasChanges = titleChanged || contentChanged;
      });
    }
  }

  Future<void> _toggleEncryption() async {
    if (_isEncrypted) {
      setState(() {
        _isEncrypted = false;
      });
    } else {
      setState(() => _isLoading = true);
      try {
        final encryptedContent = await bridge.RustLib.instance.api
            .crateApiEncryptText(text: _contentController.text);
        setState(() {
          _contentController.text = encryptedContent;
          _isEncrypted = true;
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showError('Storage permission is required to save notes.');
        }
      }
    }
  }

  Future<Directory> _getSafeDirectory() async {
    if (Platform.isAndroid) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getTemporaryDirectory();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSaveWithSafety(BuildContext context) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });
    try {
      if (Platform.isAndroid) {
        await requestStoragePermission();
      }
      await _saveNote();
    } catch (e) {
      debugPrint('Save error: $e');
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showErrorSnackBar('Title cannot be empty');
      _titleFocus.requestFocus();
      return;
    }
    if (content.isEmpty) {
      _showErrorSnackBar('Content cannot be empty');
      _contentFocus.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool saved = false;

      if (Platform.isAndroid) {
        try {
          final directory = await _getSafeDirectory();
          final fileName = '${title.replaceAll(RegExp(r'[^\w\s]+'), '')}.txt';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsString(content);
          saved = true;
          debugPrint("Flutter save successful: $filePath");
        } catch (e) {
          debugPrint("Flutter save failed: $e");
        }
      }

      if (!saved) {
        try {
          saved = await RustLib.instance.api.crateApiSaveNoteToDisk(
            title: title,
            content: content,
          );
          if (saved) {
            debugPrint("Rust save successful");
          }
        } catch (e) {
          debugPrint("Rust save failed: $e");
        }
      }

      if (saved && context.mounted) {
        _showSuccessSnackBar('Note saved successfully');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Failed to save note');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('discard changes??'),
            content: const Text(
              'u have unsaved changes, r u sure u want to discard them??',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop();
        if (result && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialTitle.isEmpty ? 'New Note' : 'Edit Note'),
          actions: [
            IconButton(
              icon: Icon(_isEncrypted ? Icons.lock : Icons.lock_open),
              onPressed: _isLoading ? null : _toggleEncryption,
              tooltip: _isEncrypted ? 'Encrypted' : 'Encrypt',
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  _hasChanges
                      ? IconButton(
                        key: const ValueKey('save'),
                        icon:
                            _isSaving
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.save),
                        onPressed:
                            (_isLoading || _isSaving)
                                ? null
                                : () => _handleSaveWithSafety(context),
                        tooltip: 'Save',
                      )
                      : const SizedBox(width: 48),
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocus,
                            decoration: const InputDecoration(
                              hintText: 'Note Title',
                              border: InputBorder.none,
                              counter: SizedBox.shrink(),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _contentController,
                              focusNode: _contentFocus,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText: 'Write your note here...',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        floatingActionButton: AnimatedOpacity(
          opacity: _hasChanges ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child:
              _hasChanges
                  ? FloatingActionButton(
                    onPressed:
                        (_isLoading || _isSaving)
                            ? null
                            : () => _handleSaveWithSafety(context),
                    tooltip: 'Save Note',
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.save),
                  )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
