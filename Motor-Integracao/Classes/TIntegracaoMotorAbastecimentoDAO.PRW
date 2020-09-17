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
    Local nOP       := 3
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
        //MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,{aItem},nOP,.F.) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão         

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
    Else
       ConOut("FIM Incluido com sucesso o PEDIDO: " + cNumPC)
    EndIf	
    
    FreeObj(oJSPC)
 

Return oJSRet


Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
METHOD EliminaResiduoPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local nPerc      := 100 
    Local cTipo      := 1 
    Local dEmisDe    := MonthSub(dDataBase,12)
    Local dEmisAte   := MonthSum(dDataBase,12)
    Local cCodigoDe  := oJson["C7_NUM"] 
    Local cCodigoAte := oJson["C7_NUM"] 
    Local cProdDe    := "" 
    Local cProdAte   := PadL(cProdAte, TamSX3('B1_COD')[01]  ,  "Z" ) 
    Local cFornDe    := "" 
    Local cFornAte   := PadL(cFornAte, TamSX3('A2_COD')[01]  ,  "Z" )
    Local dDatprfde  := dEmisDe
    Local dDatPrfAte := dEmisAte
    Local cItemDe    := "" 
    Local cItemAte   := PadL(cItemAte, TamSX3('C7_ITEM')[01] ,  "Z" )
    Local lConsEIC   := .T. 
    Local aRecSC7    := {}

    Local oJSRet     := JsonObject():New()
    Local nI         := 0    
    Local lError     := .F.    
    Local aError     := {}
    Local cError    := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})

 	
    /*
    No caso da eleminição de resíduos ficou decido da seguinte forma:

    1 - Usar a função MA235PC que se encontra no fonte padrão TOTVS MATA235;

    2 - Na eleminição parcial dos itens do pedido de compra ficou da forma:
        a) Se for informado a quantidade igual a ZERO de algum item do PC o mesmo tera o residuo eliminido pela rotina acima
        b) Se for informado a quantidade diferente de ZERO o item será alterado(ExecAuto)apenas em sua quantidade de acordo com
           o informado pela CITEL. Caso a quantidade informada a ser eliminada forma maior que o atual será enviada uma mensagem de erro.           
    */
    SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
    
    If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe)) 

       While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM  .AND. SC7->C7_RESIDUO != 'S'            
          AADD(aRecSC7, SC7->(Recno()))
          SC7->(DbSkip())
      EndDo      
      
      If Len(aRecSC7) > 0

        Begin Transaction    
        
            MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC, aRecSC7)     
            
        
        End Transaction

      EndIf

    EndIf 

    ErrorBlock(oError) 

    If !Empty(cError)

        nI++
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
        aError[nI]["defaultMessage"] := EncodeUtf8(cError)       

    ElseIf Len(aRecSC7) == 0

        nI++
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
        aError[nI]["defaultMessage"] := "O pedido não tem residuo para ser eliminado."

    Else

        // VERIFICO SE O RESIUDO FOI ELIMINADO de fato, PARA NÃO CORRER O RISCO DE NÃO ESTAR POSICIONADO  o registro
        SC7->(DbSetOrder(1))     
        If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe)) 

            While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM               
                
                If SC7->C7_RESIUO != 'S'

                    lError     := .T.
                    AADD(aError,   JsonObject():New())
                    aError[nI]["field"]          := "numeroPedidoERP"
                    aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
                    aError[nI]["defaultMessage"] := "O residuo do item: "+SC7->C7_ITEM+"  não foi eliminado."

                EndIf

            EndDo  
            
        EndIf   

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
