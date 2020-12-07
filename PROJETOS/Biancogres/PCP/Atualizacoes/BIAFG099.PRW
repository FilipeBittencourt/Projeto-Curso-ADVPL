#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG099
@author Gabriel Rossi Mafioletti
@since 11/07/2019
@version 1.0
@description Rotina para alteração de quantidade de componentes de acordo com formato
@type function
/*/

User Function BIAFG099()
	Private cEnter := CHR(13)+CHR(10)

	If !ValidPerg()
		Return
	EndIf


	fProcessa()

Return

Static Function fProcessa()

	Local _cSql		:=	""
	Local _nError	:=	0
	Local lOk       := .T.
	Local sGravaErr := ""

	BEGIN TRANSACTION

		_cSql	:=	"	UPDATE SG1									"
		_cSql	+=	"	SET G1_QUANT = "+cValtoChar(MV_PAR03)+"					"
		_cSql	+=	"	FROM "+RetSqlName('SG1')+" SG1				"
		_cSql	+=	"	INNER JOIN "+RetSqlName('SB1')+" SB1 ON B1_COD = G1_COD	"
		_cSql	+=	"		AND B1_YFORMAT = "+ValtoSql(MV_PAR01)+"				"
		DO CASE
			CASE MV_PAR05 == "1"
				_cSql	+=	"		AND B1_YESPESS = "+ValtoSql(MV_PAR06)+"	"
			Case MV_PAR05 == "2"
				_cSql	+=	"		AND B1_YESPESS <> "+ValtoSql(MV_PAR06)+"	"
		EndCase
		_cSql	+=	"		AND SB1.D_E_L_E_T_ = ' '	"
		_cSql	+=	"	WHERE G1_FILIAL = "+ValtoSql(xFilial('SG1'))+"	"
		_cSql	+=	"		AND G1_COMP = "+ValtoSql(MV_PAR02)+"	"
		_cSql	+=	"		AND SG1.D_E_L_E_T_ = ' '	"

		U_BIAMsgRun("Aguarde... Atualizando a tabela de estruturas... ","BIAFG099",{|| _nError := TcSQLExec(_cSql) })
	
		If _nError <> 0
			//MsgInfo("Ocorreu um erro ao atualizar a tabela de estruturas!","BIAFG099")
			lOk       := .F.
			sGravaErr := TCSQLError()
			DisarmTransaction()
			Return
		EndIf

        if lOk        
			_cSql	:=	"	UPDATE SD4	"												
			_cSql	+=	"	SET D4_QTDEORI = ROUND(C2_QUANT * "+cValToChar(MV_PAR04)+", 8)	"
			_cSql	+=	"		,D4_QUANT = ROUND((C2_QUANT - C2_QUJE) * "+cValToChar(MV_PAR04)+", 8)	"	
			_cSql	+=	"	FROM "+RetSqlName('SD4')+" SD4	"
			_cSql	+=	"	INNER JOIN "+RetSqlName('SC2')+" SC2 ON C2_FILIAL = "+ValtoSql(xfilial('SC2'))+"	"
			_cSql	+=	"		AND C2_NUM = SUBSTRING(D4_OP, 1, 6)	"
			_cSql	+=	"		AND C2_ITEM = SUBSTRING(D4_OP, 7, 2)	"
			_cSql	+=	"		AND C2_SEQUEN = SUBSTRING(D4_OP, 9, 3)	"
			_cSql	+=	"		AND C2_DATRF = '        '	"
			_cSql	+=	"		AND SC2.D_E_L_E_T_ = ' '	"
			_cSql	+=	"	INNER JOIN "+RetSqlName('SB1')+" SB1 ON B1_COD = C2_PRODUTO	"
			_cSql	+=	"		AND B1_YFORMAT = "+ValtoSql(MV_PAR01)+"	"
			DO CASE
				CASE MV_PAR05 == "1"
					_cSql	+=	"		AND B1_YESPESS = "+ValtoSql(MV_PAR06)+"	"
				Case MV_PAR05 == "2"
					_cSql	+=	"		AND B1_YESPESS <> "+ValtoSql(MV_PAR06)+"	"
			EndCase
			_cSql	+=	"		AND SB1.D_E_L_E_T_ = ' '	"
			_cSql	+=	"	WHERE D4_FILIAL = "+ValtoSql(xFilial('SD4'))+"	"
			_cSql	+=	"		AND D4_COD = "+ValtoSql(MV_PAR02)+"	"
			_cSql	+=	"		AND SD4.D_E_L_E_T_ = ' '	"
			
			_nError	:=	TcSqlExec(_cSql)
			U_BIAMsgRun("Aguarde... Atualizando a tabela de empenhos... ",,{|| _nError := TcSQLExec(_cSql) })
	
			If _nError <> 0
				//MsgInfo("Ocorreu um erro ao atualizar a tabela de empenhos!","BIAFG099")
				sGravaErr := TCSQLError()
				lOk := .F.
				DisarmTransaction()
				Return
			EndIf
		EndIf	
	END TRANSACTION
	
	if lOk
		Aviso('BIAFG099',"Alteração Realizada com sucesso!", {'Fecha'}, 3)
	Else
		Aviso('BIAFG099', "Erro na execução do processamento: " + cEnter + sGravaErr + cEnter + "Processo Cancelado!!!" + cEnter , {'Fecha'}, 3 )
	endif

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG099" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aOpcs 	:= {"1=Igual A","2=Diferente De","3=Todas"}
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(2)
	MV_PAR02 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR03 := 0
	MV_PAR04 := 0
	MV_PAR05 := "1"
	MV_PAR06 := SPACE(3)

	aAdd( aPergs ,{1,"Formato " 	   		,MV_PAR01 ,""  ,"NAOVAZIO() .And. ExistCpo('ZZ6')",'ZZ6'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Massa   " 	   		,MV_PAR02 ,""  ,"NAOVAZIO() .And. ExistCpo('SB1')",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Peso Estr. " 	   		,MV_PAR03 ,"@E 999.99999999"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Peso Emp. " 	   		,MV_PAR04 ,"@E 999.99999999"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Condição" 	,MV_PAR05 ,aOpcs,60,'.T.',.F.})	
	aAdd( aPergs ,{1,"Espessura" 	   		,MV_PAR06 ,""  ,"",''  ,'MV_PAR05 <> "3"',50,.F.})
	

	If ParamBox(aPergs ,"Alteração de quantidade de componentes de acordo com formato",,/*{|| U_BFG099OK()}*/,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

	EndIf

Return lRet

User Function BFG099MA()

	Local _lRet	:=	.F.
	Local _aArea	:=	GetArea()
	
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+MV_PAR02)) .And. SB1->B1_GRUPO == "PI01" .And. SB1->B1_TIPO == "PI"
		_lRet	:=	.T.
	Else
		MsgInfo("O produto Informado não existe ou não é uma Massa!","BIAFG099")
		_lRet	:=	.F.
	EndIf
	RestArea(_aArea)
Return _lRet