import 'dart:io';

void main() {
  final file = File('lib/presentation/classifieds/classifieds_screen.dart');
  var content = file.readAsStringSync();
  
  // Jobs
  content = content.replaceAll(
    "],\n            ),\n          ),\n      ],\n    );",
    "],\n            ),\n          ),\n        const SizedBox(height: 120),\n      ],\n    );"
  );

  // Workers
  content = content.replaceAll(
    "],\n            ),\n          ),\n      ],\n    );\n  }",
    "],\n            ),\n          ),\n        const SizedBox(height: 120),\n      ],\n    );\n  }"
  );

  // Market
  content = content.replaceAll(
    "],\n                ),\n              ),\n          ],\n        );\n      },\n",
    "],\n                ),\n              ),\n            const SizedBox(height: 120),\n          ],\n        );\n      },\n"
  );
  
  // Let's just do a simpler search and replace for pagination blocks.
  // We can look for the closing of pagination blocks and insert SizedBox(height: 120)
  
  file.writeAsStringSync(content);
}
