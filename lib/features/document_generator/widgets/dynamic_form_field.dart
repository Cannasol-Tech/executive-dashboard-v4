import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/document_template.dart';

class DynamicFormField extends StatelessWidget {
  final DocumentField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const DynamicFormField({
    Key? key,
    required this.field,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case 'text':
        return _buildTextField(context);
      case 'number':
        return _buildNumberField(context);
      case 'date':
        return _buildDateField(context);
      case 'boolean':
        return _buildBooleanField(context);
      case 'dropdown':
        return _buildDropdownField(context);
      case 'multiline':
        return _buildMultilineField(context);
      case 'email':
        return _buildEmailField(context);
      case 'phone':
        return _buildPhoneField(context);
      case 'url':
        return _buildUrlField(context);
      default:
        return _buildTextField(context);
    }
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      validator: field.required
          ? (value) =>
              (value == null || value.isEmpty) ? 'This field is required' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Please enter a valid number';
          }
          // Check min/max if defined in options
          if (field.options['min'] != null && number < field.options['min']) {
            return 'Value must be at least ${field.options['min']}';
          }
          if (field.options['max'] != null && number > field.options['max']) {
            return 'Value must be at most ${field.options['max']}';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final DateTime currentValue = value is DateTime
        ? value
        : (value is String && value.isNotEmpty)
            ? DateTime.tryParse(value) ?? DateTime.now()
            : DateTime.now();

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentValue,
          firstDate: field.options['minDate'] != null
              ? DateTime.parse(field.options['minDate'])
              : DateTime(1900),
          lastDate: field.options['maxDate'] != null
              ? DateTime.parse(field.options['maxDate'])
              : DateTime(2100),
        );
        if (date != null) {
          onChanged(date.toIso8601String().split('T')[0]);
        }
      },
      child: InputDecorator(
        decoration: _getInputDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null && value.isNotEmpty
                  ? _formatDate(value)
                  : 'Select a date',
              style: value != null && value.isNotEmpty
                  ? null
                  : TextStyle(color: AppTheme.textSecondaryColor),
            ),
            Icon(
              Icons.calendar_today,
              color: AppTheme.textSecondaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanField(BuildContext context) {
    final bool isChecked = value == true;

    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) => onChanged(value),
        ),
        Expanded(
          child: Text(
            field.label,
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context) {
    final options = field.options['values'] as List<dynamic>? ?? [];

    return DropdownButtonFormField<String>(
      decoration: _getInputDecoration(context),
      value: value?.toString(),
      items: options.map((option) {
        final optionValue = option is Map ? option['value'] : option.toString();
        final optionLabel = option is Map ? option['label'] : option.toString();

        return DropdownMenuItem<String>(
          value: optionValue,
          child: Text(optionLabel),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
      validator: field.required
          ? (value) => value == null ? 'This field is required' : null
          : null,
      isExpanded: true,
    );
  }

  Widget _buildMultilineField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      maxLines: field.options['maxLines'] ?? 5,
      validator: field.required
          ? (value) =>
              (value == null || value.isEmpty) ? 'This field is required' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty) {
          final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]+$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildUrlField(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: _getInputDecoration(context),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty) {
          final urlRegex = RegExp(r'^(http|https)://');
          if (!urlRegex.hasMatch(value)) {
            return 'Please enter a valid URL (starting with http:// or https://)';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: field.label + (field.required ? ' *' : ''),
      fillColor: AppTheme.secondaryColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.errorRuby),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}
