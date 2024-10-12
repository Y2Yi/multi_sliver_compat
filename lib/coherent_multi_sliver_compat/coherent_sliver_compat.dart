import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_delegate_widget.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_scroll_controller.dart';

import 'coherent_sliver_position.dart';

/// 这个CoherentSliverCompat理应是隔离的，每个层级的每个结点都有个自己的CoherentSliverCompat；
class CoherentSliverCompat {
  BuildContext buildContext;
  Key? debugKey;

  Key? get effectiveDebugKey => debugKey ?? _scrollController?.debugKey;

  CoherentSliverCompat(this.buildContext, {this.debugKey});

  CoherentSliverCompatScrollController get scrollController =>
      _scrollController!;

  CoherentSliverCompatScrollController? _scrollController;

  ScrollController generateScrollController({required Key tag}) {
    if (_scrollController != null) {
      return _scrollController!;
    }
    CoherentSliverCompatScrollController newController =
        CoherentSliverCompatScrollController.create(tag, this);
    _scrollController = newController;
    return newController;
  }

  // 接收child提交的滚动量
  double submitUserOffset(
      CoherentSliverCompatScrollPosition? submitter, double delta) {
    if (delta < 0) {
      return onScrollReverse(submitter, delta);
    } else {
      return onScrollForward(submitter, delta);
    }
  }

  double onScrollReverse(
      CoherentSliverCompatScrollPosition? submitter, double delta) {
    if (delta == 0) {
      return 0;
    }

    /// 向外传递
    double remaining = delta;
    remaining = CoherentSliverCompatDelegate.of(buildContext)
            ?.onChildrenSubmit(delta) ??
        remaining;

    if (remaining == 0) {
      return 0;
    }

    print('($effectiveDebugKey)Reverse  pha1: 剩余:$remaining');

    // 结点内部消化
    if (_scrollController != null) {
      remaining =
          (_scrollController!.position as CoherentSliverCompatScrollPosition)
              .applyClampedDragUpdate(remaining);
    }

    print('($effectiveDebugKey)Reverse  pha2: 剩余:$remaining');

    return remaining;
  }

  double onScrollForward(
      CoherentSliverCompatScrollPosition? submitter, double delta) {
    double remaining = delta;

    if (remaining == 0) {
      return remaining;
    }

    /// 内部消化
    if (_scrollController != null) {
      remaining =
          (_scrollController!.position as CoherentSliverCompatScrollPosition)
              .applyClampedDragUpdate(remaining);
    }
    print('($effectiveDebugKey)Forward pha1: 剩余:$remaining');

    if (remaining == 0) {
      return 0;
    }

    /// 向外传递
    remaining = CoherentSliverCompatDelegate.of(buildContext)
            ?.onChildrenSubmit(remaining) ?? // 如果这里换成delta就可以实现多级同步滚动
        remaining;
    print('($effectiveDebugKey)Forward pha2: 剩余:$remaining');

    return remaining;
  }

  double onChildrenSubmit(double delta) {
    print('($effectiveDebugKey)Receiver from Another layer 组件间剩余:$delta');
    return submitUserOffset(null, delta);
  }

  //
  // double submitAnimatedValue(
  //     double value, ScrollDirection lastEffectiveScrollDirection) {
  //   if (value.abs() < precisionErrorTolerance) {
  //     return value;
  //   }
  //   if (lastEffectiveScrollDirection == ScrollDirection.forward) {
  //     // to Top
  //     return _submitAnimatedValueForward(-value);
  //   } else {
  //     // to bottom
  //     return _submitAnimatedValueReverse(value);
  //   }
  // }
  //
  // // 祖先SliverCompat将无法准确获取到需要分发的下一个节点是哪一个
  // double _submitAnimatedValueForward(double value) {
  //   double remaining = value;
  //
  //   if (remaining.abs() < precisionErrorTolerance) {
  //     return remaining;
  //   }
  //   // 向上提交
  //   remaining = CoherentSliverCompatDelegate.of(buildContext)
  //           ?._submitAnimatedValueForward(remaining) ??
  //       remaining;
  //
  //   if (remaining.abs() < precisionErrorTolerance) {
  //     return remaining;
  //   }
  //   // 自己消费
  //   remaining =
  //       (_scrollController!.position as CoherentSliverCompatScrollPosition)
  //           .applyClampedDragUpdate(remaining);
  //
  //   return remaining;
  // }
  //
  // double _submitAnimatedValueReverse(double value) {
  //   double remaining = value;
  //
  //   if (remaining.abs() < precisionErrorTolerance) {
  //     return remaining;
  //   }
  //   // 自己消费
  //   remaining =
  //       (_scrollController!.position as CoherentSliverCompatScrollPosition)
  //           .applyClampedDragUpdate(remaining);
  //
  //   if (remaining.abs() < precisionErrorTolerance) {
  //     return remaining;
  //   }
  //
  //   // 向上提交
  //   remaining = CoherentSliverCompatDelegate.of(buildContext)
  //           ?._submitAnimatedValueReverse(remaining) ??
  //       remaining;
  //
  //   return remaining;
  // }

  void beginActivityToParent(double overscroll,
      {required Simulation simulation}) {
    ScrollPosition? position = CoherentSliverCompatDelegate.of(buildContext)
        ?.scrollController
        .position;
    if (position == null) {
      return;
    }
    (position as CoherentSliverCompatScrollPosition)
        .acceptBallisticValueWithAnimationController(overscroll, simulation);
  }

  CoherentSliverCompatScrollPosition get position =>
      scrollController.position as CoherentSliverCompatScrollPosition;

  /// reverse direction
  ballisticTransformReverse(double value, double delta, Simulation simulation) {
    double overscroll = position.setPixels(value);

    /// overscroll == 0
    if (overscroll.abs() < precisionErrorTolerance) {
      return;
    }

    if (delta.abs() > precisionErrorTolerance) {
      // 自身需要立即停止动画
      position.goIdle();
      beginActivityToParent(overscroll, simulation: simulation);
    }
    return;
  }

  void ballisticTransformForward(
      double value, double delta, Simulation simulation) {}
}
