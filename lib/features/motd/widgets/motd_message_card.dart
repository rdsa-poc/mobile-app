import 'package:flutter/material.dart';

class MotdMessageCard extends StatelessWidget {
  const MotdMessageCard({
    super.key,
    required this.message,
    required this.path,
  });

  final String? message;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Realtime MOTD',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Subscribed path: $path'),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
