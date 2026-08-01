# Dek TV Player — canal publico de updates

O app consulta este repositorio **direto no GitHub** (sem precisar da API), via:

`https://raw.githubusercontent.com/JuniorCabral/dek_tv_player_updates/master/manifests/<plataforma>.json`

## Plataformas

| Arquivo | Plataforma | Formato do asset |
|---------|------------|------------------|
| `manifests/android-firetv.json` | Fire TV / Android TV box | `.apk` |
| `manifests/windows.json` | Windows desktop | `.exe` (sempre) |
| `manifests/macos.json` | macOS (reservado) | `.zip` / `.dmg` |

## Publicar versao

1. Build release (APK Android + Windows Release).
2. Gere o instalador Windows com `scripts/package-windows-exe.ps1` (saida: `dist/dektv-player-windows.exe`).
3. Crie um **GitHub Release** (tag `vX.Y.Z`) e anexe:
   - `dektv-player-android.apk`
   - `dektv-player-windows.exe`
4. Atualize o JSON da plataforma com `version_name`, `version_code` e `download_url`.
5. Commit + push.

`version_code` deve ser inteiro crescente (bate com `+N` do `pubspec.yaml`).

### Windows

Sempre publicar **`.exe`**, nunca `.zip`. O script empacota a pasta `Release` do Flutter num autoextrator 7-Zip que, ao abrir, extrai e inicia `app_player.exe`.
