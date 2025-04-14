import 'dart:math';
import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';

class RadialProgressChart extends StatefulWidget {
  final double percentage;
  final String label;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  const RadialProgressChart({
    super.key,
    required this.percentage,
    required this.label,
    this.progressColor = Colors.green, // Default to green as in the image
    this.backgroundColor = Colors.white24,
    this.strokeWidth = 15.0, // Adjust as needed for thickness
  });

  @override
  State<RadialProgressChart> createState() => _RadialProgressChartState();
}

class _RadialProgressChartState extends State<RadialProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovered
                ? 1.05 * _scaleAnimation.value
                : _scaleAnimation.value,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: _RadialProgressPainter(
                      backgroundColor: widget.backgroundColor,
                      progressColor: _isHovered
                          ? Color.lerp(widget.progressColor, Colors.white, 0.2)!
                          : widget.progressColor,
                      progressValue: _progressAnimation.value,
                      strokeWidth: widget.strokeWidth,
                      glowIntensity: _isHovered ? 0.2 : 0.1,
                    ),
                  ),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Percentage Text
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            tween: Tween(
                              begin: 0,
                              end: widget.percentage,
                            ),
                            builder: (context, value, _) {
                              return Text(
                                '${value.toInt()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.moonlight,
                                      fontSize: _isHovered ? 32 : 28,
                                      shadows: _isHovered
                                          ? [
                                              Shadow(
                                                color: widget.progressColor
                                                    .withOpacity(0.6),
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : null,
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          // Label Text
                          Text(
                            widget.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.moonlight.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadialProgressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progressValue;
  final double strokeWidth;
  final double glowIntensity;

  _RadialProgressPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.progressValue,
    required this.strokeWidth,
    this.glowIntensity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;
    const startAngle = -pi / 2; // Start from the top (90 degrees)
    final sweepAngle = 2 * pi * progressValue;

    // Draw the background circle with a subtle shadow
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw the progress arc with glow effect
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Add shadow for glow effect
    canvas.saveLayer(
      Rect.fromCircle(center: center, radius: radius + strokeWidth * 2),
      Paint(),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = progressColor.withOpacity(glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    canvas.restore();

    // Draw dashes on the background circle for a more sophisticated look
    final dashCount = 24;
    final dashPaint = Paint()
      ..color = AppTheme.moonlight.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < dashCount; i++) {
      final dashAngle = (i * 2 * pi / dashCount) - pi / 2;
      final startOffset = Offset(
        center.dx + (radius - strokeWidth * 0.6) * cos(dashAngle),
        center.dy + (radius - strokeWidth * 0.6) * sin(dashAngle),
      );
      final endOffset = Offset(
        center.dx + (radius + strokeWidth * 0.6) * cos(dashAngle),
        center.dy + (radius + strokeWidth * 0.6) * sin(dashAngle),
      );
      canvas.drawLine(startOffset, endOffset, dashPaint);
    }
  }

  @override
  bool shouldRepaint(_RadialProgressPainter oldDelegate) =>
      oldDelegate.progressValue != progressValue ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.glowIntensity != glowIntensity;
}
