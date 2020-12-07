#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCCFRE02()

    Private oReport,oSection1,oSection2
    Private cPerg  := "FCCFRE02"
    Private aRegs   := {}
    Private cQuery  := GetNextAlias()

    ValPerg()

    If Pergunte(cPerg , .T. )

        If MV_PAR05 == 1

            oReport := ReportDef()

            oReport:PrintDialog()

        Else

            ReportTxt()

        EndIf

    EndIf

    If Select(cQuery) > 0

        (cQuery)->(DbCloseArea())

    EndIf

Return()

Static Function ReportTxt()

    Local cPath     := "temp"
    Local cFile     := "C:\" + cPath + "\" + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".txt"
    Local cParam    := ""
    Local cTexto    := ""
    Local cDir      := ""
    Local CSQL      := GetQuery()
    Local nTotSaldo := 0
    Local nTotVEnc  := 0
    Local nTotAVenc := 0
    Local nTotSalC := 0
    Local nSaldoC := 0
    Local nDif := 0
    Local nTotDif := 0    

    IF TCSPEXIST("SP_RELPOSCLI_CP_ANALITICO")
        LjMsgRun("Aguarde... Processando Posição Fornecedor dia "+DTOC(MV_PAR02),,{|| _aRet := TCSPEXEC("SP_RELPOSCLI_CP_ANALITICO", DTOS(MV_PAR02), MV_PAR03, MV_PAR04) })
    ENDIF

    TCQUERY CSQL New Alias (CQUERY)

    While (CQUERY)->(!EOF())

        If Empty(cTexto)

            cTexto +=   PADR("CODFOR"           , 06) + "|" +;
                        PADR("NOME"             , 70) + "|" +;
                        PADR("CNPJ"             , 14) + "|" +;	        
                        PADR("TOTAL_VENCIDO"    , 14) + "|" +;
                        PADR("TOTAL_A_VENCER"   , 14) + "|" +; 
                        PADR("SALDO_FINANC"     , 14) + "|" +;
                        PADR("SALDO_CONTABIL"   , 14) + "|" +;
                        PADR("DIFERENCA"				, 14) + "|" + CRLF
        
        EndIf
        
        If (MV_PAR06 == 1 .And. ((CQUERY)->SALDO > 0 .Or. (CQUERY)->TOTAL_VENCIDO > 0 .Or. (CQUERY)->TOTAL_A_VENCER > 0)) .Or. MV_PAR06 == 2

            nTotSaldo += (CQUERY)->SALDO
            nTotVEnc  += (CQUERY)->TOTAL_VENCIDO
            nTotAVenc += (CQUERY)->TOTAL_A_VENCER

            nSaldoC := SaldoConta((CQUERY)->CONTA, MV_PAR02, "01")
            
            nTotSalC += nSaldoC
            
            nDif := nSaldoC - (CQUERY)->SALDO
            
            nTotDif += nDif
            
            cTexto +=   PADR((CQUERY)->CODFOR                   , 06) + "|" +;
                        PADR((CQUERY)->NOME                     , 70) + "|" +;
                        PADR((CQUERY)->CNPJ                     , 14) + "|" +;	        
                        PADL(Mascara((CQUERY)->TOTAL_VENCIDO)   , 14) + "|" +;
                        PADL(Mascara((CQUERY)->TOTAL_A_VENCER)  , 14) + "|" +;
                        PADL(Mascara((CQUERY)->SALDO)           , 14) + "|" +;
                        PADL(Mascara(nSaldoC), 14) + "|" +;
                        PADL(Mascara(nDif), 14) + "|" + CRLF

        EndIf

        (CQUERY)->(DBSkip())

    EndDo

    If !Empty(cTexto)

        cTexto +=   PADR(""          , 06) + "|" +;
                    PADR(""          , 70) + "|" +;
                    PADR(""          , 14) + "|" +;	        
                    PADL(Mascara(nTotVEnc)  , 14) + "|" +;
                    PADL(Mascara(nTotAVenc) , 14) + "|" +;
                    PADL(Mascara(nTotSaldo) , 14) + "|" +;
                    PADL(Mascara(nTotSalC) , 14) + "|" +;
                    PADL(Mascara(nTotDif) , 14) + "|" + CRLF
                    
    EndIf

    (cQuery)->(DbCloseArea())

    If !lIsDir( "C:\"+cPath+"\" )

        MakeDir( "C:\"+cPath+"\" )

    EndIf

    MemoWrite( cFile, cTexto )

    ShellExecute("open", cFile, cParam, cDir, 1)

Return()

Static Function Mascara(nNumber)

    Local cNumber := ""

    Default nNumber := 0

    cNumber := Transform(nNumber,"@E 999999999.99")

    cNumber := Replace(cNumber, ",", ".")

Return(cNumber)

Static Function ReportDef()

    Local cReport := "FCCFRE02"
    Local cTitulo := "Posição de Fornecedor - Conciliação"
    Local cDescri := "Posição de Fornecedor - Conciliação"
    Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
    Local nSaldoC := 0    

    Pergunte(cPerg , .F. )

    oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
    //oReport:SetLandScape()
    oReport:SetPortrait()

    oSection1 := TRSection():New( oReport  ,"01",cQuery, {} )
    TRCell():New(oSection1	,"CODFOR"	  		,,"Cod.Fornecedor"			,"@!", 6,/*lPixel*/, {|| (cQUERY)->CODFOR } )
    TRCell():New(oSection1	,"NOME"	   			,,"Nome"	  			,"@!", 30,/*lPixel*/, {|| (cQUERY)->NOME } )
    TRCell():New(oSection1	,"CNPJ"	            ,,"CNPJ         "	  	,"@!", 20,/*lPixel*/, {|| (cQUERY)->CNPJ } )
    TRCell():New(oSection1	,"TOTAL_VENCIDO"  	,,"Vencido"			    ,"@E 999,999,999.99", 10,/*lPixel*/, {|| (cQUERY)->TOTAL_VENCIDO  } )
    TRCell():New(oSection1	,"TOTAL_A_VENCER"  	,,"A Vencer"		    ,"@E 999,999,999.99", 10,/*lPixel*/, {|| (cQUERY)->TOTAL_A_VENCER  } )
    TRCell():New(oSection1	,"SALDO_FINANC"  	  ,,"Saldo Financeiro"				,"@E 999,999,999.99", 10,/*lPixel*/, {|| (cQUERY)->SALDO  } )   
    TRCell():New(oSection1	,"SALDO_CONTABIL"  	,,"Saldo Contabil"		    ,"@E 999,999,999.99", 10,/*lPixel*/, {|| nSaldoC := SaldoConta((CQUERY)->CONTA, MV_PAR02, "01") } )
    TRCell():New(oSection1	,"DIFERENCA"  	,,"Diferenca"		    ,"@E 999,999,999.99", 10,/*lPixel*/, {|| nSaldoC - (CQUERY)->SALDO } )

    oSection1:SetTotalInLine(.F.)

Return(oReport)

Static Function ReportPrint( oReport )

    Local CSQL := ""
    Local nTotSaldo := 0
    Local nTotVEnc  := 0
    Local nTotAVenc := 0
    Local nTotSalC := 0
    Local nSaldoC := 0
    Local nDif := 0
    Local nTotDif := 0        

    IF TCSPEXIST("SP_RELPOSCLI_CP_ANALITICO")
        LjMsgRun("Aguarde... Processando Posição Fornecedor dia "+DTOC(MV_PAR02),,{|| _aRet := TCSPEXEC("SP_RELPOSCLI_CP_ANALITICO", DTOS(MV_PAR02), MV_PAR03, MV_PAR04) })
    ENDIF

    oSection1:BeginQuery()

    CSQL := GetQuery()

    TCQUERY CSQL New Alias (CQUERY)

    oSection1:EndQuery()

    While (CQUERY)->(!EOF())

        If (MV_PAR06 == 1 .And. ((CQUERY)->SALDO > 0 .Or. (CQUERY)->TOTAL_VENCIDO > 0 .Or. (CQUERY)->TOTAL_A_VENCER > 0)) .Or. MV_PAR06 == 2

            nTotSaldo += (CQUERY)->SALDO
            nTotVEnc  += (CQUERY)->TOTAL_VENCIDO
            nTotAVenc += (CQUERY)->TOTAL_A_VENCER

            nSaldoC := SaldoConta((CQUERY)->CONTA, MV_PAR02, "01")
            
            nTotSalC += nSaldoC
            
            nDif := nSaldoC - (CQUERY)->SALDO
            
            nTotDif += nDif

            oSection1:Init()

            oSection1:PrintLine()

        EndIf

        (CQUERY)->(DBSkip())

    EndDo

    oSection1:Cell("CODFOR"	  		):SetValue("")
    oSection1:Cell("NOME"	   		):SetValue("")
    oSection1:Cell("CNPJ"	        ):SetValue("")
    oSection1:Cell("TOTAL_VENCIDO"  ):SetValue(nTotVEnc)
    oSection1:Cell("TOTAL_A_VENCER" ):SetValue(nTotAVenc)
    oSection1:Cell("SALDO_FINANC"  	):SetValue(nTotSaldo)    
    oSection1:Cell("SALDO_CONTABIL" ):SetValue(nTotSalC)
    oSection1:Cell("SALDO_CONTABIL" ):SetValue(nTotDif)    
    
    oSection1:PrintLine()

    oSection1:Finish()

    (cQuery)->(DbCloseArea())

Return()

Static Function GetQuery()

    Local CSQL := ""
    Local _cEMP := ""

    If MV_PAR01 == 1
        _cEMP := "0101"
    Else
        _cEMP := "0701"
    EndIf

    CSQL := " select "+CRLF
    CSQL += " A.CODFOR, "+CRLF
    CSQL += " NOME = (select top 1 A2_NOME from SA2010 SA2 (nolock) where A2_COD = A.CODFOR and SA2.D_E_L_E_T_=''), "+CRLF
    CSQL += " CNPJ = (select top 1 A2_CGC from SA2010 SA2 (nolock) where A2_COD = A.CODFOR and SA2.D_E_L_E_T_=''), "+CRLF
    CSQL += " SALDO = SUM(B.SALDO), "+CRLF
    CSQL += " TOTAL_VENCIDO = SUM(B.VALOR_VENCIDO), "+CRLF
    CSQL += " TOTAL_A_VENCER = SUM(B.VALOR_A_VENCER), "+CRLF
    
    CSQL += " CONTA = (SELECT TOP 1 A2_CONTA FROM SA2010 SA2 (NOLOCK) WHERE A2_COD = A.CODFOR AND SA2.D_E_L_E_T_='') "+CRLF
		
    CSQL += " from POSCLI_FORNECEDORES A "+CRLF
    CSQL += " join POSCLI_DATA_CP_ANALITICO B on A.CODFOR = B.CODFOR and A.LOJAFOR = B.LOJAFOR "+CRLF

    CSQL += " WHERE "+CRLF
    CSQL += " B.EMPFIL = '"+_cEMP+"' "+CRLF
    CSQL += " and B.DATAREF = '"+DTOS(MV_PAR02)+"' "+CRLF
    CSQL += " and A.CODFOR between '"+MV_PAR03+"' and '"+MV_PAR04+"' "+CRLF

    CSQL += " GROUP BY "+CRLF
    CSQL += " A.CODFOR "+CRLF  
    CSQL += " ORDER BY 1 "+CRLF  
 
Return(CSQL)

Static Function ValPerg()

    Local i,j,nX
    Local aTRegs := {}
    Local aHelpPor := {}
    Local aHelpEng := {}
    Local aHelpSpa := {}

    cPerg := PADR(cPerg,10)

    //DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
    aAdd(aTRegs,{"Empresa?"		        ,"N", 1,0,0,"C","","Biancogres","LM","","","","",""})
    aAdd(aTRegs,{"Dt.Referencia"		,"D", 8,0,0,"G","","","","","","","",""})
    aAdd(aTRegs,{"Fornecedor De"	    ,"C", 6,0,0,"G","","","","","","","SA2",""})
    aAdd(aTRegs,{"Fornecedor Ate"	    ,"C", 6,0,0,"G","","","","","","","SA2",""})
    aAdd(aTRegs,{"Tipo do Relatorio?"	,"N", 1,0,0,"C","","Protheus","Txt","","","","",""})
    aAdd(aTRegs,{"Imprime zerados?" 	,"N", 1,0,0,"C","","Não","Sim","","","","",""})
    
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