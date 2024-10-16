import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'dart:math';

import 'coherent_sliver_position.dart';

bool show = false;

class TT {
  TT._();

  static void t(String? msg) {
    if (!show) {
      return;
    }
    print(msg);
  }
}
