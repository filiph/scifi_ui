import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:scifi_ui/staggered_director.dart';

final Random _random = Random();

String interpolate(String from, String to, num progress) {
  assert(progress >= 0 && progress <= 1);
  if (progress <= 0) return from;
  if (progress >= 1) return to;

  List<int> fromRunes = from.runes.toList(growable: false);
  int fromLength = fromRunes.length;
  List<int> toRunes = to.runes.toList(growable: false);
  int toLength = toRunes.length;

  int length = fromLength + ((toLength - fromLength) * progress).toInt();

  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    int char;
    if (_random.nextDouble() > progress) {
      char = fromRunes[(i / length * fromLength).floor()];
    } else {
      char = toRunes[(i / length * toLength).floor()];
    }
    buffer.writeCharCode(char);
  }

  return buffer.toString();
}

class GlitchText extends StatefulWidget {
  final String data;

  GlitchText(
    this.data, {
    Key key,
    this.style,
  }) : super(key: key);

  final TextStyle style;

  @override
  GlitchTextState createState() => GlitchTextState();
}

class GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  AnimationController animation;

  String _text = "";

  String _initialText = "";

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      _text,
      style: widget.style,
    );
    return textWidget;
  }

  @override
  void dispose() {
    animation.removeListener(_animationTick);
    animation.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialText =
        String.fromCharCodes(Iterable.generate(widget.data.length ~/ 2, (_) {
      if (_random.nextDouble() < 0.2) return 32 /* space */;
      return 65 + _random.nextInt(125 - 65);
    }));
    animation = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    animation.addListener(_animationTick);
    StaggeredDirector.singleton.register(() {
      if (animation.status == AnimationStatus.completed) return;
      animation.forward();
    });
  }

  void _animationTick() {
    if (animation.status == AnimationStatus.completed) {
      setState(() {
        _text = widget.data;
      });
      return;
    }
    final newText = interpolate(_initialText, widget.data, animation.value);
    setState(() {
      _text = newText;
    });
  }
}
