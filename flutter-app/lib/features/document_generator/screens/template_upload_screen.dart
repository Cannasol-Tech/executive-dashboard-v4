import 'dart:typed_data';
import 'package:executive_dashboard/config/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:provider/provider.dart';

import '../models/document_template.dart';
import '../providers/document_generator_provider.dart';

class TemplateUploadScreen extends StatefulWidget {
  const TemplateUploadScreen({Key? key}) : super(key: key);

  @override
  State<TemplateUploadScreen> createState() => _TemplateUploadScreenState();
}

class _TemplateUploadScreenState extends State<TemplateUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late DropzoneViewController _dropzoneController;

  // Template metadata
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'General';
  final List<String> _categories = [
    'General',
    'Legal',
    'Financial',
    'Marketing',
    'Human Resources',
    'Operations',
    'Customer Service',
    'Other'
  ];

  // File data
  Uint8List? _fileData;
  String? _fileName;
  String? _fileType;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Field management
  List<DocumentField> _fields = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document Template'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload New Document Template',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a template file and configure its metadata and fields.',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - File Upload
                    Expanded(
                      flex: 1,
                      child: _buildFileUploadSection(),
                    ),
                    const SizedBox(width: 24),

                    // Right side - Template Metadata
                    Expanded(
                      flex: 1,
                      child: _buildMetadataSection(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Template fields section
              Text(
                'Template Fields',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _buildFieldsSection(),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepOcean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Uploading...'),
                            ],
                          )
                        : const Text('Upload Template'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template File',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a document template file (PDF, DOCX, XLSX, etc.)',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // Dropzone
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _fileData != null
                  ? AppTheme.successEmerald
                  : AppTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Stack(
                        children: [
                          SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Builder(
                              builder: (BuildContext context) {
                                return DropzoneView(
                                  onCreated: (controller) =>
                                      _dropzoneController = controller,
                                  onDrop: _handleFileDrop,
                                  onHover: () => setState(() {}),
                                  onLeave: () => setState(() {}),
                                  onDropMultiple: (files) =>
                                      _handleFileDrop(files?.first),
                                );
                              },
                            ),
                          ),
                          Center(
                            child: _fileData != null
                                ? _buildFilePreview()
                                : _buildDropInstructions(),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: _pickFile,
                        child: Center(
                          child: _fileData != null
                              ? _buildFilePreview()
                              : _buildDropInstructions(),
                        ),
                      ),
              ),
              if (_isUploading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppTheme.errorRuby,
                fontSize: 12,
              ),
            ),
          ),

        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Select File'),
          ),
        ),
      ],
    );
  }

  Widget _buildDropInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Drag and drop a file here',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'or click to select a file',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    IconData fileIcon;

    switch (_fileType?.toLowerCase() ?? '') {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        break;
      case 'docx':
      case 'doc':
        fileIcon = Icons.article;
        break;
      case 'xlsx':
      case 'xls':
        fileIcon = Icons.table_chart;
        break;
      case 'pptx':
      case 'ppt':
        fileIcon = Icons.slideshow;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          fileIcon,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        Text(
          _fileName ?? 'Selected File',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _fileData = null;
              _fileName = null;
              _fileType = null;
              _errorMessage = null;
            });
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Remove'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRuby,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Template Name',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a template name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description field
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.secondaryColor,
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a template description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Category field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
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
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items:
                      _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      children: [
        Expanded(
          child: _fields.isEmpty
              ? _buildEmptyFieldsState()
              : ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    return _buildFieldCard(_fields[index], index);
                  },
                ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addNewField,
          icon: const Icon(Icons.add),
          label: const Text('Add Field'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.borderSuccess,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFieldsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_list_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Fields Added Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add fields to define the structure of your template',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldCard(DocumentField field, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editField(index),
                      tooltip: 'Edit Field',
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteField(index),
                      tooltip: 'Delete Field',
                      color: AppTheme.errorRuby,
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              field.label,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFieldTypeBadge(field.type),
                const SizedBox(width: 8),
                if (field.required)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.infoSapphire.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.infoSapphire,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTypeBadge(String type) {
    Color color;

    switch (type) {
      case 'text':
        color = AppTheme.successEmerald;
        break;
      case 'multiline':
        color = AppTheme.warningAmber;
        break;
      case 'number':
        color = AppTheme.infoSapphire;
        break;
      case 'date':
        color = AppTheme.primaryColor;
        break;
      case 'dropdown':
        color = AppTheme.deepOcean;
        break;
      case 'checkbox':
        color = AppTheme.errorRuby;
        break;
      default:
        color = AppTheme.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleFileDrop(dynamic event) async {
    setState(() {
      _errorMessage = null;
      _isUploading = true;
    });

    try {
      final fileName = await _dropzoneController.getFilename(event);
      final fileType = fileName.split('.').last;
      final fileData = await _dropzoneController.getFileData(event);

      // Validate file type
      if (!_isValidFileType(fileType)) {
        setState(() {
          _errorMessage =
              'Invalid file type. Please upload a PDF, DOCX, XLSX, or other document format.';
          _isUploading = false;
        });
        return;
      }

      setState(() {
        _fileData = fileData;
        _fileName = fileName;
        _fileType = fileType;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading file: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt'
        ],
      );

      if (result != null) {
        final fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;
        final fileType = fileName.split('.').last;

        setState(() {
          _fileData = fileBytes;
          _fileName = fileName;
          _fileType = fileType;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: $e';
      });
    }
  }

  bool _isValidFileType(String fileType) {
    final validTypes = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt'
    ];
    return validTypes.contains(fileType.toLowerCase());
  }

  void _addNewField() {
    showDialog(
      context: context,
      builder: (context) => FieldEditorDialog(
        onSave: (field) {
          setState(() {
            _fields.add(field);
          });
        },
      ),
    );
  }

  void _editField(int index) {
    showDialog(
      context: context,
      builder: (context) => FieldEditorDialog(
        initialField: _fields[index],
        onSave: (field) {
          setState(() {
            _fields[index] = field;
          });
        },
      ),
    );
  }

  void _deleteField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fileData == null || _fileName == null) {
      setState(() {
        _errorMessage = 'Please select a template file';
      });
      return;
    }

    if (_fields.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one field to the template';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final provider =
          Provider.of<DocumentGeneratorProvider>(context, listen: false);

      // Simulate upload progress (in a real app, you'd track actual upload progress)
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 10;
        });
      }

      // Upload template to Firebase Storage
      final templateId = await provider.uploadTemplate(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        fileData: _fileData!,
        fileName: _fileName!,
        fields: _fields,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Template "${_nameController.text}" uploaded successfully'),
            backgroundColor: AppTheme.successEmerald,
          ),
        );

        Navigator.pop(
            context, true); // Return true to indicate successful upload
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error uploading template: $e';
      });
    }
  }
}

