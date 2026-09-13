import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/profile/profile_screen.dart');
  var content = file.readAsStringSync();

  // Revert the wrong replacement
  content = content.replaceFirst(
    '  Widget build(BuildContext context, WidgetRef ref) {',
    '  Widget build(BuildContext context) {'
  );

  // Now replace only the one inside _SettingsTab
  // We can do this by splitting or regex
  final regex = RegExp(r'(class _SettingsTab extends ConsumerWidget \{[\s\S]*?)(\s*@override\s*Widget build\(BuildContext context\) \{)');
  content = content.replaceFirstMapped(regex, (match) {
    return '\${match.group(1)}\n  @override\n  Widget build(BuildContext context, WidgetRef ref) {';
  });

  file.writeAsStringSync(content);
}
