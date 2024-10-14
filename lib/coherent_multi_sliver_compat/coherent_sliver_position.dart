import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/ballistic/coherent_sliver_ballistic_reverse_scroll_activity.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_ballistic_simulation.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';

class CoherentSliverCompatScrollPosition
    extends ScrollPositionWithSingleContext {
  CoherentSliverCompat sliverCompat;
  Key? debugKey;

  CoherentSliverCompatScrollPosition(this.sliverCompat,
      {required super.physics, required super.context, this.debugKey});

  bool get canScrollReverse => minScrollExtent < pixels;

  bool get canScrollForward => maxScrollExtent > pixels;

  /// 所有的偏移量统一交给CoherentSliverCompat去处理；
  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta < 0 ? ScrollDirection.forward : ScrollDirection.reverse);
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

  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    Simulation? simulation = createSimulation(this, velocity);
    if (simulation == null) {
      goIdle();
      return;
    }
    if (velocity == 0) {
      return;
    }

    /// 这里不能用userScrollDirection来判断方向，因为弹性滚动开始的时候，往往整个Scrollable会处于idle状态。
    /// userScrollDirection的值一般也是idle，而不是forward或者reverse
    if (velocity > 0) {
      // forward
      goIdle();
      sliverCompat.ballisticTransformForward(simulation);
    } else {
      if (!canScrollReverse) {
        /// 跳过，向上传递
        goIdle();
        sliverCompat.beginActivityToParent(simulation: simulation);
        return;
      }

      /// 当前层消费
      beginActivity(CoherentBallisticReverseScrollActivity(
          this,
          sliverCompat,
          userScrollDirection,
          simulation,
          context.vsync,
          activity?.shouldIgnorePointer ?? false));
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    print(
        "(FlutterSourceCode)[coherent_sliver_position.dart]->(${sliverCompat.effectiveDebugKey})beginActivity:${newActivity.runtimeType}");
    super.beginActivity(newActivity);
  }

  void acceptBallisticValueWithAnimationController(Simulation simulation) {
    (simulation as CoherentBallisticSimulation).updatePosition(pixels);
    beginActivity(CoherentBallisticReverseScrollActivity(
        this,
        sliverCompat,
        userScrollDirection,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? false));
  }

  @override
  double setPixels(double newPixels) {
    // update pixels
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    // TODO: implement forcePixels
    super.forcePixels(value);
  }

  Simulation? createSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (outOfRange) {
      double? end;
      if (pixels > maxScrollExtent) {
        end = maxScrollExtent;
      }
      if (pixels < minScrollExtent) {
        end = minScrollExtent;
      }
      assert(end != null);
      return ScrollSpringSimulation(
        physics.spring,
        pixels,
        end!,
        min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    /// 滚动量实际上会超过当前视图往外分发，其实就不在需要ClampingScrollSimulation中的这段越界检查逻辑了
    /// 越界的滚动量会由CoherentBallisticScrollActivity处理。
    // if (velocity > 0.0 && pixels >= maxScrollExtent) {
    //   return null;
    // }
    // if (velocity < 0.0 && pixels <= minScrollExtent) {
    //   return null;
    // }
    return CoherentBallisticSimulation(
      position: pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  /// The tolerance to use for ballistic simulations.
  Tolerance toleranceFor(ScrollMetrics metrics) {
    return physics.toleranceFor(metrics);
  }
}
