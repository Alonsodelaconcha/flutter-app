import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wzzsdgseysfrchtgprbk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6enNkZ3NleXNmcmNodGdwcmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NzU5NTksImV4cCI6MjA5NDI1MTk1OX0.uv7xE4gtGvDeO9gHhoA4cqth2gfz5yGF6owgZ4ukk1E',
  );
  runApp(const NotesApp());
}

final supabase = Supabase.instance.client;

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NotesScreen());
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await supabase.from('notes').select().order('id');
    setState(() {
      _notes = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  Future<void> _addNote(String text) async {
    await supabase.from('notes').insert({'text': text});
    await _loadNotes();
  }

  Future<void> _editNote(int id, String text) async {
    await supabase.from('notes').update({'text': text}).eq('id', id);
    await _loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    await supabase.from('notes').delete().eq('id', id);
    await _loadNotes();
  }

  void _showDialog({Map<String, dynamic>? note}) {
    final controller = TextEditingController(text: note?['text'] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Text'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              if (note == null) {
                await _addNote(text);
              } else {
                await _editNote(note['id'] as int, text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('No notes yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return ListTile(
                      title: Text(note['text']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showDialog(note: note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(note['id'] as int),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}