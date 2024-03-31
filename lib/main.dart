import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/responsive/mobile_screen_layout.dart';
import 'package:pulse_social/responsive/responsive_layout_screen.dart';
import 'package:pulse_social/responsive/tablet_screen_layout_screen.dart';
import 'package:pulse_social/responsive/webscreen_layout.dart';
import 'package:pulse_social/screens/login_screen.dart';
import 'package:pulse_social/screens/signup_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBeqcz_ZquvDZMCQ9_aGyIWLYJf780Dcms",
          appId: "1:1047922345109:web:bf241966e23d06163b079c",
          messagingSenderId: "1047922345109",
          storageBucket: "pulsesocial-e85c2.appspot.com",
          projectId: "pulsesocial-e85c2"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pulse Social',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundcolor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  mobileLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                  tabletLayout: TabletScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
