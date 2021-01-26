.data
	image dd ?
	newImage dd ?
	LAPLACE_MASK dd 1, 1, 1, 1, -8, 1, 1, 1, 1
	musk_dividor dd 1
	iter_x dd 0
	x_max dd 0
	iter_y dd 0
	y_max dd 0
	image_width dd 0
	height dd 0
	sumR dd 0
	sumG dd 0
	sumB dd 0


.code
laplaceFilter proc EXPORT

	;push RBP        ; zapisuje adresy rejestrow RBP,RDI,RSP, aby po wykonaniu procedury, zachowac spojnosc w pamieci
    push RDI                
    push RSP


	;zapisanie wskaznikow na tablice w rejestrach
	mov eax, [rbp+8]
	mov [image], eax

	;zapisanie width i height w zmiennych
	mov eax, [rbp+12]
	mov [image_width], eax
	mov eax, [rbp+16]
	mov [height], eax

	;ustawienie iter_x_max i iter_y_max
	mov eax, [image_width]
	sub eax, 2
	mov ebx, 3
	mul ebx
	mov [x_max], eax
	mov eax, [height]
	sub eax, 2
	mov [y_max], eax

	;iteracja przez tablice
PETLAY:
	mov ecx, 0
	mov edi, 0
	inc [iter_y]
	mov [iter_x], 0

PETLAX:
	add iter_x, 3

	xor eax, eax

	mov sumR, eax;
	mov sumG, eax;
	mov sumB, eax;


; #################### TOP LEFT ############################
	; top left pixel RED
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; move one pixel left
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 0]
	add sumR, eax

	; top left pixel GREEN
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; move one pixel left
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 0]
	add sumG, eax

	; top left pixel BLUE
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; move one pixel left
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 0]
	add sumG, eax


; #################### TOP MIDDLE ############################
	; top mid pixel RED
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 0				; stay middle pixel
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 4]
	add sumR, eax

	; top mid pixel GREEN
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 0				; stay middle pixel
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 4]
	add sumG, eax

	; top mid pixel BLUE
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 0				; stay middle pixel
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 4]
	add sumG, eax


; #################### TOP RIGHT ############################
	; top right pixel RED
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 8]
	add sumR, eax

	; top right pixel GREEN
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 8]
	add sumG, eax

	; top right pixel BLUE
	mov eax, [iter_y]		
	dec eax
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 8]
	add sumG, eax


; #################### MIDDLE LEFT ############################
	; middle left pixel RED
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 12]
	add sumR, eax

	; middle left pixel GREEN
	mov eax, [iter_y]	
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 12]
	add sumG, eax

	; middle left pixel BLUE
	mov eax, [iter_y]	
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 12]
	add sumG, eax


; #################### MIDDLE MIDDLE ############################
	; middle middle pixel RED
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 16]
	add sumR, eax

	; middle middle pixel GREEN
	mov eax, [iter_y]	
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 16]
	add sumG, eax

	; middle middle pixel BLUE
	mov eax, [iter_y]	
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 16]
	add sumG, eax


; #################### MIDDLE RIGHT ############################
	; middle right pixel RED
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 20]
	add sumR, eax

	; middle right pixel GREEN
	mov eax, [iter_y]	
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 20]
	add sumG, eax

	; middle right pixel BLUE
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 20]
	add sumG, eax


; #################### BOTTOM LEFT ############################
	; bottom left pixel RED
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 24]																	
	add sumR, eax																			
																							
	; bottom left pixel GREEN
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 24]
	add sumG, eax

	; bottom left pixel BLUE
	mov eax, [iter_y]		
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 3				; go one pixel left
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 24]
	add sumG, eax


; #################### BOTTOM MIDDLE ############################
	; bottom middle pixel RED
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 28]
	add sumR, eax

	; bottom middle pixel GREEN
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 28]
	add sumG, eax

	; bottom middle pixel BLUE
	mov eax, [iter_y]		
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	sub eax, 0				; don't move pixel
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 28]
	add sumG, eax


; #################### BOTTOM RIGHT ############################
	; bottom right pixel RED
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 0				; go to RED value
	add eax, [image]
	mov ebx, eax			; saving pixel position to ebx
	mov eax, [ebx]			; value from [position]		
	mul [LAPLACE_MASK + 32]
	add sumR, eax

	; bottom right pixel GREEN
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 1				; go to GREEN value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 32]
	add sumG, eax

	; bottom right pixel BLUE
	mov eax, [iter_y]	
	inc eax				; go one pixel down
	mul [x_max]
	add eax, [iter_x]
	add eax, 3				; go one pixel right
	add eax, 2				; go to BLUE value
	add eax, [image]
	mov ebx, eax
	mov eax, [ebx]
	mul [LAPLACE_MASK + 32]
	add sumG, eax


	; normalizing sums
	
	mov eax, sumR
	cmp eax, 255		;przycinanie wyniku
	JB LESS_R
	mov eax, 255
	JMP GREEN
LESS_R:
	cmp eax, 0
	JA GREEN
	mov ebx, 0

GREEN:
	mov eax, sumG
	cmp eax, 255		;przycinanie wyniku
	JB LESS_G
	mov eax, 255
	JMP BLUE
LESS_G:
	cmp eax, 0
	JA BLUE
	mov ebx, 0

BLUE:
	mov eax, sumB
	cmp eax, 255		;przycinanie wyniku
	JB LESS_B
	mov eax, 255
	JMP SAVE
LESS_B:
	cmp eax, 0
	JA SAVE
	mov ebx, 0

SAVE:					; saving new pixel in new image array

; saving RED value
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	add eax, 0				; move to RED value
	add eax, [newImage]
	mov ebx, sumR;
	mov [eax], ebx

	; saving GREEN value
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	add eax, 1				; move to GREEN value
	add eax, [newImage]
	mov ebx, sumG
	mov [eax], ebx

	; saving BLUE value
	mov eax, [iter_y]		
	mul [x_max]
	add eax, [iter_x]
	add eax, 2				; move to BLUE value
	add eax, [newImage]
	mov ebx, sumB
	mov [eax], ebx

	mov eax, [iter_x]		;koniec petli x
	cmp eax, x_max
	JB PETLAX

	mov eax, [iter_y]		;koniec petli y
	cmp eax, y_max
	JB PETLAY

	mov esp, ebp			;zakonczenie
	pop rsp        ;z koncem programu ustawiam spowrotem wartosci rejestrow pobierajac je ze stosu.
    pop rdi                        
    pop rbp
	
	mov eax, newImage
	ret

laplaceFilter endp

end