import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_scroll_controller.dart';
import 'package:free_scroll_compat/multi_sliver_compat/multi_sliver_scroll_controller.dart';

typedef CoherentSliverCompatBuilder = Function(
    BuildContext, CoherentSliverCompat);

class CoherentSliverCompatWidget extends StatefulWidget {
  final CoherentSliverCompatBuilder childBuilder;
  final Key? debugKey;

  const CoherentSliverCompatWidget(this.childBuilder,
      {super.key, this.debugKey});

  @override
  State<CoherentSliverCompatWidget> createState() =>
      _CoherentSliverCompatWidgetState();
}

typedef CoherentSliverCompatDelegate = _CoherentSliverCompatWidgetState;

class _CoherentSliverCompatWidgetState
    extends State<CoherentSliverCompatWidget> {
  late CoherentSliverCompat _sliverCompat;

  @override
  void initState() {
    super.initState();
    _sliverCompat = CoherentSliverCompat(context, debugKey: widget.debugKey);
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, _sliverCompat);
  }

  static CoherentSliverCompat? of(BuildContext context) => context
      .findAncestorStateOfType<CoherentSliverCompatDelegate>()
      ?._sliverCompat;
}

/// 这个CoherentSliverCompat理应是隔离的，每个层级的每个结点都有个自己的CoherentSliverCompat；
class CoherentSliverCompat {
  BuildContext buildContext;
  Key? debugKey;

  CoherentSliverCompat(this.buildContext, {this.debugKey});

  CoherentSliverCompatScrollController? _scrollController;

  ScrollController generateScrollController({required Key tag}) {
    if (_scrollController != null) {
      return _scrollController!;
    }
    CoherentSliverCompatScrollController newController =
        CoherentSliverCompatScrollController.minor(tag, this);
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
    print('($debugKey)ToTop  pha1: 剩余:$remaining');

    // 结点内部消化
    if (_scrollController != null) {
      remaining = (_scrollController!.position as CoherentMajorScrollPosition)
          .applyClampedDragUpdate(remaining);
    }

    print('($debugKey)ToTop  pha2: 剩余:$remaining');

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
      remaining = (_scrollController!.position as CoherentMajorScrollPosition)
          .applyClampedDragUpdate(remaining);
    }
    print('($debugKey)ToBottom pha1: 剩余:$remaining');

    if (remaining == 0) {
      return 0;
    }

    /// 向外传递
    remaining = CoherentSliverCompatDelegate.of(buildContext)
            ?.onChildrenSubmit(remaining) ?? // 如果这里换成delta就可以实现多级同步滚动
        remaining;
    print('($debugKey)ToBottom pha2: 剩余:$remaining');

    return remaining;
  }

  double onChildrenSubmit(double delta) {
    print('($debugKey)Receiver from Another layer 组件间剩余:$delta');
    return submitUserOffset(null, delta);
  }
}
