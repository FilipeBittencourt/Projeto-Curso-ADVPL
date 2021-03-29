#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RWMAKE.CH"

//---------------------------------------------------------------------------------------
// Programa LIB_FINAN           MADALENO           
// Desc.    FUNCAO PARA REJEITAR O TITULO
// Data 	11/05/10  
//---------------------------------------------------------------------------------------
// Alterado:
// 12/02/2015	Thiago Dantas	OS 0664-15 
//---------------------------------------------------------------------------------------
USER FUNCTION _LIB_FINAN()
	Private aBrowse1 := {}
	Private aBrowse2 := {}
	Private CSQL := ""
	Private ENTER := CHR(13)+CHR(10)
	Private lDebug := .F.
	Private oUnCheck := LoadBitmap(GetResources(), "WFUNCHK")
	Private oCheck := LoadBitmap(GetResources(), "WFCHK")

	DEFINE DIALOG oDlg TITLE "LIBERAวรO FINANCEIRA" FROM 180,180 TO 800	,1195 PIXEL

	oFont1  := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2  := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )

	// Painel no topo da tela
	@00,00 MSPANEL oPnlTop OF oDlg SIZE 160,32
	oPnlTop:Align := CONTROL_ALIGN_TOP

	oSay1	:= TSay():New(008,175,{||"LIBERAวรO FINANCEIRA"},oPnlTop,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,016)

	// Painel na area total da tela
	@00,00 MSPANEL oPnlAll OF oDlg SIZE 160,32
	oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

	// Folder de tipos de titulos
	aFolder := {'TITULOS A PAGAR', 'TITULOS A RECEBER'}
	oFolder := TFolder():New(040,004,aFolder,,oPnlAll,,,,.T.,,270,503)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	// ROTINA PARA MONTAR O BROWSE SE2 CONTAS A PAGAR
	COMP_SE2()

	oBrowse1 := TWBrowse():New( 013 , 005, 490,100,,{'', 'Prefixo','N๚mero','Parcela','Tipo','Cod. Fornec','Loja','Fornecedor','Valor','Saldo','Motivo'},{2,25,30,25,20,35,20,120,50,50,50},oFolder:aDialogs[1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse1:SetArray(aBrowse1)
	oBrowse1:bLine := {||{ If (aBrowse1[oBrowse1:nAt,01] == 1, oCheck, oUnCheck), aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05],;
		aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08],aBrowse1[oBrowse1:nAt,09],aBrowse1[oBrowse1:nAt,10],aBrowse1[oBrowse1:nAt,11] }}
	oBrowse1:bLDblClick := {|| fMarkCP() }
	oBrowse1:Align := CONTROL_ALIGN_ALLCLIENT


	// ROTINA PARA MONTAR O BROWSE SE2 CONTAS A RECEBER
	COMP_SE1()

	oBrowse2 := TWBrowse():New( 148 , 005, 490,100,,{'', 'Prefixo','N๚mero','Parcela','Tipo','Cod. Client','Loja','Cliente','Valor','Desconto','Motivo'},{2,25,30,25,20,35,20,120,50,50,50},oFolder:aDialogs[2],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse2:SetArray(aBrowse2)
	oBrowse2:bLine := {|| { If (aBrowse2[oBrowse2:nAt,01] == 1, oCheck, oUnCheck), aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04],aBrowse2[oBrowse2:nAt,05],;
		aBrowse2[oBrowse2:nAt,06],aBrowse2[oBrowse2:nAt,07],aBrowse2[oBrowse2:nAt,08],aBrowse2[oBrowse2:nAt,09],aBrowse2[oBrowse2:nAt,10],aBrowse2[oBrowse2:nAt,11] }}
	oBrowse2:bLDblClick := {|| fMarkCR() }
	oBrowse2:Align := CONTROL_ALIGN_ALLCLIENT

	// Barra de botoes
	oButtonBar := FWButtonBar():New()
	oButtonBar:Init(oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	oButtonBar:AddBtnText("REJEITAR", "", {|| fRejeita(oFolder:nOption) },,,CONTROL_ALIGN_RIGHT, .T.)
	oButtonBar:AddBtnText("LIBERAวรO", "", {|| fLibera(oFolder:nOption) },,,CONTROL_ALIGN_RIGHT, .T.)

	ACTIVATE DIALOG oDlg CENTERED


RETURN

//---------------------------------------------------------------------------------------
// Programa REJ_SE2           MADALENO           
// Desc.    FUNCAO PARA REJEITAR O TITULO
// Data 	23/12/09   
//---------------------------------------------------------------------------------------
// Alterado:
// 12/02/2015	Thiago Dantas	OS 0664-15 
//---------------------------------------------------------------------------------------
STATIC FUNCTION REJ_SE2(nLin)
	Local cPrefixo := aBrowse1[nLin,2]
	Local cTitulo	:= aBrowse1[nLin,3]
	Local cParcela := aBrowse1[nLin,4]
	Local cTipo := aBrowse1[nLin,5]
	Local cFornece := aBrowse1[nLin,6]
	Local cLoja	:= aBrowse1[nLin,7]
	Local cDesc	:= aBrowse1[nLin,8]

	DbSelectArea("SE2")
	DbSetOrder(1)
	If !DbSeek(xFilial("SE2")+cPrefixo+cTitulo+cParcela+cTipo+cFornece+cLoja)
		MsgBox("Nใo hแ Tํtulo para ser Rejeitado!","Aten็ใo",'STOP')
		Return
	EndIf

	If MsgBox ("Deseja rejeitar o TITULO A PAGAR " +cTitulo+ " da empresa "+cDesc+" ?","Aten็ใo","YesNo")

		RecLock("SE2", .F.)
		SE2->E2_YBLQ 	:= ''
		SE2->E2_YOBSLIB	:= ''
		MsUnlock()

		// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
		C_TITULO 	:= "Titulo do Contas a Pagar Rejeitado "
		C_DESTI		:= "alessa.gomes@biancogres.com.br"

		C_MENS 		:= "Titulo Rejeitado na " + IIF(CEMPANT="01","Biancogres",IIF(CEMPANT="05","Incesa",IIF(CEMPANT="14","Vitcer","Biancogres")))
		C_MENS 		+= " "  + CHR(13)+CHR(10)
		C_MENS 		+= "N๚mero do Titulo:	" 	+ SE2->E2_NUM + CHR(13)+CHR(10)
		C_MENS 		+= "Cod Fornecedor:		" 	+ SE2->E2_FORNECE + CHR(13)+CHR(10)
		C_MENS 		+= "Nome Fornecedor:	" 	+ SE2->E2_NOMFOR + CHR(13)+CHR(10)
		C_MENS 		+= "Valor do Titulo:	" 	+ ALLTRIM(STR(SE2->E2_VALOR)) + CHR(13)+CHR(10)
		C_MENS 		+= "Saldo do Titulo:	" 	+ ALLTRIM(STR(SE2->E2_SALDO)) + CHR(13)+CHR(10)
		C_MENS 		+= "OBS: "  + CHR(13)+CHR(10)
		C_MENS 		+= ALLTRIM(SE2->E2_YOBSLIB)

		If lDebug
			C_DESTI := 'tiago@facilesistemas.com.br'
		EndIf

		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)
		aBrowse1 := {}

		COMP_SE2()

		oBrowse1:SetArray(aBrowse1)
		oBrowse1:bLine := {||{ If (aBrowse1[oBrowse1:nAt,01] == 1, oCheck, oUnCheck), aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05],;
			aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08],aBrowse1[oBrowse1:nAt,09],aBrowse1[oBrowse1:nAt,10],aBrowse1[oBrowse1:nAt,11] }}
		oBrowse1:DrawSelect()

	END IF

