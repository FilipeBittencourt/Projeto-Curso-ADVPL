#include "PROTHEUS.CH"

/*/{Protheus.doc} FROPRT09
@author Fernando Rocha
@since 19/05/2015
@version 1.0
@description DEPURAR RESERVAS - JOB
@history 05/01/2018, Ranisses A. Corona, Ajustes no cabecalho do fonte e retirar email do Rodolfo e adicionar do Robson / Ticket 1278 - Claudeir 
@type function
/*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPRT09()

	Local xv_Emps    := U_BAGtEmpr("01_05_13_14")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])
		//Gera o html do WF.
		Processa({|| ProcRT09()})

		RpcClearEnv()
	Next nI

Return

Static Function ProcRT09()
	Local aDadRes01 := {}
	Local aDadRes05 := {}
	Local aDadRes13 := {}
	Local aDadRes14 := {}	
	Local aAux

	Private cAliasTmp

	//Ticket 29694 - Pablo S. Nascimento - consulta alterada para trazer codigos cliente e vendedor para buscar atendente
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%

		select EMPRESA = ZZ7_EMP,C0_EMISSAO, C0_NUM, C0_YPEDIDO, C0_YITEMPV, C0_PRODUTO, B1_DESC, C0_SOLICIT, C0_DOCRES, C0_OBS, C0_LOTECTL, C0_QUANT, 
		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_COD	ELSE SA1_2.A1_COD		END AS COD_CLI,
		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA3_1.A3_COD	ELSE SA3_2.A3_COD		END AS COD_VEN,
		CASE WHEN SC5_7.C5_NUM IS NOT NULL THEN		SA1_1.A1_LOJA	ELSE SA1_2.A1_LOJA		END AS LOJA_CLI
		
		from %TABLE:SC0% SC0
		join %TABLE:SB1% SB1 on B1_COD = C0_PRODUTO
		join %TABLE:ZZ7% ZZ7 on ZZ7_COD = B1_YLINHA and ZZ7_LINSEQ = B1_YLINSEQ
		
		LEFT JOIN %TABLE:SC5% SC5 with(nolock) ON (SC0.C0_YPEDIDO	=  SC5.C5_NUM	AND	SC0.C0_FILIAL = SC5.C5_FILIAL		AND	SC5.D_E_L_E_T_ = '') 
		LEFT JOIN SC5070 SC5_7 with(nolock) ON (SC0.C0_YPEDIDO	=  SC5_7.C5_YPEDORI	AND	SC0.C0_FILIAL = SC5_7.C5_FILIAL	AND	SC5_7.D_E_L_E_T_ = '' AND SC5_7.C5_YEMPPED = %EXP:cEmpAnt% AND SC0.C0_YPEDIDO <> '')
		
		LEFT JOIN SA1010 SA1_1 with(nolock) ON (SC5_7.C5_CLIENTE		=  SA1_1.A1_COD		AND SC5_7.C5_LOJACLI	= SA1_1.A1_LOJA	AND SA1_1.D_E_L_E_T_ = '')
		LEFT JOIN SA1010 SA1_2 with(nolock) ON (SC5.C5_CLIENTE		=  SA1_2.A1_COD		AND SC5.C5_LOJACLI		= SA1_2.A1_LOJA	AND SA1_2.D_E_L_E_T_ = '')
		
		LEFT JOIN SA3010 SA3_1 with(nolock) ON (SC5_7.C5_VEND1		=  SA3_1.A3_COD	AND SA3_1.D_E_L_E_T_ = '')
		LEFT JOIN SA3010 SA3_2 with(nolock) ON (SC5.C5_VEND1			=  SA3_2.A3_COD	AND SA3_2.D_E_L_E_T_ = '')
		
		where
		C0_FILIAL = '01'
		and C0_VALIDA <> ''
		and C0_QUANT = C0_QTDORIG
		and C0_VALIDA < convert(varchar(8),GetDate(),112)
		and SC0.D_E_L_E_T_=' '
		and SB1.D_E_L_E_T_=' '
		and ZZ7.D_E_L_E_T_=' '

	EndSql

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		aAux := {}                    
		AAdd(aAux,DTOC(STOD((cAliasTmp)->C0_EMISSAO)))
		AAdd(aAux,(cAliasTmp)->C0_NUM)
		AAdd(aAux,(cAliasTmp)->C0_YPEDIDO)
		AAdd(aAux,(cAliasTmp)->C0_YITEMPV)
		AAdd(aAux,(cAliasTmp)->C0_PRODUTO)
		AAdd(aAux,(cAliasTmp)->B1_DESC)
		AAdd(aAux,(cAliasTmp)->C0_SOLICIT)
		AAdd(aAux,(cAliasTmp)->C0_DOCRES)
		AAdd(aAux,(cAliasTmp)->C0_OBS)
		AAdd(aAux,(cAliasTmp)->C0_LOTECTL)
		AAdd(aAux,(cAliasTmp)->C0_QUANT)
		AAdd(aAux,(cAliasTmp)->COD_CLI)
		AAdd(aAux,(cAliasTmp)->COD_VEN)
		AAdd(aAux,(cAliasTmp)->LOJA_CLI)

		If (cAliasTmp)->EMPRESA == "0101"
			AAdd(aDadRes01,aAux)         
		ElseIf (cAliasTmp)->EMPRESA == "1399"
			AAdd(aDadRes13,aAux)
		ElseIf (cAliasTmp)->EMPRESA == "1302"
			AAdd(aDadRes14,aAux)			
		Else
			AAdd(aDadRes05,aAux)
		EndIf

		Depurar()

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

	If Len(aDadRes01) > 0
		MailProc(aDadRes01, "01")
	EndIf

	If Len(aDadRes05) > 0
		MailProc(aDadRes05, "05")
	EndIf

	If Len(aDadRes13) > 0
		MailProc(aDadRes13, "13")
	EndIf

	If Len(aDadRes14) > 0
		MailProc(aDadRes14, "14")
	EndIf	

Return()


Static Function Depurar()

	SC0->(DbSetOrder(1))	
	If SC0->(DbSeek(XFilial("SC0")+(cAliasTmp)->C0_NUM+(cAliasTmp)->C0_PRODUTO))

		U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"DEPURA",AllTrim(FunName()),"DEP","SISTEMA")

		__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

		// Adiciona historico de alteracoes de reserva
		fAddHis(SC0->C0_YHIST, SC0->C0_PRODUTO, SC0->C0_LOCAL, SC0->C0_QUANT, SC0->C0_LOTECTL)	

		a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},;
		SC0->C0_NUM,;
		SC0->C0_PRODUTO,;
		SC0->C0_LOCAL,;
		SC0->C0_QUANT,;
		{	SC0->C0_NUMLOTE,;
		SC0->C0_LOTECTL,;
		SC0->C0_LOCALIZ,;
		SC0->C0_NUMSERI})

		U_FRCHKSDC(__cChaveSDC, "SISTEMA")

	EndIf

Return()


Static Function MailProc(_aDados, _cEmp)
	Local I 

	Private cHtml := ""

	GetHeader()
	GetColumnHeader()

	For I := 1 To Len(_aDados)

		GetItems(_aDados[I], _cEmp)

	Next I

	cHtml += ' </table>
	GetFooter()

	SendMail(_cEmp)  

Return


Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '      <head>
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtml += '         <title>cabtitpag</title>
	cHtml += '         <style type="text/css">
	cHtml += '			<!--
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			-->
	cHtml += '         </style>
	cHtml += '      </head>
	cHtml += '      <body>

Return()


Static Function GetColumnHeader()

	cHtml += '         <p><div class = "headTexto1">As seguintes RESERVAS foram excluídas devido a validade vencida:</div></p>
	cHtml += '         <p/>
	cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">
	cHtml += '            <tr align=center>                                            
	cHtml += '               <th class = "cabtab" width="15" scope="col"> Dt.Emis. </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Pedido </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Item </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Produto </th>
	cHtml += '               <th class = "cabtab" width="100" scope="col"> Descricao </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Lote </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Qtde. </th>
	cHtml += '               <th class = "cabtab" width="15" scope="col"> Reserva </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Solicitante </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Documento </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Obs. </th>
	cHtml += '               <th class = "cabtab" width="20" scope="col"> Vendedor </th>
	cHtml += '               <th class = "cabtab" width="30" scope="col"> Atendente </th>
	cHtml += '            </tr>

	Return()


	Static Function GetItems(_aDados, _cEmp)

	Local cRetNome := ""
	
	oGerenteAtendente	:= TGerenteAtendente():New()
	
	//se cod_cliente e cod_vendedor não forem nulos, buscar o atendente
	//if (!Empty(AllTrim(_aDados[12])) .And. !Empty(AllTrim(_aDados[13])))
		oResult 			:= oGerenteAtendente:GetCliente(_cEmp+"01", AllTrim(_aDados[12]), AllTrim(_aDados[14]), AllTrim(_aDados[13]))
	//endif
	
	If(!Empty(oResult:cAtendente))
		PswOrder(1)
		If (PswSeek(oResult:cAtendente, .T.))
			aUser		:= Pswret(1)  
			cRetNome	:= AllTrim(aUser[1][2])
		EndIf
	EndIf

	cHtml += " 			<tr align=center>                                                   
	cHtml += "          	<td class='style12' width='15'scope='col'>"+ _aDados[1] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ _aDados[3] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ _aDados[4] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ _aDados[5] +"</td>
	cHtml += "              <td class='style12' width='100'scope='col'>"+ AllTrim(_aDados[6]) +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ AllTrim(_aDados[10]) +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(_aDados[11],"@E 999,999.99") +"</td>
	cHtml += "          	<td class='style12' width='15'scope='col'>"+ _aDados[2] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ _aDados[7] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ _aDados[8] +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ AllTrim(_aDados[9]) +"</td>
	cHtml += "          	<td class='style12' width='20'scope='col'>"+ AllTrim(_aDados[13]) +"</td>
	cHtml += "          	<td class='style12' width='30'scope='col'>" + if(!Empty(AllTrim(_aDados[12])), oResult:cAtendente+" - "+cRetNome, '') + "</td>
	cHtml += "          </tr>

	Return()


	Static Function GetFooter()

	cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>
	cHtml += "          <tr>
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FROPRT09).</th>
	cHtml += "			</tr>
	cHtml += "		</table>
	cHtml += "      </body>
	cHtml += "   </html>
	cHtml += "   </html>

	Return()


	Static Function SendMail(_cEmp)
	Local _lRet

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	cFrom := "administrador@biancogres.com.br"
	cSubject := "Depuração de RESERVAS - "+ AllTrim(SM0->M0_NOME)

	cTo := U_EmailWF("FROPRT09",_cEmp)
	cCC := ""

	cBody := cHtml	
	cAttach := ""

	_lRet := U_BIAEnvMail(, cTo, cSubject, cBody, '', cAttach, , cCC)

	Return(_lRet)


	Static Function fAddHis(cHist, cProduto, cLocal, nQtd, cLote)

	If cHist == "S"

	RecLock("ZCD", .T.)

	ZCD->ZCD_FILIAL := xFilial("ZCD")
	ZCD->ZCD_CODIGO := GetSxEnum("ZCD", "ZCD_CODIGO")
	ZCD->ZCD_TIPO := "C"
	ZCD->ZCD_DATA := dDataBase
	ZCD->ZCD_HORA := Time()
	ZCD->ZCD_PRODUT := cProduto
	ZCD->ZCD_LOCAL := cLocal
	ZCD->ZCD_QTD := nQtd
	ZCD->ZCD_LOTE := cLote
	ZCD->ZCD_USR := cUserName

	ZCD->(MsUnLock())

	EndIf

	Return()
