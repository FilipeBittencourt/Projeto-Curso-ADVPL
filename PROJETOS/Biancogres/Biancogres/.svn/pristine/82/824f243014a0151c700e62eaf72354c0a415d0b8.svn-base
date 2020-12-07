#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "vkey.ch"

#DEFINE _INCLUI 	1
#DEFINE _ENTRADA 	2
#DEFINE _SAIDA 	 	3
#DEFINE _ALTERAR 	4

User Function MOV797()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MOV797   ³ Autor ³ Marcos Alberto S      ³ Data ³ 18/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Tela para pesagem de Veiculo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

// Variaveis Locais da Funcao
Private aComboBx1  := {" ","Entrega","Retirada"}
Private cComboBx1
Private aCBxMotPat := {"Sim","Não"}
Private cCBxMotPat := "Não"
Private oEdit1
Private oEdit10                          
Private oEdit11
Private oEdit12
Private oEdit13
Private oEdit14
Private oEdit15
Private oEdit16
Private oEdit17
Private oEdit18
Private oEdit19
Private oEdit20
Private oEdit2
Private oEdit3
Private oEdit4
Private oEdit6
Private oEdit7
Private oEdit8
Private oEdit9
Private oEdit21
Private oEdit23
Private oEdit24
Private oEdit25
Private oEdit26
Private oEdit27
Private oEdit28
Private oEdit29
Private oEdit30
Private oEdit31
Private oEdit32


//Private jy_Carga := Space(6)
Private jy_Carga := Space(8)
Private cf_Placa

Private	cEdit1	 := 0
Private	cEdit2	 := ''
Private	cEdit3	 := ''
Private	cEdit4	 := ''
Private	cEdit5	 := ''
Private	cEdit6	 := ''
Private	cEdit7	 := ''
Private	cEdit8	 := ''
Private	cEdit9	 := ''
Private	cEdit10	 := ''
Private	cEdit11	 := 0
Private	cEdit12	 := 0
Private	cEdit13	 := 0
Private	cEdit14	 := 0
Private	cEdit15	 := 0
Private	cEdit16	 := 0
Private	cEdit17	 := ''
Private	cEdit18	 := ''
Private	cEdit19	 := ''
Private cEdit20	 := 0
Private cEdit21 := ""
Private cEdit22 := 0
Private cEdit23 := Space(8)
Private cEdit24 := Space(5)
Private cEdit25 := Space(6)
Private cEdit26 := "" 
Private cEdit27 := "" 
Private cEdit28 := ""
Private cEdit29 := "" 
Private cEdit30 := 0 
Private cEdit31 := 0 
Private cEdit32 := 0 

Private lVisual  	:= .F.
Private lEntrada 	:= .F.
Private lSaida   	:= .F.
Private lIncluir 	:= .F.
Private lMat_Prima 	:= .F.
Private lAlterar 	:= .F.

// Variaveis Private da Funcao
Private _oDlgPV				// Dialog Principal
// Variaveis que definem a Acao do Formulario

/*IF CEMPANT == "05"
	ALERT("INCESA")
ELSE
	ALERT("BIANCOGRES")
END IF
*/

wopcao := Paramixb
Do Case
	Case wOpcao == "V" ; lVisual     := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUAL"
	Case wOpcao == "E" ; lEntrada    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ENTRADA"
	Case wOpcao == "S" ; lSaida      := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "SAIDA"
	Case wOpcao == "IN"; lIncluir    := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "INCLUIR"
	Case wOpcao == "M" ; lMat_Prima	 := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "Materia Prima"
	Case wOpcao == "AL"; lAlterar	 := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "ALTERAR"
EndCase

IF lIncluir .or. lMat_Prima
	
	kl_NovoSeq := .F.

	cEdit1	 := GetSx8Num("Z11","Z11_PESAGE")
	cEdit2	 := dtoc(dDataBase)
	cEdit3	 := Substr(Time(),1,5)
	//cEdit4	 := Space(08)
	cEdit4	 := Space(07)
	cEdit5	 := Space(08)
	cEdit6	 := Space(08)
	cEdit7	 := Space(50)
	cEdit21  := Space(06)
	cEdit8	 := Space(06)
	cEdit9	 := Space(50)
	cEdit10	 := Space(02)
	cEdit11	 := 0
	cEdit12	 := 0
	cEdit13	 := 0
	cEdit14	 := 0
	cEdit15	 := 0
	cEdit16	 := 0
	cEdit17	 := Space(2)
	cEdit18	 := Space(200)
	cEdit19	 := Space(200)
	cEdit20	 := 0
	cEdit22  := 0
	
	cEdit26 := Space(8)
	cEdit27 := Space(5)
	cEdit28 := Space(8)
	cEdit29 := Space(5)
	cEdit30 := 0
	cEdit31 := 0
	cEdit32 := 0
    
	xj_Fecha := .F.
	
	MontaTela(_INCLUI)
	
ElseIf lAlterar
	xd_Merc := IIF(Z11->Z11_MERCAD == 1, "Entrega","Retirada")
	kl_NovoSeq := .T.

	cEdit1	 := Z11->Z11_PESAGE
	cEdit10	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_EST")
	cEdit11	 := Z11->Z11_PESOIN
	cEdit12	 := Z11->Z11_PESOSA
	cEdit13	 := Z11->Z11_PESLIQ
	cEdit14	 := Z11->Z11_DESVIO
	cEdit15	 := Z11->Z11_PESCAL
	cEdit16	 := Z11->Z11_PESINF
	cEdit17  := Z11->Z11_LJTRAN
	cEdit18  := Z11->Z11_OBSER
	cEdit2	 := IIF(Empty(Z11->Z11_DATACA), Z11->Z11_DATAIN, Z11->Z11_DATACA) //Z11->Z11_DATAIN
	cEdit3	 := Z11->Z11_HORAIN
	//cEdit4	 := Substr(Z11->Z11_PCAVAL,1,3)+"-"+Substr(Z11->Z11_PCAVAL,4,4)
	cEdit4	 := Z11->Z11_PCAVAL
	cEdit6	 := Substr(Z11->Z11_PCARRE,1,3)+"-"+Substr(Z11->Z11_PCARRE,4,4)
	cEdit21  := Z11->Z11_CODMOT
	cEdit7	 := Z11->Z11_MOTORI
	cEdit8	 := Z11->Z11_CODTRA
	cEdit9	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_NOME")

	cEdit5	 := Z11->Z11_CLVEIC
	cEdit20	 := Z11->Z11_PESMAX
	cEdit19  := Z11->Z11_NOMCLI
	cEdit22  := Z11->Z11_TARA
	
	cEdit23 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_DATAAG")
	cEdit24 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_HORAAG")
	cEdit25 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_GALPAO")
	
	cEdit26 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_DATAIN, '') 
	cEdit27 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_HORAIN, '')
	cEdit28 := Z11->Z11_DATASA
	cEdit29 := Z11->Z11_HORASA
	
	cEdit30 := Posicione("DA3",3 , xFilial("DA3")+cEdit4, "DA3_YPSAD") 
	cEdit31 := cEdit22 + cEdit30
	cEdit32 := cEdit20 - cEdit31
	
	
	cComboBx1 := xd_Merc
	cCBxMotPat := IIF(Z11->Z11_MOTPAT == 'S','Sim', 'Não' )
	
	xj_Fecha := .F.
	
	MontaTela(_ALTERAR)