RETURN

//---------------------------------------------------------------------------------------
// Programa LIB_SE2           MADALENO           
// Desc.    FUNCAO PARA LIBERAR O TITULO
// Data 	23/12/09   
//---------------------------------------------------------------------------------------
// Alterado:
// 12/02/2015	Thiago Dantas	OS 0664-15 
//---------------------------------------------------------------------------------------
STATIC FUNCTION LIB_SE2(nLin)
	Local cPrefixo := aBrowse1[nLin,2]
	Local cTitulo	:= aBrowse1[nLin,3]
	Local cParcela := aBrowse1[nLin,4]
	Local cTipo := aBrowse1[nLin,5]
	Local cFornece := aBrowse1[nLin,6]
	Local cLoja	:= aBrowse1[nLin,7]
	Local cDesc	:= aBrowse1[nLin,8]

	DbSelectArea("SE2")
	DbSetOrder(1)
	If !DbSeek(xFilial("SE2")+cPrefixo+cTitulo+cParcela+cTipo+cFornece+cLoja)
		MsgBox("Nใo hแ Tํtulo para ser Liberado!","Aten็ใo",'STOP')
		Return
	EndIf

	If MsgBox ("Confirma a libera็ใo do TITULO A PAGAR " +cTitulo+ " da empresa "+ cDesc +" ?","Aten็ใo","YesNo")

		//TELA PARA A DIGITAวรO DA OBSERVAวรO
		Private cCOBSS     := Space(255)
		SetPrvt("oDlg1","oGet1")
		oDlg1      := MSDialog():New( 103,235,233,614,"OBSERVAวรO",,,.F.,,,,,,.T.,,,.T. )
		oGet1      := TGet():New( 004,004,{|u| If(PCount()>0,cCOBSS:=u,cCOBSS)},oDlg1,176,034,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCOBSS",,)
		//oMemo:= tMultiget():New(004,004,{|u|if(Pcount()>0,cCOBSS:=u,cCOBSS)},oDlg1,176,034,,,,,,.T.)
		oBtn1      := TButton():New( 044,144,"CONFIRMA",oDlg1,{|| oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
		oDlg1:Activate(,,,.T.)

		If ALLTRIM(cCOBSS) = ""
			ALERT("Favor informar a Obrserva็ใo!")
			Return
		EndIf

		RecLock("SE2",.F.)
		SE2->E2_YBLQ 	:= 'XX'
		SE2->E2_YOBSLIB := AllTrim(cCOBSS)
		MsUnlock()

		// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
		C_TITULO 	:= "Titulo do Contas a Pagar Liberado"
		C_DESTI		:= "alessa.gomes@biancogres.com.br"
		C_MENS 		:= "Titulo Liberado na " + IIF(CEMPANT="01","Biancogres",IIF(CEMPANT="05","Incesa",IIF(CEMPANT="14","Vitcer","Biancogres")))
		C_MENS 		+= " "  + CHR(13)+CHR(10)
		C_MENS 		+= "N๚mero do Titulo:	" 	+ SE2->E2_NUM + CHR(13)+CHR(10)
		C_MENS 		+= "Cod Fornecedor:	" 		+ SE2->E2_FORNECE + CHR(13)+CHR(10)
		C_MENS 		+= "Nome Fornecedor:	" 	+ SE2->E2_NOMFOR + CHR(13)+CHR(10)
		C_MENS 		+= "Valor do Titulo:	" 	+ ALLTRIM(STR(SE2->E2_VALOR)) + CHR(13)+CHR(10)
		C_MENS 		+= "Saldo do Titulo:	" 	+ ALLTRIM(STR(SE2->E2_SALDO)) + CHR(13)+CHR(10)
		C_MENS 		+= "OBS: "  + CHR(13)+CHR(10)
		C_MENS 		+= ALLTRIM(SE2->E2_YOBSLIB)

		If lDebug
			C_DESTI := 'tiago@facilesistemas.com.br'
		EndIf

		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)

		aBrowse1 := {}

		COMP_SE2()

		oBrowse1:SetArray(aBrowse1)
		oBrowse1:bLine := {||{ If (aBrowse1[oBrowse1:nAt,01] == 1, oCheck, oUnCheck), aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05],;
			aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08],aBrowse1[oBrowse1:nAt,09],aBrowse1[oBrowse1:nAt,10],aBrowse1[oBrowse1:nAt,11] }}
		oBrowse1:DrawSelect()

	END IF

