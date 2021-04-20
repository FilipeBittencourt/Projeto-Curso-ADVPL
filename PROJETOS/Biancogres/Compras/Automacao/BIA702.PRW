#include "totvs.ch"

/*/{Protheus.doc} BIA702
@author Wlysses Cerqueira (Facile)
@since 23/09/2020 
@Ticket: 25655 - Automacao Devolucao
@version 1.0
@description 
@type function
/*/

function u_BIA702()

    local aArea     as array
    local aColors   as array
    
    local cFiltro   as character

    aArea:=GetArea()    

    private cCadastro   as character
    cCadastro:="Monitor - Automacao Devolucao Intercompany"

    private aRotina as array
    aRotina:=MenuDef()

    aColors:=aColorsDef()

    DbSelectArea("ZL9")

    ZL9->(DbSetOrder(1))

    cFiltro:=("ZL9_CODEMP="+ValToSql(cEmpAnt)+" AND ZL9_CODFIL="+ValToSql(cFilAnt))

    ZL9->(MBrowse(6,1,22,75,"ZL9",nil,nil,nil,nil,nil,aColors,nil,nil,nil,nil,nil,nil,nil,cFiltro))

    RestArea(aArea)

    return

function u_BI702DOE()

    local aAreaSF1  as array

    aAreaSF1:=SF1->(GetArea())

    DBSelectArea("SF1")
    SF1->(DbSetOrder(1))  //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_

    If (SF1->(DbSeek(xFilial("SF1")+ZL9->(ZL9_DOCDEV+ZL9_SERDEV+ZL9_CLIDEV+ZL9_LOJDEV))))
        A103NFiscal("SF1",SF1->(RecNo()),2,.F.)
    Else
        Alert("Nota não encontrada!")
    EndIf

    RestArea(aAreaSF1)

    return

function u_BI702DOO()

    local aAreaSF1  as array

    aAreaSF1:=SF1->(GetArea())

    DBSelectArea("SF1")
    SF1->(DbSetOrder(1))  //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_

    If (SF1->(DbSeek(xFilial("SF1")+ZL9->(ZL9_DOCORI+ZL9_SERORI+ZL9_FORNEC+ZL9_LOJFOR))))
        A103NFiscal("SF1",SF1->(RecNo()),2,.F.)
    Else
        Alert("Nota não encontrada!")
    EndIf

    RestArea(aAreaSF1)

    return

