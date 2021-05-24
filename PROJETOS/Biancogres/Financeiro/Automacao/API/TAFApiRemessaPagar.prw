#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFApiRemessaPagar
@author Tiago Rossini Coradini
@since 08/10/2018
@project Automação Financeira
@version 1.0
@description Classe para Integracao dos titulos a rceber com a API
@type class
/*/

Class TAFApiRemessaPagar From TAFAbstractClass

	Data cOpcEnv // L=Lote; T=Titulo
	Data cReimpr // N=Nao (incluir novo titulo); S=Sim (reimprimir / segunda via de boleto)
	Data GArqRem
	Data CMovRem
	Data cIDProc // Identificador do Processo		
	Data oApi // Interface da API
	Data cTpAgrup
	
	Method New() Constructor
	Method Send() // Envia tirulos para a API
	Method SendBatch() // Envia lote de titulos
	Method SendSingle() // Envia titulos individualmente
	Method ProcessReturn() // Processa retorno da API
	Method SetRetSE2(oBjTitulo)
	Method CleanBordero(cBordero, cPrefixo, cNum, cParcela, cTipo)
	Method SendBProc(oLstBatch)

EndClass


Method New() Class TAFApiRemessaPagar

	_Super:New()
	
	::cOpcEnv 	:= "L"
	::cReimpr 	:= "N"
	::GArqRem 	:= "N"	
	::CMovRem	:= ""
	::cIDProc	:= ""
	::cTpAgrup	:= ""
	::oApi 		:= TIAFApiRemessa():New()
	::oApi:nOperacao := 2 //pagamento		
Return()


Method Send() Class TAFApiRemessaPagar

	If ::cOpcEnv == "L"

		::SendBatch()

	ElseIf ::cOpcEnv == "T"

		::SendSingle()

	EndIf

Return()


Method SendBatch() Class TAFApiRemessaPagar
	
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
		
	EndDo()

Return()


Method SendBProc(oLstBatch) Class TAFApiRemessaPagar
	
	Local nCount		:= 1
	Local cNumero		:= ""
	Local oBol			:= ArrayList():New()
	Local bValid		:= {|| }
	Local bValidCond	:= {|| __nContArq <= 50}
	Local cChave		:= "" 
	
	If (::cTpAgrup == 'C')
		bValid		:= {|| cChave := ::oLst:GetItem(nCount):cCliFor+ ::oLst:GetItem(nCount):cLoja }
		bValidCond	:= {|| cChave == ::oLst:GetItem(nCount):cCliFor+ ::oLst:GetItem(nCount):cLoja }
	EndIf
	

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
			Eval(bValid)
			
			While nCount <= oLstBatch:GetCount() .And. Eval(bValidCond)

				oBol:Add(oLstBatch:GetItem(nCount))

				CONOUT("********TAFApiRemessaPagar ==>> GERAR ARQUIVO REMESSA : LOOP ARQUIVO "+AllTrim(Str(__nContArq))+" ***********")

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


Method SendSingle() Class TAFApiRemessaPagar
Local nCount := 1
Local oBol := ArrayList():New()

	While nCount <= ::oLst:GetCount()

		oBol:Clear()

		oBol:Add(::oLst:GetItem(nCount))

		oBol:GetItem(1):cNumBor := ""

		::oApi:cReimpr := ::cReimpr

		::oApi:Send(oBol)

		::ProcessReturn()

		nCount++

	EndDo()

Return()


Method ProcessReturn() Class TAFApiRemessaPagar
	
	Local cMsg	:= ""
	Local oLog	:= TAFLog():New()
	Local nW	:= 0
	Local nX	:= 0
	Local lOk	:= .F.

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_RET_LOT"

	::oLog:Insert()
	
	If (::oApi:oRet:Ok)
		For nW := 1 To Len(::oApi:oRet:oRetorno:Titulos)
	
			::oLog:cIDProc := ::cIDProc
			::oLog:cStAPI := "1"
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_RET_OK"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := Val(::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante)
			
			//SE TITULO OK
			//SE CABECALHO OK ou REPROCESSANDO O TITULO (o cabecalho nao interessa )
			If ::oApi:oRet:oRetorno:Titulos[nW]:OK .And. ( ::oApi:oRet:oRetorno:OK .Or. ::oApi:oRet:oRetorno:Titulos[nW]:Reprocessamento )
	
				::SetRetSE2(::oApi:oRet:oRetorno:Titulos[nW], "2")
	
				::oLog:cStAPI	:= "2"
				::oLog:cMetodo	:= "CP_RET_OK"
				::oLog:cEnvWF	:= "N"
	
				::oLog:Insert()
	
				Conout("TAFApiRemessaPagar - SetRetSE2() " + ::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante  + " [OK] " + " - DATE: " + DTOC(Date()) + " TIME: " + Time())
	
			ElseIf !::oApi:oRet:oRetorno:Titulos[nW]:Reprocessamento
	
				::SetRetSE2(::oApi:oRet:oRetorno:Titulos[nW], "3")
				
				::oLog:cStAPI	:= "3"
				::oLog:cMetodo	:= "CP_RET_ER"
				::oLog:cRetMen	:= ::oApi:oRet:oRetorno:Titulos[nW]:Eventos[1]:DescricaoErro
				::oLog:cEnvWF	:= "S"
	
				::oLog:Insert()
	
				Conout("TAFApiRemessaPagar - SetRetSE2() " + ::oApi:oRet:oRetorno:Titulos[nW]:NumeroControleParticipante  + " [ERRO] " + " - DATE: " + DTOC(Date()) + " TIME: " + Time())
	
			EndIf
			
			/*For nX := 1 To Len(::oApi:oRet:oRetorno:Titulos[nW]:Eventos)
			
				::oLog:cRetOri := AllTrim(Str(::oApi:oRet:oRetorno:Titulos[nW]:Eventos[nX]:OrigemRetorno))
	
				::oLog:cRetMen := ::oApi:oRet:oRetorno:Titulos[nW]:Eventos[nX]:DescricaoErro
				
				cMsg += ::oLog:cRetOri + CRLF + ::oLog:cRetMen + CRLF 
				
				lOk := AllTrim(::oApi:oRet:oRetorno:Titulos[nW]:Eventos[nX]:DescricaoErro) == "Registrado com Sucesso" .And. ::oApi:oRet:oRetorno:Titulos[nW]:Eventos[nX]:OrigemRetorno == 2
			
			NExt nX
			
			If ::oApi:oRet:oRetorno:Titulos[nW]:OK
				
				If lOk
				
					::SetRetSE2(::oApi:oRet:oRetorno:Titulos[nW], "2")
				
				EndIf
				
				::oLog:cStAPI := "2"
				::oLog:cMetodo := "CP_RET_OK"
				::oLog:cEnvWF := "N"
				
				::oLog:Insert()
	
			Else
			
				::SetRetSE2(::oApi:oRet:oRetorno:Titulos[nW], "3")
				
				::oLog:cStAPI := "3"
				::oLog:cMetodo := "CP_RET_ER"
				::oLog:cEnvWF := "S"
	
				::oLog:Insert()
	
			EndIf*/
	
		Next nW	
		
	EndIf	
		
	/*If Empty(::oApi:oRet:Mensagem)

		cMsg += "Remessa processada com sucesso!" + CRLF 
	
	Else
	
		cMsg += ::oApi:oRet:Mensagem + CRLF 
		

		cMsg += ::oApi:oRet:RequestJson + CRLF 

	EndIf
	*/
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"	
	::oLog:cMetodo := "F_RET_LOT"
	::oLog:cHrFin := Time()

	::oLog:Insert()

	Conout("TAFApiRemessaPagar - FIM")
	/*If IsBlind()
	
		Conout("Mensagem - [API Facile.Net]" + cMsg)
		
	Else
	
		Conout("Mensagem - [API Facile.Net]" + cMsg)
	
	EndIf
	*/
