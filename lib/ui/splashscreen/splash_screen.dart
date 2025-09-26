import 'package:flutter/material.dart';

import '/util/util.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
  }

  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SplashScreen> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.push(context, HomeScreen.route());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimens.spacingMedium,
            horizontal: Dimens.spacingMedium,
          ),
          height: AppSettings.screenHeight,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: Dimens.spacingXLarge,
                ),
                Text('Loading...')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
