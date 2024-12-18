import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/bloc/bloc_onboarding.dart';
import 'package:flai_quiz/bloc/bloc_quiz.dart';
import 'package:flai_quiz/mixins/set_state_after_frame.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/ui/toggle_button.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class _PageData {
  final String header;
  final List<ToggleData> toggleData;

  _PageData(
    this.header,
    this.toggleData,
  );
}

class OnboardingPage extends StatefulWidget {
  static const String routeName = 'OnboardingPage';
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SetStateAfterFrame {
  final List<_PageData> _pageDatas = [
    _PageData(
      'Choose Your Current Level',
      [
        ToggleData(
          toggleId: 1,
          isSelected: false,
          textKey: 'General Knowledge',
          payload: '9',
        ),
        ToggleData(
          toggleId: 2,
          isSelected: false,
          textKey: 'Maths',
          payload: '19',
        ),
        ToggleData(
          toggleId: 3,
          isSelected: false,
          textKey: 'Science & Nature',
          payload: '17',
        ),
      ],
    ),
    _PageData(
      'Choose Your Difficulty Level',
      [
        ToggleData(
          toggleId: 4,
          isSelected: false,
          textKey: 'Easy',
          payload: 'easy',
        ),
        ToggleData(
          toggleId: 5,
          isSelected: false,
          textKey: 'Medium',
          payload: 'medium',
        ),
        ToggleData(
          toggleId: 6,
          isSelected: false,
          textKey: 'Hard',
          payload: 'hard',
        ),
      ],
    ),
    _PageData('Choose Amount Of Questions', [
      ToggleData(
        toggleId: 7,
        isSelected: false,
        textKey: '5',
        payload: '5',
      ),
      ToggleData(
        toggleId: 8,
        isSelected: false,
        textKey: '10',
        payload: '10',
      ),
      ToggleData(
        toggleId: 9,
        isSelected: false,
        textKey: '20',
        payload: '20',
      ),
    ]),
  ];

  final PageController _pageController = PageController();

  bool get _hasClients {
    return _pageController.hasClients == true;
  }

  bool get _hasNextPage {
    if (!_hasClients) {
      return false;
    }
    return _pageController.page!.toInt() < _pageDatas.length - 1;
  }

  int get _curPage {
    if (!_hasClients) {
      return 0;
    }
    return _pageController.page?.toInt() ?? 0;
  }

  Future _animateToPage(int page) async {
    if (_pageController.page! % 1.0 != 0.0) {
      return;
    }
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
    );
  }

  @override
  void initState() {
    _pageController.addListener(() {
      safeSetState();
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_hasNextPage) {
      _animateToPage(_curPage + 1);
    } else if (blocOnboardingState.canGoNext(_curPage)) {
      pop();
      BlocQuiz.instance.startQuiz(
        blocOnboardingState.category ?? '',
        blocOnboardingState.amount ?? '',
        blocOnboardingState.difficulty ?? '',
      );
    }
  }

  Widget _buildNextPreviousPageButtons() {
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
                  onPressed: null,
                  child: AutoSizeText('Skip'),
                ),
                Expanded(
                  child: SizedBox.shrink(),
                ),
                MaterialButton(
                  onPressed: blocOnboardingState.canGoNext(_curPage)
                      ? _onNextPressed
                      : null,
                  child: AutoSizeText(_hasNextPage ? 'Next' : 'Finish'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    return _pageDatas.map(
      (pageData) {
        List<Widget> children = [];
        for (var toggleData in pageData.toggleData) {
          children.add(ToggleButton(
            text: toggleData.textKey,
            toggleId: toggleData.toggleId,
            toggleGroup: pageData.toggleData,
            paddingBottom: SIDE_PADDING,
            toggleButtonType: ToggleButtonType.normal,
            onToggle: (ToggleData value) {
              safeSetState();
              BlocOnboarding.instance.setData(_curPage, value);
            },
          ));
        }
        return Padding(
          padding: EdgeInsets.only(
            left: SIDE_PADDING,
            right: SIDE_PADDING,
            top: SIDE_PADDING,
            bottom: SIDE_PADDING,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                BORDER_RADIUS,
              ),
              border: Border.all(
                width: 2.0,
                color: theme.colors.backgroundSelectorColor,
              ),
              color: theme.colors.backgroundSelectorColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: SIDE_PADDING,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colors.backgroundColor,
      bottomSheet: _buildNextPreviousPageButtons(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: _buildPages(),
              ),
            ),
            Expanded(
              child: Center(
                child: AutoSizeText(
                  style: theme.headerTextStyle,
                  _pageDatas[_curPage].header,
                  wrapWords: true,
                ),
              ),
            ),
            //* Dot indicators
            Expanded(
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pageDatas.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 6,
                    dotHeight: 6,
                    expansionFactor: 5.0,
                    activeDotColor: theme.colors.dotColor,
                    dotColor: theme.colors.dotColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
