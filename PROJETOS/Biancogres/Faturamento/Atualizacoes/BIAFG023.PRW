#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG023
@author Gabriel Rossi Mafioletti
@since 29/08/2017
@version 1.0
@description Rotina Para envio de Solicitações de Amostra para o Ecosis
@type function
/*/

User Function BIAFG023()

	Local xv_Emps	:=	{}
	Local _nI, xt

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05_14")

		For xt	:=	1 to Len(xv_Emps)

			RPCSetType(3)
			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIAFG023 " + cEmpAnt)

			Processa({|| fProcessa( .T. )})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIAFG023 " + cEmpAnt)

			RpcClearEnv()

		Next

	Else

		Processa({|| fProcessa( .T. )})

	EndIf

Return

Static Function fProcessa(_lJob)

	Local _cEmpresa := ""
	Local _cAlias	:=	GetNextAlias()
	Local _cStp		:=	""
	Local _cHtml	:=	""
	Local kt_BsDad
	Local _cSql		:=	""
	Local _cDtInic	:=	DtoS(GetNewPar("MV_YDTECOA",Stod("20170801")))
	Local _nI
	Local _cFiltro	:=	""
	Local _aPedidos	:=	StrToKArr(ALLTRIM(MV_PAR01),",")
	Local _nPed

	Private _aErros	:=	{}

	If _lJob
		_cFiltro	:=	"% C5_NUM BETWEEN '     ' AND 'ZZZZZZ' %"
	Else
		_cFiltro	:=	"% C5_NUM BETWEEN '     ' AND 'ZZZZZZ' %"
	EndIf

	IF cEmpAnt == "01"
		_cEmpresa	:= "0101"
		kt_BsDad	:= "%DADOSEOS%"
	ELSEIF cEmpAnt == "05"
		_cEmpresa := "0501"
		kt_BsDad	:= "%DADOS_05_EOS%"
	ELSEIF cEmpAnt == "14"
		_cEmpresa := "1401"
		kt_BsDad	:= "%DADOS_14_EOS%"			
	ELSE
		//Alterar quando houver outras emnpresas usando o Ecosis
		Return
	ENDIF

	BeginSql Alias _cAlias

		SELECT DISTINCT C5_NUM
		FROM     %TABLE:SC5% SC5
		JOIN %TABLE:SC6% SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL
		AND SC5.C5_NUM = SC6.C6_NUM
		AND SC6.%NotDel%
		LEFT JOIN %Exp:kt_BsDad%..cep_ctrl_amostra AM ON AM.cca_codigo COLLATE Latin1_General_BIN = SC6.C6_YECONAM
		AND (AM.cca_data_cancelamento = '' OR AM.cca_data_cancelamento IS NULL)
		WHERE   SC5.C5_FILIAL =  %XFILIAL:SC5%
		AND SC5.C5_YAPROV <> ''
		AND SC5.C5_YSUBTP IN('A ', 'F ','M ')
		AND SC5.C5_YCONF = 'S'
		AND SC5.%NotDel%
		AND SC6.C6_YECONAM <> ''
		AND SC6.C6_YSTTSAM NOT IN ('F','R')
		AND SC5.C5_EMISSAO >=  %Exp:_cDtInic%
		AND %EXP:_cFiltro%
		AND AM.cca_codigo IS NULL

	EndSql

	fEstSC9(_cAlias)

	(_cAlias)->(DbCloseArea())
	If cEmpAnt <> "05"
		If !_lJob

			For _nPed	:= 1 to Len(_aPedidos)

				IF TCSPEXIST(U_GSPName("EOS_SEND_SOL_AMOSTRA_PEDIDO"))

					_cStp	:=	"%" + U_GSPName("EOS_SEND_SOL_AMOSTRA_PEDIDO") + ' ' + ValtoSql(_cEmpresa) + ',' + ValtoSql(_cDtInic) + ',' + ValtoSql(_aPedidos[_nPed]) + "%"

					_cAlias	:= GetNextAlias()
					BeginSql Alias _cAlias
						%NoParser%
						EXEC %Exp:_cStp%
					EndSql

					If (_cAlias)->(!EOF())

						_cHtml		:=	MntHeadHtm()

						While (_cAlias)->(!EOF())

							_cHtml	+=	'<tr>																												'
							_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->PEDIDO						+ '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	PADL(cValToChar((_cAlias)->ITEM),4,'0')		+ '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->PRODUTO						+ '</div></td>'
							_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ PADR(SUBSTR((_cAlias)->PRODUTO,1,7),TamSx3("B1_COD")[1]),"B1_DESC"))		+ '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->ERRO						+ '</div></td>'
							_cHtml	+=	'</tr>

							(_cAlias)->(DbSkip())

						EndDo

						If Len(_aErros) > 0

							For _nI	:=	1 to Len(_aErros)

								_cHtml	+=	'<tr>																												'
								_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,1]						+ '</div></td>'
								_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,2]		+ '</div></td>'
								_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,3]						+ '</div></td>'
								_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ PADR(_aErros[_nI,3],TamSx3("B1_COD")[1]),"B1_DESC"))		+ '</div></td>'
								_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,4]						+ '</div></td>'
								_cHtml	+=	'</tr>

							Next

						EndIf

						_cHtml	+=	'	 </table>                                                                                                                     '
						_cHtml	+=	'	<p>by BIAFG023</p> '
						_cHtml	+=	'	</body>                                                                                                                       '
						_cHtml	+=	'	</html>
						'
					EndIf

					(_cAlias)->(DbCloseArea())
					If !Empty(_cHtml)
						WfSend(_cHtml)
					EndIf

				ENDIF

			Next

		Else

			IF TCSPEXIST(U_GSPName("EOS_SEND_SOL_AMOSTRA"))

				_cStp	:=	"%" + U_GSPName("EOS_SEND_SOL_AMOSTRA") + ' ' + ValtoSql(_cEmpresa) + ',' + ValtoSql(_cDtInic) + "%"

				_cAlias	:= GetNextAlias()
				BeginSql Alias _cAlias
					%NoParser%
					EXEC %Exp:_cStp%
				EndSql

				If (_cAlias)->(!EOF())

					_cHtml		:=	MntHeadHtm()

					While (_cAlias)->(!EOF())

						_cHtml	+=	'<tr>  '
						_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->PEDIDO						                                                                            + '</div></td>'
						_cHtml	+=	'	<td><div align="center">'	+	PADL(cValToChar((_cAlias)->ITEM),4,'0')		                                                                        + '</div></td>'
						_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->PRODUTO						                                                                            + '</div></td>'
						_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ PADR(SUBSTR((_cAlias)->PRODUTO,1,7),TamSx3("B1_COD")[1]),"B1_DESC"))		+ '</div></td>'
						_cHtml	+=	'	<td><div align="center">'	+	(_cAlias)->ERRO						                                                                                + '</div></td>'
						_cHtml	+=	'</tr> '

						(_cAlias)->(DbSkip())

						// Em 15/02/18... Por Marcos Alberto Soprani
						ghGrvArea := GetArea()
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1") + Substr((_cAlias)->PRODUTO,1,7) + "1" ))
						U_EXPECO(2)
						RestArea( ghGrvArea )

					EndDo

					If Len(_aErros) > 0

						For _nI	:=	1 to Len(_aErros)

							_cHtml	+=	'<tr>  '
							_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,1]						                                                                            + '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,2]	                                                                                                + '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,3]						                                                                            + '</div></td>'
							_cHtml	+=	'	<td><div align="left">	'	+	Alltrim(POSICIONE("SB1",1,xFilial("SB1")+ PADR(_aErros[_nI,3],TamSx3("B1_COD")[1]),"B1_DESC"))		            + '</div></td>'
							_cHtml	+=	'	<td><div align="center">'	+	_aErros[_nI,4]					                                                                                + '</div></td>'
							_cHtml	+=	'</tr> '

						Next

					EndIf

					_cHtml	+=	'	 </table> '
					_cHtml	+=	'	<p>by BIAFG023</p> '
					_cHtml	+=	'	</body> '
					_cHtml	+=	'	</html> '
				EndIf

				(_cAlias)->(DbCloseArea())

				If !Empty(_cHtml)
					WfSend(_cHtml)
				EndIf

			ENDIF

		EndIf
	EndIf
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
	_cHead	+=	'	<p>Erros Encontrados Durante a Importação de Amostras para o Ecosis</p>														'
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
	_cHead	+=	'					Desc. Erro																								    '
	_cHead	+=	'				</div>																											'
	_cHead	+=	'			</th>																												'
	_cHead	+=	'		</tr> 																													'

return _cHead

static function wfSend(_cHtml)

	Local df_Orig
	Local df_Dest := U_EmailWF('BIAFG023', cEmpAnt)
	Local df_Assu := "Log de Erros na Importação de Amostras Para o Ecosis"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!"

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)

return

Static Function fEstSC9(_cAlias)

	Local _lOk	:=	.T.

	While (_cAlias)->(!EOF())

		BEGIN TRANSACTION

			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+(_cAlias)->C5_NUM))
			While SC6->(!EOF()) .And. xFilial("SC6")+(_cAlias)->C5_NUM == SC6->(C6_FILIAL+C6_NUM)

				If SC6->C6_BLQ <> 'R'

					dbSelectArea("SC9")
					SC9->(dbSetOrder(1))
					If SC9->(dbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))
						While ( !Eof() .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == xFilial("SC9")+SC6->(C6_NUM+C6_ITEM) )
							If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "ZZ"  .And. SC9->C9_BLEST <> "ZZ")
								SC9->(a460Estorna()) // lMata410 , lAtuEmp , nVlrCred -> OBRIGATÓRIO PASSAR O SEGUNDO PARAMETRO COMO .T. PARA ESTORNAR O EMPENHO NA TABELA SC6
							ElseIf SC9->C9_BLCRED == "10"  .And. SC9->C9_BLEST == "10"
								SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Erro de Estorno de Liberação, Item Já Faturado"}))
								_lOk	:=	.F.
							ElseIf SC9->C9_BLCRED == "ZZ"  .And. SC9->C9_BLEST == "ZZ"
								SC6->(aAdd(_aErros,{C6_NUM, C6_ITEM, C6_PRODUTO, "Erro de Estorno de Liberação, Item com Eliminação de Resíduo"}))
								_lOk	:=	.F.
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf
					Reclock("SC6",.F.)
					SC6->C6_YSTTSAM	:=	"R"
					SC6->C6_YECONAM	:=	""
					SC6->(MsUnlock())
				EndIf
				_lOk	:=	.T.
				SC6->(DbSkip())

			EndDo

		END TRANSACTION

		(_cAlias)->(DbSkip())

	EndDo

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG023" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 :=	SPACE(100)

	aAdd( aPergs ,{1,"Pedidos " 	  				,MV_PAR01 ,""  ,"",''  ,'.T.',100,.T.})

	If ParamBox(aPergs ,"Exportação de Amostra para o Ecosis",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet

User Function BwfFG023()

	StartJob( "U_BIAFG023", GetEnvServer(),.T.)

return
