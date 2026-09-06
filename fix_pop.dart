import 'dart:io';

void main() {
  final f1 = File('lib/presentation/my_listings/my_listings_screen.dart');
  var content1 = f1.readAsStringSync();
  content1 = content1.replaceAll('if (context.mounted) Navigator.pop(context);', 'if (context.mounted) Navigator.of(context, rootNavigator: true).pop();');
  content1 = content1.replaceAll('Navigator.pop(context);\n        ScaffoldMessenger.of(context)', 'Navigator.of(context, rootNavigator: true).pop();\n        ScaffoldMessenger.of(context)');
  
  // also fix _showEditPostDialog which has:
  // TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
  // Navigator.pop(context); (on save)
  content1 = content1.replaceAll('Navigator.pop(context), child: const Text(\'বাতিল\')', 'Navigator.of(context, rootNavigator: true).pop(), child: const Text(\'বাতিল\')');
  content1 = content1.replaceAll('Navigator.pop(context);\n                  try {', 'Navigator.of(context, rootNavigator: true).pop();\n                  try {');
  
  f1.writeAsStringSync(content1);
  
  final f2 = File('lib/presentation/profile/profile_screen.dart');
  var content2 = f2.readAsStringSync();
  content2 = content2.replaceAll('Navigator.pop(context); // close loading', 'Navigator.of(context, rootNavigator: true).pop(); // close loading');
  content2 = content2.replaceAll('Navigator.pop(context);\n        ScaffoldMessenger.of(context)', 'Navigator.of(context, rootNavigator: true).pop();\n        ScaffoldMessenger.of(context)');
  f2.writeAsStringSync(content2);
}
