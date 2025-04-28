import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter_slider_drawer/src/core/animation/animation_strategy.dart';
import 'package:flutter_slider_drawer/src/core/animation/slider_drawer_controller.dart';
import 'package:flutter_slider_drawer/src/core/appbar/slider_app_bar.dart';

import 'package:flutter_slider_drawer/src/slider_shadow.dart';
import 'package:flutter_slider_drawer/src/slider_bar.dart';

/// SliderDrawer which have two [child] and [slider] parameter
///
///For Example :
///
///SliderDrawer(
///         key: _sliderDrawerKey,
///         appBar: SliderAppBar(
///           config: SliderAppBarConfig(
///               title: Text(
///             title,
///             textAlign: TextAlign.center,
///             style: const TextStyle(
///               fontSize: 22,
///               fontWeight: FontWeight.w700,
///             ),
///           )),
///         ),
///         sliderOpenSize: 179,
///         slider: SliderMenu(),
///         child: const AuthorList(),
///       )
///
///
///
class SliderDrawer extends StatefulWidget {
  /// [Widget] which display when user open drawer
  ///
  final Widget? slider;

  /// [Widget] main screen widget
  ///
  final Widget child;

  /// [int] animation duration for the drawer's open/close action in milliseconds.
  /// parameter
  ///
  final int animationDuration;

  /// The width of the open drawer.
  ///
  // final double sliderOpenSize;

  ///[double] The percentage of the screen width that the drawer should occupy
  final double sliderOpenPercent;

  ///[double]  The width of the closed drawer. Default is 0.
  final double sliderCloseSize;

  ///[bool] if you set [false] then swipe to open feature disable.
  ///By Default it's true
  ///
  final bool isDraggable;

  ///[appBar] if you set [null] then it will not display app bar
  ///
  final Widget? appBar;

  ///[SliderBoxShadow] you can enable shadow of [child] Widget by this parameter
  final SliderBoxShadow? sliderBoxShadow;

  ///[slideDirection] you can change slide direction by this parameter [slideDirection]
  ///There are three type of [SlideDirection]
  ///[SlideDirection.rightToLeft]
  ///[SlideDirection.leftToRight]
  ///[SlideDirection.topToBottom]
  ///
  /// By default it's [SlideDirection.rightToLeft], others not supported for now.
  ///
  final SlideDirection slideDirection = SlideDirection.rightToLeft;

  /// The color of the [Material] widget that underlies the entire Scaffold.
  ///
  /// The theme's [ThemeData.scaffoldBackgroundColor] by default.
  final Color? backgroundColor;

  ///[sliderItems] if you want to add any widget in slider menu then use this parameter
  /// it's optional
  final List<Widget>? sliderItems;

  ///[sliderTrailingItem] if you want to add any widget in slider menu then use this parameter
  /// it's optional
  ///

  final Widget? sliderTrailingItem;

  const SliderDrawer(
      {Key? key,
      this.slider,
      required this.child,
      this.sliderItems,
      this.sliderTrailingItem,
      this.isDraggable = true,
      this.animationDuration = 400,
      this.sliderCloseSize = 0,
      this.sliderBoxShadow,
      this.sliderOpenPercent = 75,
      this.appBar,
      this.backgroundColor})
      : super(key: key);

  @override
  SliderDrawerState createState() => SliderDrawerState();
}

