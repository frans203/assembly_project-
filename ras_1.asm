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
    fileName db "fotoanonima.bmp", 0H, 0AH ;nome do arquivo 
    fileNameOut db "foto2.bmp", 0H, 0AH ;nome do arquivo de saida

    ;VARIAVEIS ARQUIVOS
    fileHandle dd 0
    fileHandle02 dd 0
    fileBuffer db 10000 dup(0)
    fileBuffer02 db 10000 dup(0)
    pixelsArray db 6480 dup(0) 
    readCount dd 0 
    writeCount dd 0 

    ;VARIAVEIS ENTRADA E SAIDA
    outputHandle dd 0
    console_count dd 0

    ;VARIAVEIS IMAGEM
    image_width dd 0 
    image_width_pixels dd 0    


.code
start:
    ;1) ENTRADA/SAIDA
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    MOV outputHandle, eax

    ;2) LENDO ARQUIVO ORIGINAL
    INVOKE CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    MOV fileHandle, eax

    INVOKE ReadFile, fileHandle, addr fileBuffer, 18, addr readCount, NULL ; LENDO 18 BYTES DO ARQUIVO


    ;3) ESCREVENDO 18 BYTES    
    INVOKE CreateFile, addr fileNameOut, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    MOV fileHandle02, eax

    INVOKE WriteFile, fileHandle02, addr fileBuffer, 18,  addr writeCount, NULL ; ESCREVENDO 18 BYTES NO NOVO ARQUIVO; OBS: ESCRITAS VAO SEMPRE NO FINAL 


    ;4)LENDO 4 BYTES, SALVANDO NA WIDTH, ESCREVENDO NA IMAGEM 2
    INVOKE ReadFile, fileHandle, addr fileBuffer, 4, addr readCount, NULL ; LENDO MAIS 4 BYTES
    mov ebx, offset fileBuffer
    mov eax, [ebx]
    mov ebx, offset image_width
    mov [ebx], eax
    
        ;QUANTIDADE DE BYTES/PIXEL EM UMA LINHA
    xor eax, eax
    MOV eax, image_width
    xor ebx, ebx
    mov ebx, 3
    MUL ebx
    mov image_width_pixels, eax
    

    INVOKE WriteFile, fileHandle02, addr fileBuffer, 4, addr writeCount, NULL ;

    ;5) LENDO 32 BYTES RESTANTES E ESCREVENDO NO ARQUIVO DE SAIDA
    INVOKE ReadFile, fileHandle, addr fileBuffer, 32, addr readCount, NULL ;
    INVOKE WriteFile, fileHandle02, addr fileBuffer, 32, addr writeCount, NULL ;
    

    ;6)LOOP PIXELS
    loop_pixels:
       invoke ReadFile, fileHandle, addr pixelsArray, image_width_pixels , addr readCount, NULL ;
       CMP readCount, 0
       je out_loop

       INVOKE WriteFile, fileHandle02, addr pixelsArray, image_width_pixels, addr writeCount, NULL ;
       jmp loop_pixels

    

   
    out_loop:
        ;APENAS PARA TESTE:
        printf("%d", image_width)
        invoke ExitProcess, 0
end start