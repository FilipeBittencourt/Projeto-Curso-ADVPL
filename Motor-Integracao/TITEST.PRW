#Include 'TOTVS.CH'
#Include "TopConn.ch"

//U_TITEST
User Function TITEST() 
	
  Local cHtml := ""	   
  
  If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	   

  cHtml += ' <html> '
  cHtml += ' <body> '
  cHtml += ' <h1>Error motor de abastecimento CITERL: ' + SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME + '</h1><BR>' 
  cHtml += ' pedidocompra - POST METHOD<BR> ' 
  cHtml += ' {"Erros":[{"rejectedValue":"","defaultMessage":"Tabela SC7 17/09/20 11:55:50<br>Numero PC            - C7_NUM       := 455979<br>DT Emissao           - C7_EMISSAO   := 17/09/20<br>Fornecedor           - C7_FORNECE   := 000620<br>Loja                 - C7_LOJA      := 01<br>Cond. Pagto          - C7_COND      := 507<br>Filial Entr.         - C7_FILENT    := 01<br>Controle Ap.         - C7_CONAPRO   := Nil<br>ID CITEL             - C7_YIDCITE   := 1234567<br>--------------------------------------------------------------------------------<br>Tabela SC7 17/09/20 11:55:50<br>Erro no Item 323<br>--------------------------------------------------------------------------------<br>Produto              - C7_PRODUTO   := 78571 < -- Invalido<br>Quantidade           - C7_QUANT     := 3<br>Armazem              - C7_LOCAL     := 01<br>Prc Unitario         - C7_PRECO     := 15.1<br>Qtde da SC           - C7_QTDSOL    := 3<br>Dt. Entrega          - C7_DATPRF    := 30/09/20<br>Tip.Operacao         - C7_OPER      := 01<br>Tipo Compra          - C7_YTIPCMP   := OT<br>Controle Ap.         - C7_CONAPRO   := L<br>ID CITEL             - C7_YIDCITE   := 1234567<br>Rateio               - C7_RATEIO    := 2<br>Item                 - C7_ITEM      := 0323<br>--------------------------------------------------------------------------------<br>","field":""}],"Status":400} '
  cHtml += ' </body> ' 
  cHtml += ' </html> '

  //EnvEmail(cDestin,cAssunto,cMensagem,cAnexos,lUsaLogado)
  U_EnvEmail("filipe.bittencourt@facilesistemas.com.br"," Error motor de abastecimento CITERL: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

Return
