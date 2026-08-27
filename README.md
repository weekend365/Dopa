# Dopa

Dopa는 자극적인 디지털 행동을 알아차리고 스스로 조절하도록 돕는 한국형 디지털 웰빙 앱입니다. 현재 저장소에는 Flutter MVP의 도메인·로컬 저장소·화면 구현과 제품/출시 계약이 함께 있습니다.

## 현재 구현 범위

- `apps/mobile`: Today, 집중 진행/완료, 주간 리포트와 ‘평생 한 그루’ Flutter UI
- `packages/domain`: 집중 세션, 하루 1회 성장 지급, 느티나무 성장 단계의 순수 Dart 규칙
- `packages/local_storage`: 세션 완료와 성장 원장을 원자적으로 기록하는 Drift 저장소
- `apps/mobile/assets/tree`: Light/Dark 정적 느티나무 스프라이트 fallback
- `docs`: MVP Scope Freeze v1.2, ADR, Apple 출시 및 개인정보 계약

Rive 원본 에셋은 전문 원화/리깅 납품 후 연결합니다. 그 전까지 `tree_rive_enabled`는 기본 OFF이며 정적 스프라이트가 제품 fallback입니다. 나무와 세션 연결 정보는 MVP에서 기기 로컬에만 저장합니다.

현재 `DopaRoot`가 연령 확인·로그인·동의 게이트를 담당하고, `DopaApp`은 그 뒤에
마운트되는 authenticated app shell입니다. 씨앗은
`LocalAccountDataLifecycle.initializeAfterLoginAndConsent`가 동의 완료 시에만
만듭니다. 로그아웃·계정 삭제는 `deleteForLogoutOrAccountDeletion`으로
나무·세션·성장 원장을 지운 뒤 account scope를 폐기합니다. Apple·Google
로그인 SDK는 `SignInPort` 뒤에 연결하며, 현재 기본 구현은 버튼 탭을 성공으로
처리합니다. 재부팅 뒤에도 계획 시간이 남아 있으면 집중을 재개하고, 끝난 지
1시간 안이면 완료를 허용하며, 그보다 오래됐거나 시계가 시작보다 이전이면
`invalidRecovery`로 닫고 원래 하려던 일만 남깁니다. 7일 실험은 동의 직후
시작하고, 시도한 날은 세션 시작 날짜로 집계하며 체크인 답변은 성장에
영향을 주지 않습니다.

## 출시 전 남은 통합 게이트

- Apple·Google 로그인 SDK를 `SignInPort`에 연결해야 합니다. 로컬 연령 확인·동의·로그아웃·삭제는 연결되어 있습니다.
- Remote Config를 현재 provider/lifecycle 경계에 연결해야 합니다.
- 전문 Rive 원본·상업적 사용권을 납품받은 뒤 데이터 바인딩, 비동기 실패 폴백, 성능 예산을 통과하기 전까지 `tree_rive_enabled`는 OFF로 유지해야 합니다.
- Golden baseline, 실기기 VoiceOver/TalkBack·200% 글자, 네트워크 캡처, 느린 프레임, 성인 10명 사용성 검증은 출시 차단 게이트로 남아 있습니다.

## 고정 도구 버전

- Flutter `3.47.0` (`.fvmrc`)
- Dart `3.13.0` (위 Flutter SDK에 포함)

FVM 사용을 권장합니다. 다른 Flutter/Dart 버전에서는 의존성 해석이나 생성 코드가 달라질 수 있으므로 작업 전에 `flutter --version`과 `dart --version`을 확인합니다.

## 시작하기

Flutter SDK와 FVM이 설치된 환경에서 저장소 루트 기준으로 실행합니다.

```bash
fvm use 3.47.0
fvm flutter pub get
cd apps/mobile
fvm flutter run
```

FVM을 사용하지 않는다면 PATH에 Flutter `3.47.0`을 선택한 뒤 `flutter pub get`을 실행합니다. iOS/Android host 프로젝트가 아직 없다면 macOS에서 다음 명령으로 생성합니다.

```bash
bash tooling/bootstrap_mobile_macos.sh
```

이 스크립트는 로컬 FVM SDK를 우선 사용해 Flutter/Dart/Xcode 버전을 확인하고 기존 Dart 소스를 유지한 채 누락된 iOS·Android host를 생성한 다음, 저장소 루트의 workspace 의존성을 해석합니다.

## 개발 명령

```bash
# Drift 생성 코드 갱신
dart run melos run codegen

# 전체 정적 분석 및 포맷 확인
dart run melos run analyze
dart run melos run format

# 패키지별 또는 전체 테스트
dart run melos run test:domain
dart run melos run test:storage
dart run melos run test:mobile
dart run melos run test

# 저장소 계약 검사
pwsh tooling/validate_apple_identifiers.ps1
pwsh tooling/validate_tree_assets.ps1
```

Drift 스키마를 변경한 경우 `codegen` 결과인 `packages/local_storage/lib/src/database/dopa_database.g.dart`도 함께 커밋해야 합니다. CI는 생성 코드를 다시 만든 뒤 diff가 없는지 검사합니다.

## 주요 문서

- [MVP Scope Freeze v1.2](docs/product/MVP_SCOPE_FREEZE_V1_KO.md)
- [통합 제품·사업 구상안](docs/DOPA_INTEGRATED_PRODUCT_PLAN_KO.md)
- [로컬 나무 동반자 ADR](docs/adr/0002-local-tree-companion.md)
- [프로젝트 개발 규칙](docs/PROJECT_RULES_KO.md)
- [1인 개발자 Apple 출시 런북](docs/platform/apple/APPLE_LAUNCH_RUNBOOK_KO.md)
- [Apple 외부 작업 체크리스트](docs/platform/apple/EXTERNAL_ACTION_CHECKLIST_KO.md)

## 확정된 Apple 식별자

- 운영 앱: `com.devnamu.dopa`
- 운영 App Group: `group.com.devnamu.dopa`
- 개발 앱: `com.devnamu.dopa.dev`
- 개발 App Group: `group.com.devnamu.dopa.dev`

전체 앱·확장·구독 식별자는 [apple-identifiers.json](config/apple-identifiers.json)을 단일 진실 원천으로 사용합니다.

> Dopa는 의료기기가 아니며 질환을 진단·치료·치유·예방하지 않습니다. 여기서 말하는 ‘도파민 디톡스’는 뇌의 도파민을 제거하거나 초기화한다는 뜻이 아닙니다.
