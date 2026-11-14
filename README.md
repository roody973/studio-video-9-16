# Studio Vidéo 9:16

Une seule page web pour transformer une liste de scènes en fichier vidéo vertical,
sans logiciel de montage ni enregistreur d'écran.

Ouvre `index.html` dans Chrome (double-clic suffit) et c'est prêt : aucune installation,
aucune clé API, aucune dépendance externe, tout tient dans le fichier.

## Écrire les scènes

Une scène par ligne, séparée par des barres verticales :

```
Titre de la scène | Sous-titre | secondes
```

Exemple :

```
Trois idées de vidéos courtes | en 9:16, sans montage | 3
Une scène = un titre | un sous-titre court | 3
Le rendu sort en fichier | WebM ou MP4, prêt à publier | 3
```

Les lignes vides et celles commençant par `#` sont ignorées.
Le titre se coupe tout seul en plusieurs lignes, la police diminue si le texte est long.

## Deux façons d'exporter

**1. « Générer la vidéo » — rapide, direct en MP4**
Le navigateur enregistre le canvas et sort un MP4 H.264 1080×1920 (ou WebM si le
navigateur refuse le MP4). Le rendu se fait en temps réel : un film de 20 s prend 20 s.
Garde la fenêtre visible pendant le rendu — Chrome bride les onglets en arrière-plan,
et le fichier sortirait trop long. L'app mesure la durée réelle du fichier obtenu et
t'avertit si elle s'écarte de plus de 25 % de la durée voulue.

**2. « Séquence images exacte (ZIP) » — lente à convertir, mais cadence garantie**
Le studio calcule chaque image hors du temps réel et sort un ZIP de JPEG à la cadence
choisie (30 ou 60 im/s). Décompresse-le et lance :

```bash
./sequence-vers-mp4.sh sequence-30fps-90img.zip 30
```

Le script produit un MP4 H.264 avec la durée exacte, image par image, insensible aux
ralentissements de la machine. Compte environ 80 Ko par image (≈ 2,4 Mo par seconde de film).

## Réglages

- **Palette** : Nuit, Ardoise, Encre, Sable.
- **Images par seconde** : 30 (standard réseaux sociaux) ou 60.
- **Titre permanent** : petit texte en haut, facultatif.

## Ce qui est vérifié

- MP4 produit par le chemin direct : `h264 (avc1)`, `1080x1920`, `DAR 9:16`, lisible par ffmpeg.
- Chaîne séquence → MP4 : 60 JPEG à 30 im/s donnent `00:00:02.00`, `30 fps`, `h264 (High)`.
- Ouverture par double-clic (`file://`) : export fonctionnel, aucun script tiers chargé.
- Rendu du texte contrôlé au pixel : dégradé et texte corrects sur toute la hauteur.

## Limites connues

- Pas d'audio : le film sort muet (voix off et musique à ajouter avec ffmpeg).
- Une seule mise en page de scène (titre, filet, sous-titre) ; pas encore de variantes.
- Le chemin direct dépend des timers du navigateur ; en cas de doute, la séquence exacte.

## Origine

Réécriture indépendante de l'idée du dépôt `LaurentVoanhcool/svg-chat`, qui n'a **aucune
licence** : son code ne peut pas être réutilisé ni republié. Ce fichier a été écrit de zéro,
sans en reprendre le code.
