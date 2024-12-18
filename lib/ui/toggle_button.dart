import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flai_quiz/mixins/set_state_after_frame.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/utils/constants.dart';
import 'package:flutter/material.dart';

enum ToggleButtonType {
  normal,
  filled,
}

class ToggleData<T> {
  final int? toggleId;
  final String? textKey;

  final GlobalKey _globalKey = GlobalKey();
  GlobalKey get globalKey => _globalKey;

  double? width;
  bool? isSelected;
  T? payload;

  @override
  operator ==(covariant ToggleData other) {
    return toggleId == other.toggleId;
  }

  @override
  int get hashCode {
    return toggleId.hashCode;
  }

  ToggleData({
    this.toggleId,
    this.isSelected = false,
    this.textKey,
    this.payload,
  });
}

class ToggleButton<T> extends StatefulWidget {
  final List<ToggleData<T>> toggleGroup;
  final int? toggleId;
  final String? text;
  final Widget? child;
  final bool? isSelected;
  final double? width;
  final ValueChanged<ToggleData<T>>? onToggle;
  final bool isMultipleSelection;
  final bool isDisabled;
  final ValueChanged<double>? onWidthDetected;
  final double? height;
  final bool wrapWithExpanded;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final ToggleButtonType toggleButtonType;
  final String? svgIconName;
  final int? maxTextLine;

  const ToggleButton({
    required this.text,
    required this.toggleId,
    required this.onToggle,
    this.isDisabled = false,
    this.paddingTop = 0.0,
    this.svgIconName,
    this.paddingBottom = 0.0,
    this.paddingLeft = 0.0,
    this.paddingRight = 0.0,
    super.key,
    required this.toggleGroup,
    this.onWidthDetected,
    this.child,
    this.height,
    this.width = double.infinity,
    this.isMultipleSelection = false,
    this.isSelected,
    this.toggleButtonType = ToggleButtonType.normal,
    this.wrapWithExpanded = false,
    this.maxTextLine = 1,
  });

  @override
  _ToggleButtonState createState() => _ToggleButtonState<T>();
}

