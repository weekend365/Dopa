# 같이 시작하기 — 이번 구현 검증 보고

2026-09-10. 판정: **요청된 개발용 단일 흐름 구현·자동 테스트 완료. 운영 출시/동행 콘텐츠 가치 검증은 미완료.**

## 바뀐 사용자 경험

dev flavor의 홈에서 기존 집중/체크인 다음 카드로 ‘책상에 시작할 자리 만들기’를 연다.
무료 텍스트 샘플임을 확인하고 바로 시작한다. 4개 작은 행동 안내, 일시정지·이어하기·다시 보기·직접 넘기기·선택적 30초 자동 넘김을 제공한다.
중간에 나가도 단계는 보관되고 다시 열면 정지 상태로 이어진다. 안내를 마치거나 중간에 결과 화면을 열어 세 가지 자기보고 중 하나를 직접 선택한다.
그때만 결과가 저장되며 ‘오늘은 여기까지’로 홈에 돌아가거나 별도 생활 행동 기록을 볼 수 있다. 인사이트에서도 기록으로 연결되고 개별 삭제가 가능하다.
운영 flavor의 홈 카드와 세션/기록 직접 경로는 비활성이다. 가격·결제·미디어가 준비된 것처럼 표시하지 않는다.

## 주요 변경 파일

| 변경 | 파일 |
|---|---|
| 홈 진입·기존 리포트 연결 | `apps/mobile/lib/features/today/presentation/today_page.dart`, `features/insights/presentation/weekly_report_page.dart` |
| 경로·운영 차단 | `apps/mobile/lib/app/router/dopa_router.dart`, `features/companion/application/companion_controller.dart` |
| 안내·결과·기록 UI | `apps/mobile/lib/features/companion/presentation/companion_{entry_card,page,history_page,copy}.dart` |
| 콘텐츠/실행/자기보고/저장 계약 | `packages/domain/lib/src/companion/companion_session.dart`, `companion_repository.dart`, `lib/dopa_domain.dart` |
| 로컬 트랜잭션·v4·계정 삭제 | `packages/local_storage/lib/src/repository/drift_companion_repository.dart`, `database/dopa_database.dart`, 생성 `dopa_database.g.dart`, `lib/dopa_local_storage.dart` |
| 저장소 설명·삭제 회귀 | `apps/mobile/lib/core/persistence/dopa_database_providers.dart`, `apps/mobile/test/core/persistence/local_account_data_lifecycle_test.dart` |
| 신규/확장 테스트 | `packages/domain/test/companion_session_test.dart`, `packages/local_storage/test/drift_companion_repository_test.dart`, `dopa_database_migration_test.dart`, `apps/mobile/test/features/companion/` |
| 전체 계획·콘텐츠·결정 | `docs/product/COMPANION_IMPLEMENTATION_PLAN_KO.md`, `COMPANION_CONTENT_KO.md`, `MVP_SCOPE_FREEZE_V1_KO.md` v1.3, `docs/adr/0003-local-companion-sample.md`, `README.md` |

## 실행 환경과 명령

Windows 호스트, 저장소 `.tooling/flutter`의 Flutter **3.47.0**, 내장 Dart **3.13.0** 사용.
PATH의 Flutter는 3.47.2 캐시여서 사용하지 않았다. 네트워크 없이 기존 캐시에서 `pub get --offline`으로 workspace를 해석했다.
프로젝트 의존성·버전·lockfile은 변경하지 않았다. OS 실행 정책은 시스템 설정을 변경하지 않고 읽기 전용 계약 검사 프로세스에만 실행 옵션을 적용했다.

재현 가능한 PowerShell 명령(저장소 루트에서, 이 환경의 로컬 SDK 기준):

