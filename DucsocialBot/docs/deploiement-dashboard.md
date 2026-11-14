# Déploiement du dashboard @DucSocialBot

## Accès

- **Tailscale** : http://100.93.66.10:8788
- **Réseau local** : http://umbrel.local:8788
- **Mot de passe** : défini dans `~/ducsocial-dashboard/.env` sur Umbrel (demandé à l’installation).

L’accès est protégé par le mot de passe, que l’on soit en Tailscale ou en local.

## Ce qui tourne

Service systemd **utilisateur** sur le nœud Umbrel :

```bash
ssh umbrel@umbrel.local
systemctl --user status ducsocial-dashboard.service
journalctl --user -u ducsocial-dashboard.service -f
```

Le service est `enabled` et le linger est activé : il redémarre tout seul après un reboot
du nœud, sans session SSH ouverte.

Docker n’a pas été utilisé : l’utilisateur `umbrel` n’a pas accès à `/var/run/docker.sock`
(le socket est `root:docker`). Le service Python systemd est plus léger et suffit. Si tu veux
passer à Docker plus tard, il faudra ajouter `umbrel` au groupe `docker` avec `sudo`.

## Données

- Base SQLite : `/home/umbrel/ducsocial-dashboard/data/dashboard.db`
- Code : `/home/umbrel/ducsocial-dashboard/app.py`
- Interface : `/home/umbrel/ducsocial-dashboard/static/`
- Secrets : `/home/umbrel/ducsocial-dashboard/.env` (600)

Sauvegarde manuelle :

```bash
ssh umbrel@umbrel.local 'cp ~/ducsocial-dashboard/data/dashboard.db ~/ducsocial-dashboard/data/dashboard.db.bak-$(date +%F)'
```

## Modifier le mot de passe

```bash
ssh umbrel@umbrel.local
nano ~/ducsocial-dashboard/.env     # DASHBOARD_PASSWORD=...
systemctl --user restart ducsocial-dashboard.service
```

## Mettre à jour le code

Depuis le Mac, dans `ducsocial-dashboard/app/` :

```bash
scp app.py umbrel@umbrel.local:~/ducsocial-dashboard/
scp static/* umbrel@umbrel.local:~/ducsocial-dashboard/static/
ssh umbrel@umbrel.local 'systemctl --user restart ducsocial-dashboard.service'
```

## Ce qui est inclus

- Vue d’ensemble : KPI, calendrier, ce qui marche, pipeline, derniers posts.
- Post-production : 5 colonnes, cartes éditables, statuts, plateformes.
- 4 espaces : TikTok, Facebook, YouTube, Instagram.
- Veille : tendances de démonstration, prêtes à être alimentées.
- Export JSON de toutes les données.
- Auth par mot de passe, cookie HttpOnly, CSP, accès Tailscale.

## Limites de cette phase

- Les métriques sont des **données de démonstration** ; aucun import CSV/API n’est branché.
- Les tendances sont des exemples, pas une veille live.
- Pas encore de scheduler ni de génération MP4 depuis le board.
- pCloud n’est pas utilisé : tout est sur Umbrel, comme demandé.
