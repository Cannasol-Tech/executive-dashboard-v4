import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/providers/email_provider.dart';
import '../../../models/email.dart';
import '../../../models/email_task.dart';
import 'task_item_widget.dart';

class EmailListItem extends StatefulWidget {
  final Email email;
  final bool isSelected;
  final Function(bool) onSelect;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const EmailListItem({
    Key? key,
    required this.email,
    required this.isSelected,
    required this.onSelect,
    required this.onTap,
    this.isSmallScreen = false,
  }) : super(key: key);

  @override
  State<EmailListItem> createState() => _EmailListItemState();
}

class _EmailListItemState extends State<EmailListItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _aiResponseController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  List<EmailTask>? _tasks;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _aiResponseController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    if (_isExpanded && _tasks == null && !_isLoadingTasks) {
      setState(() {
        _isLoadingTasks = true;
      });

      final emailProvider = Provider.of<EmailProvider>(context, listen: false);
      await emailProvider.fetchTasksForEmail(widget.email.id);

      setState(() {
        _tasks = emailProvider.tasks;
        _isLoadingTasks = false;
        if (widget.email.aiResponse != null) {
          _aiResponseController.text = widget.email.aiResponse!;
        }
      });
    }
  }

  Color _getStatusColor(EmailStatus status) {
    switch (status) {
      case EmailStatus.pending:
        return Colors.grey;
      case EmailStatus.responded:
        return AppTheme.infoSapphire;
      case EmailStatus.approved:
        return AppTheme.successEmerald;
      case EmailStatus.rejected:
        return AppTheme.warningAmber;
    }
  }

  IconData _getStatusIcon(EmailStatus status) {
    switch (status) {
      case EmailStatus.pending:
        return Icons.pending_outlined;
      case EmailStatus.responded:
        return Icons.mark_email_read;
      case EmailStatus.approved:
        return Icons.thumb_up_outlined;
      case EmailStatus.rejected:
        return Icons.thumb_down_outlined;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Medium';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.green;
      default:
        return Colors.orangeAccent;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _loadTasks();
      }
    });
  }

  void _updateTask(EmailTask updatedTask) {
    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    emailProvider.updateTask(updatedTask);
  }

  void _deleteTask(String taskId) {
    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    emailProvider.deleteTask(taskId);
  }

  void _addNewTask() {
    if (_taskTitleController.text.isEmpty) return;

    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    final newTask = EmailTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      title: _taskTitleController.text,
      description: _taskDescriptionController.text,
      sourceEmailId: widget.email.id,
      createdDate: DateTime.now(),
      status: TaskStatus.todo,
    );

    emailProvider.addTask(newTask);
    _taskTitleController.clear();
    _taskDescriptionController.clear();
  }

  void _updateAiResponse() {
    if (_aiResponseController.text != widget.email.aiResponse) {
      final emailProvider = Provider.of<EmailProvider>(context, listen: false);
      emailProvider.updateAiResponse(
          widget.email.id, _aiResponseController.text);
    }
  }

  void _approveAiResponse() {
    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    emailProvider.approveAiResponse(widget.email.id);
  }

  void _rejectAiResponse() {
    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    emailProvider.rejectAiResponse(widget.email.id);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    // Update hover animation state
    if (_isHovered &&
        !_controller.isAnimating &&
        _controller.status != AnimationStatus.completed) {
      _controller.forward();
    } else if (!_isHovered &&
        !_controller.isAnimating &&
        _controller.status != AnimationStatus.dismissed) {
      _controller.reverse();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
              horizontal: 16.0 + (_animation.value * 4), vertical: 4.0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.royalAzure.withOpacity(0.15)
                : _isHovered
                    ? AppTheme.deepOcean.withOpacity(0.5)
                    : AppTheme.obsidian.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.royalAzure
                  : _isHovered
                      ? AppTheme.emeraldGleam.withOpacity(0.3)
                      : Colors.transparent,
              width: widget.isSelected || _isHovered ? 1 : 0,
            ),
            boxShadow: _isHovered || widget.isSelected || _isExpanded
                ? [
                    BoxShadow(
                      color: widget.isSelected
                          ? AppTheme.royalAzure.withOpacity(0.15)
                          : AppTheme.deepOcean.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // Main email item
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppTheme.emeraldGleam.withOpacity(0.1),
                highlightColor: AppTheme.emeraldGleam.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection checkbox
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: widget.isSelected,
                            onChanged: (value) =>
                                widget.onSelect(value ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: _isHovered || widget.isSelected
                                  ? AppTheme.emeraldGleam
                                  : AppTheme.moonlight.withOpacity(0.5),
                              width: 1.5,
                            ),
                            activeColor: AppTheme.emeraldGleam,
                          ),
                        ),
                      ),

                      // Read/unread indicator and priority
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                        child: Column(
                          children: [
                            // Read/unread indicator
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: email.isRead
                                    ? Colors.transparent
                                    : AppTheme.emeraldGleam,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Priority indicator
                            Container(
                              width: 8,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _getPriorityColor(email.priority)
                                    .withOpacity(
                                  email.priority == 1 ? 0.8 : 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Email content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row with sender and date
                              Row(
                                children: [
                                  // Sender info
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: email.senderName.isNotEmpty
                                                ? email.senderName
                                                : email.senderEmail,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: email.isRead
                                                  ? AppTheme.moonlight
                                                      .withOpacity(0.7)
                                                  : AppTheme.moonlight,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (email.senderName.isNotEmpty)
                                            TextSpan(
                                              text: ' <${email.senderEmail}>',
                                              style: TextStyle(
                                                color: AppTheme.moonlight
                                                    .withOpacity(0.5),
                                                fontSize: 14,
                                              ),
                                            ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Date
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 16.0),
                                    child: Text(
                                      email.formattedDate,
                                      style: TextStyle(
                                        color:
                                            AppTheme.moonlight.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Subject
                              Text(
                                email.subject,
                                style: TextStyle(
                                  fontWeight: email.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                  fontSize: 15,
                                  color: email.isRead
                                      ? AppTheme.moonlight.withOpacity(0.8)
                                      : AppTheme.moonlight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              // Email body snippet only when not expanded
                              if (!_isExpanded)
                                Text(
                                  email.snippet,
                                  style: TextStyle(
                                    color: AppTheme.moonlight.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              const SizedBox(height: 8),

                              // Footer row with status, tags, and icons
                              Row(
                                children: [
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(email.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getStatusColor(email.status)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(email.status),
                                          size: 12,
                                          color: _getStatusColor(email.status),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          email.status.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                _getStatusColor(email.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Spam indicator if applicable
                                  if (email.isSpam)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.errorRuby.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.errorRuby
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.report_gmailerrorred,
                                            size: 12,
                                            color: AppTheme.errorRuby,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Spam',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.errorRuby,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(width: 8),

                                  // Tags
                                  if (email.tags != null &&
                                      email.tags!.isNotEmpty)
                                    ...email.tags!.take(1).map((tag) =>
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.warningAmber
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '#$tag',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.warningAmber,
                                            ),
                                          ),
                                        )),

                                  // Count of additional tags
                                  if (email.tags != null &&
                                      email.tags!.length > 1)
                                    Text(
                                      '+${email.tags!.length - 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppTheme.moonlight.withOpacity(0.5),
                                      ),
                                    ),

                                  const Spacer(),

                                  // Icons for attachments, priority etc
                                  if (email.hasAttachments)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.attachment,
                                        size: 16,
                                        color:
                                            AppTheme.moonlight.withOpacity(0.5),
                                      ),
                                    ),

                                  if (email.priority == 1)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Tooltip(
                                        message: 'High Priority',
                                        child: Icon(
                                          Icons.priority_high,
                                          size: 16,
                                          color:
                                              _getPriorityColor(email.priority),
                                        ),
                                      ),
                                    ),

                                  // Expand/collapse icon
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(
                                      _isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 20,
                                      color:
                                          AppTheme.moonlight.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded view
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: _buildExpandedView(context),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.deepOcean.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email content section
          _buildSection(
            'Email Content',
            Icons.email_outlined,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.deepOcean.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.moonlight.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    widget.email.body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.moonlight.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // AI Response section
          _buildSection(
            'AI Generated Response',
            Icons.smart_toy_outlined,
            _isLoadingTasks
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (widget.email.status == EmailStatus.pending)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.deepOcean.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.moonlight.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            'AI is currently generating a response for this email...',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.moonlight.withOpacity(0.7),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            TextField(
                              controller: _aiResponseController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: AppTheme.deepOcean.withOpacity(0.2),
                                hintText: 'AI response content...',
                                hintStyle: TextStyle(
                                  color: AppTheme.moonlight.withOpacity(0.4),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.moonlight.withOpacity(0.9),
                              ),
                              onChanged: (value) {
                                // Enable live editing but don't save until button press
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Update AI Response button
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.update),
                                  label: const Text('Update Response'),
                                  onPressed: _updateAiResponse,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.infoSapphire,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Approve button
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.thumb_up),
                                  label: const Text('Approve'),
                                  onPressed: _approveAiResponse,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.successEmerald,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Reject button
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.thumb_down),
                                  label: const Text('Reject'),
                                  onPressed: _rejectAiResponse,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.warningAmber,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
          ),

          const SizedBox(height: 16),

          // Tasks section
          _buildSection(
            'AI Extracted Tasks',
            Icons.task_outlined,
            _isLoadingTasks
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Task list
                      if (_tasks != null && _tasks!.isNotEmpty)
                        ...(_tasks!
                            .map(
                              (task) => TaskItemWidget(
                                task: task,
                                onUpdate: _updateTask,
                                onDelete: () => _deleteTask(task.id),
                              ),
                            )
                            .toList())
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.deepOcean.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.moonlight.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            'No tasks have been extracted from this email yet.',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.moonlight.withOpacity(0.7),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Add new task section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.deepOcean.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.emeraldGleam.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Task',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _taskTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Task Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _taskDescriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _addNewTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.emeraldGleam,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Add Task'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppTheme.emeraldGleam,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        // Section content
        content,
      ],
    );
  }
}
