/// **MOCK DATA — NOT API DATA.**
///
/// No endpoint lists recently saved items across collections. D26 records the Inbox as
/// a confirmed product requirement and a *planned* backend capability: no path, schema,
/// pagination contract, or ordering exists or may be invented. Everything below is
/// fabricated for layout and visual review only.
///
/// Nothing here reflects a real response shape, and nothing here may be used to infer
/// one. When the backend designs the contract, this file is replaced by a data source
/// — it is not a starting point for a DTO.
///
/// The `savedTimeLabel` values are **pre-written display strings**, not timestamps.
/// They do not come from a field, a format, or a timezone, and they do not define the
/// list order: the array order below is the array order, chosen only so the labels read
/// plausibly in sequence. No sorting behaviour exists or is implied.
library;

import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// Fabricated sample items chosen to exercise the states the discovery documents call
/// load-bearing, so they can be compared side by side:
///
/// - the title → URL → domain fallback chain,
/// - `completed` with metadata and `completed` with nothing,
/// - `pending` and `failed`, which both offer retry,
/// - rows with and without a preview image,
/// - a long title and a long source line that must truncate,
/// - a range of saved-time labels, from minutes ago to days ago.
///
/// All hostnames use the reserved `.example` TLD, following the approved wireframes,
/// so nothing here can be mistaken for a real site.
const List<SavedItemSummary> mockInboxItems = [
  SavedItemSummary(
    id: 'mock-01',
    title: 'Understanding CRDTs: why eventual consistency is not a compromise',
    description:
        'Conflict-free replicated data types let several replicas converge without a '
        'central coordinator, at the cost of metadata every write must carry.',
    url: 'https://example.com/articles/crdts-explained',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    hasPreviewImage: true,
    savedTimeLabel: 'Saved 12 min ago',
  ),
  SavedItemSummary(
    id: 'mock-02',
    title: 'A thread about incremental static regeneration',
    description:
        'Where the build-time and request-time trade-offs actually land once a page '
        'has more than a handful of variants.',
    url: 'https://social.example.org/@someone/isr-tradeoffs',
    collectionName: 'Unsorted',
    enrichmentStatus: EnrichmentStatus.completed,
    hasPreviewImage: true,
    savedTimeLabel: 'Saved 48 min ago',
  ),
  SavedItemSummary(
    id: 'mock-03',
    title: 'Notes on reading more and remembering less',
    url: 'https://notes.example.com/archive/reading-less?ref=inbox',
    collectionName: 'Reading List',
    enrichmentStatus: EnrichmentStatus.completed,
    hasPreviewImage: true,
    savedTimeLabel: 'Saved 3 hours ago',
  ),
  SavedItemSummary(
    id: 'mock-04',
    // No title: the row falls back to the URL, as a page with no usable metadata does.
    url: 'https://archive.example.net/specs/build-notes',
    collectionName: 'Watch Later',
    enrichmentStatus: EnrichmentStatus.completed,
    savedTimeLabel: 'Saved yesterday',
  ),
  SavedItemSummary(
    id: 'mock-05',
    title: 'Full-Text Search in Postgres, part three',
    url: 'https://engineering.example.dev/postgres/pgsearch-3',
    collectionName: 'Wishlist',
    enrichmentStatus: EnrichmentStatus.failed,
    savedTimeLabel: 'Saved yesterday',
  ),
  SavedItemSummary(
    id: 'mock-06',
    // Deliberately long, to check truncation at the narrowest realistic width.
    title:
        'Designing a rate limiter that fails closed, and what it costs you the first '
        'time the counter store is unreachable in production',
    url:
        'https://engineering.example.dev/posts/rate-limiter-fail-closed-at-scale',
    collectionName: 'Reading List',
    enrichmentStatus: EnrichmentStatus.pending,
    hasPreviewImage: true,
    savedTimeLabel: 'Saved 2 days ago',
  ),
];
