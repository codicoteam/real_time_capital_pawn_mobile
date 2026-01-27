import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/test/homescreen.dart';
import 'package:real_time_pawn/features/welcome_page/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_pages.dart';
import 'config/api_config/api_keys.dart';
import 'features/attached_files_mngmt/controllers/attached_files_mngmt_controller.dart'
    show AttachmentController;
import 'features/auth_mngmt/controllers/auth_controller.dart';
import 'features/loan_application_mngmt/controllers/loan_application_mngmt_controller.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // // 1) Firebase (explicit options = more reliable)
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      // debugPrint('✅ Firebase initialized');

      // // 2) Notifications / FCM
      // final messagingService = FirebaseMessagingService();
      // await messagingService.initialize(); // your service handles permission + channels as needed
      // debugPrint('✅ Firebase Messaging initialized');

      // // 3) Supabase
      // await Supabase.initialize(
      //   url: ApiKeys.supabaseUrl,
      //   anonKey: ApiKeys.supabaseKey,
      // );
      // debugPrint('✅ Supabase initialized');

      // // 4) Inject controllers

      Get.put(AuthController());

      await Supabase.initialize(
        url: ApiKeys.supabaseUrl,
        anonKey: ApiKeys.supabaseKey,
        // Add this for persistence
      );
      Get.put(AuthController());
      Get.put(AttachmentController());
      Get.put(LoanApplicationController());

      runApp(const MyApp());
    },
    (error, stack) {
      // Minimal crash logging so startup failures aren’t silent
      debugPrint('❌ Uncaught error in main(): $error');
      debugPrint('$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr Pace Athletics',
      theme: Pallete.appTheme,
      initialRoute: '/',
      getPages: AppPages.pages,
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
