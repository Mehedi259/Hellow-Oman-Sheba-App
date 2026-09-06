import re
import glob

def replace_in_file(filepath, depth):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Add import if not exists
    import_statement = "import '" + ("../" * depth) + "widgets/custom_cached_image.dart';\n"
    if 'custom_cached_image.dart' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_statement)

    # Regex to replace Image.network(url, fit: ..., errorBuilder: ...)
    # This is a bit tricky with nested parentheses, so I'll just use manual replacements for known patterns.
    # Pattern 1
    content = re.sub(
        r'Image\.network\(\s*heroImageUrl,\s*fit:\s*BoxFit\.cover,\s*errorBuilder:\s*\(_,\s*__,\s*___\)\s*=>\s*Container\([^)]+\)\s*,\s*\n\s*\)',
        r'CustomCachedImage(imageUrl: heroImageUrl, fit: BoxFit.cover)',
        content
    )
    
    # Pattern 2
    content = re.sub(
        r'Image\.network\(\s*imgUrl,\s*fit:\s*BoxFit\.cover,\s*errorBuilder:\s*\(_,\s*__,\s*___\)\s*=>\s*Container\([^)]+\)\s*,\s*\n\s*\)',
        r'CustomCachedImage(imageUrl: imgUrl, fit: BoxFit.cover)',
        content
    )
    
    # Pattern 3
    content = re.sub(
        r'Image\.network\(\s*imgUrl,\s*fit:\s*BoxFit\.cover,\s*width:\s*double\.infinity,\s*\)',
        r'CustomCachedImage(imageUrl: imgUrl, fit: BoxFit.cover, width: double.infinity)',
        content
    )
    
    # Pattern 4 (with url expression)
    content = re.sub(
        r'Image\.network\(\s*([^\n,]+),\s*height:\s*250,\s*width:\s*double\.infinity,\s*fit:\s*BoxFit\.cover,\s*errorBuilder:\s*\([^)]*\)\s*=>\s*Container\([^)]+\),\s*\)',
        r'CustomCachedImage(imageUrl: \1, height: 250, width: double.infinity, fit: BoxFit.cover)',
        content
    )
    
    # Pattern 5
    content = re.sub(
        r'Image\.network\(\s*([^\n,]+),\s*fit:\s*BoxFit\.cover,\s*errorBuilder:\s*\([^)]*\)\s*=>\s*Container\([^)]+\),\s*\)',
        r'CustomCachedImage(imageUrl: \1, fit: BoxFit.cover)',
        content
    )
    
    # Generic replacement
    content = re.sub(
        r'Image\.network\(\s*([a-zA-Z0-9_\.!\(\)\?'': \$\{\}]+),\s*height:\s*(\d+),\s*width:\s*([^,]+),\s*fit:\s*([^,)]+),\s*\)',
        r'CustomCachedImage(imageUrl: \1, height: \2, width: \3, fit: \4)',
        content
    )
    
    with open(filepath, 'w') as f:
        f.write(content)

replace_in_file('lib/presentation/classifieds/classifieds_detail_screens.dart', 1)
replace_in_file('lib/presentation/classifieds/widgets/job_list_card.dart', 2)
replace_in_file('lib/presentation/classifieds/widgets/job_seeker_card.dart', 2)
replace_in_file('lib/presentation/news/news_detail_screen.dart', 1)
replace_in_file('lib/presentation/news/news_screen.dart', 1)

