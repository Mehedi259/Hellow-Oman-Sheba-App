import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class VehicleForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const VehicleForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<VehicleForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final priceController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? data['title_bn'] ?? '';
      descriptionController.text = data['description'] ?? data['description_bn'] ?? '';
      makeController.text = data['make'] ?? '';
      modelController.text = data['model'] ?? '';
      priceController.text = data['price']?.toString() ?? '';
      yearController.text = data['year']?.toString() ?? '';
      mileageController.text = data['mileage'] ?? '';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    makeController.dispose();
    modelController.dispose();
    priceController.dispose();
    yearController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    
    setState(() => isLoading = true);
    try {
      final repo = ClassifiedsRepository(ref.read(apiClientProvider));
      final payload = {
        'title': titleController.text,
        'description': descriptionController.text,
        'make': makeController.text,
        'model': modelController.text,
        'price': priceController.text,
        'year': int.tryParse(yearController.text) ?? DateTime.now().year,
        'mileage': mileageController.text,
        'status': 'PUBLISHED',
      };

      if (widget.editId != null) {
        await repo.updateVehicle(widget.editId!, payload);
      } else {
        await repo.createVehicle(payload);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.editId != null ? 'Vehicle updated successfully!' : 'Vehicle posted successfully!')));
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(titleController, 'Vehicle Title *'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(makeController, 'Make (e.g. Toyota)')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(modelController, 'Model')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(yearController, 'Year', isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(mileageController, 'Mileage (km)', isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(priceController, 'Price', isNumber: true),
          const SizedBox(height: 16),
          _buildTextField(descriptionController, 'Description *', maxLines: 5),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.editId != null ? 'Update Vehicle' : 'Post Vehicle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
