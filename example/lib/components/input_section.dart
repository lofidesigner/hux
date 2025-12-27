import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class InputSection extends StatefulWidget {
  const InputSection({super.key});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _textareaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _textareaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'input',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Input',
        subtitle: 'Input components with validation',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 768;
            final isTabletScreen = screenWidth >= 768 && screenWidth < 1024;
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
                      prefixIcon: const Icon(LucideIcons.mail),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
                      prefixIcon: const Icon(LucideIcons.lock),
                      suffixIcon: const Icon(LucideIcons.eye),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
                      helperText: 'Provide a detailed description',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
    );
  }
}
