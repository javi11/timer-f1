import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const appBarWithFiltersSize = 350.0;

class ExpandibleMenu extends HookWidget {
  final Widget actions;
  final Widget expandedActions;
  final AnimationController controller;

  ExpandibleMenu(
      {required this.actions,
      required this.expandedActions,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    var clipW = useListenable(Tween<double>(
      begin: 0,
      end: appBarWithFiltersSize,
    ).animate(
      controller,
    ));

    return Stack(children: [
      Opacity(
        opacity: clipW.value > 0 ? 0.5 : 0,
        child: Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
      Align(
          alignment: Alignment.topCenter,
          child: Transform.rotate(
            angle: pi / 1,
            child: ClipPath(
              clipper: FunctionClipper(
                splitFunction: (Size size, double x) {
                  // normalizing x to make it exactly one wave
                  final normalizedX = x / size.width * 3 * pi;
                  final waveHeight = (size.height - clipW.value) / 14;
                  final y = (size.height - clipW.value) / 14 -
                      sin(cos(normalizedX)) * waveHeight;

                  return y;
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                height: 112 + clipW.value,
                child: actions,
              ),
            ),
          ))
    ]);
  }
}

class FunctionClipper extends CustomClipper<Path> {
  final double Function(Size, double) splitFunction;

  FunctionClipper({required this.splitFunction}) : super();

  @override
  Path getClip(Size size) {
    final path = Path();

    // move to split line starting point
    path.moveTo(0, splitFunction(size, 0));

    // draw split line
    for (double x = 1; x <= size.width; x++) {
      path.lineTo(x, splitFunction(size, x));
    }

    // close bottom part of screen
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // I'm returning fixed 'true' value here for simplicity, it's not the part of actual question
    // basically that means that clipping will be redrawn on any changes
    return true;
  }
}
