import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/ballistic/coherent_sliver_ballistic_scroll_activity.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_ballistic_simulation.dart';
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
    beginActivity(createBallisticScrollActivity(simulation));
  }

  void acceptBallisticValueWithAnimationController(
      double overscroll, Simulation simulation) {
    (simulation as CoherentBallisticSimulation).updatePosition(pixels);
    beginActivity(CoherentBallisticScrollActivity(
        this,
        sliverCompat,
        userScrollDirection,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? false));
  }

  ScrollActivity createBallisticScrollActivity(Simulation simulation) {
    return CoherentBallisticScrollActivity(
        this,
        sliverCompat,
        userScrollDirection,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? false);
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
    if (velocity > 0.0 && pixels >= maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && pixels <= minScrollExtent) {
      return null;
    }
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
