import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/generated_document.dart';

/// A card representing a document in the documents grid view.
class DocumentCard extends StatelessWidget {
  final GeneratedDocument document;
  final Function(BuildContext, GeneratedDocument) onDownload;
  final Function(BuildContext, GeneratedDocument)? onDelete;
  final bool showUserName;

  const DocumentCard({
    Key? key,
    required this.document,
    required this.onDownload,
    this.onDelete,
    this.showUserName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Preview/Thumbnail
          _buildDocumentPreview(context),

          // Document Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Template name
                  Text(
                    document.templateName,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // File info
                  Row(
                    children: [
                      _buildFileTypeIcon(document.fileFormat),
                      const SizedBox(width: 4),
                      Text(
                        document.fileFormat.toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatFileSize(document.sizeInBytes),
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // Show username for shared documents
                  if (showUserName) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            document.userName,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // Date and action buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(document.createdAt)}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Download button
                          IconButton(
                            onPressed: () => onDownload(context, document),
                            icon: Icon(
                              Icons.download,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            tooltip: 'Download',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),

                          // Delete button (if user has permission)
                          if (onDelete != null)
                            IconButton(
                              onPressed: () => onDelete!(context, document),
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppTheme.errorRuby,
                                size: 20,
                              ),
                              tooltip: 'Delete',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.7),
              AppTheme.primaryColor.withOpacity(0.9),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: document.thumbnailUrl != null
            ? Image.network(
                document.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultThumbnail(context);
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultThumbnail(context),
              )
            : _buildDefaultThumbnail(context));
  }

  Widget _buildDefaultThumbnail(BuildContext context) {
    final fileFormat = document.fileFormat.toLowerCase();
    Color iconColor = Colors.white;
    
    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDocumentIcon(fileFormat),
              size: 40,
              color: iconColor,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              fileFormat.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeIcon(String fileFormat) {
    return Icon(
      _getDocumentIcon(fileFormat),
      size: 12,
      color: Colors.grey,
    );
  }

  IconData _getDocumentIcon(String fileFormat) {
    switch (fileFormat.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }
}
