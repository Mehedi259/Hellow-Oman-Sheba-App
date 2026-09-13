import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/classifieds/classifieds_screen.dart');
  var content = file.readAsStringSync();

  // Fix ServicesView
  content = content.replaceFirst(
    '''
class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.design_services_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('কোনো সার্ভিস পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }''',
    '''
class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(servicesProvider.future);
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
                        Icon(Icons.design_services_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('কোনো সার্ভিস পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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

class MarketView extends ConsumerWidget {''',
    '''
      loading: () => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))))]),
      error: (e, _) => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: Center(child: Text('Error: \$e')))]),
      ),
    );
  }
}

class MarketView extends ConsumerWidget {'''
  );

  file.writeAsStringSync(content);
}
