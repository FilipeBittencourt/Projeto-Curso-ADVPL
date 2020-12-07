#include "PROTHEUS.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Gabriel Rossi Mafioletti
Programa  := BIAFG003
Empresa   := Biancogres Cerâmica S/A
Data      := 29/05/17
Uso       := PCP
Aplicação := Funcao para criacao de nova revisao para produto
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/


User function BIAFG003()

	Local	oGetForm	:=	Nil
	Local	cGetForm	:=	SPACE(TAMSX3("B1_YFORMAT")[1])

	Local	oGetPNov	:=	Nil
	Local	oGetPAnt	:=	Nil
	Local	nGetPNov	:=	0
	Local	cGetPAnt	:=	""
	Local	oSayForm
	Local 	oSayPAnt
	Local	oSayPNov
	Local	oBtOk
	Local oGetDtRef
	Local dGetDtRef	:=	Stod("")
	Local oGetEsp
	Local cGetEsp	:=	SPACE(TAMSX3("Z34_CODIGO")[1])
	Local oSayesp


	Private oDlg

	DEFINE MSDIALOG oDlg TITLE "Alteração de Peso" FROM 000, 000  TO 190, 200 COLORS 0, 16777215 PIXEL

	@ 005, 005 SAY oSayForm PROMPT "Formato:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 002, 040 MSGET oGetForm VAR cGetForm SIZE 020, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "ZZ6" VALID VldForm(cGetForm,@cGetPAnt)

	@ 020, 005 SAY oSayPAnt PROMPT "Peso Atual:" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 017, 040 MSGET oGetPAnt VAR cGetPAnt SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.

	@ 035, 005 SAY oSayPNov PROMPT "Novo  Peso:" SIZE 033, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 032, 040 MSGET oGetPNov VAR nGetPNov SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL PICTURE "999.99" VALID vldPNov(nGetPnov)

	@ 050, 005 SAY oSayDtRef PROMPT "Data Ref:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 040 MSGET oGetDtRef VAR dGetDtRef SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 065, 005 SAY oSayEsp PROMPT "Espessura:" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 062, 040 MSGET oGetEsp VAR cGetEsp SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL VALID VldEsp(cGetEsp) F3 "Z34"

	@ 080, 035 BUTTON oBtOk PROMPT "OK" SIZE 028, 012 OF oDlg PIXEL ACTION UpdPeso(cGetForm,nGetPNov,dGetDtRef, cGetEsp) 

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function vldPNov(_nPeso)
	Local _lRet	:=	.T.
	If (_nPeso <= 0)
		MsgInfo("O Peso Deverá ser Positivo!")
		_lRet	:=	.F.
	EndIf
return _lRet

Static function vldForm(_cForm, _cPeso)

	Local _cAlias	:=	GetNextAlias()
	Local _aPesos	:=	{}
	Local _cMsg		:=	""

	If Empty(_cForm)
		MsgInfo("Digite um Formato!")
		Return .F.
	EndIf

	BeginSql Alias _cAlias

		SELECT DISTINCT  B1_PESO
		FROM    %Table:SB1%
		WHERE	B1_FILIAL = %xFilial:SB1%   
		AND B1_YFORMAT = %Exp:_cForm%
		AND %NotDel%
		AND B1_MSBLQL <> '1'

	EndSql

	If (_cAlias)->(EOF())
		MsgInfo("Não Existem Produtos com Esse Formato Cadastrados!")
		Return .F.
	EndIf

	_cMsg	:=	"O Formato " + _cForm + " Possui mais de um Peso Atribuído Conforme Abaixo: " + CRLF

	While (_cAlias)->(!EOF())

		aAdd(_aPesos,(_cAlias)->B1_PESO)
		_cMsg	+=	Alltrim(Str((_cAlias)->B1_PESO)) + CRLF
		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

	If	Len(_aPesos) == 0
		MsgInfo("Não Existem Produtos Ativos Para o Formato Escolhido")
		Return .F.
	ElseIf Len(_aPesos) > 1
		_cPeso	:=	"*"
		oDlg:Refresh()
		return MsgYesNo(_cMsg + "Deseja Prosseguir?")
	Else
		_cPeso	:=	Alltrim(Str(_aPesos[1]))
	EndIf 

