import 'package:flutter/material.dart';

enum FillDirection {
  clockwise,
  counterClockwise,
}

class CircleStepper extends StatefulWidget {
  final double? width;
  final double? height;
  final int step;
  final int totalSteps;
  final String betweenStepText;
  final Map<int, String> stepTitles;
  final Map<int, String> stepDescriptions;
  final Color progressColor;
  final Color backgroundColor;
  final TextStyle? textStyleStepper;
  final TextStyle? textStyleTitle;
  final TextStyle? textStyleDescriptions;
  final Color colorTextStepper;
  final Color colorTitle;
  final Color colorDescriptions;
  final FillDirection fillDirection;
  final double? strokeWidth;

  const CircleStepper({
    super.key,
    this.width,
    this.height,
    required this.step,
    required this.totalSteps,
    required this.betweenStepText,
    required this.stepTitles,
    required this.stepDescriptions,
    required this.progressColor,
    required this.backgroundColor,
    this.textStyleStepper,
    this.textStyleTitle,
    this.textStyleDescriptions,
    this.colorTextStepper = Colors.black,
    this.colorTitle = Colors.black,
    this.colorDescriptions = Colors.grey,
    this.fillDirection = FillDirection.clockwise,
    this.strokeWidth,
  });

  @override
  State<CircleStepper> createState() => _CircleStepperState();
}

class _CircleStepperState extends State<CircleStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _setAnimationProgress(widget.step / widget.totalSteps);
    _animationController.forward();
  }

  void _setAnimationProgress(double newProgress) {
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _previousProgress = newProgress;
  }

  @override
  void didUpdateWidget(covariant CircleStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.step != oldWidget.step ||
        widget.totalSteps != oldWidget.totalSteps) {
      double newProgress = widget.step / widget.totalSteps;
      _setAnimationProgress(newProgress);
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width =
        widget.width ?? MediaQuery.sizeOf(context).height * .061;
    final double height =
        widget.height ?? MediaQuery.sizeOf(context).height * .061;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildCircularProgressIndicator(width, height),
              SizedBox(
                width: width - 20,
                height: height,
                child: _buildProgressText(context),
              ),
            ],
          ),
          SizedBox(width: MediaQuery.sizeOf(context).width * .03),
          _buildStepInfo(context),
        ],
      ),
    );
  }

  Widget _buildCircularProgressIndicator(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: RotatedBox(
        quarterTurns: 90,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Transform(
              transform: widget.fillDirection == FillDirection.clockwise
                  ? Matrix4.identity()
                  : Matrix4.rotationY(3.14159),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: widget.progressColor,
                backgroundColor: widget.backgroundColor,
                value: _progressAnimation.value,
                strokeWidth: widget.strokeWidth ?? (width / height) * 8,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressText(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        ///'${widget.step} ${widget.betweenStepText} ${widget.totalSteps}',
        widget.step.toString().padLeft(2, '0'),
        style: widget.textStyleStepper ??
            TextStyle(
              fontSize: MediaQuery.of(context).size.width * .03,
              fontWeight: FontWeight.w500,
              color: widget.colorTextStepper,
              fontFamily: 'Poppins',
            ),
      ),
    );
  }

  Widget _buildStepInfo(BuildContext context) {
    return SizedBox(
      height: widget.height ?? MediaQuery.of(context).size.height * .061,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            widget.stepTitles[widget.step] ?? '',
            style: widget.textStyleTitle ??
                TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .034,
                  fontWeight: FontWeight.w600,
                  color: widget.colorTitle,
                  fontFamily: 'Poppins',
                ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .01),
          Text(
            widget.stepDescriptions[widget.step] ?? '',
            style: widget.textStyleDescriptions ??
                TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .029,
                  fontWeight: FontWeight.w400,
                  color: widget.colorDescriptions,
                  fontFamily: 'Poppins',
                ),
          ),
        ],
      ),
    );
  }
}
