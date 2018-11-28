#INCLUDE 'TOTVS.CH'



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120BRW  ºAutor  ³Microsiga           º Data ³  09/22/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui botoes no aRotina do Pedido de compra                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MT120BRW()

	//Chamado #28215 - Kuhn
	AAdd( aRotina,{'Cad.CRU'		, "U_VIXA043"	,0,4,0,NIL} )
	AAdd( aRotina,{'Aprovar Ped.'	, "U_VIXA114"	,0,4,0,NIL} )
	AAdd( aRotina,{'Rota x PC'		, "U_XDataZZE"	,0,4,0,NIL} )
 	
Return()

User function XDataZZE()
	
	ZZE->(DbSetOrder(1))
	ZZ0->(DbSetOrder(1))
	
	If (ZZE->(DbSeek(xFilial("ZZE") + SC7->C7_NUM)))
		
		FWExecView(Upper("Cadastro PC x Rota/Trecho"),"VIEWDEF.VIXA257", 4,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Alterar
	
	ElseIf (ZZ0->(DbSeek(xFilial("ZZ0") + SC7->C7_FORNECE +  SC7->C7_LOJA)))
		
		U_VIX259CR(SC7->C7_NUM, C7_FORNECE, SC7->C7_LOJA)
		
		If (ZZE->(DbSeek(xFilial("ZZE") + SC7->C7_NUM)))
	
			FWExecView(Upper("Cadastro PC x Rota/Trecho"),"VIEWDEF.VIXA257", 4,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Alterar
	
		Else
	
			Aviso("ATENCAO", "Houve algum erro ao cadastrar a rota padrão. Favor entrar em contato com o setor de T.I.!", {"Ok"}, 3)
	
		EndIf
	
	Else
	
		Aviso("ATENCAO", "Não foi encontrado a rota no cadastro do Fornecedor, favor cadastra-la!"+CRLF+;
			"Obs.: Após cadastrar a rota padrão (Cad. Fornecedor), será necessário clicar neste botão novamente "+;
			"para que a rota seja vinculada ao pedido.", {"Ok"}, 3)
		
	EndIf
	
Return()