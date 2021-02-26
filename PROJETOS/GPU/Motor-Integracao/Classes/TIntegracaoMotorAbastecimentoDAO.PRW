#include "protheus.ch"
#Include "TopConn.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName

    Data oJSon

    Method New() CONSTRUCTOR
    Method CreatePCompra(oJson)
    Method CreatePVenda(oJson)
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
    Local cNumPC    := ""
    Local nI        := 1
    Local nW        := 1

    Local lError    := .F.
    Local aError    := {}
    Local cError    := ""
    Local oError    := ErrorBlock({|e| cError := e:Description})


    Begin Transaction

        cNumPC := GetSXENum('SC7', 'C7_NUM')
        ConfirmSX8()
        For nI := 1 To  Len(oJSPC["pedidoCompra"]["itens"])
            Z58->(RecLock('Z58', .T.))
            Z58->Z58_FILIAL   :=  ""
            Z58->Z58_NUM      :=  cNumPC
            Z58->Z58_EMISSA   :=  oJSPC["pedidoCompra"]["cab"]["C7_EMISSAO"]
            Z58->Z58_FORNEC   :=  oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]
            Z58->Z58_LOJA     :=  oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]
            Z58->Z58_COND     :=  oJSPC["pedidoCompra"]["cab"]["C7_COND"]
            Z58->Z58_FILENT   :=  oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]
            Z58->Z58_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]

            Z58->Z58_ITEM     :=  StrZero(nI, TamSX3('C7_ITEM')[01])
            Z58->Z58_PRODUT   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"]
            Z58->Z58_QUANT    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]
            Z58->Z58_LOCAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]
            Z58->Z58_PRECO    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]
            Z58->Z58_TOTAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"] * oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]
            Z58->Z58_DATPRF   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]
            Z58->Z58_YTIPCM   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_YTIPCMP"]
            Z58->Z58_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]
            Z58->Z58_SYCSC7   :=  "N" // INICIA COMO NÃO SINCRONIZADO, JOB
            Z58->Z58_SYCELE   :=  "N" // INICIA COMO RESIDUO NÃO ELIMNADO,  JOB
            Z58->Z58_JOBALT   :=  "N" // CONTROLER DE QTD DE JOB DE ALTERACAO
            Z58->Z58_QTDNOV   :=  0   // CASO HAJA ALTERAÇÃO DA QUANTIDADE
            Z58->Z58_EMPORI   :=  oJSPC["pedidoCompra"]["cab"]["EMPRESA_ORIGEM"]
            Z58->Z58_FILORI   :=  oJSPC["pedidoCompra"]["cab"]["FILIAL_ORIGEM"]
            //Z58->Z58_EMPDES   :=  oJSPC["pedidoCompra"]["cab"]["EMPRESA_DESTINO"]
            //Z58->Z58_FILDES   :=  oJSPC["pedidoCompra"]["cab"]["FILIAL_DESTINO"]


            Z58->(MsUnlock())
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

            ::EnviaError(oJSPC, cError, "POST - Pedido de Compra na tabela Z58")

        EndIf

        If lError
            oJSRet           := JsonObject():New()
            oJSRet["Status"] := 400
            oJSRet["errors"]  := aError
            RollbackSx8()
        Else
            ConOut("FIM RECLONK Z58")
        EndIf

    End Transaction

    FreeObj(oJSPC)


Return oJSRet