ElseIf lEntrada
	
	IF Z11->Z11_PESOIN <> 0.01
		MsgINFO("Pesagem não liberado pela expedição")
		Return
	END IF
	xd_Merc := IIF(Z11->Z11_MERCAD == 1, "Entrega","Retirada")
	kl_NovoSeq := .T.
	If lEntrada .and. Z11->Z11_PESOIN <> 0 .and. Z11->Z11_PESOSA <> 0
		MsgINFO("Já está encerrado este processo de pesagem!!!")
		Return
	EndIf
	
	cEdit1	 := Z11->Z11_PESAGE
	cEdit10	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_EST")
	cEdit11	 := Z11->Z11_PESOIN
	cEdit12	 := Z11->Z11_PESOSA
	cEdit13	 := Z11->Z11_PESLIQ
	cEdit14	 := Z11->Z11_DESVIO
	cEdit15	 := Z11->Z11_PESCAL
	cEdit16	 := Z11->Z11_PESINF
	cEdit17  := Z11->Z11_LJTRAN
	cEdit18  := Z11->Z11_OBSER
	cEdit2	 := IIF(Empty(Z11->Z11_DATACA), Z11->Z11_DATAIN, Z11->Z11_DATACA)//Z11->Z11_DATAIN
	cEdit3	 := Z11->Z11_HORAIN
	//cEdit4	 := Substr(Z11->Z11_PCAVAL,1,3)+"-"+Substr(Z11->Z11_PCAVAL,4,4) 
    cEdit4	 := Z11->Z11_PCAVAL
	cEdit6	 := Substr(Z11->Z11_PCARRE,1,3)+"-"+Substr(Z11->Z11_PCARRE,4,4)
	cEdit21  := Z11->Z11_CODMOT
	cEdit7	 := Z11->Z11_MOTORI
	cEdit8	 := Z11->Z11_CODTRA
	cEdit9	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_NOME")

	cEdit5	 := Z11->Z11_CLVEIC
	cEdit20	 := Z11->Z11_PESMAX
	cEdit19  := Z11->Z11_NOMCLI
	cEdit22  := Z11->Z11_TARA
	
	cEdit23 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_DATAAG")
	cEdit24 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_HORAAG")
	cEdit25 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_GALPAO")
	
	cEdit26 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_DATAIN, '') 
	cEdit27 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_HORAIN, '')
	cEdit28 := Z11->Z11_DATASA
	cEdit29 := Z11->Z11_HORASA
	
	
	cEdit30 := Posicione("DA3",3 , xFilial("DA3")+cEdit4, "DA3_YPSAD") 
	cEdit31 := cEdit22 + cEdit30
	cEdit32 := cEdit20 - cEdit31
	
	
	
	cComboBx1 := xd_Merc
	cCBxMotPat := IIF(Z11->Z11_MOTPAT == 'S','Sim', 'Não' )
	
	xj_Fecha := .F.
	
	MontaTela(_ENTRADA)
	/*
	DEFINE MSDIALOG _oDlgPV TITLE "Pesagem de Veículos" FROM C(178),C(181) TO C(610),C(810) PIXEL
	
	// Cria as Groups do Sistema
	@ C(001),C(004) TO C(037),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(038),C(004) TO C(074),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(076),C(004) TO C(109),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(113),C(004) TO C(166),C(313) LABEL " Resultado da Pesagem " PIXEL OF _oDlgPV
	
	// Cria Componentes Padroes do Sistema
	@ C(008),C(010) Say "Quanto a Mercadoria?" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(093) Say "Seqüêncial"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(165) Say "Data Entrada:"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(239) Say "Hora Entrada:"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(017),C(010) Say xd_Merc                       Size C(072),C(010) PIXEL OF _oDlgPV
	@ C(017),C(093) MsGet oEdit1 Var cEdit1  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(017),C(166) MsGet oEdit2 Var cEdit2  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(017),C(239) MsGet oEdit3 Var cEdit3  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(044),C(010) Say "Placa do Cavalo"   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(044),C(106) Say "Placa da Carreta"  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(044),C(173) Say "Motorista"         Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(052),C(010) MsGet oEdit4 Var cEdit4 When .F. Picture "@! AAA-9999" Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(052),C(106) MsGet oEdit6 Var cEdit6 When .F. Picture "@! AAA9-999" Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(052),C(173) MsGet oEdit7 Var cEdit7 When .F. Picture "@!"          Size C(134),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(082),C(010) Say "Transportadora"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(082),C(269) Say "UF"                Size C(009),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	If lSaida .and. !lVisual
		@ C(091),C(010) MsGet oEdit8  Var cEdit8  F3 "SA2" Valid fTransp()   Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		@ C(091),C(068) MsGet oEdit17 Var cEdit17          Valid fLjTransp() Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	Else
		@ C(091),C(010) MsGet oEdit8  Var cEdit8  When .F. Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		@ C(091),C(068) MsGet oEdit17 Var cEdit17 When .F. Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf
	@ C(091),C(091) MsGet oEdit9  Var cEdit9  When .F. Size C(171),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(091),C(269) MsGet oEdit10 Var cEdit10 When .F. Size C(020),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(124),C(048) MsGet oEdit11 Var cEdit11 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(124),C(145) MsGet oEdit13 Var cEdit13 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(124),C(247) MsGet oEdit15 Var cEdit15 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(127),C(010) Say "1a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(127),C(114) Say "Peso Liquido:"     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(127),C(218) Say "Peso Calc.:"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(144),C(048) MsGet oEdit12 Var cEdit12 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(144),C(145) MsGet oEdit14 Var cEdit14 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	If lSaida .and. !lVisual
		@ C(144),C(247) MsGet oEdit16 Var cEdit16 Valid(fRefPeso())  Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	ElseIf !lSaida .and. lVisual
		@ C(144),C(247) MsGet oEdit16 Var cEdit16 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf
	
	@ C(147),C(010) Say "2a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(147),C(128) Say "Desvio:"           Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(147),C(214) Say "Peso Inform.:"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(200),C(188) Button "Cancelar"       Size C(037),C(012) PIXEL OF _oDlgPV Action(_oDlgPV:End())
	@ C(200),C(232) Button "Pesar"          Size C(037),C(012) PIXEL OF _oDlgPV Action(fPesarB())
	@ C(200),C(276) Button "Confirmar"      Size C(037),C(012) PIXEL OF _oDlgPV Action(fConfir())
	
	@ C(173),C(004) Say "Observação"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(180),C(004) MsGet oEdit18 Var cEdit18 Picture "@!"          Size C(310),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	ACTIVATE MSDIALOG _oDlgPV CENTERED
	*/
