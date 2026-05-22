import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wzzsdgseysfrchtgprbk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6enNkZ3NleXNmcmNodGdwcmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NzU5NTksImV4cCI6MjA5NDI1MTk1OX0.uv7xE4gtGvDeO9gHhoA4cqth2gfz5yGF6owgZ4ukk1E',
  );
  runApp(const ProviderScope(child: QuotesApp()));
}

// ─── MODEL ────────────────────────────────────────────────────────────────────

class Quote {
  final int id;
  final String shortText;
  final String fullText;

  Quote({required this.id, required this.shortText, required this.fullText});

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        id: json['id'],
        shortText: json['short_text'],
        fullText: json['full_text'],
      );
}

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

class QuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() async {
    final data = await Supabase.instance.client.from('quotes').select();
    return (data as List).map((j) => Quote.fromJson(j)).toList();
  }

  Future<void> addQuote(String shortText, String fullText) async {
    await Supabase.instance.client.from('quotes').insert({
      'short_text': shortText,
      'full_text': fullText,
    });
    ref.invalidateSelf();
  }
}

final quotesProvider =
    AsyncNotifierProvider<QuotesNotifier, List<Quote>>(QuotesNotifier.new);

// ─── APP ──────────────────────────────────────────────────────────────────────

class QuotesApp extends StatelessWidget {
  const QuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: QuotesScreen());
  }
}

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quotes')),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (quotes) => ListView.builder(
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return ListTile(
              title: Text(quote.shortText),
              subtitle: Text(
                quote.fullText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final shortController = TextEditingController();
    final fullController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: shortController,
              decoration: const InputDecoration(
                labelText: 'Short text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fullController,
              decoration: const InputDecoration(
                labelText: 'Full text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final shortText = shortController.text.trim();
              final fullText = fullController.text.trim();
              if (shortText.isEmpty || fullText.isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(quotesProvider.notifier)
                  .addQuote(shortText, fullText);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}