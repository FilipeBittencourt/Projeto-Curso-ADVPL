#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG094
@author Gabriel Rossi Mafioletti
@since 03/06/2019
@version 1.0
@description Integração de Recursos do MES (Gateway)
@type function
/*/

User Function BIAFG094()

	
	U_BIAMsgRun("Aguarde... Executando a integração com o Gateway" , , {|| fProcess() })
	

Return


Static Function fProcess()

	BEGIN TRANSACTION
	
		fNetwork()
		
		fCollect()
		
		fDataCol()
	
	END TRANSACTION


	
	
Return


Static Function fNetwork()
	
	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
		%NoParser%
		SELECT H1_CODIGO COD
		FROM %TABLE:SH1% SH1
		WHERE NOT EXISTS (
				SELECT 1
				FROM PCF4..TBLNetwork PCF4
				WHERE PCF4.code = 'ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND SH1.%NotDel%
			AND SH1.H1_YITGMES = '1'
	EndSql
	
	While (_cAlias)->(!EOF())
	
		_cSql	:=	"	INSERT INTO PCF4..TBLNetwork			"
		_cSql	+=	"	(IDGateway,                             "
		_cSql	+=	"	Code,                                   "
		_cSql	+=	"	Name,                                   "
		_cSql	+=	"	NickName,                               "
		_cSql	+=	"	NetworkType,                            "
		_cSql	+=	"	MainPort,                               "
		_cSql	+=	"	Timeout,                                "
		_cSql	+=	"	RxBuffer,                               "
		_cSql	+=	"	ResourceRelation,                       "
		_cSql	+=	"	RangeTypeDC,                            "
		_cSql	+=	"	FlgEnable,                              "
		_cSql	+=	"	FirstLoad,                              "
		_cSql	+=	"	MsgTime,                                "
		_cSql	+=	"	Driver,                                 "
		_cSql	+=	"	ProdQtyCountMethod,                     "
		_cSql	+=	"	ScrapQtyCountMethod,                    "
		_cSql	+=	"	ReWorkQtyCountMethod,                   "
		_cSql	+=	"	IDUserLastUpdate                        "
		_cSql	+=	"	)                                       "
		_cSql	+=	"		SELECT 1 IDGateway,                 "
		_cSql	+=	"				'ST_' + "+ValtoSql((_cAlias)->COD)+" Code,           "
		_cSql	+=	"				'ST_' + "+ValtoSql((_cAlias)->COD)+" Name,           "
		_cSql	+=	"				'ST_' + "+ValtoSql((_cAlias)->COD)+" NickName,       "
		_cSql	+=	"				9 NetworkType,              "
		_cSql	+=	"				10000 MainPort,             "
		_cSql	+=	"				20 Timeout,                 "
		_cSql	+=	"				20 RxBuffer,                "
		_cSql	+=	"				0 ResourceRelation,         "
		_cSql	+=	"				0 RangeTypeDC,              "
		_cSql	+=	"				1 FlgEnable,                "
		_cSql	+=	"				0 FirstLoad,                "
		_cSql	+=	"				20 MsgTime,                 "
		_cSql	+=	"				'DrvNet_RSStatus' Driver,   "
		_cSql	+=	"				1 ProdQtyCountMethod,       "
		_cSql	+=	"				1 ScrapQtyCountMethod,      "
		_cSql	+=	"				1 ReWorkQtyCountMethod,     "
		_cSql	+=	"				1 IDUserLastUpdate          "
		
		TcSqlExec(_cSql)
		
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
Return

Static Function fCollect()
	
	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
		%NoParser%
		SELECT H1_CODIGO COD
		FROM %TABLE:SH1% SH1
		WHERE NOT EXISTS (
				SELECT 1
				FROM PCF4..TBLDataCollector PCF4
				WHERE PCF4.code = 'C_ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND EXISTS (
				SELECT 1
				FROM PCF4..TBLNetwork PCF4
				WHERE PCF4.code = 'ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND SH1.%NotDel%
			AND SH1.H1_YITGMES = '1'
	EndSql
	
	While (_cAlias)->(!EOF())
	
		_cSql	:=	"	INSERT INTO PCF4..TBLDataCollector			"
		_cSql	+=	"	(IDNetwork,                             "
		_cSql	+=	"	 Code,                                  "
		_cSql	+=	"	 Name,                                  "
		_cSql	+=	"	 NickName,                              "
		_cSql	+=	"	 Description,                           "
		_cSql	+=	"	 ResourceAutoIdentifier,                "
		_cSql	+=	"	 FlgEnable,                             "
		_cSql	+=	"	 FirstLoad,                             "
		_cSql	+=	"	 Printer,                               "
		_cSql	+=	"	 ConnectionType,                        "
		_cSql	+=	"	 ReturnJSON,                            "
		_cSql	+=	"	 IDUserLastUpdate                       "
		_cSql	+=	"	)                                       "
		_cSql	+=	"	       SELECT                           "
		_cSql	+=	"	       (                                "
		_cSql	+=	"	           SELECT IDNetwork             "
		_cSql	+=	"	           FROM PCF4..TBLNetwork              "
		_cSql	+=	"	           WHERE Code = 'ST_'+"+ValtoSql((_cAlias)->COD)+"     "
		_cSql	+=	"	       ) IDNetwork,                     "
		_cSql	+=	"	       'C_ST_'+ "+ValtoSql((_cAlias)->COD)+"  Code,              "
		_cSql	+=	"	       'C_ST_'+ "+ValtoSql((_cAlias)->COD)+"  Name,              "
		_cSql	+=	"	       'C_ST_'+ "+ValtoSql((_cAlias)->COD)+"  NickName,          "
		_cSql	+=	"	       '' Description,                  "
		_cSql	+=	"	       0 ResourceAutoIdentifier,        "
		_cSql	+=	"	       1 FlgEnable,                     "
		_cSql	+=	"	       0 FirstLoad,                     "
		_cSql	+=	"	       '' Printer,                      "
		_cSql	+=	"	       1 ConnectionType,                "
		_cSql	+=	"	       1 ReturnJSON,                    "
		_cSql	+=	"	       1 IDUserLastUpdate 	            "
		
		TcSqlExec(_cSql)
		
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
Return


Static Function fDataCol()
	
	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
		%NoParser%
		SELECT H1_CODIGO COD
		FROM %TABLE:SH1% SH1
		WHERE EXISTS (
				SELECT 1
				FROM PCF4..TBLDataCollector PCF4
				WHERE PCF4.code = 'C_ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND EXISTS (
				SELECT 1
				FROM PCF4..TBLNetwork PCF4
				WHERE PCF4.code = 'ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND EXISTS (
				SELECT 1
				FROM PCF4..TBLResource PCF4
				WHERE PCF4.code = SH1.H1_CODIGO COLLATE Latin1_General_BIN
				)
			AND NOT EXISTS (
				SELECT 1
				FROM PCF4..TBLResNetDataCol
				WHERE IDNetwork = (
						SELECT TOP 1 IDNetwork
						FROM PCF4..TBLNetwork PCF4
						WHERE PCF4.code = 'ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
						)
					AND IDDataCollector = (
						SELECT TOP 1 IDDataCollector
						FROM PCF4..TBLDataCollector PCF4
						WHERE PCF4.code = 'C_ST_' + SH1.H1_CODIGO COLLATE Latin1_General_BIN
						)
					AND IDResource = (
						SELECT TOP 1 IDResource
						FROM PCF4..TBLResource PCF4
						WHERE PCF4.code = SH1.H1_CODIGO COLLATE Latin1_General_BIN
						)
				)
			AND SH1.%NotDel%
			AND SH1.H1_YITGMES = '1'
	EndSql
	
	While (_cAlias)->(!EOF())
	
		_cSql	:=	"	INSERT INTO PCF4..TBLResNetDataCol		"
		_cSql	+=	"	(IDNetwork,                         "
		_cSql	+=	"	IDDataCollector,                    "
		_cSql	+=	"	IDResource,                         "
		_cSql	+=	"	Position,                           "
		_cSql	+=	"	FlgEnable,                          "
		_cSql	+=	"	StatusIdentifierMethod,             "
		_cSql	+=	"	FlgCycleTimeEv,                     "
		_cSql	+=	"	IDUserLastUpdate                    "
		_cSql	+=	"	)                                   "
		_cSql	+=	"		SELECT                          "
		_cSql	+=	"		(                               "
		_cSql	+=	"			SELECT IDNetwork            "
		_cSql	+=	"			FROM PCF4..TBLNetwork             "
		_cSql	+=	"			WHERE Code = 'ST_' + "+ValtoSql((_cAlias)->COD)+"     "
		_cSql	+=	"		) IDNetwork,                    "
		_cSql	+=	"		(                               "
		_cSql	+=	"			SELECT IDDataCollector      "
		_cSql	+=	"			FROM PCF4..TBLDataCollector       "
		_cSql	+=	"			WHERE Code = 'C_ST_' + "+ValtoSql((_cAlias)->COD)+"  "
		_cSql	+=	"		) IDDataCollector,              "
		_cSql	+=	"		(                               "
		_cSql	+=	"			SELECT IDResource           "
		_cSql	+=	"			FROM PCF4..TBLResource            "
		_cSql	+=	"			WHERE Code = "+ValtoSql((_cAlias)->COD)+"       "
		_cSql	+=	"		) IDResource,                   "
		_cSql	+=	"		1 Position,                     "
		_cSql	+=	"		1 FlgEnable,                    "
		_cSql	+=	"		3 StatusIdentifierMethod,       "
		_cSql	+=	"		1 FlgCycleTimeEv,               "
		_cSql	+=	"		1 IDUserLastUpdate              "
		
		TcSqlExec(_cSql)
		
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
Return