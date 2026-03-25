import 'package:flutter/material.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;

  const OnboardingLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: child,
      ),
    );
  }
}
