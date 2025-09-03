// import 'package:flutter/material.dart';
// import 'package:msal_auth/msal_auth.dart';
//
// class LoginScreen extends StatefulWidget {
//   static const route = '/login';
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   bool _loading = false;
//   String? _error;
//   MsalUser? _user;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign in with Microsoft')),
//       body: Center(
//         child: _loading
//             ? const CircularProgressIndicator()
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _signIn,
//               child: const Text('Sign in with Microsoft'),
//             ),
//             if (_error != null) ...[
//               const SizedBox(height: 16),
//               Text(_error!, style: const TextStyle(color: Colors.red)),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _signIn() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final msalAuth = await MsalAuth.createPublicClientApplication(
//         clientId: '<YOUR_CLIENT_ID>',
//         scopes: ['https://graph.microsoft.com/user.read'],
//         androidConfig: AndroidConfig(
//           configFilePath: 'assets/msal_config.json',
//           tenantId: '<YOUR_TENANT_ID>',
//         ),
//         iosConfig: IosConfig(
//           authority: 'https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/authorize',
//           authMiddleware: AuthMiddleware.msAuthenticator,
//           tenantType: TenantType.entraIDAndMicrosoftAccount,
//         ),
//       );
//       final user = await msalAuth.acquireToken(
//         prompt: Prompt.login,
//         loginHint: null, // Or your email
//       );
//       if (user != null) {
//         setState(() => _user = user);
//         Navigator.pushReplacementNamed(context, '/');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
// }
