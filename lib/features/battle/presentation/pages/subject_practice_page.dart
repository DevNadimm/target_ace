import 'package:flutter/material.dart' hide BackButton;
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/battle/data/models/question_model.dart';
import 'package:target_ace/features/battle/data/models/subject_model.dart';
import 'package:target_ace/features/battle/data/models/topic_model.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';

class SubjectPracticePage extends StatefulWidget {
  final SubjectModel subject;

  static Route route({required SubjectModel subject}) =>
      MaterialPageRoute(builder: (_) => SubjectPracticePage(subject: subject));

  const SubjectPracticePage({super.key, required this.subject});

  @override
  State<SubjectPracticePage> createState() => _SubjectPracticePageState();
}

class _SubjectPracticePageState extends State<SubjectPracticePage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<TopicModel> _topics = [];
  List<QuestionModel> _questions = [];
  String? _selectedTopicId;
  int _currentIndex = 0;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final rawTopics = await BattleRepo.getTopics(widget.subject.id);
      final topics = rawTopics.map((json) => TopicModel.fromJson(json)).toList();

      final rawQuestions = await BattleRepo.getSubjectQuestions(
        subjectId: widget.subject.id,
        topicId: _selectedTopicId,
      );
      final questions = rawQuestions.map((json) => QuestionModel.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _topics = topics;
          _questions = questions;
          _currentIndex = 0;
          _selectedOption = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load practice questions.';
          _isLoading = false;
        });
      }
    }
  }

  void _onTopicChanged(String? topicId) {
    if (_selectedTopicId == topicId) return;
    setState(() {
      _selectedTopicId = topicId;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          widget.subject.name,
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
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
        child: Text(
          _errorMessage,
          style: GoogleFonts.poppins(color: AppColors.error),
        ),
      );
    }

    return Column(
      children: [
        if (_topics.isNotEmpty) _buildTopicFilterChips(),
        Expanded(
          child: _questions.isEmpty
              ? Center(
                  child: Text(
                    'No questions available for this subject yet.',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                )
              : _buildQuestionPracticeView(),
        ),
      ],
    );
  }

  Widget _buildTopicFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          ChoiceChip(
            label: Text('All Chapters', style: GoogleFonts.hindSiliguri(fontSize: 13)),
            selected: _selectedTopicId == null,
            onSelected: (_) => _onTopicChanged(null),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 8),
          ..._topics.map((topic) {
            final isSelected = _selectedTopicId == topic.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(topic.name, style: GoogleFonts.hindSiliguri(fontSize: 13)),
                selected: isSelected,
                onSelected: (_) => _onTopicChanged(topic.id),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionPracticeView() {
    final currentQ = _questions[_currentIndex];
    final bool hasAnswered = _selectedOption != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Level ${currentQ.difficultyLevel}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(
              currentQ.questionText,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          _buildOptionTile('A', currentQ.optionA, currentQ.correctOption, hasAnswered),
          _buildOptionTile('B', currentQ.optionB, currentQ.correctOption, hasAnswered),
          _buildOptionTile('C', currentQ.optionC, currentQ.correctOption, hasAnswered),
          _buildOptionTile('D', currentQ.optionD, currentQ.correctOption, hasAnswered),

          // Explanation Card (Visible after selecting an option)
          if (hasAnswered && currentQ.explanation != null && currentQ.explanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        color: AppColors.info,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ব্যাখ্যা (Explanation)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentQ.explanation!,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentIndex > 0
                    ? () {
                        setState(() {
                          _currentIndex--;
                          _selectedOption = null;
                        });
                      }
                    : null,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.textPrimary),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _currentIndex < _questions.length - 1
                    ? () {
                        setState(() {
                          _currentIndex++;
                          _selectedOption = null;
                        });
                      }
                    : null,
                child: Text(
                  'পরবর্তী (Next)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String key, String text, String correctOption, bool hasAnswered) {
    final bool isSelected = _selectedOption == key;
    final bool isCorrect = key == correctOption;

    Color borderColor = AppColors.inputBorder;
    Color bgColor = AppColors.card;
    Color textColor = AppColors.textPrimary;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
      } else if (isSelected) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: hasAnswered
              ? null
              : () {
                  setState(() {
                    _selectedOption = key;
                  });
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected || (hasAnswered && isCorrect) ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
