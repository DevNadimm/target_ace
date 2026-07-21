import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:target_ace/core/components/option_picker_bottom_sheet.dart';
import 'package:target_ace/core/components/searchable_option_picker_bottom_sheet.dart';
import 'package:target_ace/core/config/colors.dart';

class OptionPickerBottomSheetHelper {
  OptionPickerBottomSheetHelper._();

  static Future<void> show({
    required BuildContext context,
    required List<String> options,
    required TextEditingController controller,
    required String title,
    ValueChanged<String>? onSelect,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: OptionPickerBottomSheet(
            options: options,
            controller: controller,
            title: title,
            onOptionPicked: (option) {
              controller.text = option;
              onSelect?.call(option);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  static Future<void> showSearchable({
    required BuildContext context,
    required List<String> options,
    required TextEditingController controller,
    required String title,
    ValueChanged<String>? onSelect,
  }) async {
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      useRootNavigator: false,
      isDismissible: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SearchableOptionPickerBottomSheet(
          options: options,
          controller: controller,
          title: title,
          onOptionPicked: (option) {
            controller.text = option;
            onSelect?.call(option);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
