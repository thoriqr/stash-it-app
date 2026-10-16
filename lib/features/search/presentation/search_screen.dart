import 'package:flutter/material.dart';

/// The Search destination (S11).
///
/// **Placeholder only.** `GET /search` exists in the backend, but this screen
/// does not call it. No query is submitted and no results are produced.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text('Search', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Not implemented yet.', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'This placeholder cannot search. No query is sent to the '
                'backend yet.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
