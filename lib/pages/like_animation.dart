import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  const LikeAnimation(
      {Key? key,
      required this.child,
      this.duration = const Duration(milliseconds: 200),
      this.isSmallLikeButton = false,
      required this.isAnimating,
      this.onEnd})
      : super(key: key);
  final Widget child;
  final Duration duration;
  final bool isAnimating;
  final bool isSmallLikeButton;
  final VoidCallback? onEnd; //VoidCallback is a void function

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  //implements TickerProvider which is use to make animation possible

  //animationcontrollor
  late AnimationController _animeController;

  //animation
  late Animation<double> _animationObject;

  @override
  void initState() {
    //instatiate the controller
    _animeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    );

    //crate an animation instants using Tween.animate
    _animationObject =
        Tween<double>(begin: 1, end: 1.2).animate(_animeController);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    //called whenever current widget is replace by another widget

    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }

    super.didUpdateWidget(oldWidget);
  }

  startAnimation() async {
    if (widget.isAnimating || widget.isSmallLikeButton) {
      await _animeController.forward();
      await _animeController.reverse();
      Future.delayed(const Duration(milliseconds: 400));

      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  //dispose the controller
  @override
  void dispose() {
    _animeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animationObject, child: widget.child);
  }
}
