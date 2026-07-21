// import 'package:flutter/material.dart' hide BackButton;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:target_ace/core/components/back_button.dart';
// import 'package:target_ace/core/components/spring_button.dart';
// import 'package:target_ace/core/config/assets.dart';
// import 'package:target_ace/core/config/colors.dart';
// import 'package:target_ace/core/localization/cubit/language_cubit.dart';
// import 'package:target_ace/core/shared/widgets/gradient_background.dart';
// import 'package:target_ace/features/auth/presentation/pages/onboarding_page.dart';
// import 'package:target_ace/l10n/app_localizations.dart';
//
// class LanguageSelectionPage extends StatefulWidget {
//   final bool isFromProfile;
//
//   const LanguageSelectionPage({super.key, this.isFromProfile = false});
//
//   static Route route({bool isFromProfile = false}) {
//     return MaterialPageRoute(
//       builder: (context) => LanguageSelectionPage(isFromProfile: isFromProfile),
//     );
//   }
//
//   @override
//   State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
// }
//
// class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
//   String _selectedLanguageCode = 'en';
//
//   static const List<_LanguageOption> _languages = [
//     _LanguageOption(code: 'en', flagAsset: Assets.enFlag, nativeName: 'English', localizedKey: 'en'),
//     _LanguageOption(code: 'bn', flagAsset: Assets.bnFlag, nativeName: 'à¦¬à¦¾à¦‚à¦²à¦¾', localizedKey: 'bn'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedLanguageCode = context.read<LanguageCubit>().state.languageCode;
//   }
//
//   Future<void> _onContinue() async {
//     await context.read<LanguageCubit>().selectLanguage(_selectedLanguageCode);
//     if (widget.isFromProfile) {
//       if (mounted) Navigator.pop(context);
//     } else {
//       if (mounted) Navigator.pushReplacement(context, OnboardingPage.route());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(l10n.chooseLanguage),
//         leading: widget.isFromProfile
//             ? BackButton()
//             : null,
//         automaticallyImplyLeading: widget.isFromProfile,
//       ),
//       body: GradientBackground(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   l10n.selectLanguageSubtitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                 itemCount: _languages.length,
//                 separatorBuilder: (_, _) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final lang = _languages[index];
//                   final isSelected = _selectedLanguageCode == lang.code;
//                   return _LanguageCard(
//                     option: lang,
//                     isSelected: isSelected,
//                     onTap: () => setState(() => _selectedLanguageCode = lang.code),
//                   );
//                 },
//               ),
//             ),
//             _BottomContinueBar(
//               selectedCode: _selectedLanguageCode,
//               languages: _languages,
//               l10n: l10n,
//               onContinue: _onContinue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LanguageOption {
//   final String code;
//   final String flagAsset;
//   final String nativeName;
//   final String localizedKey;
//
//   const _LanguageOption({
//     required this.code,
//     required this.flagAsset,
//     required this.nativeName,
//     required this.localizedKey,
//   });
// }
//
// class _LanguageCard extends StatelessWidget {
//   final _LanguageOption option;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _LanguageCard({
//     required this.option,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isSelected ? AppColors.primary : AppColors.inputBorder,
//           width: isSelected ? 1.4 : 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Row(
//               children: [
//                 Container(
//                   width: 46,
//                   height: 46,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: AssetImage(option.flagAsset),
//                       fit: BoxFit.cover,
//                     ),
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.primary.withValues(alpha: 0.3)
//                           : AppColors.inputBorder,
//                       width: 1.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         option.nativeName,
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected
//                               ? AppColors.primary
//                               : AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         option.code.toUpperCase(),
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: AppColors.textSecondary,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 AnimatedOpacity(
//                   duration: const Duration(milliseconds: 200),
//                   opacity: isSelected ? 1.0 : 0.0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.check_rounded,
//                       color: AppColors.white,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _BottomContinueBar extends StatelessWidget {
//   final String selectedCode;
//   final List<_LanguageOption> languages;
//   final AppLocalizations l10n;
//   final VoidCallback onContinue;
//
//   const _BottomContinueBar({
//     required this.selectedCode,
//     required this.languages,
//     required this.l10n,
//     required this.onContinue,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final selected = languages.firstWhere(
//       (l) => l.code == selectedCode,
//       orElse: () => languages.first,
//     );
//
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         border: Border(
//           top: BorderSide(color: AppColors.inputBorder.withValues(alpha: 0.6)),
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 200),
//               child: Padding(
//                 key: ValueKey(selectedCode),
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         image: DecorationImage(
//                           image: AssetImage(selected.flagAsset),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       selected.nativeName,
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       l10n.languageSelected,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SpringButton(
//               onPressed: onContinue,
//               child: Text(l10n.continueButton),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
