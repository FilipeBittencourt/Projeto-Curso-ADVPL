#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE07
@description Tela cadastro do SELLOUT dos clientes x produtos - Projeto Pedido Automatico
@author Fernando Rocha
@since 24/07/2019
@type function
/*/
User Function FPATTE07()

    Local aCores
    Private xImpDh := .F.
    Private wdProc := ""
    Private cCadastro := "SELLOUT PARCIAL CLIENTE X PRODUTO"
    Private aRotina
    Private lRunJob := .F.
    Private aIndScr := {}
    Private cListCli
    Private cCondicao

    aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
        {"Visualizar"   	,'AxVisual',0, 2},;
        {"Incluir"   		,'U_FPTE07MN(3)',0, 3},;
        {"Alterar"   		,'U_FPTE07MN(4)',0, 4},;
        {"Excluir Linha"   	,'U_FPTE07MN(5)',0, 5},;
        {"Excluir SellOut" 	,'U_FPAT07DE',0, 4},;
        {"Import.Excel" ,'Execblock("FPAT07EX" ,.F.,.F.,"C")',0, 3}}

    dbSelectArea("ZAW")

    If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) )
        FilterBrow()
        mBrowse(6,1,22,75, "ZAW", , , , , ,aCores, , , , , , , , , , , , cCondicao)
    Else
        mBrowse(6,1,22,75, "ZAW", , , , , ,aCores)
    EndIf

EndFilBrw("ZAG",aIndScr)

If ( lRunJob )
    U_EXEJBSQL("HERMES", "PEDAUT->Carga_Cliente_SellOut_Parcial", "Sincronizando Dados com BI")
EndIf

Return

Static Function FilterBrow()

    cListCli := U_FPATVCLI()

    cCondicao := "ZAW_CODCLI $ '"+cListCli+"'"

Return

User Function FPTE07MN(nOpt)

    Local lRet   	:= .T.

    If ( nOpt == 4)
        lRet   := AxAltera( "ZAW" , ZAW->(RecNo()), nOpt ) == 1
    ElseIf ( nOpt == 3)
        lRet   := AxInclui( "ZAW" , ZAW->(RecNo()), nOpt ) == 1
    ElseIf ( nOpt == 5)
        lRet   := AxDeleta( "ZAW" , ZAW->(RecNo()), nOpt ) == 2
    EndIf

    If (!lRunJob)
        lRunJob := lRet
    EndIf

Return


/*/{Protheus.doc} FPAT07EX
@description Funcao para importar planilha Excel para cadastro de SellOut de Clientes
/*/
User Function FPAT07EX

    Local aSays	   		:= {}
    Local aButtons 		:= {}
    Local lConfirm 		:= .F.
    Private cArquivo	:= space(500)
    Private cPCliente	:= space(6)
    Private cPLoja		:= space(2)
    Private cPData      := CTOD(" ")

    fPergunte()

    AADD(aSays, OemToAnsi("Importação de Planilha SELL OUT PARCIAL de Clientes"))
    AADD(aSays, OemToAnsi("Deseja Continuar?"))

    AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
    AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
    AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

    FormBatch( OemToAnsi('Importação de Sell Out PARCIAL de Clientes X Produtos'), aSays, aButtons ,,,500)

    If lConfirm

        If !empty(cArquivo) .and. File(cArquivo)
            Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
        Else
            MsgStop('Informe o arquivo valido para importação!')
        EndIf

    EndIf

Return

//Parametros
Static Function fPergunte()

    Local aPergs 	:= {}
    Local cLoad	    := 'FPAT07EXC' + cEmpAnt
    Local cFileName := RetCodUsr() +"_"+ cLoad
    cArquivo		:= space(500)

    aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )
    aAdd( aPergs ,{1, "CLIENTE", space(6), , ".T.", "SA1" ,".T.", 4, .F.})
    aAdd( aPergs ,{1, "LOJA", space(2), , ".T.", ,".T.", 4, .F.})
    aAdd( aPergs ,{1, "PARCIAL ATÉ A DATA:", CTOD(" "), , ".T.", ,".T.", 4, .F.})

    If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)

        cArquivo  	:= ParamLoad(cFileName,,1,cArquivo)
        cPCliente	:= ParamLoad(cFileName,,2,cPCliente)
        cPLoja		:= ParamLoad(cFileName,,3,cPLoja)
        cPData       := ParamLoad(cFileName,,4,cPData)

    Endif

Return

//Processa importação
Static Function fProcImport()

    Local aArea 			:= GetArea()
    Local aArquivo 			:= {}
    Local aLinha			:= {}
    Local nImport			:= 0
    Local nErros			:= 0
    Local nTotLin			:= 0
    Local cLogErro			:= ""
    Local _cCodLojCli		:= cPCliente+cPLoja
    Local nLinPlan			:= 1
    Local nx
    Local __cListCli 		:= U_FPATVCLI()
    Local cAno, cMes, cDia
    Local cSQL

    _cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])

    ProcRegua(0)

    msTmpINI := Time()

    _cPath := SubStr(cArquivo,1,RAT('\',cArquivo))
    _cNomFile := SubStr(cArquivo,RAT('\',cArquivo)+1)

    //PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR
    _cDefPath			:= GetNewPar("FA_PATSPTH","\P10\AUTOMACAO\PEDIDO_AUTOMATICO\")

    If ( File(_cDefPath+_cNomFile) )
        FErase(_cDefPath+_cNomFile)
    EndIf

    lRet := CpyT2S(cArquivo, _cDefPath)

    If (!lRet)
        MsgAlert("ERRO AO ENVIAR ARQUIVO: "+cArquivo+" >>> PARA O SERVIDOR.")
        Return
    EndIf

    _oApi 		:= TPATApiNet():New()
    _aListCols 	:= {"COD_PRODUTO_CLIENTE","DESC_PRODUTO_CLIENTE","VENDA_REAIS","VENDA_QTDE_M2"}
    aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
    //FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

    //VALIDAR NAO PERMITIR REPRESENTANTE IMPORTAR PLANILHA COM CLIENTES QUE NAO SEJAM DELE
    If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) ) .And. !( SubStr(_cCodLojCli,1,6) $ __cListCli )
        MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO PERMITIDO PARA ESTE REPRESENTANTE")
        Return
    EndIf

    IF Empty(cPData)
        MsgAlert("DATA PARCIAL NÃO INFORMADA, Favor informar o data do mês até qual este Sell Out é Parcial.")
        Return
    ENDIF

    cAno	:= PADL(Year(cPData),4,'0')
    cMes	:= PADL(Month(cPData),2,'0')
    cDia    := PADL(Day(cPData),2,'0')

    msDtProc  := Date()
    msHrProc  := Time()
    msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

    If aArquivo <> Nil .And. Len(aArquivo) > 0

        lRunJob 	:= .T.

        nTotLin		:= len(aArquivo)

        ProcRegua(nTotLin)

        msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

        nTotLin		:= len(aArquivo)

        ProcRegua(nTotLin)


        For nx := 1 to len(aArquivo)

            nLinPlan++

            IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )

            aLinha    := aArquivo[nx]

            _cProdCli		:= AllTrim(cValTochar(aLinha[1]))
            _nValor			:= IIF(aLinha[3] <> Nil, aLinha[3], 0)
            _nQtde			:= IIF(aLinha[4] <> Nil, aLinha[4], 0)

            If Empty(_cProdCli) .And. Empty(_nQtde) .And. Empty(_nValor)
                loop
            EndIf

            _cProdCli		:= PADR(_cProdCli, TamSX3("ZAW_CODPCL")[1])

            _cProdBianco	:= ""

            SA1->(DbSetOrder(1))
            IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

                DisarmTransaction()
                MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - VERIFICAR PARAMETROS.")
                Return

            EndIf

            ZAG->(DbSetOrder(2))
            IF !ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdCli))

                cLogErro += "ERRO - CODIGO PRODUTO CLIENTE NAO ENCONTRADO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF+"VERIFICAR IMPORTACAO DO ARQUIVO LISTA DE ATIVOS"+CRLF
                nErros++
                //loop

            Else

                _cProdBianco := ZAG->ZAG_CODPRO

            EndIf

            SB1->(DbSetOrder(1))
            IF !SB1->(DbSeek(XFilial("SB1")+_cProdBianco))

                cLogErro += "ERRO - CODIGO PRODUTO BIANCO NAO ENCONTRADO/NAO INFORMADO NA EQUIVALENCIA - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
                nErros++
                //loop

            EndIf

            If (ValType(_nQtde) <> "N" .Or. ValType(_nValor) <> "N")

                cLogErro += "ERRO - QTDE OU VALOR INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
                nErros++
                loop

            EndIf

            ZAW->(DbSetOrder(1))
            //ZAW_FILIAL, ZAW_ANO, ZAW_MES, ZAW_CODCLI, ZAW_LOJCLI, ZAW_CODPRO, ZAW_DIA, R_E_C_N_O_, D_E_L_E_T_

            IF ZAW->(DbSeek(XFILIAL("ZAW")+cAno+cMes+_cCodLojCli+_cProdBianco+cDia))

                RecLock("ZAW",.F.)

            ELSE

                RecLock("ZAW",.T.)
                ZAW->ZAW_FILIAL := XFILIAL("ZAW")
                ZAW->ZAW_ANO	:= cAno
                ZAW->ZAW_MES	:= cMes
                ZAW->ZAW_DIA    := cDia
                ZAW->ZAW_CODCLI	:= SubStr(_cCodLojCli,1,6)
                ZAW->ZAW_LOJCLI := SubStr(_cCodLojCli,7,2)
                ZAW->ZAW_CODPRO := _cProdBianco

            ENDIF

            ZAW->ZAW_CODPCL	:= _cProdCli
            ZAW->ZAW_QTDE	:= _nQtde
            ZAW->ZAW_VALOR	:= _nValor

            ZAW->ZAW_USER	:= CUSERNAME
            ZAW->ZAW_DTIMP	:= Date()
            ZAW->ZAW_HRIMP	:= Time()
            ZAW->ZAW_FILE	:= cArquivo
            ZAW->ZAW_LINHA	:= nx

            ZAW->(MsUnlock())

            nImport++

        Next nx

    EndIf

    IF !Empty(cLogErro)

        U_FROPMSG("[FPATTE07] SELL OUT CLIENTE",cLogErro,,,"Log de Avisos e Inconsistencias")

    ENDIF

    //Apagar DIAS anteriores ao ultimo importado do MES
    cSQL := "update ZAW010 set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  "+CRLF
    cSQL += "where ZAW_CODCLI = '"+SubStr(_cCodLojCli,1,6)+"' and ZAW_LOJCLI = '"+SubStr(_cCodLojCli,7,2)+"' "+CRLF
    cSQL += "and ZAW_ANO+ZAW_MES+ZAW_DIA < (select isnull(max(ZAW_ANO+ZAW_MES+ZAW_DIA),'00000000') from ZAW010 where ZAW_CODCLI = '"+SubStr(_cCodLojCli,1,6)+"' and ZAW_LOJCLI = '"+SubStr(_cCodLojCli,7,2)+"' and D_E_L_E_T_ = '') "+CRLF
    cSQL += "and D_E_L_E_T_ = ' '  "+CRLF

    TcSQLExec(cSQL)

    MsgInfo(Alltrim(Str(nImport))+" Registros importados. "+Alltrim(Str(nErros))+" com ERROS. ")
    RestArea(aArea)

Return


User Function FPAT07DE()

    LjMsgRun("Aguarde... processando exclusao do SellOut",,{|| DelProc() })

Return

Static Function DelProc()

    Local _cCodLojCli		:= ZAW->ZAW_CODCLI+ZAW->ZAW_LOJCLI
    Local _cAno				:= ZAW->ZAW_ANO
    Local _cMes				:= ZAW->ZAW_MES
    Local _cDia				:= ZAW->ZAW_DIA
    Local _nCont			:= 0

    ZAW->(DbSetOrder(1))
    If ZAW->(DbSeek(XFilial("ZAW")+_cAno+_cMes+_cCodLojCli))

        If MsgNoYes("EXCLUIR TODOS OS REGISTROS DO CLIENTE: "+_cCodLojCli+", DO DIA: "+_cDia+"/"+_cMes+"/"+_cAno+"?")

            While !ZAW->(Eof()) .And. ZAW->(ZAW_FILIAL+ZAW->ZAW_ANO+ZAW->ZAW_MES+ZAW->ZAW_CODCLI+ZAW->ZAW_LOJCLI) == (XFilial("ZAW")+_cAno+_cMes+_cCodLojCli)

                If ( ZAW->ZAW_DIA == _cDia)

                    RecLock("ZAW",.F.)
                    ZAW->(DbDelete())
                    ZAW->(MsUnlock())

                    _nCont++

                ENDIF

                ZAW->(DbSkip())
            EndDo

            MsgInfo(AllTrim(Str(_nCont))+" REGISTROS EXCLUIDOS.")

            lRunJob := .T.

        EndIf

    EndIf

Return