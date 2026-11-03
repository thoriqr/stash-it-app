import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';
import 'package:stash_it_app/shared/widgets/destination_app_bar.dart';

import '../application/search_controller.dart';
import '../application/search_state.dart';
import '../domain/search_collection.dart';
import '../domain/search_query.dart';
import 'widgets/search_collection_row.dart';

/// The Search destination.
///
/// Search uses explicit submission rather than live search. Typing does not
/// issue a request; submitting through the keyboard's Search action or another
/// explicit action does. The initial state makes no request, so opening the
/// screen does not consume the endpoint's per-user rate limit.
///
/// Results contain two independent groups: Collections first, followed by
/// Saved Items. Each group preserves the order returned by the server. The
/// screen does not merge, re-sort, paginate or filter the results.
///
/// An empty result is a successful response, not an error. The screen displays
/// a neutral message without implying that anything was never saved.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();

  /// The local validation problem currently displayed, if any.
  ///
  /// Validation happens before submission, so invalid input never reaches the
  /// backend. The problem is cleared when the user edits the query or submits
  /// a valid one.
  SearchQueryProblem? _queryProblem;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Rebuild because both the Clear action and validation message depend on
    // the current text. Editing does not trigger a search request.
    setState(() => _queryProblem = null);

    // Once the field is empty, the displayed results no longer represent its
    // contents. Clearing the provider also invalidates any request in flight.
    if (value.isEmpty) ref.read(searchProvider.notifier).clear();
  }

  void _submit() {
    final problem = validateSearchQuery(_queryController.text);

    if (problem != null) {
      // Keep the input available for correction. This is a local validation
      // result, not a response from the server.
      setState(() => _queryProblem = problem);
      return;
    }

    setState(() => _queryProblem = null);
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(searchProvider.notifier).submit(_queryController.text);
  }

  /// Clears the input and restores the initial Search state.
  ///
  /// Clearing also invalidates any request in flight, preventing a late
  /// response from restoring results for a query that is no longer present.
  /// This does not submit an empty query.
  void _clear() {
    _queryController.clear();
    setState(() => _queryProblem = null);
    ref.read(searchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: DestinationAppBar(title: l10n.searchTitle),
      body: DesktopContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppMetrics.screenPadding,
                AppMetrics.space3,
                AppMetrics.screenPadding,
                AppMetrics.space3,
              ),
              decoration: BoxDecoration(
                color: tokens.surface,
                border: Border(bottom: BorderSide(color: tokens.border)),
              ),
              // The Clear action is placed inside the field, alongside its
              // trailing input action.
              child: AppField(
                controller: _queryController,
                placeholder: l10n.searchPlaceholder,
                prefixIcon: Icons.search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
                onChanged: _onChanged,
                // Any non-empty input can be cleared, including whitespace.
                // Whitespace-only queries are rejected by local validation.
                onClear: _queryController.text.isNotEmpty ? _clear : null,
                // Display validation feedback through the field's own error
                // treatment rather than rendering a separate message.
                errorText: switch (_queryProblem) {
                  final problem? => _problemCopy(problem, l10n),
                  null => null,
                },
              ),
            ),
            Expanded(child: _content(state, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _content(SearchState state, AppLocalizations localizations) {
    return switch (state) {
      SearchInitial() => _SearchMessage(
        title: localizations.searchInitialTitle,
        body: localizations.searchInitialBody,
      ),
      SearchLoading() => const _SearchLoading(),
      SearchSuccess(:final query, :final collections, :final savedItems) =>
        collections.isEmpty && savedItems.isEmpty
            ? _SearchMessage(
                title: localizations.searchNoMatchesTitle(query),
                body: localizations.searchNoMatchesBody,
              )
            : _SearchResults(collections: collections, savedItems: savedItems),
      SearchFailure(:final failure) => _SearchMessage(
        title: localizations.searchFailureTitle,
        body: _failureCopy(failure, localizations),
        action: AppButton(
          label: localizations.searchRetry,
          variant: AppButtonVariant.secondary,
          block: false,
          onPressed: () => ref.read(searchProvider.notifier).retry(),
        ),
      ),
    };
  }

  static String _problemCopy(
    SearchQueryProblem problem,
    AppLocalizations localizations,
  ) => switch (problem) {
    SearchQueryProblem.empty => localizations.searchQueryRequired,
    SearchQueryProblem.tooShort => localizations.searchQueryTooShort(
      searchQueryMinRunes,
    ),
    SearchQueryProblem.tooLong => localizations.searchQueryTooLong(
      searchQueryMaxRunes,
    ),
  };

  /// Selects client-owned copy for a failed search request.
  ///
  /// Messages are based on the typed failure rather than backend response
  /// text. Since search is a read operation, the copy describes the failed
  /// search without making claims about the state of any saved item.
  static String _failureCopy(Object failure, AppLocalizations localizations) =>
      switch (failure) {
        // Handle server-side validation explicitly. Although local validation
        // normally prevents this, the backend remains authoritative.
        ApiFailureValidation() => localizations.searchValidationFailure(
          searchQueryMinRunes,
          searchQueryMaxRunes,
        ),
        ApiFailureSessionEnded() => localizations.searchSessionEnded,
        ApiFailureAuthRequired() => localizations.searchSignInRequired,
        ApiFailureRateLimited(:final retryAfter) =>
          retryAfter != null
              ? localizations.searchRateLimitedWithWait(retryAfter.inSeconds)
              : localizations.searchRateLimitedNoWait,
        ApiFailureServerUnavailable() => localizations.searchUnavailable,
        ApiFailureTransport() => localizations.searchTransport,
        _ =>
          genericReadFailureMessage(failure, localizations) ??
              localizations.searchFailureGeneric,
      };
}

/// Shows a compact progress indicator while a search request is in flight.
///
/// A spinner is used instead of Skeletonizer because results depend on the
/// current query and are not known in advance. It indicates only that a
/// request is running, without implying that previous result rows are loading.
class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Semantics(
        label: l10n.searchSearchingSemantics,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: tokens.accent,
          ),
        ),
      ),
    );
  }
}

