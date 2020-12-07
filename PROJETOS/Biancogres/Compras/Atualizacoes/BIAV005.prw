#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#include "rwmake.ch"  

User Function BIAV005()
	if U_VALOPER("054")
		addForm()
	end if

Return

Static Function addForm()
	PRIVATE AAREA		:= GETAREA()
	Private cDtReceb := Date()
	PRIVATE dGetDt := SC1->C1_YDTENT// Variável do tipo Data
	lHasButton := .T.
	
	if Empty(dGetDt) .or. U_VALOPER("053")
	
	
	 
		DEFINE DIALOG ODLG TITLE "Recebimento de material no almoxarifado" FROM 100,300 TO 500,1100 PIXEL
		oTFont := TFont():New(,,-16,.T.)
       oTSay := TSay():New( 05, 30,{||"SC Bizagi: "+SC1->C1_YBIZAGI + " SC Protheus: " + SC1->C1_NUM },oDlg;
             ,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		//@ 05,30 SAY "SC Bizagi: "+SC1->C1_YBIZAGI + " SC Protheus: " + SC1->C1_NUM Font oTFont
		
		@ 25,30 SAY "Data Recebimento Material: "
	    //@ 05,100 GET cDtReceb SIZE 40,30  PICTURE "@!D"
	    
	    dGetDt1 := TGet():New( 25, 100, {|u| If(PCount()>0,cDtReceb:=u,dGetDt)},oDlg, ;
	     060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDtReceb",,,,lHasButton  )
	
	
	    @ 83,170 BMPBUTTON TYPE 1 ACTION Fgrava()
	    @ 83,200 BMPBUTTON TYPE 2 ACTION Close(ODLG)
			
		ACTIVATE DIALOG ODLG CENTERED
	
	EndIf
	
	RESTAREA(AAREA)
Return

Static Function Fgrava()
	RecLock("SC1",.F.)
	SC1->C1_YDTENT := cDtReceb
	SC1->C1_YUSUENT := cUserName
	SC1->(MsUnlock())
	Close(ODLG)
Return