// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
// import 'package:elysia/main.dart';
// import 'package:elysia/utiltities/consts/color_constants.dart';
// import 'package:elysia/utiltities/consts/asset_consts.dart';
//
// ListTile buildPrivateChatTile(BuildContext context) {
//   return ListTile(
//     leading: SvgPicture.asset(AssetConsts.iconPrivateChat),
//     title: const Text('Private Chat',
//         style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//             color: ColorConst.primaryBlack)),
//     onTap: () {
//       Navigator.of(context).pop(); // Close bottom sheet
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           settings: const RouteSettings(name: '/chat'),
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               const MainLayout(child: ChatScreen(isPrivate: true)),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//           transitionDuration: const Duration(milliseconds: 300),
//         ),
//       );
//     },
//   );
// }
