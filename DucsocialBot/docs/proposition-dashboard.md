# Proposition — tableau de bord et pilotage de @DucSocialBot

État : proposition, rien n'est encore codé. La maquette `mockup.html` / `mockup.png` montre
la cible visuelle ; les chiffres sont fictifs.

## 1. Le besoin, reformulé

Un seul écran doit répondre à quatre questions :

1. **Qu'est-ce que je publie cette semaine ?** (calendrier, statut, fichier prêt)
2. **Qu'est-ce que ça a produit ?** (vues, réactions, rétention 3 s, complétion, abonnés)
3. **Qu'est-ce qui marche ailleurs ?** (veille, tendances, formats, hooks)
4. **Est-ce que la machine tourne ?** (rendus, erreurs, fichiers manquants)

Le tableau de bord de la capture (Schedules, Automations, Ads, YouTube, Instagram) est une
console d'agence. Pour @DucSocialBot, il faut la même lisibilité, mais **une seule colonne
vertébrale** : le contenu. Pas besoin de Ads, DM automation ou multi-clients au départ.

## 2. Ce que les skills actuelles savent déjà faire

| Besoin | Skill existante | Verdict |
|---|---|---|
| Écrire un script, un hook, une légende | `contenu-tiktok-instagram` | bon, à garder |
| Produire le MP4 avec voix et sous-titres | `ducsocial-video` + `studio-video-9-16` | opérationnel |
| Veille YouTube (nouvelles vidéos + transcription) | `youtube-channel-veille` | bon pour YouTube |
| Veille news / concurrents | `competitor-news-monitor` | pour les entreprises, pas les formats viraux |
| Dashboard générique | `live-dashboard` | bonne base, pas encore de données sociales |
| Lire un compte connecté | `chrome-session-automation` | possible, fragile |
| X / Twitter | `xurl` | hors périmètre actuel |
| Recherche web | `web`, `rss-feeds` | OK |

**L'espion que tu crois avoir** : c'est `youtube-channel-veille` (YouTube) et
`competitor-news-monitor` (news). Il n'y a **aucun espion TikTok/Instagram** dédié. C'est
précisément le trou à combler.

## 3. La maquette

`mockup.png` montre :

- **5 KPI** : posts de la semaine, vues 7 jours, rétention 3 s, complétion, abonnés gagnés.
- **Calendrier** : 3 posts, statuts `publié`, `à tourner`, `script prêt`.
- **Ce qui marche** : classement des hooks par rétention et complétion.
- **Espion** : 3 formats repérés, avec source, âge et score.
- **Derniers posts** : vues, likes, partages, abonnés, statut.
- **Pipeline** : rendus, voix, sous-titres, fichier manquant.
- **Idées en réserve** : la banque de sujets.

## 4. Architecture proposée

### Option recommandée — Hermes `live-dashboard`

- Un dossier `~/.hermes/dashboards/ducsocial/` avec `dashboard.json` et `index.html`.
- Le JSON contient les posts, métriques, tendances, jobs, alertes et la date de chaque source.
- Un cron de refresh reconstruit `index.html` depuis le JSON ; aucun serveur à maintenir.
- Avantage : zéro service, zéro dépendance, marche sur le Mac et dans Hermes.
- Limite : lecture seule ; pour modifier un post, on passe par le bot ou un fichier.

### Option plus riche — petit serveur local

- SQLite `content.db` + FastAPI/Node + page HTML.
- Permet d'ajouter un post, changer un statut, saisir des métriques depuis le navigateur.
- Coût : un service à lancer, à sauvegarder et à surveiller. À faire seulement si tu veux
  éditer depuis le tableau de bord.

**Recommandation** : commencer par `live-dashboard` ; passer au serveur seulement si tu
cliques souvent dans l'interface.

### Données

SQLite (ou JSON au début) avec cinq tables :

