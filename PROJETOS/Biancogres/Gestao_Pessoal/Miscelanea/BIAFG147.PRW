#include "rwmake.ch"

/*/{Protheus.doc} BIAFG147
@author Gabriel Rossi Mafioletti
@since 17/09/20
@version 1.1
@description Tela de Fracionamento de Férias  
@type function
/*/                                                                                               

User Function BIAFG147()

	Private aRotina   := {}
	Private cCadastro := "Fracionamento de Férias"
	Private cAlias    := "ZOJ"
	Private msrhEnter := CHR(13) + CHR(10)

	aAdd(aRotina, {"Pesquisar"       , "PesqBrw"   , 0, 1})
	aAdd(aRotina, {"Visualizar"      , "AxVisual"  , 0, 2})
	aAdd(aRotina, {"Incluir"         , "AxInclui"  , 0, 3})
	aAdd(aRotina, {"Alterar"         , "AxAltera"  , 0, 4})
	aAdd(aRotina, {"Excluir"         , "AxDeleta"  , 0, 5})
	aAdd(aRotina, {"Processar"       , "U_BFG147A" , 0, 3})

	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()

User Function BFG147A()

	Local M001        := GetNextAlias()

	If !Validperg()
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!", "Atenção!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!", "Atenção!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	Processa({ || cMsg := U_BFG147B(_cVersao,_cRevisa,_cAnoRef) }, "Aguarde...", "Processando Integração...",.F.)

Return

User Function BFG147B(_cVersao,_cRevisa,_cAnoRef)

	Local _cAlias	:=	GetNextAlias()
	Local _nEmp		:=	Val(cEmpAnt)
	Local _aCalend	:=	{}
	Local _cAliasSr	:=	"%" + U_fGetDbSr() + ".dbo.r040prg" + "%"

	Local _cQuery   := ""

	_cQuery	    :=	" DELETE FROM " + RetSqlName("ZOJ")
	_cQuery		+=	" WHERE ZOJ_FILIAL = " + ValToSql(xFilial("ZOJ"))
	_cQuery		+=	" 	AND ZOJ_VERSAO = " + ValToSql(_cVersao)
	_cQuery		+=	" 	AND ZOJ_REVISA = " + ValToSql(_cRevisa)
	_cQuery		+=	" 	AND ZOJ_ANOREF = " + ValToSql(_cAnoRef)
	_cQuery		+=	" 	AND D_E_L_E_T_ = ''

	TcSqlExec(_cQuery)

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ZO0.ZO0_MAT MATRIC
		,CONVERT(VARCHAR(8), prg.prgdat, 112) DTINI
		,prg.prgdfe DIAS
		FROM %TABLE:ZO0% ZO0(NOLOCK)
		INNER JOIN %Exp:_cAliasSr% prg ON numemp = %Exp:_nEmp%
		AND tipcol = 1
		AND numcad = ZO0_MAT
		AND prgdat BETWEEN ZO0_ANOREF + '-01-01 00:00:00.000'
		AND ZO0_ANOREF + '-12-31 23:59:59.999'
		WHERE ZO0_FILIAL = %XFILIAL:ZO0%
		AND ZO0_VERSAO = %Exp:_cVersao%
		AND ZO0_REVISA = %Exp:_cRevisa%
		AND ZO0_ANOREF = %Exp:_cAnoRef%
		AND %NotDel%
	EndSql

	While (_cAlias)->(!EOF())

		_aCalend	:=	fCalend(StoD((_cAlias)->DTINI),(_cAlias)->DIAS)

		DbSelectArea("ZOJ")
		ZOJ->(DbSetOrder(1))
		If ZOJ->(DbSeek(xFilial("ZOJ")+PADR(_cVersao,TamSx3("ZOJ_VERSAO")[1])+;
		PADR(_cRevisa,TamSx3("ZOJ_REVISA")[1])+;
		PADR(_cAnoref,TamSx3("ZOJ_ANOREF")[1])+;
		(_cAlias)->MATRIC))

			Reclock("ZOJ",.F.)
		Else

			Reclock("ZOJ",.T.)

			ZOJ->ZOJ_FILIAL	:=	xFilial("ZOJ")
			ZOJ->ZOJ_VERSAO	:=	_cVersao
			ZOJ->ZOJ_REVISA	:=	_cRevisa
			ZOJ->ZOJ_ANOREF	:=	_cAnoRef
			ZOJ->ZOJ_MAT	:=	(_cAlias)->MATRIC

		EndIf

		ZOJ->ZOJ_MES01	+= 	_aCalend[1]	
		ZOJ->ZOJ_MES02	+=	_aCalend[2]
		ZOJ->ZOJ_MES03	+=	_aCalend[3]
		ZOJ->ZOJ_MES04	+=	_aCalend[4]
		ZOJ->ZOJ_MES05	+=	_aCalend[5]
		ZOJ->ZOJ_MES06	+=	_aCalend[6]
		ZOJ->ZOJ_MES07	+=	_aCalend[7]
		ZOJ->ZOJ_MES08	+=	_aCalend[8]
		ZOJ->ZOJ_MES09	+=	_aCalend[9]
		ZOJ->ZOJ_MES10	+=	_aCalend[10]
		ZOJ->ZOJ_MES11	+=	_aCalend[11]
		ZOJ->ZOJ_MES12	+=	_aCalend[12]


		ZOJ->(MsUnlock())

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fCalend(_dDtIni,_nDias)

	Local _aCalend	:=	{0,0,0,0,0,0,0,0,0,0,0,0}
	Local _nI
	Local _dDataAtu	:=	_dDtIni

	For _nI	:= 1 to _nDias

		If Year(_dDtIni) == Year(_dDataAtu)
			_aCalend[Month(_dDataAtu)]++
		EndIf

		_dDataAtu	:=	DaySum(_dDataAtu,1)

	Next

Return _aCalend

Static Function ValidPerg()

	local cLoad	    := "BIAFG147" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("Z98_ANOREF")[1])

	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})

	If ParamBox(aPergs ,"Processamento de Férias Fracionadas",,{||.T.},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

	EndIf

Return lRet
