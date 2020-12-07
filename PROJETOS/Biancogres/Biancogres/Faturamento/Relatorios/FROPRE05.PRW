#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FROPRE05
@description RELATORIO DE REAJUSTE DE PRECO
@author Fernando Rocha
@since 26/09/2020
@version 1.0
@type function
/*/
User Function FROPRE05()
    Private oReport,oSection1,oSection2

    Private cPerg 		:= "FROPRE05"
    Private aRegs 		:= {}
    Private cQuery	 	:= "QUERY"

    oReport:=ReportDef()
    oReport:PrintDialog()

Return


Static Function ReportDef()
    Local cReport := "FROPRE05"
    Local cTitulo := "Reajustes de Preço"
    Local cDescri := "Reajustes de Preço"
    Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
    
    ValPerg()

    Pergunte(cPerg , .F. )
    oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
    oReport:SetLandScape()
    //oReport:SetPortrait()

    oSection1 := TRSection():New( oReport  ,"RC",{"QUERY"} )
    TRCell():New(oSection1	,"Marca"			,,"Marca"				,"@!", 6,/*lPixel*/,  {|| (cQUERY)->Marca } )
    TRCell():New(oSection1	,"Gerente"			,,"Gerente"				,"@!", 6,/*lPixel*/,  {|| (cQUERY)->Gerente } )
    TRCell():New(oSection1	,"Cod_Vend"			,,"Cod_Vend"			,"@!", 6,/*lPixel*/,  {|| (cQUERY)->Cod_Vend } )
    TRCell():New(oSection1	,"Nome_Vend"		,,"Nome_Vend"			,"@!", 20,/*lPixel*/,  {|| (cQUERY)->Nome_Vend } )
    TRCell():New(oSection1	,"Cod_Cli"			,,"Cod_Cli"				,"@!", 6,/*lPixel*/,  {|| (cQUERY)->Cod_Cli } )
    TRCell():New(oSection1	,"Nome_Cli"			,,"Nome_Cli"			,"@!", 20,/*lPixel*/,  {|| (cQUERY)->Nome_Cli } )
    TRCell():New(oSection1	,"UF"			    ,,"UF"				    ,"@!", 2,/*lPixel*/,  {|| (cQUERY)->UF } )
    TRCell():New(oSection1	,"Segmento"			,,"Segmento"			,"@!", 2,/*lPixel*/,  {|| (cQUERY)->Segmento } )
    TRCell():New(oSection1	,"Pedido"		    ,,"Pedido"		    	,"@!", 6,/*lPixel*/,  {|| (cQUERY)->Pedido } )
    TRCell():New(oSection1	,"Dt_Pedido"		,,"Dt_Pedido"			,"@!", 10,/*lPixel*/,  {|| DTOC(STOD((cQUERY)->Dt_Pedido)) } )
    TRCell():New(oSection1	,"Dt_Reajuste"		,,"Dt_Reajuste"		    ,"@!", 10,/*lPixel*/,  {|| DTOC(STOD((cQUERY)->Dt_Reajuste)) } )
    TRCell():New(oSection1	,"It_Pedido"		,,"It_Pedido"			,"@!", 2,/*lPixel*/,  {|| (cQUERY)->It_Pedido } )
    TRCell():New(oSection1	,"Produto"			,,"Produto"				,"@!", 10,/*lPixel*/,  {|| (cQUERY)->Produto } )
    TRCell():New(oSection1	,"Descricao"		,,"Descricao"			,"@!", 30,/*lPixel*/,  {|| (cQUERY)->Descricao } )

    TRCell():New(oSection1	,"Quant"  		    ,,"Quant"				,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->Quant  } )
    TRCell():New(oSection1	,"Pr_Original"  	,,"Pr_Original"			,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->Pr_Original  } )
    TRCell():New(oSection1	,"Pr_Novo"  		,,"Pr_Novo"				,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->Pr_Novo  } )
    TRCell():New(oSection1	,"P_Reajuste"  		,,"P_Reajuste"			,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->P_Reajuste  } )
    TRCell():New(oSection1	,"OC"			    ,,"OC"				    ,"@!", 6,/*lPixel*/,  {|| (cQUERY)->OC } )

Return oReport


