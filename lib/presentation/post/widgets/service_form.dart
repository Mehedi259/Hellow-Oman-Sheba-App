import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class ServiceForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const ServiceForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<ServiceForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final contactInfoController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? data['title_bn'] ?? '';
      descriptionController.text = data['description'] ?? data['description_bn'] ?? '';
      categoryController.text = data['category'] ?? '';
      contactInfoController.text = data['contact_info'] ?? '';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    contactInfoController.dispose();
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
        'category': categoryController.text,
        'contact_info': contactInfoController.text,
        'status': 'PUBLISHED',
      };

      if (widget.editId != null) {
        await repo.updateService(widget.editId!, payload);
      } else {
        await repo.createService(payload);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.editId != null ? 'Service updated successfully!' : 'Service posted successfully!')));
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
          _buildTextField(titleController, 'Service Title *'),
          const SizedBox(height: 16),
          _buildTextField(categoryController, 'Category (e.g. Plumbing, Cleaning)'),
          const SizedBox(height: 16),
          _buildTextField(contactInfoController, 'Contact Information'),
          const SizedBox(height: 16),
          _buildTextField(descriptionController, 'Description *', maxLines: 5),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.editId != null ? 'Update Service' : 'Post Service', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
