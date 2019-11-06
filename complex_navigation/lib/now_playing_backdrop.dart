import 'dart:math' as math;

import 'package:flutter/material.dart';

const kTitleHeight = 60.0;

typedef NowPlayingBackdropContentBuilder = Widget Function(
  BuildContext context,
  double slideOffset,
  BackdropController controller,
);

class NowPlayingBackdrop extends StatefulWidget {
  final NowPlayingBackdropContentBuilder contentBuilder;
  final Widget background;

  final Function(AnimationController controller) slideDelegate;
  final double barTitleHeight;
  final BackdropController backdropController;
  final Duration animationDuration;
  final Size backgroundSize;

  const NowPlayingBackdrop({
    @required this.contentBuilder,
    @required this.background,
    this.slideDelegate,
    this.barTitleHeight = kTitleHeight,
    this.backdropController,
    this.animationDuration,
    this.backgroundSize,
  })  : assert(contentBuilder != null),
        assert(background != null);

  @override
  State<StatefulWidget> createState() => BackdropState();
}

class BackdropState extends State<NowPlayingBackdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');

  AnimationController _animationController;
  BackdropController _backdropController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );
    _backdropController = widget.backdropController != null
        ? widget.backdropController
        : BackdropController();
    _backdropController.animationController = _animationController;
    _backdropController.backdropKey = _backdropKey;

    if (widget.slideDelegate != null) {
      _animationController.addListener(() {
        widget.slideDelegate(_animationController);
      });
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _backdropController?.dispose();
    super.dispose();
    _animationController = null;
    _backdropController = null;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildLayout);

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    final Size panelSize = constraints.biggest;
    final double panelTop = panelSize.height -
        widget.barTitleHeight -
        MediaQuery.of(context).padding.bottom;

    var begin =
        RelativeRect.fromLTRB(0.0, panelTop, 0.0, panelTop - panelSize.height);
    var end = RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    print("begin $begin");
    print("end $end");
    Animation<RelativeRect> panelAnimation =
        RelativeRectTween(begin: begin, end: end)
            .animate(_backdropController.view);

    return Container(
      key: _backdropKey,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: widget.backgroundSize != null
                ? SizedBox.fromSize(
                    child: widget.background,
                    size: widget.backgroundSize,
                  )
                : widget.background,
          ),
          _backdropController.value > 0
              ? Opacity(
                  opacity: _animationController.value,
                  child: Container(
                      color: Color(0xbf4b5161),
                      child: SizedBox.expand(child: Container())),
                )
              : Center(),
          PositionedTransition(
            rect: panelAnimation,
            child: widget.contentBuilder(
                context, _backdropController.value, _backdropController),
          ),
        ],
      ),
    );
  }
}

const double _kFlingVelocity = 2.0;

class BackdropController {
  AnimationController animationController;
  GlobalKey backdropKey;
  bool dragEnabled = true;
  Function(AnimationController controller) slideDelegate;

  BackdropController({this.slideDelegate}) {
    if (slideDelegate != null) {
      animationController.addListener(() => slideDelegate(animationController));
    }
  }

  double get value => animationController.value;

  Animation<double> get view => animationController.view;

  bool handleBackPop() {
    var isClosed = value == 0;
    if (!isClosed) {
      updateBackdropVisibility();
    }
    return !isClosed;
  }

  bool get _backdropPanelVisible {
    final AnimationStatus status = animationController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  double get _backdropHeight {
    final RenderBox renderBox = backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  dispose() {
//    animationController.dispose();
  }

  void updateBackdropVisibility() {
    animationController.fling(
        velocity: _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (animationController.isAnimating) return;
    if (dragEnabled == false) return;

    animationController.value -= details.primaryDelta / _backdropHeight;
  }

  void handleDragEnd(DragEndDetails details) {
    if (animationController.isAnimating) return;
    if (dragEnabled == false) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0) {
      animationController.fling(
          velocity: math.max(_kFlingVelocity, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      animationController.fling(
          velocity: math.min(-_kFlingVelocity, -flingVelocity));
    } else {
      animationController.fling(
          velocity: animationController.value < 0.5
              ? -_kFlingVelocity
              : _kFlingVelocity);
    }
  }
}
