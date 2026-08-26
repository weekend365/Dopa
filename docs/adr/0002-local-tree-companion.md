# ADR-0002: 기기 전용 ‘평생 한 그루’ 성장 원장과 렌더러

- 상태: 승인
- 결정일: 2026-08-26 KST
- 결정자: 제품 책임자/창업자·기술 책임자
- 관련 문서: [MVP Scope Freeze v1.2](../product/MVP_SCOPE_FREEZE_V1_KO.md)

## 맥락

Dopa는 연속 기록이나 벌점 없이 사용자가 스스로 선택한 집중 시도를 이어 가도록 돕는다. 기존의 추상적인 성취 그래픽만으로는 하루의 시도와 장기적인 변화를 직관적으로 연결하기 어렵지만, 나무를 죽이거나 재화를 지급하는 일반적인 게임화는 Dopa의 비난 없는 원칙과 충돌한다.

나무의 성장은 세션 완료와 정확히 한 번 연결되어야 한다. 앱 재실행, 중복 콜백, 재부팅 복구, 자정 통과와 시간대 변경에도 성장일이 중복되거나 사라지면 안 된다. 동시에 나무와 세션의 연결 정보는 민감한 웰빙 기록이므로 서버·분석으로 전송하지 않는다.

## 결정

### 제품 경계

- 로그인과 동의가 끝난 뒤 현재 기기의 계정 로컬 저장소에 느티나무 모티프 한 그루를 씨앗 상태로 만든다.
- 나무는 무료 핵심 경험이다. 코인, 성장 가속, 스킨, 물주기, 시듦, 죽음, 스트릭 초기화, 리더보드, 소셜 공유와 별도 정원 탭을 만들지 않는다.
- 쉬는 날, 권한 거부, 보호 기능 열화와 필요한 사용을 위한 우회는 이미 쌓인 성장일을 줄이지 않는다.
- 기기 전용으로 저장한다. 재설치·기기 변경·클라우드 동기화를 지원하거나 영구 보존을 약속하지 않는다. 로컬 데이터 삭제와 계정 삭제 시 나무와 성장 원장도 삭제한다.
- 체크인 답변, 완료한 집중시간의 길이, 활성 계획의 수는 성장량을 바꾸지 않는다.

### 성장 규칙과 도메인 계약

```text
TreeSpecies = zelkovaV1
TreeGrowthStage = seed | sprout | sapling | smallTree |
                  youngZelkova | spreadingBranches | broadCanopy | mature
FocusSessionStatus = active | completed | endedEarly | cancelled | invalidRecovery

TreeCompanion(
  id, species, createdAtUtc, ruleVersion
)

TreeGrowthCredit(
  treeId, sourceSessionId, creditedLocalDate, creditedAtUtc, ruleVersion
)

TreeProgress(
  totalGrowthDays, stage, nextThreshold, postMatureRingCount
)
```

- `FocusSession`은 안정적인 `id`, 시작 시 확정한 `startedLocalDate`, 명시적인 `terminalStatus`를 가진다.
- `creditedLocalDate`는 완료 시각이 아니라 `FocusSession.startedLocalDate`를 사용한다. 세션 도중 자정 또는 시간대가 바뀌어도 시작 날짜를 다시 계산하지 않는다.
- `CompleteFocusSession`은 세션을 `completed`로 확정하고 성장 지급을 같은 Drift 트랜잭션에서 처리한다.
- `(treeId, creditedLocalDate)`와 `sourceSessionId`에 각각 unique constraint를 둔다. 같은 날짜의 두 번째 정상 완료, 중복 완료 콜백과 복구 재실행은 세션 완료를 유지하되 새 성장일을 만들지 않는다.
- `shield`, `accessibility`, `timerOnly`에서 끝까지 정상 완료한 세션은 모두 성장한다. 5분 허용 우회를 사용했더라도 최종 상태가 `completed`면 인정한다.
- `endedEarly`, `cancelled`, `invalidRecovery`는 성장하지 않는다. 체크인 응답 유무와 내용은 성장 판정에 사용하지 않는다.
- 성장 단계는 저장하지 않고 해당 `ruleVersion`의 유효한 `TreeGrowthCredit` 개수에서 파생한다. MVP의 `ruleVersion`은 `1`이다.

