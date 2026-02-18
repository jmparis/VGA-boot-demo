; =============================================================================
; BOOT SECTOR - Drapeau français en mode VGA 13h
; =============================================================================
; Ce programme est un boot sector x86 (16 bits) qui s'exécute au démarrage
; de l'ordinateur. Il passe en mode graphique VGA 13h (320x200 pixels, 256
; couleurs) et dessine le drapeau français en traversant l'écran pixel par
; pixel.
;
; Le drapeau français se compose de trois bandes verticales :
;   - Bleu (gauche)   : pixels 0 à 106  (107 pixels de large)
;   - Blanc (milieu)  : pixels 107 à 213 (107 pixels de large)
;   - Rouge (droite)  : pixels 214 à 319 (106 pixels de large)
;
; Le total fait 320 pixels de large (la largeur de l'écran en mode 13h).
; =============================================================================

; [org 0x7C00] - Origin (Adresse de base)
; -----------------------------------------------------------------------------
; Lors du démarrage, le BIOS charge le premier secteur (512 octets) du
; périphérique de boot (disquette, disque dur, USB...) à l'adresse mémoire
; physique 0x7C00. Cette adresse est une convention historique du PC IBM
; original (1981). L'instruction [org 0x7C00] dit au compilateur NASM que
; toutes les adresses dans ce code sont relatives à 0x7C00, ce qui permet
; d'utiliser des labels sans se soucier des adresses absolues.
;
; Cette adresse a été choisie car :
;   - Elle est juste au-dessus de la zone de données du BIOS (0x0000-0x0400)
;   - Elle laisse suffisamment de place pour la pile (qui descend)
;   - Elle n'entre pas en conflit avec les vecteurs d'interruption
; -----------------------------------------------------------------------------
[org 0x7C00]

    ; =========================================================================
    ; PHASE 1 : Passage en mode VGA 13h
    ; =========================================================================
    ; Le BIOS предоставляет услугу (interruption 0x10) pour changer le mode
    ; d'affichage. Le mode 13h est un mode graphique populaire pour les jeux
    ; DOS car il offre une résolution de 320x200 pixels avec 256 couleurs.
    ;
    ; Caractéristiques du mode 13h :
    ;   - Résolution : 320 x 200 pixels
    ;   - Couleurs   : 256 couleurs (8 bits par pixel)
    ;   - Organisation de la mémoire vidéo : linéaire, un octet par pixel
    ;   - Segment vidéo : 0xA000 (voir ci-dessous)
    ;
    ; Registres pour AH=0x00 (Set Video Mode) :
    ;   - AH = 0x00    : Fonction "Set Video Mode"
    ;   - AL = 0x13    : Mode VGA 13h (320x200x256)
    ; =========================================================================
    
    ; Charge AH = 0x00 (fonction "Set Video Mode" du BIOS)
    mov ax, 0x0013
    
    ; Appelle l'interruption 0x10 du BIOS
    ; Cette interruption gère tous les services vidéo (texte, graphique, etc.)
    int 0x10

    ; =========================================================================
    ; PHASE 2 : Configuration du segment vidéo ES
    ; =========================================================================
    ; En mode 13h, la mémoire vidéo commence à l'adresse segment 0xA000.
    ; Pour écrire un pixel, on utilise l'adresse physique :
    ;   Adresse = (segment << 4) + offset = 0xA0000 + offset
    ;            = 0xA0000 + (y * 320 + x)
    ;
    ; Le registre ES (Extra Segment) est utilisé car STOSB utilise [ES:DI].
    ; En mettant ES = 0xA000, on peut écrire directement dans la mémoire
    ; vidéo en utilisant DI comme offset (position du pixel).
    ;
    ; Détails techniques :
    ;   - Segment 0xA000 = 40960 en décimal
    ;   - Adresse physique : 0xA000 * 16 = 0xA0000 = 655360 décimal
    ;   - La mémoire vidéo fait 320 * 200 = 64000 octets (de 0 à 63999)
    ; =========================================================================
    
    ; Charge 0xA000 dans AX (le segment vidéo VGA)
    mov ax, 0xA000
    
    ; Transfère AX dans ES (Extra Segment)
    ; ES pointe maintenant vers le début de la mémoire vidéo
    mov es, ax

    ; =========================================================================
    ; PHASE 3 : Dessin du drapeau français
    ; =========================================================================
    ; Algorithme :
    ;   Pour chaque ligne y (de 0 à 199)
    ;       Pour chaque pixel x (de 0 à 319)
    ;           Déterminer la couleur selon la position x
    ;           Écrire le pixel à l'offset (y * 320 + x)
    ;
    ; Couleurs utilisées (palette VGA standard) :
    ;   - Bleu  : couleur #1   (001h) - bleu pur
    ;   - Blanc : couleur #15  (00Fh) - blanc brillant
    ;   - Rouge : couleur #4   (004h) - rouge pur
    ;
    ; Le registre AL contiendra le numéro de couleur (0-255) à écrire.
    ; Le registre DI contiendra l'offset dans la mémoire vidéo.
    ; =========================================================================

    ; -------------------------------------------------------------------------
    ; Initialisation des registres pour la boucle principale
    ; -------------------------------------------------------------------------
    
    ; DI (Destination Index) = 0
    ; DI est utilisé par STOSB comme offset dans le segment ES
    ; En mettant DI à 0, on commence au premier pixel (coin haut-gauche)
    xor di, di          ; offset vidéo = 0
    
    ; DX = 0 (compteur de lignes y)
    ; DX sera incrémenté après chaque ligne complète
    xor dx, dx          ; y = 0

; ============================================================================
; BOUCLE PRINCIPALE : Itération sur chaque ligne (axe Y)
; ============================================================================
; Cette boucle outer parcourt toutes les lignes de l'écran (0 à 199).
; À chaque itération, on dessine une ligne complète de 320 pixels.
; ============================================================================

next_line:
    ; CX = 0 (compteur de colonnes/pixels x)
    ; CX sera incrémenté après chaque pixel
    xor cx, cx          ; x = 0

; ============================================================================
; SOUS-BOUCLE : Itération sur chaque pixel (axe X)
; ============================================================================
; Cette boucle inner parcourt tous les pixels d'une ligne (0 à 319).
; À chaque pixel, on détermine sa couleur selon sa position horizontale.
; ============================================================================

next_pixel:
    ; Copie CX dans BX pour ne pas modifier CX qui sert de compteur
    ; BX = CX = position x du pixel actuel (0 à 319)
    mov bx, cx          ; bx = x

    ; -------------------------------------------------------------------------
    ; Détermination de la couleur selon la position x
    ; -------------------------------------------------------------------------
    ; Comparaison 1 : x < 107 ?
    ; Si vrai, le pixel est dans la bande bleue (gauche)
    ; -------------------------------------------------------------------------
    
    cmp bx, 107
    jl .blue_band       ; x < 107 → bleu

    ; -------------------------------------------------------------------------
    ; Comparaison 2 : 107 <= x < 214 ?
    ; Si vrai, le pixel est dans la bande blanche (milieu)
    ; Si faux (x >= 214), le pixel est dans la bande rouge (droite)
    ; -------------------------------------------------------------------------
    
    cmp bx, 214
    jl .white_band      ; 107 <= x < 214 → blanc

    ; -------------------------------------------------------------------------
    ; Bande rouge (droite) : x >= 214
    ; -------------------------------------------------------------------------
    ; donc (dans ce cas) on charge le rouge
    
    ; Charge la couleur rouge (#4) dans AL
    ; La couleur 4 dans la palette VGA standard est le rouge pur
    mov al, 4           ; rouge (palette standard)
    
    ; Saute à l'étiquette .store pour écrire le pixel
    jmp .store

; ============================================================================
; Étiquette .blue_band : Bande bleue (gauche)
; ============================================================================
; Cette section s'exécute quand x < 107
; On charge la couleur bleue (#1) dans AL
; ============================================================================

.blue_band:
    ; Charge la couleur bleue (#1) dans AL
    ; La couleur 1 dans la palette VGA standard est le bleu pur
    mov al, 1           ; bleu (palette standard)
    
    ; Saute à l'étiquette .store pour écrire le pixel
    jmp .store

; ============================================================================
; Étiquette .white_band : Bande blanche (milieu)
; ============================================================================
; Cette section s'exécute quand 107 <= x < 214
; On charge la couleur blanche (#15) dans AL
; ============================================================================

.white_band:
    ; Charge la couleur blanche (#15) dans AL
    ; La couleur 15 dans la palette VGA standard est le blanc brillant
    mov al, 15          ; blanc

; ============================================================================
; Étiquette .store : Écriture du pixel
; ============================================================================
; À ce point, AL contient le numéro de couleur à afficher.
; STOSB (Store String Byte) écrit AL à l'adresse [ES:DI], puis incrémente DI.
; ============================================================================

.store:
    ; Écrit le pixel à l'adresse [ES:DI] et incrémente DI
    ; STOSB équivalent à : [ES:DI] = AL; DI = DI + 1
    stosb               ; écrit AL à [ES:DI], DI++

    ; -------------------------------------------------------------------------
    ; Incrémentation du compteur de pixels et test de fin de ligne
    ; -------------------------------------------------------------------------
    
    ; Incrémente CX (compteur de pixels x)
    inc cx
    
    ; Compare CX à 320 (largeur de l'écran en pixels)
    ; Si CX < 320, on n'a pas fini la ligne → continuer
    cmp cx, 320
    jl next_pixel       ; tant que x < 320

    ; =========================================================================
    ; Fin de la ligne : passer à la ligne suivante
    ; =========================================================================
    
    ; Incrémente DX (compteur de lignes y)
    inc dx
    
    ; Compare DX à 200 (hauteur de l'écran en pixels)
    ; Si DX < 200, on n'a pas fini l'écran → prochaine ligne
    cmp dx, 200
    jl next_line        ; tant que y < 200

; ============================================================================
; PHASE 4 : Boucle infinie (fin du programme)
; ============================================================================
; Une fois le drapeau dessiné, le programme entre dans une boucle infinie.
; En boot sector, il n'y a pas de système d'exploitation pour retourner le
; contrôle, donc on arrête le processeur.
;
; CLI (Clear Interrupts) désactive les interruptions matérielles.
; HLT (Halt) arrête le processeur en attendant une interruption.
; La combinaison avec JMP forme une boucle de sécurité.
; ============================================================================

hang:
    ; Désactive les interruptions matérielles
    ; CLI force le CPU à ignorer les IRQ (Interrupt Requests)
    ; C'est une mesure de sécurité pour éviter que des interruptions
    ; ne viennent interrompre notre boucle d'attente
    cli
    
    ; Arrête le processeur en attendant une interruption
    ; HLT met le CPU en état de faible consommation et l'attend un événement
    ; Cela peut être une interruption matérielle (clavier, horloge, etc.)
    hlt
    
    ; Boucle de sécurité : si HLТ est réveillé par une interruption,
    ; on revient ici et on reboucle vers hang
    jmp hang

; ============================================================================
; REMPLISSAGE ET SIGNATURE DU BOOT SECTOR
; ============================================================================
; Un boot sector valide DOIT faire exactement 512 octets et se terminer
; par la signature 0xAA55 (les octets 511 et 512).
;
; Le BIOS vérifie cette signature pour确认 que le secteur est bootable.
; Si elle est absente, le BIOS ignore le secteur et passe au suivant.
;
; Calcul du remplissage :
;   - Taille cible : 510 octets (pour laisser place à la signature)
;   - Taille actuelle : nombre d'octets déjà écrits ($ - $$)
;   - On remplit avec des zéros (db 0) pour atteindre 510 octets
;
; Explications :
;   - $  = adresse actuelle dans le fichier
;   - $$ = adresse de début du segment (0x7C00)
;   - $-$$ = nombre d'octets depuis le début
;   - 510-($-$$) = nombre d'octets restants à remplir
;   - db 0 = Define Byte (octet) à 0
;
; La signature 0xAA55 = 0x55AA en little-endian (octets inversés)
; ============================================================================

times 510-($-$$) db 0

; Signature de boot (obligatoire pour que le BIOS reconnaisse ce secteur)
; DW (Define Word) écrit un mot (16 bits = 2 octets)
; En mémoire, 0xAA55 est stocké comme 0x55 0xAA (little-endian)
dw 0xAA55
