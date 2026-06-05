import 'package:flutter/material.dart';

class HorizontalCardList extends StatefulWidget {
  const HorizontalCardList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemWidth = 160,
    this.separatorWidth = 16,
    this.horizontalPadding = 32,
    this.bottomPadding = 8,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemWidth;
  final double separatorWidth;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  State<HorizontalCardList> createState() => _HorizontalCardListState();
}

class _HorizontalCardListState extends State<HorizontalCardList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemWidth + 56 + widget.bottomPadding,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        interactive: true,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(
            widget.horizontalPadding,
            0,
            widget.horizontalPadding,
            widget.bottomPadding,
          ),
          itemCount: widget.itemCount,
          separatorBuilder: (_, __) => SizedBox(width: widget.separatorWidth),
          itemBuilder: (context, index) {
            return SizedBox(
              width: widget.itemWidth,
              child: widget.itemBuilder(context, index),
            );
          },
        ),
      ),
    );
  }
}
