// import 'dart:convert';
// import 'package:flutter/material.dart' hide BackButton;
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:target_ace/core/components/back_button.dart';
// import 'package:target_ace/core/components/custom_container.dart';
// import 'package:target_ace/core/components/custom_divider.dart';
// import 'package:target_ace/core/components/spring_button.dart';
// import 'package:target_ace/core/config/colors.dart';
// import 'package:target_ace/core/shared/widgets/gradient_background.dart';
// import 'package:target_ace/core/utils/helpers/helper_functions.dart';
// import 'package:target_ace/features/subscription/presentation/pages/subscription_payment_page.dart';
//
// class SubscriptionPlansPage extends StatefulWidget {
//   static Route route() => MaterialPageRoute(builder: (_) => const SubscriptionPlansPage());
//
//   const SubscriptionPlansPage({super.key});
//
//   @override
//   State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
// }
//
// class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
//   late final List _plans;
//
//   @override
//   void initState() {
//     super.initState();
//     final data = jsonDecode(_mockResponse);
//     _plans = data['data']['plans'] as List;
//   }
//
//   bool _isPopular(Map plan) => plan['name'] == 'Pro';
//
//   String? _yearlySavingsLabel(Map plan) {
//     final duration = plan['duration_days'] as int;
//     if (duration < 300) return null;
//
//     final baseName = (plan['name'] as String).replaceAll('Yearly', '').trim();
//
//     Map? monthlyMatch;
//     for (final p in _plans) {
//       final pDuration = p['duration_days'] as int;
//       if (p['name'] == baseName && pDuration < 90) {
//         monthlyMatch = p;
//         break;
//       }
//     }
//     if (monthlyMatch == null) return null;
//
//     final yearlyEquivalent = (monthlyMatch['price'] as int) * 12;
//     final savings = yearlyEquivalent - (plan['price'] as int);
//     if (savings <= 0) return null;
//
//     return "Save ${HelperFunctions.formatTakaWithSymbol(savings)} / year";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final canPop = Navigator.canPop(context);
//
//     return Scaffold(
//       appBar: canPop ? AppBar(leading: const BackButton()) : null,
//       body: GradientBackground(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Pick the plan that fits your needs",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Full control of your rental system. Upgrade anytime, cancel anytime. Transparent pricing with no hidden charges.",
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 22),
//
//               ..._plans.map((plan) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 18),
//                   child: _PlanCard(
//                     plan: plan,
//                     isPopular: _isPopular(plan),
//                     savingsLabel: _yearlySavingsLabel(plan),
//                     onTap: () {
//                       Navigator.push(context, SubscriptionPaymentPage.route(plan: plan));
//                     },
//                   ),
//                 );
//               }),
//
//               const SizedBox(height: 4),
//               Center(
//                 child: Text(
//                   "All plans come with a 7-day money-back guarantee",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PlanCard extends StatelessWidget {
//   final Map plan;
//   final bool isPopular;
//   final String? savingsLabel;
//   final VoidCallback onTap;
//
//   const _PlanCard({
//     required this.plan,
//     required this.onTap,
//     this.isPopular = false,
//     this.savingsLabel,
//   });
//
//   List<List<dynamic>> get _icon {
//     switch (plan['name']) {
//       case 'Starter':
//         return HugeIcons.strokeRoundedRocket01;
//       case 'Pro':
//         return HugeIcons.strokeRoundedStarAward02;
//       case 'Pro Yearly':
//         return HugeIcons.strokeRoundedDiamond02;
//       default:
//         return HugeIcons.strokeRoundedStar;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final features = (plan['features'] as List).cast<String>();
//     final price = plan['price'] as int;
//     final duration = plan['duration_days'] as int;
//     final pricePerDay = price / duration;
//
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         CustomContainer(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryDark.withValues(alpha: 0.08),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: HugeIcon(
//                       icon: _icon,
//                       color: AppColors.primaryDark,
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           plan['name'],
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                             height: 1,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           "$duration days plan",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         HelperFunctions.formatTakaWithSymbol(price),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textPrimary,
//                           height: 1,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         "â‰ˆ à§³${pricePerDay.toStringAsFixed(1)} / day",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//
//               if (savingsLabel != null) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     savingsLabel!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.green[700],
//                     ),
//                   ),
//                 ),
//               ],
//
//               const SizedBox(height: 12),
//               CustomDivider.dotted(),
//               const SizedBox(height: 12),
//
//               ...features.map(
//                 (f) => Padding(
//                   padding: const EdgeInsets.only(bottom: 9),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.check_circle_rounded,
//                         size: 18,
//                         color: AppColors.primaryDark,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           f,
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               SpringButton(
//                 onPressed: onTap,
//                 height: 46,
//                 child: Text(
//                   "Choose ${plan['name']}",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         if (isPopular)
//           Positioned(
//             top: -10,
//             right: 18,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.orange[600],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 "MOST POPULAR",
//                 style: GoogleFonts.poppins(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// /// MOCK API RESPONSE (replace with real API)
// const String _mockResponse = '''
// {
//   "status": 200,
//   "message": "success",
//   "data": {
//     "plans": [
//       {
//         "id": 1,
//         "name": "Starter",
//         "price": 500,
//         "duration_days": 30,
//         "features": [
//           "Basic dashboard",
//           "Rent collection system",
//           "Manual invoice generation",
//           "Single building management",
//           "Basic tenant list",
//           "Email notifications",
//           "Monthly summary report"
//         ]
//       },
//       {
//         "id": 2,
//         "name": "Pro",
//         "price": 1200,
//         "duration_days": 30,
//         "features": [
//           "Multi-building management",
//           "Advanced rent tracking",
//           "Expense tracking & categorization",
//           "Automated receipts",
//           "Downloadable reports (PDF/Excel)",
//           "Tenant history tracking",
//           "Payment reminders (SMS/Email)",
//           "Role-based access",
//           "Data backup (weekly)"
//         ]
//       },
//       {
//         "id": 3,
//         "name": "Pro Yearly",
//         "price": 12000,
//         "duration_days": 365,
//         "features": [
//           "Everything in Pro",
//           "2 months free pricing benefit",
//           "Priority support",
//           "Advanced analytics dashboard",
//           "Auto daily backup + restore history",
//           "Unlimited report exports",
//           "API access",
//           "Bulk notifications (SMS/WhatsApp)",
//           "Audit logs",
//           "Custom invoice branding",
//           "Early access to new features"
//         ]
//       }
//     ]
//   }
// }
// ''';

