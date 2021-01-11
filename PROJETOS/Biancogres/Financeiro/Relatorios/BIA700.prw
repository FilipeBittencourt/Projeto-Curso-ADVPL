#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIA700()

    Local oReport
    Local aParam := {}
    Local cName := "BIA700"
    Local cFileName := __cUserID + "_" + cName

    Private oParam
    Private cTitulo := "Rateio de Comissões - Titulos Baixados"

    Private _dEmisDe    := CTOD(" ") // Data de
    Private _dEmisAte   := CTOD(" ") // Data ate
    Private _cVendDe    := Space(TamSx3("A3_COD")[1]) // Cli/Forn de
    Private _cVendAte   := Space(TamSx3("A3_COD")[1]) // Cli/Forn ate
    Private _cPedidoDe  := Space(TamSx3("C5_NUM")[1]) // Cli/Forn de
    Private _cPedidoAte := Space(TamSx3("C5_NUM")[1]) // Cli/Forn ate
    Private _cFiltro    := "1"

    aAdd(aParam, {2, "Status", _cFiltro, {"1=Todos", "2=Aguard. Proc.", "3=Processados"}, 50, ".T.", .T.})

    aAdd(aParam, {1, "Baixa De", _dEmisDe, "@D",".T.",,".T.",50,.F.})
    aAdd(aParam, {1, "Baixa Ate", _dEmisAte, "@D",".T.",,".T.",50,.F.})

    aAdd(aParam, {1, "Vend. Padrão De", _cVendDe, "@!", ".T.", "SA3", ".T.",50,.F.})
    aAdd(aParam, {1, "Vend. Padrão Ate", _cVendAte, "@!", ".T.", "SA3", ".T.",50,.F.})

    aAdd(aParam, {1, "Pedido De", _cPedidoDe, "@!", ".T.", "SC5", ".T.",50,.F.})
    aAdd(aParam, {1, "Pedido Ate", _cPedidoAte, "@!", ".T.", "SC5", ".T.",50,.F.})

    If ParamBox(aParam, "Parâmetros",,,,,,,,cName, .T., .T.)

        lRet := .T.

        _cFiltro    := ParamLoad(cFileName,,1, "1")
        _dEmisDe    := ParamLoad(cFileName,,2, FirstDay(dDataBase))
        _dEmisAte   := ParamLoad(cFileName,,3, LastDay(dDataBase))

        _cVendDe    := ParamLoad(cFileName,,4, Space(TamSx3("A3_COD")[1]))
        _cVendAte   := ParamLoad(cFileName,,5, Replicate("Z", TamSx3("A3_COD")[1]))

        _cPedidoDe  := ParamLoad(cFileName,,6, Space(TamSx3("C5_NUM")[1]))
        _cPedidoAte := ParamLoad(cFileName,,7, Replicate("Z", TamSx3("C5_NUM")[1]))

        If _cFiltro == "1"

            cTitulo += " - (Todos)"

        ElseIf _cFiltro == "2"

            cTitulo += " - (Aguard. Proc.)"

        ElseIf _cFiltro == "3"

            cTitulo += " - (Processados)"

        EndIf

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf

Return()

Static Function ReportDef()

    Local oReport
    Local oSecMov
    Local cQry := GetNextAlias()

    oReport := TReport():New("BIA700", cTitulo, {|| }, {|oReport| PrintReport(oReport, cQry)}, cTitulo)

    //oReport:oFontHeader:Bold := .T.

    oSecMov := TRSection():New(oReport, "Títulos", cQry)

    TRCell():New(oSecMov, "VEND_RAT"    , cQry, "Vend.Pad.",,6)
    TRCell():New(oSecMov, "VEND"        , cQry, "Vendedor",,6)
    TRCell():New(oSecMov, "E3_NUM"      , cQry)
    TRCell():New(oSecMov, "E3_PREFIXO"  , cQry)
    TRCell():New(oSecMov, "E3_CODCLI"   , cQry)
    TRCell():New(oSecMov, "E3_LOJA"     , cQry)
    TRCell():New(oSecMov, "E3_EMISSAO"  , cQry,,,15,,{|| DTOC(STOD((cQry)->E3_EMISSAO)) })
    TRCell():New(oSecMov, "E3_BASE"     , cQry)
    TRCell():New(oSecMov, "E3_PORC"     , cQry, "% Rateio")
    TRCell():New(oSecMov, "E3_COMIS"    , cQry)
    TRCell():New(oSecMov, "E3_PARCELA"  , cQry)
    TRCell():New(oSecMov, "E3_SEQ"  , cQry)
    TRCell():New(oSecMov, "E3_TIPO"     , cQry)
    TRCell():New(oSecMov, "E3_PEDIDO"   , cQry)

