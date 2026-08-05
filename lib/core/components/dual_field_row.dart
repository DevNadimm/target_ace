import 'package:flutter/material.dart';

class DualFieldRow extends StatelessWidget {
  final Widget firstField;
  final Widget lastField;
  final int? firstFlex;
  final int? lastFlex;

  const DualFieldRow({
    super.key,
    required this.firstField,
    required this.lastField,
    this.firstFlex,
    this.lastFlex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: firstFlex ?? 1,
          child: firstField,
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: lastFlex ?? 1,
          child: lastField,
        ),
      ],
    );
  }
}