RETURN

//---------------------------------------------------------------------------------------
// Programa REJ_SE1           MADALENO           
// Desc.    FUNCAO PARA REJEITAR O TITULO
// Data 	23/12/09   
//---------------------------------------------------------------------------------------
// Alterado:
// 12/02/2015	Thiago Dantas	OS 0664-15 
//---------------------------------------------------------------------------------------
STATIC FUNCTION REJ_SE1(nLin)
	Local cPrefixo := aBrowse2[nLin,2]
	Local cTitulo	:= aBrowse2[nLin,3]
	Local cParcela := aBrowse2[nLin,4]
	Local cTipo := aBrowse2[nLin,5]
	Local cCliente := aBrowse2[nLin,6]
	Local cLoja	:= aBrowse2[nLin,7]
	Local cDesc	:= aBrowse2[nLin,8]

	DbSelectArea("SE1")
	DbSetOrder(1)
	If!DbSeek(xFilial("SE1")+cPrefixo+cTitulo+cParcela+cTipo+cCliente+cLoja)
		MsgBox("Nใo hแ Tํtulo para ser rejeitado!","Aten็ใo",'STOP')
		Return
	EndIf

	If MsgBox ("Deseja rejeitar o TITULO A RECEBER " +cTitulo+ " da empresa "+ cDesc+" ?","Aten็ใo","YesNo")

		RecLock("SE1",.F.)
		SE1->E1_YBLQ 	:= ""
		SE1->E1_YOBSLIB	:= ""
		MsUnlock()

		// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
		C_TITULO 	:= "Titulo do Contas a Receber Rejeitado"
		C_DESTI		:= "wellison.toras@biancogres.com.br;nadine.araujo@biancogres.com.br"
		C_COPIA		:= ""
		C_MENS 		:= "Titulo Liberado na " + IIF(CEMPANT="01","Biancogres",IIF(CEMPANT="05","Incesa",IIF(CEMPANT="14","Vitcer","Biancogres")))
		C_MENS 		+= " "  + CHR(13)+CHR(10)
		C_MENS 		+= "N๚mero do Titulo:	" 	+ SE1->E1_NUM + CHR(13)+CHR(10)
		C_MENS 		+= "Cod Cliente:	" 		+ SE1->E1_CLIENTE + CHR(13)+CHR(10)
		C_MENS 		+= "Nome Cliente:	" 		+ SE1->E1_NOMCLI + CHR(13)+CHR(10)
		C_MENS 		+= "OBS: "  + CHR(13)+CHR(10)
		C_MENS 		+= ALLTRIM(SE1->E1_YOBSLIB)
		C_ANEXO		:= ""

		If lDebug
			C_DESTI := 'tiago@facilesistemas.com.br'
		EndIf

		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)

		aBrowse2 := {}

		COMP_SE1()

		oBrowse2:SetArray(aBrowse2)
		oBrowse2:bLine := {||{ If (aBrowse2[oBrowse2:nAt,01] == 1, oCheck, oUnCheck), aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04],aBrowse2[oBrowse2:nAt,05],;
			aBrowse2[oBrowse2:nAt,06],aBrowse2[oBrowse2:nAt,07],aBrowse2[oBrowse2:nAt,08],aBrowse2[oBrowse2:nAt,09],aBrowse2[oBrowse2:nAt,10],aBrowse2[oBrowse2:nAt,11] }}

		oBrowse2:DrawSelect()

	END IF

