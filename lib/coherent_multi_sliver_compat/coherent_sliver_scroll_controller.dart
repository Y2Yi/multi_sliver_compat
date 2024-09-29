import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'dart:math';

class CoherentSliverCompatScrollController extends ScrollController {
  Key? debugKey;
  CoherentSliverCompat sliverCompat;
  late bool isMajorScrollController;

  CoherentSliverCompatScrollController._(this.sliverCompat,
      {this.debugKey});

  CoherentSliverCompatScrollController.major(
      this.debugKey, this.sliverCompat) {
    isMajorScrollController = true;
  }

  CoherentSliverCompatScrollController.minor(
      this.debugKey, this.sliverCompat) {
    isMajorScrollController = false;
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return CoherentMajorScrollPosition(sliverCompat,
        physics: const ScrollPhysics(), context: context, debugKey: debugKey);
  }
}

class CoherentSliverCompatScrollPosition
    extends ScrollPositionWithSingleContext {
  CoherentSliverCompat sliverCompat;
  Key? debugKey;

  CoherentSliverCompatScrollPosition(this.sliverCompat,
      {required super.physics, required super.context, this.debugKey});

  /// 所有的偏移量统一交给CoherentSliverCompat去处理；
  @override
  void applyUserOffset(double delta) {
    print("$debugKey notifyScroll");
    sliverCompat.submitUserOffset(this, delta);
  }

  /// 食用滚动量，然后返回未吃完的滚动量
  double applyClampedDragUpdate(double delta) {
    assert(delta != 0.0);
    final double minValue =
        delta < 0.0 ? -double.infinity : min(minScrollExtent, pixels);
    final double maxValue = delta > 0.0
        ? double.infinity
        : pixels < 0.0
            ? 0.0
            : max(maxScrollExtent, pixels);
    final double oldPixels = pixels;
    final double newPixels = clampDouble(pixels - delta, minValue, maxValue);
    final double clampedDelta = newPixels - pixels;
    if (clampedDelta == 0.0) {
      return delta;
    }
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    final double offset = actualNewPixels - oldPixels;
    if (offset != 0.0) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(offset);
    }
    return delta + offset;
  }
}

class CoherentMajorScrollPosition
    extends CoherentSliverCompatScrollPosition {
  CoherentMajorScrollPosition(super.sliverCompat,
      {required super.physics, required super.context, super.debugKey});
}