METHOD BaixaTotalPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local cCodigoDe  := oJson["C7_NUM"]
    Local oJSRet     := JsonObject():New()
    Local nI         := 0
    Local lError     := .F.
    Local aError     := {}
    Local cError     := ""
    Local cQuery     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})

    cQuery := " SELECT DISTINCT Z58_EMPORI, Z58_FILORI, Z58_NUM " + CRLF
    cQuery += " FROM "+ RetSqlName("Z58") + CRLF
    cQuery += " WHERE Z58_EMPORI = "+ValToSql(oJson["empresa"]["empresaCodigo"])+"   " + CRLF
    cQuery += " AND Z58_FILORI = "+ValToSql(oJson["empresa"]["empresaFilial"])+"   " + CRLF
    cQuery += " AND Z58_NUM = "+ValToSql(cCodigoDe)+"   " + CRLF
    cQuery += " AND D_E_L_E_T_ = '' " + CRLF
    cQuery += " AND Z58_SYCELE <> 'S' " + CRLF
    cQuery += " AND Z58_SYCSC7 = 'S' " + CRLF

    If Select("__TRZ") > 0
        __TRZ->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "__TRZ"
    __TRZ->(dbGoTop())

    Begin Transaction

        If (! __TRZ->(EoF()) )


            cQuery := " UPDATE "+ RetSqlName("Z58") + " SET Z58_SYCELE = 'T' " + CRLF
            cQuery += " WHERE Z58_EMPORI = "+ValToSql(oJson["empresa"]["empresaCodigo"])+"   " + CRLF
            cQuery += " AND Z58_FILORI = "+ValToSql(oJson["empresa"]["empresaFilial"])+"   " + CRLF
            cQuery += " AND Z58_NUM = "+ValToSql(cCodigoDe)+"   " + CRLF
            cQuery += " AND D_E_L_E_T_ = '' " + CRLF
            cQuery += " AND Z58_SYCELE <> 'S' " + CRLF
            cQuery += " AND Z58_SYCSC7 = 'S' " + CRLF
            TCSQLEXEC(cQuery)

        Else

            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[Len(aError)]["field"]          := "numeroPedidoERP"
            aError[Len(aError)]["rejectedValue"]  := AllTrim(cCodigoDe)
            aError[Len(aError)]["defaultMessage"] := EncodeUtf8("O código do pedido de compra não existe para o CNPJ "+oJson["empresa"]["empresaCnpj"] +" .")


        EndiF

    End Transaction

    ErrorBlock(oError)

    If !Empty(cError)
        nI++
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := AllTrim(oJson["C7_NUM"])
        aError[nI]["defaultMessage"] := EncodeUtf8(cError)

    EndIf

    If lError

        oJSRet["Status"] := 400
        oJSRet["errors"] := aError

    Else

        oJSRet["Status"] := 200
        oJSRet["numeroPedidoERP"] := AllTrim(oJson["C7_NUM"])

    EndIf

    FreeObj(oJson)

Return oJSRet



METHOD BaixaParcialPC(oJson) CLASS TIntegracaoMotorAbastecimentoDAO

    Local cCodigo  := oJson["C7_NUM"]
    Local cCHAVE1     := ""
    Local cCHAVE2    := ""
    Local oJSRet     := JsonObject():New()
    Local nI         := 1
    Local lError     := .F.
    Local aError     := {}
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})
    Local cQuery     := ""


    cQuery := " SELECT * " + CRLF
    cQuery += " FROM "+ RetSqlName("Z58") + CRLF
    cQuery += " WHERE Z58_EMPORI = "+ValToSql(oJson["empresa"]["empresaCodigo"])+"   " + CRLF
    cQuery += " AND Z58_FILORI = "+ValToSql(oJson["empresa"]["empresaFilial"])+"   " + CRLF
    cQuery += " AND Z58_NUM = "+ValToSql(cCodigo)+"   " + CRLF
    cQuery += " AND D_E_L_E_T_ = '' " + CRLF
    cQuery += " AND Z58_SYCELE <> 'S' " + CRLF
    cQuery += " AND Z58_SYCSC7 = 'S' " + CRLF

    If Select("__TRZ") > 0
        __TRZ->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "__TRZ"
    __TRZ->(dbGoTop())

    Begin Transaction

        If (__TRZ->(!EoF()) )

            While __TRZ->(!Eof())

                For nI := 1 To Len(oJson["itens"])

                    If oJson["itens"][nI]["produto"] == __TRZ->Z58_PRODUT

                        If oJson["itens"][nI]["quantidade"] == 0

                            cQuery := " UPDATE "+ RetSqlName("Z58") + " SET " + CRLF
                            cQuery += " Z58_SYCELE = 'P' , " + CRLF
                            cQuery += " Z58_QTDNOV = "+ValToSql(oJson["itens"][nI]["quantidade"])+"   " + CRLF
                            cQuery += " WHERE Z58_EMPORI = "+ValToSql(oJson["empresa"]["empresaCodigo"])+"   " + CRLF
                            cQuery += " AND Z58_FILORI = "+ValToSql(oJson["empresa"]["empresaFilial"])+"   " + CRLF
                            cQuery += " AND Z58_PRODUT = "+ValToSql(__TRZ->Z58_PRODUT)+"   " + CRLF
                            cQuery += " AND Z58_NUM = "+ValToSql(cCodigo)+"   " + CRLF
                            cQuery += " AND D_E_L_E_T_ = '' " + CRLF
                            TCSQLEXEC(cQuery)

                        Else

                            cQuery := " UPDATE "+ RetSqlName("Z58") + " SET " + CRLF
                            cQuery += "  Z58_SYCELE = 'A' , " + CRLF
                            cQuery += "  Z58_JOBALT = 'S' , " + CRLF
                            cQuery += " Z58_QTDNOV = "+ValToSql(oJson["itens"][nI]["quantidade"])+"   " + CRLF
                            cQuery += " WHERE Z58_EMPORI = "+ValToSql(oJson["empresa"]["empresaCodigo"])+"   " + CRLF
                            cQuery += " AND Z58_FILORI = "+ValToSql(oJson["empresa"]["empresaFilial"])+"   " + CRLF
                            cQuery += " AND Z58_PRODUT = "+ValToSql(__TRZ->Z58_PRODUT)+"   " + CRLF
                            cQuery += " AND Z58_NUM = "+ValToSql(cCodigo)+"   " + CRLF
                            cQuery += " AND D_E_L_E_T_ = '' " + CRLF
                            TCSQLEXEC(cQuery)

                        EndIf

                    EndIf

                Next nI

                __TRZ->(DbSkip())

            EndDo

        Else

            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[Len(aError)]["field"]          := "numeroPedidoERP"
            aError[Len(aError)]["rejectedValue"]  := oJson["C7_NUM"]
            aError[Len(aError)]["defaultMessage"] := EncodeUtf8("O pedido não foi encontrado.")

        EndIf

        ErrorBlock(oError)

        If !Empty(cError)

            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[nI]["field"]          := "numeroPedidoERP"
            aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
            aError[nI]["defaultMessage"] := EncodeUtf8(cError)

        EndIf

    End Transaction


    If lError

        oJSRet["Status"] := 400
        oJSRet["errors"] := aError

    Else

        oJSRet["Status"] := 200
        oJSRet["numeroPedidoERP"] := oJson["C7_NUM"]

    EndIf

    FreeObj(oJson)

