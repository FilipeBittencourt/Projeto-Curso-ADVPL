#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT120APV
@author Ranisses A. Corona
@since 23/11/06
@version 1.0
@description O ponto de entrada F200DB1 Grava os Grupos de Aprovadores conforme Tipo do Material e/ou Classe de Valor
@history 28/11/2018, Luana Marin, Melhoria na alcada de aprovação, para contemplar o projeto Integracao de CNPJ
@type function
/*/

User Function MT120APV()
Local cQuery	:= ''
Local Enter1	:= CHR(13)+CHR(10)
Local cGrupo	:= SC7->C7_APROV
Local nDia		:= 1
Local _cDesMoed	:=	""

// Tratamento incluído por Marcos Alberto Soprani em 19/12/13
Private oTxMoedDlg
Private oTxButton1
Private oTxSay1
Private xwTxMoed
Private cwTxMoed := 0

	// Tiago Rossini Coradini - 09/12/2015 - Tratamento de classe de valor quando o pedido vem do modulo de importação
	If FunName() == "EICPO400"
    
		__aArea := GetArea()
		
		DbSelectArea("SW3")
		DbSetOrder(1)
		SW3->(DbSeek(xFilial("SW3") + SW2->W2_PO_NUM))
		
		//ATUALIZAR CLASSE DE VALOR DO PEDIDO COM BASE NA PURCHASE ORDER (PO)
		cSQL :=	"UPDATE " + RetSqlName("SC7") + ENTER1
		cSQL +=	"SET C7_CLVL = " + ValToSQL(SW2->W2_YCLVL) + ENTER1
		cSQL +=	"	,C7_YSI = " + ValToSQL(SW3->W3_YSI) + ENTER1
		cSQL +=	"	,C7_ITEMCTA = " + ValToSQL(SW3->W3_YITEMCT) + ENTER1
		cSQL +=	"	,C7_YCONTR = " + ValToSQL(SW3->W3_YCONTR) + ENTER1
		cSQL +=	"	,C7_CC = " + ValToSQL(SW3->W3_CTCUSTO) + ENTER1
		cSQL +=	"WHERE C7_NUM = " + ValToSQL(SC7->C7_NUM) + ENTER1
		cSQL +=	"	AND C7_FILIAL = '" + xFilial("SC7") + "'" + ENTER1
		cSQL +=	"	AND D_E_L_E_T_ = '' " + ENTER1
		
		TcSQLExec(cSQL)
		
		RestArea(__aArea)
		
	Else
		//ATUALIZA PEDIDO COM OS DADOS DA SOLICITAÇÃO
		cQuery0 := "UPDATE " + RetSqlName("SC7") + ENTER1
		cQuery0 += "SET C7_YAPLIC = C1_YAPLIC" + ENTER1
		cQuery0 += "	, C7_YTAG = C1_YTAG" + ENTER1
		cQuery0 += "	, C7_YMELHOR = C1_YMELHOR" + ENTER1
				
		cQuery0 += "	, C7_YCONTR = C1_YCONTR" + ENTER1
		cQuery0 += "	, C7_CLVL = C1_CLVL" + ENTER1
		cQuery0 += "	, C7_ITEMCTA = C1_ITEMCTA" + ENTER1
		cQuery0 += "	, C7_YSUBITE = C1_YSUBITE" + ENTER1
		
		cQuery0 += "	, C7_CC = C1_CC" + ENTER1
		cQuery0 += "	, C7_YMAT = C1_YMAT" + ENTER1
		cQuery0 += "	, C7_YSOLEMP = C1_YSOLEMP" + ENTER1
		cQuery0 += "	, C7_YSI = C1_YSI" + ENTER1
		cQuery0 += "	, C7_YOBS = C1_YOBS" + ENTER1
		cQuery0 += "	, C7_YTOTEST = C1_YTOTEST" + ENTER1
		cQuery0 += "	, C7_YDRIVER = C1_YDRIVER" + ENTER1	
		//cQuery0 += "	, C7_LOCAL = (CASE C1_LOCAL WHEN '' THEN C7_LOCAL ELSE C1_LOCAL END)" + Enter1
		cQuery0 += "FROM " + RetSqlName("SC7") + " SC7, " + RetSqlName("SC1") + " SC1" + ENTER1
		cQuery0 += "WHERE SC7.C7_NUM = '" + SC7->C7_NUM + "'" + ENTER1
		cQuery0 += "	AND C7_FILIAL = '" + xFilial("SC7") + "'" + ENTER1
		cQuery0 += "	AND C1_FILIAL = '" + xFilial("SC1") + "'" + ENTER1
		
		IF UPPER(ALLTRIM(FUNNAME())) == "MATA160"
			cQuery0 += "	AND SC1.C1_NUM = '" + SC8->C8_NUMSC + "'" + ENTER1
			cQuery0 += "	AND SC1.C1_ITEM = '" + SC8->C8_ITEMSC + "'" + ENTER1
			cQuery0 += "	AND SC7.C7_NUM = '" + SC7->C7_NUM + "'" + ENTER1
			cQuery0 += "	AND SC7.C7_ITEM = '" + SC7->C7_ITEM + "'" + ENTER1
		ELSE
			cQuery0 += "	AND SC7.C7_NUMSC = SC1.C1_NUM" + ENTER1
			cQuery0 += "	AND SC7.C7_ITEMSC = SC1.C1_ITEM" + ENTER1
		ENDIF
		
		cQuery0 += "	AND SC1.D_E_L_E_T_ = ''" + ENTER1
		cQuery0 += "	AND SC7.D_E_L_E_T_ = ''" + ENTER1
		TCSQLExec(cQuery0)
		  
	EndIf
	
	//SELECIONA A CLASSE DE VALOR E TIPO DO MATERIAL DO PEDIDO
	cQuery := "SELECT C7_NUM" + ENTER1
	cQuery += "		, SUM(C7_TOTAL) AS C7_TOTAL" + ENTER1
	cQuery += "		, MAX(C7_CLVL) AS C7_CLVL" + ENTER1
	cQuery += "		, MAX(B1_TIPO) AS B1_TIPO" + ENTER1
	cQuery += "		, MAX(BZ_YMD) AS BZ_YMD" + ENTER1
	cQuery += "FROM " + RetSqlName("SC7") + " SC7, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SBZ") + " SBZ" + ENTER1
	cQuery += "WHERE SC7.C7_PRODUTO = SB1.B1_COD" + ENTER1
	cQuery += "		AND SC7.C7_PRODUTO = SBZ.BZ_COD" + ENTER1
	cQuery += "		AND SC7.D_E_L_E_T_ = ''" + ENTER1
	cQuery += "		AND SBZ.D_E_L_E_T_ = ''" + ENTER1
	cQuery += "		AND SB1.D_E_L_E_T_ = ''" + ENTER1
	cQuery += "		AND SC7.C7_NUM = '" + SC7->C7_NUM + "'" + ENTER1
	cQuery += "		AND SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + ENTER1
	cQuery += "		AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + ENTER1
	cQuery += "		AND SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "'" + ENTER1
	cQuery += "GROUP BY C7_NUM" + ENTER1
	
	If chkfile("_SC7")
		dbSelectArea("_SC7")
		dbCloseArea()
	EndIf
	
	TCQuery cQuery Alias "_SC7" New
	
	
	If Alltrim(_SC7->B1_TIPO) $ ("MP_ME") .OR. (Alltrim(_SC7->BZ_YMD) <> 'S' .AND. Alltrim(_SC7->B1_TIPO) $ ("MD_MC_OI"))
		cGrupo := '000000'
	Else
		//SELECIONA GRUPO DE APROVAÇÃO
		cQuery := "SELECT TOP 1 ISNULL(AL_COD,'999999') AS GRUPO" + ENTER1
		cQuery += "FROM " + RetSQLName("SAL") + ENTER1
		cQuery += "WHERE AL_FILIAL  = '" + xFilial("SAL") + "'" + ENTER1
		cQuery += "	 AND AL_YCLVL   = '" + Trim(_SC7->C7_CLVL) + "'" + ENTER1
		cQuery += "	 AND D_E_L_E_T_ = ''" + ENTER1
		cQuery += "	 AND AL_MSBLQL <> '1'" + ENTER1
		If chkfile("_SAL")
			dbSelectArea("_SAL")
			dbCloseArea()
		EndIf
		
		TCQuery cQuery Alias "_SAL" New
		cGrupo := _SAL->GRUPO
	EndIf

	//ATUALIZA GRUPO DE APROVAÇÃO NO PEDIDO
	cQuery := "UPDATE " + RetSQLName("SC7") + ENTER1
	cQuery += "   SET C7_APROV   = '" + cGrupo + "'" + ENTER1 
	cQuery += "		, C7_GRUPCOM = ''" + ENTER1
	cQuery += " WHERE D_E_L_E_T_ = ''" + ENTER1
	cQuery += "	  AND C7_NUM     = '" + SC7->C7_NUM + "'" + ENTER1
	cQuery += "	  AND C7_FILIAL  = '" + xFilial("SC7") + "'" + ENTER1
	cQuery += "	  AND C7_NUMSC  <> ''" + ENTER1
	TCSQLExec(cQuery)

	//Grava cotação da moeda em dólar=2 ou euro=5 no pedido de compra.
	//O padrão do Protheus é gravar a moeda de acordo com a data base informada no sistema e não utiliza a data de emissão do pedido.
	IF !IsInCallStack("U_BIAFG030") .And. (SC7->C7_MOEDA = 2 .OR. SC7->C7_MOEDA = 5)
		
		_cDesMoed	:=	Iif(SC7->C7_MOEDA == 2,"DÓLAR","EURO")
		
		//Busca a taxa pela data de emissão
		nTaxa := 1 * RecMoeda(SC7->C7_EMISSAO, SC7->C7_MOEDA)
		
		While nTaxa == 0
			
			// Busca a taxa pela data anterior a emissão
			// Se for Sábado ou Domingo, a taxa destes dias deverá ser cadastrada com a taxa de sexta-feira
		
			// Tiago Rossini Coradini - 12/02/2016 - OS: 4167-15 - Claudia Carvalho - Tratamento para buscar a ultima taxa lançada no sistema
			nTaxa := 1 * RecMoeda(SC7->C7_EMISSAO - nDia, SC7->C7_MOEDA)
			
			nDia++ 
			
		EndDo
		
		cFornece := U_MontaSQLIN(GetMV("MV_YFORMOE"),'/',6)
		
		If SC7->C7_FORNECE $ cFornece
			DEFINE MSDIALOG oTxMoedDlg TITLE "Taxa Negociada" FROM 000, 000  TO 100, 600 COLORS 0, 16777215 PIXEL
			@ 013, 145 MSGET xwTxMoed VAR cwTxMoed SIZE 055, 010 OF oTxMoedDlg PICTURE "@E 999,999.9999" COLORS 0, 16777215 PIXEL
			@ 014, 007 SAY oTxSay1 PROMPT "Informe a Taxa da Moeda("+_cDesMoed+") negociada com o Fornecedor:" SIZE 135, 007 OF oTxMoedDlg COLORS 0, 16777215 PIXEL
			@ 012, 205 BUTTON oTxButton1 PROMPT "Confirma" SIZE 037, 012 OF oTxMoedDlg ACTION oTxMoedDlg:End() PIXEL
			ACTIVATE MSDIALOG oTxMoedDlg
			
			nTaxa := cwTxMoed
			cQuery0 := "UPDATE " + RetSqlName("SC7") + ENTER1
			cQuery0 += "SET C7_TXMOEDA = '" + ALLTRIM(STR(nTaxa)) + "'" + ENTER1
			cQuery0 += "WHERE C7_NUM = '" + SC7->C7_NUM + "'" + ENTER1
			cQuery0 += "	AND C7_FORNECE IN (" + cFornece + ")" + ENTER1
			cQuery0 += "	AND C7_FILIAL  = '" + xFilial("SC7") + "'" + ENTER1
			cQuery0 += "	AND D_E_L_E_T_ = ' '" + ENTER1
		Else
			
			cQuery0 := "UPDATE " + RetSqlName("SC7") + ENTER1
			cQuery0 += "SET C7_TXMOEDA = '" + ALLTRIM(STR(nTaxa)) + "'" + ENTER1
			cQuery0 += "WHERE C7_NUM = '" + SC7->C7_NUM + "'" + ENTER1
			cQuery0 += "	AND C7_FORNECE NOT IN (" + cFornece + ")" + ENTER1
			cQuery0 += "	AND C7_FILIAL  = '" + xFilial("SC7") + "'" + ENTER1
			cQuery0 += "	AND D_E_L_E_T_ = ''" + ENTER1
		EndIf
		
		TCSQLExec(cQuery0)
		
	ENDIF

Return(cGrupo)