import 'dart:typed_data';
import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/document_generator_provider.dart';
import '../models/document_template.dart';
import '../services/document_template_service.dart';
import '../../auth/models/user_model.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:ui';

class TemplateUploadScreen extends StatefulWidget {
  const TemplateUploadScreen({Key? key}) : super(key: key);

  @override
  State<TemplateUploadScreen> createState() => _TemplateUploadScreenState();
}

class _TemplateUploadScreenState extends State<TemplateUploadScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  final List<DocumentField> _fields = [];
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDragging = false;
  bool _showPreview = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileBytes = result.files.first.bytes;
        _fileName = result.files.first.name;
        if (!_showPreview) {
          _showPreview = true;
          _animationController.forward();
        }
      });
    }
  }

  void _addField() {
    setState(() {
      _fields.add(
        DocumentField(
          name: '',
          label: '',
          type: 'text',
          required: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fileBytes == null || _fileName == null) {
        setState(() {
          _errorMessage = 'Please select a template file to upload';
        });
        return;
      }

      if (_fields.isEmpty) {
        setState(() {
          _errorMessage = 'Please add at least one field for the template';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final templateService = DocumentTemplateService();
        final user = Provider.of<UserModel>(context, listen: false);

        // Create metadata with user info
        final metadata = {
          'uploadedBy': user.uid,
          'uploadedByName': user.displayName,
          'uploadedAt': DateTime.now().toIso8601String(),
        };

        await templateService.createTemplate(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          fields: _fields,
          fileData: _fileBytes!,
          fileName: _fileName!,
          metadata: metadata,
        );

        // Also update the provider
        if (mounted) {
          final provider = Provider.of<DocumentGeneratorProvider>(context, listen: false);
          provider.refreshAllData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template uploaded successfully'),
              backgroundColor: AppTheme.successEmerald,
            ),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error uploading template: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document Template'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Upload New Document Template',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new document template with custom fields that users can fill out to generate documents',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Template Information Section
                _buildSectionTitle(context, 'Template Information'),
                const SizedBox(height: 16),
                _buildTemplateInfoSection(),
                const SizedBox(height: 32),

                // Template File Section
                _buildSectionTitle(context, 'Template File'),
                const SizedBox(height: 16),
                _buildFileUploadSection(),
                const SizedBox(height: 32),

                // File Preview Section
                if (_showPreview) 
                  FadeTransition(
                    opacity: _animation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Template Preview'),
                        const SizedBox(height: 16),
                        _buildPreviewSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                // Template Fields Section
                _buildSectionTitle(context, 'Template Fields'),
                const SizedBox(height: 8),
                Text(
                  'Define the fields that users will fill out when using this template',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildFieldsList(),
                const SizedBox(height: 16),

                // Add Field Button
                ElevatedButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimaryColor,
                    backgroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRuby.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.errorRuby,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorRuby.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorRuby,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: AppTheme.errorRuby),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Upload Template'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTemplateInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter a descriptive name for the template',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Template name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a brief description of the template',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Enter a category (e.g., Legal, HR, Marketing)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload a document template file (PDF, DOC, DOCX)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DragTarget<Object>(
              onAcceptWithDetails: (details) async {
                // Handle drop event
                if (_fileBytes != null && _fileName != null) {
                  setState(() {
                    _isDragging = false;
                    if (!_showPreview) {
                      _showPreview = true;
                      _animationController.forward();
                    }
                  });
                }
              },
              onWillAcceptWithDetails: (data) {
                setState(() {
                  _isDragging = true;
                });
                return true;
              },
              onLeave: (data) {
                setState(() {
                  _isDragging = false;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: _pickFile,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    color: _isDragging
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 40,
                            color: _isDragging
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Drag and drop or click to upload',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _isDragging
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supported formats: PDF, DOC, DOCX',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successEmerald,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'File size: ${(_fileBytes!.length / 1024).toStringAsFixed(2)} KB',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: AppTheme.errorRuby),
                      onPressed: () {
                        setState(() {
                          _fileBytes = null;
                          _fileName = null;
                          _showPreview = false;
                          _animationController.reverse();
                        });
                      },
                      tooltip: 'Remove file',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getFileIcon(),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fileName ?? 'Document Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Template fields will be replaced with user input',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Icons.description;
    
    if (_fileName!.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (_fileName!.toLowerCase().endsWith('.doc') || 
               _fileName!.toLowerCase().endsWith('.docx')) {
      return Icons.article;
    } else {
      return Icons.description;
    }
  }

  List<Widget> _buildFieldsList() {
    if (_fields.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'No fields added yet. Click "Add Field" below to create form fields for this template.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    return _fields.asMap().entries.map((entry) {
      final index = entry.key;
      final field = entry.value;

      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                      'Field #${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: AppTheme.errorRuby,
                    ),
                    onPressed: () => _removeField(index),
                    tooltip: 'Remove field',
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: field.name,
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  hintText: 'Enter a unique identifier (no spaces)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field name is required';
                  }
                  if (value.contains(' ')) {
                    return 'Field name should not contain spaces';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _fields[index] = DocumentField(
                      name: value,
                      label: field.label,
                      type: field.type,
                      required: field.required,
                      options: field.options,
                      defaultValue: field.defaultValue,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: field.label,
                decoration: const InputDecoration(
                  labelText: 'Field Label',
                  hintText: 'Enter a user-friendly label',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field label is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _fields[index] = DocumentField(
                      name: field.name,
                      label: value,
                      type: field.type,
                      required: field.required,
                      options: field.options,
                      defaultValue: field.defaultValue,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: field.type,
                      decoration: const InputDecoration(
                        labelText: 'Field Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        'text',
                        'textarea',
                        'number',
                        'date',
                        'select',
                        'checkbox',
                      ].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _fields[index] = DocumentField(
                            name: field.name,
                            label: field.label,
                            type: value,
                            required: field.required,
                            options: field.options,
                            defaultValue: field.defaultValue,
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: field.required,
                        onChanged: (value) {
                          setState(() {
                            _fields[index] = DocumentField(
                              name: field.name,
                              label: field.label,
                              type: field.type,
                              required: value ?? false,
                              options: field.options,
                              defaultValue: field.defaultValue,
                            );
                          });
                        },
                      ),
                      const Text('Required'),
                    ],
                  ),
                ],
              ),
              if (field.type == 'select')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    initialValue: field.options.values.join(', '),
                    decoration: const InputDecoration(
                      labelText: 'Options (comma-separated)',
                      hintText: 'Enter options separated by commas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                    onChanged: (value) {
                      final optionsList = value
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      final optionsMap = { for (var option in optionsList) option: option };
                      setState(() {
                        _fields[index] = DocumentField(
                          name: field.name,
                          label: field.label,
                          type: field.type,
                          required: field.required,
                          options: optionsMap,
                          defaultValue: field.defaultValue,
                        );
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: field.defaultValue?.toString() ?? '',
                decoration: InputDecoration(
                  labelText: 'Default Value (Optional)',
                  hintText: 'Enter a default value for this field',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.settings),
                  helperText: field.type == 'date'
                      ? 'Use YYYY-MM-DD format'
                      : field.type == 'checkbox'
                          ? 'Use "true" or "false"'
                          : null,
                ),
                onChanged: (value) {
                  dynamic defaultValue;
                  if (field.type == 'number') {
                    defaultValue = double.tryParse(value);
                  } else if (field.type == 'checkbox') {
                    defaultValue = value.toLowerCase() == 'true';
                  } else {
                    defaultValue = value;
                  }

                  setState(() {
                    _fields[index] = DocumentField(
                      name: field.name,
                      label: field.label,
                      type: field.type,
                      required: field.required,
                      options: field.options,
                      defaultValue: value.isEmpty ? null : defaultValue,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
