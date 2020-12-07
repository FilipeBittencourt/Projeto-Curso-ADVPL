#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF019																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 25/05/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina de cadastro de motoristas 			 					 |
| 				|	Melhorias no processo de carregamento	 					 |
|------------------------------------------------------------|
| OS:			|	XXXX-XX - Usuário: Wanisay William 			 				 |
|------------------------------------------------------------|
*/

User Function BIAF020()
Local cVldAlt := ".T." // Validacao para permitir a alteracao.
Local cVldExc := ".T." // Validacao para permitir a exclusao.
Local bNoTTS  := {|| U_BIAF044() }
Private cString := "DA4"

	fUpdSX()
	
	dbSelectArea(cString)
	dbSetOrder(1)   	
	
	AxCadastro(cString, "Cadastro de Motoristas", cVldExc, cVldAlt,,,,, bNoTTS)

Return()


Static Function fUpdSX()
	
  // Atualiza campos do SX2
	DbSelectArea("SX2")
	DbSetOrder(1)	                  
	If SX2->(FieldPos("X2_SYSOBJ")) > 0
		
		If SX2->(DbSeek("DA4"))
			RecLock("SX2", .F.)
				SX2->X2_SYSOBJ := ""
			MsUnlock()
		EndIf
		
	EndIf

	// Atualiza campos do SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	If SX3->(DbSeek("DA4"))
 		
 		While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "DA4"
 			
 			If AllTrim(SX3->X3_CAMPO) $ "DA4_FORNEC/DA4_LOJA/DA4_NOME/DA4_NREDUZ/DA4_END/DA4_BAIRRO/DA4_MUN/DA4_EST/DA4_CEP/DA4_CGC/DA4_TEL/DA4_AJUDA1/"+;
 				"DA4_AJUDA2/DA4_AJUDA3/DA4_NOMFOR/DA4_NUMCNH/DA4_REGCNH/DA4_DTECNH/DA4_DTVCNH/DA4_MUNCNH/DA4_ESTCNH/DA4_CATCNH/DA4_RG/DA4_RGORG/DA4_RGEST/"+;
 				"DA4_BLQMOT/DA4_RGDT/DA4_YMOTBL/DA4_YTEL2/DA4_YNOMR1/DA4_YNOMR2/DA4_YNOMR3/DA4_YTELR1/DA4_YTELR2/DA4_YTELR3/DA4_YOBSR1/DA4_YOBSR2/DA4_YOBSR3"
 		  
 		  	RecLock("SX3", .F.) 		  	
 		  		SX3->X3_USADO := "€€€€€€€€€€€€€€" 		  	
 		  	SX3->(MsUnlock())
 			
 			EndIf
 			
 			SX3->(DbSkip())
 			
 		EndDo
 		
	EndIf

Return()