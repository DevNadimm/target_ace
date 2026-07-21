import 'package:flutter/material.dart' hide BackButton;
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/battle/data/models/subject_model.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';
import 'package:target_ace/features/battle/presentation/pages/subject_practice_page.dart';

class SubjectsPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const SubjectsPage());

  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      String userGoal = await AppPreferences.getUserGoal();
      if (userGoal.isEmpty) {
        userGoal = 'bcs'; // Default goal fallback
      }

      final rawData = await BattleRepo.getSubjects(userGoal.toLowerCase());
      final subjects = rawData.map((json) => SubjectModel.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load subjects. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  List<List<dynamic>> _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'menu_book':
      case 'book':
        return HugeIcons.strokeRoundedBook02;
      case 'translate':
        return HugeIcons.strokeRoundedTranslate;
      case 'flag':
        return HugeIcons.strokeRoundedFlag02;
      case 'public':
        return HugeIcons.strokeRoundedGlobe02;
      case 'calculate':
        return HugeIcons.strokeRoundedCalculate;
      case 'memory':
      case 'science':
        return HugeIcons.strokeRoundedCpu;
      default:
        return HugeIcons.strokeRoundedBookOpen01;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'বিষয়ভিত্তিক অনুশীলন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: Loader());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage,
                style: GoogleFonts.poppins(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchSubjects,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects found for your target goal.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _SubjectCard(
          subject: subject,
          iconData: _getIcon(subject.iconName),
          onTap: () {
            Navigator.push(
              context,
              SubjectPracticePage.route(subject: subject),
            );
          },
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final List<List<dynamic>> iconData;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: iconData,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subject.description != null && subject.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subject.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
