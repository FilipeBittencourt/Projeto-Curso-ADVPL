#include 'totvs.ch'

user function Layer()


	Local oModal   := NIL
	Local cCCusto  := NIL
	Local cNome  := NIL
	Local cCodPgto := NIL
	Local cOBS     := Nil

	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})

	cCCusto :=  Space(TamSX3("CTT_CUSTO")[1]) 
	cCCusto  := Space(TamSX3("CTT_CUSTO")[1]) 
	cCodPgto := Space(TamSX3("E4_CODIGO")[1])
	cOBS     := Space(TamSX3("C7_OBS")[1])
 
 	oModal := FwDialogModal():New()
	oModal:SetTitle("Filipe Teste")
	oModal:SetSize(200,300) //Height , Width
	oModal:CreateDialog()
		

	oPnl := oModal:GetPanelMain()	

	//TScrollBox():New( [ oWnd ], [ nTop ], [ nLeft ], [ nHeight ], [ nWidth ], [ lVertical ], [ lHorizontal ], [ lBorder ] )
	oPnl := TScrollBox():New(oPnl,01,01,150,295,.T.,.F.,.F.)
	//@ 005,005 GROUP oGrop1 TO  130,285  PROMPT "Formulário A" OF oPnl PIXEL
	
	@ 030,030 SAY "Nome: " SIZE 050,010 OF oPnl PIXEL
	@ 027,060 MSGET oGet01 VAR cNome  SIZE 0100, 011  OF oPnl PIXEL 

	@ 050,030 SAY "CC: " SIZE 050,010 OF oPnl PIXEL
	@ 047,060 MSGET oGet02 VAR cCCusto  F3 "CTT" SIZE 050,011  OF oPnl PIXEL

    @ 070,030 SAY "Cond. Pgto: " SIZE 050,010 OF oPnl PIXEL
	@ 067,060 MSGET oGet03 VAR cCodPgto F3 "SE4" SIZE 050,011 OF oPnl PIXEL
 
	@ 090,030 SAY "Obs: " SIZE 050,010 OF oPnl PIXEL
	@ 087,060 GET oGet04 VAR cOBS MEMO SIZE 110, 020 OF oPnl PIXEL MULTILINE
	
	aBtn := {}
	AADD(aBtn, {"","Confirmar01",{||Alert("Ok!")} ,"ToolTip01",5,.T.,.T. })
	AADD(aBtn, {"","Confirmar02",{||Alert("Ok!")} ,"ToolTip02",5,.T.,.T. })
	AADD(aBtn, {"","Confirmar03",{||Alert("Ok!")} ,"ToolTip03",5,.T.,.T. })
	AADD(aBtn, {"","Confirmar04",{||Alert("Ok!")} ,"ToolTip04",5,.T.,.T. })

	oModal:addButtons( aBtn  ) 

	//oModal:addButtons("Confirmar",{|| Alert("Ok!") }) 
  
	//oModal:addCloseButton(nil, "Fechar")
 
	oModal:Activate()

return




/*
user function Layer()

	

	local oDlg    as object
	local oLayer  as object
	local oPnlDoc as object
	local oPnlObs as object
	local oWdwDoc as object
	local oWdwObs as object



	Local oDlg := Nil
	Local aButtons := {}
	Local oBtn
	Local cCCusto  := NIL
	Local cCodPgto := NIL
	Local cOBS     := Nil

	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})

	cCCusto :=  Space(TamSX3("CTT_CUSTO")[1]) 
	cCCusto  := Space(TamSX3("CTT_CUSTO")[1]) 
	cCodPgto := Space(TamSX3("E4_CODIGO")[1])
	cOBS     := Space(TamSX3("C7_OBS")[1])

	oDlg := FwDialogModal():New()
	oDlg:SetTitle("Filipe Teste")
	oDlg:SetSize(100,200)
	oDlg:CreateDialog()
	 

	Define MsDialog oDlg Title 'Teste de Tela com Enchoice' From 0, 0 To 450, 700 Pixel Style DS_MODALFRAME

	//Cria a enchoide primeiro, dessa forma o Layer já terá conhecimento da enchoice e de seu tamanho
	EnchoiceBar(oDlg,{ || oDlg:End() },{ || oDlg:End() },.F.,,,,.F.,.F.,.F.,.T.,.F.)

	oLayer := FwLayer():New()

	oLayer:Init(oDlg)

	//Montagem das Layers
	oLayer:AddLine('LIN1', 035, .F.)
	oLayer:AddLine('LIN2', 065, .F.)

	oLayer:AddCollumn('COL1', 100, .T., 'LIN1')
	oLayer:AddCollumn('COL2', 100, .T., 'LIN2')

	oLayer:AddWindow('COL1', 'DOC'    , 'Dados do Manifesto'        , 100, .F. ,.T.,, 'LIN1', { || })
	oLayer:AddWindow('COL2', 'OBS'    , 'Observação do Manifesto'    , 100, .F. ,.T.,, 'LIN2', { || })

	//Montagem dos Painéis
	oPnlDoc := oLayer:GetWinPanel('COL1', 'DOC'    , 'LIN1')
	oPnlObs    := oLayer:GetWinPanel('COL2', 'OBS'    , 'LIN2')

	//Informando Títulos dos Painéis
	oLayer:GetWindow('COL1', 'DOC', @oWdwDoc, 'LIN1')
	oWdwDoc:oTitleBar:oFont := TFont():New('MS Sans Serif',,16,,.T.)

	oLayer:GetWindow('COL2', 'OBS', @oWdwObs, 'LIN2')
	oWdwObs:oTitleBar:oFont := TFont():New('MS Sans Serif',,16,,.T.)


		@ 010,020 SAY "CC: " SIZE 50,10 PIXEL OF oDlg
		@ 025,020 MSGET cCCusto F3 "CTT" SIZE 50, 10 PIXEL OF oDlg

	Activate MsDialog oDlg

return nil
*/

/*
user function Layer()
//DEFINE MSDIALOG oDlg TITLE "Teste EnchoiceBar" FROM 000,000 TO 400,600 PIXEL 	

Aadd( aButtons, {"HISTORIC", {|| TestHist()}, "Histórico1...", "Histórico1" , {|| .T.}} )     		
Aadd( aButtons, {"HISTORIC", {|| TestHist()}, "Histórico2...", "Histórico2" , {|| .T.}} )  
Aadd( aButtons, {"HISTORIC", {|| TestHist()}, "Histórico3...", "Histórico3" , {|| .T.}} )  

	@ 050,030 SAY "CC: " SIZE 50,10 PIXEL OF oDlg
	@ 047,060 MSGET cCCusto Picture "@!" F3 "CTT" SIZE 50, 10 PIXEL OF oDlg  

	//@ 142,019 Get cFiltro of oDlg Picture "@!" F3 "SED" 

    @ 070,030 SAY "Cond. Pgto: " SIZE 50,10 PIXEL OF oDlg
	@ 067,060 MSGET cCodPgto F3 "SE4" SIZE 50, 10 PIXEL OF oDlg
 
	@ 090,030 SAY "Obs: " SIZE 50,10 PIXEL OF oDlg
	@ 087,060 GET cOBS MEMO SIZE 110, 020 PIXEL OF oDlg MULTILINE        

//ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons))
 oDlg:Activate()
Return 

Static Function TestHist()	
	FwAlertSuccess("Mostra histórico")
Return
*/