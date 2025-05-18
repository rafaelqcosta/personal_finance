import 'package:flutter/material.dart';
import 'package:personal_finance/app/app_widget.dart';

class DSLoading extends StatelessWidget {
  const DSLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: CircularProgressIndicator());
  }

  Future<void> show() async {
    return showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Center(child: build(context)),
        );
      },
    );
  }

  Future<void> hide() async {
    return Navigator.of(navigatorKey.currentContext!).pop();
  }
}
