
import 'package:flutter/material.dart';
import 'package:tilawah_app/views/reciters_screen.dart';

import 'package:tilawah_app/views/splash_view.dart';
import 'package:tilawah_app/views/mushaf_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());
      case RecitersScreen.routeName:
      return MaterialPageRoute(builder: (context) => const RecitersScreen());
        case MushafView.routeName:
      return MaterialPageRoute(builder: (context) => const MushafView());
    
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
