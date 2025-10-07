import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';

class ResponseError extends StatelessWidget {
  final String message;
  const ResponseError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SvgPicture.asset(
              AssetConsts.elysiaBrainSvg,
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                message,
                style: TextStyle(
                  color: ColorConst.errorChatResponse,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
