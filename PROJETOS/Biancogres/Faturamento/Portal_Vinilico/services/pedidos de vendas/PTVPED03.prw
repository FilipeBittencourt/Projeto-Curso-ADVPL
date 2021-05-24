#include "totvs.ch"


/*/{Protheus.doc} PTVPED03
Rotina especifica para rodar o execauto do MATA410
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 13/01/2021
@param aCabSC5, array, dados da SC5
@param aItensSC6, array, Dados da SC6
@return array, Array de resultado
/*/
User Function PTVPED03( aCabSC5, aItensSC6 )

  Local aRet             :={"", "", "", ""}
  Local cMsgRet          := ""
  Local cNumPed          := ""
  Local cLogTxt          := ""
  Local lOk              := .F.
  Local cBckFunc 	       := FunName()

  Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

  Begin Transaction

    cNumPed := GetSxENum("SC5","C5_NUM")
    RollBackSX8()

    aCabSC5[1][2] := cNumPed

    aEval( aItensSC6,{ |x|  x[1][2] := cNumPed } )

    dbSelectArea("SC5")
    cMay := "SC5"+ Alltrim(xFilial("SC5"))
    SC5->(dbSetOrder(1))

    While ( dbSeek( xFilial("SC5") + cNumPed ) .Or. !MayIUseCode(cMay + cNumPed) )

      cNumPed := Soma1(cNumPed, Len(cNumPed))

      aCabSC5[1][2] := cNumPed

      aEval( aItensSC6,{ |x|  x[1][2] := cNumPed } )

    EndDo

    cMsgRet          := "Numero pedido utilizado: " + cNumPed + CRLF

    SetFunName("RPC")

    //|Variavel utilizada na regra de negocio da Bianco |
    CREPATU := ""

    MsExecAuto( { |x,y,z| Mata410(x,y,z) }, aCabSC5, aItensSC6, 3 )

    SetFunName(cBckFunc)

    //|Ocorreu erro no execauto |
    If lMsErroAuto

      RollBackSX8()

      VarInfo("aCabSC5", aCabSC5)

      VarInfo("aItensSC6", aItensSC6)

      cLogTxt := GetErrorLog()

      cMsgRet += "### ERRO ao incluir pedido de venda: " + CRLF + cLogTxt

      DisarmTransaction()

      cNumPed   := ""

    Else

      ConfirmSX8()

      cMsgRet += "Pedido incluido com sucesso: " + SC5->C5_NUM + " - Empresa/Filial: " + cEmpAnt + "/" + cFilAnt
      lOk     := .T.

    EndIf

  End Transaction

  //|Tratativa por as vezes não entrar no IF após execauto |
  If !lOk .And. !Empty(cNumPed)
    
    cNumPed := ""
    
    cLogTxt := GetErrorLog()
    cMsgRet += "### ERRO ao incluir pedido de venda: " + CRLF + cLogTxt

  EndIf

  aRet[1] := cMsgRet
  aRet[2] := cNumPed

  //|Enquanto está homologando - gera replicação automatico |
  If lOk .And. !Empty(cNumPed)

    // If ( Upper( AllTrim( GetEnvServer() ) ) $ "DEV-PONTIN/JOB-VINILICO" )

    CREPATU := ""

    U_FCOMRT01(cNumPed, .T., .F., AllTrim(CFILANT) <> "01" )
          
    // EndIf

  EndIf

Return aRet


Static Function GetErrorLog()

	Local cRet   := ""
	Local nCount := 0

	aError := GetAutoGrLog()

	For nCount := 1 To Len(aError)

		cRet += aError[nCount] + CRLF

	Next

Return(cRet)
