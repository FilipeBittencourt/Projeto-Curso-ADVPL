#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//Tipos de transmissão do pedido de vendas
#DEFINE cTransEDI 'EDI' 
#DEFINE cTransEmail 'E-mail'

/*
------------------------------------------------------------------------------------------------------------
Função		: VIXA114
Tipo		: Função de Usuário
Descrição	: Monta o workflow de pedido de compras
Uso			: Compras 
Parâmetros	: 
Retorno	: 
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/

User Function VIXA114()
	Local lLibPed  := GetNewPar('MV_YLIBCP',.F.) //Liberar o pedido no browser por problemas de cobertura
	Local aArea 	:= GetArea()
	Local lEnviou 	:= .F.
	Local cPedido	:= AllTrim(SC7->C7_NUM)
	Local lBlqDias	:= .T.
	Local cMsgBlq	:= 'Este pedido está bloqueado por causa da quantidade de dias de '+;
						 'estoque ou por ter sido gerado pela rotina de pedido por oportunidade.'+; 
						 'Favor entrar em contato com o seu gerente para liberar o pedido.'
						 
	If AnaliBloqueio(cPedido)
		
		lBlqDias := BloqDias()
		
		If !lLibPed .and. lBlqDias //.t. bloueio
			
			MsgInfo(cMsgBlq)

			Return .F.		
			
		EndIF
		
		//Se não tiver bloqueio de cobertura ou
		//Pode liberar pelo browser
		if !lLibPed .OR. !lBlqDias
			cMsgBlq := ''
		Endif
						
		If !U_VIX259PC(SC7->C7_NUM,,,cMsgBlq)
			/*
			 If (lBlqDias, 'Este pedido está bloqueado por causa da quantidade de dias de '+;
						 'estoque ou por ter sido gerado pela rotina de pedido por oportunidade.'+; 
						 'Favor entrar em contato com o seu gerente para liberar o pedido.')
			*/
			Return(.F.)
		
		EndIf
		
	Else
		If !MsgYesNo('Este pedido já está liberado, gostaria de transmitir novamente o pedido de compras?')
			Return
		EndIf
	EndIf
	
	If AllTrim(cPedido) == ''
		Return
	Else
		lEnviou := CriaTela(cPedido)
	EndIf

	RestArea(aArea)
	
Return lEnviou

