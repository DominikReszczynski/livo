import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/providers/expanses_provider.dart';
import 'package:cas_house/sections/expenses/add_new_expanses_popup.dart';
import 'package:cas_house/sections/expenses/expanses_global.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpenseTile extends StatefulWidget {
  final ExpansesProvider provider;
  final Expanses expanse;
  const ExpenseTile({super.key, required this.expanse, required this.provider});

  @override
  _ExpenseTileState createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  String _getTruncatedText(
      BuildContext context, String text, double maxWidth, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines) {
      String truncatedText = text;
      while (truncatedText.isNotEmpty && textPainter.didExceedMaxLines) {
        truncatedText = truncatedText.substring(0, truncatedText.length - 1);
        textPainter.text = TextSpan(text: '$truncatedText...', style: style);
        textPainter.layout(maxWidth: maxWidth);
      }
      return '$truncatedText...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final truncatedText = _getTruncatedText(
                          context,
                          widget.expanse.name,
                          constraints.maxWidth * 0.7,
                          textStyle!,
                        );
                        return Text(
                          truncatedText,
                          style: textStyle,
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                          "${widget.expanse.amount} ${widget.expanse.currency}"),
                      Icon(!isExpanded ? MdiIcons.menuDown : MdiIcons.menuUp),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                      children: [
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(getCategoryName(ExpenseCategory.values
                                .firstWhere((e) =>
                                    e.toString() == widget.expanse.category))),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(widget.expanse.description ?? ""),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.provider
                                    .removeExpense(widget.expanse.id!);
                              },
                              icon: Icon(
                                MdiIcons.delete,
                                color: Colors.red[400],
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
