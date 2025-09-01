import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ الحل
import 'package:tilawah_app/bloc/bloc_local_Reciters/local_reciters_bloc.dart';
import 'package:tilawah_app/bloc/internet_bloc/internet_bloc.dart';
import 'package:tilawah_app/bloc/internet_bloc/internet_event.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_bloc.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_event.dart';
import 'package:tilawah_app/bloc/localization_bloc/localization_state.dart';
import 'package:tilawah_app/core/func/on_generate_routes.dart';
import 'package:tilawah_app/database_helper.dart';
import 'package:tilawah_app/generated/l10n.dart';
import 'package:tilawah_app/repository/local_reciters_repository.dart';
import 'package:tilawah_app/repository/quran_repository_arb.dart';
import 'package:tilawah_app/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseHelper.instance;
  final savedLanguage = await db.getLanguage();

  runApp(MyApp(savedLanguage: savedLanguage));
}

class MyApp extends StatelessWidget {
  final String? savedLanguage;

  const MyApp({super.key, this.savedLanguage});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AudioQuranRepository>(
          create: (context) => AudioQuranRepository(),
        ),
        RepositoryProvider<LocalRecitersRepository>(
          create: (context) => LocalRecitersRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<InternetBloc>(
            create: (context) {
              return InternetBloc()..add(CheckInternet());
            },
          ),
          BlocProvider<LocalRecitersBloc>(
            create: (context) {
              return LocalRecitersBloc(context.read<LocalRecitersRepository>());
            },
          ),
          BlocProvider<LocalizationBloc>(
            create: (context) => LocalizationBloc()
              ..add(ChangeLocale(
                savedLanguage != null
                    ? Locale(savedLanguage!)
                    : const Locale('ar'),
              )),
          ),
        ],
        child: BlocBuilder<LocalizationBloc, LocalizationState>(
          builder: (context, state) {
            final locale = state.locale;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              onGenerateRoute: onGenerateRoute,
              initialRoute: SplashView.routeName,
            );
          },
        ),
      ),
    );
  }
}
