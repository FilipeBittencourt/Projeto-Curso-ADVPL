#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBorderoPagar
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para geração de borderos de recebimento, agrupados por regras/banco
@type class
/*/

Class TAFBorderoPagar From LongClassName

	Data oLst // Objeto com a lista titulos para criacao do bordero
	Data cNumBor // Numero do bordero
	Data cIDProc // Identificar do processo
	Data lFIDC
		
	Method New() Constructor
	Method Create()
	Method GetNumBor() // Retorna numero do bordero
	Method GetIdCnab()
	Method CleanRegra(cBordero)
	
EndClass


Method New() Class TAFBorderoPagar
	
	::oLst 		:= Nil
	::cNumBor 	:= ""
	::cIDProc 	:= ""
	::lFIDC		:= .F.	
	
Return()


Method Create() Class TAFBorderoPagar
Local nCount := 1
Local cKey := ""
local cF240TIT
Local oLog := TAFLog():New()
Local bKey := {|nCol| ::oLst:GetItem(nCol):cBanco + ::oLst:GetItem(nCol):cAgencia + ::oLst:GetItem(nCol):cConta + ::oLst:GetItem(nCol):cSubCta + ::oLst:GetItem(nCol):cArqcfg + ::oLst:GetItem(nCol):cArqUser + ::oLst:GetItem(nCol):cAmbiente + ::oLst:GetItem(nCol):cLayout + ::oLst:GetItem(nCol):cModelo + ::oLst:GetItem(nCol):cTpPag + ::oLst:GetItem(nCol):cTpCom}
	
	oLog:cIDProc := ::cIDProc
	oLog:cOperac := "P"
	oLog:cMetodo := "I_BOR"
	
	oLog:Insert()

	Begin Transaction
	
		aSort(::oLst:ToArray(),,,{|x,y| x:cBanco + x:cAgencia + x:cConta + x:cSubCta + x:cArqcfg + x:cArqUser + x:cAmbiente + x:cLayout + x:cModelo + x:cTpPag + x:cTpCom > y:cBanco + y:cAgencia + y:cConta + y:cSubCta + y:cArqcfg + y:cArqUser + y:cAmbiente + y:cLayout + y:cModelo + y:cTpPag + y:cTpCom})
			
		DbSelectArea("SE2")
		
		While nCount <= ::oLst:GetCount()
			
			If Empty(::oLst:GetItem(nCount):cNumBor)
			
				SE2->(DbGoTo(::oLst:GetItem(nCount):nRecNo))
				
				cacheData():set("F240TIT","cMens","")
				
				If U_F240TIT() // Bloqueia o titulo caso tenha PA em aberto (Envia WorkFlow)
						
					If cKey <> Eval(bKey, nCount)
			 				
						::cNumBor := ::GetNumBor()
					
						cKey := Eval(bKey, nCount)
		 
					EndIf
		 	
					::oLst:GetItem(nCount):cNumBor := ::cNumBor
					
					RecLock("SE2", .F.)
					
					 		
				
					SE2->E2_NUMBOR := ::oLst:GetItem(nCount):cNumBor
					SE2->E2_DTBORDE := dDataBase
					SE2->E2_MOVIMEN := dDataBase
					SE2->E2_YCDGREG := ::oLst:GetItem(nCount):cRCB
					SE2->E2_IDCNAB := ::GetIdCnab()
					SE2->E2_PORTADO := ::oLst:GetItem(nCount):cBanco
					
					SE2->(MsUnlock())
				
					oLog:cIDProc := ::cIDProc
					oLog:cOperac := "P"
					oLog:cMetodo := "CP_S_BOR"
					oLog:cTabela := RetSQLName("SE2")
					oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					oLog:cHrFin := Time()
					oLog:cEnvWF := "N"
				
					oLog:Insert()
				
		
					RecLock("SEA", .T.)
				
					SEA->EA_FILIAL := xFilial("SEA")
					SEA->EA_NUMBOR := ::oLst:GetItem(nCount):cNumBor
					SEA->EA_DATABOR := dDataBase
					SEA->EA_PORTADO := ::oLst:GetItem(nCount):cBanco
					SEA->EA_AGEDEP := ::oLst:GetItem(nCount):cAgencia
					SEA->EA_NUMCON := ::oLst:GetItem(nCount):cConta
					SEA->EA_NUM := SE2->E2_NUM
					SEA->EA_PARCELA := SE2->E2_PARCELA
					SEA->EA_PREFIXO := SE2->E2_PREFIXO
					SEA->EA_TIPO := SE2->E2_TIPO
					SEA->EA_CART := "P"
					SEA->EA_SITUACA := ::oLst:GetItem(nCount):cSituacao
					SEA->EA_MODELO := ::oLst:GetItem(nCount):cModelo
					SEA->EA_TIPOPAG := ::oLst:GetItem(nCount):cTpPag
					SEA->EA_FORNECE := ::oLst:GetItem(nCount):cCliFor
					SEA->EA_LOJA := ::oLst:GetItem(nCount):cLoja
					
					SEA->(MsUnlock())
				
					U_F240TBOR() // PROVISORIO
			
				Else

					cF240TIT:=cacheData():get("F240TIT","cMens","")

					::oLst:GetItem(nCount):lValid := .F.
					
					oLog:cIDProc := ::cIDProc
					oLog:cOperac := "P"
					oLog:cMetodo := "CP_TIT_INC"
					oLog:cTabela := RetSQLName("SE2")
					oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					oLog:cHrFin := Time()
					oLog:cRetMen := "Bloqueio Titulo com PA (U_F240TIT))"
					if (!empty(cF240TIT))
						oLog:cRetMen += " "
						oLog:cRetMen += cF240TIT
					endif
					oLog:cEnvWF := "S"
					
					oLog:Insert()
				
				EndIf
			
			Else
			
				oLog:cIDProc := ::cIDProc
				oLog:cOperac := "P"
				oLog:cMetodo := "CP_S_BOR"
				oLog:cTabela := RetSQLName("SE2")
				oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
				oLog:cHrFin := Time()
				oLog:cRetMen := "Reenvio"
				oLog:cEnvWF := "N"
				
				oLog:Insert()
					
			EndIf
					
			nCount++
			
		EndDo()
					
	End Transaction
	
	oLog:cIDProc := ::cIDProc
	oLog:cOperac := "P"
	oLog:cMetodo := "F_BOR"
	oLog:cHrFin := Time()
	
	oLog:Insert()
	
Return()


Method GetNumBor() Class TAFBorderoPagar
Local cRet := ""
Local oObj := Nil

	oObj := TAFNumeroBordero():New()
	
	cRet := oObj:GetNumBorPagar()

Return(cRet)


Method GetIdCnab() Class TAFBorderoPagar
Local cIdCnab := ""
Local cChaveID := ""
Local nOrdCNAB := 13
Local aAreaSE2 := SE2->(GetArea())
Local cLog := ""

	If Empty(SE2->E2_IDCNAB) // So gera outro identificador, caso o titulo ainda nao o tenha

		// Gera identificador do registro CNAB no titulo enviado
		cIdCnab := GetSxENum("SE2", "E2_IDCNAB", "E2_IDCNAB" + cEmpAnt, nOrdCNAB)
		cChaveID := cIdCnab
			
		DbSelectArea("SE2")
		SE2->(DbSetOrder(nOrdCNAB))
		
		While SE2->(MsSeek(cChaveID))
			
			cLog := Replicate("-", 120) + Chr(13)
			
			cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- Geração de IDCNAB"
			cLog += "[Thread: " + AllTrim(cValToChar(ThreadId())) + "]" + Chr(13)
			cLog += "[Empresa: " + cEmpAnt + "]" + Chr(13)
			cLog += "[Filial: " + cFilAnt + "]" + Chr(13)
			cLog += "[Processo: " + ::cIDProc + "]" + Chr(13)
			cLog += "[Bordero: " + AllTrim(::cNumBor) + "]" + Chr(13)
			cLog += "[Id Cnab: "+ AllTrim(cIdCnab) + " já existe na tabela SE2, gerando novo número]" + Chr(13)
			
			cLog += Replicate("-", 120)
			
			ConOut(Chr(13) + cLog)
			
			If __lSx8
				ConfirmSX8()
			EndIf
			
			cIdCnab := GetSxENum("SE2", "E2_IDCNAB", "E2_IDCNAB" + cEmpAnt, nOrdCNAB)
			cChaveID := cIdCnab
			
		EndDo

		ConfirmSx8()
	
	Else
	
		cIdCnab := SE2->E2_IDCNAB
	
	Endif

	RestArea(aAreaSE2)
					
Return(cIdCnab)


Method CleanRegra(cBordero) Class TAFBorderoPagar	
Local aArea := SE2->(GetArea())
Local nIndex := RetOrder("SE2", "E2_FILIAL+E2_NUMBOR")
	
	cBordero := PADR(cBordero, TamSX3("E2_NUMBOR")[1], " ")
	
	DBSelectArea("SE2")
	SE2->(DBSetOrder(nIndex))
	SE2->(DBGoTop())
	
	If ! Empty(cBordero)
	
		If SE2->(DBSeek(xFilial("SE2") + cBordero))
		
			While SE2->(E2_FILIAL + E2_NUMBOR) == xFilial("SE2") + cBordero
			
				RecLock("SE2", .F.)

					SE2->E2_YCDGREG := ""
					SE2->E2_PORTADO := ""
					
				SE2->(MSUnlock())			
				
				SE2->(DBSkip())	
			
			EndDo
			
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return()
