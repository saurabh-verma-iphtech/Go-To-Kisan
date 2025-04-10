// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:signup_login_page/screen/splash_screen.dart';
// import 'firebase_options.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await Supabase.initialize(
//     url: 'https://qpmddcybbzwioqzqxwfc.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwbWRkY3liYnp3aW9xenF4d2ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTM1MzAsImV4cCI6MjA1OTY4OTUzMH0.bx6g7WEZMAtbH7hZGxPvYrLTgK5z1QU9Aa-19MDuHwk',
//   );
//   runApp( ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Go To Kisan',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         appBarTheme: AppBarTheme(
//           backgroundColor:
//               Color(
//             0xFF2E7D32,
//           ), // ✅ Set your fixed background color here
//           // foregroundColor: Colors.white, // icon/text color
//           elevation: 4, //shadow depth
//           // centerTitle: true, // Optional: center title
//         ),

//       ),
//       home: SplashScreen(),
//     );
//   }
// }



import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_login_page/screen/splash_screen.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localization/flutter_localization.dart';
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
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go To Kisan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(
            0xFF2E7D32,
          ),
          elevation: 4, //shadow depth
          // centerTitle: true, // Optional: center title
        ),
      ),
      home: SplashScreen(),
    );
  }
}
