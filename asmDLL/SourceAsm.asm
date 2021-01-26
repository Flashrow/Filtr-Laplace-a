.data
	image DQ ?
	newImage DQ ?
	LAPLACE_MASK dd 1, 1, 1, 1, -8, 1, 1, 1, 1
	musk_dividor dd 1
	iter_x DQ 0
	x_max DQ 0
	iter_y DQ 0
	y_max DQ 0
	image_width DQ 0
	height DQ 0
	sumR DQ 0
	sumG DQ 0
	sumB DQ 0


.code
laplaceFilter proc EXPORT

	push RBP        ; zapisuje adresy rejestrow RBP,RDI,RSP, aby po wykonaniu procedury, zachowac spojnosc w pamieci
    push RDI                
    push RSP

	xor rax, rax

	;zapisanie wskaznikow na tablice w rejestrach
	
	mov rax, rcx
	mov image, rax
	;mov rcx, QWORD PTR [rax]

	;zapisanie width i height w zmiennych
	mov rax, rdx
	mov [image_width], rax
	mov rax, r8
	mov [height], rax

	mov newImage, r9
	;mov rcx, [newImage]

	

	;ustawienie iter_x_max i iter_y_max
	mov rax, [image_width]
	sub rax, 2
	mov rbx, 3
	mul rbx
	mov [x_max], rax
	mov rax, [height]
	sub rax, 2
	mov [y_max], rax

	;iteracja przez tablice
PETLAY:
	mov ecx, 0
	mov edi, 0
	inc [iter_y]
	mov [iter_x], 0

PETLAX:
	add iter_x, 3

	xor rax, rax

	mov sumR, rax;
	mov sumG, rax;
	mov sumB, rax;


; #################### TOP LEFT ############################
	; top left pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov rbx, [rax]			; value from [position]		; saving pixel position to rbx
	mul [LAPLACE_MASK + 0]
	add sumR, rbx
	mov rax, sumR

	; top left pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 0]
	add sumG, rax

	; top left pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 0]
	add sumG, rax


; #################### TOP MIDDLE ############################
	; top mid pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 4]
	add sumR, rax

	; top mid pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 4]
	add sumG, rax

	; top mid pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 4]
	add sumG, rax


; #################### TOP RIGHT ############################
	; top right pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 8]
	add sumR, rax

	; top right pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 8]
	add sumG, rax

	; top right pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 8]
	add sumG, rax


; #################### MIDDLE LEFT ############################
	; middle left pixel RED
	mov rax, [iter_y]		
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 12]
	add sumR, rax

	; middle left pixel GREEN
	mov rax, [iter_y]	
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 12]
	add sumG, rax

	; middle left pixel BLUE
	mov rax, [iter_y]	
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 12]
	add sumG, rax


; #################### MIDDLE MIDDLE ############################
	; middle middle pixel RED
	mov rax, [iter_y]		
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 16]
	add sumR, rax

	; middle middle pixel GREEN
	mov rax, [iter_y]	
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 16]
	add sumG, rax

	; middle middle pixel BLUE
	mov rax, [iter_y]	
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 16]
	add sumG, rax


; #################### MIDDLE RIGHT ############################
	; middle right pixel RED
	mov rax, [iter_y]		
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 20]
	add sumR, rax

	; middle right pixel GREEN
	mov rax, [iter_y]	
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 20]
	add sumG, rax

	; middle right pixel BLUE
	mov rax, [iter_y]		
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 20]
	add sumG, rax


; #################### BOTTOM LEFT ############################
	; bottom left pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 24]																	
	add sumR, rax																			
																							
	; bottom left pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 24]
	add sumG, rax

	; bottom left pixel BLUE
	mov rax, [iter_y]		
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 24]
	add sumG, rax


; #################### BOTTOM MIDDLE ############################
	; bottom middle pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 28]
	add sumR, rax

	; bottom middle pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 28]
	add sumG, rax

	; bottom middle pixel BLUE
	mov rax, [iter_y]		
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 28]
	add sumG, rax


; #################### BOTTOM RIGHT ############################
	; bottom right pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	mov rbx, rax			; saving pixel position to rbx
	mov rax, [rbx]			; value from [position]		
	mul [LAPLACE_MASK + 32]
	add sumR, rax

	; bottom right pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 32]
	add sumG, rax

	; bottom right pixel BLUE
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [x_max]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	mov rbx, rax
	mov rax, [rbx]
	mul [LAPLACE_MASK + 32]
	add sumG, rax


	; normalizing sums
	
	xor rax, rax
	xor rbx, rbx
	mov rax, sumR
	cmp rax, 255		;przycinanie wyniku
	JB LESS_R
	mov rax, 255
	mov sumR, rax
	JMP GREEN
LESS_R:
	cmp rax, 0
	JA GREEN
	mov rax, 0
	mov sumR, rax

GREEN:
	xor rax, rax
	xor rbx, rbx
	mov rax, sumG
	cmp rax, 255		;przycinanie wyniku
	JB LESS_G
	mov rax, 255
	mov sumG, rax
	JMP BLUE
LESS_G:
	cmp rax, 0
	JA BLUE
	mov rax, 0
	mov sumG, rax

BLUE:
	xor rax, rax
	xor rbx, rbx
	mov rax, sumB
	cmp rax, 255		;przycinanie wyniku
	JB LESS_B
	mov rax, 255
	mov sumB, rax
	JMP SAVE
LESS_B:
	cmp rax, 0
	JA SAVE
	mov rax, 0
	mov sumB, rax

SAVE:					; saving new pixel in new image array

	mov rcx, 3
; saving RED value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	mul rcx
	add rax, [iter_x]
	add rax, 0				; move to RED value
	add rax, newImage
	xor rbx, rbx
	mov rbx, sumR
	mov [rax], bl

	; saving GREEN value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	mul rcx
	add rax, [iter_x]
	add rax, 1				; move to GREEN value
	add rax, newImage
	xor rbx, rbx
	mov rbx, sumG
	mov [rax], bl

	; saving BLUE value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	mul rcx
	add rax, [iter_x]
	add rax, 2				; move to BLUE value
	add rax, newImage
	xor rbx, rbx
	mov rbx, sumB
	mov [rax], bl

	mov rax, [iter_x]		;koniec petli x
	cmp rax, x_max
	JB PETLAX

	mov rax, [iter_y]		;koniec petli y
	cmp rax, y_max
	JB PETLAY


	pop rsp        ;z koncem programu ustawiam spowrotem wartosci rejestrow pobierajac je ze stosu.
    pop rdi                        
    pop rbp
	
	xor rax, rax
	ret

laplaceFilter endp

end