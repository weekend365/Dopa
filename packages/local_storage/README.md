# Dopa local storage

Pure-Dart Drift persistence for device-local focus sessions and the single tree
companion. Tree stages are intentionally not stored: they are derived from the
growth-credit ledger by `dopa_domain`.

Generate Drift code with:

```sh
dart run build_runner build
```

The mobile composition root should construct `DopaDatabase` with its platform
query executor, then inject `DriftFocusTreeRepository` into the domain use cases.
