import 'package:flutter/material.dart';
import 'package:tilawah_app/core/utils/app_colors.dart';
import 'package:tilawah_app/views/reciters_screen.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, RecitersScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 200),
          Image.asset(
            'assets/images/noor-logo.png',
            height: 250,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Image.asset(
            'assets/images/mosque-white.png',
            height: 300,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
