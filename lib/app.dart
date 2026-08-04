import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/themes/theme.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/launch/presentation/pages/launch_page.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:target_ace/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppUserCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<BattleArenaBloc>()),
        BlocProvider(create: (_) => sl<SubscriptionBloc>()),
        BlocProvider(create: (_) => sl<NotificationBloc>()),
        BlocProvider(
          create: (_) => sl<AppLaunchBloc>()..add(const AppLaunchStarted()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'TargetAce',
        theme: theme,
        home: const LaunchPage(),
      ),
    );
  }
}
