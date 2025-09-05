import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SingleAccountPca? _msalAuth;
  bool _loading = false;
  String? _error;

  final String clientId = '2653a923-5d3a-47c3-bd01-49217fb38c8f';
  final String tenantId = '6ba04439-8b0e-43ee-ad26-c2ac9ef9e765';
  final List<String> scopes = ['User.Read'];

  @override
  void initState() {
    super.initState();
    _initMsal();
  }

  Future<void> _initMsal() async {
    try {
      final String authority = 'https://login.microsoftonline.com/$tenantId';

      _msalAuth = await SingleAccountPca.create(
        clientId: clientId,
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri: 'msauth.com.tricon.elysia://auth',
        ),
        appleConfig: AppleConfig(
          authority: authority,
          authorityType: AuthorityType.aad, // FIXED
          broker: Broker.msAuthenticator,
        ),
      );
    } catch (e) {
      setState(() => _error = 'MSAL init error: $e');
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _msalAuth!.acquireToken(
        scopes: scopes,
        prompt: Prompt.login,
      );

      if (user != null && user.accessToken != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      } else {
        setState(() => _error = 'Login failed: no token');
      }
    } on MsalException catch (e) {
      setState(() => _error = e.message); // FIXED
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elysia Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _msalAuth == null ? null : _signIn,
              child: const Text('Sign in with Microsoft'),
            ),
          ],
        ),
      ),
    );
  }
}
