import 'package:flutter/material.dart';
import 'package:target_ace/features/profile/presentation/widgets/step_header.dart';

class SingleFieldStepContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const SingleFieldStepContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(title: title, subtitle: subtitle),
        child,
      ],
    );
  }
}
