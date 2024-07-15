import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/multi_sliver_compat/sliver_compat.dart';

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
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
              _buildMenu(64),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(
            controller: MultiSliverCompatDelegate.ofNotNull(context)
                .generateMinorController(tag: const Key("goods_detail_list")),
            children: [
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
              _buildMenu(96),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMenu(double h) {
    return Container(
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Color.fromARGB(55, Random().nextInt(255), Random().nextInt(255),
            Random().nextInt(255)),
      ),
      alignment: Alignment.center,
      child: Text("${Random().nextInt(255)}"),
    );
  }
}

class RatingFragment extends StatelessWidget {
  const RatingFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text("RatingFragment"),
    );
  }
}
