import 'package:flutter/material.dart';

class ButtonLike extends StatelessWidget {
  final void Function()? onPressed;
  const ButtonLike({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.favorite),
        label: Text('Like'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
