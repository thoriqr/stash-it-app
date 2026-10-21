import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';

/// One placeholder row, shown while the Inbox listing is loading.
///
/// **The real row, painted over.** This used to hand-draw a second copy of the
/// saved-item layout in bars, which meant the two could disagree: any change to
/// [SavedItemRow]'s padding, clamps or metadata line silently left the loading
/// state describing a card the app no longer renders. Building the actual widget
/// and skeletonizing it makes that failure impossible — the placeholder *is* the
/// row, so it is the same height, the same thumbnail and the same metadata line
/// by construction rather than by agreement.
///
/// The shimmer treatment itself is shared: `StashItApp` installs one
/// [SkeletonizerConfig] for every route, so a Collections list or a saved-item
/// listing that arrives later inherits the same treatment without restating it.
class SavedItemSkeleton extends StatelessWidget {
  const SavedItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Skeletonizer(child: SavedItemRow(item: _placeholder));
  }
}

/// The item the placeholder row is built from.
///
/// **Not filler copy.** A bone takes the width of the text it replaces, so every
/// field here is chosen to make the card occupy the shape a real one will:
///
/// * a title and a description long enough to fill their two-line clamps, so the
///   placeholder is not shorter than the rows that replace it;
/// * a saved-time label, so the top-right slot is exercised rather than left
///   empty;
/// * [EnrichmentStatus.pending], the state whose metadata line is the widest —
///   chip, pip and wording — without borrowing the failure colour;
/// * `hasPreviewImage: true`, because the hatch is how the well actually looks,
///   and [SavedItemRow] keeps its custom painting out of skeletonization.
///
/// `id` is never rendered; the model requires one and this one exists only to
/// fill it.
const SavedItemSummary _placeholder = SavedItemSummary(
  id: 'skeleton',
  collectionId: 'skeleton',
  url: 'https://example.com/articles/quiet-mornings',
  collectionName: 'Unsorted',
  enrichmentStatus: EnrichmentStatus.pending,
  title: 'A page title about as long as a real one tends to run',
  description:
      'A description long enough to fill the two-line clamp, so the placeholder '
      'keeps the height a real row occupies.',
  hasPreviewImage: true,
  savedTimeLabel: 'Saved just now',
);

/// A block of skeleton rows, for the Inbox's loading state.
class SavedItemSkeletonList extends StatelessWidget {
  const SavedItemSkeletonList({super.key, this.count = 4});

  /// How many placeholder rows to draw.
  ///
  /// Fixed rather than derived from a screen size: a skeleton that changes its
  /// own height is a second layout rule, and four rows already fill the space
  /// before the real rows arrive.
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space3,
        AppMetrics.space2,
        AppMetrics.space3,
        AppMetrics.space4,
      ),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => const SavedItemSkeleton(),
    );
  }
}