ElseIf lSaida .or. lVisual
	
	xd_Merc := IIF(Z11->Z11_MERCAD == 1, "Entrega","Retirada")
	kl_NovoSeq := .T.
	If lSaida .and. Z11->Z11_PESOIN <> 0 .and. Z11->Z11_PESOSA <> 0
		MsgINFO("Já está encerrado este processo de pesagem!!!")
		Return
	EndIf
	
	cEdit1	 := Z11->Z11_PESAGE
	cEdit10	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_EST")
	cEdit11	 := Z11->Z11_PESOIN
	cEdit12	 := Z11->Z11_PESOSA
	cEdit13	 := Z11->Z11_PESLIQ
	cEdit14	 := Z11->Z11_DESVIO
	cEdit15	 := Z11->Z11_PESCAL
	cEdit16	 := Z11->Z11_PESINF
	cEdit17  := Z11->Z11_LJTRAN
	cEdit18  := Z11->Z11_OBSER
	cEdit2	 := IIF(Empty(Z11->Z11_DATACA), Z11->Z11_DATAIN, Z11->Z11_DATACA)
	cEdit3	 := Z11->Z11_HORAIN
	//cEdit4	 := Substr(Z11->Z11_PCAVAL,1,3)+"-"+Substr(Z11->Z11_PCAVAL,4,4)
	cEdit4	 := Z11->Z11_PCAVAL
	cEdit6	 := Substr(Z11->Z11_PCARRE,1,3)+"-"+Substr(Z11->Z11_PCARRE,4,4)
	cEdit21  := Z11->Z11_CODMOT
	cEdit7	 := Z11->Z11_MOTORI
	cEdit8	 := Z11->Z11_CODTRA
	cEdit9	 := Posicione("SA4",1,xFilial("SA4")+Z11->Z11_CODTRA,"A4_NOME")
	
	cEdit5	 := Z11->Z11_CLVEIC
	cEdit20	 := Z11->Z11_PESMAX
	cEdit19  := Z11->Z11_NOMCLI
	cEdit22  := Z11->Z11_TARA
	
	cEdit23 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_DATAAG")
	cEdit24 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_HORAAG")
	cEdit25 := Posicione("ZZV", 2, xFilial("ZZV")+Z11->Z11_PESAGE, "ZZV_GALPAO")
	
	cEdit26 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_DATAIN, '') 
	cEdit27 := IIF(Z11->Z11_PESOIN > 0.01, Z11->Z11_HORAIN, '')
	cEdit28 := Z11->Z11_DATASA
	cEdit29 := Z11->Z11_HORASA
	
	cComboBx1 := xd_Merc
	cCBxMotPat := IIF(Z11->Z11_MOTPAT == 'S','Sim', 'Não' )
	
	xj_Fecha := .F.
	
	MontaTela(_SAIDA)
	/*
	DEFINE MSDIALOG _oDlgPV TITLE "Pesagem de Veículos" FROM C(178),C(181) TO C(610),C(810) PIXEL
	
	// Cria as Groups do Sistema
	@ C(001),C(004) TO C(037),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(038),C(004) TO C(074),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(076),C(004) TO C(109),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(113),C(004) TO C(166),C(313) LABEL " Resultado da Pesagem " PIXEL OF _oDlgPV
	
	// Cria Componentes Padroes do Sistema
	@ C(008),C(010) Say "Quanto a Mercadoria?" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(093) Say "Seqüêncial"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(165) Say "Data Entrada:"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(008),C(239) Say "Hora Entrada:"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(017),C(010) Say xd_Merc                       Size C(072),C(010) PIXEL OF _oDlgPV
	@ C(017),C(093) MsGet oEdit1 Var cEdit1  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(017),C(166) MsGet oEdit2 Var cEdit2  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(017),C(239) MsGet oEdit3 Var cEdit3  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(044),C(010) Say "Placa do Cavalo"   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(044),C(106) Say "Placa da Carreta"  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(044),C(173) Say "Motorista"         Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(052),C(010) MsGet oEdit4 Var cEdit4 When .F. Picture "@! AAA-9999" Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(052),C(106) MsGet oEdit6 Var cEdit6 When .F. Picture "@! AAA9-999" Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(052),C(173) MsGet oEdit7 Var cEdit7 When .F. Picture "@!"          Size C(134),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(082),C(010) Say "Transportadora"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(082),C(269) Say "UF"                Size C(009),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	If lSaida .and. !lVisual
		@ C(091),C(010) MsGet oEdit8  Var cEdit8  F3 "SA2" Valid fTransp()   Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		@ C(091),C(068) MsGet oEdit17 Var cEdit17          Valid fLjTransp() Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	Else
		@ C(091),C(010) MsGet oEdit8  Var cEdit8  When .F. Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		@ C(091),C(068) MsGet oEdit17 Var cEdit17 When .F. Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf
	@ C(091),C(091) MsGet oEdit9  Var cEdit9  When .F. Size C(171),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(091),C(269) MsGet oEdit10 Var cEdit10 When .F. Size C(020),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(124),C(048) MsGet oEdit11 Var cEdit11 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(124),C(145) MsGet oEdit13 Var cEdit13 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(124),C(247) MsGet oEdit15 Var cEdit15 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(127),C(010) Say "1a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(127),C(114) Say "Peso Liquido:"     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(127),C(218) Say "Peso Calc.:"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(144),C(048) MsGet oEdit12 Var cEdit12 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(144),C(145) MsGet oEdit14 Var cEdit14 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	If lSaida .and. !lVisual
		@ C(144),C(247) MsGet oEdit16 Var cEdit16 Valid(fRefPeso())  Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	ElseIf !lSaida .and. lVisual
		@ C(144),C(247) MsGet oEdit16 Var cEdit16 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf
	
	@ C(147),C(010) Say "2a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(147),C(128) Say "Desvio:"           Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(147),C(214) Say "Peso Inform.:"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(200),C(188) Button "Cancelar"       Size C(037),C(012) PIXEL OF _oDlgPV Action(_oDlgPV:End())
	If lSaida .and. !lVisual
		@ C(200),C(232) Button "Pesar"          Size C(037),C(012) PIXEL OF _oDlgPV Action(fPesarB())
		@ C(200),C(276) Button "Confirmar"      Size C(037),C(012) PIXEL OF _oDlgPV Action(fConfir())
	EndIf
	
	@ C(173),C(004) Say "Observação"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(180),C(004) MsGet oEdit18 Var cEdit18 Picture "@!"          Size C(310),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	ACTIVATE MSDIALOG _oDlgPV CENTERED
	*/
	
EndIf

If !kl_NovoSeq
	RollBackSx8()
EndIf

Return 


