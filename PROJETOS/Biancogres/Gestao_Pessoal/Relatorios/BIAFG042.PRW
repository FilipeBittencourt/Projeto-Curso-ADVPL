#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG042
@author Gabriel Rossi Mafioletti
@since 21/05/2018
@version 1.0
@description Relatório de Saldos Por Funcionário
@type function
/*/

User Function BIAFG042()

	Local oReport
	Local _aPars	:=	{MV_PAR01,MV_PAR02,MV_PAR03}

	If Validperg()
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf

	MV_PAR01	:=	_aPars[1]
	MV_PAR02	:=	_aPars[2]
	MV_PAR03	:=	_aPars[3]

Return

Static Function ReportDef()

	Local cTitulo	:=	"Relatório de Controle de Eventos"
	Local oReport := TReport():New(cTitulo,"Controle de Eventos", , {|oReport| PrintReport(oReport)},"Controle de Eventos")	

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport,OemToAnsi("Saldos"),)    
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"MAT"	        ,/**/, "Matrícula"		          ,/**/               ,07,/**/	)
	TRCell():New(oSection1,"NOME"			,/**/, "Nome"			          ,/**/               ,30,/**/	)
	TRCell():New(oSection1,"SLDINI"			,/**/, "Saldo Inicial"			  ,"@E 999,999,999.99",15,/**/	)
	TRCell():New(oSection1,"CREDITO"		,/**/, "Crédito"				  ,"@E 999,999,999.99",15,/**/	)
	TRCell():New(oSection1,"DEBITO"			,/**/, "Débito"					  ,"@E 999,999,999.99",15,/**/	)
	TRCell():New(oSection1,"SLDFIN"			,/**/, "Saldo Final"			  ,"@E 999,999,999.99",15,/**/	)

	//TRFUNCTION():New(oCell				,cName ,cFunction ,oBreak, cTitle		, cPicture, uFormula   ,lEndSection,lEndReport    ,lEndPage,oParent,bCondition,lDisable,bCanPrint) 	
	oFuncao := TRFunction():New(oSection1:Cell("SLDINI") ,NIL,"SUM")
	oFuncao := TRFunction():New(oSection1:Cell("CREDITO"),NIL,"SUM")
	oFuncao := TRFunction():New(oSection1:Cell("DEBITO") ,NIL,"SUM")
	oFuncao := TRFunction():New(oSection1:Cell("SLDFIN") ,NIL,"SUM")
	oFuncao:SetTotalText("Saldo Final")
	oFuncao:ShowFooter()

Return oReport