return .T.

Static function UpdPeso(_cForm,_nPeso,_dDataRef, _cEsp)

	Local	_cAlias	:=	GetNextAlias()
	Local	_cDataRef	:=	DtoS(_dDataRef)

	BeginSql Alias _cAlias

		SELECT R_E_C_N_O_ RCNO
		FROM    %Table:SB1%
		WHERE	B1_FILIAL = %xFilial:SB1%   
		AND B1_YFORMAT = %Exp:_cForm%
		AND B1_YESPESS	= %Exp:_cEsp%
		AND %NotDel%
		AND B1_MSBLQL <> '1'

	EndSql		
	DbSelectArea("SB1")
	While (_cAlias)->(!EOF())

		SB1->(DbGoTo((_cAlias)->RCNO))
		Reclock("SB1",.F.)
		SB1->B1_PESO	:=	_nPeso
		SB1->(MsUnlock())

		msBlqProd := IIf(SB1->B1_MSBLQL == "1" .or. SB1->B1_YSTATUS $ "2/3", "1", " ")
		U_UpProdEco(SB1->B1_COD, msBlqProd, SB1->B1_CODBAR, SB1->B1_PESO)

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		WITH    LOTESPROD
		AS ( SELECT DISTINCT
		D3_COD ,
		D3_LOTECTL
		FROM     %TABLE:SD3%
		WHERE    D3_FILIAL = %xFilial:SD3%
		AND SUBSTRING(D3_COD, 1, 2) = %Exp:_cForm%
		AND D3_EMISSAO >= %Exp:_cDataRef%
		AND D3_EMISSAO <> '        '
		AND D3_TM = '010'
		AND D3_TIPO = 'PA'
		AND %NotDel%
		UNION
		SELECT ZZ9_PRODUT, 
		ZZ9_LOTE
		FROM %TABLE:ZZ9% ZZ9 
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% 
		AND B1_COD = ZZ9_PRODUT 
		AND B1_YFORMAT = %Exp:_cForm% 
		AND B1_YESPESS = %Exp:_cEsp%
		AND B1_YCLASSE IN('2','3')
		AND ZZ9_LOTE <> ''
		AND SB1.D_E_L_E_T_ = ' ' 
		WHERE ZZ9.%NotDel% 
		)
		SELECT  ZZ9.R_E_C_N_O_ RCNO
		FROM    %TABLE:ZZ9% ZZ9
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %xFilial:SB1%
		AND B1_COD = ZZ9_PRODUT
		AND B1_YFORMAT = %Exp:_cForm%
		AND B1_YESPESS	= %Exp:_cEsp% 
		AND SB1.%NotDel%
		INNER JOIN LOTESPROD LPD ON LPD.D3_COD = ZZ9_PRODUT
		AND LPD.D3_LOTECTL = ZZ9_LOTE
		WHERE   ZZ9.ZZ9_FILIAL = %xFilial:ZZ9%
		AND ZZ9.%NotDel%

	EndSql

	DbSelectArea("ZZ9")
	While (_cAlias)->(!EOF())
		ZZ9->(DbGoTo((_cAlias)->RCNO))
		RecLock("ZZ9",.F.)
		ZZ9->ZZ9_PESO	:=	_nPeso
		ZZ9->(MsUnlock())
		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())
	MsgInfo("Peso Atualizado com Sucesso!")
	oDlg:End()

return

Static function vldEsp(_cEsp)

	Local _lRet	:=	.T.

	DbSelectArea("Z34")
	Z34->(DbSetOrder(1))

	If !Z34->(DbSeek(xFilial("Z34")+_cEsp))
		MsgInfo("Espessura Inválida!")
		_lRet	:=	.F.
	EndIf
Return _lRet
