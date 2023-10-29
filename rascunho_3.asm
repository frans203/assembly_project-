.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

include \masm32\macros\macros.asm

.data
    ; Varivaies para o tratamento de arquivos
    
    fileHandle dd 0
    fileHandle2 dd 0
    fileBuffer db 10000 dup(0)
    ; fileBuffer2 db 10000 dup(0) Nao ta sendo usado
    pixelsArray db 6480 dup(0) 
    readCount dd 0 
    writeCount dd 0
    fileNameOut db "fotoAlterada.bmp", 0H, 0AH ;nome do arquivo de saida

    ; Variaveis para entrada e saida
    
    inputHandle dd 0
    outputHandle dd 0
    console_count dd 0
    inputString db 50 dup(0)
    tamanho_string dd 0

    ; Variaveis para a imagem
    
    image_width_pixels dd 0 
    image_width_bytes dd 0
    line_count dd 0
    pixel_count dd 0
    pixel_count_bytes dd 0
    nbytes dd 0

    ; Variaveis fornecidas pelo usuario
    
    fileName db 50 dup(0)
    start_x dd 0
    start_x_bytes dd 0
    start_y dd 0
    rectangle_width dd 0
    rectangle_width_bytes dd 0
    rectangle_height dd 0
    

    ; Debugar
    ;fileName db "fotoanonima.bmp", 0H, 0AH
    ;start_x dd 250
    ;start_y dd 310
    ;rectangle_width dd 230
    ;rectangle_height dd 30
    ;rectangle_width_x dd 0

    ; Strings
    
    request_file db "Informe o nome do arquivo original (.bmp incluso): ", 0H
    request_x db  "Informe a coordenada inicial X: ", 0H
    request_y db "Informe a coordenada inicial Y: ", 0H
    request_width db "Informe a largura desejada para o retangulo: ", 0H
    request_height db "Informe a altura desejada para o retangulo: ", 0H
    


.code
pinta_preto_func:
	push ebp
	mov ebp, esp
	sub esp, 8

      ;zerando variaveis locais 
	mov DWORD PTR [ebp-4], 0 ;variavel para contagem de pixels
      mov DWORD PTR [ebp-8], 0 ;variavel para start_x em bytes
	mov ecx, DWORD PTR [ebp+16] ;offset pixels_array
        
            mov eax, DWORD PTR [ebp+12] ;start_x
            mov ebx, 3
            mul ebx
            add DWORD PTR [ebp-8], eax ;colocando em ebp-8 start_x em bytes
                    
        pinta_preto_loop:
            mov edx, DWORD PTR [ebp+8] ;rectangle_width
            cmp edx, DWORD PTR [ebp-4] ;comparando ebp-4 com rectangle_width
            je final_funcao
            
            
            mov eax, DWORD PTR [ebp-4]
            mov edx, 3
            mul edx
            add eax, DWORD PTR [ebp-8]; somando ebp-4 em bytes com start_x em bytes
          
            mov edx, 0
            mov [ecx + eax + 0], edx
            mov [ecx + eax +  1], edx
            mov [ecx + eax +  2], edx ; pintando os bytes de preto
            inc DWORD PTR [ebp-4]  ;incrementando ebp-4
            jmp pinta_preto_loop
	
	final_funcao: ;epilogo da funcao
		mov esp, ebp
		pop ebp
		ret 12
		

