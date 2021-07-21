#include "PROTHEUS.CH"
#include "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRQCWF01	ºAutor  ³Fernando Rocha      º Data ³ 17/11/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow para enviar produtos pendentes do 6T.		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#DEFINE TIT_MSG "SISTEMA - REQ.PRODUTO COMUM"

User Function FRQCWF01() 

	Local xv_Emps    := U_BAGtEmpr("01_05_14")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		Processa({|| ProcWF()})

		RpcClearEnv()
	Next nI

Return

Static Function ProcWF()

	Local aArea := GetArea() 
	Local cFile
	Local _cDest := U_EmailWF("FRQCWF01",AllTrim(cEmpAnt))
	Local _cTexto   
	Local _cHrBloq		:= GetNewPar("FA_RQCHRB","12:00")  //Horario de bloqueio de baixas no ultimo dia do mes
	Local _lTemReg
	Local _dDia

	//ENVIAR O EMAIL APOS AS 12:00 do ultimo dia util do mes - quando ja estão bloqueadas as baixas de novas requisicoes
	_dDia := dDataBase
	If _dDia == UltimoDU(_dDia) .And. SubStr(Time(),1,5) > AllTrim(_cHrBloq)

		_lTemReg := .T.
		cFile := U_FRQCEXC1(,,,.F.,@_lTemReg) 

		If !_lTemReg
			RestArea(aArea)
			Return
		EndIf   

		_cTexto := "Existem produtos pendentes para baixa no Armazém 6T."+CRLF+;
		"Referente a requisições de produtos comuns entre as empresas do grupo, "+;
		"é necessário gerar o(s) PEDIDO(s) DE VENDA e FATURAR para baixar o estoque e entrar no custo da empresa destino antes do fechamento."

		U_BIAEnvMail(,_cDest,"Produtos Pendentes no Armazém 6T",_cTexto,,cFile)

	EndIf

	RestArea(aArea)
Return

Static Function UltimoDU(_dData)
	Local nDu := 0
	Local dDt

	dDt := LastDate(_dData)
	If DOW(dDt) <> 1 .and. DOW(dDt) <> 7
		Return(dDt)
	Else 
		While DOW(dDt) == 1 .or. DOW(dDt) == 7
			dDt := dDt - 1
		EndDo
	EndIf

return(dDt)                                                                    



