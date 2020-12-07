#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBorderoReceberTroca
@author Wlysses Cerquera
@since 17/04/2019
@project Automação Financeira
@version 1.0
@description Classe com finalidade de regerar borderos para rencio de CNAB com alteracao no JUROS.
@type class
/*/

Class TAFBorderoReceberTroca From LongClassName
	
	Data oPro
	Data oLog
	Data aTitulos
	
	Method New() Constructor

	Method Processa()
	Method GetTitulos()
	Method NovoBordero()
	
EndClass

Method New() Class TAFBorderoReceberTroca
	
	::oLog := TAFLog():New()
	
	::oPro := TAFProcess():New()
	
	::aTitulos := {}
	
Return()

Method Processa() Class TAFBorderoReceberTroca
	
	Begin Transaction
	
	::GetTitulos()
	
	::NovoBordero()
	
	End Transaction
	
Return()

Method NovoBordero() Class TAFBorderoReceberTroca
	
	Local nW := 0
	Local nQuebra := 0
	Local cNumBor := ""
	Local oObj := TAFNumeroBordero():New()	
	Local aAreaSEA := SEA->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	DBSelectArea("SE1")
	SE1->(DBSetOrder(0))
	
	DBSelectArea("SEA")
	SEA->(DBSetOrder(2))

	cNumBor := oObj:GetNumBorReceber()

	::oPro:Start()
			
	For nW := 1 To Len(::aTitulos)
		
		SE1->(DbGoTo(::aTitulos[nW]))

		If !SE1->(EOF())

			If nQuebra > 1000
			
				cNumBor := oObj:GetNumBorReceber()
				
				nQuebra := 0
				
				::oPro:Finish()
				
				::oPro:Start()
			
			Else
				
				nQuebra++
			
			EndIf
				
			SEA->(DBGoTop())
			
			If SEA->(DBSeek(xFilial("SEA") + SE1->(E1_NUMBOR + "R" + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)))
				
				::oLog:cRetMen := "Alterado de " + SE1->E1_NUMBOR + " para " + cNumBor
				
				RecLock("SE1", .F.)
				SE1->E1_NUMBOR := cNumBor					
				SE1->(MsUnlock())
				
				RecLock("SEA", .F.)
				SEA->EA_NUMBOR := cNumBor	
				SEA->(MsUnlock())

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_S_BOR"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := SE1->(Recno())
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "N"
				
				::oLog:Insert()
							
			EndIf
		
		EndIf
	
	Next nW
	
	RestArea(aAreaSE1)
	RestArea(aAreaSEA)
	
Return()

Method GetTitulos() Class TAFBorderoReceberTroca
	
	Local cSQL := ""
	Local cQry := GetNextAlias()
	
	cSQL := " SELECT SE1.R_E_C_N_O_ AS SE1_RECNO
	cSQL += " FROM " + RetSQLName("SE1") + " SE1 ( NOLOCK ) "
	//cSQL += " JOIN APIFINANCEIRO.dbo.Boleto b ( NOLOCK ) on b.UnidadeID = " + If(cEmpAnt + cFilant == "0101", "2", If(cEmpAnt + cFilant == "0501", "9", If(cEmpAnt + cFilant == "0701", "8", "")))
	//cSQL += " AND b.StatusAPIRegistro = 2 and b.CodigoBanco = E1_PORTADO "
	//cSQL += " AND b.NossoNumero = E1_NUMBCO and ValorJurosDia <= 0 "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND SE1.E1_EMISSAO between " + ValToSQL("20181213") + " AND " + "'20181214'"
	cSQL += " AND SE1.E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') "
	cSQL += " AND SE1.E1_YSITAPI <> '4' "
	cSQL += " AND E1_CLIENTE NOT IN " + FormatIn(GetNewPar("MV_YAPICEX", "000481|005885|999999|022551|026423|026308|007871|004536|010083|008615|010064|025633|025634|025704|018410|014395|001042"), "|")
	cSQL += " AND E1_YFORMA NOT IN ('3', '4') "
	cSQL += " AND SE1.E1_SALDO > 0 "
	
	//cSQL += " AND NOT EXISTS (SELECT * FROM dbo.##WSC_BORDERO WHERE ZK2_EMP = " + ValToSQL(cEmpAnt) + " AND ZK2_FIL = " + ValToSQL(cFilAnt) + " AND E1_NUMBOR = BORDERO )"
	
	cSQL += " AND SE1.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		aAdd(::aTitulos, (cQry)->SE1_RECNO)
		
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(::aTitulos)


User Function BAFBOR()

	Local oObj := Nil

	Local lJob := !(Select("SX2") > 0)
	
	If lJob
	
		RpcSetEnv("07", "01") // TROCAR PARA OUTRAS FILIAIS (0101 / 0501 / 0701)
		
	EndIf
	
	oObj := TAFBorderoReceberTroca():New()
	
	oObj:Processa()

	If lJob
	
		RpcClearEnv()
	
	EndIf
	
Return()