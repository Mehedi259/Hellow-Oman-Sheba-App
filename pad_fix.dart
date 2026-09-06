import 'dart:io';

void main() {
  final file = File('lib/presentation/classifieds/classifieds_screen.dart');
  var content = file.readAsStringSync();
  
  // Replace the ending of the Column in these functions:
  // _buildJobsContent
  content = content.replaceFirst(
    "                ),\n              ],\n            ),\n          ),\n      ],\n    );",
    "                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 120),\n      ],\n    );"
  );
  
  // _buildWorkersContent
  content = content.replaceFirst(
    "                ),\n              ],\n            ),\n          ),\n      ],\n    );\n  }",
    "                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 120),\n      ],\n    );\n  }"
  );

  // _buildPropertyContent
  content = content.replaceFirst(
    "                ),\n              ],\n            ),\n          ),\n      ],\n    );",
    "                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 120),\n      ],\n    );"
  );

  // _buildVehicleContent
  content = content.replaceFirst(
    "                ),\n              ],\n            ),\n          ),\n      ],\n    );",
    "                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 120),\n      ],\n    );"
  );

  // _buildServiceContent
  content = content.replaceFirst(
    "                ),\n              ],\n            ),\n          ),\n      ],\n    );",
    "                ),\n              ],\n            ),\n          ),\n          const SizedBox(height: 120),\n      ],\n    );"
  );

  // _buildMarketContent
  content = content.replaceFirst(
    "                  ],\n                ),\n              ),\n          ],\n        );\n      },\n",
    "                  ],\n                ),\n              ),\n            const SizedBox(height: 120),\n          ],\n        );\n      },\n"
  );
  
  file.writeAsStringSync(content);
  print('Done');
}
