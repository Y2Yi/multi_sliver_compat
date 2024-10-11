import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/ballistic/coherent_sliver_ballistic_scroll_activity.dart';
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
    print("(FlutterSourceCode)[coherent_sliver_position.dart]->delta:${delta}");
    updateUserScrollDirection(
        delta < 0 ? ScrollDirection.forward : ScrollDirection.reverse);
    double remaining = sliverCompat.submitUserOffset(this, delta);

    /// 剩余滚动量
    if (remaining < precisionErrorTolerance) {
      return;
    }

    /// 该滚动量应该造成视图自身的弹性滚动
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->$debugKey 盈余滚动量:$remaining");
  }

  ScrollDirection _lastEffectiveScrollDirection = ScrollDirection.forward;

  @override
  void updateUserScrollDirection(ScrollDirection value) {
    if (value != ScrollDirection.idle) {
      _lastEffectiveScrollDirection = value;
    }
    super.updateUserScrollDirection(value);
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

  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    if (velocity == 0) {
      goIdle();
      return;
    }

    final Simulation? simulation =
        physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      print(
          "(FlutterSourceCode)[coherent_sliver_position.dart]->goBallistic simulation is not null:${simulation.runtimeType},$_lastEffectiveScrollDirection");
      beginActivity(createBallisticScrollActivity(simulation));
    } else {
      goIdle();
    }
  }

  ScrollActivity createBallisticScrollActivity(Simulation simulation) {
    return CoherentBallisticScrollActivity(
        sliverCompat,
        _lastEffectiveScrollDirection,
        this,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? true);
  }
}