```text
posts(id, date, platform, format, pilier, hook, fichier, statut, published_at, url)
metrics(post_id, captured_at, vues, likes, commentaires, partages, saves,
        abonnes_gagnes, retention_3s, completion, watch_moyen)
trends(id, source, compte, url, format, hook, vues, engagement, age, score, notes)
jobs(id, type, statut, debut, fin, erreur, sortie)
ideas(id, texte, pilier, source, statut)
```

`posts` est la vérité ; `metrics` est un historique (on garde chaque relevé) ; `trends` est
la mémoire de la veille ; `jobs` alimente le panneau pipeline.

## 5. Les skills à créer

### `ducsocial-dashboard`

- Lit la base et génère `dashboard.json` + `index.html`.
- Recalcule les KPI, le classement « ce qui marche » et les alertes.
- Ne publie rien, ne modifie pas les posts.
- Réutilise `live-dashboard` pour la structure HTML.

### `ducsocial-calendrier`

- Maintient le calendrier : 3 posts par semaine, un pilier par post.
- Statuts : `idée → script → à tourner → rendu → publié`.
- Vérifie qu'un MP4 existe avant de marquer « prêt ».
- Écrit aussi `calendrier.md` dans le dossier de contenu pour la lecture humaine.

### `ducsocial-metriques`

- Phase 1 : importe un CSV ou un collage depuis TikTok/Instagram/YouTube Studio.
- Calcule rétention 3 s, complétion, watch moyen, partages et abonnés par 1 000 vues.
- Phase 2 : API YouTube Analytics, puis Instagram Graph, puis TikTok Display.
- Ne mélange jamais les plateformes dans un même classement.

### `ducsocial-veille` — l'espion

- YouTube : réutilise `youtube-channel-veille`.
- TikTok : Creative Center + pages publiques via navigateur connecté.
- Instagram : Explore/Reels via `chrome-session-automation` ; données publiques seulement.
- Google Trends, X via `xurl`, RSS/newsletters.
- Sort **3 opportunités par semaine**, chacune avec : format, hook observé, source, date,
  vues, âge, saturation, « pourquoi maintenant », 2 hooks adaptés à Roudy.
- Score : `demande × facilité de tournage × fraîcheur ÷ saturation`.
- Interdits : recopier un contenu, inventer un chiffre, scraper en masse, ignorer les droits.

### `ducsocial-bilan`

- Chaque dimanche : classe les hooks et formats, dit **arrêter / garder / amplifier**.
- Une seule recommandation par semaine, pas un rapport de 40 lignes.
- Met à jour la banque d'idées et le prochain calendrier.

## 6. Le scheduler

Préparation uniquement, publication toujours manuelle.

| Quand | Job | Sortie |
|---|---|---|
| dimanche 18:00 | plan de la semaine | 3 posts + hooks + créneaux |
| lundi/mercredi/vendredi 07:00 | vérifier les assets | alerte si MP4 manquant |
| tous les jours 20:00 | relevé des métriques | dashboard à jour |
| dimanche 19:00 | bilan de la semaine | 1 décision : arrêter/garder/amplifier |
| lundi et jeudi 09:00 | veille | 3 opportunités maximum |

Règle : un job qui n'a rien de neuf répond `[SILENT]` ; pas de message vide.

## 7. Ce qui compte vraiment

Le classement ne doit pas être « les likes ». Ordre proposé :

1. **Rétention à 3 s** — le hook retient-il ?
2. **Complétion** — la promesse tient-elle jusqu'au bout ?
3. **Partages + saves** par 1 000 vues — le contenu est-il utile ?
4. **Abonnés gagnés** par 1 000 vues — le profil donne-t-il envie de rester ?
5. Likes et commentaires — signaux secondaires.

Un post avec 3 000 vues, 60 % de rétention et 20 abonnés vaut mieux qu'un post à 30 000 vues
qui n'en ramène aucun. Le dashboard doit rendre ça visible, pas noyer dans les vues.

## 8. Les limites à dire franchement

