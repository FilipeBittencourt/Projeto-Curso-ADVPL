#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

/*/{Protheus.doc} BIA261
@author Marcos Alberto Soprani
@since 11/08/11
@version 1.0
@description Custo Padrão
.            Este Programa tem que estar em perfeita armonia com o BIA269
@type function
/*/

/*/{Protheus.doc} BIA261
@author Artur Antunes
@since 12/04/17
@version 1.1
@description Inclusão de regra para desconsiderar CFOP´s, contidos no parâmetro
@obs OS 4098-16
@type function
/*/

/*/{Protheus.doc} BIA261
@author Artur Antunes
@since 19/04/17
@version 1.2
@description Inclusão de controle de processamento via SX6 (MV_YULRAC)
@obs OS 2304-16
@type function
/*/
// U_BIA261

User Function BIA261()

    Processa({|| RptDetail()})

Return

Static Function RptDetail()

    LOcal i
    Private lNegEstr  := GETMV("MV_NEGESTR")
    Private aDadoX    := {}
    Private xSomaRet  := .F.
    Private xQtdRetn  := 0
    Private gtVlrRet  := .F.

    //  Usado para Filtro Aleatório
    Private oDlgCpad
    Private Confirmar
    Private oMultiGet1
    Private cMultiGet1 := ""
    Private oSay1
    Private fh_Esc     := .F.
    //*****************************

    Private cNoCfCust := AllTrim(GetNewPar("MV_YCUSCFN","1911,2911,1910,2910"))

    cNoCfCust := StrTran(cNoCfCust,"/",",")
    cNoCfCust := StrTran(cNoCfCust,"\",",")
    cNoCfCust := StrTran(cNoCfCust,"|",",")
    cNoCfCust := StrTran(cNoCfCust,";",",")

    cHInicio := Time()
    fPerg := "BIA261"
    fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
    ValidPerg()
    If !Pergunte(fPerg,.T.)
        Return
    EndIf

    if !U_BiaULRAC(dDataBase)
        Return
    endif

    // Tramento incluído para atender a OS effettivo 3716-15. Por Marcos Alberto Soprani em 22/12/2015
    agrpPAR04 := ""
    If !Empty(MV_PAR04)

        QR003 := " SELECT BM_GRUPO
        QR003 += "   FROM " + RetSqlName("SBM")
        QR003 += "  WHERE D_E_L_E_T_ = ' '
        QR003 += "    AND BM_MSBLQL <> '1'
        QR003 += "    AND BM_YAGRPCT IN "+FormatIn(MV_PAR04,",")
        QR003 += "  ORDER BY BM_GRUPO
        QRIndex := CriaTrab(Nil,.f.)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR003),'QR03',.T.,.T.)
        dbSelectArea("QR03")
        dbGoTop()
        While !Eof()
            agrpPAR04 += QR03->BM_GRUPO+","
            dbSelectArea("QR03")
            dbSkip()
        End
        QR03->(dbCloseArea())
        Ferase(QRIndex+GetDBExtension())     //arquivo de trabalho
        Ferase(QRIndex+OrdBagExt())          //indice gerado

    EndIf

    // Implementado em 30/10/12 por Marcos Alberto Soprani para atender a Montagem do Custo para BI
    // Em 28/08/14, implementada tratamento para o parametro 11 - por Marcos Alberto Soprani.
    If MV_PAR10 == 1
        If MV_PAR03 <> 1 .or. !Empty(agrpPAR04) .or. MV_PAR07 <> "PA" .or. MV_PAR09 == 1
            Help(" ",1,"BIA261:",, "Verifique os parâmetros 03, 04, 07 e 09, pois estão configurados de forma indevida.",1,0)
            Return
        Else
            mAyBI := {}
            AADD(mAyBI,{ "PRODUTO"    ,"C",15,0 } )
            AADD(mAyBI,{ "CUSTO"      ,"N",18,4 } )
            BI01 := CriaTrab(mAyBI)
            dbUseArea( .T.,, BI01, "BI01", .F., .F. )
            dbCreateInd(BI01, "PRODUTO" ,{ || Indices })
        EndIf
    EndIf

    // Em 28/08/14, implementada tratamento para o parametro 11 - por Marcos Alberto Soprani.
    If MV_PAR11 == 1
        If MV_PAR03 <> 2 .or. !Empty(agrpPAR04) .or. MV_PAR07 <> "PA"
            Help(" ",1,"BIA261:",, "Verifique os parâmetros 03, 04 e 07, pois estão configurados de forma indevida.",1,0)
            Return
        Else
            dbSelectarea("Z46")
            dbSetOrder(1)
            If dbSeek(xFilial("Z46")+dtos(dDataBase))
                UR004 := " UPDATE "+RetSqlName("Z46")+" SET D_E_L_E_T_ = '*'
                UR004 += "   FROM " + RetSqlName("Z46")
                UR004 += "  WHERE Z46_FILIAL = '"+xFilial("Z46")+"'
                UR004 += "    AND Z46_DATARF = '"+dtos(dDataBase)+"'
                UR004 += "    AND D_E_L_E_T_ = ' '
                U_BIAMsgRun("Aguarde... Preparando Base de Dados...",,{|| TcSQLExec(UR004)})
            EndIf
        EndIf
    EndIf

    fyFilAleat:= ""
    If MV_PAR13 == 1

        DEFINE MSDIALOG oDlgCpad TITLE "Filtro adicional para Custo Padrão" FROM 000, 000  TO 300, 550 COLORS 0, 16777215 PIXEL
        @ 024, 013 GET oMultiGet1 VAR cMultiGet1 OF oDlgCpad MULTILINE SIZE 246, 113 COLORS 0, 16777215 HSCROLL PIXEL
        @ 008, 223 BUTTON Confirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgCpad ACTION (fh_Esc := .T., oDlgCpad:End()) PIXEL
        @ 012, 013 SAY oSay1 PROMPT "Informe o código dos produtos que deseja filtrar separados por virgula:" SIZE 180, 007 OF oDlgCpad COLORS 0, 16777215 PIXEL
        ACTIVATE MSDIALOG oDlgCpad VALID fh_Esc

        fyFilAleat := cMultiGet1

    EndIf

    aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
    fCabec   := "CUSTO PADRÃO"
    fCabe02  := ""

    wnPag    := 0
    nRow1    := 0

    oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
    oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

    oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
    oPrint:SetPaperSize(09)
    oPrint:SetLandscape()
    oPrint:Setup()

    cTempo := Alltrim(ElapTime(cHInicio, Time()))
    IncProc("Armazenando....   Tempo: "+cTempo)

    aDados2 := {}

    // Temporário para Impressão de resumo final, quando relatório analítico
    xArry := {}
    AADD(xArry,{ "CCONTAB"    ,"C",20,0 } )
    AADD(xArry,{ "CUSTO"      ,"N",18,8 } )
    AADD(xArry,{ "PROJT"      ,"N",18,8 } )
    T001 := CriaTrab(xArry)
    dbUseArea( .T.,, T001, "T001", .F., .F. )
    dbCreateInd(T001, "CCONTAB" ,{ || Indices })

    // Temporário para evitar buscas sucessivas para um mesmo componente
    xAyCt := {}
    AADD(xAyCt,{ "CODCOMP"    ,"C",15,0 } )
    AADD(xAyCt,{ "CUSTO"      ,"N",18,8 } )
    AADD(xAyCt,{ "ULTCOM"     ,"D",08,0 } )
    AADD(xAyCt,{ "EMPR"       ,"C",02,0 } )
    AADD(xAyCt,{ "REFER"      ,"C",02,0 } )
    T002 := CriaTrab(xAyCt)
    dbUseArea( .T.,, T002, "T002", .F., .F. )
    dbCreateInd(T002, "CODCOMP" ,{ || Indices })

    // Monta referência para diluir o retorno da Massa na formulação da massa. Usado apenas para PI MASSA
    AK007 := " SELECT G1_COD, G1_TRT, SUM(G1_YMISTUR) PERC
    AK007 += "   FROM "+RetSqlName("SG1")+" SG1
    AK007 += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
    AK007 += "                      AND B1_COD = G1_COD
    AK007 += "                      AND B1_GRUPO = 'PI01'
    AK007 += "                      AND SB1.D_E_L_E_T_ = ' '
    AK007 += " INNER JOIN " + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL = '" + xFilial("SBZ") + "'
    AK007 += "                      AND BZ_COD = G1_COD
    AK007 += "                      AND SBZ.D_E_L_E_T_ = ' '
    AK007 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
    AK007 += "    AND G1_REVINI >= B1_REVATU
    AK007 += "    AND G1_REVFIM <= B1_REVATU
    AK007 += "    AND SG1.D_E_L_E_T_ = ' '
    AK007 += "  GROUP BY G1_COD, G1_TRT
    AK007 := ChangeQuery(AK007)
    cIndex := CriaTrab(Nil,.f.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,AK007),'AK07',.T.,.T.)
    aStruX := ("AK07")->(dbStruct())
    /*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
    gh_IndX := "G1_COD"
    If !chkfile("AK08")
        AK08 := U_BIACrTMP(aStruX)
        dbUseArea( .T.,, AK08, "AK08", .F., .F. )
        dbCreateInd(AK08, gh_IndX,{ || gh_IndX })
    EndIf
    dbSelectArea("AK08")
    APPEND FROM ("AK07")
    If Select("AK07") > 0
        AK07->(dbCloseArea())
    Endif

    // Filtra Produtos para montagem do relatório
    A0003 := " SELECT G1_COD, B1_QB, B1_DESC, B1_REVATU
    A0003 += "   FROM "+RetSqlName("SG1")+" SG1
    A0003 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
    A0003 += "                       AND B1_COD = G1_COD
    A0003 += "                       AND B1_TIPO = '"+MV_PAR07+"'
    A0003 += "                       AND B1_MSBLQL <> '1'
    // Implementado tratamento com a finalidade de atender ao orçamento. Data 02/09/15. Por Marcos Alberto Soprani
    If MV_PAR07 == "PA" .and. MV_PAR12 == 1
        A0003 += "                       AND B1_YCLASSE = '1'
    EndIf
    If MV_PAR07 $ "PA/PP"
        A0003 += "                       AND B1_YSTATUS IN('1')
        A0003 += "                       AND RIGHT(RTRIM(B1_COD),3) <> '000'
    EndIf
    If MV_PAR07 $ "PA/PP" .and. !Empty(MV_PAR14)
        A0003 += "    AND B1_YFORMAT IN "+FormatIn(Alltrim(MV_PAR14),",")
    EndIf
    A0003 += "                       AND SB1.D_E_L_E_T_ = ' '
    A0003 += "  INNER JOIN " + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL = '" + xFilial("SBZ") + "'
    A0003 += "                       AND BZ_COD = G1_COD
    A0003 += "                       AND SBZ.D_E_L_E_T_ = ' '
    A0003 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
    A0003 += "    AND G1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
    //A0003 += "    AND G1_COD BETWEEN 'VG0755V1' AND 'VL0757C1'
    If !Empty(fyFilAleat)
        A0003 += "    AND G1_COD IN "+FormatIn(fyFilAleat,",")
    EndIf
    A0003 += "    AND SG1.D_E_L_E_T_ = ' '
    A0003 += "  GROUP BY G1_COD, B1_QB, B1_DESC, B1_REVATU
    //A0003 := ChangeQuery(A0003)
    cIndex := CriaTrab(Nil,.f.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0003),'A003',.T.,.T.)
    aStru1 := ("A003")->(dbStruct())
    /*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
    gh_Ind := "G1_COD"
    If !chkfile("A004")
        A004 := U_BIACrTMP(aStru1)
        dbUseArea( .T.,, A004, "A004", .F., .F. )
        dbCreateInd(A004, gh_Ind,{ || gh_Ind })
    EndIf
    dbSelectArea("A004")
    APPEND FROM ("A003")
    If Select("A003") > 0
        A003->(dbCloseArea())
    Endif
    dbGotop()
    wk_RefVl := ""
    While !Eof()

        gtVlrRet  := .F.
        cTempo := Alltrim(ElapTime(cHInicio, Time()))
        IncProc("Proc.... "+A004->G1_COD+"   Tempo: "+cTempo)

        dbSelectArea("SB1")
        dbSeek(xFilial("SB1")+A004->G1_COD)

        nEstru     := 0
        wProduto   := A004->G1_COD
        wQtd       := IIF(A004->B1_QB == 0, 1, A004->B1_QB)
        wpRevAtu   := A004->B1_REVATU
        wpNiv      := 1
        cArqTmp    := ""
        cAliasTRB  := cArqTRB := "Estrut"

        xQtdRetn   := 0

        cNome      := Processa({|| StrutBia(wProduto, wQtd, cAliasTRB, cArqTRB, .F., wpRevAtu, wpNiv) })
        cArqTRB    := cArqTmp
        ESTRUT->(dbGoTop())
        ProcRegua(RecCount())
        While ESTRUT->(!Eof())

            cTempo := Alltrim(ElapTime(cHInicio, Time()))
            IncProc("Componente: "+ESTRUT->COMP+"  Tempo: "+cTempo)

            xk_UltCom := ctod("  /  /  ")
            wk_RefVl  := ""
            xk_EmpOri := Space(2)

            dbSelectArea("T002")
            If !dbSeek(ESTRUT->COMP)
                SBZ->(dbSetOrder(1))
                SBZ->(dbSeek(xFilial("SBZ")+ESTRUT->COMP))
                // A regra a seguir se fez necessária em virtude da inclusão do custo do Produto Retificado nesta rotina. Possivelmente, no futuro (qualquer coisa após a data de 23/11/11)
                // poderemos mudar esta configuração, colocando algum produto na estrutura do Produto Acabado Retificado.
                cs_VdRetif := .F.
                If Posicione("SB1", 1, xFilial("SB1")+ ESTRUT->COMP,"B1_TIPO") == "PA" .and. cEmpAnt <> "14"
                    SBZ->(dbSetOrder(1))
                    SBZ->(dbSeek(xFilial("SBZ")+wProduto))
                    cs_VdRetif := .T.
                EndIf
                xk_Custo := 0
                If SBZ->BZ_YCTREF == 0
                    A0001 := " SELECT ISNULL((SELECT SUM(SD1.D1_CUSTO) / SUM(SD1.D1_QUANT)
                    A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
                    A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
                    A0001 += "                                      AND F4_CODIGO = D1_TES
                    A0001 += "                                      AND F4_ESTOQUE = 'S'
                    A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
                    A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
                    A0001 += "                                      AND F1_DOC = D1_DOC
                    A0001 += "                                      AND F1_SERIE = D1_SERIE
                    A0001 += "                                      AND F1_FORNECE = D1_FORNECE
                    A0001 += "                                      AND F1_LOJA = D1_LOJA
                    A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
                    A0001 += "                                      AND F1_STATUS <> 'B'
                    A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
                    A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
                    A0001 += "                   AND SD1.D1_COD = '"+ESTRUT->COMP+"'
                    A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
                    A0001 += "                   AND SD1.D1_TP <> 'PI'
                    A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
                    A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
                    A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
                    A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
                    A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
                    A0001 += "                                                               AND F4_CODIGO = D1_TES
                    A0001 += "                                                               AND F4_ESTOQUE = 'S'
                    A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
                    A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
                    A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
                    A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
                    A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE
                    A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
                    A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
                    A0001 += "                                                               AND F1_STATUS <> 'B'
                    A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
                    A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
                    A0001 += "                                            AND XD1.D1_COD = '"+ESTRUT->COMP+"'
                    A0001 += "                                            AND XD1.D1_TP <> 'PI'
                    A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
                    A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
                    A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
                    A0001 += "                                            AND XD1.D1_TIPO = 'N'
                    A0001 += "                                            AND XD1.D1_QUANT <> 0
                    A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
                    A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) EMP_ATU,
                    A0001 += "         ISNULL((SELECT MAX(XD1.D1_DTDIGIT)
                    A0001 += "                   FROM "+RetSqlName("SD1")+" XD1
                    A0001 += "                  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
                    A0001 += "                                       AND F4_CODIGO = D1_TES
                    A0001 += "                                       AND F4_ESTOQUE = 'S'
                    A0001 += "                                       AND SF4.D_E_L_E_T_ = ' '
                    A0001 += "                  INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
                    A0001 += "                                       AND F1_DOC = XD1.D1_DOC
                    A0001 += "                                       AND F1_SERIE = XD1.D1_SERIE
                    A0001 += "                                       AND F1_FORNECE = XD1.D1_FORNECE
                    A0001 += "                                       AND F1_LOJA = XD1.D1_LOJA
                    A0001 += "                                       AND F1_EMISSAO = XD1.D1_EMISSAO
                    A0001 += "                                       AND F1_STATUS <> 'B'
                    A0001 += "                                       AND SF1.D_E_L_E_T_ = ' '
                    A0001 += "                  WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
                    A0001 += "                    AND XD1.D1_COD = '"+ESTRUT->COMP+"'
                    A0001 += "                    AND XD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
                    A0001 += "                    AND XD1.D1_TP <> 'PI'
                    A0001 += "                    AND XD1.D1_TES NOT IN('3I7')
                    A0001 += "                    AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
                    A0001 += "                    AND XD1.D1_TIPO = 'N'
                    A0001 += "                    AND XD1.D1_QUANT <> 0
                    A0001 += "                    AND XD1.D_E_L_E_T_ = ' '), '        ') DT_E_ATU
                    TcQuery A0001 ALIAS "A001" NEW
                    dbSelectArea("A001")
                    dbGoTop()
                    xk_Custo  := A001->EMP_ATU
                    xk_UltCom := stod(A001->DT_E_ATU)
                    wk_RefVl  := "NF"
                    xk_EmpOri := cEmpAnt
                    A001->(dbCloseArea())
                Else
                    If SBZ->BZ_COD < "A"
                        xk_Custo   := SBZ->BZ_YCTREF
                        wk_RefVl   := "I "
                        xk_UltCom  := SBZ->BZ_YDTCTRF
                        xk_EmpOri  := cEmpAnt
                    Else
                        If Posicione("SB1", 1, xFilial("SB1")+wProduto,"B1_YACABAM") $ "002/004/007" .and. Posicione("SB1", 1, xFilial("SB1")+ESTRUT->COMP,"B1_TIPO") == "PA" .AND. 1 == 2 // retirado em 11/09/15 Por Marcos Alberto.
                            xk_Custo   := SBZ->BZ_YCTREF
                            wk_RefVl   := "R "
                            xk_UltCom  := SBZ->BZ_YDTCTRF
                            xk_EmpOri  := cEmpAnt
                            If xk_Custo <> 0
                                gtVlrRet    := .T.
                            EndIf
                        EndIf
                        If cEmpAnt == "14"
                            xk_Custo   := SBZ->BZ_YCTREF
                            wk_RefVl   := "I "
                            xk_UltCom  := SBZ->BZ_YDTCTRF
                            xk_EmpOri  := cEmpAnt
                        EndIf
                    EndIf
                EndIf
                // Acumula dados para não precisar ficar executando querys sucessivas para o mesmo componente.
                If !cs_VdRetif
                    dbSelectArea("T002")
                    RecLock("T002",.T.)
                    T002->CODCOMP := ESTRUT->COMP
                    T002->CUSTO   := xk_Custo
                    T002->ULTCOM  := xk_UltCom
                    T002->EMPR    := xk_EmpOri
                    T002->REFER   := wk_RefVl
                    MsUnLock()
                EndIf
            Else
                xk_Custo   := T002->CUSTO
                xk_UltCom  := T002->ULTCOM
                xk_EmpOri  := T002->EMPR
                wk_RefVl   := T002->REFER
            EndIf

            // Controle de Projeção de Custo
            xf_Projetd := xk_Custo
            Z04->(dbSetOrder(1))
            If Z04->(dbSeek(xFilial("Z04") + ESTRUT->COMP))

                xf_QuantRf  := 0
                xf_CtVlrRf  := 0
                xf_CtFrtRf  := 0
                //   As regras que seguem abaixo se fazem necessárias porque a QUERY principal do programa traz
                //o valor do frete aglutinado ao valor da mercadoria.
                //   Neste ponto do programa, estas duas informações necessitam ser separadas.
                PX001 := " SELECT SD1.D1_QUANT, SD1.D1_CUSTO
                PX001 += "   FROM "+RetSqlName("SD1")+" SD1
                PX001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
                PX001 += "                       AND F4_CODIGO = D1_TES
                PX001 += "                       AND F4_ESTOQUE = 'S'
                PX001 += "                       AND SF4.D_E_L_E_T_ = ' '
                PX001 += "  INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
                PX001 += "                      AND F1_DOC = D1_DOC
                PX001 += "                      AND F1_SERIE = D1_SERIE
                PX001 += "                      AND F1_FORNECE = D1_FORNECE
                PX001 += "                      AND F1_LOJA = D1_LOJA
                PX001 += "                      AND F1_EMISSAO = D1_EMISSAO
                PX001 += "                      AND F1_STATUS <> 'B'
                PX001 += "                      AND SF1.D_E_L_E_T_ = ' '
                PX001 += "  WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
                PX001 += "    AND SD1.D1_COD = '"+ESTRUT->COMP+"'
                PX001 += "    AND SD1.D1_TP <> 'PI'
                PX001 += "    AND SD1.D1_TES NOT IN('397','3I7')
                PX001 += "    AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
                PX001 += "    AND SD1.D1_DTDIGIT = '"+dtos(xk_UltCom)+"'
                PX001 += "    AND SD1.D_E_L_E_T_ = ' '
                PX001 += "  ORDER BY D1_QUANT DESC
                TcQuery PX001 ALIAS "PX01" NEW
                dbSelectArea("PX01")
                dbGoTop()
                While !Eof()
                    If PX01->D1_QUANT > 0
                        xf_QuantRf  += PX01->D1_QUANT
                        xf_CtVlrRf  += PX01->D1_CUSTO
                    Else
                        xf_CtFrtRf  += PX01->D1_CUSTO
                    EndIf
                    dbSelectArea("PX01")
                    dbSkip()
                End
                PX01->(dbCloseArea())

                // Monta o Custo unitário do Valor da Mercadoria e do Frete
                xf_CtPrjtVl := 0
                xf_CtPrjtFr := 0
                If xf_QuantRf > 0
                    xf_CtPrjtVl := xf_CtVlrRf / xf_QuantRf
                    xf_CtPrjtFr := xf_CtFrtRf / xf_QuantRf
                EndIf
                If Z04->Z04_INCIVL == "1"   // Percentual
                    xf_CtPrjtVl := xf_CtPrjtVl + (xf_CtPrjtVl*Z04->Z04_VALOR/100)
                ElseIf Z04->Z04_INCIVL == "2"   // Valor
                    xf_CtPrjtVl := Z04->Z04_VALOR
                EndIf
                If Z04->Z04_INCIFR == "1"   // Percentual
                    xf_CtPrjtFr := xf_CtPrjtFr + (xf_CtPrjtFr*Z04->Z04_FRETE/100)
                ElseIf Z04->Z04_INCIFR == "2"   // Valor
                    xf_CtPrjtFr := Z04->Z04_FRETE
                EndIf
                xf_Projetd := xf_CtPrjtVl + xf_CtPrjtFr

            EndIf

            // Necessidade de posicionar no componente para buscar a UMIDADE PADRÃO.
            SBZ->(dbSetOrder(1))
            SBZ->(dbSeek(xFilial("SBZ")+ESTRUT->COMP))

            // Tratamento feito em 27/06/14 para não duplica o custo de produtos que podem ser feitos pela Biancogres e Vitcer concomitantemente...
            If ( Substr(ESTRUT->CODIGO,1,3) $ "RET/ETA" .or. Substr(ESTRUT->COMP,1,3) $ "RET/ETA" ) .and. gtVlrRet
                ESTRUT->(dbSkip())
                Loop
            EndIf

            Aadd(aDados2, { ESTRUT->PRODPAI    ,;
                ESTRUT->ORDEM                      ,;
                ESTRUT->CODIGO                     ,;
                ESTRUT->COMP                       ,;
                ESTRUT->TRT                        ,;
                ESTRUT->QUANT                      ,;
                ESTRUT->QTDORI                     ,;
                ESTRUT->NIVEL                      ,;
                xk_Custo                           ,;
                xk_UltCom                          ,;
                xk_EmpOri                          ,;
                xf_Projetd                         ,;
                wk_RefVl                           ,;
                fCalcUmid()                        })

            ESTRUT->(dbSkip())
        End
        U_BIAFimStru(cAliasTRB,cArqTRB)

        dbSelectArea("A004")
        dbSkip()
    End
    A004->(dbCloseArea())
    T002->(dbCloseArea())

    // ----------------------- Impressão --------------------------------------
    cTempo := Alltrim(ElapTime(cHInicio, Time()))
    IncProc("Imprimindo....   Tempo: "+cTempo)

    gpCustZero := .F.

    If MV_PAR05 == 1

        // Relatório Analítico
        xCamp := {}
        AADD(xCamp,{ "PROPAI"     ,"C",15,0 } )
        AADD(xCamp,{ "NIVEL"      ,"C",03,0 } )
        AADD(xCamp,{ "SG1COD"     ,"C",15,0 } )
        AADD(xCamp,{ "COMP"       ,"C",15,0 } )
        AADD(xCamp,{ "DESCR"      ,"C",70,0 } )
        AADD(xCamp,{ "REVISA"     ,"C",03,0 } )
        AADD(xCamp,{ "UM"         ,"C",02,0 } )
        AADD(xCamp,{ "SEQUEN"     ,"C",03,0 } )
        AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
        AADD(xCamp,{ "CUNIT"      ,"N",14,4 } )
        AADD(xCamp,{ "CTOTAL"     ,"N",14,4 } )
        AADD(xCamp,{ "RF"         ,"C",02,0 } )
        AADD(xCamp,{ "DTCTO"      ,"C",08,0 } )
        AADD(xCamp,{ "EMPR"       ,"C",02,0 } )
        AADD(xCamp,{ "PROJET"     ,"N",14,4 } )
        AADD(xCamp,{ "PERCT"      ,"N",08,2 } )
        AADD(xCamp,{ "UMIDAD"     ,"N",08,2 } )
        AADD(xCamp,{ "KEY"        ,"C",20,0 } )
        AADD(xCamp,{ "DESCRC"     ,"C",50,0 } )
        AADD(xCamp,{ "ITCUS"      ,"C",03,0 } )

        ql_ProdPai := Space(15)
        ql_PrdRefR := Space(15)
        ql_TotCPai := 0
        ql_ToPrPai := 0
        ql_SeqGrv  := 0
        aDados2 := Asort(aDados2,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
        For i := 1 to Len(aDados2)

            // Salto de Pagina e Totalizadores de um produto para outro
            If ql_ProdPai <> aDados2[i][1]
                If !Empty(ql_ProdPai)
                    fImpTotais()
                    ql_TotCPai := 0
                    ql_ToPrPai := 0
                    ql_SeqGrv  := 0
                EndIf
                ql_ProdPai := aDados2[i][1]
                ql_PrdRefR := Space(15)
                fImpCabec()
            EndIf
            // Reinializa páginas
            If nRow1 > 2250
                fImpRoda()
                fImpCabec()
            EndIf

            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+aDados2[i][3]))
            ql_GrpCod := Alltrim(SB1->B1_GRUPO)
            If SB1->B1_TIPO == "PA" .and. Empty(ql_PrdRefR) .and. Alltrim(aDados2[i][3]) <> Alltrim(wProduto)
                ql_PrdRefR := aDados2[i][3]
            EndIf
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+aDados2[i][4]))
            SBZ->(dbSetOrder(1))
            SBZ->(dbSeek(xFilial("SBZ") + aDados2[i][4]))
            If ql_GrpCod $ Alltrim(agrpPAR04) .or. Alltrim(SB1->B1_GRUPO) $ Alltrim(agrpPAR04) .or. Empty(agrpPAR04)

                // Calcula percetual da Projeção
                ql_Quant := aDados2[i][6]
                ql_Perct := 0

                // Novo tratamento para adicional de umidade
                If aDados2[i][14] <> 0
                    ql_Quant := ql_Quant/(-(((aDados2[i][14]/100)/1)-1))
                EndIf

                // Tratamento incluído em 03/05/16, por Marcos Alberto Soprani, para atender a OS effettivo 1532-16
                If UPPER(Alltrim(FunName())) == "BIA518" .and. Alltrim(SB1->B1_YCTRIND) == "61103001" .and. dtos(dDataBase) <= "20161231"
                    lyVlrRef := 1.0322898795 // Valor referência extraído do orçamento (tabela - Z46) de 11/10/15 para ORCA_16
                    If aDados2[i][9] < lyVlrRef
                        aDados2[i][9] := lyVlrRef
                    EndIf
                EndIf

                If (ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9]) <> 0
                    If aDados2[i][9] == 0
                        ql_Perct := 100
                    Else
                        ql_Perct := ((ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9])) / (ql_Quant*aDados2[i][9]) * 100
                    EndIf
                EndIf


                If !SB1->B1_TIPO $ "PI/PP/PA" .and. aDados2[i][9] == 0 .and. !Alltrim(aDados2[i][4]) $ "1020700/1010170/1010173/1010235/1010268/1010334/1024245" .and. !(SB1->B1_TIPO == "MP" .and. cEmpAnt == "06")

                    Aviso('CUSTO ZERADO', "Atenção! O componente: " + Alltrim(aDados2[i][4]) + " não possui custo unitário. Isto irá prejudicar o cálculo custo padrão do produto " + Alltrim(aDados2[i][1]) + " . Favor verificar antes de de proceguir",{'Ok'})
                    gpCustZero := .T.

                EndIf

                // Incluída tratativa para atender OS effettivo 3428-16
                If SB1->B1_MSBLQL == "1"

                    Aviso('Produto Bloqueado', "Atenção! O componente: " + Alltrim(aDados2[i][4]) + " está bloqueado. Isto irá prejudicar o cálculo custo padrão do produto " + Alltrim(aDados2[i][1]) + " . Favor verificar antes de de proceguir",{'Ok'})
                    gpCustZero := .T.

                EndIf

                //--------------------- Reservado para Impressão ----------------------
                xf_RefCt := aDados2[i][13]
                xf_Item := +;
                    Padr(Space(aDados2[i][8]*5) + aDados2[i][4] + Alltrim(SB1->B1_DESC)             ,075)+" "+;
                    Padc(IIF(SB1->B1_TIPO == "PI", SB1->B1_REVATU, "   ")                           ,006)+" "+;
                    Padr(SB1->B1_UM                                                                 ,002)+" "+;
                    Padc(aDados2[i][5]                                                              ,003)+" "+;
                    Padl(Transform(ql_Quant, "@E 999,999.99999999")                                 ,017)+" "+;
                    Padl(Transform(aDados2[i][9], "@E 9,999,999.9999")                              ,014)+" "+;
                    Padl(Transform(ql_Quant * aDados2[i][9], "@E 9,999,999.9999")                   ,014)+" "+;
                    Padl(xf_RefCt                                                                   ,002)+" "+;
                    Padl(dtoc(aDados2[i][10])                                                       ,008)+" "+;
                    Padl(aDados2[i][11]                                                             ,002)+" "+;
                    Padl(Transform(ql_Quant * aDados2[i][12] , "@E 99999.9999")                     ,010)+" "+;
                    Padl(Transform(ql_Perct                , "@E 99999.99")                         ,008)+" "+;
                    Padl(Transform(aDados2[i][14]          , "@E 99999.99")                         ,008)
                oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont8)
                If aDados2[i][3] == ql_ProdPai
                    oPrint:Line (nRow1-15, 100, nRow1-15, 3350)
                EndIf
                nRow1 += 050
                //---------------------------------------------------------------------

                // KEY para amarração entre o padrão e o realizado
                xdContaC := ""
                xdDescrC := ""
                xdItCus  := ""
                If 1 == 2

                    CT1->(dbSetOrder(1))
                    If CT1->(dbSeek(xFilial("CT1")+SB1->B1_YCTRIND))
                        xdContaC := Substr(CT1->CT1_YAGRUP,1,20)
                        xdItCus  := CT1->CT1_YITCUS
                        If CT1->(dbSeek(xFilial("CT1")+xdContaC))
                            xdDescrC := CT1->CT1_DESC01
                        EndIf
                    EndIf
                    If Alltrim(aDados2[i][4]) == "1030019"
                        xdContaC := "MODRCOG"
                        xdDescrC := "COGERACAO"
                        xdItCus  := "055"
                    EndIf
                    If Alltrim(aDados2[i][13]) == "R"
                        xdContaC := "RETIFICADO"
                        xdDescrC := "SERVICO DE RETIFICACAO"
                        xdItCus  := "999"
                    EndIf

                Else

                    CT1->(dbSetOrder(1))
                    If CT1->(dbSeek(xFilial("CT1")+SB1->B1_YCTRIND))
                        xdContaC := SB1->B1_YCTRIND
                        xdItCus  := CT1->CT1_YITCUS
                        xdDescrC := CT1->CT1_DESC01
                    Else
                        If SB1->B1_TIPO == "PA"
                            xdContaC := "61111003"
                            xdItCus  := "063"
                            xdDescrC := "PLACAS CONSUMIDAS NO CORTE"
                        EndIf
                    EndIf

                EndIf

                //------------------- Reservado para Exportação -----------------------
                Aadd(aDadoX, { aDados2[i][1]                                     ,;
                    Alltrim(Str(aDados2[i][8]))                                      ,;
                    aDados2[i][3]                                                    ,;
                    aDados2[i][4]                                                    ,;
                    Alltrim(SB1->B1_DESC)                                            ,;
                    IIF(SB1->B1_TIPO == "PI", SB1->B1_REVATU, "   ")                ,;
                    SB1->B1_UM                                                       ,;
                    aDados2[i][5]                                                    ,;
                    Transform(ql_Quant,                     "@E 999,999.99999999")   ,;
                    Transform(aDados2[i][9],                "@E 9,999,999.9999")     ,;
                    Transform(ql_Quant * aDados2[i][9],     "@E 9,999,999.9999")     ,;
                    xf_RefCt                                                         ,;
                    dtoc(aDados2[i][10])                                             ,;
                    aDados2[i][11]                                                   ,;
                    Transform(ql_Quant * aDados2[i][12],   "@E 9,999,999.9999")      ,;
                    Transform(ql_Perct,                    "@E 99999.99")            ,;
                    Transform(aDados2[i][14],              "@E 99999.99")            ,;
                    xdContaC                                                         ,;
                    xdDescrC                                                         ,;
                    xdItCus                                                          })
                //--------------------------------------------------------------------

                //--------------------- Reservado para Resumo ------------------------
                If SB1->B1_TIPO <> "PI" .or. aDados2[i][9] <> 0
                    dbSelectArea("T001")
                    //If !dbSeek(Substr(SB1->B1_YCTRIND,1,5))
                    If !dbSeek(SB1->B1_YCTRIND)
                        RecLock("T001",.T.)
                        //T001->CCONTAB := Substr(SB1->B1_YCTRIND,1,5)
                        T001->CCONTAB := SB1->B1_YCTRIND
                    Else
                        RecLock("T001",.F.)
                    EndIf
                    T001->CUSTO += ql_Quant * aDados2[i][9]
                    T001->PROJT += ql_Quant * aDados2[i][12]
                    MsUnLock()
                    ql_TotCPai += ql_Quant * aDados2[i][9]
                    ql_ToPrPai += ql_Quant * aDados2[i][12]
                EndIf
                //--------------------------------------------------------------------

                //-------------- Reservado para Fotografia da estrutura --------------
                If MV_PAR11 == 1
                    ql_SeqGrv  ++
                    dbSelectArea("Z46")
                    dbSetOrder(1)
                    RecLock("Z46",.T.)
                    Z46->Z46_FILIAL := xFilial("Z46")
                    Z46->Z46_DATARF := dDataBase
                    Z46->Z46_SEQGRV := StrZero(ql_SeqGrv,4)
                    Z46->Z46_COD    := aDados2[i][1]
                    Z46->Z46_SG1COD := aDados2[i][3]
                    Z46->Z46_COMP   := aDados2[i][4]
                    Z46->Z46_NIVEL  := Alltrim(Str(aDados2[i][8]))
                    Z46->Z46_REVATU := IIF(SB1->B1_TIPO == "PI", SB1->B1_REVATU, "   ")
                    Z46->Z46_TRT    := aDados2[i][5]
                    Z46->Z46_QUANT  := ql_Quant
                    Z46->Z46_CUNIT  := aDados2[i][9]
                    Z46->Z46_CTOTAL := ql_Quant * aDados2[i][9]
                    Z46->Z46_RF     := xf_RefCt
                    Z46->Z46_DTCSTO := aDados2[i][10]
                    Z46->Z46_EMPR   := aDados2[i][11]
                    Z46->Z46_PROJET := ql_Quant * aDados2[i][12]
                    Z46->Z46_PERCT  := ql_Perct
                    Z46->Z46_UMIDAD := aDados2[i][14]
                    Z46->Z46_CONTA  := IIF(SB1->B1_TIPO == "PA", "61111003", SB1->B1_YCTRIND)
                    Z46->Z46_ITCUS  := IIF(SB1->B1_TIPO == "PA", "063", xdItCus)
                    MsUnLock()
                EndIf
                //--------------------------------------------------------------------

                If gpCustZero
                    Exit
                EndIf

            EndIf

        Next i

        //-------------- Reservado para gravação recursivo do custo ----------
        If MV_PAR11 == 1

            UP043 := " UPDATE " + RetSqlName("Z46") + " SET Z46_SG1SEQ = "
            UP043 += "        ISNULL((SELECT XZ46.Z46_TRT "
            UP043 += "                  FROM " + RetSqlName("Z46") + " XZ46 "
            UP043 += "                 WHERE XZ46.Z46_FILIAL = '" + xFilial("Z46") + "' "
            UP043 += "                   AND XZ46.Z46_COD = Z46.Z46_COD "
            UP043 += "                   AND XZ46.Z46_DATARF = Z46.Z46_DATARF "
            UP043 += "                   AND XZ46.Z46_COMP = Z46.Z46_SG1COD "
            UP043 += "                   AND XZ46.R_E_C_N_O_ = (SELECT MAX(XZ46.R_E_C_N_O_) "
            UP043 += "                                             FROM " + RetSqlName("Z46") + " XZ46 "
            UP043 += "                                            WHERE XZ46.Z46_FILIAL = '" + xFilial("Z46") + "' "
            UP043 += "                                              AND XZ46.Z46_COD = Z46.Z46_COD "
            UP043 += "                                              AND XZ46.Z46_DATARF = Z46.Z46_DATARF "
            UP043 += "                                              AND XZ46.Z46_COMP = Z46.Z46_SG1COD "
            UP043 += "                                              AND XZ46.R_E_C_N_O_ < Z46.R_E_C_N_O_ "
            UP043 += "                                              AND XZ46.D_E_L_E_T_ = ' ') "
            UP043 += "                   AND XZ46.D_E_L_E_T_ = ' '), '' ) "
            UP043 += "   FROM " + RetSqlName("Z46") + " Z46 "
            UP043 += "  WHERE Z46_FILIAL = '" + xFilial("Z46") + "' "
            UP043 += "    AND Z46_DATARF = '" + dtos(dDataBase) + "' "
            UP043 += "    AND Z46.D_E_L_E_T_ = ' ' "
            U_BIAMsgRun("Aguarde... Atualizando TRT para SG1SEQ...",,{|| TcSQLExec(UP043)})

            xfAnoRef := Substr(dtos(stod(Substr(dtos(dDataBase),1,6)+"01") - 1), 1, 4)
            nivCorre := 8
            nivAcima := nivCorre + 1
            While nivCorre <> 0

                nivCorre -= 1
                nivAcima := nivCorre + 1

                XL003 := " WITH NIVELAMENTO AS (SELECT Z46_COD PRODPAI, "
                XL003 += "                             Z46_SG1COD PRODFIL, "
                XL003 += "                             Z46_SG1SEQ SG1SEQ, "
                XL003 += "                             SUM(Z46_CTOTAL) + SUM(Z46_CUSTAC) CTOTAL "
                XL003 += "                        FROM " + RetSqlName("Z46") + " Z46 "
                XL003 += "                       WHERE Z46_FILIAL = '" + xFilial("Z46") + "' "
                XL003 += "                         AND Z46_DATARF = '" + dtos(dDataBase) + "' "
                XL003 += "                         AND Z46_NIVEL = " + Alltrim(Str(nivAcima)) + " "
                XL003 += "                         AND Z46.D_E_L_E_T_ = ' ' "
                XL003 += "                       GROUP BY Z46_COD, "
                XL003 += "                                Z46_SG1COD,
                XL003 += "                                Z46_SG1SEQ) "
                XL003 += " UPDATE " + RetSqlName("Z46") + " SET Z46_CUSTAC = CTOTAL, Z46_ANOREF = '" + xfAnoRef + "' "
                XL003 += "   FROM " + RetSqlName("Z46") + " Z46 "
                XL003 += "  INNER JOIN NIVELAMENTO NIV ON PRODPAI = Z46_COD "
                XL003 += "                            AND PRODFIL = Z46_COMP "
                XL003 += "                            AND SG1SEQ = Z46_TRT
                XL003 += "  WHERE Z46_FILIAL = '" + xFilial("Z46") + "' "
                XL003 += "    AND Z46_DATARF = '" + dtos(dDataBase) + "' "
                XL003 += "    AND Z46_NIVEL = " + Alltrim(Str(nivCorre)) + " "
                XL003 += "    AND Z46.D_E_L_E_T_ = ' '  "
                U_BIAMsgRun("Aguarde... Atualizando custo por nível...",,{|| TcSQLExec(XL003)})

            End

            UP005 := " UPDATE " + RetSqlName("Z46") + " SET Z46_ANOREF = '" + xfAnoRef + "' "
            UP005 += "   FROM " + RetSqlName("Z46") + " Z46 "
            UP005 += "  INNER JOIN " + RetSqlName("SB1") + " XB1 ON XB1.B1_FILIAL = '" + xFilial("SB1") + "' "
            UP005 += "                       AND XB1.B1_COD = Z46_COMP "
            UP005 += "                       AND XB1.B1_GRUPO = '102I' "
            UP005 += "                       AND XB1.D_E_L_E_T_ = ' ' "
            UP005 += "  WHERE Z46_FILIAL = '" + xFilial("Z46") + "' "
            UP005 += "    AND Z46_DATARF = '" + dtos(dDataBase) + "' "
            UP005 += "    AND Z46_ANOREF = '    ' "
            UP005 += "    AND Z46.D_E_L_E_T_ = ' ' "
            U_BIAMsgRun("Aguarde... Atualizando custo de tinta digital...",,{|| TcSQLExec(UP005)})

        EndIf

        fImpTotais()

    Else

        // Relatório Sintético
        xCamp := {}
        AADD(xCamp,{ "PROPAI"     ,"C",15,0 } )
        AADD(xCamp,{ "DESCR"      ,"C",70,0 } )
        AADD(xCamp,{ "REVISA"     ,"C",03,0 } )
        AADD(xCamp,{ "UM"         ,"C",02,0 } )
        AADD(xCamp,{ "ULTCOM"     ,"N",14,4 } )
        AADD(xCamp,{ "PROJET"     ,"N",14,4 } )
        AADD(xCamp,{ "PERCT"      ,"N",08,2 } )
        AADD(xCamp,{ "CUSTFX"     ,"N",14,4 } )
        AADD(xCamp,{ "CTOTULC"    ,"N",14,4 } )
        AADD(xCamp,{ "CTOTPRJ"    ,"N",14,4 } )

        fImpCab01()
        ql_ProdPai := Space(15)
        ql_PrdRefR := Space(15)
        ql_TotCPai := 0
        ql_ToPrPai := 0
        aDados2 := Asort(aDados2,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
        For i := 1 to Len(aDados2)
            // Salto de Pagina e Totalizadores de um produto para outro
            If ql_ProdPai <> aDados2[i][1]
                If !Empty(ql_ProdPai)
                    fImpTotPrd()
                    ql_TotCPai := 0
                    ql_ToPrPai := 0
                EndIf
                ql_ProdPai := aDados2[i][1]
                ql_PrdRefR := Space(15)
            EndIf
            // Reinializa páginas
            If nRow1 > 2250
                fImpRoda()
                fImpCab01()
            EndIf

            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+aDados2[i][3]))
            ql_GrpCod := Alltrim(SB1->B1_GRUPO)
            If SB1->B1_TIPO == "PA" .and. Alltrim(aDados2[i][3]) <> Alltrim(ql_ProdPai) // .and. Substr(SB1->B1_COD,1,2) == "C1"
                ql_PrdRefR := aDados2[i][3]
            EndIf
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+aDados2[i][4]))
            If ql_GrpCod $ Alltrim(agrpPAR04) .or. Alltrim(SB1->B1_GRUPO) $ Alltrim(agrpPAR04) .or. Empty(agrpPAR04)

                // Calcula percetual da Projeção
                ql_Quant := aDados2[i][6]
                ql_Perct := 0

                // Novo tratamento para adicional de umidade
                If aDados2[i][14] <> 0
                    ql_Quant := ql_Quant/(-(((aDados2[i][14]/100)/1)-1))
                EndIf

                // Tratamento incluído em 03/05/16, por Marcos Alberto Soprani, para atender a OS effettivo 1532-16
                If UPPER(Alltrim(FunName())) == "BIA518" .and. Alltrim(SB1->B1_YCTRIND) == "61103001" .and. dtos(dDataBase) <= "20161231"
                    lyVlrRef := 1.0322898795 // Valor referência extraído do orçamento (tabela - Z46) de 11/10/15 para ORCA_16
                    If aDados2[i][9] < lyVlrRef
                        aDados2[i][9] := lyVlrRef
                    EndIf
                EndIf

                If (ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9]) <> 0
                    If aDados2[i][9] == 0
                        ql_Perct := 100
                    Else
                        ql_Perct := ((ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9])) / (ql_Quant*aDados2[i][9]) * 100
                    EndIf
                EndIf

                ql_TotCPai += ql_Quant * aDados2[i][9]
                ql_ToPrPai += ql_Quant * aDados2[i][12]

                If !SB1->B1_TIPO $ "PI/PP/PA" .and. aDados2[i][9] == 0 .and. !Alltrim(aDados2[i][4]) $ "1020700/1010170/1010173/1010235/1010268/1010334/1024245"
                    Aviso('CUSTO ZERADO', "Atenção! O Produto: " + Alltrim(aDados2[i][4]) + " possui um ou mais componentes que não possui custo unitário. Isto irá prejudicar o cálculo custo padrão do produto " + Alltrim(aDados2[i][1]) + " . Favor verificar antes de de proceguir",{'Ok'})
                    gpCustZero := .T.
                EndIf

            EndIf

            If gpCustZero
                Exit
            EndIF
        Next i

        fImpTotPrd()

    EndIf

    T001->(dbCloseArea())


    If MV_PAR10 == 1 .and. 1 == 2                            // Custo para BI
        *********************************************************************

        dbSelectArea("BI01")
        dbGoTop()
        While !Eof()

            zp_tipo := "3"

            dbSelectArea("ZZ5")
            dbSetOrder(6)
            If !dbSeek(xFilial("ZZ5")+dtos(dDataBase)+BI01->PRODUTO+zp_tipo)
                SB1->(dbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+BI01->PRODUTO))
                RecLock("ZZ5",.T.)
                ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
                ZZ5->ZZ5_DTINI  := dDataBase
                ZZ5->ZZ5_COD    := BI01->PRODUTO
                ZZ5->ZZ5_FORMAT := SB1->B1_YFORMAT
                ZZ5->ZZ5_LINHA  := SB1->B1_YLINHA
                ZZ5->ZZ5_LINSEQ := SB1->B1_YLINSEQ
                ZZ5->ZZ5_TIPO   := zp_tipo
            Else
                RecLock("ZZ5",.F.)
            EndIf
            ZZ5->ZZ5_CP     := BI01->CUSTO
            MsUnLock()

            dbSelectArea("BI01")
            dbSkip()
        End

        Ferase(BI01+GetDBExtension())     //arquivo de trabalho
        Ferase(BI01+OrdBagExt())          //indice gerado
        BI01->(dbCloseArea())

    EndIf

    If MV_PAR06 == 1
        U_BIAxExcel(aDadoX, xCamp, "BIA261"+strzero(seconds()%3500,5) )
    EndIf

    AK08->(dbCloseArea())

    oPrint:EndPage()
    oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Navega Estrutura de Produto para Acumular quantidades que  ¦¦¦
¦¦¦          ¦ servirão de base para custo variável                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function StrutBia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow, cRevisao, xNivel)

    LOCAL nRegi   := 0, nQuantItem := 0
    LOCAL aCampos := {}, aTamSX3:={}, lAdd :=.F.
    LOCAL nRecno
    cAliasEstru   := IIF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
    nQuant        := IIF(nQuant == NIL,1,nQuant)
    lAsShow       := IIF(lAsShow==NIL,.F.,lAsShow)
    xNivel        := IIF(xNivel == NIL, 1, xNivel)
    nEstru++
    If nEstru == 1
        xk_Ordem := 0
        aTamSX3:=TamSX3("G1_COD")
        AADD(aCampos,{"PRODPAI","C",aTamSX3[1],0})
        aTamSX3:=TamSX3("G1_TRT")
        AADD(aCampos,{"ORDEM","C",aTamSX3[1],0})
        aTamSX3:=TamSX3("G1_COD")
        AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
        aTamSX3:=TamSX3("G1_COMP")
        AADD(aCampos,{"COMP","C",aTamSX3[1],0})
        aTamSX3:=TamSX3("G1_TRT")
        AADD(aCampos,{"TRT","C",aTamSX3[1],0})
        aTamSX3:=TamSX3("G1_QUANT")
        AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
        aTamSX3:=TamSX3("G1_QUANT")
        AADD(aCampos,{"QTDORI","N",Max(aTamSX3[1],18),aTamSX3[2]})
        aTamSX3:=TamSX3("G1_NIV")
        AADD(aCampos,{"NIVEL","N",Max(aTamSX3[1],18),aTamSX3[2]})
        cArqTrab := CriaTrab(aCampos)
        If Select(cAliasEstru) > 0
            dbSelectArea(cAliasEstru)
            dbCloseArea()
        EndIf
        Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
        IndRegua(cAliasEstru,cArqTrab,"CODIGO+COMP+TRT",,,"Selecionando Registros...")
        dbSetIndex(cArqtrab+OrdBagExt())
    EndIf

    dbSelectArea("SG1")
    dbSetOrder(1)
    dbSeek(xFilial("SG1")+cProduto)

    ProcRegua(RecCount())
    cTempo := Alltrim(ElapTime(cHInicio, Time()))
    IncProc("Estrutura....   Tempo: "+cTempo)

    While !Eof() .and. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
        nRegi:=Recno()
        If SG1->G1_COD != SG1->G1_COMP
            lAdd:=.F.
            If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM

                // Retorno somado à Massa. Incluido em 30/09/11 para equiparação do programa ao que o Jecimar faz no excel
                sm_Perc := 0
                sm_QtdPlus := 0
                sm_QtdBkp := nQuant
                If AK08->(dbSeek(SG1->G1_COD)) .and. AK08->PERC < 100
                    sm_Perc := (SG1->G1_YMISTUR / AK08->PERC) * 100
                    sm_QtdPlus := sm_Perc * nQuant / SG1->G1_YMISTUR
                    nQuant := sm_QtdPlus
                    xSomaRet := .T.
                    xQtdRetn := AK08->PERC
                EndIf

                // Cálculo padrão do sistema para perda
                // nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
                // nQuant = Quantidade Pai
                // nG1Quant = Quantidade Corrente do Componente
                nQuantItem := ExplEstr(nQuant,,,cRevisao)
                nQuant := sm_QtdBkp

                If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))

                    dbSelectArea(cAliasEstru)
                    xk_Ordem ++
                    RecLock(cAliasEstru,.T.)
                    ESTRUT->ORDEM  := StrZero(xk_Ordem,3)
                    ESTRUT->PRODPAI:= wProduto
                    ESTRUT->CODIGO := SG1->G1_COD
                    ESTRUT->COMP   := SG1->G1_COMP
                    ESTRUT->TRT    := SG1->G1_TRT
                    If MV_PAR03 == 1
                        ESTRUT->QUANT  := ( nQuantItem * (100 - SG1->G1_PERDA) ) / 100
                    ElseIf MV_PAR03 == 2
                        ESTRUT->QUANT  := nQuantItem
                    EndIf
                    ESTRUT->QTDORI := SG1->G1_QUANT
                    ESTRUT->NIVEL  := xNivel
                    MsUnlock()
                    lAdd:=.T.
                EndIf
                dbSelectArea("SG1")

                // Verifica se existe sub-estrutura
                nRecno:=Recno()
                IF fSeekTpC() <> "PA" .And. dbSeek(xFilial("SG1")+SG1->G1_COMP)
                    SB1->(dbSetOrder(1))
                    SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
                    SBZ->(dbSetOrder(1))
                    SBZ->(dbSeek(xFilial("SBZ") + SG1->G1_COD))
                    StrutBia(SG1->G1_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow, SB1->B1_REVATU, xNivel+1)
                    nEstru --
                Endif
            EndIf
        EndIf
        dbGoto(nRegi)
        dbSkip()
    End
    cArqTmp := cArqTrab

Return cArqTrab

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpTotais ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpTotais()

    If xSomaRet
        oPrint:Say  (nRow1+20 ,0050 ,"Retorno: " + Transform(100-xQtdRetn, "@E 999,999,999.9999")                               ,oFont8)
    EndIf

    //-------------------------------------------------------------------------
    // Bloco do programa para impressão dos valores totais dos custos variáries
    nRow1 += 075

    If gpCustZero
        nRow1 += 075
        oPrint:Say  (nRow1 ,0050 ,"Este produto apresentou algum componente com custo zerado durante a geração do custo padrão..."               ,oFont14)
        nRow1 += 075
        nRow1 += 075
    EndIf

    oPrint:Line (nRow1-15, 050, nRow1-15, 3350)
    If nRow1 > 2250
        fImpRoda()
        fImpCabec()
    EndIf
    xf_Total := +;
        Padr("TOTAL DO CUSTO VARIÁVEL  ---->>>>>"                                       ,080)+" "+;
        Padc(""                                                                         ,006)+" "+;
        Padr(""                                                                         ,002)+" "+;
        Padc(""                                                                         ,003)+" "+;
        Padl(""                                                                         ,017)+" "+;
        Padl(""                                                                         ,014)+" "+;
        Padl(Transform(ql_TotCPai, "@E 9,999,999.9999")                                 ,014)+"  "+;
        Padl(""                                                                         ,002)+" "+;
        Padl(""                                                                         ,008)+" "+;
        Padl(""                                                                         ,002)+" "+;
        Padl(Transform(ql_ToPrPai, "@E 9,999,999.9999")                                 ,014)
    oPrint:Say  (nRow1 ,0050 ,xf_Total                               ,oFont8)
    ql_TotCPai := 0
    ql_ToPrPai := 0

    //-----------------------------------------------------------
    // Bloco do programa destinado ao tratamento dos custos fixos
    If MV_PAR09 <> 1
        nRow1 += 150
        If nRow1 > 2250
            fImpRoda()
            fImpCabec()
        EndIf
        oPrint:Line (nRow1-15, 050, nRow1-15, 3350)
        A0007 := " SELECT TOP 1 "+IIF(MV_PAR09 == 2, "Z13_CUSTFX", "Z13_DESPFX")+" Z13_CUSTFX
        A0007 += "   FROM "+RetSqlName("Z13")+" Z13
        A0007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
        A0007 += "                       AND B1_COD = '"+IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)+"'
        A0007 += "                       AND SB1.D_E_L_E_T_ = ' '
        //A0007 += "  INNER JOIN "+RetSqlName("ZZ7")+" ZZ7 ON ZZ7_FILIAL = '"+xFilial("ZZ7")+"'
        //A0007 += "                       AND ZZ7_COD = B1_YLINHA
        //A0007 += "                       AND ZZ7_LINSEQ = B1_YLINSEQ
        //A0007 += "                       AND ZZ7.D_E_L_E_T_ = ' '
        A0007 += "  WHERE Z13_FILIAL = '"+xFilial("Z13")+"'
        A0007 += "    AND '"+dtos(dDataBase)+"' >= Z13_DATADE
        A0007 += "    AND '"+dtos(dDataBase)+"' <= Z13_DATAAT
        A0007 += "    AND Z13_TIPO = '03'
        A0007 += "    AND Z13_FORMAT = B1_YFORMAT
        //A0007 += "    AND Z13_LINHCR = ZZ7_TIPO
        A0007 += "    AND Z13.D_E_L_E_T_ = ' '
        A0007 += "  ORDER BY Z13_PLANO DESC
        TcQuery A0007 ALIAS "A007" NEW
        dbSelectArea("A007")
        dbGoTop()
        xf_TCtFx := +;
            Padr("TOTAL DO CUSTO FIXO "+IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")+"---->>>>>"   ,080)+" "+;
            Padc(""                                                                               ,006)+" "+;
            Padr(""                                                                               ,002)+" "+;
            Padc(""                                                                               ,003)+" "+;
            Padl(""                                                                               ,017)+" "+;
            Padl(""                                                                               ,014)+" "+;
            Padl(Transform(A007->Z13_CUSTFX, "@E 9,999,999.9999")                                 ,014)+"  "+;
            Padl(""                                                                               ,002)+" "+;
            Padl(""                                                                               ,008)+" "+;
            Padl(""                                                                               ,002)+" "+;
            Padl(Transform(A007->Z13_CUSTFX, "@E 9,999,999.9999")                                 ,014)
        oPrint:Say  (nRow1 ,0050 ,xf_TCtFx                               ,oFont8)

        dbSelectArea("T001")
        RecLock("T001",.T.)
        T001->CCONTAB := "CUSTO FIXO"
        T001->CUSTO   := A007->Z13_CUSTFX
        T001->PROJT   := A007->Z13_CUSTFX
        MsUnLock()
        ql_TotCPai += A007->Z13_CUSTFX
        ql_ToPrPai += A007->Z13_CUSTFX

        //----------- Reservado para Exportação para Excel -------------------
        Aadd(aDadoX, { IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)                                 ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            "TOTAL DO CUSTO FIXO "+IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            Transform(A007->Z13_CUSTFX,     "@E 9,999,999.9999")                                          ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            ""                                                                                            ,;
            "CF"                                                                                          ,;
            IIF(MV_PAR09 == 2, "TOTAL ", "INDUSTRIAL ")                                                   ,;
            "   "                                                                                         })
        //--------------------------------------------------------------------

        A007->(dbCloseArea())
    EndIf

    //-----------------------------------------------
    // Impressão do resumo de custo por ContaContábil
    kv_TTVlr := 0
    kv_TTPrj := 0
    nRow1 += 125
    If nRow1 > 2250
        fImpRoda()
        fImpCabec()
    EndIf
    rr_Total := +;
        Padr(""                                                                         ,015)+" "+;
        Padr("C.Contabil"                                                               ,020)+" "+;
        Padr("Descrição"                                                                ,035)+" "+;
        Padl("Custo"                                                                    ,014)+" "+;
        Padl("Projetado"                                                                ,014)
    oPrint:Say  (nRow1 ,0050 ,rr_Total                               ,oFont8)
    oPrint:Line (nRow1+35, 050, nRow1+35, 3350)
    nRow1 += 075
    dbSelectArea("T001")
    dbGotop()
    While !Eof()
        If nRow1 > 2250
            fImpRoda()
            fImpCabec()
        EndIf
        ss_Total := +;
            Padr(""                                                                         ,015)+" "+;
            Padr(T001->CCONTAB                                                              ,020)+" "+;
            Padr(Posicione("CT1",1,xFilial("CT1")+T001->CCONTAB,"CT1_DESC01")               ,035)+" "+;
            Padl(Transform(T001->CUSTO, "@E 9,999,999.9999")                                ,014)+" "+;
            Padl(Transform(T001->PROJT, "@E 9,999,999.9999")                                ,014)
        oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)
        nRow1 += 050
        kv_TTVlr += T001->CUSTO
        kv_TTPrj += T001->PROJT
        RecLock("T001",.F.)
        Delete
        MsUnLock()
        dbSelectArea("T001")
        dbSkip()
    End

    nRow1 += 050
    If nRow1 > 2250
        fImpRoda()
        fImpCabec()
    EndIf
    ss_Total := +;
        Padr(""                                                                         ,015)+" "+;
        Padr("Total p/ Conta"                                                           ,020)+" "+;
        Padr(""                                                                         ,035)+" "+;
        Padl(Transform(kv_TTVlr, "@E 9,999,999.9999")                                   ,014)+" "+;
        Padl(Transform(kv_TTPrj, "@E 9,999,999.9999")                                   ,014)
    oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)

    If MV_PAR10 == 1 .and. 1 == 2
        dbSelectArea("BI01")
        If !dbSeek(IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR))
            RecLock("BI01",.T.)
            BI01->PRODUTO := IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)
        Else
            RecLock("BI01",.F.)
        EndIf
        BI01->CUSTO := ql_ToPrPai + A007->Z13_CUSTFX
        MsUnLock()
    EndIf

    If MV_PAR10 == 1                                         // Custo para BI
        *********************************************************************
        zp_tipo := "3"
        dbSelectArea("ZZ5")
        dbSetOrder(6)
        If !dbSeek(xFilial("ZZ5")+dtos(dDataBase)+ql_ProdPai+zp_tipo)
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
            RecLock("ZZ5",.T.)
            ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
            ZZ5->ZZ5_DTINI  := dDataBase
            ZZ5->ZZ5_COD    := ql_ProdPai
            ZZ5->ZZ5_FORMAT := SB1->B1_YFORMAT
            ZZ5->ZZ5_LINHA  := SB1->B1_YLINHA
            ZZ5->ZZ5_LINSEQ := SB1->B1_YLINSEQ
            ZZ5->ZZ5_TIPO   := zp_tipo
        Else
            RecLock("ZZ5",.F.)
        EndIf
        ZZ5->ZZ5_CP     := ql_ToPrPai + A007->Z13_CUSTFX
        MsUnLock()
    EndIf

    fImpRoda()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpTotPrd ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpTotPrd()

    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
    SBZ->(dbSetOrder(1))
    SBZ->(dbSeek(xFilial("SBZ") + ql_ProdPai))
    ql_DescPai := Substr(SB1->B1_DESC,1,50)
    ql_UmPai   := SB1->B1_UM
    ql_QtRfPai := Transform(IIF(SB1->B1_QB == 0, 1, SB1->B1_QB), "@E 999,999.999")
    ql_RAtuPai := SB1->B1_REVATU

    // Calcula percetual da Projeção
    ql_Perct := 0
    If ql_ToPrPai - ql_TotCPai <> 0
        If ql_TotCPai == 0
            ql_Perct := 100
        Else
            ql_Perct := (ql_ToPrPai - ql_TotCPai) / ql_TotCPai * 100
        EndIf
    EndIf

    //------------------------------------------------
    xf_CtoFix := 0
    If MV_PAR09 <> 1
        A0007 := " SELECT TOP 1 "+IIF(MV_PAR09 == 2, "Z13_CUSTFX", "Z13_DESPFX")+" Z13_CUSTFX
        A0007 += "   FROM "+RetSqlName("Z13")+" Z13
        A0007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
        A0007 += "                       AND B1_COD = '"+IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)+"'
        A0007 += "                       AND SB1.D_E_L_E_T_ = ' '
        //A0007 += "  INNER JOIN "+RetSqlName("ZZ7")+" ZZ7 ON ZZ7_FILIAL = '"+xFilial("ZZ7")+"'
        //A0007 += "                       AND ZZ7_COD = B1_YLINHA
        //A0007 += "                       AND ZZ7_LINSEQ = B1_YLINSEQ
        //A0007 += "                       AND ZZ7.D_E_L_E_T_ = ' '
        A0007 += "  WHERE Z13_FILIAL = '01'
        A0007 += "    AND '"+dtos(dDataBase)+"' >= Z13_DATADE
        A0007 += "    AND '"+dtos(dDataBase)+"' <= Z13_DATAAT
        A0007 += "    AND Z13_TIPO = '03'
        A0007 += "    AND Z13_FORMAT = B1_YFORMAT
        //A0007 += "    AND Z13_LINHCR = ZZ7_TIPO
        A0007 += "    AND Z13.D_E_L_E_T_ = ' '
        A0007 += "  ORDER BY Z13_PLANO DESC
        TcQuery A0007 ALIAS "A007" NEW
        dbSelectArea("A007")
        dbGoTop()
        xf_CtoFix := A007->Z13_CUSTFX
        A007->(dbCloseArea())
    EndIf

    ss_Total := +;
        Padr(ql_ProdPai + ql_DescPai                                                    ,080)+" "+;
        Padc(ql_RAtuPai                                                                 ,006)+" "+;
        Padr(ql_UmPai                                                                   ,002)+" "+;
        Padl(Transform(ql_TotCPai, "@E 9,999,999.9999")                                 ,014)+"  "+;
        Padl(Transform(ql_ToPrPai, "@E 9,999,999.9999")                                 ,014)+" "+;
        Padl(Transform(ql_Perct, "@E 99999.99")                                         ,008)+"  "+;
        Padl(Transform(xf_CtoFix, "@E 9,999,999.9999")                                  ,014)+"  "+;
        Padl(Transform(ql_TotCPai + xf_CtoFix, "@E 9,999,999.9999")                     ,014)+"  "+;
        Padl(Transform(ql_ToPrPai + xf_CtoFix, "@E 9,999,999.9999")                     ,014)
    oPrint:Say  (nRow1 ,0050 ,ss_Total                               ,oFont8)
    nRow1 += 050

    //------------------- Reservado para Exportação -----------------------
    Aadd(aDadoX, { ql_ProdPai                                      ,;
        ql_DescPai                                                     ,;
        ql_RAtuPai                                                     ,;
        ql_UmPai                                                       ,;
        Transform(ql_TotCPai, "@E 9,999,999.9999")                     ,;
        Transform(ql_ToPrPai, "@E 9,999,999.9999")                     ,;
        Transform(ql_Perct, "@E 99999.99")                             ,;
        Transform(xf_CtoFix, "@E 9,999,999.9999")                      ,;
        Transform(ql_TotCPai + xf_CtoFix, "@E 9,999,999.9999")         ,;
        Transform(ql_ToPrPai + xf_CtoFix, "@E 9,999,999.9999")         })
    //--------------------------------------------------------------------

    If MV_PAR10 == 1 .and. 1 = 2
        dbSelectArea("BI01")
        If !dbSeek(IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR))
            RecLock("BI01",.T.)
            BI01->PRODUTO := IIF(Empty(ql_PrdRefR), ql_ProdPai, ql_PrdRefR)
        Else
            RecLock("BI01",.F.)
        EndIf
        BI01->CUSTO := ql_ToPrPai + xf_CtoFix
        MsUnLock()
    EndIf

    If MV_PAR10 == 1                                         // Custo para BI
        *********************************************************************
        zp_tipo := "3"
        dbSelectArea("ZZ5")
        dbSetOrder(6)
        If !dbSeek(xFilial("ZZ5")+dtos(dDataBase)+ql_ProdPai+zp_tipo)
            //SB1->(dbSetOrder(1))
            //SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
            RecLock("ZZ5",.T.)
            ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
            ZZ5->ZZ5_DTINI  := dDataBase
            ZZ5->ZZ5_COD    := ql_ProdPai
            ZZ5->ZZ5_FORMAT := SB1->B1_YFORMAT
            ZZ5->ZZ5_LINHA  := SB1->B1_YLINHA
            ZZ5->ZZ5_LINSEQ := SB1->B1_YLINSEQ
            ZZ5->ZZ5_TIPO   := zp_tipo
        Else
            RecLock("ZZ5",.F.)
        EndIf
        ZZ5->ZZ5_CP     := ql_ToPrPai + xf_CtoFix
        MsUnLock()
    EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

    oPrint:StartPage()
    wnPag ++
    nRow1 := 050
    If File(aBitmap)
        oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
    EndIf
    nRow1 += 025

    oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
    oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabe02,110)                                          ,oFont14)
    oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
    oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
    oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
    oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

    nRow1 += 175
    oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+ql_ProdPai))
    SBZ->(dbSetOrder(1))
    SBZ->(dbSeek(xFilial("SBZ") + ql_ProdPai))
    ql_DescPai := Substr(SB1->B1_DESC,1,50)
    ql_UmPai   := SB1->B1_UM
    ql_QtRfPai := Transform(IIF(SB1->B1_QB == 0, 1, SB1->B1_QB), "@E 999,999.999")
    ql_RAtuPai := SB1->B1_REVATU

    ql_RefPai  := ql_ProdPai + " - " + ql_DescPai + " Unid.Medida: " + ql_UmPai + "            Qtd.Base: " + ql_QtRfPai + "      RevAtu: " + ql_RAtuPai
    oPrint:Say  (nRow1    ,0050 , ql_RefPai          ,oFont10)
    nRow1 += 075

    xf_Cabec := +;
        Padr("Produto - Descrição"                                                      ,075)+" "+;
        Padc("RevAtu"                                                                   ,006)+" "+;
        Padr("UM"                                                                       ,002)+" "+;
        Padc("TRT"                                                                      ,003)+" "+;
        Padl(IIF(MV_PAR03 == 1, "Quant. Orig", "Quant. c/Perda")                        ,017)+" "+;
        Padl("C.Unit"                                                                   ,014)+" "+;
        Padl("CustoUltCom"                                                              ,014)+" "+;
        Padc("Rf"                                                                       ,002)+" "+;
        Padc("UltCom"                                                                   ,008)+" "+;
        Padc("EP"                                                                       ,002)+" "+;
        Padl("Projetado"                                                                ,010)+" "+;
        Padl("%"                                                                        ,008)+" "+;
        Padl("Umidade"                                                                  ,008)
    oPrint:Say  (nRow1 ,0050 ,xf_Cabec                              ,oFont8)
    oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
    nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCab01 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 29/08/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCab01()

    oPrint:StartPage()
    wnPag ++
    nRow1 := 050
    If File(aBitmap)
        oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
    EndIf
    nRow1 += 025

    oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
    oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabe02,110)                                          ,oFont14)
    oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
    oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
    oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
    oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

    nRow1 += 175
    oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

    xf_Cabec := +;
        Padr("Produto - Descrição"                                                      ,080)+" "+;
        Padc("RevAtu"                                                                   ,006)+" "+;
        Padr("UM"                                                                       ,002)+" "+;
        Padl("CustoUltCom"                                                              ,014)+"  "+;
        Padl("Projetado"                                                                ,014)+" "+;
        Padl("%"                                                                        ,008)+"  "+;
        Padl("CustoFixo"                                                                ,014)+"  "+;
        Padl("TotUltCom"                                                                ,014)+"  "+;
        Padl("TotProjet"                                                                ,014)
    oPrint:Say  (nRow1 ,0050 ,xf_Cabec                              ,oFont8)
    oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
    nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

    oPrint:Line (2300, 050, 2300, 3350)
    oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                                    ,oFont7)
    oPrint:Say  (2300+30 ,0850,"Legenda: Rf -->> I=Informado; Nf=Nota Fiscal; R=Retificado "        ,oFont7)
    oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()                         ,oFont7)
    oPrint:EndPage()
    nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fCalcUmid ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 11/11/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCalcUmid()

    Local cfdUmid := SBZ->BZ_YUMIDAD
    Local cfdArea := GetArea()

    jh_MesA := stod(Substr(dtos(dDataBase),1,6)+"01")-1
    jh_PriD := Substr(dtos(jh_MesA),1,6) + "01"
    jh_UltD := dtos(Ultimodia(jh_MesA))

    GH009 := " SELECT ISNULL((SELECT ROUND(SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG),2)
    GH009 += "                  FROM " + RetSqlName("Z02")
    GH009 += "                 WHERE Z02_FILIAL = '"+xFilial("Z02")+"'
    GH009 += "                   AND Z02_DATREF BETWEEN '"+jh_PriD+"' AND '"+jh_UltD+"'
    GH009 += "                   AND Z02_PRODUT = '" + ESTRUT->COMP + "'
    GH009 += "                   AND Z02_QTDCRG <> 0
    GH009 += "                   AND Z02_ORGCLT = '2'
    GH009 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDADE
    GHcIndex := CriaTrab(Nil,.f.)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,GH009),'GH09',.F.,.T.)
    dbSelectArea("GH09")
    dbGoTop()
    If GH09->UMIDADE <> 0
        cfdUmid := GH09->UMIDADE
    EndIf

    GH09->(dbCloseArea())
    Ferase(GHcIndex+GetDBExtension())     //arquivo de trabalho
    Ferase(GHcIndex+OrdBagExt())          //indice gerado

    RestArea( cfdArea )

Return ( cfdUmid )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

    local i,j
    _sAlias := Alias()
    dbSelectArea("SX1")
    dbSetOrder(1)
    cPerg := PADR(fPerg,fTamX1)
    aRegs:={}

    // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
    aAdd(aRegs,{cPerg,"01","De Produto          ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
    aAdd(aRegs,{cPerg,"02","Ate Produto         ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
    aAdd(aRegs,{cPerg,"03","Ref. Quantidade     ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Quant. Orig","","","","","Quant. c/Perda","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"04","Quais Grupos Listar ?","","","mv_ch4","C",99,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"05","Formanto dos Dados  ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Analítico","","","","","Sintético","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"06","Gerar Excel         ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"07","Tipo de Produto     ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02"})
    aAdd(aRegs,{cPerg,"08","Caso Tipo PA        ?","","","mv_ch8","N",01,0,0,"C","","mv_par08","Ativos+Filtro","","","","","Apenas Filtro","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"09","Imprime Custo Fixo  ?","","","mv_ch9","N",01,0,0,"C","","mv_par09","Não","","","","","Fixo Total","","","","","Fixo Industrial","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"10","Atualizar Custo BI  ?","","","mv_cha","N",01,0,0,"C","","mv_par10","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"11","Atualizar Custo SAP ?","","","mv_chb","N",01,0,0,"C","","mv_par11","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"12","Sendo TIPO PA apenas?","","","mv_chc","N",01,0,0,"C","","mv_par12","Classe A","","","","","Todas as Classes","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"13","Filtro Aleatório    ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"14","Filtro FORMATOS     ?","","","mv_che","C",99,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","",""})
    For i := 1 to Len(aRegs)
        if !dbSeek(cPerg + aRegs[i,2])
            RecLock("SX1",.t.)
            For j:=1 to FCount()
                If j <= Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                Endif
            Next
            MsUnlock()
        Endif
    Next

    dbSelectArea(_sAlias)

Return

Static Function fSeekTpC()

    Local _cTipo	:=	"XX"
    Local _aArea	:=	GetArea()

    SB1->(DbSetOrder(1))
    If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COD)) .And. SB1->B1_YTPPROD == 'RP'
        If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP)) .And. SB1->B1_YEMPEST <> '0101'
            _cTipo	   := SB1->B1_TIPO
        EndIf
    EndIF
    RestArea(_aArea)

Return _cTipo
