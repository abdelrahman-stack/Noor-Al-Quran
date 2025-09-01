import 'package:flutter/material.dart';
import 'package:tilawah_app/views/reciters_screen.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    excuteNavigatoer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 200),
        Image.asset('assets/images/noor-logo.png', height: 300),
        const Spacer(),
        Image.asset(
          'assets/images/mosque-white.png',
          height: 300,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  void excuteNavigatoer() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, RecitersScreen.routeName);
    });
  }
}
