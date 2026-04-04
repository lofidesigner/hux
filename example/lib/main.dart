import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hux/hux.dart';

import 'components/breadcrumbs_section.dart';
import 'components/kbd_section.dart';
import 'components/command_section.dart';
import 'components/tabs_section.dart';
import 'components/tab_view_section.dart';
import 'components/otp_section.dart';
import 'components/progress_section.dart';
import 'components/bottom_sheet_section.dart';
import 'components/buttons_section.dart';
import 'components/date_picker_section.dart';
import 'components/tooltip_section.dart';
import 'components/dialog_section.dart';
import 'components/dropdown_section.dart';
import 'components/pagination_section.dart';
import 'components/input_section.dart';
import 'components/cards_section.dart';
import 'components/charts_section.dart';
import 'components/context_menu_section.dart';
import 'components/checkboxes_section.dart';
import 'components/radio_buttons_section.dart';
import 'components/toggle_switches_section.dart';
import 'components/slider_section.dart';
import 'components/toggle_buttons_section.dart';
import 'components/badges_section.dart';
import 'components/snackbars_section.dart';
import 'components/avatars_section.dart';
import 'components/loading_section.dart';
import 'config/navigation_items.dart';
import 'config/global_commands.dart';
import 'widgets/sidebar_header.dart';

void main() {
  runApp(const MyApp());
}

enum _PaneDirection { left, right, up, down }

class _PaneNavigationIntent extends Intent {
  const _PaneNavigationIntent(this.direction);
  final _PaneDirection direction;
}

class _PaneNavigationAction extends Action<_PaneNavigationIntent> {
  _PaneNavigationAction({
    required this.shouldDeferToFocusedWidget,
    required this.onNavigate,
  });

  final bool Function() shouldDeferToFocusedWidget;
  final void Function(_PaneNavigationIntent intent) onNavigate;

  @override
  bool consumesKey(_PaneNavigationIntent intent) {
    return !shouldDeferToFocusedWidget();
  }

  @override
  Object? invoke(_PaneNavigationIntent intent) {
    if (shouldDeferToFocusedWidget()) {
      return null;
    }
    onNavigate(intent);
    return null;
  }
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
      commands: GlobalCommands.getCommands(
        context,
        _toggleTheme,
        () => GlobalCommands.showSettingsBottomSheet(context),
        () => GlobalCommands.showActionSheet(context),
      ),
      onCommandSelected: (command) {
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
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _sidebarScopeNode = FocusScopeNode(debugLabel: 'sidebarScope');
  final _contentScopeNode = FocusScopeNode(debugLabel: 'contentScope');
  bool _isLoading = false;

  // Theme state
  String _selectedTheme = 'default';
  Color _currentPrimaryColor(BuildContext context) =>
      _selectedTheme == 'default'
          ? HuxTokens.primary(context)
          : HuxColors.getPresetColor(_selectedTheme);

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
  final _tabViewKey = GlobalKey();
  final _breadcrumbsKey = GlobalKey();
  final _commandKey = GlobalKey();
  final _kbdKey = GlobalKey();
  final _otpKey = GlobalKey();

  String? _selectedItemId;

  @override
  void dispose() {
    _scrollController.dispose();
    _sidebarScopeNode.dispose();
    _contentScopeNode.dispose();
    super.dispose();
  }

  void _focusSidebar({required bool isMobile}) {
    if (isMobile) {
      _scaffoldKey.currentState?.openDrawer();
    }
    _sidebarScopeNode.requestFocus();
  }

  void _focusContent() {
    _contentScopeNode.requestFocus();
  }

  void _moveFocusInActivePane({required bool forward}) {
    // Use hasFocus (not hasPrimaryFocus) so arrow navigation keeps moving
    // within the pane when any descendant of _sidebarScopeNode or
    // _contentScopeNode is focused. If neither pane currently owns focus,
    // _focusContent() is the intended fallback target.
    if (_sidebarScopeNode.hasFocus) {
      if (forward) {
        _sidebarScopeNode.nextFocus();
      } else {
        _sidebarScopeNode.previousFocus();
      }
      return;
    }

    if (_contentScopeNode.hasFocus) {
      if (forward) {
        _contentScopeNode.nextFocus();
      } else {
        _contentScopeNode.previousFocus();
      }
      return;
    }

    _focusContent();
  }

  bool _isArrowKeyOwnedByInteractiveWidget() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    final focusedContext = primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }

