# Dopa 그림일기 개발 서버

Node.js 24 이상. 단일 프로세스 HTTP API + SQLite 영속 작업 큐 + sharp 사진 정규화 + OpenAI Images edits. **공개 운영 서버가 아니다.** 기본 바인딩은 PC의 `127.0.0.1:8787`이며 외부 네트워크에 공개하지 않는다.

## 실행

### Doppler 연결 (권장)

프로젝트 `dopa`, 구성 `dev`를 사용한다. 새 PC에서는 `doppler login` 후 저장소 루트에서 `doppler setup --project dopa --config dev --no-interactive`를 실행한다. `doppler.yaml`에는 프로젝트 이름만 있으며 비밀 값은 없다.

최초 한 번 키를 숨김 입력 창으로 Doppler에 저장한다. 키 전체를 복사한 뒤 창의 **Paste** 버튼을 누르고 표시된 문자 수를 확인한 다음 **Continue**를 누른다. 한 글자·공백·잘못된 접두어는 저장할 수 없다. 형식 검사는 실제 API 인증 검증이 아니다:

```powershell
powershell -ExecutionPolicy Bypass -File tooling/set_diary_key.ps1
```

이후 서버 실행·재시작은 다음 명령을 사용한다:

```powershell
powershell -ExecutionPolicy Bypass -File tooling/start_diary_server.ps1 -Doppler
```

키는 stdin으로 Doppler에 저장하고 서버 환경변수로 주입한다. 명령 인자·저장소 파일·로그에 출력하지 않는다. Doppler 실행은 `--no-fallback`으로 로컬 시크릿 캐시를 만들지 않으며, 키 조회 실패·빈 키일 때 기존 서버를 중단하지 않는다. 키 변경 후 서버 재시작이 필요하다. `/v1/health`의 `enabled`는 키 존재 여부이며 OpenAI 인증·결제 유효성 검사가 아니다.

### 임시 환경변수 실행

```powershell
cd C:\Users\cnnet3\Dopa\backend\diary
npm.cmd ci
cd ..\..
powershell -ExecutionPolicy Bypass -File tooling/start_diary_server.ps1
```

키 없이 실행하면 `/v1/health`는 `enabled: false`를 반환한다. 앱은 사진 일기 저장을 제공하고 변환 버튼은 비활성화한다. 가짜 그림을 성공 결과로 만들지 않는다.

실제 변환을 켤 때(키를 파일·채팅·명령 기록에 넣지 않는 숨김 입력):

```powershell
powershell -ExecutionPolicy Bypass -File tooling/start_diary_server.ps1 -PromptForKey
```

스크립트는 자신이 기록한 서버 PID와 실행 경로를 확인한 뒤 해당 개발 서버만 재시작한다. 키는 자식 서버 환경변수로 전달하고 파일에 저장하지 않는다. 이미 `OPENAI_API_KEY` 환경변수를 준비했다면 `-PromptForKey` 없이 실행한다. OpenAI 프로젝트에 모델 접근과 결제 설정이 필요할 수 있다.

Android 개발 앱은 `http://127.0.0.1:8787`을 사용한다. 스크립트가 `emulator-5554`에 `adb reverse tcp:8787 tcp:8787`을 설정한다. 서버 재시작 후 일기 화면의 **연결 다시 확인**을 누르면 된다. 공개 HTTPS 서버가 준비되면 `--dart-define=DOPA_DIARY_API_URL=https://...`를 사용한다. 운영 flavor는 기본 URL이 비어 있고 HTTP를 거부한다. 서버 주소 변경은 기존 익명 세션/작업을 이전하지 않으므로 기존 작업을 먼저 삭제/정리한다.

## 동작 계약

