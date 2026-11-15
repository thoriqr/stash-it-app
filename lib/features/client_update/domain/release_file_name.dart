/// Builds a safe local file name for a downloaded release artifact.
///
/// Only the last URL path segment is used. Characters outside a conservative
/// set are replaced, leading dots are removed so traversal segments cannot
/// survive, and the platform extension is appended when it is missing.
String safeReleaseFileName(
  Uri uri, {
  required String extension,
  required int build,
}) {
  final raw = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  var name = raw.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  name = name.replaceAll(RegExp(r'^\.+'), '');

  if (name.isEmpty) name = 'stash-it-$build';
  if (name.length > 100) name = name.substring(0, 100);

  final suffix = '.${extension.toLowerCase()}';
  if (name.toLowerCase().endsWith(suffix)) return name;
  return '$name$suffix';
}
