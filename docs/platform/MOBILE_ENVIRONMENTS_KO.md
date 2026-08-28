# Dopa 모바일 환경 구성

Dopa는 개발 앱과 운영 앱을 별도 식별자로 빌드한다.

| 환경 | Android applicationId | iOS Bundle ID | 표시 이름 | Firebase 프로젝트 |
| --- | --- | --- | --- | --- |
| dev | `com.devnamu.dopa.dev` | `com.devnamu.dopa.dev` | Dopa Dev | `dopa-dev` |
| prod | `com.devnamu.dopa` | `com.devnamu.dopa` | Dopa | `dopa-prod` |

## Flutter 실행

개발 환경이 기본 flavor다. Dart 코드는 Flutter의 `appFlavor` 값을 사용하므로 별도의 `--dart-define`은 필요하지 않다.

```bash
# 개발
flutter run --flavor dev

# 운영 확인
flutter run --flavor prod

# 운영 Android 번들
flutter build appbundle --flavor prod

# 운영 iOS 아카이브
flutter build ipa --flavor prod
```

`apps/mobile/pubspec.yaml`의 `default-flavor`가 `dev`이므로 flavor를 생략한 로컬 실행도 개발 환경을 사용한다. 운영 빌드와 배포 자동화에서는 `--flavor prod`를 명시한다.

## Firebase 연결 시점

Firebase 설정 파일은 환경별로 생성한다.

```bash
flutterfire configure \
  --project=dopa-dev \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=com.devnamu.dopa.dev \
  --ios-bundle-id=com.devnamu.dopa.dev \
  --platforms=android,ios

flutterfire configure \
  --project=dopa-prod \
  --out=lib/firebase_options_prod.dart \
  --android-package-name=com.devnamu.dopa \
  --ios-bundle-id=com.devnamu.dopa \
  --platforms=android,ios
```

`firebase_options_dev.dart`와 `firebase_options_prod.dart`는 공개 앱 식별자만 포함한다. Apple private key, 서비스 계정, signing key는 저장소에 넣지 않는다.

Firebase Auth는 로컬 연령 확인을 통과한 뒤 초기화한다. Remote Config, Crashlytics, RevenueCat은 로그인과 서비스 동의가 끝난 뒤 초기화한다.

## iOS Xcode scheme

Xcode shared scheme은 `dev`와 `prod`다.

- `dev`: `Debug-dev`, `Profile-dev`, `Release-dev`, Bundle ID `com.devnamu.dopa.dev`
- `prod`: `Debug-prod`, `Profile-prod`, `Release-prod`, Bundle ID `com.devnamu.dopa`

Apple Developer와 Xcode에서 두 Bundle ID, App Group, Sign in with Apple capability를 각각 등록한다. 기준값은 [`config/apple-identifiers.json`](../../config/apple-identifiers.json)에서 확인한다.
