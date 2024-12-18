import 'package:flai_quiz/pages/main_page.dart';
import 'package:flai_quiz/pages/onboarding_page.dart';
import 'package:flai_quiz/pages/quiz_page.dart';
import 'package:flutter/material.dart';

bool isFullscreenDialog(String? routeName) {
  switch (routeName) {
    case OnboardingPage.routeName:
      return false;
    case QuizPage.routeName:
      return false;
  }
  return true;
}

bool maintainState(String? routeName) {
  switch (routeName) {
    case QuizPage.routeName:
      return true;
    case OnboardingPage.routeName:
      return true;
    case MainPage.routeName:
      return true;
  }
  return false;
}

Widget getPageByRouteName(
  String? routeName,
  dynamic arguments,
) {
  Widget page;
  switch (routeName) {
    /*case ChatPage.routeName:
      var args = arguments as ChatPageArgs?;
      page = ChatPage(
        args: args,
      );
      break;*/
    case QuizPage.routeName:
      page = QuizPage();
    case OnboardingPage.routeName:
      page = OnboardingPage();
    case MainPage.routeName:
      page = MainPage();
    default:
      page = MainPage();
      break;
  }
  return page;
}
