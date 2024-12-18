import 'package:flai_quiz/bloc/bloc_onboarding.dart';
import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider<Cubit>> getBlocProviders(BuildContext context) {
  return [
    BlocProvider<BlocOnboarding>(
      create: (BuildContext c) => BlocOnboarding(),
    ),
    BlocProvider<BlocQuiz>(
      create: (BuildContext c) => BlocQuiz(),
    ),
  ];
}
