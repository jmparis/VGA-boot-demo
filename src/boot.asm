org 0x7c00
; Adresse de chargement du secteur d'amorçage en mémoire

start:
; ---------------------------------------------------------
; Configuration du mode vidéo 0x13 (320x200, 256 couleurs)
; ---------------------------------------------------------
mov ah, 0x00       ; AH = 0x00 -> fonction "Set Video Mode"
mov al, 0x13       ; AL = 0x13 -> mode vidéo 13h (VGA 320x200 256 couleurs)
int 0x10           ; Interrupt 0x10 -> services vidéo du BIOS

; ---------------------------------------------------------
; Configuration du segment de données vers la mémoire vidéo
; ---------------------------------------------------------
mov bx, 0xA000     ; BX = 0xA000 -> segment de départ de la mémoire vidéo VGA
mov ds, bx         ; DS = segment des données (video RAM à 0xA0000)

; ---------------------------------------------------------
; Dessin de 10000 pixels verts (première bande)
; ---------------------------------------------------------
mov cx, 10000      ; CX = compteur de boucle (10 000 itérations)
green:             ; Étiquette de début de la boucle
mov bx, cx         ; BX = CX (position actuelle dans la bande)
mov byte [bx], 0x30; Écrire le code couleur 0x30 (vert) à l'offset BX
loop green         ; Décrémenter CX et retourner à "green" si CX != 0

; ---------------------------------------------------------
; Dessin de 10000 pixels bleus (deuxième bande)
; ---------------------------------------------------------
mov cx, 10000      ; CX = 10 000 (nouvelle boucle)
blue:              ; Étiquette de début de la boucle
mov bx, cx         ; BX = CX
mov byte [10000 + bx], 0x20  ; Écrire le code couleur 0x20 (bleu) à l'offset 10000+BX
loop blue          ; Décrémenter CX et retourner à "blue" si CX != 0

; ---------------------------------------------------------
; Dessin de 10000 pixels rouges (troisième bande)
; ---------------------------------------------------------
mov cx, 10000      ; CX = 10 000 (nouvelle boucle)
red:               ; Étiquette de début de la boucle
mov bx, cx         ; BX = CX
mov byte [20000 + bx], 0x27 ; Écrire le code couleur 0x27 (rouge) à l'offset 20000+BX
loop red           ; Décrémenter CX et retourner à "red" si CX != 0

; ---------------------------------------------------------
; Boucle infinie pour maintenir le système actif
; ---------------------------------------------------------
jmp $              ; $ = adresse actuelle -> boucle infinie (halt)

; ---------------------------------------------------------
; Remplissage du secteur d'amorçage (padding)
; ---------------------------------------------------------
; Le secteur d'amorçage doit faire exactement 512 octets
; Cette ligne remplit avec des zéros jusqu'à 510 octets
times 510 - $ + start db 0

; ---------------------------------------------------------
; Signature du secteur d'amorçage (must be 0xAA55)
; Cette signature indique au BIOS que ce secteur est bootable
; ---------------------------------------------------------
dw 0xAA55