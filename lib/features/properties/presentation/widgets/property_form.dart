import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PropertyForm extends StatefulWidget {
  const PropertyForm({
    required this.onSubmit,
    required this.submitLabel,
    this.initialName,
    this.initialDeveloper,
    this.initialLocation,
    this.initialPrice,
    this.initialCurrency,
    this.initialHandoverDate,
    this.initialNotes,
    super.key,
  });

  final Future<void> Function(
    String name,
    String? developer,
    String? location,
    double price,
    String currency,
    DateTime? handoverDate,
    String? notes,
  ) onSubmit;
  final String submitLabel;
  final String? initialName;
  final String? initialDeveloper;
  final String? initialLocation;
  final double? initialPrice;
  final String? initialCurrency;
  final DateTime? initialHandoverDate;
  final String? initialNotes;

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _developerController = TextEditingController(text: widget.initialDeveloper);
  late final _locationController = TextEditingController(text: widget.initialLocation);
  late final _priceController = TextEditingController(text: widget.initialPrice?.toString() ?? '');
  late final _notesController = TextEditingController(text: widget.initialNotes);
  late String _selectedCurrency = widget.initialCurrency ?? 'EGP';
  late DateTime? _selectedHandoverDate = widget.initialHandoverDate;
  late bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _developerController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(labelText: 'Property Name *'),
              validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _developerController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(labelText: 'Developer'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    enabled: !_isSubmitting,
                    decoration: const InputDecoration(labelText: 'Total Price *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final num = double.tryParse(value!);
                      if (num == null || num <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    items: const [
                      DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'AED', child: Text('AED')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: _isSubmitting ? null : (value) => setState(() => _selectedCurrency = value ?? 'EGP'),
                    decoration: const InputDecoration(labelText: 'Currency'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _isSubmitting ? null : _selectHandoverDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedHandoverDate != null
                    ? DateFormat('d MMM yyyy').format(_selectedHandoverDate!)
                    : 'Handover Date (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectHandoverDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedHandoverDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedHandoverDate = date);
    }
  }

  Future<void> _submit() async {
    if ((_formKey.currentState?.validate() ?? false) && !_isSubmitting) {
      setState(() => _isSubmitting = true);
      try {
        await widget.onSubmit(
          _nameController.text,
          _developerController.text.isEmpty ? null : _developerController.text,
          _locationController.text.isEmpty ? null : _locationController.text,
          double.parse(_priceController.text),
          _selectedCurrency,
          _selectedHandoverDate,
          _notesController.text.isEmpty ? null : _notesController.text,
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}
