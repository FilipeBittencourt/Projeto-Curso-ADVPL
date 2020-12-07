#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA318
@author Cesar Magnago
@since 09/08/2001	
@version 1.0
@description Liberar Pedidos de Vendas 
@history 07/04/2014, Ranisses A. Corona, Sem descriГЦo
@history 31/05/2017, Ranisses A. Corona, CorreГЦo do botЦo cancelar do Pergunte
@type function
/*/

User Function BIA318()
Local _NomeAprov	:= Upper(cUserName)
Local cFiltro		:= ""  
Local cAproTmp		:= ""
Local cUserTmp		:= ""

Private nAusTmp			:= ""
Private cAproTmp		:= ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a TX FINANCEIRA esta cadastrada corretamente                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nFator	:= U_fBuscaTxBI("0101","TXF",Dtos(dDataBase)) //Verifica se tem tx cadastrada para Biancogres, pois a demais tambИm terЦo.
IF nFator == 0
	MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida. Entre em contato com a Controladoria ou DireГЦo Administrativa.","BIA318","STOP")
	Return()
EndIf

//Verifica se estА com Aprovador TemporАrio Ativado
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	
	SELECT ZKQ_APROV FROM %Table:ZKQ%
		WHERE 
		ZKQ_STATUS		= 1		AND
		D_E_L_E_T_		= ''	AND
		CONVERT(date, GETDATE()) BETWEEN CONVERT(date, ZKQ_DTINI) AND CONVERT(date, ZKQ_DTFIM)
		AND ZKQ_APROVT = %Exp:__cUserID%
	
EndSql


If (!(cAliasTmp)->(EOF()))

	cAproTmp	:= ""
	cUserTmp	:= ""
	
	While  !(cAliasTmp)->(EOF())
		
		If !(Empty((cAliasTmp)->ZKQ_APROV))
			
			
			If (!Empty(cUserTmp))
				cUserTmp += ","
			EndIf
			
			cUserTmp += "'"+(cAliasTmp)->ZKQ_APROV+"'"
			
			If (!Empty(cUserTmp))
				cUserTmp += ","
			EndIf
			
			cUserTmp += "'"+UsrRetName((cAliasTmp)->ZKQ_APROV)+"'"	
			
		EndIf
		
		(cAliasTmp)->(dbSkip())
	EndDo
	
	cAproTmp	:= "("+cUserTmp+")"

EndIf

(cAliasTmp)->(dbCloseArea())

/*
//Verifica se estА com Aprovador TemporАrio Ativado
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	//SELECT COUNT(*) QUANT FROM %Table:SZM% WHERE ZM_MARCA <> '' AND ZM_CODAPRO = %Exp:__cUserID% AND ZM_APROTMP <> ' ' AND %NOTDEL%
	SELECT COUNT(*) QUANT FROM %Table:ZKJ% WHERE ZKJ_APROV = %Exp:__cUserID% AND ZKJ_APROVT <> ' ' AND %NOTDEL%
EndSql
If (cAliasTmp)->QUANT > 0 
	MsgAlert("O campo 'Aprovador TemporАrio' estА ativado em seu cadastro!")
	Return()
EndIf
(cAliasTmp)->(dbCloseArea())

If !Pergunte("BIA318",.T.)
     Return
EndIf
nAusTmp := MV_PAR01

If nAusTmp == 1
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		//	SELECT DISTINCT(ZM_CODAPRO) FROM %Table:SZM% WHERE ZM_MARCA <> '' AND ZM_APROTMP = %Exp:__cUserID% AND %NOTDEL%
		SELECT DISTINCT(ZKJ_APROVT) FROM %Table:ZKJ% WHERE ZKJ_APROVT = %Exp:__cUserID% AND %NOTDEL%
	EndSql

	//Verifica se o colaborador esta cadastrad como Ausencia Temporaria 
	If (cAliasTmp)->(EOF())
		MsgAlert("VocЙ nЦo esta cadastrado como Liberador TemporАrio!")
		MsgAlert("Favor entrar na rotina novamente e preencher o parБmetro 'AusЙncia TemporАria = NЦo'")
		Return()
	EndIf
	
	//Armazena informacao para montagem do Filtro
	While  !(cAliasTmp)->(EOF())
		//If !Empty(Alltrim(UsrRetName((cAliasTmp)->ZM_CODAPRO)))
		//	nAproTmp += "'"+Alltrim(UsrRetName((cAliasTmp)->ZM_CODAPRO))+"',"
		//EndIf
		If !Empty(Alltrim(UsrRetName((cAliasTmp)->ZKJ_APROVT)))
			nAproTmp += "'"+Alltrim(UsrRetName((cAliasTmp)->ZKJ_APROVT))+"',"
		EndIf
		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(dbCloseArea())
	nAproTmp	:= Substr(nAproTmp,1,Len(nAproTmp)-2)+"')"
	
EndIf
*/

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Limpa tabela de liberacao                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//TcSqlExec("DELETE FROM "+RetSqlName("UZ7")) RANISSES

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta query selecionando os pedidos para serem liberados                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
cSql += "		SUM(C6_VALDESC) AS DESCINCON,  MAX(C6_YPERC) AS POLITICA, " + CRLF
cSql += "		C5_YCONF, C5_YCRDENG, C5_YTPCRED, C5_YOBDCOU,	" + CRLF // Tiago Rossini - Facile Sistemas
cSql += "		C5_YCLVL, C5_YITEMCT, C5_YNUMSI, C5_YNOUTAI, C5_YCTRVER, 	" + CRLF // OS 2902-16 - Claudeir - Luana Marin
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

