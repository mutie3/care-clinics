import 'package:flutter/material.dart';

Route animateRoute(Widget animatedPage) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => animatedPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(2, 0), end: Offset.zero),
        ),
        child: child,
      );
    },
  );
}