Return()


Method SetRetSE2(oBjTitulo, cStatus) Class TAFApiRemessaPagar
Local aArea := SE2->(GetArea())

	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(Val(oBjTitulo:NumeroControleParticipante)))

	If !SE2->(Eof())
	
		RecLock("SE2", .F.)
			
			If cStatus == "3"
			
				::CleanBordero(SE2->E2_NUMBOR, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO)
				
				SE2->E2_NUMBOR := ""
				
				SE2->E2_DTBORDE := STOD("  / /  ")
				
			EndIf
			
			SE2->E2_CODBAR := oBjTitulo:CodigoBarras
			SE2->E2_YSITAPI := cStatus	 //0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
			
		SE2->(MSUnlock())
		
	EndIf

	RestArea(aArea)

Return()


Method CleanBordero(cBordero, cPrefixo, cNum, cParcela, cTipo) Class TAFApiRemessaPagar
Local aAreaSEA := SEA->(GetArea())
	
	Default cBordero := "" 
	Default cPrefixo := "" 
	Default cNum := "" 
	Default cParcela := "" 
	Default cTipo := "" 
	
	DBSelectArea("SEA")
	SEA->(DBSetOrder(2))
	
	If SEA->(DBSeek(xFilial("SEA") + cBordero + "P" + cPrefixo + cNum + cParcela + cTipo))
	
		RecLock("SEA", .F.)
		SEA->(DBDelete())
		SEA->(MSUnlock())
		
	EndIf
	
	RestArea(aAreaSEA)

Return()