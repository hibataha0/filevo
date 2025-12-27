import 'package:flutter/material.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    double used = 4; // GB
    double total = 10; // GB
    double percent = used / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Usage',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: percent, minHeight: 10),
                    const SizedBox(height: 8),
                    Text(
                      'Used ${used.toStringAsFixed(1)} GB of ${total.toStringAsFixed(1)} GB',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: const Text('Buy More Storage'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchase flow coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
