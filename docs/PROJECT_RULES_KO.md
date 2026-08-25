# Dopa 프로젝트 개발 규칙

> 상태: 구현 시작 시 적용할 v0.1 초안  
> 우선순위: `반드시`는 병합·출시 게이트, `권장`은 예외 사유를 PR에 기록하면 변경 가능하다.

## MVP Scope Freeze 게이트

[MVP Scope Freeze v1](product/MVP_SCOPE_FREEZE_V1_KO.md)은 제품 구현의 최우선 기준이다.

### 반드시

- 만 14세 미만은 인증·분석·Crashlytics·Remote Config 네트워크 초기화 전에 차단한다.
- Apple·Google 로그인 성공 전 계획·사용 기록·체크인 로컬 저장소를 만들지 않는다.
- 무료 한도는 활성 계획 1개·계획당 대상 앱 3개, Plus는 계획 5개·계획당 대상 앱 3개다.
- 세션 시간은 `5, 10, 25, 50`분만 허용하고 직접 입력을 구현하지 않는다.
- 우회는 이유 입력 없이 `allowFiveMinutes`, `endSession`, `cancel`만 사용한다.
- 앱 선택·사용 기록·체크인·원본 우회 이벤트는 기기 전용이며 서버 serializer를 만들지 않는다. 별도 선택적 `focus_bypassed` 분석은 allowlist 속성만 사용한다.
- Android는 `timerOnly`를 기본으로 하고 Accessibility는 승인과 Remote Config 활성 상태를 모두 만족할 때만 사용한다.
- 첫 페이월은 두 번째 계획 또는 반복 일정을 직접 선택한 경우에만 표시한다.
- Scope Freeze 변경은 해당 문서의 버전과 승인 기록을 갱신한 뒤 구현한다.

## 1. 폴더 구조

```text
/
├─ apps/
│  └─ mobile/
│     ├─ lib/
│     │  ├─ app/                 # bootstrap, router, theme
│     │  ├─ core/                # shared failures, clock, config
│     │  └─ features/
│     │     ├─ auth/
│     │     ├─ onboarding/
│     │     ├─ usage/
│     │     ├─ focus/
│     │     ├─ challenge/
│     │     ├─ insights/
│     │     ├─ subscription/
│     │     └─ settings/
│     ├─ ios/                    # Swift plugin and extensions
│     ├─ android/                # Kotlin plugin and services
│     ├─ test/
│     └─ integration_test/
├─ packages/
│  ├─ domain/                    # pure Dart entities and use cases
│  ├─ design_system/             # tokens and accessible components
│  ├─ native_bridge/             # platform contracts and DTOs
│  └─ analytics_contract/        # event/property allowlist
├─ backend/
│  └─ functions/                 # Firebase Functions v2
├─ docs/
│  ├─ adr/
│  ├─ privacy/
│  └─ product/
├─ tooling/
└─ .github/
```

### 반드시

- 기능 코드는 `features/<feature>` 아래 `presentation/application/domain/data` 순으로 분리한다.
- `packages/domain`은 Flutter, Firebase, RevenueCat, 플랫폼 SDK에 의존하지 않는다.
- iOS Screen Time 확장과 Android service 코드는 공통 UI 코드에서 분리한다.
- 개인정보·정책·아키텍처 결정은 `docs/adr`에 기록한다.

### 권장

- 여러 기능에서 실제로 재사용되기 전에는 `core`로 이동하지 않는다.
- `utils`, `helpers`, `common` 같은 의미 없는 대형 폴더를 만들지 않는다.

## 2. 아키텍처와 의존성

```text
presentation → application → domain ← data
                               ↑
                    native adapter contracts
```

### 반드시

- Presentation은 SDK를 직접 호출하지 않고 application controller/use case를 호출한다.
- Domain은 저장 위치나 플랫폼을 모르며 repository interface만 정의한다.
- Data는 Drift, Firebase, RevenueCat, native bridge 구현을 담당한다.
- 플랫폼 기능은 `PlatformCapabilities` 결과에 따라 실행하고 OS 이름을 조건문으로 흩뿌리지 않는다.
- 모든 네이티브 보호 기능에는 `timerOnly` 폴백과 Remote Config kill switch가 있어야 한다.
- 시간 기반 기능은 주입 가능한 `Clock`을 사용한다. 테스트에서 실제 시간을 기다리지 않는다.

### 권장

- 단순 CRUD에 불필요한 use case 클래스를 강요하지 않되 개인정보·결제·세션 상태 변경은 반드시 use case를 둔다.
- 새로운 외부 SDK 추가 시 build size, privacy manifest, Data Safety, 국외 이전 영향을 ADR에 기록한다.