    bool isInteractiveWidget(Widget widget) {
      return widget is EditableText ||
          widget is TextField ||
          widget is Slider ||
          widget is DropdownButton ||
          widget is DropdownButtonFormField ||
          widget is DropdownMenu ||
          widget is CalendarDatePicker ||
          widget is DatePickerDialog ||
          widget is InputDatePickerFormField;
    }

    if (isInteractiveWidget(focusedContext.widget)) {
      return true;
    }

    var hasInteractiveAncestor = false;
    focusedContext.visitAncestorElements((element) {
      if (isInteractiveWidget(element.widget)) {
        hasInteractiveAncestor = true;
        return false;
      }
      return true;
    });

    return hasInteractiveAncestor;
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

    final keyMap = _getSectionKeyMap();
    final key = keyMap[itemId];
    if (key != null) {
      _scrollToSection(key);
    }
  }

  Map<String, GlobalKey> _getSectionKeyMap() {
    return {
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
      'tab-view': _tabViewKey,
      'breadcrumbs': _breadcrumbsKey,
      'command': _commandKey,
      'kbd': _kbdKey,
    };
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
                  child: FocusScope(
                    node: _sidebarScopeNode,
                    child: HuxSidebar(
                      items: NavigationItems.items,
                      selectedItemId: _selectedItemId,
                      onItemSelected: (itemId) {
                        _onSidebarItemSelected(itemId);
                        Navigator.of(context).pop();
                      },
                      header: SidebarHeader(
                        themeMode: widget.themeMode,
                        onThemeToggle: widget.onThemeToggle,
                        selectedTheme: _selectedTheme,
                        onThemeChanged: (theme) {
                          setState(() {
                            _selectedTheme = theme;
                          });
                        },
                      ),
                    ),
                  ),
                )
              : null,
          body: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.arrowLeft):
                  _PaneNavigationIntent(_PaneDirection.left),
              SingleActivator(LogicalKeyboardKey.arrowRight):
                  _PaneNavigationIntent(_PaneDirection.right),
              SingleActivator(LogicalKeyboardKey.arrowUp):
                  _PaneNavigationIntent(_PaneDirection.up),
              SingleActivator(LogicalKeyboardKey.arrowDown):
                  _PaneNavigationIntent(_PaneDirection.down),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _PaneNavigationIntent: _PaneNavigationAction(
                  shouldDeferToFocusedWidget:
                      _isArrowKeyOwnedByInteractiveWidget,
                  onNavigate: (_PaneNavigationIntent intent) {
                    switch (intent.direction) {
                      case _PaneDirection.left:
                        _focusSidebar(isMobile: isMobile);
                        break;
                      case _PaneDirection.right:
                        _focusContent();
                        break;
                      case _PaneDirection.up:
                        _moveFocusInActivePane(forward: false);
                        break;
                      case _PaneDirection.down:
                        _moveFocusInActivePane(forward: true);
                        break;
                    }
                  },
                ),
              },
              child: Row(
                children: [
                  if (!isMobile)
                    FocusScope(
                      node: _sidebarScopeNode,
                      child: HuxSidebar(
                        items: NavigationItems.items,
                        selectedItemId: _selectedItemId,
                        onItemSelected: _onSidebarItemSelected,
                        header: SidebarHeader(
                          themeMode: widget.themeMode,
                          onThemeToggle: widget.onThemeToggle,
                          selectedTheme: _selectedTheme,
                          onThemeChanged: (theme) {
                            setState(() {
                              _selectedTheme = theme;
                            });
                          },
                        ),
                      ),
                    ),

                  // Main Content Area
                  Expanded(
                    child: FocusScope(
                      node: _contentScopeNode,
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
                                ButtonsSection(
                                  key: _buttonsKey,
                                  onShowSnackBar: _showSnackBar,
                                  selectedTheme: _selectedTheme,
                                ),

                                const SizedBox(height: 32),

                                // Input Section
                                InputSection(
                                  key: _textFieldsKey,
                                ),

                                const SizedBox(height: 32),

                                // OTP Input Section
                                OtpSection(
                                  key: _otpKey,
                                  onShowSnackBar: _showSnackBar,
                                ),

                                const SizedBox(height: 32),

                                // Cards Section
                                CardsSection(
                                  key: _cardsKey,
                                ),

                                const SizedBox(height: 32),

                                // Charts Section
                                ChartsSection(
                                  key: _chartsKey,
                                  selectedTheme: _selectedTheme,
                                ),

                                const SizedBox(height: 32),

                                // Context Menu Section
                                ContextMenuSection(
                                  key: _contextMenuKey,
                                  onShowSnackBar: _showSnackBar,
                                  selectedTheme: _selectedTheme,
                                ),

                                const SizedBox(height: 32),

                                // Checkboxes Section
                                CheckboxesSection(key: _checkboxesKey),

                                const SizedBox(height: 32),

                                // Radio Buttons Section
                                RadioButtonsSection(key: _radioButtonsKey),

                                const SizedBox(height: 32),

                                // Toggle Switches Section
                                ToggleSwitchesSection(key: _toggleSwitchesKey),

                                const SizedBox(height: 32),

                                // Slider Section
                                SliderSection(key: _sliderKey),

                                const SizedBox(height: 32),

                                // Progress Section
                                ProgressSection(key: _progressKey),

                                const SizedBox(height: 32),

                                // Toggle Buttons Section
                                ToggleButtonsSection(
                                  key: _toggleButtonsKey,
                                  selectedTheme: _selectedTheme,
                                ),

                                const SizedBox(height: 32),

                                // Badges Section
                                BadgesSection(key: _badgesKey),

                                const SizedBox(height: 32),

                                // Alerts Section
                                SnackbarsSection(key: _indicatorsKey),

                                const SizedBox(height: 32),

                                // Avatars Section
                                AvatarsSection(key: _displayKey),

                                const SizedBox(height: 32),

                                // Loading Section
                                LoadingSection(
                                  key: _loadingKey,
                                  isLoading: _isLoading,
                                  onToggleLoading: _toggleLoading,
                                ),
                                const SizedBox(height: 32),
                                // Date Picker Section
                                DatePickerSection(key: _datePickerNavKey),
                                const SizedBox(height: 32),
                                // Tooltip Section
                                TooltipSection(key: _tooltipKey),
                                const SizedBox(height: 32),
                                // Dialog Section
                                DialogSection(
                                  key: _dialogKey,
                                  onShowConfirmationDialog:
                                      _showConfirmationDialog,
                                ),
                                const SizedBox(height: 32),
                                // Bottom Sheet Section
                                BottomSheetSection(
                                  key: _bottomSheetKey,
                                  onShowSnackBar: _showSnackBar,
                                ),
                                const SizedBox(height: 32),
                                // Dropdown Section
                                DropdownSection(
                                  key: _dropdownKey,
                                  primaryColor: _currentPrimaryColor(context),
                                ),
                                const SizedBox(height: 32),
                                // Pagination Section
                                PaginationSection(key: _paginationKey),
                                const SizedBox(height: 32),
                                // Tabs Section
                                TabsSection(key: _tabsKey),
                                const SizedBox(height: 32),
                                // TabView Section
                                TabViewSection(key: _tabViewKey),
                                const SizedBox(height: 32),
                                // Breadcrumbs Section
                                BreadcrumbsSection(key: _breadcrumbsKey),
                                const SizedBox(height: 32),
                                // KBD Section
                                KbdSection(key: _kbdKey),

                                const SizedBox(height: 32),

                                // Command Section
                                CommandSection(
                                  key: _commandKey,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
}
