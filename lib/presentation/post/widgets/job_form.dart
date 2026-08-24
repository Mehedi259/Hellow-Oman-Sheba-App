import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class JobForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const JobForm({super.key, required this.onSuccess});
  @override
  ConsumerState<JobForm> createState() => _JobFormState();
}

class _JobFormState extends ConsumerState<JobForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final companyController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final typeController = TextEditingController(text: 'Full-time');
  final cityController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    companyController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    typeController.dispose();
    cityController.dispose();
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
      await repo.createJob({
        'title': titleController.text,
        'description': descriptionController.text,
        'company': companyController.text,
        'salary_min': minSalaryController.text,
        'salary_max': maxSalaryController.text,
        'salary_currency': 'OMR',
        'type': typeController.text,
        'city': cityController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
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
          _buildTextField(titleController, 'Job Title *'),
          const SizedBox(height: 16),
          _buildTextField(companyController, 'Company Name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(minSalaryController, 'Min Salary', isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(maxSalaryController, 'Max Salary', isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(typeController, 'Job Type (e.g. Full-time, Part-time)'),
          const SizedBox(height: 16),
          _buildTextField(cityController, 'City/Location'),
          const SizedBox(height: 16),
          _buildTextField(descriptionController, 'Description *', maxLines: 5),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Post Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
