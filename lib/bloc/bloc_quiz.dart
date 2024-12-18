import 'dart:collection';
import 'dart:math';

import 'package:flai_quiz/api/base_api_dio.dart';
import 'package:flai_quiz/api/quiz_api_dio.dart';
import 'package:flai_quiz/models/category.dart';
import 'package:flai_quiz/models/quiz.dart';
import 'package:flai_quiz/pages/quiz_page.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

BlocQuizState get blocQuizState {
  return BlocQuiz.instance.state;
}

class BlocQuiz extends Cubit<BlocQuizState> {
  static BlocQuiz of(BuildContext context) {
    return BlocProvider.of<BlocQuiz>(context);
  }

  static BlocQuiz get instance {
    return BlocQuiz.of(appContext);
  }

  BlocQuiz()
      : super(
          BlocQuizState(
              isLoading: false,
              currentStep: QuizStep.unknown,
              answers: SplayTreeMap<int, String?>()),
        );

  Future startQuiz(String category, String total, String difficulty) async {
    emit(
      state.copyWith(
        isLoading: true,
        currentStep: QuizStep.initial,
      ),
    );
    pushNamed(QuizPage.routeName);

    final quiz = await api<QuizApiDio>().getQuiz(
      category: category,
      total: total,
      difficulty: difficulty,
    );
    if (quiz != null) {
      state.answers?.clear();
      emit(
        state.copyWith(
          query: quiz,
          currentStep: QuizStep.main,
          currentQuestion: 0,
          maxQuestion: quiz.results!.length,
        ),
      );
    }

    emit(
      state.copyWith(
        isLoading: false,
      ),
    );
  }

  Future randomQuiz() async {
    final random = Random();

    emit(
      state.copyWith(
        isLoading: true,
        currentStep: QuizStep.initial,
      ),
    );
    final randomCategory = categories[random.nextInt(categories.length)];
    final amount = random.nextInt(15) + 5;
    final randomDifficulty = difficulties[random.nextInt(difficulties.length)];

    startQuiz(
      randomCategory.id.toString(),
      amount.toString(),
      randomDifficulty,
    );
  }

  void restart() {
    state.answers?.clear();
    emit(
      state.copyWith(
        currentStep: QuizStep.main,
        currentQuestion: 0,
        maxQuestion: state.query!.results!.length,
      ),
    );
  }

  void answerQuiz(String answer) {
    state.answers?[state.currentQuestion ?? 0] = answer;
    print(state.answers);
    emit(
      state.copyWith(
        isLoading: false,
      ),
    );
  }

  void prevQuestion() {
    var step = state.currentQuestion!;
    emit(
      state.copyWith(
        currentQuestion: step - 1,
      ),
    );
  }

  void nextQuestion() {
    if (state.currentQuestion! < state.maxQuestion! - 1) {
      var step = state.currentQuestion!;
      emit(
        state.copyWith(
          currentQuestion: step + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          currentStep: QuizStep.finished,
        ),
      );
    }
  }
}

class BlocQuizState {
  final bool isLoading;

  int? currentQuestion = 0;
  int? maxQuestion = 0;
  late SplayTreeMap<int, String?>? answers;

  bool canGoNext() {
    if (currentQuestion == null || maxQuestion == null) return false;
    return currentQuestion! < maxQuestion!;
  }

  bool canGoPrev() {
    if (currentQuestion == null || maxQuestion == null) return false;
    return currentQuestion! > 0;
  }

  Query? query;

  QuizStep currentStep;

  BlocQuizState({
    this.isLoading = false,
    required this.currentStep,
    this.query,
    this.currentQuestion,
    this.maxQuestion,
    this.answers,
  });

  BlocQuizState copyWith({
    bool? isLoading,
    QuizStep? currentStep,
    Query? query,
    int? currentQuestion,
    int? maxQuestion,
    SplayTreeMap<int, String?>? answers,
  }) {
    return BlocQuizState(
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      query: query ?? this.query,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      maxQuestion: maxQuestion ?? this.maxQuestion,
      answers: answers ?? this.answers,
    );
  }
}

enum QuizStep {
  initial,
  main,
  finished,
  unknown,
}
