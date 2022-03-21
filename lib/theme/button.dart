
import 'package:flutter/material.dart';
import 'package:trandry_wallet/theme/colors.dart';

class ThemeButtons {

  static Widget getThemeButton({
    required String text,
    double minWidth = 150.0,
    Function()? onPressed,
    bool loading = false,
    double loadingSize = 15.0,
    EdgeInsets buttonPadding = const EdgeInsets.all(18.0),
  }) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: UIColors.primaryButtonsTextColor,
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      backgroundColor: UIColors.primaryButtonsBackgroundColor,
    );

    return Padding(
      padding: buttonPadding,
      child: SizedBox(
        width: minWidth,
        child: TextButton(
          style: flatButtonStyle,
          onPressed: onPressed,
          child: loading
              ? SizedBox(
            child: const CircularProgressIndicator(),
            width: loadingSize,
            height: loadingSize,
          )
              : Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }


}