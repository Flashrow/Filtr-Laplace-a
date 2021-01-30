.data
	image DQ ?
	newImage DQ ?
	LAPLACE_MASK SDWORD 1, 1, 1, 1, -8, 1, 1, 1, 1
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

	push rbp        ; zapisuje adresy rejestrow RBP,RDI,RSP, aby po wykonaniu procedury, zachowac spojnosc w pamieci
    push rdi                
    push rsp
	push rsi

	xor rax, rax

	
	
	mov rax, rcx						
	mov image, rax
	;mov rcx, QWORD PTR [rax]

	
	mov rax, rdx						;zapisanie width i height w zmiennych
	mov rbx, 3
	mul rbx
	mov [image_width], rax
	mov rax, r8
	mov [height], rax

	mov newImage, r9					; zapisanie wskaŸnika na tablicê
	;mov rcx, [newImage]

	mov rax, [image_width]				; ustawienie iter_x_max i iter_y_max
	sub rax, 6
	mov [x_max], rax
	mov rax, [height]
	sub rax, 2
	mov [y_max], rax

PETLAY:									; pêtla po wartoœciach y
	mov ecx, 0
	mov edi, 0
	inc [iter_y]
	mov [iter_x], 0

PETLAX:									; pêtla po wartoœciach x
	add iter_x, 3

	xor rax, rax

	mov sumR, eax						
	mov sumG, eax
	mov sumB, eax


; #################### TOP LEFT ############################
	; top left pixel RED
	mov rax, [iter_y]		; przejœcie do bie¿¹cej pozycji Y
	dec rax					; przejœcie jeden piksel do góry
	mul [image_width]		; wybranie odpowiedniej pozycji w tablicy
	add rax, [iter_x]		; przesuniêcie na odpowiedni¹ pozycjê Y
	sub rax, 3				; przesuñ jeden pixel w lewo
	add rax, 0				; wybranie wartoœci R - czerwony
	add rax, image			; przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx
	mov bl, [rax]			; odczytanie wartoœci R z wybranego punktu
	xor rax, rax
	mov eax, ebx
	imul [LAPLACE_MASK + 0]	; na³o¿enie maski
	add sumR, eax			; zaktualizowanie sumy
							
			; ka¿dy kolejny punkt jest analogicznie procesowany

	; top left pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				
	add rax, 1				
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
	sub rax, 3				
	add rax, 2				
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
	add rax, 0				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]				
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 4]
	add sumR, eax

	; top mid pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 0				
	add rax, 1				
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
	add rax, 0				
	add rax, 2				
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
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]					
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 8]
	add sumR, eax

	; top right pixel GREEN
	mov rax, [iter_y]		
	dec rax
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				
	add rax, 1				
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
	add rax, 3				
	add rax, 2				
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
	sub rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl				
	imul [LAPLACE_MASK + 12]
	add sumR, eax

	; middle left pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				
	add rax, 1				
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
	sub rax, 3				
	add rax, 2				
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
	sub rax, 0				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				 
	imul [LAPLACE_MASK + 16]
	add sumR, eax

	; middle middle pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				
	add rax, 1				
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
	sub rax, 0				
	add rax, 2				
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
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl						
	imul [LAPLACE_MASK + 20]
	add sumR, eax

	; middle right pixel GREEN
	mov rax, [iter_y]	
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				
	add rax, 1				
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
	add rax, 3				
	add rax, 2				
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
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl	
	imul [LAPLACE_MASK + 24]																	
	add sumR, eax																			
																							
	; bottom left pixel GREEN
	mov rax, [iter_y]	
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 24]
	add sumG, eax

	; bottom left pixel BLUE
	mov rax, [iter_y]		
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 3				
	add rax, 2				
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
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 28]
	add sumR, eax

	; bottom middle pixel GREEN
	mov rax, [iter_y]	
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 28]
	add sumG, eax

	; bottom middle pixel BLUE
	mov rax, [iter_y]		
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	sub rax, 0				
	add rax, 2				
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
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				
	add rax, 0				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumR, eax

	; bottom right pixel GREEN
	mov rax, [iter_y]	
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				
	add rax, 1				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumG, eax

	; bottom right pixel BLUE
	mov rax, [iter_y]	
	inc rax				
	mul [image_width]
	add rax, [iter_x]
	add rax, 3				
	add rax, 2				
	add rax, image
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [LAPLACE_MASK + 32]
	add sumB, eax


	; normalizowanie sum
	
	xor rax, rax
	xor rbx, rbx
	mov eax, sumR
	cmp sumR, 255		; porównanie z wartoœci¹ górn¹ (255)
	JL LESS_R
	mov eax, 255		; ograniczenie wartoœci do max 255
	mov sumR, eax
	JMP GREEN
LESS_R:
	cmp eax, 0			; porównanie do wartoœci minimalnej
	JG GREEN
	mov eax, 0			; ograniczenie wartoœci minimalnej
	mov sumR, eax

	; pozosta³e kolory analogicznie

GREEN:
	xor rax, rax
	xor rbx, rbx
	mov eax, sumG
	cmp sumG, 255		
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
	cmp sumB, 255		
	JL LESS_B
	mov eax, 255
	mov sumB, eax
	JMP SAVE
LESS_B:
	cmp eax, 0
	JG SAVE
	mov eax, 0
	mov sumB, eax

SAVE:					; zapisywanie nowych wartoœci punktu do tablicy

	mov rcx, 3
; saving RED value
	xor rax, rax
	mov rax, [iter_y]		; przejœcie do odpowiedniego Y
	mul [image_width]		; przesuniêcie do miejsca w tablicy
	add rax, [iter_x]		; przejœcie do odpowiedniego X
	add rax, 0				; ustawienie czerwonego koloru (R=0, G=1, B=2)
	add rax, newImage		; przejœcie do odpowiedniego miejsca w pamiêci
	xor rbx, rbx
	mov ebx, sumR
	mov [rax], bl			; zapisanie

	; saving GREEN value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 1				; ustawienie zielonego
	add rax, newImage
	xor rbx, rbx
	mov ebx, sumG
	mov [rax], bl

	; saving BLUE value
	xor rax, rax
	mov rax, [iter_y]		
	mul [image_width]
	add rax, [iter_x]
	add rax, 2				; ustawienie niebieskiego
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


	xor rax, rax	; czyszczenie pozosta³ych rejestrów
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9
	mov image, rax
	mov newImage, rax

					;z koncem programu ustawiam spowrotem wartosci rejestrow pobierajac je ze stosu.
	pop rsi
	pop rsp    
    pop rdi                        
    pop rbp

	ret

laplaceFilter endp

end