| `totalGrowthDays` | `stage` | 사용자 문구 |
|---:|---|---|
| 0 | `seed` | 씨앗 |
| 1~2 | `sprout` | 새싹 |
| 3~6 | `sapling` | 묘목 |
| 7~13 | `smallTree` | 작은 나무 |
| 14~29 | `youngZelkova` | 어린 느티나무 |
| 30~59 | `spreadingBranches` | 가지를 펴는 나무 |
| 60~89 | `broadCanopy` | 넓은 수관 |
| 90 이상 | `mature` | 성목 |

- `nextThreshold`는 다음 단계의 첫 성장일이며 성목에서는 `null`이다.
- `postMatureRingCount`는 90일 미만이면 `0`, 90일 이상이면 `floor((totalGrowthDays - 90) / 30)`이다. 따라서 90일은 성목 reveal, 120일부터 30일마다 나이테 파문을 한 번 재생한다.
- 성목의 30일 단위 나이테 파문도 별도 Rive 입력을 늘리지 않고 `playPulse`를 사용한다.
- MVP 최초 스키마에는 과거 성장 기록이 없으므로 세션 기록을 소급 변환하지 않는다.

### 경험과 렌더러 계약

- 오늘 화면의 나무 히어로는 `함께 자란 N일 · 단계명`, 현재 실험의 `N/7일`, 빠른 집중 버튼을 한 카드에 제공한다.
- 집중 진행 화면에는 나무를 표시하지 않는다. 타이머와 원래 하려던 일에 시선을 유지한다.
- 1·3·7·14·30·60·90번째 성장일에는 완료 화면 자체에서 최대 1.2초의 reveal을 재생한다. 종료·체크인 조작은 애니메이션과 동시에 즉시 사용할 수 있어야 한다.
- 이정표가 아닌 첫 성장 완료는 300ms 이내의 잎·빛 pulse만 재생한다. 같은 날 두 번째 완료부터는 “오늘의 성장은 이미 남겨졌어요”라고 안내한다.
- 전문 원화는 크림 배경, 저채도 세이지 수관, 따뜻한 새잎 포인트의 고요한 식물 디오라마로 제작한다. 전·후경 잎, 줄기, 흙, 그림자와 빛을 분리해 리깅한다.
- 계절은 배경 빛·눈·꽃잎·낙엽 같은 환경 레이어로만 표현한다. 겨울에도 수관을 시들거나 죽은 보상처럼 바꾸지 않는다.
- 향후 납품할 Rive 단일 에셋의 공개 입력은 `stage`, `theme`, `season`, `playReveal`, `playPulse`, `reduceMotion`으로 고정한다. 로컬 텍스처를 포함하며 one-shot 종료 뒤 활성 ticker가 남지 않아야 한다.
- 기본 정적 폴백은 `zelkova_growth_sprite_light.png`, `zelkova_growth_sprite_dark.png` 두 장이다. 각 파일은 알파 채널 없는 1536×1024 PNG, 4×2 정확한 그리드이며 각 셀은 384×512다.
- 스프라이트 프레임은 좌→우, 위→아래로 `seed`, `sprout`, `sapling`, `smallTree`, `youngZelkova`, `spreadingBranches`, `broadCanopy`, `mature` 순서다. 두 테마 시트로 16개 테마·단계 프레임을 제공하고 두 파일 합계는 6MiB 이하다.
- Rive 로드·상태 머신·에셋 오류가 나면 같은 단계와 테마의 PNG 프레임으로 즉시 전환한다. Rive를 포함한 전체 나무 앱 에셋도 활성화 전 6MiB 이하를 충족해야 한다.
- `tree_ui_enabled`는 나무 UI만 제어하며 OFF여도 성장 원장은 계속 기록한다. `tree_rive_enabled`는 렌더러만 제어하며, 전문 Rive 원본이 납품되고 검증되기 전까지 모든 환경의 기본값은 OFF다.
- 일반 UI 모션은 150~300ms를 유지한다. Reduce Motion에서는 reveal과 pulse를 재생하지 않고 최종 정적 프레임을 즉시 표시한다.
- 나무 전체는 `함께 자란 14일, 어린 느티나무` 형식의 단일 semantics label로 읽고 장식 레이어는 접근성 트리에서 제외한다.

