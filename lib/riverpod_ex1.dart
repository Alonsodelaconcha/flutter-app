import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final likesProvider = NotifierProvider<LikesNotifier, int>(LikesNotifier.new);

class LikesNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

void main() {
  runApp(const ProviderScope(child: LikesApp()));
}

class LikesApp extends StatelessWidget {
  const LikesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LikesScreen());
  }
}

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Likes')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LikeButton(),
            SizedBox(height: 24),
            LikeCounter(),
          ],
        ),
      ),
    );
  }
}

class LikeButton extends ConsumerWidget {
  const LikeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      iconSize: 64,
      icon: const Icon(Icons.favorite, color: Colors.red),
      onPressed: () => ref.read(likesProvider.notifier).increment(),
    );
  }
}

class LikeCounter extends ConsumerWidget {
  const LikeCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likes = ref.watch(likesProvider);
    return Text(
      '$likes likes',
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}