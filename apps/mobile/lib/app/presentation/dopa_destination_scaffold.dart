import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DopaDestinationScaffold extends StatelessWidget {
  const DopaDestinationScaffold({
    required this.selectedIndex,
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });

  final int selectedIndex;
  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(top: false, child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/today');
              return;
            case 1:
              context.go('/focus');
              return;
            case 2:
              context.go('/insights/weekly');
              return;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '집중',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '인사이트',
          ),
        ],
      ),
    );
  }
}
