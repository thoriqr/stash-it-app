import 'package:stash_it_app/l10n/app_localizations.dart';

import 'api_failure.dart';

/// Returns shared copy for read failures that do not need feature-specific
/// wording.
///
/// Handles rate limits, server faults, and unreadable, malformed, or invalid
/// responses. Returns null when the failure needs screen-specific copy, such
/// as a session destination, content context, or feature-specific availability
/// message. Callers should handle those cases before using this helper.
///
/// Do not use for writes. [ApiFailureUnreadableResponse] and
/// [ApiFailureTransport] do not establish whether a write succeeded, so
/// mutation messages must communicate the uncertain outcome instead.
String? genericReadFailureMessage(
  Object failure,
  AppLocalizations localizations,
) => switch (failure) {
  ApiFailureRateLimited() => localizations.genericReadRateLimited,
  ApiFailureServerFault() => localizations.genericReadServerFault,
  ApiFailureUnreadableResponse() ||
  ApiFailureMalformedRequest() ||
  ApiFailureValidation() => localizations.genericReadUnreadable,
  _ => null,
};
