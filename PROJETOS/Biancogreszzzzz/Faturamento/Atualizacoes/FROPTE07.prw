#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} FROPTE07
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  - fernando.sis@gmail.com                                              
@since 17/10/2014                                                   
/*/                                                             
//--------------------------------------------------------------
User Function FROPTE07(_CLOTE, _CSALTOT, _CQTDSUG, _CQTDPAL, _CPALETE, _CPONTA, _NREGRA, _CEMPEST, _CLOCEST, _LSHOWREJ)
  Local oButOk
  Local oButRej
  Local oFont1 := TFont():New("Calibri",,026,,.T.,,,,,.F.,.F.)
  Local oFont2 := TFont():New("Calibri",,026,,.T.,,,,,.F.,.F.)
  Local oFont3 := TFont():New("Calibri",,016,,.F.,,,,,.F.,.T.)
  Local oFont4 := TFont():New("Calibri",,028,,.T.,,,,,.F.,.F.)
  Local oFont5 := TFont():New("Calibri",,044,,.T.,,,,,.F.,.F.)
  Local oGroup1
  Local oGroup2
  Local oPanel1
  Local oPanel2
  Local oPanel3
  Local oPanel4
  Local oSay1
  Local oSay10
  Local oSay11
  Local oSay2
  Local oSay3
  Local oSay4
  Local oSay5
  Local oSay6
  Local oSay7
  Local oSay8
  Local oSay9

  Local _NCONFIRMA := 2

  DEFAULT _LSHOWREJ := .F.

  Static oDlgRes

  DEFINE MSDIALOG oDlgRes TITLE "SISTEMA DE RESERVA DE ESTOQUE/OP (Regra "+AllTrim(Str(_NREGRA))+")" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

  @ 000, 000 MSPANEL oPanel1 SIZE 250, 150 OF oDlgRes COLORS 0, 16777215 RAISED
  @ 000, 000 MSPANEL oPanel2 PROMPT "Sugestão de Melhor LOTE para Venda" SIZE 249, 026 OF oPanel1 COLORS 8388608, 16764622 FONT oFont1 CENTERED RAISED
  @ 129, 000 MSPANEL oPanel3 SIZE 249, 020 OF oPanel1 COLORS 0, 16777215 RAISED

  @ 000, 200 BUTTON oButOk PROMPT "ACEITAR" SIZE 070, 019 OF oPanel3 PIXEL ACTION (_NCONFIRMA := 1, oDlgRes:End())

  //If (_LSHOWREJ)
    @ 000, 200 BUTTON oButRej PROMPT "REJEITAR" SIZE 070, 019 OF oPanel3 PIXEL ACTION (_NCONFIRMA := 2, oDlgRes:End())
  //EndIf

  @ 027, 000 MSPANEL oPanel4 SIZE 249, 150 OF oPanel1 COLORS 0, 16777215 RAISED
  @ 000, 000 GROUP oGroup1 TO 024, 248 PROMPT "Informações do Lote" OF oPanel4 COLOR 8421504, 16777215 PIXEL
  @ 024, 000 GROUP oGroup2 TO 101, 248 PROMPT "Palete(s)" OF oPanel4 COLOR 8421504, 16777215 PIXEL

  @ 006, 008 SAY oSay5 PROMPT "Lote:" SIZE 030, 015 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
  @ 006, 038 SAY oSay6 PROMPT _CLOTE SIZE 043, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL
  @ 006, 083 SAY oSay7 PROMPT "Saldo Total:" SIZE 060, 015 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
  @ 006, 140 SAY oSay8 PROMPT _CSALTOT SIZE 079, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL
  @ 006, 175 SAY oSay5 PROMPT "Local:" SIZE 030, 015 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
  @ 006, 205 SAY oSay6 PROMPT AllTrim(_CEMPEST)+"/"+AllTrim(_CLOCEST) SIZE 043, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL

  @ 030, 016 SAY oSay3 PROMPT "Quantidade Sugerida:" SIZE 114, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL
  @ 030, 130 SAY oSay4 PROMPT _CQTDSUG SIZE 093, 015 OF oPanel4 FONT oFont4 COLORS 255, 16777215 PIXEL
  @ 050, 031 SAY oSay9 PROMPT _CQTDPAL+" Paletes de "+_CPALETE+" m2" SIZE 200, 015 OF oPanel4 FONT oFont4 COLORS 255, 16777215 PIXEL
  //@ 055, 090 SAY oSay1 PROMPT "Paletes de 200 m2" SIZE 114, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL
  @ 065, 031 SAY oSay10 PROMPT _CPONTA+" m2 de ponta de estoque." SIZE 200, 015 OF oPanel4 FONT oFont4 COLORS 255, 16777215 PIXEL
  @ 060, 016 SAY oSay11 PROMPT "+" SIZE 012, 022 OF oPanel4 FONT oFont5 COLORS 16711680, 16777215 PIXEL
  //@ 071, 090 SAY oSay2 PROMPT "de ponta de estoque." SIZE 114, 015 OF oPanel4 FONT oFont1 COLORS 8388608, 16777215 PIXEL

  // Don't change the Align Order
  oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
  oPanel2:Align := CONTROL_ALIGN_TOP
  oPanel3:Align := CONTROL_ALIGN_BOTTOM
  oPanel4:Align := CONTROL_ALIGN_ALLCLIENT
  oGroup1:Align := CONTROL_ALIGN_TOP
  oGroup2:Align := CONTROL_ALIGN_ALLCLIENT

  oButOk:Align := CONTROL_ALIGN_RIGHT

  //If (_LSHOWREJ)
    oButRej:Align := CONTROL_ALIGN_RIGHT
  //EndIf

  ACTIVATE MSDIALOG oDlgRes CENTERED

Return(_NCONFIRMA)