Static Function PrintReport(oReport)

	Local oSection1 :=	oReport:Section(1)
	Local _cAlias	:=	GetNextAlias()
	Local _cPerAnt	:=	DtoS(DaySub(Stod(MV_PAR01 + "01"),1))
	Local _cPerLike	:=	MV_PAR01 + '%'

	BeginSql Alias _cAlias

	SELECT *
	,SLDFIM.SLDINI + SLDFIM.CREDITO + SLDFIM.DEBITO SLDFIM
	FROM (
	SELECT *
	,ISNULL((
	SELECT SUM(ZCE_VALOR)
	FROM ZCE010 ZCECRED
	WHERE ZCECRED.ZCE_FILIAL = %XFILIAL:ZCE%
	AND ZCECRED.ZCE_MAT = SLDINI.ZCE_MAT
	AND ZCECRED.ZCE_DATA LIKE %Exp:_cPerLike%
	AND ZCECRED.%NotDel%
	AND ZCECRED.ZCE_OPERAC = 'C'
	), 0) AS CREDITO
	,ISNULL((
	SELECT SUM(ZCE_VALOR)
	FROM ZCE010 ZCECRED
	WHERE ZCECRED.ZCE_FILIAL = %XFILIAL:ZCE%
	AND ZCECRED.ZCE_MAT = SLDINI.ZCE_MAT
	AND ZCECRED.ZCE_DATA LIKE %Exp:_cPerLike%
	AND ZCECRED.%NotDel%
	AND ZCECRED.ZCE_OPERAC = 'D'
	), 0) AS DEBITO
	FROM (
	SELECT ZCE_FILIAL
	,ZCE_MAT
	,ZCE_VALOR SLDINI
	FROM ZCE010
	WHERE ZCE_FILIAL = %xFILIAL:ZCE%
	AND ZCE_DATA = %Exp:_cPerAnt%
	AND ZCE_TABORI = 'FIM'
	AND ZCE_MAT BETWEEN ''
	AND 'ZZZZZZ'
	AND %NotDel%

	UNION

	SELECT ZCE_FILIAL
	,ZCE_MAT
	,0
	FROM ZCE010 ZCE
	WHERE ZCE_MAT BETWEEN %EXP:MV_PAR02%
	AND %Exp:MV_PAR03%
	AND ZCE_DATA LIKE %Exp:_cPerLike%
	AND %NotDel%
	AND ZCE_TABORI <> 'FIM'
	AND NOT EXISTS (
	SELECT 1
	FROM ZCE010 ZCEANT
	WHERE ZCEANT.ZCE_FILIAL = %XFILIAL:ZCE%
	AND ZCEANT.ZCE_DATA = %Exp:_cPerAnt%
	AND ZCEANT.ZCE_TABORI = 'FIM'
	AND ZCEANT.ZCE_MAT = ZCE.ZCE_MAT
	AND ZCEANT.%NotDel%
	)
	) SLDINI
	) SLDFIM

	EndSql

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	oReport:SetMeter((_cAlias)->(RecCount()))

	If (_cAlias)->(!EOF())

		oReport:PrintText("Período " + Transform(MV_PAR01,"@R 9999/99"),,10)
		oReport:THINLINE()
		oReport:PrintText("")
		oReport:PrintText("")

		While (_cAlias)->(!EOF())

			oReport:IncMeter()
			oSection1 := oReport:Section(1)
			oSection1:Init()

			oSection1:Cell("MAT"	        ):SetValue((_cAlias)->ZCE_MAT)
			oSection1:Cell("MAT"	        ):SetAlign("CENTER")
			oSection1:Cell("NOME"		    ):SetValue(POSICIONE("SRA",1,xFilial("SRA") + (_cAlias)->ZCE_MAT,"RA_NOME"))
			oSection1:Cell("NOME"		    ):SetAlign("LEFT")
			oSection1:Cell("SLDINI"			):SetValue((_cAlias)->SLDINI)
			oSection1:Cell("SLDINI"			):SetAlign("RIGHT")
			oSection1:Cell("CREDITO"		):SetValue((_cAlias)->CREDITO)
			oSection1:Cell("CREDITO"		):SetAlign("RIGHT")
			oSection1:Cell("DEBITO"			):SetValue((_cAlias)->DEBITO)
			oSection1:Cell("DEBITO"			):SetAlign("RIGHT")
			oSection1:Cell("SLDFIN"			):SetValue((_cAlias)->SLDFIM)
			oSection1:Cell("SLDFIN"			):SetAlign("RIGHT")
			oSection1:PrintLine()

			(_cAlias)->(DbSkip())

		EndDo

	EndIf

	(_cAlias)->(DbCloseArea())

	oSection1:Finish()

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG042" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(6)
	MV_PAR02 := SPACE(6)
	MV_PAR03 := SPACE(6)

	aAdd( aPergs ,{1,"Ano/Mês " 	  			,MV_PAR01 ,"@R 9999/99"  ,"U_BFG40VLD()",''  ,'.T.',50,.T.})	
	aAdd( aPergs ,{1,"Matrícula De " 	   		,MV_PAR02 ,""            ,""            ,''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matrícula Até " 	   		,MV_PAR03 ,""            ,"NAOVAZIO()"  ,''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Relatório de Controle de Eventos",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

	EndIf

Return lRet