```powershell
$env:FLUTTER_ROOT = "$PWD\.tooling\flutter"
$env:PUB_CACHE = "$PWD\.tooling\pub-cache"
$env:APPDATA = "$PWD\.tooling\appdata"
$env:CI = 'true'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
$dopaDart = "$env:FLUTTER_ROOT\bin\cache\dart-sdk\bin\dart.exe"
$dopaFlutterTools = "$env:FLUTTER_ROOT\bin\cache\flutter_tools.snapshot"
& $dopaDart $dopaFlutterTools --no-version-check pub get --offline

Push-Location packages/local_storage
& $dopaDart run build_runner build
& $dopaDart test --coverage=coverage
& $dopaDart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
& $dopaDart run coverage:format_coverage --lcov --in=coverage --out=coverage/domain-lcov.info --report-on=../domain/lib
Pop-Location
Push-Location packages/domain
& $dopaDart test --coverage=coverage
& $dopaDart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
Pop-Location
Push-Location apps/mobile
& $dopaDart $dopaFlutterTools --no-version-check test --no-pub --coverage --reporter expanded
Pop-Location

& $dopaDart analyze .
& $dopaDart format --output=none --set-exit-if-changed apps/mobile packages/domain packages/local_storage
powershell -NoProfile -ExecutionPolicy Bypass -File tooling/validate_apple_identifiers.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tooling/validate_tree_assets.ps1
git diff --check
```

일반 개발 환경에서는 고정 버전의 `flutter`/`dart` 또는 FVM으로 동일 패키지 명령을 실행한다.
생성 코드 재생성 전후 SHA-256도 비교하여 동일함을 확인했다.

| 검사 | 최종 결과 |
|---|---|
| Domain | **55/55 통과** |
| Local storage | **27/27 통과** |
| Mobile application/widget/golden | **94/94 통과** |
| 합계 | **176/176 통과**, 이번 범위 테스트 35개 추가 |
| 정적 분석 | 문제 없음 |
| 포맷 | 95개 파일 검사, 변경 필요 0개 |
| Drift 생성 재현성 | 재생성 전후 해시 동일 |
| 기존 Apple 식별자/가격 계약 | 통과, 설정 값 미변경 |
| 나무 에셋 계약 | 통과, 총 3,077,659 bytes |
| diff 공백 검사 | 통과 |

커버리지(실행 가능한 계측 line, 생성 코드 제외): mobile 1,477/1,714=86.2%, application 466/521=89.4%, storage 360/482=74.7%.
domain 단독 테스트는 298/394=75.6%이며 **domain+storage 테스트가 실행한 domain line을 파일/행별 합집합**으로 합치면 335/394=85.0%다. 같은 행을 중복 합산하지 않았다.
workspace 합계는 이 중복 없는 각 패키지 수치로 2,172/2,590=83.9%다.
신규 companion 모바일 영역은 320/330=97.0%, 새 저장소는 102/103=99.0%다.
이 line 수치는 실제 플랫폼/미디어/결제 분기 검증을 의미하지 않는다.

## 실제 검증한 시나리오

- 홈→준비→4단계→결과→기록→홈 전체 위젯 흐름. 세 가지 결과를 각각 확인.
- 안내의 끝에서 기록이 비어 있음, 부분 수행도 실패로 표시하지 않음, 기록 후 추가 세션 자동 실행 없음.
- 중간 이탈 후 단계 복원, 결과 대기 후 재진입, foreground 자동 진행과 inactive 중단, 돌아와도 자동 시작하지 않음.
- 진행 저장 중 background 전이가 와도 뒤늦은 완료 콜백이 재생을 되살리지 않음.
- 읽기/시작/단계/결과 저장/기록 조회/개별 삭제 오류 후 재시도. 완료 저장 실패에 성공 UI 없음.
- DB 트랜잭션의 결과 삽입 후 활성 상태 갱신 실패를 강제하고 전체 롤백/같은 실행 재시도를 확인.
- 결과 중복 클릭·동시 저장·재전송은 첫 결과 하나 유지, 활성 실행은 하나, 다음 무료 실행 가능.
- 실제 SQLite 파일을 닫고 재개방해 단계와 확정 결과를 각각 복원.
- v1/v2/v3 업그레이드, v2/v3의 원본 집중/나무/원장/체크인 보존 및 기존 성장 unique 제약 유지.
- 기존 완료 집중의 시간·의도·나무·원장이 생활 기록 후에도 동일. 진행 중 집중의 설정·보호 모드·우회 상태도 동일.
- 개별 기록 삭제, 로그아웃/계정 삭제 경계에서 실행·결과 제거. 미확인 실행은 개별 ‘완료 기록 삭제’에 휩쓸리지 않음.
- 320×568, 200% 글자에서 긴 한국어 안내/결과/기록을 스크롤로 조작하고 버튼 semantics의 레이블·활성·탭 액션 확인.
- prod 비활성 판단 및 노출 OFF 경로에서 홈 진입 숨김·직접 세션/기록 경로 차단.
- 기존 인증·집중·체크인·주간 리포트·나무 Light/Dark golden 포함 전체 회귀 테스트 통과.

