# Family Controls 배포 entitlement 신청문

## 신청 대상

아래 운영 App ID 각각에 같은 목적 설명으로 신청한다.

1. `com.devnamu.dopa`
2. `com.devnamu.dopa.activitymonitor`
3. `com.devnamu.dopa.activityreport`
4. `com.devnamu.dopa.shieldconfiguration`
5. `com.devnamu.dopa.shieldaction`

## 복사해 사용할 영문 설명

> Dopa is a self-directed digital wellbeing app for users aged 14 and older. Users explicitly select up to three applications and start a time-limited focus session of 5, 10, 25, or 50 minutes. Family Controls, Managed Settings, and Device Activity are used only during user-initiated focus sessions. Users can allow access for five minutes or end the session within two actions. Application selections, Screen Time tokens, usage records, check-ins, and bypass records remain on the device and are not transmitted to our servers. Dopa is not a parental surveillance, medical, diagnostic, or addiction-treatment service.

## 신청 전 확인

- App ID가 `config/apple-identifiers.json`과 정확히 일치한다.
- 메인 앱과 확장 4개가 Explicit App ID다.
- 모든 대상에 Family Controls capability가 활성화되어 있다.
- 모든 대상에 운영 App Group `group.com.devnamu.dopa`가 연결되어 있다.
- 신청자는 Account Holder인 본인이다.

## 신청 후 증빙

- 각 App ID별 접수 화면을 민감 정보 없이 캡처한다.
- 접수일, 상태, Apple 요청 번호를 `EXTERNAL_ACTION_CHECKLIST_KO.md`에 기록한다.
- 2주 이상 변화가 없으면 Apple Developer Support에 문의한다.
- 승인 상태와 배포 프로비저닝 프로파일의 entitlement 포함 여부를 모두 확인한 뒤 완료 처리한다.

공식 안내: [Requesting the Family Controls entitlement](https://developer.apple.com/documentation/FamilyControls/requesting-the-family-controls-entitlement)
