import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

class Glitch extends StatefulWidget {
  final Widget child;

  final bool useDistortion;

  final bool useFlicker;

  final bool useRotation;

  final int delay;

  Glitch({
    Key key,
    this.useDistortion = true,
    this.useFlicker = true,
    this.useRotation = true,
    this.delay = 0,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => GlitchState();
}

class GlitchState extends State<Glitch> with SingleTickerProviderStateMixin {
  static const int defaultDuration = 400;

  AnimationController animation;

  bool _distort = false;

  bool _hide = true;

  bool _finished = false;

  double _rotation = 0.0;

  Matrix4 _perspective = _pmat(20);

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;

    if (animation.status == AnimationStatus.dismissed) {
      return Opacity(
        opacity: 0.0,
        child: widget.child,
      );
    }

    Widget result = widget.child;

    if (widget.useFlicker && _hide) {
      result = Opacity(opacity: 0.6, child: result);
    }

    final transform = !widget.useRotation
        ? Matrix4.identity()
        : _perspective
            .multiplied(Matrix4.rotationX(_rotation))
            .multiplied(Matrix4.rotationY(_rotation / 4));

    if (widget.useDistortion && _distort) {
      transform.multiply(Matrix4.skewX(-0.1));
      transform.multiply(Matrix4.translationValues(5.0, 0.0, 0.0));
    }

    result = Transform(
      transform: transform,
      child: result,
    );

    // result = new ClipPath(
    //    clipper: new _GlitchPathClipper(animation.value), child: result);

    return result;
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
    animation = AnimationController(
      duration: const Duration(milliseconds: defaultDuration),
      vsync: this,
    );
    animation.addListener(_animationTick);
    Timer(Duration(milliseconds: widget.delay), () {
      if (animation.status == AnimationStatus.completed) return;
      animation.forward();
    });
  }

  void _animationTick() {
    if (!this.mounted) return;
    if (animation.status == AnimationStatus.completed) {
      setState(() {
        _distort = false;
        _hide = false;
        _finished = true;
      });

      return;
    }
    // Which fraction of the complete [duration] to use for distortion
    // and flicker.
    const fraction = 2;
    setState(() {
      // on - off - on - on - off - on
      if (animation.value > 1 / fraction) {
        _hide = false;
      } else {
        int phase = (animation.value * fraction * 5).floor();
        switch (phase) {
          case 0:
            _hide = false;
            break;
          case 1:
            _hide = true;
            break;
          case 2:
          case 3:
            _hide = false;
            _distort = true;
            break;
          case 4:
            _distort = false;
            _hide = true;
        }
      }
      _rotation = Curves.easeIn.transform(1 - animation.value) * pi / 4;
    });
  }

  /// Creates perspective matrix.
  ///
  /// http://web.iitd.ac.in/~hegde/cad/lecture/L9_persproj.pdf
  static Matrix4 _pmat(int pv) {
    return Matrix4(
      1.0, 0.0, 0.0, 0.0, //
      0.0, 1.0, 0.0, 0.0, //
      0.0, 0.0, 1.0, pv * 0.0001, //
      0.0, 0.0, 0.0, 1.0,
    );
  }
}

class _GlitchPathClipper extends CustomClipper<Path> {
  final double progress;

  _GlitchPathClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final invProgress = 1 - progress;
    const maxWidthClip = 0.3;
    const maxHeightClip = 0.4;
    path.addRect(Rect.fromLTWH(
      invProgress * maxWidthClip * size.width,
      invProgress * maxHeightClip * size.height,
      size.width - (invProgress * maxWidthClip * 2),
      size.height - (invProgress * maxHeightClip * 2),
    ));
    return path;
  }

  @override
  bool shouldReclip(_GlitchPathClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
