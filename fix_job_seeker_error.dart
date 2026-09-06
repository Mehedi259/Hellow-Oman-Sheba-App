import 'dart:io';

void main() {
  final file = File('lib/presentation/post/widgets/job_seeker_form.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:dio/dio.dart';")) {
    content = content.replaceFirst("import 'dart:io';", "import 'dart:io';\nimport 'package:dio/dio.dart';");
  }

  final targetCatchBlock = '''
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      }
    } finally {
''';

  final replacementCatchBlock = '''
    } catch (e) {
      if (mounted) {
        if (e is DioException && e.response?.statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('ইতিমধ্যেই আপনার একটি চাকরিপ্রার্থী প্রোফাইল রয়েছে।'))]),
              backgroundColor: const Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
        }
      }
    } finally {
''';

  content = content.replaceFirst(targetCatchBlock, replacementCatchBlock);
  file.writeAsStringSync(content);
  print('Fixed job seeker catch block');
}
