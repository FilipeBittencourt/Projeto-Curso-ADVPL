#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE06
@description Tela cadastro do SELLOUT DIARIO para pedido automatico
@author Fernando Rocha
@since 10/04/2020 day 23o of SARS-COV-2 Isolation
@type function
/*/
User Function FPATTE06()

    Local aCores
    Private xImpDh := .F.
    Private wdProc := ""
    Private cCadastro := "SELL OUT DIARIO"
    Private aRotina
    Private lRunJob := .F.

    aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
        {"Visualizar"   	,'AxVisual',0, 2},;
        {"Incluir"   		,'U_FPTE06MN(3)',0, 3},;
        {"Alterar"   		,'U_FPTE06MN(4)',0, 4},;
        {"Excluir"   		,'U_FPTE06MN(5)',0, 5},;
        {"Import.Excel" ,'Execblock("FPAT06EX" ,.F.,.F.,"C")',0, 3}}

    dbSelectArea("ZAY")
    mBrowse(6,1,22,75, "ZAY", , , , , ,aCores)

    //If ( lRunJob )
    //	U_EXEJBSQL("HIMEROS", "PEDAUT->Carga_Biancogres_Param_Loja", "Sincronizando Dados com BI")
    //EndIf

Return

User Function FPTE06MN(nOpt)

    Local lRet   	:= .T.

    If ( nOpt == 4)
        lRet   := AxAltera( "ZAY" , ZAY->(RecNo()), nOpt ) == 1
    ElseIf ( nOpt == 3)
        lRet   := AxInclui( "ZAY" , ZAY->(RecNo()), nOpt ) == 1
    ElseIf ( nOpt == 5)
        lRet   := AxDeleta( "ZAY" , ZAY->(RecNo()), nOpt ) == 2
    EndIf

    If (!lRunJob)
        lRunJob := lRet
    EndIf

Return


/*/{Protheus.doc} FPAT01EX
@description Funcao para importar planilha Excel para cadastro de SellOut de Clientes
/*/
User Function FPAT06EX

    Local aSays	   		:= {}
    Local aButtons 		:= {}
    Local lConfirm 		:= .F.
    Private cArquivo	:= space(500)

    fPergunte()

    AADD(aSays, OemToAnsi("Importação de Planilha SELL OUT DIARIO de Clientes"))
    AADD(aSays, OemToAnsi("Deseja Continuar?"))

    AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
    AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
    AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

    FormBatch( OemToAnsi('Importação de SELL OUT DIARIO de Clientes'), aSays, aButtons ,,,500)

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
    Local cLoad	    := 'FPAT06EXC' + cEmpAnt
    Local cFileName := RetCodUsr() +"_"+ cLoad
    cArquivo		:= space(500)

    aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

    If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)

        cArquivo  	:= ParamLoad(cFileName,,1,cArquivo)

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
    Local nLinPlan			:= 0
    Local nx

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
    EndIf

    _oApi 		:= TPATApiNet():New()
    _aListCols 	:= {"ANO","MES","CLIENTE_LOJA","MARCA","META","DATA_ENVIO","PROJECAO_DA_PREVIA","NOME_LOJA","COD_REPRESENTANTE","NOME_REPRESENTANTE"}
    aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
    //FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

    msDtProc  := Date()
    msHrProc  := Time()
    msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

    If aArquivo <> Nil .And. Len(aArquivo) > 0

        lRunJob 	:= .T.

        msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

        nTotLin		:= len(aArquivo)

        ProcRegua(nTotLin)


        For nx := 1 to len(aArquivo)

            nLinPlan++

            IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )

            aLinha    := aArquivo[nx]


            If ValType(aLinha[1]) == "N"
                aLinha[1] := Str(aLinha[1])
            EndIf


            If ValType(aLinha[2]) == "N"
                aLinha[2] := Str(aLinha[2])
            EndIf


            If ValType(aLinha[3]) == "N"
                aLinha[3] := Str(aLinha[3])
            EndIf


            If ValType(aLinha[4]) == "N"
                aLinha[4] := Str(aLinha[4])
            EndIf

            _cAno               := AllTrim(aLinha[1])
            _cMes               := AllTrim(aLinha[2])
            _cCodLojCli			:= AllTrim(aLinha[3])
            _cMarca 			:= AllTrim(aLinha[4])

            If ValType(aLinha[5]) == "C"
                aLinha[5] := 0
            EndIf

            If ValType(aLinha[6]) == "N"
                aLinha[6] := Str(aLinha[6])
            EndIf

            If ValType(aLinha[7]) == "C"
                aLinha[7] := Val(aLinha[7])
            EndIf

            _nMeta              := aLinha[5]
            _cDia               := PADL(AllTrim(aLinha[6]),2,'0')
            _nProjecao          := aLinha[7]

            _cAno := PADL(_cAno,4,'0')
            _cMes := PADL(_cMes,2,'0')

            If Empty(_cAno)
                loop
            EndIf

            If Empty(_cMes)
                loop
            EndIf

            If Empty(_cCodLojCli)
                loop
            EndIf

            If Empty(_cMarca)
                loop
            EndIf

            If Len(_cCodLojCli) <= 6
                _cCodLojCli := PADL(_cCodLojCli,6,'0')
                _cCodLojCli := _cCodLojCli + "01"
            else
                _cCodLojCli := PADL(_cCodLojCli,8,'0')
            EndIf

            SA1->(DbSetOrder(1))
            IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

                MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA")
                nErros++
                loop

            EndIf

            _cNMarca := "0101"
            If "INCESA" $ Alltrim(Upper(_cMarca))
                _cNMarca := "0501"
            ElseIf "BELLA" $ Alltrim(Upper(_cMarca))
                _cNMarca := "0501"
            ElseIf "VINI" $ Alltrim(Upper(_cMarca))
                _cNMarca := "0199"
            EndIf

            If  ( ( _nMeta <> Nil .And. ValType(_nMeta) <> "N" ) .Or. ( _nProjecao <> Nil .And. ValType(_nProjecao) <> "N") )

                cLogErro += "ERRO - VALOR INVALIDO CAMPOS META/DIA/PROJECAO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
                nErros++
                loop

            EndIf

            //ZAY_FILIAL, ZAY_ANO, ZAY_MES, ZAY_MARCA, ZAY_CODCLI, ZAY_LOJCLI, R_E_C_N_O_, D_E_L_E_T_
            ZAY->(DbSetOrder(1))
            IF ZAY->(DbSeek(XFilial("ZAY")+_cAno+_cMes+_cNMarca+_cCodLojCli))

                RecLock("ZAY",.F.)

            Else

                RecLock("ZAY",.T.)
                ZAY->ZAY_FILIAL := XFILIAL("ZAY")
                ZAY->ZAY_ANO    := _cAno
                ZAY->ZAY_MES    := _cMes
                ZAY->ZAY_MARCA  := _cNMarca
                ZAY->ZAY_CODCLI := SubStr(_cCodLojCli,1,6)
                ZAY->ZAY_LOJCLI := SubStr(_cCodLojCli,7,2)

            EndIf

            If ( _cDia == "00" )
                _cDia := ""
            EndIf

            ZAY->ZAY_META       := _nMeta
            ZAY->ZAY_DIA        := _cDia
            ZAY->ZAY_PROJEC     := _nProjecao

            ZAY->ZAY_NOMLOJ     := SA1->A1_YNLOJA

            If _cNMarca == "0101"
                _cVend := SA1->A1_VEND
            ElseIf (_cNMarca == "0501")
                _cVend := SA1->A1_YVENDI
            ElseIf (_cNMarca == "0599")
                _cVend := SA1->A1_YVENBE1
            ElseIf (_cNMarca == "1302")
                _cVend := SA1->A1_YVENVI1
            Else
                _cVend := SA1->A1_VEND
            EndIf

            ZAY->ZAY_VEND   := _cVend

            If SA3->(DbSeek(XFilial("SA3")+_cVend))
                ZAY->ZAY_NOMVEN := SA3->A3_NREDUZ
            EndIf

            ZAY->(MsUnlock())

            nImport++

        Next nx

    EndIf

    IF !Empty(cLogErro)

        U_FROPMSG("[FPATTE06] SELL OUT DIARIO",cLogErro,,,"Log de Avisos e Inconsistencias")

    ENDIF

    MsgInfo(Alltrim(Str(nImport))+" Registros importados. "+Alltrim(Str(nErros))+" com ERROS. ")
    RestArea(aArea)

Return