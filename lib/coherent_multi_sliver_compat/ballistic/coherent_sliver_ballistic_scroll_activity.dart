import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../coherent_sliver_compat.dart';

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
