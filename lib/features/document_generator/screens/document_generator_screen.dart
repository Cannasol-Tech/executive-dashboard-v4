import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_generator_provider.dart';

import '../widgets/document_request_form.dart';
import '../widgets/generated_documents_list.dart';
import '../widgets/shared_documents_list.dart';

class DocumentGeneratorScreen extends StatefulWidget {
  const DocumentGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<DocumentGeneratorScreen> createState() =>
      _DocumentGeneratorScreenState();
}

class _DocumentGeneratorScreenState extends State<DocumentGeneratorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<DocumentGeneratorProvider>(context, listen: false);
      provider.maybeStartFetching();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                Provider.of<DocumentGeneratorProvider>(context, listen: false)
                    .refreshAllData();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'New Request'),
              Tab(text: 'My Documents'),
              Tab(text: 'Shared Documents'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondaryColor,
            indicatorColor: AppTheme.primaryColor,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Tab 1: New Document Request Form
              Padding(
                padding: EdgeInsets.all(16.0),
                child: DocumentRequestForm(),
              ),

              // Tab 2: My Generated Documents
              Padding(
                padding: EdgeInsets.all(16.0),
                child: GeneratedDocumentsList(),
              ),

              // Tab 3: Shared Documents
              Padding(
                padding: EdgeInsets.all(16.0),
                child: SharedDocumentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
