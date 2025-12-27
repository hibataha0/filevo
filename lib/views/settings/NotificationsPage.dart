import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool push = true;
  bool email = false;
  bool sms = false;

  Widget _section(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Push Notifications', [
            SwitchListTile(
              title: const Text('Enable Push'),
              value: push,
              onChanged: (v) => setState(() => push = v),
            ),
          ]),
          _section('Email Notifications', [
            SwitchListTile(
              title: const Text('Enable Email'),
              value: email,
              onChanged: (v) => setState(() => email = v),
            ),
          ]),
          _section('SMS Notifications', [
            SwitchListTile(
              title: const Text('Enable SMS'),
              value: sms,
              onChanged: (v) => setState(() => sms = v),
            ),
          ]),
        ],
      ),
    );
  }
}
