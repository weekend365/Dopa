# Apple 외부 작업 체크리스트

> 소유자: 창업자·Account Holder
> 상태값: `미착수`, `진행 중`, `완료`, `차단`
> 보안: 비밀번호, 인증서 개인키, API 키, 세금·계좌 원문은 이 문서에 기록하지 않는다.
> 마지막 갱신: 2026-08-25 KST

이 문서는 Apple Developer, App Store Connect, 도메인 제공자와 실제 Mac에서 수행해야 하므로 저장소 자동화로 대신할 수 없는 작업을 추적한다.

## 현재 확인된 상태

- 2026-08-25 KST에 `https://devnamu.com`의 공개 HTTPS 응답을 확인했다.
- Dopa 소개·개인정보·이용약관·지원·계정 삭제 경로는 공개 상태를 확인하지 못했으므로 미착수로 취급한다.
- `support@devnamu.com`과 `privacy@devnamu.com` 지원 메일 설정은 2026-08-25에 완료했다.
- 운영 App Group·메인 App ID·확장 App ID 4개·capability 연결은 2026-08-25에 완료했다.
- Family Controls Framework entitlement는 2026-08-25에 팀 단위로 신청했고 Apple 검토 중이다.
- App Store Connect 비즈니스: Free Apps Agreement Active, Paid Apps는 사용자 정보 대기 중.
- 정산 계좌(Toss)는 처리 중(약 24시간). 한국 세금은 대기 중. 미국 Certificate·W-8BEN은 2026-08-25 제출 완료.
- EU DSA 트레이더 정보는 대한민국 MVP만이면 당장 필수는 아니며 미착수로 둔다.
- App Store Connect 앱 레코드(`Dopa` / SKU `DOPA-IOS-001`) 생성은 아직 미착수다.

## A. 식별자·메일·entitlement

| 상태 | 작업 | 완료 증빙 |
|---|---|---|
| 미착수 | Apple Account 2단계 인증·복구 연락처·신뢰 전화번호 확인 | 확인 날짜만 기록 |
| 완료 | `support@devnamu.com` 생성 및 송수신 테스트 | 2026-08-25 창업자 확인 |
| 완료 | `privacy@devnamu.com` 생성 또는 전달 별칭 설정 | 2026-08-25 창업자 확인 |
| 완료 | 운영 App Group `group.com.devnamu.dopa` 생성 | 2026-08-25 창업자 확인 |
| 완료 | 운영 메인 App ID 생성 | 2026-08-25 창업자 확인 |
| 완료 | 운영 확장 App ID 4개 생성 | 2026-08-25 창업자 확인 |
| 완료 | 운영 App ID 5개에 capability·App Group 연결 | 2026-08-25 창업자 확인 |
| 진행 중 | Family Controls Framework entitlement 신청 | 2026-08-25 제출, Apple 검토 대기 |

## B. App Store Connect·계약·세금

| 상태 | 작업 | 완료 증빙 |
|---|---|---|
| 미착수 | App Store Connect 앱 레코드 생성 | 앱명·Bundle ID·SKU 확인 |
| 미착수 | 앱명 `Dopa`, 불가하면 `Dopa: 디지털 웰빙` 확정 | App Store Connect 저장 |
| 진행 중 | Paid Apps Agreement | Free Active. Paid는 사용자 정보 대기(계좌·세금 반영 후 Active 예상) |
| 진행 중 | 한국 세금 정보 | 2026-08-25 제출, 대기 중 |
| 완료 | 미국 Certificate of Foreign Status | 2026-08-25 제출 |
| 완료 | U.S. Form W-8BEN | 2026-08-25 제출 |
| 진행 중 | 정산 계좌 | 2026-08-25 등록, 처리 중(약 24시간) |
| 완료 | 한국 전자상거래법 규정 준수 | 2026-08-25 Active |
| 미착수 | EU DSA 트레이더 정보 | 유럽 배포 시 필수. KR-only MVP는 후순위 |
| 미착수 | 개발 App ID·App Group 생성 | `com.devnamu.dopa.dev` 등 |

## C. Family Controls 승인 추적

| 대상 | 접수일 | 요청 번호 | 상태 | 승인일 |
|---|---|---|---|---|
| 계정/팀 Framework Entitlement | 2026-08-25 | 메일·포털 확인 예정 | 검토 중 |  |
| `com.devnamu.dopa` |  |  | 계정 승인 후 Distribution 확인 |  |
| `com.devnamu.dopa.activitymonitor` |  |  | 계정 승인 후 Distribution 확인 |  |
| `com.devnamu.dopa.activityreport` |  |  | 계정 승인 후 Distribution 확인 |  |
| `com.devnamu.dopa.shieldconfiguration` |  |  | 계정 승인 후 Distribution 확인 |  |
| `com.devnamu.dopa.shieldaction` |  |  | 계정 승인 후 Distribution 확인 |  |

계정 entitlement 승인 후 Identifiers에서 App ID별 **Family Controls (Distribution)** 표시를 확인한다. 확장에 Development만 있으면 Bundle ID별 추가 신청한다.

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

## 진행 로그

| 날짜 | 내용 |
|---|---|
| 2026-08-25 | 지원 메일 완료. 운영 App Group·App ID 5개·capability 완료. Family Controls Framework entitlement 신청. |
| 2026-08-25 | ASC 비즈니스: 계좌 등록(처리 중), 한국 세금 제출(대기), 미국 Certificate·W-8BEN 제출. Free Apps Active, Paid Apps 사용자 정보 대기. 전자상거래법 Active. |

## 다음 할 일 (가까운 순서)

1. 약 24시간 후 ASC 비즈니스에서 계좌·한국 세금·Paid Apps가 Active/Verified인지 확인
2. App Store Connect에 앱 레코드 생성 (`Dopa`, Bundle ID `com.devnamu.dopa`, SKU `DOPA-IOS-001`)
3. Family Controls 승인 메일 확인 후 App ID별 Distribution 여부 점검
4. 개발용 App ID·App Group (`*.dev`) 생성
5. (병행) 법률 검토 의·iOS/Android 기술 spike

## 외부 차단 기록

| 날짜 | 차단 요인 | 영향 | 다음 조치 |
|---|---|---|---|
| 2026-08-25 | 계좌 주소 자동 검증 실패 | 정산 등록 지연 가능 | 주소 검토 후 확인으로 진행. 계좌 처리 중 |
|  | Family Controls 승인 대기 | TestFlight/스토어 Screen Time 배포 | 승인 메일 대기. 로컬 개발은 병행 가능 |
