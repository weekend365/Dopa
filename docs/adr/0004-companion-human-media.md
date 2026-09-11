> 2026-09-11 개편: 아래는 역사적 결정 기록입니다. 현재 로그인·성장·에셋·화면 계약은 [정원 제품 범위](../product/GARDEN_SCOPE_KO.md), [디자인 규칙](../DESIGN_SYSTEM_KO.md), [ADR-0005](../adr/0005-local-garden-experience.md)가 대체합니다.

# ADR 0004: Bundled human companion media

Accepted implementation, 2026-09-10. Production availability remains disabled.

`video_player` is the sole audio/video engine. `audio_service` exposes lock-screen play/pause/stop without creating another player. `audio_session` requests speech audio focus and reports interruptions/noisy output. Background playback is enabled; in-app exit saves and pauses. Calls/focus loss/unplug pause without automatic resumption. The account-scoped controller initializes these SDKs only when opening a media run, drains its queue and disposes the player before account data deletion.

Platform configuration adds iOS background audio and Android media playback foreground service/wake lock. No camera/microphone permission, remote media URLs, analytics, or account identifiers are passed to the player. Notification content is the generic session title. These dependencies require native device verification before any rollout.

The bundled v2 manifest fails closed unless production assets, SHA-256 digests, rights confirmation/reference, four ordered step timestamps and duration are present. The current manifest is explicitly unready. v1 remains the text sample. Drift v5 adds position, guidance mode and a monotonic write revision. Position comes from the engine at five-second checkpoints and pause/seek/end; restore is paused. A serialized command queue, retired-player epochs and repository revision/terminal guards prevent stale writes. Outcome selection remains voluntary and idempotent. Text fallback is explicitly selected and recorded independently.

SDK references: [video background playback](https://pub.dev/documentation/video_player/latest/video_player/VideoPlayerOptions/allowBackgroundPlayback.html), [audio_service](https://pub.dev/packages/audio_service), [audio_session](https://pub.dev/packages/audio_session). Versions are pinned through the workspace lockfile. Device verification must include focus loss and iOS configuration interactions between plugins, Android foreground service launch restrictions and lock-screen stop behavior.
