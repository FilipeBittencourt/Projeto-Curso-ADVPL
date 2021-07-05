#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA496A    ³ Autor ³ Wanisay William       ³ Data ³ 22.05.12      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia o estoque da consulta F6 para os representantes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} BIA496A
@description Envia workflow de estoque disponivel para os representantes
@author NDA
@since 22/05/12
@version 1.0
@type function
/*/

// U_BIA496A

User Function BIA496A()
	Local aEmp := {}
	Local aArea := {}
	Local nCount := 1
	Local cSql := ''
	Local cQry := GetNextAlias()

	aAdd(aEmp, "01")
	aAdd(aEmp, "05")
	aAdd(aEmp, "13")
	aAdd(aEmp, "07")

	 /*	
	If U_GETBIAPAR("REP_BLQREST",.F.)
              Conout("Consulta temporariamente indispon?el","BIA496")
                RpcClearEnv()
             Exit
	EndIf
      */
	//For nCount := 1 To Len(aEmp)

	RpcSetType(3)
	RpcSetEnv(aEmp[nCount], "01")
	aArea := SA3->(GetArea())
	DbSelectArea("SA3")

	cSql :=" select  SA3.A3_YEMP, SA3.A3_COD FROM "+RetFullname("SA3",aEmp[nCount])+" as SA3 " +CRLF
	cSql +=" WHERE 0=0 " +CRLF
	cSql +="  AND SA3.A3_EMAIL <> '' " +CRLF
	cSql +="  AND SA3.A3_YATIVO = 'S' " +CRLF
	cSql +="  AND SA3.A3_YEMP  NOT LIKE '%XX%' " +CRLF
	cSql +="  AND SA3.D_E_L_E_T_ = '' " +CRLF

	TcQuery cSql Alias (cQry) New
	SA3->(DbSetOrder(1))
	(cQry)->(DbGoTop())

	While !(cQry)->(Eof())

		IF SA3->(DBSeek(FWXFilial("SA3")+(cQry)->(A3_COD)))

			CREPATU := (cQry)->(A3_COD)

			U_BIA496(aEmp[nCount])

			If (aEmp[nCount] != '07') // Envia WF de estoque de Amostra
				U_BIA496(aEmp[nCount], .T.)
			EndIf

		EndIf

		(cQry)->(DbSkip())

	EndDo

	RpcClearEnv()

//	Next
	RestArea(aArea)

Return()
