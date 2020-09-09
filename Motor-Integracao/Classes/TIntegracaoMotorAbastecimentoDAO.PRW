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
	Local cNumPC    := ""	
	Local nI        := 1
    Local nOpc      := 3 //inclusao 
    Local aError    := {}
    Local cError    := ""
    Local oError    := ErrorBlock({|e| cError := e:Description})

	Private lMsErroAuto := .F.
    
    cNumPC := GetNumSC7() //GetSXENum("SC7","C7_NUM")

    aAdd( aCab,	{"C7_FILIAL"    ,oJSPC["pedidoCompra"]["cab"]["C7_FILIAL"], NIL} )		
    aAdd( aCab,	{"C7_NUM"       ,cNumPC                                         ,Nil}) // Numero do Pedido				
    aAdd( aCab,	{"C7_EMISSAO"   ,Date()                                         ,NIL}) // Data de Emissao
    aAdd( aCab,	{"C7_FORNECE"   ,oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]     ,NIL}) // Fornecedor
    aAdd( aCab,	{"C7_LOJA"      ,oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]        ,NIL}) // Loja do Fornecedor
    aAdd( aCab,	{"C7_CONTATO"	,oJSPC["pedidoCompra"]["cab"]["C7_CONTATO"]     ,NIL}) // Contato
    aAdd( aCab,	{"C7_COND"      ,oJSPC["pedidoCompra"]["cab"]["C7_COND"]        ,NIL}) // Condicao de Pagamento  - 001	- A VISTA    			  
    aAdd( aCab,	{"C7_FILENT"    ,oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]      ,NIL}) // Filial de Entrega
    aAdd( aCab,	{"C7_FILCEN"    ,oJSPC["pedidoCompra"]["cab"]["C7_FILCEN"]      ,NIL}) // Filial de Entrega
    aAdd( aCab,	{"C7_FRETE"	    ,oJSPC["pedidoCompra"]["cab"]["C7_FRETE"]		,NIL}) // Frete
    aAdd( aCab,	{"C7_DESPESA"	,oJSPC["pedidoCompra"]["cab"]["C7_DESPESA"]		,NIL}) // Despesa
    aAdd( aCab,	{"C7_SEGURO"	,oJSPC["pedidoCompra"]["cab"]["C7_SEGURO"]		,NIL}) // Seguro
    aAdd( aCab,	{"C7_MSG"		,oJSPC["pedidoCompra"]["cab"]["C7_MSG"]			,NIL}) // Mensagem
    aAdd( aCab,	{"C7_REAJUST"	,oJSPC["pedidoCompra"]["cab"]["C7_REAJUST"]		,NIL}) // Reajuste
    aAdd( aCab,	{"C7_YIDCITE"	,oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]		,NIL}) // ID CITEL
    
 
    Begin Transaction

        For nI := 1 To  1 //Len(oJSPC["pedidoCompra"]["itens"])
/*
        aAdd( aItem, {"C7_ITEM"     ,StrZero(nI, 4)                                             ,NIL})
		aAdd( aItem, {"C7_PRODUTO"  ,AllTrim(oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"])  ,NIL})	
		aAdd( aItem, {"C7_QUANT"    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
        aAdd( aItem, {"C7_LOCAL"    ,"01"                                                       ,NIL})	 
		aAdd( aItem, {"C7_PRECO"    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]             ,NIL})
        aAdd( aItem, {"C7_DATPRF"   ,oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]            ,NIL})  //Data de entrega
        aAdd( aItem, {"C7_OPER"	    ,'01'                                   					,Nil})
		aAdd( aItem, {"C7_NUMSC"	,""	                                                        ,Nil})	
		aAdd( aItem, {"C7_ITEMSC"	,""	                                                        ,Nil})  
		aAdd( aItem, {"C7_QTDSOL"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
         */
           
            aAdd( aItem, {"C7_ITEM"     ,StrZero(nI, 4),NIL} )
            aAdd( aItem, {"C7_PRODUTO"  ,AllTrim(oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"])  ,NIL})		
            aAdd( aItem, {"C7_QUANT"    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]             ,NIL})
            aAdd( aItem, {"C7_PRECO"    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]             ,NIL})
            aAdd( aItem, {"C7_TOTAL"    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_TOTAL"]             ,NIL}) 
            aAdd( aItem, {"C7_DESC"	    ,oJSPC["pedidoCompra"]["itens"][nI]["C7_DESC"]	            ,Nil})  //Desconto
            aAdd( aItem, {"C7_IPI"		,oJSPC["pedidoCompra"]["itens"][nI]["C7_IPI"]	            ,NIL})  //IPI
            aAdd( aItem, {"C7_IPIBRUT"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_IPIBRUT"]           ,NIL})  //IPI Bruto
            aAdd( aItem, {"C7_REAJUST"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_REAJUST"]           ,NIL})  //Reajuste
            aAdd( aItem, {"C7_FRETE"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_FRETE"]	            ,NIL})  //Frete
            aAdd( aItem, {"C7_DATPRF"   ,oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]            ,NIL})  //Data de entrega
            aAdd( aItem, {"C7_LOCAL"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]	            ,NIL})  //Local
            aAdd( aItem, {"C7_TPFRETE"	,oJSPC["pedidoCompra"]["itens"][nI]["C7_TPFRETE"]           ,NIL})  //Tipo de frete
            aAdd( aItem, {"C7_OBS"		,oJSPC["pedidoCompra"]["itens"][nI]["C7_OBS"]               ,NIL})  //Observacao
            aAdd( aItem, {"C7_CONTA"  	,oJSPC["pedidoCompra"]["itens"][nI]["C7_CONTA"]	            ,NIL})  //Conta do produto
            aAdd( aItem, {"C7_CC"       ,oJSPC["pedidoCompra"]["itens"][nI]["C7_CC"]                ,NIL})  //Centro de custo        
                                      
              

	 
		

            If  nOpc == 3
                MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,{aItem},nOpc) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão				
            Else
                MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,{aItem}, nOpc ) // alteração
            EndIf

            If !lMsErroAuto

                ConOut("Incluido com sucesso! " + cNumPC)
                oJSRet["Status"]           := 200
                oJSRet["numeroDocumento"]  := cNumPC

                If nOpc == 3
                    ConfirmSX8()
                EndIf   

            Else
                
                If nOpc == 3
                    RollbackSx8()	
                EndIf      
              
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
                ConOut(PadC("Automatic routine ended with error", 80))
                ConOut("Error: "+ cError)
                

                AADD(aError,   JsonObject():New())
                aError[nI]["field"]          := "Item - "+StrZero(nI, 4)+""
                aError[nI]["rejectedValue"]  := "Produto - "+oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"]+""
                aError[nI]["defaultMessage"] := EncodeUtf8(cError)	
                            
                oJSRet["Status"] := 400
                oJSRet["Erros"]  := aError

                ErrorBlock(oError)

                Exit

            EndIf		
            
            aItem := {} 
        
        Next nI  

    End Transaction


Return oJSRet

Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
 
