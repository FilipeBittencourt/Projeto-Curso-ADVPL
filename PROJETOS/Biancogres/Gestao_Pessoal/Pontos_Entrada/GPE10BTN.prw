#include "Protheus.Ch"
#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

/*/{Protheus.doc} GPE10BTN
@author MADALENO
@since 26/06/07
@version 1.0
@description Alterar Cargo???? 
@type function
/*/

USER FUNCTION GPE10BTN()

Return {'DESTINOS',{||U_Altera_Cargo() },'Setor','Setor'}

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ Altera_Cargo ³ Autor ³BRUNO MADALENO        ³ Data ³ 08/08/08   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTANDO A TELA PRINCIPAL DO HISTORICO DE SETOR                 ³±±
±±³          ³                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
USER FUNCTION Altera_Cargo()

	PUBLIC SOL_TESTE
	PRIVATE GRID := ""
	PRIVATE cNOBS
	PRIVATE cHORAS
	PRIVATE cNomeUsuario := cUserName
	PRIVATE Enter := chr(13) + Chr(10)
	PRIVATE aCampos1
	PRIVATE SQL := ""

	_aCampos1 :={{"SETOR_ATU"		,"C",20,0},;
	{             "SETOR_ANT"		,"C",20,0},;
	{             "DATAS"	   		,"D",12,0}}

	If chkfile("_HIS")
		dbSelectArea("_HIS")
		dbCloseArea()
	EndIf
	_HIS := CriaTrab(_aCampos1)
	dbUseArea(.T.,,_HIS,"_HIS",.t.)
	dbCreateInd(_HIS,"DATAS",{||DATAS})

	SQL := "SELECT * FROM "+RETSQLNAME("SZV")+" " + ENTER
	SQL += "WHERE ZV_MAT = '"+SRA->RA_MAT+"' AND D_E_L_E_T_ = ' ' " + ENTER

	If chkfile("_AUX")
		dbSelectArea("_AUX")
		dbCloseArea()
	EndIf
	TCQUERY SQL ALIAS "_AUX" NEW
	_AUX->(DbGoTop())

	While ! _AUX->(EOF())
		RecLock("_HIS",.t.)
		_HIS->SETOR_ATU	:= _AUX->ZV_SETOATU
		_HIS->SETOR_ANT	:= _AUX->ZV_SETOANT
		_HIS->DATAS	  	:= STOD(_AUX->ZV_DATA)
		MsUnlock()
		_AUX->(DbSkip())
	EndDo

	DbSelectArea("_HIS")

	aCampos1 := {}
	AADD(aCampos1,{"SETOR_ANT"		,"SETOR ANTERIOR"		,30})
	AADD(aCampos1,{"SETOR_ATU"		,"SETOR ATUAL"		   	,30})
	AADD(aCampos1,{"DATAS"		  	,"DATA DA ALTERAÇÃO"	,08})

	_HIS->(DbGoTop())

	MONTA_HIST()

RETURN()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ MONTA_HIST   ³ Autor ³BRUNO MADALENO        ³ Data ³ 08/08/08   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTANDO A TELA PRINCIPAL DO HISTORICO DE SETOR                 ³±±
±±³          ³                                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
STATIC FUNCTION MONTA_HIST()

	PRIVATE cCod
	PRIVATE CAfunc := space(9)
	PRIVATE Afunc := space(30)
	PRIVATE CNfunc := space(9)
	PRIVATE Nfunc := space(30)
	PRIVATE cData  := CTOD("")

	SQL := "SELECT TOP 1 ZV_CODATU COD, ZV_SETOATU SETOR " + ENTER
	SQL += "FROM "+RETSQLNAME("SZV")+" " + ENTER
	SQL += "WHERE	ZV_MAT = '"+SRA->RA_MAT+"' " + ENTER
	SQL += "		AND D_E_L_E_T_ = ' ' " + ENTER
	SQL += "		ORDER BY ZV_DATA DESC " + ENTER
	If chkfile("_AUX2")
		dbSelectArea("_AUX2")
		dbCloseArea()
	EndIf
	TCQUERY SQL ALIAS "_AUX2" NEW
	IF _AUX2->(EOF())
		//Afunc := SRA->RA_APELIDO
	ELSE
		CAfunc := _AUX2->COD
		Afunc  := _AUX2->SETOR
	END IF

	DEFINE MSDIALOG DLG_SOL FROM 0,0 TO 390,720 TITLE "HISTÓRICO DE SETOR" PIXEL

	DEFINE FONT oBold  NAME "Arial" SIZE 0, -09 BOLD
	DEFINE FONT oBold1 NAME "Arial" SIZE 0, -12 //BOLD
	DEFINE FONT oBold2 NAME "Arial" SIZE 0, -16 BOLD
	DEFINE FONT oBold3 NAME "Arial" SIZE 0, -25 BOLD

	// CABECALHO
	@ 001,004 TO 040,357 LABEL "" OF DLG_SOL PIXEL // 1 FRAME DO TITULO 2 MAIS
	@ 003,006 TO 038,355 LABEL "" OF DLG_SOL PIXEL // 2 FRAME DO TITULO
	@ 014,130 SAY "HISTÓRICO DE SETOR"   COLOR CLR_BLUE FONT oBold2 PIXEL

	// BARA DE TAREFAS
	@ 045,004 TO 190,357 LABEL "" COLOR CLR_BLUE OF DLG_SOL PIXEL

	@ 060,010 Say "MATRICULA: "+ ALLTRIM(SRA->RA_MAT) Size 250,07 COLOR CLR_BLUE PIXEL OF DLG_SOL FONT oBold1
	@ 070,010 Say "NOME: " + ALLTRIM(SRA->RA_NOME) Size 250,07 COLOR CLR_BLUE PIXEL OF DLG_SOL FONT oBold1

	@ 100,010 Say "Setor Atual" Size 50,07 COLOR CLR_BLUE PIXEL OF DLG_SOL FONT oBold1
	@ 110,010 GET CAfunc    SIZE 20,10 PICT "@!" WHEN .F.
	@ 110,055 GET Afunc     SIZE 65,10 FONT oBold1 PIXEL OF DLG_SOL  WHEN .F.

	@ 125,010 Say "Novo Setor" Size 50,07 COLOR CLR_BLUE PIXEL OF DLG_SOL FONT oBold1
	@ 135,010 GET CNfunc    SIZE 20,10 F3 "SQBPCM" Valid(fPosiSQB()) PICT "@!" WHEN .F.
	@ 135,055 GET Nfunc     SIZE 65,10 FONT oBold1 PIXEL OF DLG_SOL  WHEN .F.

	@ 150,010 Say "Data Alteração" Size 50,07 COLOR CLR_BLUE PIXEL OF DLG_SOL FONT oBold1
	@ 160,010 GET cData    SIZE 50,10 FONT oBold1 PIXEL OF DLG_SOL  PICTURE "@D" WHEN .F.

	oBrowse1 := IW_Browse(110,160,180,350,"_HIS",,,aCampos1)

	ACTIVATE MSDIALOG DLG_SOL CENTER

RETURN

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fPosiSQB ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 18/10/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPosiSQB()

	Local dfArea := GetArea()

	dbSelectArea("SQB")
	dbSetOrder(1)
	dbSeek(xFilial("SQB")+CNfunc)
	Nfunc := SQB->QB_YPCMSO

	RestArea(dfArea)

Return
