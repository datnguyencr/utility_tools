import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/splashscreen/splash_screen.dart';
import 'util/util.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    AppSettings.screenHeight = MediaQuery.of(context).size.height;
    AppSettings.screenWidth = MediaQuery.of(context).size.width;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    AppSettings.isTablet = shortestSide >= 550;
    return MaterialApp(
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 1.0, // Minimum scale factor allowed.
          maxScaleFactor: 1.3, // Maximum scale factor allowed.
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.notoSansTextTheme()),
      onGenerateRoute: (_) => SplashScreen.route(),
    );
  }
}
