#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FRREPROG()

    Local oReport
    Local aParam := {}
    Local cName := "FRREPROG"
    Local cFileName := __cUserID +"_"+ cName

    Private oParam
    Private _cProcDe    := Space(GetSX3Cache("ZK8_NUMERO","X3_TAMANHO"))
    Private _cProcAte   := Space(GetSX3Cache("ZK8_NUMERO","X3_TAMANHO"))
    Private _dDatVDe    := CTOD(" ") // Data de
    Private _dDatVAte   := CTOD(" ") // Data ate
    Private _cCliDe     := Space(GetSX3Cache("A1_COD","X3_TAMANHO")) // Cli/Forn de
    Private _cCliAte    := Space(GetSX3Cache("A1_COD","X3_TAMANHO")) // Cli/Forn ate
    Private _cGrupoDe   := Space(GetSX3Cache("ZK8_GRPVEN","X3_TAMANHO")) // Grupo cliente de
    Private _cGrupoAte  := Space(GetSX3Cache("ZK8_GRPVEN","X3_TAMANHO")) // Grupo cliente ate
    Private _cFiltro    := "1"
    Private oJSon

    aAdd(aParam,{1,"Proc. De",_cProcDe,"@!",".T.","ZK8",".T.",50,.F.})
    aAdd(aParam,{1,"Proc. Ate",_cProcAte,"@!",".T.","ZK8",".T.",50,.F.})

    aAdd(aParam,{1,"Vencimento De",_dDatVDe,"@D",".T.",nil,".T.",50,.F.})
    aAdd(aParam,{1,"Vencimento Ate",_dDatVAte,"@D",".T.",nil,".T.",50,.F.})
    
    aAdd(aParam,{1,"Cliente De",_cCliDe,"@!",".T.","SA1",".T.",50,.F.})
    aAdd(aParam,{1,"Cliente Ate",_cCliAte,"@!",".T.","SA1",".T.",50,.F.})

    aAdd(aParam,{1,"Grupo Cliente De",_cGrupoDe,"@!",".T.","ACY",".T.",50,.F.})
    aAdd(aParam,{1,"Grupo Cliente Ate",_cGrupoAte,"@!",".T.","ACY",".T.",50,.F.})
    aAdd(aParam,{2,"Status",_cFiltro,{"1=Todos","2=Ativos","3=Cancelados","4=Baixados","5=FIDC Ativos","6=FIDC Prorrogados"},50,".T.",.T.})

    If ParamBox(aParam,"Parâmetros",nil,nil,nil,nil,nil,nil,nil,cName,.T.,.T.)

        lRet := .T.

        _cProcDe    := ParamLoad(cFileName,nil,1,Space(GetSX3Cache("ZK8_NUMERO","X3_TAMANHO")))
        _cProcAte   := ParamLoad(cFileName,nil,2,Replicate("Z",GetSX3Cache("ZK8_NUMERO","X3_TAMANHO")))

        _dDatVDe    := ParamLoad(cFileName,nil,3,dDataBase)
        _dDatVAte   := ParamLoad(cFileName,nil,4,dDataBase)

        _cCliDe     := ParamLoad(cFileName,nil,5,Space(GetSX3Cache("A1_COD","X3_TAMANHO")))
        _cCliAte    := ParamLoad(cFileName,nil,6,Replicate("Z",GetSX3Cache("A1_COD","X3_TAMANHO")))

        _cGrupoDe   := ParamLoad(cFileName,nil,7,Space(GetSX3Cache("ZK8_GRPVEN","X3_TAMANHO")))
        _cGrupoAte  := ParamLoad(cFileName,nil,8,Replicate("Z",GetSX3Cache("ZK8_GRPVEN","X3_TAMANHO")))
        _cFiltro    := ParamLoad(cFileName,nil,9,"1")

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

    oReport := TReport():New("FRREPROG",cTitRel,{|| },{|oReport| PrintReport(oReport,cQry)},cTitRel)

    oSecPrd := TRSection():New(oReport,"Cliente/Renegociação",cQry)
    TRCell():New(oSecPrd,"ZKC_NUMERO",cQry)
    TRCell():New(oSecPrd,"A1_COD",cQry)
    TRCell():New(oSecPrd,"A1_NOME",cQry)
    TRCell():New(oSecPrd,"A1_CGC",cQry)

    oSecPrd:SetLineStyle(.T.)

    oSecMov := TRSection():New(oSecPrd,"Títulos",cQry)
    /*TRCell():New(<oParent>,<cName>,<cAlias>,<cTitle>,<cPicture>,<nSize>,<lPixel>,<bBlock>,<cAlign>,<lLineBreak>,<cHeaderAlign>,<lCellBreak>,<nColSpace>,<lAutoSize>,<nClrBack>,<nClrFore>,<lBold>)*/
    TRCell():New(oSecMov,"ZKC_PREFIX",cQry,"Serie",GetSX3Cache("ZKC_PREFIX","X3_PICTURE"),CalcFieldSize("C",GetSX3Cache("ZKC_PREFIX","X3_TAMANHO"),0,"@!","Serie",/*oFont*/),.T.,nil,nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"ZKC_NUM",cQry,"Numero",GetSX3Cache("ZKC_NUM","X3_PICTURE"),CalcFieldSize("C",GetSX3Cache("ZKC_NUM","X3_TAMANHO"),0,"@!","Numero",/*oFont*/),.T.,nil,nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"ZKC_PARCEL",cQry,"Parcela",GetSX3Cache("ZKC_PARCEL","X3_PICTURE"),CalcFieldSize("C",GetSX3Cache("ZKC_PARCEL","X3_TAMANHO"),0,"@!","Parcela",/*oFont*/),.T.,nil,nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"ZKC_VALOR",cQry,nil,nil,30,nil,{||(cQry)->ZKC_VALOR},nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"ZKC_VENCTO",cQry,"Vencimento",nil,10,.F.,{||DTOC((cQry)->ZKC_VENCTO)},nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"DIAS",cQry,"Dias Prorrog.",nil,13,nil,{||(cQry)->DIAS},"RIGHT",nil,"RIGHT",nil,nil,.F.,nil,nil,nil) 
    TRCell():New(oSecMov,"ZKC_VENCCA",cQry,"Novo Vencimento",nil,15,.F.,{||DTOC((cQry)->ZKC_VENCCA)},nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    if (_cFiltro$"5|6")
        TRCell():New(oSecMov,"ZKC_OBSLIB",cQry,"Observacao","@!",CalcFieldSize("C",GetSX3Cache("ZKC_OBSLIB","X3_TAMANHO"),0,"@!","Observacao",/*oFont*/),.T.,{||oJSon:Get("Obs")},nil,nil,nil,nil,nil,.F.,nil,nil,nil) 
    endif
	
Return(oReport)

Static Function PrintReport(oReport,cQry)

    Local oSecPrd := oReport:Section(1)
    Local oSecMov := oReport:Section(1):Section(1)
    Local cSQL := ""
    Local cOBS

    Local cBanco := ""
    Local cAgencia := ""
    Local cConta := ""
    Local nTot := 0
    Local cStatus := ""

    cSQL := ""
    cSQL += " select "+CRLF

    cSQL += " A1_COD,"+CRLF
    cSQL += " A1_CGC,"+CRLF
    cSQL += " A1_NOME,"+CRLF
    cSQL += " ZK8_BANCO,"+CRLF
    cSQL += " ZK8_AGENCI,"+CRLF	
    cSQL += " ZK8_CONTA,"+CRLF
    cSQL += " ZKC_NUMERO,"+CRLF
    cSQL += " ZKC_PREFIX,"+CRLF
    cSQL += " ZKC_NUM,"+CRLF
    cSQL += " ZKC_PARCEL,"+CRLF
    cSQL += " ZKC_VALOR,"+CRLF
    cSQL += " ZK8_STATUS,"+CRLF
    cSQL += " ZKC_VENCTO,"+CRLF
    cSQL += " ZKC_STATUS,"+CRLF
    cSQL += " CAST(ZKC_DIAS AS VARCHAR) DIAS,"+CRLF
    cSQL += " ZKC_VENCCA,"+CRLF
    if (_cFiltro$"5|6")
		cSQL += " ZKC_TXJUR,"
		cSQL += " ZKC_JUROS,"
        cSQL += " ZKC_OBSLIB,"+CRLF
    endif
    cSQL += " JUROS = (select sum(ZKC_VALOR) from "+RetSQLName("ZKC")+" X where X.ZKC_NUMERO = ZKC.ZKC_NUMERO and X.ZKC_TIPO = 'JP' and X.D_E_L_E_T_=''),"+CRLF
    cSQL += " VENC_JUROS = (select max(ZKC_VENCTO) from "+RetSQLName("ZKC")+" X where X.ZKC_NUMERO = ZKC.ZKC_NUMERO and X.ZKC_TIPO = 'JP' and X.D_E_L_E_T_='') "+CRLF
    cSQL += " from "+RetSQLName("ZKC")+" ZKC "+CRLF
    cSQL += " join "+RetSQLName("SA1")+" SA1 on A1_FILIAL  = " + ValToSql(xFIlial("SA1")) + " AND A1_COD = ZKC_CLIFOR and A1_LOJA = ZKC_LOJA "+CRLF
    cSQL += " join "+RetSQLName("ZK8")+" ZK8 on ZK8_FILIAL = " + ValToSql(xFIlial("ZK8")) + " AND ZK8_NUMERO = ZKC_NUMERO "+CRLF
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

    ElseIf _cFiltro == "5" // FIDC Ativos

        cStatus := "F"

    ElseIf _cFiltro == "6" // FIDC Prorrogados

        cStatus := "P"

    EndIf

    If !Empty(cStatus)

        cSQL += " AND ZK8_STATUS = " + ValToSql(cStatus) + CRLF
        
    EndIf
    
    cSQL += " and ZKC.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and SA1.D_E_L_E_T_ = '' "+CRLF
    cSQL += " and ZK8.D_E_L_E_T_ = '' "+CRLF

    cSQL += " order by ZKC_NUMERO,ZKC_VENCCA "+CRLF

    TcQuery cSQL New Alias (cQry)

	TCSetField(cQry,"VENC_JUROS","D",8,0)
	TCSetField(cQry,"ZKC_VENCTO","D",8,0)
	TCSetField(cQry,"ZKC_VENCCA","D",8,0)
	TCSetField(cQry,"ZKC_VENCCA","D",8,0)

    oSecMov:SetParentQuery()
    oSecMov:SetParentFilter({|cParam| (cQry)->ZKC_NUMERO >= cParam .And. (cQry)->ZKC_NUMERO <= cParam},{|| (cQry)->ZKC_NUMERO})

    (cQry)->(DbGoTop())
    _cNum := (cQry)->ZKC_NUMERO
    _nJUROS := 0
    _dVENCJUR := dDataBase

    oSecPrd:Init()
    
    if (_cFiltro$"5|6")
        oJSon:=JSONArray():New()
    endif

    While (cQry)->(!Eof())

        oReport:SkipLine()  
        oReport:Say(oReport:Row(),oReport:Col(),"" )
        oReport:SkipLine()  
        oReport:Say(oReport:Row(),oReport:Col(),"Processo: "+ (cQry)->ZKC_NUMERO )
        oReport:SkipLine()
        oReport:Say(oReport:Row(),oReport:Col(),"Cod.Cliente: "+(cQry)->A1_COD )
        oReport:SkipLine()
        oReport:Say(oReport:Row(),oReport:Col(),"Nome Cliente: " +(cQry)->A1_NOME )
        oReport:SkipLine()
        oReport:Say(oReport:Row(),oReport:Col(),"CNPJ: " +(cQry)->A1_CGC )

        If (cQry)->((ZK8_STATUS=="A").Or.(ZK8_STATUS=="F"))

            oReport:SkipLine()
            
            oReport:Say(oReport:Row(),oReport:Col(),"Situação: " + "Ativo" )
            oReport:SkipLine()
            oReport:SkipLine()

        ElseIf ((cQry)->ZK8_STATUS=="C")

            oReport:SkipLine()
            
            oReport:Say(oReport:Row(),oReport:Col(),"Situação: " + "Cancelado" )
            oReport:SkipLine()
            oReport:SkipLine()

        ElseIf (cQry)->((ZK8_STATUS=="B").Or.(ZK8_STATUS=="P"))

            oReport:SkipLine()
            
            oReport:Say(oReport:Row(),oReport:Col(),"Situação: " + "Baixado" )
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

            oSecMov:Cell("ZKC_PREFIX"):SetValue((cQry)->ZKC_PREFIX)
            oSecMov:Cell("ZKC_NUM"):SetValue((cQry)->ZKC_NUM)
            oSecMov:Cell("ZKC_PARCEL"):SetValue((cQry)->ZKC_PARCEL)
            oSecMov:Cell("ZKC_VALOR"):SetValue((cQry)->ZKC_VALOR)
            oSecMov:Cell("ZKC_VENCTO"):SetValue(DTOC((cQry)->ZKC_VENCTO))
            oSecMov:Cell("DIAS"):SetValue((cQry)->DIAS)
            oSecMov:Cell("ZKC_VENCCA"):SetValue(DTOC((cQry)->ZKC_VENCCA))
            if (_cFiltro$"5|6")
                cOBS:=(cQry)->ZKC_OBSLIB
                if (empty(cOBS))
                    oJSon:Set("Juros","Nao")
                    oJSon:Set("txJuros",0)
                    oJSon:Set("vlJuros",0)
                    oJSon:Set("Obs","")
                else
                    oJSon:FromJson(cOBS)
		            if ((cQry)->ZKC_TXJUR>0)
                        oJSon:Set("txJuros",(cQry)->ZKC_TXJUR)
                    endif
                    if ((cQry)->ZKC_JUROS>0)
                        oJSon:Set("vlJuros",(cQry)->ZKC_JUROS)
                    endif
                    _nJUROS+=oJSon:get("vlJuros",0)
                endif
                oSecMov:Cell("ZKC_OBSLIB"):SetValue(oJSon:Get("Obs"))
            endif
            oSecMov:PrintLine()

            (cQry)->(DbSkip())
            
        EndDo

        oSecMov:Cell("ZKC_PREFIX"):SetValue("")
        oSecMov:Cell("ZKC_NUM"):SetValue("")
        oSecMov:Cell("ZKC_PARCEL"):SetValue("")
        oSecMov:Cell("ZKC_VALOR"):SetValue(nTot)
        oSecMov:Cell("ZKC_VENCTO"):SetValue("")
        oSecMov:Cell("DIAS"):SetValue("")
        oSecMov:Cell("ZKC_VENCCA"):SetValue("")
        if (_cFiltro$"5|6")
            oSecMov:Cell("ZKC_OBSLIB"):SetValue("")
        endif
        oSecMov:PrintLine()

        oSecMov:Finish()

        oReport:SkipLine()
        if (_cFiltro$"5|6")
            oReport:Say(oReport:Row(),oReport:Col(),"Juros (%):   "+ Transform(oJSon:Get("txJuros"),"@E 999,999,999.99") )
            oReport:SkipLine()
            oReport:Say(oReport:Row(),oReport:Col(),"Juros Total: "+ Transform(_nJUROS,"@E 999,999,999.99") )
            oReport:SkipLine()
        else    
            oReport:Say(oReport:Row(),oReport:Col(),"Juros Total: "+ Transform(_nJUROS,"@E 999,999,999.99") )
            oReport:SkipLine()
            oReport:Say(oReport:Row(),oReport:Col(),"Data Limite Pgto Juros: "+DTOC(_dVENCJUR))
            oReport:SkipLine()
        endif

    EndDo

    oSecPrd:Finish()

    (cQry)->(DbCloseArea())

Return()