Return oJSRet


METHOD EnviaError(oJSPC,cError,cTitulo) CLASS TIntegracaoMotorAbastecimentoDAO

    Local cHtml      := ""

    cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )

    cHtml  += ' <html> '
    cHtml  += ' <body> '
    cHtml  += ' <h3>'+cTitulo+'</h3><BR>'
    cHtml  += ' '+cError+'<BR> '
    cHtml  += ' </body> '
    cHtml  += ' </html> '

    U_EnvEmail("fsbvieira@gmail.com"," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

Return


/******************************************************************************************************************/
/*                                          METDODOS PARA PEDIDOS DE VENDA                                        */
/******************************************************************************************************************/


Method CreatePVenda(oJsonPV) Class TIntegracaoMotorAbastecimentoDAO


    Local oJSRet    := JsonObject():New()
    Local cNumPed   := ""
    Local aCab      := {}
    Local aItens    := {}
    Local aDet      := {}
    Local nX		:= 0

    Local aError    := {}
    Local lError    := .F.
    Local cError    := ""
    Local cHtml     := ""
    Local oError    := ErrorBlock({|e| cError := e:Description})
    Local cEmMOTOR  := SuperGetMv("MV_YMOTOR3",.F., "fsbvieira@gmail.com")  //Parametro MOTOR email de quem ira receber o email de erro ao gerar PC pelo motor de abastecimento.

    Private lMsErroAuto    := .F.

    cNumPed := GetSXENum("SC5","C5_NUM")

    aAdd(aCab,	{"C5_FILIAL" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_FILIAL"]     ,Nil})
    aAdd(aCab,	{"C5_NUM"   	,  cNumPed				                          ,Nil})
    aAdd(aCab,	{"C5_TIPO"  	,  oJsonPV["pedidoVenda"]["cab"]["C5_TIPO"]       ,Nil})
    aAdd(aCab,	{"C5_CLIENTE"	,  oJsonPV["pedidoVenda"]["cab"]["C5_CLIENTE"]    ,Nil})
    aAdd(aCab,	{"C5_LOJACLI"	,  oJsonPV["pedidoVenda"]["cab"]["C5_LOJACLI"]    ,Nil})
    aAdd(aCab,	{"C5_EMISSAO"	,  oJsonPV["pedidoVenda"]["cab"]["C5_EMISSAO"]    ,Nil})
    aAdd(aCab,	{"C5_VEND1"	    ,  oJsonPV["pedidoVenda"]["cab"]["C5_VEND1"]      ,Nil})
    aAdd(aCab,	{"C5_DESPESA" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_DESPESA"]    ,Nil})
    aAdd(aCab,	{"C5_CONDPAG" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_CONDPAG"]    ,Nil})
    aAdd(aCab,	{"C5_DESCONT"	,  oJsonPV["pedidoVenda"]["cab"]["C5_DESCONT"]    ,Nil})
    aAdd(aCab,	{"C5_INDPRES" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_INDPRES"]    ,Nil})//|2 - Significa venda nao presencial -> internet |

    aAdd(aCab,	{"C5_YEMPFOR" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_YEMPFOR"]    ,Nil})
    aAdd(aCab,	{"C5_YSTATUS" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_YSTATUS"]    ,Nil}) // LIBERADO PARA FATURAMENTO/LIBERAÇÃO
    aAdd(aCab,	{"C5_YHRINC" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_YHRINC"]     ,Nil})
    aAdd(aCab,	{"C5_YIDCITE" 	,  oJsonPV["pedidoVenda"]["cab"]["C5_YIDCITE"]    ,Nil})

    For nX := 1 To Len(oJsonPV["pedidoVenda"]["itens"])

        aDet     := {}

        AAdd(aDet,	{"C6_ITEM"	     ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_ITEM"]          ,Nil})
        AAdd(aDet,	{"C6_PRODUTO"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_PRODUTO"]       ,Nil})
        AAdd(aDet,	{"C6_LOCAL"	     ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_LOCAL"]         ,Nil})
        AAdd(aDet,	{"C6_TES"		 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_TES"]           ,Nil})
        AAdd(aDet,	{"C6_QTDVEN"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_QTDVEN"]        ,Nil})
        AAdd(aDet,	{"C6_QTDLIB"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_QTDLIB"]        ,Nil})
        AAdd(aDet,	{"C6_PRUNIT"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_PRUNIT"]        ,Nil})
        AAdd(aDet,	{"C6_PRCVEN"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_PRCVEN"]        ,Nil})
        AAdd(aDet,	{"C6_VALOR"	     ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_VALOR"]         ,Nil})
        AAdd(aDet,	{"C6_ENTREG"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_ENTREG"]        ,Nil})
        AAdd(aDet,	{"C6_SUGENTR"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_SUGENTR"]       ,Nil})
        AAdd(aDet,	{"C6_YDTRESI"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_YDTRESI"]       ,Nil})
        AAdd(aDet,	{"C6_VALDESC"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_VALDESC"]       ,Nil})
        AAdd(aDet,	{"C6_DESCONT"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_DESCONT"]       ,Nil})
        AAdd(aDet,	{"C6_NFORI"	     ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_NFORI"]         ,Nil})
        AAdd(aDet,	{"C6_SERIORI"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_SERIORI"]       ,Nil})
        AAdd(aDet,	{"C6_ITEMORI"	 ,  oJsonPV["pedidoVenda"]["itens"][nX]["C6_ITEMORI"]       ,Nil})


        AAdd(aItens,AClone(aDet))

    Next nX

    Begin Transaction

        ConOut("INICIO MsExecAuto MataMata410 - MOTOR de ABASTECIMENTO")

        MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)

        ErrorBlock(oError)

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPed )
            oJSRet["Status"]           := 200
            oJSRet["numeroDocumento"]  := cNumPed

            ConfirmSX8()

        Else



            RollbackSx8()
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

            If !Empty(MostraErro("/dirdoc", "error.log"))
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            EndIf

            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)

            AADD(aError,   JsonObject():New())
            aError[LEN(aError)]["field"]          := ""
            aError[LEN(aError)]["rejectedValue"]  := ""
            aError[LEN(aError)]["defaultMessage"] := EncodeUtf8(cError)
            lError := .T.


            cError :=  StrTran( EncodeUtf8(cError), Chr(13) + Chr(10), "<BR>" )
            cHtml  += ' <html> '
            cHtml  += ' <body> '
            cHtml  += ' <h3>JOB EXECAUTO - Pedido de VENDA MOTOR - '+ cNumPed+'</h3><BR>'
            cHtml  += ' '+cError+'<BR> '
            cHtml  += ' </body> '
            cHtml  += ' </html> '

            if !Empty(cEmMOTOR)

                U_EnvEmail(cEmMOTOR," Erro no motor de abastecimento MOTOR: "+ SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_NOME , cHtml)

            EndIf

        EndIf

    End Transaction

    If lError
        oJSRet           := JsonObject():New()
        oJSRet["Status"] := 400
        oJSRet["errors"]  := aError
    Else

        //Criar o PC para o destino trocar

        //STARTJOB( "U_ENVMOTOR", GetEnvServer(),.T.,oJsonPV:ToJason())

        //Fechar
        ConOut("FIM MsExecAuto MataMata410 - MOTOR de ABASTECIMENTO")

    EndIf

Return oJSRet
