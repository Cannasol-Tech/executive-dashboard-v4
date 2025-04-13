import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_request.dart';
import '../models/document_template.dart';
import '../models/generator_status.dart';
import '../providers/document_generator_provider.dart';

class DocumentRequestForm extends StatefulWidget {
  const DocumentRequestForm({Key? key}) : super(key: key);

  @override
  State<DocumentRequestForm> createState() => _DocumentRequestFormState();
}

class _DocumentRequestFormState extends State<DocumentRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String? _submittedRequestId;

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentGeneratorProvider>(
      builder: (context, provider, _) {
        // If we've submitted a request and are tracking status, show the status screen
        if (_submittedRequestId != null) {
          return _buildStatusTracker(_submittedRequestId!);
        }

        // If no template is selected, show template selection
        if (!provider.hasSelectedTemplate) {
          return _buildTemplateSelection(provider);
        }

        // Otherwise, show the form for the selected template
        return _buildDocumentForm(provider);
      },
    );
  }

  Widget _buildTemplateSelection(DocumentGeneratorProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    if (provider.isLoadingTemplates) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppTheme.slate,
            ),
            const SizedBox(height: 16),
            Text(
              'No templates available',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact your administrator to add document templates',
              style: TextStyle(color: AppTheme.slate),
            ),
          ],
        ),
      );
    }

    // Group templates by category
    Map<String, List<DocumentTemplate>> categorizedTemplates = {};
    for (var template in provider.templates) {
      if (!categorizedTemplates.containsKey(template.category)) {
        categorizedTemplates[template.category] = [];
      }
      categorizedTemplates[template.category]!.add(template);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Document Template',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Render each category
          ...categorizedTemplates.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    entry.key,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final template = entry.value[index];
                    return _buildTemplateCard(template, provider);
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
      DocumentTemplate template, DocumentGeneratorProvider provider) {
    return InkWell(
      onTap: () => provider.selectTemplate(template),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.charcoal),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getTemplateIcon(template.name),
                size: 48, color: AppTheme.infoSapphire),
            const SizedBox(height: 12),
            Text(
              template.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              template.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentForm(DocumentGeneratorProvider provider) {
    final textTheme = Theme.of(context).textTheme;
    final template = provider.selectedTemplate!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: provider.clearSelectedTemplate,
                ),
                Expanded(
                  child: Text(
                    template.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              template.description,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Form fields
            ...template.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildFormField(field, provider),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Privacy selection
            Text(
              'Document Privacy',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPrivacySelector(provider),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSubmittingRequest
                    ? null
                    : () => _submitForm(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.midnight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: provider.isSubmittingRequest
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Generate Document'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
      DocumentField field, DocumentGeneratorProvider provider) {
    // Determine the current value from the provider's form data
    dynamic currentValue = provider.formData[field.name];

    switch (field.type) {
      case 'text':
        return TextFormField(
          initialValue: currentValue as String? ?? '',
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          validator: field.required
              ? (value) => value == null || value.isEmpty
                  ? 'Please enter ${field.label}'
                  : null
              : null,
          onChanged: (value) => provider.updateFormData(field.name, value),
        );

      case 'multiline':
        return TextFormField(
          initialValue: currentValue as String? ?? '',
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          validator: field.required
              ? (value) => value == null || value.isEmpty
                  ? 'Please enter ${field.label}'
                  : null
              : null,
          maxLines: 5,
          minLines: 3,
          onChanged: (value) => provider.updateFormData(field.name, value),
        );

      case 'number':
        return TextFormField(
          initialValue: currentValue != null ? currentValue.toString() : '',
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (value) => value == null || value.isEmpty
                  ? 'Please enter ${field.label}'
                  : null
              : null,
          onChanged: (value) {
            final number = double.tryParse(value);
            if (number != null) {
              provider.updateFormData(field.name, number);
            }
          },
        );

      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentValue != null
                      ? DateTime.parse(currentValue)
                      : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  provider.updateFormData(
                      field.name, pickedDate.toIso8601String().split('T')[0]);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.backgroundColor),
                  borderRadius: BorderRadius.circular(4),
                  color: AppTheme.secondaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentValue != null
                          ? _formatDate(currentValue)
                          : 'Select date',
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (field.required && currentValue == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: AppTheme.errorRuby,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );

      case 'dropdown':
        final options = field.options['items'] as List<dynamic>? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderSubtle),
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.secondaryColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: currentValue as String?,
                  hint: const Text('Select an option'),
                  items: options
                      .map((option) => DropdownMenuItem<String>(
                            value:
                                option['value'] as String? ?? option.toString(),
                            child: Text(option['label'] as String? ??
                                option.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    provider.updateFormData(field.name, value);
                  },
                ),
              ),
            ),
            if (field.required && currentValue == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Text(
                  'Please select an option',
                  style: TextStyle(
                    color: AppTheme.errorRuby,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );

      case 'checkbox':
        final bool isChecked = currentValue as bool? ?? false;
        return Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (value) {
                provider.updateFormData(field.name, value ?? false);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: Text(field.label),
            ),
          ],
        );

      default:
        return TextFormField(
          initialValue: currentValue as String? ?? '',
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          validator: field.required
              ? (value) => value == null || value.isEmpty
                  ? 'Please enter ${field.label}'
                  : null
              : null,
          onChanged: (value) => provider.updateFormData(field.name, value),
        );
    }
  }

  Widget _buildPrivacySelector(DocumentGeneratorProvider provider) {
    return Column(
      children: [
        _buildPrivacyOption(
          provider,
          DocumentPrivacy.private,
          'Private',
          'Only you can access this document',
          Icons.lock_outline,
        ),
        const SizedBox(height: 12),
        _buildPrivacyOption(
          provider,
          DocumentPrivacy.shared,
          'Shared',
          'All team members can access this document',
          Icons.group_outlined,
        ),
        const SizedBox(height: 12),
        _buildPrivacyOption(
          provider,
          DocumentPrivacy.oneTime,
          'One-time Download',
          'Document will be deleted after download',
          Icons.timelapse_outlined,
        ),
      ],
    );
  }

  Widget _buildPrivacyOption(
    DocumentGeneratorProvider provider,
    DocumentPrivacy privacy,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = provider.selectedPrivacy == privacy;

    return InkWell(
      onTap: () => provider.setPrivacy(privacy),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : AppTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: privacy,
              groupValue: provider.selectedPrivacy,
              onChanged: (_) => provider.setPrivacy(privacy),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker(String requestId) {
    final textTheme = Theme.of(context).textTheme;
    final provider =
        Provider.of<DocumentGeneratorProvider>(context, listen: false);

    // Start tracking the status
    provider.startTrackingStatus(requestId);

    return StreamBuilder<GeneratorStatus?>(
      stream: provider.getStatusStream(requestId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data;
        if (status == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRuby,
                ),
                const SizedBox(height: 16),
                Text(
                  'Status not found',
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'The document generation status could not be found.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _submittedRequestId = null;
                      provider.stopTrackingStatus(requestId);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Back to Form'),
                ),
              ],
            ),
          );
        }

        // If completed, show success message
        if (status.status == DocumentRequestStatus.completed) {
          return _buildCompletionMessage(requestId, status, provider);
        }

        // If failed, show error message
        if (status.status == DocumentRequestStatus.failed) {
          return _buildErrorMessage(requestId, status, provider);
        }

        // Otherwise, show the progress indicator
        return _buildProgressIndicator(status);
      },
    );
  }

  Widget _buildProgressIndicator(GeneratorStatus status) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: status.progressPercentage / 100,
                      strokeWidth: 10,
                      backgroundColor: AppTheme.secondaryColor,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${status.progressPercentage}%',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        status.remainingTimeString,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Generating Your Document',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            status.currentStep,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: status.progressPercentage / 100,
              backgroundColor: AppTheme.secondaryColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (status.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Card(
                color: AppTheme.secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.infoSapphire,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          status.message,
                          style: TextStyle(
                            color: AppTheme.infoSapphire,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionMessage(String requestId, GeneratorStatus status,
      DocumentGeneratorProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    // Stop tracking status when completed
    provider.stopTrackingStatus(requestId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.successEmerald,
          ),
          const SizedBox(height: 16),
          Text(
            'Document Generated Successfully',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your document has been generated and is ready to view.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submittedRequestId = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: AppTheme.textPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('New Request'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Switch to the My Documents tab
                  DefaultTabController.of(context)?.animateTo(1);
                  setState(() {
                    _submittedRequestId = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('View Document'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String requestId, GeneratorStatus status,
      DocumentGeneratorProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    // Stop tracking status when failed
    provider.stopTrackingStatus(requestId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRuby,
          ),
          const SizedBox(height: 16),
          Text(
            'Document Generation Failed',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status.message ??
                'An error occurred while generating your document.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submittedRequestId = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: AppTheme.textPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Back to Form'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submittedRequestId = null;
                  });
                  provider.clearSelectedTemplate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Choose Different Template'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm(DocumentGeneratorProvider provider) async {
    if (_formKey.currentState?.validate() ?? false) {
      final requestId = await provider.submitRequest();

      if (requestId != null) {
        setState(() {
          _submittedRequestId = requestId;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit document request'),
          ),
        );
      }
    }
  }

  IconData _getTemplateIcon(String templateName) {
    final name = templateName.toLowerCase();

    if (name.contains('invoice') || name.contains('receipt')) {
      return Icons.receipt_outlined;
    }
    if (name.contains('contract') || name.contains('agreement')) {
      return Icons.handshake_outlined;
    }
    if (name.contains('report')) {
      return Icons.assessment_outlined;
    }
    if (name.contains('letter') || name.contains('email')) {
      return Icons.email_outlined;
    }
    if (name.contains('form')) {
      return Icons.assignment_outlined;
    }
    if (name.contains('presentation')) {
      return Icons.slideshow_outlined;
    }
    if (name.contains('spreadsheet')) {
      return Icons.table_chart_outlined;
    }

    return Icons.description_outlined;
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.month}/${date.day}/${date.year}';
  }
}
