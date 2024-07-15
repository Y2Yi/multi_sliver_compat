import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  Widget child;
  @override
  double maxExtent;
  @override
  double minExtent;

  CustomSliverPersistentHeaderDelegate(
      {required this.child, required this.maxExtent, required this.minExtent});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
