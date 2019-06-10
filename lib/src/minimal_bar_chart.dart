import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:scifi_ui/src/staggered_director.dart';

class MinimalBarChart extends StatefulWidget {
  final int duration;

  MinimalBarChart({
    Key key,
    this.duration = 1000,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MinimalBarChartState();
}

class MinimalBarChartState extends State<MinimalBarChart>
    with SingleTickerProviderStateMixin {
  AnimationController animation;

  double _progress = 0.0;

  List<int> values;

  static const barCount = 20;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(200.0, 100.0),
      painter: BarChartPainter(values, _progress),
    );
  }

  @override
  void dispose() {
    animation.stop();
    animation.removeListener(_animationTick);
    super.dispose();
  }

  static final _random = Random();

  @override
  void initState() {
    super.initState();
    values = List<int>.generate(
        barCount, (index) => index * 5 + _random.nextInt(10));
    animation = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    animation.addListener(_animationTick);
    StaggeredDirector.singleton.register(() {
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

class BarChartPainter extends CustomPainter {
  static const int barWidth = 10;
  static const int barPadding = 5;
  static const int chartPadding = 5;

  final List<int> values;

  final double progress;

  BarChartPainter(this.values, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()..style = PaintingStyle.stroke;
    int count = values.length;
    int maxValue = values.fold(0, max);
    int minValue = values.fold(0, min);
    int width = (size.width - 2 * chartPadding).round();
    int height = (size.height - 2 * chartPadding).round();
    assert(maxValue > minValue);
    double ratio = height / (maxValue - minValue);
    for (int i = 0; i < count; i++) {
      if (progress < i / count) return;
      double leftOffset = chartPadding + (width / count * i);
      double currentProgress = (progress * count - i).clamp(0.0, 1.0);
      double currentValue = values[i] * currentProgress;
      double topOffset = chartPadding + ((maxValue - currentValue) * ratio);
      // canvas.drawLine(new Offset(leftOffset, topOffset),
      //    new Offset(leftOffset + barWidth, topOffset), paint);
      canvas.drawRect(
          Rect.fromLTRB(leftOffset, topOffset, leftOffset + barWidth,
              (chartPadding + height).toDouble()),
          paint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