function u_BI702DOS()

    local aAreaSD2  as array

    aAreaSD2:=SD2->(GetArea())

    DBSelectArea("SD2")
    SD2->(dbSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

    If (SD2->(DbSeek(xFilial("SD2")+ZL9->(ZL9_DOC+ZL9_SERIE+ZL9_FORNECE+ZL9_LOJFOR))))
        A920NFSAI("SD2",SD2->(RecNo()),0)
    Else
        Alert("Nota não encontrada!")
    EndIf

    RestArea(aAreaSD2)

    return

function u_BI702PEV()

    local aAreaSC5 as array

    aAreaSC5:=SC5->(GetArea())

    DBSelectArea("SC5")
    SC5->(DbSetOrder(1)) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_

    If (SC5->(DbSeek(xFilial("SC5")+ZL9->ZL9_PEDIDO)))
        A410Visual("SC5",SC5->(RecNo()),2)
    Else
        Alert("Pedido não encontrado!")
    EndIf

    RestArea(aAreaSC5)

    return

function u_BI702BLQ()

    If ((ZL9->ZL9_MSBLQL=="2").or.Empty(ZL9->ZL9_MSBLQL))
        If (ZL9->ZL9_STATUS=="F")
            Alert("Processo ja finalizado!")
        Else
            If (MsgYesNo("Confirma bloqueio do processo?"))
                IF (ZL9->(RecLock("ZL9", .F.)))
                    ZL9->ZL9_MSBLQL:="1"
                    ZL9->(MSUnLock())
                ENDIF
                MsgInfo("Verifique o status do processo!")
            EndIf
        EndIf
    Else
        Alert("Processo ja bloqueado!")
    EndIf

Return()

function u_BI702UNB()

    If (ZL9->ZL9_MSBLQL=="1")
        If (MsgYesNo("Confirma Desbloqueio do processo?"))
            IF (ZL9->(RecLock("ZL9",.F.)))
                ZL9->ZL9_MSBLQL:="2"
                ZL9->(MSUnLock())
            ENDIF
            MsgInfo("Acompanhe o status do processo!")
        EndIf
    Else
        Alert("Processo ja Desbloqueado!")
    EndIf

Return()

function u_BI702REP()

    If ((ZL9->ZL9_MSBLQL=="2").or.Empty(ZL9->ZL9_MSBLQL))
        If (ZL9->ZL9_STATUS=="F")
            Alert("Processo ja finalizado!")
        Else
            If (ZL9->ZL9_STAERR=="E")
                If (MsgYesNo("Confirma reprocessamento?"))
                    if (ZL9->(RecLock("ZL9", .F.)))
                        ZL9->ZL9_STAERR:=""
                        ZL9->(MSUnLock())
                    endif
                    MsgInfo("Verifique o status do processo!")
                EndIf
            Else
                Alert("O reprocessamento é valido apenas notas com erro!")
            EndIf
        EndIf
    Else
        Alert("Processo está bloqueado!")
    EndIf

Return()

function u_BI702LEG()

    local aLegenda as array

    aLegenda:=array(0)

    aAdd(aLegenda,{"BR_VERDE","Devolucao Cliente - NF Incluida"})
    aAdd(aLegenda,{"BR_AMARELO","Devolucao Cliente - NF Enderecada"})

    aAdd(aLegenda,{"BR_BRANCO","Devolucao Intercompany - Pedido Gerado"})
    aAdd(aLegenda,{"BR_VIOLETA","Devolucao Intercompany - Pedido Faturado"})
    aAdd(aLegenda,{"BR_MARRON","Devolucao Intercompany - NF Incluida"})
    aAdd(aLegenda,{"BR_LARANJA","Devolucao Intercompany - NF Enderecada"})

    aAdd(aLegenda,{"BR_PRETO", "Processo com erros"})
    aAdd(aLegenda,{"BR_VERMELHO","Processo Finalizado"})

    brwLegenda(cCadastro,"Legenda",aLegenda)

    Return(.T.)

static function MenuDef()
    
    local aRotina as array

    aRotina:=array(0)

    aAdd(aRotina,{"Pesquisa","AxPesqui",0,1})
    aAdd(aRotina,{"Visualizar","AxVisual",0,2})
    aAdd(aRotina,{"Doc. Entrada","U_BI702DOE",0,2})
    aAdd(aRotina,{"Doc. Original","U_BI702DOO",0,2})
    aAdd(aRotina,{"Doc. Saida","U_BI702DOS",0,2})
    aAdd(aRotina,{"Ped. Venda","U_BI702PEV",0,2})
    aAdd(aRotina,{"Bloquear","U_BI702BLQ",0,5})
    aAdd(aRotina,{"Desbloquear","U_BI702UNB",0,5})
    aAdd(aRotina,{"Reprocessa","U_BI702REP",0,5})
    aAdd(aRotina,{"Legenda","U_BI702LEG",0,8})

    return(aRotina)

static function aColorsDef()

    local aColors as array

    aAdd(aColors,{"ZL9_STAERR=='E'","BR_PRETO"})
    
    aAdd(aColors,{"empty(ZL9_STATUS)","BR_VERDE"})
    
    aAdd(aColors,{"ZL9_STATUS=='1'","BR_VERDE"})
    aAdd(aColors,{"ZL9_STATUS=='2'","BR_AMARELO"})
    aAdd(aColors,{"ZL9_STATUS=='3'","BR_BRANCO"})
    aAdd(aColors,{"ZL9_STATUS=='4'","BR_VIOLETA"})
    aAdd(aColors,{"ZL9_STATUS=='5'","BR_MARRON"})
    aAdd(aColors,{"ZL9_STATUS=='6'","BR_LARANJA"})

    aAdd(aColors,{"ZL9_STATUS=='F'","BR_VERMELHO"})

    return(aColors)
