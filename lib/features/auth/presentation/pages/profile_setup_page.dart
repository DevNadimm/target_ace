import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/components/custom_text_field.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/core/utils/helpers/option_picker_bottom_sheet_helper.dart';

class ProfileSetupPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const ProfileSetupPage());

  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int _currentStep = 0; // 0: Goal Selection, 1: Sub-group Selection (if applicable), 2: Info (School/College & District)
  String _selectedGoal = '';
  String _selectedGroup = '';
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetchingGoals = true;
  bool _isFetchingGroups = false;

  List<Map<String, dynamic>> _serverGoals = [];
  List<Map<String, dynamic>> _serverGroups = []; // Dynamically loaded based on selected goal

  final List<String> _districts = [
    'Dhaka', 'Chattogram', 'Rajshahi', 'Khulna', 'Sylhet', 'Barishal', 'Rangpur', 
    'Mymensingh', 'Cumilla', 'Jashore', 'Bogura', 'Cox\'s Bazar', 'Gazipur', 'Narayanganj',
    'Narsingdi', 'Tangail', 'Feni', 'Noakhali', 'Chandpur', 'Brahmanbaria'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
    _fetchGoalsFromServer();
  }

  Future<void> _prefillUserInfo() async {
    final phone = await AppPreferences.getUserPhone();
    final gender = await AppPreferences.getUserGender();
    final dob = await AppPreferences.getUserDob();

    if (phone.isNotEmpty) _phoneController.text = phone;
    if (gender.isNotEmpty) _genderController.text = gender;
    if (dob.isNotEmpty) _dobController.text = dob;
  }

  Future<void> _fetchGoalsFromServer() async {
    try {
      final response = await Supabase.instance.client
          .from('onboarding_goals')
          .select()
          .order('created_at', ascending: true);
      
      if (mounted) {
        setState(() {
          _serverGoals = List<Map<String, dynamic>>.from(response);
          _isFetchingGoals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingGoals = false);
        AppNotifier.showSnackBar(context, 'Failed to load targets: $e', type: MessageType.error);
      }
    }
  }

  Future<void> _fetchGroupsFromServer(String goalId) async {
    setState(() {
      _isFetchingGroups = true;
      _serverGroups = [];
    });

    try {
      final response = await Supabase.instance.client
          .from('battle_groups')
          .select()
          .eq('goal_id', goalId)
          .order('created_at', ascending: true);
      
      if (mounted) {
        setState(() {
          _serverGroups = List<Map<String, dynamic>>.from(response);
          _isFetchingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingGroups = false);
        AppNotifier.showSnackBar(context, 'Failed to load groups: $e', type: MessageType.error);
      }
    }
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Parses hex color string like #3B82F6 to Flutter Color
  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  // Maps DB icon_name to HugeIcon data list
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
        AppNotifier.showSnackBar(context, 'Please select a goal to proceed.', type: MessageType.error);
        return;
      }
      
      // Load groups for selected goal
      await _fetchGroupsFromServer(_selectedGoal);

      if (_requiresGroupSelection) {
        setState(() => _currentStep = 1);
      } else {
        // If no subgroups exist in DB, default group is goalId (e.g. bcs)
        setState(() {
          _selectedGroup = _selectedGoal;
          _currentStep = 2; // Jump to info
        });
      }
    } else if (_currentStep == 1) {
      if (_selectedGroup.isEmpty) {
        AppNotifier.showSnackBar(context, 'Please select your group/division.', type: MessageType.error);
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      _submitData();
    }
  }

  void _onBack() {
    if (_currentStep == 2) {
      if (_requiresGroupSelection) {
        setState(() => _currentStep = 1);
      } else {
        setState(() => _currentStep = 0);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    }
  }

  Future<void> _submitData() async {
    if (_phoneController.text.trim().isEmpty) {
      AppNotifier.showSnackBar(context, 'Please enter your phone number.', type: MessageType.error);
      return;
    }
    if (_genderController.text.trim().isEmpty) {
      AppNotifier.showSnackBar(context, 'Please select your gender.', type: MessageType.error);
      return;
    }
    if (_dobController.text.trim().isEmpty) {
      AppNotifier.showSnackBar(context, 'Please select your date of birth.', type: MessageType.error);
      return;
    }
    if (_institutionController.text.trim().isEmpty) {
      AppNotifier.showSnackBar(context, 'Please enter your institution name.', type: MessageType.error);
      return;
    }
    if (_districtController.text.trim().isEmpty) {
      AppNotifier.showSnackBar(context, 'Please select your district.', type: MessageType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final district = _districtController.text.trim();
        final phone = _phoneController.text.trim();
        final gender = _genderController.text.trim();
        final dob = _dobController.text.trim();

        // Update user profile in Supabase profiles table
        await Supabase.instance.client.from('profiles').update({
          'goal': _selectedGoal,
          'group_id': _selectedGroup,
          'institution': _institutionController.text.trim(),
          'district': district,
          'phone': phone,
          'gender': gender,
          'dob': dob,
        }).eq('id', user.id);

        // Deactivate any existing active group memberships
        try {
          await Supabase.instance.client
              .from('group_memberships')
              .update({'is_active': false})
              .eq('user_id', user.id)
              .eq('is_active', true);
        } catch (_) {}

        // Insert new active membership
        final membershipResp = await Supabase.instance.client
            .from('group_memberships')
            .insert({
              'user_id': user.id,
              'group_id': _selectedGroup,
              'is_active': true,
            })
            .select()
            .single();

        final lockedUntil = membershipResp['locked_until'] as String;

        // Resolve group display title
        String groupTitle = '';
        if (_requiresGroupSelection) {
          final chosen = _serverGroups.firstWhere((g) => g['id'] == _selectedGroup, orElse: () => <String, dynamic>{});
          groupTitle = chosen['title'] as String? ?? 'General';
        } else {
          final chosen = _serverGoals.firstWhere((g) => g['id'] == _selectedGoal, orElse: () => <String, dynamic>{});
          groupTitle = chosen['title'] as String? ?? 'General';
        }

        // Update local preferences
        await AppPreferences.setUserGoal(_selectedGoal);
        await AppPreferences.setUserGroup(_selectedGroup);
        await AppPreferences.setUserInstitution(_institutionController.text.trim());
        await AppPreferences.setUserDistrict(district);
        await AppPreferences.setUserPhone(phone);
        await AppPreferences.setUserGender(gender);
        await AppPreferences.setUserDob(dob);
        await AppPreferences.saveGroupMembership(
          groupId: _selectedGroup,
          groupTitle: groupTitle,
          lockedUntil: lockedUntil,
        );

        // Success - Navigate to dashboard/subscription gate
        if (mounted) {
          AppNotifier.showSnackBar(context, 'Profile set up successfully!', type: MessageType.success);
          final status = await AppPreferences.getSubscriptionStatus();
          if (mounted) {
            SubscriptionNavigationHelper.navigateByStatus(context, status);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Error saving profile: $e', type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Total steps calculation
    final totalSteps = _requiresGroupSelection ? 3 : 2;
    final progressStep = _currentStep == 2 ? 2 : _currentStep;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top progress indicator
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: List.generate(totalSteps, (index) {
                        final isActive = index <= progressStep;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? AppColors.primary 
                                  : AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Main setup content
                  Expanded(
                    child: (_isFetchingGoals || _isFetchingGroups)
                        ? const Center(child: Loader())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildStepContent(),
                          ),
                  ),

                  // Footer actions
                  if (!_isFetchingGoals && !_isFetchingGroups)
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
                                style: AppFonts.body(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          
                          ElevatedButton(
                            onPressed: _onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (_currentStep == 2 || (_currentStep == 1 && !_requiresGroupSelection)) 
                                      ? 'Submit' 
                                      : 'Next',
                                  style: AppFonts.body(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                HugeIcon(
                                  icon: (_currentStep == 2 || (_currentStep == 1 && !_requiresGroupSelection)) 
                                      ? HugeIcons.strokeRoundedCheckmarkCircle02 
                                      : HugeIcons.strokeRoundedArrowRight01, 
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
              if (_isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: const Loader(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return _buildGoalStep();
    } else if (_currentStep == 1 && _requiresGroupSelection) {
      return _buildGroupStep();
    } else {
      return _buildInfoStep();
    }
  }

  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Choose your Target',
          style: AppFonts.heading(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your primary goal. We will personalize your live battle exams and leaderboards accordingly.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        if (_serverGoals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'No targets available at the moment.',
                style: AppFonts.body(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
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
                    _selectedGroup = ''; // Reset group when goal changes
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
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: goalColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: goalIcon,
                          color: goalColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] as String? ?? '',
                              style: AppFonts.body(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['subtitle'] as String? ?? '',
                              style: AppFonts.body(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
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
        const SizedBox(height: 12),
        Text(
          'Select your Group',
          style: AppFonts.heading(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your scientific or academic stream. You will compete with peers studying the same subjects.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
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
                      child: HugeIcon(
                        icon: groupIcon,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        group['title'] as String? ?? '',
                        style: AppFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
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

  Widget _buildInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Tell us about you',
          style: AppFonts.heading(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide your institution and district details to match you with peers in your region.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Phone Number Input
        CustomTextField(
          label: 'Phone Number',
          controller: _phoneController,
          hintText: 'e.g., 01700000000',
          isRequired: true,
          keyboardType: TextInputType.phone,
          prefixIcon: HugeIcons.strokeRoundedCall,
        ),
        const SizedBox(height: 24),

        // Gender Selection (Read only, with picker)
        CustomTextField(
          label: 'Gender',
          controller: _genderController,
          hintText: 'Select your gender',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedUser,
          suffixIcon: HugeIcons.strokeRoundedArrowDown01,
          onTap: () {
            OptionPickerBottomSheetHelper.show(
              context: context,
              options: _genders,
              controller: _genderController,
              title: 'Select Gender',
            );
          },
        ),
        const SizedBox(height: 24),

        // Date of Birth Input (Read only, with DatePicker)
        CustomTextField(
          label: 'Date of Birth',
          controller: _dobController,
          hintText: 'Select your date of birth',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedCalendar01,
          suffixIcon: HugeIcons.strokeRoundedCalendar02,
          onTap: () async {
            final now = DateTime.now();
            final initialDate = DateTime(2002, 1, 1);
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1950),
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppColors.card,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              final formatted = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              setState(() {
                _dobController.text = formatted;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        // Institution Input using CustomTextField
        CustomTextField(
          label: 'School / College / University',
          controller: _institutionController,
          hintText: 'e.g., BUET, Dhaka College',
          isRequired: true,
          prefixIcon: HugeIcons.strokeRoundedSchool,
        ),
        const SizedBox(height: 24),

        // District Input using CustomTextField with read-only & OptionPickerBottomSheetHelper
        CustomTextField(
          label: 'District',
          controller: _districtController,
          hintText: 'Select your district',
          isRequired: true,
          readOnly: true,
          prefixIcon: HugeIcons.strokeRoundedLocation01,
          suffixIcon: HugeIcons.strokeRoundedArrowDown01,
          onTap: () {
            OptionPickerBottomSheetHelper.showSearchable(
              context: context,
              options: _districts,
              controller: _districtController,
              title: 'Select District',
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
