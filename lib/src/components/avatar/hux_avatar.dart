import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// HuxAvatar is a circular user image component with clean styling that
/// aligns with the Hux design system.
///
/// Supports initials fallback, theme adaptation, multiple size options,
/// and automatic image caching for better performance.
/// Perfect for displaying user profile images or placeholders.
///
/// Example:
/// ```dart
/// HuxAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   name: 'John Doe',
///   size: HuxAvatarSize.large,
/// )
///
/// // Or use a local asset image:
/// HuxAvatar(
///   assetImage: 'assets/avatar.png',
///   name: 'Jane Smith',
///   size: HuxAvatarSize.medium,
/// )
/// ```
class HuxAvatar extends StatelessWidget {
  /// Creates a HuxAvatar widget.
  const HuxAvatar({
    super.key,
    this.imageUrl,
    this.assetImage,
    this.name,
    this.size = HuxAvatarSize.medium,
    this.backgroundColor,
    this.useGradient = false,
    this.gradientVariant = HuxAvatarGradient.bluePurple,
  });

  /// Optional image URL for the avatar
  final String? imageUrl;

  /// Optional asset image path for the avatar (takes precedence over imageUrl)
  final String? assetImage;

  /// Name used to generate initials when no image is provided
  final String? name;

  /// Size variant of the avatar
  final HuxAvatarSize size;

  /// Optional background color for the avatar
  final Color? backgroundColor;

  /// Whether to use a beautiful gradient background with no text
  final bool useGradient;

  /// Gradient variant when useGradient is true
  final HuxAvatarGradient? gradientVariant;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize();

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: useGradient ? _getGradient() : null,
        color: useGradient
            ? null
            : (backgroundColor ?? HuxTokens.surfaceSecondary(context)),
        border: Border.all(
          color: HuxTokens.borderSecondary(context),
          width: HuxTokens.borderWidth(context),
        ),
      ),
      child: useGradient
          ? null // No content for gradient avatars
          : ClipOval(
              child: _buildAvatarImage(context, avatarSize),
            ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final initials = _getInitials();

    return Container(
      width: _getAvatarSize(),
      height: _getAvatarSize(),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? _getDefaultBackgroundColor(context),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: HuxTokens.fontWeightEmphasis(context),
            color: _getTextColor(context),
            height: 1.0,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) {
      return '?';
    }

    final words = name!.trim().split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    } else {
      final firstInitial = words[0].isNotEmpty ? words[0][0] : '';
      final lastInitial =
          words[words.length - 1].isNotEmpty ? words[words.length - 1][0] : '';
      return (firstInitial + lastInitial).toUpperCase();
    }
  }

  Color _getDefaultBackgroundColor(BuildContext context) {
    return HuxTokens.surfaceSecondary(context);
  }

  Color _getTextColor(BuildContext context) {
    return HuxTokens.textPrimary(context);
  }

  Widget _buildAvatarImage(BuildContext context, double avatarSize) {
    // Prioritize asset image over network image
    if (assetImage != null) {
      return Image.asset(
        assetImage!,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar(context);
        },
      );
    }

    if (imageUrl != null) {
      return _buildCachedNetworkImage(avatarSize);
    }

    return _buildInitialsAvatar(context);
  }

  Widget _buildCachedNetworkImage(double avatarSize) {
    return Image.network(
      imageUrl!,
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
      // Enable built-in caching
      cacheWidth: avatarSize.toInt(),
      cacheHeight: avatarSize.toInt(),
      // Loading placeholder with gradient
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingPlaceholder(context);
      },
      // Error handling
      errorBuilder: (context, error, stackTrace) {
        return _buildInitialsAvatar(context);
      },
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: _getAvatarSize(),
      height: _getAvatarSize(),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HuxTokens.surfaceSecondary(context),
            HuxTokens.surfaceSecondary(context).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: _getAvatarSize() * 0.4,
          height: _getAvatarSize() * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              HuxTokens.primary(context),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (gradientVariant!) {
      case HuxAvatarGradient.bluePurple:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Blue to Purple
          stops: [0.0, 1.0],
        );
      case HuxAvatarGradient.greenBlue:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF3B82F6)], // Green to Blue
          stops: [0.0, 1.0],
        );
      case HuxAvatarGradient.orangeRed:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)], // Orange to Red
          stops: [0.0, 1.0],
        );
      case HuxAvatarGradient.purplePink:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
          stops: [0.0, 1.0],
        );
      case HuxAvatarGradient.tealCyan:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)], // Teal to Cyan
          stops: [0.0, 1.0],
        );
    }
  }

  double _getAvatarSize() {
    switch (size) {
      case HuxAvatarSize.small:
        return 32;
      case HuxAvatarSize.medium:
        return 40;
      case HuxAvatarSize.large:
        return 56;
      case HuxAvatarSize.extraLarge:
        return 80;
    }
  }

  double _getFontSize() {
    switch (size) {
      case HuxAvatarSize.small:
        return 12;
      case HuxAvatarSize.medium:
        return 16;
      case HuxAvatarSize.large:
        return 20;
      case HuxAvatarSize.extraLarge:
        return 28;
    }
  }
}

/// Size variants for HuxAvatar
enum HuxAvatarSize {
  /// Small avatar (32x32)
  small,

  /// Medium avatar (40x40)
  medium,

  /// Large avatar (56x56)
  large,

  /// Extra large avatar (80x80)
  extraLarge
}

/// Gradient variants for HuxAvatar when useGradient is true
enum HuxAvatarGradient {
  /// Blue to Purple gradient
  bluePurple,

  /// Green to Blue gradient
  greenBlue,

  /// Orange to Red gradient
  orangeRed,

  /// Purple to Pink gradient
  purplePink,

  /// Teal to Cyan gradient
  tealCyan
}
