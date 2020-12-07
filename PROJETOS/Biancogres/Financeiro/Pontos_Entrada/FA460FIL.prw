#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFaturaReceber
@author Wlysses Cerqueira (Facile)
@since 24/01/2019
@project Automação Financeira
@version 1.0
@description Classe responsavel pela criacao de faturas a receber.   
@type class
/*/
Static cVend__ := ""
User Function FA460FIL()

	Local cTitulo	:= " Escolha o vendedor para fatura "
	Local cQuery	:= ""
	Local cRet		:= ""
	Local nW	    := 0
	Local nSit		:= 0
	Local aSit		:= {}
	Local aSelect	:= {}
	Local nElemRet	:= 0
	Local nTamVend	:= TAMSX3("E1_VEND1")[1]
	Local lMultSelect := .T.
	Local l1Elem	:= .F.

	aSit := GetVendTit()

	If Len(aSit) > 1

		If Len(aSit[2]) > 1

			nElemRet := Len(aSit[2])
			
			If AdmOpcoes(@cRet,cTitulo,aSit[2],aSit[1],,,l1Elem,nTamVend,nElemRet,lMultSelect)

				nSit := 1

				For nW := 1 To Len(cRet) Step nTamVend

					If SubSTR(cRet, nW, nTamVend) <> Replicate("*",nTamVend)

						AADD(aSelect, SubSTR(cRet, nW, nTamVend) )

					Endif

					nSit++

				next

				lTodas := Len(aSelect) == Len(aSit)

				If !lTodas

					cQuery := " AND E1_NATUREZ = " + ValToSql(cNatureza)

					cQuery += " AND E1_VEND1 = " + ValToSql(aSelect[1])

					cVend__ := aSelect[1]

				EndIf

			Endif

		ElseIf Len(aSit[2]) > 0

			cVend__ := aSit[1]

		Endif

	Endif

Return(cQuery)

Static Function GetVendTit()

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aRet := {}
	Local cCodVend := ""

	cSQL := " SELECT DISTINCT E1_VEND1, A3_NOME "
	cSQL += " FROM " + RetSqlName("SE1") + " SE1 "

	cSQL += " LEFT JOIN " + RetSqlName("SA3") + " SA3 ON "
	cSQL += " A3_FILIAL	= '" + xFilial("SA3") + "' AND "
	cSQL += " A3_COD 	=  E1_VEND1 AND "
	cSQL += " SA3.D_E_L_E_T_ = ' ' "

	cSQL += " WHERE "
	cSQL += " E1_FILIAL 			= '" + xFilial("SE1") + "' AND "
	cSQL += " E1_CLIENTE BETWEEN 	'"	 + cCliDe   + "' AND '" + cCliAte  + "' AND "
	cSQL += " E1_LOJA BETWEEN 		'"   + cLojaDe  + "' AND '" + cLojaAte + "' AND "
	cSQL += " E1_PREFIXO BETWEEN 	'"	 + cPrefDe  + "' AND '" + cPrefAte + "' AND "
	cSQL += " E1_NUM BETWEEN 		'"   + cNumDe   + "' AND '" + cNumAte  + "' AND "

	If nIntervalo = 1
		cSQL += " E1_EMISSAO BETWEEN '" + DTOS(dData460I) + "' AND '" + DTOS(dData460F) + "' AND "
	Else
		cSQL += " E1_VENCTO BETWEEN '"  + DTOS(dData460I) + "' AND '" + DTOS(dData460F) + "' AND "
	EndIf

	cSQL += " E1_SALDO > 0 AND "
	cSQL += " E1_TIPO NOT IN " + FormatIn(StrTran(StrTran(StrTran(StrTran(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM,',','/'),';','/'),'|','/'),'\','/'), "/") + " AND "
	cSQL += " SE1.D_E_L_E_T_ = ' ' "			

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(EOF())

		aAdd(aRet, If(Empty((cQry)->E1_VEND1), "SEM VENDEDOR", (cQry)->A3_NOME))

		cCodVend += If(Empty((cQry)->E1_VEND1), Space(TAMSX3("E1_VEND1")[1]), (cQry)->E1_VEND1)

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return({cCodVend, aRet})

User Function XF460VEN()
Return(cVend__)