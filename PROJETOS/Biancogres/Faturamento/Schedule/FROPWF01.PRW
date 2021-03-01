#include "PROTHEUS.CH"
#include "TOPCONN.CH"

#DEFINE REPRESENTANTE 1
#DEFINE CLI 2

/*/{Protheus.doc} FROPWF01
@description Workflow de pedidos com data de entrega alterada pela OP 
@author Fernando Rocha
@since 23/03/2014
@version 1.0
@type function
/*/

User Function FROPWF01() 

	Local xv_Emps    := U_BAGtEmpr("01_05")
	Local nI

	Private cSQL := ""
	Private Qry := ""
	Private cHtml := ''
	Private _cRep
	Private _cCli
	Private _nCli
	Private _eCli
	Private _sCli
	Private _cAteMail := ""
	Private nOpc

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 

		nOpc := CLI
		GetData()
		ExecLoopCli()
		(Qry)->(dbCloseArea())

		RpcClearEnv()

	Next

Return() 

Static Function ExecLoopCli() 
	Local nCount := 0
	Local _cAux
	Local aPedAt := {} 
	Local I 
	Local lCabAnte
	Local lCabPost

	If !(Qry)->(Eof())

		While !(Qry)->(Eof())

			_dNewDt := SToD((Qry)->DT_DISPONIBILIDADE)
			_dOldDt := SToD((Qry)->ENTREGA_ORIGINAL)
			_dNeces := SToD((Qry)->DT_NECESSIDADE)

			//Se for ENGENHARIA e a data de necessidade estiver acima da nova entrega/ OU alteracao para menos que 7 dias da necessidade ignorar e não enviar wf
			//ENGENHARIA nunca envia antecipações
			If AllTrim((Qry)->SEG_CLI) == "E" .And. ( _dNeces >= _dNewDt   .Or.  _dNewDt < _dNeces + 7 )
				(Qry)->(DbSkip())
				loop
			EndIf

			_cRep 		:= (Qry)->VENDEDOR
			_cCli 		:= (Qry)->COD_CLI
			_nCli 		:= (Qry)->CLIENTE
			_eCli 		:= (Qry)->EMAIL_CLI
			_sCli 		:= (Qry)->SEG_CLI
			_cEmail		:= ""
			
			lCabAnte := .F.
			lCabPost := .F.

			GetHeader()
			GetColumnHeader(_cRep, _nCli)

			While !(Qry)->(Eof()) .And. (Qry)->COD_CLI == _cCli

				_dNewDt := SToD((Qry)->DT_DISPONIBILIDADE)
				_dOldDt := SToD((Qry)->ENTREGA_ORIGINAL)
				_dNeces := SToD((Qry)->DT_NECESSIDADE)

				//Se for ENGENHARIA e a data de necessidade estiver acima da nova entrega/ OU alteracao para menos que 7 dias da necessidade ignorar e não enviar wf
				//ENGENHARIA nunca envia antecipações
				If AllTrim((Qry)->SEG_CLI) == "E" 

					If ( _dNeces >= _dNewDt   .Or.  _dNewDt < _dNeces + 7 )
						(Qry)->(DbSkip())
						loop
					Else

						//Se for enviar para ENGENHARIA considerar a data de necessidade - sempre tem que ser Postergação
						_dOldDt := _dNeces 

					EndIf
				EndIf

				If !lCabAnte .And. ( _dNewDt < _dOldDt )

					GetCHead2(.T., AllTrim((Qry)->SEG_CLI) == "E")
					lCabAnte := .T.

				ElseIf !lCabPost .And. ( _dNewDt > _dOldDt )

					If lCabAnte 
						cHtml += ' </table></p> '
						cHtml += '<BR>'
						cHtml += '<BR>'
						cHtml += '<BR>'
					EndIf

					GetCHead2(.F., AllTrim((Qry)->SEG_CLI) == "E")
					lCabPost := .T.				
				EndIf

				GetItems()
				
				aAdd(aPedAt,{ (Qry)->EMPPED, (Qry)->(C6_FILIAL+C6_NUM+C6_ITEM), (Qry)->RECSC6 }  )
				
				If (!Empty(_cEmail))
					_cEmail += ";"
				EndIf
				
				_cRetEmail := EmailAtendente((Qry)->(C6_NUM), _cCli, _cRep, _sCli, (Qry)->EMPRESA)
				_cRetEmail := AllTrim(_cRetEmail)
				If (!(_cRetEmail $ _cEmail))
					_cEmail += _cRetEmail
				EndIf
				
				(Qry)->(DbSkip())
			EndDo

			cHtml += ' </table></p> '
			GetFooter()
				
				
			
			
			If SendMail(_cRep, _eCli, _sCli, _cEmail)

				For I := 1 To Len(aPedAt)

					__CSQL := "exec SP_ROP_GRAVAPZ2 '"+aPedAt[I][1]+"','01',"+AllTrim(Str(aPedAt[I][3]))+",'SC6','"+aPedAt[I][2]+"','ALTDTWF','"+AllTrim(FunName())+"','"+DTOS(dDataBase)+"','"+SubStr(Time(),1,5)+"','WFD','WORKFLOW'"
					TCSQLExec(__CSQL)

				Next I

			EndIf

			cHtml := ""
			_cAteMail := ""
			aPedAt := {}

		EndDo

	EndIf
