import 'package:flai_quiz/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_theme.dart';

class CustomFilledButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? iconData;
  final EdgeInsets? padding;
  final bool isExpanded;
  final TextStyle? style;
  final Color? color;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.style,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.iconData,
    this.padding,
    this.isExpanded = false,
    this.color,
  });

  Widget _getButtonContents(CustomTheme theme) {
    var style = this.style ?? theme.simpleWhiteButtonTextStyle;
    if (onPressed == null) {
      style = style.copyWith(
        color: Colors.black38,
      );
    }
    return !isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              child != null
                  ? child!
                  : Flexible(
                      child: Text(
                        text!,
                        style: style,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              iconData != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    )
                  : SizedBox.shrink()
            ],
          )
        : SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colors.progressBarColor,
              ),
            ),
          );
  }

  BorderRadius get _borderRadius {
    return BorderRadius.circular(BORDER_RADIUS);
  }

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? theme.colors.quizDefaultBtnColor;

    final button = MaterialButton(
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      highlightElevation: 0.0,
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: _borderRadius,
      ),
      color: color,
      disabledColor: theme.colors.checkMarkColor,
      onPressed: isLoading ? null : onPressed,
      child: _getButtonContents(theme),
    );
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          minHeight: BUTTON_HEIGHT,
        ),
        width: isExpanded ? double.infinity : null,
        child: kIsWeb
            ? ClipRRect(
                borderRadius: _borderRadius,
                child: button,
              )
            : button,
      ),
    );
  }
}
