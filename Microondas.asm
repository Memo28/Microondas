; Cada vez que presiona el pulsador conectado al pin RA4 incrementa un contador
; visualizado en el centro de la primera línea de la pantalla.
;
; ZONA DE DATOS **********************************************************************

	LIST		P=16F84A
	INCLUDE		<P16F84A.INC>
	__CONFIG	_CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC

	CBLOCK  0x0C
	Contador						; El contador a visualizar.
	ENDC

NUM_CARGA   EQU .0
#DEFINE  Pulsador PORTA,4			; Línea donde se conecta el pulsador.
#DEFINE	 Comienzo PORTA,3
#DEFINE	 motor	   PORTB,0
#DEFINE buzzer	   PORTB,1
; ZONA DE CÓDIGOS ********************************************************************

	ORG	0
Inicio
	call	LCD_Inicializa
	bsf		STATUS,RP0
	clrf TRISB
	bsf		Pulsador				; Línea del pulsador se configura como entrada. 
	bsf		Comienzo
	bcf		STATUS,RP0
	clrf	Contador				; Inicializa contador y los visualiza por 1ª vez,
	call	Visualiza
Principal
	btfss	Pulsador				; Lee el pulsador.
	call	IncrementaVisualiza		; Si pulsa salta a incrementar y visualizar el
					; contador
	btfss Comienzo
	call Activar
	goto	Principal
	
; Subrutina "IncrementaVisualiza" -------------------------------------------------------
;
IncrementaVisualiza
	call	Retardo_20ms			; Espera a que se estabilicen los niveles de tensión.
	btfsc	Pulsador				; Vuelve a leer el pulsador.
	goto	Fin_Incrementa
	incf	Contador,F				; Incrementa el contador y después lo visualiza.
	movf	Contador,0
	movwf	NUM_CARGA
Visualiza
	movlw	.7						; Se sitúa en el centro de la línea 1.
	call	LCD_PosicionLinea1
	movf	NUM_CARGA,W
	call	BIN_a_BCD				; Se debe visualizar en decimal.
	call	LCD_Byte
EsperaDejePulsar
	btfss	Pulsador
	goto	EsperaDejePulsar
Fin_Incrementa
	return
;----------------------------------------------------------------------
Activar
	call	Retardo_20ms			; Espera a que se estabilicen los niveles de tensión.
	btfsc	Comienzo				; Vuelve a leer el pulsador.
	goto	FinActivar
	call Motor
	goto Principal
Motor
	call	LCD_Borra
	bsf motor
	movlw	NUM_CARGA				; Realiza carga inicial.
	movwf	Contador
Visualiza2
	
	call	VisualizaContador		; Visualiza el valor del Contador.
	bsf	motor				; activa motor DC
	call	Retardo_500ms			; Durante este tiempo.
	decfsz	NUM_CARGA,F				; Decrementa el contador hasta llegar a cero.
	goto	Visualiza2				; Si no ha llegado a cero visualiza el siguiente.
	call	VisualizaContador		    ; Ahora también debe visualizar el cero.
	bcf	motor				; desactiva motor DC al llegar a cero
	;call	LCD_Borra				; Borra la pantalla
	bsf buzzer
	call	Retardo_1s				; durante un segundo.
	call	Retardo_1s				; durante un segundo.
	bcf buzzer
	goto	Principal				; Repite el proceso.

EsperaDejePulsar2
	btfss	Comienzo
	goto	EsperaDejePulsar2
FinActivar
	return

	;
; Subrutina "VisualizaContador" ---------------------------------------------------------
;
VisualizaContador
	movlw	.7						; Se sitúa en el centro de la línea 1.
	call	LCD_PosicionLinea1
	movf	NUM_CARGA,W				; Lo pasa a BCD.
	call	BIN_a_BCD
	call	LCD_Byte				; Visualiza el dato númerico.
	return
	INCLUDE  <RETARDOS.INC>
	INCLUDE  <BIN_BCD.INC>
	INCLUDE  <LCD_4BIT.INC>
	END


