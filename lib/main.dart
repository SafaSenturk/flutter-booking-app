import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'core/ui.dart';
import 'data/repositories.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/auth_page.dart';
import 'features/home/home_shell.dart';
import 'features/home/tab_cubit.dart';
import 'features/profile/settings_cubit.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  await Notifier.instance.init();

  final db = FirebaseFirestore.instance;
  final auth = AuthRepository(FirebaseAuth.instance, db);

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: auth),
      RepositoryProvider(create: (_) => CatalogRepository(db)),
      RepositoryProvider(create: (_) => BookingRepository(db)),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(auth)),
        BlocProvider(create: (_) => SettingsCubit(prefs)),
        BlocProvider(create: (_) => TabCubit()),
      ],
      child: const GlowApp(),
    ),
  ));
}

class GlowApp extends StatelessWidget {
  const GlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state;
    return MaterialApp(
      title: 'Glow Studio',
      debugShowCheckedModeBanner: false,
      theme: Glow.theme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (a, b) => a.status != b.status,
        // Every new session starts on the booking tab.
        listener: (context, _) => context.read<TabCubit>().show(HomeTab.book),
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: switch (state.status) {
            AuthStatus.signedOut => const AuthPage(),
            AuthStatus.signedIn when state.user != null => HomeShell(key: ValueKey(state.user!.uid), user: state.user!),
            _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
          },
        ),
      ),
    );
  }
}
