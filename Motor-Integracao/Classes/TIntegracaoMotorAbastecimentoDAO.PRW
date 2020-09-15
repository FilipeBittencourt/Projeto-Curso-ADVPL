#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method ExecAutoPCompra(oJson)
    Method ExecAutoPVenda(oJson)
    Method EliminaResiduoPC(oJson)
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoDAO
    ::oJSon := JsonObject():New() 
Return self


Method ExecAutoPCompra(oJSPC) Class TIntegracaoMotorAbastecimentoDAO
	
    Local oJSRet    := JsonObject():New() 
    Local oJSexec   := Nil
    Local oEnvMail  := Nil
	Local aCab      := {}
	Local aItem     := {}		
    Local aIClone   := {}
	Local cNumPC    := ""	
	Local nI        := 1    
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
            aAdd(aItem, {"C7_PRODUTO"     ,AllTrim(oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"])  ,NIL})	
            aAdd(aItem, {"C7_QUANT"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_LOCAL"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]             ,Nil})	
            aAdd(aItem, {"C7_PRECO"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]             ,NIL})            
            aAdd(aItem, {"C7_QTDSOL"	  ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_DATPRF"	  ,StoD(oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"])      ,NIL})  //Data de entrega
            aAdd(aItem, {"C7_OPER"	      ,oJSPC["pedidoCompra"]["itens"][nI]["C7_OPER"]			  ,Nil})
            aAdd(aItem, {"C7_YTIPCMP"     ,oJSPC["pedidoCompra"]["itens"][nI]["C7_YTIPCMP"]			  ,Nil})        
            aAdd(aItem, {"C7_CONAPRO"     ,oJSPC["pedidoCompra"]["itens"][nI]["C7_CONAPRO"]		      ,Nil})  // Pedido já caindo liberado                  
            aAdd(aItem,	{"C7_YIDCITE"	  ,oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]	              ,NIL})  // ID CITEL            
            aAdd(aIClone, AClone(aItem))

        Next nI                         
     
        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão         

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC + "")
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
            aError[1]["field"]          := ""
            aError[1]["rejectedValue"]  := ""
            aError[1]["defaultMessage"] := EncodeUtf8(cError)	                           
            lError := .T.                   

            // Criando body e a mensagem de erro para enviar via email - workflow
           //oJSexec   := JsonObject():New() 
           //oEnvMail  := TIntegracaoMotorAbastecimentoEmail():New()
           //oJSexec["cabecalho"] := aCab
           //oJSexec["item"]      := aItem
           //oJSexec["Error"]     := EncodeUtf8(cError)
           //oEnvMail:EnvEmail(oJSexec)
           //FreeObj(oJSexec)

            ErrorBlock(oError)      

        EndIf		

    End Transaction

    If lError
        oJSRet           := JsonObject():New()
        oJSRet["Status"] := 400
        oJSRet["Erros"]  := aError
    EndIf	
    
    FreeObj(oJSPC)

Return oJSRet


Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
METHOD EliminaResiduoPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local nPerc      := 100 
    Local cTipo      := "" 
    Local dEmisDe    := CTOD("01/01/20")
    Local dEmisAte   := CTOD("31/12/20")
    Local cCodigoDe  := "455947" 
    Local cCodigoAte := "455947" 
    Local cProdDe    := "" 
    Local cProdAte   := "ZZZZZZ" 
    Local cFornDe    := "" 
    Local cFornAte   := "ZZZZZZ" 
    Local dDatprfde  := CTOD("01/01/20")
    Local dDatPrfAte := CTOD("31/12/20")
    Local cItemDe    := "" 
    Local cItemAte   := "ZZZZ" 
    Local lConsEIC   := .T. 
    Local aRecSC7    := {}
    Local cRet       := ""

    
 

    SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
    If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))  
       While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM               
            AADD(aRecSC7, SC7->(Recno()))
            SC7->(DbSkip())
        EndDo      
    EndIf
    
    SC7->(dbCloseArea())
    //Function MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC, aRecSC7)
    cRet := StaticCall(MATA235,MA235PC, nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC, aRecSC7)

Return cRet


 
