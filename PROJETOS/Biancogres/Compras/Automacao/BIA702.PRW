#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA702
@author Wlysses Cerqueira (Facile)
@since 23/09/2020 
@Ticket: 25655 - Automacao Devolucao
@version 1.0
@description 
@type function
/*/

User Function BIA702()

    Local aArea     := GetArea()
    Local aCores    := {}
    Local cFiltro   := ""

    Private cCadastro   := "Monitor - Automacao Devolucao Intercompany"
    Private aRotina 	:= {}

    aAdd(aRotina, { "Pesquisa"      , "AxPesqui"	, 0, 1 })
    aAdd(aRotina, { "Visualizar"    , "AxVisual"	, 0, 2 })
    aAdd(aRotina, { "Doc. Entrada"  , "U_BI702DOE"	, 0, 2 })
    aAdd(aRotina, { "Doc. Saida"    , "U_BI702DOS"	, 0, 2 })
    aAdd(aRotina, { "Ped. Venda"    , "U_BI702PEV"	, 0, 2 })
    aAdd(aRotina, { "Bloquear"      , "U_BI702BLQ"	, 0, 5 })
    aAdd(aRotina, { "Desbloquear"   , "U_BI702UNB"	, 0, 5 })
    aAdd(aRotina, { "Reprocessa"    , "U_BI702REP"	, 0, 5 })
    aAdd(aRotina, { "Legenda"       , "U_BI702LEG"	, 0, 8 })

    aAdd(aCores, { "ZL9_STAERR == 'E'" , "BR_PRETO"     })
    aAdd(aCores, { "ZL9_STATUS == '1'" , "BR_VERDE"     })
    aAdd(aCores, { "ZL9_STATUS == '2'" , "BR_AMARELO"	})

    aAdd(aCores, { "ZL9_STATUS == '3'" , "BR_BRANCO"    })
    aAdd(aCores, { "ZL9_STATUS == '4'" , "BR_VIOLETA"   })
    aAdd(aCores, { "ZL9_STATUS == '5'" , "BR_MARRON"    })
    aAdd(aCores, { "ZL9_STATUS == '6'" , "BR_LARANJA"   })

    aAdd(aCores, { "ZL9_STATUS == 'F'" , "BR_VERMELHO"  })

    DbSelectArea("ZL9")

    DbSetOrder(1)

    cFiltro += " ZL9_CODEMP = " + ValToSql(cEmpAnt) + " AND ZL9_CODFIL = " + ValToSql(cFilAnt)

    MBrowse(6, 1, 22, 75, "ZL9",,,,,, aCores,,,,,,,,cFiltro)

    RestArea(aArea)

Return()

USer Function BI702DOE()

    Local aAreaSF1 := SF1->(GetArea())

    DBSelectArea("SF1")
    SF1->(DbSetOrder(1))  //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_

    If SF1->(DbSeek(xFilial("SF1") + ZL9->(ZL9_DOCDEV + ZL9_SERDEV + ZL9_CLIDEV + ZL9_LOJDEV)))

        A103NFiscal("SF1", SF1->(Recno()), 2, .F.)

    Else

        Alert("Nota não encontrada!")

    EndIf

    RestArea(aAreaSF1)

Return()

USer Function BI702DOS()

    Local aAreaSD2 := SD2->(GetArea())

    DBSelectArea("SD2")
    SD2->(dbSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

    If SD2->(DbSeek(xFilial("SD2") + ZL9->(ZL9_DOC + ZL9_SERIE + ZL9_FORNECE + ZL9_LOJFOR)))

        A920NFSAI("SD2", SD2->(RecNo()), 0)

    Else

        Alert("Nota não encontrada!")

    EndIf

    RestArea(aAreaSD2)

Return()

USer Function BI702PEV()

    Local aAreaSC5 := SC5->(GetArea())

    DBSelectArea("SC5")
    SC5->(DbSetOrder(1)) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_

    If SC5->(DbSeek(xFilial("SC5") + ZL9->ZL9_PEDIDO))

        A410Visual("SC5", SC5->(Recno()), 2)

    Else

        Alert("Pedido não encontrado!")

    EndIf

    RestArea(aAreaSC5)

Return()

USer Function BI702BLQ()

    If ZL9->ZL9_MSBLQL == "2" .Or. Empty(ZL9->ZL9_MSBLQL)

        If ZL9->ZL9_STATUS == "F"

            Alert("Processo ja finalizado!")

        Else

            If MsgYesNo("Confirma bloqueio do processo?")

                RecLock("ZL9", .F.)
                ZL9->ZL9_MSBLQL := "1"
                ZL9->(MSUnLock())

                MsgInfo("Verifique o status do processo!")

            EndIf

        EndIf

    Else

        Alert("Processo ja bloqueado!")

    EndIf

Return()

USer Function BI702UNB()

    If ZL9->ZL9_MSBLQL == "1"

        If MsgYesNo("Confirma Desbloqueio do processo?")

            RecLock("ZL9", .F.)
            ZL9->ZL9_MSBLQL := "2"
            ZL9->(MSUnLock())

            MsgInfo("Acompanhe o status do processo!")

        EndIf

    Else

        Alert("Processo ja Desbloqueado!")

    EndIf

Return()

USer Function BI702REP()

    If ZL9->ZL9_MSBLQL == "2" .Or. Empty(ZL9->ZL9_MSBLQL)

        If ZL9->ZL9_STATUS == "F"

            Alert("Processo ja finalizado!")

        Else

            If ZL9->ZL9_STAERR == "E"

                If MsgYesNo("Confirma reprocessamento?")

                    RecLock("ZL9", .F.)
                    ZL9->ZL9_STAERR := ""
                    ZL9->(MSUnLock())

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

User Function BI702LEG()

    Local aLegenda := {}

    aAdd(aLegenda, { "BR_VERDE"     , "Devolucao Cliente - NF Incluida"             })
    aAdd(aLegenda, { "BR_AMARELO"	, "Devolucao Cliente - NF Enderecada"           })

    aAdd(aLegenda, { "BR_BRANCO"    , "Devolucao Intercompany - Pedido Gerado"      })
    aAdd(aLegenda, { "BR_VIOLETA"   , "Devolucao Intercompany - Pedido Faturado"    })
    aAdd(aLegenda, { "BR_MARRON"    , "Devolucao Intercompany - NF Incluida"        })
    aAdd(aLegenda, { "BR_LARANJA"   , "Devolucao Intercompany - NF Enderecada"      })

    aAdd(aLegenda, { "BR_PRETO"     , "Processo com erros"                          })
    aAdd(aLegenda, { "BR_VERMELHO"  , "Processo Finalizado"                         })

    BRWLEGENDA( cCadastro, "Legenda", aLegenda )

Return(.T.)