class SliderDrawerState extends State<SliderDrawer>
    with TickerProviderStateMixin {
  late final SliderDrawerController _controller;
  late final Animation<double> _animation;
  Function(AnimationStatus status)? onAnimation;

  late final AnimationStrategy _animationStrategy;

  /// check whether drawer is open
  bool get isDrawerOpen => _controller.animationController.isCompleted;

  /// it's provide [animationController] for handle and lister drawer animation
  AnimationController get animationController =>
      _controller.animationController;

  /// Toggle drawer
  void toggle() => _controller.toggle();

  /// Open slider
  void openSlider() => _controller.openSlider();

  /// Close slider
  void closeSlider() => _controller.closeSlider();

  Color startColor = Colors.transparent;
  Color endColor = Colors.black.withAlpha(38);

  late Animation<double> _alphaAnimation;

  late Animation<double> _positionAnimation;
  late Animation<double> _itemEntryAlphaAnimation;

  bool drawerEnabled = true;

  void setDrawerEnabled(bool value) {
    setState(() {
      drawerEnabled = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = SliderDrawerController(
      vsync: this,
      animationDuration: widget.animationDuration,
      slideDirection: widget.slideDirection,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.sliderOpenPercent,
    ).animate(CurvedAnimation(
      parent: _controller.animationController,
      curve: Curves.decelerate,
      reverseCurve: Curves.decelerate,
    ));

    _animationStrategy = SliderAnimationStrategy();

    _alphaAnimation = Tween<double>(begin: 0, end: 0.15)
        .animate(_controller.animationController);

    _positionAnimation = Tween<double>(
      begin: 0,
      end: 44.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );
    _itemEntryAlphaAnimation =
        Tween<double>(begin: 0, end: 1).animate(animationController);

    _controller.addListener(() {
      onAnimation?.call(_controller.animationController.status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (widget.slider != null) ...{
              AnimatedBuilder(
                animation: _controller.animationController,
                builder: (context, child) {
                  final offset = _animationStrategy.getOffset(
                    widget.slideDirection,
                    _animation.value,
                  );

                  return Transform.translate(
                    offset: Offset(constraints.maxWidth + offset.dx, offset.dy),
                    child: child,
                  );
                },
                child: SliderBar(
                  slideDirection: widget.slideDirection,
                  sliderMenu: widget.slider!,
                  sliderMenuOpenSize:
                      _animation.value * MediaQuery.sizeOf(context).width / 100,
                ),
              ),
            } else if (widget.sliderItems != null) ...{
              AnimatedBuilder(
                animation: _controller.animationController,
                builder: (context, child) {
                  final offset = _animationStrategy.getOffset(
                    widget.slideDirection,
                    _animation.value * MediaQuery.sizeOf(context).width / 100,
                  );

                  return Transform.translate(
                    offset: Offset(constraints.maxWidth + offset.dx, offset.dy),
                    child: SliderBar(
                      slideDirection: widget.slideDirection,
                      sliderMenuOpenSize: MediaQuery.sizeOf(context).width *
                          widget.sliderOpenPercent /
                          100,
                      sliderMenu: Stack(
                        children: [
                          for (var index = 0;
                              index < widget.sliderItems!.length;
                              index++) ...{
                            Positioned(
                              top: 0 + _positionAnimation.value * index,
                              left: 0,
                              right: 0,
                              child: Opacity(
                                opacity: _itemEntryAlphaAnimation.value,
                                child: widget.sliderItems![index],
                              ),
                            ),
                          },
                          if (widget.sliderTrailingItem != null) ...{
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: widget.sliderTrailingItem!,
                            ),
                          }
                        ],
                      ),
                    ),
                  );
                },
              ),
            },

            /// Shadow Shadow
            if (widget.sliderBoxShadow != null)
              SliderShadow(
                animationDrawerController: _controller.animationController,
                slideDirection: widget.slideDirection,
                sliderOpenSize:
                    _animation.value * MediaQuery.sizeOf(context).width / 100,
                animation: _animation,
                sliderBoxShadow: widget.sliderBoxShadow!,
              ),

            AnimatedBuilder(
              animation: _controller.animationController,
              builder: (context, child) {
                final offset = _animationStrategy.getOffset(
                  widget.slideDirection,
                  _animation.value * MediaQuery.sizeOf(context).width / 100,
                );
                return Transform.translate(
                  offset: offset,
                  child: child,
                );
              },
              child: GestureDetector(
                onHorizontalDragStart: widget.isDraggable
                    ? (details) => _handleDragStart(details)
                    : null,
                onHorizontalDragEnd: widget.isDraggable
                    ? (details) => _handleDragEnd(details)
                    : null,
                onHorizontalDragUpdate: widget.isDraggable
                    ? (details) => _handleDragUpdate(details, constraints)
                    : null,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      AppBar(
                        slideDirection: widget.slideDirection,
                        animationDrawerController:
                            _controller.animationController,
                        appBar: widget.appBar,
                        onDrawerTap: _controller.toggle,
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller.animationController,
              builder: (context, child) {
                final offset = _animationStrategy.getOffset(
                  widget.slideDirection,
                  _animation.value * MediaQuery.sizeOf(context).width / 100,
                );

                return Transform.translate(
                  offset: offset,
                  child: IgnorePointer(
                    ignoring: !_controller.isDrawerOpen,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withValues(
                        alpha: _alphaAnimation.value,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (drawerEnabled) ...{
              Positioned(
                right: 16,
                top: 16,
                child: LeadingIcon(
                  onTap: _controller.toggle,
                  animationController: _controller.animationController,
                  config: widget.appBar is SliderAppBar
                      ? (widget.appBar as SliderAppBar).config
                      : const SliderAppBarConfig(),
                ),
              ),
            }
          ],
        );
      },
    );
  }

  void _handleDragStart(DragStartDetails details) {
    if (_animationStrategy.shouldStartDrag(
        details, context, widget.slideDirection)) {
      _controller.startDragging();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _controller.stopDragging();
  }

  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    _animationStrategy.handleDragUpdate(details, constraints, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
