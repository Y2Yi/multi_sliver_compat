import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_position.dart';

class CoherentBallisticScrollActivity extends ScrollActivity {
  ScrollDirection lastEffectiveScrollDirection;
  CoherentSliverCompat sliverCompat;
  late Simulation _simulation;

  /// Creates an activity that animates a scroll view based on a [simulation].
  ///
  /// The [delegate], [simulation], and [vsync] arguments must not be null.
  CoherentBallisticScrollActivity(
    super.delegate,
    this.sliverCompat,
    this.lastEffectiveScrollDirection,
    Simulation simulation,
    TickerProvider vsync,
    this.shouldIgnorePointer,
  ) {
    _controller = AnimationController.unbounded(
      debugLabel: kDebugMode
          ? objectRuntimeType(this, 'CoherentBallisticScrollActivity')
          : null,
      vsync: vsync,
    )
      ..addListener(_tick)
      ..animateWith(simulation)
          .whenComplete(_end); // won't trigger if we dispose _controller first

    _simulation = simulation;
  }

  late AnimationController _controller;

  @override
  void resetActivity() {
    delegate.goBallistic(velocity);
  }

  @override
  void applyNewDimensions() {
    delegate.goBallistic(velocity);
  }

  void _tick() {
    if (!applyMoveTo(_controller.value)) {
      delegate.goIdle();
    }
  }

  double get layerPixels =>
      (delegate as CoherentSliverCompatScrollPosition).pixels;

  @protected
  bool applyMoveTo(double value) {
    /// 当前层先消费滚动量，返回的overscroll

    double delta = value - layerPixels; // 增量
    print(
        "(FlutterSourceCode)[coherent_sliver_ballistic_scroll_activity.dart]->applyMoveTo delta:${delta}");
    if (delta < 0) {
      sliverCompat.ballisticTransformReverse(value, delta, _simulation);
    } else {
      sliverCompat.ballisticTransformForward(value, delta, _simulation);
    }
    return true;
  }

  void _end() {
    delegate.goBallistic(0.0);
  }

  @override
  void dispatchOverscrollNotification(
      ScrollMetrics metrics, BuildContext context, double overscroll) {
    OverscrollNotification(
            metrics: metrics,
            context: context,
            overscroll: overscroll,
            velocity: velocity)
        .dispatch(context);
  }

  @override
  final bool shouldIgnorePointer;

  @override
  bool get isScrolling => true;

  @override
  double get velocity => _controller.velocity;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($_controller)';
  }
}
