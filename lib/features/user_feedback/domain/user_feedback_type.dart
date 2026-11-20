/// The kind of report a user is filing.
///
/// The server accepts `bug`, `idea`, or `other` for this field.
enum UserFeedbackType {
  bug('bug'),
  idea('idea'),
  other('other');

  const UserFeedbackType(this.wireValue);

  final String wireValue;
}
