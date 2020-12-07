#include 'protheus.ch'

/*/{Protheus.doc} BIAFG001
@author Gabriel Rossi Mafioletti
@since 29/05/17
@version 1.0
@description Funcao para criacao de revisao para produto similar
@type function
/*/

User function BIAFG001()

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

	local cLoad	    := "BIAFG001" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aPergs	:= {}

	MV_PAR01 := space(TamSx3("B1_COD")[1])
	MV_PAR02 := space(TamSx3("B1_COD")[1])
	MV_PAR03 := STOD('')

	aAdd( aPergs ,{1,"Produto Novo"		,MV_PAR01 ,"@!","EXISTCPO('SB1')"		,"SB1",'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Produto Similar"	,MV_PAR02 ,"@!","EXISTCPO('SB1')"		,"SB1",'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Referencia"	,MV_PAR03 ,"@!",""		,"",'.T.',50,.T.})	

	If ParamBox(aPergs ,"Relatório de Log de processamento",,,,,,,,cFileName,.T.,.T.)  

		lRet := .T.

		MV_PAR01 := ParamLoad(cFileName,,1 ,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2 ,MV_PAR02) 
		MV_PAR03 := ParamLoad(cFileName,,3 ,MV_PAR03) 

	endif

return lRet

Static function fUpdRev()

	Local _cSql	:=	""

	_cSql	:=	"	INSERT  INTO " + RETSQLNAME("SG1") + "  "
	_cSql	+=	"	        ( G1_FILIAL ,  "
	_cSql	+=	"	          G1_COD ,     "
	_cSql	+=	"	          G1_COMP ,    "
	_cSql	+=	"	          G1_TRT ,     "
	_cSql	+=	"	          G1_QUANT ,   "
	_cSql	+=	"	          G1_PERDA ,   "
	_cSql	+=	"	          G1_INI ,     "
	_cSql	+=	"	          G1_FIM ,     "
	_cSql	+=	"	          G1_NIV ,     "
	_cSql	+=	"	          G1_OBSERV ,  "
	_cSql	+=	"	          G1_FIXVAR ,  "
	_cSql	+=	"	          G1_NIVINV ,  "
	_cSql	+=	"	          G1_GROPC ,   "
	_cSql	+=	"	          G1_REVINI ,  "
	_cSql	+=	"	          G1_OPC ,     "
	_cSql	+=	"	          G1_REVFIM ,  "
	_cSql	+=	"	          G1_YEQUIPA , "
	_cSql	+=	"	          G1_YDENSID , "
	_cSql	+=	"	          G1_YVISCOS , "
	_cSql	+=	"	          G1_YCAMADA , "
	_cSql	+=	"	          G1_YINCESP , "
	_cSql	+=	"	          G1_YPRSESP , "
	_cSql	+=	"	          G1_YROLCIL , "
	_cSql	+=	"	          G1_YALTCIL , "
	_cSql	+=	"	          G1_POTENCI , "
	_cSql	+=	"	          G1_VLCOMPE , "
	_cSql	+=	"	          G1_OK ,      "
	_cSql	+=	"	          G1_YUM ,     "
	_cSql	+=	"	          D_E_L_E_T_ , "
	_cSql	+=	"	          R_E_C_N_O_ , "
	_cSql	+=	"	          R_E_C_D_E_L_ , "
	_cSql	+=	"	          G1_YDESCCD , "
	_cSql	+=	"	          G1_YDESCCP , "
	_cSql	+=	"	          G1_YMISTUR , "
	_cSql	+=	"	          G1_YQTDREF , "
	_cSql	+=	"	          G1_YUNIDRF , "
	_cSql	+=	"	          G1_YMOAGEM , "
	_cSql	+=	"	          G1_YSEQIMP , "
	_cSql	+=	"	          G1_YDADOSF , "
	_cSql	+=	"	          G1_YTAG ,    "
	_cSql	+=	"	          G1_VECTOR ,  "
	_cSql	+=	"	          G1_TIPVEC    "
	_cSql	+=	"	        )              "
	_cSql	+=	"	        SELECT  G1_FILIAL ,         "
	_cSql	+=	"	                SB1.B1_COD G1_COD ,  "
	_cSql	+=	"	                G1_COMP ,           "
	_cSql	+=	"	                CASE WHEN G1_TRT = '   ' THEN G1_TRT         "
	_cSql	+=	"	                     ELSE B1_REVATU                         "
	_cSql	+=	"	                END G1_TRT ,                                 "
	_cSql	+=	"	                G1_QUANT ,                                   "
	_cSql	+=	"	                G1_PERDA ,                                   "
	_cSql	+=						ValtoSql(MV_PAR03) + " G1_INI , 			 "  
	_cSql	+=	"	                G1_FIM ,                                     "
	_cSql	+=	"	                G1_NIV ,                                     "
	_cSql	+=	"	                G1_OBSERV ,                                  "
	_cSql	+=	"	                G1_FIXVAR ,                                  "
	_cSql	+=	"	                G1_NIVINV ,                                  "
	_cSql	+=	"	                G1_GROPC ,                                   "
	_cSql	+=	"	                CASE WHEN G1_REVINI = '   ' THEN G1_REVINI   "
	_cSql	+=	"	                     ELSE B1_REVATU                         "
	_cSql	+=	"	                END G1_REVINI ,                              "
	_cSql	+=	"	                G1_OPC ,                                     "
	_cSql	+=	"	                CASE WHEN G1_REVFIM = 'ZZZ' THEN 'ZZZ'       "
	_cSql	+=	"	                     WHEN G1_REVFIM = '   ' THEN G1_REVFIM   "
	_cSql	+=	"	                     ELSE B1_REVATU                         "
	_cSql	+=	"	                END G1_REVFIM ,                              "
	_cSql	+=	"	                G1_YEQUIPA ,                                 "
	_cSql	+=	"	                G1_YDENSID ,                                 "
	_cSql	+=	"	                G1_YVISCOS ,                                 "
	_cSql	+=	"	                G1_YCAMADA ,                                 "
	_cSql	+=	"	                G1_YINCESP ,                                 "
	_cSql	+=	"	                G1_YPRSESP ,                                 "
	_cSql	+=	"	                G1_YROLCIL ,                                 "
	_cSql	+=	"	                G1_YALTCIL ,                                 "
	_cSql	+=	"	                G1_POTENCI ,                                 "
	_cSql	+=	"	                G1_VLCOMPE ,                                 "
	_cSql	+=	"	                G1_OK ,                                      "
	_cSql	+=	"	                G1_YUM ,                                     "
	_cSql	+=	"	                SG1.D_E_L_E_T_ ,                             "
	_cSql	+=	"	                ( SELECT    MAX(R_E_C_N_O_)                  "
	_cSql	+=	"	                  FROM "+ RetSqlName("SG1") + "  "
	_cSql	+=	"	                ) + ROW_NUMBER() OVER ( ORDER BY SG1.R_E_C_N_O_ ) AS R_E_C_N_O_ ,  "
	_cSql	+=	"	                SG1.R_E_C_D_E_L_ ,  "
	_cSql	+=	"	                SUBSTRING(SB1.B1_DESC,1,70) G1_YDESCCD ,        "
	_cSql	+=	"	                G1_YDESCCP ,        "
	_cSql	+=	"	                G1_YMISTUR ,        "
	_cSql	+=	"	                G1_YQTDREF ,        "
	_cSql	+=	"	                G1_YUNIDRF ,        "
	_cSql	+=	"	                G1_YMOAGEM ,        "
	_cSql	+=	"	                G1_YSEQIMP ,        "
	_cSql	+=	"	                G1_YDADOSF ,        "
	_cSql	+=	"	                G1_YTAG ,           "
	_cSql	+=	"	                G1_VECTOR ,         "
	_cSql	+=	"	                G1_TIPVEC           "
	_cSql	+=	"	        FROM " + RETSQLNAME("SG1") + " SG1          "
	_cSql	+=	"	                LEFT JOIN " + RETSQLNAME("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	_cSql	+=	"	                                        AND B1_COD = " + ValtoSql(MV_PAR01)
	_cSql	+=	"	                                        AND SB1.D_E_L_E_T_ = ' '   "
	_cSql	+=	"	        WHERE   G1_FILIAL = " + ValtoSql(xFilial("SG1"))
	_cSql	+=	"	                AND G1_COD = " + ValtoSql(MV_PAR02)
	_cSql	+=	"	                AND " + ValtoSql(MV_PAR03) + " >= G1_INI                           "
	_cSql	+=	"	                AND "+ ValtoSql(MV_PAR03) + " <= G1_FIM                           "
	_cSql	+=	"	                AND SG1.D_E_L_E_T_ = ' '						   "
	_cSql	+=	"	                AND NOT EXISTS ( SELECT 1   "
	_cSql	+=	"	                                                 FROM  " +  RETSQLNAME("SG1") + " SG1NOVO "
	_cSql	+=	"	                                                 WHERE  SG1NOVO.G1_FILIAL = SB1.B1_COD    "
	_cSql	+=	"	                                                        AND SG1NOVO.G1_COD = SB1.B1_COD	  "
	_cSql	+=	"	                                                        AND SG1NOVO.D_E_L_E_T_ = '' )     "

	TcSqlExec(_cSql)

	MsgInfo("Revisão Copiada com Sucesso!")

return