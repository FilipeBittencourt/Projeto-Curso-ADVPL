#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses Antonio Corona
Alteracao := 
Programa  := BIA868
Empresa   := Biancogres Ceramicas S/A
Data      := 28/03/16
Data Alt. := 
Uso       := Faturamento      
Aplicação := Grava observação quando for utilizado o desconto %Outros

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA868()
	Local nDescOut	:= Gdfieldget('C6_YDESP',n) 
	Private cObs	:= ""

	If Alltrim(Funname()) <> "RPC"
		If SC5->(FieldPos("C5_YOBDCOU")) > 0                                      
			If nDescOut > 0 .And. Empty(Alltrim(M->C5_YOBDCOU))  
				BIA868F()
				cObs := ALLTRIM(UPPER(StrTran(cObs,CHR(13)+CHR(10)," ")))
				If !Empty(cObs)
					M->C5_YOBDCOU := cObs
				EndIf
			EndIf
		EndIf
	EndIf

Return(nDescOut) 

//----------------------------------------------------------------------------------------------
Static Function BIA868F()

	// IDENTIFICADORES DE LINHA
	#DEFINE LIN1 "LIN1"

	// PERCENTUAL DAS LINHAS
	#DEFINE PER_LIN 100

	// IDENTIFICADORES DE COLUNA
	#DEFINE COL "COL"

	// PERCENTUAL DAS COLUNAS POR LINHA
	#DEFINE PER_COL 100

	// IDENTIFICADORES DE JANELA
	#DEFINE WND "WND"

	// TITULOS DAS JANELAS
	#DEFINE TIT_MAIN_WND "Observação para uso Desconto"
	#DEFINE TIT_WND_EPI "Informe a observação/justificativa para uso do desconto '%Outros':"

	Local aArea 	:= GetArea()
	Local oFntBold 	:= TFont():New('Arial',,14,,.T.)	
	Private oDlg

	// Array com as coordenadas da janela
	aCoors := FWGetDialogSize(oMainWnd)

	// Cria Dialog 
	//oDlg := MsDialog():New(aCoors[1], aCoors[2], 140, 315, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	oDlg := MsDialog():New(aCoors[1], aCoors[2], 190, 500, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	oDlg:cName := "oDlg"
	oDlg:lCentered := .T.
	oDlg:lEscClose := .F.
	oDlg:bValid := {|| .F. }


	// Barra de botoes
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	oBtnBar:AddBtnText("OK", "OK", {|| fConfirm() },,,CONTROL_ALIGN_RIGHT,.T.)


	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(oDlg, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN1, 100, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN1)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND_EPI, 100, .F. ,.T.,, LIN1, { || })

	// Retorna paimel da janela do Layer
	oPnlLin1 := oLayer:GetWinPanel(COL, WND, LIN1)


	//oGetNumCA := TMultiGet():Create(oPnlLin1)
	//oGetNumCA := TMultiGet():New( , , , oPnlLin1, , , , , , , , .T. )
	oGetNumCA := TMultiGet():Create(oPnlLin1,,,,,,,,,,,.T.,,,,,,,,,,,.T.,,,,)
	oGetNumCA:cName 	:= "oGetNumCA"
	oGetNumCA:nLeft 	:= 06
	oGetNumCA:nTop 		:= 06//22
	oGetNumCA:nWidth 	:= 470//85
	oGetNumCA:nHeight 	:= 95//30
	oGetNumCA:cVariable := "cObs"
	oGetNumCA:bSetGet 	:= bSetGet(cObs)            
	oGetNumCA:cToolTip 	:= "Informe a observação/justificativa para uso do desconto '%Outros'"
	oGetNumCA:bValid 	:= {||fVldObs()}

	// Abre a Janela
	oDlg:Activate()	

	RestArea(aArea)

Return()

//---------------------------------------------------------------------------------------------
Static Function fConfirm()

	If fVldObs()
		oDlg:bValid := {|| .T. }		
		oDlg:End()		
	EndIf

Return()                    

//---------------------------------------------------------------------------------------------
Static Function fVldObs()
	Local lRet := .T.

	If Empty(ALLTRIM(UPPER(StrTran(cObs,CHR(13)+CHR(10)," "))))
		lRet := .F.
		Msgbox("É obrigatório informar a observação/justificativa para uso do desconto '%Outros'.","BIA868","STOP")
	EndIf

Return(lRet)

//-----------------------------------------------------------------------------------------------
//exemplo utilizado na montagem de paramento dinamico
Static Function TelaObs()
	Local aPergs	:= {}
	Local aRet		:= {}                   
	Local cObs		:= ""

	aAdd( aPergs ,{9,"Favor informar a observação para o uso do desconto '%Outros'",200,15,.T.})
	aAdd( aPergs ,{11,"Observação","",'.T.','.T.',.T.})   

	If ParamBox(aPergs ,"Observação",aRet,,,,,,,,.F.,.F.)   
		cObs := aRet[2]
	EndIF

Return cObs                 