/// Copy shared by the authentication screens.
///
/// Kept outside both screens because two of them show it: the entry screen when
/// a session ends, and the sign-in form when an attempt fails with
/// `ApiFailureSessionEnded`. One constant is what stops the two explanations of
/// the same event from drifting apart.
library;

/// Copy for a session that ended while the user was elsewhere.
///
/// **Neutral and factual.** It says the session ended and what to do next, and
/// makes no claim about why — the backend's reason is not shown to users
/// ([D22]), and an expiry the user did not cause is not presented as a mistake
/// they made.
const String sessionEndedMessage =
    'Your session has ended. Sign in again to continue.';