## 3. 파일·클래스 네이밍

### 반드시

- Dart 파일: `snake_case.dart`
- 타입·enum: `UpperCamelCase`
- 변수·함수·provider: `lowerCamelCase`
- 화면: `*_page.dart`, 재사용 UI: `*_view.dart` 또는 `*_card.dart`
- 상태 조정: `*_controller.dart`, use case: 동사형 `start_focus_session.dart`
- repository 계약: `*_repository.dart`, 구현: `*_repository_impl.dart`
- DTO는 `*Dto`, DB row는 `*Row`, domain entity는 접미사 없이 의미 있는 이름 사용
- 오류 코드는 `snake_case` 안정 문자열로 두고 사용자 문구를 오류 코드에 넣지 않는다.

### 권장

- 약어는 `Uid`, `Api`, `Ios`처럼 읽히는 형태를 사용한다.
- `Manager`, `Helper`, `Utils`는 역할이 더 정확한 이름으로 대체한다.

## 4. 상태 관리

### 반드시

- Riverpod을 사용하고 provider는 feature 경계 안에 둔다.
- 화면 상태는 `loading/data/empty/error/permissionDenied/partialData`를 구분한다.
- `0분`과 `데이터 없음`은 서로 다른 상태여야 한다.
- 장기 세션 상태의 source of truth는 메모리 provider가 아니라 로컬 repository다.
- provider에서 BuildContext, Navigator, 직접 snackbar 호출을 보관하지 않는다.

### 권장

- 일회성 UI effect는 명시적 effect stream 또는 listener로 처리한다.
- 파생 상태는 저장하지 않고 계산한다.

## 5. 에러 처리

### 반드시

- 예외를 UI까지 그대로 던지지 않고 sealed `AppFailure`로 변환한다.
- 최소 오류 범주: `permission`, `nativeUnavailable`, `dataUnavailable`, `network`, `auth`, `subscription`, `validation`, `unexpected`.
- 오류 화면은 사용자가 할 수 있는 다음 행동과 안전한 폴백을 제공한다.
- catch 후 무시하지 않는다. 예상 가능한 무시라면 이유와 계측 여부를 코드에 남긴다.
- 보호 실패 시 세션 타이머는 유지하고 사용자를 잘못된 보호 상태로 속이지 않는다.

### 권장

- 재시도는 idempotent 작업에만 지수 백오프로 적용한다.
- 동일 오류를 UI·로그·분석에 중복 발송하지 않는다.

## 6. 로깅과 분석 개인정보 규칙

### 반드시

다음 값은 로그, Crashlytics, 분석 이벤트, support bundle에 절대 넣지 않는다.

- 이메일, 이름, 정확한 생년월일, auth·receipt token
- iOS Screen Time token, Android package name, 앱 표시명
- URL·도메인, 알림·메시지·화면 텍스트
- 자유 입력, 감정·수면·위기 표현
- 우회 이유 또는 우회를 설명하는 자유 입력
- 정확한 사용 기록과 선택 앱별 시간

- 운영 로그는 `eventName`, allowlist context, stable error code만 구조화해 기록한다.
- `print`, `debugPrint`, `NSLog`, raw Logcat 호출은 production path에서 금지한다.
- 분석 이벤트와 속성은 `packages/analytics_contract` enum/typed schema로만 보낸다.
- 서버도 동일 allowlist를 검증하며 알 수 없는 속성은 저장하지 않는다.
- session replay, screen autocapture, 광고 ID 수집을 활성화하지 않는다.

### 권장

- 정확한 수치 대신 사전에 정의한 bucket을 사용한다.
- 디버깅 ID는 사용자 UID와 분리하고 주기적으로 회전한다.

## 7. 환경 변수와 시크릿

### 반드시

- 시크릿은 GitHub/Codemagic/Firebase secret store에 저장한다.
- `.env`, `dart-define`, plist, manifest는 공개 가능한 설정 전달 수단일 뿐 비밀 저장소로 간주하지 않는다.
- 서비스 계정 JSON, signing key, API private key, webhook secret을 커밋하지 않는다.
- `.env.example`에는 키 이름과 설명만 두고 실제 값·비슷한 샘플 토큰을 넣지 않는다.
- 개발·staging·production Firebase 프로젝트와 스토어 상품을 분리한다.
- 유출이 의심되면 즉시 키를 회전하고 사고 기록을 남긴다.

### 권장