초기 실행 중 발생한 테스트 도구 경로/컴파일 오류와 위젯 스크롤 프레임·semantics handle 정리 오류는 수정 후 재실행했다.
현재 미해결 테스트 실패는 없다. 초기 실패 출력을 성공으로 계산하지 않았다.

## 미구현·미검증과 남은 위험

- 원본 영상/사람 음성·자막 파일 없음. 재생 로딩·실패/재시도·오디오 중단·네트워크·캐시 검증은 해당 미디어 구현 전이라 **미검증**이다.
- 실제 iOS/Android 빌드·설치·화면 잠금·전화·메모리 종료·VoiceOver/TalkBack 실기기 검증을 하지 않았다. Flutter lifecycle 시뮬레이션/semantics 검사는 이를 대신하지 않는다.
- 이번 안내는 수동 텍스트 기본, 자동 넘김도 화면을 켠 상태만 지원한다. 정지·복원 시 현재 단계의 30초 대기 창은 처음부터 시작한다.
- 초 단위 진행 위치/음성만 듣기/제작본 자막 지원은 아직 없다. 텍스트 경험을 사람의 동행 가치와 같다고 주장하지 않는다.
- 기존 로그인 SDK는 아직 대역이며 스토어 상품/기존 실제 구독자 여부를 확인하지 않았다. 결제 접근권한·취소·실패·보류·복원·만료·환불·해지 잔여기간·유예·가격 조회는 **설계만 작성, 테스트하지 않음**.
- 생활 결과의 성장 지급은 미구현. 현재 지급 0건이므로 중복 **성장** 지급 위험을 새로 도입하지 않았고, 향후 연결 시 별도 멱등 테스트가 필요하다.
- 분석 전송/동의/실사용 데이터 제외 파이프라인은 미구현. 개발 flavor 비활성 검사를 분석 중복 방지나 실제 매출 검증으로 보고하지 않는다.
- 결과는 로컬이며 기기 이전·재설치 복원을 약속하지 않는다. 목록은 최근 50개, 전체 삭제는 기존 계정 삭제 경계다. 저장된 콘텐츠 버전 유지가 필요하다.
- v4 업그레이드는 원본을 보존한다. 롤백 시 UI만 비활성하고 DB 스키마를 내리거나 삭제하지 않는다.

## 다음 단계의 정확한 범위

다음 작업은 **무료 책상 세션 한 개의 실제 사람 미디어**에 한정한다.
제작안 A의 촬영/녹음·사용권·검수본을 확보하고 버전/단계/자막 타임라인을 고정한다.
그 한 개에 재생·정지·seek/replay·텍스트 폴백·캐시·로딩 실패 재시도·오디오 중단/백그라운드·프로세스 복원을 연결한다.
iOS/Android 실제 기기로 잠금/전화/오프라인/실행 종료 및 VoiceOver/TalkBack을 확인한다.
이 단계에도 과금·생활 성장·나머지 카탈로그는 포함하지 않는다. 공개는 콘텐츠 권리와 검증 통과 후 별도 승인으로 결정한다.

첫 실사용 실험은 텍스트 개발 테스트와 분리해 성인 30명/14일 코호트로 계획한다.
핵심은 주 2일 이상 직접 ‘하려던 만큼/조금 시작’으로 확인한 사용자 수, 보조는 서로 다른 3일 사용 10명이라는 임시 투자 기준이다.
자기보고·관찰 기간·분모 n/N를 명시하고 신규/기존·개발/실사용을 섞지 않는다. 결제·갱신·정산 실험은 판매 가능한 후속 단계에서만 한다.
전체 단계와 출시 체크리스트는 [구현 계획](COMPANION_IMPLEMENTATION_PLAN_KO.md), 원고/권리 확인은 [콘텐츠 제작안](COMPANION_CONTENT_KO.md)에 있다.
