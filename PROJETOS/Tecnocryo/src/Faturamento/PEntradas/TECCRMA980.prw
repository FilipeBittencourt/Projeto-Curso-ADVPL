#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include 'totvs.ch'
function u_MA030ROT() 

	Local _aRot := {}

	//	ADD OPTION _aRot TITLE 'Locações' ACTION "MsgRun('Aguarde processando locações...','Central de Locações', {|| u_FAT8Central() })" OPERATION 2 ACCESS 0
	AADD(_aRot, {"Locações", "u_FAT8Central"	, 0, 6, 0, Nil } )

return _aRot

//User Function CRMA980()
//
//	Local aParam 	:= PARAMIXB
//	Local xRet 		:= .T.
//	Local oObj 		:= ""
//	Local cIdPonto 	:= ""
//	Local cIdModel 	:= ""
//	Local lIsGrid 	:= .F.
//	Local nLinha 	:= 0
//	Local nQtdLinhas:= 0
//	Local cMsg 		:= ""
//
//	If aParam <> NIL
//
//		oObj 		:= aParam[1]
//		cIdPonto 	:= aParam[2]
//		cIdModel 	:= aParam[3]
//		lIsGrid 	:= (Len(aParam) > 3)
//
//		//		If cIdPonto == "MODELPOS"
//		//			cMsg := "Chamada na validação total do modelo." + CRLF
//		//			cMsg += "ID " + cIdModel + CRLF
//		//
//		//			xRet := ApMsgYesNo(cMsg + "Continua?")
//
//		//		ElseIf cIdPonto == "FORMPOS"
//		//			cMsg := "Chamada na validação total do formulário." + CRLF
//		//			cMsg += "ID " + cIdModel + CRLF
//		//
//		//			If lIsGrid
//		//				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
//		//				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
//		//			Else
//		//				cMsg += "É um FORMFIELD" + CRLF
//		//			EndIf
//		//
//		//			xRet := ApMsgYesNo(cMsg + "Continua?")
//
//		//		ElseIf cIdPonto == "FORMLINEPRE"
//
//		//			If aParam[5] == "DELETE"
//		//				cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
//		//				cMsg += "Onde esta se tentando deletar a linha" + CRLF
//		//				cMsg += "ID " + cIdModel + CRLF
//		//				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
//		//				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
//		//				xRet := ApMsgYesNo(cMsg + " Continua?")
//		//			EndIf
//
//		//		ElseIf cIdPonto == "FORMLINEPOS"
//
//		//			cMsg := "Chamada na validação da linha do formulário." + CRLF
//		//			cMsg += "ID " + cIdModel + CRLF
//		//			cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
//		//			cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
//		//			xRet := ApMsgYesNo(cMsg + " Continua?")
//
//		//		ElseIf cIdPonto == "MODELCOMMITTTS"
//		//			ApMsgInfo("Chamada após a gravação total do modelo e dentro da transação.")
//
//		//		ElseIf cIdPonto == "MODELCOMMITNTTS"
//		//			ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")
//
//		//		ElseIf cIdPonto == "FORMCOMMITTTSPRE"
//		//			ApMsgInfo("Chamada após a gravação da tabela do formulário.")
//
//		//		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
//		//			ApMsgInfo("Chamada após a gravação da tabela do formulário.")
//
//		//		ElseIf cIdPonto == "MODELCANCEL"
//		//			cMsg := "Deseja realmente sair?"
//		//			xRet := ApMsgYesNo(cMsg)
//
//		If cIdPonto == "BUTTONBAR"
//			xRet := { {"Locações", "ANALITIC", { || u_FAT8Central() }}}
//		EndIf
//
//	EndIf
//
//Return xRet


User Function CRM980MDef()
	Local aRotina := {}
	//----------------------------------------------------------------------------------------------------------
	// [n][1] - Nome da Funcionalidade
	// [n][2] - Função de Usuário
	// [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
	// [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
	//----------------------------------------------------------------------------------------------------------
	aAdd(aRotina,{"Locações","u_FAT8Central",MODEL_OPERATION_VIEW,0})
Return( aRotina )