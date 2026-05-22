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

// ─── MODELS ───────────────────────────────────────────────────────────────────

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

// ─── PROVIDERS ────────────────────────────────────────────────────────────────

class QuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() async {
    final data = await Supabase.instance.client.from('quotes').select();
    return (data as List).map((j) => Quote.fromJson(j)).toList();
  }
}

final quotesProvider =
    AsyncNotifierProvider<QuotesNotifier, List<Quote>>(QuotesNotifier.new);

final searchProvider = NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final filteredQuotesProvider = Provider<AsyncValue<List<Quote>>>((ref) {
  final quotesAsync = ref.watch(quotesProvider);
  final search = ref.watch(searchProvider).toLowerCase();

  return quotesAsync.whenData((quotes) => quotes
      .where((q) => q.shortText.toLowerCase().contains(search))
      .toList());
});

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
    final filteredAsync = ref.watch(filteredQuotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quotes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search quotes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  ref.read(searchProvider.notifier).update(value),
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (quotes) => quotes.isEmpty
                  ? const Center(child: Text('No quotes found.'))
                  : ListView.builder(
                      itemCount: quotes.length,
                      itemBuilder: (context, index) {
                        final quote = quotes[index];
                        return ListTile(
                          title: Text(quote.shortText),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuoteDetailScreen(quote: quote),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quote')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          quote.fullText,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}