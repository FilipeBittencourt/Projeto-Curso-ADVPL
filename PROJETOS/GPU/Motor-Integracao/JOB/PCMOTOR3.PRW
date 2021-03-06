#Include 'TOTVS.CH'
#Include "TopConn.ch"

/*
------------------------------------------------------------------------------------------------------------
Fun��o   	: PCMOTOR3
Tipo		  : job
Descri��o	: fun��o Respons�vel por eliminizar rediduos de forma parcial o PC 
Autor     : Filipe Bittencourt - Facile
Retorno 	: .T.
Obs.      : Z58_SYCSC7 -    
                        N = N�O SINCRONIZADO COM A SC7                     
                        S = SICRONIZADO COM A SC7
                        
           Z58_SYCELE -    
                        N = N�o Eliminado                        
                        T = Eliminado residuo TOTAL 100% de todos os itens
                        P = Elimina��o DE 100%  de apenas um �NICO item do PC                        
                        A = Altera��o de quantidade de apenas um �NICO item do PC
                        S = Item ou pedido 100% encerrado.
------------------------------------------------------------------------------------------------------------
*/


//U_PCMOTOR3
User Function  PCMOTOR3(xParam1,xParam2)


  PRIVATE cEmp		:= ""
  PRIVATE cFil		:= ""


  If ValType(xParam1) == "A"
    cEmp 		:= xParam1[1]
    cFil 		:= xParam1[2]
  ElseIf ValType(xParam1) == "C"
    cEmp 		:= xParam1
    cFil 		:= xParam2
  Else
    ConOut('## ERROR - N�O FOI INFORMADO EMPRESA E FILIAL ##')
    ConOut('## ERROR - FIM DO JOB ##')
    //Return
  EndIf

  If Empty(cEmp) .OR.  Empty(cEmp)
    cEmp 		:= "11"
    cFil 		:= "88"
  EndIf


  If Select("SX6") <= 0
    RPCSetEnv(cEmp, cFil, NIL, NIL, "COM", NIL, {"SB1","SF2","SC7"})
  EndIf
  ConOut("INICIO do JOB PCMOTOR3")

  PutExec()

  PutElim()


Return .T.


