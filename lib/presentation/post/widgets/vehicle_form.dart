import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class VehicleForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const VehicleForm({super.key, required this.onSuccess});
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
      await repo.createVehicle({
        'title': titleController.text,
        'description': descriptionController.text,
        'make': makeController.text,
        'model': modelController.text,
        'price': priceController.text,
        'year': int.tryParse(yearController.text) ?? DateTime.now().year,
        'mileage': mileageController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle posted successfully!')));
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
                : const Text('Post Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
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
