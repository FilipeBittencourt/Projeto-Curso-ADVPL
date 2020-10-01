#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method CreatePCompra(oJson)
    Method CreatePVenda(oJson)
    Method BaixaTotalPC(oJson)
    Method BaixaParcialPC(oJson)
    
    Method EnviaError(oJson)
    

Method _BaixaParcialPC(oJson)


ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoDAO
    ::oJSon := JsonObject():New() 
Return ::self


/******************************************************************************************************************/
/*                                          METDODOS PARA PEDIDOS DE COMPRA                                       */
/******************************************************************************************************************/

Method CreatePCompra(oJSPC) Class TIntegracaoMotorAbastecimentoDAO
	
    Local oJSRet    := JsonObject():New() 
	Local aCab      := {}
	Local aItem     := {}		
    Local aIClone   := {}
	Local cNumPC    := ""	 
	Local nI        := 1  
    Local nW        := 1    
    
    Local lError    := .F.    
    Local aError    := {}
    Local cError    := ""
    Local oError    := ErrorBlock({|e| cError := e:Description}) 
  

    Begin Transaction       
        
       cNumPC := GetNumSC7()  
        For nI := 1 To  Len(oJSPC["pedidoCompra"]["itens"])  
            Z42->(RecLock('Z42', .T.))
                Z42->Z42_FILIAL   :=  FWxFilial("SC7")  
                Z42->Z42_NUM      :=  cNumPC                                    
                Z42->Z42_EMISSA   :=  oJSPC["pedidoCompra"]["cab"]["C7_EMISSAO"]    
                Z42->Z42_FORNEC   :=  oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]    
                Z42->Z42_LOJA     :=  oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]       
                Z42->Z42_COND     :=  oJSPC["pedidoCompra"]["cab"]["C7_COND"]       
                Z42->Z42_FILENT   :=  oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]                        
                Z42->Z42_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]

                Z42->Z42_ITEM     :=  StrZero(nI, TamSX3('C7_ITEM')[01])                  
                Z42->Z42_PRODUT   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"] 
                Z42->Z42_QUANT    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]      
                Z42->Z42_LOCAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]      	
                Z42->Z42_PRECO    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]                  
                Z42->Z42_TOTAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"] * oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]                                  
                Z42->Z42_DATPRF   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]                             
                Z42->Z42_YTIPCM   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_YTIPCMP"]                                
                Z42->Z42_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]
                Z42->Z42_SYCSC7   :=  "N" // INICIA COMO NÃO SINCRONIZADO, JOB
                Z42->Z42_SYCELE   :=  "N" // INICIA COMO RESIDUO NÃO ELIMNADO,  JOB
                Z42->Z42_JOBALT   :=  "N" // CONTROLER DE QTD DE JOB DE ALTERACAO
                Z42->Z42_QTDNOV   :=  0   // CASO HAJA ALTERAÇÃO DA QUANTIDADE
                
            Z42->(MsUnlock())   
        Next nI

        ErrorBlock(oError) 

        If Empty(cError)          
         
            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )
            oJSRet["Status"]           := 200
            oJSRet["numeroDocumento"]  := cNumPC 

        Else             

            If !Empty(MostraErro("/dirdoc", "error.log")) 
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
                ConOut(PadC("Automatic routine ended with error", 80))
            EndIf
            ConOut("Error: "+ cError)
            AADD(aError,   JsonObject():New())            
            aError[nw]["field"]          := ""
            aError[nw]["rejectedValue"]  := ""
            aError[nw]["defaultMessage"] := EncodeUtf8(cError)	                           
            lError := .T.   
            nW++         

            ::EnviaError(oJSPC, cError, "POST - Pedido de Compra na tabela Z42")

        EndIf  

        If lError
            oJSRet           := JsonObject():New()
            oJSRet["Status"] := 400
            oJSRet["Erros"]  := aError       
        Else
            ConOut("FIM RECLONK Z42")       
        EndIf	

    End Transaction
       
    FreeObj(oJSPC)
 

Return oJSRet
 
