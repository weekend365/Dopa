# Dopa MVP Scope Freeze v1.2

> 상태: 승인됨  
> 결정일: 2026-08-26 KST
> 승인자: 제품 책임자/창업자·기술 책임자
> 적용 범위: 대한민국 iOS·Android MVP 및 12주 출시 계획
> 개발·배포 주체: 개인사업자·1인 개발자, Apple Developer Program Individual
> Apple 식별자: `com.devnamu.dopa`, App Group `group.com.devnamu.dopa`

이 문서는 Dopa MVP의 제품 범위를 고정한다. 구현·디자인·분석·스토어 문구가 이 문서와 충돌하면 이 문서를 우선한다.

## 1. 동결된 결정

| 영역 | v1 결정 | 근거 |
|---|---|---|
| 출시 연령 | 만 14세 이상 | 청소년 수요를 포함하되 14세 미만 보호자 가입은 MVP에서 제공하지 않음 |
| 출시 게이트 | 미성년자 정책·인증·결제 요건 미충족 시 출시 보류 | 18세 이상으로 자동 전환하지 않고 선택한 시장 범위를 충족한 뒤 출시 |
| 계정 | 첫 사용 전 Apple·Google 필수 로그인 | 동의·구독·삭제 상태를 계정에 연결 |
| 연령 처리 | 인증 SDK 네트워크 초기화 전 기기에서 확인 | 14세 미만 데이터가 외부 SDK에 전달되지 않게 함 |
| Android 기본 | UsageStats 리포트+집중 타이머 | Accessibility 승인과 무관하게 Android를 출시 가능하게 함 |
| Android 보호 | 심사 승인 후 Remote Config로 활성화 | 정책 위험을 격리하고 원격으로 즉시 비활성화 가능하게 함 |
| 무료 한도 | 활성 계획 1개, 계획당 대상 앱 최대 3개 | 한 가지 생활 장면에 집중하고 설정·충돌을 제한 |
| Plus 한도 | 활성 계획 최대 5개, 계획당 대상 앱 최대 3개 | 복수 생활 장면과 반복 일정에 과금 |
| 실험 | 7일 실험 1개 | 습관 완성이 아닌 짧은 관찰 실험으로 검증 |
| 세션 시간 | 5·10·25·50분, 첫 추천 10분 | 선택 복잡도와 극단값을 제거하고 작은 첫 성공 제공 |
| 우회 | 이유 입력 없이 2동작 | 자율성과 긴급 사용을 보장하고 수치심·민감 데이터 수집 방지 |
| 우회 결과 | 5분 허용·세션 종료·취소 | 필요한 사용과 계획 유지 사이의 최소 선택지 |
| 체크인 | 의도 일치 `예/아니요/건너뛰기` 1탭 | 플랫폼 공통 가치 지표를 최소 정보로 측정 |
| 민감 데이터 | 앱 선택·사용 기록·체크인·원본 우회 기록은 기기 전용 | 로컬 우선이라는 제품 신뢰를 구현으로 보장 |
| 평생 한 그루 | 로그인·동의 후 느티나무 모티프 한 그루를 씨앗으로 생성 | 하루의 시도를 비경쟁·비처벌 방식으로 오래 시각화 |
| 나무 성장 | 정상 완료한 첫 세션만 시작 로컬 날짜에 1회 지급 | 시간·세션 수·체크인·스트릭과 분리하고 중복 콜백에도 멱등 보장 |
| 나무 저장 | 나무·성장 원장은 기기 전용, 단계는 원장에서 파생 | 재설치·기기 변경 동기화를 약속하지 않고 세션 연결 정보 외부 전송 방지 |
| 나무 과금 | 무료 핵심 경험, 성장 가속·재화·스킨 없음 | 안전·접근성과 장기 동반 경험을 과금하지 않음 |
| 취침 루틴 | 30분 집중+2분 오프라인 활동 기본 템플릿 | 수면 측정 없이 생활 장면을 지원 |
| 가격 | 월 ₩5,900·연 ₩39,000, 7일 체험 | 중간 가격대에서 유지보수 재원과 접근성 균형 |
| 첫 페이월 | 두 번째 계획·반복 일정 등 유료 기능을 직접 선택할 때 | 첫 무료 세션과 온보딩을 방해하지 않음 |
| Apple 배포 | Individual 멤버십·법적 실명 판매자 표시 | 법인 전환과 D‑U‑N‑S는 MVP 선행 조건이 아님 |
| Apple 식별자 | `com.devnamu.dopa` 네임스페이스 | 앱·확장·구독 식별자 충돌 방지 |
| 1인 개발 폴백 | Android Accessibility·4주 추세·고급 리포트는 출시 후 | 로그인·안전·삭제·iOS 보호·Android timerOnly를 우선 |

