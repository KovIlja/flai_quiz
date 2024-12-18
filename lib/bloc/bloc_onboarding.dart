import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flai_quiz/pages/onboarding_page.dart';
import 'package:flai_quiz/pages/quiz_page.dart';
import 'package:flai_quiz/ui/toggle_button.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

BlocOnboardingState get blocOnboardingState {
  return BlocOnboarding.instance.state;
}

class BlocOnboarding extends Cubit<BlocOnboardingState> {
  static BlocOnboarding of(BuildContext context) {
    return BlocProvider.of<BlocOnboarding>(context);
  }

  static BlocOnboarding get instance {
    return BlocOnboarding.of(appContext);
  }

  BlocOnboarding()
      : super(
          BlocOnboardingState(
            isLoading: false,
          ),
        );

  void startNewQuiz() {
    pushNamed(OnboardingPage.routeName);

    return;
  }

  void startRandomQuiz() {
    pushNamed(QuizPage.routeName);
    BlocQuiz.instance.randomQuiz();
    return;
  }

  void setData(int curStep, ToggleData data) {
    if (curStep == 0) {
      emit(
        state.copyWith(
          category: data.payload,
        ),
      );
    } else if (curStep == 1) {
      emit(
        state.copyWith(
          difficulty: data.payload,
        ),
      );
    } else if (curStep == 2) {
      emit(
        state.copyWith(
          amount: data.payload,
        ),
      );
    }
  }
}

class BlocOnboardingState {
  final bool isLoading;

  final String? category;
  final String? amount;
  final String? difficulty;

  bool canGoNext(int curStep) {
    if (curStep == 0) {
      return category?.isNotEmpty == true;
    } else if (curStep == 1) {
      return difficulty?.isNotEmpty == true;
    } else if (curStep == 2) {
      return amount?.isNotEmpty == true;
    }
    return false;
  }

  BlocOnboardingState({
    this.isLoading = false,
    this.category,
    this.amount,
    this.difficulty,
  });

  BlocOnboardingState copyWith({
    bool? isLoading,
    String? category,
    String? amount,
    String? difficulty,
  }) {
    return BlocOnboardingState(
      isLoading: isLoading ?? this.isLoading,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
