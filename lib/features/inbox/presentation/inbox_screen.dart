import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_mock_data.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';

/// The Inbox destination (S7) — **visual prototype only**.
///
/// D26 describes the Inbox as a bounded history of recently saved items across
/// collections, including where each item currently sits. **No backend endpoint
/// provides that listing**, so this screen demonstrates the saved-item row against
/// clearly labelled mock data and nothing else.
///
/// Not implemented here, deliberately: the URL capture flow, the pending-URL queue,
/// loading and empty states, pagination, and any network call.
///
/// The layout, hierarchy and hairline dividers follow the approved wireframes. The
/// saved-time labels are prototype-only display strings; they carry no timestamp
/// contract and define no ordering.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTheme.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MockDataNotice(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              'RECENTLY SAVED',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: tokens.textMuted),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 28),
              itemCount: mockInboxItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: 20,
                color: tokens.border,
              ),
              itemBuilder: (context, index) =>
                  SavedItemRow(item: mockInboxItems[index]),
            ),
          ),
        ],
      ),
    );
  }
}

/// An unmissable but quiet statement that what follows is fabricated.
///
/// This is the line that keeps mock data from reading as API data (AGENTS.md §3).
class _MockDataNotice extends StatelessWidget {
  const _MockDataNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTheme.tokens;

    return Container(
      width: double.infinity,
      color: tokens.surface,
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 12),
      foregroundDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.accent,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Prototype. Every item below is mock data — no Inbox listing '
              'endpoint exists in the backend yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
