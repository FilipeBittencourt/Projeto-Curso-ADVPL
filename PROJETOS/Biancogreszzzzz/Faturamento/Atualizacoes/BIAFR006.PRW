#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAFR006																		  	|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 26/11/14																				|
|-----------------------------------------------------------|
| Desc.:	| Rotina para impressao do relatorio de pedidos 	|
| 				| de venda via Crystal						    						|
|-----------------------------------------------------------|
*/


User Function BIAFR006(cEmpPed)
Private cSQL
Private cPedVen := Iif(IsInCallStack("U_BIA485IMP"),SZN->ZN_PEDIDO,SC5->C5_NUM)
Private cOpcao 	:= ""
Private cFile := ""
Private cNumDe := ""
Private cNumAte := ""

	Default cEmpPed := cEmpAnt

	// Pedido de Venda, Liberação de PV e Consulta F10
	If Upper(Alltrim(FunName())) $ "MATA410#BIA485" .Or. IsInCallStack("U_POS_CLI")
		
		cNumDe := cPedVen
		cNumAte := cPedVen
		
	Else
		
		lEnd := .F.
		cString := ""
		cDesc1 := "Este programa tem como objetivo imprimir relatorio "
		cDesc2 := "de acordo com os parametros informados pelo usuario."
		cDesc3 := "INMPRESSÃO DE PEDIDOS DE VENDA"
		cTamanho := ""
		limite := 80
		aReturn := {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
		cNomeprog := "PEDVEN"
		cPerg := "PEDVEN"
		aLinha := {}
		nLastKey := 0
		cTitulo	:= "Informaçoes do Pedido de Venda"
		Cabec1 := ""
		Cabec2 := ""
		nBegin := 0
		cDescri := ""
		cCancel := "***** CANCELADO PELO OPERADOR *****"
		m_pag := 1
		wnrel := "PEDVEN"
		lprim := .T.
		li := 80
		nTipo := 0
		wFlag := .T.
	
		Pergunte(cPerg,.F.)
		
		wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,cTamanho,,.F.)
		
		If nLastKey == 27
			Return
		Endif
		
		cNumDe	:= MV_PAR01
		cNumAte 	:= MV_PAR02
		
	EndIf
	
	//Gera view com as informações do Pedido de Venda (SC5 e SC6)
	cSQL := ""
	cSQL += " ALTER VIEW IMP_PEDVEN AS  																																"
	cSQL += " SELECT A1_NOME, A1_CGC, A1_END, A1_MUN, A1_BAIRRO, A1_CEP, A1_TEL, A1_FAX, A1_INSCR, A4_NOME, A4_COD, C5_NUM, C5_EMISSAO,									"
	cSQL += "	C5_CLIENTE, C5_YLINHA, C5_CONDPAG, B1_IPI, A1_CONTATO, A1_EMAIL, (CASE WHEN C6_YQTDPC<>0 THEN 'PÇ' ELSE C6_UM END) AS C6_UM, C6_PRCVEN, C6_VALOR,		"
	cSQL += "	C5_VLRFRET, C6_ITEM, E4_DESCRI, (CASE WHEN C6_YQTDPC<>0 THEN C6_YQTDPC ELSE C6_QTDVEN END) AS C6_QTDVEN, C5_YFORMA, A1_PESSOA, A3_NREDUZ, C6_PRODUTO,	"
	cSQL += "	A1_YRECR, C6_DESCRI, A3_COD, A1_EST, C6_YDESC, C6_ENTREG, C6_YDTNECE, C5_YSUBTP, (SELECT X5_DESCRI FROM "+RetFullName("SX5")+" WHERE X5_TABELA = 'DJ' AND X5_CHAVE = C5_YSUBTP AND D_E_L_E_T_= '') AS TIPO_OPE, "
	cSQL += "	CONVERT(VARCHAR(500),CONVERT(BINARY(500),SC5.C5_YOBS)) AS OBS, C5_FRETE, C5_YPGTO,  TIPO_DES = CASE WHEN C5_YTIPOCO = '1' THEN 'Com Descarga' else 'Sem Descarga' END, "
	cSQL += "	C6_YPERC, C6_YDNV, C6_YDESP, C5_YPEDORI, C5_YPRZINC, C5_YDTINC "   
	cSQL += "FROM " + RetFullName("SC5", cEmpPed) + " SC5 			"
	cSQL += "	INNER JOIN " + RetFullName("SC6", cEmpPed) + " SC6 	"
	cSQL += "		ON 	SC6.C6_FILIAL = '"+xFilial("SC6")+"' " 
	cSQL += "			AND SC6.C6_NUM = SC5.C5_NUM 		"	
	cSQL += "			AND SC6.D_E_L_E_T_ = '' 			"
	cSQL += "	INNER JOIN " + RetFullName("SA1", cEmpPed) + " SA1 	"
	cSQL += "		ON 	SA1.A1_FILIAL = '"+xFilial("SA1")+"' " 
	cSQL += "			AND SA1.A1_COD = SC5.C5_CLIENTE 	"
	cSQL += "			AND SA1.A1_LOJA = SC5.C5_LOJACLI	"
	cSQL += "			AND SA1.D_E_L_E_T_ = '' 			"
	cSQL += "	LEFT JOIN " + RetFullName("SA4", cEmpPed) + " SA4 	" 
	cSQL += "		ON 	SA4.A4_FILIAL = '"+xFilial("SA4")+"' "
	cSQL += "			AND SC5.C5_TRANSP = SA4.A4_COD 		"
	cSQL += "			AND SA4.D_E_L_E_T_ = '' 			"
	cSQL += "	INNER JOIN " + RetFullName("SE4", cEmpPed) + " SE4 	"
	cSQL += "		ON	SE4.E4_FILIAL = '"+xFilial("SE4")+"' " 
	cSQL += "			AND SE4.E4_CODIGO = SC5.C5_CONDPAG 	"
	cSQL += "			AND SE4.D_E_L_E_T_ = '' 			"
	cSQL += "	INNER JOIN " + RetFullName("SA3", cEmpPed) + " SA3 	" 
	cSQL += "		ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "
	cSQL += "			AND SA3.A3_COD = SC5.C5_VEND1 		"
	cSQL += "			AND SA3.D_E_L_E_T_ = '' 			"
	cSQL += "	LEFT JOIN " + RetFullName("SB1", cEmpPed) + " SB1 	"
	cSQL += "		ON SC6.C6_PRODUTO = SB1.B1_COD 			"
	cSQL += "			AND SB1.D_E_L_E_T_ = '' 			"
	cSQL += " WHERE	SC5.C5_FILIAL = '"+xFilial("SC5")+"'	"
	cSQL += "	AND SC5.C5_NUM >= '" + cNumDe + "' 		"
	cSQL += "	AND SC5.C5_NUM <= '" + cNumAte + "'		"
	cSQL += "	AND SC5.D_E_L_E_T_='' 						"
	
	TcSQLExec(cSQL)
	
	//Gera view com as informações do Contrato - Transforma as colunas da tabela de contrato em linhas.
	cSQL := " ALTER VIEW IMP_PEDVEN_CONTRATO2 AS " 
	cSQL += " SELECT Z60_NUMPED, CAMPO1, VENCIMENTO, CAMPO2, VALOR "
	cSQL += " FROM "
	cSQL += " (SELECT * "
	cSQL += " FROM "+ RetFullName("Z60", cEmpPed)+" " 
	cSQL += " WHERE Z60_FILIAL = '"+xFilial("Z60")+"' AND Z60_NUMPED = "+ ValToSQL(cNumDe)+" AND D_E_L_E_T_ = '' ) TMP1 "
	cSQL += " UNPIVOT "
	cSQL += " ( VENCIMENTO  FOR CAMPO1 IN (Z60_DATA1,Z60_DATA2,Z60_DATA3,Z60_DATA4,Z60_DATA5,Z60_DATA6,Z60_DATA7,Z60_DATA8,Z60_DATA9,Z60_DATAA,Z60_DATAB,Z60_DATAC)) TMP2 "
	cSQL += " UNPIVOT "
	cSQL += " ( VALOR		  FOR CAMPO2 IN (Z60_PARC1,Z60_PARC2,Z60_PARC3,Z60_PARC4,Z60_PARC5,Z60_PARC6,Z60_PARC7,Z60_PARC8,Z60_PARC9,Z60_PARCA,Z60_PARCB,Z60_PARCC)) TMP3 "
	cSQL += " WHERE RIGHT(CAMPO1,1) = RIGHT(CAMPO2,1) "
	
	TcSQLExec(cSQL)
	
	//Define forma de Impressão
	cOpcao	:=	"6;0;1;Pedido de Venda"
	
	CallCrys("PEDIDO", cEmpPed +";"+ cNumDe, cOpcao, .T., .F., .T., .F. )

Return(cFile)