METHOD BaixaTotalPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local cCodigoDe  := oJson["C7_NUM"] 
    Local oJSRet     := JsonObject():New()
    Local nI         := 0  
    Local lError     := .F.    
    Local aError     := {}
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})    

    Z42->(DbSetOrder(1)) //Z42_FILIAL, Z42_NUM, Z42_ITEM, R_E_C_N_O_, D_E_L_E_T_
    
    If Z42->(dbSeek(FWxFilial("Z42")+AllTrim(cCodigoDe))) 

        Begin Transaction           

            While Z42->(!Eof()) .AND. FWxFilial("Z42")+AllTrim(cCodigoDe) == Z42->Z42_FILIAL+AllTrim(Z42->Z42_NUM)

                if   Z42->Z42_SYCELE != 'S' .AND. Z42->Z42_SYCSC7 == 'S'   
                
                    Z42->(RecLock('Z42', .F.))

                        Z42->Z42_SYCELE   :=  "T" 
                    
                    Z42->(MsUnlock())
                
                Else
                    
                    nI++
                    lError     := .T.
                    AADD(aError,   JsonObject():New())
                    aError[nI]["field"]          := "item["+cValToChar(nI)+"].produto"
                    aError[nI]["rejectedValue"]  := AllTrim(Z42->Z42_PRODUT)
                    aError[nI]["defaultMessage"] := EncodeUtf8("O código do produto informado não foi encontrado ou ainda não foi sincronizado pelo ERP.")      
                   

                EndIf

                Z42->(DbSkip())

            EndDo    

        End Transaction        

        ErrorBlock(oError) 

        If !Empty(cError)
            nI++
            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[nI]["field"]          := "numeroPedidoERP"
            aError[nI]["rejectedValue"]  := AllTrim(oJson["C7_NUM"])
            aError[nI]["defaultMessage"] := EncodeUtf8(cError)          

        EndIf

    Else

        nI++
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := AllTrim(oJson["C7_NUM"])
        aError[nI]["defaultMessage"] := EncodeUtf8("O pedido não foi encontrado.")

    EndIf  

    If lError

        oJSRet["Status"] := 400
        oJSRet["errors"] := aError

    Else

        oJSRet["Status"] := 200        
        oJSRet["numeroPedidoERP"] := AllTrim(oJson["C7_NUM"])

    EndIf  

    FreeObj(oJson)

Return oJSRet



METHOD BaixaParcialPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local cCodigoDe  := oJson["C7_NUM"] 
    Local oJSRet     := JsonObject():New()
    Local nI         := 1  
    Local lError     := .F.    
    Local aError     := {}
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})    

    Z42->(DbSetOrder(1)) //Z42_FILIAL, Z42_NUM, Z42_ITEM, R_E_C_N_O_, D_E_L_E_T_
    
    If Z42->(dbSeek(FWxFilial("Z42")+AllTrim(cCodigoDe))) 

        Begin Transaction           

            While Z42->(!Eof()) .AND. FWxFilial("Z42")+AllTrim(cCodigoDe) == Z42->Z42_FILIAL+AllTrim(Z42->Z42_NUM)

                For nI := 1 To Len(oJson["itens"])
                    
                    If oJson["itens"][nI]["produto"] == Z42->Z42_PRODUT .AND. Z42->Z42_SYCELE != 'S' .AND.  Z42->Z42_SYCSC7 == 'S'                           

                        If oJson["itens"][nI]["quantidade"] == 0
                            
                            Z42->(RecLock('Z42', .F.))

                                Z42->Z42_SYCELE   :=  "P" // Eliminação DE 100%  de apenas um ÚNICO item do PC
                                Z42->Z42_QTDNOV   :=  oJson["itens"][nI]["quantidade"] // Nova quantidade
                            
                            Z42->(MsUnlock()) 

                        Else

                            Z42->(RecLock('Z42', .F.))
                                
                                Z42->Z42_JOBALT   :=  "S"
                                Z42->Z42_SYCELE   :=  "A" // Alteração de quantidade de apenas um ÚNICO item do PC
                                Z42->Z42_QTDNOV   :=  oJson["itens"][nI]["quantidade"] // Nova quantidade
                                

                            Z42->(MsUnlock()) 

                        EndIf                       
                        
                    EndIf

                Next nI

                Z42->(DbSkip())

            EndDo    

        End Transaction        

        ErrorBlock(oError) 

        If !Empty(cError)
            
            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[nI]["field"]          := "numeroPedidoERP"
            aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
            aError[nI]["defaultMessage"] := EncodeUtf8(cError)          

        EndIf

    Else
       
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
        aError[nI]["defaultMessage"] := EncodeUtf8("O pedido não foi encontrado.")

    EndIf  

    If lError

        oJSRet["Status"] := 400
        oJSRet["errors"] := aError

    Else

        oJSRet["Status"] := 200        
        oJSRet["numeroPedidoERP"] := oJson["C7_NUM"]

    EndIf  

    FreeObj(oJson)

