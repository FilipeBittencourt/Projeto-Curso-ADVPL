#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFApiRemessaReceber
@author Tiago Rossini Coradini
@since 08/10/2018
@project Automação Financeira
@version 1.0
@description Classe para Integracao dos titulos a rceber com a API
@type class
/*/

Class TAFApiRemessaReceber From TAFAbstractClass

Data cOpcEnv // L=Lote; T=Titulo
Data cReimpr // N=Nao (incluir novo titulo); S=Sim (reimprimir / segunda via de boleto)
Data GArqRem // S=Gera arquivo de remessa; N=Nao gera
Data CMovRem
Data cIDProc // Identificador do Processo	
Data oApi // Interface da API
Data cTpAgrup
Method New() Constructor
Method Send() // Envia tirulos para a API
Method SendBatch() // Envia lote de titulos
Method SendBProc(oLstBatch)
Method SendSingle() // Envia titulos individualmente
Method ProcessReturn(oLstBol) // Processa retorno da API

EndClass


Method New() Class TAFApiRemessaReceber

	_Super:New()

	::cOpcEnv := "L"
	::cReimpr := "N"
	::GArqRem := "N"
	::CMovRem := ""
	::cIDProc	:= ""		
	::cTpAgrup	:= ""
	::oApi := TIAFApiRemessa():New()
	::oApi:nOperacao := 1//recebimento	
Return()


Method Send() Class TAFApiRemessaReceber

	If ::cOpcEnv == "L"

		::SendBatch()

	ElseIf ::cOpcEnv == "T"

		::SendSingle()

	EndIf

Return()


Method SendBatch() Class TAFApiRemessaReceber

	Local nCTpCom := 1
	Local cNumero := ""
	Local oBol := ArrayList():New()

	aSort(::oLst:ToArray(),,,{|x,y| x:cTpCom < y:cTpCom })

	While nCTpCom <= ::oLst:GetCount()

		cTipoCom := ::oLst:GetItem(nCTpCom):cTpCom

		While nCTpCom <= ::oLst:GetCount() .And. cTipoCom == ::oLst:GetItem(nCTpCom):cTpCom

			oBol:Add(::oLst:GetItem(nCTpCom))

			cTipoCom := ::oLst:GetItem(nCTpCom):cTpCom

			nCTpCom++

		EndDo()

		//Se e arquivo de remessa
		If ( cTipoCom $ "2#4" ) .Or. ( !Empty(::CMovRem) )

			::GArqRem := "S"

		Else

			::GArqRem := "N"

		EndIf		

		::SendBProc(oBol)

		oBol:Clear()

	EndDo

Return


Method SendBProc(oLstBatch) Class TAFApiRemessaReceber
	Local nCount := 1
	Local cNumero := ""
	Local oBol := ArrayList():New()

	IF (!::GArqRem == "S")

		aSort(oLstBatch:ToArray(),,,{|x,y| x:cCliFor + x:cLoja + x:cPrefixo + x:cNumero + x:cParcela < y:cCliFor + y:cLoja + y:cPrefixo + y:cNumero + y:cParcela })

		While nCount <= oLstBatch:GetCount()

			cNumero := oLstBatch:GetItem(nCount):cNumero

			While nCount <= oLstBatch:GetCount() .And. cNumero == oLstBatch:GetItem(nCount):cNumero

				oBol:Add(oLstBatch:GetItem(nCount))

				cNumero := oLstBatch:GetItem(nCount):cNumero

				nCount++

			EndDo()

			::oApi:cReimpr := ::cReimpr

			::oApi:GArqRem := ::GArqRem

			::oApi:CMovRem := ::CMovRem

			::oApi:Send(oBol)

			::ProcessReturn(oBol)

			oBol:Clear()

			If nCount <= oLstBatch:GetCount()

				cNumero := oLstBatch:GetItem(nCount):cNumero

			EndIf

		EndDo()

	ELSE

		__nContArq := 1

		While nCount <= oLstBatch:GetCount()

			cNumero := oLstBatch:GetItem(nCount):cNumero

			While nCount <= oLstBatch:GetCount() .And. __nContArq <= 50

				oBol:Add(oLstBatch:GetItem(nCount))

				CONOUT("********TAFApiRemessaReceber ==>> GERAR ARQUIVO REMESSA: LOOP ARQUIVO "+AllTrim(Str(__nContArq))+" ***********")

				__nContArq++
				nCount++

			EndDo()

			::oApi:cReimpr := ::cReimpr

			::oApi:GArqRem := ::GArqRem

			::oApi:CMovRem := ::CMovRem

			::oApi:Send(oBol)

			::ProcessReturn(oBol)

			oBol:Clear()

			__nContArq := 1

		EndDo()

	ENDIF

Return()


Method SendSingle() Class TAFApiRemessaReceber
	Local nCount := 1
	Local oBol := ArrayList():New()

	While nCount <= ::oLst:GetCount()

		oBol:Clear()

		oBol:Add(::oLst:GetItem(nCount))

		oBol:GetItem(1):cNumBor := ""

		::oApi:cReimpr := ::cReimpr

		::oApi:Send(oBol)

		::ProcessReturn(oBol)

		nCount++

	EndDo()

Return()


Method ProcessReturn(oLstBol) Class TAFApiRemessaReceber
	Local nW	:= 0
	Local nX	:= 0
	Local nCount := 0
	Local nRecno := 0
	Local oObjBor := TAFBorderoReceber():New()

	Conout("TAFApiRemessaReceber - INICIO")

	Default oLstBol := Nil

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_RET_LOT"

	::oLog:Insert()

	For nW := 1 To Len(::oApi:oRet:oRetorno:Titulos)

		::oLog:cIDProc := ::cIDProc
		::oLog:cStAPI := "1"
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_RET_OK"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := Val(::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante)

		//SE TITULO OK
		//SE CABECALHO OK ou REPROCESSANDO O TITULO (o cabecalho nao interessa )
		If ::oApi:oRet:oRetorno:Titulos[nW]:OK .And. ( ::oApi:oRet:oRetorno:OK .Or. ::oApi:oRet:oRetorno:Titulos[nW]:Reprocessamento )

			oObjBor:CleanBorSE1(Val(::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante), "2", ::oApi:oRet:oRetorno:Titulos[nW]:CodigoBarras)

			::oLog:cStAPI := "2"
			::oLog:cMetodo := "CR_RET_OK"
			::oLog:cEnvWF := "N"

			::oLog:Insert()

			Conout("TAFApiRemessaReceber - CleanBorSE1() " + ::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante  + " [OK] " + " - DATE: " + DTOC(Date()) + " TIME: " + Time())

		ElseIf !::oApi:oRet:oRetorno:Titulos[nW]:Reprocessamento

			oObjBor:CleanBorSE1(Val(::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante), "3")

			::oLog:cStAPI := "3"
			::oLog:cMetodo := "CR_RET_ER"
			::oLog:cRetMen := ::oApi:oRet:oRetorno:Titulos[nW]:Eventos[1]:DescricaoErro
			::oLog:cEnvWF := "S"

			::oLog:Insert()

			Conout("TAFApiRemessaReceber - CleanBorSE1() " + ::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante  + " [ERRO] " + " - DATE: " + DTOC(Date()) + " TIME: " + Time())

		EndIf

	Next nW

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_RET_LOT"
	::oLog:cHrFin := Time()

	::oLog:Insert()

	Conout("TAFApiRemessaReceber - FIM")

Return()