Return()

Static Function GetData()
	Qry := GetNextAlias()

	cSQL := "EXEC SP_ROP_CONSULTA_PEDIDOS_DATA_ALTERADA_"+AllTrim(cEmpAnt) + " " + Str(nOpc)

	TcQuery cSQL New Alias (Qry)
Return()

Static Function EmailAtendente(_cPedido, _Cliente, _cVendedor, _cSegmento, _cMarca)
	
	Local cAliasTemp	:= GetNextAlias()
	Local cEmail 		:= ""
	Local cQuery		:= ""
		
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	
	If SA1->(DbSeek(xFilial("SA1") + _Cliente))

		cAliasTemp	:= GetNextAlias()
		cQuery := "SELECT EMAILATEN FROM [dbo].[GET_ZKP] ('"+_cSegmento+"', '"+_cMarca+"', '"+SA1->A1_EST+"', '"+_cVendedor+"', '"+SA1->A1_YCAT+"', '"+SA1->A1_GRPVEN+"')"
		TcQuery cQuery New Alias (cAliasTemp)
		
		If (!(cAliasTemp)->(Eof()))
			cEmail := (cAliasTemp)->EMAILATEN
		EndIf
		(cAliasTemp)->(DbCloseArea())
		
	EndIf
		
Return cEmail

Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">                                                '
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">                                                                                                                              '
	cHtml += '      <head>                                                                                                                                                                '
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />                                                                                         '
	cHtml += '         <title>cabtitpag</title>                                                                                                                                           '
	cHtml += '         <style type="text/css">                                                                                                                                            '
	cHtml += '			<!--                                                                                                                                                              '
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}                                                                  '
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}                                                                             '
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}                                                                          '
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}                                                                                             '
	cHtml += '			.headTexto2 {color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}                                                                                             '
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}                                                                          '
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}                                                                                              '
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}                                                                          '
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }         '
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }                                         '
	cHtml += '			-->                                                                                                                                                               '
	cHtml += '         </style>                                                                                                                                                           '
	cHtml += '      </head>                                                                                                                                                               '
	cHtml += '      <body>                                                                                                                                                                '

Return()


Static Function GetColumnHeader(_cRep, _nCli)

	cHtml += '         <p><div class = "headTexto1">Prezado cliente: <b>'+_nCli+'</b></div></p>                                '
	cHtml += '         <br/>                                                                                                '
	cHtml += '         <p><div class = "headTexto1">Seguem atualizações nas seguintes previsões de entrega.</div></p>          '
	cHtml += '         <br/>                                                                                                '

Return()

Static Function GetCHead2(_lAntec, _lEng)

	Default _lEng := .F.

	If _lAntec
		cHtml += '         <p><div class = "headTexto1">Pedidos que a previsão de entrega foi ANTECIPADA:</div></p>          '
	Else                                                                                                                  
		cHtml += '         <p><div class = "headTexto1">Pedidos que a previsão de entrega foi POSTERGADA:</div></p>          '
	EndIf

	cHtml += '          <p><table align="left" width="1200" border="1" cellspacing="0" cellpadding="1">                          '
	cHtml += '            <tr align=center>                                                                                    '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Representante </th>                                  '
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Pedido </th>                                         '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Item </th>                                           '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Ordem de Compra </th>                                '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Produto </th>                                        '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Descrição </th>                                      '
	cHtml += '               <th class = "cabtab" width="40" scope="col"> Qtde </th>                                           '

	If !_lEng
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Entrega Original </th>                               '
	Else
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Data Neces. Eng. </th>                               '
	EndIf

	cHtml += '               <th class = "cabtab" width="40" scope="col"> Nova Data de Entrega </th>                           '
	cHtml += '            </tr>                                                                                                '