class _ToggleButtonState<T> extends State<ToggleButton<T>>
    with SetStateAfterFrame {
  ToggleData<T>? _toggleData;

  @override
  void initState() {
    _toggleData = widget.toggleGroup.firstWhereOrNull(
      (t) => t.toggleId == widget.toggleId,
    );
    if (_toggleData == null) {
      _toggleData = ToggleData(
        toggleId: widget.toggleId,
      );
      widget.toggleGroup.add(_toggleData!);
    }
    if (widget.isSelected != null) {
      _toggleData!.isSelected = widget.isSelected;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ToggleButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  void _toggle() {
    if (!widget.isMultipleSelection) {
      if (_toggleData!.isSelected == true) {
        return;
      } else {
        for (var t in widget.toggleGroup) {
          t.isSelected = false;
        }
        _toggleData!.isSelected = true;
      }
    } else {
      _toggleData!.isSelected = !_toggleData!.isSelected!;
    }
    widget.onToggle?.call(
      _toggleData!,
    );
  }

  bool get _isFilled {
    return widget.toggleButtonType == ToggleButtonType.filled;
  }

  bool get _isNormal {
    return widget.toggleButtonType == ToggleButtonType.normal;
  }

  TextStyle _getTextStyle() {
    if (_isFilled) {
      if (_toggleData!.isSelected!) {
        return theme.toggleButtonSelectedStyle;
      } else {
        return theme.toggleButtonSelectedStyle;
      }
    }
    return theme.normalTextStyle;
    // }
  }

  BoxDecoration _buildInactiveDecoration() {
    if (_isFilled) {
      return BoxDecoration(
        color: theme.colors.backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(INPUT_BORDER_RADIUS),
        ),
        border: Border.all(
          width: BORDER_WIDTH,
          color: theme.colors.backgroundColor,
        ),
      );
    }

    return BoxDecoration(
      color: theme.colors.backgroundColor,
      borderRadius: BorderRadius.all(
        Radius.circular(INPUT_BORDER_RADIUS),
      ),
      border: Border.all(
        width: BORDER_WIDTH,
        color: theme.colors.backgroundSelectorColor,
      ),
    );
  }

  Color get _fillColor {
    return theme.colors.backgroundColor.withOpacity(.15);
  }

  bool get _isSelected {
    return _toggleData?.isSelected == true;
  }

  BoxDecoration _buildActiveDecoration() {
    if (_isFilled) {
      return BoxDecoration(
        color: theme.colors.backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(INPUT_BORDER_RADIUS),
        ),
        border: Border.all(
          width: BORDER_WIDTH,
          color: theme.colors.checkMarkColor,
        ),
      );
    }
    return BoxDecoration(
      color: theme.colors.backgroundColor,
      borderRadius: BorderRadius.all(
        Radius.circular(INPUT_BORDER_RADIUS),
      ),
      border: Border.all(
        width: BORDER_WIDTH,
        color: theme.colors.checkMarkColor,
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (_isSelected) {
      return _buildActiveDecoration();
    }
    return _buildInactiveDecoration();
  }

  Widget _buildIcon() {
    if (_isNormal) {
      return Positioned(
        top: SIDE_PADDING,
        bottom: SIDE_PADDING,
        left: SIDE_PADDING,
        child: Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: Icon(
              Icons.more_horiz,
              size: 20.0,
              color: theme.colors.iconColor,
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildCheck() {
    if (_isFilled) {
      return SizedBox.shrink();
    }

    if (_isNormal) {
      return Positioned(
        top: SIDE_PADDING,
        bottom: SIDE_PADDING,
        right: SIDE_PADDING,
        child: _buildCircle(),
      );
    }
    if (!_isSelected) {
      return SizedBox.shrink();
    }
    return SizedBox.shrink();
  }

  Widget _buildSelectedDot() {
    return Transform.translate(
      offset: Offset(-1.0, 1.0),
      child: Center(
        child: SizedBox(
          width: 18.0,
          height: 18.0,
          child: Icon(
            Icons.check_circle,
            size: 18.0,
            color: theme.colors.checkMarkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return Padding(
      padding: const EdgeInsets.only(
        right: SIDE_PADDING,
      ),
      child: _isSelected
          ? _buildSelectedDot()
          : AspectRatio(
              aspectRatio: 1.0,
              child: Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            24.0,
                          ),
                          border: Border.all(
                            width: 1.0,
                            color: _isSelected
                                ? theme.colors.backgroundColor
                                : theme.colors.checkMarkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  TextAlign _getTextAlignement() {
    if (_isNormal) {
      return TextAlign.left;
    }
    return TextAlign.center;
  }

  double get _toggleHeight {
    if (_isFilled) {
      return BUTTON_HEIGHT;
    }
    return INPUT_HEIGHT_NEW;
  }

  double get _textPaddingLeft {
    if (_isNormal) {
      return 40.0;
    }
    return 0.0;
  }

  double get _textPaddingRight {
    if (_isNormal) {
      return 40.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: EdgeInsets.only(
        top: widget.paddingTop,
        bottom: widget.paddingBottom,
        left: widget.paddingLeft,
        right: widget.paddingRight,
      ),
      child: Container(
        height: _toggleHeight,
        child: IgnorePointer(
          ignoring: widget.isDisabled,
          child: Opacity(
            opacity: widget.isDisabled ? .5 : 1.0,
            child: GestureDetector(
              onTap: _toggle,
              child: Stack(
                children: [
                  Container(
                    width: widget.width,
                    decoration: _buildDecoration(),
                    child: _isFilled
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    left: 0.0,
                                    right: _textPaddingRight,
                                  ),
                                  child: AutoSizeText(
                                    widget.text ?? '',
                                    maxLines: widget.maxTextLine,
                                    style: _getTextStyle(),
                                    textAlign: _getTextAlignement(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: _textPaddingLeft,
                                  right: _textPaddingRight,
                                ),
                                child: AutoSizeText(
                                  widget.text! ?? '',
                                  maxLines: widget.maxTextLine,
                                  style: _getTextStyle(),
                                  textAlign: _getTextAlignement(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                  _buildCheck(),
                  _buildIcon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.wrapWithExpanded) {
      return Expanded(child: child);
    }
    return child;
  }
}