### 분석과 개인정보

- 나무 생성, 성장일, 단계 전환, 이정표 reveal을 위한 행동 분석 이벤트를 추가하지 않는다. 세션 성과 분석은 기존 `focus_completed`만 사용하며 나무 식별자·성장일·단계를 속성으로 붙이지 않는다.
- 운영 이벤트는 `tree_render_failed(renderer, platform, error_code)`만 허용한다. `treeId`, `sourceSessionId`, 날짜, 단계와 에셋 경로는 로그·Crashlytics·분석 payload에 넣지 않는다.
- `TreeCompanion`, `TreeGrowthCredit`, `TreeProgress`에는 서버 serializer, Firestore 필드, sync API와 분석 outbox 변환을 구현하지 않는다.

## 출시와 폴백

1. 씨앗·7일·90일 세 장면의 Rive 기술 시제품으로 데이터 바인딩, one-shot 정지, Reduce Motion과 정적 폴백을 검증한다.
2. 성인 10명의 사용성 테스트에서 하루 한 번 성장, 쉬어도 사라지지 않음, 집중 시작 동선을 검증한다. 8명 이상이 도움 없이 규칙을 설명해야 다음 단계로 간다.
3. 통과 후 8단계 Light/Dark 원화, 계절 환경 레이어, Rive 원본과 상업적 사용·수정 권한을 납품받는다.
4. 세션 완료 트랜잭션과 성장 원장을 먼저 배포 가능한 상태로 만들고 오늘·완료·주간 리포트 UI를 연결한다.
5. 내부 알파와 최초 출시 후보는 `tree_ui_enabled=true`, `tree_rive_enabled=false`의 PNG 스프라이트 렌더러로 시작한다. 전문 Rive 원본 납품과 성능·안정성 기준 통과 후에만 Rive를 원격 활성화한다.
6. 렌더 오류나 성능 회귀 시 `tree_rive_enabled=false`로 즉시 정적 렌더러로 되돌린다. UI 전체를 꺼야 할 때도 원장은 유지해 재활성화 시 누적 성장일을 복원한다.

## 검증 기준

- 단계 경계 0·1·3·7·14·30·60·90·120일과 `postMatureRingCount`를 단위 테스트한다.
- 하루 중복, 중복 콜백, 조기 종료, 취소, 5분 우회 후 완료, 보호 실패 후 `timerOnly` 완료, 재부팅 복구, 자정 통과와 시간대 변경을 트랜잭션 테스트한다.
- 8단계 Light/Dark, 200% 글자, Reduce Motion, Rive 실패 폴백의 golden·semantics 테스트를 둔다.
- 두 PNG 스프라이트의 크기·불투명도·4×2 그리드·프레임 순서와 합계 6MiB 이하를 자동 검증한다. Rive 활성화 전에는 기준 기기 느린 프레임 비율 5% 미만, one-shot 종료 후 활성 ticker 0개, Rive 포함 전체 나무 앱 에셋 6MiB 이하를 추가로 충족한다.
- 프록시 또는 mock transport에서 나무·성장일·세션 연결 정보 외부 전송 0건, 로컬·계정 삭제 뒤 잔존 row·키·캐시 0건을 확인한다.

## 결과

- 사용자는 실패하거나 쉬어도 훼손되지 않는 장기 동반자를 얻는다.
- 성장 판정은 로컬 원장과 unique constraint로 재현 가능하고 멱등성을 가진다.
- 고품질 모션이 준비되지 않거나 기기 성능이 낮아도 같은 정보 구조와 정적 아트로 출시할 수 있다.
- 재설치·기기 변경 시 나무를 복구할 수 없으며, 이 제한을 제품 카피와 도움말에 명시해야 한다.

## 제외

- 여러 나무·수종 선택·정원 관리
- 코인·재화·상점·유료 성장 가속·유료 스킨
- 물주기·시듦·죽음·스트릭·연속 출석 보너스
- 리더보드·공개 프로필·친구 비교·공유 보상
- 나무와 성장 원장의 클라우드 백업·기기 간 이전
