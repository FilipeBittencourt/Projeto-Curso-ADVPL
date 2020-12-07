#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF019																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 25/05/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina de cadastro de veiculos  			 					 |
| 				|	Melhorias no processo de carregamento	 					 |
|------------------------------------------------------------|
| OS:			|	XXXX-XX - Usuário: Wanisay William 			 				 |
|------------------------------------------------------------|
*/

User Function BIAF019()
Private bDelete := {|| fDelete() }
Private cDelete := "Eval(bDelete)"
Private bSave := {|| fSave() }
Private cSave := "Eval(bSave)"
Private cString := "DA3"

	fUpdSX()
	
	dbSelectArea(cString)
	dbSetOrder(1)

	AxCadastro(cString, "Cadastro de Veículos", cDelete, cSave)

Return()


Static Function fDelete()
Local lRet := .T.	

Return(lRet)


Static Function fSave()
Local aArea := GetArea()
Local lRet := .T.

	If !Empty(M->DA3_YCODMO)
	
		DbSelectArea("ZCG")
		DbSetOrder(4)
		If ZCG->(DbSeek(xFilial("ZCG") + M->DA3_YDNIT + M->DA3_MARVEI + M->DA3_YCODMO))
			
			If ExistTrigger("C6_PRODUTO")
				
				RunTrigger(1, Nil, Nil, Nil, "DA3_YCODMO")
				
			EndIf
			
		Else
			
			lRet := .F.
			
			MsgStop("Atenção, modelo do veículo inválido, verifique se os campos 'Cod. DNIT', 'Marca' e 'Modelo' estão preenchidos corretamente.")
		
		EndIf
	
	EndIf
	
	RestArea(aArea)
	
Return(lRet)


Static Function fUpdSX()
	
  // Atualiza campos do SX2
	DbSelectArea("SX2")
	DbSetOrder(1)	                  
	If SX2->(FieldPos("X2_SYSOBJ")) > 0
		
		If SX2->(DbSeek("DA3"))
			RecLock('SX2', .F.)
				SX2->X2_SYSOBJ := ""
			MsUnlock()
		EndIf
		
	EndIf

  // Atualiza campos do SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	If SX3->(DbSeek("DA3"))
 		
 		While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "DA3"
 			
 			If AllTrim(SX3->X3_CAMPO) $ "DA3_DESC/DA3_PLACA/DA3_YCARRE/DA3_ESTPLA/DA3_YCODMN/DA3_MUNPLA/DA3_YDNIT/DA3_CAPACN/DA3_CAPACM/DA3_QTDEIX/DA3_TARA/"+;
 				"DA3_VOLMAX/DA3_ALTINT/DA3_LARINT/DA3_COMINT/DA3_MOTORI/DA3_DESCMO/DA3_ATIVO/DA3_FROVEI/DA3_YTRANS/DA3_YNOMTR/DA3_MARVEI/DA3_DESMAR/DA3_ANOMOD/"+;
 				"DA3_ANOFAB/DA3_CHASSI/DA3_RENAVA/DA3_RNTC/DA3_TPROD/DA3_TPCAR" 		 		
 		  
 		  	RecLock("SX3", .F.) 		  	
 		  		SX3->X3_USADO := "€€€€€€€€€€€€€€" 		  	
 		  	SX3->(MsUnlock())
 		 		
 			EndIf
 			
 			SX3->(DbSkip())
 			
 		EndDo
 		
	EndIf

Return()