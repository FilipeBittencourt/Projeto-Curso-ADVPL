#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAG0004
@author Gabriel Rossi Mafioletti
@since 01/11/2021
@version 1.0
@description Orçamento Variável 
@type function
/*/

User Function BIAG0004()

	If !ValidPerg()
		Return
	EndIf

	fProcessa()

Return


Static Function fProcessa()

	Local _cQry	:=	""


	DbSelectArea("ZON")
	ZON->(DbSetOrder(1))
	ZON->(DbGoTop())
	While ZON->(!EOF())
		_cQry	:=	fMakeQry(ZON->ZON_QUERY)
		IF ZON->ZON_TIPQRY == "P"	//PROCESSAMENTO
			If (TCSQLEXEC(_cQry) <> 0)
				MsgStop("ERRO AO EXECUTAR NIVEL: " + Alltrim(ZON->ZON_NIVEL) + " ITCUS: " + Alltrim(ZON->ZON_ITCUS) + " SEQ: " + ALLTRIM(ZON->ZON_SEQUEN) + CRLF+;
					TCSQLError(),"BIAG0004")
				EXIT
			EndIF
		ElseIf ZON->ZON_TIPQRY == "G" //GRAVAÇÃO
			_cTeste	:=	123
		EndIf
		ZON->(DbSkip())
	EndDo
Return


Static Function ValidPerg()

	local cLoad	    := "BIAG0004" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("Z98_ANOREF")[1])

	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})

	If ParamBox(aPergs ,"Orçamento Variável",,{|| U_BG0004VR()},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

	EndIf

Return lRet

User Function BG0004VR()

	Local _cAlias      := GetNextAlias()
	Local _lret		:=	.T.

	Return .T.

	IF EMPTY(MV_PAR02) .Or. Empty(MV_PAR03)
		ZB5->(DbSetOrder(1))
		ZB5->(DbSeek(xFilial("ZB5")+MV_PAR01))
		MV_PAR02	:=	ZB5->ZB5_REVISA
		MV_PAR03	:=	ZB5->ZB5_ANOREF
	EndIF

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual OBZ" + CRLF
	xfMensCompl += "Status igual Aberto" + CRLF
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + CRLF
	xfMensCompl += "Data Conciliação igual branco" + CRLF
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias _cAlias
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:MV_PAR01%
		AND ZB5.ZB5_REVISA = %Exp:MV_PAR02%
		AND ZB5.ZB5_ANOREF = %Exp:MV_PAR03%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(_cAlias)->(dbGoTop())
	If (_cAlias)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + CRLF + CRLF + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + CRLF + CRLF + xfMensCompl + CRLF + CRLF + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		_lret	:=	.F.
	Else

	EndIf	

	(_cAlias)->(dbCloseArea())

Return _lRet


Static Function fMakeQry(_cQuery)

	Local nPosQP
	Local msTamVar
	Local msAlias
	Local _cDataIni	:=	Alltrim(Str(VAL(MV_PAR03) - 1))+'0101'
	Local _cDataFim	:=	Alltrim(Str(VAL(MV_PAR03) - 1))+'1231'
	Local _cItCIni
	Local _cItCFim

	If !Empty(_cQuery)
	
		While "@ALIAS" $ _cQuery
			nPosQP = AT("@ALIAS#", _cQuery)
			msTamVar := Len("@ALIAS#")
			If nPosQP > 0
				msAlias := Substr(_cQuery, nPosQP + msTamVar, 3) 
				_cQuery = Replace(_cQuery, Substr(_cQuery, nPosQP, 3 + msTamVar) , RetSqlName(msAlias))
			Else
				Exit
			EndIf
		End

		While "@XFILIAL" $ _cQuery
			nPosQP = AT("@XFILIAL#", _cQuery)
			msTamVar := Len("@XFILIAL#")
			If nPosQP > 0
				msAlias := Substr(_cQuery, nPosQP + msTamVar, 3) 
				_cQuery = Replace(_cQuery, Substr(_cQuery, nPosQP, 3 + msTamVar) , xFilial(msAlias))
			Else
				Exit
			EndIf
		End

		If	EMPTY(ZON->ZON_ITCUS)
			_cItCIni	:=	""
			_cItCFim	:=	'ZZZ'
		Else
			_cItCIni	:=	ZON->ZON_ITCUS
			_cItCFim	:=	ZON->ZON_ITCUS
		EndIf
		
		_cQuery := Replace(_cQuery, "@DATAINI" , _cDataIni)
		_cQuery := Replace(_cQuery, "@DATAFIM" , _cDataFim)
		_cQuery := Replace(_cQuery, "@ITCUSINI" , _cItCIni)
		_cQuery := Replace(_cQuery, "@ITCUSFIM" , _cItCFim)
		_cQuery := Replace(_cQuery, "@VERSAO" , MV_PAR01)
		_cQuery := Replace(_cQuery, "@REVISAO" , MV_PAR02)
		_cQuery := Replace(_cQuery, "@ANOREF" , MV_PAR03)		

	EndIf

	

Return _cQuery