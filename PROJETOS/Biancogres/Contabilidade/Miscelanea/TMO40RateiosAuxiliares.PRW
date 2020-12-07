#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} FMO4TE01
@description O 4.0 Cadastro de Rateios
@author Fernando Rocha
@since 18/04/2020
@version 1.0
@type function
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN1 "LIN1"
#DEFINE LIN2 "LIN2"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_1 15
#DEFINE PER_LIN_2 85

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND1 "WND1"
#DEFINE WND2 "WND2"

Class TMO40RateiosAuxiliares From LongClassName

    Data cCodRat
    Data cAno
    Data cMes

    Data oDlg
    Data oBrwRat
    Data oBrwOrc
    Data aColsReal
    Data aColsOrc

    Data oSayOrc
    Data cSayOrc

    Method New() Constructor

    Method ShowReal()
    Method LoadReal()
    Method SaveReal()
    Method ProcReal()

    Method ShowOrc()
    Method LoadOrc()
    Method SaveOrc()
    Method ProcOrc()

    Method LdVlrQry()
    Method GetVlrQry()

    Method LdOrcQry()
    Method LdOrcQryPr()
    Method GetOrcQry()

EndClass

Method New() Class TMO40RateiosAuxiliares

    ::cCodRat   := Space(3)
    ::cAno      := Space(4)
    ::cMes      := Space(2)

    ::oDlg := Nil
    ::oBrwRat := Nil
    ::oBrwOrc := Nil
    ::aColsReal := {}
    ::aColsOrc := {}

    ::oSayOrc := NIL
    ::cSayOrc := Space(200)

Return()

//PROCESSAR AS BASES E RATEIOS DO REALIZADO
Method ProcReal() Class TMO40RateiosAuxiliares

    Local I
    Local _aRet
    Local _cSQL
    Local aCols := ::oBrwRat:ACols

    IF TCSPEXIST("SP_MO40_BASERATEIO_PROD")
        LjMsgRun("Aguarde... Processando Bases Rateios Realizado MO 4.0.",,{|| _aRet := TCSPEXEC("SP_MO40_BASERATEIO_PROD", ::cAno, ::cMes, CUSERNAME) })
    ENDIF

    IF TCSPEXIST("SP_MO40_CALC_RATEIO")
        LjMsgRun("Aguarde... Processando Cálculo Rateios Realizado MO 4.0.",,{|| _aRet := TCSPEXEC("SP_MO40_CALC_RATEIO", ::cAno, ::cMes, CUSERNAME) })
    ENDIF

    For I := 1 To Len(aCols)

        ZFB->(DbSetOrder(1))
        If ZFB->(DbSeek(XFilial("ZFB")+aCols[I][1])) .And. ZFB->ZFB_ORIGEM == "3" /*SP*/ .And. !Empty(ZFB->ZFB_QUERY)

            cSql := AllTrim(ZFB->ZFB_QUERY)
            _cSQL := Replace(_cSQL,"@ANO",::cAno)
            _cSQL := Replace(_cSQL,"@MES",::cMes)
            _cSQL := Replace(_cSQL,"@USERNAME",CUSERNAME)

            LjMsgRun("Aguarde... Processando Cálculo Rateios Realizado MO 4.0 => SP: "+_cSQL,,{|| TcSQLExec(_cSQL) })

        EndIf

    Next I

Return()


