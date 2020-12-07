#include 'protheus.ch'

/*/{Protheus.doc} BIAFG002
@author Gabriel Rossi Mafioletti
@since 29/05/17
@version 1.0
@description Funcao para criacao de nova revisao para produto
@type function
/*/

User function BIAFG002()

	Local fqRetA := GetArea()

	If ValidPerg()
		FUpdRev()
	Else
		return
	EndIf

	Pergunte('MTA200', .F.)

	RestArea( fqRetA )

return 


Static function ValidPerg()

	local cLoad	    := "BIAFG002" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aPergs	:= {}

	MV_PAR01 := space(TamSx3("B1_COD")[1])
	MV_PAR02 := STOD('')

	aAdd( aPergs ,{1,"Código Produto"		,MV_PAR01 ,"@!","EXISTCPO('SB1')"		,"SB1",'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Referencia"	,MV_PAR02 ,"@!",""		,"",'.T.',50,.T.})	

	If ParamBox(aPergs ,"Relatório de Log de processamento",,,,,,,,cFileName,.T.,.T.)  

		lRet := .T.

		MV_PAR01 := ParamLoad(cFileName,,1 ,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2 ,MV_PAR02) 

	endif

return lRet


Static function FUpdRev()

	local _csql	:=	""
	local _cAlias	:=	GetNextAlias()
	local _cData	:=	Dtos(MV_PAR02)
	local _dDataIni	:=	Stod('')	
	
	PRIVATE cProduto	:=	""
	PRIVATE cRevisao	:=	""
	PRIVATE dDtRevis	:=	Stod("")
	
	DBSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1") + MV_PAR01))

		BeginSql Alias _cAlias

		SELECT R_E_C_N_O_ RCNO
		FROM %TABLE:SG1%
		WHERE G1_FILIAL = %XFILIAL:SG1%
		AND G1_COD = %EXP:MV_PAR01%
		AND %EXP:_cData% > G1_INI
		AND %EXP:_cData% <= G1_FIM
		AND G1_REVINI = G1_REVFIM
		AND %NotDel%
		EndSql

		DbSelectArea("SG1")
		If (_cAlias)->(!EOF())
			While (_cAlias)->(!EOF())
				SG1->(DbGoTo((_cAlias)->RCNO))
				Reclock("SG1",.F.)
				SG1->G1_FIM := DaySub(MV_PAR02,1)
				SG1->(MsUnlock())
				_cData	:=	DTos(SG1->G1_FIM)
				(_cAlias)->(DbSkip())
			EndDo
		Else
			MsgInfo("Revisoes do Produto Não Encontradas!")
			(_cAlias)->(DbCloseArea())
			return
		EndIf

		(_cAlias)->(DbCloseArea())

		Reclock("SB1",.F.)
		SB1->B1_REVATU	:=	SOMA1(SB1->B1_REVATU)
		SB1->(MsUnlock())

		_cSql	:=	"	INSERT INTO " + RETSQLNAME('SG1')+ "  "
		_cSql	+=	"        ( G1_FILIAL , 	"
		_cSql	+=	"          G1_COD ,		"
		_cSql	+=	"          G1_COMP ,	"
		_cSql	+=	"          G1_TRT ,		"
		_cSql	+=	"          G1_QUANT ,	"
		_cSql	+=	"          G1_PERDA ,	"
		_cSql	+=	"          G1_INI ,		"
		_cSql	+=	"          G1_FIM ,		"
		_cSql	+=	"          G1_NIV ,		"
		_cSql	+=	"          G1_OBSERV ,	"
		_cSql	+=	"          G1_FIXVAR ,	"
		_cSql	+=	"          G1_NIVINV ,	"
		_cSql	+=	"          G1_GROPC ,	"
		_cSql	+=	"          G1_REVINI ,	"
		_cSql	+=	"          G1_OPC ,		"
		_cSql	+=	"          G1_REVFIM ,	"
		_cSql	+=	"          G1_YEQUIPA ,	"
		_cSql	+=	"          G1_YDENSID ,	"
		_cSql	+=	"          G1_YVISCOS ,	"
		_cSql	+=	"          G1_YCAMADA ,	"
		_cSql	+=	"          G1_YINCESP ,	"
		_cSql	+=	"          G1_YPRSESP ,	"
		_cSql	+=	"          G1_YROLCIL ,	"
		_cSql	+=	"          G1_YALTCIL ,	"
		_cSql	+=	"          G1_POTENCI ,	"
		_cSql	+=	"          G1_VLCOMPE ,	"
		_cSql	+=	"          G1_OK ,		"
		_cSql	+=	"          G1_YUM ,		"
		_cSql	+=	"          D_E_L_E_T_ ,	"
		_cSql	+=	"          R_E_C_N_O_ ,	"
		_cSql	+=	"          R_E_C_D_E_L_ ,	"
		_cSql	+=	"          G1_YDESCCD ,	"
		_cSql	+=	"          G1_YDESCCP ,	"
		_cSql	+=	"          G1_YMISTUR ,	"
		_cSql	+=	"          G1_YQTDREF ,	"
		_cSql	+=	"          G1_YUNIDRF ,	"
		_cSql	+=	"          G1_YMOAGEM ,	"
		_cSql	+=	"          G1_YSEQIMP ,	"
		_cSql	+=	"          G1_YDADOSF ,	"
		_cSql	+=	"          G1_YTAG ,	"
		_cSql	+=	"          G1_VECTOR ,	"
		_cSql	+=	"          G1_TIPVEC	"
		_cSql	+=	"        )				"
		_cSql	+=	"        SELECT  G1_FILIAL ,	"
		_cSql	+=	"                G1_COD ,		"
		_cSql	+=	"                G1_COMP ,		"
		_cSql	+=	"                B1_REVATU G1_TRT ,	"
		_cSql	+=	"                G1_QUANT ,	"
		_cSql	+=	"                G1_PERDA ,	"
		_cSql	+=					 ValtoSql(MV_PAR02) + " G1_INI ,	"
		_cSql	+=	"                '20491231' G1_FIM ,	"
		_cSql	+=	"                G1_NIV ,	"
		_cSql	+=	"                G1_OBSERV ,	"
		_cSql	+=	"                G1_FIXVAR ,	"
		_cSql	+=	"                G1_NIVINV ,	"
		_cSql	+=	"                G1_GROPC ,		"
		_cSql	+=	"                B1_REVATU G1_REVINI ,	"
		_cSql	+=	"                G1_OPC ,	"
		_cSql	+=	"                B1_REVATU G1_REVFIM ,	"
		_cSql	+=	"                G1_YEQUIPA ,			"
		_cSql	+=	"                G1_YDENSID ,			"
		_cSql	+=	"                G1_YVISCOS ,			"
		_cSql	+=	"                G1_YCAMADA ,			"
		_cSql	+=	"                G1_YINCESP ,			"
		_cSql	+=	"                G1_YPRSESP ,			"
		_cSql	+=	"                G1_YROLCIL ,			"
		_cSql	+=	"                G1_YALTCIL ,			"
		_cSql	+=	"                G1_POTENCI ,			"
		_cSql	+=	"                G1_VLCOMPE ,			"
		_cSql	+=	"                G1_OK ,				"
		_cSql	+=	"                G1_YUM ,				"
		_cSql	+=	"                SG1.D_E_L_E_T_ ,		"
		_cSql	+=	"                ( SELECT    MAX(R_E_C_N_O_)	"
		_cSql	+=	"                  FROM      " + RetSqlName("SG1") + "  "
		_cSql	+=	"                ) + ROW_NUMBER() OVER ( ORDER BY SG1.R_E_C_N_O_ ) AS R_E_C_N_O_ , "
		_cSql	+=	"                SG1.R_E_C_D_E_L_ ,	"
		_cSql	+=	"                G1_YDESCCD ,	"
		_cSql	+=	"                G1_YDESCCP ,	"
		_cSql	+=	"                G1_YMISTUR ,	"
		_cSql	+=	"                G1_YQTDREF ,	"
		_cSql	+=	"                G1_YUNIDRF ,	"
		_cSql	+=	"                G1_YMOAGEM ,	"
		_cSql	+=	"                G1_YSEQIMP ,	"
		_cSql	+=	"                G1_YDADOSF ,	"
		_cSql	+=	"                G1_YTAG ,		"
		_cSql	+=	"                G1_VECTOR ,	"
		_cSql	+=	"                G1_TIPVEC		"
		_cSql	+=	"        FROM "  + RetSqlName("SG1") + " SG1	"
		_cSql	+=	"                INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = " + ValtoSql(xFilial("SB1")) + "  "   
		_cSql	+=	"                                         AND B1_COD = G1_COD "
		_cSql	+=	"                                         AND SB1.D_E_L_E_T_ = ' '	"
		_cSql	+=	"        WHERE   G1_FILIAL = " + ValtoSql(xFilial("SG1"))
		_cSql	+=	"                AND G1_COD = " + ValtoSql(MV_PAR01) + "  " 
		_cSql	+=	"                AND G1_FIM = " + ValtoSql(_cData) + " 	"
		_cSql	+=	"                AND G1_REVINI = G1_REVFIM	"
		_cSql	+=	"                AND SG1.D_E_L_E_T_ = ' '	"

		TcSqlExec(_cSql)
		
		DbSelectArea("SG5")
		
		aMata201  := {{'G5_PRODUTO'  ,SB1->B1_COD                          ,NIL},;
		{              'G5_REVISAO'  ,SB1->B1_REVATU                      ,NIL},;
		{              'G5_DATAREV'  ,MV_PAR02 	                           ,NIL} }
		
		cProduto	:=	SB1->B1_COD
		cRevisao	:=	SB1->B1_REVATU
		dDTRevis	:=	MV_PAR02
		
		MsExecAuto({|x| Mata201(x)}, aMata201, 3)
		MsgInfo("Revisão Alterada com Sucesso!")
	Else
		MsgInfo("Produto Não Encontrado!")
	EndIf



return