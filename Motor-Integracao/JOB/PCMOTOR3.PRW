#Include 'TOTVS.CH'
#Include "TopConn.ch"


/*
------------------------------------------------------------------------------------------------------------
Função   	: PCMOTOR2
Tipo		  : job
Descrição	: função para ELIMINAR RESIDUO PARCIAL(alteração) dos dados na Z42  PARA A TABEA SC7
Retorno 	: .T.
Autor     : Filipe Bittencourt - Facile
Obs.      : Z42_SYCELE -    
                        N = Não Eliminado
                        P = Eliminado residuo PARCIAL (Alteração) nova QTD no campo Z42_QTDNOV
                        T = Eliminado residuo TOTAL
------------------------------------------------------------------------------------------------------------
*/

//U_PCMOTOR3
User Function  PCMOTOR3() 
  

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
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})
    Local cTime      :=  ""
   

 
 	
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
        cTime    := FwTimeStamp()
        cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s
        ConOut("INICIO Eliminando residuo PC MA235PC" + cTime)
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
        aError[nI]["defaultMessage"] := EncodeUtf8("O pedido não tem residuo para ser eliminado.")

    Else

        // VERIFICO SE O RESIUDO FOI ELIMINADO de fato, PARA NÃO CORRER O RISCO DE NÃO ESTAR POSICIONADO  o registro
        SC7->(DbSetOrder(1))     
        If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe)) 

            While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM               
                
                If SC7->C7_RESIDUO != 'S'

                    lError     := .T.
                    AADD(aError,   JsonObject():New())
                    aError[nI]["field"]          := "numeroPedidoERP"
                    aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
                    aError[nI]["defaultMessage"] := EncodeUtf8("O residuo do item: "+SC7->C7_ITEM+"  não foi eliminado.")

                EndIf
                
                SC7->(DbSkip())
                
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
   
    cTime := FwTimeStamp()
    cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s
    ConOut("FIM Eliminando residuo PC MA235PC" + cTime)

    FreeObj(oJson)



Return .T.
