# Apple 외부 작업 체크리스트

> 소유자: 창업자·Account Holder
> 상태값: `미착수`, `진행 중`, `완료`, `차단`
> 보안: 비밀번호, 인증서 개인키, API 키, 세금·계좌 원문은 이 문서에 기록하지 않는다.

이 문서는 Apple Developer, App Store Connect, 도메인 제공자와 실제 Mac에서 수행해야 하므로 저장소 자동화로 대신할 수 없는 작업을 추적한다.

## 현재 확인된 상태

- 2026-08-25 KST에 `https://devnamu.com`의 공개 HTTPS 응답을 확인했다.
- Dopa 소개·개인정보·이용약관·지원·계정 삭제 경로는 공개 상태를 확인하지 못했으므로 미착수로 취급한다.
- 현재 사이트에는 개인 이메일이 노출되어 있으므로 Dopa 스토어 제출 전 `support@devnamu.com`과 `privacy@devnamu.com`으로 제품 문의 채널을 분리한다.

## A. 오늘 완료

| 상태 | 작업 | 완료 증빙 |
|---|---|---|
| 미착수 | Apple Account 2단계 인증·복구 연락처·신뢰 전화번호 확인 | 확인 날짜만 기록 |
| 미착수 | `support@devnamu.com` 생성 및 송수신 테스트 | 본인 메일 왕복 성공 |
| 미착수 | `privacy@devnamu.com` 생성 또는 전달 별칭 설정 | 수신 성공 |
| 미착수 | 운영 App Group `group.com.devnamu.dopa` 생성 | Apple 식별자 화면 확인 |
| 미착수 | 운영 메인 App ID 생성 | `com.devnamu.dopa` 확인 |
| 미착수 | 운영 확장 App ID 4개 생성 | 네 ID 확인 |
| 미착수 | 운영 App ID 5개에 capability·App Group 연결 | 대상별 설정 확인 |
| 미착수 | 운영 App ID 5개 Family Controls 신청 | 접수일·요청 번호 기록 |

## B. 1~2일 차

| 상태 | 작업 | 완료 증빙 |
|---|---|---|
| 미착수 | App Store Connect 앱 레코드 생성 | 앱명·Bundle ID·SKU 확인 |
| 미착수 | 앱명 `Dopa`, 불가하면 `Dopa: 디지털 웰빙` 확정 | App Store Connect 저장 |
| 미착수 | Paid Apps Agreement 동의 | 계약 상태 Active |
| 미착수 | 개인사업자 세금 정보 입력 | 검증 상태 확인 |
| 미착수 | 정산 계좌 입력 | 검증 상태 확인 |
| 미착수 | 개발 App ID·App Group 생성 | 개발 식별자 전체 확인 |

## C. 승인 추적

| App ID | 접수일 | 요청 번호 | 상태 | 승인일 |
|---|---|---|---|---|
| `com.devnamu.dopa` |  |  | 미착수 |  |
| `com.devnamu.dopa.activitymonitor` |  |  | 미착수 |  |
| `com.devnamu.dopa.activityreport` |  |  | 미착수 |  |
| `com.devnamu.dopa.shieldconfiguration` |  |  | 미착수 |  |
| `com.devnamu.dopa.shieldaction` |  |  | 미착수 |  |

## D. 8~10주 차

- [ ] `Dopa Plus` 구독 그룹 생성
- [ ] 월간 `com.devnamu.dopa.plus.monthly`, ₩5,900, 7일 체험 설정
- [ ] 연간 `com.devnamu.dopa.plus.annual`, ₩39,000, 7일 체험 설정
- [ ] RevenueCat 운영 상품·entitlement 연결
- [ ] `https://devnamu.com/dopa` 제품 소개 페이지 배포
- [ ] 개인정보·이용약관·지원·계정 삭제 공개 페이지 배포
- [ ] App Privacy와 제3자 SDK 데이터 맵 일치 검증
- [ ] 연령 등급, 대한민국 배포 정보, 수출 규정 응답 완료

## E. 10~12주 차

- [ ] 내부 TestFlight 테스트 완료
- [ ] 외부 알파 30명 완료
- [ ] 폐쇄 베타 100명 완료
- [ ] App Review Notes와 기능 재현 영상 준비
- [ ] Family Controls Release entitlement를 모든 프로파일에서 확인
- [ ] 첫 버전을 Manual Release로 제출
- [ ] 승인 후 최종 운영 점검을 거쳐 수동 공개

## 외부 차단 기록

| 날짜 | 차단 요인 | 영향 | 다음 조치 |
|---|---|---|---|
|  |  |  |  |
