#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIA939()

    Local oReport
    Local aParam := {}
    Local cName := "BIA939"
    Local cFileName := __cUserID +"_"+ cName

    Private oParam

    Private _cProcDe    := Space(TamSx3("ZK8_NUMERO")[1])
    Private _cProcAte   := Space(TamSx3("ZK8_NUMERO")[1])
    Private _dDatVDe    := CTOD(" ") // Data de
    Private _dDatVAte   := CTOD(" ") // Data ate
    Private _cCliDe     := Space(TamSx3("A1_COD")[1]) // Cli/Forn de
    Private _cCliAte    := Space(TamSx3("A1_COD")[1]) // Cli/Forn ate
    Private _cGrupoDe   := Space(TamSx3("ZK8_GRPVEN")[1]) // Grupo cliente de
    Private _cGrupoAte  := Space(TamSx3("ZK8_GRPVEN")[1]) // Grupo cliente ate

    aAdd(aParam, {1, "Proc. De", _cProcDe, "@!", ".T.", "ZK8", ".T.",50,.F.})
    aAdd(aParam, {1, "Proc. Ate", _cProcAte, "@!", ".T.", "ZK8", ".T.",50,.F.})

    aAdd(aParam, {1, "Venc. Orig. De", _dDatVDe, "@D",".T.",,".T.",50,.F.})
    aAdd(aParam, {1, "Venc. Orig. Ate", _dDatVAte, "@D",".T.",,".T.",50,.F.})

    aAdd(aParam, {1, "Cliente De", _cCliDe, "@!", ".T.", "SA1", ".T.",50,.F.})
    aAdd(aParam, {1, "Cliente Ate", _cCliAte, "@!", ".T.", "SA1", ".T.",50,.F.})

    aAdd(aParam, {1, "Grupo Cliente De", _cGrupoDe, "@!", ".T.", "ACY", ".T.",50,.F.})
    aAdd(aParam, {1, "Grupo Cliente Ate", _cGrupoAte, "@!", ".T.", "ACY", ".T.",50,.F.})

    If ParamBox(aParam, "Parâmetros",,,,,,,,cName, .T., .T.)

        lRet := .T.

        _cProcDe    := ParamLoad(cFileName,,1, Space(TamSx3("ZK8_NUMERO")[1]))
        _cProcAte   := ParamLoad(cFileName,,2, Replicate("Z", TamSx3("ZK8_NUMERO")[1]))

        _dDatVDe    := ParamLoad(cFileName,,3, dDataBase)
        _dDatVAte   := ParamLoad(cFileName,,4, dDataBase)

        _cCliDe     := ParamLoad(cFileName,,5, Space(TamSx3("A1_COD")[1]))
        _cCliAte    := ParamLoad(cFileName,,6, Replicate("Z", TamSx3("A1_COD")[1]))

        _cGrupoDe   := ParamLoad(cFileName,,7, Space(TamSx3("ZK8_GRPVEN")[1]))
        _cGrupoAte  := ParamLoad(cFileName,,8, Replicate("Z", TamSx3("ZK8_GRPVEN")[1]))

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf


Return()

