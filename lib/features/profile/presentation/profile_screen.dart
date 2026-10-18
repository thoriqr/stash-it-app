import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

/// The Profile destination (S14).
///
/// **Partly implemented.** Sign-in, sign-out and session handling exist; the
/// profile itself does not. `GET /users/me` is implemented in the backend and is
/// not called here — D10 limits this screen to profile and account actions, and
/// the account data is the next milestone's work.
///
/// No authentication check lives in this widget. The router redirect decides
/// whether a session exists; a per-screen guard would be a second copy of that
/// decision that could disagree (`AGENTS.md` §2, rule 5).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      // Written uppercase at the call site: Flutter has no text-transform.
      appBar: AppBar(title: const Text('PROFILE')),
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
              Text(
                'Your account details are not shown yet.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: tokens.textTertiary),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Signs out and lets the router redirect to sign-in.
  ///
  /// No confirmation dialog and no success message: **[Confirmed]** the outcome
  /// is communicated by the screen change, and a dialog would be one more thing
  /// to be dismissed before the user is signed out.
  ///
  /// [AuthState.signOut] clears local credentials whether or not the server
  /// call succeeded, so this cannot leave the app apparently signed in.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).signOut();
  }
}