Static Function  PutElim()

  Local nPerc      := 100
  Local cTipo      := 3 //1-Pedido, 2-Autor.Entrega, 3-Ambos
  Local dEmisDe    := MonthSub(dDataBase,12)
  Local dEmisAte   := MonthSum(dDataBase,12)
  Local cCodigoDe  := ""
  Local cCodigoAte := ""
  Local cProdDe    := ""
  Local cProdAte   := ""
  Local cFornDe    := ""
  Local cFornAte   := cFornAte   := PadL(cFornAte, TamSX3('A2_COD')[01]  ,  "Z" )
  Local dDatprfde  := dEmisDe
  Local dDatPrfAte := dEmisAte
  Local cItemDe    := ""
  Local cItemAte   := cItemAte   := PadL(cItemAte, TamSX3('C7_ITEM')[01] ,  "Z" )
  Local lConsEIC   := .T.
  Local aRecSC7    := {}

  Local lGetErro   := .F.
  Local cHtml      := ""
  Local cError     := ""
  Local oError     := ErrorBlock({|e| cError := e:Description})
  Local cTime      := ""
  Local cEmMOTOR   := SuperGetMv("MV_YMOTOR3",.F., "fsbvieira@gmail.com")  //Parametro MOTOR email de quem ira receber o email de erro ao gerar PC pelo motor de abastecimento.
  Local cQuery     := ""
  Local cFilialX  := FWxFilial("SC7")

  aNumPC := GetNumPC("P") // PEGOS OS PEDIDOS COM ITENS QUE FORAM ZERADOS STATUTS P

  // pegando apenas os itens de cada pedido com status P
  For nI := 1 To  Len(aNumPC)

    cQuery := ""
    cQuery += " SELECT R_E_C_N_O_ AS RECNO ,  * " + CRLF
    cQuery += " FROM " + RetSqlName("Z58")  + CRLF
    cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
    cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
    cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
    cQuery += " AND  Z58_NUM    = "+ValToSql(AllTrim(aNumPC[nI]))  + CRLF

    cQuery += " AND  Z58_SYCELE = 'P' " + CRLF
    cQuery += " ORDER BY Z58_NUM , Z58_ITEM ASC "    + CRLF

    If Select("__TRZ") > 0
      __TRZ->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "__TRZ"
    __TRZ->(dbGoTop())


    If (__TRZ->(!EoF()) )

      While __TRZ->(!Eof())

        cCodigoDe  := ALLTRIM(__TRZ->Z58_NUM)
        cCodigoAte := ALLTRIM(__TRZ->Z58_NUM)



        /*
        No caso da elemini��o de res�duos ficou decido da seguinte forma:

        1 - Usar a fun��o MA235PC que se encontra no fonte padr�o TOTVS MATA235;

        2 - Na elemini��o parcial dos itens do pedido de compra ficou da forma:
            a) Se for informado a quantidade igual a ZERO de algum item do PC o mesmo tera o residuo eliminido pela rotina acima
            b) Se for informado a quantidade diferente de ZERO o item ser� alterado(ExecAuto)apenas em sua quantidade de acordo com
              o informado pela MOTOR. Caso a quantidade informada a ser eliminada forma maior que o atual ser� enviada uma mensagem de erro.           
        */

        SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

        If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))

          aRecSC7    := {}
          While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM


            If  SC7->C7_RESIDUO != 'S'  .AND.  ALLTRIM(__TRZ->Z58_PRODUT) == ALLTRIM(SC7->C7_PRODUTO)

              cProdDe    := ALLTRIM(__TRZ->Z58_PRODUT)
              cProdAte   := ALLTRIM(__TRZ->Z58_PRODUT)
              cFornDe    := ALLTRIM(__TRZ->Z58_FORNEC)
              cFornAte   := ALLTRIM(__TRZ->Z58_FORNEC)
              AADD(aRecSC7, SC7->(Recno()))  //Pegando o recno de todos para processamento

            EndIf

            SC7->(DbSkip())

          EndDo

          If Len(aRecSC7) > 0

            cTime    := FwTimeStamp()
            cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s
            ConOut("INICIO Eliminando residuo PC MA235PC" + cTime)
            Begin Transaction

              //Eliminando residuo
              MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC, aRecSC7)

              Z58->(dbGoTo(__TRZ->RECNO))
              Z58->(RecLock('Z58', .F.))
              Z58->Z58_SYCELE   :=  "S"
              Z58->(MsUnlock())

            End Transaction

          EndIf


          SC7->(dbGoTop())
          If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))

            While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM

              SC7->(RecLock('SC7', .F.))
              SC7->C7_CONAPRO := 'L'
              SC7->(MsUnlock())

              SC7->(DbSkip())

            EndDo

          EndIf

        EndIf


        ErrorBlock(oError)

        If !Empty(cError)

          lGetErro     := .T.

        Else

          // VERIFICO SE O RESIUDO FOI ELIMINADO de fato, PARA N�O CORRER O RISCO DE N�O ESTAR POSICIONADO  o registro
          SC7->(DbSetOrder(1))
          If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))

            While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM

              If SC7->C7_RESIDUO != 'S'  .AND.  ALLTRIM(__TRZ->Z58_PRODUT) == ALLTRIM(SC7->C7_PRODUTO)

                lGetErro     := .T.
                cError += EncodeUtf8("O PEDIDO "+cCodigoDe+" com o item: "+SC7->C7_ITEM+"  n�o foi eliminado.<BR>" )

              EndIf

              SC7->(DbSkip())

            EndDo

          EndIf

        EndIf

        __TRZ->(DbSkip())

      EndDo

    EndIf

  Next nI

  If lGetErro

    MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
    ConOut(PadC("Automatic routine ended with error", 80))
    ConOut("Error: "+ cError)

    cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )
    cHtml  += ' <html> '
    cHtml  += ' <body> '
    cHtml  += ' <h3>JOB Elimina��o total residuo - Pedido de Compra MOTOR </h3><BR>'
    cHtml  += ' '+cError+'<BR> '
    cHtml  += ' </body> '
    cHtml  += ' </html> '

    if !Empty(cEmMOTOR)

      U_EnvEmail(cEmMOTOR," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

    EndIf

  EndIf

Return .T.


Static Function GetNumPC(cSYCELE)

  Local cQuery   := ""
  Local aNumPC   := {}
  Local cFilialX := FWxFilial("SC7")

  cQuery += " SELECT DISTINCT Z58_NUM  " + CRLF
  cQuery += " FROM " + RetSqlName("Z58")  + CRLF
  cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
  cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
  cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
  cQuery += " AND  Z58_SYCSC7 = 'S' " + CRLF
  cQuery += " AND  Z58_SYCELE = "+ValToSql(cSYCELE)  + CRLF

  //para controle do JOB de altera��o da QTD do item . Restorna o PC em que houve alguma altera��o em um dos seus itens Z58_JOBALT = 'S' ou  'N' n�o retorna
  if cSYCELE == "A"
    cQuery  += " AND  Z58_JOBALT = 'S' " + CRLF
  EndIf




  If Select("__TRX") > 0
    __TRX->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRX"

  __TRX->(dbGoTop())

  While __TRX->(!Eof())

    aAdd(aNumPC,AllTrim(__TRX->Z58_NUM))

    __TRX->(DbSkip())

  EndDo

  __TRX->(dbCloseArea())

Return aNumPC

Static Function  PutExec()


  Local aCab      := {}
  Local aItem     := {}
  Local aIClone   := {}
  Local cQuery    := ""
  Local cError    := ""
  Local cHtml     := ""
  Local nI        := 0
  Local oError    := ErrorBlock({|e| cError := e:Description})
  Local cEmMOTOR  := cEmMOTOR := SuperGetMv("MV_YMOTOR3",.F., "fsbvieira@gmail.com")  //Parametro MOTOR email de quem ira receber o email de erro ao gerar PC pelo motor de abastecimento.
  Local cFilialX  := FWxFilial("SC7")

  Private lMsErroAuto := .F.

  aNumPC := GetNumPC("A") // PEGO UMA LISTA DE PEDIDOS QUE  TIVERAM ITENS ALTERADOS em sua QUANTIDADE Z58_SYCELE = 'A'


  For nI := 1 To  Len(aNumPC) // PEGO os itens de cada pedido com  Z58_SYCELE = 'A'

    cQuery  := ""
    cQuery  += " SELECT R_E_C_N_O_ AS RECNO ,  * " + CRLF
    cQuery  += " FROM " + RetSqlName("Z58")  + CRLF
    cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
    cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
    cQuery  += " AND D_E_L_E_T_  = '' "  + CRLF
    cQuery  += " AND Z58_QTDNOV > 0 "  + CRLF
    cQuery  += " AND Z58_SYCELE  = 'A' "  + CRLF
    cQuery  += " AND  Z58_NUM    = "+ValToSql(AllTrim(aNumPC[nI]))  + CRLF
    cQuery  += " ORDER BY Z58_NUM , Z58_ITEM ASC "    + CRLF

    If Select("__TRZ") > 0
      __TRZ->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "__TRZ"
    __TRZ->(dbGoTop())


    If (! __TRZ->(EoF()) )

      aCab    := {}
      aIClone := {}
      cNumPC  := AllTrim(__TRZ->Z58_NUM)

      aAdd(aCab,	{"C7_FILIAL"    ,AllTrim(__TRZ->Z58_FILIAL)   ,Nil}) // Numero do Pedido
      aAdd(aCab,	{"C7_NUM"       ,cNumPC                       ,Nil}) // Numero do Pedido
      aAdd(aCab,  {"C7_EMISSAO"	  ,StoD(__TRZ->Z58_EMISSA)      ,Nil})
      aAdd(aCab,  {"C7_FORNECE"	  ,__TRZ->Z58_FORNEC            ,NIL}) // Fornecedor
      aAdd(aCab,  {"C7_LOJA"	    ,__TRZ->Z58_LOJA              ,NIL}) // Loja do Fornecedor
      aAdd(aCab,  {"C7_COND"	    ,__TRZ->Z58_COND              ,NIL}) // Condicao de Pagamento
      aAdd(aCab,  {"C7_FILENT"	  ,__TRZ->Z58_FILENT            ,NIL}) // Filial de Entrega
      aAdd(aCab,	{"C7_YIDCITE"	  ,__TRZ->Z58_YIDCIT	          ,NIL}) // ID MOTOR
      aAdd(aCab,	{"C7_CONAPRO"	  ,"L"               	          ,NIL})


      SC7->(DbSetOrder(1))

      While __TRZ->(!Eof())

        aItem := {}
        aAdd(aItem,	{"C7_FILIAL"      ,AllTrim(__TRZ->Z58_FILIAL)           ,Nil}) // Numero do Pedido
        aAdd(aItem,	{"C7_NUM"         ,cNumPC                               ,Nil}) // Numero do Pedido
        aAdd(aItem, {"C7_ITEM"        ,AllTrim(__TRZ->Z58_ITEM)             ,NIL})
        aAdd(aItem, {"C7_PRODUTO"     ,AllTrim(__TRZ->Z58_PRODUT)           ,NIL})
        aAdd(aItem, {"C7_LOCAL"	      ,"01"                                 ,NIL})
        aAdd(aItem, {"C7_DATPRF"	    ,StoD(__TRZ->Z58_DATPRF)              ,NIL})
        aAdd(aItem, {"C7_OPER"	      ,"01"			                            ,Nil})
        aAdd(aItem,	{"C7_TIPO"	      ,1                	                  ,NIL})
        aAdd(aItem,	{"C7_CONAPRO"	    ,"L"               	                  ,NIL})
        aAdd(aItem, {"C7_YTIPCMP"     ,__TRZ->Z58_YTIPCMP		                ,Nil})
        aAdd(aItem,	{"C7_YIDCITE"	    ,__TRZ->Z58_YIDCIT	                  ,NIL})

        If SC7->(dbSeek(FWxFilial("SC7")+cNumPC+AllTrim(__TRZ->Z58_ITEM)))


          If __TRZ->Z58_QTDNOV == 0

            aAdd(aItem, {"C7_QUANT"	      ,SC7->C7_QUANT                ,NIL})
            aAdd(aItem, {"C7_QTDSOL"	    ,SC7->C7_QTDSOL               ,NIL})
            aAdd(aItem, {"C7_PRECO"	      ,SC7->C7_PRECO                ,NIL})
            aAdd(aItem, {"C7_TOTAL"	      ,SC7->C7_TOTAL                ,NIL})

          Else

            aAdd(aItem, {"C7_QUANT"	      ,__TRZ->Z58_QTDNOV                    ,NIL})
            aAdd(aItem, {"C7_QTDSOL"	    ,__TRZ->Z58_QTDNOV                    ,NIL})
            aAdd(aItem, {"C7_PRECO"	      ,__TRZ->Z58_PRECO                     ,NIL})
            aAdd(aItem, {"C7_TOTAL"	      ,__TRZ->Z58_PRECO * __TRZ->Z58_QTDNOV ,NIL})

          EndIf

          aAdd(aItem, {"C7_REC_WT"     ,SC7->(RECNO()) ,Nil})
          aAdd(aIClone, AClone(aItem))

        EndIf



        __TRZ->(DbSkip())

      EndDo

    EndIf

    If Len(aCab) > 0

      Begin Transaction

        ConOut("INICIO MsExecAuto Mata120")

        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,4,.F.) // 3 - Inclusao, 4 - Alteracao, 5 - Exclus�o

        If !lMsErroAuto

          ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )

          //ATUALIZO A QUANTIDADE  DE ACORDO COM A ENVIADA e para o JOB n�o ficar rodando TODAS AS VEZES
          __TRZ->(dbGoTop())
          While __TRZ->(!Eof())

            Z58->(dbGoTo(__TRZ->RECNO))

            If   Z58->Z58_SYCELE == 'A'

              Z58->(RecLock('Z58', .F.))

              Z58->Z58_QUANT    := __TRZ->Z58_QTDNOV
              Z58->Z58_QTDNOV   :=  0
              Z58->Z58_JOBALT   :=  "N"

              Z58->(MsUnlock())

            EndIf

            __TRZ->(DbSkip())

          EndDo



        Else

          ErrorBlock(oError)
          cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
          ConOut(PadC("Automatic routine ended with error", 80))
          ConOut("Error: "+ cError)

          cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )
          cHtml  += ' <html> '
          cHtml  += ' <body> '
          cHtml  += ' <h3>JOB EXECAUTO - Pedido de Compra MOTOR - '+ cNumPC+'</h3><BR>'
          cHtml  += ' '+cError+'<BR> '
          cHtml  += ' </body> '
          cHtml  += ' </html> '

          if !Empty(cEmMOTOR)

            U_EnvEmail(cEmMOTOR," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

          EndIf

        EndIf

      End Transaction

      SC7->(dbGoTop())

      If SC7->(dbSeek(FWxFilial("SC7")+cNumPC))

        While SC7->(!Eof()) .AND. FWxFilial("SC7")+cNumPC == SC7->C7_FILIAL+SC7->C7_NUM

          SC7->(RecLock('SC7', .F.))
          SC7->C7_CONAPRO := 'L'
          SC7->(MsUnlock())

          SC7->(DbSkip())

        EndDo

      EndIf

      ConOut("FIM MsExecAuto Mata120")

    Else

      ConOut("*******************************************************************************")
      ConOut(" ")
      ConOut("Nao ha dados para serem processados pelo JOB3 EXECAUTO - Pedido de Compra MOTOR ")
      ConOut(" ")
      ConOut("*******************************************************************************")

    EndIf


  Next nI

Return .T.
