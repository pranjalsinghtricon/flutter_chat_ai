import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';

class CustomMarkdownRenderer extends StatelessWidget {
  final String data;
  const CustomMarkdownRenderer({Key? key, required this.data}) : super(key: key);

  String markdownToHtml(String markdown) {
    return md.markdownToHtml(
      markdown,
      extensionSet: md.ExtensionSet.gitHubFlavored, // supports tables
      inlineSyntaxes: [],
      blockSyntaxes: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final html = markdownToHtml(data);
    return Html(
      data: html,
      style: {
        "h1": Style(fontSize: FontSize.xxLarge, fontWeight: FontWeight.bold),
        "h2": Style(fontSize: FontSize.xLarge, fontWeight: FontWeight.bold),
        "h3": Style(fontSize: FontSize.large, fontWeight: FontWeight.bold),
        "h4": Style(fontSize: FontSize.medium, fontWeight: FontWeight.bold),
        "code": Style(
          backgroundColor: Colors.black,
          color: Colors.white,
          padding: HtmlPaddings.all(8),
          fontFamily: 'monospace',
          fontSize: FontSize.medium,
        ),
        "pre": Style(
          backgroundColor: Colors.black,
          color: Colors.white,
          padding: HtmlPaddings.all(8),
          fontFamily: 'monospace',
          fontSize: FontSize.medium,
          border: Border.all(color: Colors.black54, width: 1),
        ),
        "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        "p": Style(margin: Margins.only(bottom: 8)),

        "table": Style(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          margin: Margins.symmetric(vertical: 12),
        ),
        "th": Style(
          padding: HtmlPaddings.all(8),
          backgroundColor: Colors.grey.shade200,
          fontWeight: FontWeight.bold,
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        "td": Style(
          padding: HtmlPaddings.all(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        "tr": Style(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
      },
    );
  }
}
