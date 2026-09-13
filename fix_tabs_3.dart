import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/classifieds/classifieds_screen.dart');
  var content = file.readAsStringSync();

  // Fix VehiclesView
  content = content.replaceFirst(
    '''
class VehiclesView extends ConsumerWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('কোনো যানবাহন পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }''',
    '''
class VehiclesView extends ConsumerWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(vehiclesProvider.future);
      },
      child: state.when(
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('কোনো যানবাহন পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }'''
  );

  content = content.replaceFirst(
    '''
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      error: (e, _) => Center(child: Text('Error: \$e')),
    );
  }
}

class ServicesView extends ConsumerWidget {''',
    '''
      loading: () => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))))]),
      error: (e, _) => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: Center(child: Text('Error: \$e')))]),
      ),
    );
  }
}

class ServicesView extends ConsumerWidget {'''
  );

  file.writeAsStringSync(content);
}
