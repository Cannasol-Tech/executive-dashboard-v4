import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/email_task.dart';

class TaskItemWidget extends StatefulWidget {
  final EmailTask task;
  final Function(EmailTask) onUpdate;
  final VoidCallback onDelete;

  const TaskItemWidget({
    Key? key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  bool _isHovered = false;
  late TaskStatus _selectedStatus;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedStatus = widget.task.status;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return AppTheme.infoSapphire;
      case TaskStatus.completed:
        return AppTheme.successEmerald;
      case TaskStatus.archived:
        return Colors.brown;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.archived:
        return 'Archived';
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.check_box_outline_blank;
      case TaskStatus.inProgress:
        return Icons.trending_up;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      case TaskStatus.archived:
        return Icons.archive_outlined;
    }
  }

  void _saveChanges() {
    final updatedTask = EmailTask(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      sourceEmailId: widget.task.sourceEmailId,
      createdDate: widget.task.createdDate,
      dueDate: _selectedDueDate,
      status: _selectedStatus,
      assignedTo: widget.task.assignedTo,
    );

    widget.onUpdate(updatedTask);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          color: _selectedStatus == TaskStatus.completed
              ? AppTheme.successEmerald.withOpacity(0.05)
              : _isHovered || _isEditing
                  ? AppTheme.deepOcean.withOpacity(0.5)
                  : AppTheme.obsidian.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedStatus == TaskStatus.completed
                ? AppTheme.successEmerald.withOpacity(0.3)
                : _isHovered || _isEditing
                    ? AppTheme.emeraldGleam.withOpacity(0.3)
                    : Colors.transparent,
            width: (_isHovered || _isEditing) ? 1 : 0,
          ),
          boxShadow: _isHovered || _isEditing
              ? [
                  BoxShadow(
                    color: AppTheme.deepOcean.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: _isEditing ? _buildEditingView() : _buildDisplayView(),
      ),
    );
  }

  Widget _buildDisplayView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task status icon
              GestureDetector(
                onTap: () {
                  final newStatus = _selectedStatus == TaskStatus.completed
                      ? TaskStatus.todo
                      : TaskStatus.completed;

                  setState(() {
                    _selectedStatus = newStatus;
                  });

                  // Update the task status
                  final updatedTask = EmailTask(
                    id: widget.task.id,
                    title: widget.task.title,
                    description: widget.task.description,
                    sourceEmailId: widget.task.sourceEmailId,
                    createdDate: widget.task.createdDate,
                    dueDate: widget.task.dueDate,
                    status: newStatus,
                    assignedTo: widget.task.assignedTo,
                  );

                  widget.onUpdate(updatedTask);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_selectedStatus).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(_selectedStatus),
                    color: _getStatusColor(_selectedStatus),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Task title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedStatus == TaskStatus.completed
                            ? AppTheme.moonlight.withOpacity(0.6)
                            : AppTheme.moonlight,
                        decoration: _selectedStatus == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (widget.task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.moonlight.withOpacity(0.7),
                            decoration: _selectedStatus == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Task actions
              if (_isHovered)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit task',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Delete task',
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
            ],
          ),

          // Task metadata (due date, status, assignee)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 40.0),
            child: Row(
              children: [
                // Due date if any
                if (widget.task.dueDate != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isDuesSoon(widget.task.dueDate!)
                          ? AppTheme.warningAmber.withOpacity(0.1)
                          : AppTheme.deepOcean.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event,
                          size: 12,
                          color: _isDuesSoon(widget.task.dueDate!)
                              ? AppTheme.warningAmber
                              : AppTheme.moonlight.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(widget.task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: _isDuesSoon(widget.task.dueDate!)
                                ? AppTheme.warningAmber
                                : AppTheme.moonlight.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.task.dueDate != null) const SizedBox(width: 8),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_selectedStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(_selectedStatus),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(_selectedStatus),
                    ),
                  ),
                ),

                // Show assignee if any
                if (widget.task.assignedTo != null &&
                    widget.task.assignedTo!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.royalAzure.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppTheme.royalAzure.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.task.assignedTo!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.royalAzure.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Created date
                Text(
                  'Created ${_formatCreatedDate(widget.task.createdDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.moonlight.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Description field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Status selection
          DropdownButtonFormField<TaskStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(_getStatusText(status)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Due date selection
          Row(
            children: [
              const Text('Due Date:'),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDueDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                    );

                    if (date != null) {
                      setState(() {
                        _selectedDueDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDueDate != null
                              ? _formatDueDate(_selectedDueDate!)
                              : 'No due date',
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedDueDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear due date',
                  onPressed: () {
                    setState(() {
                      _selectedDueDate = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _titleController.text = widget.task.title;
                    _descriptionController.text = widget.task.description;
                    _selectedStatus = widget.task.status;
                    _selectedDueDate = widget.task.dueDate;
                    _isEditing = false;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGleam,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate == today) {
      return 'Today';
    } else if (dueDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isDuesSoon(DateTime date) {
    final now = DateTime.now();
    final dueDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    // Consider it "due soon" if it's today or in the past
    return dueDate.compareTo(today) <= 0;
  }
}
