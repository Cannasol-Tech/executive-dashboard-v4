import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/generated_document.dart';
import '../providers/document_generator_provider.dart';
import 'document_card.dart';

class GeneratedDocumentsList extends StatefulWidget {
  const GeneratedDocumentsList({Key? key}) : super(key: key);

  @override
  State<GeneratedDocumentsList> createState() => _GeneratedDocumentsListState();
}

class _GeneratedDocumentsListState extends State<GeneratedDocumentsList> {
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'name', 'type'
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer<DocumentGeneratorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingUserDocuments) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.userDocuments.isEmpty) {
          return _buildEmptyState();
        }

        final filteredDocuments =
            _filterAndSortDocuments(provider.userDocuments);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Documents',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search and filter controls
            _buildSearchAndFilterControls(),
            const SizedBox(height: 24),

            // Document grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  return DocumentCard(
                    document: filteredDocuments[index],
                    onDownload: _handleDownload,
                    onDelete: _handleDelete,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Documents you generate will appear here',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Switch to the New Request tab
              final tabController = DefaultTabController.of(context);
              if (tabController != null) {
                tabController.animateTo(0);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Generate New Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterControls() {
    return Row(
      children: [
        // Search field
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search documents...',
              prefixIcon:
                  Icon(Icons.search, color: AppTheme.textSecondaryColor),
              filled: true,
              fillColor: AppTheme.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderSubtle),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Sort dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: AppTheme.secondaryColor),
              style: TextStyle(color: AppTheme.textPrimaryColor),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    if (_sortBy == value) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortBy = value;
                      _sortAscending = true;
                    }
                  });
                }
              },
              items: <String>['date', 'name', 'type']
                  .map<DropdownMenuItem<String>>((String value) {
                String label;
                switch (value) {
                  case 'date':
                    label = 'Sort by Date';
                    break;
                  case 'name':
                    label = 'Sort by Name';
                    break;
                  case 'type':
                    label = 'Sort by Type';
                    break;
                  default:
                    label = value;
                }

                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label),
                      const SizedBox(width: 4),
                      if (_sortBy == value)
                        Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<GeneratedDocument> _filterAndSortDocuments(
      List<GeneratedDocument> documents) {
    // Filter by search query
    var filtered = documents;
    if (_searchQuery.isNotEmpty) {
      filtered = documents.where((doc) {
        return doc.title.toLowerCase().contains(_searchQuery) ||
            doc.templateName.toLowerCase().contains(_searchQuery) ||
            doc.fileFormat.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Sort documents
    filtered.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'name':
          result = a.title.compareTo(b.title);
          break;
        case 'type':
          result = a.fileFormat.compareTo(b.fileFormat);
          break;
        case 'date':
        default:
          result = b.createdAt.compareTo(a.createdAt); // Default newest first
      }

      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  void _handleDownload(BuildContext context, GeneratedDocument document) async {
    final provider =
        Provider.of<DocumentGeneratorProvider>(context, listen: false);
    final data = await provider.downloadDocument(document.id, document.privacy);

    if (data != null) {
      // Handle the downloaded file data
      // In a web app, we would typically trigger a browser download
      // For now, we'll just show a success message

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded ${document.title} successfully'),
            backgroundColor: AppTheme.deepOcean,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleDelete(BuildContext context, GeneratedDocument document) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${document.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              final provider = Provider.of<DocumentGeneratorProvider>(context,
                  listen: false);
              provider.deleteDocument(document.id, document.privacy);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${document.title}'),
                  backgroundColor: AppTheme.infoSapphire,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRuby,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