Static Function ReportDef()

    Local oReport
    Local oSecMov
    Local cQry := GetNextAlias()
    Local cTitRel := "Baixa Renegociação de Contas a Receber"

    oReport := TReport():New("BIA939", cTitRel, {|| }, {|oReport| PrintReport(oReport, cQry)}, cTitRel)

    oSecMov := TRSection():New(oReport, "Títulos", cQry)
    TRCell():New(oSecMov, "ZKC_FILIAL"  , cQry,,,05)
    TRCell():New(oSecMov, "ZKC_NUMERO"  , cQry,,,15)
    TRCell():New(oSecMov, "ZKC_VALOR"   , cQry, "Vlr. Juros",,20)
    TRCell():New(oSecMov, "A1_COD"      , cQry,,,15)
    TRCell():New(oSecMov, "A1_LOJA"      , cQry,,,15)
    TRCell():New(oSecMov, "A1_NOME"     , cQry,,,80)
    TRCell():New(oSecMov, "E1_PREFIXO"  , cQry,,,05)
    TRCell():New(oSecMov, "E1_NUM"      , cQry,,,15)
    TRCell():New(oSecMov, "E1_PARCELA"  , cQry,,,05)
    TRCell():New(oSecMov, "E1_TIPO"     , cQry,,,05)
    TRCell():New(oSecMov, "E1_VALOR"    , cQry,,,20)
    TRCell():New(oSecMov, "ZKC_VENCTO"  , cQry, "Venc.Original",,20,,{|| (cQry)->ZKC_VENCTO })
    TRCell():New(oSecMov, "ZKC_VENCCA"  , cQry, "Novo Vencimento",,20,,{|| (cQry)->ZKC_VENCCA })

Return(oReport)

