import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/classifieds/classifieds_screen.dart');
  var content = file.readAsStringSync();

  // Fix PropertiesView
  content = content.replaceFirst(
    '''
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      error: (e, _) => Center(child: Text('Error: \$e')),
    );
  }
}

class VehiclesView extends ConsumerWidget {''',
    '''
      loading: () => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))))]),
      error: (e, _) => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: Center(child: Text('Error: \$e')))]),
    ),
    );
  }
}

class VehiclesView extends ConsumerWidget {'''
  );

  file.writeAsStringSync(content);
}