Return(oReport)

Static Function PrintReport(oReport, cQry)

    Local oSecMov := oReport:Section(1)
    Local cSQL := ""
    Local nCount := 0
    Local nPerc := 0
    Local nTotBase := 0
    Local nTotComis := 0

    If _cFiltro == "1"

        // A processar
        cSQL += " SELECT E3_FILIAL, "
        cSQL += " STATUS, "
        cSQL += " CASE WHEN E3_YVENRAT = '' THEN E3_VEND    ELSE ''      END VEND_RAT, "
        cSQL += " CASE WHEN E3_YVENRAT = '' THEN E3_YVENRAT ELSE E3_VEND END VEND, "
        cSQL += " E3_NUM, "
        cSQL += " E3_EMISSAO, "
        cSQL += " E3_SERIE, "
        cSQL += " E3_CODCLI, "
        cSQL += " E3_LOJA, "
        cSQL += " E3_BASE, "
        cSQL += " E3_PORC, "
        cSQL += " E3_COMIS, "
        cSQL += " E3_PREFIXO, "
        cSQL += " E3_PARCELA, "
        cSQL += " E3_TIPO, "
        cSQL += " E3_PEDIDO, "
        cSQL += " E3_SEQ "
        cSQL += " FROM (

    EndIf

    If _cFiltro == "1" .Or. _cFiltro == "2"

        cSQL += "   SELECT "
        cSQL += "   'A' STATUS, "
        cSQL += "   CASE WHEN E3_FILIAL = 'XX' THEN E3_YFILRAT ELSE E3_FILIAL END E3_FILIAL, "

        If  _cFiltro == "2"

            cSQL += "   CASE WHEN E3_YVENRAT = '' THEN E3_VEND    ELSE ''      END VEND_RAT, "
            cSQL += "   CASE WHEN E3_YVENRAT = '' THEN E3_YVENRAT ELSE E3_VEND END VEND, "

        EndIf

        cSQL += "   E3_VEND, "
        cSQL += "   E3_NUM, "
        cSQL += "   E3_EMISSAO, "
        cSQL += "   E3_SERIE, "
        cSQL += "   E3_CODCLI, "
        cSQL += "   E3_LOJA, "
        cSQL += "   E3_BASE, "
        cSQL += "   ( ( E3_COMIS * 100 ) / E3_BASE ) E3_PORC, "
        cSQL += "   E3_COMIS, "
        cSQL += "   E3_PREFIXO, "
        cSQL += "   E3_PARCELA, "
        cSQL += "   E3_TIPO, "
        cSQL += "   E3_PEDIDO, "
        cSQL += "   E3_YVENRAT, "
        cSQL += "   E3_YFILRAT, "
        cSQL += "   E3_SEQ "
        cSQL += "   FROM " + RetSQLName("SE3") + " SE3 "
        cSQL += "   WHERE E3_FILIAL = " + ValToSQL(xFilial("SE3"))
        cSQL += "   AND E3_EMISSAO BETWEEN " + ValToSQL(DTOS(_dEmisDe)) + " AND " + ValToSQL(DTOS(_dEmisAte))
        cSQL += "   AND E3_VEND BETWEEN " + ValToSQL(_cVendDe) + " AND " + ValToSQL(_cVendAte)
        cSQL += "   AND E3_PEDIDO BETWEEN " + ValToSQL(_cPedidoDe) + " AND " + ValToSQL(_cPedidoAte)
        cSQL += "   AND EXISTS "
        cSQL += "   ( "
        cSQL += "       SELECT NULL "
        cSQL += "       FROM " + RetSQLName("PZ9") + " PZ9 "
        cSQL += "       WHERE PZ9_FILIAL = " + ValToSQL(xFilial("PZ9"))
        cSQL += "       AND E3_VEND = PZ9_VENDPA "
        cSQL += "       AND E3_EMISSAO BETWEEN PZ9_PERINI AND PZ9_PERFIM "
        // cSQL += "       AND EXISTS "
        // cSQL += "       ( "
        // cSQL += "           SELECT NULL "
        // cSQL += "           FROM " + RetSQLName("SC5") + " SC5 "
        // cSQL += "           WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
        // cSQL += "           AND C5_NUM = E3_PEDIDO "
        // cSQL += "           AND C5_YEMP = PZ9_MARCA "
        // cSQL += "           AND SC5.D_E_L_E_T_ = '' "
        // cSQL += "       ) "
        cSQL += "       AND PZ9.D_E_L_E_T_ = '' "
        cSQL += "   ) "
        cSQL += "   AND SE3.D_E_L_E_T_ = '' "

        If _cFiltro == "2"

            cSQL += " ORDER BY CASE WHEN E3_FILIAL = 'XX' THEN E3_YFILRAT ELSE E3_FILIAL END, E3_NUM, E3_SERIE, E3_CODCLI, E3_LOJA, E3_PARCELA, E3_SEQ, E3_COMIS DESC, E3_VEND "

        EndIf

    EndIf

    If _cFiltro == "1"

        cSQL += "   UNION "

    EndIf

    If _cFiltro == "1" .Or. _cFiltro == "3"

        // Processados
        cSQL += "   SELECT "
        cSQL += "   'P' STATUS, "
        cSQL += "   CASE WHEN E3_FILIAL = 'XX' THEN E3_YFILRAT ELSE E3_FILIAL END E3_FILIAL, "

        If  _cFiltro == "3"

            cSQL += "   CASE WHEN E3_YVENRAT = '' THEN E3_VEND    ELSE ''      END VEND_RAT, "
            cSQL += "   CASE WHEN E3_YVENRAT = '' THEN E3_YVENRAT ELSE E3_VEND END VEND, "

        EndIf

        cSQL += "   E3_VEND, "
        cSQL += "   E3_NUM, "
        cSQL += "   E3_EMISSAO, "
        cSQL += "   E3_SERIE, "
        cSQL += "   E3_CODCLI, "
        cSQL += "   E3_LOJA, "
        cSQL += "   E3_BASE, "
        cSQL += "   ( ( E3_COMIS * 100 ) / E3_BASE ) E3_PORC, "
        cSQL += "   E3_COMIS, "
        cSQL += "   E3_PREFIXO, "
        cSQL += "   E3_PARCELA, "
        cSQL += "   E3_TIPO, "
        cSQL += "   E3_PEDIDO, "
        cSQL += "   E3_YVENRAT, "
        cSQL += "   E3_YFILRAT, "
        cSQL += "   E3_SEQ "
        cSQL += "   FROM " + RetSQLName("SE3") + " A "
        cSQL += "   WHERE E3_EMISSAO BETWEEN " + ValToSQL(DTOS(_dEmisDe)) + " AND " + ValToSQL(DTOS(_dEmisAte))
        cSQL += "   AND E3_PEDIDO BETWEEN " + ValToSQL(_cPedidoDe) + " AND " + ValToSQL(_cPedidoAte)
        cSQL += "   AND EXISTS "
        cSQL += "   ( "
        cSQL += "       SELECT NULL "
        cSQL += "       FROM " + RetSQLName("SE3") + " SE3 "
        cSQL += "       WHERE SE3.E3_YFILRAT = " + ValToSQL(xFilial("SE3"))
        cSQL += "       AND SE3.E3_YVENRAT BETWEEN " + ValToSQL(_cVendDe) + " AND " + ValToSQL(_cVendAte)
        cSQL += "       AND A.E3_EMISSAO = SE3.E3_EMISSAO "
        cSQL += "       AND A.E3_NUM = SE3.E3_NUM "
        cSQL += "       AND A.E3_PREFIXO = SE3.E3_PREFIXO "
        cSQL += "       AND A.E3_TIPO = SE3.E3_TIPO "
        cSQL += "       AND A.E3_PARCELA = SE3.E3_PARCELA "
        cSQL += "       AND A.E3_CODCLI = SE3.E3_CODCLI "
        cSQL += "       AND A.E3_LOJA = SE3.E3_LOJA "
        cSQL += "       AND A.E3_SEQ = SE3.E3_SEQ ""
        cSQL += "       AND SE3.D_E_L_E_T_ = '' "
        cSQL += "   ) "
        cSQL += "   AND A.D_E_L_E_T_ = '' "

        If _cFiltro == "3"

            cSQL += " ORDER BY CASE WHEN E3_FILIAL = 'XX' THEN E3_YFILRAT ELSE E3_FILIAL END, E3_NUM, E3_SERIE, E3_CODCLI, E3_LOJA, E3_PARCELA, E3_SEQ, E3_COMIS DESC, E3_VEND "

        EndIf

    EndIf

    If _cFiltro == "1"

        cSQL += " ) TAB
        cSQL += " ORDER BY TAB.E3_FILIAL, TAB.STATUS, TAB.E3_SEQ, (CASE WHEN E3_YVENRAT = '' THEN TAB.E3_VEND ELSE E3_YVENRAT END), TAB.E3_NUM, TAB.E3_SERIE, TAB.E3_CODCLI, TAB.E3_LOJA, TAB.E3_PARCELA, TAB.E3_COMIS DESC, TAB.E3_VEND "

    EndIf

    TcQuery cSQL New Alias (cQry)

    (cQry)->(DbGoTop())

    oSecMov:Init()

    While !(cQry)->(Eof())

        If !Empty((cQry)->VEND_RAT)

            nTotBase += (cQry)->E3_BASE
            nTotComis += (cQry)->E3_COMIS
            nPerc += (cQry)->E3_PORC
            nCount++

            oSecMov:oFontBody:Bold := .T.

        Else

            oSecMov:oFontBody:Bold := .F.

        EndIf
        
        oSecMov:Cell("VEND_RAT"     ):SetValue((cQry)->VEND_RAT   )
        oSecMov:Cell("VEND"      	):SetValue((cQry)->VEND       )
        oSecMov:Cell("E3_NUM"    	):SetValue((cQry)->E3_NUM     )
        oSecMov:Cell("E3_PREFIXO"	):SetValue((cQry)->E3_PREFIXO )
        oSecMov:Cell("E3_CODCLI" 	):SetValue((cQry)->E3_CODCLI  )
        oSecMov:Cell("E3_LOJA"   	):SetValue((cQry)->E3_LOJA    )
        oSecMov:Cell("E3_EMISSAO"	):SetValue(DTOC(STOD(((cQry)->E3_EMISSAO))))
        oSecMov:Cell("E3_BASE"   	):SetValue((cQry)->E3_BASE    )
        oSecMov:Cell("E3_PORC"   	):SetValue((cQry)->E3_PORC    )
        oSecMov:Cell("E3_COMIS"  	):SetValue((cQry)->E3_COMIS   )
        oSecMov:Cell("E3_PARCELA"	):SetValue((cQry)->E3_PARCELA )
        oSecMov:Cell("E3_SEQ"   	):SetValue((cQry)->E3_SEQ     )
        oSecMov:Cell("E3_TIPO"   	):SetValue((cQry)->E3_TIPO    )
        oSecMov:Cell("E3_PEDIDO"    ):SetValue((cQry)->E3_PEDIDO  )
        oSecMov:PrintLine()
        
        (cQry)->(DbSkip())

    EndDo

    If nCount > 0

        oSecMov:Cell("VEND_RAT"     ):SetValue("")
        oSecMov:Cell("VEND"      	):SetValue("")
        oSecMov:Cell("E3_NUM"    	):SetValue("")
        oSecMov:Cell("E3_PREFIXO"	):SetValue("")
        oSecMov:Cell("E3_CODCLI" 	):SetValue("")
        oSecMov:Cell("E3_LOJA"   	):SetValue("")
        oSecMov:Cell("E3_EMISSAO"	):SetValue("")
        oSecMov:Cell("E3_BASE"   	):SetValue(nTotBase)
        oSecMov:Cell("E3_PORC"   	):SetValue(nPerc/nCount)
        oSecMov:Cell("E3_COMIS"  	):SetValue(nTotComis)
        oSecMov:Cell("E3_PARCELA"	):SetValue("")
        oSecMov:Cell("E3_SEQ"	    ):SetValue("")
        oSecMov:Cell("E3_TIPO"   	):SetValue("")
        oSecMov:Cell("E3_PEDIDO"    ):SetValue("")
        oSecMov:PrintLine()

    EndIf

    oSecMov:Finish()

    (cQry)->(DbCloseArea())

Return()
