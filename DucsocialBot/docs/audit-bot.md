# Audit @DucSocialBot — 14 novembre 2026

> **Mise à jour 16 h 45** : les P0 ont été appliqués. 3 skills propres installées,
> 84 skills désactivées, SOUL et mémoire alignés, menu Telegram à 15 commandes, gateway
> redémarré. Le studio a été corrigé (fondu, durée WebM, annulation, autosave, zones sûres,
> 12 Mb/s) et une API `POST /render` a été ajoutée et testée. Voir
> `ducsocial-skills/README.md`.

Périmètre : profil Hermes `~/.hermes/profiles/social` (SOUL, config, skills, mémoire, sessions, logs). Lecture seule : aucun fichier du bot n'a été modifié.

## 1. Verdict

Le bot est **vivant et connecté** : gateway actif, Telegram en polling, allowlist à un seul identifiant, `.env` en `600`. La dernière livraison connue (plan de contenu du 14/11 à 11 h 03) est **bonne sur le fond** : niche ancrée dans le métier de Roudy, 7 idées classées, script plan par plan, hashtags, une seule question finale.

Mais le bot n'est pas encore un « bot social » propre :

- **102 skills actives**, dont **2 seulement** en `social-media` ; le reste est un clone généraliste (finance, paris, Plex, macOS, Hermes…).
- Le skill social principal est **dupliqué** entre le profil et le dossier global, avec deux versions différentes.
- Le bot **ne sauvegarde pas** ses livraisons dans le dossier de contenu : il répond dans Telegram, puis le texte reste dans `state.db`.
- Le repo `studio-video-9-16` **n'est référencé nulle part** dans le profil : le bot s'arrête au script, il ne produit pas la vidéo.
- La dernière livraison **dépasse la consigne** (48 lignes au lieu de 40) et contient au moins une affirmation non sourcée (« 20 ans »).

Priorité : recentrer le bot, unifier le skill social, ajouter la persistance, puis brancher le studio.

## 2. Architecture constatée

| Élément | État |
|---|---|
| Profil | `~/.hermes/profiles/social` |
| Rôle | « Social Media Agent — @DucSocialBot » (`SOUL.md`, 2,9 Ko) |
| Modèle configuré | `gpt-6.1-terra` via `openai-codex` |
| Modèle de secours | `deepseek-v4-pro` |
| Mémoire | dit `deepseek-flash` — **incohérent** avec la config |
| Telegram | connecté, polling, 60 commandes au menu, 10 masquées |
| Allowlist | 1 identifiant, celui de Roudy — correct |
| Secrets | `.env` en `-rw-------` — correct |
| Cron | `jobs.json` vide ; une session `cron` a tourné le 14/11 à 11 h 03 |
| Dernière session visible | 5 sessions dans `state.db`, dont 1 Telegram (18/10) |

Les erreurs `Gateway is shutting down; executor unavailable` du 14/11 à 10 h 14 et 10 h 52 sont des **courses de redémarrage**, pas des pannes Telegram : la reconnexion réussit juste après. Le heartbeat gateway continue jusqu'à 16 h 12.

## 3. Audit des skills

### 3.1 Inventaire

- **102 skills** dans le prompt de sélection, **113 fichiers `SKILL.md`** au total (archive et hub compris).
- Répartition : 20 productivité, 15 recherche, 12 agents autonomes, 12 développement, 11 sysadmin, 10 créatif, 7 Apple, 4 média, 3 notes, 2 email, **2 social-media**, 1 chacun pour devops, migration, pCloud, web.
- Les descriptions pèsent **5 516 caractères** ; ce n'est pas énorme en tokens, mais c'est du **bruit de sélection** : le modèle doit choisir parmi 100 skills hors sujet.

### 3.2 Skills sociales réellement disponibles

| Skill | État | Remarque |
|---|---|---|
| `contenu-tiktok-instagram` | présent, version profil du 18/10 | version globale du 21/10 différente |
| `humanizer` | présent | utilisé 1 fois |
| `telegram-message-formatting` | présent | marqué `stale`, non utilisé depuis le 15/10 |
| `co-driver-bus-cc2so` | présent | contexte métier utile, pas un skill de contenu |
| `youtube-content` | présent | transcripts YouTube, dépend d'un script local |
| `whisper` | présent | **non installé** : ni `whisper`, ni `torch`, ni `transformers` |
| `rss-feeds` | présent | OK, stdlib |
| `searxng-search` | présent | **pas de `SEARXNG_URL`** configuré |
| `duckduckgo-search` | présent | **`ddgs` non installé** |
| `chrome-session-automation` | présent | dépend de l'autorisation JavaScript Apple Events |
| `live-dashboard` | présent | dashboard générique, **pas un calendrier de publication** |
| `xurl` | présent | X/Twitter uniquement, hors périmètre SOUL |

