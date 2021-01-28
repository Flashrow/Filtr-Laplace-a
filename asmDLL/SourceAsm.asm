.data
	image DQ ?
	newImage DQ ?
	LAPLACE_MASK SDWORD 1, 1, 1, 1, -8, 1, 1, 1, 1
	musk_dividor dd 1
	iter_x DQ 0
	x_max DQ 0
	iter_y DQ 0
	y_max DQ 0
	image_width DQ 0
	height DQ 0
	sumR SDWORD 0
	sumG SDWORD 0
	sumB SDWORD 0


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
	mov rbx, 3
	mul rbx
	mov [image_width], rax
	mov rax, r8
	mov [height], rax

	mov newImage, r9
	;mov rcx, [newImage]

	;ustawienie iter_x_max i iter_y_max
	mov rax, [image_width]
	sub rax, 6
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

	mov sumR, eax;
	mov sumG, eax;
	mov sumB, eax;


; #################### TOP LEFT ############################
	; top left pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			; value from [position]		; saving pixel position to rbx
	xor rax, rax
	mov eax, ebx
	imul [LAPLACE_MASK + 0]
	add sumR, eax

	; top left pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 0]
	add sumG, eax

	; top left pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; move one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 0]
	add sumB, eax


; #################### TOP MIDDLE ############################
	; top mid pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			; value from [position]		
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 4]
	add sumR, eax

	; top mid pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov rbx, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 4]
	add sumG, eax

	; top mid pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 0				; stay middle pixel
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 4]
	add sumB, eax


; #################### TOP RIGHT ############################
	; top right pixel RED
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			; value from [position]		
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 8]
	add sumR, eax

	; top right pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 8]
	add sumG, eax

	; top right pixel BLUE
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 8]
	add sumB, eax


; #################### MIDDLE LEFT ############################
	; middle left pixel RED
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl			; value from [position]		
	imul [LAPLACE_MASK + 12]
	add sumR, eax

	; middle left pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 12]
	add sumG, eax

	; middle left pixel BLUE
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 12]
	add sumB, eax


; #################### MIDDLE MIDDLE ############################
	; middle middle pixel RED
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				; value from [position]	 
	imul [LAPLACE_MASK + 16]
	add sumR, eax

	; middle middle pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 16]
	add sumG, eax

	; middle middle pixel BLUE
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 16]
	add sumB, eax


; #################### MIDDLE RIGHT ############################
	; middle right pixel RED
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				; value from [position]		
	imul [LAPLACE_MASK + 20]
	add sumR, eax

	; middle right pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 20]
	add sumG, eax

	; middle right pixel BLUE
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl 
	imul [LAPLACE_MASK + 20]
	add sumB, eax


; #################### BOTTOM LEFT ############################
	; bottom left pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			; saving pixel position to rbx
	xor rax, rax
	mov al, bl	
	imul [LAPLACE_MASK + 24]																	
	add sumR, eax																			
																							
	; bottom left pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 24]
	add sumG, eax

	; bottom left pixel BLUE
	mov rax, [iter_y]		
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				; go one pixel left
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 24]
	add sumB, eax


; #################### BOTTOM MIDDLE ############################
	; bottom middle pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 28]
	add sumR, eax

	; bottom middle pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 28]
	add sumG, eax

	; bottom middle pixel BLUE
	mov rax, [iter_y]		
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				; don't move pixel
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 28]
	add sumB, eax


; #################### BOTTOM RIGHT ############################
	; bottom right pixel RED
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 0				; go to RED value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumR, eax

	; bottom right pixel GREEN
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 1				; go to GREEN value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumG, eax

	; bottom right pixel BLUE
	mov rax, [iter_y]	
	inc rax				; go one pixel down
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				; go one pixel right
	add rax, 2				; go to BLUE value
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumB, eax


	; normalizing sums
	
	xor rax, rax
	xor rbx, rbx
	mov eax, sumR
	cmp sumR, 255		;przycinanie wyniku
	JL LESS_R
	mov eax, 255
	mov sumR, eax
	JMP GREEN
LESS_R:
	cmp eax, 0
	JG GREEN
	mov eax, 0
	mov sumR, eax

GREEN:
	xor rax, rax
	xor rbx, rbx
	mov eax, sumG
	cmp sumG, 255		;przycinanie wyniku
	JL LESS_G
	mov eax, 255
	mov sumG, eax
	JMP BLUE
LESS_G:
	cmp eax, 0
	JG BLUE
	mov eax, 0
	mov sumG, eax

BLUE:
	xor rax, rax
	xor rbx, rbx
	mov eax, sumB
	cmp sumB, 255		;przycinanie wyniku
	JL LESS_B
	mov eax, 255
	mov sumB, eax
	JMP SAVE
LESS_B:
	cmp eax, 0
	JG SAVE
	mov eax, 0
	mov sumB, eax

SAVE:					; saving new pixel in new image array

	mov rcx, 3
; saving RED value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 0				; move to RED value
	add rax, newImage
	xor rbx, rbx
	mov ebx, sumR
	mov [rax], bl

	; saving GREEN value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 1				; move to GREEN value
	add rax, newImage
	xor rbx, rbx
	mov ebx, sumG
	mov [rax], bl

	; saving BLUE value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 2				; move to BLUE value
	add rax, newImage
	xor rbx, rbx
	mov ebx, sumB
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
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9
	mov image, rax
	mov newImage, rax

	ret

laplaceFilter endp

end