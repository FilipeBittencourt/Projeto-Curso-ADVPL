#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F3_SX5_ZH
@author Fernando Rocha
@since 01/03/2018
@version 1.0
@description Rotina para seleção de multiplos contratos
@type function
/*/

User Function F3_SX5_ZH(lOneEle)

    Local uVarRet   := Nil
    Local cTitulo   := ""
    Local cVarRet   := ""
    Local MvParDef 	:= ""
    Local cReadVar  := ReadVar()
    Local nTamKey 	:= TamSX3("X5_CHAVE")[1]
    Local nW        := 0

    Private aPac := {}

    Default lOneEle := .F.

    &(cReadVar) := Space(200)

    DBSelectArea("SX5")
    SX5->(DBSetOrder(1)) // X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_

    cTitulo := "Pacote GMR3"

    If SX5->(DBSeek(xFilial("SX5") + "ZH"))

        While !SX5->(EOF()) .And. SX5->(X5_FILIAL + X5_TABELA) == xFilial("SX5") + "ZH"

            aAdd(aPac, SX5->X5_DESCRI)

            MvParDef += SX5->X5_CHAVE

            SX5->(DbSkip())

        EndDo

        // Chama funcao f_Opcoes
        If f_Opcoes(@uVarRet, cTitulo, aPac, MvParDef,,,lOneEle,nTamKey,15,,,,,,.T.,)

            //Monta resultado
            cVarRet := ""

            For nW := 1 To Len(uVarRet)

                cVarRet += uVarRet[nW]
                cVarRet += ";"

            Next nW

            // Devolve Resultado
            cF3SXHZH := AllTrim(cVarRet)
            
            cF3SXHZH := If(SubStr(cF3SXHZH, Len(cF3SXHZH),1) == ";", SubStr(cF3SXHZH, 1, Len(cF3SXHZH)-1), cF3SXHZH)

            cF3SXHZH := Replace(cF3SXHZH, " ", "")

            SetMemVar(cReadVar, Replace(cF3SXHZH, " ", ""))

            SysRefresh(.T.)

        EndIf

    EndIf

Return(.T.)