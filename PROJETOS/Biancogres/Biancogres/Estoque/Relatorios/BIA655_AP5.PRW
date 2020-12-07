#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} BIA655
@author Microsiga Vitória
@since 03/07/1998
@version 1.0
@description Impressao de etiqueta de codigo de barras 
@type function
/*/

User Function Bia655()
	
	Local _oCbEmp	:=	Nil
	Local _aItens	:=	{"1=Biancogres","2=Incesa"}
	
	SetPrvt("WCOD,WQTD,WSTRING")

	Private wCod := Space(15)
	Private wQtd := 1
	Private wMarca	:= Space(30)
	Private wPn		:= Space(30)
	Private wEmpSel	:=	_aItens[1]

	@ 000,000 to 270,400 Dialog oDlg1 Title "Impressao de Etiquetas"

		@ 001,002 to 105,198
		
		@ 005,010 say "Esta rotina tem como objetivo imprimir etiquetas de codigo de"
		@ 015,010 say "barras conforme os parametros informados."
	
		
		@ 032,010 Say "Empresa..........................: "
		@ 045,010 Say "Codigo do produto.........: "
		@ 058,010 Say "Marca............................: "
		@ 071,010 Say "Part Number...................: "
		@ 084,010 Say "Quantidade de etiquetas: "
		_oCbEmp := tComboBox():New(032,073,{|u|if(PCount()>0,wEmpSel:=u,wEmpSel)},_aItens,060,10,oDlg1,,{|| },,,,.T.,,,,,,,,,'wEmpSel')
		@ 045,073 Get wCod Picture "@S8" F3 "SB1" 
		@ 058,073 Get wMarca Picture "@!" F3 "ZD6ETI"
		@ 071,073 Get wPn Picture "@!" WHEN .F.
		@ 084,073 Get wQtd Picture "999"
	
		@ 111,130 BmpButton Type 01 Action fImprime()
		@ 111,170 BmpButton Type 02 Action Close(oDlg1)
	
	Activate Dialog oDlg1 Centered

Return


Static Function fImprime()
	Local aArea := GetArea()
	
	Local _cParPc	:=	Alltrim(GetMv("MV_YPCETIQ"))

	Local _aPcEtiq	:=	StrToKarr(_cParPc,';')
	
	Local _nEmp		:=	Val(wEmpSel)
	
	Local _cPcEtiq	:=	""
	
	Local _cLocali	:=	""
	
	If Len(_aPcEtiq) >= _nEmp
		_cPcEtiq	:=	_aPcEtiq[_nEmp]
	Else
		MsgBox("Não existe impressora cadastrada para a empresa selecionada!","Alerta","ERRO")
		RestArea(aArea)
		Return
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)
	If !SB1->(DbSeek(xFilial("SB1") + wCod))
	
		MsgBox("O codigo de produto digitado nao existe!"+chr(13)+"Verifique-o e tente novamente.","Alerta","ERRO")
		
		RestArea(aArea)
		
		Return()
	
	EndIf
/*
	If !Empty(SB1->B1_YPDM)
		If Empty(wMarca) .Or. Empty(wPn)
		
			MsgBox("O produto exige que sejam informados marca e part number!"+chr(13)+"Verifique-o e tente novamente.","Alerta","ERRO")
			
			RestArea(aArea)
			
			Return()
		
		EndIf
		If !fSeekMarca()

			MsgBox("Marca e Part Number não encontrados!"+chr(13)+"Verifique-os e tente novamente.","Alerta","ERRO")
			
			RestArea(aArea)
			
			Return()
		
		EndIf
	EndIf
*/
	If wQtd < 1 .and. wQtd > 999
		
		MsgBox("A quantidade informada deve ser de 1 a 999!","Alerta","ERRO")
		
		RestArea(aArea)	
		
		Return()
		
	EndIf

	gt_Solic := ""
	gt_NumPc := ""
	C0001 := " SELECT C1_SOLICIT, C7_NUM
	C0001 += "   FROM "+RetSqlName("SC7")+" SC7
	C0001 += "   LEFT JOIN "+RetSqlName("SC1")+" SC1 ON C1_FILIAL = '"+xFilial("SC1")+"'
	C0001 += "                       AND C1_NUM = C7_NUMSC
	C0001 += "                       AND C1_ITEM = C7_ITEMSC
	C0001 += "                       AND SC1.D_E_L_E_T_ = ' '
	C0001 += "  WHERE C7_FILIAL = '"+xFilial("SC7")+"'
	C0001 += "    AND C7_NUM = '"+SC7->C7_NUM+"'
	C0001 += "    AND C7_PRODUTO = '"+Alltrim(wCod)+"'
	C0001 += "    AND SC7.D_E_L_E_T_ = ' '
	
	TcQuery C0001 ALIAS "C001" NEW
	dbSelectArea("C001")
	
	dbGoTop()
	gt_Solic := Alltrim(C001->C1_SOLICIT) + " "
	gt_NumPc := "   PC: " + Alltrim(C001->C7_NUM) + " "
	
	C001->(dbCloseArea())

	// Gera um arquivo texto temporario para a impressao das etiquetas
	If File("\\urano\Arquivos_P12\Etiquetas\ETIQ.TMP")
		Delete File \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP
	EndIf

	wString := "O0220" + Chr(13)
	wString := wString + "M0350"  + Chr(13)
	wString := wString + "c0000"  + Chr(13)
	wString := wString + "f000"   + Chr(13)
	wString := wString + "e"      + Chr(13)
	wString := wString + "LC0000" + Chr(13)
	wString := wString + "H09"     + Chr(13)
	wString := wString + "D11"     + Chr(13)
	wString := wString + "SC"      + Chr(13)
	wString := wString + "PC"      + Chr(13)
	wString := wString + "R0000"   + Chr(13)
	wString := wString + "z"       + Chr(13)
	wString := wString + "W"       + Chr(13)
	wString := wString + "^01"     + Chr(13)
	wString := wString + "121100001180007   DATA:" + DTOC(DATE()) + Chr(13)
	wString := wString + "121100000980007   UND.:" +AllTrim(SB1->B1_UM) + Chr(13)
	
	If cempant == "01"
		_cLocali	:=	POSICIONE("ZCN",1,xFilial("ZCN")+PADR(wCod,TamSx3("B1_COD")[1])+wEmpSel, "ZCN_LOCALI")
		wString := wString + "121100000780007   LOC.:"     + SUBSTR(_cLocali,01,18) + Chr(13)
	ElseIf cEmpAnt == "05"
		wString := wString + "121100000780007   LOC.:"     + SUBSTR(SB1->B1_YLOCINC,01,18) + Chr(13)
	ElseIf cEmpAnt == "14"	
		wString := wString + "121100000780007   LOC.:"     + SUBSTR(SB1->B1_YLOCVIT,01,18) + Chr(13)
	EndIf
	
	wString := wString + "1e5204000870140" + AllTrim(SB1->B1_COD) + Chr(13)
	wString := wString + "113100000800140" + AllTrim(SB1->B1_COD) + Chr(13)
	wString := wString + "121100000550020" + SUBSTR(SB1->B1_DESC   ,01,48) + Chr(13)
	wString := wString + "121100000420020" + SUBSTR(SB1->B1_DESC   ,49,48) + Chr(13)
	
	wString := wString + "121100000220007" +gt_NumPc + "      SOLIC: "  + gt_Solic + Chr(13)
		
	wString := wString + "121100000020007   MARCA: "     + Alltrim(wmarca) + "  P/N: " + Alltrim(wPn) + Chr(13)
	wString := wString + "Q"                           + StrZero(wQtd,4)                               + Chr(13)
	wString := wString + "E"                                                                           + Chr(13)
	
	MemoWrite("\\urano\Arquivos_P12\Etiquetas\ETIQ.TMP",wString)
	
	//Apaga mapeamento
	WinExec("net use lpt3 /delete")
	//Realiza o mapeamento 
	WinExec("net use lpt3 \\"+_cPcEtiq+"\ARGOX")
	//Realiza a Impressão
	WinExec("CMD /C TYPE \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP > LPT3")
	
Return()

Static Function fSeekMarca()

	Local _aArea	:=	GetArea()
	
	Local _cAlias	:=	GetNextAlias()
	
	Local _lret		:=	.F.
	
	BeginSql Alias _cAlias
	
		SELECT COUNT(*) AS QTD
		FROM %TABLE:ZD6% ZD6
		WHERE ZD6.ZD6_FILIAL = %XFILIAL:ZD6%
			AND ZD6.ZD6_COD = %Exp:wCod%
			AND ZD6.ZD6_MARCA = %Exp:wMarca%
			AND ZD6.ZD6_REFER = %Exp:wPn%
			AND %NotDel%
	EndSql
	
	If (_cAlias)->QTD > 0
		_lRet	:=	.T.
	EndIf
	
	(_cAlias)->(DbCloseArea())
	
	RestArea(_aArea)

Return _lRet