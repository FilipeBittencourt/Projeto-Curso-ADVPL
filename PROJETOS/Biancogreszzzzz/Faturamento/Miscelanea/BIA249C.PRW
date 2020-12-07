#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#DEFINE TKTSCOMUNSEMP 1
#DEFINE TKTSCOMPEMP 2
#DEFINE CARGASCOMPEMP 3
#DEFINE TKTUNICO 4

//----------------------------------------------------------------------------------------------------------------------------------------
User Function BIA249C()

Private oDlgCarga
Private oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Private oFont2 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Private oGroup1
Private oSay1
Private oSay10
Private oSay11
Private oSay12
Private oSay13
Private oSay14
Private oSay15
Private oSay16
Private oSay17
Private oSay18
Private oSay19
Private oSay2
Private oSay3
Private oSay4
Private oSay5
Private oSay6
Private oSay7
Private oSay8
Private oSay9
Private oMultiGet1
Private cMultiGet1 := ""
Private xfAlterObs := .F.
Private kt_BsDad
Private ktGuardi   := ""
Private n := 1

Private rbCarga := ""
Private rbTickt := ""
Private rbDtInc := ctod("  /  /  ")
Private rbPlaca := ""
Private rbMotor := ""
Private rbPsFat := 0
Private rbPsEco := 0
Private rbPsBal := 0
Private KL001 	:= "" 
Private QM007 	:= "" 
Private JV004 	:= ""
Private xDiverg 

If cEmpAnt == "01"
	kt_BsDad := "DADOSEOS"
ElseIf cEmpAnt == "05"
	kt_BsDad := "DADOS_05_EOS"
Else
	MsgINFO("Empresa não configurada para controle de BALANÇA!!!")
	Return
EndIf

MontaSql()

If Empty(KL001)
	MsgINFO("Não há Ticket para essa carga!")
	Return
EndIf

TCQUERY KL001 ALIAS "KL01" NEW
dbSelectArea("KL01")
dbGoTop()

// Monta o cabeçalho da tela
if !KL01->(Eof())
	If Empty(rbCarga)
		rbTickt    := KL01->Z43_TKT
		rbDtInc    := stod(KL01->ZZV_DATINC)
		rbPlaca    := KL01->ZZV_PLACA
		rbMotor    := KL01->ZZV_MOTOR
		rbPsBal    := KL01->PESO_BAL
	EndIf
	rbPsFat    := KL01->PESO_FAT
	rbPsEco    := KL01->PESO_ECO
	dbSelectArea("KL01")
	dbSkip()
Else
	MsgINFO("Não há composição de carga")
	KL01->(dbCloseArea())
	Return
EndIf

//KL01->(dbCloseArea())
MontaTela()

Return

//----------------------------------------------------------------------------------------------------------------------------------------
Static Function fGetDdCarga()

Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"Z43_EMPR", "ZZV_TICKET", "ZZV_CARGA", "ZZV_PLACA", "ZZV_MOTOR", "ZZV_DATINC", "ZZW_NUMOCE", "D2_CLIENTE", "A1_NOME", "D2_DOC", "D2_SERIE", "D2_PEDIDO", "D2_ITEMPV", "B1_COD", "B1_DESC", "D2_LOTECTL", "D2_QUANT", "PESO_FAT", "ECO_QUANT", "PESO_ECO"}
//Local aFields := {"CARGAECO","D2_CLIENTE","D2_LOJA","A1_NOME","D2_DOC","D2_SERIE","D2_PEDIDO","D2_ITEMPV","D2_COD","B1_DESC","D2_LOTECTL","D2_QUANT","PESOPRT","QUANTECO","PESOECO","D2_EMISSAO"}
Local aAlterFields := {}
Private oGetDdCarga

