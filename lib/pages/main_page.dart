import 'package:flai_quiz/bloc/bloc_onboarding.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/ui/filled_button.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  static const String routeName = 'MainPage';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _onStartQuizPressed() {
    if (kDebugMode) {
      print('Start New Quiz press');
    }
    BlocOnboarding.instance.startNewQuiz();
  }

  void _onStartRandomQuizPressed() {
    if (kDebugMode) {
      print('Start New Random Quiz press');
    }
    BlocOnboarding.instance.startRandomQuiz();
  }

  Widget _buildBottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: theme.colors.backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(
              left: SIDE_PADDING,
              right: SIDE_PADDING,
              top: SIDE_PADDING,
              bottom: SIDE_PADDING,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomFilledButton(
                    text: 'Start Quiz',
                    onPressed: _onStartQuizPressed,
                  ),
                ),
                SizedBox(
                  height: SIDE_PADDING,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomFilledButton(
                    text: 'Random Quiz',
                    onPressed: _onStartRandomQuizPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    final size = 240.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/logo.png',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocOnboarding, BlocOnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: APP_BAR_HEIGHT,
                  ),
                  _buildLogo(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomSheet(),
        );
      },
    );
  }
}
