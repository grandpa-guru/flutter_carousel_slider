import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List images;

  final Curve animationCurve;

  final Duration animationDuration;

  final double dotSize;

  final double dotIncreaseSize;

  final double dotSpacing;

  final Color dotColor;

  final Color dotBgColor;

  final bool showIndicator;

  final double indicatorBgPadding;

  final BoxFit boxFit;

  final bool borderRadius;

  final Radius radius;

  final double moveIndicatorFromBottom;

  final bool noRadiusForIndicator;

  final bool overlayShadow;

  final Color overlayShadowColors;

  final double overlayShadowSize;

  final bool autoplay;

  final Duration autoplayDuration;

  final void Function(int) onImageTap;

  final void Function(int, int) onImageChange;

  Carousel(
      {this.images,
      this.animationCurve = Curves.ease,
      this.animationDuration = const Duration(milliseconds: 300),
      this.dotSize = 8.0,
      this.dotSpacing = 25.0,
      this.dotIncreaseSize = 2.0,
      this.dotColor = Colors.white,
      this.dotBgColor,
      this.showIndicator = true,
      this.indicatorBgPadding = 20.0,
      this.boxFit = BoxFit.cover,
      this.borderRadius = false,
      this.radius,
      this.moveIndicatorFromBottom = 0.0,
      this.noRadiusForIndicator = false,
      this.overlayShadow = false,
      this.overlayShadowColors,
      this.overlayShadowSize = 0.5,
      this.autoplay = true,
      this.autoplayDuration = const Duration(seconds: 3),
      this.onImageTap,
      this.onImageChange})
      : assert(images != null),
        assert(animationCurve != null),
        assert(animationDuration != null),
        assert(dotSize != null),
        assert(dotSpacing != null),
        assert(dotIncreaseSize != null),
        assert(dotColor != null);

  @override
  State createState() => new _CarouselState();
}

class _CarouselState extends State<Carousel> {
  Timer timer;
  int _currentImageIndex = 0;
  PageController _controller = new PageController();

  @override
  void initState() {
    super.initState();

    if (widget.autoplay) {
      timer = new Timer.periodic(widget.autoplayDuration, (_) {
        if (_controller.page == widget.images.length - 1) {
          _controller.animateToPage(
            0,
            duration: widget.animationDuration,
            curve: widget.animationCurve,
          );
        } else {
          _controller.nextPage(duration: widget.animationDuration, curve: widget.animationCurve);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listImages = widget.images
        .map<Widget>(
          (netImage) => netImage is ImageProvider
              ? new Container(
                  decoration: new BoxDecoration(
                    borderRadius: widget.borderRadius ? new BorderRadius.all(widget.radius != null ? widget.radius : new Radius.circular(8.0)) : null,
                    image: new DecorationImage(
                      image: netImage,
                      fit: widget.boxFit,
                    ),
                  ),
                  child: widget.overlayShadow
                      ? new Container(
                          decoration: new BoxDecoration(
                            gradient: new LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              stops: [0.0, widget.overlayShadowSize],
                              colors: [widget.overlayShadowColors != null ? widget.overlayShadowColors.withOpacity(1.0) : Colors.grey[800].withOpacity(1.0), widget.overlayShadowColors != null ? widget.overlayShadowColors.withOpacity(0.0) : Colors.grey[800].withOpacity(0.0)],
                            ),
                          ),
                        )
                      : new Container(),
                )
              : netImage,
        )
        .toList();

    return new Stack(
      children: <Widget>[
        new Container(
          child: new Builder(
            builder: (_) {
              Widget pageView = new PageView(
                physics: new AlwaysScrollableScrollPhysics(),
                controller: _controller,
                children: listImages,
                onPageChanged: (currentPage) {
                  if (widget.onImageChange != null) {
                    widget.onImageChange(_currentImageIndex, currentPage);
                  }

                  _currentImageIndex = currentPage;
                },
              );

              if (widget.onImageTap == null) {
                return pageView;
              }

              return new GestureDetector(
                child: pageView,
                onTap: () => widget.onImageTap(_currentImageIndex),
              );
            },
          ),
        ),
        widget.showIndicator
            ? new Positioned(
                bottom: widget.moveIndicatorFromBottom,
                left: 0.0,
                right: 0.0,
                child: new Container(
                  decoration: new BoxDecoration(
                    color: widget.dotBgColor == null ? Colors.grey[800].withOpacity(0.5) : widget.dotBgColor,
                    borderRadius: widget.borderRadius ? (widget.noRadiusForIndicator ? null : new BorderRadius.only(bottomLeft: widget.radius != null ? widget.radius : new Radius.circular(8.0), bottomRight: widget.radius != null ? widget.radius : new Radius.circular(8.0))) : null,
                  ),
                  padding: new EdgeInsets.all(widget.indicatorBgPadding),
                  child: new Center(
                    child: new _DotsIndicator(
                      controller: _controller,
                      itemCount: listImages.length,
                      color: widget.dotColor,
                      dotSize: widget.dotSize,
                      dotSpacing: widget.dotSpacing,
                      dotIncreaseSize: widget.dotIncreaseSize,
                      onPageSelected: (int page) {
                        _controller.animateToPage(
                          page,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                        );
                      },
                    ),
                  ),
                ),
              )
            : new Container(),
      ],
    );
  }
}

class _DotsIndicator extends AnimatedWidget {
  _DotsIndicator({this.controller, this.itemCount, this.onPageSelected, this.color, this.dotSize, this.dotIncreaseSize, this.dotSpacing}) : super(listenable: controller);

  final PageController controller;

  final int itemCount;

  final ValueChanged<int> onPageSelected;

  final Color color;

  final double dotSize;

  final double dotIncreaseSize;

  final double dotSpacing;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (dotIncreaseSize - 1.0) * selectedness;
    return new Container(
      width: dotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize * zoom,
            height: dotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
