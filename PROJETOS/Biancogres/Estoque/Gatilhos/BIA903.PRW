#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ BIA903   ณ Autor ณ Ranisses A. Corona    ณ Data ณ 26/01/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Consulta posicao de estoque do produto                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExecBlock                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Codigo do Produto                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAEST                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BIA903()
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local Cabecalho := TFont():New("Arial",,020,,.T.,,,,,.F.,.T.)
Local Produto 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Private lFecha	:= .T.
Private wsCod   := M->ZJ_COD
Private wsTipo	:= M->ZI_TIPO
Private wsCLVL	:= M->ZI_CLVL
Private	lComum	:= .F.       
Private	cMD  	:= ""       

Static oDlg

//Posiciona no Cadastro do Produto
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+M->ZJ_COD,.F.)

//Busca Indicador do Produto
DbSelectArea("SBZ")
DbSetOrder(1)
If DbSeek(xFilial("SBZ")+M->ZJ_COD,.F.)
	//Verifica se o produto e para "Uso Comum"
	If SBZ->BZ_YCOMUM == "S"
		lComum := .T.
	EndIf
	
	If SBZ->BZ_YATIVO = "N"
		If (Alltrim(wsTipo) = "DN" .Or. Alltrim(wsTipo) = "DU")
			MsgAlert("Este item ้ do tipo OBSOLETO. Nใo ้ possํvel realizar a devolu็ใo do mesmo.")
			wsCod := SPACE(15)
			Return(wsCod)
		EndIf
	EndIf
EndIf

If Empty(M->ZI_MATRIC)
	MsgAlert("Por favor informe Matrํcula!")
	wsCod 	:= SPACE(15)
	Return(wsCod)
EndIf

If Empty(Alltrim(wsTipo))
	MsgAlert("Por favor informe o Tipo de Movimentacao (REQUISICAO / DEVOLUCAO)!")
	wsCod 	:= SPACE(15)
	Return(wsCod)
EndIf   

If Empty(Alltrim(wsCLVL))
	MsgAlert("Por favor informe a CLASSE DE VALOR do cabe็alho primeiro!")
	wsCod 	:= SPACE(15)
	Return(wsCod)
EndIf

DbSelectArea("SBM")
DbSetOrder(1)
DbSeek(xFilial("SBM")+SB1->B1_GRUPO,.F.)
If Alltrim(SB1->B1_TIPO) == "MD"
	IF SBM->BM_YCON_MD == "N"
		MsgAlert("Este produto nใo controla MD e nใo podera ser utilizado - Consulte o Almoxaridado...")
		wsCod 	:= SPACE(15)
		Return(wsCod)
	END IF
EndIf

//If wQuant == 0.0001 .and. !wsTipo $ "DN_DU"
//	MsgAlert("O produto esta com estoque zerado - Consulte o Almoxarifado...")
//	wsCod := SPACE(15)
//	wFim  := .T.
//EndIf

//If wSaldo == 0.0001 .and. wQuant > 0.0001 .and. !wsTipo $ "DN_DU"
//	MsgAlert("O produto esta totalmente empenhado - Consulte o Almoxarifado...")
//	wsCod := SPACE(15)
//	wFim  := .T.
//EndIf

While lFecha     

    DbSelectArea("SBZ")
    IF SBZ->BZ_YMD <> 'S'
       cMD := "Item de Estoque"
    ELSE
       cMD := "Nใo ้ item de Estoque "
    ENDIF
    
	If lComum
		DEFINE MSDIALOG oDlg TITLE "Consulta Estoque" FROM 000, 000  TO 535, 650 COLORS 0, 16777215 PIXEL
	Else
		DEFINE MSDIALOG oDlg TITLE "Consulta Estoque" FROM 000, 000  TO 350, 650 COLORS 0, 16777215 PIXEL
	EndIf
	@ 012, 012 SAY oSay1 PROMPT "Produto"    SIZE 035, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
	@ 012, 057 SAY oSay2 PROMPT "Descri็ใo"  SIZE 045, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
	@ 012, 165 SAY oSay3 PROMPT "Unid. Med." SIZE 030, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
	@ 012, 190 SAY oSay4 PROMPT "Tipo"       SIZE 045, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL 
	//@ 012, 280 SAY oSay5 PROMPT "Polํtica"   SIZE 030, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL	
	If lComum
		@ 045, 012 SAY oSay6 PROMPT "Estoque Fํsico BIANCOGRES(6B)" SIZE 141, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
		@ 121, 012 SAY oSay7 PROMPT "Estoque Fํsico INCESA(6I)" SIZE 160, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
		@ 197, 012 SAY oSay7 PROMPT "Estoque Fํsico VITCER(6V)" SIZE 179, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
	Else
		@ 045, 012 SAY oSay8 PROMPT "Estoque Fํsico " + Capital(FWEmpName(cEmpAnt)) SIZE 141, 008 OF oDlg FONT Cabecalho COLORS 0, 16777215 PIXEL
	EndIf
	@ 025, 012 SAY oSay9  PROMPT SB1->B1_COD    SIZE 035, 007 OF oDlg FONT Produto COLORS 128, 16777215 PIXEL
	@ 025, 057 SAY oSay10 PROMPT SB1->B1_DESC   SIZE 100, 007 OF oDlg FONT Produto COLORS 128, 16777215 PIXEL
	@ 025, 165 SAY oSay11 PROMPT SB1->B1_UM     SIZE 025, 007 OF oDlg FONT Produto COLORS 128, 16777215 PIXEL
	@ 025, 190 SAY oSay12 PROMPT cMD            SIZE 100, 007 OF oDlg FONT Produto COLORS 128, 16777215 PIXEL 
	//@ 025, 280 SAY oSay13 PROMPT SBZ->BZ_YPOLIT SIZE 025, 007 OF oDlg FONT Produto COLORS 128, 16777215 PIXEL	
	If lComum
		fWBrowse1()
		fWBrowse2()
		fWBrowse3()
	Else
		fWBrowse1()
	EndIf
	ACTIVATE MSDIALOG oDlg CENTERED
