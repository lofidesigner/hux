# <img src="doc/logo/dark.svg" alt="Hux UI Logo" width="200">

A modern Flutter UI package with beautiful, customizable components designed for clean and consistent user interfaces.

[![Flutter support](https://img.shields.io/badge/Flutter-3.16%2B-white?style=flat&labelColor=black&logo=flutter&logoColor=WHITE)](https://flutter.dev/)
[![Figma](https://img.shields.io/badge/Figma%20users-51-white?style=flat&labelColor=black&logo=figma&logoColor=white)](https://www.figma.com/community/file/1541197128732135637/the-hux-ui)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsor-Hux%20UI-white?style=flat&labelColor=black&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/lofidesigner)

[![pub package](https://img.shields.io/pub/v/hux?style=flat&color=white&labelColor=black)](https://pub.dev/packages/hux)
[![pub points](https://img.shields.io/pub/points/hux?style=flat&color=white&labelColor=black)](https://pub.dev/packages/hux/score)
[![Pub Downloads](https://img.shields.io/pub/dm/hux?style=flat&color=white&labelColor=black&logo=dart&logoColor=white)](https://pub.dev/packages/hux/score)
[![likes](https://img.shields.io/pub/likes/hux?style=flat&color=white&labelColor=black)](https://pub.dev/packages/hux/score)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20windows%20%7C%20macos%20%7C%20linux-white?style=flat&labelColor=black)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-white?style=flat&labelColor=black)](https://opensource.org/licenses/MIT)


## Latest Release: 0.24.0

**HuxBottomSheet**: Mobile-first modal component for menus and content
  - Support for multiple sizes (small, medium, large, fullscreen)
  - Optional title, subtitle, and action buttons
  - Customizable drag handle and close button
  - Responsive layout with smooth slide-up animations
  - Theme-aware design with HuxTokens integration

[![Changelog](https://img.shields.io/badge/Changelog-View-black?style=for-the-badge&labelColor=white&logo=github&logoColor=black)](CHANGELOG.md)
[![Docs](https://img.shields.io/badge/Docs-Browse-black?style=for-the-badge&labelColor=white&logo=readthedocs&logoColor=black)](https://docs.thehuxdesign.com)

## 🎮 Live Demo

**Try all components in your browser!** Explore the full Hux UI component library with our interactive demo:

[![Live Demo](https://img.shields.io/badge/Live%20Demo-Interactive%20Components-black?style=for-the-badge&labelColor=white&logo=flutter&logoColor=black)](https://ui.thehuxdesign.com)

👉 **[ui.thehuxdesign.com](https://ui.thehuxdesign.com)** - Test buttons, inputs, dialogs, charts, and more in real-time with dark mode support.

## Installation

```bash
flutter pub add hux
```

## Features

- **Modern Design** - Clean, minimal design language
- **Dark Mode Support** - Built-in light and dark theme support
- **Data Visualization** - Animated charts for data presentation
- **Responsive** - Components adapt to different screen sizes
- **Customizable** - Extensive customization options
- **Easy to Use** - Simple, intuitive API

## Components

### Buttons
- `HuxButton` - Customizable button with multiple variants (primary, secondary, outline, ghost)

![HuxButton Variants](screenshots/hux-buttons.png)

### Cards
- `HuxCard` - Flexible card component with optional header, title, and actions

![HuxCard Examples](screenshots/hux-cards.png)

### Tabs
- `HuxTabs` - Organize content into multiple panels with tab navigation

### Inputs
- `HuxInput` - Enhanced text input with consistent styling (renamed from HuxTextField)
- `HuxTextarea` - Multi-line text input optimized for longer content with character count support
- `HuxDateInput` - Date input with automatic formatting and integrated calendar picker
- `HuxOtpInput` - One-Time Password input with automatic focus management and paste support

![HuxInput Component](screenshots/hux-input.png)

- `HuxCheckbox` - Interactive checkbox with custom styling and labels  

![HuxCheckbox Component](screenshots/hux-checkbox.png)

- `HuxRadio` - Radio button controls for single selection from groups

![HuxRadio Component](screenshots/hux-radio.png)

### Dialogs
- `HuxDialog` - General-purpose dialog with modern design and multiple size variants

![HuxDialog Component](screenshots/hux-dialog.png)

### Date & Time Pickers
- `showHuxDatePickerDialog` - Modern date picker with month/year selection
- `showHuxTimePickerDialog` - Clean time picker with hour/minute dropdowns

### Widgets
- `HuxLoading` - Customizable loading indicators
- `HuxLoadingOverlay` - Full-screen loading overlay

![HuxLoading Indicators](screenshots/hux-loading.png)

- `HuxChart` - Beautiful data visualization with line and bar charts

![HuxChart Visualization](screenshots/hux-charts.png)

### Context Menu
- `HuxContextMenu` - Right-click context menus with smart positioning
- `HuxContextMenuItem` - Individual menu items with icons and states  
- `HuxContextMenuDivider` - Visual separators for menu groups

![HuxContextMenu Component](screenshots/hux-context-menu.png)

*Right-click the example app components to see context menus in action!*

### Switch
- `HuxSwitch` - Toggle switch with smooth animations between on/off states

![HuxSwitch Component](screenshots/hux-switch.png)

### Dropdown
- `HuxDropdown` - Dropdown select component with overlay-based options list
- `HuxDropdownItem` - Individual dropdown items with custom content support

### Slider
- `HuxSlider` - Interactive slider control for selecting numeric values within a range

### Toggle
- `HuxToggle` - Two-state button toggle for binary controls
### Progress
- `HuxProgress` - Linear progress indicator for task completion and status tracking

### Tooltip
- `HuxTooltip` - Contextual help and information with optional icon support

![HuxTooltip Component](screenshots/hux-tooltip.png)

### Feedback & Status
- `HuxBadge` - Status indicators and notification counters with semantic variants

![HuxBadge Component](screenshots/hux-badge.png)

- `HuxSnackbar` - Temporary notification messages with semantic variants (previously HuxAlert)

![HuxAlert Component](screenshots/hux-alerts.png)

### Avatar
- `HuxAvatar` - Circular user images with initials fallback, custom colors, and beautiful gradient variants
- `HuxAvatarGroup` - Display multiple avatars with overlapping or spaced layouts

![HuxAvatar Component](screenshots/hux-avatar.png)

### Pagination
- `HuxPagination` - Navigate through pages with intelligent ellipsis handling (originally contributed by @Kingsley-EZE)

![HuxPagination Component](screenshots/hux-pagination.png)

### Sidebar
- `HuxSidebar` - Complete navigation sidebar component for app-wide navigation
- `HuxSidebarItem` - Individual navigation items with automatic selection state

### Breadcrumbs
- `HuxBreadcrumbs` - Navigation breadcrumbs showing page hierarchy
- `HuxBreadcrumbItem` - Individual breadcrumb with label, icon, and tap handler

### Command
- `HuxCommand` - Powerful command palette for quick access to actions and navigation
- Global keyboard shortcuts integration with `HuxCommandShortcuts.wrapper`

### Bottom Sheet
- `HuxBottomSheet` - Mobile-first modal component for menus and content
- `HuxActionSheet` - Semantic alternative to context menus for mobile

### Theme
- `HuxTheme` - Pre-configured light and dark themes with Material 3 seed color support
- `HuxColors` - Comprehensive color palette
- `HuxTokens` - Semantic design tokens that adapt to custom themes

## Documentation

📚 **[Complete Documentation](https://docs.thehuxdesign.com)** - Visit our comprehensive documentation site for detailed guides, API references, and examples.

🎨 **[Figma Library](https://www.figma.com/community/file/1541197128732135637/the-hux-ui)** - Access the complete Hux UI design system in Figma with all components, colors, and design tokens.

**✨ Recently Updated**: Our documentation has been completely restructured with individual pages for each component, alphabetical navigation, and improved clarity!

### Quick Links
- [Installation Guide](https://docs.thehuxdesign.com/installation)
- [Getting Started](https://docs.thehuxdesign.com/quickstart)
- [Component Reference](https://docs.thehuxdesign.com/components/buttons)
- [Theming Guide](https://docs.thehuxdesign.com/theming)
- [Examples](https://docs.thehuxdesign.com/examples/basic-usage)
- [Figma Library](https://www.figma.com/community/file/1541197128732135637/the-hux-ui)

## Usage

### Basic Setup

Wrap your app with the Hux theme:

```dart
import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hux UI Demo',
      theme: HuxTheme.lightTheme,
      darkTheme: HuxTheme.darkTheme,
      home: MyHomePage(),
    );
  }
}
```

### Using Components

#### Button

```dart
HuxButton(
  onPressed: () => print('Button pressed'),
  child: Text('Primary Button'),
  variant: HuxButtonVariant.primary,
  size: HuxButtonSize.medium,
  icon: Icons.star,
)
```

#### Text Field

```dart
HuxInput(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icon(Icons.email),
  onChanged: (value) => print(value),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  },
)
```

#### Textarea

```dart
HuxTextarea(
  label: 'Description',
  hint: 'Enter a description...',
  minLines: 3,
  maxLines: 6,
  maxLength: 500,
  showCharacterCount: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    return null;
  },
)
```

#### OTP Input

```dart
HuxOtpInput(
  length: 6,
  label: 'Verification Code',
  helperText: 'Enter the 6-digit code sent to your email',
  onChanged: (value) => print('OTP: $value'),
  onCompleted: (value) => verifyCode(value),
)
```

#### Card

```dart
HuxCard(
  title: 'Card Title',
  subtitle: 'Card subtitle',
  action: IconButton(
    icon: Icon(Icons.more_vert),
    onPressed: () {},
  ),
  child: Text('Card content goes here'),
  onTap: () => print('Card tapped'),
)
```

#### Dialog

```dart
// Basic dialog
showHuxDialog(
  context: context,
  title: 'Confirm Action',
  content: Text('Are you sure you want to proceed?'),
  actions: [
    HuxButton(
      onPressed: () => Navigator.of(context).pop(false),
      variant: HuxButtonVariant.secondary,
      child: Text('Cancel'),
    ),
    HuxButton(
      onPressed: () => Navigator.of(context).pop(true),
      child: Text('Confirm'),
    ),
  ],
);
```

#### Date & Time Pickers

```dart
// Date picker
final DateTime? selectedDate = await showHuxDatePickerDialog(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

// Time picker
final TimeOfDay? selectedTime = await showHuxTimePickerDialog(
  context: context,
  initialTime: TimeOfDay.now(),
);
```

#### Loading

```dart
// Simple loading indicator
HuxLoading(size: HuxLoadingSize.medium)

// Loading overlay
HuxLoadingOverlay(
  isLoading: true,
  message: 'Loading...',
  child: YourContent(),
)
```

#### Charts

```dart
// Line chart
HuxChart.line(
  data: [
    {'x': 1, 'y': 10},
    {'x': 2, 'y': 20},
    {'x': 3, 'y': 15},
  ],
  xField: 'x',
  yField: 'y',
  title: 'Sales Over Time',
  subtitle: 'Monthly data',
  primaryColor: Colors.blue,
)

// Bar chart
HuxChart.bar(
  data: [
    {'category': 'A', 'value': 30},
    {'category': 'B', 'value': 45},
    {'category': 'C', 'value': 25},
  ],
  xField: 'category',
  yField: 'value',
  title: 'Category Analysis',
)
```

#### Context Menu

```dart
HuxContextMenu(
  menuItems: [
    HuxContextMenuItem(
      text: 'Copy',
      icon: FeatherIcons.copy,
      onTap: () => print('Copy action'),
    ),
    HuxContextMenuItem(
      text: 'Paste',
      icon: FeatherIcons.clipboard,
      onTap: () => print('Paste action'),
      isDisabled: true,
    ),
    const HuxContextMenuDivider(),
    HuxContextMenuItem(
      text: 'Delete',
      icon: FeatherIcons.trash2,
      onTap: () => print('Delete action'),
      isDestructive: true,
    ),
  ],
  child: Container(
    padding: const EdgeInsets.all(20),
    child: const Text('Right-click me!'),
  ),
)
```



#### Dropdown

```dart
HuxDropdown<String>(
  value: selectedValue,
  placeholder: 'Select an option',
  items: [
    HuxDropdownItem(value: 'option1', child: Text('Option 1')),
    HuxDropdownItem(value: 'option2', child: Text('Option 2')),
    HuxDropdownItem(value: 'option3', child: Text('Option 3')),
  ],
  onChanged: (value) => setState(() => selectedValue = value),
  variant: HuxButtonVariant.outline,
  size: HuxButtonSize.medium,
)
```

#### Toggle

```dart
// Icon-only toggle (e.g., for formatting controls)
HuxToggle(
  value: isBold,
  onChanged: (value) => setState(() => isBold = value),
  icon: Icons.format_bold,
  size: HuxToggleSize.medium,
)

// Toggle with label
HuxToggle(
  value: isEnabled,
  onChanged: (value) => setState(() => isEnabled = value),
  icon: Icons.notifications,
  label: 'Notifications',
  variant: HuxButtonVariant.outline,
)
```

#### Breadcrumbs

```dart
HuxBreadcrumbs(
  items: [
    HuxBreadcrumbItem(
      label: 'Home',
      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
      icon: Icons.home,
    ),
    HuxBreadcrumbItem(
      label: 'Products',
      onTap: () => Navigator.pushNamed(context, '/products'),
    ),
    HuxBreadcrumbItem(
      label: 'Details',
      onTap: () {},
      isActive: true,
    ),
  ],
  variant: HuxBreadcrumbVariant.icon,
  size: HuxBreadcrumbSize.medium,
)
```

#### Avatar & Avatar Group

```dart
// Simple avatar with initials
HuxAvatar(
  name: 'John Doe',
  size: HuxAvatarSize.medium,
)

// Gradient avatar
HuxAvatar(
  useGradient: true,
  gradientVariant: HuxAvatarGradient.bluePurple,
  size: HuxAvatarSize.medium,
)

// Avatar group with overlap
HuxAvatarGroup(
  avatars: [
    HuxAvatar(name: 'Alice'),
    HuxAvatar(name: 'Bob'),
    HuxAvatar(useGradient: true, gradientVariant: HuxAvatarGradient.greenBlue),
  ],
  overlap: true,
  maxVisible: 3,
)
```

#### Tooltip

```dart
// Basic tooltip
HuxTooltip(
  message: 'This is a helpful tooltip',
  child: Icon(Icons.info),
)

// Tooltip with icon and custom positioning
HuxTooltip(
  message: 'Information about this feature',
  icon: Icons.info_outline,
  preferBelow: false,
  verticalOffset: 16.0,
  child: HuxButton(
    onPressed: () {},
    variant: HuxButtonVariant.outline,
    child: Text('Hover me'),
  ),
)
```

#### Badges & Alerts

```dart
// Badge variants
HuxBadge(
  label: 'New',
  variant: HuxBadgeVariant.primary,
  size: HuxBadgeSize.small,
)

// Alert with dismissal
HuxAlert(
  variant: HuxAlertVariant.success,
  title: 'Success!',
  message: 'Operation completed successfully.',
  showIcon: true,
  onDismiss: () => print('Alert dismissed'),
)
```

#### Command Palette

```dart
// Define your commands
final commands = [
  HuxCommandItem(
    id: 'toggle-theme',
    label: 'Toggle Theme',
    description: 'Switch between light and dark mode',
    shortcut: '⌘⇧T',
    icon: LucideIcons.sun,
    category: 'View',
    onExecute: () => print('Theme toggled'),
  ),
  HuxCommandItem(
    id: 'settings',
    label: 'Settings',
    description: 'Open application settings',
    shortcut: '⌘,',
    icon: LucideIcons.settings,
    category: 'Preferences',
    onExecute: () => print('Settings opened'),
  ),
];

// Show the command palette
showHuxCommand(
  context: context,
  commands: commands,
  placeholder: 'Type a command or search...',
  onCommandSelected: (command) {
    print('Selected: ${command.label}');
  },
);

// Or wrap your app for global shortcuts
HuxCommandShortcuts.wrapper(
  commands: commands,
  child: MaterialApp(
    home: MyHomePage(),
  ),
)
```

#### Bottom Sheet

```dart
showHuxBottomSheet(
  context: context,
  title: 'Settings',
  subtitle: 'Customize your preferences',
  size: HuxBottomSheetSize.medium,
  child: Column(
    children: [
      ListTile(title: Text('Notifications')),
      ListTile(title: Text('Privacy')),
    ],
  ),
  actions: [
    HuxButton(
      onPressed: () => Navigator.pop(context),
      variant: HuxButtonVariant.secondary,
      child: Text('Cancel'),
    ),
    HuxButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Save'),
    ),
  ],
);
```

#### Action Sheet

```dart
showHuxActionSheet(
  context: context,
  title: 'Share Photo',
  actions: [
    HuxActionSheetItem(
      label: 'Save to Gallery',
      icon: LucideIcons.download,
      onTap: () => print('Saved'),
    ),
    HuxActionSheetItem(
      label: 'Share',
      icon: LucideIcons.share2,
      onTap: () => print('Shared'),
    ),
    HuxActionSheetItem(
      label: 'Delete',
      icon: LucideIcons.trash2,
      isDestructive: true,
      onTap: () => print('Deleted'),
    ),
  ],
);
```

## Customization

All components can be customized using the provided parameters. For more advanced customization, you can extend the theme or override specific component styles.

### Custom Colors

```dart
// Access predefined colors
Container(
  color: HuxColors.primary,
  child: Text('Primary colored container'),
)
```

## Support

If you find Hux UI helpful and would like to support its continued development, consider becoming a GitHub Sponsor! 🌟

[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsor-Hux%20UI-white?style=for-the-badge&labelColor=black&logo=github&logoColor=white)](https://github.com/sponsors/lofidesigner)

Your support helps us:
- Maintain and improve Hux UI components
- Create better documentation and examples
- Fix bugs and add new features faster
- Invest in new component development

**Thank you to all our sponsors!** Your contributions make a real difference in the Flutter community.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Fonts & Third-Party Licenses

### Manrope Font
Hux UI uses the [Manrope](https://github.com/sharanda/manrope) font family, licensed under the [SIL Open Font License, Version 1.1](fonts/Manrope/OFL.txt).

Copyright 2018 The Manrope Project Authors (https://github.com/sharanda/manrope)

## License

This project is licensed under the MIT License - see the LICENSE file for details.