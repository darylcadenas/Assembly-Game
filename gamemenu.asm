;Game Main Menu by Daryl Cadenas BSCpE-4A
;Final Project for CPE 412 - Computer Architecture and Organization

.MODEL SMALL
.STACK 200H
.DATA

; GAME MAIN MENU
	MAIN_MENU_TITLE_TEXT db 'CHOOSE YOUR GAME','$'
	GAME1_PONG_TEXT db '1 - Pong','$'
	GAME2_SNAKE_TEXT db '2 - Snake','$'
	EXIT_TEXT db 'X - Exit Game','$'
	CREATOR_TEXT db 'Developed by Daryl Cadenas (c) 2023','$'
	DEVELOPED_TEXT db 'Written in 8086 Assembly Language','$'
	
; PONG GAME
	WINDOW_WIDTH DW 140h                 ;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h                ;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6                   ;variable used to check collisions early
	
	TIME_AUX DB 0                        ;variable used when checking if the time has changed
	GAME_ACTIVE DB 1                     ;is the game active? (1 -> Yes, 0 -> No (game over))
	EXITING_GAME DB 0
	WINNER_INDEX DB 0                    ;the index of the winner (1 -> player one, 2 -> player two)
	CURRENT_SCENE DB 0                   ;the index of the current scene (0 -> main menu, 1 -> game)
	
	TEXT_PLAYER_ONE_POINTS DB '0','$'    							;text with the player one points
	TEXT_PLAYER_TWO_POINTS DB '0','$'    							;text with the player two points
	TEXT_GAME_OVER_TITLE DB 'GAME OVER','$' 						;text with the game over menu title
	TEXT_GAME_OVER_WINNER DB 'Player 0 won','$' 					;text with the winner text
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again','$' 		;text with the game over play again message
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to exit to main menu','$' 	;text with the game over main menu message
	
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' 											;text with the main menu title
	TEXT_MAIN_MENU_SINGLEPLAYER DB 'SINGLEPLAYER - S KEY','$' 							;text with the singleplayer message
	TEXT_MAIN_MENU_MULTIPLAYER DB 'MULTIPLAYER - M KEY','$' 							;text with the multiplayer message
	TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - E KEY','$' 										;text with the exit game message
	TEXT_MAIN_MENU_RULE1 DB 'RULES:','$' 												;text with the rules message
	TEXT_MAIN_MENU_RULE2 DB 'PLAYER 1 - W for UP, S for DOWN','$' 						;text with the player 1 message
	TEXT_MAIN_MENU_RULE3 DB 'PLAYER 2 - O for UP, L for DOWN','$' 						;text with the player 2 message
	TEXT_MAIN_MENU_RULE4 DB 'First to score 5 POINTS is the WINNER!','$' 				;text with the winner rule message
	
	BALL_ORIGINAL_X DW 0A0h   ;X position of the ball on the beginning of a game
	BALL_ORIGINAL_Y DW 64h    ;Y position of the ball on the beginning of a game
	BALL_X DW 0A0h            ;current X position (column) of the ball
	BALL_Y DW 64h             ;current Y position (line) of the ball
	BALL_SIZE DW 06h          ;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h    ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h    ;Y (vertical) velocity of the ball
	
	PADDLE_LEFT_X DW 0Ah      ;current X position of the left paddle
	PADDLE_LEFT_Y DW 55h      ;current Y position of the left paddle
	PLAYER_ONE_POINTS DB 0    ;current points of the left player (player one)
	
	PADDLE_RIGHT_X DW 130h    ;current X position of the right paddle
	PADDLE_RIGHT_Y DW 55h     ;current Y position of the right paddle
	PLAYER_TWO_POINTS DB 0    ;current points of the right player (player two)
	AI_CONTROLLED DB 0		  ;is the right paddle controlled by AI
	
	
	PADDLE_WIDTH DW 06h       ;default paddle width
	PADDLE_HEIGHT DW 25h      ;default paddle height
	PADDLE_VELOCITY DW 0Fh    ;default paddle velocity
	