Method ShowReal() Class TMO40RateiosAuxiliares

    Local aHBrwRat

    // Cria Dialog
    ::oDlg := MsDialog():New(0, 0, 400, 800, "Valores de Rateios Fixos MO 4.0 - REALIZADO",,,,DS_MODALFRAME,,,,,.T.)
    ::oDlg:lCentered := .T.
    ::oDlg:lEscClose := .T.

    // Layer
    oLayer := FWLayer():New()
    oLayer:Init(::oDlg, .F., .T.)

    // Adiciona linha ao Layer
    oLayer:AddLine(LIN1, PER_LIN_1, .F.)
    // Adiciona coluna ao Layer
    oLayer:AddCollumn(COL, PER_COL, .T., LIN1)

    // Painel Ativo
    oPanel := oLayer:getLinePanel(LIN1)

    oSay1      := TSay():New( 10,10,{||"Ano:"}, oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
    oGet1      := TGet():New( 10,30,{|u| If(PCount()>0, ::cAno := u, ::cAno)} , oPanel,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","::cAno",,)

    oSay2      := TSay():New( 10,80,{||"Mês:"}, oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
    oGet2      := TGet():New( 10,100,{|u| If(PCount()>0, ::cMes := u, ::cMes)} , oPanel,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","::cMes",,)

    oBtn1 := TBUTTON():Create(oPanel)
    oBtn1:cCaption	:= "Carregar"
    oBtn1:nWidth 	:= 60
    oBtn1:nHeight 	:= 10
    oBtn1:cTooltip 	:= "Carregar Rateios do Mês"
    oBtn1:bAction 	:= {|| ::LoadReal() }

    oBtn4 := TBUTTON():Create(oPanel)
    oBtn4:cCaption	:= "Query"
    oBtn4:nWidth 	:= 60
    oBtn4:nHeight 	:= 10
    oBtn4:cTooltip 	:= "Carrega valores da query"
    oBtn4:bAction 	:= {|| ::LdVlrQry() }

    oBtn2 := TBUTTON():Create(oPanel)
    oBtn2:cCaption	:= "Salvar"
    oBtn2:nWidth 	:= 60
    oBtn2:nHeight 	:= 10
    oBtn2:cTooltip 	:= "Salvar/Fechar a Janela"
    oBtn2:bAction 	:= {|| ::SaveReal() }

    oBtn3 := TBUTTON():Create(oPanel)
    oBtn3:cCaption	:= "Fechar"
    oBtn3:nWidth 	:= 60
    oBtn3:nHeight 	:= 10
    oBtn3:cTooltip 	:= "Cancelar/Fechar a Janela"
    oBtn3:bAction 	:= {|| ::oDlg:End()}

    oBtn3:Align		:= CONTROL_ALIGN_RIGHT
    oBtn2:Align		:= CONTROL_ALIGN_RIGHT
    oBtn4:Align		:= CONTROL_ALIGN_RIGHT
    oBtn1:Align		:= CONTROL_ALIGN_RIGHT

    // Adiciona linha ao Layer
    oLayer:AddLine(LIN2, PER_LIN_2, .F.)
    // Adiciona coluna ao Layer
    oLayer:AddCollumn(COL, PER_COL, .T., LIN2)
    // Adiciona janela ao Layer
    oLayer:AddWindow(COL, WND2, "Rateios", 100, .F. ,.T.,, LIN2, { || })

    // Painel Ativo
    oPanel := oLayer:GetWinPanel(COL, WND2, LIN2)

    aHBrwRat := {}
    aAdd(aHBrwRat,{"Codigo"     ,"CODRAT" ,"@!"                   ,3  ,0,,,"C",,})
    aAdd(aHBrwRat,{"Descrição"  ,"DESRAT" ,"@!"                   ,40 ,0,,,"C",,})
    aAdd(aHBrwRat,{"Valor"      ,"VALRAT" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})

    aEdits := {"VALRAT"}

    AAdd(::aColsReal, Array(Len(aHBrwRat)+1))
    ::oBrwRat := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE + GD_DELETE, 'AllwaysTrue()', 'AllwaysTrue()','',aEdits,,,'AllwaysTrue()','','AllwaysTrue()',oPanel, aHBrwRat, ::aColsReal )
    ::oBrwRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    // Abre Janela
    ::oDlg:Activate()

Return


Method LoadReal() Class TMO40RateiosAuxiliares

    Local _cAliasTmp
    Local aAux
    Local _cAno := ::cAno
    Local _cMes := ::cMes

    _cAliasTmp := GetNextAlias()
    BeginSql Alias _cAliasTmp
		%NoParser%

			select
			ZFB_CODIGO,
            ZFB_DESCR,
			ZFC_VALOR = isnull(ZFC_VALOR,0)
            
			from ZFB010 ZFB 
            left join ZFC010 ZFC on 
                ZFB_CODIGO = ZFC_CODIGO
                and ZFC_VALOR <> 0
                and ZFC_ANO = %Exp:_cAno%
                and ZFC_MES = %Exp:_cMes%
                and ZFC_TIPVAL = 'R'
                and ZFC.D_E_L_E_T_=''
			
			where 
			ZFB_TIPAPL in ('R','X')
			and ZFB.D_E_L_E_T_=''
            order by ZFB_CODIGO

    ENDSQL

    ::aColsReal := {}

    (_cAliasTmp)->(DbGoTop())
    While !(_cAliasTmp)->(Eof())

        aAux := {}
        AAdd(aAux, (_cAliasTmp)->ZFB_CODIGO)
        AAdd(aAux, (_cAliasTmp)->ZFB_DESCR)
        AAdd(aAux, (_cAliasTmp)->ZFC_VALOR)
        AAdd(aAux, .F.)

        AAdd(::aColsReal, aAux)

        (_cAliasTmp)->(DbSkip())
    EndDo
    (_cAliasTmp)->(DbCloseArea())

    ::oBrwRat:ACols := ::aColsReal
    ::oBrwRat:oBrowse:Refresh()

Return


Method SaveReal() Class TMO40RateiosAuxiliares

    Local aCols := ::oBrwRat:ACols
    Local I

    ZFC->(DbSetOrder(1))

    If !Empty(::cAno) .And. !Empty(::cMes) .And. Len(::cAno) == 4 .and. Len(::cMes) == 2

        For I := 1 To Len(aCols)

            If ZFC->(DbSeek(XFilial("ZFC")+::cAno+::cMes+aCols[I][1]+"R"))

                RecLock("ZFC",.F.)
                ZFC->ZFC_VALOR := aCols[I][3]
                ZFC->(MsUnlock())

            Else

                RecLock("ZFC",.T.)
                ZFC->ZFC_FILIAL := XFilial("ZFC")
                ZFC->ZFC_ANO    := ::cAno
                ZFC->ZFC_MES    := ::cMes
                ZFC->ZFC_CODIGO := aCols[I][1]
                ZFC->ZFC_TIPVAL := "R"
                ZFC->ZFC_USER   := CUSERNAME
                ZFC->ZFC_VALOR  := aCols[I][3]
                ZFC->(MsUnlock())

            EndIf

        Next I

        If MsgNoYes("Deseja Processar os Rateios Relizados " + ::cMes + "/"+ ::cAno +" MO 4.0 Agora?")

            LjMsgRun("Aguarde... Processando Rateios Relizados MO 4.0.",,{|| ::ProcReal() })

        EndIf

    EndIf

    ::oDlg:End()

Return


Method LoadOrc() Class TMO40RateiosAuxiliares

    Local _cAliasTmp
    Local _cAZFCTmp
    Local aAux
    Local _cAno := ::cAno
    Local _cMes
    Local nX


    _cAliasTmp := GetNextAlias()
    //BeginSql Alias _cAliasTmp
    //select top 1 ZB5_VERSAO, ZB5_REVISA from ZB5010 where ZB5_ANOREF = %Exp:_cAno% and ZB5_TPORCT = 'RECEITA' and D_E_L_E_T_='' order by ZB5_REVISA desc
    //EndSql

    BeginSql Alias _cAliasTmp
        select top 1 ZBM_VERSAO, ZBM_REVISA, ZBM_SEQUEN from ZBM010 where ZBM_ANOREF = %Exp:_cAno% and ZBM_ATIVO = 'S' and D_E_L_E_T_='' order by 1 desc, 2 desc, 3 desc
    EndSql

    If !(_cAliasTmp)->(Eof())

        ::cSayOrc := "ORÇAMENTO VERSÃO: "+AllTrim((_cAliasTmp)->ZBM_VERSAO)+" / REVISÃO: "+AllTrim((_cAliasTmp)->ZBM_REVISA)+" / SEQ: "+AllTrim((_cAliasTmp)->ZBM_SEQUEN)
        ::oSayOrc:Refresh()

    EndIf
    (_cAliasTmp)->(DbCloseArea())


    _cAliasTmp := GetNextAlias()
    BeginSql Alias _cAliasTmp
		%NoParser%

        select
        ZFB_CODIGO,
        ZFB_DESCR
        
        from ZFB010 ZFB             			
        where 
        ZFB_TIPAPL in ('O','X')
        and ZFB.D_E_L_E_T_=''
        order by ZFB_CODIGO

    ENDSQL

    ::aColsOrc := {}

    (_cAliasTmp)->(DbGoTop())
    While !(_cAliasTmp)->(Eof())

        aAux := {}
        AAdd(aAux, (_cAliasTmp)->ZFB_CODIGO)
        AAdd(aAux, (_cAliasTmp)->ZFB_DESCR)

        For nX := 1 To 12

            _cMes := StrZero(nX,2)

            _cAZFCTmp := GetNextAlias()
            BeginSql Alias _cAZFCTmp
		    %NoParser%

			select ZFC_VALOR
			from ZFC010 ZFC 
            where ZFC_CODIGO = %Exp:(_cAliasTmp)->ZFB_CODIGO%
            and ZFC_VALOR <> 0
            and ZFC_ANO = %Exp:_cAno%
            and ZFC_MES = %Exp:_cMes%
            and ZFC_TIPVAL = 'O'
            and ZFC.D_E_L_E_T_=''

            ENDSQL

            If !(_cAZFCTmp)->(Eof())

                AAdd(aAux, (_cAZFCTmp)->ZFC_VALOR)
            Else

                AAdd(aAux, 0)

            EndIf
            (_cAZFCTmp)->(DbCloseArea())

        Next nX

        AAdd(aAux, .F.)
        AAdd(::aColsOrc, aAux)

        (_cAliasTmp)->(DbSkip())
    EndDo
    (_cAliasTmp)->(DbCloseArea())

    ::oBrwOrc:ACols := ::aColsOrc
    ::oBrwOrc:oBrowse:Refresh()

Return


Method ShowOrc() Class TMO40RateiosAuxiliares

    Local aHBrwRat

    // Cria Dialog
    ::oDlg := MsDialog():New(0, 0, 400, 1000, "Valores de Rateios Fixos MO 4.0 - ORÇAMENTO",,,,DS_MODALFRAME,,,,,.T.)
    ::oDlg:lCentered := .T.
    ::oDlg:lEscClose := .T.

    // Layer
    oLayer := FWLayer():New()
    oLayer:Init(::oDlg, .F., .T.)

    // Adiciona linha ao Layer
    oLayer:AddLine(LIN1, PER_LIN_1, .F.)
    // Adiciona coluna ao Layer
    oLayer:AddCollumn(COL, PER_COL, .T., LIN1)

    // Painel Ativo
    oPanel := oLayer:getLinePanel(LIN1)

    oSay1      := TSay():New( 10,10,{||"Ano:"}, oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
    oGet1      := TGet():New( 10,30,{|u| If(PCount()>0, ::cAno := u, ::cAno)} , oPanel,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","::cAno",,)

    ::oSayOrc  := TSay():New( 10,80,{|| ::cSayOrc }, oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,008)

    oBtn1 := TBUTTON():Create(oPanel)
    oBtn1:cCaption	:= "Carregar"
    oBtn1:nWidth 	:= 60
    oBtn1:nHeight 	:= 10
    oBtn1:cTooltip 	:= "Carregar Rateios do Ano"
    oBtn1:bAction 	:= {|| ::LoadOrc() }

    oBtn4 := TBUTTON():Create(oPanel)
    oBtn4:cCaption	:= "Query"
    oBtn4:nWidth 	:= 60
    oBtn4:nHeight 	:= 10
    oBtn4:cTooltip 	:= "Carrega valores da query"
    oBtn4:bAction 	:= {|| ::LdOrcQry() }

    oBtn2 := TBUTTON():Create(oPanel)
    oBtn2:cCaption	:= "Salvar"
    oBtn2:nWidth 	:= 60
    oBtn2:nHeight 	:= 10
    oBtn2:cTooltip 	:= "Salvar/Fechar a Janela"
    oBtn2:bAction 	:= {|| ::SaveOrc() }

    oBtn3 := TBUTTON():Create(oPanel)
    oBtn3:cCaption	:= "Fechar"
    oBtn3:nWidth 	:= 60
    oBtn3:nHeight 	:= 10
    oBtn3:cTooltip 	:= "Cancelar/Fechar a Janela"
    oBtn3:bAction 	:= {|| ::oDlg:End()}

    oBtn3:Align		:= CONTROL_ALIGN_RIGHT
    oBtn2:Align		:= CONTROL_ALIGN_RIGHT
    oBtn4:Align		:= CONTROL_ALIGN_RIGHT
    oBtn1:Align		:= CONTROL_ALIGN_RIGHT

    // Adiciona linha ao Layer
    oLayer:AddLine(LIN2, PER_LIN_2, .F.)
    // Adiciona coluna ao Layer
    oLayer:AddCollumn(COL, PER_COL, .T., LIN2)
    // Adiciona janela ao Layer
    oLayer:AddWindow(COL, WND2, "Rateios", 100, .F. ,.T.,, LIN2, { || })

    // Painel Ativo
    oPanel := oLayer:GetWinPanel(COL, WND2, LIN2)

    aHBrwRat := {}
    aAdd(aHBrwRat,{"Codigo"     ,"CODRAT"   ,"@!"                   ,3  ,0,,,"C",,})
    aAdd(aHBrwRat,{"Descrição"  ,"DESRAT"   ,"@!"                   ,40 ,0,,,"C",,})
    aAdd(aHBrwRat,{"Janeiro"    ,"VALORC01" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Fevereiro"  ,"VALORC02" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Março"      ,"VALORC03" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Abril"      ,"VALORC04" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Maio"       ,"VALORC05" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Junho"      ,"VALORC06" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Julho"      ,"VALORC07" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Agosto"     ,"VALORC08" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Setembro"   ,"VALORC09" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Outubro"    ,"VALORC10" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Novembro"   ,"VALORC11" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})
    aAdd(aHBrwRat,{"Dezembro"   ,"VALORC12" ,"@E 999,999,999.99"    ,15 ,2,"AllwaysTrue()",,"N",,})

    aEdits := {"VALORC01","VALORC02","VALORC03","VALORC04","VALORC05","VALORC06","VALORC07","VALORC08","VALORC09","VALORC10","VALORC11","VALORC12"}

    AAdd(::aColsOrc, Array(Len(aHBrwRat)+1))
    ::oBrwOrc := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE + GD_DELETE, 'AllwaysTrue()', 'AllwaysTrue()','',aEdits,,,'AllwaysTrue()','','AllwaysTrue()',oPanel, aHBrwRat, ::aColsOrc )
    ::oBrwOrc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    // Abre Janela
    ::oDlg:Activate()

Return


Method SaveOrc() Class TMO40RateiosAuxiliares

    Local aCols := ::oBrwOrc:ACols
    Local I
    Local nX
    Local _cMes

    ZFC->(DbSetOrder(1))

    If !Empty(::cAno) .And. Len(::cAno) == 4

        For I := 1 To Len(aCols)

            For nX := 1 To 12

                _cMes := StrZero(nX,2)

                If ZFC->(DbSeek(XFilial("ZFC")+::cAno+_cMes+aCols[I][1]+"O"))

                    RecLock("ZFC",.F.)
                    ZFC->ZFC_VALOR := aCols[I][2+nX]
                    ZFC->(MsUnlock())

                Else

                    RecLock("ZFC",.T.)
                    ZFC->ZFC_FILIAL := XFilial("ZFC")
                    ZFC->ZFC_ANO    := ::cAno
                    ZFC->ZFC_MES    := _cMes
                    ZFC->ZFC_CODIGO := aCols[I][1]
                    ZFC->ZFC_TIPVAL := "O"
                    ZFC->ZFC_USER   := CUSERNAME
                    ZFC->ZFC_VALOR  := aCols[I][2+nX]
                    ZFC->(MsUnlock())

                EndIf

            Next nX

        Next I

        If MsgNoYes("Deseja Processar os Rateios do Orcamento " + ::cAno +" MO 4.0 Agora?")

            LjMsgRun("Aguarde... Processando Rateios Orcamento MO 4.0.",,{|| ::ProcOrc() })

        EndIf

    EndIf

    ::oDlg:End()

Return

//PROCESSAR AS BASES E RATEIOS DO ORCAMENTO
Method ProcOrc() Class TMO40RateiosAuxiliares

    Local I
    Local _aRet
    Local aCols := ::oBrwOrc:ACols
    Local _cSQL

    IF TCSPEXIST("SP_MO40_BASERATEIO_ORC")
        LjMsgRun("Aguarde... Processando Bases Rateios Orçados MO 4.0.",,{|| _aRet := TCSPEXEC("SP_MO40_BASERATEIO_ORC", ::cAno, CUSERNAME) })
    ENDIF

    IF TCSPEXIST("SP_MO40_CALC_RATEIO_ORC")
        LjMsgRun("Aguarde... Processando Cálculo Rateios Orçados MO 4.0.",,{|| _aRet := TCSPEXEC("SP_MO40_CALC_RATEIO_ORC", ::cAno, CUSERNAME) })
    ENDIF

    For I := 1 To Len(aCols)

        ZFB->(DbSetOrder(1))
        If ZFB->(DbSeek(XFilial("ZFB")+aCols[I][1])) .And. ZFB->ZFB_ORIGEM == "3" /*SP*/ .And. !Empty(ZFB->ZFB_QRYORC)

            cSql := AllTrim(ZFB->ZFB_QRYORC)
            _cSQL := Replace(_cSQL,"@ANO",::cAno)
            _cSQL := Replace(_cSQL,"@MES",::cMes)
            _cSQL := Replace(_cSQL,"@USERNAME",CUSERNAME)

            LjMsgRun("Aguarde... Processando Cálculo Rateios Orçados MO 4.0 => SP: "+_cSQL,,{|| TcSQLExec(_cSQL) })

        EndIf

    Next I

Return()


//BUSCAR VALOR DE RATEIO DE QUERY PARA A TELA
Method LdVlrQry() Class TMO40RateiosAuxiliares

    Local aCols := ::oBrwRat:ACols
    Local I

    ZFC->(DbSetOrder(1))

    If !Empty(::cAno) .And. !Empty(::cMes) .And. Len(::cAno) == 4 .and. Len(::cMes) == 2

        For I := 1 To Len(aCols)

            ::cCodRat := aCols[I][1]

            ZFB->(DbSetOrder(1))
            If ZFB->(DbSeek(XFilial("ZFB")+::cCodRat)) .And. ZFB->ZFB_ORIGEM == "1" .And. !Empty(ZFB->ZFB_QUERY)

                _nVal := ::GetVlrQry()
                aCols[I][3] := _nVal

            EndIf

        Next I

        ::oBrwRat:ACols := aCols
        ::oBrwRat:oBrowse:Refresh()

    ENDIF

Return

//BUSCAR VALOR DE RATEIO DE QUERY
Method GetVlrQry() Class TMO40RateiosAuxiliares

    Local dDataIni
    Local dDataFim
    Local cAliasTmp
    Local nValRet := 0

    If !Empty(::cCodRat) .And. !Empty(::cAno) .And. !Empty(::cMes) .And. Len(::cAno) == 4 .And. Len(::cMes) == 2

        ZFB->(DbSetOrder(1))
        If ZFB->(DbSeek(XFilial("ZFB")+::cCodRat)) .And. ZFB->ZFB_ORIGEM == "1" .And. !Empty(ZFB->ZFB_QUERY)

            _cSQL := ZFB->ZFB_QUERY

            dDataIni := STOD(::cAno+::cMes+"01")
            dDataFim := LastDay(dDataIni)

            _cSQL := Replace(_cSQL,"@DATAINI",DTOS(dDataIni))
            _cSQL := Replace(_cSQL,"@DATAFIM",DTOS(dDataFim))

            cAliasTmp := GetNextAlias()
            TcQuery _cSQL New Alias (cAliasTmp)

            If !(cAliasTmp)->(Eof())

                If ValType(&("(cAliasTmp)->"+(cAliasTmp)->(Field(1)))) == "N"

                    nValRet := &("(cAliasTmp)->"+(cAliasTmp)->(Field(1)))

                EndIf

            EndIf
            (cAliasTmp)->(DbCloseArea())

        EndIf

    ENDIF

Return(nValRet)


Method LdOrcQry() Class TMO40RateiosAuxiliares

    LjMsgRun("Aguarde... Processando Querys Rateios Orçados MO 4.0.",,{|| ::LdOrcQryPr() })

RETURN

Method LdOrcQryPr() Class TMO40RateiosAuxiliares

    Local aCols := ::oBrwOrc:ACols
    Local I, nX
    Local _cMes

    ZFC->(DbSetOrder(1))

    If !Empty(::cAno) .And. Len(::cAno) == 4

        For I := 1 To Len(aCols)

            ::cCodRat := aCols[I][1]

            ZFB->(DbSetOrder(1))
            If ZFB->(DbSeek(XFilial("ZFB")+::cCodRat)) .And. ZFB->ZFB_ORIGEM == "1" .And. !Empty(ZFB->ZFB_QRYORC)

                For nX := 1 To 12

                    _cMes := StrZero(nX,2)
                    ::cMes := _cMes

                    _nVal := ::GetOrcQry()
                    aCols[I][2+nX] := _nVal

                Next nX


            EndIf

        Next I

        ::oBrwOrc:ACols := aCols
        ::oBrwOrc:oBrowse:Refresh()

    ENDIF

Return


Method GetOrcQry() Class TMO40RateiosAuxiliares

    Local dDataIni
    Local dDataFim
    Local cAliasTmp
    Local nValRet := 0

    If !Empty(::cCodRat) .And. !Empty(::cAno) .And. !Empty(::cMes) .And. Len(::cAno) == 4 .And. Len(::cMes) == 2

        ZFB->(DbSetOrder(1))
        If ZFB->(DbSeek(XFilial("ZFB")+::cCodRat)) .And. ZFB->ZFB_ORIGEM == "1" .And. !Empty(ZFB->ZFB_QRYORC)

            _cSQL := ZFB->ZFB_QRYORC

            dDataIni := STOD(::cAno+::cMes+"01")
            dDataFim := LastDay(dDataIni)

            _cSQL := Replace(_cSQL,"@DATAINI",DTOS(dDataIni))
            _cSQL := Replace(_cSQL,"@DATAFIM",DTOS(dDataFim))

            _cAno := ::cAno

            cAliasTmp := GetNextAlias()
            BeginSql Alias cAliasTmp

                select top 1 ZB5_VERSAO, ZB5_REVISA from ZB5010 where ZB5_ANOREF = %Exp:_cAno% and ZB5_TPORCT = 'RECEITA' and D_E_L_E_T_='' order by ZB5_REVISA desc

            EndSql

            If !(cAliasTmp)->(Eof())

                _cSQL := Replace(_cSQL,"@ORCVER", AllTrim((cAliasTmp)->ZB5_VERSAO))
                _cSQL := Replace(_cSQL,"@ORCREV", AllTrim((cAliasTmp)->ZB5_REVISA))

            EndIf
            (cAliasTmp)->(DbCloseArea())


            cAliasTmp := GetNextAlias()
            TcQuery _cSQL New Alias (cAliasTmp)

            If !(cAliasTmp)->(Eof())

                If ValType(&("(cAliasTmp)->"+(cAliasTmp)->(Field(1)))) == "N"

                    nValRet := &("(cAliasTmp)->"+(cAliasTmp)->(Field(1)))

                EndIf

            EndIf
            (cAliasTmp)->(DbCloseArea())

        EndIf

    ENDIF

Return(nValRet)