#INCLUDE "PROTHEUS.CH"
#Include 'TOTVS.CH'

User Function ComboBox() 

	Local oDlg
	Local oButton
	Local oCombo
	Local cCombo
	Local aItems := {"item1","item2","item3"} 
	Local cCombo := aItems[2]

	Local cCCusto :=  ""
	Local cCodPgto := ""
	Local cOBS := ""

	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})

	cCCusto := Space(TamSX3("CTT_CUSTO")[1]) 
	cCodPgto := Space(TamSX3("E4_CODIGO")[1])
	cOBS := Space(TamSX3("C7_OBS")[1])

	DEFINE MSDIALOG oDlg TITLE " Contrao de parceria " FROM 0,0 TO 170, 400 OF oMainWnd PIXEL Style DS_MODALFRAME
	
	@ 010,020 SAY "CC: " SIZE 50,10 PIXEL OF oDlg
	@ 025,020 MSGET cCCusto F3 "CTT" SIZE 50, 10 PIXEL OF oDlg

	@ 040,020 SAY "Cond. Pgto: " SIZE 50,10 PIXEL OF oDlg
	@ 055,020 MSGET cCodPgto F3 "SE4" SIZE 50, 10 PIXEL OF oDlg
 
	@ 070,020 SAY "Obs: " SIZE 50,10 PIXEL OF oDlg
	@ 085,020 GET cOBS MEMO SIZE 110, 020 PIXEL OF oDlg MULTILINE 
 

	@ 100,080 BUTTON "Confirma " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())
	ACTIVATE MSDIALOG oDlg CENTER

/*
	DEFINE MSDIALOG oDlg TITLE " Combo " FROM 0,0 TO 150, 300 OF oMainWnd PIXEL Style DS_MODALFRAME
	
		oCombo:= tComboBox():New(10,10,{|u|if(PCount()>0,cCombo:=u,cCombo)},; 
		aItems,100,20,oDlg,,{||MsgStop("Mudou item")},;
		,,,.T.,,,,,,,,,”cCombo”)

		// Botão para fechar a janela 
		@ 40,10 BUTTON oButton PROMPT "Fechar" OF oDlg PIXEL ACTION oDlg:End()
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
	MsgStop( "O valor é "+cCombo ) */
  
	//FwAlertSuccess(" Cadastrado com sucesso !!! ")
	
Return




















	/*
	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})
	Alert("OlÃ¡")
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())

        
	If dbSeek(xFilial("SB1")+"000001")	        // verifica a existencia do registro    	   	            
		cNome := AllTrim(SB1->B1_DESC)
	EndIf
  

Return
 */