;SNAKE GAME
	; init
	backgroud_color equ 0Fh 
	player_score_color equ 2Bh
	screen_width equ 80d
	screen_hight equ 25d
	
	; player
	player_score_label_offset equ (screen_hight*screen_width-1d)*2d
	player_score db ?
	player_win_score equ 0FFh
	
	; snake
	; len X 2
	snake_len dw ?
	snake_body dw player_win_score + 3h dup(?)
	
	; for repairing the backgroud(the snake will never start at 25d*80d*2d)
	snake_previous_last_cell dw ?
	
	; snake movement
	; 4D/4B/48/50 - r/l/u/d. defulte - right
	RIGHT equ 4Dh
	LEFT equ 4Bh
	UP equ 48h
	DOWN equ 50h
	snake_direction db ?
	
	; food
	food_location dw ?
	food_color equ 4Dh
	food_icon equ 01h
	food_bounders equ 2d*screen_width*2d
	
	; start and exit
	EXIT db 0h
	START_AGAIN db 0h
	
	; 39h = bios code for the space key
	START_AGAIN_KEY equ 39h
	END_GAME_KEY equ 01h
	
	; messeges
	msg_game_over db 'GAME OVER','$'
	msg_game_over2 db 'PRESS Esc TO EXIT or PRESS SPACE TO START AGAIN','$'
	msg_start_game db 'Controls: UP, DOWN, LEFT, RIGHT','$'
	
	;Ex2q3 write register content
	;initializing ascii array with every possible combenation of ?? 0-F
	ascii db 16 dup ('0') 
	db 16 dup ('1') 
	db 16 dup ('2') 
	db 16 dup ('3') 
	db 16 dup ('4') 
	db 16 dup ('5') 
	db 16 dup ('6') 
	db 16 dup ('7')
	db 16 dup ('8')
	db 16 dup ('9') 
	db 16 dup ('A')
	db 16 dup ('B')
	db 16 dup ('C') 
	db 16 dup ('D')
	db 16 dup ('E') 
	db 16 dup ('F')
	db 16 dup ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F')

.CODE
	MAIN PROC FAR
	MOV AX,@DATA 						;save on the AX register the contents of the DATA segment
	MOV DS,AX							;save on the DS segment the contents of the AX
	
		CALL CLEAR_SCREEN1                ;set initial video mode configurations
	
	MAIN ENDP
	
	GAME_MAIN_MENU PROC NEAR
	
		CALL CLEAR_SCREEN1
		
;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,02h                       ;set row 
		MOV DL,0Ch						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,MAIN_MENU_TITLE_TEXT      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the Pong message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,07h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX, GAME1_PONG_TEXT   		 ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the Snake message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,07h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX, GAME2_SNAKE_TEXT         ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the exit message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ch                       ;set row 
		MOV DL,07h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX, EXIT_TEXT      			 ;give DX a pointer 
		INT 21h                          ;print the string	
		
;		Shows the creator message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,13h                       ;set row 
		MOV DL,02h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX, CREATOR_TEXT      		;give DX a pointer 
		INT 21h                          ;print the string	
		
;		Shows the programming developed message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,16h                       ;set row 
		MOV DL,03h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX, DEVELOPED_TEXT      	;give DX a pointer 
		INT 21h                          ;print the string	
		
		MAIN_MENU_KEY_WAIT:
;       Waits for a key press
			MOV AH,00h
			INT 16h
		
;       Check whick key was pressed
			CMP AL,'X'
			JE QUIT_MAIN_MENU
			CMP AL,'x'
			JE QUIT_MAIN_MENU
			
			CMP AL,'1'
			JE PONG
			
			CMP AL,'2'
			JMP SNAKE
		
			JMP MAIN_MENU_KEY_WAIT
			
	GAME_MAIN_MENU ENDP
	
;/////////////////////////////////////////////////////////////////////;

;Quitting the Game Main Menu
QUIT_MAIN_MENU PROC NEAR         ;goes back to the text mode
		
		MOV AH,00h                   ;set the configuration to video mode
		MOV AL,02h                   ;choose the video mode
		INT 10h    					 ;execute the configuration 

		
		MOV AH,4Ch                   ;terminate program
		INT 21h

QUIT_MAIN_MENU ENDP

;/////////////////////////////////////////////////////////////////////;

;Pong Game	
PONG PROC NEAR

		CALL CLEAR_SCREEN                ;set initial video mode configurations
		
		CHECK_TIME:                      ;time checking loop
			
			CMP EXITING_GAME,01h
			JE START_EXIT_PROCESS
			
			CMP CURRENT_SCENE,00h
			JE SHOW_MAIN_MENU
			
			CMP GAME_ACTIVE,00h
			JE SHOW_GAME_OVER
			
			MOV AH,2Ch 					 ;get the system time
			INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds
			
			CMP DL,TIME_AUX  			 ;is the current time equal to the previous one(TIME_AUX)?
			JE CHECK_TIME    		     ;if it is the same, check again
			
;           If it reaches this point, it's because the time has passed
  
			MOV TIME_AUX,DL              ;update time
			
			CALL CLEAR_SCREEN            ;clear the screen by restarting the video mode
			
			CALL MOVE_BALL               ;move the ball
			CALL DRAW_BALL               ;draw the ball
			
			CALL MOVE_PADDLES            ;move the two paddles (check for pressing of keys)
			CALL DRAW_PADDLES            ;draw the two paddles with the updated positions
			
			CALL DRAW_UI                 ;draw the game User Interface
			
			JMP CHECK_TIME               ;after everything checks time again
			
			SHOW_GAME_OVER:
				CALL DRAW_GAME_OVER_MENU
				JMP CHECK_TIME
				
			SHOW_MAIN_MENU:
				CALL DRAW_MAIN_MENU
				JMP CHECK_TIME
				
			START_EXIT_PROCESS:
				CALL CONCLUDE_EXIT_GAME
				
		RET		
	
	MOVE_BALL PROC NEAR                  ;proccess the movement of the ball
		
