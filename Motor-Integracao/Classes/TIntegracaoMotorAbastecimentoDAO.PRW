#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method CreatePCompra(oJson)
    Method ExecAutoPVenda(oJson)
    Method BaixaTotalPC(oJson)
    Method BaixaParcialPC(oJson)
    Method EnviaError(oJson)
    

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
                Z42->Z42_SYCSC7   :=  "N"
                Z42->Z42_SYCELE   :=  "N"
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
    Local nI         := 1  
    Local lError     := .F.    
    Local aError     := {}
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})    

    Z42->(DbSetOrder(1)) //Z42_FILIAL, Z42_NUM, Z42_ITEM, R_E_C_N_O_, D_E_L_E_T_
    
    If Z42->(dbSeek(FWxFilial("Z42")+AllTrim(cCodigoDe))) 

        //Begin Transaction
           
            //Z42->(dbGoTo(Z42->((Recno())))
            //Z42->(dbGoTop())
            While Z42->(!Eof()) .AND. FWxFilial("Z42")+AllTrim(cCodigoDe) == Z42->Z42_FILIAL+AllTrim(Z42->Z42_NUM)

                if  Z42->Z42_SYCELE == 'N'  .AND.  Z42->Z42_SYCSC7 == 'S'   
                
                    Z42->(RecLock('Z42', .F.))

                        Z42->Z42_SYCELE   :=  "T" 
                    
                    Z42->(MsUnlock())
                
                EndIf

                Z42->(DbSkip())

            EndDo    

        //End Transaction        

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

Method BaixaParcialPC(oJSPC) Class TIntegracaoMotorAbastecimentoDAO
	
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

	Private lMsErroAuto := .F.

    cNumPC := GetNumSC7()   
    aAdd(aCab,	{"C7_NUM"       ,cNumPC                                      ,Nil}) // Numero do Pedido
    aAdd(aCab,  {"C7_EMISSAO"	,oJSPC["pedidoCompra"]["cab"]["C7_EMISSAO"]  ,Nil})
    aAdd(aCab,  {"C7_FORNECE"	,oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]  ,NIL}) // Fornecedor
    aAdd(aCab,  {"C7_LOJA"	    ,oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]     ,NIL}) // Loja do Fornecedor
    aAdd(aCab,  {"C7_COND"	    ,oJSPC["pedidoCompra"]["cab"]["C7_COND"]     ,NIL}) // Condicao de Pagamento   
    aAdd(aCab,  {"C7_FILENT"	,oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]   ,NIL}) // Filial de Entrega
    aAdd(aCab,  {"C7_CONAPRO"   ,oJSPC["pedidoCompra"]["cab"]["C7_CONAPRO"]  ,Nil})  // Pedido já caindo liberado
    aAdd(aCab,	{"C7_YIDCITE"	,oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]	 ,NIL}) // ID CITEL
    
 
    Begin Transaction

        For nI := 1 To  Len(oJSPC["pedidoCompra"]["itens"])    
             
            aItem := {}
            //aAdd(aItem,	{"C7_NUM"         ,cNumPC                                                     ,Nil}) // Numero do Pedido
            //aAdd(aItem, {"C7_ITEM"        ,StrZero(nI, TamSX3('C7_ITEM')[01])                         ,NIL})
            aAdd(aItem, {"C7_PRODUTO"     ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"]           ,NIL})//U_NAOCOMPRAR()            
            aAdd(aItem, {"C7_QUANT"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_LOCAL"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]             ,Nil})	
            aAdd(aItem, {"C7_PRECO"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]             ,NIL})            
            aAdd(aItem, {"C7_TOTAL"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"] * oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})            
            aAdd(aItem, {"C7_QTDSOL"	  ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_DATPRF"	  ,oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]            ,NIL})  //Data de entrega
            aAdd(aItem, {"C7_OPER"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_OPER"]			  ,Nil})
            aAdd(aItem, {"C7_YTIPCMP"     ,oJSPC["pedidoCompra"]["itens"][nI]["C7_YTIPCMP"]			  ,Nil})        
            aAdd(aItem, {"C7_CONAPRO"     ,oJSPC["pedidoCompra"]["itens"][nI]["C7_CONAPRO"]		      ,Nil})  // Pedido já caindo liberado                  
            aAdd(aItem,	{"C7_YIDCITE"	  ,oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]	              ,NIL})  // ID CITEL            
            aAdd(aIClone, AClone(aItem))

        Next nI                         
        ConOut("INICIO MsExecAuto Mata120")
        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão                   

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )
            oJSRet["Status"]           := 200
            oJSRet["numeroDocumento"]  := cNumPC             
          

            // Logica abaixo para ja alterar os PC para Liberado
            SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

            If SC7->(dbSeek(FWxFilial("SC7")+cNumPC))  

                While SC7->(!Eof()) .AND. FWxFilial("SC7")+cNumPC == SC7->C7_FILIAL+ SC7->C7_NUM               

                    SC7->(RecLock('SC7', .F.))
                        SC7->C7_CONAPRO := 'L'
                    SC7->(MsUnlock())

                    SC7->(DbSkip())

                EndDo   

            EndIf 

        Else                     	
            
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)
            AADD(aError,   JsonObject():New())            
            aError[nw]["field"]          := ""
            aError[nw]["rejectedValue"]  := ""
            aError[nw]["defaultMessage"] := EncodeUtf8(cError)	                           
            lError := .T.   
            nW++         

            ::EnviaError(oJSPC, cError, "POST - Pedido de Compra")

            ErrorBlock(oError)      

        EndIf
       		

    End Transaction

    If lError
        oJSRet           := JsonObject():New()
        oJSRet["Status"] := 400
        oJSRet["Erros"]  := aError       
    Else
        ConOut("FIM MsExecAuto Mata120")       
    EndIf	
    
    FreeObj(oJSPC)
 

Return oJSRet


/******************************************************************************************************************/
/*                                          METDODOS PARA PEDIDOS DE VENDA                                        */
/******************************************************************************************************************/

Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson


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
