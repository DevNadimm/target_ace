import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SpringButton(
        backgroundColor: AppColors.white,
        shadowColor: AppColors.textLight,
        onPressed: () {
          context.read<AuthBloc>().add(GoogleSignInRequested());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.google, scale: 12),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: AppFonts.body(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}