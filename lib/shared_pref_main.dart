import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_pref_detail.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

final items = [
  {'id': '1', 'name': 'Apple', 'color': Colors.red},
  {'id': '2', 'name': 'Blueberry', 'color': Colors.blue},
  {'id': '3', 'name': 'Lime', 'color': Colors.green},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selected;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selected = prefs.getInt('selected_index');
    });
  }

  Future<void> _savePrefs(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_index', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruits')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              setState(() => selected = index);
              _savePrefs(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(item: item),
                ),
              );
            },
            child: Hero(
              tag: item['id']!,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == index ? Colors.black : Colors.white,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    item['name'] as String,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}