### 3.3 Problème principal : le skill social est dupliqué

- Copie globale : `~/.hermes/skills/social-media/contenu-tiktok-instagram/` (21/10, avec `references/outils-publication.md`).
- Copie profil : `~/.hermes/profiles/social/skills/social-media/contenu-tiktok-instagram/` (18/10, sans `outils-publication.md`).
- Le bot charge la copie **profil**. Preuve : le message de skill du cron contient « **Publier automatiquement** » (ancienne version) et pas « **Publication et outillage** » (version globale).
- Conséquence : les corrections faites dans le dossier global **n'arrivent jamais** dans le bot. La divergence est peut-être volontaire (le SOUL interdit la publication automatique), mais elle n'est documentée nulle part.

### 3.4 Contradictions SOUL / skill

| Sujet | SOUL | Skill |
|---|---|---|
| Longueur du hook | 12 mots max | 10 mots max |
| Publication | toujours manuelle, aucune API | la copie globale autorise les agrégateurs |
| A/B | 2 variantes | 2 variantes + « ce que chacune teste » |

Le bot a suivi la limite basse (hooks à 7 et 9 mots), mais il n'a pas donné le « ce que chaque hook teste ». Il faut une seule règle, écrite une fois.

### 3.5 Références cassées dans les skills actives

- `productivity/briefing-pdf` renvoie à `references/style-chatgpt.md` : **fichier absent**.
- `autonomous-ai-agents/hermes-cron-jobs` renvoie à `references/quota-and-rate-limits.md` : absent.
- `productivity/analyse-image-pdf` renvoie à `scripts/ocr_vision_jxa.js` : absent.

`briefing-pdf` est le plus gênant s'il est utilisé pour des livrables : la section de style manque.

## 4. Audit de la dernière livraison

Session : `local-1979d…`, source `cron`, 14/11 11 h 03, modèle `deepseek-v4-pro` (bascule après un 429 du provider principal).

**Ce qui marche**

- 7 idées, classées pédagogie / coulisses / preuve.
- Script plan par plan, texte incrusté + mot dit.
- Légende sans hashtag en première ligne, 4 hashtags précis.
- 3 puces de tournage, créneau proposé, une seule question finale.
- Bonne connaissance du contexte : chauffeur de bus en Picardie, public local.

**Ce qui ne respecte pas la consigne**

| Point | Consigne | Réel |
|---|---|---|
| Longueur | 40 lignes max | **48 lignes** |
| Chiffres | aucun chiffre inventé | « **20 ans** que je fais ça » (non sourcé) |
| Affirmations | à vérifier sinon | « **zéro concurrent** » (absolu non vérifié) |
| Planning | jamais pendant ses services | « mardi 17 h 45, fin de service » supposé |
| Hook A/B | dire ce que chacun teste | absent |
| Fichier | skill : nom + frontmatter | aucun fichier écrit |

Le dossier `~/Cerveau/06-Projets/contenu-social/DucSocialBot/` ne contient que **6 images** de profil. Le plan n'a pas été sauvegardé ; il n'existe que dans `state.db` et `cron/deliveries.db`.

## 5. Intégration du repo studio

Le repo `studio-video-9-16` est un studio **client-side** : `index.html` + `sequence-vers-mp4.sh`. Aucune référence dans le profil social, aucun skill, aucun outil. Le bot ne peut donc pas rendre de MP4 aujourd'hui.

Pourtant, l'environnement est prêt :

- ffmpeg bundlé : `~/.hermes/tools/ffmpeg-9.0.1-darwin-arm64/ffmpeg` (9.0.1).
- Node 26.12.1 et pnpm disponibles.
- Playwright 1.64 et Chromium 1208 présents dans Hermes.
- Le studio expose déjà `window.STUDIO.setScenes()`, `render()`, `exportFrames()`.

