;Realizar un contador ascendente hasta los dos últimos dígitos de su número 
;de celular en caso de que el valor sea menor a 10 multiplicar por 11 y realizar
;el conteo,  Cuando exista una interrupción por RB0 el contador debe contar en forma 
;descendente desde el mismo número en que se produjo la interrupción. Una vez que se 
;quite la interrupción, el conteo debe volver al mismo número en el que se hizo la interrupción 
;y seguir contando hasta concluir con los dos últimosñ números de su número de celular. 
;Se deberá desplegar en display de ánodo común...

;Observaciones: El código necesita ser corregido, no tiene un limite de conteo, cuando existe
;la interrupción realiza el conteo descendente pero no muestra el cero. El código a un está en proceso!!
;se utiliza la técnica de multiplexación.

;El archivo de simulación es CONTADOR_ASCENDENTE_INTRB0.sim1 se realiza con el software simulide.exe
,que se encuentra en la carpeta SimulIDE_1.1.0-SR0_Win64

		__CONFIG _XT_OSC & _WDTE_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF & _BOREN_OFF
		LIST	P=16F877A
		INCLUDE <P16F877A.INC>
		CBLOCK	0X20
		UNIDAD
		DECENA
		AUX
		CONT1
		CONT2
		AUX2
		ENDC

		#DEFINE	DISPLAY1	PORTA,RA0
		#DEFINE	DISPLAY2	PORTA,RA1
		#DEFINE	BOTON_INT	PORTB,RB0
				ORG		0X00
				GOTO	CONFIGURAR
				ORG		0X04
				GOTO	INT_RB0
CONFIGURAR:
				BSF		STATUS,RP0
				MOVLW	0X06
				MOVWF	ADCON1
				BCF		TRISA,RA0
				BCF		TRISA,RA1
				BCF		TRISA,RA2
				BSF		TRISB,RB0
				CLRF	TRISD
				BSF		OPTION_REG,INTEDG	;FLANCO DE SUBIDA
				BCF		STATUS,RP0
				BSF		INTCON,GIE			;ACTIVA INTERRUPCION GLOBAL
				BSF		INTCON,INTE			;ACTIVA INTERRUPCION EXTERNA RB0
				CLRF	PORTA
				CLRF	PORTD
				CLRF	UNIDAD
				CLRF	DECENA
				MOVLW	.50
				MOVWF	AUX2

MAIN:
				CALL	VISUALIZAR
				CALL	INCREMENTAR
				GOTO	MAIN

INT_RB0:
				BTFSS	BOTON_INT
				GOTO	LIMPIAR
				BSF		PORTA,2
				CALL	DECREMENTAR
				CALL	VISUALIZAR
				GOTO	INT_RB0
LIMPIAR:
				BCF		INTCON,INTF
				BCF		PORTA,2
				MOVLW	.50
				MOVWF	AUX2
				RETFIE
DECREMENTAR:
				DECFSZ	AUX2
				RETURN
			
				MOVLW	.50
				MOVWF	AUX2
				DECFSZ	UNIDAD
				RETURN

				MOVLW	.9
				MOVWF	UNIDAD
				DECFSZ	DECENA,F
				RETURN

				MOVLW	.10
				MOVWF	DECENA
				RETURN
				
				
				

VISUALIZAR:
;UNIDAD
				BSF		DISPLAY1
				BCF		DISPLAY2
				MOVF	UNIDAD,W
				CALL	TABLA_DEC
				MOVWF	PORTD
				CALL	RETARDO_5MS
;DECENA
				BCF		DISPLAY1
				BSF		DISPLAY2
				MOVF	DECENA,W
				CALL	TABLA_DEC
				MOVWF	PORTD
				CALL	RETARDO_5MS
				RETURN
TABLA_DEC:
				ADDWF	PCL,F	;PCL=PCL+W
				RETLW	0X3F	;0
				RETLW	0X06	;1
				RETLW	0X5B	;2
				RETLW	0X4F	;3
				RETLW	0X66	;4
				RETLW	0X6D	;5
				RETLW	0X7D	;6
				RETLW	0X07	;7
				RETLW	0X7F	;8
				RETLW	0X6F	;9	

INCREMENTAR:
				INCF	AUX,F	;AUX=AUX+1
				MOVLW	.50
				SUBWF	AUX,W
				BTFSS	STATUS,Z
				RETURN
;INCREMENTA UNIDAD
				CLRF	AUX
				INCF	UNIDAD,F
				MOVLW	.10
				SUBWF	UNIDAD,W
				BTFSS	STATUS,Z
				RETURN
;INCREMENTA DECENA
				CLRF	UNIDAD
				INCF	DECENA,F
				MOVLW	.10
				SUBWF	DECENA,W
				BTFSS	STATUS,Z
				RETURN
;REINICIA
				CLRF	UNIDAD
				CLRF	DECENA
				CLRF	AUX
				RETURN
				
RETARDO_5MS:
				MOVLW	.32
				MOVWF	CONT2
CICLO2:
				MOVLW	.50
				MOVWF	CONT1
CICLO1:
				DECFSZ	CONT1,F
				GOTO	CICLO1
				DECFSZ	CONT2,F
				GOTO	CICLO2
				RETURN
				END
