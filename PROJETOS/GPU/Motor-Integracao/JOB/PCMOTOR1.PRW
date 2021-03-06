#Include 'TOTVS.CH'
#Include "TopConn.ch"

/*
------------------------------------------------------------------------------------------------------------
Fun��o   	: PCMOTOR1
Tipo		  : job
Descri��o	: fun��o para pegar os dados na Z58  e incluir via ExecAUTO NA TABEA SC7
Autor     : Filipe Bittencourt - Facile
Retorno 	: .T.
Obs.      : Z58_SYCSC7 -    
                        N = N�O SINCRONIZADO COM A SC7                     
                        S = SICRONIZADO COM A SC7
                        
           Z58_SYCELE -    
                        N = N�o Eliminado                        
                        T = INSTRU��O PARA O job Eliminar 100%  do residuo de todo o PC
                        P = INSTRU��O PARA O job Eliminar 100%  do residuo de apenas um �NICO item do PC                        
                        A = INSTRU��O PARA O job Alterar a quantidade de apenas um �NICO item do PC
                        S = Fim do clico de vida do PC , ou seja, sem mais a��es pedido 100% encerrado.
------------------------------------------------------------------------------------------------------------
*/


//U_PCMOTOR1
User Function  PCMOTOR1(xParam1,xParam2)

  Local aCab      := {}
  Local aItem     := {}
  Local aIClone   := {}
  Local aNumPC    := {}
  Local cNumPC    := ""
  Local nI        := 0

  Local cQuery    := ""
  Local cError    := ""
  Local cHtml     := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})
  Local cEmMOTOR  :=  ""

  Private lMsErroAuto := .F.
  Private cEmp		:= ""
  Private cFil		:= ""

  If ValType(xParam1) == "A"
    cEmp 		:= xParam1[1]
    cFil 		:= xParam1[2]
  ElseIf ValType(xParam1) == "C"
    cEmp 		:= xParam1
    cFil 		:= xParam2
  Else
    ConOut('## ERROR - N�O FOI INFORMADO EMPRESA E FILIAL ##')
    ConOut('## ERROR - FIM DO JOB ##')
    //  Return

  EndIf

  If Empty(cEmp) .OR.  Empty(cFil)
    cEmp 		:= "08"
    cFil 		:= "01"
  EndIf

  ConOut("INICIO do JOB PCMOTOR1 "+cEmp+" / "+cFil)

  If Select("SX6") <= 0
    RPCSetType(3)
    RPCSetEnv(cEmp, cFil, NIL, NIL, "COM", NIL, {"SB1","SF2","SF1"})
  EndIf

  cEmMOTOR := SuperGetMv("MV_YMOTOR3",.F., "fsbvieira@gmail.com;")  //Parametro MOTOR email de quem ira receber o email de erro ao gerar PC pelo motor de abastecimento.

  aNumPC := GetNumPC()

  For nI := 1 To  Len(aNumPC)

    cQuery := ""
    cQuery += " SELECT R_E_C_N_O_ AS RECNO ,  * " + CRLF
    cQuery += " FROM   "+ RetSqlName("Z58") + " "  + CRLF
    cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
    cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
    cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
    cQuery += " AND  Z58_SYCSC7 = 'N' " + CRLF
    cQuery += " AND  Z58_NUM    = "+ValToSql(AllTrim(aNumPC[nI]))  + CRLF
    cQuery += " ORDER BY Z58_NUM , Z58_ITEM ASC "    + CRLF

    If Select("__TRZ") > 0
      __TRZ->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "__TRZ"
    __TRZ->(dbGoTop())


    If (! __TRZ->(EoF()) )

      aCab    := {}
      aIClone := {}
      cNumPC  := AllTrim(__TRZ->Z58_NUM)

      aAdd(aCab,	{"C7_NUM"       ,cNumPC      ,Nil}) // Numero do Pedido
      aAdd(aCab,  {"C7_EMISSAO"	  ,dDataBase           ,Nil})
      aAdd(aCab,  {"C7_FORNECE"	  ,__TRZ->Z58_FORNEC   ,NIL}) // Fornecedor
      aAdd(aCab,  {"C7_LOJA"	    ,__TRZ->Z58_LOJA     ,NIL}) // Loja do Fornecedor
      aAdd(aCab,  {"C7_COND"	    ,__TRZ->Z58_COND     ,NIL}) // Condicao de Pagamento
      aAdd(aCab,  {"C7_FILENT"	  ,__TRZ->Z58_FILENT   ,NIL}) // Filial de Entrega
      aAdd(aCab,	{"C7_YIDCITE"	  ,__TRZ->Z58_YIDCIT	 ,NIL}) // ID MOTOR

      While __TRZ->(!Eof())

        aItem := {}
        aAdd(aItem, {"C7_ITEM"        ,__TRZ->Z58_ITEM                      ,NIL})
        aAdd(aItem, {"C7_PRODUTO"     ,AllTrim(__TRZ->Z58_PRODUT)           ,NIL})
        aAdd(aItem, {"C7_QUANT"	      ,__TRZ->Z58_QUANT                     ,NIL})
        aAdd(aItem, {"C7_LOCAL"	      ,"01"                                 ,NIL})
        aAdd(aItem, {"C7_PRECO"	      ,__TRZ->Z58_PRECO                     ,NIL})
        aAdd(aItem, {"C7_TOTAL"	      ,__TRZ->Z58_PRECO * __TRZ->Z58_QUANT  ,NIL})
        aAdd(aItem, {"C7_QTDSOL"	    ,__TRZ->Z58_QUANT                     ,NIL})
        aAdd(aItem,	{"C7_TIPO"	      ,1                	                  ,NIL})
        aAdd(aItem, {"C7_DATPRF"	    ,StoD(__TRZ->Z58_DATPRF)              ,NIL})
        aAdd(aItem, {"C7_OPER"	      ,"01"			                            ,Nil})
        aAdd(aItem, {"C7_YTIPCMP"     ,__TRZ->Z58_YTIPCMP		                ,Nil})
        aAdd(aItem,	{"C7_YIDCITE"	    ,__TRZ->Z58_YIDCIT	                  ,NIL})
        aAdd(aIClone, AClone(aItem))

        __TRZ->(DbSkip())

      EndDo

    EndIf


    If Len(aCab) > 0


      /*SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

      If SC7->(dbSeek(FWxFilial("SC7")+AllTrim(cNumPC)))

        ConOut("*******************************************************************************")
        ConOut(" ")
        ConOut("O codigo " + AllTrim(cNumPC)+ " do pedido de compra ja existe na SC7  na Filial: "+cEmp+"/"+cFil)
        ConOut(" ")
        ConOut("*******************************************************************************")

        return .F.

      EndIf*/

      Begin Transaction

        ConOut("INICIO MsExecAuto Mata120")

        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alteracao, 5 - Exclus�o

        If !lMsErroAuto

          ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )

          // Logica abaixo para ja alterar os PC para Liberado, PARA N�O CONFLITAR COM REGRAS DE LIBERA��O EXISTENTES  

          If SC7->(dbSeek(FWxFilial("SC7")+cNumPC))

            While SC7->(!Eof()) .AND. FWxFilial("SC7")+cNumPC == SC7->C7_FILIAL+ SC7->C7_NUM

              SC7->(RecLock('SC7', .F.))
              SC7->C7_CONAPRO := 'L'
              SC7->(MsUnlock())

              SC7->(DbSkip())

            EndDo

          EndIf

          // Logica abaixo para marcar o pedido sincronizado
          __TRZ->(dbGoTop())
          cQuery := " UPDATE  "+ RetSqlName("Z58")+ " SET  Z58_SYCSC7 = 'S'   " 
          cQuery += " WHERE Z58_EMPORI = '"+__TRZ->Z58_EMPORI+"' " 
          cQuery += " AND Z58_FILORI   = '"+__TRZ->Z58_FILORI+"' " 
          cQuery += " AND Z58_NUM      = '"+__TRZ->Z58_NUM+"' " 
          TCSQLEXEC(cQuery)  

          ErrorBlock(oError)

        Else

          cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
          ConOut(PadC("Automatic routine ended with error", 80))
          ConOut("Error: "+ cError)

          cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )
          cHtml  += ' <html> '
          cHtml  += ' <body> '
          cHtml  += ' <h3>JOB EXECAUTO - Pedido de Compra MOTOR - '+ cNumPC+'</h3><BR>'
          cHtml  += ' '+cError+'<BR><BR><BR> '
          cHtml  += ' <h2>**** O MESMO SER� DELETADO ****</h2><BR> '
          cHtml  += ' </body> '
          cHtml  += ' </html> '
          
          if !Empty(cEmMOTOR)

            U_EnvEmail(cEmMOTOR," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

            // DELETANDO O REGISTRO NA Z58, para n�o ficar enviando email de erro
            __TRZ->(dbGoTop())
            cQuery := " UPDATE  "+ RetSqlName("Z58")+ " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_   " 
            cQuery += " WHERE Z58_EMPORI = '"+__TRZ->Z58_EMPORI+"' " 
            cQuery += " AND Z58_FILORI   = '"+__TRZ->Z58_FILORI+"' " 
            cQuery += " AND Z58_NUM      = '"+__TRZ->Z58_NUM+"' " 
            TCSQLEXEC(cQuery) 

          EndIf



        EndIf

      End Transaction

      ConOut("FIM MsExecAuto Mata120")

    Else

      ConOut("*******************************************************************************")
      ConOut(" ")
      ConOut("Nao ha dados para serem processados pelo JOB EXECAUTO - Pedido de Compra MOTOR ")
      ConOut(" ")
      ConOut("*******************************************************************************")

    EndIf

  Next nI

Return .T.


Static Function GetNumPC()

  Local cQuery   := ""
  Local aNumPC   := {}

  cQuery += " SELECT DISTINCT Z58_NUM  " + CRLF
  cQuery += " FROM   "+ RetSqlName("Z58") + "  " + CRLF
  cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
  cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
  cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
  cQuery += " AND  Z58_SYCSC7 = 'N' " + CRLF

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
