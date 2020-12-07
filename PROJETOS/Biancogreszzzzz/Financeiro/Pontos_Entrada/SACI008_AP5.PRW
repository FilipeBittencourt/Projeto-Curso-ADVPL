#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#Include "PROTHEUS.CH"

User Function saci008()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01 

Local oFont1 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Local oGet1
Local oGet2
Local oGet3
Local oSay1
Local oSay2
Local oSay3
Local oSButton1               

Private oDlg
Private cGet3 := SE5->E5_YSI
Private cGet2 := SE5->E5_CLVLDB
Private cGet1 := SE5->E5_ITEMD

If (Alltrim(SE5->E5_TIPODOC) == 'DC') ;
	.OR. (Alltrim(SE5->E5_MOTBX) == 'DES' .AND. Alltrim(SE5->E5_NATUREZ) = '2451') ;
	.OR. ((Alltrim(SE5->E5_TIPO) == 'RPA' .AND. Alltrim(SE5->E5_PREFIXO) == 'GPE' .AND. Alltrim(SE5->E5_MOTBX) $ 'DEB_NOR'))		
	
	
		DEFINE MSDIALOG oDlg TITLE "INFORMAÇÕES COMPLEMENTARES" FROM 000, 000  TO 300, 350 COLORS 0, 16777215 PIXEL
	
	    @ 014, 005 SAY oSay1 PROMPT "Informe o Item Contabil de Débito:" SIZE 140, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	    @ 031, 010 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "CTD" PIXEL
	    @ 054, 005 SAY oSay2 PROMPT "Informe a Classe de Valor de Débito:" SIZE 150, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	    @ 070, 010 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "CTH" PIXEL
	    @ 091, 005 SAY oSay3 PROMPT "Informe o Cliente da SI:" SIZE 089, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	    @ 104, 010 MSGET oGet3 VAR cGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SA1" PIXEL
	    DEFINE SBUTTON oSButton1 FROM 130, 067 TYPE 01 OF oDlg ENABLE ACTION Altera()
	
	  ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return  

Static Function Altera() 

Reclock("SE5",.F.)   

	SE5->E5_YSI 	:= cGet3
	SE5->E5_CLVLDB 	:= cGet2
	SE5->E5_ITEMD  	:= cGet1

MsUnlock()   

oDlg:End()

Return




//Desabilitado 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//SetPrvt("_ARQANT,_INDANT,_REGANT,_NOVADATA,_DTA,")


//DESABILITADO
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SACI008  ³ Autor ³ Nilton                 ³ Data ³ 17/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera vencimento da comissao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_Arqant := Alias()
_indant := IndexOrd()
_Regant := Recno()
DbSelectArea("SE3")
DbSetOrder(1)
If DbSeek(xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
   Reclock("SE3",.F.)
   If Day(SE1->E1_BAIXA)<=11
      _novadata := "15"+"/"+STRZERO(Month(SE1->E1_BAIXA),2)+"/"+Right(Dtoc(SE1->E1_BAIXA),2)
   Else
      If Month(SE1->E1_BAIXA) < 12
         _novadata := "15"+"/"+STRZERO(Month(SE1->E1_BAIXA)+1,2)+"/"+Right(Dtoc(SE1->E1_BAIXA),2)
      else
         _dta := SE1->E1_BAIXA + 23
         _novadata := "15"+"/"+STRZERO(Month(_dta),2)+"/"+Right(Dtoc(_dta),2)
      EndIf
   EndIf
   Reclock("SE3",.f.)
   SE3->E3_EMISSAO := Ctod(_novadata)
   MsUnlock()
EndIf
DbSelectArea(_arqant)
Return*/
