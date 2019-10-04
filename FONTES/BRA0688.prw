#include "totvs.ch"
#include "topConn.ch"

/*/{Protheus.doc} BRA0688
Funcao para troca de armazem da OP de acordo EXPEDI das etiquetas da OP conforme chamado 14315
@author TOTVS.IURY
@since 01/10/2018
@type user function
/*/
user function BRA0688(cOp)
    Local aArea := getArea()
    Local cQuery := ""
    Local cLocOp := ""
    Local cSpedi := "N"
    Local cModificador := ""

    //Default cOp := '14570801120'

    SC2->(dbSelectArea("SC2"))
    SC2->(dbSetOrder(1))
    
    SB1->(dbSelectArea("SB1"))
    SB1->(dbSetOrder(1))

    If SC2->(dbSeek(xFilial("SC2")+cOp))
        SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

        cModificador := U_retLabel(SC2->C2_PRODUTO, "MODIFICADOR", "SB1")

        If cModificador == "I" .OR. cModificador == "A" .OR. cModificador == "APV"
            //Verifica o modificador do produto se for I/A/APV o retorno vai ser sempre "BRA_LOCPA","02"
            cLocOp := getnewPar("BRA_LOCPA","02")
        Elseif SB1->B1_TIPO == "MP"
            cLocOp := SB1->B1_LOCPAD
        else
            //Caso contrario vai verificar o EXPEDI de todas as etiquetas da OP e utilizar o que tiver maioria
            cQuery := " SELECT ZC2_EXPEDI, SUM(ZC2_QUANT) AS QUANT"
            cQuery += " FROM " + retSqlName("ZC2") + " AS ZC2 (NOLOCK)"
            cQuery += " WHERE ZC2_FILIAL='" + xFilial("ZC2") + "'"
            cQuery += " AND ZC2_OP='" + cOp + "'"
            cQuery += " AND ZC2.D_E_L_E_T_=''"
            cQuery += " AND ZC2.ZC2_EXPEDI <> ''"
            cQuery += " GROUP BY ZC2_EXPEDI"
            cQuery += " ORDER BY SUM(ZC2_QUANT) DESC"

            tcQuery cQuery New Alias "QRY"

            If !QRY->(eof())
                cSpedi :=  QRY->ZC2_EXPEDI
            EndIf
            //40709301616
            QRY->(dbCloseArea())

            If cSpedi == "S"
                cLocOp := getnewPar("BRA_LOCCQ","21")
            Else
                cLocOp := getnewPar("BRA_LOCPRO","43")
            EndIf


        EndIf

        recLock("SC2", .F.)
            SC2->C2_LOCAL := cLocOp
        SC2->(msUnlock())
    EndIf

    RestArea(aArea)
return