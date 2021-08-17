#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG069
@author Gabriel Rossi Mafioletti
@since 04/10/2018
@version 1.0
@description Rotina para Manter os Armazéns na tabela ZCN
@type function
/*/

User Function BIAFG069()
	Local x
	xv_Emps    := U_BAGtEmpr("01_14")

	For x := 1 to Len(xv_Emps)
		RPCSetType(3)
		//RPCSetEnv('01', '01')
		RPCSetEnv(xv_Emps[x,1], xv_Emps[x,2])

		ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG069 " + xv_Emps[x,1])

		Processa({|| fProcessa( .T. )})

		ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG069 " + xv_Emps[x,1])

		RpcClearEnv()
	Next
Return


Static Function fProcessa()

	Local _cAlias	:=	GetNextAlias()

	DbSelectArea("ZCN")

	BEGINSQL Alias _cAlias

		SELECT BZ_COD
		,BZ_LOCPAD
		,BZ_ESTSEG
		,BZ_EMIN
		,BZ_LE
		,B1_TIPO
		,BZ_YLOCAL
		,BZ_YPOLIT
		,BZ_YMD
		FROM %TABLE:SBZ% SBZ
		JOIN %TABLE:SB1% SB1
		ON SBZ.BZ_COD = SB1.B1_COD
		AND SB1.%NotDel%
		LEFT JOIN %TABLE:ZCN% ZCN ON SBZ.BZ_COD = ZCN.ZCN_COD
		AND ZCN.ZCN_SEQUEN = '1'
		AND ZCN.%NotDel%
		WHERE SBZ.%NotDel%
		AND (
		ZCN.ZCN_FILIAL IS NULL
		OR (
		ZCN.ZCN_FILIAL IS NOT NULL
		AND (
		ZCN.ZCN_LOCAL <> SBZ.BZ_LOCPAD
		OR ZCN.ZCN_ESTSEG <> SBZ.BZ_ESTSEG
		OR ZCN.ZCN_PONPED <> SBZ.BZ_EMIN
		OR ZCN.ZCN_LE <> SBZ.BZ_LE
		OR ZCN.ZCN_LOCALI <> SBZ.BZ_YLOCAL
		OR ZCN.ZCN_MD <> SBZ.BZ_YMD
		OR ZCN.ZCN_POLIT <> SBZ.BZ_YPOLIT
		)
		)
		)

	ENDSQL

	ZCN->(DbSetOrder(1))

	While (_cAlias)->(!EOF())

		If !ZCN->(DbSeek(xFilial("ZCN")+(_cAlias)->BZ_COD+'1'))
			Reclock("ZCN",.T.)
			ZCN->ZCN_FILIAL :=	xFilial("ZCN")
			ZCN->ZCN_COD	:=	(_cAlias)->BZ_COD
			ZCN->ZCN_SEQUEN	:=	"1"
			ZCN->ZCN_LOCAL	:=	IIF(Alltrim((_cAlias)->B1_TIPO) $ "PA_PP", '02','01') 
			ZCN->ZCN_ESTSEG	:=	(_cAlias)->BZ_ESTSEG
			ZCN->ZCN_PONPED	:=	(_cAlias)->BZ_EMIN
			ZCN->ZCN_LE		:=	(_cAlias)->BZ_LE
			ZCN->ZCN_LOCALI	:=	(_cAlias)->BZ_YLOCAL
			ZCN->ZCN_POLIT	:=	(_cAlias)->BZ_YPOLIT
			ZCN->ZCN_MD		:=	(_cAlias)->BZ_YMD
			ZCN->(MsUnlock())
		EndIf

		xcLocSecPad := "20"
		
		// Regra incluída para atender a unificação do controle de almoxarifado dos insumos de MPM
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek(xFilial("SB1") + (_cAlias)->BZ_COD))
		If SB1->B1_TIPO = "MP" .and. SB1->B1_GRUPO >= "101 " .and. SB1->B1_GRUPO <= "101Z"
			xcLocSecPad := "01"
		EndIf

		If !ZCN->(DbSeek(xFilial("ZCN")+(_cAlias)->BZ_COD+'2'))
			Reclock("ZCN",.T.)
			ZCN->ZCN_FILIAL :=	xFilial("ZCN")
			ZCN->ZCN_COD	:=	(_cAlias)->BZ_COD
			ZCN->ZCN_SEQUEN	:=	"2"
			ZCN->ZCN_LOCAL	:=	IIF(Alltrim((_cAlias)->B1_TIPO) $ "PA_PP", '04', xcLocSecPad)
			ZCN->ZCN_ESTSEG	:=	(_cAlias)->BZ_ESTSEG
			ZCN->ZCN_PONPED	:=	(_cAlias)->BZ_EMIN
			ZCN->ZCN_LE		:=	(_cAlias)->BZ_LE
			ZCN->ZCN_LOCALI	:=	(_cAlias)->BZ_YLOCAL
			ZCN->ZCN_POLIT	:=	(_cAlias)->BZ_YPOLIT
			ZCN->ZCN_MD		:=	(_cAlias)->BZ_YMD
			ZCN->(MsUnlock())
		EndIf

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	
	fAtuMundi()
	fAtuVinilico()

Return

Static Function fAtuVinilico()

	Local _cSql	:=	""

	
	_cSql	+=	"INSERT INTO ZCN140 (							"
	_cSql	+=	"	[ZCN_FILIAL]								"
	_cSql	+=	"	,[ZCN_COD]									"
	_cSql	+=	"	,[ZCN_SEQUEN]								"
	_cSql	+=	"	,[ZCN_LOCAL]								"
	_cSql	+=	"	,[ZCN_ESTSEG]								"
	_cSql	+=	"	,[ZCN_PONPED]								"
	_cSql	+=	"	,[ZCN_LE]									"
	_cSql	+=	"	,[ZCN_LOCALI]								"
	_cSql	+=	"	,[D_E_L_E_T_]								"
	_cSql	+=	"	,[R_E_C_N_O_]								"
	_cSql	+=	"	,[R_E_C_D_E_L_]								"
	_cSql	+=	"	,[ZCN_PORTAR]								"
	_cSql	+=	"	,[ZCN_POLIT]								"
	_cSql	+=	"	,[ZCN_MD]									"
	_cSql	+=	"	,[ZCN_COMUM]								"
	_cSql	+=	"	,[ZCN_OBSOLE]								"
	_cSql	+=	"	,[ZCN_SOLIC]								"
	_cSql	+=	"	)											"	
	_cSql	+=	"SELECT '01'									"
	_cSql	+=	"	,[ZCN_COD]                                  "
	_cSql	+=	"	,[ZCN_SEQUEN]                               "
	_cSql	+=	"	,[ZCN_LOCAL]                                "
	_cSql	+=	"	,[ZCN_ESTSEG]                               "
	_cSql	+=	"	,[ZCN_PONPED]                               "
	_cSql	+=	"	,[ZCN_LE]                                   "
	_cSql	+=	"	,[ZCN_LOCALI]                               "
	_cSql	+=	"	,ZCN.[D_E_L_E_T_]                           "
	_cSql	+=	"	,ROW_NUMBER() OVER (                        "
	_cSql	+=	"		ORDER BY ZCN_FILIAL                     "
	_cSql	+=	"			,ZCN_COD                            "
	_cSql	+=	"		) + (                                   "
	_cSql	+=	"		SELECT ISNULL(MAX(R_E_C_N_O_), 0)       "
	_cSql	+=	"		FROM ZCN140                             "
	_cSql	+=	"		)                                       "
	_cSql	+=	"	,ZCN.[R_E_C_D_E_L_]                         "
	_cSql	+=	"	,[ZCN_PORTAR]                               "
	_cSql	+=	"	,[ZCN_POLIT]                                "
	_cSql	+=	"	,[ZCN_MD]                                   "
	_cSql	+=	"	,[ZCN_COMUM]                                "
	_cSql	+=	"	,[ZCN_OBSOLE]                               "
	_cSql	+=	"	,[ZCN_SOLIC]                                "
	_cSql	+=	"FROM "+ RETSQLNAME("SB1") + " SB1                                "
	_cSql	+=	"JOIN "+ RETSQLNAME("ZCN") + " ZCN ON ZCN.ZCN_FILIAL = "+ValtoSql(xFilial('ZCN'))+"       "
	_cSql	+=	"	AND SB1.B1_COD = ZCN.ZCN_COD                "
	_cSql	+=	"	AND ZCN_SEQUEN = '1'                        "
	_cSql	+=	"	AND ZCN.D_E_L_E_T_ = ''                     "
	_cSql	+=	"WHERE B1_YFORMAT IN ('VG', 'VH', 'VI')         "
	_cSql	+=	"	AND SB1.D_E_L_E_T_ = ''                     "
	_cSql	+=	"	AND NOT EXISTS (                            "
	_cSql	+=	"		SELECT 1                                "
	_cSql	+=	"		FROM ZCN140 ZCN14                       "
	_cSql	+=	"		WHERE ZCN14.ZCN_FILIAL = ZCN.ZCN_FILIAL "
	_cSql	+=	"			AND ZCN14.ZCN_COD = ZCN.ZCN_COD     "
	_cSql	+=	"			AND ZCN14.ZCN_SEQUEN = '1'          "
	_cSql	+=	"			AND ZCN14.D_E_L_E_T_ = ''           "
	_cSql	+=	"		)                                       "
	
	
	TcSqlExec(_cSql)

Return

Static Function fAtuMundi()

	Local _cSql	:=	""

	
	_cSql	+=	"INSERT INTO ZCN130 (							"
	_cSql	+=	"	[ZCN_FILIAL]								"
	_cSql	+=	"	,[ZCN_COD]									"
	_cSql	+=	"	,[ZCN_SEQUEN]								"
	_cSql	+=	"	,[ZCN_LOCAL]								"
	_cSql	+=	"	,[ZCN_ESTSEG]								"
	_cSql	+=	"	,[ZCN_PONPED]								"
	_cSql	+=	"	,[ZCN_LE]									"
	_cSql	+=	"	,[ZCN_LOCALI]								"
	_cSql	+=	"	,[D_E_L_E_T_]								"
	_cSql	+=	"	,[R_E_C_N_O_]								"
	_cSql	+=	"	,[R_E_C_D_E_L_]								"
	_cSql	+=	"	,[ZCN_PORTAR]								"
	_cSql	+=	"	,[ZCN_POLIT]								"
	_cSql	+=	"	,[ZCN_MD]									"
	_cSql	+=	"	,[ZCN_COMUM]								"
	_cSql	+=	"	,[ZCN_OBSOLE]								"
	_cSql	+=	"	,[ZCN_SOLIC]								"
	_cSql	+=	"	)											"	
	_cSql	+=	"SELECT '01'									"
	_cSql	+=	"	,[ZCN_COD]                                  "
	_cSql	+=	"	,[ZCN_SEQUEN]                               "
	_cSql	+=	"	,[ZCN_LOCAL]                                "
	_cSql	+=	"	,[ZCN_ESTSEG]                               "
	_cSql	+=	"	,[ZCN_PONPED]                               "
	_cSql	+=	"	,[ZCN_LE]                                   "
	_cSql	+=	"	,[ZCN_LOCALI]                               "
	_cSql	+=	"	,ZCN.[D_E_L_E_T_]                           "
	_cSql	+=	"	,ROW_NUMBER() OVER (                        "
	_cSql	+=	"		ORDER BY ZCN_FILIAL                     "
	_cSql	+=	"			,ZCN_COD                            "
	_cSql	+=	"		) + (                                   "
	_cSql	+=	"		SELECT ISNULL(MAX(R_E_C_N_O_), 0)       "
	_cSql	+=	"		FROM ZCN130                             "
	_cSql	+=	"		)                                       "
	_cSql	+=	"	,ZCN.[R_E_C_D_E_L_]                         "
	_cSql	+=	"	,[ZCN_PORTAR]                               "
	_cSql	+=	"	,[ZCN_POLIT]                                "
	_cSql	+=	"	,[ZCN_MD]                                   "
	_cSql	+=	"	,[ZCN_COMUM]                                "
	_cSql	+=	"	,[ZCN_OBSOLE]                               "
	_cSql	+=	"	,[ZCN_SOLIC]                                "
	_cSql	+=	"FROM "+ RETSQLNAME("SB1") + " SB1                                "
	_cSql	+=	"JOIN "+ RETSQLNAME("ZCN") + " ZCN ON ZCN.ZCN_FILIAL = "+ValtoSql(xFilial('ZCN'))+"       "
	_cSql	+=	"	AND SB1.B1_COD = ZCN.ZCN_COD                "
	_cSql	+=	"	AND ZCN_SEQUEN = '1'                        "
	_cSql	+=	"	AND ZCN.D_E_L_E_T_ = ''                     "
	_cSql	+=	"WHERE B1_YPCGMR3 = 'J'                         "
	_cSql	+=	"	AND SB1.D_E_L_E_T_ = ''                     "
	_cSql	+=	"	AND NOT EXISTS (                            "
	_cSql	+=	"		SELECT 1                                "
	_cSql	+=	"		FROM ZCN130 ZCN13                       "
	_cSql	+=	"		WHERE ZCN13.ZCN_FILIAL = ZCN.ZCN_FILIAL "
	_cSql	+=	"			AND ZCN13.ZCN_COD = ZCN.ZCN_COD     "
	_cSql	+=	"			AND ZCN13.ZCN_SEQUEN = '1'          "
	_cSql	+=	"			AND ZCN13.D_E_L_E_T_ = ''           "
	_cSql	+=	"		)                                       "
	
	
	TcSqlExec(_cSql)

Return
