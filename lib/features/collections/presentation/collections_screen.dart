import 'package:flutter/material.dart';

/// The Collections destination (S8).
///
/// **Placeholder only.** `GET /collections` exists in the backend, but this
/// screen does not call it. It shows no collections, no counts, and no actions.
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text('Collections', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Not implemented yet.', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'This placeholder shows no collections. Nothing is loaded from '
                'the backend yet.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
