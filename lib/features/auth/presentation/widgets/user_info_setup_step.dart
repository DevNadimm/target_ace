import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_text_field.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/utils/helpers/option_picker_bottom_sheet_helper.dart';

class UserInfoSetupStep extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController genderController;
  final TextEditingController dobController;
  final TextEditingController institutionController;
  final TextEditingController districtController;
  final List<String> genders;
  final List<String> districts;
  final VoidCallback onSelectDob;
  final String? phoneErrorText;
  final String? genderErrorText;
  final String? dobErrorText;
  final String? institutionErrorText;
  final String? districtErrorText;

  const UserInfoSetupStep({
    super.key,
    required this.phoneController,
    required this.genderController,
    required this.dobController,
    required this.institutionController,
    required this.districtController,
    required this.genders,
    required this.districts,
    required this.onSelectDob,
    this.phoneErrorText,
    this.genderErrorText,
    this.dobErrorText,
    this.institutionErrorText,
    this.districtErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Tell us about you',
          style: AppFonts.heading(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide your personal & institution details to complete your competitive profile.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),

        // Phone Number Input
        CustomTextField(
          label: 'Phone Number',
          controller: phoneController,
          hintText: 'e.g., 01700000000',
          isRequired: true,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          prefixIcon: HugeIcons.strokeRoundedCall02,
          errorText: phoneErrorText,
        ),
        const SizedBox(height: 20),

        // Gender Selection (Read only, with picker)
        CustomTextField(
          label: 'Gender',
          controller: genderController,
          hintText: 'Select your gender',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedUser03,
          suffixIcon: HugeIcons.strokeRoundedArrowDown01,
          errorText: genderErrorText,
          onTap: () {
            OptionPickerBottomSheetHelper.show(
              context: context,
              options: genders,
              controller: genderController,
              title: 'Select Gender',
            );
          },
        ),
        const SizedBox(height: 20),

        // Date of Birth Input (Read only, with DatePicker)
        CustomTextField(
          label: 'Date of Birth',
          controller: dobController,
          hintText: 'Select your date of birth',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedCalendar04,
          errorText: dobErrorText,
          onTap: onSelectDob,
        ),
        const SizedBox(height: 20),

        // Institution Input using CustomTextField
        CustomTextField(
          label: 'School / College / University',
          controller: institutionController,
          hintText: 'e.g., BUET, Dhaka College',
          isRequired: true,
          prefixIcon: HugeIcons.strokeRoundedUniversity,
          errorText: institutionErrorText,
        ),
        const SizedBox(height: 20),

        // District Input using CustomTextField with read-only & OptionPickerBottomSheetHelper
        CustomTextField(
          label: 'District',
          controller: districtController,
          hintText: 'Select your district',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedLocation01,
          suffixIcon: HugeIcons.strokeRoundedArrowDown01,
          errorText: districtErrorText,
          onTap: () {
            OptionPickerBottomSheetHelper.showSearchable(
              context: context,
              options: districts,
              controller: districtController,
              title: 'Select District',
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
