import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

import '../../domain/search_collection.dart';

/// One collection result, in the Search feature's compact row form.
///
/// **Only what `/search` returns: a name.** No count, type, system marker or
/// timestamp is available, so none is shown.
///
/// **No trailing kind label and no chevron.** The `COLLECTIONS` group heading
/// already says what these rows are, and there is no collection-contents route
/// in this client yet, so a chevron or tap target would promise a destination
/// that does not exist. The row is deliberately non-interactive.
class SearchCollectionRow extends StatelessWidget {
  const SearchCollectionRow({super.key, required this.collection});

  final SearchCollection collection;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Container(
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
    );
  }
}
