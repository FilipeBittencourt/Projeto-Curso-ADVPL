#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FRREPROG()

    Local oReport
    Local aParam := {}
    Local cName := "FRREPROG"
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
    Private _cFiltro    := "1"

    aAdd(aParam, {1, "Proc. De", _cProcDe, "@!", ".T.", "ZK8", ".T.",50,.F.})
    aAdd(aParam, {1, "Proc. Ate", _cProcAte, "@!", ".T.", "ZK8", ".T.",50,.F.})

    aAdd(aParam, {1, "Vencimento De", _dDatVDe, "@D",".T.",,".T.",50,.F.})
    aAdd(aParam, {1, "Vencimento Ate", _dDatVAte, "@D",".T.",,".T.",50,.F.})
    
    aAdd(aParam, {1, "Cliente De", _cCliDe, "@!", ".T.", "SA1", ".T.",50,.F.})
    aAdd(aParam, {1, "Cliente Ate", _cCliAte, "@!", ".T.", "SA1", ".T.",50,.F.})

    aAdd(aParam, {1, "Grupo Cliente De", _cGrupoDe, "@!", ".T.", "ACY", ".T.",50,.F.})
    aAdd(aParam, {1, "Grupo Cliente Ate", _cGrupoAte, "@!", ".T.", "ACY", ".T.",50,.F.})
    aAdd(aParam, {2, "Status", _cFiltro, {"1=Todos", "2=Ativos", "3=Cancelados", "4=Baixados"}, 50, ".T.", .T.})	

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
        _cFiltro    := ParamLoad(cFileName,,9, "1")

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf


Return()

Static Function ReportDef()

    Local oReport
    Local oSecPrd
    Local oSecMov
    Local cQry := GetNextAlias()
    Local cTitRel := "Renegociação de Contas a Receber"

    oReport := TReport():New("FRREPROG", cTitRel, {|| }, {|oReport| PrintReport(oReport, cQry)}, cTitRel)

    oSecPrd := TRSection():New(oReport, "Cliente/Renegociação", cQry)
    TRCell():New(oSecPrd, "ZKC_NUMERO", cQry)
    TRCell():New(oSecPrd, "A1_COD", cQry)
    TRCell():New(oSecPrd, "A1_NOME", cQry)
    TRCell():New(oSecPrd, "A1_CGC", cQry)
    TRCell():New(oSecPrd, "JUROS", cQry, "Juros Total",,,,{|| (cQry)->JUROS })
    TRCell():New(oSecPrd, "VENC_JUROS", cQry, "Vencto do Juros",,,,{|| DTOC(STOD((cQry)->VENC_JUROS)) })

    oSecPrd:SetLineStyle(.T.)

    oSecMov := TRSection():New(oSecPrd, "Títulos", cQry)
    TRCell():New(oSecMov, "ZKC_PREFIX"  , cQry, "Serie",,5)
    TRCell():New(oSecMov, "ZKC_NUM"     , cQry, "Numero",,11)
    TRCell():New(oSecMov, "ZKC_PARCEL"  , cQry, "Parcela",,28)
    TRCell():New(oSecMov, "ZKC_VALOR"   , cQry,,,30,,{|| (cQry)->ZKC_VALOR })
    TRCell():New(oSecMov, "ZKC_VENCTO"   , cQry,,,15,,{|| DTOC(STOD((cQry)->ZKC_VENCTO)) })
    TRCell():New(oSecMov, "DIAS"        , cQry, "Dias Prorrog.",,4,,{|| (cQry)->DIAS }, "RIGHT",,"RIGHT")
    TRCell():New(oSecMov, "ZKC_VENCCA"   , cQry, "Novo Vencimento",,15,,{|| DTOC(STOD((cQry)->ZKC_VENCCA)) })

    //oBreak := TRBreak():New(oSecPrd, oSecPrd:Cell("ZKC_NUMERO"))//, "Totais")

    //oTot := TRFunction():New(oSecMov:Cell("ZKC_VALOR"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)
    //oTot:SetTotalInLine(.T.)

    //oBreak1 := TRBreak():New(::oSection1,{|| (cQry)->ZKC_NUMERO})
	
	//TRFunction():New(::oSection1:Cell("E2_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	
Return(oReport)