Il manque seulement le pont : un script CLI (Playwright + Chromium + ffmpeg) et un skill `studio-video-9-16` qui l'appelle. C'est faisable sans toucher à l'interface du studio.

## 6. Risques

| Risque | Gravité | Détail |
|---|---|---|
| Confusion de skills | élevée | 100 skills hors sujet, le modèle peut partir sur Hermes/Plex/finance |
| Divergence du skill social | élevée | corrections perdues, version du 18/10 |
| Perte des livrables | moyenne | rien dans le dossier de contenu |
| Chiffres inventés | moyenne | « 20 ans » dans un script publiable |
| Sécurité | moyenne | toolset Telegram complet : terminal, email, Home Assistant |
| Menu surchargé | faible | 60 commandes, dont admin/restart/finance |
| Modèle instable | moyenne | 429 du provider principal, bascule deepseek-v4-pro |
| Outils annoncés indisponibles | moyenne | Whisper, SearXNG, DDGS non installés/configurés |

## 7. Plan de correction proposé

### P0 — Recentrer et fiabiliser (1 session)

1. **Sauvegarder le profil** dans `~/.hermes/backups/` avant toute modification.
2. **Décider du périmètre** : bot 100 % social, ou assistant général ? Cette réponse conditionne tout le reste.
3. **Désactiver les skills hors sujet** via `skills.disabled` (réversible), en gardant environ 20 skills :
   `contenu-tiktok-instagram`, `humanizer`, `telegram-message-formatting`, `co-driver-bus-cc2so`,
   `youtube-content`, `rss-feeds`, `duckduckgo-search`, `chrome-session-automation`,
   `live-dashboard`, `briefing-pdf`, `second-cerveau-roudy`, `obsidian`, `gif-search`,
   `concept-diagrams`, `mono-color`, `baoyu-infographic`, `songwriting-and-ai-music`.
4. **Unifier le skill social** : une seule copie, avec une note explicite « publication manuelle » si c'est la règle. Supprimer la copie morte ou la remplacer par un lien documenté.
5. **Aligner le SOUL** : hook 10 mots, A/B + ce que chacun teste, plafond de 40 lignes / 3 500 caractères, zéro chiffre non sourcé, bloc « hypothèses ».
6. **Ajouter la persistance** : écrire chaque pièce dans `~/Cerveau/06-Projets/contenu-social/DucSocialBot/AAAA-MM-JJ-...md` avec le frontmatter du skill, et un fichier `calendrier.md`.

### P1 — Brancher le studio (1 à 2 sessions)

1. Ajouter au repo un `rendu-auto.mjs` : Playwright charge `index.html`, injecte les scènes, appelle `exportFrames()`, récupère le ZIP, lance ffmpeg.
2. Ajouter un skill `studio-video-9-16` au profil social : format d'entrée, commande, sortie MP4, contrôles durée/format.
3. Tester un film de 10 s (3 scènes), vérifier `ffprobe` : 1080×1920, H.264, 30 fps, durée exacte.
4. Le bot peut alors livrer : script + MP4 + légende, sans publication automatique.

### P2 — Sécurité et qualité (ensuite)

1. Restreindre `agent.disabled_toolsets` : `homeassistant`, `email`, `discord`, `slack`, `whatsapp`, `signal`, `computer_use`. Garder `terminal` pour ffmpeg, ou le remplacer par un outil dédié.
2. Réduire le menu Telegram à 12 commandes (`command_menu.max_commands: 12`).
3. Ajouter un contrôle de sortie avant envoi : nombre de lignes, caractères, chiffres non sourcés.
4. Corriger les références cassées (`briefing-pdf`, `hermes-cron-jobs`, `analyse-image-pdf`).
5. Mettre à jour la mémoire : modèle réel, état du cron, dernier livrable.
6. Tester 10 prompts types (niche, script, analyse concurrent, calendrier) et comparer.

## 8. Décisions à prendre

1. **Périmètre** : bot social spécialisé, ou assistant général ? (recommandé : spécialisé)
2. **Publication** : manuelle uniquement, ou agrégateur autorisé plus tard ?
3. **Vidéo** : le bot doit-il générer le MP4, ou seulement le script et les scènes ?
4. **Modification** : accord pour appliquer les P0 sur le profil, avec sauvegarde et liste exacte des skills désactivées ?