RETURN
//---------------------------------------------------------------------------------------
// Programa LIB_SE1           MADALENO           
// Desc.    FUNCAO PARA LIBERAR O TITULO
// Data 	23/12/09   
//---------------------------------------------------------------------------------------
// Alterado:
// 12/02/2015	Thiago Dantas	OS 0664-15 
//---------------------------------------------------------------------------------------

STATIC FUNCTION LIB_SE1(nLin)
	Local cPrefixo := aBrowse2[nLin,2]
	Local cTitulo	:= aBrowse2[nLin,3]
	Local cParcela := aBrowse2[nLin,4]
	Local cTipo := aBrowse2[nLin,5]
	Local cCliente := aBrowse2[nLin,6]
	Local cLoja	:= aBrowse2[nLin,7]
	Local cDesc	:= aBrowse2[nLin,8]

	DbSelectArea("SE1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SE1")+cPrefixo+cTitulo+cParcela+cTipo+cCliente+cLoja)
		MsgBox("Nใo hแ Tํtulo para ser Liberado!","Aten็ใo",'STOP')
		Return
	EndIf

	If MsgBox ("Confirma a libera็ใo do TITULO A RECEBER " +cTitulo+ " da empresa "+ cDesc+" ?","Aten็ใo","YesNo")

		//TELA PARA A DIGITAวรO DA OBSERVAวรO
		Private cCOBSS     := Space(255)
		SetPrvt("oDlg1","oGet1")
		oDlg1      := MSDialog():New( 103,235,233,614,"OBSERVAวรO",,,.F.,,,,,,.T.,,,.T. )
		oGet1      := TGet():New( 004,004,{|u| If(PCount()>0,cCOBSS:=u,cCOBSS)},oDlg1,176,034,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCOBSS",,)
		//oMemo:= tMultiget():New(004,004,{|u|if(Pcount()>0,cCOBSS:=u,cCOBSS)},oDlg1,176,034,,,,,,.T.)
		oBtn1      := TButton():New( 044,144,"CONFIRMA",oDlg1,{|| oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
		oDlg1:Activate(,,,.T.)
		IF ALLTRIM(cCOBSS) = ""
			ALERT("OBSERVAวรO OBRIGATำRIA")
			RETURN
		END IF

		MV_PAR01 := ''
		Pergunte("FA070T",.T.)

		RecLock("SE1",.F.)
		SE1->E1_YBLQ 	:= AllTrim(MV_PAR01)
		SE1->E1_YOBSLIB := AllTrim(cCOBSS)
		MsUnlock()

		// ENVIANCO EMAIL PARA OS RESPONSAVEIS PELO FINANCEIRO
		C_TITULO 	:= "Titulo do Contas a Receber Liberado"
		C_DESTI		:= "nadine.araujo@biancogres.com.br"
		C_COPIA		:= ""
		C_MENS 		:= "Titulo Liberado na " + IIF(CEMPANT="01","Biancogres",IIF(CEMPANT="05","Incesa",IIF(CEMPANT="14","Vitcer","Biancogres")))
		C_MENS 		+= " "  + CHR(13)+CHR(10)
		C_MENS 		+= "N๚mero do Titulo:	" 	+ SE1->E1_NUM + CHR(13)+CHR(10)
		C_MENS 		+= "Cod Cliente:	" 		+ SE1->E1_CLIENTE + CHR(13)+CHR(10)
		C_MENS 		+= "Nome Cliente:	" 		+ SE1->E1_NOMCLI + CHR(13)+CHR(10)
		C_MENS 		+= "OBS: "+ALLTRIM(SE1->E1_YOBSLIB) + CHR(13)+CHR(10)
		C_MENS 		+= "C๓digo de Autoriza็ใo: "+ALLTRIM(SE1->E1_YBLQ)
		C_ANEXO		:= ""

		If lDebug
			C_DESTI := 'tiago@facilesistemas.com.br'
		EndIf

		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)

		aBrowse2 := {}

		COMP_SE1()

		oBrowse2:SetArray(aBrowse2)
		oBrowse2:bLine := {||{ If (aBrowse2[oBrowse2:nAt,01] == 1, oCheck, oUnCheck), aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04],aBrowse2[oBrowse2:nAt,05],;
			aBrowse2[oBrowse2:nAt,06],aBrowse2[oBrowse2:nAt,07],aBrowse2[oBrowse2:nAt,08],aBrowse2[oBrowse2:nAt,09],aBrowse2[oBrowse2:nAt,10],aBrowse2[oBrowse2:nAt,11] }}

		oBrowse2:DrawSelect()

	EndIf

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOMPOEM_SE2       ณ MADALENO           บ Data ณ  23/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FUNCAO PARA MONTAR O BROWSE                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION COMP_SE2()
	PRIVATE CSQL 	:= ""
	PRIVATE ENTER	:= CHR(13)+CHR(10)

	cQUERY := "SELECT  E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VALOR, E2_SALDO, E2_YBLQ, R_E_C_N_O_ " + ENTER
	cQUERY += "FROM "+RETSQLNAME("SE2")+" WITH (NOLOCK) 		" + ENTER
	cQUERY += "WHERE	E2_FILIAL = '"+xFilial("SE2")+"'    AND	" + ENTER
	cQUERY += "      	E2_TIPO	<> 'PA'	    AND					" + ENTER
	cQUERY += "			E2_SALDO	<> 0	AND					" + ENTER
	cQUERY += "			(E2_YBLQ <> 'XX' AND E2_YBLQ <> '') AND	" + ENTER // FLAG RESPONSAVEL EM BLOQUEAR
	cQUERY += "			E2_YOBSLIB  = '' AND 					" + ENTER
	cQUERY += "			D_E_L_E_T_ 	= ''						" + ENTER
	If chkfile("_TRAB")
		dbSelectArea("_TRAB")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_TRAB" NEW

	IF _TRAB->(EOF())
		aAdd(aBrowse1,{0,"","","","","","","","","","",0})
		RETURN
	END IF

	DO WHILE ! _TRAB->(EOF())

		aAdd(aBrowse1,{0;
			,_TRAB->E2_PREFIXO ;
			, _TRAB->E2_NUM ;
			, _TRAB->E2_PARCELA ;
			, _TRAB->E2_TIPO ;
			, _TRAB->E2_FORNECE ;
			, _TRAB->E2_LOJA ;
			, ALLTRIM(_TRAB->E2_NOMFOR) ;
			, "R$" + (Transform(  _TRAB->E2_VALOR ,"@E 999,999,999,999.99")) ;
			, "R$" + (Transform(  _TRAB->E2_SALDO ,"@E 999,999,999,999.99")) ;
			, IIF(_TRAB->E2_YBLQ = "01","PA",IIF(_TRAB->E2_YBLQ = "02","DESCONTO",""));
			, _TRAB->R_E_C_N_O_ })
		_TRAB->(DBSKIP())
	END DO


RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COMPOEM_SE1      ณ MADALENO           บ Data ณ  23/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FUNCAO PARA MONTAR O BROWSE                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION COMP_SE1()
	PRIVATE CSQL 	:= ""
	PRIVATE ENTER	:= CHR(13)+CHR(10)

	cQUERY := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA,  E1_NOMCLI, E1_SALDO, E1_VALOR, E1_YBLQ, E1_YVLDESC, R_E_C_N_O_	" + ENTER
	cQUERY += "FROM "+RETSQLNAME("SE1")+" WITH (NOLOCK)			" + ENTER
	cQUERY += "WHERE	E1_FILIAL = '"+xFilial("SE1")+"'    AND	" + ENTER
	cQUERY += "			(E1_YBLQ <> 'XX' AND E1_YBLQ <> '') AND	" + ENTER
	cQUERY += "			E1_YOBSLIB = '' AND						" + ENTER
	cQUERY += "			D_E_L_E_T_ = ''							" + ENTER
	If chkfile("_TRAB")
		dbSelectArea("_TRAB")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_TRAB" NEW

	IF _TRAB->(EOF())
		aAdd(aBrowse2,{0, "","","","","","","","","",0})
		RETURN
	END IF

	DO WHILE ! _TRAB->(EOF())


		aAdd(aBrowse2,{0;
			,_TRAB->E1_PREFIXO ;
			, _TRAB->E1_NUM ;
			, _TRAB->E1_PARCELA ;
			, _TRAB->E1_TIPO ;
			, _TRAB->E1_CLIENTE ;
			, _TRAB->E1_LOJA ;
			, ALLTRIM(_TRAB->E1_NOMCLI) ;
			, "R$" + (Transform(  _TRAB->E1_SALDO ,"@E 999,999,999,999.99")) ;
			, "R$" + (Transform(  _TRAB->E1_YVLDESC,"@E 999,999,999,999.99"))  ;
			, IIF(_TRAB->E1_YBLQ = "01","PA",IIF(_TRAB->E1_YBLQ = "02","DESCONTO",""));
			, _TRAB->R_E_C_N_O_ })
		_TRAB->(DBSKIP())
	END DO


RETURN


Static Function fMarkCP()
	Local nPos := 0

	// Se existe itens a liberar
	If Len(aBrowse1) > 0

		// Se jแ existe algum item marcaco
		nPos := aScan(aBrowse1, {|x| x[1] == 1 })

		// Caso ja exista e nใo seja o item da selecao atual, limpa a marcacao
		If nPos > 0 .And. nPos <> oBrowse1:nAt
			aBrowse1[nPos,01] := 0
		EndIf


		// Atualiza marcacao
		If aBrowse1[oBrowse1:nAt,01] == 0
			aBrowse1[oBrowse1:nAt,01] := 1
		ElseIf aBrowse1[oBrowse1:nAt,01] == 1
			aBrowse1[oBrowse1:nAt,01] := 0
		Else
			aBrowse1[oBrowse1:nAt,01] := 0
		EndIf

		oBrowse1:Refresh()

	EndIf

Return()


Static Function fMarkCR()
	Local nPos := 0

	// Se existe itens a liberar
	If Len(aBrowse2) > 0

		// Se jแ existe algum item marcaco
		nPos := aScan(aBrowse2, {|x| x[1] == 1 })

		// Caso ja exista e nใo seja o item da selecao atual, limpa a marcacao
		If nPos > 0 .And. nPos <> oBrowse2:nAt
			aBrowse2[nPos,01] := 0
		EndIf


		// Atualiza marcacao
		If aBrowse2[oBrowse2:nAt,01] == 0
			aBrowse2[oBrowse2:nAt,01] := 1
		ElseIf aBrowse2[oBrowse2:nAt,01] == 1
			aBrowse2[oBrowse2:nAt,01] := 0
		Else
			aBrowse2[oBrowse2:nAt,01] := 0
		EndIf

		oBrowse2:Refresh()

	EndIf

Return()


Static Function fLibera(nOption)
	Local nPos := 0

	If nOption == 1

		// Se jแ existe algum item a pagar marcaco
		nPos := aScan(aBrowse1, {|x| x[1] == 1 })

		If nPos > 0
			LIB_SE2(nPos)
		Else
			MsgBox("Aten็ใo, nenhum Tํtulo a Pagar foi marcado!")
		EndIf

	ElseIf nOption == 2

		// Se jแ existe algum item a receber marcaco
		nPos := aScan(aBrowse2, {|x| x[1] == 1 })

		If nPos > 0
			LIB_SE1(nPos)
		Else
			MsgBox("Aten็ใo, nenhum Tํtulo a Receber foi marcado!")
		EndIf

	EndIf

Return()


Static Function fRejeita(nOption)
	Local nPos := 0

	If nOption == 1

		// Se jแ existe algum item a pagar marcaco
		nPos := aScan(aBrowse1, {|x| x[1] == 1 })

		If nPos > 0
			REJ_SE2(nPos)
		Else
			MsgBox("Aten็ใo, nenhum Tํtulo a Pagar foi marcado!")
		EndIf

	ElseIf nOption == 2

		// Se jแ existe algum item a receber marcaco
		nPos := aScan(aBrowse2, {|x| x[1] == 1 })

		If nPos > 0
			REJ_SE1(nPos)
		Else
			MsgBox("Aten็ใo, nenhum Tํtulo a Receber foi marcado!")
		EndIf

	EndIf
Return()