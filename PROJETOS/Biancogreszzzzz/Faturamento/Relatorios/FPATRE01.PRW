#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function FPATRE01()

    Private oReport,oSection1,oSection2
    Private cPerg  := "FPATRE01"
    Private aRegs   := {}
    Private cQuery  := GetNextAlias()

    ValPerg()

    If Pergunte(cPerg , .T. )

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf

    If Select(cQuery) > 0

        (cQuery)->(DbCloseArea())

    EndIf

Return()

Static Function ReportDef()

    Local cReport := "FPATRE01"
    Local cTitulo := "Sugestão de Pedidos - Inconsistencias"
    Local cDescri := "Sugestão de Pedidos - Inconsistencias"
    Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }

    Pergunte(cPerg , .F. )

    oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
    oReport:SetPortrait()

    oSection1 := TRSection():New( oReport  ,"01",cQuery, {} )
    TRCell():New(oSection1	,"TABELA"	  		,,"Tabela"			    ,"@!", 10,/*lPixel*/, {|| (cQUERY)->TABELA } )
    TRCell():New(oSection1	,"ANO"	  		    ,,"Ano" 			    ,"@!", 4,/*lPixel*/, {|| (cQUERY)->ANO } )
    TRCell():New(oSection1	,"MES"	  		    ,,"Mes"  			    ,"@!", 4,/*lPixel*/, {|| (cQUERY)->MES } )
    TRCell():New(oSection1	,"DIA"	  		    ,,"Dia" 			    ,"@!", 4,/*lPixel*/, {|| (cQUERY)->DIA } )
    TRCell():New(oSection1	,"DESC_ERRO"	  	,,"ERRO" 			    ,"@!", 40,/*lPixel*/, {|| (cQUERY)->DESC_ERRO } )
    TRCell():New(oSection1	,"CODCLI"	  		,,"Cod.Cliente"			,"@!", 6,/*lPixel*/, {|| (cQUERY)->CODCLI } )
    TRCell():New(oSection1	,"LOJCLI"	  		,,"Loja"    			,"@!", 2,/*lPixel*/, {|| (cQUERY)->LOJCLI } )
    TRCell():New(oSection1	,"NOMECLI"	  		,,"Nome"    			,"@!", 40,/*lPixel*/, {|| (cQUERY)->NOMECLI } )
    TRCell():New(oSection1	,"CODPRO"	  		,,"Cod.Produto"			,"@!", 20,/*lPixel*/, {|| (cQUERY)->CODPRO } )
    TRCell():New(oSection1	,"CODPCL"	  		,,"Cod.Prod.Cliente"	,"@!", 20,/*lPixel*/, {|| (cQUERY)->CODPCL } )
    TRCell():New(oSection1	,"NOMEPRO"	  		,,"Descr.Produto"	    ,"@!", 30,/*lPixel*/, {|| (cQUERY)->NOMEPRO } )

    oSection1:SetTotalInLine(.F.)

Return(oReport)

Static Function ReportPrint( oReport )

    oSection1:BeginQuery()

    CSQL := GetQuery()

    TCQUERY CSQL New Alias (CQUERY)

    oSection1:EndQuery()
    oSection1:Init()

    While (CQUERY)->(!EOF())

        oSection1:PrintLine()
        (CQUERY)->(DBSkip())

    EndDo

    oSection1:Finish()

    (cQuery)->(DbCloseArea())

Return()

Static Function GetQuery()

    Local CSQL := ""

    CSQL := " select * from FNC_PAT_REL_INCONSISTENCIAS('"+MV_PAR01+"','"+MV_PAR02+"','"+DTOS(MV_PAR03)+"','"+DTOS(MV_PAR04)+"') "+CRLF
    CSQL += " order by TABELA, ANO, MES, DIA "+CRLF

Return(CSQL)

Static Function ValPerg()

    Local i,j,nX
    Local aTRegs := {}
    Local aHelpPor := {}
    Local aHelpEng := {}
    Local aHelpSpa := {}

    cPerg := PADR(cPerg,10)

    //DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
    aAdd(aTRegs,{"Cliente De"		    ,"C", 6,0,0,"G","","","","","","","SA1",""})
    aAdd(aTRegs,{"Cliente Ate"		    ,"C", 6,0,0,"G","","","","","","","SA1",""})
    aAdd(aTRegs,{"Data De"		        ,"D", 8,0,0,"G","","","","","","","",""})
    aAdd(aTRegs,{"Data Ate"		        ,"D", 8,0,0,"G","","","","","","","",""})

    //Criar aRegs na ordem do vetor Temporario
    aRegs := {}
    For I := 1 To Len(aTRegs)
        aAdd(aRegs,{cPerg, StrZero(I,2), aTRegs[I][1], aTRegs[I][1], aTRegs[I][1],;
            "mv_ch"+Alltrim(Str(I)), aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],;
            aTRegs[I][6],aTRegs[I][7],"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",;
            aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","",;
            "",aTRegs[I][12],"","","",aTRegs[I][13],""})
    Next I

    //Grava no SX1 se ja nao existir
    dbSelectArea("SX1")
    For i:=1 to Len(aRegs)

        If !dbSeek(cPerg+aRegs[i,2])
            RecLock("SX1",.T.)
            For j:=1 to FCount()
                If j <= Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                Endif
            Next
            MsUnlock()
        Else
            RecLock("SX1",.F.)
            For j:=3 to FCount()
                If j <= Len(aRegs[i])
                    If SubStr(FieldName(j),1,6) <> "X1_CNT"
                        FieldPut(j,aRegs[i,j])
                    EndIf
                Endif
            Next
            MsUnlock()
        EndIf

        //HELP DAS PERGUNTAS
        aHelpPor := {}
        __aRet := STRTOKARR(aTRegs[I][14],"#")
        FOR nX := 1 To Len(__aRet)
            AADD(aHelpPor,__aRet[nX])
        NEXT nX
        PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)

    Next

Return()