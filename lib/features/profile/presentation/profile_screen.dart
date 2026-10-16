import 'package:flutter/material.dart';

/// The Profile destination (S14).
///
/// **Placeholder only.** `GET /users/me` exists in the backend, but this screen
/// does not call it. There is no session, no sign-in, and no account data.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text('Profile', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Not implemented yet.', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'This placeholder shows no account. Sign-in is not implemented, '
                'so there is no session to display.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
