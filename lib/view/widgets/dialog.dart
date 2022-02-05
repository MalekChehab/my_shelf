import 'package:flutter/material.dart';
import 'book_text_form_field.dart';

class MyDialog extends StatelessWidget {
  final String? title;
  final Widget? textField1, textField2;
  final String buttonLabel;
  final String? text;
  final void Function() onPressed;
  final double? dialogHeight;
  late double _height;

  MyDialog({
    required this.buttonLabel,
      required this.onPressed,
      this.title,
      this.dialogHeight,
      this.text,
      this.textField1,
      this.textField2,
        Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title ?? '',
        style: Theme.of(context).textTheme.subtitle2,
      ),
      content: SizedBox(
        height: dialogHeight?? _height / 5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              text != null ? Center(child: Text(text.toString())) : SizedBox(),
              text != null ? SizedBox(height: _height / 50) : SizedBox(),
              const SizedBox(
                height: 2,
              ),
              showTexField(context, textField1),
              showTexField(context, textField2),
              SizedBox(
                height: textField1 != null && textField2 != null ? _height / 40 : 0,
              ),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: MyButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: MyButton(
                          onPressed: onPressed, child: Text(buttonLabel)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showTexField(BuildContext context, Widget? textField) {
    if (textField != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10),
              height: 55,
              child: textField,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }
}
