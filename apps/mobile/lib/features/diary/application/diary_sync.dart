import 'dart:async';

import 'package:dopa/app/router/dopa_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'diary_controller.dart';

/// Mounted only inside the age/consent-gated app, never during onboarding.
class DiarySync extends ConsumerStatefulWidget {
  const DiarySync({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<DiarySync> createState() => _DiarySyncState();
}

class _DiarySyncState extends ConsumerState<DiarySync>
    with WidgetsBindingObserver {
  Timer? timer;
  bool syncing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(recoverPhoto());
    unawaited(sync());
    timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => unawaited(sync()),
    );
  }

  Future<void> recoverPhoto() async {
    try {
      final controller = ref.read(diaryControllerProvider);
      final photo = await controller.picker.recover();
      if (photo == null || !mounted) return;
      final day = diaryDay(controller.now());
      if (await controller.repository.forDay(day) != null) return;
      final id = await controller.save(photo: photo, body: '', day: day);
      if (mounted) ref.read(dopaRouterProvider).push('/diary/entry/$id');
    } on Object {
      // No background permission prompts or uploads. The picker can be reopened.
    }
  }

  Future<void> sync() async {
    if (syncing ||
        !mounted ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      return;
    }
    syncing = true;
    try {
      final controller = ref.read(diaryControllerProvider);
      final ids = await controller.repository.pendingIds();
      for (final id in ids) {
        if (!mounted) break;
        try {
          await controller.refresh(id);
        } on Object {
          /* persisted job remains recoverable on next foreground pass */
        }
      }
    } on Object {
      // The account scope can close the DB during full deletion. No retry is
      // scheduled outside the consent-gated widget's lifetime.
    } finally {
      syncing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(sync());
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
