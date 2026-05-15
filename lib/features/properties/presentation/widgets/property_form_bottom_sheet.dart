import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/core/theme/app_colors.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';

class PropertyFormBottomSheet extends StatefulWidget {
  final PropertyEntity? property;
  final Future<void> Function(
    String name,
    String? developer,
    String? location,
    double price,
    String currency,
    DateTime? handoverDate,
    String? notes,
  ) onSubmit;

  const PropertyFormBottomSheet({
    required this.onSubmit,
    this.property,
    super.key,
  });

  @override
  State<PropertyFormBottomSheet> createState() =>
      _PropertyFormBottomSheetState();
}

class _PropertyFormBottomSheetState extends State<PropertyFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _developerController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;
  late String _selectedCurrency;
  late DateTime? _selectedHandoverDate;
  late bool _isSubmitting;

  final _formKey = GlobalKey<FormState>();
  final _currencies = ['EGP', 'USD', 'AED', 'EUR', 'GBP', 'SAR', 'TRY'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name);
    _developerController =
        TextEditingController(text: widget.property?.developer);
    _locationController =
        TextEditingController(text: widget.property?.location);
    _priceController =
        TextEditingController(text: widget.property?.totalPrice.toString());
    _notesController = TextEditingController(text: widget.property?.notes);
    _selectedCurrency = widget.property?.currency ?? 'EGP';
    _selectedHandoverDate = widget.property?.handoverDate;
    _isSubmitting = false;
  }

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
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.property != null ? 'Edit Property' : 'Add Property',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Property Name *',
                  hintText: 'e.g., Zamalek Apartment',
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Developer
              TextFormField(
                controller: _developerController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Developer',
                  hintText: 'e.g., Emaar, Azadea',
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Zamalek, Cairo',
                ),
              ),
              const SizedBox(height: 16),

              // Price and Currency
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Total Price *',
                        hintText: '0.00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final num = double.tryParse(value!);
                        if (num == null || num <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      items: _currencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(
                                  () => _selectedCurrency = value ?? 'EGP');
                            },
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Handover Date
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

              // Notes
              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes...',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.property != null
                                ? 'Update Property'
                                : 'Add Property',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectHandoverDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedHandoverDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      setState(() => _selectedHandoverDate = date);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