- 로컬 개발은 최소 권한의 별도 계정을 사용한다.
- secret scanner를 pre-commit과 CI에 둔다.

## 8. API 작성 규칙

### 반드시

- HTTPS JSON API는 `/v1`을 사용한다. 계정·동의·결제·삭제는 Firebase ID token을 검증한다.
- `/analytics/batch`는 Firebase UID를 받지 않고 App Check, 회전형 install ID, rate limit을 사용한다.
- 쓰기 API는 idempotency key를 지원한다.
- 시간은 UTC ISO 8601, 클라이언트 표시는 로컬 timezone으로 변환한다.
- 오류는 `code`, `message`, `request_id`만 반환하고 stack trace를 노출하지 않는다.
- 입력은 타입·길이·enum allowlist로 검증한다. 알 수 없는 개인정보 필드는 거부한다.
- 계정·동의·삭제·entitlement 변경은 감사 가능한 최소 이벤트를 남긴다.
- CORS, rate limit, App Check 적용 여부를 endpoint별로 명시한다.
- 앱명·사용 기록·감정을 받는 범용 payload나 자유 형식 `metadata` 필드를 만들지 않는다.

### 권장

- breaking change는 새 API 버전 또는 명시적 migration window로 제공한다.
- OpenAPI 또는 동등한 machine-readable contract를 유지한다.

## 9. 데이터 모델과 마이그레이션

### 반드시

- domain entity, API DTO, DB row를 분리한다.
- Drift schema version을 증가시키고 forward migration과 fixture test를 추가한다.
- migration 실패 시 원본 DB를 즉시 삭제하지 않는다. 복구 또는 안전한 export 경로를 검토한다.
- `DistractionTarget`과 raw usage model에는 server serializer를 구현하지 않는다.
- `DailyCheckIn`과 `InterventionEvent`에는 server serializer를 구현하지 않는다.
- `InterventionEvent`에 `reason`, `coarseReason`, `freeText` 필드를 추가하지 않는다.
- `AgeBand`, `PlanLimits`, `SessionDurationPreset`, `BypassAction`, `IntentionAlignment` 값은 Scope Freeze 계약과 일치해야 한다.
- 삭제는 DB row뿐 아니라 암호화 키, outbox, 캐시, notification schedule까지 포함한다.
- 데이터 보관기간과 TTL은 코드·인프라·처리방침에서 일치해야 한다.

### 권장

- enum은 알 수 없는 미래 값을 처리하는 `unknown` 상태를 둔다.
- 로컬 요약은 원본에서 재생성 가능하게 만든다.

## 10. 테스트 전략과 커버리지

### 반드시

- 생성 코드 제외 전체 line coverage 70% 이상
- `packages/domain`과 application 계층 85% 이상
- 금액·결제·계정 삭제·연령 계산·시간대·세션 state machine은 branch test 필수
- 만 14세 생일 전날·당일 경계와 14~17세 연례 재확인을 테스트한다.
- 로그인 취소·실패·오프라인에서 로컬 웰빙 기록이 생성되지 않는지 테스트한다.
- 무료·Plus 계획 한도, 앱 3개 한도, 두 번째 계획·반복 일정 페이월을 테스트한다.
- 5·10·25·50분 외 세션 값이 거부되는지 테스트한다.
- 이유 없는 2동작 우회와 `yes/no/skipped` 체크인 enum을 테스트한다.
- Drift migration은 이전 두 schema version에서 최신으로 올리는 테스트를 둔다.
- native adapter는 성공·거부·철회·unavailable·timeout·partial data 계약 테스트를 갖는다.
- 핵심 E2E: 온보딩, 권한 거부 폴백, 첫 집중, 우회, 7일 회고, 구매 복원, 계정 삭제
- iOS·Android 실제 기기에서 전화·지도·설정·인증 allowlist를 확인한다.
- 프록시 또는 mock transport로 금지 필드 외부 전송 0건을 검증한다.
- flaky test를 단순 retry로 숨기지 않는다. 담당자·원인·기한을 issue에 기록한다.

### 권장

- 핵심 5화면 golden test, copy snapshot, Remote Config variant contract test를 둔다.
- OEM·OS 조합을 위험 기반 device matrix로 관리한다.

## 11. 접근성 테스트

### 반드시

- VoiceOver·TalkBack으로 핵심 흐름 전체를 완료할 수 있어야 한다.
- 200% text scale에서 잘림·겹침·조작 불가가 없어야 한다.
- 텍스트·아이콘 대비는 WCAG 2.2 AA를 만족한다.
- 색만으로 완료·오류·데이터 없음을 구분하지 않는다.
- 최소 터치 영역은 iOS 44pt, Android 48dp다.
- 타이머 변경과 보호 상태는 적절한 live region/announcement로 전달하되 매초 읽지 않는다.
- Reduce Motion에서 불필요한 애니메이션을 제거한다.

