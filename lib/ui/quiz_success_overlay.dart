import 'package:auto_size_text/auto_size_text.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flutter/material.dart';

showInAppAnswer(bool? answer) {
  _notificationDisplayKey.currentState!.showMessage(answer);
}

GlobalKey<QuizSuccessState> _notificationDisplayKey =
    GlobalKey<QuizSuccessState>();

class QuizSuccessOverlay extends StatefulWidget {
  final int masMessagesInStack;

  const QuizSuccessOverlay({
    super.key,
    this.masMessagesInStack = 5,
  });

  @override
  _QuizSuccessOverlayState createState() => _QuizSuccessOverlayState();
}

class _QuizSuccessOverlayState extends State<QuizSuccessOverlay> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var safeAreaOffset = mediaQuery.viewPadding.top;

    return Container(
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      child: _InAppNotificationDisplay(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        key: _notificationDisplayKey,
        saveAreaOffset: safeAreaOffset,
        maxMessagesInStack: widget.masMessagesInStack,
      ),
    );
  }
}

class _InAppNotificationDisplay extends StatefulWidget {
  final double width;
  final double height;
  final double saveAreaOffset;
  final int maxMessagesInStack;

  const _InAppNotificationDisplay({
    super.key,
    required this.width,
    required this.height,
    required this.saveAreaOffset,
    required this.maxMessagesInStack,
  });

  @override
  State<_InAppNotificationDisplay> createState() => QuizSuccessState();
}

class QuizSuccessState extends State<_InAppNotificationDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveAnimation;
  List<bool> _messageBuffer = <bool>[];

  void showMessage(bool? answer) {
    if (answer == null) {
      return;
    }
    if (_messageBuffer.length >= widget.maxMessagesInStack) {
      return;
    }
    _messageBuffer.add(answer);
    if (!_animationController.isAnimating) {
      _displayMessage();
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: Duration(
        milliseconds: 3000,
      ),
    );

    _moveAnimation = Tween<double>(
      begin: -130.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0.0,
          0.07,
          curve: Curves.easeInOutCubic,
        ),
        parent: _animationController,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0.01,
          0.05,
          curve: Curves.easeOutExpo,
        ),
        parent: _animationController,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _clear() {
    _messageBuffer.clear();
  }

  void _showNextMessage() {
    if (_messageBuffer.isNotEmpty) {
      _messageBuffer.removeAt(0);
    }
    _displayMessage();
  }

  Future _displayMessage() async {
    _animationController.stop();
    _animationController.value = 0.0;
    if (_messageBuffer.isNotEmpty) {
      await _animationController.forward();
      await _animationController.reverse();
      _animationController.value = 0.0;
      _showNextMessage();
    }
    setState(() {});
  }

  Future _onMessageTap(bool? pushData) async {
    _clear();
    _showNextMessage();
  }

  String _getMessage(bool pushData) {
    return pushData ? 'Correct!' : 'Incorrect!';
  }

  bool? _getCurrentData() {
    if (_messageBuffer.isNotEmpty) {
      return _messageBuffer[0];
    }
    return null;
  }

  Widget _buildTextView() {
    final pushData = _getCurrentData();
    if (pushData == null) {
      return SizedBox.shrink();
    }
    final upperLine = _getMessage(pushData);

    return GestureDetector(
      onTap: () {
        _onMessageTap(pushData);
      },
      child: AutoSizeText(
        textAlign: TextAlign.center,
        upperLine,
        style: theme.headerTextStyle.copyWith(
          height: 1.2,
          color: theme.colors.backgroundColor,
        ),
      ),
    );
  }

  Color get _color {
    final message = _getCurrentData();
    if (message == null) {
      return theme.colors.backgroundColor;
    }
    return message
        ? theme.colors.quizSuccessColor
        : theme.colors.quizFailureColor;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (c, w) {
                return Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    _moveAnimation.value,
                    // 0,
                    0.0,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    // opacity: 1.0,
                    child: Material(
                      color: _color,
                      elevation: 20,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: widget.saveAreaOffset,
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                12.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                      ),
                                      child: _buildTextView(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