- **TikTok/Instagram ne donnent pas d'API publique de tendances.** Les chiffres publics se
  lisent via le navigateur, changent vite et peuvent être bloqués. Toute veille de ce type
  est indicative, pas une mesure.
- **Les métriques de concurrents ne sont pas auditables.** Vues publiques ≠ vues réelles
  après suppression ; ne jamais les mettre dans le même tableau que tes propres analytics.
- **Un CSV manuel est plus fiable qu'un scraper fragile** au début. On automatise seulement
  ce qui est stable.
- **Trois posts par semaine suffisent pour apprendre.** Le dashboard ne sert à rien si le
  volume s'arrête.
- **La publication reste manuelle** : le bot prépare, tu publies. Aucun API de publication
  automatique dans cette version.

## 9. Découpage proposé

**Phase 0 — la maquette (faite)** : valider les panneaux et les KPI.

**Phase 1 — dashboard lecture seule (1 session)** :
- base SQLite + 3 posts de démonstration ;
- génération `dashboard.json` + `index.html` ;
- pas de cron, rafraîchissement manuel.

**Phase 2 — calendrier + métriques (1 à 2 sessions)** :
- `ducsocial-calendrier`, `ducsocial-metriques` ;
- import CSV, calculs de rétention, classement ;
- cron de préparation + alerte assets.

**Phase 3 — espion (1 à 2 sessions)** :
- `ducsocial-veille` avec YouTube d'abord, puis TikTok/IG via navigateur ;
- 3 opportunités par semaine, sources datées.

**Phase 4 — API et automatisation (plus tard)** :
- YouTube Analytics, Instagram Graph, TikTok Display ;
- expériences A/B de hooks ;
- pas de publication automatique avant que la niche et le rythme soient stables.

## 10. Décisions à prendre

1. **Support** : dashboard Hermes `live-dashboard` (léger) ou petit serveur local (éditable) ?
2. **Plateformes prioritaires** : TikTok + Instagram + YouTube, ou une seule d'abord ?
3. **Métriques** : qui saisit les chiffres au début — toi via CSV, ou le bot via API ?
4. **Cron** : accepte-t-on les jobs de préparation (pas de publication) malgré la décision
   « aucun cron » du 14/11 ?
5. **Veille** : jusqu'où va-t-on sur TikTok/Instagram, sachant que les données publiques
   sont fragiles ?

## 11. Hébergement : pCloud ou Umbrel ?

### pCloud

pCloud est un **stockage**, pas un serveur d'application :

- pas de Docker, pas de cron, pas de base de données, pas d'API côté pCloud ;
- un dossier public peut partager des fichiers, mais pas faire tourner un tableau de bord
  dynamique avec authentification ;
- en revanche, c'est excellent pour **archiver les MP4, les vignettes, les sauvegardes SQLite
  et un portfolio public**.

Verdict : **pCloud = archive et sauvegarde**, pas l'hébergement du dashboard.

### Umbrel

Le nœud est déjà prêt pour héberger l'application :

- Docker 28.5 disponible, accès SSH par clé, Tailscale actif ;
- 24 Go de RAM, disque système 1,8 To mais **87 % plein (247 Go libres)** ;
- accès local `http://umbrel.local`, distant `http://100.93.66.10` via Tailscale ;
- toujours allumé, contrairement au Mac.

Verdict : **Umbrel = hébergement du dashboard, de la base et du scheduler**.

### La répartition recommandée

| Machine | Rôle |
|---|---|
| **Mac** | bot Hermes, rendu vidéo (`say`, Playwright, ffmpeg), publication manuelle |
| **Umbrel** | dashboard, SQLite, scheduler, file d’attente, archives locales |
| **pCloud** | archive des MP4, sauvegardes, portfolio public |

Le Mac envoie chaque rendu et chaque métrique à l’API du dashboard sur Umbrel. Si le Mac
dort, les jobs restent en attente ; Umbrel ne dépend pas de la session utilisateur du Mac.

### Pourquoi ne pas déplacer le rendu sur Umbrel tout de suite

