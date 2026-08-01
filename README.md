# Dek TV Player — canal publico de updates

O app consulta este repositorio **direto no GitHub** (sem precisar da API), via:

`https://raw.githubusercontent.com/JuniorCabral/dek_tv_player_updates/master/manifests/<plataforma>.json`

## Plataformas

| Arquivo | Plataforma |
|---------|------------|
| `manifests/android-firetv.json` | Fire TV / Android |
| `manifests/windows.json` | Windows desktop |
| `manifests/macos.json` | macOS (reservado) |

## Publicar versao

1. Build release (APK / zip Windows).
2. Crie um **GitHub Release** (tag `vX.Y.Z`) e anexe os arquivos.
3. Atualize o JSON da plataforma com `version_name`, `version_code` e `download_url` (URL do asset).
4. Commit + push.

`version_code` deve ser inteiro crescente (bate com `+N` do `pubspec.yaml`).
