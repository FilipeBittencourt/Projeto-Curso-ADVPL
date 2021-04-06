#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIACMGMR
@author Pedro - Facile
@since 17/06/20
@version 1.0
@description Cria sequência para GMRResponsável por criar uma nova sequência para carga GMR de uma determinada revisão orçamentária
@obs Responsável por criar uma nova sequência para carga GMR de uma determinada revisão orçamentária
@type function
/*/

User Function BIACMGMR()

	Private cVersao			:= SPACE(TAMSX3("ZBM_VERSAO")[1]) 
	Private cRevisa			:= SPACE(TAMSX3("ZBM_REVISA")[1])
	Private cAno			:= SPACE(TAMSX3("ZBM_ANOREF")[1]) 

	Filtrar()

Return 

Static Function Filtrar()

	Local nPos				:= 0
	Private aPergs			:= {}
	Private cRefPer		  	:= 'BIACMGMR' + cEmpAnt
	Private cFileName    	:= __cUserID +"_"+ cRefPer
	Private aRetPerg		:= {"","",""}

	aAdd( aPergs ,{1, "Versão:"					,cVersao  ,"","U_BIAFUGMR('1')","ZB5",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Revisao:"				,cRevisa  ,"","U_BIAFUGMR('1')","",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Ano:"					,cAno     ,"","U_BIAFUGMR('1')","",'.T.',50,.T.})

	If !ParamBox(aPergs ,"Filtro - Copiar meta GMR", aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nPos	:= 1
	cVersao	:= ParamLoad(cFileName,,nPos++ 	, cVersao)
	cRevisa	:= ParamLoad(cFileName,,nPos++ 	, cRevisa)
	cAno	:= ParamLoad(cFileName,,nPos++ 	, cAno)

	ProcDados()

Return 

Static Function ProcDados()

	Local cAliasTmp			:= GetNextAlias()
	Local cProxSeque		:= "001"
	Local cQuery			:= ""

	cQuery := " SELECT SEQUENCIA=(REPLICATE('0', 3 - LEN(MAX(ZBM_SEQUEN)+1)) + RTrim(MAX(ZBM_SEQUEN)+1)) FROM " + RetSqlName("ZBM") + " where D_E_L_E_T_ = ''	"

	TcQuery cQuery New Alias (cAliasTmp)

	If !(cAliasTmp)->(Eof()) 
		cProxSeque := (cAliasTmp)->SEQUENCIA
	EndIf

	(cAliasTmp)->(DbCloseArea())

	If (MSGYESNO("Deseja gerar uma nova sequência para transfêrencia de GMR?", "" ))

		U_BIAMsgRun("Aguarde... Copiando registros...",, {|| ExecCopia(cProxSeque) })

	EndIf

Return

Static Function ExecCopia(cProxSeque)

	Local cQuery	:= ""
	Local nStatus	:= 0

	cQuery += " INSERT INTO " + RetSqlName("ZBM") + "																						"			
	cQuery += " (ZBM_FILIAL, ZBM_VERSAO,                                                                                                    "
	cQuery += " ZBM_REVISA,                                                                                                                 "
	cQuery += " ZBM_ANOREF,                                                                                                                 "
	cQuery += " ZBM_PERIOD,                                                                                                                 "
	cQuery += " ZBM_MARCA,                                                                                                                  "
	cQuery += " ZBM_CANALD,                                                                                                                 "
	cQuery += " ZBM_VEND,                                                                                                                   "
	cQuery += " ZBM_GRPCLI,                                                                                                                 "
	cQuery += " ZBM_TPSEG,                                                                                                                  "
	cQuery += " ZBM_ESTADO,                                                                                                                 "
	cQuery += " ZBM_PCTGMR,                                                                                                                 "
	cQuery += " ZBM_FORMAT,                                                                                                                 "
	cQuery += " ZBM_CATEG,                                                                                                                  "
	cQuery += " ZBM_QUANT,                                                                                                                  "
	cQuery += " ZBM_VALOR,                                                                                                                  "
	cQuery += " ZBM_TOTAL,                                                                                                                  "
	cQuery += " ZBM_USER,                                                                                                                   "
	cQuery += " ZBM_DTPROC,                                                                                                                 "
	cQuery += " ZBM_HRPROC,                                                                                                                 "
	cQuery += " ZBM_PCOMIS,                                                                                                                 "
	cQuery += " ZBM_VCOMIS,                                                                                                                 "
	cQuery += " ZBM_PICMS,                                                                                                                  "
	cQuery += " ZBM_VICMS,                                                                                                                  "
	cQuery += " ZBM_PPIS,                                                                                                                   "
	cQuery += " ZBM_VPIS,                                                                                                                   "
	cQuery += " ZBM_PCOF,                                                                                                                   "
	cQuery += " ZBM_VCOF,                                                                                                                   "
	cQuery += " ZBM_PST,                                                                                                                    "
	cQuery += " ZBM_VST,                                                                                                                    "
	cQuery += " ZBM_PDIFAL,                                                                                                                 "
	cQuery += " ZBM_VDIFAL,                                                                                                                 "
	cQuery += " ZBM_ORIGF,                                                                                                                  "
	cQuery += " D_E_L_E_T_,                                                                                                                 "
	cQuery += " R_E_C_N_O_,                                                                                                                 "
	cQuery += " R_E_C_D_E_L_,                                                                                                               "
	cQuery += " ZBM_LINHAA,                                                                                                                 "
	cQuery += " ZBM_FILEIN,                                                                                                                 "
	cQuery += " ZBM_TIPO2,                                                                                                                  "
	cQuery += " ZBM_CLASSE,                                                                                                                 "
	cQuery += " ZBM_PRZMET,                                                                                                                 "
	cQuery += " ZBM_METVER,                                                                                                                 "
	cQuery += " ZBM_PERVER,                                                                                                                 "
	cQuery += " ZBM_PERBON,                                                                                                                 "
	cQuery += " ZBM_VALVER,                                                                                                                 "
	cQuery += " ZBM_VALBON,                                                                                                                 "
	cQuery += " ZBM_PERCPV,                                                                                                                 "
	cQuery += " ZBM_VALCPV,                                                                                                                 "
	cQuery += " ZBM_PICMBO,                                                                                                                 "
	cQuery += " ZBM_VICMBO,                                                                                                                 "
	cQuery += " ZBM_MODAO,                                                                                                                  "
	cQuery += " ZBM_MODCF,                                                                                                                  "
	cQuery += " ZBM_MOINVE,                                                                                                                 "
	cQuery += " ZBM_MOICMS,                                                                                                                 "
	cQuery += " ZBM_MODCVF,                                                                                                                 "
	cQuery += " ZBM_MODCVC,	                                                                                                                "
	cQuery += " ZBM_ATIVO,	                                                                                                                "
	cQuery += " ZBM_SEQUEN	                                                                                                                "
	cQuery += " )                                                                                                                           "
	cQuery += "                                                                                                                             "
	cQuery += " SELECT  ZBM_FILIAL, ZBM_VERSAO, 		                                                                               	    "
	cQuery += " ZBM_REVISA,                                                                                                                 "
	cQuery += " ZBM_ANOREF,                                                                                                                 "
	cQuery += " ZBM_PERIOD,                                                                                                                 "
	cQuery += " ZBM_MARCA,                                                                                                                  "
	cQuery += " ZBM_CANALD,                                                                                                                 "
	cQuery += " ZBM_VEND,                                                                                                                   "
	cQuery += " ZBM_GRPCLI,                                                                                                                 "
	cQuery += " ZBM_TPSEG,                                                                                                                  "
	cQuery += " ZBM_ESTADO,                                                                                                                 "
	cQuery += " ZBM_PCTGMR,                                                                                                                 "
	cQuery += " ZBM_FORMAT,                                                                                                                 "
	cQuery += " ZBM_CATEG,                                                                                                                  "
	cQuery += " ZBM_QUANT,                                                                                                                  "
	cQuery += " ZBM_VALOR,                                                                                                                  "
	cQuery += " ZBM_TOTAL,                                                                                                                  "
	cQuery += " ZBM_USER,                                                                                                                   "
	cQuery += " ZBM_DTPROC,                                                                                                                 "
	cQuery += " ZBM_HRPROC,                                                                                                                 "
	cQuery += " ZBM_PCOMIS,                                                                                                                 "
	cQuery += " ZBM_VCOMIS,                                                                                                                 "
	cQuery += " ZBM_PICMS,                                                                                                                  "
	cQuery += " ZBM_VICMS,                                                                                                                  "
	cQuery += " ZBM_PPIS,                                                                                                                   "
	cQuery += " ZBM_VPIS,                                                                                                                   "
	cQuery += " ZBM_PCOF,                                                                                                                   "
	cQuery += " ZBM_VCOF,                                                                                                                   "
	cQuery += " ZBM_PST,                                                                                                                    "
	cQuery += " ZBM_VST,                                                                                                                    "
	cQuery += " ZBM_PDIFAL,                                                                                                                 "
	cQuery += " ZBM_VDIFAL,                                                                                                                 "
	cQuery += " ZBM_ORIGF,                                                                                                                  "
	cQuery += " D_E_L_E_T_,                                                                                                                 "
	cQuery += "  (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("ZBM") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_,	        "
	cQuery += " R_E_C_D_E_L_,                                                                                                               "
	cQuery += " ZBM_LINHAA,                                                                                                                 "
	cQuery += " ZBM_FILEIN,                                                                                                                 "
	cQuery += " ZBM_TIPO2,                                                                                                                  "
	cQuery += " ZBM_CLASSE,                                                                                                                 "
	cQuery += " ZBM_PRZMET,                                                                                                                 "
	cQuery += " ZBM_METVER,                                                                                                                 "
	cQuery += " ZBM_PERVER,                                                                                                                 "
	cQuery += " ZBM_PERBON,                                                                                                                 "
	cQuery += " ZBM_VALVER,                                                                                                                 "
	cQuery += " ZBM_VALBON,                                                                                                                 "
	cQuery += " ZBM_PERCPV,                                                                                                                 "
	cQuery += " ZBM_VALCPV,                                                                                                                 "
	cQuery += " ZBM_PICMBO,                                                                                                                 "
	cQuery += " ZBM_VICMBO,                                                                                                                 "
	cQuery += " ZBM_MODAO,                                                                                                                  "
	cQuery += " ZBM_MODCF,                                                                                                                  "
	cQuery += " ZBM_MOINVE,                                                                                                                 "
	cQuery += " ZBM_MOICMS,                                                                                                                 "
	cQuery += " ZBM_MODCVF,                                                                                                                 "
	cQuery += " ZBM_MODCVC,                    	                                                                                            "
	cQuery += " ' ' ZBM_ATIVO,                    	                                                                                            "
	cQuery += " '"+cProxSeque+"'             	                                                                                            "
	cQuery += " from " + RetSqlName("ZBM") + "                                                                                              "
	cQuery += " where ZBM_VERSAO = '"+cVersao+"' AND ZBM_REVISA = '"+cRevisa+"' AND ZBM_ANOREF = '"+cAno+"' AND D_E_L_E_T_ = ''				"
	cQuery += " AND ZBM_FILIAL = '"+xFilial('ZBM')+"'																						"
	cQuery += " AND (ZBM_ATIVO = 'S')																										"	

	ConOut(cQuery)
	nStatus := TcSQLExec(cQuery)

	If (nStatus < 0)

		ConOut("Erro=> " + TCSQLError())
		MsgAlert("Erro na criação da sequência: " + cProxSeque + ".", "BIACMGMR")

	Else

		MsgINFO("Processamento realizado com sucesso. Nova Sequência gerada: " + cProxSeque + ".", "BIACMGMR")

	EndIf

Return
