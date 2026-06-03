import 'package:flutter/material.dart';

class RotatingIconButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const RotatingIconButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<RotatingIconButton> createState() => _RotatingIconButtonState();
}

class _RotatingIconButtonState extends State<RotatingIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RotatingIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      icon: RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.autorenew,
          color: widget.isLoading ? Colors.green : null,
        ),
      ),
    );
  }
}