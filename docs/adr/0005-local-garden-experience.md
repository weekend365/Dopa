# ADR-0005: 동의 기반 로컬 정원과 생활 행동 성장
- 상태: 승인, 구현 기준
- 날짜: 2026-09-11
- 승인: 사용자 명시적 전체 구현 요청
- 대체: ADR-0002의 로그인·나무 렌더러 계약, ADR-0003의 성장 격리, ADR-0004의 기본 미디어 UX
- 범위: [현재 제품 범위](../product/GARDEN_SCOPE_KO.md), [디자인 규칙](../DESIGN_SYSTEM_KO.md)

## 로컬 사용
AccountSession.canCreateLocalWellbeingData는 로그인 제공자와 독립적으로 유효 연령 구간 및 현재 동의를 요구한다.
AuthController는 저장된 연령 확인의 재확인 필요 여부를 확인한 뒤 동의 화면 또는 앱을 연다. 동의 버전은 v2로 갱신한다.
처음 동의할 때 정원과 기존 체크인 창을 초기화한다. 기존 동의 업데이트는 기존 ID와 기록을 유지한다. 인증·동기화 UI는 없다.
전체 삭제는 결과·세션·체크인·원장·정원과 동의를 모두 지운다.

## v5 → v6
tree_growth_credits의 source_session_id 컬럼 이름은 이전 데이터 보존을 위해 유지한다.
source_kind는 focus/companion. 집중 키는 기존 세션 ID, 생활 키는 companion:runId.
기존 focus_sessions 외래 키를 제거해 생활 결과 삭제 후에도 최소 원장이 남도록 한다. tree_id의 외래 키와 (tree_id, credited_local_date) 유일성은 유지한다.
마이그레이션은 기존 성장 원장을 복사하고 source_kind=focus를 부여한다. 집중·생활 결과·성장 날짜와 정원 ID는 보존한다.
기존 생활 결과를 읽거나 재제출해도 소급 지급하지 않는다.

## 지급과 삭제
생활 결과 확정, active_slot 해제, 성장 삽입은 한 DB 트랜잭션이다.
started/asPlanned만 해당 run.startedLocalDate로 지급한다. difficult와 미확인은 지급하지 않는다.
집중 완료와 생활 결과가 같은 날짜에 경합해도 유일 제약으로 하루 한 번만 기록한다.
이미 저장된 결과는 최초 결과를 그대로 반환한다. 실패 시 전체 트랜잭션이 롤백되어 같은 결과를 다시 제출할 수 있다.
개별 생활 기록 삭제는 companion_outcomes 및 run 상세를 제거하고 최소 원장을 유지한다. 같은 날 새 활동을 해도 재지급하지 않는다.
원장에는 행동 내용·텍스트를 넣지 않는다. 원장 출처와 날짜는 기기 밖으로 전송하지 않는다.

## 시각 호환
TreeSpecies.zelkovaV1, 기존 성장 단계 열거형과 ruleVersion=1은 저장 호환을 위해 유지한다.
GardenProgress가 누적 성장 기준 0/1/3/7/14/30/60/90을 정원 8단계로 매핑한다.
렌더러는 낮/밤 16개 개별 WebP. 스프라이트/Rive/계절 오버레이는 새 UI에서 사용하지 않는다.
처음부터 완성된 풍경, 오른쪽 작은 식물만 성장, 성장 차감 없음.