;       Move the ball horizontally
		MOV AX,BALL_VELOCITY_X    
		ADD BALL_X,AX                   
		
;       Check if the ball has passed the left boundarie (BALL_X < 0 + WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX                    ;BALL_X is compared with the left boundarie of the screen (0 + WINDOW_BOUNDS)          
		JL GIVE_POINT_TO_PLAYER_TWO      ;if is less, give one point to the player two and reset ball position
		
;       Check if the ball has passed the right boundarie (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX	                ;BALL_X is compared with the right boundarie of the screen (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)  
		JG GIVE_POINT_TO_PLAYER_ONE     ;if is greater, give one point to the player one and reset ball position
		JMP MOVE_BALL_VERTICALLY
		
		GIVE_POINT_TO_PLAYER_ONE:		 ;give one point to the player one and reset ball position
			INC PLAYER_ONE_POINTS       ;increment player one points
			CALL RESET_BALL_POSITION     ;reset ball position to the center of the screen
			
			CALL UPDATE_TEXT_PLAYER_ONE_POINTS ;update the text of the player one points
			
			CMP PLAYER_ONE_POINTS,05h   ;check if this player has reached 5 points
			JGE GAME_OVER                ;if this player points is 5 or more, the game is over
			RET
		
		GIVE_POINT_TO_PLAYER_TWO:        ;give one point to the player two and reset ball position
			INC PLAYER_TWO_POINTS      ;increment player two points
			CALL RESET_BALL_POSITION     ;reset ball position to the center of the screen
			
			CALL UPDATE_TEXT_PLAYER_TWO_POINTS ;update the text of the player two points
			
			CMP PLAYER_TWO_POINTS,05h  ;check if this player has reached 5 points
			JGE GAME_OVER                ;if this player points is 5 or more, the game is over
			RET
			
		GAME_OVER:                       ;someone has reached 5 points
			CMP PLAYER_ONE_POINTS,05h    ;check wich player has 5 or more points
			JNL WINNER_IS_PLAYER_ONE     ;if the player one has not less than 5 points is the winner
			JMP WINNER_IS_PLAYER_TWO     ;if not then player two is the winner
			
			WINNER_IS_PLAYER_ONE:
				MOV WINNER_INDEX,01h     ;update the winner index with the player one index
				JMP CONTINUE_GAME_OVER
			WINNER_IS_PLAYER_TWO:
				MOV WINNER_INDEX,02h     ;update the winner index with the player two index
				JMP CONTINUE_GAME_OVER
				
			CONTINUE_GAME_OVER:
				MOV PLAYER_ONE_POINTS,00h   ;restart player one points
				MOV PLAYER_TWO_POINTS,00h  ;restart player two points
				CALL UPDATE_TEXT_PLAYER_ONE_POINTS
				CALL UPDATE_TEXT_PLAYER_TWO_POINTS
				MOV GAME_ACTIVE,00h            ;stops the game
				RET	

;       Move the ball vertically		
		MOVE_BALL_VERTICALLY:		
			MOV AX,BALL_VELOCITY_Y
			ADD BALL_Y,AX             
		
;       Check if the ball has passed the top boundarie (BALL_Y < 0 + WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y is compared with the top boundarie of the screen (0 + WINDOW_BOUNDS)
		JL NEG_VELOCITY_Y                ;if is less reverve the velocity in Y

;       Check if the ball has passed the bottom boundarie (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y		
		MOV AX,WINDOW_HEIGHT	
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y is compared with the bottom boundarie of the screen (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
		JG NEG_VELOCITY_Y		         ;if is greater reverve the velocity in Y
		
;       Check if the ball is colliding with the right paddle
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_X
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,PADDLE_RIGHT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_Y
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,PADDLE_RIGHT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
;       If it reaches this point, the ball is colliding with the right paddle

		JMP NEG_VELOCITY_X

;       Check if the ball is colliding with the left paddle
		CHECK_COLLISION_WITH_LEFT_PADDLE:
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_X
		JNG EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
		
		MOV AX,PADDLE_LEFT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_Y
		JNG EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
		
		MOV AX,PADDLE_LEFT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
		
;       If it reaches this point, the ball is colliding with the left paddle	

		JMP NEG_VELOCITY_X
		
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y   ;reverse the velocity in Y of the ball (BALL_VELOCITY_Y = - BALL_VELOCITY_Y)
			RET
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X              ;reverses the +--- velocity of the ball
			RET                              
			
		EXIT_COLLISION_CHECK:
			RET
	MOVE_BALL ENDP
	
	MOVE_PADDLES PROC NEAR               ;process movement of the paddles
		
;       Left paddle movement
		
		;check if any key is being pressed (if not check the other paddle)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;ZF = 1, JZ -> Jump If Zero
		
		;check which key is being pressed (AL = ASCII character)
		MOV AH,00h
		INT 16h
		
		;if it is 'w' or 'W' move up
		CMP AL,77h ;'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h ;'W'
		JE MOVE_LEFT_PADDLE_UP
		
		;if it is 's' or 'S' move down
		CMP AL,73h ;'s'
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h ;'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		
;       Right paddle movement
		CHECK_RIGHT_PADDLE_MOVEMENT:
			
			CMP AI_CONTROLLED, 01h
			JE CONTROL_BY_AI
			
;			The paddle is controlled by the user pressing a key
			CHECK_FOR_KEYS:
				;if it is 'o' or 'O' move up
				CMP AL,6Fh ;'o'
				JE MOVE_RIGHT_PADDLE_UP
				CMP AL,4Fh ;'O'
				JE MOVE_RIGHT_PADDLE_UP
				
				;if it is 'l' or 'L' move down
				CMP AL,6Ch ;'l'
				JE MOVE_RIGHT_PADDLE_DOWN
				CMP AL,4Ch ;'L'
				JE MOVE_RIGHT_PADDLE_DOWN
				JMP EXIT_PADDLE_MOVEMENT
		
;		The paddle is controlled by AI		
			CONTROL_BY_AI:
				;check if the ball is above the paddle (BALL_X + BALL_SIZE < PADDLE_RIGHT_Y)
				;if it is move up
				MOV AX, BALL_Y 
				ADD AX, BALL_SIZE
				CMP AX, PADDLE_RIGHT_Y
				JL MOVE_RIGHT_PADDLE_UP
				
				;check if the ball is below the paddle (BALL_Y > PADDLE_RIGHT_Y + PADDLE_HEIGHT)
				;if it is move down
				MOV AX, PADDLE_RIGHT_Y
				ADD AX, PADDLE_HEIGHT
				CMP AX ,BALL_Y
				JL MOVE_RIGHT_PADDLE_DOWN
				
				;if none of the conditions above is true, then don't move the paddle (exit paddle movement)
				JMP EXIT_PADDLE_MOVEMENT
				
			MOVE_RIGHT_PADDLE_UP:
				MOV AX,PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y,AX
				
				MOV AX,WINDOW_BOUNDS
				CMP PADDLE_RIGHT_Y,AX
				JL FIX_PADDLE_RIGHT_TOP_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_TOP_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
			
			MOVE_RIGHT_PADDLE_DOWN:
				MOV AX,PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y,AX
				MOV AX,WINDOW_HEIGHT
				SUB AX,WINDOW_BOUNDS
				SUB AX,PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y,AX
				JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_BOTTOM_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
		
		EXIT_PADDLE_MOVEMENT:
		
			RET
		
	MOVE_PADDLES ENDP
	
	RESET_BALL_POSITION PROC NEAR        ;restart ball position to the original position
		
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		
		NEG BALL_VELOCITY_X
		NEG BALL_VELOCITY_Y
		
		RET
	RESET_BALL_POSITION ENDP
	
	DRAW_BALL PROC NEAR                  
		
		MOV CX,BALL_X                    ;set the initial column (X)
		MOV DX,BALL_Y                    ;set the initial line (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch                   ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			 
			MOV CX,BALL_X 				 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX             		 ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
	DRAW_PADDLES PROC NEAR
		
		MOV CX,PADDLE_LEFT_X 			 ;set the initial column (X)
		MOV DX,PADDLE_LEFT_Y 			 ;set the initial line (Y)
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch 					 ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X 		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
		MOV CX,PADDLE_RIGHT_X 			 ;set the initial column (X)
		MOV DX,PADDLE_RIGHT_Y 			 ;set the initial line (Y)
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch 					 ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     ;DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		RET
	DRAW_PADDLES ENDP
	
	DRAW_UI PROC NEAR
		
;       Draw the points of the left player (player one)
		
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,06h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_PLAYER_ONE_POINTS    ;give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
		INT 21h                          ;print the string 
		
;       Draw the points of the right player (player two)
		
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,1Fh						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_PLAYER_TWO_POINTS    ;give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
		INT 21h                          ;print the string 
		
		RET
	DRAW_UI ENDP
	
	UPDATE_TEXT_PLAYER_ONE_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_ONE_POINTS ;given, for example that P1 -> 2 points => AL,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ASCII)
		;and by subtracting 30h (ASCII to number)
		ADD AL,30h                       ;AL,'2'
		MOV [TEXT_PLAYER_ONE_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_ONE_POINTS ENDP
	
	UPDATE_TEXT_PLAYER_TWO_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_TWO_POINTS ;given, for example that P2 -> 2 points => AL,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ASCII)
		;and by subtracting 30h (ASCII to number)
		ADD AL,30h                       ;AL,'2'
		MOV [TEXT_PLAYER_TWO_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_TWO_POINTS ENDP
	
	DRAW_GAME_OVER_MENU PROC NEAR        ;draw the game over menu
		
		CALL CLEAR_SCREEN                ;clear the screen before displaying the menu

;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_TITLE      ;give DX a pointer 
		INT 21h                          ;print the string

;       Shows the winner
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,06h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		CALL UPDATE_WINNER_TEXT
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_WINNER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the play again message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 

		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_PLAY_AGAIN      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the main menu message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 

		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_MAIN_MENU      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Waits for a key press
		MOV AH,00h
		INT 16h

;       If the key is either 'R' or 'r', restart the game		
		CMP AL,'R'
		JE RESTART_GAME
		CMP AL,'r'
		JE RESTART_GAME
		
;       If the key is either 'E' or 'e', exit to main menu
		CMP AL,'E'
		JE EXIT_TO_MAIN_MENU
		CMP AL,'e'
		JE EXIT_TO_MAIN_MENU
		RET
		
		RESTART_GAME:
			MOV GAME_ACTIVE,01h
			RET
		
		EXIT_TO_MAIN_MENU:
			MOV GAME_ACTIVE,00h
			MOV CURRENT_SCENE,00h
			RET
			
	DRAW_GAME_OVER_MENU ENDP
	
	DRAW_MAIN_MENU PROC NEAR
		
		CALL CLEAR_SCREEN
		
;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_TITLE      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the singleplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,06h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_SINGLEPLAYER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the multiplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_MULTIPLAYER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the exit message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_EXIT      ;give DX a pointer 
		INT 21h                          ;print the string	
		
;       Shows the rules message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Dh                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_RULE1     ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the player 1 rule message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Fh                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_RULE2     ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the player 2 rule message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,10h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_RULE3    ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the winner rule message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,13h                       ;set row 
		MOV DL,01h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_RULE4     ;give DX a pointer 
		INT 21h                          ;print the string
		
		MAIN_MENU_WAIT_FOR_KEY:
;       Waits for a key press
			MOV AH,00h
			INT 16h
		
;       Check whick key was pressed
			CMP AL,'S'
			JE START_SINGLEPLAYER
			CMP AL,'s'
			JE START_SINGLEPLAYER
			CMP AL,'M'
			JE START_MULTIPLAYER
			CMP AL,'m'
			JE START_MULTIPLAYER
			CMP AL,'E'
			JE EXIT_GAME
			CMP AL,'e'
			JE EXIT_GAME
			JMP MAIN_MENU_WAIT_FOR_KEY
			
		START_SINGLEPLAYER:
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE,01h
			MOV AI_CONTROLLED, 01h
			RET
		
		START_MULTIPLAYER:
			MOV CURRENT_SCENE, 01h
			MOV GAME_ACTIVE, 01h
			MOV AI_CONTROLLED, 00h
			RET
		
		EXIT_GAME:
			MOV EXITING_GAME,01h
			RET

	DRAW_MAIN_MENU ENDP
	
	UPDATE_WINNER_TEXT PROC NEAR
		
		MOV AL,WINNER_INDEX              ;if winner index is 1 => AL,1
		ADD AL,30h                       ;AL,31h => AL,'1'
		MOV [TEXT_GAME_OVER_WINNER+7],AL ;update the index in the text with the character
		
		RET
	UPDATE_WINNER_TEXT ENDP
	
	CLEAR_SCREEN PROC NEAR               ;clear the screen by restarting the video mode
	
			MOV AH,00h                   ;set the configuration to video mode
			MOV AL,13h                   ;choose the video mode
			INT 10h    					 ;execute the configuration 
		
			MOV AH,0Bh 					 ;set the configuration
			MOV BH,00h 					 ;to the background color
			MOV BL,00h 					 ;choose black as background color
			INT 10h    					 ;execute the configuration
			
			RET
			
	CLEAR_SCREEN ENDP
	
	CONCLUDE_EXIT_GAME PROC NEAR         ;goes back to the text mode
		
		MOV AH,00h                   ;set the configuration to video mode
		MOV AL,02h                   ;choose the video mode
		INT 10h    					 ;execute the configuration 
		
		MOV AH,4Ch                   ;terminate program
		INT 21h

	CONCLUDE_EXIT_GAME ENDP
	
PONG ENDP

;/////////////////////////////////////////////////////////////////////;
	
SNAKE PROC NEAR

	MAIN3:

	call INIT_GAME
	
	; infinit loop with escape key(esc) and game over or win game options
	MAIN_LOOP:	
		;next frame
		call MOVE_SNAKE
		
		call PRINT_SNAKE	
		
		call CHECK_SNAKE_AET_FOOD
		call CHECK_SNAKE_IN_BORDERS
		call CHECK_SNAKE_NOOSE
		
		call GET_DIRECTION_BY_KEY
		
		call MAIN_LOOP_FRAME_RATE
		
		; if exit is on, end the game and return to OS
		cmp [EXIT],1h
		
		jnz MAIN_LOOP
		
		; start again
		cmp [START_AGAIN],1h
		jz MAIN3
		
		call INIT_SCREEN_BACK_TO_OS
		
		; return to OS
		mov ah,4ch
		int 21h
	
	INIT_GAME proc near

		mov byte ptr [player_score],0h
		mov byte ptr [snake_direction],RIGHT
		mov word ptr [snake_previous_last_cell],screen_width*screen_hight*2d
		mov word ptr [food_location],8d*screen_width*2d + 10d*2d
		mov byte ptr [EXIT],0h
		mov byte ptr [START_AGAIN],0h
		
		call INIT_SCREEN
		call INIT_SNAKE_BODY

		ret
	INIT_GAME endp	

	; if it is, it's GAME OVER. the snake is noose if the head has the same location as one of its body cells
	CHECK_SNAKE_NOOSE proc near
		push si
		push ax
		
		mov ax,snake_body[0h]
		mov si,2h
		CHECK_SNAKE_NOOSE_LOOP:
			; if ax == snake body[si] its game over
			cmp ax,snake_body[si]
			jz CHECK_SNAKE_NOOSE_GAME_OVER
			; next iteration
			add si,2h
			cmp si,snake_len
			jnz CHECK_SNAKE_NOOSE_LOOP

		jmp END_CHECK_SNAKE_NOOSE

	CHECK_SNAKE_NOOSE_GAME_OVER:
		call SNAKE_GAME_OVER
		
	END_CHECK_SNAKE_NOOSE:
		pop ax
		pop si
		ret
	CHECK_SNAKE_NOOSE endp
	
	; for now, N and S(E and W is fine)
	CHECK_SNAKE_IN_BORDERS proc near
	
		push ax
		mov ax,snake_body[0h]
		
		;S
		cmp ax,screen_width*screen_hight*2h
		jb CHECK_SNAKE_IN_BORDERS_VALID

		call SNAKE_GAME_OVER
		
		CHECK_SNAKE_IN_BORDERS_VALID:	
	
			pop ax
			ret
		
	CHECK_SNAKE_IN_BORDERS endp

	CHECK_SNAKE_AET_FOOD proc near
	
		push ax
		push si
		mov ax, snake_body[0h]
		cmp ax,food_location
		jnz END_CHECK_SNAKE_AET_FOOD
		; gemerate new food location
		call GENERATE_RANDOM_FOOD_LOCATION
		; print it to the screen
		mov si,[food_location]
		mov al,food_icon
		mov ah,food_color
		mov es:[si],ax
		; make the snake bigger
		mov ax,[snake_previous_last_cell]
		mov si,[snake_len]
		mov snake_body[si],ax
		add [snake_len],2d
		; add score
		inc byte ptr [player_score]
		call PRINT_PLAYER_SCORE
		
		cmp byte ptr [player_score],player_win_score
		jnz END_CHECK_SNAKE_AET_FOOD
		
		END_CHECK_SNAKE_AET_FOOD:
			pop si
			pop ax
			ret
		
	CHECK_SNAKE_AET_FOOD endp

	GENERATE_RANDOM_FOOD_LOCATION proc near
		push ax
		push dx
		push si
		push bx
		
	GENERATE_RANDOM_FOOD_LOCATIPN_AGAIN:
		; update its location
		; cx:dx number of clock ticks since midnight
		mov ah,0h
		INT 1Ah
		mov ax,dx
		mov dx,cx
		add dx,[snake_len]
		add dx,[snake_len]
		; div 16-bit dx:ax/operant -> dx = mod, ax = result
		mov cx, screen_width*screen_hight*2h - food_bounders
		div cx
		;get rid of the last bit
		and dx,0FFFEh
		add dx, food_bounders/2d
		;check if the food is on the snake
		mov si,0d
		
	GENERATE_RANDOM_FOOD_LOCATION_AGAIN_LOOP:
		mov ax,snake_body[si]
		
		;if the new location is on the snake, start over the whole function
		cmp dx,ax
		jz GENERATE_RANDOM_FOOD_LOCATIPN_AGAIN
		add si,2d
		cmp si,[snake_len]
		jnz GENERATE_RANDOM_FOOD_LOCATION_AGAIN_LOOP
		
		;update food location
		mov [food_location], dx
		
		pop bx
		pop si
		pop dx
		pop ax
		ret
	GENERATE_RANDOM_FOOD_LOCATION endp
	
	MAIN_LOOP_FRAME_RATE proc near
		push ax
		push cx
		push dx
		push bx
		;make the game faster
		mov bx,0h
		mov bl,[player_score]
		mov cl,4d
		shr bx,cl
		;delay cx:dx micro sec (10^-6)
		mov al,0
		mov ah,86h
		mov cx,0000h		
		mov dx,0FFFFh
		sub dx,bx
		int 15h
		
		pop bx
		pop dx
		pop cx
		pop dx
		ret
	MAIN_LOOP_FRAME_RATE endp

	SNAKE_GAME_OVER proc near 
		push dx
		push ax
		push bx
		
		; print game over msg 
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,20h						 ;set column
		INT 10h							 
		
		mov ah, 9h
		lea dx, msg_game_over
		int 21h
		
		; print game over msg2
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Bh                       ;set row 
		MOV DL,0Fh						 ;set column
		INT 10h		
		
		mov ah, 9h
		lea dx, msg_game_over2
		int 21h
		
	GAME_OVER_GET_OTHER_KEY:
		; clear key buffer
		mov ah,0Ch
		int 21h	
		; get key
		mov ax,0h
		mov ah,0h
		int 16h	
		
		cmp ah, END_GAME_KEY
		jz END_GAME_OVER
		
		cmp ah, START_AGAIN_KEY
		jz GAME_OVER_START_AGAIN
		
		jmp GAME_OVER_GET_OTHER_KEY


	GAME_OVER_START_AGAIN:
		mov [START_AGAIN],1h

	END_GAME_OVER:		
		; clear key buffer
		mov ah,0Ch
		int 21h	
		
		mov byte ptr [EXIT],1h
		
		pop bx
		pop ax
		pop dx
		ret
	SNAKE_GAME_OVER endp
	
	MOVE_SNAKE proc near
		push ax
		push bx
		; save snake_previous_last_cell(for backgroud repairing)
		mov bx,snake_len
		mov ax,snake_body[bx - 2d]
		mov [snake_previous_last_cell],ax
		
		mov ax,snake_body[0h]
		call SHR_ARRAY
		; RIGHT
		cmp byte ptr [snake_direction],RIGHT
		jz MOVE_RIGHT
		; LEFT
		cmp byte ptr [snake_direction],LEFT
		jz MOVE_LEFT
		; UP
		cmp byte ptr [snake_direction],UP
		jz MOVE_UP
		; DOWN
		cmp byte ptr [snake_direction],DOWN
		jz MOVE_DOWN

		
		MOVE_RIGHT:
			add ax,2d
			jmp MOVE_TO_DIRECTION
			
		MOVE_LEFT:
			sub ax, 2d
			jmp MOVE_TO_DIRECTION
			
		MOVE_UP:
			sub ax, screen_width*2d
			jmp MOVE_TO_DIRECTION
			
		MOVE_DOWN:
			add ax, screen_width*2d
			jmp MOVE_TO_DIRECTION
			
	MOVE_TO_DIRECTION:
		;add the new head cell
		mov snake_body[0h],ax
		
		pop bx
		pop ax
		ret
	MOVE_SNAKE endp
	
	PRINT_SNAKE proc near
		push ax
		push si
		push bx
		
		;repair the backgroud
		mov bx,[snake_previous_last_cell]
		mov al,0h
		mov ah,backgroud_color
		mov es:[bx],ax
		
		;print head
		mov al,'o'
		mov ah, 10h
		mov bx, snake_body[0d]
		mov es:[bx], ax
		
		;if the snake has no body(only head) - jump to the end of the function
		cmp snake_len,2h
		jz END_PRINT_SNAKE
		
		;print the rest if the snake
		;snake color(body)
		mov al,0h
		mov ah, 10h
		
		mov si,2h
		PRINT_SNAKE_LOOP:
			mov bx, snake_body[si]
			mov es:[bx], ax
			
			;next iteration	
			add si,2h
			cmp si, [snake_len]
			jnz PRINT_SNAKE_LOOP
			
	END_PRINT_SNAKE:	
		pop bx
		pop si
		pop ax
		ret
	PRINT_SNAKE endp

	PRINT_PLAYER_SCORE proc near
		push ax
		push bx
		mov ah,player_score_color
		
		mov bx,0h
		mov bl,[player_score]
		; low
		mov al, ascii[bx + 256d]
		mov es:[player_score_label_offset],ax
		; height
		mov al, ascii[bx]
		mov es:[player_score_label_offset-2d],ax
		; label
		mov al,':'
		mov es:[player_score_label_offset-4d],ax
		
		mov al,'E'
		mov es:[player_score_label_offset-6d],ax
		
		mov al,'R'
		mov es:[player_score_label_offset-8d],ax
		
		mov al,'O'
		mov es:[player_score_label_offset-10d],ax
		
		mov al,'C'
		mov es:[player_score_label_offset-12d],ax
		
		mov al,'S'
		mov es:[player_score_label_offset-14d],ax
		

		pop bx
		pop ax
		ret
		
	PRINT_PLAYER_SCORE endp
	
	INIT_SCREEN proc near
		push ax
		push cx
		push si
		
		; graphics mode
		mov ah,00h
		mov al,13h
		int 10h
		
		; set screen segment 
		mov ax, 0b800h
		mov es, ax
		
		; clear the screen
		mov ax, 03h
		int 10h
		call WRITE_SCREEN_BACKGROUND
		call PRINT_PLAYER_SCORE

		; write the first food
		mov si, [food_location]
		mov al,food_icon
		mov ah,food_color
		mov es:[si],ax
		
		; print start game msg
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,00h                       ;set row 
		MOV DL,00h						 ;set column
		INT 10h	
		
		mov dx, offset msg_start_game
		mov ah, 9h
		int 21h

		; --hide text-cusor--	
		pop si
		pop cx
		pop ax
		ret
	INIT_SCREEN endp

	WRITE_SCREEN_BACKGROUND proc near
		push si
		push ax
		; set backgroud
		mov al,0h
		mov ah,backgroud_color
		mov si,0
	INIT_BACKGROUND_LOOP:
		
		mov es:[si],ax
		
		add si,2d
		cmp si,25d*80d*2d
		jnz INIT_BACKGROUND_LOOP
		
		pop ax
		pop si
		ret
	WRITE_SCREEN_BACKGROUND endp

	INIT_SCREEN_BACK_TO_OS proc near
		push ax
		push bx
		;clear the screen
		mov ax, 03h
		int 10h
		; normal text mode
		mov ah,03h
		mov al,13h
		int 10h

		pop cx
		pop ax
		ret
	INIT_SCREEN_BACK_TO_OS endp

 
	INIT_SNAKE_BODY proc near
		; init snake_body
		mov word ptr snake_body[6d],4d + 3d*screen_width*2d
		mov word ptr snake_body[4d],6d + 3d*screen_width*2d
		mov word ptr snake_body[2d],8d + 3d*screen_width*2d
		mov word ptr snake_body[0d],10d + 3d*screen_width*2d
		
		; sizeX2
		mov word ptr [snake_len],8d

		ret
	INIT_SNAKE_BODY endp
	
	
	; update [direction] accordingly. if there is no new key-event direction will stay the same.
	; ecs will quit the game
	GET_DIRECTION_BY_KEY proc near
		; check for a key storke
		push ax
		push bx
		mov ax, 0h
		mov ah,01h
		int 16h	
		
		; zero flag is on if there was no event
		jz END_GET_DIRECTION_BY_KEY
		
		; esc key
		cmp ah,END_GAME_KEY
		jz GET_DIRECTION_BY_KEY_EXIT_GAME_IS_ON
		
		;if |new direction - old direction| == 3d or 5d it's a valid move(the snake cant turn backward)
		mov bh,ah
		mov bl,[snake_direction]
		sub bh,bl
		cmp bh,3d
		jz GET_DIRECTION_BY_KEY_VALID_MOVE
		cmp bh,5d
		jz GET_DIRECTION_BY_KEY_VALID_MOVE
		neg bh
		cmp bh,3d
		jz GET_DIRECTION_BY_KEY_VALID_MOVE
		cmp bh,5d
		jz GET_DIRECTION_BY_KEY_VALID_MOVE
		
		; invalid move:
		; clear key buffer
		mov ah,0Ch
		int 21h	
		jmp END_GET_DIRECTION_BY_KEY
		
	GET_DIRECTION_BY_KEY_VALID_MOVE:
		mov [snake_direction], ah
		; clear key buffer
		mov ah,0Ch
		int 21h	

		jmp END_GET_DIRECTION_BY_KEY
		
	GET_DIRECTION_BY_KEY_EXIT_GAME_IS_ON:
		mov byte ptr [EXIT], 1h
		; clear key buffer
		mov ah,0Ch
		int 21h	
		
	END_GET_DIRECTION_BY_KEY:
		pop bx
		pop ax
		ret
		
	GET_DIRECTION_BY_KEY endp

	; the last cell overrided
	SHR_ARRAY proc near
		push bx
		push ax
		push si
		
		mov si,[snake_len]
		sub si,2h
		L1:
			mov ax,snake_body[si - 2h]
			mov snake_body[si], ax
			;next iteration
			sub si,2h
			cmp si,0h
			jnz L1
			
			pop si
			pop ax
			pop bx
			ret
	SHR_ARRAY endp 

SNAKE ENDP
	
;/////////////////////////////////////////////////////////////////////;

	CLEAR_SCREEN1 PROC NEAR               ;clear the screen by restarting the video mode
	
		MOV AH,00h                   ;set the configuration to video mode
		MOV AL,13h                   ;choose the video mode
		INT 10h    					 ;execute the configuration 
		
		MOV AH,0Bh 					 ;set the configuration
		MOV BH,00h 					 ;to the background color
		MOV BL,00h 					 ;choose black as background color
		INT 10h    					 ;execute the configuration
			
		RET
			
	CLEAR_SCREEN1 ENDP

END