EndDo


Return(wsCod)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Monta browse com produtos 6B ou da empresa corrente                   บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fWBrowse1()
Local oWBrowse1
Local aWBrowse1 := {}
Local _cInAcess	:=	"%('1')%"

Local _cAlias	:=	GetNextAlias()

	DbSelectArea("ZZY")
	ZZY->(DbSetOrder(3))
	If ZZY->(DbSeek(xFilial("ZZY")+M->ZI_MATRIC))
		If ZZY->ZZY_LOCACE == '1'
			_cInAcess	:=	"%('1')%"
		Elseif ZZY->ZZY_LOCACE == '2'
			_cInAcess	:=	"%('2')%"
		ElseIf ZZY->ZZY_LOCACE == '3'
			_cInAcess	:=	"%('1','2')%"
		EndIf
	EndIf
	
BeginSql Alias _cAlias

SELECT ZCN.ZCN_COD
	,ZCN.ZCN_LOCAL
	,ZCN.ZCN_LOCALI
	,ZCN.ZCN_POLIT
	,ISNULL(SB2.B2_QATU, 0) AS QATU
	,ISNULL(SB2.B2_VATU1, 0) AS B2_VATU1
	,ISNULL(SB2.B2_RESERVA, 0) AS B2_RESERVA
	,ISNULL(SB2.B2_QATU, 0) - ISNULL(SB2.B2_RESERVA, 0) AS ESTOQUE
FROM %TABLE:ZCN% ZCN
LEFT JOIN %TABLE:SB2% SB2 ON ZCN.ZCN_FILIAL = SB2.B2_FILIAL
	AND ZCN.ZCN_COD = SB2.B2_COD
	AND ZCN.ZCN_LOCAL = SB2.B2_LOCAL
	AND SB2.%NotDel%
WHERE ZCN.ZCN_FILIAL = %XFILIAL:ZCN%
	AND ZCN.ZCN_COD = %Exp:M->ZJ_COD%
	AND ZCN.ZCN_SEQUEN IN %Exp:_cInAcess%
	AND ZCN.%NotDel%


EndSql

//Grava informacoes no Browser
If !(_cAlias)->(Eof())
	While !(_cAlias)->(Eof())
		If !Empty(M->ZI_YLOCAL)
			IF (_cAlias)->ZCN_LOCAL == M->ZI_YLOCAL
				Aadd(aWBrowse1,{Alltrim(M->ZJ_COD),Alltrim((_cAlias)->ZCN_LOCAL),(_cAlias)->ZCN_LOCALI,(_cAlias)->ZCN_POLIT,(_cAlias)->QATU,(_cAlias)->B2_VATU1,(_cAlias)->B2_RESERVA,(_cAlias)->ESTOQUE})
			EndIf
		Else
			Aadd(aWBrowse1,{Alltrim(M->ZJ_COD),Alltrim((_cAlias)->ZCN_LOCAL),(_cAlias)->ZCN_LOCALI,(_cAlias)->ZCN_POLIT,(_cAlias)->QATU,(_cAlias)->B2_VATU1,(_cAlias)->B2_RESERVA,(_cAlias)->ESTOQUE})		
		EndIF
		(_cAlias)->(DbSkip())
	End Do
Else
	Aadd(aWBrowse1,{Alltrim(M->ZJ_COD),"  ","",0,0,0,0})
EndIf

