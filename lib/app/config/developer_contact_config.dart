/// Developer contact links shown in Settings.
abstract final class DeveloperContactConfig {
  /// Whether any contact link is configured.
  static bool get hasAnyContact =>
      githubUrl.isNotEmpty || instagramUrl.isNotEmpty;

  /// The developer's GitHub profile.
  static const String githubUrl = 'https://github.com/thoriqr';

  /// The developer's Instagram profile.
  ///
  /// Set this to the full profile URL, for example
  /// `https://instagram.com/yourhandle`. The Settings row is hidden while this
  /// value is empty, so no link that cannot open is offered.
  static const String instagramUrl = 'https://www.instagram.com/thoriqrah';
}