Return()


Static Function GetItems()

	Local lEng := AllTrim((Qry)->SEG_CLI) == "E"

	cHtml += " 			<tr align=center>

	If nOpc == REPRESENTANTE
		cHtml += "          	<td class='style12' width='100'scope='col'>"+ (Qry)->CLIENTE +"</td>
	Else
		SA3->(DbSetOrder(1))
		SA3->(DbSeek(XFilial("SA3")+_cRep))

		cHtml += "          	<td class='style12' width='100'scope='col'>"+ AllTrim(SA3->A3_NREDUZ) +"</td>
	EndIf

	cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->C6_NUM +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->C6_ITEM +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->PEDIDO_COMPRA +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->C6_PRODUTO +"</td>

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+(Qry)->C6_PRODUTO))
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ AllTrim(SB1->B1_DESC) +"</td>

	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->SALDO,"@E 999,999.99") +"</td>

	If !lEng
		cHtml += "              <td class='style12' width='40'scope='col'>"+ DToC(SToD((Qry)->ENTREGA_ORIGINAL)) +"</td>
	Else
		cHtml += "              <td class='style12' width='40'scope='col'>"+ DToC(SToD((Qry)->DT_NECESSIDADE)) +"</td>
	EndIf

	cHtml += "              <td class='style12' width='40'scope='col'>"+ DToC(SToD((Qry)->DT_DISPONIBILIDADE)) +"</td>
	cHtml += "          </tr>

Return()


Static Function GetFooter()

	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	cHtml += "<BR>"
	cHtml += "<BR>"
	cHtml += "<BR>"
	cHtml += '<p><div class = "headTexto1">Atenciosamente,</div></p>'
	cHtml += "<br/>"
	cHtml += '<p><div class = "headTexto1">'+AllTrim(SM0->M0_NOME)+'</div></p>'
	cHtml += "<br/>"
	cHtml += '<p><div class = "headTexto2">Mensagem gerada automaticamente pelo sistema (FROPWF01). Favor não responder.</div></p>'
	cHtml += "      </body>                                                                                                                                       "
	cHtml += "   </html>                                                                                                                                          "
	cHtml += "   </html> 																																		  "

Return()

Static Function SendMail(_cRep, _cAteMail, _sCli, cEmailAte)
	Local _lRet  
	Local _cFrom := ""
	Local _cTo := ""
	Local _cSubject := ""
	Local _cBody := ""
	Local _cCC := ""
	Local _oCC := ""

	SA3->(DbSetOrder(1))
	SA3->(DbSeek(XFilial("SA3")+_cRep))

	
	eAtend := cEmailAte
	/*ZZI->(DbSetOrder(1))
	ZZI->(DbSeek(XFilial("ZZI")+_cRep+_sCli))

	eAtend := ""
	If !ZZI->(EOF())
		eAtend := UsrRetMail(ZZI->ZZI_ATENDE)
	EndIf*/

	If AllTrim(cEmpAnt) == '01'
		If !Empty(_cAteMail)
			_cTo := _cAteMail
			_oCC := U_EmailWF("FROPWF01",AllTrim(cEmpAnt)) + eAtend
		Else
			_cTo := U_EmailWF("FROPWF01",AllTrim(cEmpAnt)) + eAtend
		EndIf
	Else
		If !Empty(_cAteMail)
			_cTo := _cAteMail
			_oCC := U_EmailWF("FROPWF01",AllTrim(cEmpAnt)) + eAtend
		Else
			_cTo := U_EmailWF("FROPWF01",AllTrim(cEmpAnt)) + eAtend
		EndIf
	EndIf

	If !Empty(SA3->A3_EMAIL)
		_cCC := AllTrim(SA3->A3_EMAIL)
	EndIf

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	_cSubject := "Atualização na Previsão de Entrega - "+ AllTrim(SM0->M0_NOME) 


	If !(Upper(AllTrim(getenvserver())) == "SCHEDULE")
		_cTo 	:= "fernando@facilesistemas.com.br"
		_cCC	:= ""	
		_oCC	:= ""
	EndIf

	_cBody := cHtml

	//teste - bloquear registros - enviar email somente interno
	//_cTo := "fernando@facilesistemas.com.br"
	//_cCC := "" 
	//_cCC := "raul.grossi@biancogres.com.br;claudeir.fadini@biancogres.com.br"
	//_cTo := 'luana.ribeiro@biancogres.com.br'
	//_lRet := .T.
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC, _oCC)

Return(_lRet)