@ 058, 012 LISTBOX oWBrowse1 Fields HEADER "C๓digo","Almox.","Localiza็ใo","Polํtica","Quant.","Valor","Empenho","Saldo" SIZE 300, 050 OF oDlg PIXEL ColSizes 50,50 //COLOR CLR_HBLUE,0
oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {;
aWBrowse1[oWBrowse1:nAt,1],;
aWBrowse1[oWBrowse1:nAt,2],;
aWBrowse1[oWBrowse1:nAt,3],;
aWBrowse1[oWBrowse1:nAt,4],;
aWBrowse1[oWBrowse1:nAt,5],;
aWBrowse1[oWBrowse1:nAt,6],;
aWBrowse1[oWBrowse1:nAt,7],;
aWBrowse1[oWBrowse1:nAt,8];
}}


//Executa no duplo-clique
oWBrowse1:bLDblClick := {|| GravaInf()}

(_cAlias)->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Monta browser com informacoes do Produtos 6I                          บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fWBrowse2()
Local oWBrowse2
Local aWBrowse2		:= {}
Local cEmpresa 		:= ""
Local cAliasTmp1	:= ""
Local cAliasTmp2	:= ""

//Busca Saldo do Almoxarifado 6I
cAliasTmp1 := GetNextAlias()
BeginSql Alias cAliasTmp1
	SELECT *
	FROM (SELECT B2_FILIAL,B2_COD, B2_LOCAL, SUM(B2_QATU) B2_QATU, SUM(B2_VATU1) B2_VATU1, SUM(B2_RESERVA) B2_RESERVA
	FROM 	(SELECT B2_FILIAL,B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2010 WHERE B2_COD = %Exp:M->ZJ_COD%  AND B2_LOCAL = '6I' AND B2_QATU > 0 AND %NOTDEL%
	UNION ALL
	SELECT B2_FILIAL,B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2050 WHERE B2_COD = %Exp:M->ZJ_COD% AND B2_LOCAL = '6I' AND B2_QATU > 0 AND %NOTDEL% 
	UNION ALL
	SELECT B2_FILIAL,B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2140 WHERE B2_COD = %Exp:M->ZJ_COD% AND B2_LOCAL = '6I' AND B2_QATU > 0 AND %NOTDEL% ) SALDO
	GROUP BY B2_FILIAL,B2_COD, B2_LOCAL)TAB
	LEFT JOIN %TABLE:ZCN% ZCN ON ZCN.ZCN_FILIAL = TAB.B2_FILIAL
	AND ZCN.ZCN_COD = TAB.B2_COD
	AND ZCN.ZCN_LOCAL = TAB.B2_LOCAL
EndSql

//Busca a Localizacao no Indicador da Incesa
cAliasTmp2 := GetNextAlias()
BeginSql Alias cAliasTmp2
	SELECT * FROM SBZ050 WHERE BZ_COD = %Exp:M->ZJ_COD% AND %NOTDEL%
EndSql

//Grava informacoes no Browser
If !(cAliasTmp1)->(EOF())
	Do While !(cAliasTmp1)->(EOF())
		Aadd(aWBrowse2,{Alltrim(M->ZJ_COD),Alltrim((cAliasTmp1)->B2_LOCAL),Alltrim((cAliasTmp2)->BZ_YLOCAL),(cAliasTmp1)->B2_QATU,(cAliasTmp1)->B2_VATU1,(cAliasTmp1)->B2_RESERVA,(cAliasTmp1)->B2_QATU-(cAliasTmp1)->B2_RESERVA})
		(cAliasTmp1)->(DbSkip())
	End Do
Else
	Aadd(aWBrowse2,{Alltrim(M->ZJ_COD),"  ","",0,0,0,0})
EndIf

@ 133, 012 LISTBOX oWBrowse2 Fields HEADER "C๓digo","Almox.","Localiza็ใo","Quant.","Valor","Empenho","Saldo" SIZE 300, 050 OF oDlg PIXEL ColSizes 50,50
oWBrowse2:SetArray(aWBrowse2)
oWBrowse2:bLine := {|| {;
aWBrowse2[oWBrowse2:nAt,1],;
aWBrowse2[oWBrowse2:nAt,2],;
aWBrowse2[oWBrowse2:nAt,3],;
aWBrowse2[oWBrowse2:nAt,4],;
aWBrowse2[oWBrowse2:nAt,5],;
aWBrowse2[oWBrowse2:nAt,6],;
aWBrowse2[oWBrowse2:nAt,7];
}}

//Executa no duplo-clique
oWBrowse2:bLDblClick := {|| GravaInf()}

// Tiago Rossini Coradini - 14/12/15 - Tratamento para alterar a cor do grid
//oWBrowse2:lUseDefaultColors := .F.

//Fecha Arquivo Temporario
(cAliasTmp1)->(dbCloseArea())
(cAliasTmp2)->(dbCloseArea())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Monta browser com informacoes do Produtos 6V                          บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fWBrowse3()
Local oWBrowse3
Local aWBrowse3		:= {}
Local cEmpresa 		:= ""
Local cAliasTmp1	:= ""
Local cAliasTmp2	:= ""