//-----------------------------------------------------------------------------------------------------------
Static Function MontaTela(tpTela)

	DEFINE MSDIALOG _oDlgPV TITLE "Pesagem de Veículos" FROM C(178),C(181) TO C(650),C(860) PIXEL
	
	nEspLin := 023
	
	// Cria as Groups do Sistema
	//@ C(001),C(004) TO C(037),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(001),C(004) TO C(2*nEspLin),C(353) LABEL "" PIXEL OF _oDlgPV
	
	//@ C(038),C(004) TO C(074),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(2*nEspLin+2),C(004) TO C(3*nEspLin),C(353) LABEL "" PIXEL OF _oDlgPV
	
	//@ C(076),C(004) TO C(109),C(313) LABEL "" PIXEL OF _oDlgPV
	@ C(3*nEspLin+2),C(004) TO C(5*nEspLin),C(353) LABEL "" PIXEL OF _oDlgPV
	
	//@ C(113),C(004) TO C(166),C(313) LABEL " Resultado da Pesagem " PIXEL OF _oDlgPV
	@ C(5*nEspLin+2),C(004) TO C(8*nEspLin),C(353) LABEL " Resultado da Pesagem " PIXEL OF _oDlgPV
	
	// Cria Componentes Padroes do Sistema
	@ C(004),C(010) Say "Quanto a Mercadoria?" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(004),C(093) Say "Seqüêncial"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(004),C(165) Say "Data Cadastro:"       Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	//@ C(004),C(239) Say "Hora Entrada:"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	@ C(010),C(010) ComboBox cComboBx1 Items aComboBx1 When (Inclui .Or. lMat_Prima)  Size C(072),C(010) PIXEL OF _oDlgPV
	@ C(010),C(093) MsGet oEdit1 Var cEdit1  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(010),C(166) MsGet oEdit2 Var cEdit2  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	//@ C(010),C(239) MsGet oEdit3 Var cEdit3  When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin := 0
	nLin += 22 //044
	
	@ C(nLin),C(010) Say "Data Agen."	Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(093) Say "Hora Agen."	Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(165) Say "Galpão"		Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	
	nLin += 6 
	@ C(nLin),C(010) MsGet oEdit23 Var cEdit23	When .F. Size C(072),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(093) MsGet oEdit24 Var cEdit24	When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(166) MsGet oEdit25 Var cEdit25	When .F. Size C(120),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin := 2*nEspLin+4 //044
	
	@ C(nLin),C(010) Say "Placa Cavalo"   	Size C(040),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(045) Say "Placa Carreta"   	Size C(040),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV	
	@ C(nLin),C(075) Say "Codigo DNIT"  	Size C(040),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV 
	@ C(nLin),C(110) Say "PB Padrão"  		Size C(040),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(172) Say "Tara"  			Size C(060),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(232) Say "Tampa"  			Size C(040),C(008) COLOR CLR_HRED PIXEL OF _oDlgPV
	@ C(nLin),C(272) Say "Total"  			Size C(040),C(008) COLOR CLR_HRED PIXEL OF _oDlgPV
	@ C(nLin),C(302) Say "Carga Liquida"	Size C(040),C(008) COLOR CLR_HRED PIXEL OF _oDlgPV
	
	nLin += 8 // 052

	@ C(nLin),C(010) MsGet oEdit4 Var cEdit4 F3 "DA3Z11" when (Inclui .Or. lAlterar .Or. lMat_Prima) Valid fPlaca() Picture "@! AAA9N99" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV //CARLOS 03/03
	@ C(nLin),C(045) MsGet oEdit6 Var cEdit6 when (Inclui .Or. lMat_Prima) Picture "@! AAA9N99" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV //CARLOS 03/03
	@ C(nLin),C(075) MsGet oEdit5  Var cEdit5 F3 "Z58" When .F. Valid fCodDnit() Picture "@!" Size C(020),C(008) COLOR CLR_BLACK  PIXEL OF _oDlgPV
	@ C(nLin),C(110) MsGet oEdit20 Var cEdit20 When .F. Picture "@E 999,999,999.99" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV		
	@ C(nLin),C(172) MsGet oEdit22 Var cEdit22 When Inclui .Or. lAlterar Picture "@E 999,999,999.99" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV		
	@ C(nLin),C(232) MsGet oEdit30 Var cEdit30 When .F. Picture "@E 999,999,999.99" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV		
	@ C(nLin),C(272) MsGet oEdit31 Var cEdit31 When .F. Picture "@E 999,999,999.99" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV		
	@ C(nLin),C(302) MsGet oEdit32 Var cEdit32 When .F. Picture "@E 999,999,999.99" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV		
	
	
	nLin := 3*nEspLin+4
	
	@ C(nLin),C(010) Say "Motorista"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin += 8

	lEdit := .T.
	
	If tpTela != _INCLUI .And. tpTela != _ALTERAR
		
		If !lSaida .And. lVisual
			lEdit := .F.
		EndIf
	
	EndIf

	@ C(nLin),C(010) MsGet oEdit21  Var cEdit21 When lEdit F3 "DA4Z11" Valid fMotor() Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(068) MsGet oEdit7  Var cEdit7  When .F. Size C(171),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV	
	

	nLin += 12 //082
	@ C(nLin),C(010) Say "Transportadora"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(269) Say "UF"                Size C(009),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV

	nLin += 8 // 091
	
	If tpTela != _INCLUI .And. tpTela != _ALTERAR
		If lSaida .and. !lVisual
			@ C(nLin),C(010) MsGet oEdit8  Var cEdit8  F3 "SA4" Valid fTransp()   Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
			@ C(nLin),C(068) MsGet oEdit17 Var cEdit17          Valid fLjTransp() Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
		Else
			@ C(nLin),C(010) MsGet oEdit8  Var cEdit8  When .F. Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
			@ C(nLin),C(068) MsGet oEdit17 Var cEdit17 When .F. Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
		EndIf
	Else
		@ C(nLin),C(010) MsGet oEdit8  Var cEdit8  F3 "SA4" Valid fTransp()   Size C(057),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		@ C(nLin),C(068) MsGet oEdit17 Var cEdit17          Valid fLjTransp() Size C(020),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf

	@ C(nLin),C(091) MsGet oEdit9  Var cEdit9  When .F.                   Size C(171),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(269) MsGet oEdit10 Var cEdit10 When .F.                   Size C(020),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		
	//nLin += 15
	//@ C(nLin),C(010) Say "Cliente"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV

	nLin += 10

	//@ C(nLin),C(010) MsGet oEdit19  Var cEdit19  When Inclui .Or. lAlterar           Size C(171),C(009) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin := 5*nEspLin + 12 //124
	
	@ C(nLin),C(010) Say "1a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(114) Say "Peso Liquido:"     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(218) Say "Peso Calc.:"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	
	nLin := 5*nEspLin + 10 
	@ C(nLin),C(048) MsGet oEdit11 Var cEdit11 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(145) MsGet oEdit13 Var cEdit13 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(247) MsGet oEdit15 Var cEdit15 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	
	nLin += 16 
	@ C(nLin),C(010) Say "Data Pes. :"	Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(114) Say "Hora Pes. :"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin -= 2 
	@ C(nLin),C(048) MsGet oEdit26 Var cEdit26	When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(145) MsGet oEdit27 Var cEdit27	When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
		
	nLin += 15 // 144
	@ C(nLin),C(048) MsGet oEdit12 Var cEdit12 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(145) MsGet oEdit14 Var cEdit14 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
    
	If tpTela != _INCLUI .And. tpTela != _ALTERAR
		If lSaida .and. !lVisual
			@ C(nLin),C(247) MsGet oEdit16 Var cEdit16 Valid(fRefPeso())  Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		ElseIf !lSaida .and. lVisual
			@ C(nLin),C(247) MsGet oEdit16 Var cEdit16 When .F. Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
		EndIf
	Else
		@ C(nLin),C(247) MsGet oEdit16 Var cEdit16 When .F. Valid(fRefPeso())   Picture "@E 999,999,999.99" Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	EndIf
	
	nLin += 3 //147
	@ C(nLin),C(010) Say "2a Pesagem:"       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(114) Say "Desvio:"           Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(214) Say "Peso Inform.:"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	
	nLin += 16 
	@ C(nLin),C(010) Say "Data Pes.:"	Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(114) Say "Hora Pes.:"    Size C(034),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin -= 2 
	@ C(nLin),C(048) MsGet oEdit28 Var cEdit28	When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(145) MsGet oEdit29 Var cEdit29	When .F. Size C(060),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	
	nLin := 8*nEspLin+4 // 173
	@ C(nLin),C(004) Say "Observação"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	nLin += 8 // 180
	@ C(nLin),C(004) MsGet oEdit18 Var cEdit18 Picture "@!"          Size C(310),C(010) COLOR CLR_BLACK PIXEL OF _oDlgPV
	
	nLin += 12
	@ C(nLin),C(004) Say "Motorista no Patio?" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
	@ C(nLin),C(048) ComboBox cCBxMotPat Items aCBxMotPat When (Inclui .Or. lMat_Prima)  Size C(072),C(010) PIXEL OF _oDlgPV
	
	nLin += 10 //200

	@ C(nLin),C(188) Button "Cancelar"       Size C(037),C(012) PIXEL OF _oDlgPV Action(_oDlgPV:End())
	
	If tpTela == _INCLUI .Or. tpTela == _ALTERAR
		@ C(nLin),C(276) Button "Confirmar"      Size C(037),C(012) PIXEL OF _oDlgPV Action(fConfir())

		If lMat_Prima
			@ C(nLin),C(232) Button "Pesar"          Size C(037),C(012) PIXEL OF _oDlgPV Action(fPesarB())
		EndIf
	Else
		If !lVisual
			@ C(nLin),C(232) Button "Pesar"          Size C(037),C(012) PIXEL OF _oDlgPV Action(fPesarB())
			@ C(nLin),C(276) Button "Confirmar"      Size C(037),C(012) PIXEL OF _oDlgPV Action(fConfir())
		EndIf
	EndIf
	
	ACTIVATE MSDIALOG _oDlgPV CENTERED
	
Return
//-----------------------------------------------------------------------------------------------------------
Static Function getVeiculo()
Local nLinLn, nColLn := 0
Local aCampos := {}

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	nLinDlg := nLin*.850
	nColDlg := nCol*.900

	nLinLn := nLinDlg*.490
	nColLn := nColDlg*.490

	aCampos := {}
	AADD(aCampos,{"CODIGO"		,"CODIGO" 		,05})
	AADD(aCampos,{"DESCRI"		,"DESCRIÇÃO" 	,50})
	AADD(aCampos,{"NUMEIXO"    	,"QTD EIXOS"   	,10})
	AADD(aCampos,{"INFO"		,"INFORMAÇÂO"	,100})
	AADD(aCampos,{"PESO_MAX"   	,"PESO MAX"		,10})
	
	If chkfile("CLV")
		dbSelectArea("CLV")
		dbCloseArea()
	EndIf

	aCampArea := {;			
				{"CODIGO"	,"C",05,0},;
				{"DESCRI"	,"C",50,2},;
				{"NUMEIXO"	,"N",10,0},;
				{"INFO"		,"C",100,0},;
				{"PESO_MAX"	,"N",10,0}}

	CLV := CriaTrab(aCampArea)
	dbUseArea(.T.,,CLV,"CLV",.t.)

	DEFINE MSDIALOG oSelDlg TITLE "Classificação dos Veículos - DNIT" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
	oBrowse2 := IW_Browse(001,001,200,300,"CLV",,,aCampos)
	oBrowse2:OBROWSE:BLDBLCLICK := {|| SelLinha() }
	AtualizaBrowse()

	ACTIVATE DIALOG oSelDlg ON INIT Eval({|| MsAguarde(), CLV->(DbGoTop()),oBrowse2:oBrowse:Refresh() }) CENTERED

Return
//-----------------------------------------------------------------------------------------------------------
Static function AtualizaBrowse()
Local cSql := ""

UpPesoMax(.F.)

While !MOD->(EOF())
	
	lPassei := .T.
	RecLock("CLV",.t.)
	CLV->CODIGO			:= MOD->CODIGO
	CLV->DESCRI 		:= MOD->DESCRI
	CLV->INFO			:= MOD->INFO
	CLV->PESO_MAX		:= MOD->PESO_MAX
	CLV->NUMEIXO		:= MOD->NUMEIXO

	MsUnlock()
	MOD->(DbSkip())
EndDo

CLV->(DbGoTop())
oBrowse2:OBROWSE:Refresh()

IF !lPassei
	MSGBOX("Não existem dados para a consulta realizada","STOP")
