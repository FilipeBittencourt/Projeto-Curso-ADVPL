#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "Totvs.ch"          
#INCLUDE "TBICONN.CH"'

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Cesar Magnago
Alterdo   := Ranisses Antonio Corona
Programa  := BIA312
Empresa   := Biancogres Ceramicas S/A
Data      := 09/08/01
Data Alt. := 07/04/14
Uso       := Faturamento      
Aplicação := Visualizar os Pedidos com Bloqueio

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA312()
Local 	cFiltro	:= ""  
Private cQuery 	:= ""
Private cCadastro := ""   
Private aRotina := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TX FINANCEIRA esta cadastrada corretamente                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFator	:= U_fBuscaTxBI("0101","TXF",Dtos(dDataBase)) //Verifica se tem tx cadastrada para Biancogres, pois a demais também terão.
IF nFator == 0
	MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida. Entre em contato com a Controladoria ou Direção Administrativa.","BIA312","STOP")
	Return()
EndIf

cSql := ""
cSql += "WITH UZ7_TMP AS(	" + CRLF
cSql += "SELECT UZ7_PEDIDO, CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(UZ7.UZ7_USERGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(UZ7.UZ7_USERGA,16,1)) - 50)),'19960101'),112) AS UZ7_ALT " + CRLF 
cSql += "FROM "+RetSqlName("UZ7")+"	UZ7	" + CRLF 
cSql += "WHERE UZ7_FILIAL = '"+xFilial("UZ7")+"' AND D_E_L_E_T_ = ''),	" + CRLF
cSql += " "
cSql += "SC5_TMP AS(	" + CRLF
cSql += "SELECT	C5_FILIAL, C5_NUM, C5_YSUBTP, C5_CLIENTE, C5_LOJACLI, C5_LOJAENT, C5_YAPROV, C5_YAAPROV, C5_YLINHA, C5_YMAXCND, C5_EMISSAO,	C5_CONDPAG, C5_YRECR, C5_YPRZINC, C5_YDTINC, C5_VEND1, C5_YTPBLQ, 	" + CRLF 
cSql += "		C5_YMEDDES, C5_YMDESPD, CONVERT(VARCHAR(500),CONVERT(BINARY(500),(C5_YOBS))) AS C5_YOBS, C5_YCONF, C5_YCRDENG, C5_YTPCRED, C5_YOBDCOU, C5_YCLVL, C5_YITEMCT, C5_YNUMSI, C5_YNOUTAI, C5_YCTRVER,		" + CRLF
cSql += "		ISNULL(CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(C5_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(C5_USERLGA,16,1)) - 50)),'19960101'),112),CONVERT(VARCHAR,GETDATE(),112)) SC5_ALT	" + CRLF  
cSql += "FROM "+RetSqlName("SC5")+"	SC5	" + CRLF	 
cSql += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = '') " + CRLF
cSql += " "
cSql += "SELECT	C5_FILIAL, C5_NUM, C5_YSUBTP, C5_CLIENTE, C5_LOJACLI, C5_LOJAENT, C5_YAPROV, C5_YAAPROV, C5_YLINHA, C5_YMAXCND, C5_EMISSAO,	C5_CONDPAG, C5_YRECR, C5_YPRZINC, C5_YDTINC, " + CRLF
cSql += "		A1_NOME, A1_MUN, A1_EST, C5_VEND1, C5_YTPBLQ, C5_YMEDDES CORRECAO, C5_YMDESPD, C5_YOBS,	" + CRLF
cSql += "		(SELECT X5_DESCRI FROM "+RetSqlName("SX5")+" WITH (NOLOCK) WHERE X5_TABELA = 'DJ' AND X5_CHAVE = C5_YSUBTP AND D_E_L_E_T_ = '') TIPOPED, " + CRLF
cSql += "		SUBTP = CASE " + CRLF
cSql += "						WHEN C5_YSUBTP = 'A' THEN 'Amostra' " + CRLF
cSql += "						WHEN C5_YSUBTP = 'B' THEN 'Bonif.' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'N' THEN 'Venda' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'F' THEN 'Feiras' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'G' THEN 'Garantia' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'R1' THEN 'Conta Ordem:Dupl' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'R2' THEN 'Conta Ordem:Est'	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'DC' THEN 'Dev.Compras' 		" + CRLF
cSql += "						WHEN C5_YSUBTP = 'I' THEN 'Incesa' 				" + CRLF
cSql += "						WHEN C5_YSUBTP = 'O' THEN 'Outros' 		" + CRLF
cSql += "						WHEN C5_YSUBTP = 'M' THEN 'Mostruario' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'D' THEN 'Doacao' 		" + CRLF
cSql += "						WHEN C5_YSUBTP = 'FE' THEN 'Esp.Export.' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'E' THEN 'Trat.Especial'	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'FA' THEN 'Fat.Ant.' 		" + CRLF
cSql += "						WHEN C5_YSUBTP = 'IM' THEN 'Venda Imp.' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'FI' THEN 'Fat.Ant.Inc.' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'AG' THEN 'Venda Imp.' 	" + CRLF
cSql += "						WHEN C5_YSUBTP = 'R3' THEN 'Conta Ordem:Est(Esp)' " + CRLF
cSql += "						WHEN C5_YSUBTP = 'C' THEN 'Consignacao' " + CRLF
cSql += "						ELSE 'Nao encontrado' 	" + CRLF
cSql += "					END,						" + CRLF
cSql += "		SUM(C6_VALDESC) AS DESCINCON,  MAX(C6_YPERC) AS POLITICA, 
cSql += "		C5_YCONF, C5_YCRDENG, C5_YTPCRED, C5_YOBDCOU, 	" + CRLF // Tiago Rossini - Facile Sistemas
cSql += "		C5_YCLVL, C5_YITEMCT, C5_YNUMSI, C5_YNOUTAI, C5_YCTRVER,  	" + CRLF // OS 2902-16 - Claudeir - Luana Marin
cSql += "		SC5_ALT, ISNULL(UZ7_ALT,'19960101') UZ7_ALT		" + CRLF 
cSql += "FROM SC5_TMP SC5 WITH (NOLOCK) INNER JOIN " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) ON " + CRLF
cSql += "		SC5.C5_NUM 		= SC6.C6_NUM AND " + CRLF
cSql += "		SC5.C5_CLIENTE  = SC6.C6_CLI AND " + CRLF
cSql += "		SC5.C5_LOJACLI  = SC6.C6_LOJA  INNER JOIN " + RetSqlName("SA1") + " SA1 ON " + CRLF
cSql += "		SC5.C5_CLIENTE	= SA1.A1_COD	AND " + CRLF
cSql += "		SC5.C5_LOJACLI	= SA1.A1_LOJA		" + CRLF
cSql += "		LEFT JOIN UZ7_TMP ON SC5.C5_NUM = UZ7_PEDIDO  " + CRLF
cSql += "WHERE	SC5.C5_FILIAL	= '"+xFilial("SC5")+"'	AND	" + CRLF
cSql += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'	AND	" + CRLF
cSql += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"'	AND	" + CRLF
cSql += "		SC5.C5_YAPROV	= ''                    AND " + CRLF
cSql += "		SC5.C5_YAAPROV 	<> ''					AND " + CRLF
cSql += "		SC6.C6_BLQ      <> 'R'          AND " + CRLF //NÃO CARREGA PEDIDOS COM BLOQUEIO DE RESIDUO
cSql += "		SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND " + CRLF
cSql += "		SC6.D_E_L_E_T_ = ''				AND	" + CRLF
cSql += "		SA1.D_E_L_E_T_ = ''					" + CRLF
cSql += "GROUP BY	C5_FILIAL, C5_NUM, C5_YSUBTP, C5_CLIENTE, C5_LOJACLI, C5_LOJAENT, C5_YAPROV, C5_YAAPROV, C5_YLINHA, C5_YMAXCND, C5_EMISSAO, C5_CONDPAG, C5_YRECR, C5_YPRZINC, C5_YDTINC, 						" + CRLF
cSql += "			A1_NOME, A1_MUN, A1_EST, C5_VEND1, C5_YTPBLQ, C5_YMEDDES, C5_YMDESPD, C5_YOBS, C5_YCONF, C5_YCRDENG, C5_YTPCRED, C5_YOBDCOU, C5_YCLVL, C5_YITEMCT, C5_YNUMSI, C5_YNOUTAI, C5_YCTRVER, SC5_ALT, UZ7_ALT	" + CRLF
cSql += "HAVING SC5_ALT >= ISNULL(UZ7_ALT,'19960101') " + CRLF //IMPORTA SOMENTE OS PEDIDOS QUE FORAM ALTERADOS APOS A INCLUSÃO NA TABELA UZ7
cSql += "ORDER BY C5_FILIAL, C5_NUM " + CRLF
If chkfile("TRB")
	dbSelectArea("TRB")
	dbCloseArea()
