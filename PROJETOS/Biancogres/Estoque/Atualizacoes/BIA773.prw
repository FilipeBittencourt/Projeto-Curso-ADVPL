#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA773
@author Marcos Alberto Soprani
@since 16/03/17
@version 1.0
@description Cockpit Simulador para Solicitar Compras
@type function
/*/

User Function BIA773()

	Local aArea         := GetArea()
	Private smEnter     := Chr(13) + Chr(10)

	// Descritivo da Method MsAdvSize
	//   1 -> Linha inicial área trabalho.
	//   2 -> Coluna inicial área trabalho.
	//   3 -> Linha final área trabalho.
	//   4 -> Coluna final área trabalho.
	//   5 -> Coluna final dialog (janela).
	//   6 -> Linha final dialog (janela).
	//   7 -> Linha inicial dialog (janela).

	lEnch := .F.

	Private aSize := MsAdvSize(lEnch)

	/*-------------------------------------------------------------------------+
	|Passo parametros para calculo da resolucao da tela                        |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	// Quantos mais objetos, mais o Method MsObjSize Trabalha para subdividir
	//                 | Fracionamento Horizontal
	//                      | Fracionamento Vertical

	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	// Descritivo da Method MsObjSize
	//   Parte 1:
	//     1 - Linha inicial
	//     2 - Coluna Inicial
	//     3 - Linha Final
	//     4 - Coluna Final
	//     5 - Separação X
	//     6 - Separação Y
	//     7 - Separação X da borda (Opcional)
	//     8 - Separação Y da borda (Opcional)
	//   Parte 2:
	//     1 - Tamanho X  - Indica o tamanho do objeto na dimensão X (horizontal).
	//     2 - Tamanho Y  - Indica o tamanho do objeto na dimensão Y (vertical).
	//     3 - Dimensiona X ( Lógico ) - Indica se o tamanho do objeto deve ser modificado na dimensão X. Em alguns casos, não é desejável alterar a largura de um objeto. Exemplo: imagem.
	//     4 - Dimensiona Y ( Lógico ) - Indica se o tamanho do objeto deve ser modificado na dimensão Y. Em alguns casos, não é desejável alterar a altura de um objeto. Exemplo: linha contendo texto fixo ou objeto de altura fixa (folder de totalizadores da rotina MATA103 – documento de entrada – parte inferior)
	//     5 - Retorna dimensões X e Y ao invés de linha / coluna final (Lógico) - Algumas classes de objetos do Protheus recebem parâmetros de dimensões X e Y ao invés da linha / coluna inicial / final. Neste caso o parâmetro deve ser passado como .T. . Exemplo de classe que recebe X e Y -> MSPANEL		
	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )
	//   Retorno: Vetor
	//     1 - Linha inicial 
	//     2 - Coluna inicial 
	//     3 - Linha final
	//     4 - Coluna final Ou caso seja passado o elemento 5 de cada definicao de objetos como .t. o retorno será:                      
	//        1 -> Tamanho da dimensao X          
	//        2 -> Tamanho da dimensao Y    

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos2                                         |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Área libre disponível para outro objeto
	aSize2 := aClone( aPosObj1[2] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos3                                         |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	AAdd( aObjects, { 100, 250, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Área libre disponível para outro objeto
	aSize3 := aClone( aPosObj2[1] )
	aInfo3   := { aSize3[2], aSize3[1], aSize3[4], aSize3[3], 3, 3 }
	aPosObj3 := MsObjSize( aInfo3, aObjects, .T. )

	Private cCadastro 	:= "Cockpit Simulador para Solicitar Compras"
	Private aRotina 	:= { {"Pesquisar"           ,"AxPesqui"     ,0,1},;
	{                         "Visualizar"          ,"U_BIAFG007"   ,0,2},;
	{                         "0-Cockpit"           ,"U_B773CPT"    ,0,3},;
	{                         "1-ConsumoMed."       ,"U_BIAFG070"   ,0,4},;
	{                         "2-PrazoEntrega"      ,"U_B773PZG"    ,0,5},;
	{                         "3-EstoqueSegur"      ,"U_B773ETS"    ,0,6},;
	{                         "4-PontoPedido"       ,"U_B773PPD"    ,0,7},;
	{                         "5-Log. Proc"         ,"U_B773LPC"    ,0,8},;
	{                         "6-Rel. Polít. 8"     ,"U_BIAFG135"    ,0,9} }

	dbSelectArea("Z08")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"Z08",,,,,,)

	RestArea( aArea )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773CPT  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 16/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cockpit Simulador para Solicitar Compras                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773CPT()

	Private oDlgCockSim
	Private oBt1CockSim
	Private oBt2CockSim
	Private oBt3CockSim
	Private oFt1CockSim := TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)
	Private oGp1CockSim
	Private oSy1CockSim
	Private cSy1DescPrd := Space(250)
	Private elFirst     := .T.
	Private elxFirst    := .T.

	Private fh_Esc      := .F.
	Private cj_Fecha    := .T.

	Static oMsNGDCockSim
	Static oDtNGDCockSim
	Static oCmNGDCockSim

	fPerg := "BIA773"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	DEFINE MSDIALOG oDlgCockSim TITLE "Cockpit Simulador" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	// Painel 1
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGp1CockSim TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "..." OF oDlgCockSim COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (1)",,{|| fMsNGDCockSim() })	

	// Painel 2
	@ aPosObj1[2][1], aPosObj1[2][2] GROUP oGp1CockSim TO aPosObj1[2][3], aPosObj1[2][4] PROMPT "..." OF oDlgCockSim COLOR 0, 16777215 PIXEL

	// Painel 2.1
	@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGp1CockSim TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "..." OF oDlgCockSim COLOR 0, 16777215 PIXEL
	// Painel 2.1.1

	U_BIAMsgRun("Aguarde... Carregando dados (2)",,{|| fDtNGDCockSim() })
	// Painel 2.1.2
	U_BIAMsgRun("Aguarde... Carregando dados (3)",,{|| fCmNGDCockSim() })

	// Painel 2.2
	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGp1CockSim TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "3.." OF oDlgCockSim COLOR 0, 16777215 PIXEL

	// Painel 3
	@ aPosObj1[3][1], aPosObj1[3][2] GROUP oGp1CockSim TO aPosObj1[3][3], aPosObj1[3][4] PROMPT "..." OF oDlgCockSim COLOR 0, 16777215 PIXEL
	@ aPosObj1[3][1]+10, aPosObj1[3][2]+05 SAY oSy1CockSim PROMPT cSy1DescPrd SIZE 446, 011 OF oDlgCockSim FONT oFt1CockSim COLORS 0, 16777215 PIXEL

	@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar" SIZE 037, 012 OF oDlgCockSim ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgCockSim:End()) PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-080 BUTTON oBt2CockSim PROMPT "Gravar"   SIZE 037, 012 OF oDlgCockSim ACTION Processa({|| xfGrvLogSC() }) PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-120 BUTTON oBt3CockSim PROMPT "E-Mail"   SIZE 037, 012 OF oDlgCockSim ACTION Processa({|| xfEnvMailC() }) PIXEL

	ACTIVATE MSDIALOG oDlgCockSim CENTERED VALID fh_Esc

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ fMsNGDCockSim ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 16/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMsNGDCockSim()

	Local aHeaderEx    := {}
	Local aColsEx      := {}
	//                      1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17       18       19		20			21		22			23		24
	Local aFields      := {"PRODUT", "DESCRI", "TPPROD", "POLITC", "LOCAL", "UMPROD", "PRZENT", "ESTSEG", "ESTMIN", "PRVSOL", "GERSOL", "CNFSOL","STATSC", "CONSUM", "SALEST", "LOTECO", "QTDSOL", "QTDPDC", "OBSSC", "GPPROD", "LOCFIS", "CDMARC", "DSMARC", "PARTN"}
	Local aAlterFields := {"GERSOL", "CNFSOL", "LOTECO", "OBSSC","STATSC","CDMARC"}
	Local _nI
	Local _cInLocal	:=	""
	Private xDspClico  := 30

	For _nI	:=	1 to Len(MV_PAR07) STEP 2
		If Substr(MV_PAR07,_nI,2) <> '**'
			_cInLocal +=	"'" + Substr(MV_PAR07,_nI,2) + "',"
		EndIf
	Next
	If !Empty(_cInLocal)
		_cInLocal	:=	"(" + Substr(_cInLocal,1,Len(_cInLocal)-1) + ")"
	End

	aAdd(aHeaderEx,{"Prod"         ,"PRODUT" ,"@!"               , 15   , 0,,, "C",, })      // 1
	aAdd(aHeaderEx,{"Descr"        ,"DESCRI" ,"@!"               , 50   , 0,,, "C",, })      // 2
	aAdd(aHeaderEx,{"Tipo"         ,"TPPROD" ,"@!"               , 02   , 0,,, "C",, })      // 3
	aAdd(aHeaderEx,{"Pol"          ,"POLITC" ,"@!"               , 01   , 0,,, "C",, })      // 4
	aAdd(aHeaderEx,{"Almoxarifado" ,"LOCAL"  ,"@!"               , 02   , 0,,, "C",, })      // 5
	aAdd(aHeaderEx,{"UM"           ,"UMPROD" ,"@!"               , 02   , 0,,, "C",, })      // 6
	aAdd(aHeaderEx,{"Prz Ent"      ,"PRZENT" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 7
	aAdd(aHeaderEx,{"Est Seg"      ,"ESTSEG" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 8
	aAdd(aHeaderEx,{"Ponto Ped"    ,"ESTMIN" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 9
	aAdd(aHeaderEx,{"Qtd Sugerida" ,"PRVSOL" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 10
	aAdd(aHeaderEx,{"Gera SC"      ,"GERSOL" ,"@!"               , 01   , 0,,, "C",, })      // 11
	aAdd(aHeaderEx,{"Cnf SC"       ,"CNFSOL" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 12
	aAdd(aHeaderEx,{"Status SC"    ,"STATSC" ,"@!"				 , 01   , 0,,, "C",,,"N=Normal;U=Urgente;E=Emergencia;P=Parada" })      // 13
	aAdd(aHeaderEx,{"Consumo"      ,"CONSUM" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 14
	aAdd(aHeaderEx,{"Sal Est"      ,"SALEST" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 15
	aAdd(aHeaderEx,{"Lt.Econ"      ,"LOTECO" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 16
	aAdd(aHeaderEx,{"Qtd SC"       ,"QTDSOL" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 17
	aAdd(aHeaderEx,{"Qtd PC"       ,"QTDPDC" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      // 18
	aAdd(aHeaderEx,{"Obs SC"       ,"OBSSC"  ,"@S50"             ,250   , 0,,, "C",, })      // 19
	aAdd(aHeaderEx,{"Local"        ,"LOCFIS" ,"@!"               , 10   , 0,,, "C",, })      // 20
	aAdd(aHeaderEx,{"Grp"          ,"GPPROD" ,"@!"               , 04   , 0,,, "C",, })      // 21
	aAdd(aHeaderEx,{"Marca"        ,"CDMARC" ,"@!"               , 03   , 0,,, "C","ZD6CPT", })      // 22
	aAdd(aHeaderEx,{"Ds. Marca"    ,"DSMARC" ,"@!"               , 30   , 0,,, "C",, })      // 23
	aAdd(aHeaderEx,{"Part Number"  ,"PARTN" ,"@!"                , 30   , 0,,, "C",, })      // 24

	EL007 := Alltrim(" WITH BASEREF AS (SELECT ZCN_COD PRODUTO,                                                                                                                          ") + smEnter
	EL007 += Alltrim("                         SUBSTRING(B1_DESC,1,75) PDESCR,                                                                                                           ") + smEnter
	EL007 += Alltrim("                         B1_TIPO TIPOPROD,                                                                                                                         ") + smEnter
	EL007 += Alltrim("                         B1_GRUPO PGRUPO,                                                                                                                          ") + smEnter
	EL007 += Alltrim("                         B1_UM UM,                                                                                                                                 ") + smEnter
	EL007 += Alltrim("                         ZCN_LOCAL LOCAL,                                                                                                                          ") + smEnter
	EL007 += Alltrim("                         ZCN_LOCALI,                                                                                                                               ") + smEnter
	EL007 += Alltrim("                         ZCN_POLIT POLITICA,                                                                                                                       ") + smEnter
	EL007 += Alltrim("                         ZCN_ESTSEG,                                                                                                                               ") + smEnter
	EL007 += Alltrim("                         ZCN_PE,                                                                                                                                   ") + smEnter
	EL007 += Alltrim("                         SUBSTRING(ZCP_MES,5,2) MES,                                                                                                               ") + smEnter
	EL007 += Alltrim("                         CASE                                                                                                                                      ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '01' THEN ROUND(( ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '02' THEN ROUND(( ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '03' THEN ROUND(( ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '04' THEN ROUND(( ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '05' THEN ROUND(( ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '06' THEN ROUND(( ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '07' THEN ROUND(( ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '08' THEN ROUND(( ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '09' THEN ROUND(( ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '10' THEN ROUND(( ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '11' THEN ROUND(( ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                           WHEN SUBSTRING(ZCP_MES,5,2) = '12' THEN ROUND(( ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07) / 6 / 30, 2)                           ") + smEnter
	EL007 += Alltrim("                         END ZCP_CONSUMO,                                                                                                                          ") + smEnter
	EL007 += Alltrim("                         ZCN_PONPED,                                                                                                                               ") + smEnter
	EL007 += Alltrim("                         ZCN_LE                                                                                                                                    ") + smEnter
	EL007 += Alltrim("                    FROM " + RetSqlName("ZCN") + " ZCN WITH (NOLOCK)                                                                                               ") + smEnter
	EL007 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                                  ") + smEnter
	EL007 += Alltrim("                                                      AND B1_COD = ZCN_COD                                                                                         ") + smEnter
	EL007 += Alltrim("                                                      AND B1_MSBLQL <> '1'                                                                                         ") + smEnter
	If MV_PAR04 == 1
		EL007 += Alltrim("                                                      AND B1_IMPORT = 'S'	                                                                                     ") + smEnter
	Else
		EL007 += Alltrim("                                                      AND B1_IMPORT <> 'S'	                                                                                 ") + smEnter
	EndIf
	If MV_PAR08 == 1
		EL007 += Alltrim("                                                      AND B1_YPDM <> ''	                                                                                     ") + smEnter
	ElseIf MV_PAR08 == 2
		EL007 += Alltrim("                                                      AND B1_YPDM = ''	                                                                                     ") + smEnter
	EndIf
	EL007 += Alltrim("                                                      AND SB1.D_E_L_E_T_ = ' '                                                                                     ") + smEnter
	EL007 += Alltrim("                                                      AND ZCN.D_E_L_E_T_ = ' '                                                                                     ") + smEnter
	EL007 += Alltrim("                    LEFT JOIN " + RetSqlName("ZCP") + " ZCP WITH (NOLOCK) ON ZCP_FILIAL = '" + xFilial("ZCP") + "'                                                 ") + smEnter
	EL007 += Alltrim("                                                      AND ZCP_COD = ZCN_COD                                                                                        ") + smEnter
	EL007 += Alltrim("                                                      AND ZCP_LOCAL = ZCN_LOCAL                                                                                    ") + smEnter
	EL007 += Alltrim("                                                      AND ZCP.D_E_L_E_T_ = ' '                                                                                     ") + smEnter
	EL007 += Alltrim("                    LEFT JOIN " + RetSqlName("SX5") + " SX5 WITH (NOLOCK) ON X5_FILIAL = '" + xFilial("SX5") + "'                                                  ") + smEnter
	EL007 += Alltrim("                                                      AND X5_TABELA = 'Y8'                                                                                         ") + smEnter
	EL007 += Alltrim("                                                      AND X5_CHAVE = ZCN_POLIT                                                                                     ") + smEnter
	EL007 += Alltrim("                                                      AND SX5.D_E_L_E_T_ = ' '                                                                                     ") + smEnter
	EL007 += Alltrim("                   WHERE ZCN_FILIAL = '" + xFilial("ZCN") + "'                                                                                                     ") + smEnter
	EL007 += Alltrim("                     AND ZCN_ATIVO <> 'N'                                                                                                                         ") + smEnter
	If !Empty(_cInLocal)
		EL007 += Alltrim("                     AND ZCN_LOCAL IN "+ _cInLocal +"                                                                                                          ") + smEnter
	EndIf
	If MV_PAR05 == 1
		EL007 += Alltrim("                     AND ZCN_YRELEV = 'S'	                                                                                                                     ") + smEnter
	ElseIf MV_PAR05 == 2
		EL007 += Alltrim("                     AND ZCN_YRELEV <> 'S'	                                                                                                                 ") + smEnter
	EndIf
	EL007 += Alltrim("                     AND ZCN.D_E_L_E_T_ = ' ')                                                                                                                     ") + smEnter
	EL007 += Alltrim(" SELECT *,                                                                                                                                                         ") + smEnter
	EL007 += Alltrim("        CASE                                                                                                                                                       ") + smEnter

	EL007 += Alltrim("          WHEN ROUND(B2_QATU + C7_SALDO + C1_SALDO - ZCN_PONPED, 0 ) < 0 AND ZCN_PE <> 0 THEN ROUND( ( '" + Alltrim(Str(xDspClico)) + "' / ZCN_PE ) * ( ZCN_PONPED ), 0 )  ") + smEnter
	EL007 += Alltrim("          WHEN ROUND(B2_QATU + C7_SALDO + C1_SALDO - ZCN_PONPED, 0 ) <= 0 AND ZCN_PE = 0 THEN ROUND( ( ZCN_PONPED ), 0 )                                                   ") + smEnter
	EL007 += Alltrim("          ELSE 0                                                                                                                                                   ") + smEnter
	EL007 += Alltrim("        END C1_QUANT                                                                                                                                               ") + smEnter
	EL007 += Alltrim("   FROM (SELECT *,                                                                                                                                                 ") + smEnter
	EL007 += Alltrim("                ISNULL((SELECT SUM(B2_QATU)                                                                                                                        ") + smEnter
	EL007 += Alltrim("                   FROM " + RetSqlName("SB2") + " WITH (NOLOCK)                                                                                                    ") + smEnter
	EL007 += Alltrim("                  WHERE B2_FILIAL = '" + xFilial("SB2") + "'                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND B2_COD = BSF.PRODUTO                                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND B2_LOCAL = BSF.LOCAL                                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND D_E_L_E_T_ = ' '),0) B2_QATU,                                                                                                              ") + smEnter
	EL007 += Alltrim("                (SELECT ISNULL(SUM(C1_QUANT - C1_QUJE), 0)                                                                                                         ") + smEnter
	EL007 += Alltrim("                   FROM " + RetSqlName("SC1") + " WITH (NOLOCK)                                                                                                    ") + smEnter
	EL007 += Alltrim("                  WHERE C1_FILIAL = '" + xFilial("SC1") + "'                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND C1_PRODUTO = BSF.PRODUTO                                                                                                                   ") + smEnter
	EL007 += Alltrim("                    AND C1_LOCAL = BSF.LOCAL                                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND C1_PEDIDO = '      '                                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND C1_RESIDUO = ' '                                                                                                                           ") + smEnter
	EL007 += Alltrim("                    AND C1_APROV NOT IN('B','R')                                                                                                                   ") + smEnter
	EL007 += Alltrim("                    AND C1_QUANT - C1_QUJE <> 0                                                                                                                    ") + smEnter
	EL007 += Alltrim("                    AND C1_YTOTEST NOT IN('T','P')                                                                                                                 ") + smEnter
	EL007 += Alltrim("                    AND D_E_L_E_T_ = ' ') C1_SALDO,                                                                                                                ") + smEnter
	EL007 += Alltrim("                (SELECT ISNULL(SUM(SC7.C7_QUANT - SC7.C7_QUJE), 0)                                                                                                 ") + smEnter
	EL007 += Alltrim("                   FROM " + RetSqlName("SC7") + " SC7 WITH (NOLOCK)                                                                                                ") + smEnter
	EL007 += Alltrim("                  WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'                                                                                                   ") + smEnter
	EL007 += Alltrim("                    AND SC7.C7_PRODUTO = BSF.PRODUTO                                                                                                               ") + smEnter
	EL007 += Alltrim("                    AND SC7.C7_LOCAL = BSF.LOCAL                                                                                                                   ") + smEnter
	EL007 += Alltrim("                    AND SC7.C7_QUANT - SC7.C7_QUJE > 0                                                                                                             ") + smEnter
	EL007 += Alltrim("                    AND SC7.C7_RESIDUO = ' '                                                                                                                       ") + smEnter
	EL007 += Alltrim("                    AND SC7.C7_YTOTEST NOT IN('T','P')                                                                                                             ") + smEnter
	EL007 += Alltrim("                    AND SC7.D_E_L_E_T_ = ' ') C7_SALDO                                                                                                             ") + smEnter
	EL007 += Alltrim("           FROM BASEREF BSF                                                                                                                                        ") + smEnter
	EL007 += Alltrim("          WHERE POLITICA = '" + MV_PAR06 + "'                                                                                                                      ") + smEnter
	EL007 += Alltrim("            AND POLITICA IN('1','8')                                                                                                                               ") + smEnter
	EL007 += Alltrim("            AND PGRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                                                                                           ") + smEnter
	EL007 += Alltrim("            ) AS TABREF                                                                                                                                            ") + smEnter
	If MV_PAR03 == 1
		EL007 += Alltrim("   WHERE ROUND( ( B2_QATU + C7_SALDO + C1_SALDO ), 0 ) < ZCN_PONPED                                                                                            ") + smEnter
	EndIf
	EL007 += Alltrim("   ORDER BY PRODUTO                                                                                                                                                ") + smEnter
	ELcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,EL007),'EL07',.F.,.T.)
	dbSelectArea("EL07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		// Calculo da Necessidade
		xptoPrvSol  := EL07->C1_QUANT
		xptoSomaInt := 0
		If (EL07->C1_QUANT/EL07->ZCN_LE) - int(EL07->C1_QUANT/EL07->ZCN_LE) > 0 
			xptoSomaInt := 1
		EndIf

		If xptoPrvSol <> 0 .and. EL07->ZCN_LE <> 0
			xptoPrvSol := IIF(EL07->C1_QUANT < EL07->ZCN_LE, EL07->ZCN_LE, (int(EL07->C1_QUANT/EL07->ZCN_LE) + xptoSomaInt) * EL07->ZCN_LE )
		EndIf

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := EL07->PRODUTO
		aColsEx[Len(aColsEx), 2] := EL07->PDESCR
		aColsEx[Len(aColsEx), 3] := EL07->TIPOPROD
		aColsEx[Len(aColsEx), 4] := EL07->POLITICA
		aColsEx[Len(aColsEx), 5] := EL07->LOCAL
		aColsEx[Len(aColsEx), 6] := EL07->UM
		aColsEx[Len(aColsEx), 7] := EL07->ZCN_PE
		aColsEx[Len(aColsEx), 8] := EL07->ZCN_ESTSEG
		aColsEx[Len(aColsEx), 9] := EL07->ZCN_PONPED
		aColsEx[Len(aColsEx),10] := EL07->C1_QUANT
		aColsEx[Len(aColsEx),11] := "N"
		aColsEx[Len(aColsEx),12] := xptoPrvSol
		aColsEx[Len(aColsEx),13] := "N"
		aColsEx[Len(aColsEx),14] := EL07->ZCP_CONSUMO
		aColsEx[Len(aColsEx),15] := EL07->B2_QATU
		aColsEx[Len(aColsEx),16] := EL07->ZCN_LE
		aColsEx[Len(aColsEx),17] := EL07->C1_SALDO
		aColsEx[Len(aColsEx),18] := EL07->C7_SALDO
		aColsEx[Len(aColsEx),19] := Space(250)
		aColsEx[Len(aColsEx),20] := EL07->ZCN_LOCALI
		aColsEx[Len(aColsEx),21] := EL07->PGRUPO
		aColsEx[Len(aColsEx),22] := SPACE(3)
		aColsEx[Len(aColsEx),23] := SPACE(30)
		aColsEx[Len(aColsEx),24] := SPACE(30)
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.
		dbSelectArea("EL07")
		dbSkip()

	End
	EL07->(dbCloseArea())
	Ferase(ELcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ELcIndex+OrdBagExt())          //indice gerado

	oMsNGDCockSim := MsNewGetDados():New( aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, 'U_B773LTE()', "", "AllwaysTrue", oDlgCockSim, aHeaderEx, aColsEx, { || xf773NavLin() } )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ fDtNGDCockSim ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 16/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fDtNGDCockSim()

	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFields      := {"TIPO", "SCPCNF", "DTREF", "QUANT", "VALOR", "QUJE", "FORNEC", "LOJA", "NOME", "OBSERV"}
	Local aAlterFields := {}

	aAdd(aHeaderEx,{"Tipo"         ,"TIPO"   ,"@!"                 , 02   , 0,,, "C",, })
	aAdd(aHeaderEx,{"ScPcNf"       ,"SCPCNF" ,"@!"                 , 09   , 0,,, "C",, })
	aAdd(aHeaderEx,{"DtRef"        ,"DTREF"  ,"@!"                 , 10   , 0,,, "C",, })
	aAdd(aHeaderEx,{"Quant"        ,"QUANT"  ,"@E 9,999,999.99"    , 12   , 2,,, "N",, })
	aAdd(aHeaderEx,{"Preço"        ,"VALOR"  ,"@E 999,999,999.99"  , 14   , 2,,, "N",, })
	aAdd(aHeaderEx,{"Quje"         ,"QUJE"   ,"@E 9,999,999.99"    , 12   , 2,,, "N",, })
	aAdd(aHeaderEx,{"Fornec"       ,"FORNEC" ,"@!"                 , 10   , 0,,, "C",, })
	aAdd(aHeaderEx,{"Loja"         ,"LOJA"   ,"@!"                 , 01   , 0,,, "C",, })
	aAdd(aHeaderEx,{"Nome"         ,"NOME"   ,"@!"                 , 50   , 0,,, "C",, })
	aAdd(aHeaderEx,{"Observacao"   ,"OBSERV" ,"@!"                 ,250   , 0,,, "C",, })

	ZU005 := " WITH DETALH AS (SELECT 'SC' TIPO,
	ZU005 += "                        C1_NUM SCPCNF,
	ZU005 += "                        C1_EMISSAO DTREF,
	ZU005 += "                        C1_QUANT QUANT,
	ZU005 += "                        0 VALOR,
	ZU005 += "                        C1_QUJE QUJE,
	ZU005 += "                        C1_FORNECE FORNEC,
	ZU005 += "                        C1_LOJA LOJA,
	ZU005 += "                        C1_YOBS OBSERV
	ZU005 += "                   FROM " + RetSqlName("SC1") + " WITH (NOLOCK)
	ZU005 += "                  WHERE C1_FILIAL = '" + xFilial("SC1") + "'
	ZU005 += "                    AND C1_PRODUTO = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][1] + "'
	ZU005 += "                    AND C1_LOCAL = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][5] + "'	
	ZU005 += "                    AND C1_PEDIDO = '      '
	ZU005 += "                    AND C1_RESIDUO = ' '
	ZU005 += "                    AND C1_APROV NOT IN('B', 'R')
	ZU005 += "                    AND C1_QUANT - C1_QUJE <> 0
	ZU005 += "                    AND D_E_L_E_T_ = ' '
	ZU005 += "                  UNION ALL
	ZU005 += "                 SELECT 'PC' TIPO,
	ZU005 += "                        C7_NUM SCPCNF,
	ZU005 += "                        C7_EMISSAO DTREF,
	ZU005 += "                        C7_QUANT QUANT,
	ZU005 += "                        C7_TOTAL VALOR,
	ZU005 += "                        C7_QUJE QUJE,
	ZU005 += "                        C7_FORNECE FORNEC,
	ZU005 += "                        C7_LOJA LOJA,
	ZU005 += "                        C7_YOBS OBSERV
	ZU005 += "                   FROM " + RetSqlName("SC7") + " WITH (NOLOCK)
	ZU005 += "                  WHERE C7_FILIAL = '" + xFilial("SC7") + "'
	ZU005 += "                    AND C7_PRODUTO = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][1] + "'
	ZU005 += "                    AND C7_LOCAL = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][5] + "'
	ZU005 += "                    AND C7_QUANT - C7_QUJE <> 0
	ZU005 += "                    AND C7_RESIDUO = ' '
	ZU005 += "                    AND C7_YTOTEST NOT IN('T','P')
	ZU005 += "                    AND D_E_L_E_T_ = ' '
	ZU005 += "                  UNION ALL
	ZU005 += "                 SELECT '' TIPO,
	ZU005 += "                        '' SCPCNF,
	ZU005 += "                        '' DTREF,
	ZU005 += "                        0 QUANT,
	ZU005 += "                        0 VALOR,
	ZU005 += "                        0 QUJE,
	ZU005 += "                        '' FORNEC,
	ZU005 += "                        '' LOJA,
	ZU005 += "                        '' OBSERV
	ZU005 += "                  UNION ALL
	ZU005 += "                 SELECT 'NF' TIPO, *
	ZU005 += "                   FROM (SELECT TOP 3
	ZU005 += "                                D1_DOC SCPCNF,
	ZU005 += "                                D1_DTDIGIT DTREF,
	ZU005 += "                                D1_QUANT QUANT,
	ZU005 += "                                D1_TOTAL VALOR,
	ZU005 += "                                0 QUJE,
	ZU005 += "                                D1_FORNECE FORNEC,
	ZU005 += "                                D1_LOJA LOJA,
	ZU005 += "                                '' OBSERV
	ZU005 += "                           FROM " + RetSqlName("SD1") + " SD1 WITH (NOLOCK)
	ZU005 += "                          INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "'
	ZU005 += "                                               AND SF4.F4_CODIGO = D1_TES                                     
	ZU005 += "                                               AND SF4.F4_ESTOQUE = 'S'                                       
	ZU005 += "                                               AND SF4.D_E_L_E_T_ = ' '                                       
	ZU005 += "                          WHERE D1_FILIAL = '" + xFilial("SD1") + "'
	ZU005 += "                            AND D1_COD = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][1] + "'
	ZU005 += "                            AND D1_LOCAL = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][5] + "'
	ZU005 += "                            AND D1_QUANT <> 0
	ZU005 += "                            AND SD1.D_E_L_E_T_ = ' '
	ZU005 += "                          ORDER BY D1_DTDIGIT DESC) AS SD1)
	ZU005 += " SELECT DTH.*,
	ZU005 += "        ISNULL(A2_NOME, '') NOME
	ZU005 += "   FROM DETALH DTH
	ZU005 += "   LEFT JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '  '
	ZU005 += "                       AND A2_COD = FORNEC
	ZU005 += "                       AND A2_LOJA = LOJA
	ZU005 += "                       AND SA2.D_E_L_E_T_ = ' '
	ZUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZU005),'ZU05',.F.,.T.)
	dbSelectArea("ZU05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := ZU05->TIPO
		aColsEx[Len(aColsEx), 2] := ZU05->SCPCNF
		aColsEx[Len(aColsEx), 3] := dtoc(stod(ZU05->DTREF))
		aColsEx[Len(aColsEx), 4] := ZU05->QUANT
		aColsEx[Len(aColsEx), 5] := ZU05->VALOR
		aColsEx[Len(aColsEx), 6] := ZU05->QUJE
		aColsEx[Len(aColsEx), 7] := ZU05->FORNEC
		aColsEx[Len(aColsEx), 8] := ZU05->LOJA
		aColsEx[Len(aColsEx), 9] := ZU05->NOME
		aColsEx[Len(aColsEx),10] := ZU05->OBSERV
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.

		dbSelectArea("ZU05")
		dbSkip()

	End
	ZU05->(dbCloseArea())
	Ferase(ZUcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZUcIndex+OrdBagExt())          //indice gerado

	If elFirst

		elFirst := .F.
		oDtNGDCockSim := MsNewGetDados():New( aPosObj3[1][1] + 5, aPosObj3[1][2], aPosObj3[1][3], aPosObj3[1][4], , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCockSim, aHeaderEx, aColsEx)

	Else

		oDtNGDCockSim:Acols := aColsEx 
		ObjectMethod(oDtNGDCockSim,"Refresh()")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ fCmNGDCockSim ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 21/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCmNGDCockSim()

	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aAlterFields := {}

	aAdd(aHeaderEx,{"Mes Ref"      ,"MESREF"  ,"@!"             , 05   , 0,,, "C",, })
	aAdd(aHeaderEx,{"M01"          ,"M00"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M01"          ,"M01"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M02"          ,"M02"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M03"          ,"M03"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M04"          ,"M04"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M05"          ,"M05"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"M06"          ,"M06"     ,"@E 999,999.99"  , 10   , 2,,, "N",, })
	aAdd(aHeaderEx,{"Consumo"      ,"CONSUMO" ,"@E 999,999.99"  , 10   , 2,,, "N",, })

	dtInCsmMes := Substr(dtos(dDataBase),1,6)+"01" 
	dtFmCsmMes := dtos(Ultimodia(dDataBase))

	VY001 := Alltrim( " SELECT SUBSTRING(ZCP_MES,5,2) MES,                                                                  " ) + smEnter
	VY001 += Alltrim( "        ISNULL((SELECT SUM(QUANT)                                                                    " ) + smEnter
	VY001 += Alltrim( "                  FROM (SELECT CASE                                                                  " ) + smEnter
	VY001 += Alltrim( "                                 WHEN D3_TM >= '500' THEN D3_QUANT                                   " ) + smEnter
	VY001 += Alltrim( "                                 ELSE D3_QUANT * (-1)                                                " ) + smEnter
	VY001 += Alltrim( "                               END QUANT                                                             " ) + smEnter
	VY001 += Alltrim( "                          FROM " + RetSqlName("SD3") + " (NOLOCK)                                    " ) + smEnter
	VY001 += Alltrim( "                         WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                  " ) + smEnter
	VY001 += Alltrim( "                           AND D3_EMISSAO BETWEEN '" + dtInCsmMes + "' AND '" + dtFmCsmMes + "'      " ) + smEnter
	VY001 += Alltrim( "                           AND D3_COD = ZCP_COD                                                      " ) + smEnter
	VY001 += Alltrim( "                           AND D3_YPARADA <> 'S'                                                     " ) + smEnter
	VY001 += Alltrim( "                           AND D3_LOCAL = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][5] + "'        " ) + smEnter
	VY001 += Alltrim( "                           AND D_E_L_E_T_ = ' ') AS TRB), 0) ZCP_Q00,                                " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q01,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q02,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q03,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q04,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q05,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q06,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q07,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q08,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q09,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q10,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q11,                                                                                     " ) + smEnter
	VY001 += Alltrim( "        ZCP_Q12                                                                                      " ) + smEnter
	VY001 += Alltrim( "   FROM " + RetSqlName("ZCP") + " WITH (NOLOCK)                                                      " ) + smEnter
	VY001 += Alltrim( "  WHERE ZCP_FILIAL = '" + xFilial("ZCP") + "'                                                        " ) + smEnter
	VY001 += Alltrim( "    AND ZCP_COD = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][1] + "'                                " ) + smEnter
	VY001 += Alltrim( "    AND ZCP_LOCAL = '" + oMsNGDCockSim:Acols[oMsNGDCockSim:NAT][5] + "'                              " ) + smEnter
	VY001 += Alltrim( "    AND D_E_L_E_T_ = ' '                                                                             " ) + smEnter
	VYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,VY001),'VY01',.F.,.T.)
	dbSelectArea("VY01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		If VY01->MES == "01"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q01, VY01->ZCP_Q12, VY01->ZCP_Q11, VY01->ZCP_Q10, VY01->ZCP_Q09, VY01->ZCP_Q08, ( (VY01->ZCP_Q01 + VY01->ZCP_Q12 + VY01->ZCP_Q11 + VY01->ZCP_Q10 + VY01->ZCP_Q09 + VY01->ZCP_Q08) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "FEV"; aHeaderEx[3][1] := "JAN"; aHeaderEx[4][1] := "DEZ"; aHeaderEx[5][1] := "NOV"; aHeaderEx[6][1] := "OUT"; aHeaderEx[7][1] := "SET"; aHeaderEx[8][1] := "AGO"
		ElseIf VY01->MES == "02"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q02, VY01->ZCP_Q01, VY01->ZCP_Q12, VY01->ZCP_Q11, VY01->ZCP_Q10, VY01->ZCP_Q09, ( (VY01->ZCP_Q02 + VY01->ZCP_Q01 + VY01->ZCP_Q12 + VY01->ZCP_Q11 + VY01->ZCP_Q10 + VY01->ZCP_Q09) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "MAR"; aHeaderEx[3][1] := "FEV"; aHeaderEx[4][1] := "JAN"; aHeaderEx[5][1] := "DEZ"; aHeaderEx[6][1] := "NOV"; aHeaderEx[7][1] := "OUT"; aHeaderEx[8][1] := "SET"
		ElseIf VY01->MES == "03"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q03, VY01->ZCP_Q02, VY01->ZCP_Q01, VY01->ZCP_Q12, VY01->ZCP_Q11, VY01->ZCP_Q10, ( (VY01->ZCP_Q03 + VY01->ZCP_Q02 + VY01->ZCP_Q01 + VY01->ZCP_Q12 + VY01->ZCP_Q11 + VY01->ZCP_Q10) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "ABR"; aHeaderEx[3][1] := "MAR"; aHeaderEx[4][1] := "FEV"; aHeaderEx[5][1] := "JAN"; aHeaderEx[6][1] := "DEZ"; aHeaderEx[7][1] := "NOV"; aHeaderEx[8][1] := "OUT"
		ElseIf VY01->MES == "04"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q04, VY01->ZCP_Q03, VY01->ZCP_Q02, VY01->ZCP_Q01, VY01->ZCP_Q12, VY01->ZCP_Q11, ( (VY01->ZCP_Q04 + VY01->ZCP_Q03 + VY01->ZCP_Q02 + VY01->ZCP_Q01 + VY01->ZCP_Q12 + VY01->ZCP_Q11) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "MAI"; aHeaderEx[3][1] := "ABR"; aHeaderEx[4][1] := "MAR"; aHeaderEx[5][1] := "FEV"; aHeaderEx[6][1] := "JAN"; aHeaderEx[7][1] := "DEZ"; aHeaderEx[8][1] := "NOV"
		ElseIf VY01->MES == "05"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q05, VY01->ZCP_Q04, VY01->ZCP_Q03, VY01->ZCP_Q02, VY01->ZCP_Q01, VY01->ZCP_Q12, ( (VY01->ZCP_Q05 + VY01->ZCP_Q04 + VY01->ZCP_Q03 + VY01->ZCP_Q02 + VY01->ZCP_Q01 + VY01->ZCP_Q12) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "JUN"; aHeaderEx[3][1] := "MAI"; aHeaderEx[4][1] := "ABR"; aHeaderEx[5][1] := "MAR"; aHeaderEx[6][1] := "FEV"; aHeaderEx[7][1] := "JAN"; aHeaderEx[8][1] := "DEZ"
		ElseIf VY01->MES == "06"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q06, VY01->ZCP_Q05, VY01->ZCP_Q04, VY01->ZCP_Q03, VY01->ZCP_Q02, VY01->ZCP_Q01, ( (VY01->ZCP_Q06 + VY01->ZCP_Q05 + VY01->ZCP_Q04 + VY01->ZCP_Q03 + VY01->ZCP_Q02 + VY01->ZCP_Q01) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "JUL"; aHeaderEx[3][1] := "JUN"; aHeaderEx[4][1] := "MAI"; aHeaderEx[5][1] := "ABR"; aHeaderEx[6][1] := "MAR"; aHeaderEx[7][1] := "FEV"; aHeaderEx[8][1] := "JAN"
		ElseIf VY01->MES == "07"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q07, VY01->ZCP_Q06, VY01->ZCP_Q05, VY01->ZCP_Q04, VY01->ZCP_Q03, VY01->ZCP_Q02, ( (VY01->ZCP_Q07 + VY01->ZCP_Q06 + VY01->ZCP_Q05 + VY01->ZCP_Q04 + VY01->ZCP_Q03 + VY01->ZCP_Q02) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "AGO"; aHeaderEx[3][1] := "JUL"; aHeaderEx[4][1] := "JUN"; aHeaderEx[5][1] := "MAI"; aHeaderEx[6][1] := "ABR"; aHeaderEx[7][1] := "MAR"; aHeaderEx[8][1] := "FEV"
		ElseIf VY01->MES == "08"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q08, VY01->ZCP_Q07, VY01->ZCP_Q06, VY01->ZCP_Q05, VY01->ZCP_Q04, VY01->ZCP_Q03, ( (VY01->ZCP_Q08 + VY01->ZCP_Q07 + VY01->ZCP_Q06 + VY01->ZCP_Q05 + VY01->ZCP_Q04 + VY01->ZCP_Q03) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "SET"; aHeaderEx[3][1] := "AGO"; aHeaderEx[4][1] := "JUL"; aHeaderEx[5][1] := "JUN"; aHeaderEx[6][1] := "MAI"; aHeaderEx[7][1] := "ABR"; aHeaderEx[8][1] := "MAR"
		ElseIf VY01->MES == "09"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q09, VY01->ZCP_Q08, VY01->ZCP_Q07, VY01->ZCP_Q06, VY01->ZCP_Q05, VY01->ZCP_Q04, ( (VY01->ZCP_Q09 + VY01->ZCP_Q08 + VY01->ZCP_Q07 + VY01->ZCP_Q06 + VY01->ZCP_Q05 + VY01->ZCP_Q04) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "OUT"; aHeaderEx[3][1] := "SET"; aHeaderEx[4][1] := "AGO"; aHeaderEx[5][1] := "JUL"; aHeaderEx[6][1] := "JUN"; aHeaderEx[7][1] := "MAI"; aHeaderEx[8][1] := "ABR"
		ElseIf VY01->MES == "10"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q10, VY01->ZCP_Q09, VY01->ZCP_Q08, VY01->ZCP_Q07, VY01->ZCP_Q06, VY01->ZCP_Q05, ( (VY01->ZCP_Q10 + VY01->ZCP_Q09 + VY01->ZCP_Q08 + VY01->ZCP_Q07 + VY01->ZCP_Q06 + VY01->ZCP_Q05) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "NOV"; aHeaderEx[3][1] := "OUT"; aHeaderEx[4][1] := "SET"; aHeaderEx[5][1] := "AGO"; aHeaderEx[6][1] := "JUL"; aHeaderEx[7][1] := "JUN"; aHeaderEx[8][1] := "MAI"
		ElseIf VY01->MES == "11"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q11, VY01->ZCP_Q10, VY01->ZCP_Q09, VY01->ZCP_Q08, VY01->ZCP_Q07, VY01->ZCP_Q06, ( (VY01->ZCP_Q11 + VY01->ZCP_Q10 + VY01->ZCP_Q09 + VY01->ZCP_Q08 + VY01->ZCP_Q07 + VY01->ZCP_Q06) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "DEZ"; aHeaderEx[3][1] := "NOV"; aHeaderEx[4][1] := "OUT"; aHeaderEx[5][1] := "SET"; aHeaderEx[6][1] := "AGO"; aHeaderEx[7][1] := "JUL"; aHeaderEx[8][1] := "JUN"
		ElseIf VY01->MES == "12"
			AADD(aColsEx, {VY01->MES, VY01->ZCP_Q00, VY01->ZCP_Q12, VY01->ZCP_Q11, VY01->ZCP_Q10, VY01->ZCP_Q09, VY01->ZCP_Q08, VY01->ZCP_Q07, ( (VY01->ZCP_Q12 + VY01->ZCP_Q11 + VY01->ZCP_Q10 + VY01->ZCP_Q09 + VY01->ZCP_Q08 + VY01->ZCP_Q07) / 6 / 30 ), .F.} )
			aHeaderEx[2][1] := "JAN"; aHeaderEx[3][1] := "DEZ"; aHeaderEx[4][1] := "NOV"; aHeaderEx[5][1] := "OUT"; aHeaderEx[6][1] := "SET"; aHeaderEx[7][1] := "AGO"; aHeaderEx[8][1] := "JUL"
		EndIf

		dbSelectArea("VY01")
		dbSkip()

	End
	VY01->(dbCloseArea())
	Ferase(VYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(VYcIndex+OrdBagExt())          //indice gerado

	If elxFirst

		elxFirst := .F.
		oCmNGDCockSim := MsNewGetDados():New( aPosObj3[2][1] , aPosObj3[2][2], aPosObj3[2][3], aPosObj3[2][4], , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCockSim, aHeaderEx, aColsEx)

	Else

		oCmNGDCockSim:Acols := aColsEx 
		ObjectMethod(oCmNGDCockSim,"Refresh()")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xf773NavLin  ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 17.03.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xf773NavLin()

	cSy1DescPrd := ""
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + oMsNGDCockSim:Acols[n][1] ))
	cSy1DescPrd := Alltrim(SB1->B1_DESC)
	oSy1CockSim:Refresh()

	fDtNGDCockSim()
	fCmNGDCockSim()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xfGrvLogSC ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 21.03.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gravação de Log e inclusão da SC                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xfGrvLogSC()

	Local   xpk
	Private dhNumProc := ""

	B773LOGPRC("0")

	pxkVetCols := oMsNGDCockSim:Acols
	pxkGrvSc   := .F.

	For xpk := 1 to Len(pxkVetCols)

		dbSelectArea("Z09")
		RecLock("Z09",.T.)
		Z09->Z09_FILIAL  := xFilial("Z09")
		Z09->Z09_NUMPRC  := dhNumProc  
		Z09->Z09_PRODUT  := pxkVetCols[xpk][1] 
		Z09->Z09_POLITI  := pxkVetCols[xpk][4]
		Z09->Z09_LOCAL	 :=	pxkVetCols[xpk][5]
		Z09->Z09_PE      := pxkVetCols[xpk][7]
		Z09->Z09_ESTSEG  := pxkVetCols[xpk][8]
		Z09->Z09_EMIN    := pxkVetCols[xpk][9]
		Z09->Z09_PRVSSC  := pxkVetCols[xpk][10]
		Z09->Z09_GERASC  := pxkVetCols[xpk][11]
		Z09->Z09_CNFSC   := pxkVetCols[xpk][12]
		Z09->Z09_STATUS	 :=	pxkVetCols[xpk][13]
		Z09->Z09_CONSUM  := pxkVetCols[xpk][14]
		Z09->Z09_QATU    := pxkVetCols[xpk][15]
		Z09->Z09_LE      := pxkVetCols[xpk][16]
		Z09->Z09_SALDSC  := pxkVetCols[xpk][17]
		Z09->Z09_SALDPC  := pxkVetCols[xpk][18]
		Z09->Z09_OBS     := pxkVetCols[xpk][19]
		Z09->Z09_LOCALI  := pxkVetCols[xpk][20]
		Z09->Z09_CODMAR  := pxkVetCols[xpk][22]
		Z09->Z09_MARCA   := pxkVetCols[xpk][23]
		Z09->Z09_REFER   := pxkVetCols[xpk][24]
		MsUnLock()

		If pxkVetCols[xpk][11] == "S"
			pxkGrvSc := .T. 
		EndIf

	Next xpk 

	If pxkGrvSc

		pxkNumSc := B773GrvSC(pxkVetCols)
		If !Empty(pxkNumSc)

			UP003 := " UPDATE " + RetSqlName("Z08") + " SET Z08_NUMSC = '" + pxkNumSc + "' "
			UP003 += "   FROM " + RetSqlName("Z08") + " "
			UP003 += "  WHERE Z08_FILIAL = '" + xFilial("Z08") + "' "
			UP003 += "    AND Z08_NUMPRC = '" + dhNumProc + "' "
			UP003 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Concluindo gravação de LOGs",,{|| TCSQLExec(UP003)})

			UP003 := " UPDATE " + RetSqlName("Z09") + " SET Z09_NUMSC = '" + pxkNumSc + "' "
			UP003 += "   FROM " + RetSqlName("Z09") + " "
			UP003 += "  WHERE Z09_FILIAL = '" + xFilial("Z09") + "' "
			UP003 += "    AND Z09_NUMPRC = '" + dhNumProc + "' "
			UP003 += "    AND Z09_GERASC = 'S' "
			UP003 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Concluindo gravação de LOGs",,{|| TCSQLExec(UP003)})

		EndIf 

	EndIf

	cj_Fecha := .F.
	fh_Esc := .T.
	oDlgCockSim:End()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ B773GRVSC  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 21.03.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gravação de Log e inclusão da SC                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function B773GrvSC(jlVetArray)

	Local jlCabec := {}
	Local jlItens := {}
	Local jlLinha := {}
	Local jlnX    := 0
	Local jlDoc   := ""
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	jlCabec := {}	
	jlItens := {}	

	jlDoc := GetSXENum("SC1","C1_NUM")		
	SC1->(dbSetOrder(1))	
	While SC1->(dbSeek(xFilial("SC1") + jlDoc))	
		ConfirmSX8()		
		jlDoc := GetSXENum("SC1", "C1_NUM")	
	End				

	aadd(jlCabec,{"C1_NUM"     , jlDoc })
	aadd(jlCabec,{"C1_SOLICIT" , UsrRetName(RetCodUsr()) })
	aadd(jlCabec,{"C1_EMISSAO" , dDataBase })
	aadd(jlCabec,{"C1_FILENT"  , cFilAnt })

	jlSeqIt := 0
	For jlnX := 1 To Len(jlVetArray)

		jlLinha := {}
		If jlVetArray[jlnX][11] == "S"

			jlSeqIt ++
			aadd(jlLinha,{"C1_ITEM"    , StrZero(jlSeqIt,len(SC1->C1_ITEM))                                    , Nil})	
			aadd(jlLinha,{"C1_PRODUTO" , jlVetArray[jlnX][1]                                                   , Nil})	
			aadd(jlLinha,{"C1_LOCAL" , jlVetArray[jlnX][5]                                                   , Nil})
			aadd(jlLinha,{"C1_YSTATUS" , "N"                                                                   , Nil})	
			aadd(jlLinha,{"C1_DATPRF"  , dDataBase + jlVetArray[jlnX][7]                                      , Nil})	
			aadd(jlLinha,{"C1_YAPLIC"  , "0"                                                                   , Nil})	
			aadd(jlLinha,{"C1_QTSEGUM" , ConvUm(jlVetArray[jlnX][1], jlVetArray[jlnX][12], 0, 2)               , Nil})	
			aadd(jlLinha,{"C1_QUANT"   , jlVetArray[jlnX][12]                                                  , Nil})	
			aadd(jlLinha,{"C1_YOBS"    , jlVetArray[jlnX][19]                                                  , Nil})	
			aadd(jlLinha,{"C1_YSTATUS" , jlVetArray[jlnX][13]                                                  , Nil})
			aadd(jlLinha,{"C1_YCODMAR" , jlVetArray[jlnX][22]                                                  , Nil})
			aadd(jlLinha,{"C1_YMARCA" , jlVetArray[jlnX][23]                                                  , Nil})
			aadd(jlLinha,{"C1_YREFER" , jlVetArray[jlnX][24]                                                  , Nil})
			aadd(jlItens,jlLinha)	

		EndIf

	Next jlnX	

	MSExecAuto({|x,y| mata110(x,y)}, jlCabec, jlItens, 3, .F., .T.)	
	If !lMsErroAuto

		MsgINFO('Solicitação de Compras número: ' + Alltrim(jlDoc) + ' incluída com sucesso!!!', 'Parabéns!!!')

	Else

		Mostraerro()
		jlDoc := Space(6)

	EndIf

Return ( jlDoc )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773PZG  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Calcula e atualiza PRAZO DE ENTREGA                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773PZG()

	Local zjMens := ""

	zjMens += 'Você está prestes a atualizar o PRAZO DE ENTREGA.' + smEnter
	zjMens += 'Abaixo detalhes do cálculo efetuado:' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 1/4/6' + smEnter
	zjMens += ' 1 -	Todos os prazos de entrega da política selecionada são zerados no início do processamento;(ZCN_PE = 0)' + smEnter
	zjMens += ' 2 -	São recuperadas todas as notas entre a data da última entrada e retrocedendo 180 dias, calculando a diferença entre as datas da solicitação e da entrada da nota;' + smEnter
	zjMens += ' 3 -	O prazo de entrega é alterado nos produtos de acordo com a média do cálculo do item ;' + smEnter
	zjMens += ' 4 -	Os demais produtos da mesma política que ao fim do processamento não tenham prazo de entrega terão o mesmo alterado para 1. (ZCN_PE = 1)' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 8' + smEnter
	zjMens += ' - Zerar o campo ZCN_P8PE conforme set de filtro;' + smEnter
	zjMens += ' - Recalcular e gravar o campo ZCN_P8PE conforme critério definido (mesmo cálculo anterior);' + smEnter
	zjMens += ' - Verificar se algum produto do set de filtro ficou sem prazo de entrega e gravar o conteúdo 1 (um).' + smEnter
	zjMens += ' ' + smEnter	

	qwContinua := Aviso('B773PZG(1)',  zjMens, {'Confirma', 'Cancela'}, 3)

	If qwContinua == 1 

		fPerg := "BIA773UP"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidUPPerg()
		If !Pergunte(fPerg,.T.)
			MsgSTOP("Processamento abortado!!!")
			Return
		EndIf

		If MV_PAR01 $ "1/4/6"

			UP001 := " UPDATE ZCN SET ZCN_PE = 0 "
			UP001 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP001 += "                                      AND SB1.B1_COD = ZCN.ZCN_COD "
			UP001 += "                                      AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP001 += "                                      AND SB1.D_E_L_E_T_ = ' ' "
			UP001 += "  WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP001 += "    AND ZCN.ZCN_POLIT = " + ValtoSql(MV_PAR01) + " "
			UP001 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Preparando base para atualização!!!",,{|| TcSqlExec(UP001) })

			//  A Data de 01/01/2016 (AND C1_EMISSAO >= '20160101') foi escolhida preferencialmente para que não trouxéssemos resultados de movimentos
			// com possíveis problema de base.
			UP002 := " WITH PRAZOENTREGA AS (SELECT D1_COD, "
			UP002 += "                              D1_LOCAL, "
			UP002 += "                              CONVERT(DATETIME, D1_DTDIGIT) D1_DTDIGIT, "
			UP002 += "                              CONVERT(DATETIME, C1_EMISSAO) C1_EMISSAO, "
			UP002 += "                              D1_PEDIDO, "
			UP002 += "                              D1_ITEMPC, "
			UP002 += "                              C7_NUMSC, "
			UP002 += "                              C7_ITEMSC, "
			UP002 += "                              D1_QUANT "
			UP002 += "                         FROM " + RetSqlName("SD1") + " SD1 "
			UP002 += "                        INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
			UP002 += "                                             AND B1_COD = D1_COD "
			UP002 += "                                             AND B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP002 += "                                             AND B1_MSBLQL <> '1' "
			UP002 += "                                             AND SB1.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
			UP002 += "                                             AND SF4.F4_CODIGO = D1_TES "
			UP002 += "                                             AND SF4.F4_ESTOQUE = 'S' "
			UP002 += "                                             AND SF4.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = '" + xFilial("SC7") + "' "
			UP002 += "                                             AND C7_NUM = D1_PEDIDO "
			UP002 += "                                             AND C7_ITEM = D1_ITEMPC "
			UP002 += "                                             AND C7_YTOTEST NOT IN('T','P') "
			UP002 += "                                             AND SC7.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SC1") + " SC1 ON C1_FILIAL = '" + xFilial("SC1") + "' "
			UP002 += "                                             AND C1_NUM = C7_NUMSC "
			UP002 += "                                             AND C1_ITEM = C7_ITEMSC "
			UP002 += "                                             AND C1_EMISSAO >= '20160101' "
			UP002 += "                                             AND C1_YTOTEST NOT IN('T','P') "
			UP002 += "                                             AND SC1.D_E_L_E_T_ = ' ' "
			UP002 += "                        WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
			UP002 += "                          AND D1_DTDIGIT BETWEEN Convert(Char(10), DATEADD(DAY, -180, ISNULL( (SELECT MAX(XD1.D1_DTDIGIT) "
			UP002 += "                                                                                                 FROM " + RetSqlName("SD1") + " XD1 "                                  
			UP002 += "                                                                                                INNER JOIN " + RetSqlName("SF4") + " XF4 ON XF4.F4_FILIAL = '" + xFilial("SF4") + "' "
			UP002 += "                                                                                                                     AND XF4.F4_CODIGO = XD1.D1_TES "          
			UP002 += "                                                                                                                     AND XF4.F4_ESTOQUE = 'S' "         
			UP002 += "                                                                                                                     AND XF4.D_E_L_E_T_ = ' ' "        
			UP002 += "                                                                                                WHERE XD1.D1_FILIAL = '" + xFilial("SD1") + "' "      
			UP002 += "                                                                                                  AND XD1.D1_COD = SD1.D1_COD "
			UP002 += "                                                                                                  AND XD1.D1_LOCAL = SD1.D1_LOCAL "
			UP002 += "                                                                                                  AND XD1.D_E_L_E_T_ = ' '), CONVERT(Char(10), GETDATE(), 112) ) ), 112) AND Convert(Char(10), GETDATE(), 112) "
			UP002 += "                          AND SD1.D_E_L_E_T_ = ' ') "
			UP002 += " UPDATE ZCN SET ZCN_PE = INTEGRA.PE "
			UP002 += "   FROM (SELECT D1_COD, "
			UP002 += "                D1_LOCAL, "
			UP002 += "                ROUND(AVG(PE),0) PE "
			UP002 += "           FROM (SELECT D1_COD, "
			UP002 += "                        D1_LOCAL, "
			UP002 += "                        DATEDIFF(dd,C1_EMISSAO,D1_DTDIGIT) PE "
			UP002 += "                   FROM PRAZOENTREGA) AS PRZENTR "
			UP002 += "          GROUP BY D1_COD, "
			UP002 += "                   D1_LOCAL ) AS INTEGRA "
			UP002 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN ON ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP002 += "                       AND ZCN.ZCN_COD = D1_COD "
			UP002 += "                       AND ZCN.ZCN_LOCAL = D1_LOCAL "
			UP002 += "                       AND ZCN.ZCN_POLIT = " + ValtoSql(MV_PAR01) + " "
			UP002 += "                       AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_PE!!!",,{|| TcSqlExec(UP002) })

			UP003 := " UPDATE ZCN SET ZCN_PE = 1 "
			UP003 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP003 += "                                      AND SB1.B1_COD = ZCN.ZCN_COD "
			UP003 += "                                      AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP003 += "                                      AND SB1.B1_MSBLQL <> '1' "
			UP003 += "                                      AND SB1.D_E_L_E_T_ = ' ' "
			UP003 += "  WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP003 += "    AND ZCN.ZCN_POLIT = " + ValtoSql(MV_PAR01) + " "
			UP003 += "    AND ZCN.ZCN_PE = 0 "
			UP003 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Completando ZCN_PE, quando prazo ZERO!!!",,{|| TcSqlExec(UP003) })

			B773LOGPRC("1")

			MsgINFO("Processamento realizado com sucesso!!!")

		ElseIf MV_PAR01 == "8"

			UP001 := " UPDATE ZCN SET ZCN_P8PE = 0 "
			UP001 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP001 += "                                      AND SB1.B1_COD = ZCN.ZCN_COD "
			UP001 += "                                      AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP001 += "                                      AND SB1.D_E_L_E_T_ = ' ' "
			UP001 += "  WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP001 += "    AND ZCN.ZCN_POLIT = '8' "
			UP001 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Preparando base para atualização!!!",,{|| TcSqlExec(UP001) })

			//  A Data de 01/01/2016 (AND C1_EMISSAO >= '20160101') foi escolhida preferencialmente para que não trouxéssemos resultados de movimentos
			// com possíveis problema de base.
			UP002 := " WITH PRAZOENTREGA AS (SELECT D1_COD, "
			UP002 += "                              D1_LOCAL, "
			UP002 += "                              CONVERT(DATETIME, D1_DTDIGIT) D1_DTDIGIT, "
			UP002 += "                              CONVERT(DATETIME, C1_EMISSAO) C1_EMISSAO, "
			UP002 += "                              D1_PEDIDO, "
			UP002 += "                              D1_ITEMPC, "
			UP002 += "                              C7_NUMSC, "
			UP002 += "                              C7_ITEMSC, "
			UP002 += "                              D1_QUANT "
			UP002 += "                         FROM " + RetSqlName("SD1") + " SD1 "
			UP002 += "                        INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
			UP002 += "                                             AND B1_COD = D1_COD "
			UP002 += "                                             AND B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP002 += "                                             AND B1_MSBLQL <> '1' "
			UP002 += "                                             AND SB1.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
			UP002 += "                                             AND SF4.F4_CODIGO = D1_TES "
			UP002 += "                                             AND SF4.F4_ESTOQUE = 'S' "
			UP002 += "                                             AND SF4.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = '" + xFilial("SC7") + "' "
			UP002 += "                                             AND C7_NUM = D1_PEDIDO "
			UP002 += "                                             AND C7_ITEM = D1_ITEMPC "
			UP002 += "                                             AND C7_YTOTEST NOT IN('T','P') "
			UP002 += "                                             AND SC7.D_E_L_E_T_ = ' ' "
			UP002 += "                        INNER JOIN " + RetSqlName("SC1") + " SC1 ON C1_FILIAL = '" + xFilial("SC1") + "' "
			UP002 += "                                             AND C1_NUM = C7_NUMSC "
			UP002 += "                                             AND C1_ITEM = C7_ITEMSC "
			UP002 += "                                             AND C1_EMISSAO >= '20160101' "
			UP002 += "                                             AND C1_YTOTEST NOT IN('T','P') "
			UP002 += "                                             AND SC1.D_E_L_E_T_ = ' ' "
			UP002 += "                        WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
			UP002 += "                          AND D1_DTDIGIT BETWEEN Convert(Char(10), DATEADD(DAY, -180, ISNULL( (SELECT MAX(XD1.D1_DTDIGIT) "
			UP002 += "                                                                                                 FROM " + RetSqlName("SD1") + " XD1 "                                  
			UP002 += "                                                                                                INNER JOIN " + RetSqlName("SF4") + " XF4 ON XF4.F4_FILIAL = '" + xFilial("SF4") + "' "
			UP002 += "                                                                                                                     AND XF4.F4_CODIGO = XD1.D1_TES "          
			UP002 += "                                                                                                                     AND XF4.F4_ESTOQUE = 'S' "         
			UP002 += "                                                                                                                     AND XF4.D_E_L_E_T_ = ' ' "        
			UP002 += "                                                                                                WHERE XD1.D1_FILIAL = '" + xFilial("SD1") + "' "      
			UP002 += "                                                                                                  AND XD1.D1_COD = SD1.D1_COD "
			UP002 += "                                                                                                  AND XD1.D1_LOCAL = SD1.D1_LOCAL "
			UP002 += "                                                                                                  AND XD1.D_E_L_E_T_ = ' '), CONVERT(Char(10), GETDATE(), 112) ) ), 112) AND Convert(Char(10), GETDATE(), 112) "
			UP002 += "                          AND SD1.D_E_L_E_T_ = ' ') "
			UP002 += " UPDATE ZCN SET ZCN_P8PE = INTEGRA.PE "
			UP002 += "   FROM (SELECT D1_COD, "
			UP002 += "                D1_LOCAL, "
			UP002 += "                ROUND(AVG(PE),0) PE "
			UP002 += "           FROM (SELECT D1_COD, "
			UP002 += "                        D1_LOCAL, "
			UP002 += "                        DATEDIFF(dd,C1_EMISSAO,D1_DTDIGIT) PE "
			UP002 += "                   FROM PRAZOENTREGA) AS PRZENTR "
			UP002 += "          GROUP BY D1_COD, "
			UP002 += "                   D1_LOCAL ) AS INTEGRA "
			UP002 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN ON ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP002 += "                       AND ZCN.ZCN_COD = D1_COD "
			UP002 += "                       AND ZCN.ZCN_LOCAL = D1_LOCAL "
			UP002 += "                       AND ZCN.ZCN_POLIT = '8' "
			UP002 += "                       AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_P8PE!!!",,{|| TcSqlExec(UP002) })

			UP003 := " UPDATE ZCN SET ZCN_P8PE = 1 "
			UP003 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP003 += "                                      AND SB1.B1_COD = ZCN.ZCN_COD "
			UP003 += "                                      AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP003 += "                                      AND SB1.B1_MSBLQL <> '1' "
			UP003 += "                                      AND SB1.D_E_L_E_T_ = ' ' "
			UP003 += "  WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP003 += "    AND ZCN.ZCN_POLIT = '8' "
			UP003 += "    AND ZCN.ZCN_P8PE = 0 "
			UP003 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Completando ZCN_P8PE, quando prazo ZERO!!!",,{|| TcSqlExec(UP003) })

			B773LOGPRC("1")

			MsgINFO("Processamento realizado com sucesso!!!")


		Else

			Aviso('B773PZG(2)', "Não existe regra definida para atualização do PRAZO DE ENTREGA para a política selecionada. Favor verificar!!!", {'Ok'}, 3)

		EndIf

	Else

		MsgSTOP("Processamento abortado!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773ETS  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Calcula e atualiza ESTOQUE DE SEGURANÇA                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773ETS()

	Local zjMens := ""

	zjMens += 'Você está prestes a atualizar o ESTOQUE DE SEGURANÇA.' + smEnter
	zjMens += 'Abaixo detalhes do cálculo efetuado:' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 1' + smEnter
	zjMens += ' 1 -	É feito o cálculo do consumo médio diário, tendo como base o consumo dos últimos 6 meses' + smEnter
	zjMens += ' 2 -	O consumo médio diário é multiplicado pelo prazo de entrega e dividido por 2;' + smEnter
	zjMens += ' 3 -	Se este valor for superior a 1, este será o ESTOQUE DE SEGURANÇA;(ZCN_ESTSEG)' + smEnter
	zjMens += ' 4 -	Caso contrário, o ESTOQUE DE SEGURANÇA será zero;' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 8' + smEnter
	zjMens += ' - O campo ZCN_P8ESEG recebe o valor calculado conforme critério definido (mesmo cálculo anterior);' + smEnter
	zjMens += ' ' + smEnter	

	qwContinua := Aviso('B773ETS(1)',  zjMens, {'Confirma', 'Cancela'}, 3)

	If qwContinua == 1 

		fPerg := "BIA773UP"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidUPPerg()
		If !Pergunte(fPerg,.T.)
			MsgSTOP("Processamento abortado!!!")
			Return
		EndIf

		If MV_PAR01 == "1"

			// Parâmetro para tempo pravisto para GUARDA em estoque com base no ZCN_PE
			TmpEstSeg = 0.5
			// Quando ZCN_ESTSEG = ZERO, retorna este parâmetro
			QtdEstSeg = 0

			UP004 := " WITH ESTSEGNEW AS (SELECT ZCN.R_E_C_N_O_ REGZCN, "
			UP004 += "                           ZCN.ZCN_COD PRODUT, "
			UP004 += "                           RTRIM(SB1.B1_DESC) DESCR, "
			UP004 += "                           SB1.B1_UM UM, "
			UP004 += "                           ZCN.ZCN_POLIT POLITICA, "
			UP004 += "                           SX5.X5_DESCRI DPOLITICA, "
			UP004 += "                           ZCN.ZCN_ESTSEG ESTSEG, "
			UP004 += "                           ZCN.ZCN_PE PE, "
			UP004 += "                           ISNULL(SUBSTRING(ZCP.ZCP_MES,5,2),'01') MES, "
			UP004 += "                           ISNULL(CASE "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '01' THEN ROUND(( ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '02' THEN ROUND(( ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '03' THEN ROUND(( ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '04' THEN ROUND(( ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '05' THEN ROUND(( ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '06' THEN ROUND(( ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '07' THEN ROUND(( ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '08' THEN ROUND(( ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '09' THEN ROUND(( ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '10' THEN ROUND(( ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '11' THEN ROUND(( ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '12' THEN ROUND(( ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07) / 6 / 30, 2) "
			UP004 += "                                  END, 0) ZCP_CONSUMO "
			UP004 += "                      FROM " + RetSqlName("ZCN") + " ZCN(NOLOCK) "
			UP004 += "                     INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP004 += "                                                         AND SB1.B1_COD = ZCN.ZCN_COD "
			UP004 += "                                                         AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP004 += "                                                         AND SB1.B1_MSBLQL <> '1' "
			UP004 += "                                                         AND SB1.D_E_L_E_T_ = ' ' "
			UP004 += "                      LEFT JOIN " + RetSqlName("ZCP") + " ZCP(NOLOCK) ON ZCP.ZCP_FILIAL = '" + xFilial("ZCP") + "' "
			UP004 += "                                                         AND ZCP.ZCP_COD = ZCN.ZCN_COD "
			UP004 += "                                                         AND ZCP.ZCP_LOCAL = ZCN.ZCN_LOCAL "
			UP004 += "                                                         AND ZCP.D_E_L_E_T_ = ' ' "
			UP004 += "                      LEFT JOIN " + RetSqlName("SX5") + " SX5(NOLOCK) ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' "
			UP004 += "                                                         AND SX5.X5_TABELA = 'Y8' "
			UP004 += "                                                         AND SX5.X5_CHAVE = ZCN.ZCN_POLIT "
			UP004 += "                                                         AND SX5.D_E_L_E_T_ = ' ' "
			UP004 += "                     WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP004 += "                       AND ZCN.ZCN_POLIT = '1' "
			UP004 += "                       AND ZCN.D_E_L_E_T_ = ' ') "
			UP004 += " UPDATE ZCN SET "
			UP004 += "        ZCN_ESTSEG = CASE "
			UP004 += "                      WHEN ROUND(PE * " + Alltrim(Str(TmpEstSeg)) + " * ZCP_CONSUMO, 0) < 1 THEN " + Alltrim(Str(QtdEstSeg)) + " "
			UP004 += "                      ELSE ROUND(PE * " + Alltrim(Str(TmpEstSeg)) + " * ZCP_CONSUMO, 0) "
			UP004 += "                    END "
			UP004 += "   FROM ESTSEGNEW ESN "
			UP004 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN(NOLOCK) ON ZCN.R_E_C_N_O_ = ESN.REGZCN "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_ESTSEG!!!",,{|| TcSqlExec(UP004) })

			B773LOGPRC("2")

			MsgINFO("Processamento realizado com sucesso!!!")

		ElseIf MV_PAR01 == "8"

			// Parâmetro para tempo pravisto para GUARDA em estoque com base no ZCN_PE
			TmpEstSeg = 0.5
			// Quando ZCN_ESTSEG = ZERO, retorna este parâmetro
			QtdEstSeg = 0

			UP004 := " WITH ESTSEGNEW AS (SELECT ZCN.R_E_C_N_O_ REGZCN, "
			UP004 += "                           ZCN.ZCN_COD PRODUT, "
			UP004 += "                           RTRIM(SB1.B1_DESC) DESCR, "
			UP004 += "                           SB1.B1_UM UM, "
			UP004 += "                           ZCN.ZCN_POLIT POLITICA, "
			UP004 += "                           SX5.X5_DESCRI DPOLITICA, "
			UP004 += "                           ZCN.ZCN_ESTSEG ESTSEG, "
			UP004 += "                           ZCN.ZCN_P8PE PE, "
			UP004 += "                           ISNULL(SUBSTRING(ZCP.ZCP_MES,5,2),'01') MES, "
			UP004 += "                           ISNULL(CASE "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '01' THEN ROUND(( ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '02' THEN ROUND(( ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '03' THEN ROUND(( ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '04' THEN ROUND(( ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '05' THEN ROUND(( ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '06' THEN ROUND(( ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '07' THEN ROUND(( ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '08' THEN ROUND(( ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '09' THEN ROUND(( ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '10' THEN ROUND(( ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '11' THEN ROUND(( ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06) / 6 / 30, 2) "
			UP004 += "                                    WHEN SUBSTRING(ZCP_MES,5,2) = '12' THEN ROUND(( ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07) / 6 / 30, 2) "
			UP004 += "                                  END, 0) ZCP_CONSUMO "
			UP004 += "                      FROM " + RetSqlName("ZCN") + " ZCN(NOLOCK) "
			UP004 += "                     INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP004 += "                                                         AND SB1.B1_COD = ZCN.ZCN_COD "
			UP004 += "                                                         AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP004 += "                                                         AND SB1.B1_MSBLQL <> '1' "
			UP004 += "                                                         AND SB1.D_E_L_E_T_ = ' ' "
			UP004 += "                      LEFT JOIN " + RetSqlName("ZCP") + " ZCP(NOLOCK) ON ZCP.ZCP_FILIAL = '" + xFilial("ZCP") + "' "
			UP004 += "                                                         AND ZCP.ZCP_COD = ZCN.ZCN_COD "
			UP004 += "                                                         AND ZCP.ZCP_LOCAL = ZCN.ZCN_LOCAL "
			UP004 += "                                                         AND ZCP.D_E_L_E_T_ = ' ' "
			UP004 += "                      LEFT JOIN " + RetSqlName("SX5") + " SX5(NOLOCK) ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' "
			UP004 += "                                                         AND SX5.X5_TABELA = 'Y8' "
			UP004 += "                                                         AND SX5.X5_CHAVE = ZCN.ZCN_POLIT "
			UP004 += "                                                         AND SX5.D_E_L_E_T_ = ' ' "
			UP004 += "                     WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP004 += "                       AND ZCN.ZCN_POLIT = '8' "
			UP004 += "                       AND ZCN.D_E_L_E_T_ = ' ') "
			UP004 += " UPDATE ZCN SET "
			UP004 += "        ZCN_P8ESEG = CASE "
			UP004 += "                      WHEN ROUND(PE * " + Alltrim(Str(TmpEstSeg)) + " * ZCP_CONSUMO, 0) < 1 THEN " + Alltrim(Str(QtdEstSeg)) + " "
			UP004 += "                      ELSE ROUND(PE * " + Alltrim(Str(TmpEstSeg)) + " * ZCP_CONSUMO, 0) "
			UP004 += "                    END "
			UP004 += "   FROM ESTSEGNEW ESN "
			UP004 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN(NOLOCK) ON ZCN.R_E_C_N_O_ = ESN.REGZCN "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_P8ESEG!!!",,{|| TcSqlExec(UP004) })

			B773LOGPRC("2")

			MsgINFO("Processamento realizado com sucesso!!!")


		Else

			Aviso('B773ETS(2)', "Não existe regra definida para atualização do ESTOQUE DE SEGURANÇA para a política selecionada. Favor verificar!!!", {'Ok'}, 3)

		EndIf

	Else

		MsgSTOP("Processamento abortado!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773PPD  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Calcula e atualiza PONTO DE PEDIDO                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773PPD()

	Local zjMens := ""

	zjMens += 'Você está prestes a atualizar o PONTO DE PEDIDO.' + smEnter
	zjMens += 'Abaixo detalhes do cálculo efetuado:' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 1' + smEnter
	zjMens += ' 1 -	É feito o cálculo do consumo médio diário, tendo como base o consumo dos últimos 6 meses' + smEnter
	zjMens += ' 2 -	O consumo médio diário é multiplicado pelo prazo de entrega;' + smEnter
	zjMens += ' 3 -	PONTO DE PEDIDO será esse valor, somado ao estoque de segurança;(ZCN_PONPED)' + smEnter
	zjMens += ' 3 -	Caso o estoque de segurança seja zero, o PONTO DE PEDIDO será 1;' + smEnter
	zjMens += ' ' + smEnter
	zjMens += ' Política = 8' + smEnter
	zjMens += ' - O campo ZCN_P8PPED recebe o valor calculado conforme critério definido (mesmo cálculo anterior);' + smEnter
	zjMens += ' ' + smEnter	

	qwContinua := Aviso('B773PPD(1)',  zjMens, {'Confirma', 'Cancela'}, 3)

	If qwContinua == 1 

		fPerg := "BIA773UP"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidUPPerg()
		If !Pergunte(fPerg,.T.)
			MsgSTOP("Processamento abortado!!!")
			Return
		EndIf

		If MV_PAR01 == "1"

			UP005 := " WITH PONTOPEDIDO AS (SELECT ZCN.ZCN_COD, "
			UP005 += "                             RTRIM(SB1.B1_DESC) DESCR, "
			UP005 += "                             ZCN.ZCN_POLIT POLITICA, "
			UP005 += "                             SX5.X5_DESCRI DPOLITICA, "
			UP005 += "                             ISNULL(ZCP.ZCP_MES,'19800101') ULMES, "
			UP005 += "                             ZCN.ZCN_ESTSEG ESTSEG, "
			UP005 += "                             ZCN.ZCN_PE PE, "
			UP005 += "                             SB1.B1_UM UM, "
			UP005 += "                             ISNULL(SUBSTRING(ZCP.ZCP_MES,5,2),'01') MES, "
			UP005 += "                             ISNULL(CASE "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '01' THEN ROUND(( ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '02' THEN ROUND(( ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '03' THEN ROUND(( ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '04' THEN ROUND(( ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '05' THEN ROUND(( ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '06' THEN ROUND(( ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '07' THEN ROUND(( ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '08' THEN ROUND(( ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '09' THEN ROUND(( ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '10' THEN ROUND(( ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '11' THEN ROUND(( ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '12' THEN ROUND(( ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07) / 6 / 30, 2) "
			UP005 += "                                    END, 0) ZCP_CONSUMO, "
			UP005 += "                             ZCN.ZCN_PONPED EMIN, "
			UP005 += "                             ZCN.ZCN_LE LE, "
			UP005 += "                             ZCN.R_E_C_N_O_ REGZCN "
			UP005 += "                        FROM " + RetSqlName("ZCN") + " ZCN(NOLOCK) "
			UP005 += "                       INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP005 += "                                                           AND SB1.B1_COD = ZCN.ZCN_COD "
			UP005 += "                                                           AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP005 += "                                                           AND SB1.B1_MSBLQL <> '1' "
			UP005 += "                                                           AND SB1.D_E_L_E_T_ = ' ' "
			UP005 += "                        LEFT JOIN " + RetSqlName("ZCP") + " ZCP(NOLOCK) ON ZCP.ZCP_FILIAL = '" + xFilial("ZCP") + "' "
			UP005 += "                                                           AND ZCP.ZCP_COD = ZCN.ZCN_COD "
			UP005 += "                                                           AND ZCP.ZCP_LOCAL = ZCN.ZCN_LOCAL "
			UP005 += "                                                           AND ZCP.D_E_L_E_T_ = ' ' "
			UP005 += "                        LEFT JOIN " + RetSqlName("SX5") + " SX5(NOLOCK) ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' "
			UP005 += "                                                           AND SX5.X5_TABELA = 'Y8' "
			UP005 += "                                                           AND SX5.X5_CHAVE = ZCN.ZCN_POLIT "
			UP005 += "                                                           AND SX5.D_E_L_E_T_ = ' ' "
			UP005 += "                       WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP005 += "                         AND ZCN.ZCN_POLIT = '1' "
			UP005 += "                         AND ZCN.D_E_L_E_T_ = ' ') "
			UP005 += " UPDATE ZCN SET ZCN_PONPED = ROUND((ZCP_CONSUMO * PE) + ESTSEG, 0) "
			UP005 += "   FROM PONTOPEDIDO PXP "
			UP005 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN ON ZCN.R_E_C_N_O_ = PXP.REGZCN "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_PONPED(1)!!!",,{|| TcSqlExec(UP005) })

			UP007 := " UPDATE ZCN SET ZCN_PONPED = ZCN_ESTSEG + 1 "
			UP007 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = ZCN_COD "
			UP007 += "                       AND B1_MSBLQL <> '1' "
			UP007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
			UP007 += "  WHERE ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP007 += "    AND ZCN_POLIT = '1' "
			UP007 += "    AND ZCN_ESTSEG = 0 "
			UP007 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_PONPED(2)!!!",,{|| TcSqlExec(UP007) })

			B773LOGPRC("3")

			MsgINFO("Processamento realizado com sucesso!!!")

		ElseIf MV_PAR01 == "8"

			UP005 := " WITH PONTOPEDIDO AS (SELECT ZCN.ZCN_COD, "
			UP005 += "                             RTRIM(SB1.B1_DESC) DESCR, "
			UP005 += "                             ZCN.ZCN_POLIT POLITICA, "
			UP005 += "                             SX5.X5_DESCRI DPOLITICA, "
			UP005 += "                             ISNULL(ZCP.ZCP_MES,'19800101') ULMES, "
			UP005 += "                             ZCN.ZCN_P8ESEG ESTSEG, "
			UP005 += "                             ZCN.ZCN_P8PE PE, "
			UP005 += "                             SB1.B1_UM UM, "
			UP005 += "                             ISNULL(SUBSTRING(ZCP.ZCP_MES,5,2),'01') MES, "
			UP005 += "                             ISNULL(CASE "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '01' THEN ROUND(( ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '02' THEN ROUND(( ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '03' THEN ROUND(( ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11+ZCP_Q10) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '04' THEN ROUND(( ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12+ZCP_Q11) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '05' THEN ROUND(( ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01+ZCP_Q12) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '06' THEN ROUND(( ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02+ZCP_Q01) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '07' THEN ROUND(( ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03+ZCP_Q02) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '08' THEN ROUND(( ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04+ZCP_Q03) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '09' THEN ROUND(( ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05+ZCP_Q04) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '10' THEN ROUND(( ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06+ZCP_Q05) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '11' THEN ROUND(( ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07+ZCP_Q06) / 6 / 30, 2) "
			UP005 += "                                      WHEN SUBSTRING(ZCP_MES,5,2) = '12' THEN ROUND(( ZCP_Q12+ZCP_Q11+ZCP_Q10+ZCP_Q09+ZCP_Q08+ZCP_Q07) / 6 / 30, 2) "
			UP005 += "                                    END, 0) ZCP_CONSUMO, "
			UP005 += "                             ZCN.ZCN_P8PPED EMIN, "
			UP005 += "                             ZCN.ZCN_LE LE, "
			UP005 += "                             ZCN.R_E_C_N_O_ REGZCN "
			UP005 += "                        FROM " + RetSqlName("ZCN") + " ZCN(NOLOCK) "
			UP005 += "                       INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			UP005 += "                                                           AND SB1.B1_COD = ZCN.ZCN_COD "
			UP005 += "                                                           AND SB1.B1_GRUPO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
			UP005 += "                                                           AND SB1.B1_MSBLQL <> '1' "
			UP005 += "                                                           AND SB1.D_E_L_E_T_ = ' ' "
			UP005 += "                        LEFT JOIN " + RetSqlName("ZCP") + " ZCP(NOLOCK) ON ZCP.ZCP_FILIAL = '" + xFilial("ZCP") + "' "
			UP005 += "                                                           AND ZCP.ZCP_COD = ZCN.ZCN_COD "
			UP005 += "                                                           AND ZCP.ZCP_LOCAL = ZCN.ZCN_LOCAL "
			UP005 += "                                                           AND ZCP.D_E_L_E_T_ = ' ' "
			UP005 += "                        LEFT JOIN " + RetSqlName("SX5") + " SX5(NOLOCK) ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' "
			UP005 += "                                                           AND SX5.X5_TABELA = 'Y8' "
			UP005 += "                                                           AND SX5.X5_CHAVE = ZCN.ZCN_POLIT "
			UP005 += "                                                           AND SX5.D_E_L_E_T_ = ' ' "
			UP005 += "                       WHERE ZCN.ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP005 += "                         AND ZCN.ZCN_POLIT = '8' "
			UP005 += "                         AND ZCN.D_E_L_E_T_ = ' ') "
			UP005 += " UPDATE ZCN SET ZCN_P8PPED = ROUND((ZCP_CONSUMO * PE) + ESTSEG, 0) "
			UP005 += "   FROM PONTOPEDIDO PXP "
			UP005 += "  INNER JOIN " + RetSqlName("ZCN") + " ZCN ON ZCN.R_E_C_N_O_ = PXP.REGZCN "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_P8PPED(1)!!!",,{|| TcSqlExec(UP005) })

			UP007 := " UPDATE ZCN SET ZCN_P8PPED = ZCN_P8ESEG + 1 "
			UP007 += "   FROM " + RetSqlName("ZCN") + " ZCN "
			UP007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = ZCN_COD "
			UP007 += "                       AND B1_MSBLQL <> '1' "
			UP007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
			UP007 += "  WHERE ZCN_FILIAL = '" + xFilial("ZCN") + "' "
			UP007 += "    AND ZCN_POLIT = '8' "
			UP007 += "    AND ZCN_ESTSEG = 0 "
			UP007 += "    AND ZCN.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Atualizando ZCN_P8PPED(2)!!!",,{|| TcSqlExec(UP007) })

			B773LOGPRC("3")

			MsgINFO("Processamento realizado com sucesso!!!")


		Else

			Aviso('B773PPD(2)', "Não existe regra definida para atualização do PONTO DE PEDIDO para a política selecionada. Favor verificar!!!", {'Ok'}, 3)

		EndIf

	Else

		MsgSTOP("Processamento abortado!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773LOGPRC  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 24/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Grava Log de Processamento                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function B773LOGPRC(gbxOrig)

	Local cvArea         := GetArea()

	ZI009 := " SELECT ISNULL(MAX(Z08_NUMPRC), '000000000') NUMPROC"
	ZI009 += "   FROM " + RetSqlName("Z08") + " "
	ZI009 += "  WHERE Z08_FILIAL = '" + xFilial("Z08") + "' "
	ZI009 += "    AND Z08_NUMPRC <> '1' "
	ZI009 += "    AND D_E_L_E_T_ = ' ' "
	ZIcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZI009),'ZI09',.F.,.T.)
	dbSelectArea("ZI09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		dhNumProc := Soma1(ZI09->NUMPROC)
		dbSelectArea("ZI09")
		dbSkip()
	End
	ZI09->(dbCloseArea())
	Ferase(ZIcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZIcIndex+OrdBagExt())          //indice gerado

	dbSelectArea("Z08")
	RecLock("Z08",.T.)
	Z08->Z08_FILIAL  := xFilial("Z08")
	Z08->Z08_NUMPRC  := dhNumProc  
	Z08->Z08_DTPRC   := dDataBase
	Z08->Z08_HRPRC   := Time()
	Z08->Z08_USRPRC  := UsrRetName(RetCodUsr())
	Z08->Z08_DTSYSP  := Date()
	Z08->Z08_ORIGPR  := gbxOrig
	MsUnLock()

	RestArea(cvArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773LPC     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 27/03/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Lista Log de Processamento                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773LPC()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	oExcel := FWMSEXCEL():New()
	nxPlan := "Planilha 01"
	nxTabl := "Log de processamento do Cockpit Simulador"

	fPerg := "B773LPC"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidLpcPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "NumProc"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DtPrc"               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "HrPrc"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UsrPrc"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DtSysP"              ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "OrigPr"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descric"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SaldSC"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SaldPC"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PrvsSC"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "GeraSC"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CnfSC"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Obs"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Politica"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EstSeg"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PE"                  ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Ponto Pedido"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Consumo"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "LE"                  ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Qatu"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "NumSC"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EstoqueAtual"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CustoAtual"          ,3,2)

	RT003 := " WITH LOGPROC AS (SELECT Z08_NUMPRC NUMPRC,
	RT003 += "                         Z08_DTPRC DTPRC,
	RT003 += "                         Z08_HRPRC HRPRC,
	RT003 += "                         Z08_USRPRC USRPRC,
	RT003 += "                         Z08_DTSYSP DTSYSP,
	RT003 += "                         Z08_ORIGPR ORIGPR,
	RT003 += "                         Z09_PRODUT PRODUT,
	RT003 += "                         Z09_SALDSC SALDSC,
	RT003 += "                         Z09_SALDPC SALDPC,
	RT003 += "                         Z09_PRVSSC PRVSSC,
	RT003 += "                         Z09_GERASC GERASC,
	RT003 += "                         Z09_CNFSC CNFSC,
	RT003 += "                         Z09_OBS OBS,
	RT003 += "                         Z09_POLITI POLITI,
	RT003 += "                         Z09_ESTSEG ESTSEG,
	RT003 += "                         Z09_PE PE,
	RT003 += "                         Z09_EMIN EMIN,
	RT003 += "                         Z09_CONSUM CONSUM,
	RT003 += "                         Z09_LE LE,
	RT003 += "                         Z09_QATU QATU,
	RT003 += "                         Z09_NUMSC NUMSC
	RT003 += "                    FROM " + RetSqlName("Z08") + " Z08
	RT003 += "                    LEFT JOIN " + RetSqlName("Z09") + " Z09 ON Z09_NUMPRC = Z08_NUMPRC
	RT003 += "                                        AND Z09.D_E_L_E_T_ = ' '
	RT003 += "                   WHERE Z08_FILIAL = '" + xFilial("Z08") + "'
	RT003 += "                     AND Z08_NUMPRC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'
	RT003 += "                     AND Z08_DTPRC  BETWEEN '" + dtos(MV_PAR03) + "' AND '" + dtos(MV_PAR04) + "'
	RT003 += "                     AND Z08.D_E_L_E_T_ = ' ')
	RT003 += " SELECT *
	RT003 += "   FROM LOGPROC
	RT003 += "  WHERE PRODUT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'	
	RTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT003),'RT03',.F.,.T.)
	dbSelectArea("RT03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + RT03->PRODUT ))

		aSaldos := CalcEst(RT03->PRODUT, "01", dDataBase+1)
		xQuantZ := aSaldos[1]
		xCustoZ := aSaldos[2]

		oExcel:AddRow(nxPlan, nxTabl, { RT03->NUMPRC, stod(RT03->DTPRC), RT03->HRPRC, RT03->USRPRC, stod(RT03->DTSYSP), RT03->ORIGPR, RT03->PRODUT, Alltrim(SB1->B1_DESC),RT03->SALDSC, RT03->SALDPC, RT03->PRVSSC, RT03->GERASC, RT03->CNFSC, RT03->OBS, RT03->POLITI, RT03->ESTSEG, RT03->PE, RT03->EMIN, RT03->CONSUM, RT03->LE, RT03->QATU, RT03->NUMSC, xQuantZ, xCustoZ })

		dbSelectArea("RT03")
		dbSkip()

	End

	RT03->(dbCloseArea())
	Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "logproc - " + cEmpAnt

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B773LTE     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 19/04/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçao ¦ Grava Lote Economico                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B773LTE()

	Local xptoRet := .T.
	Local saArea   := GetArea()

	If Alltrim(__readvar) == "M->LOTECO"

		// Atualizar Indicador de Produto...
		dbSelectArea("ZCN")
		dbSetOrder(2)
		If dbSeek(xFilial("ZCN") + GdFieldGet("PRODUT",n) + GdFieldGet("LOCAL",n) )
			RecLock("ZCN",.F.)
			ZCN->ZCN_LE := M->LOTECO 
			MsUnLock()
		EndIf

		// Calculo da Necessidade
		xp1oPrvSol := GdFieldGet("PRVSOL",n)
		xptoSomaInt := 0
		If (GdFieldGet("PRVSOL",n)/ZCN->ZCN_LE) - int(GdFieldGet("PRVSOL",n)/ZCN->ZCN_LE) > 0 
			xptoSomaInt := 1
		EndIf
		If xp1oPrvSol <> 0 .and. ZCN->ZCN_LE <> 0
			xp1oPrvSol := IIF(GdFieldGet("PRVSOL",n) < ZCN->ZCN_LE, ZCN->ZCN_LE, (int(GdFieldGet("PRVSOL",n)/ZCN->ZCN_LE) + xptoSomaInt)  * ZCN->ZCN_LE )
		EndIf

		GdFieldPut("CNFSOL", xp1oPrvSol, n)

	ElseIf Alltrim(__readvar) == "M->CNFSOL"

		If M->CNFSOL < GdFieldGet("LOTECO",n)

			MsgALERT("Você digitou uma quantidade para solicitação de compras menor que o lote econômico. Favor verificar se é isto mesmo que deseja!!!")

		EndIf 

	ElseIf Alltrim(__readvar) == "M->CDMARC"

		DbSelectArea("ZD6")
		ZD6->(DbSetOrder(1))
		If !ZD6->(DbSeek(xFilial("ZD6")+GdFieldGet("PRODUT",n)+M->CDMARC+GdFieldGet("PARTN",n)))
			MsgInfo("Marca não Associada ao Produto Selecionado!")
			xptoRet	:=	.F.
		EndIf
	EndIf

	RestArea(saArea)

Return ( xptoRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xfEnvMailC ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 16.05.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gravação de Log e inclusão da SC                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xfEnvMailC()

	Local vcArea   := GetArea()
	Local vcDduser := pswret(1) 

	fPerg := "BIA773EM"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidEMPerg()
	If !Pergunte(fPerg,.T.)
		MsgSTOP("Processamento abortado!!!")
		Return
	EndIf

	xqCorpMail := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	xqCorpMail += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	xqCorpMail += ' <head> '
	xqCorpMail += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	xqCorpMail += ' <title>Untitled Document</title> '
	xqCorpMail += ' </head> '
	xqCorpMail += ' <body> '
	xqCorpMail += ' <p>Prezado (a) ' + Alltrim(MV_PAR01) + ',</p> '
	xqCorpMail += ' <p>&nbsp;</p> '
	xqCorpMail += ' <p>O produto: <strong>' + Alltrim(OMSNGDCOCKSIM:ACOLS[OMSNGDCOCKSIM:NAT][1]) + ' - ' + Alltrim(OMSNGDCOCKSIM:ACOLS[OMSNGDCOCKSIM:NAT][2]) + '</strong>, encontra-se a bastante tempo sem movimentações. Contudo, recentemente apresentou algumas movintações que acabaram interferindo nas projeções padrões da Política de Estoque gerando demanda de compra.</p> '
	xqCorpMail += ' <p>&nbsp;</p> '
	xqCorpMail += ' <p>Favor confirmar para o e-mail ' + vcDduser[1][14] + ' se realmente é necessária a compra.</p> '
	xqCorpMail += ' <p>&nbsp;</p> '
	xqCorpMail += ' <p>Atenciosamente,</p> '
	xqCorpMail += ' <p>&nbsp;</p> '
	xqCorpMail += ' <p>' + vcDduser[1][4] + '</p> '
	xqCorpMail += ' </body> '
	xqCorpMail += ' </html> '

	df_Dest := Alltrim(MV_PAR02)
	df_Assu := "Conformação de compra de material de baixo giro" 
	df_Mens := xqCorpMail
	df_Erro := "Conformação de compra de material de baixo giro não enviado. Favor verificar!!!"

	U_BIAEnvMail(, df_Dest, df_Assu, df_Mens, df_Erro)

	RestArea(vcArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidEMPerg ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 24/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidEMPerg()

	local i,j
	Local wxArea   := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Destinatário                 ?","","","mv_ch1","C",75,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","E-mail Destinatário          ?","","","mv_ch2","C",95,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(wxArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Grupo                     ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"02","Até Grupo                    ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"03","Considera Apenas Ponto Pedido?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Produto Importado            ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Produto com mais Relevância  ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","","","Não","","","","","Ambos","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Política                     ?","","","mv_ch6","C",01,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","Y8"})
	aAdd(aRegs,{cPerg,"07","Locais                       ?","","","mv_ch7","C",30,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Somente PDM					 ?","","","mv_ch8","N",01,0,0,"C","","mv_par08","Sim","","","","","Não","","","","","Todos","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidUPPerg ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 24/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidUPPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Política                     ?","","","mv_ch1","C",01,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","Y8"})
	aAdd(aRegs,{cPerg,"02","De Grupo                     ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"03","Até Grupo                    ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidLpcPerg ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 27/03/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidLpcPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De NumProc               ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate NumProc              ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Data                  ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até Data                 ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","De Produto               ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Ate Produto              ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

User Function B773Loc()

	Local _aArea	:=	GetArea()
	Local _aLocais	:=	{}
	Local MvPar
	Local MvParDef	:=	""
	Local lRet		:= .F.
	Local _nTamKey	:= 0
	Local _nElemen	:= 0

	DbSelectArea("NRR")
	NNR->(DbSetOrder(1))
	NNR->(DbGoTop())

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	While NNR->(!EOF())

		If aScan(_aLocais,{|x| x == Alltrim(NNR->NNR_CODIGO) + ' - ' + Alltrim(NNR->NNR_DESCRI)}) == 0 .And. !Empty(NNR->NNR_CODIGO)
			aAdd(_aLocais,Alltrim(NNR->NNR_CODIGO) + ' - ' + Alltrim(NNR->NNR_DESCRI))
			MvParDef	+=	NNR->NNR_CODIGO
			_nElemen++
		EndIf

		NNR->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MVPARDEF)

	If f_Opcoes(@MvPar,"Seleção de Armazéns",_aLocais,MvParDef,,,.F.,2,_nElemen)
		lRet	:= .T.
		&MvRet := Alltrim(mvpar)
	EndIf
	RestArea(_aArea)

Return lRet
