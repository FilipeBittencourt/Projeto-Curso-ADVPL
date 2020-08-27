#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10) 

//U_000TESTS
USer Function 000TESTS()    
 
  Local cTes       := ""  
  Local cCodPgto   := ""  
  Local oModal     := Nil
  Local lRet       := .F.

  If Select("SX6") <= 0	
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	

  cTes     := SPACE(TamSX3("F4_CODIGO")[01])  
  cCodPgto := SPACE(TamSX3("E4_CODIGO")[01])  

  SetPrvt("oDlg","oGrp","oSay1","oSay2","oGet1","oGet2")

  oModal  := FWDialogModal():New()         
  oModal:SetEscClose(.F.)    // Não permite fechar com ESC
  oModal:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
  oModal:SetBackground(.T.)  // Escurece o fundo da janela
  oModal:setTitle("PTX0035C")
  oModal:setSubTitle("Informe os dados abaixo")
  oModal:setSize(150, 200) //Seta a altura e a largura da janela em pixel
  oModal:createDialog() //Cria Dialog  
  
  oPanel := TPanel():New( ,,, oModal:getPanelMain())  
  oPanel:Align := CONTROL_ALIGN_ALLCLIENT
  oSay1  := TSay():New( 020,025,{||"TES:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oGet1  := TGet():New( 020,040,{|u| If(PCount()>0,cTes:=u,cTes)},oPanel,080,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","cTes",,)
  oSay2  := TSay():New( 040,009,{||"Cond. Pgto:"},oPanel,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)  
  oGet2  := TGet():New( 040,040,{|u| If(PCount()>0,cCodPgto:=u,cCodPgto)},oPanel,080,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCodPgto",,)    

  //oModal:addCloseButton(nil, "Fechar")
  //oModal:AddOKButton({||FwAlertInfo(cTes,"Info") }, "Prosseguir")
 
   oModal:AddButton( 'Fechar', { || lRet := .T.,  oModal:DeActivate()} , 'Fechar'   ,,.T.,.F.,.T.,)
   oModal:AddButton( 'Cancelar', { || lRet := .F.,  oModal:DeActivate()} , 'Cancelar' ,,.T.,.F.,.T.,)
   oModal:AddButton('Op1'    , { || lRet := .F., oModal:DeActivate()})
   oModal:AddButton('Op2'    , { || lRet := .F., oModal:DeActivate()})
   oModal:AddButton('Op3'    , { || lRet := .F., oModal:DeActivate()})
   
  
  /*oModal:AddButtons(;
		{;
		{'', 'Fechar', {|| alert("Fechou") }, '','', .T., .T.},;
    {'', 'Prosseguir', {|| alert("Foi") }, '','', .T., .T.};
		};
	)*/
	

  oModal:Activate()
  
  //oContainer := TPanel():New( ,,, oModal:getPanelMain() )
  //oContainer:SetCss("TPanel{background-color : red;}")
  //oContainer:Align := CONTROL_ALIGN_ALLCLIENT
  //TSay():New(1,1,{|| "Teste "},oContainer,,,,,,.T.,,,30,20,,,,,,.T.)

  


  //42190511145209000160550010000366791005113007	
  // ZZZ->(dbSetOrder(1))	
  //If !ZZZ->(dbSeek("01"+"42190511145209000160550010000366791005113007"))	
  //   Return .f.	
  // EndIf
  /*

  SetPrvt("oDlg","oGrp","oSay1","oSay2","oGet1","oGet2")

  oDlg   := MSDialog():New( 000,232,200,600,"PTX0035C",,,.F.,,,,,,.T.,,,.T. )
  oGrp   := TGroup():New( 003,004,072,181,"Informe os dados abaixo",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. ) 
  oSay1  := TSay():New( 020,025,{||"TES:"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oGet1  := TGet():New( 020,040,{|u| If(PCount()>0,cTes:=u,cTes)},oGrp,080,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","cTes",,)
  oSay2  := TSay():New( 040,009,{||"Cond. Pgto:"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)  
  oGet2  := TGet():New( 040,040,{|u| If(PCount()>0,cCodPgto:=u,cCodPgto)},oGrp,080,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCodPgto",,)

  oBtn1      := TButton():New( 080,080,"Fechar",oGrp,{||oDlg:End()},040,015,,,,.T.,,"",,,,.F. )
  oBtn2      := TButton():New( 080,140,"Confirmar",oGrp,{||alert("Abriu")},040,015,,,,.T.,,"",,,,.F. )
  oDlg:Activate(,,,.T.)*/
Return 
