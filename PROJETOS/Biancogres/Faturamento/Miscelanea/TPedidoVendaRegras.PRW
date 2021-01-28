#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TPedidoVendaRegras
@author Fernando Soares Rocha
@since 22/10/2018
@version 1.0
@description Classe para regras de inclusao e replicacao de pedidos de venda - projeto consolidacao 
@type class
/*/

//DEFINE TITULO PARA MENSAGENS
#DEFINE TIT_MSG "Regras de Pedido de Venda"

//DEFINE QUAIS OS TIPOS DE PEDIDO CONSIDERADO AMOSTRA (campo C5_YSUBTP)
#DEFINE TP_AMOSTRA "A#M#F"

//DEFINE QUAIS OS TIPOS DE PRODUTO FAZEM VALIDACAO
#DEFINE TP_PRODREGRA "PA#PR"

//TIPOS DE PEDIDO QUE IGNORAM A VALIDACAO
#DEFINE TP_SEMREGRA "O"

//DEFINE QUAIS EMPRESAS SAO FABRICANTES
#DEFINE EMP_FABR "01#05#13"

//DEFINE QUAIS EMPRESAS SAO DISTRIBUIDORAS (LM)
#DEFINE EMP_DISTR "07"


Class TPedidoVendaRegras From LongClassName	

//propriedades do cabecalho do pedido
Data TipoPedido   //C5_YSUBTP
Data Pedido
Data ClienteLoja
Data Linha
Data MarcasPermitidas

//Cliente
Data oCliente

//Acols
Data aItems

//variaveis do processo
Data lAmostra
Data lEmpFabric

Data lValLinha //definir se esta executando do PE M410LIOK

//Retorno
Data lOk
Data cRegraItem
Data cRegraCod
Data cRegraTit
Data cRegraDesc

//Posicoes do aHeader
Data nP_Item
Data nP_Produto	
Data nP_Quantidade
Data nP_Lote

Data REG_001
Data REG_002
Data REG_003
Data REG_004
Data REG_005

Data REG_TIT_001
Data REG_DES_001
Data REG_TIT_002
Data REG_DES_002
Data REG_TIT_003
Data REG_DES_003
Data REG_TIT_004
Data REG_DES_004
Data REG_TIT_005
Data REG_DES_005

Method New() Constructor
Method LoadSC5Mem()
Method LoadSC5Bas()
Method SetVar()
Method Validar()
Method SetRegra(lOk, cCod, cTit, cDesc)
Method ShowRegra()
Method SetMarcas()

EndClass


Method New() Class TPedidoVendaRegras

	::TipoPedido		:= ""
	::Pedido			:= ""
	::ClienteLoja		:= ""
	::Linha				:= ""
	::MarcasPermitidas	:= ""  //listar marcas permitidas conforme a linha

	::oCliente		:= Nil

	::lAmostra 		:= .F.
	::lEmpFabric	:= .F.

	::lOk			:= .T.
	::cRegraItem	:= ""   
	::cRegraCod		:= "000"
	::cRegraTit		:= ""
	::cRegraDesc	:= ""

	::nP_Item			:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_ITEM"})
	::nP_Produto		:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	::nP_Quantidade		:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	::nP_Lote			:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_LOTECTL"})	

	::aItems			:= {}

	::lValLinha			:= .F.

	//PARA EXIBIR ALERTA DAS REGRAS                                                                                                                                                                                      

	::REG_001 := "001"  	//1.	Para pedidos tipo “A”-Amostra só permitir a digitação na empresa fabricante (Bianco ou Incesa)                                                                                              
	::REG_002 := "002"  	//2.	Para produtos do pacotes “9”-Outs Premium e “C”-Louças Mundialli, sempre exigir que o pedido seja na empresa LM (exceto pedidos tipo “A”-Amostra).                                          
	::REG_003 := "003"  	//3.	Clientes com campo tratamento especial  = “Sim”, obrigar o pedido ser pela LM (exceto pedidos tipo “A”-Amostra).                                                                            
	::REG_004 := "004"		//4.	Clientes com campo tratamento especial = “Não”, obrigar o pedido a ser pela empresa fabricante (Biancogres ou Incesa). Exceto produtos do pacote “9”-Outs. Premium e “C”-Louças Mundialli.  
	::REG_005 := "005"		//5.	Somente Permitir Marcas conforme linha do pedido.

	::REG_TIT_001 := "Pedido de AMOSTRA => Empresa Fabricante"                                                                                                                                                               
	::REG_DES_001 := "Somente permitida digitação na empresa FABRICANTE."                                                                                                                                                    

	::REG_TIT_002 := "Pacotes Outsourcing/Mundialli"                                                                                                                                                                         
	::REG_DES_002 := "Somente permitida digitação na empresa LM."                                                                                                                                                            

	::REG_TIT_003 := "Tratamento Especial - Sim"                                                                                                                                                                             
	::REG_DES_003 := "Somente permitida digitação na empresa LM."                                                                                                                                                            

	::REG_TIT_004 := "Tratamento Especial - Não"                                                                                                                                                                             
	::REG_DES_004 := "Somente permitida digitação na empresa FABRICANTE."+CRLF+"Exceção para pacote Sustentação com estoque disponível na Incesa."                                                                                                                                              

	::REG_TIT_005 := "Linha do Pedido"                                                                                                                                                                             
	::REG_DES_005:= "Esta MARCA de produto não é permitida para a LINHA selecionada."


Return()


Method LoadSC5Mem() Class TPedidoVendaRegras

	Local nX
	Local _oItem

	::TipoPedido 	:= M->C5_YSUBTP
	::Pedido		:= M->C5_NUM
	::ClienteLoja	:= M->C5_CLIENTE+M->C5_LOJACLI
	::Linha			:= M->C5_YLINHA

	::SetMarcas()

	::oCliente		:= TPedidoVendaClienteRegras():FromCodLin(::ClienteLoja, M->C5_YLINHA)

	For nX := 1 To Len(ACOLS)

		//ignorar linha deletada
		If ( ACOLS[nX][Len(AHEADER)+1] )
			loop
		EndIf

		_oItem := TPedidoVendaItemRegras():New()
		_oItem:FromACols(ACOLS[nX])

		//adiciona para validação linhas que pelo menos o produto esteja preenchido
		If ( !Empty(_oItem:oProduto:Codigo) )

			AAdd(::aItems, _oItem)

		EndIf

	Next nX

Return


Method LoadSC5Bas() Class TPedidoVendaRegras

Return


Method SetVar() Class TPedidoVendaRegras

	::lAmostra := ( !Empty(::TipoPedido) .And. AllTrim(::TipoPedido) $ TP_AMOSTRA )

	::lEmpFabric := ( AllTrim(CEMPANT) $ EMP_FABR )

Return


Method Validar() Class TPedidoVendaRegras

	Local nX
	Local lAtend := ( ALTERA .And. Type("CREPATU") <> "U" .And. EMPTY(CREPATU) )

	//MODO ATENDENTE - LIBERA QUALQUER COISA
	If lAtend
		::lOk:= .T.
		Return(::lOk)
	EndIf

	//EMPRESAS QUE NÃO VERIFICAM REGRAS
	If !(( AllTrim(CEMPANT) $ EMP_FABR ) .Or. ( AllTrim(CEMPANT) $ EMP_DISTR ))
		::lOk:= .T.
		Return(::lOk)
	EndIf

	//TIPOS LIBERADOS
	If ( !Empty(::TipoPedido) .And. AllTrim(::TipoPedido) $ TP_SEMREGRA )
		::lOk:= .T.
		Return(::lOk)
	EndIf

	//IGNORAR VALIDACAO PARA PRODUTOS DIFERENTE DE PA/PR
	If ( Len(::aItems) > 0 .And. ( N > 0 ) .And. !( ::aItems[N]:oProduto:Tipo $ TP_PRODREGRA ) )
		::lOk:= .T.
		Return(::lOk)
	EndIf

	::SetVar()

	//REGRAS DO CABECALHO

	//REGRA 001: Para pedidos tipo “A”-Amostra só permitir a digitação na empresa fabricante (Bianco ou Incesa)
	//Vinilico permitir digitar Amostra LM
	If ( ::lOk .And. ::lAmostra .And. !::lEmpFabric .And. !(AllTrim(::Linha) == "6"))

		::SetRegra(.F., ::REG_001) 

	EndIf

	//REGRAS DO CABECALHO - APOS DIGITACAO DO CLIENTE
	If (!Empty(::oCliente:Codigo))

		//REGRA 003: Clientes com campo tratamento especial  = “Sim”, obrigar o pedido ser pela LM (exceto pedidos tipo “A”-Amostra).
		If ( ::lOk .And. ::oCliente:lEspecial .And. ::lEmpFabric .And. !::lAmostra)

			::SetRegra(.F., ::REG_003) 

		EndIf

	EndIf

	//REGRAS DEPENDENTES DO ITEM
	For nX := 1 To Len(::aItems)

		//IGNORAR VALIDACAO PARA PRODUTOS DIFERENTE DE PA/PR
		If ( !( ::aItems[nX]:oProduto:Tipo $ TP_PRODREGRA ) )
			::lOk:= .T.
			loop
		EndIf

		//REGRA 002: Para produtos do pacotes “9”-Outs Premium e “C”-Louças Mundialli, sempre exigir que o pedido seja na empresa LM (exceto pedidos tipo “A”-Amostra).
		If ( ::lOk .And. !::lAmostra .And. ::lEmpFabric .And. ::aItems[nX]:oProduto:Pacote $ "9#C" )

			::SetRegra(.F., ::REG_002, nX)			

		EndIf

		//APOS DIGITACAO DO CLIENTE
		If (!Empty(::oCliente:Codigo))

			//REGRA 004: Clientes com campo tratamento especial = “Não”, obrigar o pedido a ser pela empresa fabricante (Biancogres ou Incesa). Exceto produtos do pacote “9”-Outs. Premium e “C”-Louças Mundialli.
			
		//	alert(cvaltochar(::lOk))
	//		alert(cvaltochar(::lValLinha))
	//		alert(cvaltochar(::lEmpFabric))
		//	alert(cvaltochar(::aItems[nX]:oProduto:Pacote))
			
			
			If ( 	::lOk .And.;
			::lValLinha .And.;
			!::lEmpFabric .And.;
			!::oCliente:lEspecial .And.;
			!(::aItems[nX]:oProduto:Pacote $ "9#C#J") .And.;
			!( ::aItems[nX]:oProduto:Pacote $ "4" .And. ::aItems[nX]:EmpEst == "05" ) .And.;
			!(AllTrim(::oCliente:Segmento) == 'R' .And. AllTrim(::oCliente:cUF) == 'ES' .And. ::aItems[nX]:oProduto:ClasseProd $ "2_3" ) )

				::SetRegra(.F., ::REG_004, nX) 

			EndIf
			
			/*If ( 	::lOk .And.;
			::lValLinha .And.;
			!::oCliente:lEspecial .And.;
			!::lEmpFabric .And.;
			!(::aItems[nX]:oProduto:Pacote $ "9#C#J") .And.;
			!( ::aItems[nX]:oProduto:Pacote $ "4" .And. ::aItems[nX]:EmpEst == "05" ) )

				::SetRegra(.F., ::REG_004, nX) 

			EndIf*/

			//REGRA 005: Produto X Linha
			If ( ::lOk .And. !( ::aItems[nX]:oProduto:Marca $ ::MarcasPermitidas ) )

				::SetRegra(.F., ::REG_005, nX) 

			EndIf

		EndIf

	Next nX

	If (!::lOk)
		::ShowRegra()
	EndIf

