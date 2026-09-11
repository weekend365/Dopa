import 'package:dopa/app/presentation/rest_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

void main() {
  testWidgets(
    'silent rest computes elapsed time on resume and has no countdown',
    (t) async {
      var now = DateTime(2026, 9, 11, 12);
      await t.pumpWidget(TestApp(home: RestPage(clock: () => now)));
      await t.tap(find.text('1분 쉬기 시작'));
      await t.pump();
      expect(find.text('01:00'), findsNothing);
      expect(find.text('마치기'), findsOneWidget);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 2));
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      expect(find.text('조금 더 쉬어도 괜찮아요.'), findsOneWidget);
      expect(find.text('같이 시작하기'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(TestApp(home: RestPage(clock: () => now)));
      expect(find.text('1분 쉬기 시작'), findsOneWidget);
    },
  );
}
