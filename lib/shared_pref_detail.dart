import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, Object> item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item['name'] as String)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.item['id']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: _expanded ? 300 : 150,
                height: _expanded ? 300 : 150,
                decoration: BoxDecoration(
                  color: widget.item['color'] as Color,
                  borderRadius: BorderRadius.circular(_expanded ? 40 : 12),
                ),
                child: Center(
                  child: Text(
                    widget.item['name'] as String,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Shrink' : 'Expand'),
            ),
          ],
        ),
      ),
    );
  }
}