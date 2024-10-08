import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_delegate_widget.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_scroll_controller.dart';

import 'coherent_sliver_position.dart';

/// 这个CoherentSliverCompat理应是隔离的，每个层级的每个结点都有个自己的CoherentSliverCompat；
class CoherentSliverCompat {
  BuildContext buildContext;
  Key? debugKey;

  Key? get effectiveDebugKey => debugKey ?? _scrollController?.debugKey;

  CoherentSliverCompat(this.buildContext, {this.debugKey});

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
      return onScrollToTop(submitter, delta);
    } else {
      return onScrollToBottom(submitter, delta);
    }
  }

  double onScrollToTop(
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

    print('($effectiveDebugKey)ToTop  pha1: 剩余:$remaining');

    // 结点内部消化
    if (_scrollController != null) {
      remaining =
          (_scrollController!.position as CoherentSliverCompatScrollPosition)
              .applyClampedDragUpdate(remaining);
    }

    print('($effectiveDebugKey)ToTop  pha2: 剩余:$remaining');

    return remaining;
  }

  double onScrollToBottom(
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
    print('($effectiveDebugKey)ToBottom pha1: 剩余:$remaining');

    if (remaining == 0) {
      return 0;
    }

    /// 向外传递
    remaining = CoherentSliverCompatDelegate.of(buildContext)
            ?.onChildrenSubmit(remaining) ?? // 如果这里换成delta就可以实现多级同步滚动
        remaining;
    print('($effectiveDebugKey)ToBottom pha2: 剩余:$remaining');

    return remaining;
  }

  double onChildrenSubmit(double delta) {
    print('($effectiveDebugKey)Receiver from Another layer 组件间剩余:$delta');
    return submitUserOffset(null, delta);
  }

  double submitAnimatedValue(double value) {
    if (value.abs() < precisionErrorTolerance) {
      return value;
    }
    // if (value < 0) {
    //   // to Top
    //   return _submitAnimatedValueToTop(value);
    // } else {
    //   // to bottom
    //   return _submitAnimatedValueToBottom(value);
    // }
    return _submitAnimatedValueToTop(value);
  }

  // // 祖先SliverCompat将无法准确获取到需要分发的下一个节点是哪一个
  // double _submitAnimatedValueToBottom(double value) {
  //   return (_scrollController!.position as CoherentSliverCompatScrollPosition)
  //       .applyClampedDragUpdate(value);
  // }

  double _submitAnimatedValueToTop(double value) {
    print(
        "(FlutterSourceCode)[coherent_sliver_compat.dart]->_submitAnimatedValueToTop layer receive($effectiveDebugKey):${value}");
    double remaining = value;

    if (remaining.abs() > 0) {
      // 向上提交
      remaining = CoherentSliverCompatDelegate.of(buildContext)
              ?.submitAnimatedValue(remaining) ??
          remaining;
    }
    if (remaining.abs() < precisionErrorTolerance) {
      return remaining;
    }
    remaining =
        (_scrollController!.position as CoherentSliverCompatScrollPosition)
            .applyClampedDragUpdate(remaining);

    print(
        "(FlutterSourceCode)[coherent_sliver_compat.dart]->_submitAnimatedValueToTop layer($effectiveDebugKey) remain:${remaining}");
    return remaining;
  }
}
