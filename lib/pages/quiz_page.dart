import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flai_quiz/pages/quiz_views/finished.dart';
import 'package:flai_quiz/pages/quiz_views/initial.dart';
import 'package:flai_quiz/pages/quiz_views/main.dart';
import 'package:flai_quiz/ui/circle_stepper.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizPage extends StatefulWidget {
  static const String routeName = 'QuizPage';

  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  ScrollController? _scrollController;

  List<Widget> _buildForm() {
    if (blocQuizState.currentStep == QuizStep.main) {
      return [
        MainView(),
      ];
    } else if (blocQuizState.currentStep == QuizStep.initial) {
      return [
        Initial(),
      ];
    } else if (blocQuizState.currentStep == QuizStep.finished) {
      return [
        Finished(),
      ];
    }
    return [];
  }

  void _onPrevPressed() {
    BlocQuiz.instance.prevQuestion();
  }

  void _onNextPressed() {
    BlocQuiz.instance.nextQuestion();
  }

  Widget _buildNextPreviousPageButtons() {
    if (blocQuizState.currentStep != QuizStep.main) {
      return SizedBox.shrink();
    } else if (blocQuizState.currentStep != QuizStep.finished) {}
    return Container(
      color: theme.colors.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 5.0,
              right: 5.0,
              bottom: 10.0,
            ),
            child: Row(
              children: [
                MaterialButton(
                  onPressed: blocQuizState.canGoPrev() ? _onPrevPressed : null,
                  child: AutoSizeText('Previous'),
                ),
                Expanded(
                  child: SizedBox.shrink(),
                ),
                MaterialButton(
                  onPressed: blocQuizState.canGoNext() ? _onNextPressed : null,
                  child: AutoSizeText('Next'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocQuiz, BlocQuizState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          bottomSheet: _buildNextPreviousPageButtons(),
          backgroundColor: blocQuizState.currentStep == QuizStep.initial
              ? theme.colors.quizDefaultColor
              : theme.colors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SafeArea(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ScrollConfiguration(
                      behavior: MaterialScrollBehavior(),
                      child: CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SIDE_PADDING,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                _buildForm(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