/*
------------------------------------------------------------------------------------------------------------
Função		: CriaTela
Tipo		: Função estática
Descrição	: Cria uma interface para o usuário escolher qual o tipo de transmissão do pedido de compras
Parâmetros	: cExp1 : Número do pedido de compras
Retorno	: Booleano
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function CriaTela(cPedido)
	Local cTipo	:= 'EDI'
	Local oTipo	:= Nil
	Local lEnvio  := .F.

	DEFINE MSDIALOG oDlg TITLE "Envio do pedido de compras" FROM 0,0 TO 150,270 OF oMainWnd PIXEL Style DS_MODALFRAME
 		@ 010, 010  SAY "Enviar o pedido através de ?" 		PIXEL 
   		@ 025, 010 COMBOBOX oTipo  Var cTipo ITEMS {cTransEDI, cTransEmail}  SIZE 120,010 OF oDlg PIXEL
   		
   		@ 045, 010 BUTTON "Fechar" SIZE 50,15 ACTION oDlg:End() PIXEL OF oDlg
   		@ 045, 080 BUTTON "Enviar" SIZE 50,15 ACTION {||IIF(AnaliSaida(cPedido, cTipo, @lEnvio), oDlg:End(), NIL)} PIXEL OF oDlg
   	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return lEnvio

/*
------------------------------------------------------------------------------------------------------------
Função		: AnaliSaida
Tipo		: Função estática
Descrição	: Analisa a saída do pedido de compras
Parâmetros	: cExp1 : Número do pedido de compras
			  cExp2 : Tipo de transmissão do pedido
			  lExp3 : Parâmetro que retorno se o e-mai foi ou não enviado
Retorno	: Boolean
------------------------------------------------------------------------------------------------------------
Atualizações:
- 02/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AnaliSaida(cPedido, cTipo, lEnviou)
	Local cPerg 	:= ''
	Local lPedLib	:= .F.
	Local cEmail	:= ''
	Local lEmailCad := .T.
	
	lEnviou := .F.

	If cTipo == cTransEmail

		cEmail := AllTrim(POSICIONE('SA2',1, XFILIAL('SA2')+SC7->(C7_FORNECE+C7_LOJA), 'A2_EMAIL'))

		If AllTrim(cEmail) == ''
			MsgInfo('Favor cadastrar o e-mail do fornecedor antes de continuar.')
			Return .F.
		EndIf 

		If SC7->C7_CONAPRO == 'B'
			LjMsgRun('Aguarde','Liberando o pedido de compras',{||lPedLib := LiberaPedid(cPedido)})
		Else
			lPedLib := .T.
		EndIf
	
		If lPedLib
			LjMsgRun('Aguarde','Enviando o e-mail',{||lEnviou := EnviaEmail(cPedido, cTipo, @lEmailCad)})
		EndIf
	Else
		If SC7->C7_CONAPRO == 'B'
			cPerg := PADR("EDIUNI",LEN(SX1->X1_GRUPO))
			
			DbSelectArea("SX1")
			DbSetorder(1)
			If DbSeek(cPerg)
				RecLock("SX1",.F.)
					SX1->X1_CNT01 := cPedido 
					SX1->X1_CNT02 := cPedido
				MsUnlock()
			EndIf
		
			LjMsgRun('Aguarde','Liberando o pedido de compras',{||lPedLib := LiberaPedid(cPedido)})
		Else
			lPedLib := .T.
		Endif	
			
		If lPedLib
			LjMsgRun('Aguarde','Gerando a EDI',{||lEnviou := U_EDI(cPedido)})
			If !lEnviou
				Return .F.
			EndIf
			
			If lEnviou
				LjMsgRun('Aguarde','Enviando o e-mail',{||lEnviou := EnviaEmail(cPedido, cTipo, @lEmailCad)})
			EndIf
			
		EndIf
	EndIf
	
	If lPedLib .AND. !lEnviou .AND. lEmailCad
		MsgInfo('O e-mail não foi enviado, favor entrar em contato com o administrador para rever o cadastro de seu e-mail.')
	EndIf
	
Return lEnviou

/*
------------------------------------------------------------------------------------------------------------
Função		: LiberaPedid
Tipo		: Função estática
Descrição	: Libera o pedido de compras
Parâmetros	: cExp1 : Número do pedido de compra
Retorno	: Boolean
------------------------------------------------------------------------------------------------------------
Atualizações:
- 02/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function LiberaPedid(cPedido)
	
	Local nReg 		:= 0
	Local lContinua := .F.
	Local ca097User := RetCodUsr()
	
	//===============================================================================================
	//Variável necessário na liberação do pedido de compras, poís sem a declaração do sistema gera erro
	//===============================================================================================
	Private bFilSCRBrw	:= {|| Nil}
	Private cXFiltraSCR := ""
	Private aIndexSCR	:= {}
	
	DbSelectArea('SCR')
	DbSetOrder(2)
	
	If SCR->(DbSeek(xFilial('SCR')+'PC'+Padr(cPedido,TamSx3("CR_NUM")[1])+ca097User))
	
		lContinua 	:= .T.
		nReg 		:= SCR->(Recno())
		
		A097Libera('SCR',nReg)

		If Empty(SCR->CR_DATALIB)
			lContinua := .F.
		ElseIf SCR->CR_STATUS $ "01"
			lContinua := .F.
		EndIf
		
	Else
		MsgInfo('Não é possível liberar o pedido de compras, favor analisar seu limite de compras (máximo por pedido ou valor acumulado do período). ')
		
	EndIf

Return lContinua
 
/*
------------------------------------------------------------------------------------------------------------
Função		: EnviaEmail
Tipo		: Função estática
Descrição	: Envia o pedido de compras para o e-mail do fornecedor
Parâmetros	: cExp1 : Número do pedido de compras
			  cExp2 : Endereço de e-mail
Retorno	: Boolean
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function EnviaEmail(cPedido, cTipo, lEmailCad)
	Local cHtml 		:= ''
	Local cAssunto	:= ''
	Local lEnviou 	:= .F.
	Local cArqForm	:= SuperGetMv("MV_YARQFML",.F., "\WORKFLOW\COMPRAS\FormularioAgendamento.xls") 
	Local cArqPorta	:= SuperGetMv("MV_YARQPTR",.F., "\WORKFLOW\COMPRAS\Portaria_31_R_1.pdf") 
	Local cAnexos		:= ''
	Local cEmail		:= ''
	
	Default cTipo := ''
	
	DbSelectArea('SC7')
	DbSetOrder(1)

	If !SC7->(DbSeek(xFilial('SC7')+AllTrim(cPedido)))
		Return .F.
	EndIf
	
	cHtml := MontaLayout(cPedido, cTipo)
	DbSelectArea('SA2')
	DbSetOrder(1)
	
	//=======================================================================
	//O e-mail está sendo capturado novamente pois em alguns casos o sistema 
	//está disposicionando o fornecedor e com isso o e-mail estava vindo
	//de outro fornecedor
	//=======================================================================
	If cTipo == cTransEmail
		If SA2->(DbSeek(XFILIAL('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
			cEmail := SA2->A2_EMAIL
		EndIf
		
		If AllTrim(cEmail) == '' .Or. At('@',cEmail) == 0
			MsgInfo('Favor cadastrar o e-mail do fornecedor antes de continuar.')
			lEmailCad := .F.
			Return .F.
		EndIf
	EndIf
	
	cAssunto := 'Pedido de compras'
	
	If Alltrim(cArqForm) != ''
		cAnexos := cArqForm
	EndIf
	
	If Alltrim(cArqPorta) != ''
		If AllTrim(cArqPorta) != ''
			cAnexos += ','
		EndIf
		
		cAnexos += cArqPorta
	EndIf	

	lEnviou := U_EnvEmail(cEmail,cAssunto,cHtml,cAnexos, .T.)
	If lEnviou
		Aviso('Atenção', 'E-mail enviado com sucesso!',{"Fechar"})
	Else
		Aviso('Atenção', 'O e-mail não foi enviado, favor entrar em contato com a TI para verificar sua conta de e-mail.',{"Fechar"})
	EndIF
	
Return lEnviou

/*
------------------------------------------------------------------------------------------------------------
Função		: MontaLayout
Tipo		: Função estática
Descrição	: Monta o workflow de pedido de compras
Parâmetros	: cExp01 = Pedido de compras
Retorno	: Caracter - HTML do corpo do e-mail
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function MontaLayout(cPedido, cTipo)
	Local _cBody 		:= ''
	Local cEnt      	:= Chr(10)+chr(13)
	Local nItem		:= 0
	
	Local cValid		:= ''
	Local nPosRef  	:= 0
	Local cRefCols 	:= ''	
	Local nTotal		:= 0
	Local cCondPtgo	:= ''
	Local cEndCobran	:= ''
	Local cEndEntre	:= ''
	Local dDataEnt	:= nil
	Local cCnpj		:= ''
	Local cRazao		:= ''
	Local cEmailAge	:= SuperGetMv("MV_YEAGEND",.F.,"fpp01.ambra@ambralogistica.com.br")
	Local cTelagend	:= SuperGetMv("MV_YTELAGE",.F.,"(27) 3089-8334")
	Local cLogo		:= SuperGetMv("MV_YPCLOGO",.F.,"http://www.ambralogistica.com.br/logoatc.png")
	Local cObs			:= ''
	Local lExibeVlrs 	:= NIL // Manter a variavel como nil
	Local cProduto	:= ''
	Local cTrans		:= ''

	DbSelectArea('SA2')
	DbSetOrder(1)
	
	If SA2->(DbSeek(XFILIAL('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
		cCnpj 	:= SA2->A2_CGC 
		cRazao := SA2->A2_NOME
	EndIf
	
	//dDataEnt := DataEntrega(cPedido)
	dDataEnt := 'IMEDIATO'
	
	_cBody :=' </head>'+cEnt
	_cBody +=' <body>'+cEnt
	_cBody +=' 		<table style="text-align: left; width: 100px;" border="0" cellpadding="0" cellspacing="0">'+cEnt
	_cBody +='     		<tbody>'+cEnt
	_cBody +='       		<tr>'+cEnt
	_cBody +='         			<td style="vertical-align: top;">'+cEnt
	_cBody +='        			</td>'+cEnt
	_cBody +='       		</tr>'+cEnt
	_cBody +='    		</tbody>'+cEnt
	_cBody +='   	</table>'+cEnt	
	//_cBody +=' <img src="http://s14.postimg.org/hir66g44h/LOGOMARCA.jpg" alt="Big Boat">'+cEnt
	If AllTrim(cLogo) <> ''
		_cBody +=' <img src="'+cLogo+'" alt="Big Boat">'+cEnt
	EndIf
	_cBody +=" <p>Prezado fornecedor ("+cRazao+"),"
	//_cBody +=" <p>Segue o pedido de compras ("+SC7->C7_NUM+"), para ser entregue na data ("+DTOC( dDataEnt )+"), podendo antecipar de acordo com a disponibilidade logística."
	_cBody +=" <p>Segue o pedido de compras ("+SC7->C7_NUM+"), para ser entregue de imediato."
	_cBody +=" <p>CNPJ a faturar: "+Transform( SM0->M0_CGC, '@R 99.999.999/9999-99')
	_cBody +=" <p>Abaixo orientações para serem seguidas:"
	_cBody +=" <p>- ATENÇÃO Preencher o formulário para agendamento conforme anexo."
	_cBody +=" <p>- Divergência de quantidade e preço, favor informar antes do faturamento, caso contrário a mercadoria será devolvida com desconto no próprio boleto referido;"
	_cBody +=" <p>- O faturamento deve ser feito no CNPJ ("+Transform( cCnpj, IIF(Len(AllTrim(cCnpj)) == 11, '@R 999.999.999-99', '@R 99.999.999/9999-99'))+") "+;
				"que esta cadastrado em nosso sistema."
	_cBody +=" <p>- Não fazer o pagamento da ST conforme termo do acordo anexo"

	_cBody +=" <p>- Para agendamento, entrar em contato através do e-mail "+cEmailAge+" ou pelo telefone "+cTelagend
	_cBody +=" <p>- Informar após faturamento as pendências do pedido via email."
	_cBody +=" <p>- Enviar o arquivo XML pelo e-mail nfe@grupouniaosa.com.br"
	_cBody +=" <p>Por determinação do diretor financeiro do grupo não podemos pagar duplicatas de fornecedores, no período do dia 8 ao dia 11 de cada mês."
	_cBody +=" <p>Favor confirmar o recebimento do email."
	_cBody +=" <p>Qualquer duvida, estaremos a disposição."
	_cBody +=" <p>Atenciosamente,"	
	_cBody +=" <p>&nbsp;</p>"+cEnt

	_cBody +=" <p>Segue pedido de compras:</p>"+cEnt
	_cBody +=' <font size="-1"><br>'+cEnt
	_cBody +='   </font>'+cEnt
	_cBody +='   <table style="text-align: left; width: 964px; height: 60px;" border="1" bordercolor="Black" cellpadding="0" cellspacing="0">'+cEnt
	_cBody +='     <tbody>'+cEnt

   
   MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})

	//Já está posicionado o pedido
	nItem := 0
	SC7->(DbSeek(xFilial('SC7')+cPedido))
	While !SC7->(Eof()) .AND. SC7->C7_NUM == cPedido
	
		//Caso o item esteja residuado, não envia para o fornecedor
		If SC7->C7_RESIDUO == 'S' 
			SC7->(DbSkip()) 
			Loop
		EndIf
		
		cProduto	:= SC7->C7_PRODUTO
		nTotal 	+= SC7->C7_TOTAL
		
		cEndCobran	:= SM0->(AllTrim(M0_ENDCOB)+', '+AllTrim(M0_CIDCOB)+'-'+AllTrim(M0_ESTCOB)+' - '+AllTrim(M0_CEPCOB))
		cEndEntre	:= SM0->(AllTrim(M0_ENDENT)+', '+AllTrim(M0_CIDENT)+'-'+AllTrim(M0_ESTENT)+' - '+AllTrim(M0_CEPENT))
		
		nItem ++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.           
				MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
			EndIf
			dbSkip()
		EndDo
		MaFisEndLoad(nItem,2)
			
		nTotMerc	:= MaFisRet(,"NF_TOTAL")
	   	nTotIpi	:= MaFisRet(,'NF_VALIPI')
		nTotIcms	:= MaFisRet(,'NF_VALICM')
		nTotDesp	:= MaFisRet(,'NF_DESPESA')
		nTotFrete	:= MaFisRet(,'NF_FRETE')
		nTotSegur	:= MaFisRet(,'NF_SEGURO')
		nTotalNF	:= MaFisRet(,'NF_TOTAL')
		cTES		:= MaFisRet(nItem,'IT_TES')
		
		If lExibeVlrs == nil
			lExibeVlrs := ImprVlrs(cProduto, SC7->C7_FORNECE, SC7->C7_LOJA, cTES)
			_cBody += HtmlCab(lExibeVlrs)	
		EndIf
		   
		_cBody += HtmlItens(lExibeVlrs, dDataEnt)

		SC7->(DbSkip()) 
	EndDo
	MaFisEnd()
	
	//Reposiciona por causa no While anterior
	SC7->(DbSeek(xFilial('SC7')+cPedido))
	
	cTrans := SC7->C7_YTRANSP
	If AllTrim(cTrans) != ''
		cTrans := Posicione('SA4', 1, xFilial('SA4')+cTrans, 'A4_NOME')
	EndIf 
	
	DbSelectArea('SE4')
	DbSetOrder(1)
	If SE4->(DbSeek(xFilial('SE4')+SC7->C7_COND))
		cCondPtgo := SE4->E4_DESCRI
	EndIf
	
	_cBody +='		</tbody>'+cEnt
	_cBody +='</table>'+cEnt
	_cBody +='<table style="text-align: left; width: 964px; height: 60px;" border="1" bordercolor="Black" cellpadding="0" cellspacing="0">'+cEnt

	_cBody +='     <tbody>'+cEnt
	_cBody +='       <tr>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 200px; text-align: center; background-color: rgb(217, 230, 236);">Local de Entrega :<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 764px; text-align: center;">'+cEndEntre+' <br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='       </tr>'+cEnt	
	_cBody +='       <tr>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 200px; text-align: center; background-color: rgb(217, 230, 236);">Local de Cobranca:<br>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 764px; text-align: center;">'+cEndCobran+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='       </tr>'+cEnt
	_cBody +='		</table>'+cEnt
	_cBody +='		<table style="text-align: left; width: 964px; height: 60px;" border="1" bordercolor="Black" cellpadding="0" cellspacing="0">'+cEnt
	_cBody +='       <tr>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 101px; text-align: center; background-color: rgb(217, 230, 236);">Condicao de Pagto:'+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 101px; text-align: center; background-color: rgb(217, 230, 236);">Data de Emissao'+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 050px; text-align: center; background-color: rgb(217, 230, 236);">Total das mercadorias:<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	
	If lExibeVlrs
		_cBody +='         	<td style="vertical-align: top; width: 051px; text-align: center;">'+Transform(nTotal, '@E 999,999,999.99')+'<br>'+cEnt
	Else
		_cBody +='         	<td style="vertical-align: top; width: 051px; text-align: center;">-<br>'+cEnt
	EndIf
	
	_cBody +='       </tr>'+cEnt
	_cBody +='       <tr>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 101px; text-align: center;"> '+cCondPtgo+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 101px; text-align: center;">'+DTOC(SC7->C7_EMISSAO)+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	
	_cBody +='         	<td style="vertical-align: top; width: 050px; text-align: center; background-color: rgb(217, 230, 236);">Total com Impostos:<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	
	If lExibeVlrs
		_cBody +='         	<td style="vertical-align: top; width: 051px; text-align: center;">'+Transform(nTotalNF, '@E 999,999,999.99')+'<br>'+cEnt
	Else
		_cBody +='         	<td style="vertical-align: top; width: 051px; text-align: center;">-<br>'+cEnt
	EndIf
	
	_cBody +='        	</td>'+cEnt
	_cBody +='       </tr>'+cEnt
	
	_cBody +='		</table>'+cEnt
	_cBody +='		<table style="text-align: left; width: 964px; height: 60px;" border="1" bordercolor="Black" cellpadding="0" cellspacing="0">'+cEnt
	If lExibeVlrs	
		_cBody +='		<tr>'+cEnt
		_cBody +='			<td colspan="1" rowspan = "2" style="vertical-align: top; width: 50px; text-align: center;background-color: rgb(217, 230, 236);">Reajuste<br>'+cEnt
		_cBody +='			</td>'+cEnt
		
		cObs := ''
		dbSelectArea("SM4")
		If dbSeek(xFilial("SM4")+SC7->C7_REAJUST)
			cObs := SM4->M4_DESCR
		EndIf
		dbSelectArea("SC7")		
		_cBody +='			</td><td colspan="1" rowspan = "2" style="vertical-align: top; width: 150px; text-align: center;">'+cObs+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">IPI<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;">'+Transform(nTotIpi, '@E 999,999,999.99')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">ICMS<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;">'+Transform(nTotIcms, '@E 999,999,999.99')+'<br>'	+cEnt
		_cBody +='		</tr>'+cEnt
		_cBody +='		<tr>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">Frete<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;">'+Transform(nTotFrete, '@E 999,999,999.99')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">Despesas<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;">'+Transform(nTotDesp, '@E 999,999,999.99')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
	
		_cBody +='		</tr>'+cEnt
		_cBody +='		<tr>'+cEnt
		_cBody +='			<td colspan="2" rowspan = "1" style="vertical-align: top; width: 50px; text-align: center;background-color: rgb(217, 230, 236);">Observações<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">Grupo<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;"><br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 40px; text-align: center;background-color: rgb(217, 230, 236);">Seguro<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 80px; text-align: center;">'+Transform(nTotSegur, '@E 999,999,999.99')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='		</tr>'+cEnt
		_cBody +='		<tr>'+cEnt
		_cBody +='			<td colspan="2" rowspan = "3" style="vertical-align: top; width: 150px; text-align: center;"><br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="2" style="vertical-align: top; width: 50px; text-align: center;background-color: rgb(217, 230, 236);">Total Geral<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='			<td colspan="2" style="vertical-align: top; width: 70px; text-align: center;">'+Transform(nTotalNF, '@E 999,999,999.99')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt
		_cBody +='		</tr>'+cEnt	
	EndIf
			
	_cBody +='		<tr>'+cEnt
	If lExibeVlrs	
		_cBody +='			<td colspan="4" style="vertical-align: top; width: 50px; text-align: center;background-color: rgb(217, 230, 236);">Observação do Frete<br>'+cEnt
		_cBody +='			</td>'+cEnt	
		_cBody +='		</tr>'+cEnt
		_cBody +='		<tr>'+cEnt
		_cBody +='			<td colspan="4" rowspan = "1" style="vertical-align: top; width: 50px; text-align: center;">'+;
									IIF(SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))+;
									IIF(AllTrim(cTrans) !='', ' - Transportadora: '+cTrans, '')+'<br>'+cEnt
		_cBody +='			</td>'+cEnt	
	
	Else
		_cBody +='			<td colspan="1" style="vertical-align: top; width: 50px; text-align: center;background-color: rgb(217, 230, 236);">Observação do Frete<br>'+cEnt
		_cBody +='			<td colspan="5" rowspan = "1" style="vertical-align: top; width: 50px; text-align: center;">'+;
					IIF(SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))+;
					IIF(AllTrim(cTrans) !='', ' - Transportadora: '+cTrans, '')+'<br>'+cEnt
	EndIf
	
	_cBody +='		</tr>'+cEnt
	
	_cBody +='		<tr>'+cEnt
	_cBody +='			<td colspan="6" rowspan = "1" style="vertical-align: top; width: 50px; text-align: center;">'+cEnt
	_cBody +='				 NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras. <br>'+cEnt
	_cBody +='			</td>'+cEnt	
	_cBody +='		</tr>'+cEnt
	_cBody +='		</table>'+cEnt    
	_cBody +='     </tbody>'+cEnt
	_cBody +='  </table>'+cEnt	
	_cBody +=' </body>'+cEnt
	_cBody +=' </html>'+cEnt
	
Return _cBody

/*
------------------------------------------------------------------------------------------------------------
Função		: DataEntrega
Tipo		: Função estática
Descrição	: Extrai a maior data de entrega do pedido
Parâmetros	: cExp01 = Pedido de compras
Retorno	: Date
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function DataEntrega(cPedido)
	Local aArea 	:= GetArea()
	Local cAlias := GetNextAlias()
	Local dData  := Nil
	
	BeginSql Alias cAlias
		SELECT Max(C7_DATPRF) C7_DATPRF 
		FROM %Table:SC7% SC7
		WHERE C7_FILIAL = %xFilial:SC7%
			AND SC7.%NotDel%
			AND SC7.C7_NUM = %Exp:cPedido%
	EndSql
	
	dData := STOD((cAlias)->C7_DATPRF)
	
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return dData

/*
------------------------------------------------------------------------------------------------------------
Função		: ImprVlrs
Tipo		: Função de Usuário
Descrição	: Analisa se será impresso os valores do pedido de venda
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 13/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function ImprVlrs(cProduto, cFornece, cLoja, cTES)
	Local lRet 	:= .T.
	Local aArea 	:= GetArea()
	
	DbSelectArea('SA2')
	DbSetOrder(1)
	If SA2->(DbSeek(xFilial('SA2')+cFornece+cLoja))
		If SA2->A2_B2B == "1" 
			If AllTrim(cTES) == ''
				lRet := .F.
			Else
				If Posicione("SF4",1,xFilial("SF4")+cTES,"F4_UPRC") == "S"
					DbSelectArea("SB1")                            			
					DbSetOrder(1)
					If DbSeek(xFilial("SB1")+cProduto)
						lRet := .F.
			   		EndIf	
			   	Endif
			EndIf
		Endif
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*
------------------------------------------------------------------------------------------------------------
Função		: ImprVlrs
Tipo		: Função de Usuário
Descrição	: Analisa se será impresso os valores do pedido de venda
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function HtmlCab(lExibeVlr)
	Local _cBody 	:= ''
	Local cEnt		:= Chr(10)+chr(13)
	
	Default lExibeVlr := .F.
	
	If lExibeVlr
		_cBody +='       <tr>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 025px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Item<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 040px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Produto<br>'+cEnt
		_cBody +=' 			</td>'+cEnt  
		_cBody +='         	<td style="vertical-align: top; width: 150px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Descrição<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 025px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">UM<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Quant.<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">V. Unit<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">V. IPI<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">V. Total<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">D. Entrega<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='       </tr>'+cEnt
	Else		
		_cBody +='       <tr>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 025px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Item<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 040px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Produto<br>'+cEnt
		_cBody +=' 			</td>'+cEnt  
		_cBody +='         	<td style="vertical-align: top; width: 200px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Descrição<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 025px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">UM<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">Quant.<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='         	<td style="vertical-align: top; width: 056px; text-align: center; background-color: rgb(217, 230, 236); font-weight: bold; color: black;">D. Entrega<br>'+cEnt
		_cBody +='         	</td>'+cEnt
		_cBody +='       </tr>'+cEnt
	
	EndIf
Return _cBody

/*
------------------------------------------------------------------------------------------------------------
Função		: ImprVlrs
Tipo		: Função de Usuário
Descrição	: Analisa se será impresso os valores do pedido de venda
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function HtmlItens(lExibeVlr, dDataEnt)
	Local cEnt      	:= Chr(10)+chr(13)
	Local _cBody 		:= ''
	Local cItem		:= SC7->C7_ITEM
	Local cProduto	:= SC7->C7_PRODUTO
	Local cDescProd	:= SC7->C7_DESCRI
	Local cUMedida	:= SC7->C7_UM
	Local nQuant		:= SC7->C7_QUANT
	Local nVUnit		:= SC7->C7_PRECO
	Local nIPI			:= SC7->C7_IPI
	Local nSubTot		:= SC7->C7_TOTAL
	
	Default lExibeVlr := .T.
	
	_cBody +='       <tr>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 25px; text-align: center;">'+cItem+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 40px; text-align: center;">'+cProduto+'<br>'+cEnt
	_cBody +='         	</td>'+cEnt
	
	If lExibeVlr
		_cBody +='         	<td style="vertical-align: top; width: 150px; text-align: center;">'+cDescProd+'<br>'+cEnt
	Else
		_cBody +='         	<td style="vertical-align: top; width: 200px; text-align: center;">'+cDescProd+'<br>'+cEnt
	EndIf
	
	_cBody +='        	</td>'+cEnt
	_cBody +='         	<td style="vertical-align: top; width: 25px; text-align: center;">'+cUMedida+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	_cBody +='        	<td style="vertical-align: top; width: 56px; text-align: center;">'+Transform( nQuant, '@E 999,999.99' )+'<br>'+cEnt
	_cBody +='        	</td>'+cEnt
	
	If lExibeVlr
		_cBody +='        	<td style="vertical-align: top; width: 56px; text-align: center;">'+Transform( nVUnit, '@E 999,999.99' )+'<br>'+cEnt
		_cBody +='        	</td>'+cEnt
		_cBody +='        	<td style="vertical-align: top; width: 56px; text-align: center;">'+Transform( nIPI, '@E 999,999.99' )+'<br>'+cEnt
		_cBody +='        	</td>'+cEnt
		_cBody +='        	<td style="vertical-align: top; width: 56px; text-align: center;">'+Transform( nSubTot, '@E 999,999.99' )+'<br>'+cEnt
		_cBody +='        	</td>'+cEnt
	EndIf
	
	_cBody +='        	<td style="vertical-align: top; width: 56px; text-align: center;">IMEDIATO<br>'+cEnt
	_cBody +='         	</td>'+cEnt
	_cBody +='      </tr>'+cEnt
	
Return _cBody

/*
------------------------------------------------------------------------------------------------------------
Função		: BloqDias
Tipo		: Função de estática
Descrição	: Analise se o pedido possui bloqueio por quantidade de dias em estoque
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 04/04/2016 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function BloqDias()
	Local _aArea		:= GetArea()
	Local _lRet 		:= .T. //Variavel para não permitir seguir com o processo

	Local _cProduto	:= ""   
	Local _cLocal		:= ""
	Local _cItem		:= ""
	Local _cPedido	:= ""
	Local _nQtdReq	:= 0
	local _nQtdLib	:= 0
	Local _cTipoCmp	:= ''
	
	Local _nEstAtu	:= 0	//Estoque atual para o produto posicionado
	Local _nDiasEst	:= 0	//Dias Estoque
	Local _nMedPon	:= 0	//Média Ponderada
	
	Local cAlias 		:= GetNextAlias()
	Local _cPedido	:= SC7->C7_NUM
	Local aColsEx := {}
	Local _nLimDias	:= GetNewPar("MV_YLIMDIA",120)
	Local _nSldPed	:= 0	//Saldo de pedidos
	
	BeginSQL Alias cAlias
		SELECT	
			C7_ITEM, C7_QUANT, C7_PRODUTO, C7_LOCAL, C7_DESCRI, C7_YQTDLIB
			, C7_OBS, C7_YTIPCMP
		FROM 
			%table:SC7% SC7
		WHERE	
			SC7.%NotDel%
			AND SC7.C7_FILIAL = %xFilial:SC7%
			AND SC7.C7_NUM = %Exp:_cPedido%
	EndSql
	
	While !(cAlias)->(Eof())
		_cItem		:= (cAlias)->C7_ITEM
		_nQtdReq	:= (cAlias)->C7_QUANT
		_cProduto	:= (cAlias)->C7_PRODUTO
		_cLocal	:= (cAlias)->C7_LOCAL
		_cTipoCmp	:= (cAlias)->C7_YTIPCMP
		_nQtdLib	:= (cAlias)->C7_YQTDLIB
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+_cProduto))
		
		If (_nQtdReq > _nQtdLib) 
			_nMedPon 	:= StaticCall(MT120OK, MedPondG, _cProduto)
			_nEstAtu	:= StaticCall(MT120OK, EstAtuCruG, _cProduto)
			_nSldPed	:= SaldoPed(_cProduto)
			_nDiasEst	:= ROUND(( (_nEstAtu + _nQtdReq + _nSldPed)  /_nMedPon) * 30, 0) 	
						
			//Dias em estoque maior que 120 dias bloqueia
			//Toda compra por oportunidade deverá ser analisada pelo gerente de compras independente da quandidade de dias
			If _nDiasEst > _nLimDias .Or. _cTipoCmp == 'CO'// CO = Compra por oportunidade //.and. (_nQtdReq > _nQtdLib)
		        Aadd(aColsEx, {	_cPedido, _cItem, _cProduto}) 	
	        EndIf
		EndIf
	
		(cAlias)->(DbSkip())
	EndDo

	_lRet := Len(aColsEx) > 0
			
	RestArea(_aArea)
Return _lRet

/*
------------------------------------------------------------------------------------------------------------
Função		: SaldoPed
Tipo		: Função de estática
Descrição	: Calcula o saldo não classificado de um produto 
Parâmetros	:
Retorno	:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 04/04/2016 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function SaldoPed(_cProduto)
	Local aArea 		:= GetArea()
	Local cProduto 	:= SC7->C7_PRODUTO
	Local aSaldo		:= {}
	Local nSaldo		:= 0
	
	Default _cProduto := ''
	
	If ! Empty(_cProduto)
		cProduto := _cProduto
	EndIf

	aSaldo := StaticCall(VIXA141, EstPendente, cProduto, SC7->C7_NUM)//IIF(Inclui, '', SC7->C7_NUM))
	
	nSaldo 	:= 0
	If Len(aSaldo) > 0 .and. Len(aSaldo)>= 1 .and. Len(aSaldo[1]) >= 2 
		nSaldo := aSaldo[1, 2]
	EndIf
	
	RestArea(aArea)

Return (nSaldo)

/*
------------------------------------------------------------------------------------------------------------
Função		: AnaliBloqueio
Tipo		: Função de estática
Descrição	: Analisa se o pedido possui algum item bloqueado 
Parâmetros	: cExp1 : Número do pedido de compras
Retorno	: Lógico
------------------------------------------------------------------------------------------------------------
Atualizações:
- 13/05/2016 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AnaliBloqueio(cNum)
	Local cAliasBlo := GetNextAlias()
	
	BeginSql Alias cAliasBlo
		SELECT 
			C7_NUM
		FROM 
			%Table:SC7% SC7
		WHERE 
			C7_FILIAL = %xFilial:SC7%
			AND SC7.%NotDel%
			AND C7_NUM = %Exp:cNum%  
			AND C7_CONAPRO = 'B'
	EndSql
	
	lRet := !(cAliasBlo)->(Eof())
	
	(cAliasBlo)->(DbCloseArea())
Return lRet