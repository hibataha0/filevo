import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 42, child: Icon(Icons.cloud, size: 42)),
              const SizedBox(height: 16),
              Text(
                'Filevo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Secure Cloud Storage Application',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text('Version 1.0.0'),
              const SizedBox(height: 12),
              const Text(
                'Developed by\nHiba Taha\nAn-Najah National University',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('© 2025 Filevo'),
            ],
          ),
        ),
      ),
    );
  }
}
