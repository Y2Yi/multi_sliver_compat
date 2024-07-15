// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';
import 'package:free_scroll_compat/sliver_persistent_header_delegate.dart';

import 'fragments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SliverCompatBizWidget(),
    );
  }
}

class SliverCompatBizWidget extends StatefulWidget {
  const SliverCompatBizWidget({super.key});

  @override
  State<SliverCompatBizWidget> createState() => _SliverCompatBizWidgetState();
}

class _SliverCompatBizWidgetState extends State<SliverCompatBizWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child:
            MultiSliverCompatWidget.asRoot(debugKey: Key("Top DebugKey"),
                (BuildContext buildContext, SliverCompat sliverCompat) {
          return CustomScrollView(
            controller: sliverCompat.generateMajorController(),
            slivers: [
              SliverPersistentHeader(
                  pinned: true,
                  delegate: CustomSliverPersistentHeaderDelegate(
                    maxExtent: 200,
                    minExtent: MediaQuery.of(context).viewPadding.top,
                    child: AppBar(
                      title: const Text("SliverAppBar"),
                    ),
                  )),

              /// Tab
              SliverPersistentHeader(
                pinned: true,
                delegate: CustomSliverPersistentHeaderDelegate(
                    maxExtent: 48,
                    minExtent: 48,
                    child: ColoredBox(
                      color: Color(0xAAFFFFFF),
                      child: TabBar(
                        controller: _tabController,
                        tabs: _implementTabs(),
                        unselectedLabelColor: Colors.black,
                        labelColor: Colors.blue,
                      ),
                    )),
              ),

              /// Tab body
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _generateGoodsPage(),
                    _generateRatingPage(),
                    _generateStorePage(),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  List<Tab> _implementTabs() {
    return [
      const Tab(
        text: "商品",
      ),
      const Tab(
        text: "评价",
      ),
      const Tab(
        text: "商家",
      ),
    ];
  }

  _generateGoodsPage() => MultiSliverCompatWidget.asCommon(
        (ctx, sliverCompat) => CustomScrollView(
          controller: sliverCompat.generateMajorController(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: FittedBox(
                  child: Text("广告视图"),
                ),
              ),
            ),
            SliverFillRemaining(child: GoodsFragment()),
          ],
        ),
        debugKey: Key("Middleware DebugKey"),
      );

  _generateRatingPage() => RatingFragment();

  _generateStorePage() => StoreFragment();
}
