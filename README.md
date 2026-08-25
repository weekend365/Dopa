# Dopa

Dopa는 자극적인 디지털 행동을 알아차리고 스스로 조절하도록 돕는 한국형 디지털 웰빙 서비스입니다.

현재 저장소에는 구현 전 의사결정과 Apple 출시 준비를 위한 문서가 있습니다.

- [통합 제품·사업 구상안](docs/DOPA_INTEGRATED_PRODUCT_PLAN_KO.md)
- [MVP Scope Freeze v1.1](docs/product/MVP_SCOPE_FREEZE_V1_KO.md)
- [프로젝트 개발 규칙](docs/PROJECT_RULES_KO.md)
- [1인 개발자 Apple 출시 런북](docs/platform/apple/APPLE_LAUNCH_RUNBOOK_KO.md)
- [Apple 외부 작업 체크리스트](docs/platform/apple/EXTERNAL_ACTION_CHECKLIST_KO.md)
- [Pull Request 템플릿](.github/pull_request_template.md)

## 확정된 Apple 식별자

- 운영 앱: `com.devnamu.dopa`
- 운영 App Group: `group.com.devnamu.dopa`
- 개발 앱: `com.devnamu.dopa.dev`
- 개발 App Group: `group.com.devnamu.dopa.dev`

전체 앱·확장·구독 식별자는 [apple-identifiers.json](config/apple-identifiers.json)을 단일 진실 원천으로 사용합니다.

Mac에서 최초 모바일 프로젝트를 생성할 때는 `bash tooling/bootstrap_mobile_macos.sh`를 실행합니다. 기존 `apps/mobile`이 있으면 스크립트가 중단됩니다.

> Dopa는 의료기기가 아니며 질환을 진단·치료·치유·예방하지 않습니다. 여기서 말하는 ‘도파민 디톡스’는 뇌의 도파민을 제거하거나 초기화한다는 뜻이 아닙니다.
