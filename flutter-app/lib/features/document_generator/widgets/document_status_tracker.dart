import 'package:executive_dashboard/config/app_theme.dart';
import 'package:executive_dashboard/features/document_generator/providers/document_generator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_request.dart';
import '../models/generator_status.dart';
// Removed duplicate relative import as the provider is already imported via the package URI.

/// Widget that displays the real-time status of a document generation request
class DocumentStatusTracker extends StatelessWidget {
  final String requestId;

  const DocumentStatusTracker({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentGeneratorProvider>(context);

    return StreamBuilder<GeneratorStatus?>(
      stream: provider.getStatusStream(requestId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final status = snapshot.data;
        if (status == null) {
          return _buildNoStatusState();
        }

        return _buildStatusTracker(status);
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 60,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.emeraldGleam,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRuby,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error loading status: $error',
              style: TextStyle(
                color: AppTheme.errorRuby,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStatusState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: AppTheme.warningAmber,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Waiting for processing to begin...',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTracker(GeneratorStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: status.progressPercentage / 100,
          backgroundColor: AppTheme.secondaryColor,
          color: _getStatusColor(status.status),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 8),

        // Status info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status.currentStep,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            Text(
              '${status.progressPercentage}%',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),

        // Time remaining
        if (_shouldShowTimeRemaining(status)) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Estimated time: ${status.remainingTimeString}',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],

        // Error message if present
        if (status.status == DocumentRequestStatus.failed) ...[
          const SizedBox(height: 4),
          Text(
            status.message,
            style: TextStyle(
              color: AppTheme.errorRuby,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(DocumentRequestStatus status) {
    switch (status) {
      case DocumentRequestStatus.pending:
        return AppTheme.warningAmber;
      case DocumentRequestStatus.processing:
        return AppTheme.infoSapphire;
      case DocumentRequestStatus.completed:
        return AppTheme.successEmerald;
      case DocumentRequestStatus.failed:
        return AppTheme.errorRuby;
    }
  }

  bool _shouldShowTimeRemaining(GeneratorStatus status) {
    return status.status == DocumentRequestStatus.processing &&
        status.progressPercentage > 0 &&
        status.progressPercentage < 100 &&
        status.remainingTimeInSeconds! > 0;
  }
}
