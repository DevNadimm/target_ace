import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/themes/theme.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/launch/presentation/pages/launch_page.dart';
// Feature blocs are scoped locally in their respective navigation boundaries.
import 'package:target_ace/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppUserCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        // Feature blocs have been moved to MainNavigationPage and route builders.
        BlocProvider(
          create: (_) => sl<AppLaunchBloc>()..add(const AppLaunchStarted()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            // Force the AppLaunchBloc to show the login page directly,
            // bypassing the session check which might still see a valid session
            // during the milliseconds it takes for Supabase to revoke the token.
            context.read<AppLaunchBloc>().add(const OnboardingCompleted());
            navigatorKey.currentState?.pushAndRemoveUntil(
              LaunchPage.route(),
              (_) => false,
            );
          }
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'TargetAce',
          theme: theme,
          home: const LaunchPage(),
        ),
      ),
    );
  }
}