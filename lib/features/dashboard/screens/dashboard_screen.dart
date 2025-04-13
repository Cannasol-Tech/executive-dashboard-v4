import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_summary_provider.dart';
import '../models/dashboard_summary.dart';
import '../widgets/dashboard_card.dart';
import '../../shared/widgets/theme_toggle.dart';
import 'package:google_fonts/google_fonts.dart';

/// Main dashboard screen for the Cannasol Executive Dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _layoutAnimationController;
  late Animation<double> _gridSpacingAnimation;
  int _previousCrossAxisCount = 0;

  @override
  void initState() {
    super.initState();
    _layoutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _gridSpacingAnimation = Tween<double>(begin: 16, end: 16).animate(
      CurvedAnimation(
        parent: _layoutAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _layoutAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final authProvider = Provider.of<AuthProvider>(context);
    final summaryProvider = Provider.of<DashboardSummaryProvider>(context);

    // Determine the current cross axis count for the grid
    final currentCrossAxisCount = _getGridCrossAxisCount(context);

    // Animate grid spacing when layout changes
    if (_previousCrossAxisCount != currentCrossAxisCount &&
        _previousCrossAxisCount != 0) {
      _gridSpacingAnimation = Tween<double>(
        begin: _gridSpacingAnimation.value,
        end: isSmallScreen ? 12 : 16,
      ).animate(
        CurvedAnimation(
          parent: _layoutAnimationController,
          curve: Curves.easeInOutCubic,
        ),
      );
      _layoutAnimationController.forward(from: 0);
    }

    _previousCrossAxisCount = currentCrossAxisCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icn/cannasol-logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: AppTheme.emeraldGleam),
            ),
            const SizedBox(width: 12),
            const Text('Executive Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications view
            },
          ),
          const SizedBox(width: 8),
          _buildUserAvatar(context, authProvider),
          const SizedBox(width: 16),
          ThemeToggle(),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: isSmallScreen ? _buildSideMenu(context, authProvider) : null,
      body: Row(
        children: [
          // Side menu for larger screens with animated transition
          if (!isSmallScreen)
            AnimatedSidebar(
              authProvider: authProvider,
              child: _buildSideMenu(context, authProvider),
            ),

          // Main content area with animated transition
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(context, authProvider),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildDashboardGrid(context, summaryProvider),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthProvider authProvider) {
    final greeting = _getGreeting();
    final userName = authProvider.currentUser?.displayName ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome to your executive dashboard',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.slate,
              ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(
      BuildContext context, DashboardSummaryProvider summaryProvider) {
    final summaryData = summaryProvider.summaryData;
    final isLoading = summaryProvider.isLoading;
    final error = summaryProvider.error;

    if (error != null) {
      return Center(child: Text('Error loading dashboard: $error'));
    }

    final List<CardType> cardOrder = [
      CardType.revenue,
      CardType.customers,
      CardType.operations,
      CardType.sales,
      CardType.marketing,
    ];

    // Determine card heights for a more aesthetically pleasing grid
    final List<double> cardHeights = [
      250, // Revenue (taller)
      200, // Customers
      200, // Operations
      250, // Sales (taller for charts)
      220, // Marketing
    ];

    return AnimatedBuilder(
      animation: _layoutAnimationController,
      builder: (context, child) {
        return MasonryGridView.count(
          crossAxisCount: _getGridCrossAxisCount(context),
          itemCount: cardOrder.length,
          // physics: const BouncingScrollPhysics(),
          mainAxisSpacing: _gridSpacingAnimation.value,
          crossAxisSpacing: _gridSpacingAnimation.value,
          itemBuilder: (context, index) {
            CardType cardType = cardOrder[index];
            String title = _getCardTitle(cardType);
            IconData icon = _getCardIcon(cardType);

            Widget cardContent =
                _buildCardContent(context, cardType, summaryData, isLoading);

            // Add staggered animation for each card
            return AnimatedEntrance(
              delay: Duration(milliseconds: 100 * index),
              child: DashboardCard(
                title: title,
                icon: icon,
                cardType: cardType,
                minHeight: cardHeights[index],
                child: cardContent,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, CardType type,
      DashboardSummary summary, bool isLoading) {
    if (isLoading) {
      return Center(
        child: ShimmerLoading(
          isLoading: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 30,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 15,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    TextStyle? valueStyle = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold);
    TextStyle? labelStyle = Theme.of(context).textTheme.bodyMedium;

    switch (type) {
      case CardType.revenue:
        final double percentage =
            (summary.revenueCurrent / summary.revenueTarget) * 100;
        final bool isOnTarget = percentage >= 85;
        return AnimatedProgressIndicator(
          value: percentage / 100,
          color: isOnTarget ? AppTheme.successEmerald : AppTheme.warningAmber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CountUpAnimation(
                begin: 0,
                end: summary.revenueCurrent,
                duration: const Duration(seconds: 1),
                prefix: '\$',
                decimals: 2,
                style: valueStyle,
              ),
              const SizedBox(height: 4),
              Text('Target: \$${summary.revenueTarget.toStringAsFixed(2)}',
                  style: labelStyle),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(1)}% of goal',
                style: TextStyle(
                  color: isOnTarget
                      ? AppTheme.successEmerald
                      : AppTheme.warningAmber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case CardType.customers:
        return AnimatedCountVisualizer(
          value: summary.customerCount,
          style: valueStyle,
          label: "Total Customers",
          labelStyle: labelStyle,
          icon: Icons.people,
          color: AppTheme.royalAzure,
        );
      case CardType.operations:
        return AnimatedCountVisualizer(
          value: summary.activeOperations,
          style: valueStyle,
          label: "Active Operations",
          labelStyle: labelStyle,
          icon: Icons.precision_manufacturing,
          color: AppTheme.infoSapphire,
        );
      case CardType.sales:
        return AnimatedProgressIndicator(
          value: summary.salesPerformancePercent / 100,
          color: AppTheme.successEmerald,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CountUpAnimation(
                begin: 0,
                end: summary.salesPerformancePercent,
                duration: const Duration(seconds: 1),
                suffix: '%',
                decimals: 1,
                style: valueStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Sales Performance',
                style: labelStyle,
              ),
            ],
          ),
        );
      case CardType.marketing:
        return AnimatedCountVisualizer(
          value: summary.marketingLeads,
          style: valueStyle,
          label: "Marketing Leads",
          labelStyle: labelStyle,
          icon: Icons.campaign,
          color: AppTheme.warningAmber,
        );
      default:
        return Center(
          child:
              Text('Coming Soon', style: Theme.of(context).textTheme.bodyLarge),
        );
    }
  }

  Widget _buildSideMenu(BuildContext context, AuthProvider authProvider) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSmallScreen ? double.infinity : 260,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: AppTheme.nightOcean,
        boxShadow: isSmallScreen ? [] : AppTheme.elevation3,
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              authProvider.currentUser?.displayName ?? 'User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              authProvider.currentUser?.email ?? '',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.moonlight.withOpacity(0.8),
              ),
            ),
            currentAccountPicture: Hero(
              tag: 'user_avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.emeraldGleam, width: 2),
                ),
                child: CircleAvatar(
                  backgroundImage: authProvider.currentUser?.photoUrl != null
                      ? NetworkImage(authProvider.currentUser!.photoUrl!)
                      : null,
                  child: authProvider.currentUser?.photoUrl == null
                      ? const Icon(Icons.person,
                          size: 40, color: AppTheme.moonlight)
                      : null,
                ),
              ),
            ),
            decoration: BoxDecoration(gradient: AppTheme.premiumBrand),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  isSelected:
                      currentRoute == '/' || currentRoute == '/dashboard',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/dashboard') {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.email_rounded,
                  title: 'Email Manager',
                  isSelected: currentRoute == '/email',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/email') {
                      Navigator.pushNamed(context, '/email');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.description_rounded,
                  title: 'Documents',
                  isSelected: currentRoute == '/documents',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/documents') {
                      Navigator.pushNamed(context, '/documents');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.chat_rounded,
                  title: 'Chatbot',
                  isSelected: currentRoute == '/chat',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/chat') {
                      Navigator.pushNamed(context, '/chat');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Task Analytics',
                  isSelected: currentRoute == '/ai_analytics',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/ai_analytics') {
                      Navigator.pushNamed(context, '/ai_analytics');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.trending_up_rounded,
                  title: 'SEO',
                  isSelected: currentRoute == '/seo',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/seo') {
                      Navigator.pushNamed(context, '/seo');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.article_rounded,
                  title: 'Blog Manager',
                  isSelected: currentRoute == '/blog',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/blog') {
                      Navigator.pushNamed(context, '/blog');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.insights_rounded,
                  title: 'AI Insights',
                  isSelected: currentRoute == '/insights',
                  onTap: () {
                    if (isSmallScreen) Navigator.pop(context);
                    if (currentRoute != '/insights') {
                      Navigator.pushNamed(context, '/insights');
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.slate.withOpacity(0.3)),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            isSelected: currentRoute == '/settings',
            onTap: () {
              if (isSmallScreen) Navigator.pop(context);
              if (currentRoute != '/settings') {
                Navigator.pushNamed(context, '/settings');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected ? AppTheme.premiumBrand : null,
        color: isSelected ? null : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.moonlight
                      : AppTheme.moonlight.withOpacity(0.7),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                    color: isSelected
                        ? AppTheme.moonlight
                        : AppTheme.moonlight.withOpacity(0.7),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.emeraldGleam,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, AuthProvider authProvider) {
    return Hero(
      tag: 'user_avatar',
      child: GestureDetector(
        onTap: () => _showUserMenu(context, authProvider),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.emeraldGleam, width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: authProvider.currentUser?.photoUrl != null
                ? NetworkImage(authProvider.currentUser!.photoUrl!)
                : null,
            backgroundColor: AppTheme.deepOcean,
            child: authProvider.currentUser?.photoUrl == null
                ? const Icon(Icons.person, size: 24, color: AppTheme.moonlight)
                : null,
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, AuthProvider authProvider) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: const Text('Profile'),
          onTap: () {
            // TODO: Navigate to profile screen
          },
        ),
        PopupMenuItem(
          child: const Text('Settings'),
          onTap: () {
            // TODO: Navigate to settings screen
          },
        ),
        PopupMenuItem(
          child: const Text('Sign Out'),
          onTap: () {
            authProvider.signOut();
          },
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    } else if (width < 900) {
      return 2;
    } else if (width < 1200) {
      return 3;
    } else {
      return 4;
    }
  }

  String _getCardTitle(CardType type) {
    switch (type) {
      case CardType.revenue:
        return 'Revenue';
      case CardType.customers:
        return 'Customers';
      case CardType.operations:
        return 'Operations';
      case CardType.sales:
        return 'Sales Performance';
      case CardType.marketing:
        return 'Marketing';
    }
  }

  IconData _getCardIcon(CardType type) {
    switch (type) {
      case CardType.revenue:
        return Icons.attach_money;
      case CardType.customers:
        return Icons.people;
      case CardType.operations:
        return Icons.precision_manufacturing;
      case CardType.sales:
        return Icons.trending_up;
      case CardType.marketing:
        return Icons.campaign;
    }
  }
}

enum CardType {
  revenue,
  customers,
  operations,
  sales,
  marketing,
}

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedEntrance({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Delay the animation if specified
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// Add this new widget for animated sidebar transitions
class AnimatedSidebar extends StatefulWidget {
  final Widget child;
  final AuthProvider authProvider;

  const AnimatedSidebar({
    Key? key,
    required this.child,
    required this.authProvider,
  }) : super(key: key);

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 0, end: 260).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: _widthAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Add these animation widgets at the end of the file
class ShimmerLoading extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const ShimmerLoading({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0x30FFFFFF),
                Color(0x60FFFFFF),
                Color(0x30FFFFFF),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class CountUpAnimation extends StatelessWidget {
  final double begin;
  final double end;
  final Duration duration;
  final String? prefix;
  final String? suffix;
  final int decimals;
  final TextStyle? style;

  const CountUpAnimation({
    Key? key,
    required this.begin,
    required this.end,
    this.duration = const Duration(milliseconds: 1500),
    this.prefix,
    this.suffix,
    this.decimals = 0,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${prefix ?? ''}${value.toStringAsFixed(decimals)}${suffix ?? ''}',
          style: style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class AnimatedProgressIndicator extends StatelessWidget {
  final double value;
  final Color color;
  final Widget child;

  const AnimatedProgressIndicator({
    Key? key,
    required this.value,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              height: double.infinity,
              width: double.infinity * animatedValue,
            );
          },
        ),
        child,
      ],
    );
  }
}

class AnimatedCountVisualizer extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String label;
  final TextStyle? labelStyle;
  final IconData icon;
  final Color color;

  const AnimatedCountVisualizer({
    Key? key,
    required this.value,
    this.style,
    required this.label,
    this.labelStyle,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return Transform.scale(
              scale: animatedValue,
              child: Icon(
                icon,
                size: 40,
                color: color.withOpacity(0.7),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        CountUpAnimation(
          begin: 0,
          end: value.toDouble(),
          duration: const Duration(seconds: 1),
          style: style,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: labelStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