class FieldEditorDialog extends StatefulWidget {
  final DocumentField? initialField;
  final void Function(DocumentField) onSave;

  const FieldEditorDialog({
    Key? key,
    this.initialField,
    required this.onSave,
  }) : super(key: key);

  @override
  State<FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<FieldEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _defaultValueController = TextEditingController();
  String _selectedType = 'text';
  bool _isRequired = false;
  List<Map<String, dynamic>> _options = [];

  final List<String> _fieldTypes = [
    'text',
    'multiline',
    'number',
    'date',
    'dropdown',
    'checkbox',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialField != null) {
      _nameController.text = widget.initialField!.name;
      _labelController.text = widget.initialField!.label;
      _selectedType = widget.initialField!.type;
      _isRequired = widget.initialField!.required;

      if (widget.initialField!.defaultValue != null) {
        _defaultValueController.text =
            widget.initialField!.defaultValue.toString();
      }

      if (widget.initialField!.type == 'dropdown' &&
          widget.initialField!.options.containsKey('items')) {
        final items = widget.initialField!.options['items'] as List<dynamic>;
        _options = items.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              'label': item['label'] ?? item.toString(),
              'value': item['value'] ?? item.toString(),
            };
          } else {
            return {'label': item.toString(), 'value': item.toString()};
          }
        }).toList();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialField == null ? 'Add Field' : 'Edit Field'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Field Name (no spaces)',
                  hintText: 'e.g. firstName',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a field name';
                  }
                  if (value.contains(' ')) {
                    return 'Field name cannot contain spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Label field
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Field Label',
                  hintText: 'e.g. First Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a field label';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Field type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    // Clear default value when changing type
                    _defaultValueController.clear();
                  });
                },
                items: _fieldTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getFieldTypeDisplayName(type)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Default value
              if (_selectedType != 'dropdown')
                TextFormField(
                  controller: _defaultValueController,
                  decoration: InputDecoration(
                    labelText: 'Default Value (optional)',
                    hintText: _getDefaultValueHint(),
                  ),
                ),

              // Options for dropdown
              if (_selectedType == 'dropdown') ...[
                const SizedBox(height: 8),
                const Text('Options'),
                ..._options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: option['label'],
                            decoration: const InputDecoration(
                              labelText: 'Label',
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _options[index]['label'] = value;
                                _options[index]['value'] =
                                    _options[index]['value'] ?? value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: option['value'],
                            decoration: const InputDecoration(
                              labelText: 'Value',
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _options[index]['value'] = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              _options.removeAt(index);
                            });
                          },
                          color: AppTheme.errorRuby,
                          iconSize: 20,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _options.add({'label': '', 'value': ''});
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Option'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: AppTheme.textPrimaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Required checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isRequired,
                    onChanged: (value) {
                      setState(() {
                        _isRequired = value!;
                      });
                    },
                  ),
                  const Text('Required field'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveField,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getFieldTypeDisplayName(String type) {
    switch (type) {
      case 'text':
        return 'Text';
      case 'multiline':
        return 'Multi-line Text';
      case 'number':
        return 'Number';
      case 'date':
        return 'Date';
      case 'dropdown':
        return 'Dropdown';
      case 'checkbox':
        return 'Checkbox';
      default:
        return type.capitalize();
    }
  }

  String _getDefaultValueHint() {
    switch (_selectedType) {
      case 'text':
      case 'multiline':
        return 'Default text';
      case 'number':
        return 'e.g. 100';
      case 'date':
        return 'YYYY-MM-DD';
      case 'checkbox':
        return 'true or false';
      default:
        return '';
    }
  }

  void _saveField() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == 'dropdown' && _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one option for dropdown'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Process default value based on type
    dynamic defaultValue;
    if (_defaultValueController.text.isNotEmpty) {
      switch (_selectedType) {
        case 'number':
          defaultValue = double.tryParse(_defaultValueController.text);
          break;
        case 'checkbox':
          defaultValue = _defaultValueController.text.toLowerCase() == 'true';
          break;
        default:
          defaultValue = _defaultValueController.text;
      }
    }

    // Create field
    final field = DocumentField(
      name: _nameController.text.trim(),
      label: _labelController.text.trim(),
      type: _selectedType,
      required: _isRequired,
      defaultValue: defaultValue,
      options: _selectedType == 'dropdown' ? {'items': _options} : {},
    );

    widget.onSave(field);
    Navigator.of(context).pop();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
