import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usernameProvider = NotifierProvider<UsernameNotifier, String>(UsernameNotifier.new);

class UsernameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

void main() {
  runApp(const ProviderScope(child: UsernameApp()));
}

class UsernameApp extends StatelessWidget {
  const UsernameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: UsernameScreen());
  }
}

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Username')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UsernameField(),
            SizedBox(height: 24),
            UsernameGreeting(),
          ],
        ),
      ),
    );
  }
}

class UsernameField extends ConsumerWidget {
  const UsernameField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Enter your name',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => ref.read(usernameProvider.notifier).update(value),
    );
  }
}

class UsernameGreeting extends ConsumerWidget {
  const UsernameGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    return Text(
      username.isEmpty ? 'Hello, stranger!' : 'Hello, $username!',
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }
}