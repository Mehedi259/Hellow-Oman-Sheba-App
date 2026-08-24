import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class MarketForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const MarketForm({super.key, required this.onSuccess});
  @override
  ConsumerState<MarketForm> createState() => _MarketFormState();
}

class _MarketFormState extends ConsumerState<MarketForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final conditionController = TextEditingController(text: 'New');
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    conditionController.dispose();
    cityController.dispose();
    areaController.dispose();
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
      await repo.createMarketItem({
        'title': titleController.text,
        'description': descriptionController.text,
        'category_name': categoryController.text,
        'price': priceController.text,
        'currency': 'OMR',
        'condition': conditionController.text,
        'city': cityController.text,
        'area': areaController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item posted successfully!')));
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
          _buildTextField(titleController, 'Item Title *'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(categoryController, 'Category (e.g. Electronics)')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(conditionController, 'Condition (New, Used)')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(priceController, 'Price (OMR)', isNumber: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(cityController, 'City')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(areaController, 'Area')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(descriptionController, 'Description *', maxLines: 5),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Post Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
