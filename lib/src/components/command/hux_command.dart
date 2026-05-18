import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';
import 'hux_command_item.dart';

import 'hux_kbd.dart';

/// HuxCommand is a command palette component that provides quick access
/// to commands via search and keyboard shortcuts.
///
/// The command palette can be opened with CMD+K (or Ctrl+K on non-Mac platforms)
/// and provides a searchable list of available commands with their shortcuts.
///
/// Example:
/// ```dart
/// HuxCommand(
///   commands: [
///     HuxCommandItem(
///       id: 'new-file',
///       label: 'New File',
///       description: 'Create a new file',
///       shortcut: '⌘N',
///       icon: Icons.add,
///       onExecute: () => print('New file created'),
///     ),
///     HuxCommandItem(
///       id: 'save',
///       label: 'Save',
///       description: 'Save current file',
///       shortcut: '⌘S',
///       icon: Icons.save,
///       onExecute: () => print('File saved'),
///     ),
///   ],
/// )
/// ```
class HuxCommand extends StatefulWidget {
  /// Creates a HuxCommand widget
  const HuxCommand({
    super.key,
    required this.commands,
    this.placeholder = 'Type a command or search...',
    this.emptyText = 'No commands found',
    this.onCommandSelected,
    this.onClose,
  });

  /// List of available commands
  final List<HuxCommandItem> commands;

  /// Placeholder text for the search input
  final String placeholder;

  /// Text displayed when no commands match the search
  final String emptyText;

  /// Callback when a command is selected
  final ValueChanged<HuxCommandItem>? onCommandSelected;

  /// Callback when the command palette is closed
  final VoidCallback? onClose;

  @override
  State<HuxCommand> createState() => _HuxCommandState();
}

class _HuxCommandState extends State<HuxCommand> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  List<HuxCommandItem> _filteredCommands = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _filteredCommands = widget.commands;

    // Focus the search field when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterCommands();
  }

  void _filterCommands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCommands = widget.commands;
      } else {
        _filteredCommands = widget.commands.where((command) {
          return command.label.toLowerCase().contains(query) ||
              (command.description?.toLowerCase().contains(query) ?? false) ||
              (command.category?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      _selectedIndex = 0;
    });
  }

  void _executeCommand(HuxCommandItem command) {
    widget.onCommandSelected?.call(command);
    command.onExecute();
    Navigator.of(context).pop();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = _selectedIndex > 0
              ? _selectedIndex - 1
              : _filteredCommands.length - 1;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredCommands.isNotEmpty) {
          _executeCommand(_filteredCommands[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        widget.onClose?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            widget.onClose?.call();
          }
        },
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            widget.onClose?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside from closing
              child: Center(
                child: SizedBox(
                  height:
                      500, // viewport to keep the bar visually centered; grow/shrink from top
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 600,
                      decoration: BoxDecoration(
                        color: HuxTokens.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
                        border: Border.all(
                          color: HuxTokens.borderPrimary(context),
                          width: HuxTokens.borderWidth(context),
                        ),
                        boxShadow: HuxTokens.shadowElevated(context),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSearchInput(context),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(
                              height: 1,
                              color: HuxTokens.borderSecondary(context),
                            ),
                          ),
                          _buildCommandList(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HuxTokens.textSecondary(context),
            ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      ),
      onChanged: (_) => _filterCommands(),
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HuxTokens.textPrimary(context),
          ),
    );
  }

  Widget _buildCommandList(BuildContext context) {
    if (_filteredCommands.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      shrinkWrap: true,
      itemCount: _filteredCommands.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands[index];
        final isSelected = index == _selectedIndex;

        return _buildCommandItem(context, command, isSelected);
      },
    );
  }

  Widget _buildCommandItem(
      BuildContext context, HuxCommandItem command, bool isSelected) {
    return Material(
      color: isSelected ? HuxTokens.surfaceHover(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
      child: InkWell(
        onTap: () => _executeCommand(command),
        borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return HuxTokens.surfaceHover(context);
            }
            return null;
          },
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (command.icon != null) ...[
                Icon(
                  command.icon,
                  size: 18,
                  color: HuxTokens.iconPrimary(context),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  command.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: HuxTokens.textPrimary(context),
                      ),
                ),
              ),
              if (command.shortcut != null) ...[
                const SizedBox(width: 8),
                HuxKBD(shortcut: command.shortcut!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 32,
            color: HuxTokens.iconSecondary(context),
          ),
          const SizedBox(height: 12),
          Text(
            widget.emptyText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HuxTokens.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }
}

/// Shows the HuxCommand dialog with keyboard shortcut support
///
/// This function handles the CMD+K (or Ctrl+K) shortcut to open the command palette
/// and provides a convenient way to show the command dialog.
///
/// Example:
/// ```dart
/// showHuxCommand(
///   context: context,
///   commands: [
///     HuxCommandItem(
///       id: 'new-file',
///       label: 'New File',
///       onExecute: () => print('New file'),
///     ),
///   ],
/// );
/// ```
Future<void> showHuxCommand({
  required BuildContext context,
  required List<HuxCommandItem> commands,
  String placeholder = 'Type a command or search...',
  String emptyText = 'No commands found',
  ValueChanged<HuxCommandItem>? onCommandSelected,
  VoidCallback? onClose,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: HuxTokens.overlay(context),
    builder: (context) => HuxCommand(
      commands: commands,
      placeholder: placeholder,
      emptyText: emptyText,
      onCommandSelected: onCommandSelected,
      onClose: onClose,
    ),
  );
}
