import 'package:flutter/material.dart';
import 'package:tilawah_app/widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  static const routeName = "splash";
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff009363),
      body: SplashViewBody(),
    );
  }
}
