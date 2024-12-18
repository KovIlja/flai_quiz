import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/ui/filled_button.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/material.dart';

class Finished extends StatelessWidget {
  const Finished({super.key});

  Widget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Result',
        style: theme.boldTextStyle.copyWith(
          color: theme.colors.quizDefaultColor,
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: TextButton(
        onPressed: pop,
        child: Icon(
          Icons.close,
          size: 20.0,
          color: theme.colors.quizDefaultColor,
        ),
      ),
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
              'assets/images/result.png',
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    return [
      Column(
        children: [
          CustomFilledButton(
            text: 'Retry',
            iconData: Icons.restart_alt,
            onPressed: BlocQuiz.instance.restart,
            isExpanded: true,
            padding: EdgeInsets.only(bottom: SIDE_PADDING),
          ),
          CustomFilledButton(
            text: 'Home',
            iconData: Icons.home,
            onPressed: pop,
            isExpanded: true,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(),
        SizedBox(
          height: SIDE_PADDING,
        ),
        _buildLogo(),
        SizedBox(
          height: SIDE_PADDING,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SIDE_PADDING),
          child: AutoSizeText(
            style: theme.headerTextStyle,
            textAlign: TextAlign.center,
            'Your achievements',
            wrapWords: true,
          ),
        ),
        SizedBox(
          height: APP_BAR_HEIGHT,
        ),
        ..._buildButtons(),
      ],
    );
  }
}
