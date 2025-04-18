import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_login_page/Theme/theme_provider.dart';
import 'package:signup_login_page/screen/splash_screen.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://qpmddcybbzwioqzqxwfc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwbWRkY3liYnp3aW9xenF4d2ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTM1MzAsImV4cCI6MjA1OTY4OTUzMH0.bx6g7WEZMAtbH7hZGxPvYrLTgK5z1QU9Aa-19MDuHwk',
  );
  runApp(EasyLocalization(
    supportedLocales: const[Locale('en'),Locale('hi')],
    path: 'assets/lang',
    fallbackLocale: const Locale('en'),
    child: ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
        final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go To Kisan',
       localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: Color(
      //       0xFF2E7D32,
      //     ),
      //     elevation: 4, //shadow depth
      //     // centerTitle: true, // Optional: center title
      //   ),
      // ),
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 153, 203, 154), // Light green
          iconTheme: IconThemeData(
            color: Colors.black,
          ), // Icons black in light mode
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
      // ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 21, 79, 25), // Dark green
          iconTheme: IconThemeData(
            color: Colors.white,
          ), // Icons white in dark mode
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: themeMode,
      home: SplashScreen(),
    );
  }
}