Return oJSRet


METHOD EnviaError(oJSPC,cError,cTitulo) CLASS TIntegracaoMotorAbastecimentoDAO
	
  Local cHtml      := ""

  cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )

  cHtml  += ' <html> '
  cHtml  += ' <body> ' 
  cHtml  += ' <h3>'+cTitulo+'</h3><BR>' 
  cHtml  += ' '+cError+'<BR> '  
  cHtml  += ' </body> ' 
  cHtml  += ' </html> '

  U_EnvEmail("fsbvieira@gmail.com"," Erro no motor de abastecimento CITEL: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

  //Local cTime      := FwTimeStamp()
  //Local cFilName  := ""
  //cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s' 	
  //oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"]  := "XXXXX99"
  //cFilName := "POST_PC_IDCITEL_"+oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]+"_"+cTime
  //memowrite("\data\"+cFilName+".json", oJSPC:ToJson()) 
  //EnvEmail(cDestin,cAssunto,cMensagem,cAnexos,lUsaLogado)
  //U_EnvEmail("fsbvieira@gmail.com"," Error motor de abastecimento CITERL: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml, cFilName)
  //FERASE("\data\"+cFilName+".json")

Return


/******************************************************************************************************************/
/*                                          METDODOS PARA PEDIDOS DE VENDA                                        */
/******************************************************************************************************************/

 
Method CreatePVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO

	Local aC5CODLJ     := {}
	Local cCodTes      := ""
	Local cNumPed      := ""
	Local cError       := ""
	Local aCab         := {}
	Local aItens       := {}
	Local aDet         := {}
	Local aOFacIN      := {}
	Local nW					 := 0
	Local nX					 := 0


	/*
		SFM - Tes Inteligente. O cadastro das regras de preenchimento do cÃ³digo do TES estÃ¡ 
		vinculado com um cÃ³digo de tipo de 	movimentaÃ§Ã£o (FM_TIPO), por exemplo: 
		01 - Venda de Mercadorias,
		02 - Simples Remessa de Material, 
		03 - Venda para Consumidor Final
	*/
	Local cTipOper 	:= SuperGetMV("ZF_TIPOTES", .F., "03")

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	aOFacIN := ::ListarFacIN("?Status=finalizado")

	If !Empty(aOFacIN)

		For nW := 1 To Len(aOFacIN:RESPONSE)
			// Neste RDMAKE (Exemplo), o mesmo nÃºmero do Pedido de Venda Ã© utilizado para a Rotina AutomÃ¡tica (Modelos INCLUSÃƒO / ALTERAÃ‡ÃƒO e EXCLUSÃƒO).

			//****************************************************************
			//* Inclusao - INÃCIO
			//****************************************************************
			aCab     := {}
			aItens   := {}

			aC5CODLJ := StrTokArr(AllTrim(aOFacIN:RESPONSE[nW]:CLIENTE:CodigoLegado),"-")
			cNumPed := GetSXENum("SC5","C5_NUM")

			aAdd(aCab,	{"C5_FILIAL" 	, xFilial("SC5")			,Nil})
			aAdd(aCab,	{"C5_NUM"   	, cNumPed				,Nil})
			aAdd(aCab,	{"C5_TIPO"   	, "N"						,Nil})
			aAdd(aCab,	{"C5_CLIENTE"	, aC5CODLJ[1]				,Nil})
			aAdd(aCab,	{"C5_LOJACLI"	, aC5CODLJ[2]				,Nil})
			aAdd(aCab,	{"C5_EMISSAO"	, Date()					,Nil})
			aAdd(aCab,	{"C5_VEND1"  	, AllTrim(aOFacIN:RESPONSE[nW]:Usuario:CodigoVendedor),Nil})
			aAdd(aCab,	{"C5_DESPESA" 	, 0							,Nil})
			aAdd(aCab,	{"C5_CONDPAG" 	, AllTrim(aOFacIN:RESPONSE[nW]:CondicaoPagamento:CodigoLegado)	,Nil})
			aAdd(aCab,	{"C5_DESCONT" 	, aOFacIN:RESPONSE[nW]:ValorDesconto		,Nil})
			aAdd(aCab,	{"C5_INDPRES" 	, "2"						,Nil}) 	//|2 - Significa venda nÃ£o presencial -> internet |
			aAdd(aCab,	{"C5_YFACIN" 	, aOFacIN:RESPONSE[nW]:Id	,Nil}) 	// Id do FacIN
			aAdd(aCab,	{"C5_YFASYNC" 	, "N"	,Nil}) 	// Sincronizado?  (S)para sim <<APENAS QUANDO EXISTIR NF C5_NOTA>> ou (N) para nÃ£o.


			For nX := 1 To Len(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem)
				aDet     := {}
				//--- Informando os dados do item do Pedido de Venda
				AAdd(aDet,	{"C6_FILIAL" , xFilial("SC6")	,Nil})
				AAdd(aDet,	{"C6_NUM"  	 , cNumPed			,Nil})
				AAdd(aDet,	{"C6_ITEM"   , StrZero(nX,2)	,Nil})
				AAdd(aDet,	{"C6_PRODUTO", AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado)		,Nil})
				AAdd(aDet,	{"C6_UM"     , AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:UnidadeMedida:CodigoLegado)		,Nil})
				AAdd(aDet,	{"C6_QTDVEN" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Quantidade	,Nil})
				AAdd(aDet,	{"C6_PRCVEN" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario			,Nil})
				AAdd(aDet,	{"C6_PRUNIT" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario			,Nil})

				//|Procura a TES da Venda |
				If !Empty(cTipOper)
					cCodTes  :=  MaTesInt(02, cTipOper, aC5CODLJ[1], aC5CODLJ[2], "C", AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado))
				EndIf

				If Empty(cCodTes)
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
					SB1->(dbSeek(xFilial("SB1")+AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado)))
					cCodTes	:= SB1->B1_TS
				EndIf

				If Empty(cCodTes)
					cCodTes	:=  "502"
				EndIf
				//|Fim Procura a TES da Venda |


				AAdd(aDet,	{"C6_TES"   , cCodTes	,Nil})
				AAdd(aDet,	{"C6_DESCRI" , AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:Descricao)		,Nil})
				AAdd(aDet,	{"C6_LOCAL"  , "01"			,Nil})
				//AAdd(aDet,	{"C6_VALOR"  , Round((aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Quantidade*aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario),TamSX3("C6_PRCVEN")[2]),Nil})
				AAdd(aItens,AClone(aDet))

			Next nX

			Begin Transaction
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)
				If !lMsErroAuto
					ConOut("Incluido com sucesso! " + cNumPed)
					ConfirmSX8()
					::EditarPVFacIN(aOFacIN:RESPONSE[nW], cNumPed)
				Else
					RollbackSx8()
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
					ConOut(PadC("Automatic routine ended with error", 80))
					ConOut("Error: "+ cError)
					U_EmailFac("Erro ao inserir pedido de Venda - FacIN  >> Protheus", cError, "", "")
				EndIf
			End Transaction
			lMsErroAuto    := .F.
			//****************************************************************
			//* Inclusao - FIM
			//****************************************************************
		Next nW

	EndIf

Return(.T.)
