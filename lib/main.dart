import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Required
import 'package:provider/provider.dart';
import 'package:travel_in_a_box/views/screens/register_screen.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'viewmodels/trip_viewmodel.dart';
import 'viewmodels/closet_viewmodel.dart';
import 'viewmodels/packing_viewmodel.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary to prevent the Auth calls from failing
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripViewModel()),
        ChangeNotifierProvider(create: (_) => ClosetViewModel()),
        ChangeNotifierProvider(create: (_) => PackingViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel in a Box',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4FC3F7),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}