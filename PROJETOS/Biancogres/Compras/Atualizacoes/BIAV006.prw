#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#include "rwmake.ch"  

User Function BIAV006()
	if U_VALOPER("054")
		addForm()
	end if
Return

Static Function addForm()
	PRIVATE AAREA		:= GETAREA()
	Private cDtCole := Date()
	PRIVATE cNf := SPACE(9)
	PRIVATE cSer := SPACE(3)
	PRIVATE dGetDt := SC1->C1_YDTCOLE// Variável do tipo Data
	PRIVATE dGetNf := SC1->C1_YNF
	lHasButton := .T.
	if Empty(dGetDt) .or. U_VALOPER("053") 
	    DEFINE DIALOG ODLG TITLE "Coleta de material pelo fornecedor" FROM 100,300 TO 500,1100 PIXEL
	    oTFont := TFont():New(,,-16,.T.)
        oTSay := TSay():New( 05, 30,{||"SC Bizagi: "+SC1->C1_YBIZAGI + " SC Protheus: " + SC1->C1_NUM },oDlg;
             ,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		
		@ 25,30 SAY "Data da coleta: "
	    //@ 05,100 GET cDtCole SIZE 40,30  PICTURE "@!D"
	    
	     dGetDt1 := TGet():New( 25, 100, {|u| If(PCount()>0,cDtCole:=u,dGetDt)},oDlg, ;
	     060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDtCole",,,,lHasButton  )
	
	     @ 44,30 SAY "Nota de remessa: "
	     @ 044,100 Get cNf F3 ("SF2SC") size 057,010 Object oGet1 
	     @ 60,30 SAY "Série: "
	     @ 060,100 Get cSer           size 025,010 Object oGet2 
	     //oGet1      := TGet():New( 024,100,{|u| If(PCount()>0,cNf:=u,dGetNf)},oDlg,052,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"cNf","",,)
	
	    @ 83,170 BMPBUTTON TYPE 1 ACTION Fgrava()
	    @ 83,200 BMPBUTTON TYPE 2 ACTION Close(ODLG)
			
		ACTIVATE DIALOG ODLG CENTERED
	
	EndIf
	
	RESTAREA(AAREA)
Return

Static Function Fgrava()
    if FexiNf()
	    RecLock("SC1",.F.)
		SC1->C1_YDTCOLE := cDtCole
		SC1->C1_YNF := cNf
		SC1->C1_YNFSER := cSer
		SC1->(MsUnlock())
		Close(ODLG)
	else 
		MSGSTOP("Nota não encontrada em saldo de terceiros (SB6). Favor entrar em contato com a Contabilidade!", "Nota de remessa")
    end if
	
Return

Static Function FexiNf()
    private bExNf := .F.
	private cSQL := ""
	cSQL += " SELECT B6_DOC " 
	cSQL += " FROM SB6010 " 
	cSQL += " WHERE B6_DOC = '" + cNf + "' " 
	cSQL += " AND D_E_L_E_T_ = '' " 
	cSQL += " AND B6_SERIE = '" + cSer + "' " 
	cSQL += " AND B6_PODER3 = 'R' " 
	
	If chkfile("SB6_CONS")
		dbSelectArea("SB6_CONS")
		dbCloseArea()
	EndIf
	
	TcQuery cSql New Alias "SB6_CONS"

	While !SB6_CONS->(Eof())
		bExNf := .T.
		SB6_CONS->(DbSkip())
	EndDo
   SB6_CONS->(DbCloseArea())
  
	
Return bExNf