ENDIF
Return
//-----------------------------------------------------------------------------------------------------------
Static Function UpPesoMax(lChange)

//Selecionando todos os modelos
If chkfile("MOD")
	dbSelectArea("MOD")
	dbCloseArea()
EndIf

lPassei := .F.

cSql := " SELECT TVC_CODIGO AS CODIGO, TVC_DESCRICAO AS DESCRI, TVC_INFORMACAO_ADICIONAL AS INFO,  TVC_PESO_BRUTO_PADRAO AS PESO_MAX, TVC_NUMERO_EIXOS AS NUMEIXO
cSql += " FROM VW_CLASSE_VEICULO T

If lChange
	cSql += " WHERE TVC_CODIGO = '"+cEdit5+"'
EndIf

cSql += " ORDER BY TVC_CODIGO, TVC_PESO_BRUTO_PADRAO, TVC_DESCRICAO "

TCQUERY cSql ALIAS "MOD" NEW
MOD->(DbGoTop())

If lChange
	If !Eof()
		cEdit20 := MOD->PESO_MAX
	Else
		cEdit5	:= Space(08)
		cEdit20 := 0
		Alert('Não existe essa Classificação de Veículo no DNIT')
	EndIf
	MOD->(dbCloseArea())
EndIf

Return  
//-----------------------------------------------------------------------------------------------------------
Static Function SelLinha()
   
cEdit5 := CLV->CODIGO
cEdit20 := CLV->PESO_MAX

Close(oSelDlg)
CLV->(dbCloseArea())

Return 
//-----------------------------------------------------------------------------------------------------------
User Function AltMotPat()
Local lNoPatio 		:= IIF(Z11->Z11_MOTPAT == 'S',.T.,.F.)
Local lAuxNoPatio 	:= .F.
Local lAlteraHora	:= .F.

	lAuxNoPatio := MSGNOYES("O motorista "+AllTrim(Z11->Z11_MOTORI)+" está com o caminhão no pátio?","MOTORISTA NO PATIO")
	
	If lAuxNoPatio != lNoPatio
		
		If FieldPos('Z11_HORACH') != 0
			If !Empty(Z11->Z11_HORACH) .And. !lNoPatio
				lAlteraHora := MSGNOYES("Está registrada a entrada às "+AllTrim(Z11->Z11_HORACH)+". Gostaria de alterar a hora para a hora atual?","ALTERAR A HORA")
			Else
				lAlteraHora := lAuxNoPatio
			EndIf
		EndIf	
	
		Reclock("Z11",.F.)
		If lAlteraHora
			Z11->Z11_HORACH := Substr(Time(),1,5)	
		EndIf
		Z11->Z11_MOTPAT := IIF(lAuxNoPatio, 'S','N') 
        MsUnLock()
	EndIf  

Return
//-----------------------------------------------------------------------------------------------------------
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Marcos Alberto S       ³ Data ³18/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf

Return Int(nTam)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fTransp ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna o Nome da Transportadora e a Unidade Federativa      ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fTransp()
/*
SA2->(dbSetOrder(1))
If SA2->(dbSeek(xFilial("SA2")+cEdit8))
cEdit17 := SA2->A2_LOJA
cEdit9 := SA2->A2_NOME
cEdit10 := SA2->A2_EST
_oDlgPV:Refresh()
Else
If !Empty(cEdit8)
MsgINFO("Transportadora não cadastrada")
Return(.F.)
EndIf
cEdit8 := Space(6)
EndIf
*/

SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+cEdit8+'01'))
	cEdit17 := '01'
	cEdit9 := SA4->A4_NOME
	cEdit10 := SA4->A4_EST
	_oDlgPV:Refresh()
Else
	If !Empty(cEdit8)
		MsgINFO("Transportadora não cadastrada")
		Return(.F.)
	EndIf
	cEdit8 := Space(6)
EndIf

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fLjTransp ³ Autores ³ Marcos Alberto S     ³ Data ³19/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna o Nome da Transportadora e a Unidade Federativa      ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fLjTransp()

SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+cEdit8+cEdit17))
	cEdit9 := SA4->A4_NOME
	cEdit10 := SA4->A4_EST
	_oDlgPV:Refresh()
Else
	If !Empty(cEdit8)
		MsgINFO("Transportadora não cadastrada")
		Return(.F.)
	EndIf
	cEdit8  := Space(6)
	cEdit17 := Space(2)
EndIf

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fPesarB ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna o peso da balança e calcula o desvio                 ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fPesarB()

IF lEntrada  .OR. lMat_Prima
	// VERIFICANDO SE EXISTE ALGUMA PESAGEM EM ABERTO.
	ENTER := CHR(13)+CHR(10)
	CSQL := "SELECT SUM(QUANT) AS QUANTIDADE " + ENTER
	CSQL += "FROM " + ENTER
	CSQL += "		(SELECT COUNT(Z11_PCAVAL) AS QUANT FROM Z11010 " + ENTER
	//CSQL += "		WHERE	Z11_PCAVAL = '"+STRTRAN(   ALLTRIM(cEdit4)  ,  "-" ,  "" )+"' AND " + ENTER
	CSQL += "		WHERE	Z11_PCAVAL = '"+ALLTRIM(cEdit4)+"' AND " + ENTER	
	CSQL += "				Z11_DATAIN = '"+DTOS(DDATABASE)+"' AND " + ENTER
	CSQL += "				Z11_PESOSA = 0 AND " + ENTER
	CSQL += "				D_E_L_E_T_ = '' " + ENTER
	CSQL += "		UNION ALL " + ENTER
	CSQL += "		SELECT COUNT(Z11_PCAVAL) AS QUANT  FROM Z11050 " + ENTER
	//CSQL += "		WHERE	Z11_PCAVAL = '"+STRTRAN(   ALLTRIM(cEdit4)  ,  "-" ,  "" )+"' AND " + ENTER 
	CSQL += "		WHERE	Z11_PCAVAL = '"+ALLTRIM(cEdit4)+"' AND " + ENTER	
	CSQL += "				Z11_DATAIN = '"+DTOS(DDATABASE)+"' AND " + ENTER
	CSQL += "				Z11_PESOSA = 0 AND " + ENTER                 '
	CSQL += "				D_E_L_E_T_ = '') AS TE " + ENTER
	IF CHKFILE("_TRAB")
		DBSELECTAREA("_TRAB")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_TRAB" NEW
	IF _TRAB->QUANTIDADE >= 1
		//ALERT("EXISTE UMA PESAGEM EM ABERTO DESSA PLACA")
		//RETURN
	END IF
END IF


_peso := 0
ExecBlock("MOV795",.F.,.F.)

If cEmpAnt == "01"
	IF _peso > 80000
		MsgINFO("PESAGEM ACIMA DE 80 TONELADAS")
		RETURN
	END IF
Else
	IF _peso > 100000
		MsgINFO("PESAGEM ACIMA DE 100 TONELADAS")
		RETURN
	END IF
EndIf

If lEntrada .OR. lMat_Prima
	cEdit11 := _peso
	_oDlgPV:Refresh()
ElseIf lSaida
	cEdit12 := _peso
	cEdit13 := ABS(cEdit11 - cEdit12)
	If cEdit16 <> 0
		cEdit14 := ((cEdit13 - cEdit16)/cEdit16)*100
	ElseIf cEdit15 <> 0
		cEdit14 := ((cEdit13 - cEdit15)/cEdit15)*100
	EndIf
	_oDlgPV:Refresh()
EndIf

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fRefPeso³ Autores ³ Marcos Alberto S       ³ Data ³27/06/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Recalcula o desvio a partir da digitacao do Peso Informado   ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fRefPeso()

If lSaida
	cEdit14 := ((cEdit13 - cEdit16)/cEdit16)*100
EndIf
_oDlgPV:Refresh()

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fChkPac ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³   Verifica se Não há nenhum processo de pesagem aberto para  ³±±
±±³           ³ esta placa                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fChkPac()

cv_Chk := .F.

A0002 := " SELECT COUNT(*) CONTAD "
A0002 += "   FROM "+RetSqlName("Z11")
A0002 += "  WHERE Z11_FILIAL = '"+xFilial("Z11")+"' "
A0002 += "    AND Z11_PCAVAL = '"+cf_placa+"' "
A0002 += "    AND Z11_PESOIN <> 0 "
A0002 += "    AND Z11_PESOSA = 0 "
A0002 += "    AND D_E_L_E_T_ = ' ' "
TcQuery A0002 New Alias "A002"
dbSelectArea("A002")
dbGoTop()

