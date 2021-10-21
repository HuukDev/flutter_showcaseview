/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:math';

import 'package:flutter/material.dart';

import 'get_position.dart';
import 'measure_size.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final String? description;
  final Animation<double>? animationOffset;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipColor;
  final Color? textColor;
  final bool? showArrow;
  final double? contentHeight;
  final double? contentWidth;
  static late bool isArrowUp;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? contentPadding;
  final double borderRadius;

  ToolTipWidget(
      {this.position,
      this.offset,
      this.screenSize,
      this.title,
      this.description,
      this.animationOffset,
      this.titleTextStyle,
      this.descTextStyle,
      this.container,
      this.tooltipColor,
      this.textColor,
      this.showArrow,
      this.contentHeight,
      this.contentWidth,
      this.onTooltipTap,
      this.borderRadius = 8.0,
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8)});

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  Offset? position;

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    height = widget.contentHeight ?? height;
    return (widget.screenSize!.height - position.dy) <= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  double _getTooltipWidth() {
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .subtitle2!
            .merge(TextStyle(color: widget.textColor));
    final titleLength = widget.title == null
        ? 0
        : _textSize(widget.title!, titleStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    final descriptionLength =
        _textSize(widget.description!, descriptionStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize!.width - 20) {
      return widget.screenSize!.width - 20;
    } else {
      return maxTextWidth + 15;
    }
  }

  bool _isLeft() {
    final screenWidth = widget.screenSize!.width / 3;
    return !(screenWidth <= widget.position!.getCenter());
  }

  bool _isRight() {
    final screenWidth = widget.screenSize!.width / 3;
    return ((screenWidth * 2) <= widget.position!.getCenter());
  }

  double? _getLeft() {
    if (_isLeft()) {
      var leftPadding =
          widget.position!.getCenter() - (_getTooltipWidth() * 0.1);
      if (leftPadding + _getTooltipWidth() > widget.screenSize!.width) {
        leftPadding = (widget.screenSize!.width - 20) - _getTooltipWidth();
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double? _getRight() {
    if (_isRight()) {
      var rightPadding =
          widget.position!.getCenter() + (_getTooltipWidth() / 2);
      if (rightPadding + _getTooltipWidth() > widget.screenSize!.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    ToolTipWidget.isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = ToolTipWidget.isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = ToolTipWidget.isArrowUp ? 22.0 : 0.0;
    var paddingBottom = ToolTipWidget.isArrowUp ? 0.0 : 27.0;

    if (!widget.showArrow!) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    if (widget.container == null) {
      return Stack(
        children: <Widget>[
          widget.showArrow! ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentY,
            left: _getLeft(),
            right: _getRight(),
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset as double),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: Offset(0.0, 0.100),
                ).animate(widget.animationOffset!),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                        EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: GestureDetector(
                        onTap: widget.onTooltipTap,
                        child: Container(
                          width: _getTooltipWidth(),
                          padding: widget.contentPadding,
                          color: widget.tooltipColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  crossAxisAlignment: widget.title != null
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: <Widget>[
                                    widget.title != null
                                        ? Text(
                                            widget.title!,
                                            style: widget.titleTextStyle ??
                                                Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .merge(TextStyle(
                                                        color:
                                                            widget.textColor)),
                                          )
                                        : Container(),
                                    Text(
                                      widget.description!,
                                      style: widget.descTextStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .merge(TextStyle(
                                                  color: widget.textColor)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset as double),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: !widget.showArrow! && !ToolTipWidget.isArrowUp
                      ? Offset(0.0, 0.0)
                      : Offset(0.0, 0.100),
                ).animate(widget.animationOffset!),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(() {
                                var tempPos = position;
                                tempPos = Offset(
                                    position!.dx, position!.dy + size!.height);
                                position = tempPos;
                              });
                            },
                            child: widget.container),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _getArrow(double contentOffsetMultiplier) {
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);
    return Positioned(
      top: ToolTipWidget.isArrowUp
          ? widget.position!.getBottom()
          : widget.position!.getTop() - 1,
      left: widget.position!.getCenter() - 24,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFractionalOffset),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, contentFractionalOffset / 5),
            end: Offset(0.0, 0.150),
          ).animate(widget.animationOffset!),
          child: Icon(
            ToolTipWidget.isArrowUp
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down,
            color: widget.tooltipColor,
            size: 50,
          ),
        ),
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = (TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return textPainter;
  }
}
