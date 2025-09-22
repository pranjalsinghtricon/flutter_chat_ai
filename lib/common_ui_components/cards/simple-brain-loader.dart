import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';

class SimpleBrainLoader extends StatefulWidget {
  final double size;

  const SimpleBrainLoader({Key? key, this.size = 22}) : super(key: key);

  @override
  State<SimpleBrainLoader> createState() => _SimpleBrainLoaderState();
}

class _SimpleBrainLoaderState extends State<SimpleBrainLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        AssetConsts.elysiaBrainLoaderSvg,
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}