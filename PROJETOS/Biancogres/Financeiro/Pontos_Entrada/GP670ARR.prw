#Include 'Protheus.ch'

/*/{Protheus.doc} GP670ARR
Esse Ponto de entrada deve ser utilizado para adicionar, na integração do titulo, campos criados pelo usuario. 
Ele somente será executado quando estiver sendo efetuada a integraçcao do titulo, se isso não ocorrer 
sera apresentado log com os titulos não integrado.
@type function
@author Pontin
@since 18/07/2018
@version 1.0
/*/
User Function GP670ARR()
	
	Local aDados	:= {}
	
	aDados := {{'E2_HIST' , RC1->RC1_MAT ,Nil}} 

Return aDados

