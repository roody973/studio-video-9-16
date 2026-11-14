# @DucSocialBot — dossier de contexte

Ce dossier rassemble le contexte visuel et les décisions du bot. Objectif : ne plus avoir à
réexpliquer le projet à chaque conversation. Ouvre-le, regarde les images, et le contexte est là.

## Dépôt GitHub

- **Dépôt de contexte** : https://github.com/roody973/DucsocialBot (privé)
- **Dépôt du studio** : https://github.com/roody973/studio-video-9-16 (public) — contient une copie de ce dossier.
- **Clone Hermes** : `~/.hermes/profiles/social/workspace/DucsocialBot`
- **SSH Hermes** : `git@github-ducsocial:roody973/DucsocialBot.git`
- **Clés** : `~/.ssh/ducsocial_github` et `~/.ssh/studio_github`, deploy keys écriture.

Le dépôt contient ce README, `images/`, `docs/` et `AGENTS.md`. Les secrets (mot de passe du
dashboard, tokens) ne sont jamais versionnés.

## Identité

- **Bot** : `@DucSocialBot`, profil Hermes `social`.
- **Métier de Roudy** : chauffeur de bus, CC2SO / Poix-de-Picardie.
- **But** : produire des posts TikTok, Facebook, YouTube et Instagram prêts à filmer, avec
  scripts, hooks, légendes, vidéos verticales et suivi.
- **Publication** : toujours manuelle. Le bot prépare, Roudy publie.
- **Niche** : pas encore fixée ; les pistes tournent autour du métier de chauffeur de bus,
  des coulisses et de la pédagogie du transport.

## Où est le bot

| Élément | Chemin |
|---|---|
| Profil Hermes | `~/.hermes/profiles/social/` |
| SOUL | `~/.hermes/profiles/social/SOUL.md` |
| Mémoire | `~/.hermes/profiles/social/memories/MEMORY.md` |
| Skills installées | `~/.hermes/profiles/social/skills/social-media/` |
| Dossier de contenu | `~/Cerveau/06-Projets/contenu-social/DucSocialBot/` |

Skills propres installées :

- `ducsocial-video` : script → voix off → sous-titres → MP4.
- `studio-video-9-16` : pilote le studio avec Playwright + ffmpeg.
- `ducsocial-soustitres` : sous-titres ASS en zone sûre.

Autres skills actives : `contenu-tiktok-instagram`, `humanizer`, `telegram-message-formatting`,
`co-driver-bus-cc2so`, `youtube-content`, `youtube-channel-veille`, `rss-feeds`,
`duckduckgo-search`, `competitor-news-monitor`, `chrome-session-automation`, `live-dashboard`,
`briefing-pdf`, `gif-search`, `concept-diagrams`, `mono-color`, `baoyu-infographic`,
`songwriting-and-ai-music`, `mkv-pistes-sous-titres`, `weekly-review-planning`,
`grounded-citations`, `github`, `hermes-cron-jobs`, `hermes-agent`.

## Dashboard

- **Hébergement** : Umbrel uniquement, service systemd utilisateur, pas de pCloud.
- **Tailscale** : http://100.93.66.10:8788
- **LAN** : http://umbrel.local:8788
- **Mot de passe** : dans `~/ducsocial-dashboard/.env` sur Umbrel (demandé à l’installation).
- **Code** : `~/ducsocial-dashboard/app.py` + `static/`.
- **Données** : `~/ducsocial-dashboard/data/dashboard.db`.

Le dashboard contient : vue d’ensemble, post-production en 5 colonnes, calendrier, espaces
TikTok / Facebook / YouTube / Instagram, veille, export JSON. Les métriques et tendances sont
encore des données de démonstration.

## Décisions prises

- **Umbrel seulement** comme hébergeur ; pCloud n’est pas utilisé pour l’instant.
- **4 plateformes** : TikTok, Facebook, YouTube, Instagram.
- **Accès** : Tailscale + mot de passe.
- **Post-production éditable** depuis le navigateur.
- **Aucune publication automatique**.
- **Pas de cron** pour l’instant ; le scheduler reste à construire.
- **Rendu sur le Mac** (voix `say`, Chromium/Playwright, ffmpeg), pas sur Umbrel.

## Architecture

| Machine | Rôle |
|---|---|
| **Mac** | bot Hermes, rendu vidéo, publication manuelle |
| **Umbrel** | dashboard, SQLite, service web, accès Tailscale |
| **pCloud** | non utilisé pour l’instant |

## Images

### Captures de la conversation

- `images/screenshots/2026-11-14-12-59-dashboard-agence.png` — dashboard d’agence servant de
  référence visuelle (Schedules, Automations, Ads, YouTube, Instagram).
- `images/screenshots/2026-11-14-16-20-liste-skills.png` — liste des skills génériques
  (contenu, veille, visuels, publication) ; sert à distinguer « installé » de « propre au bot ».
- `images/screenshots/2026-11-14-16-30-trois-niveaux.png` — plan en trois niveaux : fiabiliser
  le studio, en faire le moteur du bot, qualité éditoriale.
- `images/screenshots/2026-11-14-16-57-sidebar-socials.png` — sidebar YouTube / Instagram /
  TikTok qui a servi de base aux espaces plateformes.

### Photos de profil

`images/photo-profil/` : trois propositions (`signal-robot`, `studio-ds`, `pulse-social`) en
PNG et SVG.

### Dashboard

- `images/dashboard/maquette-vue-ensemble.png` — maquette de la vue d’ensemble.
- `images/dashboard/maquette-postprod.png` — maquette du board de post-production.
- `images/dashboard/deploye-vue-ensemble.png` — capture du dashboard réel sur Umbrel.
- `images/dashboard/deploye-postprod.png` — capture du board réel sur Umbrel.

### Vidéo

- `images/video/frame-demo-bot.png` — frame du MP4 de démonstration généré par le bot
  (6,2 s, 1080×1920, voix et sous-titres).

## Documents

- `docs/audit-bot.md` — audit du profil, des skills et de la dernière livraison.
- `docs/proposition-dashboard.md` — proposition complète : dashboard, skills, scheduler,
  métriques, veille, hébergement.
- `docs/deploiement-dashboard.md` — accès, service systemd, sauvegarde, mise à jour.
- `docs/skills-ducsocial.md` — README des trois skills vidéo.

## Prochaines étapes

1. Remplacer les données de démonstration par les vrais posts des deux dernières semaines.
2. Importer les métriques (CSV TikTok/YouTube/Facebook/Instagram) et calculer rétention 3 s,
   complétion, partages, abonnés.
3. Ajouter le scheduler : plan du dimanche, alerte assets, bilan.
4. Brancher `ducsocial-video` sur les cartes « À produire ».
5. Construire l’espion multi-plateformes.

## Règle pour les prochaines conversations

Quand Roudy parle de `@DucSocialBot`, lire ce README et regarder `images/` avant de proposer
quoi que ce soit. Ne pas redemander le contexte déjà écrit ici. Ne pas inventer de chiffres :
les données du dashboard sont des exemples tant que l’import n’est pas branché.
