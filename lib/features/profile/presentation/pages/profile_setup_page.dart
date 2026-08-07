import 'package:target_ace/core/config/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart' as core_component;
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/inline_error_widget.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/core/utils/helpers/option_picker_bottom_sheet_helper.dart';
import 'package:target_ace/features/home/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/enums/profile_step_type.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/profile/presentation/bloc/setup/profile_setup_cubit.dart';
import 'package:target_ace/features/profile/presentation/helpers/profile_setup_constants.dart';
import 'package:target_ace/features/profile/presentation/widgets/group_locked_view.dart';
import 'package:target_ace/features/profile/presentation/widgets/profile_setup_footer.dart';
import 'package:target_ace/features/profile/presentation/widgets/profile_setup_input_field.dart';
import 'package:target_ace/features/profile/presentation/widgets/selection_step_container.dart';
import 'package:target_ace/features/profile/presentation/widgets/single_field_step_container.dart';
import 'package:target_ace/features/profile/presentation/widgets/step_header.dart';
import 'package:target_ace/features/profile/presentation/widgets/step_progress_bar.dart';

class ProfileSetupPage extends StatefulWidget {
  final List<ProfileStepType>? customSteps;

  static Route route({List<ProfileStepType>? customSteps}) => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<ProfileSetupCubit>(),
      child: ProfileSetupPage(customSteps: customSteps),
    ),
  );

  const ProfileSetupPage({super.key, this.customSteps});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  late List<ProfileStepType> _activeSteps;
  int _currentStepIndex = 0;
  bool _isForward = true;
  bool _isCheckingPhone = false;

  String _selectedGoal = '';
  String _selectedGroup = '';
  String _rawDobIso = '';

  String? _phoneError;
  String? _genderError;
  String? _dobError;
  String? _institutionError;
  String? _districtError;
  String? _howDidYouHearError;
  String? _dailyGoalError;
  String? _learningModesError;
  String? _submitError;

  bool _isGroupLocked = false;
  String _lockedExpiryFormatted = '';
  int _lockedRemainingDays = 0;
  String _lockedCurrentGroupTitle = '';

  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _howDidYouHearController =
      TextEditingController();
  final TextEditingController _dailyGoalController = TextEditingController();

  final Set<String> _selectedLearningModes = {};

  List<OnboardingGoalEntity> _serverGoals = [];
  List<BattleGroupEntity> _serverGroups = [];



  @override
  void initState() {
    super.initState();
    _activeSteps =
        widget.customSteps ??
        [
          ProfileStepType.goal,
          ProfileStepType.group,
          ProfileStepType.howDidYouHear,
          ProfileStepType.dailyGoal,
          ProfileStepType.learningModes,
          ProfileStepType.phone,
          ProfileStepType.gender,
          ProfileStepType.dob,
          ProfileStepType.institution,
          ProfileStepType.district,
        ];
    _prefillUserInfo();
  }

  Future<void> _prefillUserInfo() async {
    final phone = await UserLocalDataSource.getUserPhone();
    final gender = await UserLocalDataSource.getUserGender();
    final dob = await UserLocalDataSource.getUserDob();
    final institution = await UserLocalDataSource.getUserInstitution();
    final district = await UserLocalDataSource.getUserDistrict();
    final goal = await UserLocalDataSource.getUserGoal();
    final groupId = await UserLocalDataSource.getUserGroupId();
    final howDidYouHear = await UserLocalDataSource.getHowDidYouHear();
    final dailyGoal = await UserLocalDataSource.getDailyGoal();
    final learningModes = await UserLocalDataSource.getLearningModes();

    if (phone.isNotEmpty) _phoneController.text = phone;
    if (gender.isNotEmpty) _genderController.text = gender;
    if (institution.isNotEmpty) _institutionController.text = institution;
    if (district.isNotEmpty) _districtController.text = district;
    if (goal.isNotEmpty) _selectedGoal = goal;
    if (groupId.isNotEmpty) _selectedGroup = groupId;
    if (howDidYouHear.isNotEmpty) _howDidYouHearController.text = howDidYouHear;
    if (dailyGoal.isNotEmpty) _dailyGoalController.text = dailyGoal;
    if (learningModes.isNotEmpty) {
      _selectedLearningModes.addAll(learningModes);
    }

    if (dob.isNotEmpty) {
      _rawDobIso = DateFormatter.yyyyMMdd(dob);
      _dobController.text = DateFormatter.readable(dob);
    }

    final isSwitchAllowed = await UserLocalDataSource.isGroupSwitchAllowed();
    final lockedUntil = await UserLocalDataSource.getUserGroupLockedUntil();
    final groupTitle = await UserLocalDataSource.getUserGroupTitle();

    if (!isSwitchAllowed && lockedUntil != null && lockedUntil.isNotEmpty) {
      if (widget.customSteps != null) {
        final lockDate = DateTime.tryParse(lockedUntil)?.toLocal() ?? DateTime.now();
        final now = DateTime.now();
        final days = lockDate.difference(now).inDays + 1;

        if (mounted) {
          setState(() {
            _isGroupLocked = true;
            _lockedExpiryFormatted = DateFormatter.readable(lockedUntil);
            _lockedRemainingDays = days > 0 ? days : 1;
            _lockedCurrentGroupTitle = (groupTitle != null && groupTitle.isNotEmpty)
                ? groupTitle
                : groupId;
          });
        }
        return;
      }
    }

    if (mounted) {
      context.read<ProfileSetupCubit>().fetchGoals();
    }
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _howDidYouHearController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  ProfileStepType get _currentStepType => _activeSteps[_currentStepIndex];

  bool get _isLastStep => _currentStepIndex == _activeSteps.length - 1;

  Future<void> _onNext(BuildContext context) async {
    switch (_currentStepType) {
      case ProfileStepType.goal:
        if (_selectedGoal.isEmpty) {
          AppNotifier.showSnackBar(
            context,
            'Please select a goal to proceed.',
            type: MessageType.error,
          );
          return;
        }

        final matches = _serverGoals.where((g) => g.id == _selectedGoal);
        final selectedGoalObj = matches.isNotEmpty ? matches.first : null;
        final groups = selectedGoalObj?.battleGroups ?? [];

        if (groups.isNotEmpty) {
          setState(() {
            _serverGroups = groups;
            if (_selectedGroup.isEmpty) {
              _selectedGroup = groups.first.id;
            }
          });
          _advanceStep();
        } else {
          context.read<ProfileSetupCubit>().fetchGroups(_selectedGoal);
        }
        break;

      case ProfileStepType.group:
        if (_selectedGroup.isEmpty && _serverGroups.isNotEmpty) {
          AppNotifier.showSnackBar(
            context,
            'Please select your group/division.',
            type: MessageType.error,
          );
          return;
        }
        if (_selectedGroup.isEmpty) {
          _selectedGroup = _selectedGoal;
        }

        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.howDidYouHear:
        final hear = _howDidYouHearController.text.trim();
        if (hear.isEmpty) {
          setState(
            () => _howDidYouHearError = 'Please select how you found us',
          );
          return;
        }
        setState(() => _howDidYouHearError = null);
        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.dailyGoal:
        final goal = _dailyGoalController.text.trim();
        if (goal.isEmpty) {
          setState(
            () => _dailyGoalError = 'Please select your daily commitment',
          );
          return;
        }
        setState(() => _dailyGoalError = null);
        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.learningModes:
        if (_selectedLearningModes.isEmpty) {
          setState(
            () => _learningModesError =
                'Please select at least one learning mode',
          );
          return;
        }
        setState(() => _learningModesError = null);
        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.phone:
        final phone = _phoneController.text.trim();
        final phoneRegex = RegExp(r'^01[3-9]\d{8}$');
        if (phone.isEmpty) {
          setState(() => _phoneError = 'Phone number is required');
          return;
        } else if (phone.length != 11 || !phoneRegex.hasMatch(phone)) {
          setState(
            () => _phoneError =
                'Enter a valid 11-digit Bangladeshi number (e.g., 018..., 013...)',
          );
          return;
        }
        setState(() => _phoneError = null);

        if (!mounted) return;
        setState(() => _isCheckingPhone = true);
        final isUnique = await context.read<ProfileSetupCubit>().checkPhoneUnique(phone);
        if (!mounted) return;
        setState(() => _isCheckingPhone = false);
        
        if (!isUnique) {
          setState(() => _phoneError = 'This phone number is already registered.');
          return;
        }

        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.gender:
        final gender = _genderController.text.trim();
        if (gender.isEmpty) {
          setState(() => _genderError = 'Please select your gender');
          return;
        }
        setState(() => _genderError = null);

        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.dob:
        // DOB is optional
        setState(() => _dobError = null);
        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.institution:
        // Institution is optional
        setState(() => _institutionError = null);
        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;

      case ProfileStepType.district:
        final district = _districtController.text.trim();
        if (district.isEmpty) {
          setState(() => _districtError = 'Please select your district');
          return;
        }
        setState(() => _districtError = null);

        if (_isLastStep) {
          _submitData(context);
        } else {
          _advanceStep();
        }
        break;
    }
  }

  void _advanceStep() {
    if (_currentStepIndex < _activeSteps.length - 1) {
      setState(() {
        _isForward = true;
        _currentStepIndex++;
      });
    }
  }

  void _onBack() {
    if (_currentStepIndex > 0) {
      setState(() {
        _isForward = false;
        _currentStepIndex--;
      });
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitData(BuildContext context) async {
    final phone = _phoneController.text.trim();
    final gender = _genderController.text.trim();
    final dob = _dobController.text.trim();
    final institution = _institutionController.text.trim();
    final district = _districtController.text.trim();

    final user = sl<AuthRemoteDataSource>().currentUser;
    if (user != null) {
      final dobValue = _rawDobIso.isNotEmpty
          ? _rawDobIso
          : (dob.isNotEmpty ? DateFormatter.yyyyMMdd(dob) : '');

      context.read<ProfileSetupCubit>().setupProfile(
        userId: user.id,
        goalId: _selectedGoal,
        groupId: _selectedGroup,
        institution: institution,
        district: district,
        phone: phone,
        gender: gender,
        dob: dobValue,
        howDidYouHear: _howDidYouHearController.text.trim(),
        dailyGoal: _dailyGoalController.text.trim(),
        learningModes: _selectedLearningModes.toList(),
      );
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
    return BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
        listener: (context, state) async {
          if (state is ProfileSetupGoalsLoaded) {
            setState(() {
              _serverGoals = state.goals;
            });
          } else if (state is ProfileSetupGroupsLoaded) {
            final groups = state.groups;
            setState(() {
              _serverGroups = groups;
              if (groups.isNotEmpty) {
                _selectedGroup = groups.first.id;
              } else {
                _selectedGroup = _selectedGoal;
              }
            });
            _advanceStep();
          } else if (state is ProfileSetupSuccess) {
            String groupTitle = '';
            final matches = _serverGroups.where((g) => g.id == _selectedGroup);
            if (matches.isNotEmpty) {
              groupTitle = matches.first.title;
            } else {
              final goalMatches = _serverGoals.where(
                (g) => g.id == _selectedGoal,
              );
              groupTitle = goalMatches.isNotEmpty
                  ? goalMatches.first.title
                  : 'General';
            }

            await UserLocalDataSource.updateFields({
              'goal': _selectedGoal,
              'group_id': _selectedGroup,
              'institution': _institutionController.text.trim(),
              'district': _districtController.text.trim(),
              'phone': _phoneController.text.trim(),
              'gender': _genderController.text.trim(),
              'dob': _rawDobIso,
              'how_did_you_hear': _howDidYouHearController.text.trim(),
              'daily_goal': _dailyGoalController.text.trim(),
              'learning_modes': _selectedLearningModes.toList(),
              'group_title': groupTitle,
              'group_locked_until': state.lockedUntil,
            });

            if (!context.mounted) return;
            AppNotifier.showSnackBar(
              context,
              'Profile updated successfully!',
              type: MessageType.success,
            );
            if (!context.mounted) return;
            if (Navigator.canPop(context) && widget.customSteps != null) {
              // In-app profile edit â€” pop back to the previous page.
              Navigator.pop(context, true);
            } else if (widget.customSteps != null) {
              // In-app edit with no previous route â€” go to main navigation.
              Navigator.pushAndRemoveUntil(
                context,
                MainNavigationPage.route(),
                (_) => false,
              );
            } else {
              // Launch flow â€” notify the coordinator.
              context.read<AppLaunchBloc>().add(const ProfileSetupCompleted());
            }
          } else if (state is ProfileSetupFailure) {
            setState(() {
              _submitError = state.error;
            });
            AppNotifier.showSnackBar(
              context,
              state.error ?? AppMessages.errorMessage,
              type: MessageType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileSetupLoading;

          if (_isGroupLocked) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: GradientBackground(
                child: GroupLockedView(
                  currentGroupTitle: _lockedCurrentGroupTitle.isNotEmpty
                      ? _lockedCurrentGroupTitle
                      : 'Current Group',
                  lockExpiryDate: _lockedExpiryFormatted,
                  remainingDays: _lockedRemainingDays,
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          }

          return PopScope(
            canPop: _currentStepIndex == 0 && Navigator.canPop(context),
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_currentStepIndex > 0) {
                _onBack();
              }
            },
            child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: GradientBackground(
              child: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                          child: Row(
                            children: [
                              core_component.BackButton(onBack: _onBack),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StepProgressBar(
                                  currentStep: _currentStepIndex,
                                  totalSteps: _activeSteps.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              (state is ProfileSetupInitial ||
                                  (isLoading && _serverGoals.isEmpty))
                              ? const Center(child: Loader())
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    final isIncoming =
                                        child.key == ValueKey<int>(_currentStepIndex);
                                    final offsetAnimation = Tween<Offset>(
                                      begin: isIncoming
                                          ? Offset(_isForward ? 1.0 : -1.0, 0.0)
                                          : Offset(_isForward ? -1.0 : 1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      ),
                                    );

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  layoutBuilder: (currentChild, previousChildren) {
                                    return Stack(
                                      alignment: Alignment.topCenter,
                                      children: <Widget>[
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    );
                                  },
                                  child: SingleChildScrollView(
                                    key: ValueKey<int>(_currentStepIndex),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildStepContent(),
                                        if (_submitError != null &&
                                            _submitError!.isNotEmpty &&
                                            _isLastStep) ...[
                                          const SizedBox(height: 16),
                                          InlineErrorWidget(_submitError!),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        if (state is! ProfileSetupInitial &&
                            !(isLoading && _serverGoals.isEmpty))
                          ProfileSetupFooter(
                            currentStep: _currentStepIndex,
                            isLastStep: _isLastStep,
                            onBack: _onBack,
                            onNext: () => _onNext(context),
                          ),
                      ],
                    ),
                  ),
                  if ((isLoading || _isCheckingPhone) && _serverGoals.isNotEmpty)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Loader(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      );
  }

  Widget _buildStepContent() {
    switch (_currentStepType) {
      case ProfileStepType.goal:
        const title = 'What is your target goal?';
        const subtitle = 'Choose your target academic or competitive exam to customize your preparation path.';

        if (_serverGoals.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepHeader(title: title, subtitle: subtitle),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Center(
                  child: Text(
                    'No goals available. Please check back later.',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return SelectionStepContainer<OnboardingGoalEntity>(
          title: title,
          subtitle: subtitle,
          items: _serverGoals,
          selectedId: _selectedGoal,
          onSelected: (goal) {
            setState(() {
              _selectedGoal = goal.id;
              _selectedGroup = '';
            });
          },
          idExtractor: (goal) => goal.id,
          titleExtractor: (goal) => goal.title,
          imageExtractor: (goal) => goal.iconName.isNotEmpty ? goal.iconName : null,
        );

      case ProfileStepType.group:
        const title = 'Which battle group do you belong to?';
        const subtitle = 'Select your academic stream to compete with peers studying the same subjects.';

        if (_serverGroups.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepHeader(title: title, subtitle: subtitle),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Center(
                  child: Text(
                    'No subgroups available. Please check back later.',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return SelectionStepContainer<BattleGroupEntity>(
          title: title,
          subtitle: subtitle,
          items: _serverGroups,
          selectedId: _selectedGroup.isNotEmpty
              ? _selectedGroup
              : _selectedGoal,
          onSelected: (group) {
            setState(() => _selectedGroup = group.id);
          },
          idExtractor: (group) => group.id,
          titleExtractor: (group) => group.title,
          imageExtractor: (group) =>
              group.iconName.isNotEmpty ? group.iconName : null,
        );

      case ProfileStepType.howDidYouHear:
        return SelectionStepContainer<String>(
          title: 'How did you hear about TargetAce?',
          subtitle: 'Help us understand how learners discover our platform.',
          items: ProfileSetupConstants.howDidYouHearOptions,
          selectedId: _howDidYouHearController.text,
          onSelected: (option) {
            setState(() {
              _howDidYouHearController.text = option;
              _howDidYouHearError = null;
            });
          },
          titleExtractor: (option) => option,
          errorText: _howDidYouHearError,
        );

      case ProfileStepType.dailyGoal:
        return SelectionStepContainer<String>(
          title: 'What is your daily study goal?',
          subtitle:
              'Select how much time you want to practice each day to achieve your goal.',
          items: ProfileSetupConstants.dailyGoalOptions,
          selectedId: _dailyGoalController.text,
          onSelected: (option) {
            setState(() {
              _dailyGoalController.text = option;
              _dailyGoalError = null;
            });
          },
          titleExtractor: (option) => option,
          errorText: _dailyGoalError,
        );

      case ProfileStepType.learningModes:
        return SelectionStepContainer<String>(
          title: 'How do you prefer to learn?',
          subtitle:
              'Select one or more learning modes to customize your TargetAce experience.',
          items: ProfileSetupConstants.learningModesOptions,
          isMultiSelect: true,
          selectedIds: _selectedLearningModes,
          onSelected: (option) {
            setState(() {
              if (_selectedLearningModes.contains(option)) {
                _selectedLearningModes.remove(option);
              } else {
                _selectedLearningModes.add(option);
              }
              _learningModesError = null;
            });
          },
          titleExtractor: (option) => option,
          errorText: _learningModesError,
        );

      case ProfileStepType.phone:
        return SingleFieldStepContainer(
          title: 'What is your phone number?',
          subtitle:
              'Please enter your 11-digit Bangladeshi mobile number.',
          child: ProfileSetupInputField(
            label: 'Phone Number',
            controller: _phoneController,
            hintText: 'e.g., 01700000000',
            isRequired: true,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: HugeIcons.strokeRoundedCall02,
            errorText: _phoneError,
          ),
        );

      case ProfileStepType.gender:
        return SelectionStepContainer<String>(
          title: 'What is your gender?',
          subtitle: 'This helps us personalize your profile details and app experience.',
          items: ProfileSetupConstants.genders,
          selectedId: _genderController.text,
          onSelected: (gender) {
            setState(() {
              _genderController.text = gender;
            });
          },
          titleExtractor: (gender) => gender,
          errorText: _genderError,
        );

      case ProfileStepType.dob:
        return SingleFieldStepContainer(
          title: 'When is your date of birth?',
          subtitle:
              '(Optional) Provide your date of birth to complete your academic profile.',
          child: ProfileSetupInputField(
            label: 'Date of Birth (Optional)',
            controller: _dobController,
            hintText: 'Select your date of birth',
            isRequired: false,
            readOnly: true,
            prefixIcon: HugeIcons.strokeRoundedCalendar04,
            suffixIcon: HugeIcons.strokeRoundedArrowDown01,
            errorText: _dobError,
            onTap: _selectDob,
          ),
        );

      case ProfileStepType.institution:
        return SingleFieldStepContainer(
          title: 'What is your current or last academic institution?',
          subtitle:
              '(Optional) Enter your school, college, or university name.',
          child: ProfileSetupInputField(
            label: 'School / College / University (Optional)',
            controller: _institutionController,
            hintText: 'e.g., BUET, Dhaka College',
            isRequired: false,
            prefixIcon: HugeIcons.strokeRoundedUniversity,
            errorText: _institutionError,
          ),
        );

      case ProfileStepType.district:
        return SingleFieldStepContainer(
          title: 'Which district are you from?',
          subtitle:
              'Select your home district to connect with local competitive leaderboards.',
          child: ProfileSetupInputField(
            label: 'District',
            controller: _districtController,
            hintText: 'Select your district',
            isRequired: true,
            readOnly: true,
            prefixIcon: HugeIcons.strokeRoundedLocation01,
            suffixIcon: HugeIcons.strokeRoundedArrowDown01,
            errorText: _districtError,
            onTap: () {
              OptionPickerBottomSheetHelper.showSearchable(
                context: context,
                options: ProfileSetupConstants.districts,
                controller: _districtController,
                title: 'Select District',
              );
            },
          ),
        );
    }
  }
}