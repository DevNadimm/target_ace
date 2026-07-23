import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/features/auth/presentation/widgets/goal_selection_step.dart';
import 'package:target_ace/features/auth/presentation/widgets/group_selection_step.dart';
import 'package:target_ace/features/auth/presentation/widgets/step_progress_bar.dart';
import 'package:target_ace/features/auth/presentation/widgets/user_info_setup_step.dart';
import 'package:target_ace/features/auth/presentation/widgets/profile_setup_footer.dart';

class ProfileSetupPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (_) => const ProfileSetupPage());

  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int _currentStep = 0; // 0: Goal, 1: Sub-group (if exists), 2: User Info
  String _selectedGoal = '';
  String _selectedGroup = '';
  String _rawDobIso = '';

  String? _phoneError;
  String? _genderError;
  String? _dobError;
  String? _institutionError;
  String? _districtError;

  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isLoading = false;
  bool _isFetchingGoals = true;
  bool _isFetchingGroups = false;

  List<Map<String, dynamic>> _serverGoals = [];
  List<Map<String, dynamic>> _serverGroups = [];

  final List<String> _districts = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Sylhet',
    'Barishal',
    'Rangpur',
    'Mymensingh',
    'Cumilla',
    'Jashore',
    'Bogura',
    'Cox\'s Bazar',
    'Gazipur',
    'Narayanganj',
    'Narsingdi',
    'Tangail',
    'Feni',
    'Noakhali',
    'Chandpur',
    'Brahmanbaria',
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
    if (dob.isNotEmpty) {
      _rawDobIso = DateFormatter.yyyyMMdd(dob);
      _dobController.text = DateFormatter.readable(dob);
    }
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
        AppNotifier.showSnackBar(
          context,
          'Failed to load targets: $e',
          type: MessageType.error,
        );
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
        final groups = List<Map<String, dynamic>>.from(response);
        setState(() {
          _serverGroups = groups;
          _isFetchingGroups = false;
          // Auto-select first group if available, else default to goalId for General stream
          if (groups.isNotEmpty) {
            _selectedGroup = groups.first['id'] as String? ?? goalId;
          } else {
            _selectedGroup = goalId;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingGroups = false;
          _selectedGroup = goalId;
        });
        AppNotifier.showSnackBar(
          context,
          'Failed to load groups: $e',
          type: MessageType.error,
        );
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

  bool get _requiresGroupSelection => _serverGroups.isNotEmpty;

  Future<void> _onNext() async {
    if (_currentStep == 0) {
      if (_selectedGoal.isEmpty) {
        AppNotifier.showSnackBar(
          context,
          'Please select a goal to proceed.',
          type: MessageType.error,
        );
        return;
      }

      await _fetchGroupsFromServer(_selectedGoal);
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_requiresGroupSelection && _selectedGroup.isEmpty) {
        AppNotifier.showSnackBar(
          context,
          'Please select your group/division.',
          type: MessageType.error,
        );
        return;
      }
      if (!_requiresGroupSelection && _selectedGroup.isEmpty) {
        _selectedGroup = _selectedGoal;
      }
      setState(() => _currentStep = 2);
    } else {
      _submitData();
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitData() async {
    final phone = _phoneController.text.trim();
    final gender = _genderController.text.trim();
    final dob = _dobController.text.trim();
    final institution = _institutionController.text.trim();
    final district = _districtController.text.trim();

    // Valid BD operators: 013 (GP), 014 (BL), 015 (Teletalk), 016 (Airtel), 017 (GP), 018 (Robi), 019 (BL)
    final phoneRegex = RegExp(r'^01[3-9]\d{8}$');
    String? phoneErrorMsg;
    if (phone.isEmpty) {
      phoneErrorMsg = 'Phone number is required';
    } else if (phone.length != 11) {
      phoneErrorMsg = 'Phone number must be exactly 11 digits';
    } else if (!phoneRegex.hasMatch(phone)) {
      phoneErrorMsg = 'Enter a valid 11-digit Bangladeshi number (e.g., 018..., 013...)';
    }

    setState(() {
      _phoneError = phoneErrorMsg;
      _genderError = gender.isEmpty ? 'Please select your gender' : null;
      _dobError = dob.isEmpty ? 'Please select your date of birth' : null;
      _institutionError = institution.isEmpty ? 'Institution name is required' : null;
      _districtError = district.isEmpty ? 'Please select your district' : null;
    });

    if (_phoneError != null ||
        _genderError != null ||
        _dobError != null ||
        _institutionError != null ||
        _districtError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final district = _districtController.text.trim();
        final phone = _phoneController.text.trim();
        final gender = _genderController.text.trim();
        final dob = _rawDobIso.isNotEmpty ? _rawDobIso : DateFormatter.yyyyMMdd(_dobController.text.trim());

        // Save phone, gender, dob and other details to auth metadata as they don't exist in public.profiles table
        try {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(
              data: {
                'phone': phone,
                'gender': gender,
                'dob': dob,
                'institution': _institutionController.text.trim(),
                'district': district,
              },
            ),
          );
        } catch (_) {}

        try {
          await Supabase.instance.client
              .from('profiles')
              .update({
                'goal': _selectedGoal,
                'group_id': _selectedGroup,
                'institution': _institutionController.text.trim(),
                'district': district,
                'phone': phone,
                'gender': gender,
                'dob': dob,
              })
              .eq('id', user.id);
        } catch (dbErr) {
          // If a field like 'dob' or 'gender' is missing in Supabase schema cache, fallback to essential profile fields
          try {
            await Supabase.instance.client
                .from('profiles')
                .update({
                  'goal': _selectedGoal,
                  'group_id': _selectedGroup,
                  'institution': _institutionController.text.trim(),
                  'district': district,
                })
                .eq('id', user.id);
          } catch (_) {}
        }


        try {
          await Supabase.instance.client
              .from('group_memberships')
              .update({'is_active': false})
              .eq('user_id', user.id)
              .eq('is_active', true);
        } catch (_) {}

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

        String groupTitle = '';
        if (_requiresGroupSelection) {
          final chosen = _serverGroups.firstWhere(
            (g) => g['id'] == _selectedGroup,
            orElse: () => <String, dynamic>{},
          );
          groupTitle = chosen['title'] as String? ?? 'General';
        } else {
          final chosen = _serverGoals.firstWhere(
            (g) => g['id'] == _selectedGoal,
            orElse: () => <String, dynamic>{},
          );
          groupTitle = chosen['title'] as String? ?? 'General';
        }

        await AppPreferences.setUserGoal(_selectedGoal);
        await AppPreferences.setUserGroup(_selectedGroup);
        await AppPreferences.setUserInstitution(
          _institutionController.text.trim(),
        );
        await AppPreferences.setUserDistrict(district);
        await AppPreferences.setUserPhone(phone);
        await AppPreferences.setUserGender(gender);
        await AppPreferences.setUserDob(dob);
        await AppPreferences.saveGroupMembership(
          groupId: _selectedGroup,
          groupTitle: groupTitle,
          lockedUntil: lockedUntil,
        );

        if (mounted) {
          AppNotifier.showSnackBar(
            context,
            'Profile set up successfully!',
            type: MessageType.success,
          );
          final status = await AppPreferences.getSubscriptionStatus();
          if (mounted) {
            SubscriptionNavigationHelper.navigateByStatus(context, status);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.showSnackBar(
          context,
          'Error saving profile: $e',
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(_rawDobIso) ?? DateTime(2002, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
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
      _rawDobIso = DateFormatter.yyyyMMdd(pickedDate);
      final formattedText = DateFormatter.readable(pickedDate);
      if (mounted) {
        setState(() {
          _dobController.text = formattedText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top progress indicator (Always 3 steps)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: StepProgressBar(
                      currentStep: _currentStep,
                      totalSteps: 3,
                    ),
                  ),

                  // Main step content
                  Expanded(
                    child: (_isFetchingGoals || _isFetchingGroups)
                        ? const Center(child: Loader())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildStepContent(),
                          ),
                  ),

                  // Footer navigation buttons
                  if (!_isFetchingGoals && !_isFetchingGroups)
                    ProfileSetupFooter(
                      currentStep: _currentStep,
                      onBack: _onBack,
                      onNext: _onNext,
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
      return GoalSelectionStep(
        goals: _serverGoals,
        selectedGoal: _selectedGoal,
        onGoalSelected: (goalId) {
          setState(() {
            _selectedGoal = goalId;
            _selectedGroup = '';
          });
        },
      );
    } else if (_currentStep == 1) {
      return GroupSelectionStep(
        groups: _serverGroups,
        selectedGroup: _selectedGroup.isNotEmpty ? _selectedGroup : _selectedGoal,
        onGroupSelected: (groupId) {
          setState(() => _selectedGroup = groupId);
        },
      );
    } else {
      return UserInfoSetupStep(
        key: ValueKey('user_info_step_${_dobController.text}_${_dobError ?? ""}'),
        phoneController: _phoneController,
        genderController: _genderController,
        dobController: _dobController,
        institutionController: _institutionController,
        districtController: _districtController,
        genders: _genders,
        districts: _districts,
        onSelectDob: _selectDob,
        phoneErrorText: _phoneError,
        genderErrorText: _genderError,
        dobErrorText: _dobError,
        institutionErrorText: _institutionError,
        districtErrorText: _districtError,
      );
    }
  }
}
