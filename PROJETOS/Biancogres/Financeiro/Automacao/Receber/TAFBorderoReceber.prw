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
	
	Method CleanBorSE1(nSE1RecNo, cStatus, cCodBar)
	Method CleanBordero(cBordero, cPrefixo, cNum, cParcela, cTipo)
	
	Method CheckTrocaPortado()
	
EndClass


Method New() Class TAFBorderoReceber
	
	::oLog := TAFLog():New()
	::oLst := Nil
	::cNumBor := ""
	::cIDProc := ""
	
Return()

Method Create() Class TAFBorderoReceber

	local cBanco			as character
	local cAgencia			as character
	local cConta			as character

	Local nCount			as numeric
	Local cKey				as character
	Local bKey				as block

	Local nSE1RecNo			as numeric

	nCount:=1
	cKey:=""
	bKey:={|nCol| ::oLst:GetItem(nCol):cBanco + ::oLst:GetItem(nCol):cAgencia + ::oLst:GetItem(nCol):cConta }

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_BOR"
	
	::oLog:Insert()

	aSort(::oLst:ToArray(),,,{|x,y| x:cBanco + x:cAgencia + x:cConta > y:cBanco + y:cAgencia + y:cConta})

	Begin Transaction
			
		While nCount <= ::oLst:GetCount()
			
			If Empty(::oLst:GetItem(nCount):cNumBor)
			
				If cKey <> Eval(bKey, nCount)
			 				
					::cNumBor := ::GetNumBor()
					
					cKey := Eval(bKey, nCount)
		 
				EndIf
		 	
				::oLst:GetItem(nCount):cNumBor := ::cNumBor
				
				//::CheckTrocaPortado(nCount)	//Problemas na numeraçao
						
			 	// Analisar o preenchimento do nosso numero neste momento ou no retono da API
			 	If Empty(::oLst:GetItem(nCount):cNumBco)
			 		
			 		::oLst:GetItem(nCount):cNumBco := ::GetNumBco(nCount)
			 		
			 	EndIf		

				cBanco:=::oLst:GetItem(nCount):cBanco
				cAgencia:=::oLst:GetItem(nCount):cAgencia
				cConta:=::oLst:GetItem(nCount):cConta

				DbSelectArea("SE1")
				nSE1Recno:=::oLst:GetItem(nCount):nRecNo
				SE1->(MsGoTo(nSE1Recno))
				
				RecLock("SE1", .F.)
				
					SE1->E1_PORTADO := cBanco
					SE1->E1_AGEDEP  := cAgencia
					SE1->E1_CONTA	:= cConta
					SE1->E1_SITUACA := ::oLst:GetItem(nCount):cSituacao
					SE1->E1_NUMBOR  := ::oLst:GetItem(nCount):cNumBor					
					SE1->E1_NUMBCO  := ::oLst:GetItem(nCount):cNumBco
					
					if (FIDC():isFIDCEnabled())					
						FIDC():setFIDCVar("cBanco",cBanco)
						FIDC():setFIDCVar("cAgencia",cAgencia)
						FIDC():setFIDCVar("cConta",cConta)
						if (FIDC():BCOIsFIDC())
							SE1->E1_YFDCPER:=FIDC():percentualDesconto() 
							SE1->E1_YFDCVAL:=FIDC():calculaDesconto(SE1->E1_VALOR,SE1->E1_VENCTO)
						else
							::oLst:GetItem(nCount):cCHVNFE:=""
						endif
					else
						::oLst:GetItem(nCount):cCHVNFE:=""
					endif

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
				::oLog:nIDTab := nSE1Recno
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

			Else
			
				::oLog:cIDProc := ::cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_S_BOR"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := nSE1Recno
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

