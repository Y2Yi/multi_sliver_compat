import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  @override
  double applyBoundaryConditions(double value) {
    return super.applyBoundaryConditions(value);
  }
}

class CoherentBallisticScrollActivity extends BallisticScrollActivity {
  ScrollDirection lastEffectiveScrollDirection;

  CoherentBallisticScrollActivity(
      this.sliverCompat,
      this.lastEffectiveScrollDirection,
      super.delegate,
      super.simulation,
      super.vsync,
      super.shouldIgnorePointer);

  CoherentSliverCompat sliverCompat;

  /// applyMoveTo产生的value，其实是velocity，用在惯性滚动中，就是此刻的速度。
  /// 只要手指稍微快一点滚动，那么这个数值就有可能达到1000+甚至是3000+，直接会导致视图的偏移量打满。
  /// 除此之外，这个数值是一个标量，他不具有方向含义，因此它在产生的时候具体的数值一定是正数，无论是视图向下还是向上，
  /// 这就会导致另一个问题，如果不额外结合方向去处理这个value，就一定会有一个方向的滚动是异常的。
  @override
  bool applyMoveTo(double value) {
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart](ScrollActivity hashCode:${hashCode}) ------------------- ballistic tick $value");

    var remaining =
        sliverCompat.submitAnimatedValue(value, lastEffectiveScrollDirection);

    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->applyMoveTo remaining $remaining");
    if (remaining == value) {
      print(
          "(FlutterSourceCode)[coherent_sliver_position.dart]->applyMoveTo full consume");
      return super.applyMoveTo(value);
    }
    return remaining.abs() < precisionErrorTolerance;
  }

  @override
  void resetActivity() {
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]-> ScrollActivity(${this.hashCode}) reset!");
    super.resetActivity();
  }

  @override
  void dispose() {
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->ScrollActivity(${this.hashCode} dispose!");
    super.dispose();
  }
}
