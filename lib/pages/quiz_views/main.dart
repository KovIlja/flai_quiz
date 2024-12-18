import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flai_quiz/models/quiz.dart';
import 'package:flai_quiz/ui/circle_stepper.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/ui/filled_button.dart';
import 'package:flai_quiz/ui/quiz_success_overlay.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/material.dart';

class MainView extends StatelessWidget {
  const MainView({
    super.key,
  });

  int get _curStepNum {
    return (blocQuizState.currentQuestion ?? 0) + 1;
  }

  int get _maxStepNum {
    return (blocQuizState.maxQuestion ?? 0);
  }

  Question? get _curQuestion {
    return blocQuizState.query?.results?[blocQuizState.currentQuestion!];
  }

  bool get _isAnswered {
    return blocQuizState
            .answers?[blocQuizState.currentQuestion ?? 0]?.isEmpty ==
        false;
  }

  void _onClosePressed() {
    pop();
  }

  IconData? _getIcon(String? answer) {
    if (!_isAnswered) return null;
    final savedAnswer =
        blocQuizState.answers?[blocQuizState.currentQuestion ?? 0];
    if (savedAnswer == answer) {
      return Icons.check_box;
    }
    return Icons.cancel;
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: SIDE_PADDING,
        top: SIDE_PADDING,
        bottom: SIDE_PADDING,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            style: theme.boldTextStyle,
            '$_curStepNum/$_maxStepNum',
            wrapWords: true,
          ),
          SizedBox(
            child: Center(
              child: CircleStepper(
                step: _curStepNum,
                totalSteps: _maxStepNum,
                betweenStepText: '',
                stepTitles: {},
                stepDescriptions: {},
                textStyleStepper: theme.boldTextStyle,
                progressColor: theme.colors.quizDefaultColor,
                backgroundColor: theme.colors.backgroundSelectorColor,
              ),
            ),
          ),
          TextButton(
            onPressed: _onClosePressed,
            child: Icon(
              Icons.close,
              size: 24.0,
              color: theme.colors.dotColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final size = 120.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/logo_quiz.png',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _curQuestion?.question ?? '';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SIDE_PADDING),
      child: AutoSizeText(
        style: theme.headerTextStyle,
        textAlign: TextAlign.center,
        question,
        wrapWords: true,
      ),
    );
  }

  void _onPressed(String? answer, bool isCorrect) {
    BlocQuiz.instance.answerQuiz(answer!);
    showInAppAnswer(isCorrect);
  }

  List<Widget> _buildButtons() {
    List<Widget> children = [];
    children.add(
      CustomFilledButton(
        onPressed: () => _onPressed(_curQuestion!.correctAnswer, true),
        text: _curQuestion!.correctAnswer,
        iconData: _getIcon(_curQuestion!.correctAnswer),
        isExpanded: true,
        padding: EdgeInsets.only(bottom: SIDE_PADDING),
        color: _isAnswered ? theme.colors.quizSuccessColor : null,
      ),
    );
    for (var str in _curQuestion!.incorrectAnswers!) {
      children.add(
        CustomFilledButton(
          onPressed: () => _onPressed(str, false),
          text: str,
          isExpanded: true,
          padding: EdgeInsets.only(bottom: SIDE_PADDING),
          iconData: _getIcon(str),
          color: _isAnswered ? theme.colors.quizFailureColor : null,
        ),
      );
    }
    children.shuffle();
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isAnswered,
      child: Column(
        children: [
          _buildAppBar(),
          SizedBox(
            height: SIDE_PADDING,
          ),
          _buildLogo(),
          SizedBox(
            height: SIDE_PADDING,
          ),
          _buildQuestion(),
          SizedBox(
            height: SIDE_PADDING,
          ),
          ..._buildButtons(),
        ],
      ),
    );
  }
}
