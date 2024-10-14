import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_position.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';

typedef ScrollActivityDelegateListener = Function(
    ScrollActivityDelegate delegate);

class CoherentBallisticForwardScrollActivity extends ScrollActivity {
  CoherentFallDownScrollActivityManager manager;

  /// Creates an activity that animates a scroll view based on a [simulation].
  ///
  /// The [delegate], [simulation], and [vsync] arguments must not be null.
  CoherentBallisticForwardScrollActivity(
    super.delegate,
    this.manager,
    Simulation simulation,
    TickerProvider vsync,
    this.shouldIgnorePointer,
  ) {
    _controller = AnimationController.unbounded(
      debugLabel: kDebugMode
          ? objectRuntimeType(this, 'CoherentBallisticForwardScrollActivity')
          : null,
      vsync: vsync,
    )
      ..addListener(_tick)
      ..animateWith(simulation)
          .whenComplete(_end); // won't trigger if we dispose _controller first
  }

  late AnimationController _controller;

  @override
  void resetActivity() {
    delegate.goBallistic(velocity);
  }

  @override
  void applyNewDimensions() {
    // delegate.goBallistic(velocity);
  }

  void _tick() {
    if (!applyMoveTo(_controller.value)) {
      manager.onNodeCompleteListener(delegate);
      delegate.goIdle();
    }
  }

  double get layerPixels =>
      (delegate as CoherentSliverCompatScrollPosition).pixels;

  CoherentSliverCompat get layerSliverCompat =>
      (delegate as CoherentSliverCompatScrollPosition).sliverCompat;

  /// 这东西返回的结果是是否在当前组件上滚动完成
  @protected
  bool applyMoveTo(double value) {
    var overscroll = delegate.setPixels(value);
    print(
        "(FlutterSourceCode)[coherent_sliver_ballistic_forward_scroll_activity.dart]->applyMoveTo animation producer:${value}");
    print(
        "(FlutterSourceCode)[coherent_sliver_ballistic_forward_scroll_activity.dart]->applyMoveTo overscroll:${overscroll}!(pixels:${(delegate as ScrollPosition).pixels},scrollExtent:${(delegate as ScrollPosition).minScrollExtent},${(delegate as ScrollPosition).maxScrollExtent})");
    return overscroll.abs() < precisionErrorTolerance;
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
