import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Enable Fingerprint / Face ID'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Two-Factor Authentication'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