- 원본과 본문은 앱 SQLite v7. 본문은 API 구조에 필드 자체가 없다.
- 사진 전송 동의 후 익명 서버 토큰 발급. 토큰은 Flutter Secure Storage, 서버에는 SHA-256 해시만 저장.
- `PUT /v1/jobs/{32자리 랜덤 ID}`는 PNG 바이트만 받는다. JSON 메타데이터/일기 글/원본 파일명/임의 URL을 받지 않는다. 업로드 최대 10MiB, 디코딩 최대 2,400만 픽셀, 최대변 1536px 재인코딩, EXIF 제거.
- 한도는 최초 세션 시간대 오프셋의 날짜 기준 하루 성공 한 건. 여행·서머타임에도 최초 오프셋 유지. 앱의 일기 날짜는 작성 시작 시 기기 날짜로 고정. 과거 일기를 오늘 변환하면 오늘 한도를 사용.
- 요청 ID를 앱 DB에 먼저 기록해 통신 재시도 시 같은 ID 사용. 다른 동시 요청은 SQLite 트랜잭션에서 하나만 예약. 명확한 실패만 하루 최대 3회 시도. 타임아웃/5xx/서버 재시작 중 처리 작업은 `uncertain`으로 보존하고 자동 재호출하지 않는다.
- 기본 전체 한도 UTC 하루 25회 API 호출(실패 포함), 익명 세션 발급 50회. 숫자는 환경/생성자 설정. 익명 세션은 실제 사람을 식별하지 않아 재설치 남용을 완전히 방지하지 못한다. 호출 수 제한은 정확한 달러 상한을 뜻하지 않는다.
- 원본은 처리 완료/실패 시 즉시 제거. 결과는 앱의 로컬 저장 완료 ACK 후 제거. 서버 임시 사진은 생성 후 최대 24시간+정리 주기(60초) 내 삭제. 서버 중단 중에는 삭제 실행 불가하며 재시작 시 정리. 개인 삭제는 작업 tombstone을 남기고 사진/usage를 삭제. 사용량/중복 방지 최소 작업 정보는 7일, 익명 세션은 전체 삭제까지 보관.
- 서버 DB `secure_delete`와 WAL checkpoint를 사용한다. 서버 데이터 폴더를 백업하거나 로그에 본문/사진/토큰을 넣지 않는다. 공급자의 별도 보관까지 삭제했다고 약속하지 않는다.
- 전체 삭제는 서버 삭제 성공 후 보안 토큰과 로컬 기록을 삭제한다. 오프라인이면 내용을 유지하고 재시도를 안내한다. 개별 삭제 이후에도 전체 삭제가 토큰을 찾을 수 있도록 로컬 remote-use 마커를 유지한다.
- CORS 허용 없음(네이티브 앱 전용). 모든 작업 조회/다운로드/ACK/삭제는 Bearer 소유권 검증. 최초 가입은 버전 동의+전역 발급 제한. 공개 배포 전 HTTPS reverse proxy, 요청 rate limit, attestation/남용 방지, 운영 로그·비밀 저장·보관·스토어 고지 검토가 필요하다. 현재 localhost 개발 서버에 Firebase/App Check를 연결하지 않았다.

## 그림체와 공급자

`src/style.mjs`: `dopa-gouache-v1`, `gpt-image-2.5-sunburst`, medium, 1024×1024 WebP, 결과 1장. 원본 사진과 Dopa 정원 `light_0.webp`를 색/붓질 참고로 전달하며 구도/사물은 복제하지 않도록 지시한다. 일기 텍스트는 전달하지 않는다. 이 기준 아트는 이전 정원 작업에서 생성한 Dopa 에셋이며, 새 사진 결과의 품질을 검증했다고 간주하지 않는다.

공식 사양 확인 2026-09-11:
- https://developers.openai.com/api/docs/guides/image-generation
- https://developers.openai.com/api/docs/guides/your-data
- https://developers.openai.com/api/docs/pricing

키 연결 후 동의받은 사진/테스트 사진 20~30장(인물·동물·음식·실내·밤·풍경)으로 구도/피사체 보존, 그림체 일관성, 처리 시간, usage 기반 비용을 기록한다. 현재 실 API 품질/지연/단가는 미검증이며 과금/무료 운영 정책은 이 측정 후 결정한다.

## 검증

```powershell
cd backend/diary
npm.cmd test
```

`test/fixture_server.mjs`는 8788 포트에서만 실행하는 통합 테스트 대역이다. 외부 API 없이 입력을 WebP로 재인코딩한다. **실제 그림 변환이 아니며 개발 앱의 기본 서버로 사용하지 않는다.** `apps/mobile/integration_test/diary_flow_test.dart`는 격리된 메모리 활동 DB, 합성 에셋 사진 선택 대역, 실제 HTTP와 네이티브 보안 저장소를 사용한다. `--dart-define=DOPA_NATIVE_PICKER_TEST=true`로 실제 Android Photo Picker를 열고 직접 테스트 사진을 선택할 수도 있다. 두 경로 모두 검증했다. 테스트 도구가 종료 시 개발 앱을 제거할 수 있으므로 개인 데이터가 있는 기기에서 실행하지 않는다.

```powershell
node test/fixture_server.mjs
# 별도 터미널에서
adb -s emulator-5554 reverse tcp:8788 tcp:8788
cd ../../apps/mobile
flutter test integration_test/diary_flow_test.dart -d emulator-5554 --flavor dev
```

iOS는 사진 권한 설명을 추가했지만 실기기·Keychain 동작은 미검증이다. 새 SDK: image_picker(BSD/Apache), flutter_secure_storage(BSD), 서버 sharp(Apache). 앱은 광범위한 사진 라이브러리 권한 대신 선택한 사진만 읽으며 Android 자동 백업을 비활성화한다. 서버 동기화/복원/공유 피드/결제/사진 성장 보상은 없다.
