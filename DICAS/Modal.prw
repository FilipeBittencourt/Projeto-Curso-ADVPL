#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10)


 

//U_Modal1
USer Function Modal1()    
 
  Local cTes       := ""  
  Local cCodPgto   := ""  
  Local oModal     := Nil  
  Local lNext      := .T.
  Local aCombo     := {'A=Não enviados','P=Um Envio sem resposta','S=Dois Envios sem resposta','R=Resposta enviada','N=Fechada sem resposta','T=Todos'}
  Local cCombo     := ""
  Local cObs       := ""
  Local cNome      := ""

  If Select("SX6") <= 0	
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	

  cTes     := SPACE(TamSX3("F4_CODIGO")[01])  
  cCodPgto := SPACE(TamSX3("E4_CODIGO")[01])    

  oModal  := FWDialogModal():New()         
  oModal:SetEscClose(.F.)    // Não permite fechar com ESC
  oModal:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
  oModal:SetBackground(.T.)  // Escurece o fundo da janela
  oModal:setTitle("PTX0035C")
  oModal:setSubTitle("Informe os dados abaixo")
  oModal:setSize(200, 200) //Seta a altura e a largura da janela em pixel
  oModal:createDialog() //Cria Dialog  
  
  oPanel := TPanel():New( ,,, oModal:getPanelMain())  
  oPanel:Align := CONTROL_ALIGN_ALLCLIENT

  TSay():New( 015,010,{||"NOME:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,011)
  TGet():New( 012,040,{|u|  If(PCount()>0,cNome:=u,cNome)  /*F2_YNOMZAP*/ },oPanel,100,011,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNome",,)

  TSay():New( 035,012,{||"TES:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,011)
  TGet():New( 032,040,{|u| If(PCount()>0,cTes:=u,cTes)},oPanel,080,011,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","cTes",,)
  
  TSay():New( 055,010,{||"Cond. Pgto:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,011)  
  TGet():New( 052,040,{|u| If(PCount()>0,cCodPgto:=u,cCodPgto)},oPanel,080,011,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCodPgto",,)    
  
   TSay():New( 075,010,{||"Combo:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,011)  
   TComboBox():New(072,040,{|u| if(PCount()>0,cCombo:=u,cCombo)},aCombo,080,011,oPanel,,/*{||Alert(cCombo)}*/,,,,.T.,,,,,,,,,"cCombo")

  TSay():New( 095,010,{||"OBS:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
   TMultiget():new( 092, 040, {|u| if(PCount()>0,cObs:=u,cObs)}, oPanel, 050/*width*/,020/*height*/, , , , , , .T., , , , , , .F./* ReadOnly  é .T. */ )

  
  //oModal:addCloseButton(nil, "Fechar")
  //oModal:AddOKButton({||FwAlertInfo(cTes,"Info") }, "Prosseguir")
  oModal:AddButton( 'Prosseguir', { || lNext := .T.,  oModal:DeActivate()} , 'Prosseguir'   ,,.T.,.F.,.T.,)
  oModal:AddButton( 'Fechar', { || lNext := .F.,  oModal:DeActivate()} , 'Fechar' ,,.T.,.F.,.T.,)  
  oModal:Activate()  
   
Return 



//U_Modal2
user function Modal2()


	Local oModal   := NIL
	Local cCCusto  := NIL
	Local cNome  := NIL
	Local cCodPgto := NIL
	Local cOBS     := Nil
	Local aCombo := {'A=Não enviados','P=Um Envio sem resposta','S=Dois Envios sem resposta','R=Resposta enviada','N=Fechada sem resposta','T=Todos'}

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
 
	oModal:Activate()

return



User Function Modal3()
  
  Local cTes          := ""
  Local cCodPgto      := ""
  Local oModal        := Nil
  Local oPanel        := Nil
  Local lNext         := .F.

 

  cTes     := SPACE(TamSX3("F4_CODIGO")[01])
  cCodPgto := SPACE(TamSX3("E4_CODIGO")[01])

  oModal  := FWDialogModal():New()
  oModal:SetEscClose(.F.)    // Não permite fechar com ESC
  oModal:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
  oModal:SetBackground(.T.)  // Escurece o fundo da janela
  oModal:setTitle("PTX0035B")
  oModal:setSubTitle("Informe os dados abaixo")
  oModal:setSize(150, 200) //Seta a altura e a largura da janela em pixel
  oModal:createDialog() //Cria Dialog

  oPanel := TPanel():New( ,,, oModal:getPanelMain())
  oPanel:Align := CONTROL_ALIGN_ALLCLIENT
  TSay():New( 020,025,{||"TES:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  TGet():New( 020,040,{|u| If(PCount()>0,cTes:=u,cTes)},oPanel,080,011,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","cTes",,)
  TSay():New( 040,009,{||"Cond. Pgto:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  TGet():New( 040,040,{|u| If(PCount()>0,cCodPgto:=u,cCodPgto)},oPanel,080,011,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCodPgto",,)
  TSay():New( 060,025,{||"Combo:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  TComboBox():New(060,040,{|u| if(PCount()>0,cCombo:=u,cCombo)},aCombo,080,011,oPanel,,{||Alert(cCombo)},,,,.T.,,,,,,,,,"cCombo")

  oModal:AddButton( 'Prosseguir', { || lNext := .T.,  oModal:DeActivate()} , 'Prosseguir'   ,,.T.,.F.,.T.,)
  oModal:AddButton( 'Fechar', { || lNext := .F.,  oModal:DeActivate()} , 'Fechar' ,,.T.,.F.,.T.,)

  oModal:Activate()

  If lNext == .F.
    Return
  Else
    If !ExistCpo("SF4", cTes)
      FwAlertWarning('Dados inválidos! Favor digite uma TES válida','Aviso')
      Return
    Endif
    If  !ExistCpo("SE4", cCodPgto)
      FwAlertWarning('Dados inválidos! Favor digite uma Condição de pagemto válida','Aviso')
      Return
    Endif
  Endif


return
