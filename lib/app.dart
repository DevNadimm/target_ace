import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/themes/theme.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/launch/presentation/pages/launch_page.dart';
import 'package:target_ace/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppUserCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<AppLaunchBloc>()..add(const AppLaunchStarted())),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            (current is LogoutSuccess || current is AccountDeletedSuccess) &&
            previous.runtimeType != current.runtimeType,
        listener: (context, state) async {
          if (state is LogoutSuccess || state is AccountDeletedSuccess) {
            context.read<AppLaunchBloc>().add(const AppLaunchLoggedOut());
            // Yield to the event loop so AppLaunchBloc updates its state to AppLaunchShowLogin
            // before LaunchPage builds its first frame.
            await Future.delayed(Duration.zero);
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
