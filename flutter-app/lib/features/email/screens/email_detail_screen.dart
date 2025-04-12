import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/email_provider.dart';
import '../email.dart';
import '../email_task.dart';
import '../widgets/task_item_widget.dart';

class EmailDetailScreen extends StatefulWidget {
  final String emailId;

  const EmailDetailScreen({
    Key? key,
    required this.emailId,
  }) : super(key: key);

  static const String routeName = '/email/detail';

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _newTaskController = TextEditingController();
  late TabController _tabController;
  bool _isEditingResponse = false;
  bool _isAddingTask = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load the email details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmailProvider>(context, listen: false);
      provider.selectEmail(widget.emailId);
    });
  }

  @override
  void dispose() {
    _responseController.dispose();
    _newTaskController.dispose();
    _tabController.dispose();
    Provider.of<EmailProvider>(context, listen: false).clearSelectedEmails();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailProvider = Provider.of<EmailProvider>(context);
    final email = emailProvider.selectedEmail;
    final isLoading = emailProvider.isLoading;
    final error = emailProvider.error;
    final tasks = emailProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          email?.subject ?? 'Email Detail',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (email != null) ...[
            _buildStatusBadge(email.status),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppTheme.textPrimaryColor),
              onSelected: (value) async {
                switch (value) {
                  case 'mark_read':
                    await emailProvider.markEmailsReadStatus([email.id], true);
                    break;
                  case 'mark_unread':
                    await emailProvider.markEmailsReadStatus([email.id], false);
                    break;
                  case 'archive':
                    await emailProvider.archiveSelectedEmails();
                    Navigator.of(context).pop(); // Go back after archiving
                    break;
                  case 'spam':
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Mark as Spam?'),
                        content: const Text(
                            'Are you sure you want to mark this email as spam?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorRuby,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Mark as Spam'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await emailProvider.markAsSpam(email.id);
                      Navigator.of(context)
                          .pop(); // Go back after marking as spam
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'mark_read',
                  child: Row(
                    children: const [
                      Icon(Icons.mark_email_read_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Mark as Read'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'mark_unread',
                  child: Row(
                    children: const [
                      Icon(Icons.mark_email_unread_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Mark as Unread'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: const [
                      Icon(Icons.archive_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Archive'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'spam',
                  child: Row(
                    children: const [
                      Icon(Icons.report_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Mark as Spam'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
        backgroundColor: AppTheme.deepOcean,
        elevation: 0,
        bottom: email != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.email_outlined),
                    text: 'Email & Response',
                  ),
                  Tab(
                    icon: Icon(Icons.task_outlined),
                    text: 'Tasks',
                  ),
                ],
                indicatorColor: AppTheme.emeraldGleam,
                labelColor: AppTheme.emeraldGleam,
                unselectedLabelColor: AppTheme.moonlight.withOpacity(0.7),
              )
            : null,
      ),
      body: isLoading
          ? _buildLoadingView()
          : error != null && email == null
              ? _buildErrorView(error)
              : email == null
                  ? _buildEmailNotFoundView()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEmailResponseTab(email),
                        _buildTasksTab(email, tasks),
                      ],
                    ),
    );
  }

  Widget _buildStatusBadge(EmailStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case EmailStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        icon = Icons.pending_outlined;
        break;
      case EmailStatus.responded:
        color = AppTheme.infoSapphire;
        text = 'Response Ready';
        icon = Icons.mark_email_read;
        break;
      case EmailStatus.approved:
        color = AppTheme.successEmerald;
        text = 'Approved';
        icon = Icons.thumb_up_outlined;
        break;
      case EmailStatus.rejected:
        color = AppTheme.warningAmber;
        text = 'Rejected';
        icon = Icons.thumb_down_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailResponseTab(Email email) {
    final bool hasResponse =
        email.aiResponse != null && email.aiResponse!.isNotEmpty;

    if (!_isEditingResponse && hasResponse) {
      _responseController.text = email.aiResponse!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email metadata card
          _buildEmailInfoCard(email),
          const SizedBox(height: 24),

          // Email body
          Text(
            'Email Content',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.moonlight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.obsidian.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.obsidian.withOpacity(0.6), width: 1),
            ),
            child: SelectableText(
              email.body,
              style: TextStyle(
                color: AppTheme.moonlight.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // AI Response section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Generated Response',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.moonlight,
                ),
              ),
              if (hasResponse && email.status != EmailStatus.approved)
                OutlinedButton.icon(
                  icon: Icon(
                    _isEditingResponse ? Icons.save : Icons.edit,
                    size: 16,
                  ),
                  label: Text(_isEditingResponse ? 'Save' : 'Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.emeraldGleam,
                    side: BorderSide(
                        color: AppTheme.emeraldGleam.withOpacity(0.5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isEditingResponse) {
                        // Save changes
                        Provider.of<EmailProvider>(context, listen: false)
                            .updateAiResponse(
                                email.id, _responseController.text);
                      }
                      _isEditingResponse = !_isEditingResponse;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // AI Response content
          if (!hasResponse)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.obsidian.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending,
                    size: 48,
                    color: AppTheme.moonlight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI is generating a response...',
                    style: TextStyle(
                      color: AppTheme.moonlight.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a moment depending on the complexity of the request',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.moonlight.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            _isEditingResponse
                ? Container(
                    decoration: BoxDecoration(
                      color: AppTheme.deepOcean.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.infoSapphire.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _responseController,
                      maxLines: 10,
                      style: TextStyle(color: AppTheme.moonlight),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Edit AI response here...',
                        hintStyle: TextStyle(
                          color: AppTheme.moonlight.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.infoSapphire.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.infoSapphire.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.infoSapphire.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.smart_toy_outlined,
                                color: AppTheme.infoSapphire,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Response',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.infoSapphire,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: 'Copy to clipboard',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: email.aiResponse!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Copied to clipboard'),
                                    backgroundColor: AppTheme.successEmerald,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          email.aiResponse!,
                          style: TextStyle(
                            color: AppTheme.moonlight,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

          // Response actions
          if (hasResponse && email.status != EmailStatus.approved)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (email.status == EmailStatus.responded ||
                      email.status == EmailStatus.rejected)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.thumb_down),
                      label: const Text('Reject Response'),
                      onPressed: () {
                        Provider.of<EmailProvider>(context, listen: false)
                            .rejectAiResponse(email.id);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warningAmber,
                        side: BorderSide(
                            color: AppTheme.warningAmber.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve & Send'),
                    onPressed: () {
                      Provider.of<EmailProvider>(context, listen: false)
                          .approveAiResponse(email.id);

                      // Show a success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Email response sent successfully!'),
                          backgroundColor: AppTheme.successEmerald,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

          if (email.status == EmailStatus.approved)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              margin: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successEmerald.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.successEmerald,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Response Approved and Sent',
                    style: TextStyle(
                      color: AppTheme.successEmerald,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(Email email, List<EmailTask> tasks) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                'Tasks extracted from this email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.moonlight,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Task'),
                onPressed: () {
                  setState(() {
                    _isAddingTask = true;
                    _newTaskController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.emeraldGleam,
                  side:
                      BorderSide(color: AppTheme.emeraldGleam.withOpacity(0.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        if (_isAddingTask)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: AppTheme.deepOcean.withOpacity(0.6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppTheme.emeraldGleam.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.moonlight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newTaskController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.moonlight.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isAddingTask = false;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_newTaskController.text.isNotEmpty) {
                              final provider = Provider.of<EmailProvider>(
                                  context,
                                  listen: false);

                              final newTask = EmailTask(
                                id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                                title: _newTaskController.text,
                                description: 'Task created from email',
                                sourceEmailId: email.id,
                                createdDate: DateTime.now(),
                              );

                              provider.addTask(newTask);

                              setState(() {
                                _isAddingTask = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emeraldGleam,
                            foregroundColor: AppTheme.obsidian,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyTasksView()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskItemWidget(
                      task: task,
                      onUpdate: (updatedTask) {
                        Provider.of<EmailProvider>(context, listen: false)
                            .updateTask(updatedTask);
                      },
                      onDelete: () {
                        Provider.of<EmailProvider>(context, listen: false)
                            .deleteTask(task.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyTasksView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.deepOcean,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.emeraldGleam.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.task_outlined,
              size: 48,
              color: AppTheme.emeraldGleam.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.moonlight,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: Text(
              'No tasks have been extracted from this email yet. You can add tasks manually or wait for the AI to analyze the content.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.moonlight.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInfoCard(Email email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.deepOcean.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.obsidian.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject line
          Text(
            email.subject,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.moonlight,
            ),
          ),
          const SizedBox(height: 16),

          // From line
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.royalAzure.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: email.senderName.isNotEmpty
                      ? Text(
                          email.senderName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalAzure,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppTheme.royalAzure,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.senderName.isNotEmpty
                          ? email.senderName
                          : email.senderEmail,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.moonlight,
                      ),
                    ),
                    if (email.senderName.isNotEmpty)
                      Text(
                        email.senderEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.moonlight.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Additional metadata row
          Row(
            children: [
              // Date/time received
              Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.moonlight.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDate(email.receivedAt)} at ${_formatTime(email.receivedAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.moonlight.withOpacity(0.7),
                ),
              ),

              const SizedBox(width: 16),

              // Priority indicator
              if (email.priority == 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.priority_high,
                        size: 12,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'High Priority',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),

              // Attachments indicator
              if (email.hasAttachments) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_file,
                  size: 14,
                  color: AppTheme.moonlight.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  email.attachmentUrls != null
                      ? '${email.attachmentUrls!.length} attachments'
                      : 'Has attachments',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.moonlight.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),

          // Display attachments if any
          if (email.hasAttachments && email.attachmentUrls != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: email.attachmentUrls!.map((url) {
                  final fileName = url.split('/').last;
                  final fileExt = fileName.split('.').last.toLowerCase();

                  IconData iconData;
                  Color iconColor;

                  switch (fileExt) {
                    case 'pdf':
                      iconData = Icons.picture_as_pdf;
                      iconColor = Colors.redAccent;
                      break;
                    case 'doc':
                    case 'docx':
                      iconData = Icons.description;
                      iconColor = Colors.blueAccent;
                      break;
                    case 'xls':
                    case 'xlsx':
                      iconData = Icons.table_chart;
                      iconColor = Colors.greenAccent;
                      break;
                    case 'jpg':
                    case 'jpeg':
                    case 'png':
                    case 'gif':
                      iconData = Icons.image;
                      iconColor = Colors.purpleAccent;
                      break;
                    default:
                      iconData = Icons.insert_drive_file;
                      iconColor = Colors.orangeAccent;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.deepOcean,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.obsidian,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          iconData,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fileName.length > 20
                              ? '${fileName.substring(0, 10)}...${fileName.substring(fileName.length - 8)}'
                              : fileName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.moonlight,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emeraldGleam),
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
              'Failed to load email',
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
                    .selectEmail(widget.emailId);
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

  Widget _buildEmailNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.warningAmber,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Email Not Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.moonlight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The email you\'re looking for may have been deleted or moved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.moonlight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Inbox'),
            onPressed: () {
              Navigator.of(context).pop();
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

  // Helper for formatting date
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Helper for formatting time
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
