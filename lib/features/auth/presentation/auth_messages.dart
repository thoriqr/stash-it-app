/// Copy shared by the authentication screens.
///
/// Used on the entry screen when a session ends and on the sign-in screen when
/// an attempt fails because the session has ended. Keeping one constant
/// ensures both screens show the same explanation.
library;

/// Message shown when a session has ended.
///
/// Neutral and factual: explains what happened and what the user should do
/// next without speculating about the cause.
const String sessionEndedMessage =
    'Your session has ended. Sign in again to continue.';
