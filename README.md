# Dek TV — atualizações do app player

Repositório de **manifests** e releases de APK do Dek TV Player (Fire TV / Android).

## Como publicar uma versão

1. Gere o APK release no monorepo:
   `flutter build apk --release` em `app_player/`.
2. Crie um GitHub Release neste repositório (tag `vX.Y.Z`) e anexe o APK
   (ex.: `dektv-player-X.Y.Z.apk`).
3. Atualize `manifests/android-firetv.json` com `version_name`, `version_code`,
   `apk_url` (URL do asset do Release) e `changelog`.
4. Commit + push do manifest.

O app consulta o manifest (via API Dek TV ou URL direta) e baixa o APK.

## Importante — instalação no Fire TV

Apps sideload **não** instalam silenciosamente. Após o download o sistema pede
que o usuário confirme **Instalar**. O app avisa isso com antecedência (~10s).

Silent install só existe com privilegios de sistema / Device Owner — fora do
escopo do app de consumidor.
