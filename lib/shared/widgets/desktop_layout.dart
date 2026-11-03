import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const double desktopContentMaxWidth = 840;
const double desktopSheetMaxWidth = 560;

/// Native Windows uses the compact desktop layout; mobile and web keep theirs.
bool get usesDesktopLayout =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

BoxConstraints? get desktopSheetConstraints => usesDesktopLayout
    ? const BoxConstraints(maxWidth: desktopSheetMaxWidth)
    : null;

/// Centers and constrains content on desktop without changing mobile layouts.
class DesktopContentFrame extends StatelessWidget {
  const DesktopContentFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!usesDesktopLayout) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: desktopContentMaxWidth),
        child: child,
      ),
    );
  }
}
