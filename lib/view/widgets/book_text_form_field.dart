import 'package:flutter/material.dart';
import 'package:my_library/controllers/responsive_ui.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hint;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final IconData? icon;
  final FormFieldValidator? validator;
  final TextCapitalization? capitalization;
  final Function(String)? onChanged;
  final TextStyle? hintStyle;
  final Widget? suffix;
  final bool? enabled;
  final bool? readOnly;
  final TextInputAction? textInputAction;

  const CustomTextFormField(
      {Key? key,
        this.hint,
        this.textEditingController,
        this.keyboardType,
        this.icon,
        this.validator,
        this.capitalization,
        this.onChanged,
        this.hintStyle,
        this.suffix,
        this.enabled,
        this.readOnly,
        this.textInputAction,
      }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large =  ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium=  ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      color: Theme.of(context).backgroundColor,
      borderRadius: BorderRadius.circular(30.0),
      elevation: _large? 12 : (_medium? 10 : 8),
      child: TextFormField(
        onChanged: widget.onChanged,
        readOnly: widget.readOnly??false,
        enabled: widget.enabled,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.capitalization ?? TextCapitalization.none,
        style: Theme.of(context).textTheme.subtitle2,
        validator: widget.validator,
        controller: widget.textEditingController,
        keyboardType: widget.keyboardType,
        cursorColor: Theme.of(context).iconTheme.color,
        decoration: InputDecoration(
          prefixIcon: Icon(
              widget.icon,
              color: Theme.of(context).iconTheme.color,
              size: 20,
            ),
          suffixIcon: widget.suffix,
          hintText: widget.hint,
          hintStyle: widget.hintStyle,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget{
  final String? hint;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon;
  final FormFieldValidator? validator;
  final TextStyle? hintStyle;

  PasswordTextField(
      {this.hint,
        this.textEditingController,
        this.keyboardType,
        this.icon,
        this.validator,
        this.hintStyle,
        this.obscureText= true,
      });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  late bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large =  ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium=  ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      color: Theme.of(context).backgroundColor,
      borderRadius: BorderRadius.circular(30.0),
      elevation: _large? 12 : (_medium? 10 : 8),
      child: TextFormField(
        style: TextStyle(color: Theme.of(context).accentColor),
        obscureText: _obscureText,
        validator: widget.validator,
        enableSuggestions: false,
        autocorrect: false,
        controller: widget.textEditingController,
        keyboardType: widget.keyboardType,
        // cursorColor: Colors.red[500],
        decoration: InputDecoration(
          prefixIcon: Icon(
              widget.icon,
              color: Theme.of(context).iconTheme.color,
              size: 18
          ),
          hintText: widget.hint,
          hintStyle: widget.hintStyle,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).accentColor,
              size: 22,
            ),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatefulWidget{
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const MyButton({Key? key,
    required this.onPressed,
    required this.child,
    this.color,
    this.elevation,
    this.shape,}) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        color: widget.color,
        child: widget.child,
        elevation: widget.elevation,
        shape: widget.shape
            ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        )
        ,
        textColor: Theme.of(context).accentColor,
        padding: const EdgeInsets.all(2.0),
        onPressed: widget.onPressed,
      ),
    );
  }
}