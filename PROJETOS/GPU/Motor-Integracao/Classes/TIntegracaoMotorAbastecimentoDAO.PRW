#include "protheus.ch"

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

        cNumPC := GetNumSC7()
        For nI := 1 To  Len(oJSPC["pedidoCompra"]["itens"])
            Z42->(RecLock('Z42', .T.))
            Z42->Z42_FILIAL   :=  FWxFilial("SC7")
            Z42->Z42_NUM      :=  cNumPC
            Z42->Z42_EMISSA   :=  oJSPC["pedidoCompra"]["cab"]["C7_EMISSAO"]
            Z42->Z42_FORNEC   :=  oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"]
            Z42->Z42_LOJA     :=  oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]
            Z42->Z42_COND     :=  oJSPC["pedidoCompra"]["cab"]["C7_COND"]
            Z42->Z42_FILENT   :=  oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]
            Z42->Z42_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]

            Z42->Z42_ITEM     :=  StrZero(nI, TamSX3('C7_ITEM')[01])
            Z42->Z42_PRODUT   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRODUTO"]
            Z42->Z42_QUANT    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]
            Z42->Z42_LOCAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_LOCAL"]
            Z42->Z42_PRECO    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"]
            Z42->Z42_TOTAL    :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_PRECO"] * oJSPC["pedidoCompra"]["itens"][nI]["C7_QUANT"]
            Z42->Z42_DATPRF   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_DATPRF"]
            Z42->Z42_YTIPCM   :=  oJSPC["pedidoCompra"]["itens"][nI]["C7_YTIPCMP"]
            Z42->Z42_YIDCIT   :=  oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"]
            Z42->Z42_SYCSC7   :=  "N" // INICIA COMO NÃO SINCRONIZADO, JOB
            Z42->Z42_SYCELE   :=  "N" // INICIA COMO RESIDUO NÃO ELIMNADO,  JOB
            Z42->Z42_JOBALT   :=  "N" // CONTROLER DE QTD DE JOB DE ALTERACAO
            Z42->Z42_QTDNOV   :=  0   // CASO HAJA ALTERAÇÃO DA QUANTIDADE

            Z42->(MsUnlock())
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

            ::EnviaError(oJSPC, cError, "POST - Pedido de Compra na tabela Z42")

        EndIf

        If lError
            oJSRet           := JsonObject():New()
            oJSRet["Status"] := 400
            oJSRet["Erros"]  := aError
        Else
            ConOut("FIM RECLONK Z42")
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
    Local oError     := ErrorBlock({|e| cError := e:Description})

    Z42->(DbSetOrder(1)) //Z42_FILIAL, Z42_NUM, Z42_ITEM, R_E_C_N_O_, D_E_L_E_T_

    If Z42->(dbSeek(FWxFilial("Z42")+AllTrim(cCodigoDe)))

        Begin Transaction

            While Z42->(!Eof()) .AND. FWxFilial("Z42")+AllTrim(cCodigoDe) == Z42->Z42_FILIAL+AllTrim(Z42->Z42_NUM)

                if   Z42->Z42_SYCELE != 'S' .AND. Z42->Z42_SYCSC7 == 'S'

                    Z42->(RecLock('Z42', .F.))

                    Z42->Z42_SYCELE   :=  "T"

                    Z42->(MsUnlock())

                Else

                    nI++
                    lError     := .T.
                    AADD(aError,   JsonObject():New())
                    aError[nI]["field"]          := "item["+cValToChar(nI)+"].produto"
                    aError[nI]["rejectedValue"]  := AllTrim(Z42->Z42_PRODUT)
                    aError[nI]["defaultMessage"] := EncodeUtf8("O código do produto informado não foi encontrado ou ainda não foi sincronizado pelo ERP.")


                EndIf

                Z42->(DbSkip())

            EndDo

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

    Else

        nI++
        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := AllTrim(oJson["C7_NUM"])
        aError[nI]["defaultMessage"] := EncodeUtf8("O pedido não foi encontrado.")

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

    Local cCodigoDe  := oJson["C7_NUM"]
    Local oJSRet     := JsonObject():New()
    Local nI         := 1
    Local lError     := .F.
    Local aError     := {}
    Local cError     := ""
    Local oError     := ErrorBlock({|e| cError := e:Description})

    Z42->(DbSetOrder(1)) //Z42_FILIAL, Z42_NUM, Z42_ITEM, R_E_C_N_O_, D_E_L_E_T_

    If Z42->(dbSeek(FWxFilial("Z42")+AllTrim(cCodigoDe)))

        Begin Transaction

            While Z42->(!Eof()) .AND. FWxFilial("Z42")+AllTrim(cCodigoDe) == Z42->Z42_FILIAL+AllTrim(Z42->Z42_NUM)

                For nI := 1 To Len(oJson["itens"])

                    If oJson["itens"][nI]["produto"] == Z42->Z42_PRODUT .AND. Z42->Z42_SYCELE != 'S' .AND.  Z42->Z42_SYCSC7 == 'S'

                        If oJson["itens"][nI]["quantidade"] == 0

                            Z42->(RecLock('Z42', .F.))

                            Z42->Z42_SYCELE   :=  "P" // Eliminação DE 100%  de apenas um ÚNICO item do PC
                            Z42->Z42_QTDNOV   :=  oJson["itens"][nI]["quantidade"] // Nova quantidade

                            Z42->(MsUnlock())

                        Else

                            Z42->(RecLock('Z42', .F.))

                            Z42->Z42_JOBALT   :=  "S"
                            Z42->Z42_SYCELE   :=  "A" // Alteração de quantidade de apenas um ÚNICO item do PC
                            Z42->Z42_QTDNOV   :=  oJson["itens"][nI]["quantidade"] // Nova quantidade


                            Z42->(MsUnlock())

                        EndIf

                    EndIf

                Next nI

                Z42->(DbSkip())

            EndDo

        End Transaction

        ErrorBlock(oError)

        If !Empty(cError)

            lError     := .T.
            AADD(aError,   JsonObject():New())
            aError[nI]["field"]          := "numeroPedidoERP"
            aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
            aError[nI]["defaultMessage"] := EncodeUtf8(cError)

        EndIf

    Else

        lError     := .T.
        AADD(aError,   JsonObject():New())
        aError[nI]["field"]          := "numeroPedidoERP"
        aError[nI]["rejectedValue"]  := oJson["C7_NUM"]
        aError[nI]["defaultMessage"] := EncodeUtf8("O pedido não foi encontrado.")

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

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPed )
            oJSRet["Status"]           := 200
            oJSRet["numeroDocumento"]  := cNumPed

            ConfirmSX8()

        Else

            ErrorBlock(oError)

            RollbackSx8()
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

            If !Empty(MostraErro("/dirdoc", "error.log"))
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            EndIf

            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)

            AADD(aError,   JsonObject():New())
            aError[nw]["field"]          := ""
            aError[nw]["rejectedValue"]  := ""
            aError[nw]["defaultMessage"] := EncodeUtf8(cError)
            lError := .T.
            nW++

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
        oJSRet["Erros"]  := aError
    Else

        ConOut("FIM MsExecAuto MataMata410 - MOTOR de ABASTECIMENTO")

    EndIf

Return oJSRet