Method CheckTrocaPortado(_nI) Class TAFBorderoReceber
	
	Local _lRet 		:= .F.
	Local _aArea		:= SE1->(GetArea())
	Local _cBanco		:= ""
	Local _cAgencia		:= ""
	Local _cConta		:= ""
	Local _cID			:= ""
	Local _cChave		:= ""
	Local _cChaveBa1	:= ""
	Local _cChaveBa2	:= ""
	
	_cBanco				:= ::oLst:GetItem(_nI):cBanco
	_cAgencia			:= ::oLst:GetItem(_nI):cAgencia
	_cConta				:= ::oLst:GetItem(_nI):cConta
	_cID				:= ::oLst:GetItem(_nI):nRecNo
	
	DbSelectArea("SE1")
	SE1->(MsGoTo(_cID))
	
	If (!SE1->(Eof()))
		
		If (!Empty(SE1->E1_PORTADO) .And. !Empty(SE1->E1_AGEDEP) .And. !Empty(SE1->E1_CONTA))
		
			If (;
						AllTrim(_cBanco) 		!= AllTrim(SE1->E1_PORTADO) ;
				.And.	AllTrim(_cAgencia)		!= AllTrim(SE1->E1_AGEDEP) ;
				.And.	AllTrim(_cConta) 		!= AllTrim(SE1->E1_CONTA) ;
			)
				_lRet 		:= .T.
				
				_cChave	:= ""
				_cChave += SE1->E1_PREFIXO
				_cChave += SE1->E1_NUM
				_cChave += SE1->E1_PARCELA
				_cChave += SE1->E1_TIPO
				_cChave += SE1->E1_CLIENTE
				_cChave += SE1->E1_LOJA
				
				_cChaveBa1	:= _cBanco+_cAgencia+_cConta
				_cChaveBa2	:= SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA
				
				ConOut("TAF => TAFBorderoReceber:CheckTrocaPortado - " + cEmpAnt + cFilAnt + " -[Atual: "+_cChaveBa1+" / Anterior: "+_cChaveBa2+"] - DATE: "+DTOC(Date())+" TIME: "+Time())
				ConOut("TAF => TAFBorderoReceber:CheckTrocaPortado - " + cEmpAnt + cFilAnt + " - " + _cChave+" - DATE: "+DTOC(Date())+" TIME: "+Time())
			
			EndIf
			
		EndIf
		
	EndIf
	
	SE1->(RetArea(_aArea))
	
Return _lRet


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

Method CleanBorSE1(nSE1RecNo,cStatus,cCodBar) Class TAFBorderoReceber

	Local aArea 		as array

	local cPadrao		as character

	local cSA1IdxKey	as character

	aArea:=SE1->(GetArea())

	Default cStatus:="0"
	Default cCodBar:=""
	
	SE1->(dbSetOrder(0))
	SE1->(MsGoTo(nSE1RecNo))

	If SE1->(!EOF())
		
		If (cStatus=="2")
			
			if (RecLock("SE1", .F.))
				SE1->E1_CODBAR:=cCodBar
				//0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
				SE1->E1_YSITAPI:=cStatus	 
				//Titulos FIDC nao entram no Fluxo de Caixa
				SE1->E1_FLUXO:="N"
				SE1->(MSUnlock())
			endif

			FIDC():resetFIDCVars()
			if (FIDC():isFIDCEnabled().and.FIDC():getBiaPar("FIDC_CTB_LP_BORDERO_ONLINE",.T.))
				cSA1IdxKey:="A1_FILIAL+A1_COD+A1_LOJA"
				SA1->(dbSetOrder(retOrder("SA1",cSA1IdxKey)))
				if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
					//Contabilizacao FIDC
					cPadrao:=FIDC():getBiaPar("FIDC_LP_BORDERO","FBO")
					if (!empty(cPadrao))
						FIDC():setFIDCVar("lCTBFIDC",.T.)
						FIDC():setFIDCVar("cCTBStack","CleanBorSE1")
						FIDC():setFIDCVar("cPadrao",cPadrao)
						FIDC():setFIDCVar("nSE1RecNo",nSE1RecNo)
						FIDC():setFIDCVar("nSA1RecNo",SA1->(recNo()))
						FIDC():setFIDCVar("cBanco",SE1->E1_PORTADO)
						FIDC():setFIDCVar("cAgencia",SE1->E1_AGEDEP)
						FIDC():setFIDCVar("cConta",SE1->E1_CONTA)
						FIDC():setFIDCVar("lUsaFlag",SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/))
						if (FIDC():getFIDCVar("lUsaFlag",.F.))
							FIDC():setFIDCVar("aFlagCTB",{"E1_LA","S","SE1",nSE1RecNo,0,0,0})
						endif
						FIDC():setFIDCVar("lDiario",(FindFunction("UsaSeqCor").and.UsaSeqCor()))
						if (FIDC():getFIDCVar("lDiario",.F.))
							FIDC():setFIDCVar("aDiario",{"SE1",nSE1RecNo,SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
						endif
						SE1->(FIDC():ctbFIDC(1))
						FIDC():resetFIDCVars()
					endif
				endif
			endif

		Else
		
			if (RecLock("SE1", .F.))
	
				::CleanBordero(SE1->E1_NUMBOR, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		
				SE1->E1_NUMBOR := ""
		
				SE1->E1_DATABOR := STOD("  / /  ")
		
				SE1->E1_CODBAR  := ""
				
				SE1->E1_YSITAPI := cStatus	 //0=Pendente;1=Enviado;2=Retorno com Sucesso;3=Retorno com Erro
				
				SE1->(MSUnlock())
			
			endif
		
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