Return(::lOk)


Method SetRegra(lOk, cCod, nItem) Class TPedidoVendaRegras

	Default nItem := 0

	::lOk			:= lOk   
	::cRegraCod		:= cCod

	If ( nItem > 0 )
		::cRegraItem	:= StrZero(nItem,2)
	Else
		::cRegraItem	:= ""
	EndIf

	If ( cCod == ::REG_001 )

		::cRegraTit		:= ::REG_TIT_001
		::cRegraDesc	:= ::REG_DES_001

	ElseIf ( cCod == ::REG_002 )

		::cRegraTit		:= ::REG_TIT_002
		::cRegraDesc	:= ::REG_DES_002

	ElseIf ( cCod == ::REG_003 )

		::cRegraTit		:= ::REG_TIT_003
		::cRegraDesc	:= ::REG_DES_003

	ElseIf ( cCod == ::REG_004 )

		::cRegraTit		:= ::REG_TIT_004
		::cRegraDesc	:= ::REG_DES_004

	ElseIf ( cCod == ::REG_005 )

		::cRegraTit		:= ::REG_TIT_005
		::cRegraDesc	:= ::REG_DES_005

	EndIf

Return


Method ShowRegra() Class TPedidoVendaRegras

	U_FROPMSG(TIT_MSG, IIf(!Empty(::cRegraItem),"[ITEM "+::cRegraItem+"] ","") + ::cRegraDesc,,, "[REGRA: "+::cRegraCod+"] "+::cRegraTit)

Return


Method SetMarcas() Class TPedidoVendaRegras

	If (::Linha == "1")

		::MarcasPermitidas := "0101"

	ElseIf (::Linha == "2")

		::MarcasPermitidas := "0501"

	ElseIf (::Linha == "3")

		::MarcasPermitidas := "0599"

	ElseIf (::Linha == "4")

		::MarcasPermitidas := "1399"
		
	ElseIf (::Linha == "5")

		::MarcasPermitidas := "0199"
	
	ElseIf (::Linha == "6")

		::MarcasPermitidas := "1302"
				
	EndIf

Return