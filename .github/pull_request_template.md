## 목적

<!-- 사용자가 겪는 문제와 이 변경의 결과를 한두 문장으로 적어주세요. -->

## 변경 사항

- 

## 범위에서 제외한 것

- 

## MVP Scope Freeze

- [ ] [MVP Scope Freeze v1.2](../docs/product/MVP_SCOPE_FREEZE_V1_KO.md)의 범위와 일치합니다.
- [ ] 만 14세 미만 사용자는 인증·분석 SDK 네트워크 초기화 전에 차단됩니다.
- [ ] 무료 활성 계획 1개·계획당 대상 앱 3개 제한을 지킵니다.
- [ ] 세션 시간은 5·10·25·50분만 허용합니다.
- [ ] 우회는 이유 입력 없이 2동작 이내이며 5분 허용·세션 종료·취소만 제공합니다.
- [ ] 앱 선택·사용 기록·체크인·원본 우회 이벤트는 기기 전용이며 선택적 분석은 allowlist 속성만 사용합니다.
- [ ] Android Accessibility OFF에서 UsageStats 리포트와 타이머가 동작합니다.
- [ ] 첫 페이월은 두 번째 계획 또는 반복 일정을 직접 선택한 경우에만 표시됩니다.
- [ ] Scope Freeze를 변경했다면 문서 버전과 승인 기록을 갱신했습니다.
- [ ] iOS 식별자는 `config/apple-identifiers.json`과 일치하며 운영/개발 App Group을 혼용하지 않습니다.
- [ ] Family Controls 변경은 메인 앱과 확장 4개의 entitlement·프로비저닝 영향을 확인했습니다.
- [ ] 나무 성장은 정상 완료 세션 기준 하루 1회이며 조기 종료·취소에는 지급되지 않습니다.
- [ ] 나무·성장 원장·시작일·세션 연결 정보는 기기 밖으로 전송되지 않습니다.
- [ ] `tree_ui_enabled` OFF와 `tree_rive_enabled` OFF에서 성장 기록 및 정적 fallback이 정상 동작합니다.

## 테스트

- [ ] Unit / widget test
- [ ] Integration / native contract test
- [ ] iOS 실제 기기
- [ ] Android 실제 기기
- [ ] 오프라인·부분 데이터
- [ ] 권한 거부·철회
- [ ] Remote Config OFF 폴백
- [ ] 하루 중복 완료·복구 콜백·자정 통과 성장 원장
- [ ] Light/Dark 나무 에셋·Reduce Motion·Rive 실패 fallback
- [ ] iOS Release 프로파일과 실제 기기 Family Controls

테스트 방법과 결과:

## 개인정보·보안

- [ ] 앱명, package ID, Screen Time token, URL, 감정·자유 입력이 로그·분석·네트워크에 들어가지 않습니다.
- [ ] 우회 이유·생년월일·정확한 나이가 저장·전송되지 않습니다.
- [ ] 새 데이터·SDK·권한·보관기간이 없습니다. 있다면 아래에 적고 데이터 맵을 수정했습니다.
- [ ] 시크릿이 코드·설정·fixture·스크린샷에 없습니다.
- [ ] 계정 삭제·로컬 삭제 동작에 미치는 영향을 확인했습니다.

개인정보 영향:

## 플랫폼·안전 폴백

- [ ] iOS와 Android의 capability 차이를 처리합니다.
- [ ] 보호 기능이 실패해도 timerOnly 또는 안전한 기본 동작으로 열화합니다.
- [ ] 전화·문자·지도·설정·인증 및 긴급 우회를 막지 않습니다.
- [ ] 위험 기능에 kill switch가 있습니다.

## 접근성

- [ ] VoiceOver
- [ ] TalkBack
- [ ] 200% 글자 확대
- [ ] WCAG 2.2 AA 대비
- [ ] 색상 외 상태 표현
- [ ] Reduce Motion / 초점 순서

## 카피·제품 원칙

- [ ] 비난·수치심·공포·스트릭 손실을 유도하지 않습니다.
- [ ] 진단·치료·도파민 초기화·효과 보장을 주장하지 않습니다.
- [ ] 알림이나 앱 체류시간을 불필요하게 늘리지 않습니다.

## 화면

<!-- UI 변경이면 전/후 스크린샷 또는 영상을 첨부하세요. 민감 데이터는 반드시 합성 값으로 대체합니다. -->

## 출시·모니터링·롤백

- Feature flag:
- 단계 출시 비율:
- 확인할 지표/오류 코드:
- 롤백 또는 kill switch 절차:

## 관련 문서

- Issue:
- ADR:
- 개인정보 데이터 맵:
- Scope Freeze 변경 기록:
