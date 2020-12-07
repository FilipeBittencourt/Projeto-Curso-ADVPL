#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'

User Function FLOADFUN
    Local aArea    := GetArea()
    Local oDlgForm := NIL
    Local oGrpForm := NIL
    Local oGetForm := NIL
    Local cGetForm := Space(250)
    Local oGrpAco  := NIL
    Local oBtnExec := NIL
    Local nJanLarg := 500
    Local nJanAltu := 120
    Local nJanMeio := (nJanLarg / 2) / 2
    Local nTamBtn  := 048

    DEFINE MSDIALOG oDlgForm TITLE "Execução de Funções" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
        @ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1         PROMPT "Função: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL

        @ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExec(cGetForm)) PIXEL
		
    ACTIVATE MSDIALOG oDlgForm CENTERED

    RestArea(aArea)
	
Return

Static Function fExec(cGetForm)
    Local aArea    := GetArea()
    Local cFormula := Alltrim(cGetForm)
    Local cError   := ""
    Local bError   := ErrorBlock({|oError| cError := oError:Description})

    If (!Empty(cFormula))
        BEGIN SEQUENCE
            &(cFormula)
        END SEQUENCE

        ErrorBlock(bError)

        If (!Empty(cError))
            MsgStop("Houve um erro na fórmula digitada: " + CRLF + CRLF + cError, "Execução de Funções")
        EndIf
    EndIf

    RestArea(aArea)
	
Return