/// Displays the two populated result groups, Collections first.
///
/// Each group preserves the order returned by the server.
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.collections, required this.savedItems});

  final List<SearchCollection> collections;
  final List<SavedItemSummary> savedItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.screenPadding,
        AppMetrics.space2,
        AppMetrics.screenPadding,
        AppMetrics.space4,
      ),
      children: [
        if (collections.isNotEmpty) ...[
          _GroupHeading(l10n.searchCollectionsHeading),
          for (final collection in collections)
            SearchCollectionRow(
              collection: collection,
              // The collection detail is pushed above the shell. Returning
              // reveals Search with its query and results still mounted.
              // The destination loads the collection again by ID rather than
              // treating this result's name as current data.
              onTap: () =>
                  context.push(AppRoutes.collectionDetail(collection.id)),
            ),
        ],
        if (savedItems.isNotEmpty) ...[
          if (collections.isNotEmpty) const SizedBox(height: AppMetrics.space4),
          _GroupHeading(l10n.searchSavedItemsHeading),
          for (var index = 0; index < savedItems.length; index++) ...[
            SavedItemRow(
              item: savedItems[index],
              // Reuse the detail route used by the Inbox. Search remains
              // mounted underneath it, and the detail loads the item by ID.
              onTap: () =>
                  context.push(AppRoutes.savedItemDetail(savedItems[index].id)),
              // Search does not expose an enrichment retry action. The row
              // still displays the item's pending or failed status.
              onRetry: null,
            ),
            if (index < savedItems.length - 1) const SizedBox(height: 9),
          ],
        ],
      ],
    );
  }
}

/// A section heading within the Search results.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppMetrics.space2,
        bottom: AppMetrics.space1,
      ),
      child: Text(
        label,
        style: AppTypography.sectionLabel.copyWith(color: tokens.textTertiary),
      ),
    );
  }
}

/// Displays the initial prompt, an empty-result message or a failed-search
/// message with its optional Retry action.
class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.title, required this.body, this.action});

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            if (action case final action?) ...[
              const SizedBox(height: AppMetrics.space4),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