Static Function PrintReport(oReport, cQry)

    Local oSecMov := oReport:Section(1)
    Local cSQL := ""
    Local nTot := 0
    Local nTotJr := 0

    cSQL += " WITH ta " + CRLF
    cSQL += "   AS (SELECT ZKC_FILIAL, " + CRLF
    cSQL += "              ZKC_NUMERO, " + CRLF
    cSQL += "              ZKC_VALOR = " + CRLF
    cSQL += "                     ISNULL(( " + CRLF
    cSQL += "                         SELECT TOP 1 ZKC_VALOR " + CRLF
    cSQL += "                         FROM    " + RetSqlName("ZKC") + "  JUR " + CRLF
    cSQL += "                         WHERE  JUR.ZKC_FILIAL = ZKC.ZKC_FILIAL " + CRLF
    cSQL += "                           AND  JUR.ZKC_NUMERO  = ZKC.ZKC_NUMERO " + CRLF
    cSQL += "                           AND  JUR.ZKC_STATUS  = 'J' " + CRLF
    cSQL += "                           AND  JUR.D_E_L_E_T_  = '' " + CRLF
    cSQL += "                     ), 0), " + CRLF
    cSQL += "              A1_COD, " + CRLF
    cSQL += "              A1_LOJA, " + CRLF
    cSQL += "              A1_NOME, " + CRLF
    cSQL += "              E1_PREFIXO, " + CRLF
    cSQL += "              E1_NUM, " + CRLF
    cSQL += "              E1_PARCELA, " + CRLF
    cSQL += "              E1_TIPO, " + CRLF
    cSQL += "              E1_VALOR, " + CRLF
    cSQL += "              ZKC_VENCTO, " + CRLF
    cSQL += "              ZKC_VENCCA " + CRLF
    cSQL += "       FROM    " + RetSqlName("ZKC") + "  ZKC (NOLOCK) " + CRLF
    cSQL += "       JOIN    " + RetSqlName("ZK8") + "  ZK8 (NOLOCK) " + CRLF
    cSQL += "         ON ( " + CRLF
    cSQL += "                ZK8_FILIAL = ZKC_FILIAL " + CRLF
    cSQL += "          AND   ZK8_NUMERO = ZKC_NUMERO " + CRLF
    cSQL += "            ) " + CRLF
    cSQL += "       JOIN    " + RetSqlName("SE1") + "  SE1 (NOLOCK) " + CRLF
    cSQL += "         ON ( " + CRLF
    cSQL += "                E1_FILIAL  = ZKC_FILIAL " + CRLF
    cSQL += "          AND   E1_PREFIXO = ZKC_PREFIX " + CRLF
    cSQL += "          AND   E1_NUM     = ZKC_NUM " + CRLF
    cSQL += "          AND   E1_PARCELA = ZKC_PARCEL " + CRLF
    cSQL += "          AND   E1_TIPO    = ZKC_TIPO " + CRLF
    cSQL += "            ) " + CRLF
    cSQL += "       JOIN    " + RetSqlName("SA1") + "  SA1 (NOLOCK) " + CRLF
    cSQL += "         ON ( " + CRLF
    cSQL += "                A1_FILIAL  = " + ValToSql(xFilial("SA1")) + CRLF
    cSQL += "          AND   A1_COD     = E1_CLIENTE " + CRLF
    cSQL += "          AND   A1_LOJA    = E1_LOJA " + CRLF
    cSQL += "            ) " + CRLF
    cSQL += "       WHERE  ZKC_FILIAL   = " + ValToSql(xFilial("ZKC")) + CRLF
    cSQL += "         AND  ZKC_STATUS   <> 'J' " + CRLF

    cSQL += "         AND  ( " + CRLF
	cSQL += "         			ZK8_STATUS   = 'B' " + CRLF
	cSQL += "         			OR NOT EXISTS " + CRLF
	cSQL += "         			( " + CRLF
	cSQL += "         				SELECT NULL " + CRLF
	cSQL += "         				FROM " + RetSqlName("ZKC") + " X (NOLOCK) " + CRLF
	cSQL += "         				WHERE X.ZKC_FILIAL  = ZKC.ZKC_FILIAL " + CRLF
	cSQL += "         				AND X.ZKC_NUMERO    = ZKC.ZKC_NUMERO " + CRLF
	cSQL += "         				AND X.ZKC_STATUS    = 'J' " + CRLF
	cSQL += "         				AND SE1.E1_SALDO    = 0 " + CRLF
	cSQL += "         				AND X.D_E_L_E_T_    = '' " + CRLF
	cSQL += "         			) " + CRLF
	cSQL += "         		 ) " + CRLF

    cSQL += "         AND  ZKC_NUMERO   BETWEEN " + ValToSQL(_cProcDe)  + " AND " + ValToSQL(_cProcAte)
    cSQL += "         AND  ZKC_VENCRE   BETWEEN " + ValToSQL(_dDatVDe)  + " AND " + ValToSQL(_dDatVAte)
    cSQL += "         AND  E1_CLIENTE   BETWEEN " + ValToSQL(_cCliDe)   + " AND " + ValToSQL(_cCliAte)
    cSQL += "         AND  A1_GRPVEN    BETWEEN " + ValToSQL(_cGrupoDe) + " AND " + ValToSQL(_cGrupoAte)
    
    cSQL += "         AND  ZKC.D_E_L_E_T_ = '' " + CRLF
    cSQL += "         AND  ZK8.D_E_L_E_T_ = '' " + CRLF
    cSQL += "         AND  SE1.D_E_L_E_T_ = '' " + CRLF
    cSQL += "         AND  SA1.D_E_L_E_T_ = ''), " + CRLF
    cSQL += "      tb " + CRLF
    cSQL += "   AS (SELECT *, " + CRLF
    cSQL += "              SEQ = ROW_NUMBER() OVER (PARTITION BY ZKC_NUMERO ORDER BY ZKC_NUMERO) " + CRLF
    cSQL += "       FROM   ta) " + CRLF
    cSQL += " SELECT   ZKC_FILIAL, " + CRLF
    cSQL += "          ZKC_NUMERO, " + CRLF
    cSQL += "          ZKC_VALOR = CASE " + CRLF
    cSQL += "                          WHEN SEQ = 1 THEN ZKC_VALOR " + CRLF
    cSQL += "                      ELSE '' END, " + CRLF
    cSQL += "          A1_COD, " + CRLF
    cSQL += "          A1_LOJA, " + CRLF
    cSQL += "          A1_NOME, " + CRLF
    cSQL += "          E1_PREFIXO, " + CRLF
    cSQL += "          E1_NUM, " + CRLF
    cSQL += "          E1_PARCELA, " + CRLF
    cSQL += "          E1_TIPO, " + CRLF
    cSQL += "          E1_VALOR, " + CRLF
    cSQL += "          ZKC_VENCTO, " + CRLF
    cSQL += "          ZKC_VENCCA, " + CRLF
    cSQL += "          SEQ
    cSQL += " FROM     tb
    cSQL += " ORDER BY ZKC_FILIAL,
    cSQL += "          ZKC_NUMERO;

    TcQuery cSQL New Alias (cQry)

    oSecMov:SetParentQuery()
    oSecMov:SetParentFilter({|cParam| (cQry)->ZKC_NUMERO >= cParam .And. (cQry)->ZKC_NUMERO <= cParam}, {|| (cQry)->ZKC_NUMERO})

    (cQry)->(DbGoTop())

    _cNum := (cQry)->ZKC_NUMERO

    While !(cQry)->(Eof())

        nTot := 0

        nTotJr := 0

        _cNum := (cQry)->ZKC_NUMERO

        oSecMov:Init()

        While !(cQry)->(Eof()) .And. (cQry)->ZKC_NUMERO == _cNum

            nTotJr += (cQry)->ZKC_VALOR

            nTot += (cQry)->E1_VALOR

            oSecMov:Cell("ZKC_FILIAL"	):SetValue((cQry)->ZKC_FILIAL   )
            oSecMov:Cell("ZKC_NUMERO"	):SetValue((cQry)->ZKC_NUMERO   )
            oSecMov:Cell("ZKC_VALOR"	):SetValue((cQry)->ZKC_VALOR    )
            oSecMov:Cell("A1_COD"   	):SetValue((cQry)->A1_COD       )
            oSecMov:Cell("A1_LOJA"   	):SetValue((cQry)->A1_LOJA      )
            oSecMov:Cell("A1_NOME"  	):SetValue((cQry)->A1_NOME      )
            oSecMov:Cell("E1_PREFIXO"	):SetValue((cQry)->E1_PREFIXO   )
            oSecMov:Cell("E1_NUM"   	):SetValue((cQry)->E1_NUM       )
            oSecMov:Cell("E1_PARCELA"	):SetValue((cQry)->E1_PARCELA   )
            oSecMov:Cell("E1_TIPO"  	):SetValue((cQry)->E1_TIPO      )
            oSecMov:Cell("E1_VALOR"	    ):SetValue((cQry)->E1_VALOR     )
            oSecMov:Cell("ZKC_VENCTO"	):SetValue(DTOC(STOD((cQry)->ZKC_VENCTO)))
            oSecMov:Cell("ZKC_VENCCA"	):SetValue(DTOC(STOD((cQry)->ZKC_VENCCA)))
            oSecMov:PrintLine()

            (cQry)->(DbSkip())

        EndDo

        oSecMov:Cell("ZKC_FILIAL"	):SetValue("")
        oSecMov:Cell("ZKC_NUMERO"	):SetValue("")
        oSecMov:Cell("ZKC_VALOR"	):SetValue(nTotJr)
        oSecMov:Cell("A1_COD"   	):SetValue("")
        oSecMov:Cell("A1_LOJA"   	):SetValue("")
        oSecMov:Cell("A1_NOME"  	):SetValue("")
        oSecMov:Cell("E1_PREFIXO"	):SetValue("")
        oSecMov:Cell("E1_NUM"   	):SetValue("")
        oSecMov:Cell("E1_PARCELA"	):SetValue("")
        oSecMov:Cell("E1_TIPO"  	):SetValue("")
        oSecMov:Cell("E1_VALOR"	    ):SetValue(nTot)
        oSecMov:Cell("ZKC_VENCTO"	):SetValue("")
        oSecMov:Cell("ZKC_VENCCA"	):SetValue("")
        oSecMov:PrintLine()

        oSecMov:Finish()

    EndDo

    (cQry)->(DbCloseArea())

Return()