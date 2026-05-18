#!/bin/sh

set -u

NASM=${NASM:-nasm}
QEMU=${QEMU:-qemu-system-i386}
MODE=${1:-all}

if [ "${NO_COLOR:-}" = "" ]; then
	RED    =$(printf '\033[31m')
	GREEN  =$(printf '\033[32m')
	YELLOW =$(printf '\033[33m')
	RESET  =$(printf '\033[0m')
else
	RED=
	GREEN=
	YELLOW=
	RESET=
fi

missing=0

error() {
	printf '%b\n' "${RED}$1${RESET}"
}

ok() {
	printf '%b\n' "${GREEN}$1${RESET}"
}

warning() {
	printf '%b\n' "${YELLOW}$1${RESET}"
}

check_nasm() {
	if command -v "$NASM" >/dev/null 2>&1; then
		ok "OK: NASM est installé ($("$NASM" -v))."
		return 0
	fi

	error "Erreur: NASM est introuvable."
	warning "Installez-le avec l'une de ces commandes:"
	warning "  Fedora : sudo dnf install nasm"
	warning "  CachyOS: sudo pacman -S nasm"
	warning "  Windows: winget install NASM.NASM"
	warning "Vérifiez aussi que nasm est disponible dans le PATH."
	missing=1
	return 1
}

check_qemu() {
	if command -v "$QEMU" >/dev/null 2>&1; then
		ok "OK: QEMU est installé."
		"$QEMU" --version
		return 0
	fi

	error "Erreur: QEMU est introuvable."
	warning "Installez-le avec l'une de ces commandes:"
	warning "  Fedora : sudo dnf install qemu-system-x86"
	warning "  CachyOS: sudo pacman -S qemu-system-x86"
	warning "  Windows: winget install SoftwareFreedomConservancy.QEMU"
	warning "Vérifiez aussi que qemu-system-i386 est disponible dans le PATH."
	missing=1
	return 1
}

case "$MODE" in
	all)
		check_nasm || true
		check_qemu || true
		if [ "$missing" -ne 0 ]; then
			exit 1
		fi
		ok "OK: Tous les outils requis sont disponibles."
		;;
	nasm)
		check_nasm
		;;
	qemu)
		check_qemu
		;;
	*)
		error "Erreur: mode inconnu '$MODE'."
		warning "Utilisation: $0 [all|nasm|qemu]"
		exit 2
		;;
esac
