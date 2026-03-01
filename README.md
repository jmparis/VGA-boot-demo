# Projet Boot Sector VGA - Drapeau Français

Ce projet est un **boot sector x86 (16 bits)** qui s'exécute au démarrage de l'ordinateur. Il affiche le drapeau français en utilisant le mode graphique VGA 13h.

## Description du programme

### Fonctionnement général

Le programme [`src/boot.asm`](src/boot.asm) est un secteur d'amorçage (boot sector) de 512 octets qui :

1. **Passe en mode VGA 13h** - Utilise l'interruption BIOS `0x10` avec `AH=0x00` et `AL=0x13` pour activer le mode graphique 320×200 pixels avec 256 couleurs.

2. **Configure le segment vidéo** - Positionne le registre `ES` à `0xA000` (segment de mémoire vidéo VGA) pour pouvoir écrire directement dans le framebuffer.

3. **Dessine le drapeau français** - Parcourt chaque pixel de l'écran (320×200 = 64 000 pixels) et détermine sa couleur selon la position horizontale :
   - **Bande bleue** (gauche) : pixels x = 0 à 106 → couleur VGA #1 (bleu pur)
   - **Bande blanche** (milieu) : pixels x = 107 à 213 → couleur VGA #15 (blanc brillant)
   - **Bande rouge** (droite) : pixels x = 214 à 319 → couleur VGA #4 (rouge pur)

4. **Boucle infinie** - Une fois le drapeau affiché, le processus entre dans une boucle `HLT` en attendant une interruption.

### Spécifications techniques

| Caractéristique | Valeur |
|-----------------|--------|
| Mode VGA | 13h (320×200×256) |
| Taille du secteur | 512 octets |
| Adresse de chargement | 0x7C00 |
| Signature de boot | 0xAA55 |
| Langage | Assembleur x86 16 bits (NASM) |

## Prérequis

### Option 1 : Avec Docker (Recommandé)

Le projet utilise un conteneur Docker avec tous les outils nécessaires :

- **NASM** - Assembleur x86
- **QEMU** - Émulateur PC pour tester le boot sector

Le conteneur est configuré automatiquement via [`.devcontainer`](.devcontainer/devcontainer.json).

### Option 2 : Installation locale (Windows)

Si vous souhaitez installer les outils localement :

1. **NASM** - Téléchargez depuis https://www.nasm.us/
2. **QEMU** - Téléchargez QEMU pour Windows depuis https://www.qemu.org/download/#windows

## Compilation

### Via le conteneur Docker

1. Ouvrez le projet dans VSCode
2. VSCode détectera automatiquement le fichier `.devcontainer/devcontainer.json`
3. Cliquez sur "Reopen in Container" quand VSCode le suggère
4. Attendez que le conteneur soit construit et démarré

### Commandes de compilation

Dans le dossier `src/`, exécutez :

```bash
# Compiler le boot sector
make all
```

Cette commande exécute :
```bash
nasm -f bin boot.asm -o boot.bin
```

Cela produit le fichier `boot.bin` (512 octets) contenant le secteur d'amorçage.

## Exécution et test

### Lancer avec QEMU

Dans le dossier `src/`, exécutez :

```bash
make run
```

Cette commande exécute :
```bash
qemu-system-i386 -drive format=raw,file=boot.bin
```

QEMU émulera un PC classique et démarrera sur le secteur d'amorçage. Vous devriez voir le drapeau français s'afficher à l'écran.

### Via VSCode

Le projet est configuré avec une extension Makefile Tools. Vous pouvez :

1. Ouvrir le dossier `src/` dans VSCode
2. Utiliser les tâches Makefile (Ctrl+Shift+P → "Tasks: Run Task")
3. Sélectionner "build" pour compiler
4. Sélectionner "run" pour exécuter dans QEMU

## Nettoyage

Pour supprimer les fichiers générés :

```bash
make clean
```

Cela supprime le fichier `boot.bin`.

## Structure du projet

```
VGA-boot/
├── .devcontainer/
│   ├── devcontainer.json    # Configuration VSCode Dev Containers
│   └── Dockerfile          # Image Docker avec NASM et QEMU
├── src/
│   ├── boot.asm             # Code source du boot sector
│   └── Makefile             # Script de compilation
├── .gitignore
└── VGA-boot.code-workspace # Workspace VSCode
```

## Fonctionnement détaillé du code

Le code assembleur suit ces étapes :

1. **[org 0x7C00](src/boot.asm:31)** - Définit l'adresse d'origine du programme (adresse où le BIOS charge le boot sector)

2. **[mov ax, 0x0013](src/boot.asm:52)** + **[int 0x10](src/boot.asm:56)** - Passage en mode VGA 13h

3. **[mov es, ax](src/boot.asm:81)** - Configuration du segment vidéo ES = 0xA000

4. **Boucles principales** - Deux boucles imbriquées parcourent :
   - La boucle externe : chaque ligne Y (0 à 199)
   - La boucle interne : chaque pixel X (0 à 319)

5. **[stosb](src/boot.asm:206)** - Écrit le pixel dans la mémoire vidéo

6. **[times 510-($-$$) db 0](src/boot.asm:284)** + **[dw 0xAA55](src/boot.asm:289)** - Remplissage et signature de boot

## Dépannage

### QEMU ne démarre pas

- Vérifiez que `boot.bin` existe dans le dossier `src/`
- Assurez-vous que QEMU est correctement installé

### L'écran reste noir

- Vérifiez que le fichier fait exactement 512 octets
- Assurez-vous que la signature `0xAA55` est présente à la fin

### Erreur NASM

- Vérifiez que NASM est installé et accessible depuis le PATH
- Tapez `nasm --version` pour vérifier l'installation
