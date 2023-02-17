import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AnimatedEmoji extends StatefulWidget {
  final String iconTitle;
  const AnimatedEmoji({super.key, required this.iconTitle});

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _animationFloatUp;

  late double _emojiHeight;
  late double _emojiWidth;
  late double _emojiBottomLocation;
  bool isDisapear = false;

  @override
  void initState() {
    _aniController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    // _animationFloatUp = _animationFloatUp =
    //     Tween(begin: _emojiBottomLocation, end: 0.0).animate(CurvedAnimation(
    //         parent: _aniController,
    //         curve: Interval(0.0, 1.0, curve: Curves.fastOutSlowIn)));
    // _emojiHeight = device;
    // _emojiWidth = 30;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final deviceSize = MediaQuery.of(context).size;

    _emojiHeight = deviceSize.height / 2;
    _emojiWidth = deviceSize.width / 3;
    _emojiBottomLocation = deviceSize.height - 100;

    _animationFloatUp = Tween(begin: _emojiBottomLocation, end: 0.0).animate(
        CurvedAnimation(
            parent: _aniController,
            curve: Interval(0.0, 1.0, curve: Curves.fastOutSlowIn)));
    if (!_aniController.isCompleted) {
      print('kkkk');
      _aniController.forward();
    }

    // _aniController.reset();
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationFloatUp,
        builder: (context, child) {
          return Container(
            child: child,
            margin: EdgeInsets.only(top: _animationFloatUp.value),
          );
        },
        child: StatefulBuilder(builder: (context, setState) {
          if (isDisapear) {
            return Container();
          } else {
            return GestureDetector(
                onTap: () {
                  if (_aniController.isCompleted) {
                    _aniController.reverse();
                  } else {
                    _aniController.forward();
                  }
                },
                child: isDisapear
                    ? Container()
                    : Image.asset(
                        "assets/images/${widget.iconTitle}",
                        height: _emojiHeight * 0.3,
                        width: _emojiWidth,
                      ));
          }
        }));
  }
}
