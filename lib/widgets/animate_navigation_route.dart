import 'package:flutter/material.dart';

Route animateRoute(Widget animatedPage) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => animatedPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // تأثير انزلاق مع تغيير الشفافية والتكبير
      var curve = Curves.easeInOut;
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return SlideTransition(
        position: curvedAnimation.drive(
          Tween(begin: const Offset(2, 0), end: Offset.zero),
        ),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: child,
          ),
        ),
      );
    },
  );
}