Le pipeline actuel utilise la voix macOS `say` et Chromium/Playwright installés sur le Mac.
Sur Umbrel (Linux), il faudrait :

- un Chromium headless en Docker ;
- ffmpeg (ok) ;
- un TTS différent (Piper, Coqui, ou une API), car `say` n’existe pas ;
- plus de RAM/CPU pendant les rendus.

C’est faisable en Phase 4, mais cela change la voix et ajoute du maintenance. Pour l’instant,
le Mac reste le worker de rendu ; Umbrel pilote et affiche.

### Sécurité

- Dashboard lié à `127.0.0.1` ou au réseau Tailscale uniquement ;
- mot de passe unique + cookie de session, ou reverse proxy Caddy avec Basic Auth ;
- aucun token de plateforme dans le frontend ;
- sauvegarde SQLite quotidienne vers pCloud, conservation 30 jours ;
- pas d’exposition publique tant que les analytics personnelles y sont.

## 12. Post-production : le board

C’est le cœur de la demande. Un seul board, cinq colonnes :

1. **Idées** — la banque de sujets, avec source (veille, quotidien, commentaire).
2. **À produire** — script validé, plateforme et deadline.
3. **En production** — voix, rendu, sous-titres, vignette.
4. **Prêt à publier** — MP4 + légende + hashtags + créneau.
5. **Publié** — lien, métriques, statut.

Chaque carte contient :

- titre et angle ;
- hook A / hook B ;
- pilier (pédagogie, coulisses, preuve) ;
- plateformes visées (TikTok, Facebook, YouTube) ;
- durée et format ;
- date de publication prévue ;
- checklist : script, voix, sous-titres, MP4, vignette, légende ;
- lien vers le fichier et vers le post publié ;
- métriques une fois publié.

Une idée peut avoir **plusieurs variantes** : un même MP4 pour TikTok et Facebook, mais un
hook et une légende différents. Le board doit le montrer sans dupliquer la carte.

Actions utiles :

- « Générer le script » ;
- « Générer le MP4 » (appelle `ducsocial-video`) ;
- « Marquer prêt » (refuse si le MP4 manque) ;
- « Ouvrir le dossier » ;
- « Copier la légende » ;
- « Marquer publié » (manuel, avec URL).

## 13. Les espaces plateformes

Chaque espace reprend la même structure, avec ses spécificités.

### TikTok

- Calendrier, posts publiés, top formats, tendances.
- 9:16, 15–45 s, sous-titres obligatoires, sons de la bibliothèque commerciale.
- API Display pour tes propres vidéos ; Creative Center pour les tendances.
- Pas d’API publique de tendances : les chiffres publics sont indicatifs.

### Facebook

- Reels 9:16 et posts de Page.
- Graph API pour les insights de ta Page ; moins de données de tendances que TikTok.
- Réutiliser le MP4 TikTok avec un hook et une légende adaptés.
- Attention : Facebook est une Page, pas un profil personnel.

### YouTube

- Shorts et vidéos longues.
- Data API + Analytics API pour les vues, la rétention et les abonnés.
- `youtube-channel-veille` déjà disponible pour l’espion YouTube.
- Les Shorts et les longues ne se comparent pas : deux tableaux séparés.

### Instagram (optionnel, déjà dans la sidebar)

- Reels et carrousels.
- Graph API avec compte professionnel.
- À ajouter seulement si tu y publies vraiment ; sinon, le laisser hors du dashboard.

## 14. Ce que je recommande

1. **Héberger sur Umbrel** en Docker ; garder le rendu sur le Mac.
2. **pCloud en archive** : MP4 finaux, sauvegardes, portfolio.
3. **Post-prod d’abord** : c’est ce qui manque le plus, avant les métriques fines.
4. **Un espace par plateforme** : TikTok, Facebook, YouTube ; Instagram seulement si utile.
5. **Métriques manuelles au début** (CSV), APIs ensuite.
6. **Pas de publication automatique** : le board prépare, Roudy publie.
