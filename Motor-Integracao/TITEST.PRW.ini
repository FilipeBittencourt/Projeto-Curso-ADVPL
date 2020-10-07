#Include 'TOTVS.CH'
#Include "TopConn.ch"


// u_TITEST1
User Function TITEST1()  
	   

  Local oJSTest  := JsonObject():New()
  Local oJson    := JsonObject():New()
  Local aItem    := {}    
  Local nI       := 0
  Local cQuery   := ""
  Local cBody    := ""
 

 
 
  If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2","Z42"})	
  EndIf

  cQuery += " SELECT * from Z42080  "
   
 

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  While __TRZ->(!Eof())
    nI++     
  __TRZ->(DbSkip())

  EndDo  
 
Return

//U_TITEST
User Function TITEST2() 
	
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

//U_TITEST3
User Function  TITEST3() 
 
  Local aCab      := {}
  Local aItem     := {}		
  Local aIClone   := {}
  Local cNumPC    := ""	 
  Local nI        := 1   
  Local cFilialX  := ""
  Local cQuery    := ""   
  Local cError    := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})

	Private lMsErroAuto := .F.
   
  If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF2","Z42"})	
  EndIf

  cFilialX := FWxFilial("SC7")

  cQuery += " SELECT R_E_C_N_O_ AS RECNO ,  * " + CRLF
  cQuery += " FROM " + RetSqlName("Z42")  + CRLF
  cQuery += " WHERE  Z42_FILIAL = "+ValToSql(cFilialX)  + CRLF
  cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
  cQuery += " AND  Z42_SYCSC7 != 'S' " + CRLF
  cQuery += " AND  Z42_NUM = '456028' " + CRLF
  cQuery += " ORDER BY Z42_ITEM ASC "    + CRLF
 

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  
  If (! __TRZ->(EoF()) )

    cNumPC := __TRZ->Z42_NUM
    aAdd(aCab,	{"C7_NUM"       ,__TRZ->Z42_NUM      ,Nil}) // Numero do Pedido
    aAdd(aCab,  {"C7_EMISSAO"	  ,dDataBase           ,Nil})
    aAdd(aCab,  {"C7_FORNECE"	  ,__TRZ->Z42_FORNEC   ,NIL}) // Fornecedor
    aAdd(aCab,  {"C7_LOJA"	    ,__TRZ->Z42_LOJA     ,NIL}) // Loja do Fornecedor
    aAdd(aCab,  {"C7_COND"	    ,__TRZ->Z42_COND     ,NIL}) // Condicao de Pagamento   
    aAdd(aCab,  {"C7_FILENT"	  ,__TRZ->Z42_FILENT   ,NIL}) // Filial de Entrega    
    aAdd(aCab,	{"C7_YIDCITE"	  ,__TRZ->Z42_YIDCIT	 ,NIL}) // ID CITEL
     
    While __TRZ->(!Eof())
      
      aItem := {}            
      aAdd(aItem, {"C7_ITEM"        ,__TRZ->Z42_ITEM                      ,NIL})
      aAdd(aItem, {"C7_PRODUTO"     ,__TRZ->Z42_PRODUT                    ,NIL})
      aAdd(aItem, {"C7_QUANT"	      ,__TRZ->Z42_QUANT                     ,NIL})
      aAdd(aItem, {"C7_LOCAL"	      ,"01"                                 ,NIL})
      aAdd(aItem, {"C7_PRECO"	      ,__TRZ->Z42_PRECO                     ,NIL})            
      aAdd(aItem, {"C7_TOTAL"	      ,__TRZ->Z42_PRECO * __TRZ->Z42_QUANT  ,NIL})            
      aAdd(aItem, {"C7_QTDSOL"	    ,__TRZ->Z42_QUANT                     ,NIL})
      aAdd(aItem, {"C7_DATPRF"	    ,StoD(__TRZ->Z42_DATPRF)              ,NIL})
      aAdd(aItem, {"C7_OPER"	      ,"01"			                            ,Nil})
      aAdd(aItem, {"C7_YTIPCMP"     ,__TRZ->Z42_YTIPCMP		                ,Nil})                            
      aAdd(aItem,	{"C7_YIDCITE"	    ,__TRZ->Z42_YIDCIT	                  ,NIL})
      aAdd(aIClone, AClone(aItem))       

      __TRZ->(DbSkip())

    EndDo 

  EndIf

 
  If Len(aCab) > 0
 
    SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
    
    If SC7->(dbSeek(FWxFilial("SC7")+AllTrim(cNumPC)))

      ConOut("*******************************************************************************") 
      ConOut(" ") 
      ConOut("O codigo " + AllTrim(cNumPC)+ " do pedido de compra ja existe na SC7  na Filial: "+FWxFilial("SC7")) 
      ConOut(" ") 
      ConOut("*******************************************************************************") 

      return .F.

    EndIf

    Begin Transaction
                                 
        ConOut("INICIO MsExecAuto Mata120")
        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alterao, 5 - Excluso                   

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )

            // Logica abaixo para ja alterar os PC para Liberado, PARA NÃO CONFLITAR COM REGRAS DE LIBERAÇÃO EXISTENTES 

            If SC7->(dbSeek(FWxFilial("SC7")+cNumPC))  

                While SC7->(!Eof()) .AND. FWxFilial("SC7")+cNumPC == SC7->C7_FILIAL+ SC7->C7_NUM               

                    SC7->(RecLock('SC7', .F.))
                        SC7->C7_CONAPRO := 'L'                        
                    SC7->(MsUnlock())

                    SC7->(DbSkip())

                EndDo   

            EndIf 

           
          __TRZ->(dbGoTop())                 
          While __TRZ->(!Eof())
 
            Z42->(dbGoTo(__TRZ->RECNO))

            Z42->(RecLock('Z42', .F.))
              Z42->Z42_SYCSC7 := 'S'                        
            Z42->(MsUnlock())           

            __TRZ->(DbSkip())

          EndDo 

          ErrorBlock(oError) 

        Else                     	
            
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)                
            ::EnviaError(oJSPC, cError, "JOB EXECAUTO - Pedido de Compra CITEL - "+ cNumPC)                 

        EndIf       		

    End Transaction
    
    ConOut("FIM MsExecAuto Mata120") 
  
  Else  

    ConOut("*******************************************************************************") 
    ConOut(" ") 
    ConOut("Nao ha dados para serem processados pelo JOB EXECAUTO - Pedido de Compra CITEL ") 
    ConOut(" ") 
    ConOut("*******************************************************************************") 

  EndIf 

Return .T.
