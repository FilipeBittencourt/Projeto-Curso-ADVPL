#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBorderoReceber
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para geração de borderos de recebimento, agrupados por regras/banco
@type class
/*/

Class TAFBorderoReceber From LongClassName

	Data oLog // Objeto de log de processamento
	Data oLst // Objeto com a lista titulos para criacao do bordero
	Data cNumBor // Numero do bordero
	Data cIDProc // Identificar do processo
		
	Method New() Constructor
	Method Create()
	Method GetNumBor() // Retorna numero do bordero
	Method GetNumBco(nPos) // Retorna nosso numero
	
	Method CleanBorSE1(nRecno, cStatus, cCodBar)
	Method CleanBordero(cBordero, cPrefixo, cNum, cParcela, cTipo)
	
EndClass


Method New() Class TAFBorderoReceber
	
	::oLog := TAFLog():New()
	::oLst := Nil
	::cNumBor := ""
	::cIDProc := ""
	
Return()

Method Create() Class TAFBorderoReceber

	static lA6YTPINTB	as logical

	local cBanco		as character
	local cAgencia		as character
	local cConta		as character

	Local nCount		as numeric
	Local cKey			as character
	Local bKey			as block

	nCount:=1
	cKey:=""
	bKey:={|nCol| ::oLst:GetItem(nCol):cBanco + ::oLst:GetItem(nCol):cAgencia + ::oLst:GetItem(nCol):cConta }

	DEFAULT lA6YTPINTB:=SA6->(FieldPos("A6_YTPINTB")>0)

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_BOR"
	
	::oLog:Insert()

	Begin Transaction
	
		aSort(::oLst:ToArray(),,,{|x,y| x:cBanco + x:cAgencia + x:cConta > y:cBanco + y:cAgencia + y:cConta})
			
		While nCount <= ::oLst:GetCount()
			
			If Empty(::oLst:GetItem(nCount):cNumBor)
			
				If cKey <> Eval(bKey, nCount)
			 				
					::cNumBor := ::GetNumBor()
					
					cKey := Eval(bKey, nCount)
		 
				EndIf
		 	
				::oLst:GetItem(nCount):cNumBor := ::cNumBor
							
			 	// Analisar o preenchimento do nosso numero neste momento ou no retono da API
			 	If Empty(::oLst:GetItem(nCount):cNumBco)
			 		
			 		::oLst:GetItem(nCount):cNumBco := ::GetNumBco(nCount)
			 		
			 	EndIf		

				cBanco:=::oLst:GetItem(nCount):cBanco
				cAgencia:=::oLst:GetItem(nCount):cAgencia
				cConta:=::oLst:GetItem(nCount):cConta

				DbSelectArea("SE1")
				SE1->(DbGoTo(::oLst:GetItem(nCount):nRecNo))
				
				RecLock("SE1", .F.)
				
					SE1->E1_PORTADO := cBanco
					SE1->E1_AGEDEP  := cAgencia
					SE1->E1_CONTA	:= cConta
					SE1->E1_SITUACA := ::oLst:GetItem(nCount):cSituacao
					SE1->E1_NUMBOR  := ::oLst:GetItem(nCount):cNumBor					
					SE1->E1_NUMBCO  := ::oLst:GetItem(nCount):cNumBco
					
					//solicitação Nadine
					If (AllTrim(::oLst:GetItem(nCount):cBanco) == '021') //apenas banco banestes
						If (Len(AllTrim(::oLst:GetItem(nCount):cNumBco)) == 8)//nosso numero banestes 8 caracteres e sem digito
							_oOBjDVNN		:= TCalculoDVNossoNumero():new()
							SE1->E1_NUMBCO	:= AllTrim(::oLst:GetItem(nCount):cNumBco)+''+_oOBjDVNN:GetDVBanestes(AllTrim(::oLst:GetItem(nCount):cNumBco))
							::oLst:GetItem(nCount):cNumBco := AllTrim(::oLst:GetItem(nCount):cNumBco)+''+_oOBjDVNN:GetDVBanestes(AllTrim(::oLst:GetItem(nCount):cNumBco))
						EndIf
					EndIf
										
					SE1->E1_DATABOR := dDataBase
					SE1->E1_MOVIMEN := dDataBase
					SE1->E1_YCDGREG := ::oLst:GetItem(nCount):cRCB
					
				SE1->(MsUnlock())
				
				::oLog:cIDProc := ::cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_S_BOR"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "N"
				
				::oLog:Insert()				
		
				RecLock("SEA", .T.)
				
					SEA->EA_FILIAL := xFilial("SEA")
					SEA->EA_NUMBOR := ::oLst:GetItem(nCount):cNumBor
					SEA->EA_DATABOR := dDataBase
					SEA->EA_PORTADO := ::oLst:GetItem(nCount):cBanco
					SEA->EA_AGEDEP := ::oLst:GetItem(nCount):cAgencia
					SEA->EA_NUMCON := ::oLst:GetItem(nCount):cConta
					SEA->EA_NUM := SE1->E1_NUM
					SEA->EA_PARCELA := SE1->E1_PARCELA
					SEA->EA_PREFIXO := SE1->E1_PREFIXO
					SEA->EA_TIPO := SE1->E1_TIPO
					SEA->EA_CART := "R"
					SEA->EA_SITUACA := ::oLst:GetItem(nCount):cSituacao
					
				SEA->(MsUnlock())

				if (lA6YTPINTB)
					SA1->(dbSetOrder(retOrder("SA1","A1_FILIAL+A1_COD+A1_LOJA")))
					if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
						//Contabilizacao FIDC
						ctbFIDC(@cBanco,@cAgencia,@cConta)
					endif
				endif

			Else
			
				::oLog:cIDProc := ::cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_S_BOR"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Reenvio"
				::oLog:cEnvWF := "N"
				
				::oLog:Insert()
					
			EndIf
					
			nCount++
			
		EndDo
					
	End Transaction
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_BOR"
	::oLog:cHrFin := Time()
	
	::oLog:Insert()	
	
Return()


Method GetNumBor() Class TAFBorderoReceber
Local cRet := ""
Local oObj := Nil

	oObj := TAFNumeroBordero():New()
	
	cRet := oObj:GetNumBorReceber()

Return(cRet)


Method GetNumBco(nPos) Class TAFBorderoReceber
Local cRet := ""
Local oObj := Nil

	oObj := TAFNossoNumero():New()
	
	oObj:cBanco := ::oLst:GetItem(nPos):cBanco
	oObj:cAgencia := ::oLst:GetItem(nPos):cAgencia
	oObj:cConta := ::oLst:GetItem(nPos):cConta
	oObj:cSubCta := ::oLst:GetItem(nPos):cSubCta
	
	cRet := oObj:Get()
	 
Return(cRet)

Method CleanBorSE1(nRecno, cStatus, cCodBar) Class TAFBorderoReceber

	Local aArea := SE1->(GetArea())
	
	Default cStatus := "0"
	Default cCodBar := ""
	
	SE1->(DbSetOrder(0))
	SE1->(DbGoTo(nRecno))

	If !SE1->(EOF())
		
		If cStatus == "2"
			
			RecLock("SE1", .F.)
				SE1->E1_CODBAR  := cCodBar
				SE1->E1_YSITAPI := cStatus	 //0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
			SE1->(MSUnlock())
			
		Else
		
			RecLock("SE1", .F.)
	
				::CleanBordero(SE1->E1_NUMBOR, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		
				SE1->E1_NUMBOR := ""
		
				SE1->E1_DATABOR := STOD("  / /  ")
		
				SE1->E1_CODBAR  := ""
				
				SE1->E1_YSITAPI := cStatus	 //0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
				
			SE1->(MSUnlock())
		
		EndIf

	EndIf

	RestArea(aArea)

Return()

Method CleanBordero(cBordero, cPrefixo, cNum, cParcela, cTipo) Class TAFBorderoReceber

	Local aAreaSEA := SEA->(GetArea())

	Default cBordero := "" 
	Default cPrefixo := "" 
	Default cNum := "" 
	Default cParcela := "" 
	Default cTipo := "" 

	DBSelectArea("SEA")
	SEA->(DBSetOrder(2))

	If SEA->(DBSeek(xFilial("SEA") + cBordero + "R" + cPrefixo + cNum + cParcela + cTipo))

		RecLock("SEA", .F.)
		SEA->(DBDelete())
		SEA->(MSUnlock())

	EndIf

	RestArea(aAreaSEA)

Return()

static function ctbFIDC(cBanco as character,cAgencia as character,cConta as character)

	/* begin variavais contabilizacao*/
	local aArea		as array
	local aDiario	as array
	local aFlagCTB	as array

	local cLote		as character
	local cFunCTB	as character
	local cPadrao	as character
	local cArquivo	as character
	local cTmpAlias	as character

	local lPadrao	as logical
	local lDigita	as logical
	local lDiario	as logical
	local lUsaFlag	as logical

	local nTotal	as numeric
	local nHdlPrv	as numeric
	local nSA6RECNO	as numeric
	/* end variavais contabilizacao*/

	aArea:=getArea()
	
	begin sequence

		cTmpAlias:=getNextAlias()
		
		beginSQL alias cTmpAlias
			SELECT SA6.R_E_C_N_O_ SA6RECNO
				FROM %table:SA6% SA6
			WHERE SA6.%notDel%
				AND SA6.A6_FILIAL=%xFilial:SA6%
				AND SA6.A6_COD=%exp:cBanco%
				AND SA6.A6_AGENCIA=%exp:cAgencia%
				AND SA6.A6_NUMCON=%exp:cConta%
				AND SA6.A6_YTPINTB='1'
		endSQL

		nSA6RECNO:=0
		while (cTmpAlias)->(!eof())
			nSA6RECNO:=(cTmpAlias)->SA6RECNO
			if (nSA6RECNO>0)
				exit
			endif
			(cTmpAlias)->(dbSkip())
		end while

		(cTmpAlias)->(dbCloseArea())
		
		restArea(aArea)

		if (empty(nSA6RECNO))
			break
		endif

		SA6->(MsGoTo(nSA6RECNO))

		cPadrao:=SuperGetMV("BIA_FIDCLP",.F./*lHelp*/,"U01"/*cPadrao*/) 

		lPadrao:=VerPadrao(cPadrao)

		if (!lPadrao)
			break
		endif
		
		cFunCTB:=SuperGetMV("BIA_FIDCFN",.F./*lHelp*/,"FIDC01"/*cPadrao*/)
		cLote:=SuperGetMV("BIA_FIDCLT",.F./*lHelp*/,"FIDC01"/*cPadrao*/)
		
		cArquivo:=""
		nHdlPrv:=HeadProva(cLote,cFunCTB,SubStr(&("cUsuario"),7,6),@cArquivo)
		
		if (empty(nHdlPrv))
			break
		endif

		if (!(nHdlPrv>0))
			break
		endif

		lUsaFlag:=SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/) 
		if (lUsaFlag) 
			// Armazena em aFlagCTB para atualizar no modulo Contabil 
			aFlagCTB:=array(0)
			aAdd(aFlagCTB,{"E1_LA","S","SE1",SE1->(Recno()),0,0,0})
		endif
		
		lDiario:=(FindFunction("UsaSeqCor").and.UsaSeqCor())
		if (lDiario)
			aDiario:=array(0)
			aAdd(aDiario,{"SE1",SE1->(recno()),SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
		EndIf

		nTotal:=DetProva(nHdlPrv,cPadrao,cFunCTB,cLote,/*nLinha*/,/*lExecuta*/,;
							/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
							/*lPosiciona*/,@aFlagCTB,/*aTabRecOri*/,/*aDadosProva*/)
		
		if (nTotal>0)
			RodaProva(nHdlPrv,nTotal)
			lDigita:=.F.
			cA100Incl(cArquivo,nHdlPrv,3/*nOpcx*/,cLote,lDigita,.F./*lAglut*/,/*cOnLine*/,/*dData*/,/*dReproc*/, @aFlagCTB,/*aDadosProva*/,@aDiario)
		endif
	
	end sequence

	restArea(aArea)

	return
