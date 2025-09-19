import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elysia/common_ui_components/buttons/custom_icon_button.dart';
import 'package:elysia/common_ui_components/markdown/custom_markdown_renderer.dart';
import 'package:elysia/features/chat/presentation/widgets/show_feedback_card.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAiResponseCard extends StatefulWidget {
  final Message message;
  final bool isGenerating;
  final ValueChanged<Message>? onMessageUpdated;

  const CustomAiResponseCard({
    super.key,
    required this.message,
    required this.isGenerating,
    this.onMessageUpdated,
  });

  @override
  State<CustomAiResponseCard> createState() => _CustomAiResponseCardState();
}

class _CustomAiResponseCardState extends State<CustomAiResponseCard> {
  Future<void> _launchUrl() async {
    final url = Uri.parse('https://login.microsoftonline.com/2567d566-604c-408a-8a60-55d0dc9d9d6b/oauth2/authorize?client_id=4c28b0d1-d0b2-406d-a8d2-77dd007c7fa4&redirect_uri=https%3a%2f%2fportal.informa.com%2f&response_type=code+id_token&scope=openid+profile+email&state=OpenIdConnect.AuthenticationProperties%3dpQjIGTZq0D-XXWpN7avDNIZ9y55vKbP0LCjHle-VTY_Cuwy9Wi964LS6gFTy_e24ttV5dY8WYLS_f9mzpObjJmllK8tVJE7PgVuHtSmzFQnB4unhqnXV_Y6x1INYM8yBGCy7OiV3j-9YNmW0GZBxNq9mHmMobtW6G9TBUSMXumUkZjjhGpJ2To1UxxX-NRYLS1Z6gGZfwTgUFZNpXJ4Cw0ZbKpI6AcR2abVO3OxjmhmkSClzcyz9_bEFyP5tA19S0gUQYeRH3UWcUNucJF7s1KMrjD7LGvJzZa9XctgukFNNEWLC57I7As1nDkWx_ZY6m0LUfkEFrMdmZoSIlKxx12HO6LBvgvZE7fKUQS_teS4&response_mode=form_post&nonce=638938694539256457.YjY0MWNiMjAtNjMzYy00YjAxLWE2YjMtZTBjNjU0MGFkMDk3NWZmNWIyMWMtMTg4Ni00ZmRhLWFiNmQtMTkwYjg4NTZhNjYw&domain_hint=informa.com&x-client-SKU=ID_NET472&x-client-ver=7.5.1.0&sso_reload=true&sso_nonce=AwABEgEAAAADAOz_BQD0_2bVXaQyHQR5J-BOXoDUWdYtXuF3zeYOA6IRPT6KqXHpILHLk-BqjStIdIhhRKMhbOY1WdrxxSJU_KMseSGiVLUgAA&client-request-id=22e75bc1-c8bc-44b4-a461-a544599ceb3e&mscrid=22e75bc1-c8bc-44b4-a461-a544599ceb3e');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
  bool _showFeedback = false;

  void _toggleFeedback() {
    setState(() {
      _showFeedback = !_showFeedback;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = widget.isGenerating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AssetConsts.elysiaBrainSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGenerating
                      ? "Elyria is creating response for you..."
                      : "Elysia’s response",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isGenerating ? FontWeight.w400 : FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isGenerating)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: CustomMarkdownRenderer(data: widget.message.content),
          ),

        if (!isGenerating)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomIconButton(
                  icon: Icons.info_outline,
                  svgColor: Colors.grey,
                  toolTip: 'Info',
                  onPressed: () {},
                  isDense: true,
                ),
                CustomIconButton(
                  icon: Icons.thumb_up_alt_outlined,
                  svgColor: Colors.grey,
                  toolTip: 'Like',
                  onPressed: _toggleFeedback,
                  isDense: true,
                  iconSize: 18,
                ),
                CustomIconButton(
                  icon: Icons.thumb_down_alt_outlined,
                  svgColor: Colors.grey,
                  toolTip: 'Dislike',
                  onPressed: _toggleFeedback,
                  isDense: true,
                  iconSize: 18,
                ),
                CustomIconButton(
                  icon: Icons.copy,
                  svgColor: Colors.grey,
                  toolTip: 'Copy',
                  onPressed: _copyToClipboard,
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),

        if (!isGenerating)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                const TextSpan(
                  text:
                  'Elysia responses may be inaccurate. Know more about how your data is processed ',
                ),
                TextSpan(
                  text: 'here',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 30, right: 30, bottom: 12),
          //   child: Text(
          //     "Elysia responses may be inaccurate. Know more about how your data is processed here",
          //     style: const TextStyle(
          //       fontSize: 12,
          //       color: Colors.grey,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),

        /// Feedback Card (if toggled)
        if (_showFeedback)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ShowFeedbackCard(
              onClose: () {
                setState(() {
                  _showFeedback = false;
                });
              },
            ),
          ),
      ],
    );
  }
}
