

name "snake"

org     100h

; salta sobre la sección de datos:
jmp     start

; ------ seccion de los datos  ------

s_size  equ     7

; las coordenadas de la serpiente
; (de la cabeza a la cola)
; el byte inferior es la izquierda, el byte superior
; es la parte superior - [superior, izquierda]
snake dw s_size dup(0)

tail    dw      ?

; constantes de dirección
; (códigos de teclas de la bios):
left    equ     4bh
right   equ     4dh
up      equ     48h
down    equ     50h

; dirección actual de la serpiente:
cur_dir db      right

wait_time dw    0

; mensaje
msg 	db "==== SNAKE GRUPO HAJB====", 0dh,0ah

    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    db "UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG,UMG", 0dh,0ah
    
	db "====================", 0dh,0ah, 0ah
	db "Tecla esc para salir", 0dh,0ah
	db "Tecla Enter para iniciar $" 
	

; ------ seccion de codigo ------

start:

; imprime el mensaje:
mov dx, offset msg
mov ah, 9 
int 21h


; espera por cualquier llave:
mov ah, 00h
int 16h

; ocultar el cursor de texto:
mov     ah, 1
mov     ch, 2bh
mov     cl, 0bh
int     10h           


game_loop:

; === seleccionar la primera página de vídeo
mov     al, 0  ; numero de pagina.
mov     ah, 05h
int     10h

; === mostrar nueva cabeza:
mov     dx, snake[0]

; poner el cursor en dl,dh
mov     ah, 02h
int     10h

; imprimir '*' en el lugar:
mov     al, '*'
mov     ah, 09h
mov     bl, 0eh ; atributos
mov     cx, 1   ; unico char.
int     10h

; === mantener la cola:
mov     ax, snake[s_size * 2 - 2]
mov     tail, ax

call    move_snake


; === oculta la vieja cola
mov     dx, tail

; pone el cursor dl,dh
mov     ah, 02h
int     10h

; imprimir ' ' en el lugar:
mov     al, ' '
mov     ah, 09h
mov     bl, 0eh ; atributo.
mov     cx, 1   ; unico char.
int     10h



check_for_key:

; === comprobar los comandos del jugador:
mov     ah, 01h
int     16h
jz      no_key

mov     ah, 00h
int     16h

cmp     al, 1bh    ; ¿Tecla esc
je      stop_game  ;

mov     cur_dir, ah

no_key:



; === esperar unos momentos aquí:
; obtener el número de ticks del reloj
; (unos 18 por segundo)
; desde la medianoche en cx:dx
mov     ah, 00h
int     1ah
cmp     dx, wait_time
jb      check_for_key
add     dx, 4
mov     wait_time, dx



; === bucle de juego eterno:
jmp     game_loop


stop_game:

; mostrar el cursor de vuelta:
mov     ah, 1
mov     ch, 0bh
mov     cl, 0bh
int     10h

ret

; ------ sección de funciones ------

; Este procedimiento crea la
; animación moviendo todas las partes del cuerpo de la serpiente
; partes del cuerpo un paso hacia la cola,
; la antigua cola desaparece:
; [última parte (cola)]-> se va
; [parte i] -> [parte i+1]
; ....

move_snake proc near

; establecer es al segmento de información de la bios:  
mov     ax, 40h
mov     es, ax

  ; punto di a cola
  mov   di, s_size * 2 - 2
 ; mover todas las partes del cuerpo
  ; (la ultima simplemente desaparece)
  mov   cx, s_size-1
move_array:
  mov   ax, snake[di-2]
  mov   snake[di], ax
  sub   di, 2
  loop  move_array


cmp     cur_dir, left
  je    move_left
cmp     cur_dir, right
  je    move_right
cmp     cur_dir, up
  je    move_up
cmp     cur_dir, down
  je    move_down

jmp     stop_move       ; no tiene direccion.


move_left:
  mov   al, b.snake[0]
  dec   al
  mov   b.snake[0], al
  cmp   al, -1
  jne   stop_move       
  mov   al, es:[4ah]    ; numero de columna.
  dec   al
  mov   b.snake[0], al  ; retorna a la derecha.
  jmp   stop_move

move_right:
  mov   al, b.snake[0]
  inc   al
  mov   b.snake[0], al
  cmp   al, es:[4ah]    ; numero de la columna.   
  jb    stop_move
  mov   b.snake[0], 0   ; retorna a la izquierda.
  jmp   stop_move

move_up:
  mov   al, b.snake[1]
  dec   al
  mov   b.snake[1], al
  cmp   al, -1
  jne   stop_move
  mov   al, es:[84h]    ; número de fila -1.
  mov   b.snake[1], al  ; volver a la parte inferior.
  jmp   stop_move

move_down:
  mov   al, b.snake[1]
  inc   al
  mov   b.snake[1], al
  cmp   al, es:[84h]    ; número de fila -1.
  jbe   stop_move
  mov   b.snake[1], 0   ; volver a la parte superior.
  jmp   stop_move

stop_move:
  ret
move_snake endp


