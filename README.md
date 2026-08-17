# Dek TV Player — canal publico de updates

O app consulta este repositorio **direto no GitHub** (sem auth), via:

`https://raw.githubusercontent.com/JuniorCabral/dek_tv_player_updates/master/manifests/<arquivo>.json`

## Plataformas / flavors

| Arquivo | Variante | Asset |
|---------|----------|-------|
| `manifests/android-firetv.json` | Fire TV / TV box | `dektv-player-firetv.apk` |
| `manifests/googletv.json` | Google TV | `dektv-player-googletv.apk` |
| `manifests/android-mobile.json` | Android mobile | `dektv-player-mobile.apk` |
| `manifests/ios.json` | iOS mobile | TestFlight / App Store |
| `manifests/windows.json` | Windows desktop | `dektv-player-windows.exe` |
| `manifests/macos.json` | macOS (reservado) | — |

## Publicar versao

1. Build release com o flavor correto (`firetv` / `googletv` / `mobile`).
2. Windows: `scripts/package-windows-exe.ps1` → `dist/dektv-player-windows.exe`.
3. GitHub Release (tag `vX.Y.Z`) com os assets nomeados acima.
4. Atualize o JSON da variante (`version_name`, `version_code`, `download_url`).
5. Commit + push.

`version_code` deve ser inteiro crescente (bate com `+N` do `pubspec.yaml`).

### Builds Flutter (app_player)

```bash
flutter build apk --release --flavor firetv --dart-define=DEK_VARIANT=firetv
flutter build apk --release --flavor googletv --dart-define=DEK_VARIANT=googletv
flutter build apk --release --flavor mobile --dart-define=DEK_VARIANT=mobile
flutter build windows --release
```

iOS (macOS + Xcode):

```bash
flutter build ipa --dart-define=DEK_VARIANT=mobile
```