// Define field properties
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For nX := 1 to Len(aFields)
	
	If Alltrim(aFields[nX]) == "ZZW_NUMOCE"
		Aadd(aHeaderEx, {"CargaEco", "CARGAECO", "@!", 10, 0, , , "C", , , ,})
		
	ElseIf Alltrim(aFields[nX]) == "Z43_EMPR"
		Aadd(aHeaderEx, {AllTrim("Emp."),SX3->X3_CAMPO,SX3->X3_PICTURE, 05,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

	ElseIf Alltrim(aFields[nX]) == "ZZV_CARGA"
		Aadd(aHeaderEx, {AllTrim("Carga"),SX3->X3_CAMPO,SX3->X3_PICTURE, 05,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

	ElseIf Alltrim(aFields[nX]) == "B1_DESC"
		Aadd(aHeaderEx, {AllTrim("Descrição"),SX3->X3_CAMPO,SX3->X3_PICTURE, 40,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

	ElseIf Alltrim(aFields[nX]) == "B1_COD"
		Aadd(aHeaderEx, {AllTrim("Produto"),SX3->X3_CAMPO,SX3->X3_PICTURE, 10,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		
	ElseIf Alltrim(aFields[nX]) == "A1_NOME"
		Aadd(aHeaderEx, {AllTrim("Nome"),SX3->X3_CAMPO,SX3->X3_PICTURE, 40,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		
	ElseIf Alltrim(aFields[nX]) == "PESO_FAT"
		Aadd(aHeaderEx, {"PesoNota", "PESO_FAT", "@E 999,999,999.99", 14, 2, , , "N", , , ,})
		
	ElseIf Alltrim(aFields[nX]) == "PESO_ECO"
		Aadd(aHeaderEx, {"PesoEco", "PESO_ECO", "@E 999,999,999.99", 14, 2, , , "N", , , ,})
		
	ElseIf Alltrim(aFields[nX]) == "ECO_QUANT"
		Aadd(aHeaderEx, {"QuantEco", "ECO_QUANT", "@E 999,999,999.99", 14, 2, , , "N", , , ,})
		
	ElseIf SX3->(DbSeek(aFields[nX]))
		Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		
	Endif
	
Next nX

SqlCarga()
TCQUERY QM007 ALIAS "QM07" NEW
dbSelectArea("QM07")
dbGoTop()
While !Eof()
	//Aadd(aFieldFill, {QM07->Z43_TKT,QM07->Z43_EMPR, QM07->ZZV_TICKET, QM07->ZZV_CARGA, QM07->ZZV_PLACA, QM07->ZZV_MOTOR, QM07->ZZV_DATINC, QM07->ZZW_NUMOCE, QM07->D2_CLIENTE, QM07->A1_NOME, QM07->D2_DOC, QM07->D2_SERIE, QM07->D2_PEDIDO, QM07->D2_ITEMPV, QM07->B1_COD, QM07->B1_DESC, QM07->D2_LOTECTL, QM07->D2_QUANT, QM07->PESO_FAT, QM07->ECO_QUANT, QM07->PESO_ECO, stod(QM07->D2_EMISSAO), .F.})
	Aadd(aFieldFill, {QM07->Z43_EMPR, QM07->ZZV_TICKET, QM07->ZZV_CARGA, QM07->ZZV_PLACA, QM07->ZZV_MOTOR, stod(QM07->ZZV_DATINC), QM07->ZZW_NUMOCE, QM07->D2_CLIENTE, QM07->A1_NOME, QM07->D2_DOC, QM07->D2_SERIE, QM07->D2_PEDIDO, QM07->D2_ITEMPV, QM07->B1_COD, QM07->B1_DESC, QM07->D2_LOTECTL, QM07->D2_QUANT, QM07->PESO_FAT, QM07->ECO_QUANT, QM07->PESO_ECO,.F.})
	//Aadd(aFieldFill, {QM07->ZZW_NUMOCE, QM07->D2_CLIENTE, QM07->A1_NOME, QM07->D2_DOC, QM07->D2_SERIE, QM07->D2_PEDIDO, QM07->D2_ITEMPV, QM07->B1_COD, QM07->B1_DESC, QM07->D2_LOTECTL, QM07->D2_QUANT, QM07->PESO_FAT, QM07->ECO_QUANT, QM01->PESO_ECO, stod(ECO_QUANT->D2_EMISSAO), .F. })
	dbSkip()
End

//QM07->(dbCloseArea())

// Define field values
If Len(aFieldFill) == 0
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nX := 1 to Len(aFields)
		If Alltrim(aFields[nX]) == "CARGAECO"
			Aadd(aFieldFill, CriaVar("F2_YAGREG"))
			
		ElseIf Alltrim(aFields[nX]) == "PESOPRT"
			Aadd(aFieldFill, CriaVar("D2_QUANT"))
			
		ElseIf Alltrim(aFields[nX]) == "QUANTECO"
			Aadd(aFieldFill, CriaVar("D2_QUANT"))
			
		ElseIf Alltrim(aFields[nX]) == "PESOECO"
			Aadd(aFieldFill, CriaVar("D2_QUANT"))
			
		ElseIf DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)
Else
	aColsEx := aFieldFill
EndIf

oGetDdCarga := MsNewGetDados():New( 085, nCol*.005, nLin*.405, nCol*.485, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCarga, aHeaderEx, aColsEx)

Return

//----------------------------------------------------------------------------------------------------------------------------------------
Static Function BIA249CA()

Local gnX
Local gHeaderEx := {}
Local gColsEx := {}
Local gFieldFill := {}
Local gFields := {"D2_DOC","D2_SERIE","D2_EMISSAO","D2_CLIENTE","D2_LOJA","A1_NOME"}
Local gAlterFields := {}
Private oGDNfVc
Private oDlgNfVinc

// Define field properties
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For gnX := 1 to Len(gFields)
	If SX3->(dbSeek(gFields[gnX]))
		Aadd(gHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	Endif
Next gnX

SqlConsult()

JV004 := ChangeQuery(JV004)
cIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,JV004),'DH04',.T.,.T.)
aStruX := ("DH04")->(dbStruct())
/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
gh_IndX := "D2_DOC"
If !chkfile("JV04")
	JV04 := U_BIACrTMP(aStruX)
	dbUseArea( .T.,, JV04, "JV04", .F., .F. )
	dbCreateInd(JV04, gh_IndX,{ || gh_IndX })
EndIf
dbSelectArea("JV04")
APPEND FROM ("DH04")
If Select("DH04") > 0
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado
	DH04->(dbCloseArea())
Endif

dbSelectArea("JV04")
dbGoTop()
While !Eof()
	Aadd(gFieldFill, {JV04->D2_DOC, JV04->D2_SERIE, stod(JV04->D2_EMISSAO), JV04->D2_CLIENTE, JV04->D2_LOJA, JV04->A1_NOME, .F. })
	dbSkip()
End
Ferase(JV04+GetDBExtension())     //arquivo de trabalho
Ferase(JV04+OrdBagExt())          //indice gerado
JV04->(dbCloseArea())

// Define field values
If Len(gFieldFill) == 0
	dbSelectArea("SX3")
	dbSetOrder(2)
	For gnX := 1 to Len(gFields)
		If dbSeek(gFields[gnX])
			Aadd(gFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next gnX
	Aadd(gFieldFill, .F.)
	Aadd(gColsEx, gFieldFill)
Else
	gColsEx := gFieldFill
EndIf

DEFINE MSDIALOG oDlgNfVinc TITLE "Relação de Notas Vinculadas" FROM 000, 000  TO 530, 700 COLORS 0, 16777215 PIXEL

oGDNfVc := MsNewGetDados():New( 008, 004, 243, 345, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", gAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgNfVinc, gHeaderEx, gColsEx)

ACTIVATE MSDIALOG oDlgNfVinc CENTERED ON INIT (EnchoiceBar(oDlgNfVinc, {|| IIF(1==1, oDlgNfVinc:End(),) }, {|| oDlgNfVinc:End()},,))

Return
//----------------------------------------------------------------------------------------------------------------------------------------
Static Function BIA249CC()

If !Empty(rbTickt)
	If xfAlterObs
		xfAlterObs := .F.
	Else
		xfAlterObs := .T.
	EndIf
EndIf

Return

//----------------------------------------------------------------------------------------------------------------------------------------
Static Function BIA249CO()

fgtArea := GetArea()

If !Empty(rbTickt)
	
	dbSelectArea("Z11")
	dbSetOrder(1)
	If dbSeek(xFilial("Z11")+rbTickt)
		RecLock("Z11",.F.)
		Z11->Z11_OBSER := Alltrim(cMultiGet1)
		MsUnLock()
	EndIf
	
	xfAlterObs := .F.
	
EndIf

RestArea(fgtArea)

Return ( .T. )

//----------------------------------------------------------------------------------------------------------------------------------------
//											::: BLOCO DE PERGUNTA :::
//----------------------------------------------------------------------------------------------------------------------------------------
Static Function fValidPerg()
local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}
	
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data Faturamento        ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data Faturamento       ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","De Carga                   ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até Carga                  ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Tipo Relatório     		   ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Carga","","","","","Ticket Composto","","","","","Carga Composta","","","","","Ticket Unico","","","","","","","","",""})

	For i := 1 to Len(aRegs)
	
		lInsert := !DbSeek(cPerg + aRegs[i,2])
		
		RecLock("SX1", lInsert)
			
			For j := 1 to FCount()
			
				If j <= Len(aRegs[i])
					
					FieldPut(j,aRegs[i,j])
					
				Endif
				
			Next
			
		MsUnlock()
				
	Next
	
	dbSelectArea(_sAlias)

Return

//----------------------------------------------------------------------------------------------------------------------------------------
//											:::: BLOCO DE ITERFACES ::::
//----------------------------------------------------------------------------------------------------------------------------------------
Static Function MontaTela()

nCol := oMainWnd:nClientWidth
nLin := oMainWnd:nClientHeight

DEFINE MSDIALOG oDlgCarga TITLE "Controle de Pesagem de Carga" FROM  nLin*.001, nCol*.001 TO nLin*.88, nCol*.975 COLORS 0, 16777215 PIXEL

@ nLin*.005, nCol*.005 GROUP oGroup1 TO 080, nCol*.485 OF oDlgCarga COLOR 0, 16777215 PIXEL

@ 009, 012 SAY oSay3 PROMPT "Composição:"                             SIZE 068, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 009, 070 SAY oSay4 PROMPT rbTickt                                   SIZE 031, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

@ 009, 114 SAY oSay5 PROMPT "Dt Entrada:"                             SIZE 068, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 009, 160 SAY oSay6 PROMPT dtoc(rbDtInc)                             SIZE 036, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

@ 027, 012 SAY oSay7 PROMPT "Placa:"                                  SIZE 028, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 027, 042 SAY oSay8 PROMPT Transform(rbPlaca, "@R AAA-9999")         SIZE 041, 010 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL
@ 027, 114 SAY oSay9 PROMPT "Motorista:"                              SIZE 043, 011 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 027, 160 SAY oSay10 PROMPT rbMotor                                  SIZE 131, 010 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

@ 050, 012 SAY oSay11 PROMPT "Peso Faturamento:"                      SIZE 075, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 065, 033 SAY oSay12 PROMPT Transform(rbPsFat, "@E 999,999,999.99")  SIZE 056, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL
@ 050, 114 SAY oSay13 PROMPT "Peso Ecosis:"                           SIZE 055, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 065, 115 SAY oSay14 PROMPT Transform(rbPsEco, "@E 999,999,999.99")  SIZE 049, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL
@ 050, 190 SAY oSay15 PROMPT "Peso Balança:"                          SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 065, 198 SAY oSay16 PROMPT Transform(rbPsBal, "@E 999,999,999.99")  SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

xDiverg := (rbPsFat - rbPsBal) / rbPsFat * 100
@ 050, 273 SAY oSay17 PROMPT "Divergência:"                           SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
@ 065, 280 SAY oSay18 PROMPT Transform(xDiverg, "@E 999,999.99")+" %" SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

fGetDdCarga()
zrButtons := {} 

aAdd(zrButtons,{"NOVACELULA",{|| BIA249CRel()},"Imprimir"})

ACTIVATE MSDIALOG oDlgCarga CENTERED ON INIT (EnchoiceBar(oDlgCarga, {|| fFinCarga(), oDlgCarga:End() }, {|| oDlgCarga:End()},,zrButtons))

QM07->(dbCloseArea())
KL01->(dbCloseArea()) 

Return
//----------------------------------------------------------------------------------------------------------------------------------------
//											:::: BLOCO DE SQLs ::::
//----------------------------------------------------------------------------------------------------------------------------------------
Static Function MontaSql()


If !Empty(ZZV->ZZV_TICKET)

KL001 += "	SELECT Z43_TKT,ZZV_DATINC,ZZV_PLACA,
KL001 += "	MAX(ZZV_MOTOR) AS ZZV_MOTOR,   
KL001 += "	SUM(PESO_PROD + PESO_EMB) AS PESO_FAT , 
//KL001 += "	SUM(ISNULL(Z11_PESLIQ,0)) AS PESO_BAL, 
//(15/12/2014) Alterado para atender OUTSOURCING 
KL001 += "	SUM(ISNULL((CASE WHEN EMPR <> ZZ7_EMP THEN 0 ELSE Z11.Z11_PESLIQ END), 0)) AS PESO_BAL, 
KL001 += "	SUM(ECO_PESO)  AS PESO_ECO
KL001 += "	FROM(
KL001 += "	SELECT	Z43_TKT, ZZV_CARGA, ZZV_TICKET, ZZV.EMPR, ZZV_DATINC,ZZV_PLACA,ZZ7_EMP, 
KL001 += "			MAX(ZZV_MOTOR) AS ZZV_MOTOR, 
KL001 += "			SUM(SD2.D2_QUANT*Z9.ZZ9_PESO)AS PESO_PROD,  
KL001 += "			SUM(CASE WHEN B1_TIPCONV = 'D' THEN (SD2.D2_QUANT/B1.B1_CONV)*Z9.ZZ9_PESEMB 
KL001 += "									   ELSE (SD2.D2_QUANT*B1.B1_CONV)*Z9.ZZ9_PESEMB 
KL001 += "			END) AS PESO_EMB,
KL001 += "			SUM(ECO.ECO_QUANT) AS ECO_QUANT,
KL001 += "			SUM(ECO.ECO_PESO)  AS ECO_PESO
KL001 += "			
KL001 +="		FROM Z43010 Z43 WITH(NOLOCK)
KL001 +="		INNER JOIN VW_ZZV_EMP ZZV WITH(NOLOCK) ON Z43.Z43_EMPR	= ZZV.EMPRESA AND ZZV.ZZV_TICKET = Z43.Z43_PESAGE 
KL001 +="		INNER JOIN Z11010 Z11 WITH(NOLOCK) ON Z11.Z11_PESAGE = ZZV.ZZV_TICKET
KL001 +="		INNER JOIN VW_ZZW_EMP ZZW WITH(NOLOCK) ON ZZW.EMPR = ZZV.EMPR AND ZZW.ZZW_CARGA = ZZV.ZZV_CARGA
KL001 +="		INNER JOIN VW_SC9_EMP SC9 WITH(NOLOCK) ON SC9.C9_EMP = ZZW.EMPR AND SC9.C9_PEDIDO = ZZW.ZZW_PEDIDO AND SC9.C9_ITEM = ZZW.ZZW_ITEM AND SC9.C9_SEQUEN = ZZW.ZZW_SEQUEN  AND  SC9.C9_AGREG = ZZW_CARGA 
KL001 +="		INNER JOIN VW_SD2_EMP SD2 WITH(NOLOCK) ON SC9.C9_EMP = SD2.D2_EMP AND SC9.C9_PEDIDO	= SD2.D2_PEDIDO	AND SC9.C9_PRODUTO	= SD2.D2_COD	AND SC9.C9_LOTECTL  = SD2.D2_LOTECTL	AND SC9.C9_QTDLIB	= SD2.D2_QUANT	AND SC9.C9_CLIENTE  = SD2.D2_CLIENTE	AND SC9.C9_ITEM		= SD2.D2_ITEMPV	AND SC9.C9_NFISCAL	= SD2.D2_DOC	AND SC9.C9_SERIENF	= SD2.D2_SERIE	AND SC9.C9_NUMSEQ	= SD2.D2_NUMSEQ	
KL001 +="		LEFT JOIN 
KL001 +="				  (
KL001 +="					SELECT DISTINCT PRO_CARGA, IFE.ECO_CARGA,ECO_PEDIDO, IFE.ECO_PRODUTO, IFE.ECO_LOTE , IFE.ECO_QUANT, IFE.ECO_PESO
KL001 +="					FROM VW_FAT_ECOSIS FE
KL001 +="					INNER JOIN VW_ITEM_FAT_ECOSIS IFE 
KL001 +="					ON IFE.ECO_EMP		= FE.ECO_EMP
KL001 +="					AND IFE.ECO_CARGA	= FE.ECO_CARGA             
KL001 +="				  )	ECO 
KL001 +="		ON ECO.PRO_CARGA = ZZV.ZZV_CARGA AND ECO.ECO_CARGA = ZZW.ZZW_NUMOCE AND ECO.ECO_PEDIDO	= SD2.D2_PEDIDO AND ECO.ECO_PRODUTO	= SD2.D2_COD  AND ECO.ECO_LOTE		= SD2.D2_LOTECTL  AND ECO.ECO_QUANT		= SD2.D2_QUANT
//KL001 +="		LEFT JOIN  VW_ITEM_FAT_ECOSIS IFE ON IFE.ECO_EMP	= SD2.D2_EMP AND  IFE.ECO_CARGA = ZZW.ZZW_NUMOCE AND IFE.ECO_PEDIDO = SD2.D2_PEDIDO AND IFE.ECO_PRODUTO = SD2.D2_COD AND IFE.ECO_LOTE = SD2.D2_LOTECTL  AND IFE.ECO_QUANT = SD2.D2_QUANT AND IFE.ECO_ITEM	= SC9.C9_SEQUEN	
KL001 +="		INNER JOIN SB1010 B1 WITH(NOLOCK) ON B1.B1_COD = SD2.D2_COD
KL001 +="		LEFT JOIN ZZ7010 ZZ7 WITH(NOLOCK) ON  ZZ7.ZZ7_FILIAL = '' AND ZZ7.ZZ7_COD = B1_YLINHA AND ZZ7.ZZ7_LINSEQ = B1.B1_YLINSEQ AND ZZ7.D_E_L_E_T_ = ''
KL001 +="		INNER JOIN ZZ9010 Z9 WITH(NOLOCK) ON B1.B1_COD = Z9.ZZ9_PRODUT AND SD2.D2_LOTECTL = Z9.ZZ9_LOTE
KL001 +=" 		WHERE Z43.Z43_TKT = ( SELECT TOP 1 Z43_TKT 
KL001 +="					   FROM	 Z43010 
KL001 +="					   WHERE Z43_PESAGE = '"+ZZV->ZZV_TICKET+"'" 
KL001 +="					   AND Z43_EMPR = '"+cEmpAnt+"01'"
KL001 +=" 					   AND Z43_FILIAL = '' 
KL001 +="					   AND D_E_L_E_T_= '')
KL001 +="		AND Z43.Z43_FILIAL = '' 
KL001 +="       AND Z43.D_E_L_E_T_ = '' 
KL001 +="       AND B1.B1_FILIAL   = ''
KL001 +="       AND B1.D_E_L_E_T_  = '' 
KL001 +="       AND Z9.ZZ9_FILIAL  = ''
KL001 +="       AND Z9.D_E_L_E_T_  = '' 
KL001 += "	GROUP BY Z43_TKT, ZZV_CARGA, ZZV_TICKET, ZZV.EMPR, ZZV_DATINC,ZZV_PLACA,ZZ7_EMP
KL001 += "	) CG
KL001 += "	LEFT JOIN Z11010 Z11 ON Z11_PESAGE = CG.ZZV_TICKET
KL001 += "	GROUP BY Z43_TKT,ZZV_DATINC,ZZV_PLACA

Else
	// CARGA INVÁLIDA - É NECESSÁRIO TICKET PARA EXIBIR AS CARGAS COMPOSTAS.	
EndIf

Return

//----------------------------------------------------------------------------------------------------------------------------------------
Static Function SqlCarga()

QM007:= " SELECT Z43_TKT, Z43_EMPR, 
QM007+= " 	   ZZW_NUMOCE,
QM007+= " 	   ZZV_TICKET,ZZV_CARGA, ZZV_PLACA,ZZV_DATINC,
QM007+= " 	   MAX(ZZV_MOTOR) AS ZZV_MOTOR,
QM007+= " 	   D2_CLIENTE,
QM007+= " 	   A1_NOME,
QM007+= " 	   D2_DOC, D2_SERIE, D2_PEDIDO,D2_ITEMPV,
QM007+= " 	   B1_COD, B1_DESC, D2_LOTECTL,D2_QUANT, D2_EMISSAO,
QM007+= " 	   SUM(PESO_PROD + PESO_EMB) AS PESO_FAT,
QM007+= " 	   SUM(ISNULL(ECO_QUANT,0))  AS ECO_QUANT,
QM007+= " 	   SUM(ISNULL(ECO_PESO,0))   AS PESO_ECO
QM007+= " FROM(
QM007+= " SELECT	Z43.Z43_TKT, Z43_EMPR, Z43_PESAGE, 
QM007+= " 		ZZV_TICKET, ZZV.ZZV_CARGA, ZZV.ZZV_DATINC, ZZV_DATFIM, ZZV.ZZV_MOTOR, ZZV.ZZV_PLACA, ZZV.ZZV_OBS, ZZV.ZZV_TRANSP, 
QM007+= " 		ZZW.ZZW_PEDIDO, ZZW.ZZW_NUMOCE , 
QM007+= " 		Z11.Z11_PESAGE, Z11.Z11_GUARDI, Z11.Z11_PESLIQ,
QM007+= " 		SD2.D2_CLIENTE, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_ITEM, SD2.D2_COD,SD2.D2_LOTECTL, SD2.D2_PEDIDO,SD2.D2_ITEMPV, SD2.D2_EMISSAO, SD2.D2_QUANT, SD2.D2_PESO, 
QM007+= " 		B1.B1_COD, B1.B1_DESC, B1.B1_CONV,B1_TIPCONV, 
QM007+= " 		Z9.ZZ9_PESO, Z9.ZZ9_PESEMB,
QM007+= " 		(SD2.D2_QUANT*Z9.ZZ9_PESO) AS PESO_PROD , 
QM007+= " 		CASE WHEN B1_TIPCONV = 'D' THEN (SD2.D2_QUANT/B1.B1_CONV)*Z9.ZZ9_PESEMB 
QM007+= " 								   ELSE (SD2.D2_QUANT*B1.B1_CONV)*Z9.ZZ9_PESEMB 
QM007+= " 		END PESO_EMB,
QM007+= " 		ECO.ECO_QUANT,
QM007+= " 		ECO.ECO_PESO,
QM007+= " 		ISNULL(A1_NOME, A2_NOME) AS A1_NOME 
QM007+= "		FROM Z43010 Z43 WITH(NOLOCK)
QM007+= "		INNER JOIN VW_ZZV_EMP ZZV WITH(NOLOCK) ON Z43.Z43_EMPR	= ZZV.EMPRESA AND ZZV.ZZV_TICKET = Z43.Z43_PESAGE 
QM007+= "		INNER JOIN Z11010 Z11 WITH(NOLOCK) ON Z11.Z11_PESAGE = ZZV.ZZV_TICKET
QM007+= "		INNER JOIN VW_ZZW_EMP ZZW WITH(NOLOCK) ON ZZW.EMPR = ZZV.EMPR AND ZZW.ZZW_CARGA = ZZV.ZZV_CARGA
QM007+= "		INNER JOIN VW_SC9_EMP SC9 WITH(NOLOCK) ON SC9.C9_EMP = ZZW.EMPR AND SC9.C9_PEDIDO = ZZW.ZZW_PEDIDO AND SC9.C9_ITEM = ZZW.ZZW_ITEM AND SC9.C9_SEQUEN = ZZW.ZZW_SEQUEN  AND  SC9.C9_AGREG = ZZW_CARGA 
QM007+= "		INNER JOIN VW_SD2_EMP SD2 WITH(NOLOCK) ON SC9.C9_EMP = SD2.D2_EMP AND SC9.C9_PEDIDO	= SD2.D2_PEDIDO	AND SC9.C9_PRODUTO	= SD2.D2_COD	AND SC9.C9_LOTECTL  = SD2.D2_LOTECTL	AND SC9.C9_QTDLIB	= SD2.D2_QUANT	AND SC9.C9_CLIENTE  = SD2.D2_CLIENTE	AND SC9.C9_ITEM		= SD2.D2_ITEMPV	AND SC9.C9_NFISCAL	= SD2.D2_DOC	AND SC9.C9_SERIENF	= SD2.D2_SERIE	AND SC9.C9_NUMSEQ	= SD2.D2_NUMSEQ	
QM007+= " 		INNER JOIN VW_SF2_EMP SF2 WITH(NOLOCK) ON SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE 	= SD2.D2_SERIE AND SF2.F2_EMP 		= SD2.D2_EMP 	AND SF2.F2_EMISSAO 	= SD2.D2_EMISSAO
//QM007+= "		LEFT JOIN  VW_ITEM_FAT_ECOSIS IFE ON IFE.ECO_EMP	= SD2.D2_EMP AND  IFE.ECO_CARGA = ZZW.ZZW_NUMOCE AND IFE.ECO_PEDIDO = SD2.D2_PEDIDO AND IFE.ECO_PRODUTO = SD2.D2_COD AND IFE.ECO_LOTE = SD2.D2_LOTECTL  AND IFE.ECO_QUANT = SD2.D2_QUANT AND IFE.ECO_ITEM	= SC9.C9_SEQUEN	
QM007 +="		LEFT JOIN 
QM007 +="				  (
QM007 +="					SELECT DISTINCT PRO_CARGA, IFE.ECO_CARGA,ECO_PEDIDO, IFE.ECO_PRODUTO, IFE.ECO_LOTE , IFE.ECO_QUANT, IFE.ECO_PESO
QM007 +="					FROM VW_FAT_ECOSIS FE
QM007 +="					INNER JOIN VW_ITEM_FAT_ECOSIS IFE 
QM007 +="					ON IFE.ECO_EMP			= FE.ECO_EMP
QM007 +="					AND IFE.ECO_CARGA	= FE.ECO_CARGA             
QM007 +="				  )	ECO 
QM007 +="		ON ECO.PRO_CARGA = ZZV.ZZV_CARGA AND ECO.ECO_CARGA = ZZW.ZZW_NUMOCE AND ECO.ECO_PEDIDO	= SD2.D2_PEDIDO AND ECO.ECO_PRODUTO	= SD2.D2_COD  AND ECO.ECO_LOTE		= SD2.D2_LOTECTL  AND ECO.ECO_QUANT		= SD2.D2_QUANT
QM007+= " 		INNER JOIN SB1010 B1 WITH(NOLOCK)  ON B1.B1_COD = SD2.D2_COD
QM007+= " 		INNER JOIN ZZ9010 Z9 WITH(NOLOCK)  ON B1.B1_COD = Z9.ZZ9_PRODUT AND SD2.D2_LOTECTL = Z9.ZZ9_LOTE
QM007+= " 		LEFT  JOIN SA1010 SA1 WITH(NOLOCK) ON SA1.A1_COD = D2_CLIENTE AND F2_TIPO NOT IN ('B','D') AND SA1.D_E_L_E_T_ = ''
QM007+= " 		LEFT  JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_COD = D2_CLIENTE AND F2_TIPO IN ('B','D')     AND SA2.D_E_L_E_T_ = ''  		
QM007+= " 		WHERE Z43.Z43_TKT 	= '"+rbTickt+"'
QM007+= "		AND Z43.Z43_FILIAL 	= '' 
QM007+= " 		AND Z43.D_E_L_E_T_ 	= ''
QM007+= "		AND B1.B1_FILIAL 	= ''
QM007+= " 		AND B1.D_E_L_E_T_  	= ''
QM007+= "		AND Z9.ZZ9_FILIAL 	= '' 
QM007+= " 		AND Z9.D_E_L_E_T_  	= ''
QM007+= " ) TMP
QM007+= " GROUP BY Z43_TKT, Z43_EMPR,
QM007+= " 	   ZZW_NUMOCE,
QM007+= " 	   D2_CLIENTE,
QM007+= " 	   A1_NOME,
QM007+= " 	   D2_DOC, D2_SERIE, D2_PEDIDO,D2_ITEMPV,
QM007+= " 	   B1_COD, B1_DESC, D2_LOTECTL,D2_QUANT, D2_EMISSAO,
QM007+= " 	   ZZV_TICKET,ZZV_CARGA, ZZV_PLACA,ZZV_DATINC

Return


Static Function BIA249CRel()

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	cTitulo := ""
	cGenero := ""
	cTitulo := "Resumo do Carregamento"
	cGenero := "Composição de Cargas das Empresas"
	
	oReport:= TReport():New(cTitulo,"Composição de Cargas das Empresas", , {|oReport| PrintReport(oReport)},"Composição de Cargas das Empresas")	
	
	oReport:SetLandScape(.T.)
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport,OemToAnsi("Resumo do Carregamento"),{"KL01"})    
	oSection1:SetTotalInLine(.F.)
    
	oSection2 := TRSection():New(oReport,OemToAnsi("Cargas"),{"QM07"})    
	oSection2:SetTotalInLine(.T.)

    
	TRCell():New(oSection1,"TICKET"			,/**/, "Composição"			,/**/,7,/**/	)
	TRCell():New(oSection1,"EMISSAO"		,/**/, "Data Entrada"		,/**/,8,/**/	)
	TRCell():New(oSection1,"PLACA"			,/**/, "Placa"				,/**/,7,/**/	)
	TRCell():New(oSection1,"MOTOR"			,/**/, "Motorista"			,/**/,20,/**/	)
	TRCell():New(oSection1,"PESOFAT"		,/**/, "Peso Faturamento"	,/**/,12,/**/	)
	TRCell():New(oSection1,"PESOBAL"		,/**/, "Peso Balança"		,/**/,12,/**/	)
	TRCell():New(oSection1,"PESOECO"		,/**/, "Peso Ecosis"		,/**/,12,/**/	)
	TRCell():New(oSection1,"DIVERG"			,/**/, "Divergência"		,/**/,8,/**/	)
	
	
	//TRCell():New(oSection2,"TICKET"			,/**/, "Composição"			,/**/,10,/**/	)
	TRCell():New(oSection2,"EMPRESA"		,/**/, "Empresa"			,/**/,7,/**/	)
	TRCell():New(oSection2,"CARGAECO"		,/**/, "Carga Eco"			,/**/,7,/**/	)
	TRCell():New(oSection2,"PESAGEM"		,/**/, "Pesagem"			,/**/,7,/**/	)		
	TRCell():New(oSection2,"CARGA"			,/**/, "Carga"				,/**/,7,/**/	)
	//TRCell():New(oSection2,"MOTOR"			,/**/, "Motorista"			,/**/,20,/**/	)
	//TRCell():New(oSection2,"PLACA"			,/**/, "Placa"				,/**/,7,/**/	)
	//TRCell():New(oSection2,"DTINICIO"		,/**/, "Data Entrada"		,/**/,8,/**/	)
	TRCell():New(oSection2,"CODCLI"			,/**/, "Cliente"			,/**/,8,/**/	)
	TRCell():New(oSection2,"NOMECLI"		,/**/, "Nome"				,/**/,30,/**/	)
	TRCell():New(oSection2,"NF"				,/**/, "Nota Fiscal"		,/**/,15,/**/	)
	TRCell():New(oSection2,"SERIE"			,/**/, "Série"				,/**/,5 ,/**/	)			
	TRCell():New(oSection2,"PEDIDO"			,/**/, "Pedido"				,/**/,8 ,/**/	)
	TRCell():New(oSection2,"ITEM"			,/**/, "Item"				,/**/,5 ,/**/	)
	TRCell():New(oSection2,"CODPROD"		,/**/, "Produto"			,/**/,8 ,/**/	)
	TRCell():New(oSection2,"DESCPROD"		,/**/, "Descrição"			,/**/,30 ,/**/	)
	TRCell():New(oSection2,"LOTE"			,/**/, "Lote"				,/**/,5 ,/**/	)
	TRCell():New(oSection2,"QUANT"			,/**/, "Quantidade"			,/**/,8 ,/**/	)		
	TRCell():New(oSection2,"PESOFAT"		,/**/, "Peso Faturamento"	,/**/,12,/**/	)
	TRCell():New(oSection2,"ECOQUANT"		,/**/, "Quant. Ecosis"		,/**/,8,/**/	)
	TRCell():New(oSection2,"PESOECO"		,/**/, "Peso Ecosis"		,/**/,12,/**/	)
	
	//TRFUNCTION():New(oCell				,cName ,cFunction ,oBreak, cTitle		, cPicture, uFormula   ,lEndSection,lEndReport    ,lEndPage,oParent,bCondition,lDisable,bCanPrint) 	
	//oFuncao := TRFunction():New(oSection2:Cell("DIAS") ,"MEDIA","AVERAGE" ,		 ,"Tempo Médio" ,"@E 999" ,/*uFormula*/,/*secao*/.F.,/*report*/.T.,/*pagina*/.F.)
	//oFuncao:SetTotalText("Tempo Médio Gasto")
	//oFuncao:ShowFooter()
	
//	 TRFunction():New(oSection2:Cell("PESOECO"/*X3_CAMPO*/) ,"PESOECO"/* cID */, "SUM", /*oBreak*/, /*cTitle*/, /*cPicture*/, /*uFormula*/, .T. /*lEndSection*/, .F./*lEndReport*/, .F. /*lEndPage*/)
//	 TRFunction():New(oSection2:Cell("PESOFAT"/*X3_CAMPO*/) ,"PESOFAT"/* cID */, "SUM", /*oBreak*/, /*cTitle*/, /*cPicture*/, /*uFormula*/, .T. /*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)

Return oReport

//---------------------------------------------------------------------------
Static Function PrintReport(oReport)
	
	Local lImprime := .F.
	Local nTotPesoFat, nTotEcoPeso := 0
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	
	// Finaliza carga composta ao imprimir relatorio
	fFinCarga()
	
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	DbSelectArea("KL01")
	KL01->(dbGoTop())
	
	oSection1:Cell("TICKET"			):SetValue(KL01->Z43_TKT)
	oSection1:Cell("TICKET"			):SetAlign("CENTER")
	
	oSection1:Cell("EMISSAO"		):SetValue(dtoc(rbDtInc))
	oSection1:Cell("EMISSAO"		):SetAlign("CENTER")
	
	oSection1:Cell("PLACA"			):SetValue(KL01->ZZV_PLACA)
	oSection1:Cell("PLACA"			):SetAlign("CENTER")
	
	oSection1:Cell("MOTOR"			):SetValue(KL01->ZZV_MOTOR)
	oSection1:Cell("MOTOR"			):SetAlign("LEFT")
	
	oSection1:Cell("PESOFAT"		):SetValue(Transform(KL01->PESO_FAT, "@E 999,999,999.99"))
	oSection1:Cell("PESOFAT"		):SetAlign("RIGH")
	
	oSection1:Cell("PESOBAL"		):SetValue(Transform(KL01->PESO_BAL, "@E 999,999,999.99"))
	oSection1:Cell("PESOBAL"		):SetAlign("RIGH")
	
	oSection1:Cell("PESOECO"		):SetValue(Transform(KL01->PESO_ECO, "@E 999,999,999.99"))
	oSection1:Cell("PESOECO"		):SetAlign("RIGH")
	
	oSection1:Cell("DIVERG"			):SetValue(Transform(xDiverg, "@E 999,999,999.99"))
	oSection1:Cell("DIVERG"			):SetAlign("RIGH")
    
    nTotPesoFat := KL01->PESO_FAT
    nTotEcoPeso := KL01->PESO_ECO
     
  	oSection1:PrintLine()
  	oSection1:Finish() 

	DbSelectArea("QM07")
	QM07->(dbGoTop())
	
	oReport:SetMeter(QM07->(RecCount()))
	 
	oSection2:Init()
	oSection2:SetHeaderSection(.T.)
	QM07->(dbGoTop())    
	
  	While QM07->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf  

		oReport:IncMeter()
		
		oSection2:Cell("EMPRESA"		):SetValue(QM07->Z43_EMPR	)
		oSection2:Cell("CARGAECO"		):SetValue(QM07->ZZW_NUMOCE)
		oSection2:Cell("PESAGEM"		):SetValue(QM07->ZZV_TICKET)
		oSection2:Cell("CARGA"			):SetValue(QM07->ZZV_CARGA)
		//oSection2:Cell("MOTOR"			):SetValue(QM07->ZZV_MOTOR)
		//oSection2:Cell("PLACA"			):SetValue(QM07->ZZV_PLACA)
		//oSection2:Cell("DTINICIO"		):SetValue(QM07->ZZV_DATINC)
		oSection2:Cell("CODCLI"			):SetValue(QM07->D2_CLIENTE)
		oSection2:Cell("NOMECLI"		):SetValue(QM07->A1_NOME)
		oSection2:Cell("NF"				):SetValue(QM07->D2_DOC)
		oSection2:Cell("SERIE"			):SetValue(QM07->D2_SERIE)
		oSection2:Cell("PEDIDO"			):SetValue(QM07->D2_PEDIDO)
		oSection2:Cell("ITEM"			):SetValue(QM07->D2_ITEMPV)
		oSection2:Cell("CODPROD"		):SetValue(QM07->B1_COD)
		oSection2:Cell("DESCPROD"		):SetValue(QM07->B1_DESC)
		oSection2:Cell("LOTE"			):SetValue(QM07->D2_LOTECTL)
		oSection2:Cell("QUANT"			):SetValue(Transform((D2_QUANT)	, "@E 999,999,999.99"))
		oSection2:Cell("PESOFAT"		):SetValue(Transform((PESO_FAT)	, "@E 999,999,999.99")) 
		oSection2:Cell("ECOQUANT"		):SetValue(Transform((ECO_QUANT), "@E 999,999,999.99"))  
		oSection2:Cell("PESOECO"		):SetValue(Transform((PESO_ECO)	, "@E 999,999,999.99")) 
		oSection2:Cell("EMPRESA"		):SetAlign("CENTER")
		oSection2:Cell("CARGAECO"		):SetAlign("CENTER")
		oSection2:Cell("PESAGEM"		):SetAlign("CENTER")
		oSection2:Cell("CARGA"			):SetAlign("CENTER")
		oSection2:Cell("CODCLI"			):SetAlign("CENTER")
		oSection2:Cell("NOMECLI"		):SetAlign("CENTER")
		oSection2:Cell("NF"				):SetAlign("CENTER")
		oSection2:Cell("SERIE"			):SetAlign("CENTER")
		oSection2:Cell("PEDIDO"			):SetAlign("CENTER")
		oSection2:Cell("ITEM"			):SetAlign("CENTER")
		oSection2:Cell("CODPROD"		):SetAlign("CENTER")
		oSection2:Cell("DESCPROD"		):SetAlign("LEFT")
		oSection2:Cell("LOTE"			):SetAlign("CENTER")
		oSection2:Cell("QUANT"			):SetAlign("RIGHT")
		oSection2:Cell("PESOFAT"		):SetAlign("RIGH")
		oSection2:Cell("ECOQUANT"		):SetAlign("RIGH")
		oSection2:Cell("PESOECO"		):SetAlign("RIGH")
	
		oSection2:PrintLine()
		QM07->(DBSKIP())
	End
	
	// o TReport não gera os totais corretamente (sem precisão)
	// Limpa os valores nas células para imprimir o total.
	/*LimpaCels(oSection2)
	
	oSection2:Cell("DESCPROD"		):SetValue("		TOTAL		")
	oSection2:Cell("PESOFAT"		):SetValue(Transform((nTotPesoFat)	, "@E 999,999,999.99"))
	oSection2:Cell("PESOECO"		):SetValue(Transform((nTotEcoPeso)	, "@E 999,999,999.99"))
	
	
	oSection2:PrintLine()  */
    //QM07->(dbCloseArea())
    //QM01->(dbCloseArea())    
	oSection2:Finish()
	QM07->(dbGoTop())
	
Return                                                                       

//----------------------------------------------------------------------------------------------------------------------------------------
//	Funcao 	: BI249CR
//  Desc	: Impressão do relatório Por Periodo ou Carga
//----------------------------------------------------------------------------------------------------------------------------------------
USER Function BIA249CR()
	
	Local oReport
	Local cSqlRel := ""                                            
	
	fPerg := "BIA249CR"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	
	fValidPerg()
	
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	
	//Cargas de Tickets comuns
	cSqlRel := SqlCargasT(MV_PAR05)
	TCQUERY cSqlRel ALIAS "R249CR" NEW
	dbSelectArea("R249CR")
	dbGoTop()

	oReport:= ReportDef2()
	oReport:PrintDialog()
	R249CR->(dbCloseArea())

Return()


Static Function ReportDef2()

	cTitulo := ""
	cGenero := ""
	
	If MV_PAR05 == TKTSCOMUNSEMP
		cTitulo := "Cargas"
	ElseIf MV_PAR05 == TKTSCOMPEMP
		cTitulo := "Ticket Composto"
	ElseIf MV_PAR05 == CARGASCOMPEMP
		cTitulo := "Cargas Campostas
	ElseIf MV_PAR05 == TKTUNICO
		cTitulo := "Ticket Unico"
	EndIf
		
	oReport:= TReport():New(cTitulo,cTitulo + " - Faturamento de "+ dToc(MV_PAR01)+ " até "+ dToc(MV_PAR02), , {|oReport| PrntRep2(oReport)},cTitulo)
	
	oReport:SetLandScape(.T.)
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport,OemToAnsi(cTitulo),{"R249CR"})    
	oSection1:SetTotalInLine(.F.)

	If MV_PAR05 == CARGASCOMPEMP

		TRCell():New(oSection1,"TICKET"			,/**/, "Composição"			,/**/,7,/**/	)
		TRCell():New(oSection1,"EMPRESA"		,/**/, "Empresa"			,/**/,7,/**/	)
	
	ElseIf MV_PAR05 == TKTUNICO

		TRCell():New(oSection1,"EMPRESA"		,/**/, "Empresa"			,/**/,7,/**/	)		
		
	EndIf
	
	TRCell():New(oSection1,"CARGA"			,/**/, "Carga"				,/**/,7,/**/	)
	TRCell():New(oSection1,"GUARDIAN"		,/**/, "Guardian"			,/**/,7,/**/	)
	TRCell():New(oSection1,"PESAGEM"		,/**/, "Pesagem"			,/**/,10,/**/	)
	TRCell():New(oSection1,"DATINI"			,/**/, "Incio Pes."			,/**/,10,/**/	)
	TRCell():New(oSection1,"DATFIM"			,/**/, "Fim Pes"			,/**/,10,/**/	)
	TRCell():New(oSection1,"PLACA"			,/**/, "Placa"				,/**/,10,/**/	)		
	TRCell():New(oSection1,"MOTOR"			,/**/, "Motorista"			,/**/,30,/**/	)
	TRCell():New(oSection1,"PESOFAT"		,/**/, "Peso Fat"			,/**/,14,/**/	)
	TRCell():New(oSection1,"PESOECO"		,/**/, "Peso Ecosis"		,/**/,14,/**/	)    
	TRCell():New(oSection1,"PESOBAL"		,/**/, "Peso Balança"		,/**/,14,/**/	)    
	TRCell():New(oSection1,"DIFECO"			,/**/, "Dif FATtxECO"		,/**/,14,/**/	)
	TRCell():New(oSection1,"DIFBAL"			,/**/, "Dif FATxBAL"		,/**/,14,/**/	)
	TRCell():New(oSection1,"VARIACAO"		,/**/, "Var (%)"			,/**/,14,/**/	)
	TRCell():New(oSection1,"DIFECOBAL"		,/**/, "Dif ECOxBAL"		,/**/,14,/**/	)
	TRCell():New(oSection1,"PBP"			,/**/, "PBP",/**/,14,/**/	)
	TRCell():New(oSection1,"PBT"			,/**/, "PBT Carregado"		,/**/,14,/**/	)		
	TRCell():New(oSection1,"OBS"			,/**/, "Obs. Ticket"		,/**/,60,/**/	)
	
Return oReport


Static Function PrntRep2(oReport)
Local lImprime := .F.
Local nTotPesoFat, nTotEcoPeso, nTotPesBal, nVariac := 0
Local oSection1 := oReport:Section(1)
Local cAuxTicket := ""
Local cAuxPlaca  := ""
Local cAuxTktUni := ""	
Local nPesoBal := 0
Local aTktUni := {}
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	                                                             
	DbSelectArea("R249CR")
	R249CR->(dbGoTop())
	
	nTotPesoEco := 0
	nTotPesoFat	:= 0
	nTotPesoBal := 0
	nVariac		:= 0
	
	cAuxTicket := R249CR->Z43_TKT
	cAuxPlaca := R249CR->ZZV_PLACA
	cAuxTktUni := R249CR->ZZV_TICKET	
	
	oReport:SetMeter(R249CR->(RecCount()))
	
  	While R249CR->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf  

		oReport:IncMeter()
		
		If MV_PAR05 == CARGASCOMPEMP
			
			oSection1:Cell("TICKET"			):SetValue(R249CR->Z43_TKT	)
			oSection1:Cell("EMPRESA"		):SetValue(R249CR->EMPR	)

		ElseIf MV_PAR05 == TKTUNICO
			
			oSection1:Cell("EMPRESA"		):SetValue(R249CR->EMPR	)			
			
		EndIf
		
		oSection1:Cell("CARGA"			):SetValue(R249CR->ZZV_CARGA	)
		oSection1:Cell("GUARDIAN"		):SetValue(R249CR->Z11_GUARDI	)
		oSection1:Cell("PESAGEM"		):SetValue(R249CR->ZZV_TICKET	)
		oSection1:Cell("DATINI"			):SetValue(dtoc(stod(R249CR->Z11_DATAIN)))
		oSection1:Cell("DATFIM"			):SetValue(dtoc(stod(R249CR->Z11_DATASA)))
		oSection1:Cell("PLACA"			):SetValue(R249CR->ZZV_PLACA	)
		oSection1:Cell("MOTOR"			):SetValue(R249CR->ZZV_MOTOR	)

		nPesoBal := 0
		
		If MV_PAR05 == TKTUNICO											

			If (nPos := aScan(aTktUni, {|x| x[1] == R249CR->ZZV_TICKET})) == 0
			
				aAdd(aTktUni, {R249CR->ZZV_TICKET, R249CR->PESO_BAL})

				nPesoBal := R249CR->PESO_BAL
				
			Else
			
				If aTktUni[nPos, 2] == R249CR->PESO_BAL
					
					nPesoBal := 0
					
				Else
				
					nPesoBal := R249CR->PESO_BAL
				
				EndIf	
				
			EndIf
			
		ElseIf !(MV_PAR05 == TKTSCOMPEMP .And. (R249CR->PESO_FAT - R249CR->PESO_ECO >= 1)) 
		
			nPesoBal := R249CR->PESO_BAL
				
		EndIf

		oSection1:Cell("PESOFAT"		):SetValue(Transform((R249CR->PESO_FAT)	, "@E 999,999,999.99")) 
		oSection1:Cell("PESOECO"		):SetValue(Transform((R249CR->PESO_ECO)	, "@E 999,999,999.99")) 
		oSection1:Cell("PESOBAL"		):SetValue(Transform((nPesoBal)	, "@E 999,999,999.99"))
		
		nDifFatEco 	:= R249CR->PESO_FAT - R249CR->PESO_ECO
		nDifFatBal 	:= R249CR->PESO_FAT - nPesoBal
		nDifEcotBal	:= R249CR->PESO_ECO - nPesoBal
		nTotPesoEco += R249CR->PESO_ECO
		nTotPesoFat += R249CR->PESO_FAT 
		nTotPesoBal += nPesoBal
		
		nVariac 	:= (nDifFatBal / R249CR->PESO_FAT) * 100
		
		oSection1:Cell("DIFECO"		):SetValue(Transform((nDifFatEco)	, "@E 999,999.99"))
		oSection1:Cell("DIFBAL"		):SetValue(Transform((nDifFatBal)	, "@E 999,999.99"))
		oSection1:Cell("VARIACAO"	):SetValue(Transform((nVariac)		, "@E 999,999.99"))
		oSection1:Cell("DIFECOBAL"	):SetValue(Transform((nDifEcotBal)	, "@E 999,999.99"))
		oSection1:Cell("PBP"):SetValue(Transform((R249CR->Z11_PESMAX)	, "@E 999,999,999.99"))
		oSection1:Cell("PBT"		):SetValue(Transform((R249CR->Z11_PESOSA)	, "@E 999,999,999.99"))
		oSection1:Cell("OBS"		):SetValue(R249CR->Z11_OBSER)
		
		oSection1:Cell("PESOFAT"		):SetAlign("RIGH")
		oSection1:Cell("PESOBAL"		):SetAlign("RIGH")
		oSection1:Cell("PESOECO"		):SetAlign("RIGH")
		oSection1:Cell("DIFBAL"			):SetAlign("RIGH")
		oSection1:Cell("DIFECO"			):SetAlign("RIGH")
		oSection1:Cell("VARIACAO"		):SetAlign("RIGH")
		oSection1:Cell("DIFECOBAL"		):SetAlign("RIGH")
		oSection1:Cell("PBP"):SetAlign("RIGH")
		oSection1:Cell("PBT"			):SetAlign("RIGH") 
	  oSection1:Cell("OBS"			):SetAlign("LEFT")
	  oSection1:Cell("MOTOR"			):SetAlign("LEFT") 		
		
		oSection1:PrintLine()
		
		R249CR->(DBSKIP())
		
		If (MV_PAR05 == CARGASCOMPEMP .And. cAuxTicket != R249CR->Z43_TKT) .Or.;
		   (MV_PAR05 == TKTSCOMPEMP   .And. cAuxPlaca  != R249CR->ZZV_PLACA )	.Or.;
		   (MV_PAR05 == TKTUNICO .And. cAuxTktUni != R249CR->ZZV_TICKET)

			// Limpa as Células
			LimpaCels(oSection1)
			
			//Calcula a Variacao
			nVariac	:= ((nTotPesoFat - nTotPesoBal) / nTotPesoFat ) * 100
			oSection1:Cell("VARIACAO"	):SetValue(Transform((nVariac)		, "@E 999,999,999.99"))
			
			// Gera os totais
			oSection1:Cell("MOTOR"			):SetValue("		TOTAL		")
			oSection1:Cell("PESOFAT"		):SetValue(Transform((nTotPesoFat)	, "@E 999,999,999.99"))
			oSection1:Cell("PESOECO"		):SetValue(Transform((nTotPesoEco)	, "@E 999,999,999.99"))
			oSection1:Cell("PESOBAL"		):SetValue(Transform((nTotPesoBal)	, "@E 999,999,999.99"))
			
			oSection1:PrintLine()
			
			oSection1:Finish()
			oSection1:Init()
			
			cAuxTicket := R249CR->Z43_TKT
			cAuxPlaca := R249CR->ZZV_PLACA
			cAuxTktUni := R249CR->ZZV_TICKET

			nTotPesoFat := 0
			nTotPesoBal := 0
			nTotPesoEco := 0
			
		EndIf
		
	End
	
	If MV_PAR05 == TKTSCOMUNSEMP .Or. MV_PAR05 == TKTUNICO
		
		// o TReport não gera os totais corretamente (sem precisão)
		// Limpa os valores nas células para imprimir o total.
		LimpaCels(oSection1)
		
		oSection1:Cell("MOTOR"			):SetValue("		TOTAL		")
		oSection1:Cell("PESOFAT"		):SetValue(Transform((nTotPesoFat)	, "@E 999,999,999.99"))
		oSection1:Cell("PESOECO"		):SetValue(Transform((nTotPesoEco)	, "@E 999,999,999.99"))
		oSection1:Cell("PESOBAL"		):SetValue(Transform((nTotPesoBal)	, "@E 999,999,999.99"))
		oSection1:PrintLine()  
		
	EndIf

	oSection1:Finish()
	
Return                                                                       



Static Function SqlCargasT(nTpRel)
Local cSql := ""

	If nTpRel == TKTUNICO
		
		cSQL := fTktUnico()
		
	Else
	
		cSql+= " SELECT * FROM ( 
		cSql+= " SELECT 
		cSql+= " ISNULL(Z43.Z43_TKT,'') AS Z43_TKT ,
		cSql+= " ZZV.EMPR,
		cSql+= " ZZV_CARGA,
		cSql+= " Z11_GUARDI,
		cSql+= " ZZV_TICKET,
		cSql+= " Z11_DATAIN,
		cSql+= " Z11_DATASA,
		cSql+= " ZZV_PLACA,
		cSql+= " ZZV_MOTOR,
		cSql+= " Z11_PESOSA,
		cSql+= " Z11_PESMAX,
		cSql+= " Z11_OBSER,
		
		If nTpRel == CARGASCOMPEMP
			cSql+= " CASE WHEN EHOUTSC = 1 THEN 0 ELSE 
			cSql+= "          (SELECT SUM(ISNULL(Z11_PESLIQ, 0)) FROM Z11010 WITH(NOLOCK)  WHERE ZZV.ZZV_TICKET = Z11_PESAGE ) END AS PESO_BAL, 
		Else
			cSql+= " (SELECT SUM(ISNULL(Z11_PESLIQ, 0)) FROM Z11010 WITH(NOLOCK)  WHERE ZZV.ZZV_TICKET = Z11_PESAGE ) AS PESO_BAL,
		EndIf
		
		cSql+= " (SELECT  SUM(ISNULL(SF2.F2_PBRUTO,0)) 
		cSql+= "  FROM VW_SF2_EMP SF2 WITH(NOLOCK)
		cSql+= "  WHERE SF2.F2_EMP = ZZV.EMPR 
		cSql+= "  AND SF2.F2_CARGA = ZZV.ZZV_CARGA
		cSql+= " ) AS PESO_FAT,
		cSql+= " (SELECT SUM(ISNULL(ECO_PESO,0)) 
		cSql+= " FROM VW_FAT_ECOSIS FE WITH(NOLOCK)
		cSql+= "            INNER JOIN VW_ITEM_FAT_ECOSIS  IFE WITH(NOLOCK)
		cSql+= "            ON IFE.ECO_EMP = FE.ECO_EMP AND IFE.ECO_CARGA = FE.ECO_CARGA
		cSql+= "  WHERE PRO_CARGA = ZZV.ZZV_CARGA AND IFE.ECO_EMP = ZZV.EMPR ) PESO_ECO
		cSql+= " FROM VW_ZZV_EMP ZZV WITH(NOLOCK)
		cSql+= " LEFT JOIN Z11010 Z11 WITH(NOLOCK) ON ZZV.ZZV_TICKET = Z11.Z11_PESAGE
		cSql+= " LEFT JOIN (SELECT  F2_EMP, F2_CARGA, F2_PBRUTO, (CASE WHEN F2_YRESULT = 'S' AND F2_YRESUL2 = 'N' THEN 1 ELSE 0 END ) EHOUTSC FROM VW_SF2_EMP) SF2 ON SF2.F2_EMP = ZZV.EMPR AND SF2.F2_CARGA = ZZV.ZZV_CARGA 
		cSql+= " LEFT JOIN Z43010 Z43 WITH(NOLOCK)ON Z43.Z43_EMPR = ZZV.EMPRESA AND Z43.Z43_PESAGE = ZZV.ZZV_TICKET AND Z43.Z43_FILIAL = '' AND Z43.D_E_L_E_T_ = ''
		cSql+= " WHERE ZZV.ZZV_CARGA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		cSql+= " AND EXISTS (SELECT * FROM VW_SF2_EMP F2 WITH(NOLOCK) WHERE F2.F2_EMP = ZZV.EMPR AND  F2_CARGA = ZZV.ZZV_CARGA AND F2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' ) 
		 
		If nTpRel == TKTSCOMUNSEMP .OR. nTpRel == TKTSCOMPEMP
			
			cSql+= " AND Z43.Z43_TKT IS NULL
			cSql+= " AND ZZV.EMPR = '" +cEmpAnt+ "' " 
			
			If nTpRel == TKTSCOMUNSEMP
			
				cSql+= " AND NOT EXISTS 
				
			Else
				
				cSql+= " AND EXISTS
				
			EndIf
						
			cSql+= " (
			cSql+= " 	SELECT * 
			cSql+= " 	FROM VW_ZZV_EMP WITH(NOLOCK)
			cSql+= " 	WHERE EMPR		= ZZV.EMPR
			cSql+= " 	AND ZZV_TICKET	= ZZV.ZZV_TICKET
			cSql+= " 	AND ZZV_CARGA   <> ZZV.ZZV_CARGA
			cSql+= "	AND ZZV_TICKET  <> ''
			cSql+= " )
		
		Else
			
			cSql+= " AND Z43.Z43_TKT IS NOT NULL
			
		EndIf
		
		cSql+= " GROUP BY Z43.Z43_TKT ,ZZV.EMPR, ZZV_CARGA,Z11_GUARDI, ZZV_TICKET, Z11_DATAIN, Z11_DATASA, "
		
		If nTpRel == CARGASCOMPEMP

			cSql += " EHOUTSC, "
		
		EndIf		
			
		cSql+= " ZZV_PLACA,
		cSql+= " ZZV_MOTOR,
		cSql+= " Z11_PESOSA,
		cSql+= " Z11_PESMAX, 
		cSql+= " Z11_OBSER ) CG
		
		If nTpRel == TKTSCOMUNSEMP
				
			cSql+= " ORDER BY ZZV_CARGA,ZZV_PLACA, Z11_DATAIN, Z11_DATASA
			
		Else
			
			cSql+= " ORDER BY Z43_TKT,ZZV_PLACA, Z11_DATAIN, Z11_DATASA
			
		EndIf
	
	EndIf
	
Return(cSql)


Static Function LimpaCels(pSecao)

	If MV_PAR05 == CARGASCOMPEMP
		
		pSecao:Cell("TICKET"		):SetValue('')
		pSecao:Cell("EMPRESA"		):SetValue('')
	
	ElseIf MV_PAR05 == TKTUNICO
	
		pSecao:Cell("EMPRESA"		):SetValue('')	
		
	EndIf

	pSecao:Cell("CARGA"			):SetValue('')
	pSecao:Cell("GUARDIAN"		):SetValue('')		
	pSecao:Cell("PESAGEM"		):SetValue('')
	pSecao:Cell("DATINI"		):SetValue('')
	pSecao:Cell("DATFIM"		):SetValue('')
	pSecao:Cell("PLACA"			):SetValue('')
	pSecao:Cell("MOTOR"			):SetValue('')
	pSecao:Cell("PESOFAT"		):SetValue('') 
	pSecao:Cell("PESOECO"		):SetValue('')
	pSecao:Cell("PESOBAL"		):SetValue('')		
	pSecao:Cell("DIFECO"		):SetValue('')
	pSecao:Cell("DIFBAL"		):SetValue('')
	pSecao:Cell("VARIACAO"		):SetValue('')
	pSecao:Cell("DIFECOBAL"		):SetValue('')
	pSecao:Cell("PBP"):SetValue('')
	pSecao:Cell("PBT"			):SetValue('')
	pSecao:Cell("OBS"			):SetValue('')
	
Return


// Rotina para finalizar carga composta
Static Function fFinCarga()
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT EMPRESA, CARGA, TICKET "
	cSQL += " FROM FNC_CARGA_EMP('"+AllTrim(CEMPANT)+AllTrim(CFILANT)+"',"+ ValToSQL(ZZV->ZZV_CARGA) + ","+ ValToSQL(ZZV->ZZV_TICKET) + ")"
	
	TcQuery cSQL New Alias (cQry)
		
	While !(cQry)->(Eof())
		
		If (cQry)->EMPRESA <> cEmpAnt+cFilAnt
			
			cSQL := " UPDATE Z11" + SubStr((cQry)->EMPRESA, 1, 2) + "0"
			cSQL += " SET Z11_PESOIN = 0.01, Z11_PESOSA = 0.01, Z11_OBSER = 'BAIXA AUTOMATICA - CARGA COMPOSTA' "
			cSQL += " WHERE Z11_FILIAL = '' "
			cSQL += " AND Z11_PESAGE = " + ValToSQL((cQry)->TICKET)
			cSQL += " AND D_E_L_E_T_ = '' "
			cSQL += " AND Z11_PESOIN = 0 "
			cSQL += " AND Z11_PESOSA = 0 "
			
			TcSQLExec(cSQL)
			
		EndIf
	
		(cQry)->(DbSkip())
	
	EndDo()

Return()


Static Function fTktUnico()
Local cSQL := ""

	cSQL := " SELECT * "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT '' AS Z43_TKT, ZZV.EMPR, ZZV_CARGA, Z11_GUARDI, ZZV_TICKET, Z11_DATAIN, Z11_DATASA, ZZV_PLACA, ZZV_MOTOR, Z11_PESOSA, Z11_PESMAX, Z11_OBSER, "
	cSQL += " 	( "
	cSQL += " 		SELECT SUM(ISNULL(Z11_PESLIQ, 0)) "
	cSQL += "			FROM " + RetSQLName("Z11")
	cSQL += " 		WHERE ZZV.ZZV_TICKET = Z11_PESAGE "
	cSQL += " 	) AS PESO_BAL, "
	cSQL += " 	( "
	cSQL += " 		SELECT SUM(ISNULL(F2_PBRUTO, 0)) "
	cSQL += "   	FROM VW_SF2_EMP "
	cSQL += "   	WHERE F2_EMP = ZZV.EMPR "
	cSQL += "   	AND F2_CARGA = ZZV.ZZV_CARGA "
	cSQL += " 	) AS PESO_FAT, "
	cSQL += " 	( "
	cSQL += " 		SELECT SUM(ISNULL(ECO_PESO, 0)) "
	cSQL += " 		FROM VW_FAT_ECOSIS FE "
	cSQL += " 		INNER JOIN VW_ITEM_FAT_ECOSIS IFE "
	cSQL += " 		ON IFE.ECO_EMP = FE.ECO_EMP "
	cSQL += " 		AND IFE.ECO_CARGA = FE.ECO_CARGA "
	cSQL += " 		WHERE PRO_CARGA = ZZV.ZZV_CARGA "
	cSQL += " 		AND IFE.ECO_EMP = ZZV.EMPR "
	cSQL += " 	) AS PESO_ECO "
	cSQL += " 	FROM VW_ZZV_EMP ZZV "
	cSQL += " 	INNER JOIN VW_SF2_EMP "
	cSQL += " 	ON EMPR = F2_EMP "
	cSQL += " 	AND ZZV_CARGA = F2_CARGA "
	cSQL += " 	INNER JOIN "+ RetSQLName("Z11") + " Z11 "
	cSQL += " 	ON ZZV.ZZV_TICKET = Z11.Z11_PESAGE "	
	cSQL += " 	WHERE ZZV_TICKET IN "
	cSQL += " 	( "
	cSQL += "			SELECT ZZV_TICKET "
	cSQL += " 		FROM VW_ZZV_EMP "
	cSQL += " 		INNER JOIN VW_SF2_EMP "
	cSQL += " 		ON EMPR = F2_EMP "
	cSQL += " 		AND ZZV_CARGA = F2_CARGA "
	cSQL += " 		WHERE ZZV_TICKET <> '' "
	cSQL += " 		AND ZZV_CARGA BETWEEN "+ ValToSQL(MV_PAR03) +" AND "+ ValToSQL(MV_PAR04)
	cSQL += " 		AND F2_EMISSAO BETWEEN "+ ValToSQL(MV_PAR01) +" AND "+ ValToSQL(MV_PAR02)
	cSQL += " 		GROUP BY ZZV_TICKET "
	cSQL += " 	) "
	cSQL += "		GROUP BY ZZV.EMPR, ZZV_CARGA, Z11_GUARDI, ZZV_TICKET, Z11_DATAIN, Z11_DATASA, ZZV_PLACA, ZZV_MOTOR, Z11_PESOSA, Z11_PESMAX, Z11_OBSER "
	cSQL += "	) AS TMP "
	cSQL += "	ORDER BY ZZV_PLACA, Z11_DATAIN, Z11_DATASA "

Return(cSQL)