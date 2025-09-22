import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CustomMarkdownRenderer extends StatelessWidget {
  final String data;

  const CustomMarkdownRenderer({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      styleSheet: MarkdownStyleSheet(
        // Remove default padding/margins
        p: TextStyle(
          fontSize: 16,
          height: 1.4,
        ).copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),

        // Headers
        h1: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ).copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),

        h2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ).copyWith(color: Theme.of(context).textTheme.headlineMedium?.color),

        h3: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ).copyWith(color: Theme.of(context).textTheme.headlineSmall?.color),

        h4: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ).copyWith(color: Theme.of(context).textTheme.titleMedium?.color),

        // Code styling
        code: TextStyle(
          backgroundColor: Colors.grey.shade800,
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 14,
        ),

        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade700),
        ),

        codeblockPadding: const EdgeInsets.all(12),

        // Table styling
        tableHead: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ).copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),

        tableBody: TextStyle(
          fontSize: 14,
        ).copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),

        tableBorder: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),

        tableHeadAlign: TextAlign.left,
        tableColumnWidth: const FlexColumnWidth(),

        // Reduce spacing
        h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
        h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
        h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
        h4Padding: const EdgeInsets.only(top: 10, bottom: 4),
        h5Padding: const EdgeInsets.only(top: 8, bottom: 4),
        h6Padding: const EdgeInsets.only(top: 8, bottom: 4),

        pPadding: const EdgeInsets.only(bottom: 8),
        blockquotePadding: const EdgeInsets.all(8),

        // List styling
        listIndent: 16,
        listBullet: TextStyle(
          fontSize: 14,
        ).copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),

        // Remove excessive margins
        blockSpacing: 8.0,
      ),

      // Custom builders for better control
      builders: {
        'table': CustomTableBuilder(),
      },
    );
  }
}

// Custom table builder for better styling control
class CustomTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'table') return null;

    List<TableRow> rows = [];

    for (var child in element.children ?? []) {
      if (child.tag == 'thead' || child.tag == 'tbody') {
        for (var row in child.children ?? []) {
          if (row.tag == 'tr') {
            List<Widget> cells = [];

            for (var cell in row.children ?? []) {
              bool isHeader = cell.tag == 'th';

              cells.add(
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHeader ? Colors.grey.shade100 : Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    cell.textContent,
                    style: TextStyle(
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            rows.add(TableRow(children: cells));
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: rows,
      ),
    );
  }
}

// Alternative simpler version without custom table builder
class SimpleMarkdownRenderer extends StatelessWidget {
  final String data;

  const SimpleMarkdownRenderer({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        // Reduce spacing
        blockSpacing: 6.0,
        h1Padding: const EdgeInsets.only(top: 12, bottom: 6),
        h2Padding: const EdgeInsets.only(top: 10, bottom: 4),
        h3Padding: const EdgeInsets.only(top: 8, bottom: 4),
        pPadding: const EdgeInsets.only(bottom: 6),

        // Table styling
        tableBorder: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        tableHead: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}