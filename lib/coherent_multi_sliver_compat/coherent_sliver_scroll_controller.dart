import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'dart:math';

import 'coherent_sliver_position.dart';

class CoherentSliverCompatScrollController extends ScrollController {
  Key? debugKey;
  CoherentSliverCompat sliverCompat;

  CoherentSliverCompatScrollController._(this.sliverCompat, {this.debugKey});

  CoherentSliverCompatScrollController.create(this.debugKey, this.sliverCompat);

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return CoherentSliverCompatScrollPosition(sliverCompat,
        physics: physics, context: context, debugKey: debugKey);
  }
}
