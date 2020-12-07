#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*/{Protheus.doc} BIAFG095
@author Gabriel Rossi Mafioletti
@since 17/06/2019
@version 1.0
@description Rotina para Integração de Centro de Trabalho com o MES
@type function
/*/

User Function BIAFG095()

	Local _cSql	:=	""

	_cSql	+=	"	INSERT INTO PCF4..TBLManagerGrp (								"
	_cSql	+=	"		IDSector                                                    "
	_cSql	+=	"		,Code                                                       "
	_cSql	+=	"		,Nickname                                                   "
	_cSql	+=	"		,Name                                                       "
	_cSql	+=	"		,FlgEnable                                                  "
	_cSql	+=	"		,FlgDTM                                                     "
	_cSql	+=	"		,IDUserLastUpdate                                           "
	_cSql	+=	"		)                                                           "
	_cSql	+=	"	SELECT (                                                        "
	_cSql	+=	"			SELECT IDSeCtor                                         "
	_cSql	+=	"			FROM PCF4..TBLSector                                    "
	_cSql	+=	"			WHERE CODE = HB_YSETORM collate Latin1_General_BIN      "
	_cSql	+=	"			) IDSector                                              "
	_cSql	+=	"		,HB_COD Code                                                "
	_cSql	+=	"		,HB_NOME Nickname                                           "
	_cSql	+=	"		,HB_NOME Name                                               "
	_cSql	+=	"		,1 FlgEnable                                                "
	_cSql	+=	"		,1 FlgDTM                                                   "
	_cSql	+=	"		,1 IDUserLastUpdate                                         "
	_cSql	+=	"	FROM "+RetSqlName("SHB")+"                                      "
	_cSql	+=	"	WHERE D_E_L_E_T_ = ' '                                          "
	_cSql	+=	"		AND HB_COD NOT IN (                                         "
	_cSql	+=	"			SELECT Code collate Latin1_General_BIN                  "
	_cSql	+=	"			FROM PCF4..TBLManagerGrp                                "
	_cSql	+=	"			)                                                       "
 

	U_BIAMsgRun("Aguarde... Integrando Centros de Trabalho" , , {|| tcSqlExec(_cSql) })

Return