import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hux/hux.dart';

import 'breadcrumbs.dart';
import 'tabs.dart';
import 'components/otp_section.dart';
import 'components/progress_section.dart';
import 'components/bottom_sheet_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HuxCommandShortcuts.wrapper(
      commands: _getGlobalCommands(),
      onCommandSelected: (command) {
        // Execute the command's onExecute callback
        command.onExecute();
      },
      child: MaterialApp(
        title: 'Hux UI Demo',
        theme: HuxTheme.lightTheme,
        darkTheme: HuxTheme.darkTheme,
        themeMode: _themeMode,
        home: MyHomePage(
          themeMode: _themeMode,
          onThemeToggle: _toggleTheme,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  List<HuxCommandItem> _getGlobalCommands() {
    return [
      HuxCommandItem(
        id: 'toggle-theme',
        label: 'Toggle Theme',
        description: 'Switch between light and dark theme',
        shortcut: '⌘⇧D',
        icon: LucideIcons.sun,
        category: 'View',
        onExecute: _toggleTheme,
      ),
      HuxCommandItem(
        id: 'open-command-palette',
        label: 'Open Command Palette',
        description: 'Open the command palette',
        shortcut: '⌘⇧K',
        icon: LucideIcons.command,
        category: 'Navigation',
        onExecute: () {
          showHuxCommand(
            context: context,
            commands: _getGlobalCommands(),
            onCommandSelected: (command) {
              context.showHuxSnackbar(
                message: 'Command executed: ${command.label}',
                variant: HuxSnackbarVariant.info,
              );
            },
          );
        },
      ),
      HuxCommandItem(
        id: 'help',
        label: 'Help',
        description: 'Open help documentation',
        shortcut: '⌘H',
        icon: LucideIcons.helpCircle,
        category: 'Help',
        onExecute: () {
          context.showHuxSnackbar(
            message: 'Help opened',
            variant: HuxSnackbarVariant.info,
          );
        },
      ),
      HuxCommandItem(
        id: 'show-bottom-sheet',
        label: 'Show Bottom Sheet',
        description: 'Open example settings bottom sheet',
        icon: LucideIcons.panelBottom,
        category: 'Components',
        onExecute: () => _showSettingsInContext(context),
      ),
      HuxCommandItem(
        id: 'show-action-sheet',
        label: 'Show Action Sheet',
        description: 'Open example share action sheet',
        icon: LucideIcons.share2,
        category: 'Components',
        onExecute: () => _showActionSheetInContext(context),
      ),
    ];
  }

  void _showSettingsInContext(BuildContext context) {
    // We need a helper because the section logic is now encapsulated
    const BottomSheetSection(onShowSnackBar: _dummySnackBar)
        .showSettingsBottomSheet(context);
  }

  static void _dummySnackBar(String message) {
    // Dummy for command execution if needed, though they usually just pop
  }

  void _showActionSheetInContext(BuildContext context) {
    showHuxActionSheet(
      context: context,
      title: 'Action Sheet',
      actions: [
        HuxActionSheetItem(
            label: 'Action 1', onTap: () => Navigator.pop(context)),
        HuxActionSheetItem(
            label: 'Action 2', onTap: () => Navigator.pop(context)),
      ],
    );
  }
}

/// Wrapper widget that adds a documentation button to component sections
class SectionWithDocumentation extends StatelessWidget {
  final Widget child;
  final String componentName;

  const SectionWithDocumentation({
    super.key,
    required this.child,
    required this.componentName,
  });

  Widget _buildDocumentationButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: HuxButton(
        onPressed: () async {
          final url = Uri.parse(
            'https://docs.thehuxdesign.com/components/$componentName',
          );
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        variant: HuxButtonVariant.ghost,
        size: HuxButtonSize.small,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Theme.of(context).brightness == Brightness.dark
                  ? SvgPicture.asset(
                      'assets/doc.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/doc.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        HuxTokens.buttonSecondaryText(context),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            const Text('Documentation'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If child is a HuxCard, modify its child to include the button
    if (child is HuxCard) {
      final card = child as HuxCard;
      return HuxCard(
        key: card.key,
        title: card.title,
        subtitle: card.subtitle,
        action: card.action,
        size: card.size,
        padding: card.padding,
        margin: card.margin,
        elevation: card.elevation,
        borderRadius: card.borderRadius,
        backgroundColor: card.backgroundColor,
        borderColor: card.borderColor,
        borderWidth: card.borderWidth,
        onTap: card.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            card.child,
            const SizedBox(height: 16),
            _buildDocumentationButton(context),
          ],
        ),
      );
    }

    // For other widgets, wrap in a Stack
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDocumentationButton(context),
          ),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const MyHomePage({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _textareaController = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  DateTime? _selectedDateInline;

  // Time picker temporarily disabled
  // TimeOfDay? _selectedTime;

  // Theme state
  String _selectedTheme = 'default';
  Color _currentPrimaryColor(BuildContext context) =>
      _selectedTheme == 'default'
          ? HuxTokens.primary(context)
          : HuxColors.getPresetColor(_selectedTheme);

  // Button size state
  HuxButtonSize _selectedButtonSize = HuxButtonSize.medium;
  bool _showIconButtons = true;

  // Global keys for each section
  final _buttonsKey = GlobalKey();
  final _textFieldsKey = GlobalKey();
  final _cardsKey = GlobalKey();
  final _chartsKey = GlobalKey();
  final _loadingKey = GlobalKey();
  final _contextMenuKey = GlobalKey();
  final _checkboxesKey = GlobalKey();
  final _radioButtonsKey = GlobalKey();
  final _toggleSwitchesKey = GlobalKey();
  final _sliderKey = GlobalKey();
  final _progressKey = GlobalKey();
  final _toggleButtonsKey = GlobalKey();
  final _badgesKey = GlobalKey();
  final _indicatorsKey = GlobalKey();
  final _displayKey = GlobalKey();
  final _datePickerNavKey = GlobalKey();
  final _tooltipKey = GlobalKey();
  final _dialogKey = GlobalKey();
  final _bottomSheetKey = GlobalKey();
  final _dropdownKey = GlobalKey();
  final _paginationKey = GlobalKey();
  final _tabsKey = GlobalKey();
  final _breadcrumbsKey = GlobalKey();
  final _commandKey = GlobalKey();
  final _otpKey = GlobalKey();
  // final _timePickerKey = GlobalKey();
  // final _timePickerNavKey = GlobalKey();
  // final _timeButtonKey = GlobalKey();

  // Navigation items
  late final List<HuxSidebarItemData> _navigationItems;
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _navigationItems = [
      const HuxSidebarItemData(
        id: 'buttons',
        label: 'Buttons',
        icon: LucideIcons.square,
      ),
      const HuxSidebarItemData(
        id: 'input',
        label: 'Input',
        icon: LucideIcons.edit3,
      ),
      const HuxSidebarItemData(
        id: 'otp',
        label: 'OTP Input',
        icon: LucideIcons.keyboard,
      ),
      const HuxSidebarItemData(
        id: 'cards',
        label: 'Cards',
        icon: LucideIcons.creditCard,
      ),
      const HuxSidebarItemData(
        id: 'charts',
        label: 'Charts',
        icon: LucideIcons.barChart2,
      ),
      const HuxSidebarItemData(
        id: 'context-menu',
        label: 'Context Menu',
        icon: LucideIcons.menu,
      ),
      const HuxSidebarItemData(
        id: 'checkbox',
        label: 'Checkbox',
        icon: LucideIcons.checkSquare,
      ),
      const HuxSidebarItemData(
        id: 'radio-buttons',
        label: 'Radio Buttons',
        icon: LucideIcons.circle,
      ),
      const HuxSidebarItemData(
        id: 'switch',
        label: 'Switch',
        icon: LucideIcons.toggleLeft,
      ),
      const HuxSidebarItemData(
        id: 'slider',
        label: 'Slider',
        icon: LucideIcons.slidersHorizontal,
      ),
      const HuxSidebarItemData(
        id: 'progress',
        label: 'Progress',
        icon: LucideIcons.activity,
      ),
      const HuxSidebarItemData(
        id: 'toggle',
        label: 'Toggle',
        icon: LucideIcons.edit3,
      ),
      const HuxSidebarItemData(
        id: 'badges',
        label: 'Badges',
        icon: LucideIcons.tag,
      ),
      const HuxSidebarItemData(
        id: 'snackbar',
        label: 'Snackbar',
        icon: LucideIcons.alertCircle,
      ),
      const HuxSidebarItemData(
        id: 'avatar',
        label: 'Avatar',
        icon: LucideIcons.user,
      ),
      const HuxSidebarItemData(
        id: 'loading',
        label: 'Loading',
        icon: LucideIcons.loader,
      ),
      const HuxSidebarItemData(
        id: 'date-picker',
        label: 'Date Picker',
        icon: LucideIcons.calendar,
      ),
      const HuxSidebarItemData(
        id: 'tooltip',
        label: 'Tooltip',
        icon: LucideIcons.messageCircle,
      ),
      const HuxSidebarItemData(
        id: 'dialog',
        label: 'Dialog',
        icon: LucideIcons.messageSquare,
      ),
      const HuxSidebarItemData(
        id: 'bottom-sheet',
        label: 'Bottom Sheet',
        icon: LucideIcons.panelBottom,
      ),
      const HuxSidebarItemData(
        id: 'dropdown',
        label: 'Dropdown',
        icon: LucideIcons.chevronDown,
      ),
      const HuxSidebarItemData(
        id: 'pagination',
        label: 'Pagination',
        icon: LucideIcons.layers,
      ),
      const HuxSidebarItemData(
        id: 'tabs',
        label: 'Tabs',
        icon: LucideIcons.layout,
      ),
      const HuxSidebarItemData(
        id: 'breadcrumbs',
        label: 'Breadcrumbs',
        icon: LucideIcons.navigation,
      ),
      const HuxSidebarItemData(
        id: 'command',
        label: 'Command',
        icon: LucideIcons.command,
      ),
    ];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _textareaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSidebarItemSelected(String itemId) {
    setState(() {
      _selectedItemId = itemId;
    });

    // Map item IDs to their corresponding keys
    final keyMap = {
      'buttons': _buttonsKey,
      'input': _textFieldsKey,
      'otp': _otpKey,
      'cards': _cardsKey,
      'charts': _chartsKey,
      'context-menu': _contextMenuKey,
      'checkbox': _checkboxesKey,
      'radio-buttons': _radioButtonsKey,
      'switch': _toggleSwitchesKey,
      'slider': _sliderKey,
      'progress': _progressKey,
      'toggle': _toggleButtonsKey,
      'badges': _badgesKey,
      'snackbar': _indicatorsKey,
      'avatar': _displayKey,
      'loading': _loadingKey,
      'date-picker': _datePickerNavKey,
      'tooltip': _tooltipKey,
      'dialog': _dialogKey,
      'bottom-sheet': _bottomSheetKey,
      'dropdown': _dropdownKey,
      'pagination': _paginationKey,
      'tabs': _tabsKey,
      'breadcrumbs': _breadcrumbsKey,
      'command': _commandKey,
    };

    final key = keyMap[itemId];
    if (key != null) {
      _scrollToSection(key);
    }
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });

    if (_isLoading) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // Removed _selectDate() dialog opener

  // Future<void> _selectTime() async {
  //   final TimeOfDay? picked = await showHuxTimePickerDialog(
  //     context: context,
  //     initialTime: _selectedTime ?? TimeOfDay.now(),
  //     targetKey: _timeButtonKey,
  //   );
  //   if (picked != null && picked != _selectedTime) {
  //     setState(() {
  //       _selectedTime = picked;
  //     });
  //   }
  // }

  Widget _buildSidebarHeader(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/logo-dark.svg'
                              : 'assets/logo-light.svg',
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                  // Theme Toggle Button
                  HuxButton(
                    onPressed: widget.onThemeToggle,
                    variant: HuxButtonVariant.outline,
                    size: HuxButtonSize.small,
                    width: HuxButtonWidth.fixed,
                    widthValue: 36,
                    icon: widget.themeMode == ThemeMode.light
                        ? LucideIcons.moon
                        : LucideIcons.sun,
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Theme Selector
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Button Theme',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? HuxColors.white80
                          : HuxColors.black80,
                    ),
              ),
              const SizedBox(height: 8),
              HuxDropdown<String>(
                value: _selectedTheme,
                items: HuxColors.availablePresetColors
                    .map<HuxDropdownItem<String>>((String colorName) {
                  final color = colorName == 'default'
                      ? HuxTokens.primary(context)
                      : HuxColors.getPresetColor(colorName);
                  return HuxDropdownItem<String>(
                    value: colorName,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? HuxColors.white30
                                  : HuxColors.black30,
                              width: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          colorName[0].toUpperCase() + colorName.substring(1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTheme = newValue;
                    });
                  }
                },
                placeholder: 'Select theme',
                variant: HuxButtonVariant.outline,
                size: HuxButtonSize.small,
              ),
            ],
          ),
        ),

        // GitHub and Documentation Buttons
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resources',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? HuxColors.white80
                          : HuxColors.black80,
                    ),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://github.com/lofidesigner/hux');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.github,
                child: const Text('GitHub'),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://docs.thehuxdesign.com/');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.bookOpen,
                child: const Text('Documentation'),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://pub.dev/packages/hux');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.package,
                child: const Text('Package'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDark ? HuxColors.black : HuxColors.white,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: isDark ? HuxColors.black : HuxColors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      LucideIcons.menu,
                      color: isDark ? HuxColors.white : HuxColors.black,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  title: Row(
                    children: [
                      SvgPicture.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/logo-dark.svg'
                            : 'assets/logo-light.svg',
                        height: 24,
                      ),
                    ],
                  ),
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  backgroundColor: HuxTokens.surfacePrimary(context),
                  child: HuxSidebar(
                    items: _navigationItems,
                    selectedItemId: _selectedItemId,
                    onItemSelected: (itemId) {
                      _onSidebarItemSelected(itemId);
                      Navigator.of(context).pop();
                    },
                    header: _buildSidebarHeader(context),
                  ),
                )
              : null,
          body: Row(
            children: [
              // Left Navigation Sidebar (desktop/tablet only)
              if (!isMobile)
                HuxSidebar(
                  items: _navigationItems,
                  selectedItemId: _selectedItemId,
                  onItemSelected: _onSidebarItemSelected,
                  header: _buildSidebarHeader(context),
                ),

              // Main Content Area
              Expanded(
                child: HuxLoadingOverlay(
                  isLoading: _isLoading,
                  message: 'Processing...',
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(isMobile
                        ? 16
                        : isTablet
                            ? 24
                            : 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Buttons Section
                          Container(
                            key: _buttonsKey,
                            child: SectionWithDocumentation(
                              componentName: 'buttons',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Buttons',
                                subtitle: 'Different button variants and sizes',
                                action: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Size buttons group
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildSizeButton(
                                            'S', HuxButtonSize.small),
                                        const SizedBox(width: 8),
                                        _buildSizeButton(
                                            'M', HuxButtonSize.medium),
                                        const SizedBox(width: 8),
                                        _buildSizeButton(
                                            'L', HuxButtonSize.large),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Show icons switch group
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Show icons:',
                                          style: TextStyle(
                                            color: HuxTokens.textSecondary(
                                                context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        HuxSwitch(
                                          value: _showIconButtons,
                                          onChanged: (value) {
                                            setState(() {
                                              _showIconButtons = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),

                                    const SizedBox(height: 20),

                                    // Button Variants - Responsive Height Container
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final screenWidth =
                                            MediaQuery.of(context).size.width;
                                        final isMobile = screenWidth < 768;
                                        // Use flexible height on mobile, fixed on desktop
                                        final containerHeight =
                                            isMobile ? null : 48.0;

                                        return SizedBox(
                                          height: containerHeight,
                                          child: Center(
                                            child: Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: [
                                                _showIconButtons
                                                    ? HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Primary pressed'),
                                                        primaryColor:
                                                            _currentPrimaryColor(
                                                                context),
                                                        size:
                                                            _selectedButtonSize,
                                                        icon:
                                                            LucideIcons.upload,
                                                        child: const Text(
                                                            'Primary'),
                                                      )
                                                    : HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Primary pressed'),
                                                        primaryColor:
                                                            _currentPrimaryColor(
                                                                context),
                                                        size:
                                                            _selectedButtonSize,
                                                        child: const Text(
                                                            'Primary'),
                                                      ),
                                                _showIconButtons
                                                    ? HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Secondary pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .secondary,
                                                        size:
                                                            _selectedButtonSize,
                                                        icon:
                                                            LucideIcons.upload,
                                                        child: const Text(
                                                            'Secondary'),
                                                      )
                                                    : HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Secondary pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .secondary,
                                                        size:
                                                            _selectedButtonSize,
                                                        child: const Text(
                                                            'Secondary'),
                                                      ),
                                                _showIconButtons
                                                    ? HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Outline pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .outline,
                                                        size:
                                                            _selectedButtonSize,
                                                        icon:
                                                            LucideIcons.upload,
                                                        child: const Text(
                                                            'Outline'),
                                                      )
                                                    : HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Outline pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .outline,
                                                        size:
                                                            _selectedButtonSize,
                                                        child: const Text(
                                                            'Outline'),
                                                      ),
                                                _showIconButtons
                                                    ? HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Ghost pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .ghost,
                                                        size:
                                                            _selectedButtonSize,
                                                        icon:
                                                            LucideIcons.upload,
                                                        child:
                                                            const Text('Ghost'),
                                                      )
                                                    : HuxButton(
                                                        onPressed: () =>
                                                            _showSnackBar(
                                                                'Ghost pressed'),
                                                        variant:
                                                            HuxButtonVariant
                                                                .ghost,
                                                        size:
                                                            _selectedButtonSize,
                                                        child:
                                                            const Text('Ghost'),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Input Section
                          Container(
                            key: _textFieldsKey,
                            child: SectionWithDocumentation(
                              componentName: 'input',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Input',
                                subtitle: 'Input components with validation',
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final isMobileScreen = screenWidth < 768;
                                    final isTabletScreen = screenWidth >= 768 &&
                                        screenWidth < 1024;
                                    final inputWidth = isMobileScreen
                                        ? constraints.maxWidth
                                        : isTabletScreen
                                            ? constraints.maxWidth * 0.7
                                            : 400.0;
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Center(
                                          child: SizedBox(
                                            width: inputWidth,
                                            child: HuxInput(
                                              controller: _emailController,
                                              label: 'Email',
                                              hint: 'Enter your email address',
                                              prefixIcon:
                                                  const Icon(LucideIcons.mail),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your email';
                                                }
                                                if (!value.contains('@')) {
                                                  return 'Please enter a valid email';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: SizedBox(
                                            width: inputWidth,
                                            child: HuxInput(
                                              controller: _passwordController,
                                              label: 'Password',
                                              hint: 'Enter your password',
                                              prefixIcon:
                                                  const Icon(LucideIcons.lock),
                                              suffixIcon:
                                                  const Icon(LucideIcons.eye),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your password';
                                                }
                                                if (value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Date Input Example
                                        Center(
                                          child: SizedBox(
                                            width: inputWidth,
                                            child: HuxDateInput(
                                              label: 'Select Date',
                                              hint: 'MM/DD/YYYY',
                                              helperText:
                                                  'Click the calendar icon or type the date manually',
                                              onDateChanged: (date) {
                                                // Handle date change
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Textarea Example
                                        Center(
                                          child: SizedBox(
                                            width: inputWidth,
                                            child: HuxTextarea(
                                              controller: _textareaController,
                                              label: 'Description',
                                              hint: 'Enter a description...',
                                              minLines: 3,
                                              maxLines: 6,
                                              maxLength: 500,
                                              showCharacterCount: true,
                                              helperText:
                                                  'Provide a detailed description',
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a description';
                                                }
                                                if (value.length < 10) {
                                                  return 'Description must be at least 10 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // OTP Input Section
                          Container(
                            key: _otpKey,
                            child: SectionWithDocumentation(
                              componentName: 'otp',
                              child: OtpSection(
                                onShowSnackBar: _showSnackBar,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Cards Section
                          Container(
                            key: _cardsKey,
                            child: SectionWithDocumentation(
                              componentName: 'cards',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Cards',
                                subtitle:
                                    'Container components for content organization',
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final isMobileScreen = screenWidth < 768;

                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        isMobileScreen
                                            ? const Column(
                                                children: [
                                                  HuxCard(
                                                    title: 'Simple Card',
                                                    child: Text(
                                                        'This is a simple card with just a title and content.'),
                                                  ),
                                                  SizedBox(height: 16),
                                                  HuxCard(
                                                    title: 'Card with Subtitle',
                                                    subtitle:
                                                        'This card has both title and subtitle',
                                                    child: Text(
                                                        'Cards can have optional subtitles for additional context.'),
                                                  ),
                                                ],
                                              )
                                            : const Row(
                                                children: [
                                                  Expanded(
                                                    child: HuxCard(
                                                      title: 'Simple Card',
                                                      child: Text(
                                                          'This is a simple card with just a title and content.'),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: HuxCard(
                                                      title:
                                                          'Card with Subtitle',
                                                      subtitle:
                                                          'This card has both title and subtitle',
                                                      child: Text(
                                                          'Cards can have optional subtitles for additional context.'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Charts Section
                          Container(
                            key: _chartsKey,
                            child: SectionWithDocumentation(
                              componentName: 'charts',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Charts',
                                subtitle: 'Data visualization with Cristalyse',
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final isMobileScreen = screenWidth < 768;

                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),

                                        // Sample chart data
                                        isMobileScreen
                                            ? Column(
                                                children: [
                                                  HuxChart(
                                                    data: _getSampleLineData(),
                                                    type: HuxChartType.line,
                                                    xField: 'day',
                                                    yField: 'calories',
                                                    title: 'Daily Calories',
                                                    subtitle:
                                                        'Calorie tracking over time',
                                                    size: HuxChartSize.small,
                                                    primaryColor:
                                                        _currentPrimaryColor(
                                                            context),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  HuxChart(
                                                    data: _getSampleBarData(),
                                                    type: HuxChartType.bar,
                                                    xField: 'product',
                                                    yField: 'revenue',
                                                    title: 'Product Revenue',
                                                    subtitle:
                                                        'Revenue by product',
                                                    size: HuxChartSize.small,
                                                    primaryColor:
                                                        _currentPrimaryColor(
                                                            context),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: HuxChart(
                                                      data:
                                                          _getSampleLineData(),
                                                      type: HuxChartType.line,
                                                      xField: 'day',
                                                      yField: 'calories',
                                                      title: 'Daily Calories',
                                                      subtitle:
                                                          'Calorie tracking over time',
                                                      size: HuxChartSize.small,
                                                      primaryColor:
                                                          _currentPrimaryColor(
                                                              context),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: HuxChart(
                                                      data: _getSampleBarData(),
                                                      type: HuxChartType.bar,
                                                      xField: 'product',
                                                      yField: 'revenue',
                                                      title: 'Product Revenue',
                                                      subtitle:
                                                          'Revenue by product',
                                                      size: HuxChartSize.small,
                                                      primaryColor:
                                                          _currentPrimaryColor(
                                                              context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Context Menu Section
                          Container(
                            key: _contextMenuKey,
                            child: SectionWithDocumentation(
                              componentName: 'context-menu',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Context Menu',
                                subtitle:
                                    'Right-click interactive context menus',
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      'Right-click on any of the items below to see the context menu:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? HuxColors.white70
                                                    : HuxColors.black70,
                                          ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Context Menu Examples
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final screenWidth =
                                            MediaQuery.of(context).size.width;
                                        final isMobileScreen =
                                            screenWidth < 768;

                                        return isMobileScreen
                                            ? Column(
                                                children: [
                                                  HuxContextMenu(
                                                    menuItems: [
                                                      HuxContextMenuItem(
                                                        text: 'Copy',
                                                        icon: LucideIcons.copy,
                                                        onTap: () => _showSnackBar(
                                                            'Copy action triggered'),
                                                      ),
                                                      HuxContextMenuItem(
                                                        text: 'Paste',
                                                        icon: LucideIcons
                                                            .clipboard,
                                                        onTap: () => _showSnackBar(
                                                            'Paste action triggered'),
                                                        isDisabled: true,
                                                      ),
                                                      const HuxContextMenuDivider(),
                                                      HuxContextMenuItem(
                                                        text: 'Share',
                                                        icon:
                                                            LucideIcons.share2,
                                                        onTap: () => _showSnackBar(
                                                            'Share action triggered'),
                                                      ),
                                                    ],
                                                    child: HuxCard(
                                                      title: 'Document',
                                                      subtitle:
                                                          'Right-click for options',
                                                      child: Container(
                                                        height: 60,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          LucideIcons.fileText,
                                                          size: 32,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? HuxColors
                                                                  .white50
                                                              : HuxColors
                                                                  .black50,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  HuxContextMenu(
                                                    menuItems: [
                                                      HuxContextMenuItem(
                                                        text: 'Edit',
                                                        icon: LucideIcons.edit2,
                                                        onTap: () => _showSnackBar(
                                                            'Edit action triggered'),
                                                      ),
                                                      HuxContextMenuItem(
                                                        text: 'Duplicate',
                                                        icon: LucideIcons.copy,
                                                        onTap: () => _showSnackBar(
                                                            'Duplicate action triggered'),
                                                      ),
                                                      const HuxContextMenuDivider(),
                                                      HuxContextMenuItem(
                                                        text: 'Delete',
                                                        icon:
                                                            LucideIcons.trash2,
                                                        onTap: () => _showSnackBar(
                                                            'Delete action triggered'),
                                                        isDestructive: true,
                                                      ),
                                                    ],
                                                    child: HuxCard(
                                                      title: 'Project',
                                                      subtitle:
                                                          'Right-click for actions',
                                                      child: Container(
                                                        height: 60,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          LucideIcons.folder,
                                                          size: 32,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? HuxColors
                                                                  .white50
                                                              : HuxColors
                                                                  .black50,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: HuxContextMenu(
                                                      menuItems: [
                                                        HuxContextMenuItem(
                                                          text: 'Copy',
                                                          icon:
                                                              LucideIcons.copy,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Copy action triggered'),
                                                        ),
                                                        HuxContextMenuItem(
                                                          text: 'Paste',
                                                          icon: LucideIcons
                                                              .clipboard,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Paste action triggered'),
                                                          isDisabled: true,
                                                        ),
                                                        const HuxContextMenuDivider(),
                                                        HuxContextMenuItem(
                                                          text: 'Share',
                                                          icon: LucideIcons
                                                              .share2,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Share action triggered'),
                                                        ),
                                                      ],
                                                      child: HuxCard(
                                                        title: 'Document',
                                                        subtitle:
                                                            'Right-click for options',
                                                        child: Container(
                                                          height: 60,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            LucideIcons
                                                                .fileText,
                                                            size: 32,
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? HuxColors
                                                                    .white50
                                                                : HuxColors
                                                                    .black50,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: HuxContextMenu(
                                                      menuItems: [
                                                        HuxContextMenuItem(
                                                          text: 'Edit',
                                                          icon:
                                                              LucideIcons.edit2,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Edit action triggered'),
                                                        ),
                                                        HuxContextMenuItem(
                                                          text: 'Duplicate',
                                                          icon:
                                                              LucideIcons.copy,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Duplicate action triggered'),
                                                        ),
                                                        const HuxContextMenuDivider(),
                                                        HuxContextMenuItem(
                                                          text: 'Delete',
                                                          icon: LucideIcons
                                                              .trash2,
                                                          onTap: () =>
                                                              _showSnackBar(
                                                                  'Delete action triggered'),
                                                          isDestructive: true,
                                                        ),
                                                      ],
                                                      child: HuxCard(
                                                        title: 'Project',
                                                        subtitle:
                                                            'Right-click for actions',
                                                        child: Container(
                                                          height: 60,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            LucideIcons.folder,
                                                            size: 32,
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? HuxColors
                                                                    .white50
                                                                : HuxColors
                                                                    .black50,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Button with Context Menu
                                    HuxContextMenu(
                                      menuItems: [
                                        HuxContextMenuItem(
                                          text: 'Save',
                                          icon: LucideIcons.save,
                                          onTap: () => _showSnackBar(
                                              'Save action triggered'),
                                        ),
                                        HuxContextMenuItem(
                                          text: 'Export',
                                          icon: LucideIcons.download,
                                          onTap: () => _showSnackBar(
                                              'Export action triggered'),
                                        ),
                                        const HuxContextMenuDivider(),
                                        HuxContextMenuItem(
                                          text: 'Reset',
                                          icon: LucideIcons.refreshCw,
                                          onTap: () => _showSnackBar(
                                              'Reset action triggered'),
                                          isDestructive: true,
                                        ),
                                      ],
                                      child: HuxButton(
                                        onPressed: () => _showSnackBar(
                                            'Button clicked normally'),
                                        primaryColor:
                                            _currentPrimaryColor(context),
                                        icon: LucideIcons.settings,
                                        child: const Text(
                                            'Right-click for More Options'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Checkboxes Section
                          SectionWithDocumentation(
                            componentName: 'checkbox',
                            child: CheckboxesSection(key: _checkboxesKey),
                          ),

                          const SizedBox(height: 32),

                          // Radio Buttons Section
                          SectionWithDocumentation(
                            componentName: 'radio',
                            child: RadioButtonsSection(key: _radioButtonsKey),
                          ),

                          const SizedBox(height: 32),

                          // Toggle Switches Section
                          SectionWithDocumentation(
                            componentName: 'switch',
                            child:
                                ToggleSwitchesSection(key: _toggleSwitchesKey),
                          ),

                          const SizedBox(height: 32),

                          // Slider Section
                          SectionWithDocumentation(
                            componentName: 'slider',
                            child: SliderSection(key: _sliderKey),
                          ),

                          const SizedBox(height: 32),

                          // Progress Section
                          SectionWithDocumentation(
                            componentName: 'progress',
                            child: ProgressSection(key: _progressKey),
                          ),

                          const SizedBox(height: 32),

                          // Toggle Buttons Section
                          SectionWithDocumentation(
                            componentName: 'toggle',
                            child: ToggleButtonsSection(key: _toggleButtonsKey),
                          ),

                          const SizedBox(height: 32),

                          // Badges Section
                          SectionWithDocumentation(
                            componentName: 'badge',
                            child: BadgesSection(key: _badgesKey),
                          ),

                          const SizedBox(height: 32),

                          // Alerts Section
                          SectionWithDocumentation(
                            componentName: 'snackbar',
                            child: IndicatorsSection(key: _indicatorsKey),
                          ),

                          const SizedBox(height: 32),

                          // Display Section
                          SectionWithDocumentation(
                            componentName: 'avatar',
                            child: DisplaySection(key: _displayKey),
                          ),

                          const SizedBox(height: 32),

                          // Loading Section
                          Container(
                            key: _loadingKey,
                            child: SectionWithDocumentation(
                              componentName: 'loading',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Loading Indicators',
                                subtitle: 'Different loading states and sizes',
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            HuxLoading(
                                                size: HuxLoadingSize.small),
                                            SizedBox(height: 8),
                                            Text('Small'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            HuxLoading(
                                                size: HuxLoadingSize.medium),
                                            SizedBox(height: 8),
                                            Text('Medium'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            HuxLoading(
                                                size: HuxLoadingSize.large),
                                            SizedBox(height: 8),
                                            Text('Large'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            HuxLoading(
                                                size:
                                                    HuxLoadingSize.extraLarge),
                                            SizedBox(height: 8),
                                            Text('XL'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    HuxButton(
                                      onPressed: _toggleLoading,
                                      variant: HuxButtonVariant.outline,
                                      child: Text(_isLoading
                                          ? 'Stop Loading'
                                          : 'Show Loading Overlay'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _datePickerNavKey,
                            child: SectionWithDocumentation(
                              componentName: 'date-picker',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Date Picker',
                                subtitle: 'Themed picker for date selection',
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    // Dropdown-only variant
                                    Center(
                                      child: HuxDatePicker(
                                        initialDate: _selectedDateInline,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        onDateChanged: (date) {
                                          setState(() {
                                            _selectedDateInline = date;
                                          });
                                        },
                                        variant: HuxButtonVariant.outline,
                                        icon: LucideIcons.calendar,
                                        placeholder: 'Select Date',
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _tooltipKey,
                            child: SectionWithDocumentation(
                              componentName: 'tooltip',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Tooltip',
                                subtitle: 'Contextual help and information',
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    // Basic tooltip example
                                    Center(
                                      child: HuxTooltip(
                                        message: 'This is a tooltip message',
                                        preferBelow: false,
                                        verticalOffset: 16.0,
                                        child: HuxButton(
                                          onPressed: () {},
                                          variant: HuxButtonVariant.outline,
                                          child: const Text('Hover'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _dialogKey,
                            child: SectionWithDocumentation(
                              componentName: 'dialog',
                              child: HuxCard(
                                size: HuxCardSize.large,
                                backgroundColor: HuxColors.white5,
                                borderColor: HuxTokens.borderSecondary(context),
                                title: 'Dialog',
                                subtitle: 'Modal dialogs with Hux styling',
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    // Confirmation dialog example
                                    Center(
                                      child: HuxButton(
                                        onPressed: () =>
                                            _showConfirmationDialog(context),
                                        variant: HuxButtonVariant.outline,
                                        child: const Text(
                                            'Show Confirmation Dialog'),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _bottomSheetKey,
                            child: SectionWithDocumentation(
                              componentName: 'bottom-sheet',
                              child: BottomSheetSection(
                                onShowSnackBar: _showSnackBar,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _dropdownKey,
                            child: SectionWithDocumentation(
                              componentName: 'dropdown',
                              child: DropdownSection(
                                primaryColor: _currentPrimaryColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _paginationKey,
                            child: const SectionWithDocumentation(
                              componentName: 'pagination',
                              child: PaginationSection(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _tabsKey,
                            child: const SectionWithDocumentation(
                              componentName: 'tabs',
                              child: TabsSection(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _breadcrumbsKey,
                            child: const SectionWithDocumentation(
                              componentName: 'breadcrumbs',
                              child: BreadcrumbsSection(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            key: _commandKey,
                            child: SectionWithDocumentation(
                              componentName: 'command',
                              child: CommandSection(
                                onThemeToggle: widget.onThemeToggle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Sample data generators for charts
  List<Map<String, dynamic>> _getSampleLineData() {
    return [
      {'day': 1, 'calories': 520, 'type': 'Daily Goal'},
      {'day': 2, 'calories': 480, 'type': 'Daily Goal'},
      {'day': 3, 'calories': 440, 'type': 'Daily Goal'},
      {'day': 4, 'calories': 580, 'type': 'Daily Goal'},
      {'day': 5, 'calories': 520, 'type': 'Daily Goal'},
      {'day': 6, 'calories': 610, 'type': 'Daily Goal'},
      {'day': 7, 'calories': 490, 'type': 'Daily Goal'},
      {'day': 8, 'calories': 550, 'type': 'Daily Goal'},
      {'day': 9, 'calories': 580, 'type': 'Daily Goal'},
      {'day': 10, 'calories': 470, 'type': 'Daily Goal'},
      {'day': 11, 'calories': 620, 'type': 'Daily Goal'},
      {'day': 12, 'calories': 540, 'type': 'Daily Goal'},
      {'day': 13, 'calories': 510, 'type': 'Daily Goal'},
      {'day': 14, 'calories': 590, 'type': 'Daily Goal'},
    ];
  }

  List<Map<String, dynamic>> _getSampleBarData() {
    return [
      {'product': 'Mobile', 'revenue': 450},
      {'product': 'Tablet', 'revenue': 320},
      {'product': 'Laptop', 'revenue': 580},
      {'product': 'Desktop', 'revenue': 290},
      {'product': 'Watch', 'revenue': 180},
    ];
  }

  void _showSnackBar(String message) {
    context.showHuxSnackbar(
      message: message,
      variant: HuxSnackbarVariant.info,
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showHuxDialog(
      context: context,
      title: 'Confirm Action',
      subtitle: 'Are you sure you want to proceed?',
      content: const Text(
          'This action cannot be undone. Please confirm that you want to continue.'),
      actions: [
        HuxButton(
          onPressed: () => Navigator.of(context).pop(false),
          variant: HuxButtonVariant.secondary,
          child: const Text('Cancel'),
        ),
        HuxButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            _showSnackBar('Action confirmed!');
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildSizeButton(String label, HuxButtonSize size) {
    final isSelected = _selectedButtonSize == size;

    return HuxButton(
      onPressed: () {
        setState(() {
          _selectedButtonSize = size;
        });
      },
      variant: isSelected ? HuxButtonVariant.primary : HuxButtonVariant.outline,
      size: HuxButtonSize.small,
      width: HuxButtonWidth.fixed,
      widthValue: 40,
      child: Text(
        label,
        // ignore: prefer_const_constructors
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Checkboxes Section
class CheckboxesSection extends StatefulWidget {
  const CheckboxesSection({super.key});

  @override
  State<CheckboxesSection> createState() => _CheckboxesSectionState();
}

class _CheckboxesSectionState extends State<CheckboxesSection> {
  bool _checkboxValue = false;
  final bool _checkboxDisabled = true;

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Checkbox',
      subtitle: 'Interactive checkbox controls',
      child: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HuxCheckbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value ?? false;
                    });
                  },
                  label: 'I agree to the terms and conditions',
                ),
                const SizedBox(height: 16),
                HuxCheckbox(
                  value: _checkboxDisabled,
                  onChanged: null,
                  label: 'Disabled checkbox',
                  isDisabled: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Radio Buttons Section
class RadioButtonsSection extends StatefulWidget {
  const RadioButtonsSection({super.key});

  @override
  State<RadioButtonsSection> createState() => _RadioButtonsSectionState();
}

class _RadioButtonsSectionState extends State<RadioButtonsSection> {
  String _selectedOption = 'option1';

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Radio Buttons',
      subtitle: 'Interactive radio button controls',
      child: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HuxRadio<String>(
                  value: 'option1',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value ?? 'option1';
                    });
                  },
                  label: 'Option 1',
                ),
                const SizedBox(height: 16),
                HuxRadio<String>(
                  value: 'option2',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value ?? 'option1';
                    });
                  },
                  label: 'Option 2',
                ),
                const SizedBox(height: 16),
                HuxRadio<String>(
                  value: 'option3',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value ?? 'option1';
                    });
                  },
                  label: 'Option 3',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Toggle Switches Section
class ToggleSwitchesSection extends StatefulWidget {
  const ToggleSwitchesSection({super.key});

  @override
  State<ToggleSwitchesSection> createState() => _ToggleSwitchesSectionState();
}

class _ToggleSwitchesSectionState extends State<ToggleSwitchesSection> {
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Switch',
      subtitle: 'Interactive toggle switch control',
      child: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HuxSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  _switchValue ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Slider Section
class SliderSection extends StatefulWidget {
  const SliderSection({super.key});

  @override
  State<SliderSection> createState() => _SliderSectionState();
}

class _SliderSectionState extends State<SliderSection> {
  double _sliderValue = 50.0;

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Slider',
      subtitle: 'Interactive slider control for selecting numeric values',
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: HuxSlider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
              min: 0,
              max: 100,
              label: 'Volume',
              showValue: true,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// Badges Section
class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Badge',
      subtitle: 'Status indicators and notification counters',
      child: const Column(
        children: [
          SizedBox(height: 32),
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HuxBadge(
                    label: 'Primary',
                    variant: HuxBadgeVariant.primary,
                    size: HuxBadgeSize.small),
                HuxBadge(
                    label: 'Secondary',
                    variant: HuxBadgeVariant.secondary,
                    size: HuxBadgeSize.small),
                HuxBadge(
                    label: 'Outline',
                    variant: HuxBadgeVariant.outline,
                    size: HuxBadgeSize.small),
                HuxBadge(
                    label: 'Success',
                    variant: HuxBadgeVariant.success,
                    size: HuxBadgeSize.small),
                HuxBadge(
                    label: 'Destructive',
                    variant: HuxBadgeVariant.destructive,
                    size: HuxBadgeSize.small),
                HuxBadge(
                    label: '99+',
                    variant: HuxBadgeVariant.primary,
                    size: HuxBadgeSize.small),
              ],
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Indicators Section
class IndicatorsSection extends StatelessWidget {
  const IndicatorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Snackbar',
      subtitle: 'Temporary notification messages for user actions and status',
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Information Snackbar
          Center(
            child: HuxAlert(
              variant: HuxAlertVariant.info,
              title: 'Information',
              message: 'This is a informational message.',
              showIcon: true,
              onDismiss: () {
                context.showHuxSnackbar(
                  message: 'Information alert dismissed',
                  variant: HuxSnackbarVariant.info,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Success Alert
          Center(
            child: HuxAlert(
              variant: HuxAlertVariant.success,
              title: 'Success',
              message: 'Your operation completed successfully!',
              showIcon: true,
              onDismiss: () {
                context.showHuxSnackbar(
                  message: 'Success alert dismissed',
                  variant: HuxSnackbarVariant.success,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Destructive Alert
          Center(
            child: HuxAlert(
              variant: HuxAlertVariant.error,
              title: 'Destructive',
              message:
                  'This action cannot be undone. Please proceed with caution.',
              showIcon: true,
              onDismiss: () {
                context.showHuxSnackbar(
                  message: 'Destructive alert dismissed',
                  variant: HuxSnackbarVariant.error,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Display Section
class DisplaySection extends StatelessWidget {
  const DisplaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Avatar',
      subtitle: 'User avatars and profile displays',
      child: const Column(
        children: [
          SizedBox(height: 32),

          // Avatars and avatar group inline
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HuxAvatar(
                  name: 'John Doe',
                  size: HuxAvatarSize.small,
                ),
                SizedBox(width: 16),
                HuxAvatar(
                  name: 'Lofi Designer',
                  assetImage: 'assets/lofidesigner.png', // Your custom image
                  size: HuxAvatarSize.small,
                ),
                SizedBox(width: 16),
                HuxAvatar(
                  useGradient: true,
                  size: HuxAvatarSize.small,
                ),
                SizedBox(width: 48),
                HuxAvatarGroup(
                  avatars: [
                    HuxAvatar(
                      useGradient: true,
                      gradientVariant: HuxAvatarGradient.bluePurple,
                    ),
                    HuxAvatar(
                      useGradient: true,
                      gradientVariant: HuxAvatarGradient.greenBlue,
                    ),
                    HuxAvatar(
                      useGradient: true,
                      gradientVariant: HuxAvatarGradient.orangeRed,
                    ),
                  ],
                  size: HuxAvatarSize.small,
                  overlap: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Dropdown Section
class DropdownSection extends StatefulWidget {
  final Color primaryColor;

  const DropdownSection({
    super.key,
    required this.primaryColor,
  });

  @override
  State<DropdownSection> createState() => _DropdownSectionState();
}

class _DropdownSectionState extends State<DropdownSection> {
  String? _selectedOption;
  HuxButtonVariant _selectedVariant = HuxButtonVariant.outline;
  bool _useItemWidgetAsValue = false;

  final List<HuxDropdownItem<String>> _options = [
    const HuxDropdownItem(
      value: 'Option 1',
      child: Row(
        children: [
          Icon(LucideIcons.user, size: 16),
          SizedBox(width: 8),
          Text('Option 1'),
        ],
      ),
    ),
    const HuxDropdownItem(
      value: 'Option 2',
      child: Row(
        children: [
          Icon(LucideIcons.settings, size: 16),
          SizedBox(width: 8),
          Text('Option 2'),
        ],
      ),
    ),
    const HuxDropdownItem(
      value: 'Option 3',
      child: Row(
        children: [
          Icon(LucideIcons.bell, size: 16),
          SizedBox(width: 8),
          Text('Option 3'),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Dropdown',
      subtitle: 'Dropdown/select components with various styles',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Group 1: Variant label + dropdown
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Variant:',
                style: TextStyle(
                  color: HuxTokens.textSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 160,
                child: HuxDropdown<HuxButtonVariant>(
                  items: const [
                    HuxDropdownItem(
                      value: HuxButtonVariant.primary,
                      child: Text('Primary'),
                    ),
                    HuxDropdownItem(
                      value: HuxButtonVariant.secondary,
                      child: Text('Secondary'),
                    ),
                    HuxDropdownItem(
                      value: HuxButtonVariant.outline,
                      child: Text('Outline'),
                    ),
                    HuxDropdownItem(
                      value: HuxButtonVariant.ghost,
                      child: Text('Ghost'),
                    ),
                  ],
                  value: _selectedVariant,
                  onChanged: (value) {
                    setState(() {
                      _selectedVariant = value;
                    });
                  },
                  placeholder: 'Select variant',
                  variant: HuxButtonVariant.outline,
                  size: HuxButtonSize.small,
                  primaryColor: widget.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Group 2: Item widget label + switch
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item widget as value:',
                style: TextStyle(
                  color: HuxTokens.textSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              HuxSwitch(
                value: _useItemWidgetAsValue,
                onChanged: (value) {
                  setState(() {
                    _useItemWidgetAsValue = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 200,
              child: HuxDropdown<String>(
                items: _options,
                value: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
                placeholder: 'Select an option',
                useItemWidgetAsValue: _useItemWidgetAsValue,
                variant: _selectedVariant,
                primaryColor: widget.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Toggle Buttons Section
class ToggleButtonsSection extends StatefulWidget {
  const ToggleButtonsSection({super.key});

  @override
  State<ToggleButtonsSection> createState() => _ToggleButtonsSectionState();
}

class _ToggleButtonsSectionState extends State<ToggleButtonsSection> {
  bool _isEditing = false;
  HuxButtonVariant _selectedVariant = HuxButtonVariant.primary;

  Color _currentPrimaryColor(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_MyHomePageState>();
    return parentState?._currentPrimaryColor(context) ??
        HuxTokens.primary(context);
  }

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Toggle',
      subtitle: 'Two-state toggle buttons for formatting controls',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Variant:',
            style: TextStyle(
              color: HuxTokens.textSecondary(context),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: HuxDropdown<HuxButtonVariant>(
              items: const [
                HuxDropdownItem(
                  value: HuxButtonVariant.primary,
                  child: Text('Primary'),
                ),
                HuxDropdownItem(
                  value: HuxButtonVariant.secondary,
                  child: Text('Secondary'),
                ),
                HuxDropdownItem(
                  value: HuxButtonVariant.outline,
                  child: Text('Outline'),
                ),
                HuxDropdownItem(
                  value: HuxButtonVariant.ghost,
                  child: Text('Ghost'),
                ),
              ],
              value: _selectedVariant,
              onChanged: (value) {
                setState(() {
                  _selectedVariant = value;
                });
              },
              placeholder: 'Select variant',
              variant: HuxButtonVariant.outline,
              size: HuxButtonSize.small,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                // Icon-only toggle
                HuxToggle(
                  value: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _isEditing = value;
                    });
                  },
                  icon: LucideIcons.edit2,
                  variant: _selectedVariant,
                  primaryColor: _currentPrimaryColor(context),
                ),
                const SizedBox(height: 16),
                // Icon with text toggle
                HuxToggle(
                  value: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _isEditing = value;
                    });
                  },
                  icon: LucideIcons.edit2,
                  label: 'Edit',
                  variant: _selectedVariant,
                  primaryColor: _currentPrimaryColor(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class PaginationSection extends StatefulWidget {
  const PaginationSection({
    super.key,
  });

  @override
  State<PaginationSection> createState() => _PaginationSectionState();
}

class _PaginationSectionState extends State<PaginationSection> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Reduce pages on mobile to prevent overflow
    final totalPages = isMobile ? 10 : 20;
    final maxPagesToShow = isMobile ? 3 : 5;

    // Clamp current page to valid range if totalPages changed
    final currentPage = _currentPage.clamp(1, totalPages);

    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Pagination',
      subtitle: 'Navigate through pages with intelligent ellipsis handling.',
      child: Column(
        children: [
          const SizedBox(height: 16),

          HuxPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            maxPagesToShow: maxPagesToShow,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          const SizedBox(height: 16),

          // Current page indicator
          Text(
            'Current Page: $currentPage',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HuxTokens.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }
}

class CommandSection extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const CommandSection({super.key, this.onThemeToggle});

  @override
  State<CommandSection> createState() => _CommandSectionState();
}

class _CommandSectionState extends State<CommandSection> {
  late final List<HuxCommandItem> _commands;

  @override
  void initState() {
    super.initState();
    _commands = [
      HuxCommandItem(
        id: 'toggle-theme',
        label: 'Toggle Theme',
        description: 'Switch between light and dark mode',
        shortcut: '⌘⇧D',
        icon: LucideIcons.sun,
        category: 'View',
        onExecute: () {
          widget.onThemeToggle?.call();
          _showSnackBar('Theme toggled');
        },
      ),
      HuxCommandItem(
        id: 'quick-search',
        label: 'Quick Search',
        description: 'Search across all content',
        shortcut: '⌘⇧K',
        icon: LucideIcons.search,
        category: 'Navigation',
        onExecute: () => _showSnackBar('Quick search opened'),
      ),
      HuxCommandItem(
        id: 'new-project',
        label: 'New Project',
        description: 'Create a new project',
        shortcut: '⌘⇧N',
        icon: LucideIcons.folderPlus,
        category: 'Project',
        onExecute: () => _showSnackBar('New project created'),
      ),
      HuxCommandItem(
        id: 'settings',
        label: 'Settings',
        description: 'Open application settings',
        shortcut: '⌘,',
        icon: LucideIcons.settings,
        category: 'Preferences',
        onExecute: () => _showSnackBar('Settings opened'),
      ),
      HuxCommandItem(
        id: 'help',
        label: 'Help & Support',
        description: 'View help documentation',
        shortcut: '⌘H',
        icon: LucideIcons.helpCircle,
        category: 'Help',
        onExecute: () {
          _showSnackBar('Help documentation would open here');
          // In a real app, this would open help documentation
        },
      ),
      HuxCommandItem(
        id: 'open-command-palette',
        label: 'Open Command Palette',
        description: 'Open the command palette',
        shortcut: '⌘⇧K',
        icon: LucideIcons.command,
        category: 'Navigation',
        onExecute: () {
          showHuxCommand(
            context: context,
            commands: _commands,
            onCommandSelected: (command) {
              _showSnackBar('Command executed: ${command.label}');
            },
          );
        },
      ),
    ];
  }

  void _showSnackBar(String message) {
    context.showHuxSnackbar(
      message: message,
      variant: HuxSnackbarVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Command Palette',
      subtitle: 'Quick access to commands via CMD+K or action button',
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Description
          Text(
            'Press CMD+K (or Ctrl+K) to open the command palette, or click the button below:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HuxTokens.textSecondary(context),
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Open Command Palette Button
          Center(
            child: HuxButton(
              onPressed: () => showHuxCommand(
                context: context,
                commands: _commands,
                onCommandSelected: (command) {
                  _showSnackBar('Command executed: ${command.label}');
                },
              ),
              icon: LucideIcons.command,
              child: const Text('Open Command Palette'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
