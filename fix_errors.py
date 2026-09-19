import os
import re

directory = "/Users/mehedihasanmridul/app/Hellow-Probash-Sheba-App/lib"

def replace_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Pattern to match basic error snackbars
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red));
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    
    modified = False
    
    lines = content.split('\n')
    for i in range(len(lines)):
        if "ScaffoldMessenger.of(context).showSnackBar" in lines[i] and ("Text('ত্রুটি: $e')" in lines[i] or "Text('Error: $e')" in lines[i]):
            # Replace it with a robust block
            indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
            replacement = f"""{indent}String errMsg = e.toString().replaceAll('Exception: ', '');
{indent}if (errMsg == 'অনুগ্রহ করে লগইন করুন') {{
{indent}  ScaffoldMessenger.of(context).showSnackBar(
{indent}    SnackBar(content: Text(errMsg), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
{indent}  );
{indent}}} else {{
{indent}  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg), backgroundColor: Colors.red));
{indent}}}"""
            lines[i] = replacement
            modified = True

    if modified:
        with open(filepath, 'w') as f:
            f.write('\n'.join(lines))
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            replace_in_file(os.path.join(root, file))

