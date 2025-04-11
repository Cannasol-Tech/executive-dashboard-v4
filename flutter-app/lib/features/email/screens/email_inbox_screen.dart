import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/providers/email_provider.dart';
import '../widgets/email_actions_panel.dart';
import '../../../models/email.dart';
import '../widgets/email_list_item.dart';
import '../screens/email_detail_screen.dart';

class EmailInboxScreen extends StatefulWidget {
  const EmailInboxScreen({super.key});

  static const String routeName = '/email';

  @override
  State<EmailInboxScreen> createState() => _EmailInboxScreenState();
}

class _EmailInboxScreenState extends State<EmailInboxScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Generate sample data if needed for development and testing
    // Uncomment this to generate sample data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<EmailProvider>(context, listen: false).generateSampleData(15);
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _animationController.forward();
        _searchFocus.requestFocus();
      } else {
        _animationController.reverse();
        _searchController.clear();
        Provider.of<EmailProvider>(context, listen: false)
            .setFilters(searchQuery: '');
      }
    });
  }

  void _performSearch(String query) {
    Provider.of<EmailProvider>(context, listen: false)
        .setFilters(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final emailProvider = Provider.of<EmailProvider>(context);
    final emails = emailProvider.emails;
    final isLoading = emailProvider.isLoading;
    final error = emailProvider.error;
    final hasSelection = emailProvider.selectedEmailIds.isNotEmpty;
    final mediaQuery = MediaQuery.of(context).size;
    final bool isSmallScreen = mediaQuery.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: hasSelection
              ? Text(
                  '${emailProvider.selectedEmailIds.length} selected',
                  key: const ValueKey('selection'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.moonlight,
                  ),
                )
              : _isSearchVisible
                  ? _buildSearchField()
                  : const Text(
                      'Email Management',
                      key: ValueKey('title'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
        ),
        leading: hasSelection
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear selection',
                onPressed: () {
                  emailProvider.clearSelectedEmails();
                },
              )
            : null,
        actions: [
          // Search icon button
          if (!hasSelection && !_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.moonlight),
              tooltip: 'Search emails',
              onPressed: _toggleSearch,
            ),
          if (_isSearchVisible)
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.moonlight),
              tooltip: 'Cancel search',
              onPressed: _toggleSearch,
            ),
          // Filters button
          if (!hasSelection && !_isSearchVisible)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: AppTheme.moonlight),
              tooltip: 'Filter options',
              onSelected: (value) {
                switch (value) {
                  case 'pending':
                  case 'responded':
                  case 'approved':
                  case 'rejected':
                    emailProvider.setFilters(
                        statusFilter:
                            value == emailProvider.statusFilter ? null : value);
                    break;
                  case 'high_priority':
                    emailProvider.setFilters(
                        priorityFilter:
                            emailProvider.priorityFilter == 1 ? null : 1);
                    break;
                  case 'show_archived':
                    emailProvider.setFilters(
                        includeArchived: !emailProvider.includeArchived);
                    break;
                  case 'show_spam':
                    emailProvider.setFilters(
                        includeSpam: !emailProvider.includeSpam);
                    break;
                  case 'clear_filters':
                    emailProvider.setFilters(
                      includeArchived: false,
                      includeSpam: false,
                      statusFilter: null,
                      priorityFilter: null,
                      searchQuery: '',
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'pending',
                  child: _buildFilterMenuItem(
                    'Pending',
                    Icons.pending_outlined,
                    isSelected: emailProvider.statusFilter == 'pending',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'responded',
                  child: _buildFilterMenuItem(
                    'Response Ready',
                    Icons.mark_email_read,
                    isSelected: emailProvider.statusFilter == 'responded',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'approved',
                  child: _buildFilterMenuItem(
                    'Approved',
                    Icons.thumb_up_outlined,
                    isSelected: emailProvider.statusFilter == 'approved',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'rejected',
                  child: _buildFilterMenuItem(
                    'Rejected',
                    Icons.thumb_down_outlined,
                    isSelected: emailProvider.statusFilter == 'rejected',
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'high_priority',
                  child: _buildFilterMenuItem(
                    'High Priority',
                    Icons.priority_high,
                    isSelected: emailProvider.priorityFilter == 1,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'show_archived',
                  child: _buildFilterMenuItem(
                    'Show Archived',
                    Icons.archive,
                    isSelected: emailProvider.includeArchived,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'show_spam',
                  child: _buildFilterMenuItem(
                    'Show Spam',
                    Icons.report_gmailerrorred,
                    isSelected: emailProvider.includeSpam,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'clear_filters',
                  child: Text('Clear All Filters'),
                ),
              ],
            ),
          // Refresh button
          if (!hasSelection && !_isSearchVisible)
            IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.emeraldGleam),
                      ),
                    )
                  : const Icon(Icons.refresh, color: AppTheme.moonlight),
              tooltip: 'Refresh inbox',
              onPressed: isLoading
                  ? null
                  : () {
                      emailProvider.fetchEmails();
                    },
            ),
          // Show action panel when emails are selected
          if (hasSelection) const EmailActionsPanel(),

          const SizedBox(width: 8),
        ],
        backgroundColor: AppTheme.deepOcean,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (isLoading && emails.isEmpty)
            _buildLoadingIndicator()
          else if (error != null && emails.isEmpty)
            _buildErrorView(error)
          else if (emails.isEmpty)
            _buildEmptyView()
          else
            _buildEmailList(emails, emailProvider, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(right: 8.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: _performSearch,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.obsidian.withOpacity(0.3),
          hintText: 'Search emails...',
          hintStyle: TextStyle(color: AppTheme.moonlight.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: AppTheme.emeraldGleam),
        ),
        style: TextStyle(
          color: AppTheme.moonlight,
        ),
      ),
    );
  }

  Widget _buildFilterMenuItem(String title, IconData icon,
      {bool isSelected = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected
              ? AppTheme.emeraldGleam
              : AppTheme.moonlight.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(title),
        const Spacer(),
        if (isSelected)
          const Icon(
            Icons.check,
            size: 18,
            color: AppTheme.emeraldGleam,
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emeraldGleam),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading emails...',
            style: TextStyle(
              color: AppTheme.moonlight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load emails',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.moonlight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.moonlight.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                Provider.of<EmailProvider>(context, listen: false)
                    .fetchEmails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGleam,
                foregroundColor: AppTheme.obsidian,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.deepOcean,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.emeraldGleam.withOpacity(0.5), width: 2),
            ),
            child: Icon(
              Icons.inbox,
              size: 48,
              color: AppTheme.emeraldGleam,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No emails found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.moonlight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your inbox is empty or no emails match your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.moonlight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Generate Sample Data'),
            onPressed: () {
              Provider.of<EmailProvider>(context, listen: false)
                  .generateSampleEmails(15);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGleam,
              foregroundColor: AppTheme.obsidian,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList(
      List<Email> emails, EmailProvider provider, bool isSmallScreen) {
    return ListView.builder(
      key: _listKey,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: emails.length,
      itemBuilder: (context, index) {
        final email = emails[index];
        final isSelected = provider.selectedEmailIds.contains(email.id);

        return EmailListItem(
          email: email,
          isSelected: isSelected,
          onSelect: (selected) {
            provider.toggleEmailSelection(email.id);
          },
          onTap: () {
            if (provider.selectedEmailIds.isNotEmpty) {
              // If in selection mode, toggle selection
              provider.toggleEmailSelection(email.id);
            } else {
              // Otherwise navigate to detail screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EmailDetailScreen(emailId: email.id),
                ),
              );
            }
          },
          isSmallScreen: isSmallScreen,
        );
      },
    );
  }
}
