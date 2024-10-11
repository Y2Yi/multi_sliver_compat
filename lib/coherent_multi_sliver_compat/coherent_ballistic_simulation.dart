import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/ballistic/coherent_sliver_ballistic_scroll_activity.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';

class CoherentBallisticSimulation extends Simulation {
  /// Creates a scroll physics simulation that aligns with Android scrolling.
  CoherentBallisticSimulation({
    required this.position,
    required this.velocity,
    this.friction = 0.015,
    super.tolerance,
  }) {
    _duration = _flingDuration();
    _distance = _flingDistance();
  }

  /// The position of the particle at the beginning of the simulation, in
  /// logical pixels.
  double position;

  /// The velocity at which the particle is traveling at the beginning of the
  /// simulation, in logical pixels per second.
  final double velocity;

  /// The amount of friction the particle experiences as it travels.
  ///
  /// The more friction the particle experiences, the sooner it stops and the
  /// less far it travels.
  ///
  /// The default value causes the particle to travel the same total distance
  /// as in the Android scroll physics.
  // See mFlingFriction.
  final double friction;

  /// The total time the simulation will run, in seconds.
  late double _duration;

  /// The total, signed, distance the simulation will travel, in logical pixels.
  late double _distance;

  // See DECELERATION_RATE.
  static final double _kDecelerationRate = log(0.78) / log(0.9);

  // See INFLEXION.
  static const double _kInflexion = 0.35;

  // See mPhysicalCoeff.  This has a value of 0.84 times Earth gravity,
  // expressed in units of logical pixels per second^2.
  static const double _physicalCoeff = 9.80665 // g, in meters per second^2
      *
      39.37 // 1 meter / 1 inch
      *
      160.0 // 1 inch / 1 logical pixel
      *
      0.84; // "look and feel tuning"

  // See getSplineFlingDuration().
  double _flingDuration() {
    // See getSplineDeceleration().  That function's value is
    // log(velocity.abs() / referenceVelocity).
    final double referenceVelocity = friction * _physicalCoeff / _kInflexion;

    // This is the value getSplineFlingDuration() would return, but in seconds.
    final double androidDuration =
        pow(velocity.abs() / referenceVelocity, 1 / (_kDecelerationRate - 1.0))
            as double;

    // We finish a bit sooner than Android, in order to travel the
    // same total distance.
    return _kDecelerationRate * _kInflexion * androidDuration;
  }

  // See getSplineFlingDistance().  This returns the same value but with the
  // sign of [velocity], and in logical pixels.
  double _flingDistance() {
    final double distance = velocity * _duration / _kDecelerationRate;
    assert(() {
      // This is the more complicated calculation that getSplineFlingDistance()
      // actually performs, which boils down to the much simpler formula above.
      final double referenceVelocity = friction * _physicalCoeff / _kInflexion;
      final double logVelocity = log(velocity.abs() / referenceVelocity);
      final double distanceAgain = friction *
          _physicalCoeff *
          exp(logVelocity * _kDecelerationRate / (_kDecelerationRate - 1.0));
      return (distance.abs() - distanceAgain).abs() < tolerance.distance;
    }());
    return distance;
  }

  @override
  double x(double time) {
    final double t = clampDouble(time / _duration, 0.0, 1.0);
    return position + _distance * (1.0 - pow(1.0 - t, _kDecelerationRate));
  }

  @override
  double dx(double time) {
    final double t = clampDouble(time / _duration, 0.0, 1.0);
    return velocity * pow(1.0 - t, _kDecelerationRate - 1.0);
  }

  @override
  bool isDone(double time) {
    return time >= _duration;
  }

  updatePosition(double newPosition) {
    position = newPosition;
  }
}