If Empty(A002->CONTAD)
	//Veiculos
	DA3->(dbSetOrder(3))
	//DA3->(dbSeek(xFilial("DA3")+cEdit4,1,3)+Substr(cEdit4,4,4)) 
    DA3->(dbSeek(xFilial("DA3")+cEdit4))	
	//Motorista
	DA4->(dbSetOrder(1))
	DA4->(dbSeek(xFilial("DA4")+DA3->DA3_MOTORI))
	cEdit21 := DA4->DA4_COD
	cEdit7 := DA4->DA4_NOME
	SA4->(dbSetOrder(1))
	If SA4->(dbSeek(xFilial("SA4")+DA4->DA4_FORNEC+DA4->DA4_LOJA))
		cEdit8  := SA4->A4_COD
		cEdit17 := SA4->A4_LOJA
		cEdit9  := SA4->A4_NOME
		cEdit10 := SA4->A4_EST
	EndIf
	cv_Chk := .T.
Else
	MsgINFO("Favor verificar, pois existe pendência relacionada a esta placa....")
EndIf
A002->(dbCloseArea())

Return(cv_Chk)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fNotas  ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³    Usada para ser lancadas as notas fiscais continas na      ³±±
±±³           ³ Carga que está sendo pesada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fNotas()

Local nI
Local oDlg01
Local nUsado := 0
Local oDlgNf
Local oPCadastro
Local oPanel
Local oChkBox
Local aEdits

Private lRefresh := .T.
Private aHeader   := {}
Private aCols     := {}
Private aVetor    := {}
Private aRecnos   := {}
Private oGetDados
Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1}, {"Visualizar", "AxVisual", 0, 2},{"Incluir", "AxInclui", 0, 3},{"Alterar", "AxAltera", 0, 4},{"Excluit", "AxDeleta", 0, 5}}

A0001 := " SELECT * "
A0001 += "   FROM "+RetSqlName("Z12")
A0001 += "  WHERE Z12_FILIAL = '"+xFilial("Z12")+"' "
A0001 += "    AND Z12_PESAGE = '"+cEdit1+"' "
A0001 += "    AND D_E_L_E_T_ = ' ' "
TcQuery A0001 New Alias "A001"
dbSelectArea("A001")
dbGoTop()
While !Eof()
	If Alltrim(cComboBx1) == "Entrega"
		cd_CliFor := Posicione("SA4",1,xFilial("SA4")+A001->Z12_CLIFOR+A001->Z12_LOJA,"A4_NOME")
	Else
		cd_CliFor := Posicione("SA1",1,xFilial("SA1")+A001->Z12_CLIFOR+A001->Z12_LOJA,"A1_NOME")
	EndIf
	aAdd(aCols, {A001->Z12_SERIE,;
	A001->Z12_NFISC,;
	A001->Z12_CLIFOR,;
	A001->Z12_LOJA,;
	cd_CliFor,;
	A001->Z12_NUMCTR,;
	A001->Z12_PESLIQ,;
	.F.})
	dbSelectArea("A001")
	dbSkip()
End
A001->(dbCloseArea("A001"))

nCol := oMainWnd:nClientWidth
nLin := oMainWnd:nClientHeight

Define FONT oFont   NAME "Arial"          SIZE 0,14 BOLD
Define FONT oFont2  NAME "Lucida Console" SIZE 0,14 BOLD
CursorWait()

Define MsDialog oDlgNf TITLE "Relação de Notas Fiscais" FROM C(178),C(181) TO C(455),C(800) PIXEL
oDlgNf:lMaximized := .F.
fHeader(aHeader)

vr_Acao := 4
vr_dele := .T.
If Len(aCols) > 0 .or. lVisual
	vr_Acao := 2
	vr_dele := .F.
EndIf
aEdits := {"F1_SERIE","F1_DOC","CLIFOR","LOJA","CTR","B1_PESO"}
If nCol >= 1200
	oGetDados :=   MsGetDados():New(nLin*.030,nCol*.003,nLin*.24,nCol*.280, vr_Acao  ,         ,          ,          , vr_dele, aEdits      ,    , .F.,9999,'U_MOV797A()',             , ,          ,oDlgNf)
Else
	oGetDados :=   MsGetDados():New(nLin*.030,nCol*.003,nLin*.24,nCol*.350, vr_Acao  ,         ,          ,          , vr_dele, aEdits      ,    , .F.,9999,'U_MOV797A()',             , ,          ,oDlgNf)
EndIf

Activate MsDialog oDlgNf Centered On Init EnchoiceBar(oDlgNf, {|| ExecBlock("MOV797D",.F.,.F.), oDlgNf:End() }, {|| oDlgNf:End()}, , {{"NOTE",{|| ExecBlock("MOV797E",.F.,.F.) },"Notas"}} )

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | fHeader  | Autor | Alberto               | Data | 14.03.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Monta o Header da tela                                      |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function fHeader(aHeader)

dbSelectArea("SX3")
dbSetOrder(2)

