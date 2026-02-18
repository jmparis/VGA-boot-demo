# =============================================================================
# Makefile pour le projet de secteur d'amorçage (Boot Sector)
# =============================================================================

# Cible par défaut : Compile boot.bin
all: boot.bin

# =============================================================================
# Règle de compilation : Assemble le fichier boot.asm en binaire brut
# =============================================================================
boot.bin: boot.asm
    # nasm : assembleur x86
    # -f bin : format de sortie binaire brut (pas d'exécutable ELF/PE)
    # boot.asm : fichier source en langage assembleur
    # -o boot.bin : fichier de sortie binaire
	nasm -f bin boot.asm -o boot.bin

# =============================================================================
# Règle d'exécution : Lance QEMU avec le binaire comme disque amorçable
# =============================================================================
run: boot.bin
    # qemu-system-i386 : Émulateur PC (processeur Intel 32 bits)
    # -drive : Configure un périphérique de stockage
    #   format=raw : format brut (pas de système de fichiers)
    #   file=boot.bin : fichier image du disque (512 octets = secteur amorçable)
    # Le BIOS démarrera sur ce secteur comme sur un vrai PC
	qemu-system-i386 -drive format=raw,file=boot.bin

# =============================================================================
# Règle de nettoyage : Supprime les fichiers générés
# =============================================================================
clean:
    # Supprime le fichier binaire boot.bin pour une recompilation propre
	rm -f boot.bin
