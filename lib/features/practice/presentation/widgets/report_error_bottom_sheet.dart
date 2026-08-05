import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/components/custom_text_field.dart';
import 'package:target_ace/core/components/custom_container.dart';

class ReportErrorBottomSheet extends StatefulWidget {
  final String questionId;
  final Function(String) onSubmit;

  const ReportErrorBottomSheet({
    super.key,
    required this.questionId,
    required this.onSubmit,
  });

  static Future<void> show(BuildContext context, {required String questionId, required Function(String) onSubmit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportErrorBottomSheet(
        questionId: questionId,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReportErrorBottomSheet> createState() => _ReportErrorBottomSheetState();
}

class _ReportErrorBottomSheetState extends State<ReportErrorBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });

    await widget.onSubmit(_controller.text.trim());
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Center(
                child: Container(
                  height: 5,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFlag02,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'FEEDBACK',
                              style: AppFonts.body(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Report Error',
                            style: AppFonts.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Found a typo, wrong answer, or unclear explanation? Let us know and we will fix it.',
                style: AppFonts.body(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Report Description',
                controller: _controller,
                hintText: 'Describe the issue...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SpringButton(
                onPressed: _isSubmitting ? () {} : _handleSubmit,
                child: Text(_isSubmitting ? 'Submitting...' : 'Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}