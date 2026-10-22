import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

import '../../domain/search_collection.dart';

/// One collection result, in the Search feature's compact row form.
///
/// **Only what `/search` returns: a name.** No count, type, system marker or
/// timestamp is available, so none is shown.
///
/// **No trailing kind label and no chevron.** The `COLLECTIONS` group heading
/// already says what these rows are, and the row itself is the tap target. It
/// opens the collection's existing detail screen by [SearchCollection.id]; it
/// does not add a second destination or a second collection screen.
class SearchCollectionRow extends StatelessWidget {
  const SearchCollectionRow({
    super.key,
    required this.collection,
    required this.onTap,
  });

  final SearchCollection collection;

  /// Opens the collection named by [collection].
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
          ),
          child: Text(
            collection.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
