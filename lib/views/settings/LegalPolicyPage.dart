import 'package:flutter/material.dart';

class LegalPolicyPage extends StatelessWidget {
  const LegalPolicyPage({super.key});

  Widget _section(BuildContext context, String title, String content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal & Policies')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            context,
            'Privacy Policy',
            'Your files are securely stored and encrypted. We do not share your '
                'data with third parties. Authentication tokens are stored securely '
                'on your device.',
          ),
          const SizedBox(height: 12),
          _section(
            context,
            'Terms of Service',
            'By using this app, you agree not to upload illegal content. You are '
                'fully responsible for the files you upload or share.',
          ),
        ],
      ),
    );
  }
}
