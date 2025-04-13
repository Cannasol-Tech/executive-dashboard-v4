import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_generator_provider.dart';
import '../models/document_request.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/document_request_form.dart';
import '../widgets/document_status_tracker.dart';
import '../widgets/generated_documents_list.dart';
import '../widgets/shared_documents_list.dart';
import './template_upload_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize data when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final documentProvider = Provider.of<DocumentGeneratorProvider>(context, listen: false);
        documentProvider.refreshAllData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textTheme = theme.textTheme;
    final appTheme = Provider.of<AppTheme>(context);
    final user = Provider.of<UserModel>(context);
    final documentProvider = Provider.of<DocumentGeneratorProvider>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, textTheme),
          const SizedBox(height: 16),
          _buildTabBar(context, theme, appTheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewRequestTab(context, documentProvider, appTheme),
                _buildMyDocumentsTab(context, documentProvider, appTheme),
                _buildSharedDocumentsTab(context, documentProvider, appTheme),
              ],
          ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // New method to build a floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    // Only show the button if we're on the "My Documents" tab
    if (_tabController.index != 1) return const SizedBox.shrink();

    final user = Provider.of<UserModel>(context);

    // Hide if user doesn't have the necessary permission
    // You can implement permission checking based on your app's requirements
    bool hasUploadPermission = true; // For demo, we allow all users

    if (!hasUploadPermission) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TemplateUploadScreen(),
          ),
        );

        // If template was uploaded successfully, refresh the document list
        if (result == true) {
          if (mounted) {
            // Refresh templates data
            final provider =
                Provider.of<DocumentGeneratorProvider>(context, listen: false);
            provider.refreshAllData();
          }
        }
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.upload_file),
      tooltip: 'Upload Template',
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document Generator',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create, manage, and download AI-generated documents',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildRefreshButton(context),
              const SizedBox(width: 16),
              _buildUserProfile(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      BuildContext context, ThemeData theme, AppTheme appTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.textPrimaryColor,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'New Request'),
          Tab(text: 'My Documents'),
          Tab(text: 'Shared Documents'),
        ],
      ),
    );
  }

  Widget _buildNewRequestTab(BuildContext context,
      DocumentGeneratorProvider provider, AppTheme appTheme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (provider.errorMessage != null)
          _buildErrorMessage(context, provider.errorMessage!, provider),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DocumentRequestForm(),
          ),
        ),
        const SizedBox(height: 24),
        _buildRecentRequestsSection(context, provider, appTheme),
      ],
    );
  }

  Widget _buildMyDocumentsTab(BuildContext context,
      DocumentGeneratorProvider provider, AppTheme appTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GeneratedDocumentsList(),
    );
  }

  Widget _buildSharedDocumentsTab(BuildContext context,
      DocumentGeneratorProvider provider, AppTheme appTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SharedDocumentsList(),
    );
  }

  Widget _buildRecentRequestsSection(BuildContext context,
      DocumentGeneratorProvider provider, AppTheme appTheme) {
    final textTheme = Theme.of(context).textTheme;

    if (provider.isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.userRequests.isEmpty) {
      return Center(
        child: Text(
          'No document requests yet',
          style: textTheme.titleMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    final recentRequests = provider.userRequests.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Requests',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recentRequests.map(
            (request) => _buildRequestStatusItem(context, request, provider)),
      ],
    );
  }

  Widget _buildRequestStatusItem(
    BuildContext context,
    DocumentRequest request,
    DocumentGeneratorProvider provider,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.templateName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _buildStatusChip(context, request.status),
              ],
            ),
            const SizedBox(height: 12),
            DocumentStatusTracker(requestId: request.id),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDateTime(request.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, DocumentRequestStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case DocumentRequestStatus.pending:
        backgroundColor = AppTheme.warningAmber;
        textColor = AppTheme.textPrimaryColor;
        label = 'Pending';
        break;
      case DocumentRequestStatus.processing:
        backgroundColor = Theme.of(context).primaryColorLight;
        textColor = AppTheme.infoSapphire;
        label = 'Processing';
        break;
      case DocumentRequestStatus.completed:
        backgroundColor = AppTheme.successEmerald;
        textColor = AppTheme.textPrimaryColor;
        label = 'Completed';
        break;
      case DocumentRequestStatus.failed:
        backgroundColor = AppTheme.errorRuby;
        textColor = AppTheme.textPrimaryColor;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message,
      DocumentGeneratorProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRuby.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorRuby),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorRuby),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.errorRuby),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.errorRuby),
            onPressed: provider.clearError,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Consumer<DocumentGeneratorProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: provider.refreshAllData,
        );
      },
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final auth = Provider.of<AuthService>(context);

    return PopupMenuButton(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: CircleAvatar(
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null ? Text(user.displayName[0]) : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text('Signed in as ${user.displayName}'),
          enabled: false,
        ),
        const PopupMenuItem(
          child: Text('Settings'),
          value: 'settings',
        ),
        const PopupMenuItem(
          child: Text('Sign out'),
          value: 'sign_out',
        ),
      ],
      onSelected: (value) {
        if (value == 'sign_out') {
          auth.signOut();
        } else if (value == 'settings') {
          Navigator.pushNamed(context, '/settings');
        }
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