/*If nAusTmp == 1
	//cSql += "		SC5.C5_YAAPROV	IN "+nAproTmp+"	AND " + CRLF
	
	cSql += "		(SC5.C5_YAAPROV	= '" +_NomeAprov+"'	OR SC5.C5_YAAPROV	= '" +__cUserID+"')	AND " + CRLF
	
	
Else
//	cSql += "		SC5.C5_YAAPROV	= '" +_NomeAprov+"'	AND " + CRLF
	cSql += "		(SC5.C5_YAAPROV	= '" +_NomeAprov+"'	OR SC5.C5_YAAPROV	= '" +__cUserID+"')	AND " + CRLF
EndIf
*/


cSqlTemp := IIF (!Empty(cAproTmp) .And. cAproTmp <> "()", " OR SC5.C5_YAAPROV IN "+cAproTmp+"", "") 
	
cSql += "		(SC5.C5_YAAPROV	= '" +_NomeAprov+"'	OR SC5.C5_YAAPROV	= '" +__cUserID+"'  "+cSqlTemp+")	AND " + CRLF


cSql += "		SC5.C5_YAPROV	= ''			AND	" + CRLF
cSql += "		SC6.C6_BLQ      <> 'R'          AND " + CRLF 
cSql += "		SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND " + CRLF
cSql += "		SC6.D_E_L_E_T_ = ''				AND	" + CRLF
cSql += "		SA1.D_E_L_E_T_ = ''					" + CRLF
cSql += "GROUP BY	C5_FILIAL, C5_NUM, C5_YSUBTP, C5_CLIENTE, C5_LOJACLI, C5_LOJAENT, C5_YAPROV, C5_YAAPROV, C5_YLINHA, C5_YMAXCND, C5_EMISSAO, C5_CONDPAG, C5_YRECR, C5_YPRZINC, C5_YDTINC, " + CRLF
cSql += "			A1_NOME, A1_MUN, A1_EST, C5_VEND1, C5_YTPBLQ, C5_YMEDDES, C5_YMDESPD, C5_YOBS, C5_YCONF, C5_YCRDENG, C5_YTPCRED, C5_YOBDCOU, C5_YCLVL, C5_YITEMCT, C5_YNUMSI, C5_YNOUTAI, C5_YCTRVER, SC5_ALT, UZ7_ALT " + CRLF
cSql += "HAVING SC5_ALT >= ISNULL(UZ7_ALT,'19960101') " + CRLF //IMPORTA SOMENTE OS PEDIDOS QUE FORAM ALTERADOS APOS A INCLUSцO NA TABELA UZ7
cSql += "ORDER BY C5_FILIAL, C5_NUM " + CRLF
TCQUERY cSql ALIAS "TRB" NEW

