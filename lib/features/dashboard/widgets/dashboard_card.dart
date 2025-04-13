import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';

/// Reusable card widget for dashboard grid items
class DashboardCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final CardType cardType;
  final VoidCallback? onTap;
  final double minHeight;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    required this.cardType,
    this.onTap,
    this.minHeight = 200,
  }) : super(key: key);

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glossOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundOpacityAnimation = Tween<double>(begin: 0.0, end: 0.12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.01).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _glossOpacityAnimation = Tween<double>(begin: 0.04, end: 0.08).animate(
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
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..scale(_scaleAnimation.value)
              ..rotateZ(_rotationAnimation.value),
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: _elevationAnimation.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Animated background
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeInOutSine,
                        top: _isHovering ? -100 : -120,
                        right: _isHovering ? -30 : -50,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _backgroundOpacityAnimation.value,
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getIconColor(context).withOpacity(0.6),
                                  _getIconColor(context).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Background glow effect
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isHovering ? 0.12 : 0.05,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getIconColor(context),
                                    blurRadius: 50,
                                    spreadRadius: 5,
                                  )
                                ]),
                          ),
                        ),
                      ),

                      // Main card content
                      Container(
                        constraints: BoxConstraints(
                          minHeight: widget.minHeight,
                        ),
                        decoration: BoxDecoration(
                          gradient: _getCardGradient(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isHovering ? AppTheme.elevation2 : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card header with animated indicator
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Animated icon container with glow effect
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        height: 36,
                                        width: 36,
                                        decoration: BoxDecoration(
                                          color: _getIconBackgroundColor(),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: _isHovering
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        _getIconColor(context)
                                                            .withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: AnimatedRotation(
                                          turns: _isHovering ? 0.05 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Icon(
                                            widget.icon,
                                            color: _getIconColor(context),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color:
                                                      _getTitleColor(context),
                                                  fontWeight: _isHovering
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  letterSpacing:
                                                      _isHovering ? 0.5 : 0.3,
                                                  shadows: _isHovering
                                                      ? [
                                                          Shadow(
                                                            color: _getIconColor(
                                                                    context)
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 4,
                                                          )
                                                        ]
                                                      : null,
                                                ) ??
                                            const TextStyle(),
                                        child: Text(widget.title),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: AnimatedRotation(
                                      turns: _isHovering ? 0.125 : 0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: _getTitleColor(context)
                                            .withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                    splashRadius: 20,
                                    onPressed: () {
                                      _showCardMenu(context);
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Animated divider with glow effect
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                  begin: 0.3, end: _isHovering ? 0.8 : 0.3),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Container(
                                  height: 1,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        _getIconColor(context)
                                            .withOpacity(value),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: _isHovering
                                        ? [
                                            BoxShadow(
                                              color: _getIconColor(context)
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                            )
                                          ]
                                        : null,
                                  ),
                                );
                              },
                            ),

                            // Card content with animation
                            Expanded(
                              child: AnimatedPadding(
                                duration: const Duration(milliseconds: 300),
                                padding:
                                    EdgeInsets.all(_isHovering ? 20.0 : 16.0),
                                child: widget.child,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Glass morphism effect
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 70,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _glossOpacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCardMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.obsidian,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            children: [
              _buildMenuOption(
                icon: Icons.fullscreen,
                title: 'Expand',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement expanded view
                },
              ),
              _buildMenuOption(
                icon: Icons.refresh,
                title: 'Refresh',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement refresh
                },
              ),
              _buildMenuOption(
                icon: Icons.settings,
                title: 'Configure',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement configuration
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: AppTheme.deepOcean,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.emeraldGleam,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.moonlight,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Color _getIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    switch (widget.cardType) {
      case CardType.revenue:
        return AppTheme.emeraldGleam;
      case CardType.customers:
        return AppTheme.royalAzure;
      case CardType.operations:
        return AppTheme.infoSapphire;
      case CardType.sales:
        return AppTheme.successEmerald;
      case CardType.marketing:
        return AppTheme.warningAmber;
      default:
        return brightness == Brightness.light
            ? AppTheme.deepOcean
            : AppTheme.moonlight;
    }
  }

  Color _getIconBackgroundColor() {
    switch (widget.cardType) {
      case CardType.revenue:
        return AppTheme.emeraldGleam.withOpacity(0.1);
      case CardType.customers:
        return AppTheme.royalAzure.withOpacity(0.1);
      case CardType.operations:
        return AppTheme.infoSapphire.withOpacity(0.1);
      case CardType.sales:
        return AppTheme.successEmerald.withOpacity(0.1);
      case CardType.marketing:
        return AppTheme.warningAmber.withOpacity(0.1);
      default:
        return AppTheme.deepOcean.withOpacity(0.1);
    }
  }

  Color _getTitleColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? AppTheme.graphite
        : AppTheme.moonlight;
  }

  Gradient _getCardGradient(BuildContext context) {
    switch (widget.cardType) {
      case CardType.revenue:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            Color.lerp(AppTheme.deepOcean, AppTheme.emeraldGleam, 0.1) ??
                AppTheme.deepOcean,
          ],
        );
      case CardType.customers:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            Color.lerp(AppTheme.deepOcean, AppTheme.royalAzure, 0.1) ??
                AppTheme.deepOcean,
          ],
        );
      case CardType.operations:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            Color.lerp(AppTheme.deepOcean, AppTheme.infoSapphire, 0.1) ??
                AppTheme.deepOcean,
          ],
        );
      case CardType.sales:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            Color.lerp(AppTheme.deepOcean, AppTheme.successEmerald, 0.1) ??
                AppTheme.deepOcean,
          ],
        );
      case CardType.marketing:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            Color.lerp(AppTheme.deepOcean, AppTheme.warningAmber, 0.1) ??
                AppTheme.deepOcean,
          ],
        );
      default:
        return AppTheme.nightOcean;
    }
  }
}
