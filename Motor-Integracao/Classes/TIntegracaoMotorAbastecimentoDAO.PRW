#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method ExecAutoPCompra(oJson)
    Method ExecAutoPVenda(oJson)
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoDAO
    ::oJSon := JsonObject():New() 
Return self


Method ExecAutoPCompra(oJSPC) Class TIntegracaoMotorAbastecimentoDAO
	
    Local oJSRet    := JsonObject():New() 
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
    aAdd(aCab,  {"C7_EMISSAO"	,dDataBase									 ,Nil})
    aAdd(aCab,  {"C7_FORNECE"	,oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]  ,NIL}) // Fornecedor
    aAdd(aCab,  {"C7_LOJA"	    ,oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]     ,NIL}) // Loja do Fornecedor
    aAdd(aCab,  {"C7_COND"	    ,oJSPC["pedidoCompra"]["cab"]["C7_COND"]     ,NIL}) // Condicao de Pagamento   
    aAdd(aCab,  {"C7_FILENT"	,oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]   ,NIL}) // Filial de Entrega
    aAdd(aCab,	{"C7_YIDCITE"	,oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]	 ,NIL}) // ID CITEL
    
 
    Begin Transaction

        For nI := 1 To  Len(oJSPC["pedidoCompra"]["itens"])    
             
            aItem := {}

            aAdd(aItem, {"C7_PRODUTO"   ,AllTrim(oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"])  ,NIL})	
            aAdd(aItem, {"C7_QUANT"	    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_LOCAL"	    ,"01"                       	                            ,Nil})	
            aAdd(aItem, {"C7_PRECO"	    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]             ,NIL})            
            aAdd(aItem, {"C7_QTDSOL"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd(aItem, {"C7_DATPRF"	,StoD(oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"])      ,NIL})  //Data de entrega
            aAdd(aItem, {"C7_OPER"	    ,'01'				                                     	,Nil})
            aAdd(aItem, {"C7_YTIPCMP"   ,'OT'					                                    ,Nil})  
            
            aAdd(aIClone, AClone(aItem))

        Next nI  
                       
        //SetFunName('RESTPC')
        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão 

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC + "")
            oJSRet["Status"]           := 200
            oJSRet["numeroDocumento"]  := cNumPC                       

        Else     
                	
             
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)
            AADD(aError,   JsonObject():New())
            aError[1]["field"]          := ""
            aError[1]["rejectedValue"]  := ""
            aError[1]["defaultMessage"] := EncodeUtf8(cError)	                           
            lError := .T.        
            ErrorBlock(oError)                      

        EndIf		

    End Transaction

    If lError
        oJSRet           := JsonObject():New()
        oJSRet["Status"] := 400
        oJSRet["Erros"]  := aError
    EndIf	


Return oJSRet

Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
 