dbSeek("F1_SERIE")
aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
dbSeek("F1_DOC")
aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
dbSeek("F1_FORNECE")
aAdd(aHeader,{"Cli/For"        ,"CLIFOR"   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo, "SA4"   ,          })
dbSeek("F1_LOJA")
aAdd(aHeader,{x3_titulo        ,"LOJA"     ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
dbSeek("A4_NOME")
aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
dbSeek("F1_DOC")
aAdd(aHeader,{"CTR"            ,"CTR"      ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
dbSeek("B1_PESO")
aAdd(aHeader,{"Peso"           ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | MOV797A  | Autor | Alberto               | Data | 19.06.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição |   Atualização informacoes no GET                            |
|          |                                                             |
+----------+------------------------------------------------------------*/
User Function MOV797A

If Alltrim(__readvar) == "M->CLIFOR"
	If Alltrim(cComboBx1) == "Entrega"
		GdFieldPut("LOJA"   , Posicione( "SA4", 1, xFilial("SA4")+M->CLIFOR                     , "A4_LOJA"), n)
		GdFieldPut("A4_NOME", Posicione( "SA4", 1, xFilial("SA4")+M->CLIFOR                     , "A4_NOME"), n)
	Else
		GdFieldPut("LOJA"   , Posicione( "SA1", 1, xFilial("SA1")+M->CLIFOR                     , "A1_LOJA"), n)
		GdFieldPut("A1_NOME", Posicione( "SA1", 1, xFilial("SA1")+M->CLIFOR                     , "A1_NOME"), n)
	EndIf
ElseIf Alltrim(__readvar) == "M->LOJA"
	If Alltrim(cComboBx1) == "Entrega"
		GdFieldPut("A4_NOME", Posicione( "SA4", 1, xFilial("SA4")+GdFieldGet("CLIFOR",n)+M->LOJA, "A4_NOME"), n)
	Else
		GdFieldPut("A1_NOME", Posicione( "SA1", 1, xFilial("SA1")+GdFieldGet("CLIFOR",n)+M->LOJA, "A1_NOME"), n)
	EndIf
EndIf

Return(.T.)

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | MOV797C  | Autor | Alberto               | Data | 27.06.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição |  Responsavel pela gravacao dos registros das Notas Fiscais  |
|          |                                                             |
+----------+------------------------------------------------------------*/
User Function MOV797D
local i
If lVisual
	Return(.T.)
EndIf

For i := 1 to Len(aCols)
	If !GdDeleted(i, aHeader, aCols)
		dbSelectArea("Z12")
		dbSetOrder(1)
		If !dbSeek(xFilial("Z12")+cEdit1+GdFieldGet("F1_DOC",i)+GdFieldGet("F1_SERIE",i)+GdFieldGet("CLIFOR",i)+GdFieldGet("LOJA",i))
			RecLock("Z12",.T.)
			Z12->Z12_FILIAL := xFilial("Z12")
			Z12->Z12_PESAGE := cEdit1
			Z12->Z12_NFISC  := GdFieldGet("F1_DOC",i)
			Z12->Z12_SERIE  := GdFieldGet("F1_SERIE",i)
			Z12->Z12_CLIFOR := GdFieldGet("CLIFOR",i)
			Z12->Z12_LOJA   := GdFieldGet("LOJA",i)
			Z12->Z12_NUMCTR := GdFieldGet("CTR",i)
			Z12->Z12_PESLIQ := GdFieldGet("B1_PESO",i)
			MsUnLock()
			cEdit15 += GdFieldGet("B1_PESO",i)
		EndIf
	Else
		dbSelectArea("Z12")
		dbSetOrder(1)
		If dbSeek(xFilial("Z12")+cEdit1+GdFieldGet("F1_DOC",i)+GdFieldGet("F1_SERIE",i)+GdFieldGet("CLIFOR",i)+GdFieldGet("LOJA",i))
			RecLock("Z12",.T.)
			DELETE
			MsUnLock()
		EndIf
	EndIf
Next k

Return(.T.)

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | MOV797E  | Autor | Alberto               | Data | 06.07.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição |   Inclui Registros no Acols das Notas Fiscais a partir do   |
|          | número da carga informada                                   |
+----------+------------------------------------------------------------*/
User Function MOV797E

/*----- Monta tela para que seja informado o numero da Carga -----*/
DEFINE MSDIALOG _oDlgm TITLE "Informe o Número da Placa" FROM 178,181 TO 275,456 PIXEL
@ 020,020 get jy_Carga     Picture "@!" Size 30,10 PIXEL OF _oDlgm
@ 019,070 Button "Ok" Size 037,012 PIXEL OF _oDlgm Action _oDlgm:End()
ACTIVATE MSDIALOG _oDlgm CENTERED

If Len(aCols) <= 1
	If Empty(aCols[1][1])
		aCols := {}
	EndIf
EndIf

A0010 := " SELECT C9_SERIENF, C9_NFISCAL, C9_CLIENTE, C9_LOJA, A1_NOME, F2_PBRUTO "
A0010 += "   FROM "+RetSqlName("SC9")+" SC9 "
A0010 += "   LEFT JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' "
A0010 += "                       AND A1_COD = C9_CLIENTE "
A0010 += "                       AND A1_LOJA = C9_LOJA "
A0010 += "                       AND SA1.D_E_L_E_T_ = ' ' "
A0010 += "  INNER JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL = '"+xFilial("SF2")+"' "
A0010 += "                       AND F2_DOC = C9_NFISCAL "
A0010 += "                       AND F2_SERIE = C9_SERIENF "
A0010 += "                       AND F2_CLIENTE = C9_CLIENTE "
A0010 += "                       AND F2_LOJA = C9_LOJA "
A0010 += "                       AND F2_YPLACA = '"+jy_Carga+"' "
A0010 += "                       AND F2_EMISSAO = '"+DTOS(Ddatabase)+"' "
A0010 += "                       AND SF2.D_E_L_E_T_ = ' ' "
A0010 += "  WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
//A0010 += "    AND C9_CARGA = '"+jy_Carga+"' "
A0010 += "    AND C9_BLEST = '10' "
A0010 += "    AND C9_BLCRED = '10' "
A0010 += "    AND SC9.D_E_L_E_T_ = ' ' "
A0010 += "  GROUP BY C9_SERIENF, C9_NFISCAL, C9_CLIENTE, C9_LOJA, A1_NOME, F2_PBRUTO "
TcQuery A0010 New Alias "A010"
dbSelectArea("A010")
dbGoTop()
While !Eof()
	aAdd(aCols, {A010->C9_SERIENF,;
	A010->C9_NFISCAL,;
	A010->C9_CLIENTE,;
	A010->C9_LOJA,;
	A010->A1_NOME,;
	"",;
	A010->F2_PBRUTO,;
	.F.})
	dbSkip()
End
dbSelectArea("A010")
dbCloseArea()

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fConfir ³ Autores ³ Marcos Alberto S       ³ Data ³19/06/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³    Esta rotina é usada para gravação da pesagem              ³±±
±±³           ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fConfir()

If lIncluir
	
	/*If Empty(AllTrim(cEdit5))
		MsgINFO("Favor informar a classificação do veículo")
		Return(.F.)
	EndIf*/
	
	// Reestabelecido obrigatoriedade em 03/07/13 por Marcos Alberto Soprani
	If Empty(cEdit4) .or. cComboBx1 == NIL .or. Empty(Alltrim(cComboBx1))
		MsgINFO("Existem campos Obrigatórios que não foram preenchido")
		Return(.F.)
	EndIf
	
	// Incluído bloqueio em 03/07/13 por Marcos Alberto Soprani para não permitir que a mesma placa seja informada sem que esta mesma placa seja dada saída
	ZP005 := " SELECT COUNT(Z11_PCAVAL) AS COUNT "
	ZP005 += " FROM " + RetSqlName("Z11")
	ZP005 += " WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	ZP005 += " AND NOT(Z11_PESOIN <> 0 AND Z11_PESOSA <> 0)
	ZP005 += " AND Z11_PCAVAL = '"+ALLTRIM(cEdit4)+"'
	ZP005 += " AND D_E_L_E_T_ = ' '

	ZPcIndex := CriaTrab(Nil, .f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP005),'ZP05',.T.,.T.)
	dbSelectArea("ZP05")
	dbGoTop()
	
	If ZP05->COUNT > 0
		
		MsgStop("A placa informada possui processos de pesagem em aberto no sistema. Favor verificar!!!")
		Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(ZPcIndex+OrdBagExt())          //indice gerado
		ZP05->(dbCloseArea())
		
		Return(.F.)
		
	EndIf
	
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado
	ZP05->(dbCloseArea())
	
ElseIf lEntrada
	
	If Empty(cEdit4) .or. Empty(cEdit11) .or. cComboBx1 == NIL .or. Empty(Alltrim(cComboBx1))
		//MsgINFO("Existem campos Obrigatórios que não foram preenchido")
		//	Return(.F.)
	EndIf
	
ElseIf lSaida
	
	If Empty(cEdit4) .or. Empty(cEdit11) .or. Empty(cEdit12)
		//MsgINFO("Existem campos Obrigatórios que não foram preenchido")
		//Return(.F.)
	EndIf
	/*
	If Alltrim(cComboBx1) == "Retirada"
	If Empty(jy_Carga)
	MsgINFO("O Número da Carga não foi informado. Favor Verificar!!!")
	Return(.F.)
	EndIf
	EndIf
	*/
	
EndIf

_oDlgPV:End()

CSQL := "SELECT ISNULL(COUNT(Z11_PCAVAL),0) AS QUANT FROM "+RETSQLNAME("Z11")+" "
//CSQL += "WHERE	Z11_PCAVAL = '"+Substr(cEdit4,1,3)+Substr(cEdit4,5,4)+"' AND "
CSQL += "WHERE	Z11_PCAVAL = '"+ALLTRIM(cEdit4)+"' AND "
CSQL += "		Z11_DATAIN = '"+DTOS(Ddatabase)+"' AND "
CSQL += "		D_E_L_E_T_ = '' AND  Z11_MERCAD = '2' "
IF CHKFILE("C_TESTE")
	DBSELECTAREA("C_TESTE")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "C_TESTE" NEW

IF lIncluir .or. lMat_Prima

	kl_NovoSeq := .T.
	ConfirmSX8()
	dbSelectArea("Z11")
	Reclock("Z11",.T.)
	Z11->Z11_FILIAL := xFilial("Z11")
	Z11->Z11_PESAGE := cEdit1
	Z11->Z11_MERCAD := IIF(Alltrim(cComboBx1) == "Entrega", 1, 2)
	//Z11->Z11_PCAVAL := Substr(cEdit4,1,3)+Substr(cEdit4,5,4) 
	Z11->Z11_PCAVAL := cEdit4
	Z11->Z11_PCARRE := Substr(cEdit6,1,3)+Substr(cEdit6,5,4)
	Z11->Z11_CODMOT := cEdit21
	Z11->Z11_MOTORI := cEdit7
	Z11->Z11_CODTRA := cEdit8
	Z11->Z11_LJTRAN := cEdit17
	Z11->Z11_OBSER  := cEdit18
	Z11->Z11_OPERIN := __cUserID
	Z11->Z11_DATAIN := dDataBase
	Z11->Z11_HORAIN := Substr(Time(),1,5)
	Z11->Z11_PESOIN := CEDIT11
	Z11->Z11_PESCAL := cEdit15
	Z11->Z11_PESINF := cEdit16
	Z11->Z11_CLVEIC := cEdit5
	Z11->Z11_PESMAX := cEdit20
	Z11->Z11_NOMCLI := cEdit19
	//Z11->Z11_SITUAC := 'C'
	Z11->Z11_TARA := cEdit22 //fRetTara(cEdit1, Substr(cEdit4,1,3)+Substr(cEdit4,5,4), IIF(Alltrim(cComboBx1) == "Entrega", 1, 2))
	Z11->Z11_DATACA := dDataBase
	
	If Alltrim(cComboBx1) == "Entrega"
		Z11->Z11_SEQB := ""
	Else
		Z11->Z11_SEQB := LTRIM(STR(IIF(C_TESTE->QUANT=0,1,C_TESTE->QUANT + 1)))
	EndIf
	
	//Z11->Z11_MOTPAT := IIF(cCBxMotPat == 'Sim','S','N' )
	Z11->Z11_MOTPAT := IIF(cCBxMotPat == 'S','Sim','Não' )
	
	If cCBxMotPat == 'Sim'
		If FieldPos('Z11_HORACH') != 0
			Z11->Z11_HORACH := cEdit3
		EndIf	
	EndIf
	
	MsUnLock()
ElseIf lAlterar

	Reclock("Z11",.F.)
	Z11->Z11_CODMOT := cEdit21
	Z11->Z11_MOTORI := cEdit7
	Z11->Z11_CODTRA := cEdit8
	Z11->Z11_LJTRAN := cEdit17
	Z11->Z11_OBSER  := cEdit18
	Z11->Z11_CLVEIC := cEdit5
	Z11->Z11_PESMAX := cEdit20
	Z11->Z11_NOMCLI := cEdit19
	Z11->Z11_TARA := cEdit22
	MsUnLock()
	
ElseIf lEntrada
	
	kl_NovoSeq := .T.
	ConfirmSX8()
	dbSelectArea("Z11")
	Reclock("Z11",.F.)
	Z11->Z11_FILIAL := xFilial("Z11")
	Z11->Z11_PESAGE := cEdit1
	//Z11->Z11_MERCAD := IIF(Alltrim(cComboBx1) == "Entrega", 1, 2)
	//Z11->Z11_PCAVAL := Substr(cEdit4,1,3)+Substr(cEdit4,5,4)
	Z11->Z11_PCAVAL := cEdit4
	Z11->Z11_PCARRE := Substr(cEdit6,1,3)+Substr(cEdit6,5,4)
	Z11->Z11_CODMOT := cEdit21
	Z11->Z11_MOTORI := cEdit7
	Z11->Z11_CODTRA := cEdit8
	Z11->Z11_LJTRAN := cEdit17
	Z11->Z11_OBSER  := cEdit18
	Z11->Z11_OPERIN := __cUserID
	
	Z11->Z11_DATAIN := dDataBase
	Z11->Z11_HORAIN := Substr(Time(),1,5)
	
	//Z11->Z11_DATAPI := dDataBase
	//Z11->Z11_HORAPI := Substr(Time(),1,5)
	
	Z11->Z11_PESOIN := cEdit11
	Z11->Z11_PESCAL := cEdit15
	Z11->Z11_PESINF := cEdit16
	Z11->Z11_CLVEIC := cEdit5
	Z11->Z11_PESMAX := cEdit20
	Z11->Z11_NOMCLI := cEdit19
	Z11->Z11_TARA := cEdit22
	
	/*
	If Z11->Z11_TARA == 0
		Z11->Z11_TARA := fRetTara(cEdit1, Substr(cEdit4,1,3)+Substr(cEdit4,5,4), IIF(Alltrim(cComboBx1) == "Entrega", 1, 2))
	EndIf */	

	//IF Alltrim(cComboBx1) == "Entrega"
	//Z11->Z11_SEQB := ""
	//ELSE
	//Z11->Z11_SEQB := LTRIM(STR(IIF(C_TESTE->QUANT=0,1,C_TESTE->QUANT + 1)))
	//END IF
	MsUnLock()
	
ElseIf lSaida
	
	
	dbSelectArea("Z11")
	dbSetOrder(1)
	If dbSeek(xFilial("Z11")+cEdit1)
		Reclock("Z11",.F.)
		Z11->Z11_FILIAL := xFilial("Z11")
		Z11->Z11_CODTRA := cEdit8
		Z11->Z11_LJTRAN := cEdit17
		Z11->Z11_OBSER  := cEdit18
		Z11->Z11_OPERSA := __cUserID
		Z11->Z11_DATASA := dDataBase
		Z11->Z11_HORASA := Substr(Time(),1,5)
		Z11->Z11_PESOSA := cEdit12
		Z11->Z11_PESLIQ := cEdit13
		Z11->Z11_DESVIO := cEdit14
		Z11->Z11_PESCAL := cEdit15
		Z11->Z11_PESINF := cEdit16
		MsUnLock()
	EndIf
	dbSelectArea("Z11")
	//ExecBlock("MOV580",.F.,.F.)
	ExecBlock("GERA_TICK",.F.,.F.)
		
		
EndIf

Return


Static Function fPlaca()
Local lRet := .F.

	If !lMat_Prima
	
		DbSelectArea("DA3")
		DA3->(dbSetOrder(3))
		If DA3->(dbSeek(xFilial("DA3")+cEdit4))
			
			lRet := .T.
	
			cEdit6 := DA3->DA3_YCARRE	
			cEdit5 := DA3->DA3_YDNIT
			cEdit20 := DA3->DA3_CAPACN
			cEdit22 := DA3->DA3_TARA
			cEdit21 := DA3->DA3_MOTORI
			cEdit7 := Posicione("DA4", 1, xFilial("DA4") + DA3->DA3_MOTORI, "DA4_NOME")
			cEdit8 := DA3->DA3_YTRANS
			cEdit17 := "01"
			cEdit9 := Posicione("SA4",1, xFilial("SA4") + DA3->DA3_YTRANS, "A4_NOME")
			cEdit10 := Posicione("SA4",1, xFilial("SA4") + DA3->DA3_YTRANS, "A4_EST")
		
			cEdit30 := DA3->DA3_YPSAD
			cEdit31 := cEdit22 + cEdit30
			cEdit32 := cEdit20 - cEdit31
	
		Else
			MsgINFO("Placa não localizada")
		EndIf
  
  Else
  	lRet := .T.
	EndIf
	
Return(lRet)


Static Function fCodDnit()
Local lRet := .F.

	DbSelectArea("Z58")
	Z58->(dbSetOrder(1))
	If Z58->(dbSeek(xFilial("Z58")+cEdit5))
		
		lRet := .T.

		cEdit20 := Z58->Z58_PESMAX
	
	Else
		MsgINFO("Código Dnit não localizado")
	EndIf

Return(lRet)


Static Function fMotor()
Local lRet := .T.

	DbSelectArea("DA4")
	DA4->(dbSetOrder(1))
	If DA4->(dbSeek(xFilial("DA4")+cEdit21))
		cEdit7 := DA4->DA4_NOME
		_oDlgPV:Refresh()
	Else
		If !Empty(cEdit21)
			MsgINFO("Motorista não localizado")
			lRet := .F.
		EndIf
		cEdit21 := Space(6)
	EndIf

Return(lRet)


Static Function fRetTara(cPesagem, cPlaca, nTipo)
Local nRet := 0
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cZ11 := RetSQLName("Z11")
Local nQtdPes := SuperGetMv("MV_QTDPES", .T., "10") // Quantidade de pesagens para calculo da tara media

	cSQL := " SELECT ISNULL(AVG(Z11_PESOIN),0) TARA "
	cSQL += " FROM ( "	
	cSQL += " 	SELECT TOP "+ nQtdPes +" Z11_PESOIN "
	cSQL += " 	FROM " + cZ11
	cSQL += " 	WHERE Z11_PESAGE <> " + ValToSQL(cPesagem)
	cSQL += " 	AND Z11_PCAVAL = " + ValToSQL(cPlaca)
	cSQL += " 	AND Z11_PESOIN > 0 "
	cSQL += " 	AND Z11_MERCAD = " + ValToSQL(nTipo)
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) AS Z11 "

	TcQuery cSQL New Alias (cQry)
					
	nRet := (cQry)->TARA
	
	(cQry)->(DbCloseArea())
	
	RestArea(aArea)

Return(nRet)