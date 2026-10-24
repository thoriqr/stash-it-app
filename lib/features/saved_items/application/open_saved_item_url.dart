import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/feedback/app_feedback.dart';
import '../../../app/feedback/feedback_controller.dart';
import '../domain/saved_item_summary.dart';
import '../domain/saved_item_url.dart';

/// What a refused link says.
///
/// **The link is the subject, not the page.** This client will not hand the value
/// over, and that is all it knows: the stored URL may point at a page that exists
/// perfectly well and simply was not saved as an absolute `http(s)` address. No
/// copy here may say the item is gone or that the page cannot be reached.
const AppFeedback _linkRejectedFeedback = AppFeedback(
  tone: FeedbackTone.danger,
  copy: "This link can't be opened.",
);

/// What a launch the platform refused says.
///
/// The client asked the OS to open a link it had already accepted, and the OS did
/// not take it. Nothing was opened, and nothing about the page is known either
/// way — so the sentence reports the handoff, not the destination.
const AppFeedback _launchFailedFeedback = AppFeedback(
  tone: FeedbackTone.danger,
  copy: "We couldn't open this link. Try again.",
);

/// The handoff to the operating system, behind one method.
///
/// **A seam, not a wrapper.** `url_launcher` talks to a platform channel, which no
/// test may open. Overriding [savedItemUrlLauncherProvider] lets a test assert
/// exactly which URL was handed over — and that a value this client refused never
/// was — without a device and without a browser window.
///
/// **`externalApplication`, not `platformDefault`.** On Android the package's
/// default opens an `http(s)` URL *inside* the app (a Custom Tab), which would
/// leave the detail screen behind a branded browser and make "opened" mean
/// something different on each platform. This action hands the link to the user's
/// own browser or app; nothing here renders the page. The package's in-app web view
/// is deliberately not used: this project has no requirement for one.
class SavedItemUrlLauncher {
  const SavedItemUrlLauncher();

  /// Passes [url] to the platform.
  ///
  /// `true` means the request was **accepted for handling** — never that the page
  /// loaded, still exists, needs no sign-in, or redirects anywhere useful.
  ///
  /// A refusal arrives in two shapes: Android converts its own `false` into a
  /// thrown `PlatformException` (`ACTIVITY_NOT_FOUND`), while iOS returns `false`.
  /// Neither is predictable from the URL, so [OpenSavedItemUrl.open] handles both.
  Future<bool> launch(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}

/// The launcher the app uses.
///
/// A plain provider rather than generated state: the object is stateless and never
/// changes, so there is nothing for a notifier to own. It is a provider at all so
/// tests can substitute a fake, exactly as they do for the repositories.
final Provider<SavedItemUrlLauncher> savedItemUrlLauncherProvider =
    Provider<SavedItemUrlLauncher>((ref) => const SavedItemUrlLauncher());

/// Opens a saved item's original URL in the platform's browser or app.
///
/// **A platform action, not an API call** (`ux-discovery.md` C.3). There is no
/// endpoint, no preliminary `HEAD`/`GET` availability check, no retry and no cache
/// update: the value the server stored is handed to the operating system as it was
/// saved. `url` is the only input — never `imageUrl`, never a URL derived from
/// metadata, never one resolved against a base.
///
/// **Three outcomes, two notices, and no success message.**
///
/// - A value this client will not hand over — not an absolute `http`/`https` URL
///   with a host — is refused locally and reported. It never reaches the platform.
/// - A launch the platform refuses (a `false` result, or a thrown exception) is
///   reported.
/// - A launch the platform accepts is **silent**. The OS has taken over, and this
///   client cannot know whether the page loads, redirects, demands a sign-in or no
///   longer exists. A success notice would claim something nobody has established.
///
/// **A tap changes nothing else.** No enrichment status, metadata, Inbox row,
/// collection contents, collection count or pagination is written, refreshed or
/// invalidated: opening a page is not an operation on the saved item.
class OpenSavedItemUrl {
  const OpenSavedItemUrl(this._ref);

  final Ref _ref;

  /// Hands [item]'s original URL to the platform.
  Future<void> open(SavedItemSummary item) async {
    final url = launchableSavedItemUrl(item.url);
    if (url == null) {
      _publish(_linkRejectedFeedback);
      return;
    }

    final bool accepted;
    try {
      accepted = await _ref.read(savedItemUrlLauncherProvider).launch(url);
    } on Exception {
      // Android reports a refused intent by throwing; iOS reports it by returning
      // `false`. A missing plugin in a stripped build arrives the same way. All of
      // them mean one thing here: nothing was handed over.
      _publish(_launchFailedFeedback);
      return;
    }

    if (!accepted) _publish(_launchFailedFeedback);
  }

  void _publish(AppFeedback feedback) =>
      _ref.read(feedbackProvider.notifier).show(feedback);
}

/// The URL this client will hand to the platform, or `null` when it will not.
///
/// **The intake form's gate, reused deliberately.** [isSubmittableUrl] is the one
/// place that answers "is this an absolute `http(s)` URL with a host this client
/// can address?" — no network call, no allowlist, no normalisation — and a second
/// implementation of those rules for the launch path could drift from the one
/// applied before a value ever becomes an item. It refuses a relative value rather
/// than completing it against a base, and it refuses an unsupported scheme rather
/// than hoping some app handles it.
///
/// The trim happens once, in the gate, and the resulting URI is what the platform
/// receives; the destination is not rewritten beyond the parsing `launchUrl`
/// requires.
Uri? launchableSavedItemUrl(String stored) {
  if (!isSubmittableUrl(stored)) return null;
  // Unreachable as a null: the gate already parsed the same string. Kept total so
  // this function cannot throw on a value that slipped past the gate.
  return Uri.tryParse(stored.trim());
}

/// The opener the detail screen uses.
final Provider<OpenSavedItemUrl> openSavedItemUrlProvider =
    Provider<OpenSavedItemUrl>((ref) => OpenSavedItemUrl(ref));