Static Function ReportPrint( oReport )
    Local CSQL 		:= ""
    

    CSQL := ""
    CSQL += " select "+CRLF
    CSQL += " Marca = C5_YEMP, "+CRLF
    CSQL += " Gerente = (select top 1 N_GERENT from [dbo].[GET_ZKP] (A1_YTPSEG, C5_YEMP, A1_EST, A3_COD, A1_YCAT, A1_GRPVEN)), "+CRLF
    CSQL += " Cod_Vend = A3_COD, "+CRLF
    CSQL += " Nome_Vend = A3_NREDUZ, "+CRLF
    CSQL += " Cod_Cli = A1_COD, "+CRLF
    CSQL += " Nome_Cli = A1_NOME, "+CRLF
    CSQL += " UF = A1_EST, "+CRLF
    CSQL += " Segmento = A1_YTPSEG, "+CRLF
    CSQL += " Pedido = C5_NUM, "+CRLF
    CSQL += " Dt_Pedido = C5_EMISSAO, "+CRLF
    CSQL += " Dt_Reajuste = ZM9_DATA, "+CRLF
    CSQL += " It_Pedido = C6_ITEM, "+CRLF
    CSQL += " Produto = C6_PRODUTO, "+CRLF
    CSQL += " Descricao = C6_DESCRI, "+CRLF
    CSQL += " Quant = C6_QTDVEN, "+CRLF
    CSQL += " Pr_Original = ZM9_PRCOLD, "+CRLF
    CSQL += " Pr_Novo = ZM9_PRCNEW, "+CRLF
    CSQL += " P_Reajuste = ZM9_PERC, "+CRLF
    CSQL += " OC = C5_YPC "+CRLF
    CSQL += " from "+RetSqlName("ZM9")+" ZM9 (nolock) "+CRLF
    CSQL += " join "+RetSqlName("SC6")+" SC6 (nolock) on C6_FILIAL = ZM9_FILIAL and C6_NUM = ZM9_PEDIDO and C6_ITEM = ZM9_ITEM "+CRLF
    CSQL += " join "+RetSqlName("SC5")+" SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM "+CRLF
    CSQL += " join "+RetSqlName("SA1")+" SA1 (nolock) on A1_FILIAL = '  ' and C5_CLIENTE = A1_COD and C5_LOJACLI = A1_LOJA "+CRLF
    CSQL += " join "+RetSqlName("SA3")+" SA3 (nolock) on A3_FILIAL = '  ' and A3_COD = C5_VEND1 "+CRLF
    CSQL += " where "+CRLF
    CSQL += " ZM9_FILIAL = '"+XFilial("ZM9")+"' "+CRLF
    CSQL += " and ZM9_DATA between '"+DTOS(MV_PAR01)+"' and '"+DTOS(MV_PAR02)+"' "+CRLF
    CSQL += " and A3_COD between '"+MV_PAR03+"' and '"+MV_PAR04+"' "+CRLF
    CSQL += " and A1_COD between '"+MV_PAR05+"' and '"+MV_PAR06+"' "+CRLF
    CSQL += " and ZM9.D_E_L_E_T_ = '' "+CRLF
    CSQL += " and SC6.D_E_L_E_T_ = '' "+CRLF
    CSQL += " and SC5.D_E_L_E_T_ = '' "+CRLF
    CSQL += " and SA1.D_E_L_E_T_ = '' "+CRLF
    CSQL += " and SA3.D_E_L_E_T_ = '' "+CRLF

    TCQUERY CSQL New Alias "QUERY"

    oSection1:Init()
    oSection1:Print()
    oSection1:Finish()

    IF Select("QUERY") > 0
        QUERY->(DbCloseArea())
    ENDIF

Return Nil

Static Function ValPerg()
    Local i,j,nX
    Local aTRegs := {}
    Local aHelpPor := {}
    Local aHelpEng := {}
    Local aHelpSpa := {}

    cPerg := PADR(cPerg,10)

    //DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
    aAdd(aTRegs,{"Data Reajuste De?"	,"D", 8,0,0,"G","","","","","","","",""})
    aAdd(aTRegs,{"Data Reajuste Ate?"	,"D", 8,0,0,"G","","","","","","","",""})
    aAdd(aTRegs,{"Vendedor De?"			,"C", 6,0,0,"G","","","","","","","SA3",""})
    aAdd(aTRegs,{"Vendedor Ate?"		,"C", 6,0,0,"G","","","","","","","SA3",""})
    aAdd(aTRegs,{"Cliente De?"			,"C", 6,0,0,"G","","","","","","","SA1",""})
    aAdd(aTRegs,{"Cliente Ate?"		    ,"C", 6,0,0,"G","","","","","","","SA1",""})


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

RETURN
