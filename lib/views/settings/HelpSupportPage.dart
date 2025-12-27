import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _email() async {
    final uri = Uri.parse('mailto:support@filevo.app?subject=Filevo Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle: 'Common questions',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('FAQ coming soon')));
            },
          ),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'support@filevo.app',
            onTap: _email,
          ),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            onTap: _email,
          ),
        ],
      ),
    );
  }
}
