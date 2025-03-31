import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrductTile extends StatefulWidget {
  final ProductModel product;
  final VoidCallback updateIsBuy;
  const PrductTile(
      {super.key, required this.product, required this.updateIsBuy});

  @override
  State<PrductTile> createState() => _PrductTileState();
}

class _PrductTileState extends State<PrductTile> {
  bool isExanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onLongPress: () {
              setState(() {
                isExanded = !isExanded;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: widget.product.isBuy,
                        onChanged: (bool? value) => widget.updateIsBuy(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: widget.product.priority == 'Low'
                                        ? Colors.green
                                        : widget.product.priority == 'Medium'
                                            ? Colors.yellow
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(1000)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              AutoSizeText(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AutoSizeText(
                                widget.product.producent ?? "-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const Text(
                                "/",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              AutoSizeText(
                                widget.product.shop ?? "-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  AutoSizeText(
                    "${widget.product.amount}${widget.product.unit}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExanded)
            const Column(
              children: [
                Text('aditional text'),
              ],
            )
        ],
      ),
    );
  }
}
