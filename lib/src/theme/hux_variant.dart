import 'package:flutter/widgets.dart';

/// Visual style variants available for Hux components.
///
/// - [defaultStyle]: the original Hux look — soft rounded corners, thin borders,
///   subtle elevation.
/// - [brutalist]: sharp edges, thick borders, hard-offset shadows, heavier type.
///
/// Switch variants by wrapping your app in a [HuxScope].
enum HuxVariant {
  /// The default Hux style — rounded, soft, neutral.
  defaultStyle,

  /// Brutalist style — sharp corners, thick borders, hard shadows.
  brutalist,
}

/// Inherited widget that exposes the active [HuxVariant] to descendant
/// Hux components.
///
/// Wrap your app (typically above `MaterialApp`) to apply a variant to every
/// Hux component in the tree:
///
/// ```dart
/// HuxScope(
///   variant: HuxVariant.brutalist,
///   child: MaterialApp(
///     theme: HuxTheme.lightTheme,
///     home: const MyHome(),
///   ),
/// );
/// ```
///
/// You can also nest [HuxScope]s to apply a different variant to a subtree.
class HuxScope extends InheritedWidget {
  /// Creates a [HuxScope] that exposes [variant] to its descendants.
  const HuxScope({
    super.key,
    required this.variant,
    required super.child,
  });

  /// The variant applied to all Hux components in this subtree.
  final HuxVariant variant;

  /// Returns the nearest [HuxVariant] above [context], or
  /// [HuxVariant.defaultStyle] when no [HuxScope] is present.
  static HuxVariant of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HuxScope>();
    return scope?.variant ?? HuxVariant.defaultStyle;
  }

  @override
  bool updateShouldNotify(HuxScope oldWidget) => oldWidget.variant != variant;
}
