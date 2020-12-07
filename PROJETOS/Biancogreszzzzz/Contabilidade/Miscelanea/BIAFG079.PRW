#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG079
@author Gabriel Rossi Mafioletti
@since 07/01/2019
@version 1.0
@description Consulta Padrão de Driver
@type function
/*/

User Function BIAFG079()

	Local aArea   		:= GetArea()
	Local cTitulo	:=	"Consulta Driver"
	Local cQuery	:=	""
	Local nTamCpo	:=	9
	Local cCodigo	:=	&(ReadVar())
	Local cCpoChave	:=	"ZBZ_DRIVER"
	Local cTitCampo	:=	"Driver"
	Local cMascara	:=	"@!"
	Local cRetCpo	:=	"uCRet1"
	Local nColuna		:= 1
	Local cAlias	:=	"ZBZ"
	Local aColsPesq		:= {1,2}
	Local cCpo		:=	ReadVar()

	Local _cClVl	:=	""
	Local _cAnoref	:=	""
	Local _cCtaDe	:=	""
	Local _cCtaAte	:=	""
	Local _cConta	:=	""
	Local _cProd	:=	""

	Private bRet	:=	.F.
	Public uCRet1	:=  ""

	Do Case
		CASE cCpo == "M->D3_YDRIVER"
		If ISINCALLSTACK("MATA241") //Movimentos Múltiplos
			_cClvl		:=	aCV[1][2]
			_cAnoRef	:=	SUBSTR(DtoS(dA241Data),1,4)	
			_cConta		:=	GdFieldGet("D3_CONTA",n)
		Else
			_cClvl		:=	M->D3_CLVL
			_cAnoRef	:=	SUBSTR(DtoS(M->D3_EMISSAO),1,4)	
			_cConta		:=	M->D3_CONTA
		EndIf
		CASE cCpo == "M->D1_YDRIVER"
		_cClvl		:=	GdFieldGet("D1_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(dDataBase),1,4)	
		_cConta		:=	GdFieldGet("D1_CONTA",n)
		CASE cCpo == "M->C1_YDRIVER"
		_cClvl		:=	GdFieldGet("C1_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(DA110DATA),1,4)	
		_cConta		:=	GdFieldGet("C1_CONTA",n)
		CASE cCpo == "M->C7_YDRIVER"
		_cClvl		:=	GdFieldGet("C7_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(DA120EMIS),1,4)	
		_cConta		:=	GdFieldGet("C7_CONTA",n)
		CASE cCpo == "M->E5_YDRVDB"
		_cClvl		:=	M->E5_CLVLDB
		_cAnoRef	:=	SUBSTR(DtoS(M->E5_DATA),1,4)	
		_cConta		:=	M->E5_DEBITO
		CASE cCpo == "M->E5_YDRVCR"
		_cClvl		:=	M->E5_CLVLCR
		_cAnoRef	:=	SUBSTR(DtoS(M->E5_DATA),1,4)	
		_cConta		:=	M->E5_CREDITO
		CASE cCpo == "M->CT2_YDRVDB"
		_cClvl		:=	TMP->CT2_CLVLDB
		_cAnoRef	:=	SUBSTR(DtoS(dDataLanc),1,4)	
		_cConta		:=	TMP->CT2_DEBITO
		CASE cCpo == "M->CT2_YDRVCR"
		_cClvl		:=	TMP->CT2_CLVLCR
		_cAnoRef	:=	SUBSTR(DtoS(dDataLanc),1,4)	
		_cConta		:=	TMP->CT2_CREDITO
		CASE cCpo == "M->ZJ_YDRIVER"
		_cClvl		:=	GdFieldGet("ZJ_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(M->ZI_EMISSAO),1,4)	
		_cProd		:=	GdFieldGet("ZJ_COD",n)

		DbSelectArea("CTH")
		CTH->(DbSetOrder(1))
		If CTH->(DbSeek(xFilial("CTH")+_cClvl))
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+_cProd))
				IF CTH->CTH_YATRIB	== "C"
					_cConta	:=	SB1->B1_YCTRIND
				ElseIf CTH->CTH_YATRIB	== "D"
					_cConta	:=	SB1->B1_YCTRADM
				EndIf
			EndIf
		EndIF		

		OtherWise
		MsgInfo("Campo Driver não Cadastrado para consulta. Favor Procurar a TI!")
		RestArea(aArea)
		Return .T.

	EndCase

	_cCtaDe		:=	_cConta
	_cCtaAte	:=	_cConta

	cQuery	:=	"	SELECT DISTINCT ZBE_DRIVER	"
	cQuery	+=	"		,ZBE_DESCRI	"
	cQuery	+=	"	FROM (	"
	cQuery	+=	"		SELECT ZBZ.ZBZ_VERSAO VERSAO	"
	cQuery	+=	"			,ZBZ_REVISA REVISA	"
	cQuery	+=	"			,ZBZ_ANOREF ANO	"
	cQuery	+=	"			,ZBZ_CLVLDB CLVL	"
	cQuery	+=	"			,ZBZ_DRVDB DRIVER	"
	cQuery	+=	"		FROM "+RETSQLNAME("ZBZ")+" ZBZ(NOLOCK)	"
	cQuery	+=	"		WHERE ZBZ_ANOREF = "+ValtoSql(_cAnoRef)+"	"
	cQuery	+=	"			AND ZBZ.D_E_L_E_T_ = ''	"
	cQuery	+=	"			AND ZBZ_DEBITO <> ''	"
	cQuery	+=	"			AND ZBZ_CLVLDB <> ''	"
	cQuery	+=	"		UNION	"
	cQuery	+=	"		SELECT ZBZ_VERSAO	"
	cQuery	+=	"			,ZBZ_REVISA	"
	cQuery	+=	"			,ZBZ_ANOREF	"
	cQuery	+=	"			,ZBZ_CLVLCR	"
	cQuery	+=	"			,ZBZ_DRVCR	"
	cQuery	+=	"		FROM "+RETSQLNAME("ZBZ")+" ZBZ(NOLOCK)	"
	cQuery	+=	"		WHERE ZBZ_ANOREF = "+ValtoSql(_cAnoRef)+"	"
	cQuery	+=	"			AND ZBZ.D_E_L_E_T_ = ''	"
	cQuery	+=	"			AND ZBZ_CREDIT <> ''	"
	cQuery	+=	"			AND ZBZ_CLVLCR <> ''	"
	cQuery	+=	"		) CLASSES	"
	cQuery	+=	"	JOIN "+RETSQLNAME("ZBE")+" ZBE ON ZBE.ZBE_DRIVER = CLASSES.DRIVER	"
	cQuery	+=	"		AND ZBE.ZBE_VERSAO = CLASSES.VERSAO	"
	cQuery	+=	"		AND ZBE.ZBE_REVISA = CLASSES.REVISA	"
	cQuery	+=	"		AND ZBE.ZBE_ANOREF = CLASSES.ANO	"
	cQuery	+=	"		AND ZBE.D_E_L_E_T_ = ''	"
	cQuery	+=	"	WHERE CLASSES.DRIVER <> ''	"
	cQuery	+=	"		AND CLASSES.CLVL = "+ValtoSql(_cClvl)+"	"
	cQuery	+=	"		AND CLASSES.REVISA = (	"
	cQuery	+=	"			SELECT MAX(ZBZ_REVISA)	"
	cQuery	+=	"			FROM "+RETSQLNAME("ZBZ")+" ZBZREV	"
	cQuery	+=	"			WHERE ZBZREV.ZBZ_VERSAO = CLASSES.VERSAO	"
	cQuery	+=	"				AND ZBZREV.ZBZ_ANOREF = CLASSES.ANO	"
	cQuery	+=	"				AND ZBZREV.D_E_L_E_T_ = ''	"
	cQuery	+=	"			)	"

	cQuery	+=	"	UNION													"
	cQuery	+=	"	SELECT ZBE_DRIVER                                       "
	cQuery	+=	"		,ZBE_DESCRI                                         "
	cQuery	+=	"	FROM "+RETSQLNAME("ZBE")+" ZBE                                         "
	cQuery	+=	"	JOIN "+RETSQLNAME("ZBN")+" ZBN ON ZBE.ZBE_FILIAL = ''                  "
	cQuery	+=	"		AND ZBN.ZBN_FILIAL = "+ValtoSql(xFilial("ZBN"))+"   "
	cQuery	+=	"		AND ZBE.ZBE_VERSAO = ZBN.ZBN_VERSAO                 "
	cQuery	+=	"		AND ZBE.ZBE_REVISA = ZBN.ZBN_REVISA                 "
	cQuery	+=	"		AND ZBE.ZBE_ANOREF = ZBN.ZBN_ANOREF                 "
	cQuery	+=	"		AND ZBE.ZBE_DRIVER = ZBN.ZBN_DRIVER                 "
	cQuery	+=	"		AND ZBE.ZBE_ANOREF = "+ValtoSql(_cAnoRef)+"	"
	cQuery	+=	"		AND ZBE.ZBE_REVISA = (                              "
	cQuery	+=	"			SELECT MAX(ZBE_REVISA)                          "
	cQuery	+=	"			FROM "+RETSQLNAME("ZBE")+" ZBEREV                              "
	cQuery	+=	"			WHERE ZBEREV.ZBE_FILIAL = "+ValtoSql(xFilial("ZBE"))+"   "
	cQuery	+=	"				AND ZBEREV.ZBE_VERSAO = ZBE.ZBE_VERSAO      "
	cQuery	+=	"				AND ZBEREV.ZBE_ANOREF = ZBE.ZBE_ANOREF      "
	cQuery	+=	"				AND ZBEREV.D_E_L_E_T_ = ''                  "
	cQuery	+=	"			)                                               "
	cQuery	+=	"		AND ZBN.ZBN_CLVL = "+ValtoSql(_cClvl)+"	"
	cQuery	+=	"		AND ZBN.D_E_L_E_T_ = ''                             "
	cQuery	+=	"		AND ZBE.D_E_L_E_T_ = ''                             "

	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna,aColsPesq)

	RestArea(aArea)

Return .T.

/*Valida se o driver é permitido apra Classe de Valor x Conta*/
User Function BFG79VLD()

	Local _lRet	:=	.T.
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()

	Local cCpo		:=	ReadVar()

	Local _cClVl	:=	""
	Local _cAnoref	:=	""
	Local _cCtaDe	:=	""
	Local _cCtaAte	:=	""
	Local _cConta	:=	""
	Local _cDriver	:=	""
	Local _cProd	:=	""

	Do Case
		CASE cCpo == "M->D3_YDRIVER"
		If ISINCALLSTACK("MATA241") //Movimentos Múltiplos
			_cClvl		:=	aCV[1][2]
			_cAnoRef	:=	SUBSTR(DtoS(dA241Data),1,4)	
			_cConta		:=	GdFieldGet("D3_CONTA",n)
			_cDriver	:=	M->D3_YDRIVER
		Else
			_cClvl		:=	M->D3_CLVL
			_cAnoRef	:=	SUBSTR(DtoS(M->D3_EMISSAO),1,4)	
			_cConta		:=	M->D3_CONTA
			_cDriver	:=	M->D3_YDRIVER
		EndIf
		CASE cCpo == "M->D1_YDRIVER"
		_cClvl		:=	GdFieldGet("D1_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(dDataBase),1,4)	
		_cConta		:=	GdFieldGet("D1_CONTA",n)
		_cDriver	:=	M->D1_YDRIVER
		CASE cCpo == "M->C1_YDRIVER"
		_cClvl		:=	GdFieldGet("C1_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(DA110DATA),1,4)	
		_cConta		:=	GdFieldGet("C1_CONTA",n)
		_cDriver	:=	M->C1_YDRIVER
		CASE cCpo == "M->C7_YDRIVER"
		_cClvl		:=	GdFieldGet("C7_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(DA120EMIS),1,4)	
		_cConta		:=	GdFieldGet("C7_CONTA",n)
		_cDriver	:=	M->C7_YDRIVER
		CASE cCpo == "M->E5_YDRVDB"
		_cClvl		:=	M->E5_CLVLDB
		_cAnoRef	:=	SUBSTR(DtoS(M->E5_DATA),1,4)	
		_cConta		:=	M->E5_DEBITO
		_cDriver	:=	M->E5_YDRVDB
		CASE cCpo == "M->E5_YDRVCR"
		_cClvl		:=	M->E5_CLVLCR
		_cAnoRef	:=	SUBSTR(DtoS(M->E5_DATA),1,4)	
		_cConta		:=	M->E5_CREDITO
		_cDriver	:=	M->E5_YDRVCR
		CASE cCpo == "M->CT2_YDRVDB"
		_cClvl		:=	TMP->CT2_CLVLDB
		_cAnoRef	:=	SUBSTR(DtoS(dDataLanc),1,4)	
		_cConta		:=	TMP->CT2_DEBITO
		_cDriver	:=	M->CT2_YDRVDB
		CASE cCpo == "M->CT2_YDRVCR"
		_cClvl		:=	TMP->CT2_CLVLCR
		_cAnoRef	:=	SUBSTR(DtoS(dDataLanc),1,4)	
		_cConta		:=	TMP->CT2_CREDITO
		_cDriver	:=	M->CT2_YDRVCR
		CASE cCpo == "M->ZJ_YDRIVER"
		_cClvl		:=	GdFieldGet("ZJ_CLVL",n)
		_cAnoRef	:=	SUBSTR(DtoS(M->ZI_EMISSAO),1,4)		
		_cDriver	:=	M->ZJ_YDRIVER
		_cProd		:=	GdFieldGet("ZJ_COD",n)

		DbSelectArea("CTH")
		CTH->(DbSetOrder(1))
		If CTH->(DbSeek(xFilial("CTH")+_cClvl))
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+_cProd))
				IF CTH->CTH_YATRIB	== "C"
					_cConta	:=	SB1->B1_YCTRIND
				ElseIf CTH->CTH_YATRIB	== "D"
					_cConta	:=	SB1->B1_YCTRADM
				EndIf
			EndIf
		EndIF
	EndCase

	_cCtaDe		:=	_cConta
	_cCtaAte	:=	_cConta

	If !U_BFG81VCL(_cClVl) .Or. !U_BFG81VCO(_cConta)
		RestArea(_aArea)
		Return .T.
	EndIf

	BeginSql Alias _cAlias
		%NoParser%
		SELECT COUNT(*) QTD
		FROM(
		SELECT DISTINCT ZBE_DRIVER	
		,ZBE_DESCRI	
		FROM (	
		SELECT ZBZ.ZBZ_VERSAO VERSAO	
		,ZBZ_REVISA REVISA	
		,ZBZ_ANOREF ANO	
		,ZBZ_CLVLDB CLVL	
		,ZBZ_DRVDB DRIVER	
		FROM %TABLE:ZBZ% ZBZ(NOLOCK)	
		WHERE ZBZ_ANOREF = %Exp:_cAnoRef%	
		AND ZBZ.%NotDel%
		AND ZBZ_DEBITO <> ''	
		AND ZBZ_CLVLDB <> ''	
		UNION	
		SELECT ZBZ_VERSAO	
		,ZBZ_REVISA	
		,ZBZ_ANOREF	
		,ZBZ_CLVLCR	
		,ZBZ_DRVCR	
		FROM %TABLE:ZBZ% ZBZ(NOLOCK)	
		WHERE ZBZ_ANOREF = %Exp:_cAnoRef%	
		AND ZBZ.%NotDel%	
		AND ZBZ_CREDIT <> ''	
		AND ZBZ_CLVLCR <> '' ) CLASSES	
		JOIN %TABLE:ZBE% ZBE ON ZBE.ZBE_DRIVER = CLASSES.DRIVER	
		AND ZBE.ZBE_VERSAO = CLASSES.VERSAO	
		AND ZBE.ZBE_REVISA = CLASSES.REVISA	
		AND ZBE.ZBE_ANOREF = CLASSES.ANO	
		AND ZBE.%NotDel%	
		WHERE CLASSES.DRIVER <> ''	
		AND CLASSES.CLVL = %Exp:_cClvl%	
		AND CLASSES.REVISA = (	
		SELECT MAX(ZBZ_REVISA)	
		FROM %TABLE:ZBZ% ZBZREV	
		WHERE ZBZREV.ZBZ_VERSAO = CLASSES.VERSAO	
		AND ZBZREV.ZBZ_ANOREF = CLASSES.ANO	
		AND ZBZREV.%NotDel%	)	
		UNION													
		SELECT ZBE_DRIVER                                       
		,ZBE_DESCRI                                         
		FROM %TABLE:ZBE% ZBE                                         
		JOIN %TABLE:ZBN% ZBN ON ZBN.ZBN_FILIAL = %XFILIAL:ZBN%   
		AND ZBE.ZBE_VERSAO = ZBN.ZBN_VERSAO                 
		AND ZBE.ZBE_REVISA = ZBN.ZBN_REVISA                 
		AND ZBE.ZBE_ANOREF = ZBN.ZBN_ANOREF                 
		AND ZBE.ZBE_DRIVER = ZBN.ZBN_DRIVER                 
		AND ZBE.ZBE_ANOREF = %Exp:_cAnoRef%	
		AND ZBE.ZBE_REVISA = (                              
		SELECT MAX(ZBE_REVISA)                          
		FROM %TABLE:ZBE% ZBEREV                              
		WHERE ZBEREV.ZBE_FILIAL = %XFILIAL:ZBE%   
		AND ZBEREV.ZBE_VERSAO = ZBE.ZBE_VERSAO      
		AND ZBEREV.ZBE_ANOREF = ZBE.ZBE_ANOREF      
		AND ZBEREV.%NotDel%                  
		)                                               
		AND ZBN.ZBN_CLVL = %Exp:_cClvl%	
		AND ZBN.%NotDel%                             
		AND ZBE.%NotDel%                             
		)DRIVER
		WHERE DRIVER.ZBE_DRIVER = %Exp:_cDriver%

	EndSql

	If (_cAlias)->QTD == 0

		_lRet	:=	.F.
		MsgInfo("Driver não Encontrado para a combinação de Conta e Classe de Valor!", "BIAFG079")

	EndIf 

	(_cAlias)->(DbCloseArea())

	RestArea(_aArea)

Return _lRet