## 2. 무료와 Plus의 출시 범위

| 무료 | Dopa Plus |
|---|---|
| 활성 계획 1개 | 활성 계획 최대 5개 |
| 계획당 대상 앱 최대 3개 | 계획당 대상 앱 최대 3개 |
| 5·10·25·50분 세션 | 동일한 세션 preset |
| 집중 또는 기본 취침 계획 중 하나 | 집중·취침 등 복수 계획 동시 운영 |
| 7일 실험 1개 | 계획별 반복 일정 |
| 의도 일치 체크인·기본 주간 리포트 | 4주 추세·전체 활동 템플릿 |
| 평생 한 그루 전체 성장 경험 | 동일한 나무 경험—성장·안전·접근성은 과금하지 않음 |
| 긴급 우회·권한 진단 | 동일하게 제공—안전 기능은 과금하지 않음 |

무료 사용자가 기본 취침 템플릿을 선택하면 기존 무료 집중 계획을 교체해야 한다. 두 계획을 동시에 유지하려고 할 때 Plus 페이월을 표시한다.

## 3. 정확한 사용자 흐름

### 가입

`로컬 연령 화면 → under14 차단 또는 age band 계산 → 인증 SDK 활성화 → Apple·Google 로그인 → 동의 → 씨앗 생성 → 목표 설정`

- 생년월일은 계산 직후 폐기한다.
- 서버에는 `ageBand`와 `ageAttestedAt`만 저장한다.
- `age14To17` 사용자는 12개월 뒤 앱 시작 시 로컬 연령 확인을 다시 수행한다.
- 로그인 취소·실패·오프라인 상태에서는 웰빙 계획이나 사용 기록을 만들지 않는다.
- 나무는 로그인·동의 뒤 현재 기기의 계정 로컬 저장소에 한 그루만 만들며 서버에 생성 사실을 전송하지 않는다.

### 첫 무료 가치

`생활 장면 선택 → 앱 최대 3개 → 10분 추천 세션 → 완료·첫 새싹 reveal → 7일 실험 저장`

- 5·10·25·50분만 선택할 수 있으며 직접 입력은 제공하지 않는다.
- 첫 무료 세션과 첫 계획 생성에는 페이월을 표시하지 않는다.

### 보호 앱 우회

`필요한 사용 → 5분 허용 또는 세션 종료 → 실행`

- 첫 동작은 `필요한 사용`, 두 번째 동작은 결과 선택이다.
- 이유·감정·자유 입력을 묻지 않는다.
- `취소`는 원래 보호 화면으로 돌아간다.
- 전화·문자·지도·설정·금융·인증 allowlist는 이 흐름 없이 항상 허용한다.

### 페이월

`두 번째 계획 생성 또는 반복 일정 선택 → 무료/Plus 비교 → 월·연 선택 또는 닫기`

- 월 ₩5,900, 연 ₩39,000, 7일 체험과 실제 갱신 주기를 표시한다.
- 닫기·구매 복원·구독 관리 경로를 숨기지 않는다.
- 온보딩, 권한 요청, 첫 세션, 오류, 안전 안내 중에는 표시하지 않는다.

## 4. 인터페이스·데이터 계약

```text
AgeBand = under14 | age14To17 | adult18Plus
IntentionAlignment = yes | no | skipped
SessionDurationPreset = 5 | 10 | 25 | 50
BypassAction = allowFiveMinutes | endSession | cancel
UsageReportMode = nativeView | structured | none
ProtectionMode = shield | accessibility | timerOnly
TreeSpecies = zelkovaV1
TreeGrowthStage = seed | sprout | sapling | smallTree | youngZelkova | spreadingBranches | broadCanopy | mature
FocusSessionStatus = active | completed | endedEarly | cancelled | invalidRecovery
```

### `AccountProfile`

