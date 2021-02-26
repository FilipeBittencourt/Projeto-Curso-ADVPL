#Include 'TOTVS.CH'
#Include "TopConn.ch"


/*
------------------------------------------------------------------------------------------------------------
Função   	: PCMOTOR2
Tipo		  : job
Descrição	: função para ELIMINAR RESIDUO TOTAL, ou seja, de todos os ITENS do Pedido de compra E FLEGAR  A Z58  COMO ELEMINADO
Retorno 	: .T.
Autor     : Filipe Bittencourt - Facile
Obs.      : Z58_SYCSC7 -    
                        N = NÃO SINCRONIZADO COM A SC7                     
                        S = SICRONIZADO COM A SC7
                        
           Z58_SYCELE -    
                        N = Não Eliminado                        
                        T = Eliminado residuo TOTAL 100% de todos os itens
                        P = Eliminação DE 100%  de apenas um ÚNICO item do PC                        
                        A = Alteração de quantidade de apenas um ÚNICO item do PC
                        S = Item ou pedido 100% encerrado.
------------------------------------------------------------------------------------------------------------
*/

//U_PCMOTOR2
User Function  PCMOTOR2(xParam1,xParam2)

  Local nPerc      := 100
  Local cTipo      := 1
  Local dEmisDe    := NIL
  Local dEmisAte   := NIL
  Local cCodigoDe  := ""
  Local cCodigoAte := ""
  Local cProdDe    := ""
  Local cProdAte   := ""
  Local cFornDe    := ""
  Local cFornAte   := ""
  Local dDatprfde  := NIL
  Local dDatPrfAte := NIL
  Local cItemDe    := ""
  Local cItemAte   := ""
  Local lConsEIC   := .T.
  Local aRecSC7    := {}

  Local lGetErro   := .F.
  Local cHtml      := ""
  Local cError     := ""
  Local oError     := ErrorBlock({|e| cError := e:Description})
  Local cTime      := ""
  Local cEmMOTOR   := ""
  Local cQuery     := ""

  PRIVATE cEmp	     := ""
  PRIVATE cFil	     := ""


  If ValType(xParam1) == "A"
    cEmp 		:= xParam1[1]
    cFil 		:= xParam1[2]
  ElseIf ValType(xParam1) == "C"
    cEmp 		:= xParam1
    cFil 		:= xParam2
  Else
    ConOut('## ERROR - NÃO FOI INFORMADO EMPRESA E FILIAL ##')
    ConOut('## ERROR - FIM DO JOB ##')
    //Return

  EndIf

  If Empty(cEmp) .OR.  Empty(cEmp)
    cEmp 		:= "11"
    cFil 		:= "84"
  EndIf




  ConOut("INICIO do JOB PCMOTOR2 "+cEmp+" / "+cFil)
  If Select("SX6") <= 0
    RPCSetType(3)
    RPCSetEnv(cEmp, cFil, NIL, NIL, "COM", NIL, {"SB1","SF2","SF1"})
  EndIf


  cEmMOTOR := SuperGetMv("MV_YMOTOR3",.F., "fsbvieira@gmail.com;")  //Parametro MOTOR email de quem ira receber o email de erro ao gerar PC pelo motor de abastecimento.

  dEmisDe    := MonthSub(dDataBase,12)
  dEmisAte   := MonthSum(dDataBase,12)
  dDatprfde  := dEmisDe
  dDatPrfAte := dEmisAte
  cProdAte   := PadL(cProdAte, TamSX3('B1_COD')[01]  ,  "Z" )
  cFornAte   := PadL(cFornAte, TamSX3('A2_COD')[01]  ,  "Z" )
  cItemAte   := PadL(cItemAte, TamSX3('C7_ITEM')[01] ,  "Z" )


  cQuery := " SELECT Distinct Z58_NUM , Z58_EMPORI, Z58_FILORI " + CRLF
  cQuery += " FROM  "+  RetSqlName("Z58") + " "  + CRLF
  cQuery += " WHERE  Z58_EMPORI = "+ValToSql(cEmp)  + CRLF
  cQuery += " AND Z58_FILORI  = "+ValToSql(cFil)  + CRLF
  cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
  cQuery += " AND  Z58_SYCSC7  = 'S' " + CRLF
  cQuery += " AND  Z58_SYCELE  = 'T' " + CRLF


  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  If (! __TRZ->(EoF()) )

    While __TRZ->(!Eof())

      cCodigoDe  := AllTrim(__TRZ->Z58_NUM)
      cCodigoAte := AllTrim(__TRZ->Z58_NUM)

      SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

      If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))

        While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM
          If  SC7->C7_RESIDUO != 'S'
            AADD(aRecSC7, SC7->(Recno()))
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

            //Atualizando status Z58_SYCELE para eliminado S=sim
            __TRZ->(dbGoTop())
            cQuery := " UPDATE  " + RetSqlName("Z58") + " SET  Z58_SYCELE = 'S'   "
            cQuery += " WHERE Z58_EMPORI = '"+__TRZ->Z58_EMPORI+"' "
            cQuery += " AND Z58_FILORI   = '"+__TRZ->Z58_FILORI+"' "
            cQuery += " AND Z58_NUM      = '"+__TRZ->Z58_NUM+"' "
            cQuery += " AND Z58_SYCELE  <> 'S' "
            cQuery += " AND Z58_SYCSC7 = 'S'  "
            TCSQLEXEC(cQuery)



          End Transaction

        EndIf

      EndIf

      ErrorBlock(oError)

      If !Empty(cError)

        cError += " - Pedido: "+__TRZ->Z58_NUM
        lGetErro     := .T.

      Else

        // VERIFICO SE O RESIUDO FOI ELIMINADO de fato, PARA NÃO CORRER O RISCO DE NÃO ESTAR POSICIONADO  o registro
        SC7->(DbSetOrder(1))
        If SC7->(dbSeek(FWxFilial("SC7")+cCodigoDe))

          While SC7->(!Eof()) .AND. FWxFilial("SC7")+cCodigoDe == SC7->C7_FILIAL+SC7->C7_NUM

            If SC7->C7_RESIDUO != 'S'

              lGetErro     := .T.
              cError += EncodeUtf8("O PEDIDO "+cCodigoDe+" com o item: "+SC7->C7_ITEM+"  não foi eliminado.<BR>" )

            EndIf

            SC7->(DbSkip())

          EndDo

        EndIf

      EndIf

      __TRZ->(DbSkip())

    EndDo

    If lGetErro

      MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
      ConOut(PadC("Automatic routine ended with error", 80))
      ConOut("Error: "+ cError)

      cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )
      cHtml  += ' <html> '
      cHtml  += ' <body> '
      cHtml  += ' <h3>JOB Eliminação total residuo - Pedido de Compra MOTOR </h3><BR>'
      cHtml  += ' '+cError+'<BR> '
      cHtml  += ' </body> '
      cHtml  += ' </html> '

      if !Empty(cEmMOTOR)

        U_EnvEmail(cEmMOTOR," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

      EndIf

    EndIf

  EndIf

Return .T.

