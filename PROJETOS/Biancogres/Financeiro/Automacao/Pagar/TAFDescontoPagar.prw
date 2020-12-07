#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFDescontoPagar
@author Wlysses Cerqueira (Facile)
@since 07/01/2019
@project Automação Financeira
@version 1.0
@description Classe com as regras de desconto titulos a receber
@type class
/*/

Class TAFDescontoPagar From LongClassName
		
	Data cOpc // E=Envio; R=Retorno
	Data oLst // Lista de titulos a analisar
	Data cIDProc // Identificar do processo
	Data oLog // Objeto de Log
			
	Method New() Constructor
	Method Set()
	Method Baixa(oObj)
	Method ExistBaAnt()
	
EndClass


Method New() Class TAFDescontoPagar

	::cOpc := "E"
	::oLst := Nil
	::cIDProc := ""
	::oLog := TAFLog():New()
	
Return()


Method Set() Class TAFDescontoPagar
Local nCount := 0

	For nCount := 1 To ::oLst:GetCount()
					
		If ::cOpc == "E"
			
			If ::oLst:GetItem(nCount):lMRCB // Multiplo ?
			
				::oLst:GetItem(nCount):lValid := .F.
					
			Else
			
				If ! Empty(::oLst:GetItem(nCount):cRCB) .And. ::oLst:GetItem(nCount):lDescTarif .And. ::oLst:GetItem(nCount):nVlrTarifa > 0
				
					::Baixa(@::oLst:GetItem(nCount))
				
				EndIf
							
			EndIf
		
		EndIf
		
	Next nCount
	
Return()


Method ExistBaAnt() class TAFDescontoPagar

	Local cAliasAnt		:= GetNextAlias()
	Local cQuery		:= ""
	Local lRet			:= .F.

	//// E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ
	
	cQuery	+= "SELECT TOTAL=COUNT(*) FROM "+RetSQLName("SE5")+"							"
	cQuery	+= " WHERE 																		"
	cQuery	+= " E5_FILIAL		= '"+cValToChar(xFilial("SE5"))+"'							"
	cQuery	+= " AND E5_TIPODOC	= 'BA'														"
	cQuery	+= " AND E5_PREFIXO	= '"+cValToChar(SE2->E2_PREFIXO)+"'							"
	cQuery	+= " AND E5_NUMERO	= '"+cValToChar(SE2->E2_NUM)+"'								"
	cQuery	+= " AND E5_PARCELA	= '"+cValToChar(SE2->E2_PARCELA)+"'							"
	cQuery	+= " AND E5_TIPO	= '"+cValToChar(SE2->E2_TIPO)+"'							"
	cQuery	+= " AND E5_DATA	= '"+cValToChar(DTOS(SE2->E2_BAIXA))+"'						"
	cQuery	+= " AND E5_CLIFOR	= '"+cValToChar(SE2->E2_FORNECE)+"'							"
	cQuery	+= " AND E5_LOJA	= '"+cValToChar(SE2->E2_LOJA)+"'							"
	cQuery	+= " AND D_E_L_E_T_	= ''														"
	
	TcQuery cQuery New Alias cAliasAnt

	If !(cAliasAnt->(Eof()))
		
		lRet := IIF(cAliasAnt->TOTAL == 1, .T., .F.)
		
	EndIf

	cAliasAnt->(DbCloseArea())

Return lRet

Return 

Method Baixa(oObj) Class TAFDescontoPagar
Local aItens := {}
Local aArea := SE2->(GetArea())
Local cErro := ""

Private lMsErroAuto := .F.

	DBSelectArea("SE2")
	SE2->(DBSetOrder(0))
	SE2->(DBGoTo(oObj:nRecNo))

	DBSelectArea("SE5")
	SE5->(DBSetOrder(2)) // E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ
	
	If !SE2->(Eof()) .And. ( !SE5->(DBseek(xFilial("SE5") + "BA" + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + DTOS(E2_BAIXA) + E2_FORNECE + E2_LOJA))) .Or. (SE2->E2_PREFIXO == 'APF' .And. ::ExistBaAnt()) )
	
		aAdd(aItens, {"E2_FILIAL", SE2->E2_FILIAL, NIL })
		aAdd(aItens, {"E2_PREFIXO", SE2->E2_PREFIXO, NIL })
		aAdd(aItens, {"E2_NUM"	, SE2->E2_NUM	, NIL })
		aAdd(aItens, {"E2_PARCELA", SE2->E2_PARCELA , NIL })
		aAdd(aItens, {"E2_TIPO", SE2->E2_TIPO   , NIL })
		aAdd(aItens, {"E2_FORNECE", SE2->E2_FORNECE, NIL })
		aAdd(aItens, {"E2_LOJA", SE2->E2_LOJA	, NIL })

		//AADD(aItens, {"AUTMOTBX", "", Nil}) // comente para NÃO funcionar
		AADD(aItens, {"AUTMOTBX", "TAR FORNEC", Nil}) // comente para funcionar
		AADD(aItens, {"AUTBANCO", oObj:cBanco, Nil})
		AADD(aItens, {"AUTAGENCIA", oObj:cAgencia, Nil})
		AADD(aItens, {"AUTCONTA", oObj:cConta, Nil})
		AADD(aItens, {"AUTDTBAIXA", dDataBase, Nil})
		//AADD(aItens, {"AUTHIST", cHist070, Nil})
		AADD(aItens, {"AUTVLRPG", oObj:nVlrTarifa, Nil})
	
		SetModulo( "SIGAFIN","FIN" )
		
		AcessaPerg("FIN080", .F.)
		
		MsExecAuto({|x,y| FINA080(x,y)}, aItens, 3) // 3 - Baixa de Título, 5 - Cancelamento de baixa, 6 - Exclusão de Baixa.
				
		If lMsErroAuto
			
			cPath := GetSrvProfString("Startpath", "")
			
			cFileLog := "TAFDescontoPagar" + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"
					
			cErro += MostraErro(cPath, cFileLog)
			
			oObj:lValid := .F.
		
			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_DESC"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := oObj:nRecNo
			::oLog:cHrFin := Time()
			::oLog:cRetMen := cErro
			::oLog:cEnvWF := "S"
			
			::oLog:Insert()
						
		Else
		
			oObj:nValor := SE2->E2_VALOR
			oObj:nSaldo := SE2->E2_SALDO

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_DESC"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := oObj:nRecNo
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa efetuada com sucesso"
			::oLog:cEnvWF := "N"
			
			::oLog:Insert()
			
		EndIf
		
		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] " + cEmpAnt + cFilAnt + " - TAFDescontoPagar - " + oObj:cPrefixo + "-" + oObj:cNumero + "-" + oObj:cParcela + "-" + oObj:cTipo + " - DATE: " + DTOC(Date())+ " TIME: " + Time() + cErro)
	
	EndIf
	
	RestArea(aArea)

Return(!lMsErroAuto)

