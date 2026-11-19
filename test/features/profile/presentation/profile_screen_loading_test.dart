import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';
import 'package:stash_it_app/features/profile/presentation/profile_screen.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../../support/fake_profile_repository.dart';

void main() {
  testWidgets(
    'loading shows the profile skeleton and keeps sign out outside it',
    (tester) async {
      final gate = Completer<void>();
      final repository = FakeProfileRepository()..getUserGate = gate;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(repository)],
          child: SkeletonizerConfig(
            data: appSkeletonizerConfig(Brightness.light),
            child: MaterialApp(
              theme: AppTheme.light(),
              locale: const Locale('en'),
              supportedLocales: const [Locale('en')],
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const ProfileScreen(),
            ),
          ),
        ),
      );

      // The read is held open, so the provider remains AsyncLoading.
      await tester.pump();

      // `Skeletonizer` builds the package's private `_Skeletonizer` widget, so
      // a direct byType lookup on the public wrapper would find nothing.
      final skeleton = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_Skeletonizer',
        description: 'Skeletonizer',
      );

      expect(skeleton, findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loading profile…'), findsNothing);
      expect(find.text('you@example.com'), findsOneWidget);
      expect(find.text('reader@example.com'), findsNothing);
      expect(find.text('Sign out'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('Sign out'), matching: skeleton),
        findsNothing,
        reason: 'the sign-out action must not be part of the skeleton',
      );

      gate.complete();
      await tester.pump();
      await tester.pump();

      expect(find.text('reader@example.com'), findsOneWidget);
      expect(find.text('you@example.com'), findsNothing);
      expect(find.text('Sign out'), findsOneWidget);
      expect(skeleton, findsNothing);
    },
  );
}
