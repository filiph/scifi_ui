import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:scifi_ui/progress_border.dart';

class AnimatedBorderContainer extends StatefulWidget {
  final Widget child;

  final Color borderColor;

  final EdgeInsetsGeometry padding;

  /// How long to wait before starting the animation. Time is in milliseconds.
  final int delay;

  final int duration;

  AnimatedBorderContainer({
    Key key,
    this.borderColor = const Color(0xFFFF000000),
    this.padding = EdgeInsets.zero,
    this.delay = 0,
    this.duration = 1000,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AnimatedBorderContainerState();
}

class AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  AnimationController animation;

  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration:
          ProgressBorder(color: widget.borderColor, progress: _progress),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    animation.stop();
    animation.removeListener(_animationTick);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    animation.addListener(_animationTick);
    Timer(Duration(milliseconds: widget.delay), () {
      if (animation.status == AnimationStatus.completed) return;
      animation.forward();
    });
  }

  void _animationTick() {
    setState(() {
      _progress = Curves.easeOut.transform(animation.value);
    });
  }
}
