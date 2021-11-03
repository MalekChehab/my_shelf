import 'package:flutter/material.dart';
import 'package:my_library/Widgets/responsive_ui.dart';

class ConfirmButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const ConfirmButton({Key? key,
    required this.text,
    required this.onPressed,
    this.height = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child:FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: Theme.of(context).buttonColor,
        textColor: Colors.white.withOpacity(0.9),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18.0,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
