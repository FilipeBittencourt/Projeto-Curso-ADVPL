#include "PROTHEUS.CH"

/*
##############################################################################################################
# PROGRAMA...: VldCdBarLD         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 19/11/2013                      
# DESCRICAO..: Nao Permitir que Cod Barras Seja Digitado no Campo de Linha Digitavel e Vice-e-Versa
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function VldCdBarLD(_cCodBar,_nOpc)

     Local lRet := .T.
     Local aAreaSF6 := SF6->(GetArea())
     Local aAreaSA2 := SA2->(GetArea())
     Local aRetorno := {}

     //(_nOpc == 1) VALIDAR CODIGO DE BARRAS
     //(_nOpc == 2) VALIDAR LINHA DIGITAVEL

     _cCodBar := Alltrim(_cCodBar)

     If Empty(Alltrim(_cCodBar))
          Return .T.
     EndIf

     If Len(_cCodBar) < 44
          _cCodBar := Left(_cCodBar+Replicate("0", 48-Len(_cCodBar)),47)
     Endif

     If (_nOpc == 1) .And. ((Len(_cCodBar)>44) .Or. (Len(_cCodBar) == 33))
          MsgStop("Valor Deve Ser Digitado no Campo da Linha Digitavel. Verifique!")
          lRet := .F.
     EndIf
     If (_nOpc == 2) .And. (Len(_cCodBar) == 44)
          MsgStop("Valor Deve Ser Digitado no Campo Cod. de Barras. Verifique!")
          lRet := .F.
     EndIf

     // Ticket: 24897
     If lRet .And. !Empty(&(Alltrim(ReadVar()))) .And. !IsBlind()

          DBSelectArea("SF6")
          SF6->(DBSetOrder(1)) // F6_FILIAL, F6_EST, F6_NUMERO, R_E_C_N_O_, D_E_L_E_T_

          DBSelectArea("SA2")
          SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_

          If SA2->(DBSeek(xFilial("SA2") + M->E2_FORNECE + M->E2_LOJA))

               If SF6->(DBSeek(xFilial("SF6") + SA2->A2_EST + M->E2_PREFIXO + M->E2_NUM)) .Or.;
                         ( SF6->(DBSeek(xFilial("SF6") + SA2->A2_EST +  Space(3) + M->E2_NUM)) .And. SF6->F6_EST = "SP" .And. SF6->F6_SERIE == M->E2_PREFIXO )

                    If !Empty(SF6->F6_DOC) 

                         oObj := TFaturamentoAutomatico():New(.T.)

                         aRetorno := oObj:MonitoraNFe(SF6->F6_SERIE, SF6->F6_DOC, .F.)

                         If Len(aRetorno) == 0

                              lRet := .F.

                              Alert("A nota fiscal " + SF6->F6_DOC + " serie " + AllTrim(SF6->F6_SERIE) + " ainda não foi transmitida!")

                         ElseIf !(aRetorno[1, 5] $ "100")

                              lRet := .F.

                              Alert("A nota fiscal " + SF6->F6_DOC + " serie " + AllTrim(SF6->F6_SERIE) + " ainda não foi autorizada!" + CRLF + "[" + AllTrim(aRetorno[1, 9]) + "]")

                         ElseIf aRetorno[1, 5] $ "100"

                              lRet := .T.

                         EndIf

                    EndIf

               EndIf

          EndIf

     EndIf

     RestArea(aAreaSF6)
     RestArea(aAreaSA2)

Return(lRet)
