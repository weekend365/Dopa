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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(top: false, child: body),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selectedIndex == 2 ? 1 : 0,
      onDestinationSelected: (index) =>
          context.go(index == 0 ? '/today' : '/insights/weekly'),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny),
          label: '오늘',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: '기록',
        ),
      ],
    ),
  );
}