EndIf
TCQUERY cSql ALIAS "TRB" NEW

//Posiciona no primeiro registro 
TRB->(DbGotop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Arquivo de Liberação
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !TRB->(EOF())

	UZ7->(DbSetOrder(1))
	If UZ7->(DbSeek(TRB->C5_FILIAL+TRB->C5_NUM)) 
		
		UZ7->(RecLock("UZ7",.F.))
		
			UZ7->UZ7_FILIAL	:= TRB->C5_FILIAL
			UZ7->UZ7_PEDIDO	:= TRB->C5_NUM
			UZ7->UZ7_TIPO	:= TRB->SUBTP	//Tipo de Venda
			UZ7->UZ7_CLIENT	:= TRB->C5_CLIENTE
			UZ7->UZ7_LOJACL	:= TRB->C5_LOJACLI
			UZ7->UZ7_LOJAEN	:= TRB->C5_LOJAENT
			UZ7->UZ7_APROV := TRB->C5_YAPROV
			UZ7->UZ7_AAPROV	:= TRB->C5_YAAPROV
			UZ7->UZ7_NOME := TRB->A1_NOME
			UZ7->UZ7_CIDADE	:= TRB->A1_MUN
			UZ7->UZ7_EST := TRB->A1_EST
			UZ7->UZ7_REP := Posicione("SA3",1,xFilial("SA3")+TRB->C5_VEND1,"A3_NREDUZ")
			nVend	:= TRB->C5_VEND1
			nCli := TRB->C5_CLIENTE
			nGrpCli	:= Posicione("SA1",1,xFilial("SA1")+TRB->C5_CLIENTE+TRB->C5_LOJACLI,"A1_GRPVEN")
			nSegm	:= Posicione("SA1",1,xFilial("SA1")+TRB->C5_CLIENTE+TRB->C5_LOJACLI,"A1_SATIV1") //TRATAMENTO POR SEGMENTO
			nProd	:= "AAAAAAAA"		//INFORMAR QUALQUER PRODUTO/LOTE, POIS NAO PODE ACHAR REGRA POR PRODUTO/LOTE
			nLote	:= "AAA" 			//INFORMAR QUALQUER PRODUTO/LOTE, POIS NAO PODE ACHAR REGRA POR PRODUTO/LOTE
			dtEmis := TRB->C5_EMISSAO
			nLinha := TRB->C5_YLINHA
			UZ7->UZ7_LINHA := TRB->C5_YLINHA
			UZ7->UZ7_PERCMC	:= U_fMargem3(TRB->C5_NUM,"2") // CALCULA MARGEM	
			UZ7->UZ7_POLITI	:= TRB->POLITICA
			UZ7->UZ7_MAXCND	:= TRB->C5_YMAXCND
			UZ7->UZ7_EMISSA	:= U_STOD(TRB->C5_EMISSAO)
			UZ7->UZ7_CODPAG	:= TRB->C5_CONDPAG
			UZ7->UZ7_VALDES := TRB->DESCINCON	//Desconto Incondicional
			UZ7->UZ7_DESCLI	:= U_fBuscaDesconto(nVend,nSegm,nCli,nGrpCli,nProd,nLote,dtEmis,nLinha) //Politica de Desconto Representante / Cliente
			UZ7->UZ7_RECR	:= TRB->C5_YRECR
			UZ7->UZ7_YPRZIN	:= TRB->C5_YPRZINC
			UZ7->UZ7_YDTINC	:= U_STOD(TRB->C5_YDTINC)
			UZ7->UZ7_DESPAG	:= Posicione("SE4",1,xFilial("SE4")+TRB->C5_CONDPAG,"E4_DESCRI")
			UZ7->UZ7_DESC	:= TRB->CORRECAO //Media da Correcao
			UZ7->UZ7_MDESPD	:= TRB->C5_YMDESPD
			UZ7->UZ7_TPBLQ := TRB->C5_YTPBLQ
			UZ7->UZ7_OBS := TRB->C5_YOBS	 
			UZ7->UZ7_YCONF := TRB->C5_YCONF	// Tiago Rossini - Pedido Conferido - Comercial
			UZ7->UZ7_TPCRED	:= TRB->C5_YTPCRED	// Ranisses - Tipo de Analise de Crédito
			UZ7->UZ7_CRDENG	:= TRB->C5_YCRDENG	// Ranisses - Crédito de Engenharia	
			
			If UZ7->(FieldPos("UZ7_OBDCOU")) > 0
				
				UZ7->UZ7_OBDCOU	:= TRB->C5_YOBDCOU  // Ranisses
				 
			EndIf
				
			If UZ7->(FieldPos("UZ7_CLVL")) > 0
				
				UZ7->UZ7_CLVL	:= TRB->C5_YCLVL //Classe Valor
				UZ7->UZ7_ITEMCT	:= TRB->C5_YITEMCT //Item Contábil
				UZ7->UZ7_NUMSI := TRB->C5_YNUMSI //Numero SI
				UZ7->UZ7_CTRVER := TRB->C5_YCTRVER //Numero Contrato
				UZ7->UZ7_NOUTAI := TRB->C5_YNOUTAI //Numero SI Outros
				
			EndIf
		
		UZ7->(MsUnlock())
	
	EndIf		
	
	TRB->(DbSkip())
	
EndDo

//Apaga Arquivo da Query                                                  
TRB->(DbCloseArea())

//Rotina do MBrowse fazendo leitura do resultado do Arquivo Temporario    
cCadastro := "Pedidos Bloqueados na Politíca Comercial"

//Menu
aRotina   := {	{"Pesquisar"    ,"AxPesqui"                       ,0,1},;
				{"Visualizar"   ,'ExecBlock("BIA660",.F.,.F.,"V")',0,2},;
				{"Legenda" 		,'U_BIA318LEG()'				  ,0,5} }			

//Legenda
aCores    := {	{  'Alltrim(UZ7_APROV)=="" '	, 'BR_VERMELHO'} ,;
				{  'Alltrim(UZ7_APROV)<>"" '	, 'BR_VERDE'} } 

//Monta filtro
cFiltro += " UZ7_APROV = '' "

mBrowse(6,1,22,75,"UZ7",,,,,,aCores,,,,,,,,cFiltro)               

Return