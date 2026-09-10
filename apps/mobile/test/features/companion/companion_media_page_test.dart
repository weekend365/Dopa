import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/application/companion_media.dart';
import 'package:dopa/features/companion/application/companion_media_controller.dart';
import 'package:dopa/features/companion/presentation/companion_experience_page.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'companion_media_controller_test.dart'
    show FakePlayback, MediaRepository;

void main() {
  testWidgets(
    '200% long captions, background playback, explicit text fallback and result',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MediaRepository()
        ..active = CompanionRun(
          id: 'media',
          contentId: 'desk_space',
          contentVersion: 2,
          startedAtUtc: DateTime.utc(2026, 9, 10),
          startedLocalDate: LocalDate(2026, 9, 10),
          stepCount: 4,
          guidanceMode: CompanionGuidanceMode.humanMedia,
        );
      final port = FakePlayback();
      const longCaption =
          '종이를 한쪽에 모아봐요. 지금 분류하거나 버릴 것을 정하지 않아도 괜찮아요. 천천히 시작해도 좋아요.';
      const media = CompanionMedia(
        video: 'fake.mp4',
        poster: 'fake.jpg',
        captions: 'WEBVTT\n\n00:00:00.000 --> 00:00:10.000\n$longCaption\n',
        durationMs: 120000,
        stepStarts: [0, 30000, 60000, 90000],
      );
      final container = ProviderContainer(
        overrides: [
          companionRepositoryProvider.overrideWithValue(repo),
          companionMediaProvider.overrideWith((ref) async => media),
          companionPlaybackFactoryProvider.overrideWithValue(() => port),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const CompanionExperiencePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(longCaption), findsOneWidget);
      expect(tester.takeException(), isNull);
      final controller = container.read(
        companionMediaControllerProvider.notifier,
      );
      final playing = controller.play();
      await tester.pump();
      await playing;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(port.current.playing, true);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final fallingBack = controller.fallback();
      await tester.pump();
      await fallingBack;
      await tester.pumpAndSettle();
      expect(find.text(longCaption), findsNothing);
      expect(repo.active!.guidanceMode, CompanionGuidanceMode.textFallback);
      final finishing = controller.finish();
      await tester.pump();
      await finishing;
      await tester.pumpAndSettle();
      expect(repo.records, isEmpty);
      expect(find.text('하려던 만큼 했어요'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(controller.shutdown);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await port.events.close();
      await port.control.close();
    },
  );
}
