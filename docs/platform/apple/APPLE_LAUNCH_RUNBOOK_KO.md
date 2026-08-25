# Dopa 1인 개발자 Apple 출시 런북

> 기준일: 2026-08-25 KST
> 배포 주체: 개인사업자·Apple Developer Program Individual
> Account Holder·개발자·App Manager: 창업자 본인
> 운영 도메인: `devnamu.com`

## 1. 시작 상태

- Apple Developer Program Individual 멤버십은 활성 상태다.
- App Store 법적 실명 판매자 표시를 수용한다.
- Xcode 26 실행 가능한 Mac과 실제 iPhone이 있다.
- App ID와 Family Controls 배포 entitlement는 아직 만들거나 신청하지 않았다.
- 웹사이트는 있지만 도메인 이메일은 아직 없다.

따라서 D‑U‑N‑S와 조직 가입은 건너뛰고 식별자·entitlement를 Apple 작업의 최우선 경로로 둔다.

## 2. 식별자와 capability

식별자의 단일 진실 원천은 [`config/apple-identifiers.json`](../../../config/apple-identifiers.json)이다. Apple Developer, Xcode, Firebase, RevenueCat의 값을 수동 입력할 때 이 파일과 대조한다.

| 타깃 | Family Controls | App Groups | Sign in with Apple | Push | IAP |
|---|:---:|:---:|:---:|:---:|:---:|
| 메인 앱 | O | O | O | O | O |
| Activity Monitor | O | O | - | - | - |
| Activity Report | O | O | - | - | - |
| Shield Configuration | O | O | - | - | - |
| Shield Action | O | O | - | - | - |

HealthKit, 위치, 연락처, 사진, ATT는 MVP에서 활성화하지 않는다.

## 3. 포털 실행 순서

1. `Certificates, Identifiers & Profiles → Identifiers → App Groups`에서 운영 App Group을 만든다.
2. 운영 메인 앱과 확장 4개를 Explicit App ID로 만든다.
3. capability 표에 따라 각 App ID를 설정한다.
4. [`FAMILY_CONTROLS_REQUEST.md`](FAMILY_CONTROLS_REQUEST.md)의 문구로 운영 App ID 5개에 배포 entitlement를 신청한다.
5. 접수 증빙과 상태를 [`EXTERNAL_ACTION_CHECKLIST_KO.md`](EXTERNAL_ACTION_CHECKLIST_KO.md)에 기록한다.
6. App Store Connect에 앱 레코드를 생성한다.
7. Paid Apps Agreement, 세금 정보, 정산 계좌 검증을 시작한다.
8. 개발 App ID와 개발 App Group을 만든다.

## 4. App Store Connect 고정값

| 필드 | 값 |
|---|---|
| 앱 이름 | `Dopa`, 사용할 수 없으면 `Dopa: 디지털 웰빙` |
| 기본 언어 | Korean |
| Bundle ID | `com.devnamu.dopa` |
| SKU | `DOPA-IOS-001` |
| 기본 카테고리 | Productivity |
| 보조 카테고리 | Health & Fitness |
| Made for Kids | 선택하지 않음 |
| 첫 버전 출시 | Manual Release |

자체 서비스 이용 연령 만 14세 이상과 Apple 콘텐츠 연령 등급은 동일한 설정이 아니다. App Store 연령 등급 설문은 실제 콘텐츠와 기능에 맞게 별도로 답한다.

## 5. Mac에서 만들 Xcode 구조

Mac에서 저장소 루트로 이동해 다음 명령으로 기본 Flutter 프로젝트를 만든다.

```bash
bash tooling/bootstrap_mobile_macos.sh
open apps/mobile/ios/Runner.xcworkspace
```

스크립트는 macOS·Flutter·Xcode를 확인하고 기존 `apps/mobile`이 있으면 덮어쓰지 않고 중단한다. 생성 후 Xcode에서 아래 확장 타깃을 수동으로 추가한다.

```text
Runner
DeviceActivityMonitorExtension
DeviceActivityReportExtension
ShieldConfigurationExtension
ShieldActionExtension
```

- Flutter는 일반 UI와 application 상태를 담당한다.
- Swift는 FamilyControls, ManagedSettings, DeviceActivity를 담당한다.
- Activity Report와 Shield UI는 SwiftUI로 구현한다.
- iOS 최소 지원 버전은 16으로 두고 App Store 제출은 Xcode 26 이상·iOS 26 SDK 이상으로 빌드한다.
- 개발·운영 scheme은 서로 다른 Bundle ID, App Group, Firebase 프로젝트를 사용한다.
- 운영 앱과 모든 확장의 Release 프로파일에 필요한 entitlement가 있는지 아카이브 단계에서 확인한다.
- `PrivacyInfo.xcprivacy`와 포함 SDK의 privacy manifest를 검증한다.

현재 저장소 작업 환경은 Windows이고 Flutter·Dart·Xcode가 설치되어 있지 않으므로 Xcode 타깃 생성과 코드 서명은 실제 Mac에서 수행해야 한다.

## 6. 구현 순서

1. SDK 초기화 전 로컬 연령 게이트
2. Apple·Google 로그인과 동의 기록
3. Family Controls 개인 사용자 승인·거부·철회
4. 앱 1~3개 선택과 opaque token 로컬 저장
5. 5·10·25·50분 세션 state machine
6. ManagedSettings shield와 DeviceActivityMonitor
7. 이유 없는 2동작 우회
8. DeviceActivityReport 네이티브 리포트
9. 권한 거부·철회 시 timer-only 폴백
10. 구독·복원·계정 삭제

Flutter와 Swift의 계약은 `PlatformCapabilities`, `PermissionAdapter`, `FocusProtectionAdapter`, `UsageInsightsAdapter`로 나눈다. 앱 이름, Bundle ID, Screen Time token 원문을 Flutter 분석 계층이나 서버 전송 DTO로 노출하지 않는다.

## 7. 웹과 지원 채널

출시 전에 다음 HTTPS 경로를 공개한다.

```text
https://devnamu.com/dopa
https://devnamu.com/dopa/privacy
https://devnamu.com/dopa/terms
https://devnamu.com/dopa/support
https://devnamu.com/dopa/account-deletion
```

지원 주소는 `support@devnamu.com`, 개인정보 문의는 `privacy@devnamu.com`을 사용한다. 두 주소는 전달 별칭이어도 되지만 송수신 테스트를 완료해야 한다.

## 8. 출시 게이트

- 운영 앱과 확장 4개 모두 Family Controls 배포 entitlement 승인
- Release 프로비저닝 프로파일에 entitlement 포함
- 실제 iPhone에서 승인·거부·철회·재부팅·확장 종료 복구 통과
- 연령 확인 전 Firebase·RevenueCat·Analytics 네트워크 호출 0건
- 앱 선택·token·사용 기록·체크인·원본 우회 기록 외부 전송 0건
- 구독 구매·체험·갱신·취소·환불·복원 검증
- 계정 삭제와 구독 해지 경로 검증
- P0/P1 0건, crash-free sessions 99.5% 이상
- 외부 TestFlight 베타 100명 완료

심사 제출문은 [`APP_REVIEW_NOTES.md`](APP_REVIEW_NOTES.md)를 사용한다. 첫 버전은 퍼센트 phased release가 아니라 TestFlight 베타 후 Manual Release로 공개한다.
