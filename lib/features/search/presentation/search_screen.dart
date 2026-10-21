import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import '../application/search_controller.dart';
import '../application/search_state.dart';
import '../domain/search_collection.dart';
import '../domain/search_query.dart';
import 'widgets/search_collection_row.dart';

/// The Search destination (S11).
///
/// **Explicit submission, never live search.** Typing does not issue a request;
/// the keyboard's Search action (or another explicit submission) does. The
/// initial screen requests nothing, which is both the quiet state the design
/// calls for and what keeps a visit from spending the endpoint's per-user rate
/// limit.
///
/// The response has two independent groups. They render **Collections first,
/// then Saved Items**, each in the order the server sent it. Nothing is merged,
/// re-sorted, paginated or filtered.
///
/// **Zero results is a successful response**, not an error. It is drawn as a
/// message and never claims that anything was never saved.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();

  /// The local validation problem currently shown, if any.
  ///
  /// Local so an invalid query can be corrected without ever reaching the
  /// backend. It is cleared on the next edit or valid submission.
  SearchQueryProblem? _queryProblem;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // The Clear action's visibility and the validation message both depend on
    // the text, so this rebuild is necessary even though no request is made.
    setState(() => _queryProblem = null);

    // An empty field cannot describe the results on screen any more. Resetting
    // here also invalidates an in-flight request, so deleting the query cannot
    // let old results reappear later.
    if (value.isEmpty) ref.read(searchProvider.notifier).clear();
  }

  void _submit() {
    final problem = validateSearchQuery(_queryController.text);

    if (problem != null) {
      // Retain the input so it can be corrected. This is not a server response
      // and must not be presented as one.
      setState(() => _queryProblem = problem);
      return;
    }

    setState(() => _queryProblem = null);
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(searchProvider.notifier).submit(_queryController.text);
  }

  /// Empties the field and returns to the quiet initial state.
  ///
  /// `clear` also invalidates an in-flight request, so a late answer cannot
  /// restore results for a query the field no longer holds. It never submits:
  /// an empty query is not a search.
  void _clear() {
    _queryController.clear();
    setState(() => _queryProblem = null);
    ref.read(searchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        // Written uppercase at the call site: Flutter has no text-transform.
        title: const Text('SEARCH'),
      ),
      body: Column(
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
            // The field is the whole row now: the clear action lives inside it,
            // on the same trailing edge Material gives a suffix action.
            child: AppField(
              controller: _queryController,
              placeholder: 'Search saved items and collections',
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              onChanged: _onChanged,
              // Non-empty, not non-blank: whitespace is still text the user can
              // clear, and submitting it is already refused by the local gate.
              onClear: _queryController.text.isNotEmpty ? _clear : null,
              // The field takes the approved invalid border and message
              // treatment rather than a second copy rendered beside it.
              errorText: switch (_queryProblem) {
                final problem? => _problemCopy(problem),
                null => null,
              },
            ),
          ),
          Expanded(child: _content(state)),
        ],
      ),
    );
  }

  Widget _content(SearchState state) {
    return switch (state) {
      SearchInitial() => const _SearchMessage(
        title: 'Find something you saved',
        body: 'Search matches item titles, domains, URLs and collection names.',
      ),
      SearchLoading() => const _SearchLoading(),
      SearchSuccess(:final query, :final collections, :final savedItems) =>
        collections.isEmpty && savedItems.isEmpty
            ? _SearchMessage(
                title: 'No matches for \u2018$query\u2019',
                body:
                    'An item may still match by title, domain, URL or '
                    'collection name. Try a different word, or browse '
                    'Collections.',
              )
            : _SearchResults(collections: collections, savedItems: savedItems),
      SearchFailure(:final failure) => _SearchMessage(
        title: 'Search did not run',
        body: _failureCopy(failure),
        action: AppButton(
          label: 'Retry',
          variant: AppButtonVariant.secondary,
          block: false,
          onPressed: () => ref.read(searchProvider.notifier).retry(),
        ),
      ),
    };
  }

  static String _problemCopy(SearchQueryProblem problem) => switch (problem) {
    SearchQueryProblem.empty => 'Enter something to search for.',
    SearchQueryProblem.tooShort => 'Search needs at least 2 characters.',
    SearchQueryProblem.tooLong =>
      'Search is limited to 128 characters. Shorten it and try again.',
  };

  /// Client-owned copy for a failed search read.
  ///
  /// **[D22] Selected from the typed failure, never from a backend message.**
  /// Nothing here names a backend code or status. A read is not a write, so
  /// every message says the search did not run rather than suggesting an item's
  /// fate.
  static String _failureCopy(Object failure) => switch (failure) {
    // Local validation should prevent this, but the backend owns the rule and
    // can still answer with it. Handle it explicitly so it never falls through
    // to the unreadable-response copy, which would describe the wrong problem.
    ApiFailureValidation() =>
      'Search needs between 2 and 128 characters. Check your search and try '
          'again.',
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to search.',
    ApiFailureAuthRequired() => 'Sign in again to search.',
    ApiFailureRateLimited(:final retryAfter) =>
      retryAfter != null
          ? 'Too many searches. Try again in ${retryAfter.inSeconds} seconds.'
          : 'Too many searches. Try again shortly.',
    ApiFailureServerUnavailable() =>
      'Search is temporarily unavailable. Try again shortly.',
    ApiFailureTransport() =>
      'No connection to the server. We could not run your search.',
    _ =>
      genericReadFailureMessage(failure) ??
          'We could not run your search. Try again.',
  };
}

/// The compact spinner Search uses while a query is in flight.
///
/// **Not Skeletonizer.** Search results are transient and query-dependent, so a
/// skeleton that mirrors a previous result set would imply rows are already
/// known. A small spinner says only that work is happening.
class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Semantics(
        label: 'Searching',
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

/// The two populated groups, Collections first, each in the server's order.
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.collections, required this.savedItems});

  final List<SearchCollection> collections;
  final List<SavedItemSummary> savedItems;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.screenPadding,
        AppMetrics.space2,
        AppMetrics.screenPadding,
        AppMetrics.space4,
      ),
      children: [
        if (collections.isNotEmpty) ...[
          const _GroupHeading('COLLECTIONS'),
          for (final collection in collections)
            SearchCollectionRow(collection: collection),
        ],
        if (savedItems.isNotEmpty) ...[
          if (collections.isNotEmpty) const SizedBox(height: AppMetrics.space4),
          const _GroupHeading('SAVED ITEMS'),
          for (var index = 0; index < savedItems.length; index++) ...[
            SavedItemRow(
              item: savedItems[index],
              // There is no saved-item detail route yet, so the row must not
              // look tappable and must not promise a destination.
              onTap: null,
              // Search has no enrichment retry action. The row's own state
              // wording still reports pending and failed accurately.
              onRetry: null,
            ),
            if (index < savedItems.length - 1) const SizedBox(height: 9),
          ],
        ],
      ],
    );
  }
}

/// A section eyebrow in the Search results.
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

/// A centred message: the quiet initial state, a successful empty result, or a
/// failed read with its Retry action.
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