- 서버 허용: `uid`, `provider`, `ageBand`, `ageAttestedAt`, `locale`, `timezone`
- 금지: 생년월일, 정확한 나이, 앱 선택, 사용 기록, 체크인

### `PlanLimits`

| entitlement | activePlans | targetsPerPlan |
|---|---:|---:|
| free | 1 | 3 |
| plus | 5 | 3 |

### `InterventionEvent`

- 로컬 필드: `trigger`, `action`, `elapsedBucket`, `protectionMode`
- 존재하지 않는 필드: `reason`, `coarseReason`, `freeText`

### `DailyCheckIn`

- 로컬 필드: `localDate`, `intentionAlignment`
- 서버 serializer를 만들지 않는다.

### `FocusSession`

- 로컬 필수 필드: 안정적인 `id`, `startedLocalDate`, `plannedDuration`, `protectionMode`, `terminalStatus`, 시작·완료 시각
- `startedLocalDate`는 세션 시작 시 확정하고 자정 통과·시간대 변경 뒤 다시 계산하지 않는다.
- `completed`만 성장 지급 대상이다. `endedEarly`, `cancelled`, `invalidRecovery`는 대상이 아니다.

### `TreeCompanion`·`TreeGrowthCredit`·`TreeProgress`

- `TreeCompanion`: `id`, `species`, `createdAtUtc`, `ruleVersion`
- `TreeGrowthCredit`: `treeId`, `sourceSessionId`, `creditedLocalDate`, `creditedAtUtc`, `ruleVersion`
- `TreeProgress`: `totalGrowthDays`, `stage`, `nextThreshold`, `postMatureRingCount`
- `CompleteFocusSession`은 세션 완료와 성장 지급을 하나의 Drift 트랜잭션으로 처리한다.
- `(treeId, creditedLocalDate)`와 `sourceSessionId`를 각각 unique로 두며, 중복 시 세션 완료는 유지하고 성장일만 추가하지 않는다.
- `creditedLocalDate`는 해당 세션의 `startedLocalDate`다. 정상 완료라면 `shield`, `accessibility`, `timerOnly`와 5분 허용 우회 사용 여부에 관계없이 인정한다.
- 단계는 저장하지 않고 `ruleVersion=1` 성장 원장 개수로 파생한다. 경계는 0·1·3·7·14·30·60·90일이고 120일부터 매 30일마다 성목 나이테 수가 증가한다.
- 세 타입 모두 서버 serializer·Firestore 필드·동기화 API를 만들지 않는다. 로컬 데이터 삭제와 계정 삭제 시 함께 삭제한다.

### 나무 렌더러·플래그

- Rive 입력 계약은 `stage`, `theme`, `season`, `playReveal`, `playPulse`, `reduceMotion`이다.
- 정적 폴백은 Light/Dark별 알파 채널 없는 1536×1024 PNG 스프라이트 두 장이다. 각 시트는 4×2이며 프레임 순서는 `seed`→`sprout`→`sapling`→`smallTree`→`youngZelkova`→`spreadingBranches`→`broadCanopy`→`mature`다.
- 로컬 기본값은 `tree_ui_enabled=true`, `tree_rive_enabled=false`다. UI가 OFF여도 성장 원장은 기록하며 Rive가 OFF이거나 오류가 나면 같은 단계·테마의 PNG 프레임으로 즉시 전환한다.
- `tree_rive_enabled`는 전문 Rive 원본 납품·검증 전까지 모든 환경에서 기본 OFF다. 정적 시트 두 장의 합계는 6MiB 이하이며 Rive 활성화 전 전체 나무 앱 에셋도 6MiB 이하를 충족한다.
- 상세 데이터·렌더러·롤아웃 계약은 [ADR-0002](../adr/0002-local-tree-companion.md)를 따른다.

### `SubscriptionOffering`

- `monthly`: ₩5,900
- `annual`: ₩39,000
- `trialDays`: 7
- `freeActivePlanLimit`: 1
- `plusActivePlanLimit`: 5
- `targetsPerPlan`: 3

### 분석 계약

원본 `InterventionEvent`는 동기화하지 않는다. 별도의 선택적 분석 이벤트 `focus_bypassed`는 `action`, `elapsed_bucket`, `protection_mode`만 허용한다. 앱 식별자, 이유, 자유 입력, 정확한 시각을 받지 않는다.