start:
    ; --- ENTRADA/SAIDA ---
    
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    MOV inputHandle, eax
    
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    MOV outputHandle, eax

    ; --- Leitura das variaveis ---

        ; fileName
        
    INVOKE WriteConsole, outputHandle, addr request_file, sizeof request_file, addr console_count, NULL
    INVOKE ReadConsole, inputHandle, addr fileName, sizeof fileName, addr console_count, NULL

    MOV esi, offset fileName ; Limpa a string do input
    proximo1:
        MOV al, [esi]
        INC esi
        CMP al, 13 ; compara como  ASCII de CR
        JNE proximo1
        DEC esi
        XOR al, al ; Basicamente coloca aquele 0H (0) para indicar o final da string
        MOV [esi], al

        ; start_x
        
    INVOKE WriteConsole, outputHandle, addr request_x, sizeof request_x, addr console_count, NULL
    INVOKE ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL

    MOV esi, offset inputString ; Limpa a string do input
    proximo2:
        MOV al, [esi]
        INC esi
        CMP al, 13 ; compara como  ASCII de CR
        JNE proximo2
        DEC esi
        XOR al, al ; Basicamente coloca aquele 0H (0) para indicar o final da string
        MOV [esi], al

    INVOKE atodw, addr inputString
    MOV start_x, eax

        ; start_y

    INVOKE WriteConsole, outputHandle, addr request_y, sizeof request_y, addr console_count, NULL
    INVOKE ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL

    MOV esi, offset inputString ; Limpa a string do input
    proximo3:
        MOV al, [esi]
        INC esi
        CMP al, 13 ; compara como  ASCII de CR
        JNE proximo3
        DEC esi
        XOR al, al ; Basicamente coloca aquele 0H (0) para indicar o final da string
        MOV [esi], al

    INVOKE atodw, addr inputString
    MOV start_y, eax
    
        ; rectangle_width

    INVOKE WriteConsole, outputHandle, addr request_width, sizeof request_width, addr console_count, NULL
    INVOKE ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL

    MOV esi, offset inputString ; Limpa a string do input
    proximo4:
        MOV al, [esi]
        INC esi
        CMP al, 13 ; compara como  ASCII de CR
        JNE proximo4
        DEC esi
        XOR al, al ; Basicamente coloca aquele 0H (0) para indicar o final da string
        MOV [esi], al

    INVOKE atodw, addr inputString
    MOV rectangle_width, eax

        ; rectangle_height

    INVOKE WriteConsole, outputHandle, addr request_height, sizeof request_height, addr console_count, NULL
    INVOKE ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL

    MOV esi, offset inputString ; Limpa a string do input
    proximo5:
        MOV al, [esi]
        INC esi
        CMP al, 13 ; compara como  ASCII de CR
        JNE proximo5
        DEC esi
        XOR al, al ; Basicamente coloca aquele 0H (0) para indicar o final da string
        MOV [esi], al

    INVOKE atodw, addr inputString
    MOV rectangle_height, eax

    
    ; --- LENDO ARQUIVO ORIGINAL ---
    
    INVOKE CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    MOV fileHandle, eax

    INVOKE ReadFile, fileHandle, addr fileBuffer, 18, addr readCount, NULL ; LENDO 18 BYTES DO ARQUIVO


    ; --- ESCREVENDO 18 BYTES ---   
     
    INVOKE CreateFile, addr fileNameOut, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    MOV fileHandle2, eax

    INVOKE WriteFile, fileHandle2, addr fileBuffer, 18,  addr writeCount, NULL ; ESCREVENDO 18 BYTES NO NOVO ARQUIVO; OBS: ESCRITAS VAO SEMPRE NO FINAL 


    ; --- LENDO 4 BYTES, SALVANDO NA WIDTH, ESCREVENDO NA IMAGEM 2 ---
    
    INVOKE ReadFile, fileHandle, addr image_width_pixels, 4, addr readCount, NULL ; LENDO MAIS 4 BYTES

    ; Se ler no fileBuffer prexcisa fazer esse processo todo
    ;mov ebx, offset fileBuffer
    ;mov eax, [ebx]
    ;mov ebx, offset image_width_pixels
    ;mov [ebx], eax
    
        ;QUANTIDADE DE BYTES/PIXEL EM UMA LINHA
    ; xor eax, eax
    MOV eax, image_width_pixels
    xor ebx, ebx
    mov ebx, 3
    MUL ebx
    mov image_width_bytes, eax
    

    INVOKE WriteFile, fileHandle2, addr image_width_pixels, 4, addr writeCount, NULL

    ; --- LENDO 32 BYTES RESTANTES E ESCREVENDO NO ARQUIVO DE SAIDA ---
    
    INVOKE ReadFile, fileHandle, addr fileBuffer, 32, addr readCount, NULL
    INVOKE WriteFile, fileHandle2, addr fileBuffer, 32, addr writeCount, NULL
    

    ; --- LOOP PIXELS ---
    
    loop_pixels_inicial:
        ; Comparacao entre line_count e start_y
        MOV eax, start_y
        MOV ecx, line_count
        CMP eax, ecx
        JE loop_pixels_criticos

        invoke ReadFile, fileHandle, addr pixelsArray, image_width_bytes , addr readCount, NULL
        CMP readCount, 0
        JE out_loop

        INVOKE WriteFile, fileHandle2, addr pixelsArray, image_width_bytes, addr writeCount, NULL

        MOV ecx, line_count
        INC ecx
        MOV line_count, ecx
        JMP loop_pixels_inicial

    loop_pixels_criticos:
        

        ; Vai ficar nesse loop ate o line_count superar o start_y + rectangle_width
        MOV eax, start_y
        ADD eax, rectangle_height
        MOV ecx, line_count
        CMP eax, ecx
        JE loop_pixels_final
        
       
        invoke ReadFile, fileHandle, addr pixelsArray, image_width_bytes, addr readCount, NULL
        push offset pixelsArray
        push start_x
        push rectangle_width
        CALL pinta_preto_func


        incrementa_linha:
            INVOKE WriteFile, fileHandle2, addr pixelsArray, image_width_bytes, addr writeCount, NULL
            INC line_count
           
            JMP loop_pixels_criticos

    loop_pixels_final:
    ; Copia o restante dos pixels da imagem
        INVOKE ReadFile, fileHandle, addr pixelsArray, image_width_bytes, addr readCount, NULL
        CMP readCount, 0
        JE out_loop

        INVOKE WriteFile, fileHandle2, addr pixelsArray, image_width_bytes, addr writeCount, NULL

        JMP loop_pixels_final
   
    out_loop:
        ;APENAS PARA TESTE:
        MOV eax, start_x
        mov ebx, 3
        MUL ebx
        printf("testeaaaa %d\n", eax)
        printf("Image Width Pixels %d\n", image_width_pixels)
        printf("Image Width Bytes %d\n", image_width_bytes)
        printf("Start_x %d\n", start_x)
        printf("Start_y %d\n", start_y)
        printf("rectangle_width %d\n", rectangle_width)
        printf("rectangle_height %d\n", rectangle_height)
        invoke ExitProcess, 0
end start