import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';

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
    double remaining = sliverCompat.submitUserOffset(this, delta);

    /// 剩余滚动量
    if (remaining < precisionErrorTolerance) {
      return;
    }

    /// 该滚动量应该造成视图自身的弹性滚动
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->$debugKey 盈余滚动量:$remaining");
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
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->$debugKey 剩余滚动量:${delta + offset}");
    return delta + offset;
  }

  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    final Simulation? simulation =
        physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      print(
          "(FlutterSourceCode)[coherent_sliver_position.dart]->goBallistic simulation is not null:${simulation.runtimeType}");
      beginActivity(createBallisticScrollActivity(simulation));
    } else {
      goIdle();
    }
  }

  ScrollActivity createBallisticScrollActivity(Simulation simulation) {
    return CoherentBallisticScrollActivity(sliverCompat, this, simulation,
        context.vsync, activity?.shouldIgnorePointer ?? true);
  }

  @override
  double applyBoundaryConditions(double value) {
    return super.applyBoundaryConditions(value);
  }
}

class CoherentBallisticScrollActivity extends BallisticScrollActivity {
  CoherentBallisticScrollActivity(this.sliverCompat, super.delegate,
      super.simulation, super.vsync, super.shouldIgnorePointer);

  CoherentSliverCompat sliverCompat;

  @override
  bool applyMoveTo(double value) {
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->applyMoveTo $value");

    var remaining = sliverCompat.submitAnimatedValue(value);

    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->applyMoveTo remaining $remaining");
    if (remaining == value) {
      return super.applyMoveTo(value);
    }
    return remaining.abs() < precisionErrorTolerance;
  }
}