Static Function PrintReport(oReport, cQry)

    Local oSecPrd := oReport:Section(1)
    Local oSecMov := oReport:Section(1):Section(1)
    Local cSQL := ""

    Local cBanco := ""
    Local cAgencia := ""
    Local cConta := ""
    Local nTot := 0
    Local cStatus := ""

    cSQL := ""
    cSQL += " select "+CRLF

    cSQL += " A1_COD, "+CRLF
    cSQL += " A1_CGC, "+CRLF
    cSQL += " A1_NOME, "+CRLF
    cSQL += " ZK8_BANCO, "+CRLF
    cSQL += " ZK8_AGENCI, "+CRLF	
    cSQL += " ZK8_CONTA, "+CRLF
    cSQL += " ZKC_NUMERO, "+CRLF
    cSQL += " ZKC_PREFIX, "+CRLF
    cSQL += " ZKC_NUM, "+CRLF
    cSQL += " ZKC_PARCEL, "+CRLF
    cSQL += " ZKC_VALOR, "+CRLF
    cSQL += " ZK8_STATUS, "+CRLF
    cSQL += " ZKC_VENCTO, "+CRLF
    cSQL += " ZKC_STATUS, "+CRLF
    cSQL += " CAST(ZKC_DIAS AS VARCHAR) DIAS, "+CRLF
    cSQL += " ZKC_VENCCA, "+CRLF
    cSQL += " JUROS = (select sum(ZKC_VALOR) from "+RetSqlName("ZKC")+" X where X.ZKC_NUMERO = ZKC.ZKC_NUMERO and X.ZKC_TIPO = 'JP' and X.D_E_L_E_T_=''), "+CRLF
    cSQL += " VENC_JUROS = (select max(ZKC_VENCTO) from "+RetSqlName("ZKC")+" X where X.ZKC_NUMERO = ZKC.ZKC_NUMERO and X.ZKC_TIPO = 'JP' and X.D_E_L_E_T_='') "+CRLF
    cSQL += " from "+RetSqlName("ZKC")+" ZKC "+CRLF
    cSQL += " join "+RetSqlName("SA1")+" SA1 on A1_FILIAL  = " + ValToSql(xFIlial("SA1")) + " AND A1_COD = ZKC_CLIFOR and A1_LOJA = ZKC_LOJA "+CRLF
    cSQL += " join "+RetSqlName("ZK8")+" ZK8 on ZK8_FILIAL = " + ValToSql(xFIlial("ZK8")) + " AND ZK8_NUMERO = ZKC_NUMERO "+CRLF
    cSQL += " where ZKC_FILIAL = " + ValToSql(xFIlial("ZKC"))
    cSQL += " and ZKC_NUMERO    between '"+_cProcDe+"' and '"+_cProcAte+"' "+CRLF
    cSQL += " AND ZKC_TIPO <> 'JP' "+CRLF
    cSQL += " and SA1.A1_COD    between '"+_cCliDe+"' and '"+_cCliAte+"' "+CRLF
    cSQL += " AND SA1.A1_GRPVEN between '"+ _cGrupoDe +"' and '"+ _cGrupoAte +"' "+CRLF
    cSQL += " and ZKC_VENCTO between '"+DTOS(_dDatVDe)+"' and '"+DTOS(_dDatVAte)+"' "+CRLF

    If _cFiltro == "2" // Ativos

        cStatus := "A"
    
    ElseIf _cFiltro == "3" // Cancelados

        cStatus := "C"

    ElseIf _cFiltro == "4" // Baixados

        cStatus := "B"

    EndIf

    If !Empty(cStatus)

        cSQL += " AND ZK8_STATUS = " + ValToSql(cStatus) + CRLF
        
    EndIf
    
    cSQL += " and ZKC.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and SA1.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and ZK8.D_E_L_E_T_ = '' "+CRLF

    cSQL += " order by ZKC_NUMERO, ZKC_VENCCA "+CRLF

    TcQuery cSQL New Alias (cQry)

    oSecMov:SetParentQuery()
    oSecMov:SetParentFilter({|cParam| (cQry)->ZKC_NUMERO >= cParam .And. (cQry)->ZKC_NUMERO <= cParam}, {|| (cQry)->ZKC_NUMERO})

    //oSecPrd:Print()


    (cQry)->(DbGoTop())
    _cNum := (cQry)->ZKC_NUMERO
    _nJUROS := 0
    _dVENCJUR := dDataBase

    oSecPrd:Init()
    
    While !(cQry)->(Eof())

        oReport:SkipLine()  
        oReport:Say(oReport:Row() ,oReport:Col() , "" )
        oReport:SkipLine()  
        oReport:Say(oReport:Row() ,oReport:Col() , "Processo: "+ (cQry)->ZKC_NUMERO )
        oReport:SkipLine()
        oReport:Say(oReport:Row() ,oReport:Col() , "Cod.Cliente: "+(cQry)->A1_COD )
        oReport:SkipLine()
        oReport:Say(oReport:Row() ,oReport:Col() , "Nome Cliente: " +(cQry)->A1_NOME )
        oReport:SkipLine()
        oReport:Say(oReport:Row() ,oReport:Col() , "CNPJ: " +(cQry)->A1_CGC )

        If (cQry)->ZK8_STATUS == "A" .Or. ( (cQry)->ZKC_STATUS == "F" .And. (cQry)->ZK8_STATUS == "A" )

            oReport:SkipLine()
            
            oReport:Say(oReport:Row() ,oReport:Col() , "Situação: " + "Ativo" )
            oReport:SkipLine()
            oReport:SkipLine()

        ElseIf (cQry)->ZK8_STATUS == "C"

            oReport:SkipLine()
            
            oReport:Say(oReport:Row() ,oReport:Col() , "Situação: " + "Cancelado" )
            oReport:SkipLine()
            oReport:SkipLine()

        ElseIf (cQry)->ZK8_STATUS == "B"

            oReport:SkipLine()
            
            oReport:Say(oReport:Row() ,oReport:Col() , "Situação: " + "Baixado" )
            oReport:SkipLine()
            oReport:SkipLine()      

        Else

            oReport:SkipLine()
            oReport:SkipLine()
        
        EndIf

        nTot := 0

        _nJUROS := (cQry)->JUROS
        _dVENCJUR := (cQry)->VENC_JUROS

        _cNum := (cQry)->ZKC_NUMERO

        cBanco := (cQry)->ZK8_BANCO
        cAgencia := (cQry)->ZK8_AGENCI
        cConta := (cQry)->ZK8_CONTA

        oSecMov:Init()

        While !(cQry)->(Eof()) .And. (cQry)->ZKC_NUMERO == _cNum

            nTot += (cQry)->ZKC_VALOR

            oSecMov:Cell("ZKC_PREFIX"	):SetValue((cQry)->ZKC_PREFIX )
            oSecMov:Cell("ZKC_NUM"   	):SetValue((cQry)->ZKC_NUM    )
            oSecMov:Cell("ZKC_PARCEL"	):SetValue((cQry)->ZKC_PARCEL )
            oSecMov:Cell("ZKC_VALOR" 	):SetValue((cQry)->ZKC_VALOR  )
            oSecMov:Cell("ZKC_VENCTO"	):SetValue(DTOC(STOD((cQry)->ZKC_VENCTO )))
            oSecMov:Cell("DIAS"  	):SetValue((cQry)->DIAS   )
            oSecMov:Cell("ZKC_VENCCA"	):SetValue(DTOC(STOD((cQry)->ZKC_VENCCA )))
            oSecMov:PrintLine()

            (cQry)->(DbSkip())
            
        EndDo

        oSecMov:Cell("ZKC_PREFIX"	):SetValue("")
        oSecMov:Cell("ZKC_NUM"   	):SetValue("")
        oSecMov:Cell("ZKC_PARCEL"	):SetValue("")
        oSecMov:Cell("ZKC_VALOR" 	):SetValue(nTot)
        oSecMov:Cell("ZKC_VENCTO"	):SetValue("")
        oSecMov:Cell("DIAS"  	):SetValue("")
        oSecMov:Cell("ZKC_VENCCA"	):SetValue("")
        oSecMov:PrintLine()

        oSecMov:Finish()

        oReport:SkipLine()
        oReport:Say(oReport:Row() ,oReport:Col() , "Juros Total: "+ Transform(_nJUROS, "@E 999,999,999.99") )
        oReport:SkipLine()
        oReport:Say(oReport:Row() ,oReport:Col() , "Data Limite Pgto Juros: "+DTOC(STOD(_dVENCJUR)))
        oReport:SkipLine()

        //oReport:Say(oReport:Row() ,oReport:Col() , "Banco: "+ cBanco )
        //oReport:SkipLine()

        //oReport:Say(oReport:Row() ,oReport:Col() , "Agencia: "+ cAgencia )
        //oReport:SkipLine()

        //oReport:Say(oReport:Row() ,oReport:Col() , "Conta: "+ cConta )
        //oReport:SkipLine()

    EndDo

    oSecPrd:Finish()

    (cQry)->(DbCloseArea())

Return()