### 권장

- 키보드·스위치 접근과 화면 회전·고대비 모드를 지원한다.

## 12. 코드 리뷰 체크리스트

### 반드시 확인

- 요구사항과 out-of-scope가 PR 설명과 일치하는가?
- 플랫폼 권한 거부·철회·unavailable 폴백이 있는가?
- 로그·이벤트·DTO에 금지 개인정보가 없는가?
- 위험 기능에 kill switch가 있는가?
- 오류를 0이나 성공으로 위장하지 않는가?
- 결제·삭제·연령·시간대 경계 테스트가 있는가?
- 접근성 레이블, 초점 순서, 큰 글자가 검증됐는가?
- 새 SDK·권한·데이터의 스토어·법률 영향이 기록됐는가?
- 카피가 진단·치료·효과 보장·수치심을 만들지 않는가?

### 권장 확인

- 코드가 현재 요구보다 과도하게 일반화되지 않았는가?
- PR이 리뷰 가능한 크기이며 ADR이 필요한 결정이 포함되지 않았는가?

## 13. 브랜치·커밋 규칙

### 반드시

- 보호된 `main` 브랜치에 직접 push하지 않는다.
- 브랜치: `feat/<short-name>`, `fix/<short-name>`, `chore/<short-name>`.
- Conventional Commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- 한 커밋에 시크릿·생성물·무관한 포맷 변경을 섞지 않는다.
- 최소 1명 승인과 모든 required CI 성공 후 squash merge한다.

### 권장

- 브랜치는 3일 이내 병합 가능한 크기로 유지한다.
- PR은 가급적 400 변경줄 이하로 나눈다.

## 14. PR 템플릿

실제 템플릿은 [pull_request_template.md](../.github/pull_request_template.md)를 사용한다. 최소 항목은 목적, 변경, 범위 제외, 테스트, 플랫폼 폴백, 개인정보, 접근성, 스크린샷, 출시·롤백이다.

## 15. Definition of Done

### 반드시

- acceptance criteria를 충족했다.
- unit·widget·integration·native contract 테스트가 위험에 비례해 추가됐다.
- lint, format check, coverage gate, secret scan이 통과했다.
- 권한 거부·철회·오프라인·부분 데이터·kill switch를 검증했다.
- 로그·분석·network payload 개인정보 검토가 완료됐다.
- VoiceOver·TalkBack·200% 글자·다크 모드가 확인됐다.
- 사용자 문구와 비의료 표현이 검수됐다.
- 새 데이터·SDK·권한이 문서와 스토어 선언에 반영됐다.
- rollout·monitoring·rollback 담당자와 지표가 정해졌다.

### 권장

- 운영·지원팀이 이해할 수 있는 변경 요약과 알려진 제한을 남긴다.
- 기능이 앱 체류시간이나 알림 수를 불필요하게 늘리지 않았는지 확인한다.

## 16. AI 코딩 도구 보안 규칙

### 반드시

- 운영 데이터, 사용자 입력, Crashlytics 원문, auth token, receipt, service account를 AI 도구에 입력하지 않는다.
- 예제에는 합성 사용자·가짜 패키지·가짜 토큰만 사용한다.
- 생성 코드를 사람이 읽고 테스트·라이선스·취약점·플랫폼 정책을 확인한다.
- AI가 작성한 인프라·권한·삭제·암호화 코드는 별도 보안 리뷰 없이 배포하지 않는다.
- AI 도구가 production에 직접 배포·키 회전·스토어 제출하지 못하게 한다.
- 외부 저장·학습 옵션과 조직 보존 정책을 확인하지 않은 도구는 사용하지 않는다.

### 권장

- AI 사용이 큰 설계 판단에 영향을 주면 PR에 검증 방법을 적는다.
- 생성 코드 출처와 라이선스가 불명확하면 다시 작성한다.

## 17. 예외 승인

`반드시` 규칙의 예외는 다음을 모두 충족해야 한다.

1. PR이 아니라 ADR에 이유·영향·대안·만료일을 기록한다.
2. 개인정보·보안·안전 규칙은 제품 책임자와 보안/개인정보 검토자의 승인을 받는다.
3. 임시 예외에는 제거 issue와 담당자·기한을 연결한다.
4. 스토어 정책·법률을 우회하기 위한 예외는 허용하지 않는다.
