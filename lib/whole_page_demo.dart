// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_delegate_widget.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'package:free_scroll_compat/sliver_persistent_header_delegate.dart';

import 'coherent_multi_sliver_compat/coherent_sliver_compat.dart';
import 'fragments.dart';

class WholePageDemo extends StatefulWidget {
  const WholePageDemo({super.key});

  @override
  State<WholePageDemo> createState() => _WholePageDemoState();
}

class _WholePageDemoState extends State<WholePageDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CoherentSliverCompatWidget((context, sliverCompat) =>
            CustomScrollView(
              controller: sliverCompat.generateScrollController(tag: Key("1")),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CustomSliverPersistentHeaderBuilderDelegate(
                      maxExtent: 128,
                      minExtent: 48,
                      child: AppBar(
                        title: Text("Appbar"),
                      ),
                      builder: (Widget child, BuildContext context,
                          double shrinkOffset, bool overlapsContent) {
                        print(
                            "(FlutterSourceCode)[whole_page_demo.dart]->shrinkOffset:$shrinkOffset");
                        return Stack(
                          children: [
                            // 展开时展示
                            Opacity(
                                opacity: 1 - (shrinkOffset / 128),
                                child: SizedBox(
                                  height: 120,
                                  child: FittedBox(child: Text("Other")),
                                )),
                            // 收起时展示
                            Opacity(
                                opacity: (shrinkOffset / 128), child: child),
                          ],
                        );
                      }),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CustomSliverPersistentHeaderDelegate(
                      maxExtent: 50,
                      minExtent: 50,
                      child: Column(
                        children: [
                          Divider(thickness: 1,height: 1,),
                          ColoredBox(
                            color: Color(0xAAFFFFFF),
                            child: TabBar(
                              controller: _tabController,
                              tabs: _implementTabs(),
                              unselectedLabelColor: Colors.black,
                              labelColor: Colors.blue,
                            ),
                          ),
                          Divider(thickness: 1,height: 1,),
                        ],
                      )),
                ),
                SliverFillRemaining(
                  child:TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListPart(),
                      _buildListPart(),
                      _buildListPart(),
                      _buildListPart(),
                      _buildListPart(),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget _buildListPart()=>Row(
    children: [
      Expanded(
          flex: 1,
          child: CoherentSliverCompatWidget(
                  (context, sliverCompat) {
                return buildMenuList(
                    sliverCompat.generateScrollController(
                        tag: Key("1-1")),
                    64,
                    count: 18);
              })),
      Expanded(
          flex: 4,
          child: CoherentSliverCompatWidget(
                  (context, sliverCompat) {
                return buildMenuList(
                    sliverCompat.generateScrollController(
                        tag: Key("1-2")),
                    128,
                    count: 128);
              })),
    ],
  );

  List<Tab> _implementTabs() {
    return [
      const Tab(
        text: "1",
      ),
      const Tab(
        text: "22",
      ),
      const Tab(
        text: "333",
      ),
      const Tab(
        text: "4444",
      ),
      const Tab(
        text: "5555",
      )
    ];
  }
}
