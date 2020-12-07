#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIAFG024
@author Gabriel Rossi Mafioletti
@since 05/09/2017
@version 1.0
@description Rotina para Liberação de Pedidos de Amostra Liberados pelo Ecosis
@type function
/*/

User Function BIAFG024()

	Local xv_Emps	:=	{}
	Local _nI, xt

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05")

		For xt	:=	1 to Len(xv_Emps)

			RPCSetType(3)
			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG024 " + xv_Emps[xt,1])

			Processa({||fProcessa()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG024 " + xv_Emps[xt,1])

			RpcClearEnv()

		Next

	Else

		Processa({||fProcessa()})

	EndIf

Return

Static Function fProcessa()

	Local _cEmpresa := ""
	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""
	Local kt_BsDad
	Local _cPedido	:=	""
	Local _nI
	Local _cHtml
	Local _nSaldo

	Private _aErros	:=	{}
	Private _lCritical	:=	.F.

	IF cEmpAnt == "01"
		kt_BsDad	:= "%DADOSEOS%"
	ELSEIF cEmpAnt == "05"
		//kt_BsDad	:= "%DADOS_05_EOS%"
		Return
	ELSE
		//Alterar quando houver outras emnpresas usando o Ecosis
		Return
	ENDIF

	BeginSql Alias _cAlias

		SELECT DISTINCT  SC6.C6_NUM
		FROM %TABLE:SC6% SC6
		INNER JOIN %Exp:Kt_BsDad%..cep_ctrl_amostra B ON SC6.C6_YECONAM = B.cca_codigo COLLATE Latin1_General_BIN
		AND B.cca_data_pronta IS NOT NULL
		AND (B.cca_data_cancelamento = '' OR B.cca_data_cancelamento IS NULL)
		WHERE SC6.C6_YSTTSAM = 'T'
		AND SC6.C6_YECONAM <> ''
		AND SC6.%NotDel%

	EndSql

	If (_cAlias)->(!EOF())

		While (_cAlias)->(!EOF())
			_lCritical := .F.
			BEGIN TRANSACTION

				//Fernando em 11/04/18 - marcar o campo C5_LIBEROK para acertar a leganda dos pedidos
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+(_cAlias)->C6_NUM))
					RecLock("SC5",.F.)
					SC5->C5_LIBEROK := "S"
					SC5->(MsUnlock())
				EndIf

				SC6->(DbSetOrder(1))
				SC6->(DbSeek(xFilial("SC6")+(_cAlias)->C6_NUM))
				While SC6->(!EOF()) .And. (xFilial("SC6")+(_cAlias)->C6_NUM) == SC6->(C6_FILIAL+C6_NUM)
					If  SC6->C6_YSTTSAM == 'T'
						_nSaldo	:= 0
						If Alltrim(SC6->C6_BLQ) == 'R'
							SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Pedido Encerrado"}))
							_lCritical	:=	.T.
						Elseif fCancIt(SC6->C6_YECONAM, SC6->C6_ITEM)
							SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Item Cancelado no Ecosis"}))
							Reclock("SC6")
							SC6->C6_YSTTSAM	:=	"R"
							SC6->C6_YECONAM :=	""
							SC6->(MsUnlock())
						ElseIf Alltrim(SC6->C6_BLQ) <> 'R' .And. (_nSaldo := ChkSalPed(SC6->C6_NUM,SC6->C6_ITEM)) > 0
							fLibPed(_nSaldo)
						ElseIf _nSaldo <= 0
							SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Pedido Sem Saldo (verificar liberação)"}))
						EndIf
					EndIf
					SC6->(DbSkip())
				EndDo
				If _lCritical
					DisarmTransaction()
				EndIf

			END TRANSACTION

			(_cAlias)->(DbSkip())

		EndDo

		If Len(_aErros) > 0

			_cHtml		:=	MntHeadHtm()
			For _nI	:=	1 to Len(_aErros)

				_cHtml	+=	'<tr>																												'
				_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,1]						+ '</div></td>'
				_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,2]		+ '</div></td>'
				_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,3]						+ '</div></td>'
				_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ PADR(_aErros[_nI,3],TamSx3("B1_COD")[1]),"B1_DESC"))		+ '</div></td>'
				_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,4]						+ '</div></td>'
				_cHtml	+=	'</tr>

			Next

			_cHtml	+=	'	 </table>          '
			_cHtml	+=	'	<p>by BIAFG024</p> '
			_cHtml	+=	'	</body>            '
			_cHtml	+=	'	</html>            '

			If !Empty(_cHtml)
				WfSend(_cHtml)
			EndIf

		EndIf

	EndIf

	(_cAlias)->(DbCloseArea())

Return

Static Function ChkSalPed(_cPedido, _cItem)

	Local _nSaldo := 0
	Local _cSQL := ""

	_cSQL +="	SELECT ROUND( "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(C6_QTDVEN) FROM "+RetSQLName("SC6")+" "+CRLF
	_cSQL +="					WHERE C6_NUM = '"+_cPedido+"' AND C6_ITEM = '"+_cItem+"' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					- "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(D2_QUANT) FROM "+RetSQLName("SD2")+" "+CRLF
	_cSQL +="					WHERE D2_PEDIDO = '"+_cPedido+"' AND D2_ITEMPV = '"+_cItem+"' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					- "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(C9_QTDLIB) FROM "+RetSQLName("SC9")+" "+CRLF
	_cSQL +="					WHERE C9_PEDIDO = '"+_cPedido+"' AND C9_ITEM = '"+_cItem+"' AND C9_BLEST = ' ' AND C9_BLCRED = ' ' AND C9_NFISCAL = ' ' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					,2) as SALDO "+CRLF
	TCQuery _cSQL Alias "QRYVAL" New

	QRYVAL->(DbGoTop())
	If (!QRYVAL->(Eof()))
		_nSaldo := QRYVAL->SALDO
	EndIf
	QRYVAL->(DbCloseArea())

Return _nSaldo

Static Function fLibPed(_nSaldo)

	Local lCredito 	:= .T.
	Local lEstoque 	:= .T.
	Local lAvalCred	:= .F.

	Local _nQtdLib2  := ConvUM(SC6->C6_PRODUTO, _nSaldo, 0, 2)

	Local _nQtdLib

	Local aListRes := U_FRTE02LO("", SC6->C6_NUM, SC6->C6_ITEM, "", "")

	If Len(aListRes) > 0
		U_FRRT02EX(SC6->C6_NUM, SC6->C6_ITEM,Nil,"LIB",,,.F.)
	EndIf

	_nQtdLib := MaLibDoFat(SC6->(RecNo()),_nSaldo,@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,_nQtdLib2)

	Do Case
		Case _nQtdLib <> _nSaldo
		SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Erro de Liberação, Pedido Parcialmente Liberado"}))
		_lCritical	:=	.T.
		Case lEstoque == .F.
		SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Erro de Liberação, Pedido Com Bloqueio de Estoque"}))
		_lCritical	:=	.T.
		Case lCredito == .F.
		SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Erro de Liberação, Pedido Com Bloqueio de Crédito"}))
		_lCritical	:=	.T.
		OtherWise
		RecLock("SC6",.F.)
		SC6->C6_YSTTSAM	:=	"L"
		SC6->(MsUnlock())

	EndCase

Return

static function MntHeadHtm()

	Local _cHead	:=	""

	_cHead	+=	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		'
	_cHead	+=	'<html xmlns="http://www.w3.org/1999/xhtml">																					'
	_cHead	+=	'<head>																															'
	_cHead	+=	'	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />														'
	_cHead	+=	'	<title>Untitled Document</title>																							'
	_cHead	+=	'	<style type="text/css">																										'
	_cHead	+=	'		<!--																													'
	_cHead	+=	'		.style3 {color: #000000; }																								'
	_cHead	+=	'		.style4 {color: #FFFFFF; }																								'
	_cHead	+=	'		.style5 {color: #FF0000; }																								'
	_cHead	+=	'		-->																														'
	_cHead	+=	'	</style>																													'
	_cHead	+=	'</head>																														'
	_cHead	+=	'<body>																															'
	_cHead	+=	'	<p>Erros Encontrados Durante a Liberação de Pedidos de Amostra</p>														    '
	_cHead	+=	'	<table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" >										'
	_cHead	+=	'		<tr>																													'
	_cHead	+=	'			<th width="20" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Pedido																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="15" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Item																										'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="60" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Cod. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="150" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Desc. Produto																								'
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'			<th width="300" height="21" bgcolor="#0033FF" scope="col">															'
	_cHead	+=	'				<div align="center" class="style4">																				'
	_cHead	+=	'					Desc. Erro																							        '
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'		</tr> 																													'

return _cHead

static function wfSend(_cHtml)

	Local df_Orig
	Local df_Dest := U_EmailWF('BIAFG024', cEmpAnt)
	Local df_Assu := "Log de Erros na Liberação de Pedidos de Amostra"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!"

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)

return

Static Function fCancIt(_cNum, _cItem)

	Local _cAlias	:=	GetNextAlias()
	Local _nItem	:=	Val(_cItem)
	Local kt_BsDad		
	Local _lret

	IF cEmpAnt == "01"
		kt_BsDad	:= "%DADOSEOS%"
	ELSEIF cEmpAnt == "05"
		//kt_BsDad	:= "%DADOS_05_EOS%"
		Return
	ELSE
		//Alterar quando houver outras emnpresas usando o Ecosis
		Return
	ENDIF

	BEGINSQL ALIAS _cAlias

		SELECT COUNT(*) QTD
		FROM %Exp:Kt_BsDad%..cep_ctrl_amostra C
		INNER JOIN %Exp:Kt_BsDad%..cep_ctrl_amostra_itens I ON I.cca_codigo = C.cca_codigo
		AND I.id_itens = %Exp:_nItem%
		WHERE C.cca_codigo = %Exp:_cNum%
		AND cca_data_cancelamento IS NULL

	ENDSQL

	_lRet := (_cAlias)->QTD == 0

	(_cAlias)->(DbCloseArea())

Return _lRet
