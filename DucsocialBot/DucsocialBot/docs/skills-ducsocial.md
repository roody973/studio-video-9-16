# Skills propres à @DucSocialBot — brouillons

Trois skills écrites pour le bot, pas des skills génériques copiées du profil `default`.
Elles sont **installées** dans `~/.hermes/profiles/social` depuis le 14/11/2026 ; ce dossier
reste la version de travail, à relire avant toute réinstallation.

## Contenu

| Skill | Rôle |
|---|---|
| `ducsocial-video` | chaîne complète script → voix off → sous-titres → MP4 |
| `studio-video-9-16` | pilote le repo studio avec Playwright + ffmpeg |
| `ducsocial-soustitres` | génère et incruste des sous-titres ASS en zone sûre |

Le skill `studio-video-9-16` contient aussi :

| Fichier | Rôle |
|---|---|
| `scripts/rendu-auto.mjs` | storyboard visuel → MP4, sans voix |
| `scripts/pipeline.mjs` | storyboard avec narration → voix + sous-titres + MP4 |
| `api/server.mjs` | API locale `POST /render`, stockage et envoi Telegram optionnel |

## Ce qui a été testé le 14/11/2026

- Studio chargé en headless avec Chromium 1208.
- Storyboard 3 scènes × 1 s → **90 frames → MP4 3,00 s**, 1080×1920, H.264 High, `yuv420p(tv)`.
- Voix française `say -v Thomas` : 3 scènes, durées mesurées et réinjectées.
- Mixage des 3 voix avec `adelay` + `amix`.
- Sous-titres ASS en `PlayRes 1080×1920`, `MarginV 230` : incrustés en bas, lisibles.
- Sortie finale test : **8,2 s, 1080×1920, H.264 + AAC**, 1,5 Mo.

Le test n'est pas un livrable de production : la voix `say` est robotique et la musique
n'est pas encore gérée. La chaîne technique, elle, fonctionne de bout en bout.

## Test réel du bot après installation

Le 14/11/2026, le bot lui-même a exécuté `ducsocial-video` sur un test de 2 scènes :

- sortie : `6,20 s`, 1080×1920, H.264 High, `yuv420p`, 30 fps, AAC 48 kHz ;
- 186 frames, voix `Thomas`, sous-titres ASS incrustés ;
- seul le MP4 de test a été écrit, rien n'a été publié.

Le bot a trouvé un bug au passage : `apad` crée un flux audio infini, il faut borner avec
`-t <durée>`. La skill a été corrigée après le test.

Démo : `demo/bot-test.mp4` (6,2 s) et une frame de contrôle `demo/bot-frame.png`.

## API locale

```bash
STUDIO_HTML=/chemin/studio-video-9-16/index.html \
RENDER_TOKEN=un-secret-local \
PORT=8787 \
node api/server.mjs
```

```bash
curl -s -H "Authorization: Bearer un-secret-local" \
  -H "content-type: application/json" \
  -d @storyboard.json http://127.0.0.1:8787/render
```

Le corps accepte `telegram: true` et `caption` pour envoyer le MP4 sur Telegram
(`TELEGRAM_BOT_TOKEN` + `TELEGRAM_HOME_CHANNEL`). L'API est liée à `127.0.0.1` par défaut.
Le stockage est `~/.hermes/profiles/social/cache/renders/<job_id>/`.

Testé le 14/11/2026 : `POST /render` sur 2 scènes → **6,20 s**, 1080×1920, H.264 + AAC,
1,08 Mo, réponse JSON avec `job_id`, `duration`, `video`, `audio`.

## Réinstallation

Copier chaque dossier dans le profil social :

```bash
SKILLS=~/.hermes/profiles/social/skills/social-media
cp -R ducsocial-video "$SKILLS/"
cp -R studio-video-9-16 "$SKILLS/"
cp -R ducsocial-soustitres "$SKILLS/"
```

Puis sauvegarder le profil et redémarrer le gateway. Ne pas installer avant validation :
le SOUL du bot demande l'accord de Roudy avant toute modification de son système.

## Dépendances

- Node 26 : `~/.hermes/tools/node-26.12.1-darwin-arm64/bin/node`
- Playwright 1.64 + Chromium 1208 (présents dans Hermes)
- ffmpeg 9.0.1 : `~/.hermes/tools/ffmpeg-9.0.1-darwin-arm64/ffmpeg`
- `say` macOS avec la voix `Thomas`
- `unzip`

## Limites connues

- Le rendu charge toutes les frames en mémoire (ZIP) : au-delà de ~60 s à 30 fps, découper.
- La voix `say` est gratuite et locale, mais peu naturelle. Le toolset `tts` de Hermes peut
  la remplacer sans changer le reste.
- Aucune musique : il faudra une source libre de droits et un ducking.
- Les sous-titres sont par scène, pas mot-à-mot.
- La publication reste manuelle.
