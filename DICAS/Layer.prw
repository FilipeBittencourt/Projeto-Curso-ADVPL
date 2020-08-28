#include 'totvs.ch'

//U_Layer
user function Layer()


	Local oModal   := NIL
	Local cCCusto  := NIL
	Local cNome  := NIL
	Local cCodPgto := NIL
	Local cOBS     := Nil
	Local aStatus := {'A=Não enviados','P=Um Envio sem resposta','S=Dois Envios sem resposta','R=Resposta enviada','N=Fechada sem resposta','T=Todos'}

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

