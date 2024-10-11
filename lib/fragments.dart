import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_delegate_widget.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'package:free_scroll_compat/sliver_persistent_header_delegate.dart';

Widget buildMenu(double h, {int? index}) {
  return Container(
    height: h,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      color: Color.fromARGB(55, Random().nextInt(255), Random().nextInt(255),
          Random().nextInt(255)),
    ),
    alignment: Alignment.center,
    child: Builder(builder: (context) {
      return Text("$index,${Random().nextInt(255)}");
    }),
  );
}

Widget buildMenuList(ScrollController? scrollController, double h,
    {int count = 32}) {
  if (count == 0) {
    return const SizedBox.shrink();
  }
  List<Widget> children = [];
  for (int i = 0; i < count; i++) {
    children.add(buildMenu(h, index: i));
  }
  return ListView(controller: scrollController, children: children);
}

class StoreFragment extends StatelessWidget {
  const StoreFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text("StoreFragment"),
    );
  }
}

class GoodsFragment extends StatelessWidget {
  const GoodsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            controller: MultiSliverCompatDelegate.ofNotNull(context)
                .generateMinorController(tag: const Key("goods_type_list")),
            children: [
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
              buildMenu(64),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(
            controller: MultiSliverCompatDelegate.ofNotNull(context)
                .generateMinorController(tag: const Key("goods_detail_list")),
            children: [
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
              buildMenu(96),
            ],
          ),
        )
      ],
    );
  }
}

class RatingFragment extends StatelessWidget {
  const RatingFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return CoherentSliverCompatWidget((context, sliverCompat) =>
        CustomScrollView(
          controller:
              sliverCompat.generateScrollController(tag: const Key("1")),
          slivers: [
            SliverPersistentHeader(
                pinned: true,
                delegate: CustomSliverPersistentHeaderDelegate(
                  maxExtent: 100,
                  minExtent: MediaQuery.of(context).viewPadding.top,
                  child: AppBar(
                    title: const Text("SliverAppBar"),
                  ),
                )),
            SliverFillRemaining(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CoherentSliverCompatWidget((ctx, sliverCompat) =>
                        buildMenuList(
                            sliverCompat.generateScrollController(
                                tag: const Key("1-1")),
                            64)),
                  ),
                  Expanded(
                    flex: 1,
                    child: CoherentSliverCompatWidget((ctx, sliverCompat) =>
                        buildMenuList(
                            sliverCompat.generateScrollController(
                                tag: const Key("1-2")),
                            96)),
                  ),
                  Expanded(
                    flex: 4,
                    child: CoherentSliverCompatWidget((ctx, sliverCompat) =>
                        CustomScrollView(
                          controller: sliverCompat.generateScrollController(
                              tag: Key("2")),
                          slivers: [
                            SliverPersistentHeader(
                                pinned: true,
                                delegate: CustomSliverPersistentHeaderDelegate(
                                  maxExtent: 200,
                                  minExtent:
                                      MediaQuery.of(context).viewPadding.top,
                                  child: AppBar(
                                    title: const Text("SliverAppBar"),
                                  ),
                                )),
                            SliverFillRemaining(
                              child: Row(
                                children: [
                                  const FittedBox(
                                    child: SizedBox(
                                      height: 320,
                                      child: Text("CommonView"),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: CoherentSliverCompatWidget(
                                        (ctx, sliverCompat) => CustomScrollView(
                                              controller: sliverCompat
                                                  .generateScrollController(
                                                      tag: Key("3")),
                                              slivers: [
                                                SliverPersistentHeader(
                                                    pinned: true,
                                                    delegate:
                                                        CustomSliverPersistentHeaderDelegate(
                                                      maxExtent: 300,
                                                      minExtent:
                                                          MediaQuery.of(context)
                                                              .viewPadding
                                                              .top,
                                                      child: LayoutBuilder(
                                                        builder:
                                                            (ctx, constraint) {
                                                          return AppBar(
                                                              title: Text(
                                                                  "${constraint.maxHeight}"));
                                                        },
                                                      ),
                                                    )),
                                                CoherentSliverCompatWidget(
                                                  (ctx, sliverCompat) =>
                                                      SliverFillRemaining(
                                                    child: buildMenuList(
                                                        sliverCompat
                                                            .generateScrollController(
                                                                tag: const Key(
                                                                    "3-1")),
                                                        66),
                                                  ),
                                                )
                                              ],
                                            )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class NestedScrollFragment extends StatelessWidget {
  const NestedScrollFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (a, b) {
          return [
            SliverPersistentHeader(
                pinned: true,
                delegate: CustomSliverPersistentHeaderDelegate(
                  maxExtent: 300,
                  minExtent: MediaQuery.of(context).viewPadding.top,
                  child: AppBar(
                    title: const Text("SliverAppBar"),
                  ),
                )),
          ];
        },
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: buildMenuList(null, 64),
            ),
            Expanded(
              flex: 2,
              child: buildMenuList(null, 128),
            )
          ],
        ));
  }
}

class BallisticFragment extends StatelessWidget {
  const BallisticFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return CoherentSliverCompatWidget((context, sliverCompat) {
      return buildMenuList(
          sliverCompat.generateScrollController(tag: Key("Demo")), 72,
          count: 128);
    });
  }
}