나무 생성·성장·단계·reveal 행동 이벤트는 만들지 않고 기존 `focus_completed`만 사용한다. 운영용 `tree_render_failed`는 `renderer`, `platform`, `error_code`만 허용하며 나무 ID, 세션 ID, 날짜, 단계와 에셋 경로를 받지 않는다.

## 5. MVP 제외 범위

- 14·30일 실험
- 사용자 지정 세션 시간
- 감정 범주·자유 입력·상담형 체크인
- 앱 선택·사용 기록·체크인·우회의 클라우드 동기화
- 상시 차단·삭제 방지·금전 벌칙
- 위젯, AI 코치, 가족·친구, 공개 비교, 광고, 평생 이용권
- 여러 나무·수종 선택·별도 정원 탭, 코인·상점·스킨·성장 가속, 물주기·시듦·죽음·스트릭·리더보드
- 나무·성장 원장의 클라우드 백업, 재설치 복구와 기기 간 이전
- Android Accessibility 기반 보호, 반복 일정, 4주 추세, 고급 리포트
- 수면 측정, 건강·집중력·수면 개선 주장

## 6. 출시 차단 조건

- 만 14세 이상 대상의 법률·Google Play Families·인증 SDK·미성년 구독 검토 미완료
- 14세 미만 사용자가 인증 SDK 활성화 또는 계정 생성 단계로 진입 가능
- 정확한 생년월일·앱 식별자·사용 기록·체크인·우회 이유의 서버 전송
- 나무·성장일·세션 연결 정보의 서버·분석·로그 전송 또는 나무 타입의 서버 serializer 존재
- 전화·문자·지도·설정·금융·인증 앱 오차단
- Android Accessibility OFF에서 UsageStats 리포트 또는 타이머 사용 불가
- 무료 한도·페이월·가격·체험 표시가 이 문서와 불일치
- 정상 완료와 성장 지급이 단일 트랜잭션이 아니거나 하루 중복·복구 재실행에 성장일이 중복됨
- Rive 실패 시 정적 폴백이 없거나 Reduce Motion에서 reveal이 강제로 재생됨
- 8단계 Light/Dark PNG 스프라이트의 크기·불투명도·4×2 그리드·프레임 순서, 200% 글자, VoiceOver·TalkBack 또는 삭제 후 잔존 데이터 검증 미완료
- 정적 시트 두 장 합계 6MiB 초과, Rive 활성화 시 전체 나무 앱 에셋 6MiB 초과, 기준 기기 느린 프레임 5% 이상 또는 one-shot 종료 후 활성 ticker 존재

## 7. 변경 통제

| 변경 유형 | 필수 승인 |
|---|---|
| 무료·Plus 한도, 가격, 페이월, MVP 기능 | 제품 책임자/창업자 + 기술 책임자 |
| 연령, 로그인, 개인정보, 클라우드 동기화 | 제품 책임자/창업자 + 개인정보·법률 검토자 + 기술 책임자 |
| Accessibility 범위, 긴급 우회, allowlist | 제품 책임자/창업자 + 기술 책임자 + 스토어 정책 검토자 |
| 카피의 의학적 주장·안전 안내 | 제품 책임자/창업자 + 관련 전문 검토자 |
| 나무 성장 규칙·무료 범위·로컬 전용 계약·Rive 공개 입력 | 제품 책임자/창업자 + 기술 책임자 |

변경은 PR 설명만으로 승인하지 않는다. 이 문서의 버전을 올리고 변경 사유·영향·롤백·승인자를 기록해야 한다.

## 8. 승인 기록

| 날짜 | 버전 | 결정 | 승인자 |
|---|---|---|---|
| 2026-08-25 | v1 | 본 문서의 전체 MVP 범위 동결 | 제품 책임자/창업자 |
| 2026-08-25 | v1.1 | 개인사업자·1인 개발·Apple Individual·`com.devnamu.dopa` 식별자와 출시 후 범위 반영 | 제품 책임자/창업자 |
| 2026-08-26 | v1.2 | 무료·기기 전용 ‘평생 한 그루’, 하루 1회 성장 원장, 모션 예외·정적 폴백·분석 제한 승인 | 제품 책임자/창업자·기술 책임자 |
