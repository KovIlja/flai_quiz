import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Initial extends StatelessWidget {
  const Initial({super.key});

  Widget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Own Quiz',
        style: theme.headerTextStyle.copyWith(
          color: theme.colors.backgroundColor,
        ),
      ),
      leading: SizedBox.shrink(),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
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
    return IgnorePointer(
      ignoring: true,
      child: Column(
        children: [
          _buildAppBar(),
          SizedBox(
            height: SIDE_PADDING,
          ),
          _buildLogo(),
          SizedBox(
            height: APP_BAR_HEIGHT,
          ),
          Center(
            child: AutoSizeText(
              textAlign: TextAlign.center,
              style: theme.headerTextStyle.copyWith(
                color: theme.colors.backgroundColor,
              ),
              'Our AI-curated quizzes adapt to your learning style, making every session fun. Discover something new every day.',
              wrapWords: true,
            ),
          ),
          SizedBox(
            height: SIDE_PADDING,
          ),
          //* Dot indicators
          Center(
            child: SmoothPageIndicator(
              controller: PageController(
                initialPage: 1,
              ),
              count: 3,
              effect: ExpandingDotsEffect(
                dotWidth: 6,
                dotHeight: 6,
                expansionFactor: 5.0,
                activeDotColor: theme.colors.backgroundColor,
                dotColor: theme.colors.backgroundColor,
              ),
            ),
          ),
          SizedBox(
            height: APP_BAR_HEIGHT,
          ),
          Center(
            child: AutoSizeText(
              textAlign: TextAlign.center,
              style: theme.headerTextStyle.copyWith(
                color: theme.colors.backgroundColor,
              ),
              'Loading...',
              wrapWords: true,
            ),
          ),
        ],
      ),
    );
    ;
  }
}
