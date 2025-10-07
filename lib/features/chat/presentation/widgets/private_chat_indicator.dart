// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:elysia/providers/private_chat_provider.dart';
// import 'package:elysia/utiltities/consts/color_constants.dart';
//
// class PrivateChatIndicator extends ConsumerWidget {
//   const PrivateChatIndicator({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isPrivate = ref.watch(privateChatProvider);
//
//     if (!isPrivate) return const SizedBox.shrink();
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: ColorConst.primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: ColorConst.primaryColor.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.lock,
//             size: 16,
//             color: ColorConst.primaryColor,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             'Private Chat',
//             style: TextStyle(
//               color: ColorConst.primaryColor,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
