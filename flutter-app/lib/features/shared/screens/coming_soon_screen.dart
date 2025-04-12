import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A visually sophisticated placeholder screen for features that are not yet implemented
class ComingSoonScreen extends StatefulWidget {
  final String featureName;

  const ComingSoonScreen({
    Key? key,
    required this.featureName,
  }) : super(key: key);

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: false);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.05, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get feature-specific icon
    IconData featureIcon = _getFeatureIcon();
    Color featureColor = _getFeatureColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.featureName),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepOcean,
              Color.lerp(AppTheme.deepOcean, featureColor, 0.15) ??
                  AppTheme.deepOcean,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: featureColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(75),
                              boxShadow: [
                                BoxShadow(
                                  color: featureColor.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Rotating outer circle
                                Transform.rotate(
                                  angle: _rotationAnimation.value,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(70),
                                      border: Border.all(
                                        color: featureColor.withOpacity(0.3),
                                        width: 2,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: DottedCirclePainter(
                                          color: featureColor),
                                    ),
                                  ),
                                ),
                                // Icon
                                Icon(
                                  featureIcon,
                                  size: 60,
                                  color: featureColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Title with shimmer effect
                  ShimmerText(
                    baseColor: Colors.white.withOpacity(0.8),
                    highlightColor: featureColor,
                    text: '${widget.featureName} Coming Soon',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Our team is working diligently to build this feature for you. Check back soon to enjoy the full functionality.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.moonlight.withOpacity(0.8),
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Feature description
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.deepOcean.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: featureColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getFeatureDescription(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.moonlight.withOpacity(0.7),
                            height: 1.6,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Back button with hover effect
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Return to Dashboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          backgroundColor: featureColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: featureColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFeatureIcon() {
    switch (widget.featureName.toLowerCase()) {
      case 'email manager':
        return Icons.email_rounded;
      case 'documents':
        return Icons.description_rounded;
      case 'chatbot':
        return Icons.chat_rounded;
      case 'task analytics':
        return Icons.bar_chart_rounded;
      case 'seo':
        return Icons.trending_up_rounded;
      case 'blog manager':
        return Icons.article_rounded;
      case 'ai insights':
        return Icons.insights_rounded;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.construction_rounded;
    }
  }

  Color _getFeatureColor() {
    switch (widget.featureName.toLowerCase()) {
      case 'email manager':
        return AppTheme.infoSapphire;
      case 'documents':
        return AppTheme.royalAzure;
      case 'chatbot':
        return AppTheme.emeraldGleam;
      case 'task analytics':
        return AppTheme.successEmerald;
      case 'seo':
        return AppTheme.warningAmber;
      case 'blog manager':
        return Color.lerp(AppTheme.emeraldGleam, AppTheme.royalAzure, 0.5) ??
            AppTheme.emeraldGleam;
      case 'ai insights':
        return Color.lerp(AppTheme.emeraldGleam, AppTheme.warningAmber, 0.3) ??
            AppTheme.emeraldGleam;
      case 'settings':
        return AppTheme.slate;
      default:
        return AppTheme.emeraldGleam;
    }
  }

  String _getFeatureDescription() {
    switch (widget.featureName.toLowerCase()) {
      case 'email manager':
        return 'The Email Manager will allow you to review and approve AI-generated email responses, manage email tasks, and streamline communication workflows.';
      case 'documents':
        return 'The Documents feature will provide a centralized viewer and downloader for all your generated documents, with secure access controls and organization options.';
      case 'chatbot':
        return 'The Chatbot interface will provide an interactive AI assistant to answer questions, perform tasks, and provide real-time support for your business needs.';
      case 'task analytics':
        return 'Task Analytics will offer detailed performance metrics on AI task execution, helping you track efficiency, identify bottlenecks, and optimize workflows.';
      case 'seo':
        return 'The SEO Management feature will provide tools to analyze search performance, manage keywords, and implement strategies to improve your online visibility.';
      case 'blog manager':
        return 'Blog Manager will help you organize content creation, schedule posts, track performance, and leverage AI for content idea generation.';
      case 'ai insights':
        return 'AI Insights will deliver intelligent anomaly detection and proactive business recommendations based on patterns in your data.';
      case 'settings':
        return 'The Settings section will allow you to customize your dashboard experience, manage user preferences, and configure application behavior.';
      default:
        return 'This feature is currently in development and will be available in a future update. We appreciate your patience.';
    }
  }
}

/// Custom shimmer text effect
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color baseColor;
  final Color highlightColor;
  final TextAlign textAlign;

  const ShimmerText({
    Key? key,
    required this.text,
    this.style,
    required this.baseColor,
    required this.highlightColor,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(
                slidePercent: _shimmerController.value,
              ),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// Custom painter for dotted circle effect
class DottedCirclePainter extends CustomPainter {
  final Color color;

  DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    // Draw dotted circle
    double arcLength = 2 * math.pi / 24; // 24 segments

    for (int i = 0; i < 24; i++) {
      // Draw arc for even segments only (to create the dotted effect)
      if (i % 2 == 0) {
        double startAngle = i * arcLength;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          startAngle,
          arcLength,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
