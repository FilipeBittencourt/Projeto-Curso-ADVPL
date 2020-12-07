#include "rwmake.ch"
#include "topconn.ch"

User Function MA103F4I() 

Local aVetor2 := {}    

//aVetor2 := {SUBSTR(DTOS(SC7->C7_YDATCHE),7,2)+"/"+SUBSTR(DTOS(SC7->C7_YDATCHE),5,2)+"/"+SUBSTR(DTOS(SC7->C7_YDATCHE),3,2)}    
IF SC7->C7_ORIGEM == '1'  
	aVetor2 := {SC7->C7_DATPRF,SC7->C7_LOCAL}   	
ELSE 	                           
	aVetor2 := {SC7->C7_YDATCHE,SC7->C7_LOCAL,SC7->C7_PRECO}   
ENDIF

DbSelectArea("SC7")

Return(aVetor2)