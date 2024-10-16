import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/ballistic/coherent_sliver_ballistic_forward_scroll_activity.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_ballistic_simulation.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_delegate_widget.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_scroll_controller.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/tt.dart';
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

    TT.t('($effectiveDebugKey)Reverse  pha1: 剩余:$remaining');

    // 结点内部消化
    if (_scrollController != null) {
      remaining =
          (_scrollController!.position as CoherentSliverCompatScrollPosition)
              .applyClampedDragUpdate(remaining);
    }

    TT.t('($effectiveDebugKey)Reverse  pha2: 剩余:$remaining');

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
    TT.t('($effectiveDebugKey)Forward pha1: 剩余:$remaining');

    if (remaining == 0) {
      return 0;
    }

    /// 向外传递
    remaining = CoherentSliverCompatDelegate.of(buildContext)
            ?.onChildrenSubmit(remaining) ?? // 如果这里换成delta就可以实现多级同步滚动
        remaining;
    TT.t('($effectiveDebugKey)Forward pha2: 剩余:$remaining');

    return remaining;
  }

  double onChildrenSubmit(double delta) {
    TT.t('($effectiveDebugKey)Receiver from Another layer 组件间剩余:$delta');
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

  void beginActivityToParent({required Simulation simulation}) {
    ScrollPosition? position = CoherentSliverCompatDelegate.of(buildContext)
        ?.scrollController
        .position;
    if (position == null) {
      return;
    }
    (position as CoherentSliverCompatScrollPosition)
        .acceptBallisticValueWithAnimationController(simulation);
  }

  CoherentSliverCompatScrollPosition get position =>
      scrollController.position as CoherentSliverCompatScrollPosition;

  // /// reverse direction
  // ballisticTransformReverse(double value, double delta, Simulation simulation) {
  //   double overscroll = position.setPixels(value);
  //
  //   /// overscroll == 0
  //   if (overscroll.abs() < precisionErrorTolerance) {
  //     return;
  //   }
  //
  //   if (delta.abs() > precisionErrorTolerance) {
  //     // 自身需要立即停止动画
  //     position.goIdle();
  //     beginActivityToParent(simulation: simulation);
  //   }
  //   return;
  // }

  void ballisticTransformForward(Simulation simulation) {
    CoherentFallDownScrollActivityManager manager =
        CoherentFallDownScrollActivityManager(
            ScrollDirection.forward, simulation);
    onBallisticTransformForward(manager);
  }

  void onBallisticTransformForward(
      CoherentFallDownScrollActivityManager manager) {
    // 需要在这个方向上滚动
    if (position.canScrollForward) {
      manager.addScrollActivityDelegate(position);
      TT.t(
          "(FlutterSourceCode)[coherent_sliver_compat.dart]->($effectiveDebugKey) marked!"
          "(available extent:${position.maxScrollExtent - position.pixels})");
    } else {
      TT.t(
          "(FlutterSourceCode)[coherent_sliver_compat.dart]->($effectiveDebugKey) cant be marked"
          ".(position maxExtent:${position.maxScrollExtent},pixels:${position.pixels})");
    }
    CoherentSliverCompat? lastLayer =
        CoherentSliverCompatDelegate.of(buildContext);
    // 已经是最高层了
    if (lastLayer == null) {
      TT.t(
          "(FlutterSourceCode)[coherent_sliver_compat.dart]->(${effectiveDebugKey} fall down)");
      manager.startFallDown();
    } else {
      lastLayer.onBallisticTransformForward(manager);
    }
  }
}

/// 一个新的ScrollActivityDelegate的前端，用于管理在向上传递弹性滚动事件
/// 持有路径节点中会消费弹性滚动事件的所有节点的ScrollActivityDelegate，也就是ScrollPosition
class CoherentFallDownScrollActivityManager {
  final Queue<ScrollActivityDelegate> _list = Queue();
  CoherentBallisticForwardScrollActivity? _activity;
  final ScrollDirection _lastEffectiveScrollDirection;
  final Simulation _simulation;
  double _consumed = 0;
  double currentNodeStart = 0;

  CoherentFallDownScrollActivityManager(
      this._lastEffectiveScrollDirection, this._simulation);

  addScrollActivityDelegate(ScrollActivityDelegate delegate) {
    _list.add(delegate);
  }

  removeScrollActivityDelegate(ScrollActivityDelegate delegate) {
    _list.removeWhere((element) => element == delegate);
  }

  ScrollActivityDelegate? get head => _list.lastOrNull;

  startFallDown() {
    if (head == null) {
      return;
    }
    for (var element in _list) {
      element.goIdle();
    }
    handleCurrentNode();
  }

  handleCurrentNode() {
    if (head == null) {
      return;
    }

    /// 更新下一个Delegate
    _activity = CoherentBallisticForwardScrollActivity(
        head!,
        this,
        _simulation,
        (head as CoherentSliverCompatScrollPosition).context.vsync,
        false // shouldIgnorePointer
        );

    TT.t(
        "(FlutterSourceCode)[coherent_sliver_compat.dart]->CoherentFallDownScrollActivityManager::handleNode start handle:${(head as CoherentSliverCompatScrollPosition).sliverCompat.effectiveDebugKey}");
    (_simulation as CoherentBallisticSimulation)
        .updatePosition((head as ScrollPosition).pixels);
    (_simulation as CoherentBallisticSimulation).updateExtraConsumed(_consumed);
    (head as CoherentSliverCompatScrollPosition).beginActivity(_activity);
    currentNodeStart = (head as CoherentSliverCompatScrollPosition).pixels;
  }

  void onNodeCompleteListener(ScrollActivityDelegate completedDelegate) {
    TT.t(
        "(FlutterSourceCode)[coherent_sliver_compat.dart]->CoherentFallDownScrollActivityManager::handleNode handle completed!:${(head as CoherentSliverCompatScrollPosition).sliverCompat.effectiveDebugKey}");
    removeScrollActivityDelegate(completedDelegate);
    _consumed +=
        (completedDelegate as CoherentSliverCompatScrollPosition).pixels -
            currentNodeStart;
    handleCurrentNode();
  }
}