//Posiciona no primeiro registro 
TRB->(DbGotop())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava Arquivo de LiberaГЦo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !TRB->(EOF())
	
	UZ7->(DbSetOrder(1))
	
	If UZ7->(DbSeek(TRB->C5_FILIAL+TRB->C5_NUM)) 
		
		UZ7->(RecLock("UZ7", .F.))					
			
			UZ7->UZ7_FILIAL	:= TRB->C5_FILIAL
			UZ7->UZ7_PEDIDO	:= TRB->C5_NUM
			UZ7->UZ7_TIPO	:= TRB->SUBTP	//Tipo de Venda
			UZ7->UZ7_CLIENT	:= TRB->C5_CLIENTE
			UZ7->UZ7_LOJACL	:= TRB->C5_LOJACLI
			UZ7->UZ7_LOJAEN	:= TRB->C5_LOJAENT
			UZ7->UZ7_APROV := TRB->C5_YAPROV
			UZ7->UZ7_AAPROV	:= TRB->C5_YAAPROV
			UZ7->UZ7_NOME	:= TRB->A1_NOME
			UZ7->UZ7_CIDADE	:= TRB->A1_MUN
			UZ7->UZ7_EST := TRB->A1_EST
			UZ7->UZ7_REP := Posicione("SA3",1,xFilial("SA3")+TRB->C5_VEND1,"A3_NREDUZ")
			nVend	:= TRB->C5_VEND1
			nCli :=	TRB->C5_CLIENTE
			nGrpCli	:= Posicione("SA1",1,xFilial("SA1")+TRB->C5_CLIENTE+TRB->C5_LOJACLI,"A1_GRPVEN")
			nProd	:= "AAAAAAAA"	//INFORMAR QUALQUER PRODUTO/LOTE, POIS NAO PODE ACHAR REGRA POR PRODUTO/LOTE
			nSegm	:= Posicione("SA1",1,xFilial("SA1")+TRB->C5_CLIENTE+TRB->C5_LOJACLI,"A1_SATIV1") //TRATAMENTO POR SEGMENTO
			nLote	:= "AAA" 		//INFORMAR QUALQUER PRODUTO/LOTE, POIS NAO PODE ACHAR REGRA POR PRODUTO/LOTE
			dtEmis := TRB->C5_EMISSAO
			nLinha := TRB->C5_YLINHA
			UZ7->UZ7_LINHA := TRB->C5_YLINHA
			UZ7->UZ7_PERCMC := U_fMargem3(TRB->C5_NUM,"2") // CALCULA MARGEM
			UZ7->UZ7_POLITI := TRB->POLITICA
			UZ7->UZ7_MAXCND := TRB->C5_YMAXCND
			UZ7->UZ7_EMISSA := U_STOD(TRB->C5_EMISSAO)
			UZ7->UZ7_CODPAG := TRB->C5_CONDPAG
			UZ7->UZ7_VALDES := TRB->DESCINCON	//Desconto Incondicional
			UZ7->UZ7_DESCLI := U_fBuscaDesconto(nVend,nSegm,nCli,nGrpCli,nProd,nLote,dtEmis,nLinha) //Politica de Desconto Representante / Cliente
			UZ7->UZ7_RECR := TRB->C5_YRECR
			UZ7->UZ7_YPRZIN := TRB->C5_YPRZINC
			UZ7->UZ7_YDTINC := U_STOD(TRB->C5_YDTINC)
			UZ7->UZ7_DESPAG := Posicione("SE4",1,xFilial("SE4")+TRB->C5_CONDPAG,"E4_DESCRI")
			UZ7->UZ7_DESC := TRB->CORRECAO //Media da Correcao
			UZ7->UZ7_MDESPD := TRB->C5_YMDESPD
			UZ7->UZ7_TPBLQ := TRB->C5_YTPBLQ
			UZ7->UZ7_OBS := TRB->C5_YOBS
			UZ7->UZ7_YCONF := TRB->C5_YCONF	// Tiago Rossini - Pedido Conferido - Comercial
			UZ7->UZ7_TPCRED := TRB->C5_YTPCRED	// Ranisses - Tipo de Analise de CrИdito
			UZ7->UZ7_CRDENG := TRB->C5_YCRDENG	// Ranisses - CrИdito de Engenharia  
			
			If UZ7->(FieldPos("UZ7_OBDCOU")) > 0
				
				UZ7->UZ7_OBDCOU	:= TRB->C5_YOBDCOU  // Ranisses
				 
			EndIf
			
			If UZ7->(FieldPos("UZ7_CLVL")) > 0
				
				UZ7->UZ7_CLVL := TRB->C5_YCLVL //Classe Valor
				UZ7->UZ7_ITEMCT := TRB->C5_YITEMCT //Item ContАbil
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
cCadastro := "LiberaГЦo de Pedidos bloqueados na PolitМca Comercial"

