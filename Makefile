# =============================================================================
# Makefile pour le projet de secteur d'amorcage (Boot Sector)
# =============================================================================

SRC_DIR   := src
BOOT_SRC  := $(SRC_DIR)/boot.asm
BUILD_DIR := build
BOOT_BIN  := $(BUILD_DIR)/boot.bin

NASM ?= nasm
QEMU ?= qemu-system-i386

.PHONY: all run clean

# Cible par defaut : compile boot.bin
all: $(BOOT_BIN)


# =============================================================================
# Règle de compilation : assemble le fichier boot.asm en binaire brut
# =============================================================================
$(BOOT_BIN): $(BOOT_SRC)
	$(NASM) -f bin $(BOOT_SRC) -o $(BOOT_BIN)

# =============================================================================
# Règle d'execution : lance QEMU avec le binaire comme disque amorcable
# =============================================================================
run: $(BOOT_BIN)
	$(QEMU) -drive format=raw,file=$(BOOT_BIN)

# =============================================================================
# Règle de nettoyage : supprime les fichiers générés
# =============================================================================
clean:
	rm -f $(BOOT_BIN)
