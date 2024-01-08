import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';

class CounterLike extends StatelessWidget {
  final int _qty;
  const CounterLike({
    super.key,
    required int qty,
  }) : _qty = qty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Text(
        '$_qty Likes',
        style: headerStyle(level: 5),
      ),
    );
  }
}
