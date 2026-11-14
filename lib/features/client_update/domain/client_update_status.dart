/// The server's decision about whether this client should update.
///
/// The server computes this from the client's build and the platform's release
/// policy. The client never compares version strings.
enum ClientUpdateStatus {
  /// No action is needed.
  none,

  /// A newer release exists and the update may be postponed.
  optional,

  /// The installed build is below the minimum supported build.
  required;

  /// Parses the API's status value, or returns null when it is unknown.
  ///
  /// An unknown value is treated as an invalid manifest and produces no
  /// action, keeping an older client usable against a newer API.
  static ClientUpdateStatus? fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'none' => ClientUpdateStatus.none,
      'optional' => ClientUpdateStatus.optional,
      'required' => ClientUpdateStatus.required,
      _ => null,
    };
  }
}
