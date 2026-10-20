import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'profile_date.dart';

/// The Profile destination.
///
/// Laid out as the reference's compact bands rather than cards: an identity
/// header, an account section, the linked identities, and one block action.
/// Every date is optional, because a timestamp the client could not parse is
/// omitted rather than replaced with the current date.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTheme.tokensOf(context);
    final profile = ref.watch(profileProvider);

    final sections = switch (profile) {
      AsyncData(:final value) => <Widget>[
        _AccountSection(profile: value, tokens: tokens),
        _LinkedIdentitiesSection(profile: value, tokens: tokens),
      ],
      _ => const <Widget>[],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(
            profile: profile,
            tokens: tokens,
            onRetry: () => ref.read(profileProvider.notifier).retry(),
          ),
          ...sections,
          Padding(
            padding: const EdgeInsets.all(AppMetrics.space4),
            child: AppButton(
              label: 'Sign out',
              variant: AppButtonVariant.secondary,
              onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The identity band: name, email and joined date, or the current request state.
///
/// The band keeps its place in every state, so the page does not jump between a
/// full screen of content and a full-screen spinner.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.tokens,
    required this.onRetry,
  });

  final AsyncValue<UserProfile> profile;
  final AppTokens tokens;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space4),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: switch (profile) {
        AsyncData(:final value) => _IdentitySummary(
          value: value,
          tokens: tokens,
        ),
        AsyncLoading() => _HeaderLoading(tokens: tokens),
        AsyncError(:final error) => _HeaderError(
          error: error,
          tokens: tokens,
          onRetry: onRetry,
        ),
      },
    );
  }
}

class _IdentitySummary extends StatelessWidget {
  const _IdentitySummary({required this.value, required this.tokens});

  final UserProfile value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final displayName = value.displayName.trim();
    final email = value.email.trim();
    final joined = formatProfileDate(value.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName.isNotEmpty ? displayName : email,
          style: AppTypography.variable(
            AppTypography.uiFamily,
            17,
            1.2,
            FontWeight.w600,
            tracking: -0.255,
            color: tokens.textPrimary,
          ),
        ),
        // When there is no display name the email is already the heading above,
        // so repeating it here would show the same line twice.
        if (displayName.isNotEmpty && email.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            email,
            style: AppTypography.mono.copyWith(color: tokens.textTertiary),
          ),
        ],
        if (joined != null) ...[
          const SizedBox(height: AppMetrics.space2),
          _DateChip(label: 'joined $joined', tokens: tokens),
        ],
      ],
    );
  }
}

/// The `.ds-chip` treatment, used for the joined date.
class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.tokens});

  final String label;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        border: Border.all(color: tokens.accentBorder),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: tokens.accent),
      ),
    );
  }
}

class _HeaderLoading extends StatelessWidget {
  const _HeaderLoading({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: tokens.accent,
          ),
        ),
        const SizedBox(width: AppMetrics.space3),
        Text(
          'Loading profile…',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }
}

class _HeaderError extends StatelessWidget {
  const _HeaderError({
    required this.error,
    required this.tokens,
    required this.onRetry,
  });

  final Object error;
  final AppTokens tokens;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _profileErrorMessage(error),
          style: AppTypography.body.copyWith(color: tokens.textPrimary),
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Retry',
          variant: AppButtonVariant.secondary,
          block: false,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

String _profileErrorMessage(Object error) => switch (error) {
  ApiFailureSessionEnded() => 'Your session has ended. Sign in again.',
  ApiFailureAuthRequired() => 'Sign in again to view your profile.',
  ApiFailureServerUnavailable() =>
    'Profile is temporarily unavailable. Try again shortly.',
  ApiFailureTransport() => 'No connection. We could not load your profile.',
  _ =>
    genericReadFailureMessage(error) ??
        'We could not load your profile. Try again.',
};

/// A section heading with the reference's rule running to the right edge.
class _SectionLabelRow extends StatelessWidget {
  const _SectionLabelRow({required this.label, required this.tokens});

  final String label;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space4,
        AppMetrics.space3,
        AppMetrics.space4,
        AppMetrics.space1,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.sectionLabel.copyWith(
              color: tokens.textTertiary,
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          Expanded(
            child: Container(
              height: AppMetrics.borderWidth,
              color: tokens.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.profile, required this.tokens});

  final UserProfile profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.displayName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabelRow(label: 'ACCOUNT', tokens: tokens),
        _InfoRow(
          label: 'Display name',
          value: displayName.isEmpty ? '—' : displayName,
          tokens: tokens,
        ),
        _PasswordActionRow(
          hasPasswordCredential: profile.hasPasswordCredential,
          tokens: tokens,
        ),
      ],
    );
  }
}

/// A compact account row: label on the left, a quiet mono value on the right.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space3,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _rowLabelStyle(tokens))),
          const SizedBox(width: AppMetrics.space3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTypography.monoSmall.copyWith(
                color: tokens.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(profile): navigate to and implement password creation/change. This row is
// a visual placeholder only — no password-management flow exists in this client.
class _PasswordActionRow extends StatelessWidget {
  const _PasswordActionRow({
    required this.hasPasswordCredential,
    required this.tokens,
  });

  final bool hasPasswordCredential;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasPasswordCredential ? 'Change password' : 'Create password',
              style: _rowLabelStyle(tokens),
            ),
          ),
          _Chevron(tokens: tokens),
        ],
      ),
    );
  }
}

/// The reference's disclosure chevron (`.ds-chev`), drawn rather than iconed so
/// it keeps the 7 px, 1.5 px-stroke geometry.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: tokens.textTertiary, width: 1.5),
            bottom: BorderSide(color: tokens.textTertiary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _LinkedIdentitiesSection extends StatelessWidget {
  const _LinkedIdentitiesSection({required this.profile, required this.tokens});

  final UserProfile profile;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabelRow(label: 'LINKED IDENTITIES', tokens: tokens),
        if (profile.identities.isEmpty)
          _EmptyIdentities(tokens: tokens)
        else
          for (final identity in profile.identities)
            _IdentityRow(
              identity: identity,
              accountEmail: profile.email,
              accountDisplayName: profile.displayName,
              tokens: tokens,
            ),
      ],
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.identity,
    required this.accountEmail,
    required this.accountDisplayName,
    required this.tokens,
  });

  final UserIdentity identity;
  final String accountEmail;
  final String accountDisplayName;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final linked = formatProfileDate(identity.linkedAt);
    final note = linked != null ? 'linked $linked' : _usefulSnapshot();

    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(identity.displayLabel, style: _rowLabelStyle(tokens)),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(
              note,
              style: AppTypography.variable(
                AppTypography.uiFamily,
                11.5,
                1.35,
                FontWeight.w400,
                color: tokens.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// A snapshot is shown only when it is present, different from the account
  /// value already displayed above, and the linked date is unavailable.
  String? _usefulSnapshot() {
    final email = identity.emailSnapshot?.trim() ?? '';
    if (email.isNotEmpty && email != accountEmail.trim()) return email;

    final displayName = identity.displayNameSnapshot?.trim() ?? '';
    if (displayName.isNotEmpty && displayName != accountDisplayName.trim()) {
      return displayName;
    }

    return null;
  }
}

class _EmptyIdentities extends StatelessWidget {
  const _EmptyIdentities({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space4,
      ),
      child: Text(
        'No accounts connected yet.',
        style: AppTypography.body.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}

TextStyle _rowLabelStyle(AppTokens tokens) => AppTypography.variable(
  AppTypography.uiFamily,
  13.5,
  1.3,
  FontWeight.w500,
  color: tokens.textPrimary,
);
