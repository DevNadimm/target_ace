import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/profile/data/repos/profile_repo.dart';

class GroupSwitchPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const GroupSwitchPage());

  const GroupSwitchPage({super.key});

  @override
  State<GroupSwitchPage> createState() => _GroupSwitchPageState();
}

class _GroupSwitchPageState extends State<GroupSwitchPage> {

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLocked = true;
  String _currentGroupTitle = '';
  String _lockExpiryDate = '';
  int _remainingDays = 0;

  // Unlocked state variables
  int _currentStep = 0; // 0: Goal, 1: Subgroup (if applicable)
  String _selectedGoal = '';
  String _selectedGroup = '';

  List<Map<String, dynamic>> _serverGoals = [];
  List<Map<String, dynamic>> _serverGroups = [];
  bool _isFetchingGroups = false;

  @override
  void initState() {
    super.initState();
    _checkLockStatusAndLoad();
  }

  Future<void> _checkLockStatusAndLoad() async {
    try {
      final allowed = await AppPreferences.isGroupSwitchAllowed();
      final currentGroup = await AppPreferences.getActiveGroupTitle();
      final lockedUntil = await AppPreferences.getGroupLockedUntil();

      if (!allowed && lockedUntil != null && lockedUntil.isNotEmpty) {
        final expiry = DateTime.tryParse(lockedUntil);
        if (expiry != null) {
          final now = DateTime.now().toUtc();
          final difference = expiry.difference(now);
          _remainingDays = difference.inDays;
          if (_remainingDays < 0) _remainingDays = 0;
          _lockExpiryDate = DateFormatter.readable(lockedUntil);
        }
        setState(() {
          _isLocked = true;
          _currentGroupTitle = currentGroup.isNotEmpty ? currentGroup : 'Your Current Group';
          _isLoading = false;
        });
      } else {
        // Fetch goals since we are allowed to switch
        final response = await ProfileRepo.getOnboardingGoals();

        setState(() {
          _isLocked = false;
          _serverGoals = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotifier.showSnackBar(context, 'Failed to check lock status: $e', type: MessageType.error);
      }
    }
  }

  Future<void> _fetchGroupsFromServer(String goalId) async {
    setState(() {
      _isFetchingGroups = true;
      _serverGroups = [];
    });

    try {
      final response = await ProfileRepo.getBattleGroups(goalId);

      if (mounted) {
        setState(() {
          _serverGroups = List<Map<String, dynamic>>.from(response);
          _isFetchingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingGroups = false);
        AppNotifier.showSnackBar(context, 'Failed to load subgroups: $e', type: MessageType.error);
      }
    }
  }

  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  List<List<dynamic>> _mapIcon(String iconName) {
    switch (iconName) {
      case 'bookOpen':
        return HugeIcons.strokeRoundedBookOpen01;
      case 'graduateCap':
        return HugeIcons.strokeRoundedGraduateMale;
      case 'school':
        return HugeIcons.strokeRoundedSchool;
      case 'atom':
      case 'atom01':
        return HugeIcons.strokeRoundedAtom01;
      case 'chartAnalysing':
      case 'chart':
        return HugeIcons.strokeRoundedBarChart;
      case 'tools':
        return HugeIcons.strokeRoundedTools;
      case 'dna':
        return HugeIcons.strokeRoundedDna;
      default:
        return HugeIcons.strokeRoundedTarget01;
    }
  }

  bool get _requiresGroupSelection => _serverGroups.isNotEmpty;

  Future<void> _onNext() async {
    if (_currentStep == 0) {
      if (_selectedGoal.isEmpty) {
        AppNotifier.showSnackBar(context, 'Please select a target first.', type: MessageType.error);
        return;
      }

      await _fetchGroupsFromServer(_selectedGoal);

      if (_requiresGroupSelection) {
        setState(() => _currentStep = 1);
      } else {
        setState(() {
          _selectedGroup = _selectedGoal;
        });
        _confirmAndSubmit();
      }
    } else {
      if (_selectedGroup.isEmpty) {
        AppNotifier.showSnackBar(context, 'Please select a group first.', type: MessageType.error);
        return;
      }
      _confirmAndSubmit();
    }
  }

  void _onBack() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    } else {
      Navigator.pop(context);
    }
  }

  void _confirmAndSubmit() {
    String newGroupTitle = '';
    if (_requiresGroupSelection) {
      final chosen = _serverGroups.firstWhere((g) => g['id'] == _selectedGroup, orElse: () => <String, dynamic>{});
      newGroupTitle = chosen['title'] as String? ?? 'General';
    } else {
      final chosen = _serverGoals.firstWhere((g) => g['id'] == _selectedGoal, orElse: () => <String, dynamic>{});
      newGroupTitle = chosen['title'] as String? ?? 'General';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Switch',
          style: AppFonts.heading(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to switch to $newGroupTitle? This will lock you in this group for the next 30 days.',
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppFonts.body(fontSize: 14, color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitData(newGroupTitle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Switch Group', style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitData(String groupTitle) async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final lockedUntil = await ProfileRepo.switchGroup(
          userId: user.id,
          goalId: _selectedGoal,
          groupId: _selectedGroup,
        );

        // 4. Save locally
        await AppPreferences.setUserGoal(_selectedGoal);
        await AppPreferences.setUserGroup(_selectedGroup);
        await AppPreferences.saveGroupMembership(
          groupId: _selectedGroup,
          groupTitle: groupTitle,
          lockedUntil: lockedUntil,
        );

        if (mounted) {
          AppNotifier.showSnackBar(context, 'Group switched successfully!', type: MessageType.success);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Failed to switch group: $e', type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLocked ? 'Battle Group Status' : 'Switch Battle Group',
        ),
        leading: BackButton(onBack: _onBack),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: _isLoading
            ? const Center(child: Loader())
            : _isLocked
                ? _buildLockedView()
                : _buildUnlockedView(),
      ),
    );
  }

  Widget _buildLockedView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLock,
                color: AppColors.error,
                size: 72,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Group is Locked',
              style: AppFonts.heading(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'To ensure fair competition and leaderboard consistency, target groups are locked for 30 days upon selection.',
              style: AppFonts.body(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildLockedDetailRow('Current Group', _currentGroupTitle),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildLockedDetailRow('Locked Until', _lockExpiryDate),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildLockedDetailRow('Days Remaining', '$_remainingDays days'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: SpringButton(
                backgroundColor: AppColors.primary,
                shadowColor: Colors.black26,
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Okay, Back',
                  style: AppFonts.body(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: AppFonts.body(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildUnlockedView() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _currentStep == 0 ? _buildGoalStep() : _buildGroupStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _onBack,
                      child: Text(
                        'Back',
                        style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (_currentStep == 1 || !_requiresGroupSelection) ? 'Confirm' : 'Next',
                          style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isSaving)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: const Loader(),
          ),
      ],
    );
  }

  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select New Target',
          style: AppFonts.heading(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Switching your target will update your daily live exams. Note: This will lock your selection for 30 days.',
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 28),
        ..._serverGoals.map((goal) {
          final isSelected = _selectedGoal == goal['id'];
          final goalColor = _parseColor(goal['color_hex'] as String? ?? '#3B82F6');
          final goalIcon = _mapIcon(goal['icon_name'] as String? ?? '');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedGoal = goal['id'] as String;
                  _selectedGroup = '';
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: goalColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(icon: goalIcon, color: goalColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'] as String? ?? '',
                            style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal['subtitle'] as String? ?? '',
                            style: AppFonts.body(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGroupStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Battle Group',
          style: AppFonts.heading(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your scientific or academic stream. You will compete with peers studying the same subjects.',
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 28),
        if (_isFetchingGroups)
          const Center(child: Loader())
        else
          ..._serverGroups.map((group) {
            final isSelected = _selectedGroup == group['id'];
            final groupIcon = _mapIcon(group['icon_name'] as String? ?? '');

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedGroup = group['id'] as String);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(icon: groupIcon, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          group['title'] as String? ?? '',
                          style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
