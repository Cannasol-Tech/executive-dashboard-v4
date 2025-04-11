import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/providers/email_provider.dart';

/// Panel of action buttons shown when emails are selected
class EmailActionsPanel extends StatelessWidget {
  const EmailActionsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailProvider = Provider.of<EmailProvider>(context);
    final selectedCount = emailProvider.selectedEmailIds.length;
    final selectedIds = emailProvider.selectedEmailIds.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.mark_email_read_outlined,
          label: 'Mark Read',
          tooltip: 'Mark selected emails as read',
          onPressed: () {
            emailProvider.markEmailsReadStatus(selectedIds, true);
          },
        ),
        _buildActionButton(
          icon: Icons.mark_email_unread_outlined,
          label: 'Mark Unread',
          tooltip: 'Mark selected emails as unread',
          onPressed: () {
            emailProvider.markEmailsReadStatus(selectedIds, false);
          },
        ),
        _buildActionButton(
          icon: Icons.archive_outlined,
          label: 'Archive',
          tooltip: 'Archive selected emails',
          onPressed: () {
            emailProvider.archiveSelectedEmails();
          },
        ),
        _buildActionButton(
          icon: Icons.report_outlined,
          label: 'Spam',
          tooltip: 'Mark selected emails as spam',
          onPressed: () async {
            // Show confirmation dialog for marking as spam
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Mark as Spam?'),
                content: Text(
                  'Are you sure you want to mark ${selectedCount} ${selectedCount == 1 ? 'email' : 'emails'} as spam?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRuby,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as Spam'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // Mark each selected email as spam
              for (final id in selectedIds) {
                await emailProvider.markAsSpam(id);
              }
              // Clear selection
              emailProvider.clearSelectedEmails();
            }
          },
        ),
        _buildActionButton(
          icon: Icons.delete_outline,
          label: 'Delete',
          tooltip: 'Delete selected emails',
          onPressed: () async {
            // Show confirmation dialog for delete
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete Emails?'),
                content: Text(
                  'Are you sure you want to delete ${selectedCount} ${selectedCount == 1 ? 'email' : 'emails'}?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRuby,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // We don't have a delete method yet in the provider
              // This would be implemented when needed
              emailProvider.clearSelectedEmails();
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextButton.icon(
          icon: Icon(
            icon,
            size: 20,
            color: AppTheme.moonlight,
          ),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.moonlight,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: AppTheme.obsidian.withOpacity(0.3),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
