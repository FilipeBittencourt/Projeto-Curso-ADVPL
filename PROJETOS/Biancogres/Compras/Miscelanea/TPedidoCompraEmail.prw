#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPedidoCompraEmail
@author Tiago Rossini Coradini
@since 27/12/2017
@version 1.0
@description Classe para controle de envio e retorno de pedidos de compra por e-mail 
@obs Ticket: 1146 - Projeto Demandas Compras - Item 2 - Complemento 1
@type class
/*/

Class TPedidoCompraEmail From LongClassName
	
	Data cEmp // Empresa logada
	Data cFil // Filial logada
	
	Data cNumPed // Numero do pedido de compra
	Data cCodApr // Codigo do aprovador
	Data cEmailApr // E-mail do aprovador
	Data cCodCom // Codigo do comprador
	Data cEmailCom // E-mail do comprador
	Data cCodFor // Codigo do fornecedor
	Data cLojFor // Loja do fornecedor
	Data cNomFor // Nome do fornecedor
	Data cEmailFor // E-mail do fornecedor
	Data cCodTra // Codigo do transportador
	Data cNomTra // Nome do transportador
	Data cEmailTra // E-mail do transportador
	Data cEnvTra // Enia e-mail ao transportador
	Data cTipFre // Tipo de frete
	Data cTipEnv // Tipo de envio: A=Automatico;M=Manual
	Data cChave // Chave de identificação, na confirmação do pedido por e-mail
			
	Data oServidor // Objeto(TMailManager) de gerenciamento de e-mail
	Data oMensagem // Objeto(TMailMessage) de mensagem de e-mail
	Data cServidor // Endereço do servidor de e-mail
	Data cSrvPOP
	Data cConta // Conta de e-mail
	Data cSenha // Senha do e-mail
	Data cEmail // endereço de e-mail
	
	Data cPtSMTP
	Data cPtPOP3
	Data lUseTLS
	Data lUseSSL
	Data lUseAut
	
	

	Method New() Constructor
	Method Inclui() // Inclui pedido
	Method Cancela() // Cancela pedido
	Method Atualiza() // Atualiza status do pedido 
	Method Existe() // Verifica se o pedido já existe
	Method Confirma() // Confirma o recebimento do pedido pelo fornecedor
	Method Envia() // Envia pedido por e-mail
	Method EnviaFor() // Envia e-mail para o fornecedor
	Method EnviaTra() // Envia e-mail para o transportador
	Method Recebe() // Recebe o pedido por e-mail
	Method Valida() // Valida o recebimento do pedido por e-mail 
	Method RetHtmlFor() // Retorna Html do e-mail que sera enviado ao fornecedor
	Method RetHtmlTra() // Retorna Html do e-mail que sera enviado ao transportador
	Method RetArqPed() // Retorna arquivo(TXT) que será anexado ao e-mail enviado ao fornecedor
	Method RetChave() // Renorta chave de validação do pedido
			
EndClass


Method New() Class TPedidoCompraEmail

	::cEmp := ""
	::cFil := ""
	
	::cNumPed := ""
	::cCodApr := ""
	::cEmailApr := ""
	::cCodCom := ""
	::cEmailCom := ""
	::cCodFor := ""
	::cLojFor := ""
	::cNomFor := ""
	::cEmailFor := ""
	::cCodTra := ""
	::cNomTra := ""	
	::cEmailTra := ""
	::cEnvTra := ""
	::cTipFre := ""
	::cTipEnv := ""
	::cChave := ""
		
	::oServidor := TMailManager():New()
	::oMensagem := TMailMessage():New()
	::cServidor := SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
	::cSrvPOP	:= SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)	
	::cConta 	:= GetMv("MV_YPCCT")
	::cSenha 	:= GetMv("MV_YPCSN")
	::cEmail 	:= GetMv("MV_YPCCT")
	//
	::lUseTLS 	:= GetMv("MV_RELTLS")
	::lUseSSL 	:= GetMv("MV_RELSSL")
	::lUseAUT 	:= GetMv("MV_RELAUTH")
	::cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))    
	::cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP"))))) 
			
Return()


Method Inclui() Class TPedidoCompraEmail 

	If ::Existe()
	
		::Cancela()
	
	EndIf
			
	RecLock("ZC2", .T.)
	
		ZC2->ZC2_FILIAL	:= xFilial("ZC2")
		ZC2->ZC2_EMP := cEmpAnt
		ZC2->ZC2_FIL := cFilAnt
		ZC2->ZC2_PEDIDO := ::cNumPed
		ZC2->ZC2_CODAPR := ::cCodApr
		ZC2->ZC2_EMAPR := ::cEmailApr
		ZC2->ZC2_CODCOM := ::cCodCom
		ZC2->ZC2_EMCOM := ::cEmailCom
		ZC2->ZC2_CODFOR := ::cCodFor
		ZC2->ZC2_EMFOR := ::cEmailFor
		ZC2->ZC2_CODTRA := ::cCodTra
		ZC2->ZC2_EMTRA := ::cEmailTra
		ZC2->ZC2_TIPENV := ::cTipEnv
		ZC2->ZC2_CHAVE := ::cChave
		ZC2->ZC2_DATENV := dDataBase 
		ZC2->ZC2_STATUS	:= "E"

	ZC2->(MsUnlock())
	
Return()


Method Cancela() Class TPedidoCompraEmail

	RecLock("ZC2", .F.)

		ZC2->ZC2_DATCAN := dDataBase
		ZC2->ZC2_STATUS := "C"

	ZC2->(MsUnlock())
		
Return()


Method Atualiza() Class TPedidoCompraEmail
Local nRecNoSC7 := 0
Local nRecNoZC2 := ZC2->(RecNo())
 	
	DbSelectArea("SC7")
	DbSetOrder(1)
	If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))

		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TPedidoCompraEmail:Atualiza()")
		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Empresa: "+ ::cEmp)
		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Pedido: "+ ::cNumPed)
		
		nRecNoSC7 := SC7->(RecNo())
		
		// Somente confirma automaticamente se ainda não foi confimado manualmente 
		If SC7->C7_YCONFIR <> "S"
			
			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Status: CONFIRMADO")
			
			While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed			
			
				RecLock("SC7", .F.)
					
					SC7->C7_YCONFIR := "S"
					SC7->C7_YTPCONF := "A"
					SC7->C7_YDATCON := dDatabase
								
				SC7->(MsUnLock())
					
				SC7->(DbSkip())
		
			EndDo()
			
		Else
		
			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Status: CONFIRMADO ANTERIORMENTE")
		
		EndIf
			
		SC7->(DbGoTo(nRecNoSC7))
		
		ZC2->(DbGoTo(nRecNoZC2))
		
		RecLock("ZC2", .F.)
			
			ZC2->ZC2_DATREC := dDataBase
			ZC2->ZC2_STATUS := "R"
			
		ZC2->(MsUnlock())
		
	EndIf
	
Return()


Method Existe() Class TPedidoCompraEmail
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT MAX(R_E_C_N_O_) AS RECNO "	
	cSQL += " FROM "+ RetSQLName("ZC2")
	cSQL += " WHERE ZC2_CHAVE = " + ValToSQL(::cChave)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->RECNO > 0
	
		DbSelectArea("ZC2")
		ZC2->(DbGoTo((cQry)->RECNO))
		
		lRet := .T.
			
	EndIf 

Return(lRet)


Method Confirma() Class TPedidoCompraEmail
	
	::cEmp := ZC2->ZC2_EMP
	::cFil := ZC2->ZC2_FIL
	::cNumPed := ZC2->ZC2_PEDIDO

	If cEmpAnt <> ::cEmp
	
		RpcClearEnv()
		
		RpcSetType(3)
		RpcSetEnv(::cEmp, ::cFil)
		
	EndIf
	
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TPedidoCompraEmail:Confirma()")	
			
	::Atualiza()
	
Return()


Method EnviaFor() Class TPedidoCompraEmail
Local lRet := .T.

	lRet := U_BIAEnvMail(, ::cEmailFor, "Pedido de Compra Num: " + ::cNumPed, ::RetHtmlFor(), "", ::RetArqPed())  

Return(lRet)


Method EnviaTra() Class TPedidoCompraEmail
Local lRet := .T.
	
	If ::cTipFre == "F" .And. ::cEnvTra == "S"
				
		lRet := U_BIAEnvMail(,::cEmailTra, "Pedido para transporte", ::RetHtmlTra(),,,, "vagner.salles@biancogres.com.br")
		
	EndIf
	
Return(lRet)


Method Envia() Class TPedidoCompraEmail
Local nRecNo := 0
		
	If ::EnviaFor() .And. ::EnviaTra()
		
		nRecNo := SC7->(RecNo())
		
		While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed
		
			RecLock("SC7", .F.)
			
				SC7->C7_YEMAIL := "S"				
				SC7->C7_YDTENV := dDataBase
				SC7->C7_YHRENV := SubStr(Time(), 1, 5)
				
			SC7->(MsUnLock())
			
			SC7->(DbSkip())
		
		EndDo()
		
		SC7->(DbGoTo(nRecNo))		
					
		::Inclui()
		
		If ::cTipEnv == "M"
		
			MsgInfo("Pedido de compra: " + ::cNumPed + " enviado com sucesso!", "Envio de pedido de compra")
			
		EndIf
	
	Else
	
		If ::cTipEnv == "M"
			
			MsgStop("Erro ao enviar o pedido de compra: " + ::cNumPed, "Envio de pedido de compra")
			
		EndIf
		
	EndIf
		
Return()


Method Recebe() Class TPedidoCompraEmail
Local nMsg := 0
Local nTotMsg := 0 
  
  ::oServidor := TMailMng():New(0, 2, 6)
 
  ::oServidor:cSrvAddr := SubStr(GetMv("MV_YSRVPOP"),1, RAT(':', GetMv("MV_YSRVPOP"))-1)	
  ::oServidor:cSMTPAddr := SubStr(GetMv("MV_RELSERV"),1, RAT(':', GetMv("MV_RELSERV"))-1)
  ::oServidor:nSrvPort := Val(SubStr(GetMv("MV_YSRVPOP"), RAT(':', GetMv("MV_YSRVPOP"))+1, Len(Alltrim(GetMv("MV_YSRVPOP")))))
  ::oServidor:cUser := GetMv("MV_YPCCT")
  ::oServidor:cPass := GetMv("MV_YPCSN")
  
   If ::oServidor:Connect() == 0

	  ::oServidor:GetNumMsgs(@nTotMsg)
	  
	  For nMsg := 1 To nTotMsg
	      
	    ::oMensagem:Clear()
	     
	    ::oMensagem:Receive2(::oServidor, nMsg)	    	    	     	    	    
	    
	    ConOut(cValToChar(dDataBase) + "-" + Time() + " -- TPedidoCompraEmail:Recebe()")
	    
	    If ::Valida()
	    	
	    	::Confirma()
	    
	    EndIf
	    	    	    
	    ::oServidor:DeleteMsg(nMsg)	    
	    
	  Next
	  
	  ::oServidor:Disconnect()
  
  EndIf
  		
Return()


Method Valida()	Class TPedidoCompraEmail
Local lRet := .F.
Local cFrom := ""
Local nPos := 0

	::cChave := ::RetChave()		
	
	If !Empty(::cChave) .And. ::Existe()
	
		cFrom := Lower(::oMensagem:cFrom)
	
		If (nPos := At("<", cFrom)) > 0
		
			cFrom := SubStr(cFrom, nPos + 1)
			
			If (nPos := At(">", cFrom)) > 0
				
				cFrom := Left(cFrom, nPos - 1)
				
			EndIf
			
		EndIf
	
		If ZC2->ZC2_STATUS == "E" .And. Lower(AllTrim(cFrom)) $ Lower(AllTrim(ZC2->ZC2_EMFOR))
			
			lRet := .T.
			
		EndIf
	
	EndIf
	
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TPedidoCompraEmail:Valida()")
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Email: "+ AllTrim(cFrom))
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Chave: "+ ::cChave)
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Valida: " + If (lRet, "SIM", "NAO") )		

Return(lRet)


Method RetHtmlFor() Class TPedidoCompraEmail
Local cSQL := ""
Local cQry := GetNextAlias()
Local cHtml := ""
Local cNomCon := ""
Local cEmailCon := ""
Local nCount := 1
Local cMailNfe := "" 
Local lServ := .F.
Local cConPag := ""
Local nTotMer := 0
Local nTotIpi := 0
Local nTotFre := 0
Local nTotDes := 0
Local nTotDesp := 0
Local nTotGer := 0
Local cObs := ""
Local cImp := ""
Local cTpFre := ""

	cSQL := " SELECT * " 
	cSQL += " FROM "+ RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += "	AND C7_NUM = " + ValToSQL(::cNumPed)
	cSQL += "	AND C7_FORNECE = " + ValToSQL(::cCodFor)
	cSQL += "	AND C7_LOJA = " + ValToSQL(::cLojFor) 
	cSQL += "	AND C7_RESIDUO = '' "
	cSQL += "	AND C7_ENCER = '' "
	cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL += "	AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof()) 
			
		cNomCon := (cQry)->C7_USER	
		cEmailCon :=	Lower(UsrRetMail(cNomCon))
		
		PswOrder(1)
		
		If (!Empty(cNomCon) .And. PswSeek(cNomCon))	
	
			cNomCon:= PswRet(1)[1][4]
			
		EndIf
		
		cLink := '<a href="mailto:'+ ::cEmail +'?subject=Confirmação do pedido de compra: '+ ::cNumPed + '&body=KEY:'+ ::cChave +'">** CLIQUE AQUI PARA CONFIRMAR O PEDIDO DE COMPRA **</a></span><br /><br />'
		
		cHtml := '<style type="text/css">
		cHtml += 'body{ font-family: Verdana; font-size: 10px; }
		cHtml += 'a{text-decoration: none;}
		cHtml += '.mainTableCss{ max-width: 950px;  }
		cHtml += '.tblDadosComprador,.tblDadosFornecedor,.tblDadosItens,.tblTotais,.tblDadosTransportadora { border: 1px solid #c6c6c6; padding: 5px; width: 100%; }
		cHtml += '.mainTableCss tr,.tblDadosComprador tr,.tblDadosFornecedor tr,.tblTotais tr,.tblDadosTransportadora tr{ }
		cHtml += '.mainTableCss th,.tblDadosComprador th,.tblDadosFornecedor th,.tblDadosItens th,.tblTotais th,.tblDadosTransportadora th{ padding: 10px; }
		cHtml += '.mainTableCss td,.tblDadosComprador td,.tblDadosFornecedor td,.tblDadosItens td,.tblTotais td,.tblDadosTransportadora td{ padding: 2px 10px 2px 10px; font-size: 12px; }
		cHtml += '.tblItensPedido td{border-top: 1px solid #c6c6c6; border-bottom: 1px solid #c6c6c6; } 
		cHtml += '.tblItensPedido-border-left{ border-left: 1px solid #c6c6c6; padding:1px 1px 1px 1px; } 
		cHtml += '.tblItensPedido-border-right{ border-right: 1px solid #c6c6c6; border-left: 1px solid #c6c6c6; padding:1fpx 1px 1px 1px;} 
		cHtml += '.titleCss{ font-size: 14px; } 
		cHtml += '.titleTable{ background-color: #C6C6C6; font-size: 14px; }
		cHtml += '.linkConfirmacao{ font-size: 12px; color: blue; font-weight: bold; }
		cHtml += '</style>
		cHtml += '<table class="mainTableCss" >
		cHtml += '	<tr class="">
		cHtml += '		<th colspan="2" valign="top">
		
		cHtml += '			<span class="linkConfirmacao">' + cLink		
		
		cHtml += '			<span class="titleCss">PEDIDO DE COMPRA: '+((cQry)->C7_NUM)+'</span><span>
		cHtml += '		</th>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td align="left" valign="top">
		cHtml += '			<table class="tblDadosComprador">
		cHtml += '				<tr class="titleTable"><th>DADOS DO COMPRADOR</th></tr>
		cHtml += '				<tr><td><b>Razão Social do Comprador:&nbsp;</b>'+ Capital(SM0->M0_NOMECOM) +'</td></tr>
		cHtml += '				<tr><td><b>CNPJ:&nbsp;</b>' + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") +'</td></tr>
		cHtml += '				<tr><td><b>Endereço:&nbsp;</b>'+ Capital(SM0->M0_ENDCOB) +'</td></tr>
		cHtml += '				<tr><td><b>Município:&nbsp;</b>'+ Capital(SM0->M0_CIDCOB) +'</td></tr>
		cHtml += '				<tr><td><b>Estado:&nbsp;</b>'+ SM0->M0_ESTCOB +'</td></tr>
		cHtml += '				<tr><td><b>CEP:&nbsp;</b>'+ TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999") +'</td></tr>
		cHtml += '				<tr><td><b>País:&nbsp;</b>Brasil</td></tr>
		cHtml += '				<tr><td><b>Contato:&nbsp;</b>'+ Capital(cNomCon) +'</td></tr>
		cHtml += '				<tr><td><b>E-mail:&nbsp;</b>'+ Lower(Alltrim(cEmailCon)) +'</td></tr>
		cHtml += '				<tr><td><b>Telefone:&nbsp;</b>'+ AllTrim(SM0->M0_TEL) +'</td></tr>
		cHtml += '			</table>
		cHtml += '		</td>
		cHtml += '		<td align="right" valign="top">
		cHtml += '			<table class="tblDadosFornecedor">
		cHtml += '				<tr class="titleTable"><th>DADOS DO FORNECEDOR</th></tr>
		cHtml += '				<tr><td><b>Razão Social do Comprador:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_NOME)) +'</td></tr>

		If Alltrim(SA2->A2_TIPO) == "J"
			cHtml += '				<tr><td><b>CNPJ:&nbsp;</b>'+ TRANSFORM(SA2->A2_CGC,"@R 99.999.999/9999-99") +'</td></tr>
		Else
			cHtml += '				<tr><td><b>CPF:&nbsp;</b>'+ TRANSFORM(SA2->A2_CGC,"@R 999.999.999-99") +'</td></tr>
		EndIf

		cHtml += '				<tr><td><b>Endereço:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_END)) +'</td></tr>
		cHtml += '				<tr><td><b>Município:&nbsp;</b>'+ Capital(SA2->A2_MUN) +'</td></tr>
		cHtml += '				<tr><td><b>Estado:&nbsp;</b>'+ SA2->A2_EST +'</td></tr>
		cHtml += '				<tr><td><b>CEP:&nbsp;</b>'+ TRANSFORM(SA2->A2_CEP,"@R 99999-999") +'</td></tr>
		cHtml += '				<tr><td><b>País:&nbsp;</b>'+ If (Alltrim(SA2->A2_EST) == 'EX', 'Exterior', 'Brasil') +'</td></tr>
		cHtml += '				<tr><td><b>Contato:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_CONTATO)) +'</td></tr>
		cHtml += '				<tr><td><b>E-mail:&nbsp;</b>'+ Lower(Alltrim(SA2->A2_EMAIL)) +'</td></tr>
		cHtml += '				<tr><td><b>Telefone:&nbsp;</b>'+ Alltrim(SA2->A2_TEL) +'</td></tr>
		cHtml += '			</table>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td colspan="2" valign="top">
		cHtml += '			<table class="tblDadosItens">
		cHtml += '				<tr class="titleTable"><th>ITENS DO PEDIDO DE COMPRA</th></tr>
		cHtml += '				<tr>
		cHtml += '					<td>
		cHtml += '						<table class="tblItensPedido" cellpadding="0" cellspacing="0">
		cHtml += '							 <tr>
		cHtml += '								<th> ITEM </th>
		cHtml += '								<th> TP </th>
		cHtml += '								<th> CODIGO </th>
		cHtml += '								<th> DESCRIÇÃO </th>
		cHtml += '								<th> UN </th>
		cHtml += '								<th> SAIDA </th>
		cHtml += '								<th> IMP </th>
		cHtml += '								<th> QUANTIDADE </th>
		cHtml += '								<th> PREÇO </th>
		cHtml += '								<th> IPI </th>
		cHtml += '								<th> TOTAL </th>
		cHtml += '								<th> S.C </th>
		cHtml += '								<th> MOEDA </th>
		cHtml += '								<th> OBSERVAÇÃO </th>
		cHtml += '								<th> ARMAZÉM </th>
		cHtml += '								<th> PORTARIA </th>
		cHtml += '							 </tr>

		lServ := .F.
		
		nTotMer := 0
		nTotIpi := 0
		nTotFre := 0
		nTotDes := 0
		nTotDesp := 0
		
		cTpFre := If ((cQry)->C7_TPFRETE == "C", "CIF", "FOB")

		//ITENS
		While !(cQry)->(Eof())

			cHtml += '							 <tr>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ POSICIONE("SB1",1,XFILIAL("SB1")+(cQry)->C7_PRODUTO,"B1_TIPO") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_PRODUTO) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_DESCRI) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_UM) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ SUBSTR((cQry)->C7_DATPRF,7,2)+"/"+SUBSTR((cQry)->C7_DATPRF,5,2)+"/"+SUBSTR((cQry)->C7_DATPRF,1,4) +'</td>

			cImp := IIf((cQry)->C7_YICMS = "S","M","") + IIf((cQry)->C7_YPIS = "S","P","")
			cImp += IIf((cQry)->C7_YCOF = "S","M","C") + IIf((cQry)->C7_YIPI = "S","I","")

			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(cImp) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_QUANT	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_PRECO	,"@E 999,999,999.9999") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_IPI	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_TOTAL	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ (cQry)->C7_NUMSC +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(GetMv("MV_MOEDA" + Alltrim(Str((cQry)->C7_MOEDA)))) +'</td>
			cHtml += '								<td class="tblItensPedido-border-right">'+ ALLTRIM((cQry)->C7_OBS) +'</td>
			cHtml += '								<td class="tblItensPedido-border-right">'+ ALLTRIM((cQry)->C7_LOCAL) +'</td>
			cHtml += '								<td class="tblItensPedido-border-right">'+ ALLTRIM(fGetPort((cQry)->C7_PRODUTO, (cQry)->C7_LOCAL)) +'</td>

			cConPag := Posicione("SE4",1,xFilial("SE4")+(cQry)->C7_COND,"E4_DESCRI")
			nTotMer += (cQry)->C7_TOTAL
			nTotIpi += round((( (cQry)->C7_PRECO/100)* (cQry)->C7_IPI) * (cQry)->C7_QUANT,2)
			nTotFre += (cQry)->C7_VALFRE
			nTotDes += (cQry)->C7_VLDESC
			nTotDesp += (cQry)->C7_DESPESA
			
			If (Empty(cObs), cObs := (cQry)->C7_VLDESC, "") 
			
			If Substr((cQry)->C7_PRODUTO,1,3) == "306"
				lServ := .T.
			EndIf
				   
			(cQry)->(DbSkip())
			
			nCount ++
				                                          
		EndDo()     

		nTotGer := (nTotMer+nTotIpi+nTotFre+nTotDesp) - nTotDes

		cHtml += '							 </tr> 
		cHtml += '						</table>
		cHtml += '					</td>
		cHtml += '				</tr>
		cHtml += '			</table>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td valign="top">
		cHtml += '			<table class="tblTotais" >
		cHtml += '				<tr class="titleTable"><th colspan="2">TOTAIS</th></tr>
		cHtml += '				<tr><td><b>Total das Mercadorias:&nbsp;</b></td><td>'+ Transform(nTotMer,"@E 999,999,999.99") +'</td></tr>
		cHtml += '				<tr><td><b>Valor IPI:&nbsp;</b></td><td>'+ Transform(nTotIpi,"@E 999,999,999.99") +'</td></tr>
		cHtml += '				<tr><td><b>Tipo FRETE:&nbsp;</b></td><td>'+ cTpFre +'</td></tr>
		cHtml += '				<tr><td><b>Valor FRETE:&nbsp;</b></td><td>'+ Transform(nTotFre,"@E 999,999,999.99") +'</td></tr>
		cHtml += '				<tr><td><b>Despesa:&nbsp;</b></td><td>'+ Transform(nTotDesp,"@E 999,999,999.99") +'</td></tr>
		cHtml += '				<tr><td><b>Desconto:&nbsp;</b></td><td>'+ Transform(nTotDes,"@E 999,999,999.99") +'</td></tr>
		cHtml += '				<tr><td><b>Total Geral:&nbsp;</b></td><td>'+ Transform(nTotGer,"@E 999,999,999.99") +'</td></td>
		cHtml += '				<tr><td><b>Cond. Pagamento:&nbsp;</b></td><td>'+ Alltrim(cConPag) +'</td></tr>
		cHtml += '			</table>
		cHtml += '		</td>
		cHtml += '		<td valign="top">
		cHtml += '			<table class="tblDadosTransportadora">
		cHtml += '				<tr class="titleTable"><th colspan="2">DADOS DA TRANSPORTADORA</th></tr>
		cHtml += '				<tr><td><b>TRANSPORTADORA:&nbsp;</b></td><td>'+ Capital(Alltrim(::cNomTra)) +'</td></tr>
		cHtml += '			</table>
		cHtml += '		</td>			
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '	<tr>
		cHtml += '		<td colspan="2" valign="top">
		cHtml += '			<table class="tblDadosItens" width="100%">
		cHtml += '				<tr class="titleTable"><th>INFORMAÇÃO OBRIGATÓRIA</th></tr>
		cHtml += '				<tr>
		cHtml += '					<td>
		cHtml += '						 1 - Informar o número do pedido de compra no XML da NF-e na TAG ESPECÍFCA, bem como no campo de OBSERVAÇÃO do DANFE, caso não tenha está informação, a nota fiscal poderá ser recusada.<br />
		cHtml += '						 2 - Informar o Armazém e a Portaria no campo de OBSERVAÇÃO do DANFE.<br />
		cHtml += '						 3 - Discriminar a classificação fiscal do produto conforme tabela do IPI, caso não haja campo específico na nota fiscal informar uma relação em anexo.<br />
		cHtml += '						 4 - Conferir se os dados cadastrais que constam no pedido estão de acordo com emissão da NF.<br />

		If cEmpAnt == "01"
			cMailNfe := 'nf-e.biancogres@biancogres.com.br'
		ElseIf cEmpAnt == "05"
			cMailNfe := 'nf-e.incesa@incesa.ind.br '
		ElseIf cEmpAnt == "07"
			cMailNfe := 'nf-e.lmcomercio@biancogres.com.br'
		ElseIf cEmpAnt == "12"
			cMailNfe := 'nf-e.stgestao@biancogres.com.br'
		ElseIf cEmpAnt == "13"
			cMailNfe := 'nf-e.mundi@biancogres.com.br'
		ElseIf cEmpAnt == "14"
			cMailNfe := 'nf-e.vitcer@biancogres.com.br'
		Else
			cMailNfe := 'nf-e.biancogres@biancogres.com.br'
		EndIf

		cHtml += '						 5 - Empresa autorizada a emissão de Nota Fiscal Eletrônica deverá enviar o arquivo XML, para o endereço eletrônico: '+ cMailNfe +'<br />
		cHtml += '						 6 - Os pagamentos referentes a esse pedido de compras somente serão feitos através de emissão de boletos bancários registrados.<br />
		cHtml += '						 7 - Não será permitido o desconto de títulos com bancos, empresas de factoring e/ou repasse de direitos a favor de terceiros.<br />
		cHtml += '						 8 – As entregas devem ser realizadas na portaria indicada no pedido.<br />
		cHtml += '						 9 - As NFs de <b>SERVIÇO</b> só poderão ser emitidas e entregue em mãos, até o dia 24 de cada mês.<br />
		cHtml += '						10 - Toda NF de <b>SERVIÇO</b> de fornecedor optante pelo simples, deverá ser entregue juntamente com a declaração assinada e carimbada.<br />
		cHtml += '					</td>
		cHtml += '				</tr>
		cHtml += '			</table>
		cHtml += '		</td>
		cHtml += '	</tr>
		cHtml += '</table>

	EndIf

	(cQry)->(DbCloseArea()) 
	
Return(cHtml)


Method RetHtmlTra() Class TPedidoCompraEmail
Local cSQL := ""
Local cQry := GetNextAlias()
Local cHtml := ""
Local nTotPed := 0

	cSQL := " SELECT C7_NUM, C7_PRODUTO, C7_LOCAL, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL, C7_QUJE, C7_DATPRF, C7_YDATCHE, C7_EMISSAO, C7_TIPO, "
	cSQL += " C7_UM, C7_TES, C7_YICMS, C7_YPIS, C7_YCOF, C7_YIPI, C7_IPI, C7_NUMSC, C7_COND, C7_VALFRE, C7_VLDESC, C7_OBS " 
	cSQL += " FROM "+ RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += "	AND C7_NUM = " + ValToSQL(::cNumPed)
	cSQL += "	AND C7_FORNECE = " + ValToSQL(::cCodFor)
	cSQL += "	AND C7_LOJA = " + ValToSQL(::cLojFor) 
	cSQL += "	AND C7_RESIDUO = '' "
	cSQL += "	AND C7_ENCER = '' "
	cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL += "	AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
	
		cHtml := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		cHtml += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
		cHtml += ' <head> '
		cHtml += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		cHtml += ' <title>Untitled Document</title> '
		cHtml += ' <style type="text/css"> '
		cHtml += ' <!-- '
		cHtml += ' .style12 {font-size: 9px; } '
		cHtml += ' .style18 {font-size: 10} '
		cHtml += ' .style21 {color: #FFFFFF; font-size: 9px; } '
		cHtml += ' .style22 { '
		cHtml += ' 	font-size: 10pt; '
		cHtml += ' 	font-weight: bold; '
		cHtml += ' } '
		cHtml += ' .style35 {font-size: 10pt; } '
		cHtml += ' .style36 {font-size: 9pt; } '
		cHtml += ' .style39 {font-size: 12pt; } '
		cHtml += ' .style41 { '
		cHtml += ' 	font-size: 12px; '
		cHtml += ' 	font-weight: bold; '
		cHtml += ' } '
		cHtml += ' .style42 {font-size: 12px; } '
		cHtml += '  '
		cHtml += ' --> '
		cHtml += ' </style> '
		cHtml += ' </head> '
		cHtml += '  '
		cHtml += ' <body> '
		cHtml += ' <table width="956" border="1"> '
		cHtml += '   <tr> '
		cHtml += '     <th width="751" rowspan="3" scope="col">ROMANEIOS REALIZADOS NO DIA </th> '
		cHtml += '     <td width="189" class="style12"><div align="right"> DATA EMISSÃO: '+ dtoC(dDataBase) +' </div></td> '
		cHtml += '   </tr> '
		cHtml += '   <tr> '
		cHtml += '     <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+Subs(Time(),1,8)+' </div></td> '
		cHtml += '   </tr> '
		cHtml += '   <tr> '
		 
		If cEmpAnt = "01"
			cHtml += '    <td><div align="center" class="style41"> BIANCOGRES CERÂMICA SA </div></td> '
		ElseIf cEmpAnt = "05"
			cHtml += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
		ElseIf cEmpAnt = "07"
			cHtml += '    <td><div align="center" class="style41"> LM COMERCIO LTDA </div></td> '
		ElseIf cEmpAnt = "12"
			cHtml += '    <td><div align="center" class="style41"> ST GESTAO DE NEGOCIOS LTDA </div></td> '
		ElseIf cEmpAnt = "13"
			cHtml += '    <td><div align="center" class="style41"> MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA </div></td> '
		EndIf
		
		cHtml += '   </tr> '
		cHtml += ' </table> '
		cHtml += '  '
		cHtml += ' <table width="956" border="1"> '		
		cHtml += '   <tr bgcolor="#FFFFFF"> '
		cHtml += '     <th colspan="5" scope="col"><div align="left" class="style42"> TRANSPORTADORA: '+ ::cCodTra +' - '+ ::cNomTra +' </div></th> '
		cHtml += '   </tr> '		
		cHtml += '   <tr bgcolor="#FFFFFF"> '
		cHtml += '     <th colspan="5" scope="col"><div align="left" class="style42">FORNECEDOR: '+ ::cCodFor +' - '+ ::cNomFor +' </div></th> '
		cHtml += '   </tr> '		
		cHtml += '   <tr bgcolor="#0066CC"> '
		cHtml += '     <th width="223"	scope="col"><span class="style21"> Produto  </span></th> '
		cHtml += '     <th width="380" scope="col"><span class="style21"> Descrição </span></th> '
		cHtml += '     <th width="132" 	scope="col"><span class="style21"> Quantidade </span></th> '
		cHtml += '     <th width="100" scope="col"><span class="style21"> Data Entrega </span></th> '
		cHtml += '     <th width="70"	scope="col"><span class="style21"> Armazém  </span></th> '
		cHtml += '     <th width="223"	scope="col"><span class="style21"> Portaria  </span></th> '
		cHtml += '   </tr> '
		cHtml += '    '
		cHtml += '   <tr bgcolor="#FFFFFF"> '
		cHtml += '     <th colspan="5" scope="col"><div align="left" class="style42">Pedido N&ordm; '+ ::cNumPed +' </div></th> '
		cHtml += '   </tr> '		
		cHtml += '    '
		cHtml += '    '
		
		nTotPed := 0
		
		While !(cQry)->(Eof())
		
			cHtml += '   <tr> '
			cHtml += '     <td class="style12"> '+(cQry)->C7_PRODUTO+' </td> '
			cHtml += '     <td class="style12"> '+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+(cQry)->C7_PRODUTO,"B1_DESC"))+' </td> '
			cHtml += '     <td class="style12"> '+PADR(Transform(((cQry)->C7_QUANT - (cQry)->C7_QUJE),    "@E 999,999,999.99"),15)+' </td> '
			cHtml += '     <td class="style12"> '+PADC(ALLTRIM(DTOC(STOD((cQry)->C7_DATPRF))),11)+' </td> '		
			cHtml += '     <td class="style12"> '+(cQry)->C7_LOCAL+' </td> '
			cHtml += '     <td class="style12"> '+fGetPort((cQry)->C7_PRODUTO,(cQry)->C7_LOCAL)+' </td> '
			cHtml += '   </tr> '
			
			nTotPed += ((cQry)->C7_QUANT - (cQry)->C7_QUJE)
			
			(cQry)->(DbSkip())
		
		EndDo()
	
		cHtml += '    '
		cHtml += '   <tr bordercolor="#FFFFFF"> '
		cHtml += '     <td colspan="5">&nbsp;</td> '
		cHtml += '   </tr> '
		cHtml += '  '
		
		cHtml += '	  <tr>
		cHtml += '	    <td colspan="2" class="style18"><span class="style22">Total do Pedido :  </span></td>
		cHtml += '	    <td class="style12"> '+ALLTRIM(STR(nTotPed))+' </div></td>
		cHtml += '	 	 <td class="style12">  </div></td>
		cHtml += '	  	 <td class="style12">  </div></td>
		cHtml += '	  </tr>
		
		cHtml += '  <tr bordercolor="#FFFFFF" class="style18"> '
		cHtml += '    <td colspan="5" class="style36">&nbsp;</td> '
		cHtml += '  </tr> '
		cHtml += '</table> '
		cHtml += 'Esta é uma mensagem automática, favor não responde-la. '
		cHtml += '</body> '
		cHtml += '</html> '
		
	EndIf

Return(cHtml)


Method RetArqPed() Class TPedidoCompraEmail
Local cArqTxt := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local lServ := .F.
Local cLin := ""
Local nIdx := 1
Local nQtd := 0
Local cConPag := ""
Local nTotMer := 0
Local nTotIpi := 0
Local nTotFre := 0
Local nTotDes := 0
Local nTotDesp := 0
Local nTotGer := 0
Local cObs := ""
Local cImp := ""
Local cEOL := Chr(13) + Chr(10)
Local _cPortaria	:= ""	

	cSQL := " SELECT * " 
	cSQL += " FROM "+ RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += "	AND C7_NUM = " + ValToSQL(::cNumPed)
	cSQL += "	AND C7_FORNECE = " + ValToSQL(::cCodFor)
	cSQL += "	AND C7_LOJA = " + ValToSQL(::cLojFor) 
	cSQL += "	AND C7_RESIDUO = '' "
	cSQL += "	AND C7_ENCER = '' "
	cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL += "	AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof()) 
		
		cArqTxt := "\P10\relato\PC\" + ::cCodFor + "_PC.TXT"
		
		nHdl := fCreate(cArqTxt)
			
		cLin := PADL("EMISSAO: " + ALLTRIM(DTOC(STOD((cQry)->C7_EMISSAO))),126)
		fWrite(nHdl,cLin+cEOL)
				
		cLin := REPLICATE(" ",56) + "####################"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := REPLICATE(" ",56) + "# PEDIDO DE COMPRA #" + REPLICATE(" ",10) + PADL((cQry)->C7_NUM,7)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := REPLICATE(" ",56) + "####################"
		fWrite(nHdl,cLin+cEOL)		
		
		cLin := "  " + REPLICATE("_",61) + "     " + REPLICATE("_",61)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " |" + REPLICATE(" ",60) + " |   |" + REPLICATE(" ",60) + " |"
		fWrite(nHdl,cLin+cEOL)
	
		If cEmpAnt == "01"
			
			cLin := PADR(" |BIANCOGRÊS CERÂMICA S/A ",62) + PADR(" |   |FORN..:" + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",66) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Av.Talma Rodrigues Ribeiro, 1145 Civit II ",62) + PADR(" |   |END...:" + SA2->A2_END,66) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Cep: 29.168-080, Serra/ES ",62) + PADR(" |   |CIDADE:" + SA2->A2_MUN,30) + PADR("UF..:" + SA2->A2_EST,18) + PADR("CEP:" + SA2->A2_CEP,18)+ " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR(" |   |C.G.C.:" + SA2->A2_CGC,30) + PADR("I.E.:" + SA2->A2_INSCR,36) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |Fax: ",62) + PADR(" |   |TEL...:" + SA2->A2_TEL,30) + PADR("FAX.:" + SA2->A2_FAX,36) + " |"
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR(" |CGC: 02.077.546/0001-76  IE: 081936443 ",62) + PADR(" |   |CONT..:" + SA2->A2_CONTATO,66) + " |"
			fWrite(nHdl,cLin+cEOL)
		
		ElseIf cEmpAnt == "05"
		
			cLin := PADR("INCESA REVESTIMENTO CERAMICO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua 3, 648, Civit II                     ",62)  		+ PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-079, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9127/(27)3421-9114/(27)3421-9116 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: ",62)										+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 04.917.232/0001-60  IE: 082.140.12-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		
		ElseIf cEmpAnt == "07"
		
			cLin := PADR("LM COMERCIO LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Dois, Lote 07 Quadra VI - Civit II",62)  		+ PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-081, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9001 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62)						+ PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 10.524.837/0001-93  IE: 082.591.70-9 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
			
		ElseIf cEmpAnt == "12"
		
			cLin := PADR("ST GESTAO DE NEGOCIOS LTDA ",62)	+ PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Dois, 246, Quadra VI, Lote 07, SL 04, Civit II",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-081, Serra/ES ",62)			+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9100 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 13.231.737/0001-67 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
			
		ElseIf cEmpAnt == "13"
			
			cLin := PADR("MUNDI COMERCIO EXTERIOR E LOGISTICA LTDA ",62) + PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Rua Holdercim, 165, Lote 03, Quadra VI, Civit II ",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Cep: 29.168-066, Serra/ES ",62)	+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9039 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("CGC: 14.086.214/0001-37  IE: 082.819.61-0 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
			        
		ElseIf cEmpAnt == "14"
			
			cLin := PADR("BIANCOGRES VINILICO LTDA ",62) + PADR("FORN..:"  + SA2->A2_COD + " " + SA2->A2_LOJA + " " + SA2->A2_NOME + " ",50)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("R CINCO, S/N, LOTE 001 QUADRA8-A, Civit II ",62) + PADR("END...:" + SA2->A2_END,50)
			fWrite(nHdl,cLin+cEOL)     
			cLin := PADR("Cep: 29.160-073, Serra/ES ",62)	+ PADR("CIDADE:" + SA2->A2_MUN,20) + PADR("UF..:" + SA2->A2_EST,8) + "CEP:" + SA2->A2_CEP
			fWrite(nHdl,cLin+cEOL)   
			cLin := PADR("Tel: (27)3421-9000 ",62) + PADR("C.G.C.:" + SA2->A2_CGC,20) + PADR("I.E.:" + SA2->A2_INSCR,8)
			fWrite(nHdl,cLin+cEOL)
			cLin := PADR("Fax: (27)3421-9000 ",62) + PADR("TEL...:" + SA2->A2_TEL,20) + PADR("FAX.:" + SA2->A2_FAX,8)
			fWrite(nHdl,cLin+cEOL)  
			cLin := PADR("CGC: 08.930.868/0001-00  IE: 082.468.96-6 ",62)	+ PADR("CONT..:" + SA2->A2_CONTATO,20)
			fWrite(nHdl,cLin+cEOL)
		
		EndIf
		
		cLin := " |" + REPLICATE("_",61) + "|   |" + REPLICATE("_",61) + "|"
		fWrite(nHdl,cLin+cEOL)
		cLin := REPLICATE(" ",120)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " " + REPLICATE("-",129)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADC(" TP",4)
		cLin += PADC("COD",9)
		cLin += PADR("DESCRICAO",34)
		cLin += PADC("UN",5)
		cLin += PADC("DT.SAI.",11)		
		cLin += PADC("TES",4)
		cLin += PADC("IMP.",4)
		cLin += PADL("QTD",15)
		cLin += PADL("P.UNIT",15)
		cLin += PADC("IPI",6)
		cLin += PADL("VAL.TOT",15)
		cLin += PADC("S.C",6)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " " + REPLICATE("-",129)
		fWrite(nHdl,cLin+cEOL)
		
		While !(cQry)->(Eof())
			
			If SubStr((cQry)->C7_PRODUTO,1,3) == "306"
				lServ := .T.
			EndIf
						
			nIdx := 1
			nQtd := 0
			
			cLin := " " + PADR(POSICIONE("SB1",1,XFILIAL("SB1")+(cQry)->C7_PRODUTO,"B1_TIPO"),3)
			cLin += PADC((cQry)->C7_PRODUTO,9)
			cLin += PADR((cQry)->C7_DESCRI,34)
			cLin += PADC((cQry)->C7_UM,5)
			cLin += PADC(ALLTRIM(DTOC(STOD((cQry)->C7_DATPRF))),11)		
			cLin += PADC((cQry)->C7_TES,4)
			
			cImp := IIf((cQry)->C7_YICMS = "S","M","") + IIf((cQry)->C7_YPIS = "S","P","")
			cImp += IIf((cQry)->C7_YCOF = "S","M","C") + IIf((cQry)->C7_YIPI = "S","I","")
			
			cLin += PADC(cImp,4)
			cLin += PADR(Transform((cQry)->C7_QUANT,    "@E 999,999,999.99"),15)
			cLin += PADR(Transform((cQry)->C7_PRECO,    "@E 99,999,999.9999"),15)
			cLin += PADC((cQry)->C7_IPI,6)
			cLin += PADR(Transform((cQry)->C7_TOTAL,    "@E 999,999,999.99"),15)
			cLin += PADC((cQry)->C7_NUMSC,6)
			fWrite(nHdl,cLin+cEOL)
						
			nQtd := LEN(ALLTRIM((cQry)->C7_DESCRI)) - 34
			nIdx := 35
			
			While nQtd > 34
				cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM((cQry)->C7_DESCRI), nIdx, 34)
				fWrite(nHdl,cLin+cEOL)
				nIdx := nIdx + 34
				nQtd := nQtd - 34
			EndDo()
			
			If nQtd <> 0
				cLin := REPLICATE(" ",13) + SUBSTRING(ALLTRIM((cQry)->C7_DESCRI), nIdx, 34)
				fWrite(nHdl,cLin+cEOL)
			EndIf
			
			cLin := ALLTRIM("  OBSERVAÇÃO: " + ALLTRIM((cQry)->C7_OBS))
			
			If cLin <> ""
				fWrite(nHdl,cLin+cEOL)
			EndIf
			
			cLin := ALLTRIM("  ARMAZÉM PARA ENTREGA: " + ALLTRIM((cQry)->C7_LOCAL))

			If cLin <> ""
				fWrite(nHdl,cLin+cEOL)
			EndIf

			_cPortaria	:=	fGetPort((cQry)->C7_PRODUTO,(cQry)->C7_LOCAL)
			
			If !Empty(_cPortaria)
				cLin := ALLTRIM("  PORTARIA PARA ENTREGA: " + ALLTRIM(_cPortaria))
			EndIf
			
			If cLin <> ""
				fWrite(nHdl,cLin+cEOL)
			EndIf
			
			cConPag := Posicione("SE4",1,xFilial("SE4")+(cQry)->C7_COND,"E4_DESCRI")
			nTotMer += (cQry)->C7_TOTAL
			nTotIpi += round((( (cQry)->C7_PRECO/100)* (cQry)->C7_IPI) * (cQry)->C7_QUANT,2)
			nTotFre += (cQry)->C7_VALFRE
			nTotDes += (cQry)->C7_VLDESC
			nTotDesp += (cQry)->C7_DESPESA
			
			If (Empty(cObs), cObs := (cQry)->C7_VLDESC, "")			
			
			(cQry)->(DbSkip())
		
		EndDo()
				
		nTotGer := (nTotMer+nTotIpi+nTotFre+nTotDesp) - nTotDes
		
		cLin := " "
		fWrite(nHdl,cLin+cEOL)
		cLin := " "
		fWrite(nHdl,cLin+cEOL)
		
		cLin := "  " + REPLICATE("_",127)
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " |" + REPLICATE(" ",38) + " |" + REPLICATE(" ",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |TOTAL DAS MERCADORIAS.: ",25)	+	PADR(Transform(nTotMer,    "@E 999,999,999.99"),15) + " |"
		cLin += PADR(" Transportadora : " + ::cNomTra ,86)  + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |VALOR IPI.............: ",25)	+	PADR(Transform(nTotIpi,    "@E 999,999,999.99"),15) 	+ " |"
		cLin += PADR(" " + Replicate("-",84) +" " ,86)  + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |VALOR FRETE...........: ",25)	+	PADR(Transform(nTotFre,    "@E 999,999,999.99"),15)	+ " |"
		cLin += PADR("  OBSERVAÇOES",86)  + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |DESPESAS..............: ",25)	+	PADR(Transform(nTotDesp,    "@E 999,999,999.99"),15)	+ " |"
		cLin += PADR(" 1. Os pagamentos referentes a esse pedido de compras somente serão feitos",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |DESCONTO..............: ",25)	+	PADR(Transform(nTotDes,    "@E 999,999,999.99"),15)	+ " |"
		cLin += PADR("    preferencialmente através de emissao de boletos bancários.",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |TOTAL GERAL...........: ",25)	+	PADR(Transform(nTotGer,    "@E 999,999,999.99"),15)+ " |"
		cLin += PADR(" 2. Nao será permitido o desconto de títulos com bancos, empresas de factoring",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := PADR(" |COND. PAGAMENTO.......: ",25)	+	PADR(cConPag,15)										+ " |"
		cLin += PADR("    e/ou repasse de direitos a favor de terceiros.",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		//cLin := PADR(" |",40) + " |"
		//cLin += PADR("    e/ou repasse de direitos a favor de terceiros.",86) + " |"
		//fWrite(nHdl,cLin+cEOL)
		
		cLin := " |" + REPLICATE(" ",38) + " |" + REPLICATE(" ",86) + " |"
		fWrite(nHdl,cLin+cEOL)
		
		nIdx := 0
		nQtd := LEN(ALLTRIM(cObs))
		
		While nQtd > 80
			cLin := " |" + REPLICATE(" ",38) + " |" 	+ SUBSTRING(ALLTRIM(cObs), nIdx, 87)  + " |"
			fWrite(nHdl,cLin+cEOL)
			nIdx := nIdx + 80
			nQtd := nQtd - 80
		EndDo()
		
		If nQtd <> 0
			cLin := " |" + REPLICATE(" ",38) + " |" 	+ SUBSTRING(ALLTRIM(cObs), nIdx, 87)  + " |"
			fWrite(nHdl,cLin+cEOL)
		EndIf
		
		cLin := " |" + REPLICATE("_",39) + "|" + REPLICATE("_",87) + "|"
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " "
		fWrite(nHdl,cLin+cEOL)
		
		cLin := " INFORMAÇÃO OBRIGATÓRIA: "
		
		fWrite(nHdl,cLin+cEOL)	
		
		fWrite(nHdl," "+cEOL)
			
		cLin := "	1 - Informar o número do pedido de compra no XML da NF-e na TAG ESPECÍFCA, bem como no campo de OBSERVAÇÃO do DANFE, "   
		fWrite(nHdl,cLin+cEOL)
		cLin := "	    caso não tenha esta informação, a nota fiscal poderá ser recusada."   
		fWrite(nHdl,cLin+cEOL)
		fWrite(nHdl," "+cEOL)
		
		cLin := "	2 - Informar o Armazém e a Portaria no campo de OBSERVAÇÃO do DANFE."
		fWrite(nHdl,cLin+cEOL)
		fWrite(nHdl," "+cEOL)
		
		cLin := "	3 - Discriminar a classificação fiscal do produto conforme tabela do IPI, caso não haja "
		fWrite(nHdl,cLin+cEOL)
		cLin := "	    campo específico na nota fiscal informar uma relação em anexo. "
		fWrite(nHdl,cLin+cEOL)
		fWrite(nHdl," "+cEOL)
		
		cLin := "	4 - Conferir se os dados cadastrais que constam no pedido estão de acordo com emissão da NF."
		fWrite(nHdl,cLin+cEOL)
		fWrite(nHdl," "+cEOL)
		
		cLin := "	5 - Empresa autorizada a emissão de Nota Fiscal Eletrônica deverá enviar o arquivo XML,"
		fWrite(nHdl,cLin+cEOL)
		
		If cEmpAnt == "01"
			cLin := "	    para o endereço eletrônico: nf-e.biancogres@biancogres.com.br "
		ElseIf cEmpAnt == "05"
			cLin := "	    para o endereço eletrônico: nf-e.incesa@incesa.ind.br "
		ElseIf cEmpAnt == "07"
			cLin := "       para o endereço eletrônico: nf-e.lmcomercio@biancogres.com.br "
		ElseIf cEmpAnt == "12"
			cLin := "       para o endereço eletrônico: nf-e.stgestao@biancogres.com.br "
		ElseIf cEmpAnt == "13"
			cLin := "       para o endereço eletrônico: nf-e.mundi@biancogres.com.br "
		Else
			cLin := "       para o endereço eletrônico: nf-e.biancogres@biancogres.com.br "
		EndIf 
		
		fWrite(nHdl,cLin+cEOL)
		fWrite(nHdl," "+cEOL)
		
		cLin := "	6 - Os pagamentos referentes a esse pedido de compras somente serão feitos através de emissão de boletos bancários registrados. "
		fWrite(nHdl,cLin+cEOL) 
		fWrite(nHdl," "+cEOL) 
		cLin := "	7 - Não será permitido o desconto de títulos com bancos, empresas de factoring e/ou repasse de direitos a favor de terceiros."
		fWrite(nHdl,cLin+cEOL)  
		fWrite(nHdl," "+cEOL)
		cLin := "	8 – As entregas devem ser realizadas na portaria indicada no pedido. "
		fWrite(nHdl,cLin+cEOL)  
		fWrite(nHdl," "+cEOL)
		
		If lServ		
			cLin := "	9 - As NFs de SERVIÇO só poderão ser emitidas e entregue em mãos, até o dia 24 de cada mês."
			fWrite(nHdl,cLin+cEOL)			
			fWrite(nHdl," "+cEOL)
			cLin := "	10 - Toda NF de SERVIÇO de fornecedor optante pelo simples, deverá ser entregue juntamente com a declaração assinada e carimbada."
			fWrite(nHdl,cLin+cEOL)
			fWrite(nHdl," "+cEOL)
		EndIf
		
		fClose(nHdl)
		
	EndIf

	(cQry)->(DbCloseArea())
	
Return(cArqTxt)


Method RetChave() Class TPedidoCompraEmail
Local cRet := ""

	If "KEY:" $ Upper(::oMensagem:cBody)
		
		cRet := SubStr(Self:oMensagem:cBody, At("KEY", ::oMensagem:cBody) + 4, 32)
		
	EndIf

Return(cRet)

Static Function fGetPort(_cProd,_cLocal)

	Local _cPort	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT TOP 1 ISNULL(ZCN_PORTAR,'') ZCN_PORTAR
		FROM %TABLE:ZCN% ZCN
		WHERE ZCN_FILIAL = %XFILIAL:ZCN%
			AND ZCN_COD = %Exp:_cProd%
			AND ZCN_LOCAL = %Exp:_cLocal%
			AND %NotDel%
	EndSql

	_cPort	:=	(_cAlias)->ZCN_PORTAR

	(_cAlias)->(DbCloseArea())

Return _cPort
