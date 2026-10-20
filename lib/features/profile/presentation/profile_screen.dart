import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';

/// The Profile destination.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTheme.tokensOf(context);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: [
                _ProfileHeader(profile: profile, tokens: tokens),
                const SizedBox(height: 24),
                _LinkedIdentitiesSection(profile: profile, tokens: tokens),
                const SizedBox(height: 24),
                _AccountActions(tokens: tokens, ref: ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.tokens});

  final AsyncValue<UserProfile> profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: AppTypography.sectionLabel.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border.all(color: tokens.border),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
          child: switch (profile) {
            AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.displayName.isNotEmpty
                      ? value.displayName
                      : value.email,
                  style: AppTypography.screenHeading.copyWith(
                    color: tokens.textPrimary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.email,
                  style: AppTypography.meta.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value.hasPasswordCredential
                      ? 'Password set'
                      : 'No password set',
                  style: AppTypography.label.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ],
            ),
            AsyncLoading() => Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tokens.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading profile…',
                  style: AppTypography.body.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
            AsyncError(:final error) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _errorMessage(error),
                  style: AppTypography.body.copyWith(color: tokens.textPrimary),
                ),
              ],
            ),
          },
        ),
      ],
    );
  }

  String _errorMessage(Object error) => switch (error) {
    ApiFailureSessionEnded() => 'Your session has ended. Sign in again.',
    ApiFailureAuthRequired() => 'Sign in again to view your profile.',
    ApiFailureServerUnavailable() =>
      'Profile is temporarily unavailable. Try again shortly.',
    ApiFailureServerFault() => 'We could not reach the server. Try again.',
    ApiFailureTransport() => 'No connection. We could not load your profile.',
    ApiFailureUnreadableResponse() ||
    ApiFailureMalformedRequest() ||
    ApiFailureValidation() => "We couldn't read the server's reply. Try again.",
    _ => 'We could not load your profile. Try again.',
  };
}

class _LinkedIdentitiesSection extends ConsumerWidget {
  const _LinkedIdentitiesSection({required this.profile, required this.tokens});

  final AsyncValue<UserProfile> profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LINKED IDENTITIES',
          style: AppTypography.sectionLabel.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border.all(color: tokens.border),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
          child: switch (profile) {
            AsyncData(:final value) =>
              value.identities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No linked identities.',
                        style: AppTypography.body.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < value.identities.length; i++) ...[
                          _IdentityRow(
                            identity: value.identities[i],
                            tokens: tokens,
                          ),
                          if (i < value.identities.length - 1)
                            Divider(height: 1, color: tokens.border),
                        ],
                      ],
                    ),
            AsyncLoading() => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loading identities…',
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
            ),
            AsyncError() => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load identities.',
                style: AppTypography.body.copyWith(color: tokens.textPrimary),
              ),
            ),
          },
        ),
      ],
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.identity, required this.tokens});

  final UserIdentity identity;
  final AppTokens tokens;

  IconData _iconFor(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'github':
        return Icons.code;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            _iconFor(identity.provider),
            size: 18,
            color: tokens.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.displayLabel,
                  style: AppTypography.body.copyWith(color: tokens.textPrimary),
                ),
                if (identity.emailSnapshot != null &&
                    identity.emailSnapshot!.isNotEmpty)
                  Text(
                    identity.emailSnapshot!,
                    style: AppTypography.meta.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'Linked',
            style: AppTypography.label.copyWith(color: tokens.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _AccountActions extends ConsumerWidget {
  const _AccountActions({required this.tokens, required this.ref});

  final AppTokens tokens;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT ACTIONS',
          style: AppTypography.sectionLabel.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}
