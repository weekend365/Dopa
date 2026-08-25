# ADR-0001: Apple 계정과 식별자

- 상태: 승인
- 결정일: 2026-08-25 KST
- 결정자: 창업자·개인 개발자

## 맥락

Dopa는 개인사업자인 1인 개발자가 대한민국에 iOS·Android MVP를 동시 출시한다. Apple Developer Program Individual 멤버십은 활성 상태이며 App Store의 법적 실명 판매자 표시를 수용한다. 운영 도메인은 `devnamu.com`이다.

## 결정

- Apple 멤버십은 Individual을 유지하고 D‑U‑N‑S 또는 조직 계정 전환을 MVP 선행 조건으로 두지 않는다.
- 운영 네임스페이스는 `com.devnamu.dopa`, 운영 App Group은 `group.com.devnamu.dopa`로 고정한다.
- 개발 환경은 `com.devnamu.dopa.dev`, `group.com.devnamu.dopa.dev`로 분리한다.
- 전체 식별자는 `config/apple-identifiers.json`을 단일 진실 원천으로 사용한다.
- Account Holder인 창업자가 메인 앱과 Screen Time 확장 4개 각각의 Family Controls 배포 entitlement를 신청한다.
- Xcode Automatic Signing을 우선 사용하고 CI용 App Store Connect API Key는 CI 도입 시 최소 권한으로 생성한다.

## 결과

- App Store 판매자에는 창업자의 법적 실명이 표시된다.
- 운영·개발 앱은 서로 다른 App Group, Firebase 프로젝트와 로컬 데이터를 사용한다.
- 식별자 변경은 새 앱 배포·구독·프로비저닝에 큰 영향을 주므로 Scope Freeze 변경 승인을 받아야 한다.
- Family Controls 승인이 지연되어도 개발 빌드는 진행하지만 승인 전 운영 배포 준비를 완료로 판단하지 않는다.

## 제외

- 조직 계정 전환
- D‑U‑N‑S 발급
- 운영 인증서·API 키·프로비저닝 프로파일의 저장소 보관