//Busca Saldo do Almoxarifado 6I
cAliasTmp1 := GetNextAlias()
BeginSql Alias cAliasTmp1
	SELECT B2_COD, B2_LOCAL, SUM(B2_QATU) B2_QATU, SUM(B2_VATU1) B2_VATU1, SUM(B2_RESERVA) B2_RESERVA
	FROM 	(SELECT B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2010 WHERE B2_COD = %Exp:M->ZJ_COD%  AND B2_LOCAL = '6V' AND B2_QATU > 0 AND %NOTDEL%
	UNION ALL
	SELECT B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2050 WHERE B2_COD = %Exp:M->ZJ_COD% AND B2_LOCAL = '6V' AND B2_QATU > 0 AND %NOTDEL% 
	UNION ALL
	SELECT B2_COD, B2_LOCAL, B2_QATU, B2_VATU1, B2_RESERVA FROM SB2140 WHERE B2_COD = %Exp:M->ZJ_COD% AND B2_LOCAL = '6V' AND B2_QATU > 0 AND %NOTDEL% ) SALDO
	GROUP BY B2_COD, B2_LOCAL
EndSql

//Busca a Localizacao no Indicador da Incesa
cAliasTmp2 := GetNextAlias()
BeginSql Alias cAliasTmp2
	SELECT * FROM SBZ140 WHERE BZ_COD = %Exp:M->ZJ_COD% AND %NOTDEL%
EndSql

//Grava informacoes no Browser
If !(cAliasTmp1)->(EOF())
	Do While !(cAliasTmp1)->(EOF())
		Aadd(aWBrowse3,{Alltrim(M->ZJ_COD),Alltrim((cAliasTmp1)->B2_LOCAL),Alltrim((cAliasTmp2)->BZ_YLOCAL),(cAliasTmp1)->B2_QATU,(cAliasTmp1)->B2_VATU1,(cAliasTmp1)->B2_RESERVA,(cAliasTmp1)->B2_QATU-(cAliasTmp1)->B2_RESERVA})
		(cAliasTmp1)->(DbSkip())
	End Do
Else
	Aadd(aWBrowse3,{Alltrim(M->ZJ_COD),"  ","",0,0,0,0})
EndIf

@ 208, 012 LISTBOX oWBrowse3 Fields HEADER "C๓digo","Almox.","Localiza็ใo","Quant.","Valor","Empenho","Saldo" SIZE 300, 050 OF oDlg PIXEL ColSizes 50,50
oWBrowse3:SetArray(aWBrowse3)
oWBrowse3:bLine := {|| {;
aWBrowse3[oWBrowse3:nAt,1],;
aWBrowse3[oWBrowse3:nAt,2],;
aWBrowse3[oWBrowse3:nAt,3],;
aWBrowse3[oWBrowse3:nAt,4],;
aWBrowse3[oWBrowse3:nAt,5],;
aWBrowse3[oWBrowse3:nAt,6],;
aWBrowse3[oWBrowse3:nAt,7];
}}

//Executa no duplo-clique
oWBrowse3:bLDblClick := {|| GravaInf()}

// Tiago Rossini Coradini - 14/12/15 - Tratamento para alterar a cor do grid
//oWBrowse3:lUseDefaultColors := .F.

//Fecha Arquivo Temporario
(cAliasTmp1)->(dbCloseArea())
(cAliasTmp2)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ Grava informacoes no acols Itens da PreRequiscao                      บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaInf()    
Local nPos

//Define a Empresa que o sistema ira buscar o estoque    
If (ODLG:OCTLFOCUS:Nat <> Nil .and. ODLG:OCTLFOCUS:Nat > 0)
	nPos := ODLG:OCTLFOCUS:Nat 
Else
	nPos := 1
EndIf                                                                                                                        

cEmpresa := cEmpAnt//U_EstoqueEmpresa(ODLG:OCTLFOCUS:AARRAY[nPos][1],ODLG:OCTLFOCUS:AARRAY[nPos][2])

aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]		:= ODLG:OCTLFOCUS:AARRAY[nPos][2]
aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_EMPDEST'})]	:= cEmpresa
aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_YLOCALI'})]	:= ODLG:OCTLFOCUS:AARRAY[nPos][3]

M->ZI_YLOCAL	:=	ODLG:OCTLFOCUS:AARRAY[nPos][2]

lFecha := .F.

Close(oDlg)

// Acha a posicao do campo no Enchoice
nPos     := aScan(O:OWND:ACONTROLS,{|x| x:CREADVAR == 'M->ZI_YLOCAL' })     

// Atualiza campo
O:OWND:ACONTROLS[nPos]:REFRESH()

Return