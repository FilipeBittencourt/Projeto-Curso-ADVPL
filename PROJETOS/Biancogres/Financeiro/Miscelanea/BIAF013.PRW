#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF013																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 05/01/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina para retorno do numero do convenio do   	 |
| 				|	do banco do brasil por empresa   								 |
| 				|	Utilizado no cnab a pagar												 |
|------------------------------------------------------------|
| OS:			|	0624-14 - Usuário: Gardenia Ghisolfi			 			 |
| OS:			|	2248-14 - Usuário: Alessa Feliciano							 |
|------------------------------------------------------------|
*/

User Function BIAF013()
Local cConvBB := ""

	If SM0->M0_CODIGO == "01"

		cConvBB := "000713112"				
		
	ElseIf SM0->M0_CODIGO == "05"
	
		cConvBB := "000897269"

	ElseIf SM0->M0_CODIGO == "06"
	
		cConvBB := "000122085"
		
	ElseIf SM0->M0_CODIGO == "07"
	
		cConvBB := "000972682"
		
	ElseIf SM0->M0_CODIGO == "12"
	
		cConvBB := "000993892"
		
	ElseIf SM0->M0_CODIGO == "13"
	
		cConvBB := "000994818"
		
	ElseIf SM0->M0_CODIGO == "14"
		
		cConvBB := "000928747"
		
	EndIf		

	If !Empty(cConvBB)
		
			cConvBB += "0126"			
					
	ElseIf SEA->EA_MODELO = "01"
		
		cConvBB := "CCCCCCCCCCCCCCCCC"
		
	Else
		
		cConvBB := "XXXXXXXXXXXXXXXXXX"
		
	EndIf

Return(cConvBB)