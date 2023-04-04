import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  Color primaryColor, beginColor, endColor;
  String label;
  IconData icon;
  Duration duration;
  bool secureText;
  AnimatedTextField(
      {Key? key,
      required this.primaryColor,
      required this.beginColor,
      required this.endColor,
      required this.label,
      required this.icon,
      required this.duration,
      required this.secureText})
      : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _scaleAnimation;
  late Animation _colorAnimation;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _colorAnimation = ColorTween(begin: widget.beginColor, end: widget.endColor)
        .animate(_animationController);

    _focusNode.addListener(_onTextFieldFocusChange);

    _animationController.addListener(() {
      setState(() {});
    });
  }

  void _onTextFieldFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 50,
      child: Stack(
        children: [
          LayoutBuilder(builder: (_, constraints) {
            return Transform.scale(
              scaleX: _scaleAnimation.value,
              origin: Offset(constraints.maxWidth / 2, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
          TextField(
            focusNode: _focusNode,
            obscureText: widget.secureText,
            decoration: InputDecoration(
              label: Text(
                widget.label,
                style: TextStyle(color: _colorAnimation.value),
              ),
              border: InputBorder.none,
              focusedBorder: const OutlineInputBorder(),
              prefixIcon: Icon(
                widget.icon,
                color: _colorAnimation.value,
              ),
            ),
          )
        ],
      ),
    );
  }
}