//Menu
aRotina   := { 	{"Pesquisar"    ,"AxPesqui"                       	,0,1},;
				{"Visualizar"   ,'ExecBlock("BIA660",.F.,.F.,"V")'	,0,2},;
				{"Liberar"      ,'ExecBlock("BIA319",.F.,.F.,{"L",UZ7->UZ7_PEDIDO})',0,2},;
				{"Recusar"      ,'U_BIA318RC()',0,2},;
				{"Revisar"      ,'U_BIA318RV()',0,2},;
				{"Legenda" 		,'U_BIA318LEG()'					,0,5} }

//Legenda
aCores    := {	{  'Alltrim(UZ7_APROV)=="" '	, 'BR_VERMELHO'} ,;
				{  'Alltrim(UZ7_APROV)<>"" '	, 'BR_VERDE'} } 

//Monta filtro
cFiltro	:= ""


/*If nAusTmp == 1
	//cFiltro += " UZ7_AAPROV	IN "+nAproTmp+"	AND UZ7_APROV = '' "
	//cFiltro += " UZ7_AAPROV	IN "+nAproTmp+"	AND UZ7_APROV = '' "
	cFiltro += " (UZ7_AAPROV	= '" +_NomeAprov+"' OR UZ7_AAPROV	= '" +__cUserID+"')	AND UZ7_APROV = '' "
Else
	cFiltro += " (UZ7_AAPROV	= '" +_NomeAprov+"' OR UZ7_AAPROV	= '" +__cUserID+"')	AND UZ7_APROV = '' "
EndIf
*/


cSqlTemp := IIF (!Empty(cAproTmp) .And. cAproTmp <> "()", " OR UZ7_AAPROV IN "+cAproTmp+"", "") 
cFiltro += " (UZ7_AAPROV	= '" +_NomeAprov+"' OR UZ7_AAPROV	= '" +__cUserID+"' "+cSqlTemp+")	AND UZ7_APROV = '' "


//cSql += "		(SC5.C5_YAAPROV	= '" +_NomeAprov+"'	OR SC5.C5_YAAPROV	= '" +__cUserID+"')	AND " + CRLF

mBrowse(6,1,22,75,"UZ7",,,,,,aCores,,,,,,,,cFiltro)               

Return()

User Function BIA318RC()
   
   	Local oLibBloq 		:= TLiberacaoBloqueioPedidoVenda():New()
	
	oLibBloq:cEmp 		:= cEmpAnt
	oLibBloq:cFil 		:= cFilAnt
	oLibBloq:cNumPed	:= UZ7->UZ7_PEDIDO
	oLibBloq:cCodAprov	:= __cUserID
	oLibBloq:lAprovTemp	:= (AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(__cUserID) .Or. AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(_NomeAprov))
	oLibBloq:cOrigem	:= 'T'
	oLibBloq:lJob		:= .F.
	oLibBloq:cObs		:= ''
	
	oLibBloq:Recusar()
	     
Return()

User Function BIA318RV()
   
	Local cMsg		:= ""
	Local lOk		:= .F.
	Local oLibBloq 	:= TLiberacaoBloqueioPedidoVenda():New()
   
	DEFINE DIALOG oDlg TITLE "Motivo" FROM 180,180 TO 280, 600 PIXEL
	    	
		oTMultiget1	:= TMultiGet():new( 01, 01, {| u | if( pCount() > 0, cMsg := u, cMsg ) }, oDlg, 210, 30, , , , , , .T. )
    	oTButton1 	:= TButton():New(35, 170, "OK", oDlg,{|| lOk:=.T. ,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If (lOk)
		
		If (!Empty(cMsg))
			
			oLibBloq:cEmp 		:= cEmpAnt
			oLibBloq:cFil 		:= cFilAnt
			oLibBloq:cNumPed	:= UZ7->UZ7_PEDIDO
			oLibBloq:cCodAprov	:= __cUserID
			oLibBloq:lAprovTemp	:= (AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(__cUserID) .Or. AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(_NomeAprov))
			oLibBloq:cOrigem	:= 'T'
			oLibBloq:lJob		:= .F.
			oLibBloq:cObs		:= cMsg
			
			oLibBloq:Revisar()
			
		Else
			Alert("Informe uma descriГЦo de recusa do pedido.")
		EndIf
		
	EndIf
   
Return()



//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Rotina do MBrowse fazendo leitura do resultado do Arquivo Temporario     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
User Function BIA318LEG()
   
   aLegenda := { { "BR_VERMELHO",	"Bloqueado" },;
                 { "BR_VERDE"	,   "Liberado"  } }
                 
   BRWLEGENDA( cCadastro, "Legenda", aLegenda )
   
Return()
