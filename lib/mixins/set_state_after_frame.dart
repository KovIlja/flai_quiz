import 'package:flutter/material.dart';

mixin SetStateAfterFrame<T extends StatefulWidget> on State<T> {
  void safeSetState([Function? closure]) {
    try {
      if (mounted) {
        setState(() {
          closure?.call();
        });
      } else {
        setStateAfterFrame();
      }
    } catch (e) {
      setStateAfterFrame();
    }
  }

  void setStateAfterFrame([Function? closure]) {
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (mounted) {
          setState(() {
            closure?.call();
          });
        }
      },
    );
  }
}
