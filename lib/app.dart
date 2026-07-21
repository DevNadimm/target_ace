import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/shared/themes/theme.dart';
import 'package:target_ace/features/auth/presentation/pages/splash_page.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:target_ace/features/battle/presentation/bloc/live_battle_hub_bloc.dart';
import 'package:target_ace/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => SubscriptionBloc()),
        BlocProvider(create: (_) => LiveBattleHubBloc()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'TargetAce',
        theme: theme,
        home: const SplashPage(),
      ),
    );
  }
}
