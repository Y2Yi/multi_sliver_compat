
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_scroll_compat/coherent_multi_sliver_compat/coherent_sliver_compat.dart';


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
