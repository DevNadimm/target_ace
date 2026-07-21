// import 'package:flutter/material.dart' hide BackButton;
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:target_ace/core/components/back_button.dart';
// import 'package:target_ace/core/components/custom_container.dart';
// import 'package:target_ace/core/components/custom_divider.dart';
// import 'package:target_ace/core/components/custom_text_field.dart';
// import 'package:target_ace/core/components/spring_button.dart';
// import 'package:target_ace/core/config/assets.dart';
// import 'package:target_ace/core/config/colors.dart';
// import 'package:target_ace/core/shared/widgets/gradient_background.dart';
// import 'package:target_ace/core/shared/widgets/loader.dart';
// import 'package:target_ace/core/utils/helpers/helper_functions.dart';
// import 'package:target_ace/features/subscription/presentation/pages/subscription_pending_page.dart';
//
// class SubscriptionPaymentPage extends StatefulWidget {
//   final Map plan;
//
//   static Route route({required Map plan}) => MaterialPageRoute(builder: (_) => SubscriptionPaymentPage(plan: plan));
//
//   const SubscriptionPaymentPage({super.key, required this.plan});
//
//   @override
//   State<SubscriptionPaymentPage> createState() => _SubscriptionPaymentPageState();
// }
//
// class _SubscriptionPaymentPageState extends State<SubscriptionPaymentPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _senderController = TextEditingController();
//   final _trxIdController = TextEditingController();
//
//   String _selectedMethod = 'bkash';
//   bool _isSubmitting = false;
//
//   static const Map<String, Map<String, dynamic>> _paymentMethods = {
//     'bkash': {
//       'name': 'bKash',
//       'number': '01944557101',
//       'type': 'Personal',
//       'logo': Assets.premium,
//       'color': Color(0xFFE2125D),
//     },
//     'nagad': {
//       'name': 'Nagad',
//       'number': '01944557101',
//       'type': 'Personal',
//       'logo': Assets.premium,
//       'color': Color(0xFFEC5A24),
//     },
//   };
//
//   @override
//   void dispose() {
//     _senderController.dispose();
//     _trxIdController.dispose();
//     super.dispose();
//   }
//
//   void _submitPayment() {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//
//     setState(() => _isSubmitting = true);
//
//     // Simulate brief loading before navigate
//     Future.delayed(const Duration(milliseconds: 600), () {
//       if (!mounted) return;
//       Navigator.pushAndRemoveUntil(
//         context,
//         SubscriptionPendingPage.route(),
//         (route) => false,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         _content(context),
//         if (_isSubmitting)
//           Container(
//             color: AppColors.black.withValues(alpha: 0.6),
//             child: const Center(child: Loader()),
//           ),
//       ],
//     );
//   }
//
//   Widget _content(BuildContext context) {
//     final planName = widget.plan['name'] as String? ?? '';
//     final price = widget.plan['price'] as int? ?? 0;
//     final duration = widget.plan['duration_days'] as int? ?? 30;
//
//     final method = _paymentMethods[_selectedMethod]!;
//     final methodNumber = method['number'] as String;
//     final methodName = method['name'] as String;
//
//     return Scaffold(
//       appBar: AppBar(leading: const BackButton()),
//       body: GradientBackground(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 16),
//                 Text(
//                   "Complete Payment",
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Follow the instructions below to upgrade your plan.",
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 CustomContainer(
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryDark.withValues(alpha: 0.08),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const HugeIcon(
//                           icon: HugeIcons.strokeRoundedDiamond02,
//                           color: AppColors.primaryDark,
//                           size: 22,
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               planName,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.textPrimary,
//                                 height: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               "$duration days subscription",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         HelperFunctions.formatTakaWithSymbol(price),
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primaryDark,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   "Select Payment Method",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: _paymentMethods.entries.map((entry) {
//                     final key = entry.key;
//                     final details = entry.value;
//                     final isSelected = _selectedMethod == key;
//                     final activeColor = details['color'] as Color;
//                     final logo = details['logo'] as String;
//                     final name = details['name'] as String;
//
//                     return Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: GestureDetector(
//                           onTap: () => setState(() => _selectedMethod = key),
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             decoration: BoxDecoration(
//                               color: isSelected ? activeColor.withValues(alpha: 0.08) : AppColors.card,
//                               border: Border.all(
//                                 color: isSelected ? activeColor : AppColors.inputBorder,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               children: [
//                                 SvgPicture.asset(logo, height: 30),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   name,
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 13,
//                                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                                     color: isSelected ? activeColor : AppColors.textSecondary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 20),
//                 CustomContainer(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 6,
//                             height: 18,
//                             decoration: BoxDecoration(
//                               color: AppColors.primaryDark,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             "How to Pay via $methodName",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.textPrimary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       CustomDivider.dotted(),
//                       const SizedBox(height: 14),
//                       _InstructionStep(
//                         step: "1",
//                         text: "Open your $methodName app and tap Send Money.",
//                       ),
//                       const SizedBox(height: 10),
//                       _InstructionStep(
//                         step: "2",
//                         text: "Send the exact amount to the number below:",
//                       ),
//                       const SizedBox(height: 10),
//                       _CopyBox(
//                         label: "Account Number (${method['type'] as String})",
//                         value: methodNumber,
//                         onCopy: () => Clipboard.setData(
//                           ClipboardData(text: methodNumber.replaceAll('-', '')),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _InstructionStep(
//                         step: "3",
//                         text: "The exact amount to send is shown below:",
//                       ),
//                       const SizedBox(height: 10),
//                       _CopyBox(
//                         label: "Amount",
//                         value: HelperFunctions.formatTakaWithSymbol(price),
//                         onCopy: () => Clipboard.setData(
//                           ClipboardData(text: price.toString()),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _InstructionStep(
//                         step: "4",
//                         text: "Enter your sender number and Transaction ID (TrxID) in the form below and tap Submit.",
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   "Payment Confirmation",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 CustomContainer(
//                   child: Column(
//                     children: [
//                       CustomTextField(
//                         label: "Sender Mobile Number",
//                         controller: _senderController,
//                         isRequired: true,
//                         keyboardType: TextInputType.phone,
//                         hintText: 'Enter your mobile number',
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return "Sender number is required";
//                           }
//                           final v = value.trim();
//                           if (v.length != 11 || !RegExp(r'^01[3-9]\d{8}$').hasMatch(v)) {
//                             return "Enter a valid 11-digit Bangladeshi mobile number";
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       CustomTextField(
//                         label: "Transaction ID (TrxID)",
//                         controller: _trxIdController,
//                         isRequired: true,
//                         keyboardType: TextInputType.text,
//                         hintText: 'Enter your transaction ID',
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return "Transaction ID is required";
//                           }
//                           if (value.trim().length < 6) {
//                             return "Transaction ID seems too short";
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 SpringButton(
//                   onPressed: _submitPayment,
//                   child: Text("Submit Payment Request"),
//                 ),
//                 const SizedBox(height: 12),
//                 Center(
//                   child: Text(
//                     "Your request will be reviewed within 24 hours.",
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _InstructionStep extends StatelessWidget {
//   final String step;
//   final String text;
//
//   const _InstructionStep({required this.step, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 22,
//           height: 22,
//           decoration: BoxDecoration(
//             color: AppColors.primaryDark.withValues(alpha: 0.08),
//             shape: BoxShape.circle,
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             step,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryDark,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: AppColors.textPrimary,
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _CopyBox extends StatelessWidget {
//   final String label;
//   final String value;
//   final VoidCallback onCopy;
//
//   const _CopyBox({
//     required this.label,
//     required this.value,
//     required this.onCopy,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.inputBorder),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 10,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                     letterSpacing: 0.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: onCopy,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryDark.withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const HugeIcon(
//                 icon: HugeIcons.strokeRoundedCopy01,
//                 color: AppColors.primaryDark,
//                 size: 18,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

