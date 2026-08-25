# App Review 제출 메모 템플릿

아래 내용은 실제 빌드와 테스트 절차에 맞게 마지막으로 검증한 뒤 App Store Connect의 Review Notes에 입력한다. 비밀번호나 운영 토큰은 이 파일에 기록하지 않는다.

## 영문 템플릿

```text
Dopa is a self-directed digital wellbeing app for users aged 14 and older.

Test steps:
1. Complete the local age gate with an age of 14 or older. The exact birth date is discarded after the age band is calculated.
2. Sign in with Apple or Google.
3. Open Focus and select the 10-minute preset.
4. Grant Family Controls authorization when requested.
5. Select one nonessential test application.
6. Start the focus session and open the selected application.
7. The shield screen appears.
8. Select “Needed use”, then choose either five-minute access or end session. No reason is requested.

If Family Controls authorization is denied or unavailable, Dopa remains usable as a manual focus timer. Application selections, Screen Time tokens, usage records, check-ins, and original bypass records remain on the device and are not transmitted to our servers.

Dopa is not a parental surveillance, medical, diagnostic, or addiction-treatment service. It does not claim to remove or reset dopamine or guarantee improvements in concentration or sleep.

Account deletion is available in: Today > Settings > Account > Delete account.
Purchase restoration is available on the Dopa Plus paywall and subscription settings screen.
```

## 제출 직전 교체할 항목

- 실제 메뉴 이름과 순서
- 검증된 Review 연락처
- 심사자가 Plus 기능을 확인할 수 있는 방법
- 30~60초 기능 재현 영상 첨부 여부
- 구독 상품 심사 동시 제출 여부
- 권한 거부 시 timer-only 폴백의 실제 동작

숨겨진 심사 우회 코드나 운영 인증을 무력화하는 백도어는 만들지 않는다.
