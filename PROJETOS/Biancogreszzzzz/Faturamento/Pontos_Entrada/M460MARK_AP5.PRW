#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} M460MARK
@description Ponto de Entrada apos Marcacao dos Itens a serem Faturados
@description Revicoes durante o projeto CICLO DO PEDIDO em 08/2019
@author Ranisses A. Corona  / Fernando Rocha
@since 07/03/02
@version 1.0
@type function
/*/


User Function M460MARK()

	Local lUsaCarga	:= GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga

	Private aArea		:= GetArea()
	Private cArq    	:= ""
	Private cInd    	:= 0
	Private cReg	    := 0
	Private cArqSC9		:= ""
	Private cIndSC9		:= 0
	Private cRegSC9		:= 0	
	Private lRetorno	:= .T.
	Private cSql		:= ""
	Private Enter 		:= CHR(13)+CHR(10)
	Private nPedido		:= ""			//Armazena Numero do Pedido
	Private nSerie		:= Paramixb[3]	//Retona a seria a ser faturada
	Private	lRet		:= .F.
	Private nLimite 	:= GETMV("MV_YLIMFAT")
	Private dEmis		:= dDataBase
	Private aRadioTr	:= {"Calcula Frete Autonomo. ","Não calcula Frete Autonomo. "}
	Private nRadioTr	:= ""
	Private aRadioDp	:= {"Procurar nova Condição de Pagamento.","Manter a mesma Condição de Pagamento."}
	Private nRadioDp	:= ""
	Private xCodTra		:= ""
	Private xNomTra		:= ""
	Private lTelaTr		:= .T. //Variavel para controlar a tela de escolha da Transportadora, que devera ser exibida uma unica vez
	Private	lOkTrans	:= .T. //Variavel para controle da tela Transportorada
	Private oDlgTrans
	Private oDlg
	Private cPedDe		:= nPedDe  //Variavel Publica que vem do P.E. M460QRY
	Private cPedate		:= nPedAte //Variavel Publica que vem do P.E. M460QRY
	Private	nPeso		:= 0                              
	Private nEst		:= ""

	Private _IsAuto := Type("_XCRGATFAT") <> "U" .And. _XCRGATFAT


	//VARIAVEIS PUBLICAS USADAS PARA PASSAR DADOS PARA OUTROS PONTOS DE ENTRADAS/ROTINAS DURANTE O FATURAMENTO
	Public  nTransp		:= ""
	Public  nTpFrete	:= ""
	Public  nFlagFT		:= ""
	Public 	nNovaCond	:= ""

	//Armazena variaveis
	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SC9")
	cArqSC9 := Alias()
	cIndSC9 := IndexOrd()
	cRegSC9 := Recno()

	//Selecina os Pedidos Liberados
	cSql := " SELECT ROUND(C9_QTDLIB2-ROUND(C9_QTDLIB2,0,1),2) AS DIF, * 	" + Enter
	cSql += " FROM "+RetSqlName("SC9")+" AS SC9 							" + Enter
	cSql += " WHERE	C9_FILIAL  	=  '"+xFilial("SC9")+"'	AND	" + Enter
	cSql += "		C9_NFISCAL	=  ''					AND	" + Enter
	cSql += "		C9_AGREG	>= '"+MV_PAR09+"'		AND	" + Enter //Numero Romaneio
	cSql += "		C9_AGREG	<= '"+MV_PAR10+"'		AND	" + Enter //Numero Romaneio
	cSql += "		C9_PEDIDO	>= '"+cPedDe+"'	  		AND	" + Enter //Numero Pedido
	cSql += "		C9_PEDIDO	<= '"+cPedAte+"'		AND	" + Enter //Numero Pedido
	If ThisInv()
		cSql += "		C9_OK	<> '"+ThisMark()+"'			AND " + Enter
	Else
		cSql += "		C9_OK	=  '"+ThisMark()+"'			AND " + Enter
	EndIf
	cSql += "		D_E_L_E_T_	=	''						" + Enter
	If Len(aPedOri) > 0
		cSql += cFilM460QRY									  + Enter
	EndIf
	cSql += "ORDER BY C9_PEDIDO, C9_ITEM 		" + Enter
	If chkfile("_SC9")
		dbSelectArea("_SC9")
		dbCloseArea()
	EndIf
	TcQuery cSql ALIAS "_SC9" NEW

	If _SC9->(EOF())
		MsgBox("Favor verificar os parametros informados!","Atencao","ALERT")
		Return(.F.)
	EndIf

	//Fernando 25/5 - tickekt 4910 - verificando faturamento de produto PR
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_SC9->C9_PRODUTO))

	//Valida vendas BIANCOGRES/INCESA X LM
	//Implementado por Marcos Alberto Soprani em 15/05/13 conforme OS effettivo 0786-13 MV_YVLVDLM
	//Implementado por Ranisses               em 29/06/15 conforme OS effettivo 0090-15 MV_YEXR1R2
	If cEmpAnt == "07" .And. GETMV("MV_YVLVDLM") .And. !ALLTRIM(_SC9->C9_CLIENTE)+ALLTRIM(_SC9->C9_LOJA) $ ALLTRIM(GETMV("MV_YEXR1R2")) .And. !(SB1->B1_TIPO == "PR") .And. !(Posicione("SC5", 1, xFilial("SC5")+ _SC9->C9_PEDIDO,"C5_TIPO") $ "C#I#P")
		
			
		TK004 := " SELECT COUNT(C6_CF) CONTAD
		TK004 += "   FROM "+RetSqlName("SC9")+" SC9
		TK004 += "  INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = '"+xFilial("SC6")+"'
		TK004 += "                       AND C6_NUM = C9_PEDIDO
		TK004 += "                       AND C6_ITEM = C9_ITEM
		TK004 += "                       AND C6_CLI = C9_CLIENTE
		TK004 += "                       AND C6_LOJA = C9_LOJA
		TK004 += "                       AND SUBSTRING(C6_CF,2,3) = '401'
		TK004 += "                       AND SC6.D_E_L_E_T_ = ' '
		TK004 += "  WHERE C9_FILIAL = '"+xFilial("SC9")+"'
		TK004 += "    AND C9_NFISCAL = '         '
		TK004 += "    AND C9_AGREG >= '"+MV_PAR09+"'
		TK004 += "    AND C9_AGREG <= '"+MV_PAR10+"'
		TK004 += "    AND C9_PEDIDO >= '"+cPedDe+"'
		TK004 += "    AND C9_PEDIDO <= '"+cPedAte+"'
		If ThisInv()
			TK004 += "    AND C9_OK <> '"+ThisMark()+"'
		Else
			TK004 += "    AND C9_OK = '"+ThisMark()+"'
		EndIf
		If Len(aPedOri) > 0
			TK004 += cFilM460QRY 
		EndIf
		TK004 += "    AND SC9.D_E_L_E_T_ = ' '
		TkIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TK004),'TK04',.T.,.T.)
		dbSelectArea("TK04")
		dbGoTop()
		If TK04->CONTAD > 0
			Aviso("Atenção (M460MARK)!!!", "Não é permitido faturamento na empresa LM de pedido com CFOP 5401 e suas derivações", {"Ok"})
			TK04->(dbCloseArea())
			Ferase(TkIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(TkIndex+OrdBagExt())          //indice gerado
			Return(.F.)
		EndIf
		TK04->(dbCloseArea())
		Ferase(TkIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TkIndex+OrdBagExt())          //indice gerado

		// Checa venda com entrega por conta e ordem: não controla saldo do pedido de vendas.- Solicitado pelo Robert em 03/06/13 - implementado por Marcos Alberto Soprani
		TK071 := " SELECT COUNT(*) CONTAD
		TK071 += "   FROM "+RetSqlName("SC9")+" SC9
		TK071 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
		TK071 += "                       AND C5_NUM = C9_PEDIDO
		TK071 += "                       AND C5_CLIENTE = C9_CLIENTE
		TK071 += "                       AND C5_LOJACLI = C9_LOJA
		TK071 += "                       AND C5_TIPO NOT IN('B','D')
		// Ajustado filtro para tratamento de complemento de ICMS-ST
		//TK071 += "                       AND C5_YSUBTP = 'R1'
		TK071 += "                       AND ( C5_YSUBTP = 'R1' OR C5_TIPO = 'I' )
		TK071 += "                       AND SC5.D_E_L_E_T_ = ' '
		TK071 += "  WHERE C9_FILIAL = '"+xFilial("SC9")+"'
		TK071 += "    AND C9_NFISCAL = '         '
		TK071 += "    AND C9_AGREG >= '"+MV_PAR09+"'
		TK071 += "    AND C9_AGREG <= '"+MV_PAR10+"'
		TK071 += "    AND C9_PEDIDO >= '"+cPedDe+"'
		TK071 += "    AND C9_PEDIDO <= '"+cPedAte+"'
		If ThisInv()
			TK071 += "    AND C9_OK <> '"+ThisMark()+"'
		Else
			TK071 += "    AND C9_OK = '"+ThisMark()+"'
		EndIf
		If Len(aPedOri) > 0
			TK071 += cFilM460QRY 
		EndIf	
		TK071 += "    AND SC9.D_E_L_E_T_ = ' '	
		TxIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TK071),'TK71',.T.,.T.)
		dbSelectArea("TK71")
		dbGoTop()
		If TK71->CONTAD = 0

			// Implementado por Marcos Alberto Soprani em 17/05/13 conforme OS effettivo 0733-13. Esta regra não atende a OS, mas garante que os dados sejam gerados de forma correta para que o relatório que será gerado.
			HF007 := " SELECT ISNULL((SELECT COUNT(*) " + Enter
			HF007 += "                  FROM "+RetSqlName("SC9")+" SC9 " + Enter
			HF007 += "                 INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"' " + Enter
			HF007 += "                                      AND C5_NUM = C9_PEDIDO " + Enter
			HF007 += "                                      AND C5_CLIENTE = C9_CLIENTE " + Enter
			HF007 += "                                      AND C5_LOJACLI = C9_LOJA " + Enter
			HF007 += "                                      AND C5_TIPO NOT IN('B','D') " + Enter
			HF007 += "                                      AND SC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                 WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + Enter
			HF007 += "                   AND C9_NFISCAL = '         ' " + Enter
			HF007 += "                   AND C9_AGREG >= '"+MV_PAR09+"' " + Enter
			HF007 += "                   AND C9_AGREG <= '"+MV_PAR10+"' " + Enter
			HF007 += "                   AND C9_PEDIDO >= '"+cPedDe+"' " + Enter
			HF007 += "                   AND C9_PEDIDO <= '"+cPedAte+"' " + Enter
			If ThisInv()
				HF007 += "                   AND C9_OK <> '"+ThisMark()+"' " + Enter
			Else
				HF007 += "                   AND C9_OK = '"+ThisMark()+"' " + Enter
			EndIf
			If Len(aPedOri) > 0
				HF007 += cFilM460QRY + Enter 
			EndIf
			HF007 += "                   AND SC9.D_E_L_E_T_ = ' '), 0) " + Enter
			// Verifica na empresa Biancogres
			HF007 += "        -(ISNULL((SELECT COUNT(*) " + Enter
			HF007 += "                    FROM SD2010 XD2 " + Enter
			HF007 += "                   INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01' " + Enter
			HF007 += "                                        AND XC5.C5_NUM = D2_PEDIDO " + Enter
			HF007 += "                                        AND XC5.C5_CLIENTE = D2_CLIENTE " + Enter
			HF007 += "                                        AND XC5.C5_LOJACLI = D2_LOJA " + Enter
			HF007 += "                                        AND XC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                   WHERE XD2.D2_FILIAL = '01' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO = '"+dtos(dDataBase)+"' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO + XC5.C5_YCLIORI " + Enter
			HF007 += "                         + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD " + Enter
			HF007 += "                         + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) IN (SELECT '"+dtos(dDataBase)+"' + (case when C5_CLIENTE in ('025633','025634','025704') then C5_YCLIORI else C5_CLIENTE end) " + Enter
			HF007 += "                                                                                      + C5_LOJACLI + SC5.C5_YPEDORI + C9_PRODUTO " + Enter
			HF007 += "                                                                                      + C9_LOTECTL + CONVERT(VARCHAR, C9_QTDLIB) " + Enter
			HF007 += "                                                                                 FROM "+RetSqlName("SC9")+" SC9 " + Enter
			HF007 += "                                                                                INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"' " + Enter
			HF007 += "                                                                                                     AND C5_NUM = C9_PEDIDO " + Enter
			HF007 += "                                                                                                     AND C5_CLIENTE = C9_CLIENTE " + Enter
			HF007 += "                                                                                                     AND C5_LOJACLI = C9_LOJA " + Enter
			HF007 += "                                                                                                     AND C5_TIPO NOT IN('B','D') " + Enter
			HF007 += "                                                                                                     AND SC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                                                                                WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + Enter
			HF007 += "                                                                                  AND C9_NFISCAL = '         ' " + Enter
			HF007 += "                                                                                  AND C9_AGREG >= '"+MV_PAR09+"' " + Enter
			HF007 += "                                                                                  AND C9_AGREG <= '"+MV_PAR10+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO >= '"+cPedDe+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO <= '"+cPedAte+"' " + Enter
			If ThisInv()
				HF007 += "                                                                                  AND C9_OK <> '"+ThisMark()+"' " + Enter
			Else 
				HF007 += "                                                                                  AND C9_OK = '"+ThisMark()+"' " + Enter
			EndIf
			If Len(aPedOri) > 0
				HF007 += cFilM460QRY + Enter 
			EndIf
			HF007 += "                                                                                  AND SC9.D_E_L_E_T_ = ' ') " + Enter
			HF007 += "                     AND XD2.D_E_L_E_T_ = ' '), 0)
			// Verifica na empresa Incesa
			HF007 += "        + ISNULL((SELECT COUNT(*) " + Enter
			HF007 += "                    FROM SD2050 XD2 " + Enter
			HF007 += "                   INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01' " + Enter
			HF007 += "                                       AND XC5.C5_NUM = D2_PEDIDO " + Enter
			HF007 += "                                       AND XC5.C5_CLIENTE = D2_CLIENTE " + Enter
			HF007 += "                                       AND XC5.C5_LOJACLI = D2_LOJA " + Enter
			HF007 += "                                       AND XC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                   WHERE XD2.D2_FILIAL = '01' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO = '"+dtos(dDataBase)+"' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO + XC5.C5_YCLIORI  " + Enter
			HF007 += "                         + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD " + Enter
			HF007 += "                         + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) IN (SELECT '"+dtos(dDataBase)+"' + (case when C5_CLIENTE in ('025633','025634','025704') then C5_YCLIORI else C5_CLIENTE end) " + Enter
			HF007 += "                                                                                      + C5_LOJACLI + SC5.C5_YPEDORI + C9_PRODUTO " + Enter
			HF007 += "                                                                                      + C9_LOTECTL + CONVERT(VARCHAR, C9_QTDLIB) " + Enter
			HF007 += "                                                                                 FROM "+RetSqlName("SC9")+" SC9	" + Enter
			HF007 += "                                                                                INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"' " + Enter
			HF007 += "                                                                                                     AND C5_NUM = C9_PEDIDO " + Enter
			HF007 += "                                                                                                     AND C5_CLIENTE = C9_CLIENTE " + Enter
			HF007 += "                                                                                                     AND C5_LOJACLI = C9_LOJA " + Enter
			HF007 += "                                                                                                     AND C5_TIPO NOT IN('B','D') " + Enter
			HF007 += "                                                                                                     AND SC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                                                                                WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + Enter
			HF007 += "                                                                                  AND C9_NFISCAL = '         ' " + Enter
			HF007 += "                                                                                  AND C9_AGREG >= '"+MV_PAR09+"' " + Enter
			HF007 += "                                                                                  AND C9_AGREG <= '"+MV_PAR10+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO >= '"+cPedDe+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO <= '"+cPedAte+"' " + Enter
			If ThisInv()
				HF007 += "                                                                                  AND C9_OK <> '"+ThisMark()+"' " + Enter
			Else 
				HF007 += "                                                                                  AND C9_OK = '"+ThisMark()+"' " + Enter
			EndIf
			If Len(aPedOri) > 0
				HF007 += cFilM460QRY + Enter 
			EndIf
			HF007 += "                                                                                  AND SC9.D_E_L_E_T_ = ' ') " + Enter
			HF007 += "                     AND XD2.D_E_L_E_T_ = ' '), 0) " + Enter
			// Verifica na empresa Mundi
			HF007 += "        + ISNULL((SELECT COUNT(*) " + Enter
			HF007 += "                    FROM SD2130 XD2 " + Enter
			HF007 += "                   INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01' " + Enter
			HF007 += "                                       AND XC5.C5_NUM = D2_PEDIDO " + Enter
			HF007 += "                                       AND XC5.C5_CLIENTE = D2_CLIENTE " + Enter
			HF007 += "                                       AND XC5.C5_LOJACLI = D2_LOJA " + Enter
			HF007 += "                                       AND XC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                   WHERE XD2.D2_FILIAL = '01' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO = '"+dtos(dDataBase)+"' " + Enter
			HF007 += "                     AND XD2.D2_EMISSAO + XC5.C5_YCLIORI " + Enter
			HF007 += "                         + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD " + Enter
			HF007 += "                         + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) IN (SELECT '"+dtos(dDataBase)+"' + (case when C5_CLIENTE in ('025633','025634','025704') then C5_YCLIORI else C5_CLIENTE end) " + Enter
			HF007 += "                                                                                      + C5_LOJACLI + SC5.C5_YPEDORI + C9_PRODUTO " + Enter
			HF007 += "                                                                                      + C9_LOTECTL + CONVERT(VARCHAR, C9_QTDLIB) " + Enter
			HF007 += "                                                                                 FROM "+RetSqlName("SC9")+" SC9 " + Enter
			HF007 += "                                                                                INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"' " + Enter
			HF007 += "                                                                                                     AND C5_NUM = C9_PEDIDO " + Enter
			HF007 += "                                                                                                     AND C5_CLIENTE = C9_CLIENTE " + Enter
			HF007 += "                                                                                                     AND C5_LOJACLI = C9_LOJA " + Enter
			HF007 += "                                                                                                     AND C5_TIPO NOT IN('B','D') " + Enter
			HF007 += "                                                                                                     AND SC5.D_E_L_E_T_ = ' ' " + Enter
			HF007 += "                                                                                WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + Enter
			HF007 += "                                                                                  AND C9_NFISCAL = '         ' " + Enter
			HF007 += "                                                                                  AND C9_AGREG >= '"+MV_PAR09+"' " + Enter
			HF007 += "                                                                                  AND C9_AGREG <= '"+MV_PAR10+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO >= '"+cPedDe+"' " + Enter
			HF007 += "                                                                                  AND C9_PEDIDO <= '"+cPedAte+"' " + Enter
			If ThisInv()
				HF007 += "                                                                                  AND C9_OK <> '"+ThisMark()+"' " + Enter
			Else
				HF007 += "                                                                                  AND C9_OK = '"+ThisMark()+"' " + Enter
			EndIf
			If Len(aPedOri) > 0
				HF007 += cFilM460QRY + Enter 
			EndIf
			HF007 += "                                                                                  AND SC9.D_E_L_E_T_ = ' ') " + Enter
			HF007 += "                     AND XD2.D_E_L_E_T_ = ' '), 0) ) SALDO
			HfIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,HF007),'HF07',.T.,.T.)
			dbSelectArea("HF07")
			dbGoTop()
			If HF07->SALDO > 0
				Aviso("Atenção (M460MARK)!!!", "Favor verificar a amarração dos pedidos de vendas da LM com seus respectivos pedidos nas empresas do grupo.", {"Ok"})
				HF07->(dbCloseArea())
				Ferase(HfIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(HfIndex+OrdBagExt())          //indice gerado
				TK71->(dbCloseArea())
				Ferase(TxIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(TxIndex+OrdBagExt())          //indice gerado
				Return(.F.)
			EndIf
			HF07->(dbCloseArea())
			Ferase(HfIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(HfIndex+OrdBagExt())          //indice gerado

		EndIf
		TK71->(dbCloseArea())
		Ferase(TxIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TxIndex+OrdBagExt())          //indice gerado

	EndIf

	//O sistema ira verificar todos os pedidos selecionados
	DbSelectArea("_SC9")
	DbGoTop()
	Do While !_SC9->(EOF())

		//Executa as verificacoes abaixo, uma unica vez para cada Pedido
		If _SC9->C9_PEDIDO <> nPedido
		
			If (!TransLMSP())
				Return(.F.)
			EndIf

			//Posiciona no Pedido do Venda
			cQuery := "SELECT C5_YRECR AS DISTRI, C5_DATA1, C5_DATA2, C5_DATA3, C5_DATA4, C5_DATA5, C5_DATA6, C5_DATA7, C5_DATA8, C5_DATA9, C5_DATAA, C5_DATAB, C5_DATAC, C5_DATAD, C5_DATAE, C5_DATAF, C5_PARC1, C5_PARC2, C5_PARC3, C5_PARC4, C5_PARC5, C5_PARC6, C5_PARC7, C5_PARC8, C5_PARC9, C5_PARCA, C5_PARCB, C5_PARCC, C5_PARCD, C5_PARCE, C5_PARCF, C5_YVLTOTP, C5_TIPO AS TIPO, C5_YLINHA, C5_TABELA, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_TPFRETE, C5_TRANSP, C5_YSUBTP, C5_YPEDPAI, C5_CONDPAG, C5_YPRZINC, C5_YDTINC, C5_YFORMA, C5_YCLIORI, C5_YLOJORI, C5_TIPOCLI FROM "+RetSqlName("SC5")+" SC5 WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+_SC9->C9_PEDIDO+"' AND D_E_L_E_T_ = '' "
			If chkfile("X")
				DbSelectArea("X")
				DbCloseArea()
			EndIf
			TcQuery cQuery Alias "X" New

			//Procura condição de Pagamento para analisar o Tipo = '9'
			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek(xFilial("SE4")+X->C5_CONDPAG,.F.)

			IF SE4->E4_TIPO = '9'
				IF EMPTY(X->C5_PARC1).OR. EMPTY(X->C5_DATA1)
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)
				ELSE
					IF ALLTRIM(SE4->E4_COND) $ '%' .AND. (X->C5_PARC1 + X->C5_PARC2 + X->C5_PARC3 + X->C5_PARC4 + X->C5_PARC5 + X->C5_PARC6 + X->C5_PARC7 + X->C5_PARC8 + X->C5_PARC9 + X->C5_PARCA + X->C5_PARCB + X->C5_PARCC + X->C5_PARCD + X->C5_PARCE + X->C5_PARCF ) <> 100
						MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento corretamente.","Condição de Pagamento")
						Return(.F.)
					ENDIF

					IF ALLTRIM(SE4->E4_COND) <> '%' .AND. (X->C5_PARC1 + X->C5_PARC2 + X->C5_PARC3 + X->C5_PARC4 + X->C5_PARC5 + X->C5_PARC6 + X->C5_PARC7 + X->C5_PARC8 + X->C5_PARC9 + X->C5_PARCA + X->C5_PARCB + X->C5_PARCC + X->C5_PARCD + X->C5_PARCE + X->C5_PARCF ) <> X->C5_YVLTOTP
						MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento corretamente.","Condição de Pagamento")
						Return(.F.)
					ENDIF
				ENDIF

				DO CASE
					CASE (EMPTY(X->C5_PARC1).AND. !EMPTY(X->C5_DATA1)) .OR. (!EMPTY(X->C5_PARC1).AND. EMPTY(X->C5_DATA1))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)
					CASE (EMPTY(X->C5_PARC2).AND. !EMPTY(X->C5_DATA2)) .OR. (!EMPTY(X->C5_PARC2).AND. EMPTY(X->C5_DATA2))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)
					CASE (EMPTY(X->C5_PARC3).AND. !EMPTY(X->C5_DATA3)) .OR. (!EMPTY(X->C5_PARC3).AND. EMPTY(X->C5_DATA3))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)
					CASE (EMPTY(X->C5_PARC4).AND. !EMPTY(X->C5_DATA4)) .OR. (!EMPTY(X->C5_PARC4).AND. EMPTY(X->C5_DATA4))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARC5).AND. !EMPTY(X->C5_DATA5)) .OR. (!EMPTY(X->C5_PARC5).AND. EMPTY(X->C5_DATA5))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARC6).AND. !EMPTY(X->C5_DATA6)) .OR. (!EMPTY(X->C5_PARC6).AND. EMPTY(X->C5_DATA6))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARC7).AND. !EMPTY(X->C5_DATA7)) .OR. (!EMPTY(X->C5_PARC7).AND. EMPTY(X->C5_DATA7))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARC8).AND. !EMPTY(X->C5_DATA8)) .OR. (!EMPTY(X->C5_PARC8).AND. EMPTY(X->C5_DATA8))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARC9).AND. !EMPTY(X->C5_DATA9)) .OR. (!EMPTY(X->C5_PARC9).AND. EMPTY(X->C5_DATA9))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCA).AND. !EMPTY(X->C5_DATAA)) .OR. (!EMPTY(X->C5_PARCA).AND. EMPTY(X->C5_DATAA))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCB).AND. !EMPTY(X->C5_DATAB)) .OR. (!EMPTY(X->C5_PARCB).AND. EMPTY(X->C5_DATAB))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCC).AND. !EMPTY(X->C5_DATAC)) .OR. (!EMPTY(X->C5_PARCC).AND. EMPTY(X->C5_DATAC))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCD).AND. !EMPTY(X->C5_DATAD)) .OR. (!EMPTY(X->C5_PARCD).AND. EMPTY(X->C5_DATAD))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCE).AND. !EMPTY(X->C5_DATAE)) .OR. (!EMPTY(X->C5_PARCE).AND. EMPTY(X->C5_DATAE))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

					CASE (EMPTY(X->C5_PARCF).AND. !EMPTY(X->C5_DATAF)) .OR. (!EMPTY(X->C5_PARCF).AND. EMPTY(X->C5_DATAF))
					MsgAlert("Favor informar as datas e vencimentos dos títulos para esta condição de pagamento.","Condição de Pagamento")
					Return(.F.)

				ENDCASE
			ENDIF

			//Verifica se os itens do pedido esta com o campo C6_YEMP preenchido
			If cEmpAnt $ "01_05_07_13"
				cSql := "SELECT COUNT(*) COUNT							" + Enter
				cSql += "FROM "+RetSqlName("SC6")+" SC6					" + Enter
				cSql += "WHERE	C6_FILIAL  	= '"+xFilial("SC6")+"'	AND " + Enter
				cSql += "		C6_NUM	   	= '"+_SC9->C9_PEDIDO+"'	AND " + Enter
				cSql += "		C6_YEMP 	= '' 					AND " + Enter
				cSql += "		D_E_L_E_T_ 	= '' 						" + Enter
				If chkfile("X2")
					DbSelectArea("X2")
					DbCloseArea()
				EndIf
				TcQuery cSql Alias "X2" New
				If X2->COUNT > 0
					MsgBox("Este pedido possui campos sem preenchimento. Favor informar o setor de TI!","Atencao","ALERT")
					DbSelectArea("X2")
					DbCloseArea()
					Return(.F.)
				EndIf
			EndIf

			//Verifica o tipo de TES do Pedido - Duplicata e Estoque
			cSql := "SELECT MAX(F4_DUPLIC) GERADUPL, MAX(F4_ESTOQUE) ATUEST		" + Enter
			cSql += "FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SF4")+" SF4	" + Enter
			cSql += "WHERE	C6_FILIAL  = '"+xFilial("SC6")+"'	AND " + Enter
			cSql += "		F4_FILIAL  = '"+xFilial("SF4")+"'	AND	" + Enter
			cSql += "		C6_TES     = F4_CODIGO				AND	" + Enter
			cSql += "		C6_NUM	   = '"+_SC9->C9_PEDIDO+"'	AND " + Enter
			cSql += "		SC6.D_E_L_E_T_ = '' 				AND " + Enter
			cSql += "		SF4.D_E_L_E_T_ = '' 					" + Enter
			If chkfile("X2")
				DbSelectArea("X2")
				DbCloseArea()
			EndIf
			TcQuery cSql Alias "X2" New

			//Realiza verificacao de Faturamento com parcela menor que o parametro MV_YLIMFAT
			//Apenas para Produtos PA
			If Alltrim(_SC9->C9_GRUPO) == "PA"

				IF cEmpAnt <> '02'

					//Se o TES gerar DUPLICATA e o Tipo de Pagto for BANCO, é realizado verificacao do Total do Pedido com o parametro de faturamento Minimo (MV_YLIMFAT)
					If X2->GERADUPL == "S" .And. X->C5_YFORMA == "1"
						cSql := " SELECT 	ISNULL(SUM(ROUND((C9_QTDLIB/C6_QTDVEN*100)*C6_YVLIMP/ 100,2)),0) AS VALOR,	" + Enter
						cSql += "			ISNULL(SUM(ROUND((C9_QTDLIB/C6_QTDVEN*100)*C6_YVLTIPI/100,2)),0) AS IPI,		" + Enter
						cSql += "			ISNULL(SUM(ROUND((C9_QTDLIB/C6_QTDVEN*100)*C6_YVLTST/ 100,2)),0) AS ST		" + Enter
						cSql += " FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC9")+" SC9	" + Enter
						cSql += " WHERE	C6_FILIAL	= '"+xFilial("SC6")+"'	AND 			" + Enter
						cSql += "		C9_FILIAL	= '"+xFilial("SC9")+"'	AND 			" + Enter
						cSql += "		C6_NUM		= C9_PEDIDO					AND		" + Enter
						cSql += "		C6_ITEM		= C9_ITEM						AND		" + Enter
						cSql += "		C6_PRODUTO	= C9_PRODUTO			AND		" + Enter
						cSql += "		C9_NFISCAL	= ''							AND		" + Enter
						cSql += "		C9_AGREG	>= '"+MV_PAR09+"'		AND		" + Enter //Numero Romaneio
						cSql += "		C9_AGREG	<= '"+MV_PAR10+"'		AND		" + Enter //Numero Romaneio
						cSql += "		C9_PEDIDO	>= '"+cPedDe+"'			AND		" + Enter //Numero Pedido
						cSql += "		C9_PEDIDO	<= '"+cPedAte+"'		AND		" + Enter //Numero Pedido
						If ThisInv()
							cSql += "		C9_OK	<> '"+ThisMark()+"'	AND 			" + Enter
						Else
							cSql += "		C9_OK	=  '"+ThisMark()+"'	AND 			" + Enter
						EndIf
						cSql += "		SC6.C6_QTDVEN	 > 0		AND							" + Enter //TRATAMENTO PARA PEDIDOS DE COMPLEMENTO DE PRECO
						cSql += "		SC6.D_E_L_E_T_ = ''		AND							" + Enter
						cSql += "		SC9.D_E_L_E_T_ = ''										" + Enter
						If Len(aPedOri) > 0
							cSql += cFilM460QRY + Enter 
						EndIf
						If chkfile("X5")
							DbSelectArea("X5")
							DbCloseArea()
						EndIf
						TcQuery cSql Alias "X5" New

						//Verifica se o Pedido possui Incremento de Vencimento
						If Empty(X->C5_YDTINC)
							If X->C5_YPRZINC > 0
								dEmis	:= dDataBase + X->C5_YPRZINC
							EndIf
						Else
							If Stod(X->C5_YDTINC) > dDataBase
								dEmis	:= dDataBase + (Stod(X->C5_YDTINC) - dDataBase)
							EndIf
						EndIf

						//Verifica se o valor da Parcela e menor que MV_YLIMFAT, considerando as parcelas ja emitidas no mesmo dia
						//Os parametros da funcao fCalculaParcela sao CLIENTE / LOJA / VALOR MERC / COND. PAG. / VALOR IPI / EMISSAO+PRAZO INC / VALOR ICMS ST
						lRet := U_fCalculaParcela(_SC9->C9_CLIENTE,_SC9->C9_LOJA,X5->VALOR,X->C5_CONDPAG,X5->IPI,dEmis,X5->ST)

						If lRet
							//Nao encontrou titulos gerados com a mesma (emissao / tipo / situacao ), o sistema solicita o que deseja fazer
							If nQtdTit == 0
								lOk	:= .T.
								Do While lOk
									@ 0,0 TO 150,320 DIALOG oDlg TITLE "Informações ref. Duplicatas"
									@ 005,010 Say "Não foram encontrados títulos para compor parcela "
									@ 015,010 Say "maior que R$ "+Alltrim(Trans(nLimite,"@E 999.99"))+". "
									@ 028,010 TO 060,150 TITLE "O que deseja fazer?"
									@ 038,020 RADIO aRadioDp VAR nRadioDp
									@ 062,120 BMPBUTTON TYPE 1 ACTION fFecha()
									ACTIVATE DIALOG oDlg CENTER
								EndDo
								//Caso encontre titulos, o sistema busca novas condicoes
							Else
								nRadioDp := 1
							EndIf

							//Procura nova condicao de pagamento
							If nRadioDp == 1
								Posicione("SE4",1,xFilial("SE4")+X->C5_CONDPAG,"E4_CODIGO")
								cQuery := "SELECT *										" + Enter
								cQuery += "FROM "+RetSqlName("SE4")+"					" + Enter
								cQuery += "WHERE E4_FILIAL	= '"+xFilial("SE4")+"'	AND " + Enter
								cQuery += "		 E4_TIPO	= '"+SE4->E4_TIPO+"'	AND	" + Enter
								cQuery += "		 E4_YMEDIA	= '"+Alltrim(Str(SE4->E4_YMEDIA))+"'  AND	" + Enter
								//Tratar condicoes de pagamento por empresa 19/10/10
								If Alltrim(SE4->E4_YREP) == "1"		//Condicoes de Pagamento Biancogres
									cQuery += "		 E4_YREP	= '"+SE4->E4_YREP+"'	AND	" + Enter
								Else															//Condicoes de Pagamento Incesa e Bellacasa
									cQuery += "		 E4_YREP	IN ('2','3')	AND	" + Enter
								EndIf
								cQuery += "		 E4_SOLID	= '"+SE4->E4_SOLID+"'	AND	" + Enter
								cQuery += "		 E4_CODIGO	<> '"+SE4->E4_CODIGO+"'	AND	" + Enter
								cQuery += "		 E4_YATIVO	<> '2'					AND	" + Enter
								cQuery += "		 E4_MSBLQL	<> '1'					AND " + Enter
								cQuery += "		 D_E_L_E_T_	=  ''						" + Enter
								cQuery += "ORDER BY E4_COND								" + Enter
								If chkfile("_SE4")
									dbSelectArea("_SE4")
									dbCloseArea()
								EndIf
								TCQUERY cQuery ALIAS "_SE4" NEW

								//Testa todas as Condicoes Pagamento com os mesmos parametros.
								dbSelectArea("_SE4")
								dbGotop()
								While !Eof() .And. lRet
									lRet := U_fCalculaParcela(_SC9->C9_CLIENTE,_SC9->C9_LOJA,X5->VALOR,_SE4->E4_CODIGO,X5->IPI,dEmis,X5->ST)
									If lRet
										dbSelectArea("_SE4")
										DbSkip()
									EndIf
								Enddo

								//Apos testar todas as Condicoes, pergunta ao Colaborador se deseja continuar.
								If lRet
									If X5->VALOR <= nLimite
										n := MsgBox("Esta NF irá gerar parcela menor que R$ "+Alltrim(Trans(nLimite,"@E 999.99"))+"."+chr(10)+"Durante o dia você irá faturar outras NF deste cliente para compor parcela com valor maior que R$ "+Alltrim(Trans(nLimite,"@E 999.99"))+"? ","Atencao","YesNo")
										If n
											nFlagFT := "S" //Variavel publica utilizado no P.E. SF2460I
										Else
											lRetorno := .F.
											Return(lRetorno)
										EndIf
									Else
										MsgBox("Favor cadastrar nova condicao de pagamento para gerar parcela maior que "+Alltrim(Trans(nLimite,"@E 999.99"))+"!","Atencao","ALERT")
										lRetorno := .F.
										Return(lRetorno)
									EndIf
									//Neste caso o sistema ira sugerir a nova condicao de pagamento.
								Else
									nNovaCond := _SE4->E4_CODIGO //Variavel publica utilizado no P.E. SF2460I
									MsgBox("A Condição de Pagamento será alterada para atender o faturamento mínimo de R$ "+Alltrim(Trans(nLimite,"@E 999.99"))+" por parcela."+chr(10)+"A nova Condição de Pagamento será "+_SE4->E4_CODIGO+" / Venc.:"+_SE4->E4_COND+".","Atencao","ALERT")
								EndIf

								//Mantem a Condicao de Pagamento atual ou finaliza a geracao da NF.
							Else
								n := MsgBox("Esta NF irá gerar parcela menor que R$ "+Alltrim(Trans(nLimite,"@E 999.99"))+". Deseja continuar? ","Atencao","YesNo")
								If n
									nFlagFT := "S" //Variavel publica utilizado no P.E. SF2460I
								Else
									lRetorno := .F.
									Return(lRetorno)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			//Monta janela para Troca da Transportadora e Frete Autonomo - Exibe a tela abaixo uma unica vez por Carga
			If lTelaTr
				If !Alltrim(X->C5_TPFRETE) == "S" .Or. fPedCliFi()

					//Posiciona na Transportadora do Pedido 
					SA4->(DbSetOrder(1))
					SA4->(DbSeek(xFilial("SA4")+X->C5_TRANSP))

					//Armazena informações da Transportadora Original
					xCodTra	 := X->C5_TRANSP
					xNomTra  := SA4->A4_NOME
					nRadioTr := Val(SA4->A4_YTIPO)				
					cTpTrans := SA4->A4_YTIPO 	
					cUFTrans := SA4->A4_EST  				

					//OS 3577-16 - Copiar dados da CARGA para o Faturamento  - Fernando/Facile
					IF (Type("cQNumCarga") <> "U") .And. !Empty(cQNumCarga) .And. (_SC9->C9_CLIENTE <> "010064") 

						_cTabZZV := "% ZZV"+AllTrim(CEMPANT)+"0 %"
						If AllTrim(CEMPANT) == "07"
							IF (Type("cEmpCarga") <> "U") .And. !Empty(cEmpCarga)
								_cTabZZV := "% ZZV"+AllTrim(cEmpCarga)+"0 %"
							ENDIF
						EndIf

						_cAliasTmp := GetNextAlias()
						BeginSql Alias _cAliasTmp
							%NoParser%
							SELECT ZZV_TRANSP, ZZV_CFRETE FROM %Exp:_cTabZZV% 
							WHERE 
								ZZV_CARGA 		= %Exp:cQNumCarga% 
								AND ZZV_FILIAL 	= %Exp:xFilial('ZZV')%  
								AND %NotDel%
						EndSql

						If !(_cAliasTmp)->(Eof())
						

							//Posiciona na Transportadora da carga
							If !Empty((_cAliasTmp)->ZZV_TRANSP)

								SA4->(DbSetOrder(1))
								SA4->(DbSeek(xFilial("SA4")+(_cAliasTmp)->ZZV_TRANSP))

								xCodTra	 := (_cAliasTmp)->ZZV_TRANSP
								xNomTra  := SA4->A4_NOME
								cTpTrans := SA4->A4_YTIPO 	
								cUFTrans := SA4->A4_EST 

								If !Empty((_cAliasTmp)->ZZV_CFRETE)
									nRadioTr := IIF( (_cAliasTmp)->ZZV_CFRETE == "S", 1, 2 )
								Else
									nRadioTr := Val(SA4->A4_YTIPO)
								EndIf

							EndIf

						EndIf
						(_cAliasTmp)->(DbCloseArea())

					ENDIF

					IF (_IsAuto)

						fValTran("2")

					ELSE

						lOkTrans := .T.					
						Do While lOkTrans
							@ 0,0 TO 150,320 DIALOG oDlgTrans TITLE "Alterar Transportadora e Cálculo do Frete Autonomo"				

							@ 005,010 Say "Escolha a Transportadora:"
							@ 015,010 Get xCodTra F3 "SA4" Valid fValTran("1")
							@ 015,050 Say xNomTra Picture "@!" SIZE 100,100 OBJECT oSayMotor					

							@ 033,010 TO 060,150 TITLE "Como será o Calculo do ICMS Frete?"
							@ 040,020 RADIO aRadioTr VAR nRadioTr OBJECT oRadioTr  

							//Ajusta e bloqueia a alteração, de acordo com a necessidade abaixo OS 1617-15
							If (Alltrim(SA4->A4_EST) == "ES" .And. Alltrim(SA4->A4_INSEST) $ "0_1_2_3_4_5_6_7_8_9")
								oRadioTr:LREADONLY := .T.
							Else
								oRadioTr:LREADONLY := .F.
							EndIf 

							@ 061,120 BMPBUTTON TYPE 1 ACTION fSair()
							ACTIVATE DIALOG oDlgTrans CENTER
						EndDo

					ENDIF

					//Atualiza variaveis publicas
					nTransp		:= xCodTra
					nTpFrete	:= nRadioTr
					lTelaTr		:= .F.
				Else
					//Se o campo C5_TPFRETE = "S" permite sem transportadora
					nTransp		:= "" //Sem transportadora
					nTpFrete	:= 2  //Nao Calcula Frente
					lTelaTr		:= .F.
				EndIf
			EndIf

			//Se calcula ICMS Frete Autonomo, o produto tem que ter o PESO no cadastro
			If nTpFrete == 1
				//Busca peso no cadastro de PRODUTO/LOTE
				_ZZ9 := GetNextAlias()
				BeginSql Alias _ZZ9
					SELECT * FROM ZZ9010 WHERE ZZ9_PRODUT = %Exp:_SC9->C9_PRODUTO% AND ZZ9_LOTE = %Exp:_SC9->C9_LOTECTL% AND %NOTDEL%
				EndSql

				//Busca peso no cadastro de PRODUTO
				_SB1 := GetNextAlias()
				BeginSql Alias _SB1
					SELECT B1_COD, B1_PESO, B1_YPESEMB, B1_TIPCONV, B1_CONV FROM SB1010 WHERE	B1_COD = %Exp:_SC9->C9_PRODUTO% AND %NOTDEL%
				EndSql

				If !(_ZZ9)->(EOF())
					nPeso		 	:= (_ZZ9)->ZZ9_PESO
				Else
					nPeso		 	:= (_SB1)->B1_PESO
				EndIf
				(_ZZ9)->(dbCloseArea())
				(_SB1)->(dbCloseArea())

				If nPeso == 0
					MsgBox("O produto "+_SC9->C9_PRODUTO+" não possui PESO cadastrado no sistema, sendo este necessário para efetuar o cálculo do ICMS Frete Autonomo. Favor alterar o cadastro do produto, antes de continuar o faturamento!","M460MARK","STOP")
					lRetorno := .F.
					Return(lRetorno)
				EndIf
			EndIf

			//Verifica se e Venda ou Devolucao, verificando se o Cliente/Fornecedor esta bloqueado ou liberado para faturamento
			If X->TIPO $ "D_B"
				cQuery := "SELECT * FROM "+RetSqlName("SA2")+" SA1 WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '"+_SC9->C9_CLIENTE+"' AND A2_LOJA = '"+_SC9->C9_LOJA+"' AND D_E_L_E_T_ = '' "
			Else
				cQuery := "SELECT A1_EST, A1_YDTVENC, A1_CONTRIB, A1_MSBLQL, A1_YATUCLI FROM "+RetSqlName("SA1")+" SA1 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+_SC9->C9_CLIENTE+"' AND A1_LOJA = '"+_SC9->C9_LOJA+"' AND D_E_L_E_T_ = '' "
			EndIf
			If chkfile("X1")
				DbSelectArea("X1")
				DbCloseArea()
			EndIf
			TcQuery cQuery Alias "X1" New

			//Se for Devolucao/Bonificao considera o cadastro de Fornecedor
			If X->TIPO $ "D_B"
				nEst := X1->A2_EST

				//Teste se o Fornecedor esta Bloqueado ou Desatualizado
				If X1->A2_MSBLQL == '1' .OR. X1->A2_YATUFOR <> 'S'
					MsgBox("Este fornecedor esta bloqueado para faturamento. Favor atualizar o cadastro!","Atencao","ALERT")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

			Else
				nEst := X1->A1_EST

				//Testa Data de Declaracao de Contribuinte
				IF X1->A1_CONTRIB == '1'
					IF !EMPTY(X1->A1_YDTVENC) .AND. X1->A1_YDTVENC < DTOS(DDATABASE)
						MsgBox("A data de vencimento da declaracao de contribuinte esta vencida. Realize o ajuste para continuar!","Atencao","ALERT")
						lRetorno := .F.
						Return(lRetorno)
					ENDIF
				ENDIF

				//Teste se o Cliente esta Bloqueado ou Desatualizado
				If X1->A1_MSBLQL == '1' .OR. X1->A1_YATUCLI <> 'S'
					MsgBox("Este cliente esta bloqueado para faturamento. Favor atualizar o cadastro!","Atencao","ALERT")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

				//A partir de 01/01/12 não será permite faturamento para Distribuidores
				If Alltrim(X->DISTRI) == "S"
					MsgBox("Atencao! Não é permitido faturamento para Clientes Distribuidores. Favor verificar com o Setor de TI!","Atencao","ALERT")
					lRetorno := .F.
					Return(lRetorno)
				EndIf
			EndIf

		EndIf


		//Verifica os Itens liberados para Faturamento analisando a consistencia de SB2 X SBF X SB8 X SC9 X SDC
		//Verifica se existe MVA para este NCM/UF/GRP. TRIBUTACAO
		If !(Alltrim(X->TIPO)) $ "D_B" .And. Alltrim(X->C5_TIPOCLI) == "S" .And. Alltrim(_SC9->C9_GRUPO) == "PA"
			nNCM	:= Posicione("SB1",1,xFilial("SB1")+ALLTRIM(_SC9->C9_PRODUTO),"B1_POSIPI")
			nGRTRIB	:= Posicione("SB1",1,xFilial("SB1")+ALLTRIM(_SC9->C9_PRODUTO),"B1_GRTRIB")
			If !U_fBuscaMVA(nNCM,nEst,nGRTRIB,dDataBase)[1]
				Return(.F.)
			EndIf
		EndIf

		//PROJETO2014
		If (U_fValidaRA(X->C5_CONDPAG) .Or. Alltrim(X->C5_CONDPAG) $ "145_975") //.And. !GetMv("MV_YVLDRA") .And. !Empty(Alltrim(_SC9->C9_AGREG)) DESATIVADO PARA FORCAR VERIFICACAO DO RA
			//0 ou vazio => Sem classificação
			//1			 => Liberado
			//2          => Sem saldo
			//3          => Estornado		        
			If Alltrim(_SC9->C9_YRASTAT) <> "1" 
				MsgBox("->PEDIDO "+_SC9->C9_PEDIDO+" ->PRODUTO "+ALLTRIM(_SC9->C9_PRODUTO)+Chr(10)+Chr(13)+"ESTE PEDIDO ESTÁ BLOQUEADO PARA FATURAMENTO, POIS O SALDO DE RA É INSUFICIENTE!","M460MARK","STOP")		
				Return(.F.)
			EndIf

		EndIf


		//Verifica se Quantidade de Caixas esta correta
		If Alltrim(_SC9->C9_GRUPO) == "PA" .AND. _SC9->DIF <> 0 .AND. !_SC9->C9_LOCAL == "05" .AND. cEmpAnt <> '14'
			MsgBox("A quantidade de Caixas para o Pedido "+_SC9->C9_PEDIDO+ " está incorreta. Favor comunicar a TI!","Atencao","ALERT")
			Return(.F.)
		EndIf

		//Fernando/Facile em 19/11/2015 - Nao permitir faturar itens com preço SC9 <> SC6 quando nao houver desconto incondicional
		SC6->(dbSetOrder(1))
		If 	SC6->(dbSeek(xFilial("SC6")+_SC9->C9_PEDIDO+_SC9->C9_ITEM)) .And.;
		SC6->C6_DESCONT == 0 .And.;
		SC6->C6_PRCVEN <> _SC9->C9_PRCVEN

			MsgBox("Pedido "+_SC9->C9_PEDIDO+ ", Item "+_SC9->C9_ITEM+Chr(10)+Chr(13)+"O PREÇO DE VENDA da Liberação está diferente do Pedido!","Atenção","ALERT")
			Return(.F.)	
		EndIf

		//Realiza verificacao apenas para Pedidos com Tipo = Normal
		If X->TIPO == "N" .And. !Alltrim(_SC9->C9_AGREG) $ "EUIX" //"ETSZ" //"ETHE"  //!Alltrim(_SC9->C9_PEDIDO) $ "M01323" //!Alltrim(_SC9->C9_AGREG) $ //"ESRN#ESSF"  //"ESF2#ESEZ#ESC5"

			//Somente para PA
			If Alltrim(_SC9->C9_GRUPO) <> "PA"
				_SC9->(DBSKIP())
				Loop
			EndIf                      

			//Fernando/Facile em 14/07/15 - retirar mensagem de tabela de preco para produto comum
			_lComum := .F.
			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek(xFilial("SBZ")+_SC9->C9_PRODUTO)) .And. SBZ->BZ_YCOMUM == "S"
				_lComum := .T.
			EndIf 

			//Verifica se existe Tabela de Preco Cadastrada para este Produto 
			If !Alltrim(X->C5_YSUBTP) $ "RR_RQ" .And. !_lComum //UTILIZADO APENAS PARA EMPRESA VITCER
				SC6->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+_SC9->C9_PEDIDO+_SC9->C9_ITEM)) .And. SC6->C6_YPRCTAB == 0
					MsgBox("Atencao! O produto "+Alltrim(_SC9->C9_PRODUTO)+" não está cadastrado na tabela de preço!","M460MARK","ALERT")
					lRetorno := .F.
					Return(lRetorno)
				EndIf
			EndIf

			//Verifica se o Pedido é R2 e se já faturou o Pedido Pai - Madaleno em 09/12/08
			IF ALLTRIM(X->C5_YSUBTP) $ "R2/R3"
				LLRET := U_VER_R1_R2(X->C5_YPEDPAI)
				IF !LLRET
					//MsgBox("Atencao! O produto "+Alltrim(_SC9->C9_PRODUTO)+" não está cadastrado na tabela de preço!","Atencao","ALERT")
					MsgBox("Atenção, favor verificar pois este pedido já foi utilizado no processo R1/R2!","M460MARK","ALERT")			
					RETURN(LLRET)
				ENDIF
			ENDIF

			If X2->ATUEST == "S"
				//Testa se os Totais do Produto estao corretos
				//Saldo Total
				cSql := "SELECT B2_COD, B2_QATU, B2_RESERVA				" + Enter
				cSql += "FROM "+RetSqlName("SB2")+" SB2					" + Enter
				cSql += "WHERE B2_FILIAL  = '"+xFilial("SB2")+"'	AND " + Enter
				cSql += "	   B2_COD 	  = '"+_SC9->C9_PRODUTO+"' 	AND	" + Enter
				cSql += "	   B2_LOCAL		= '"+_SC9->C9_LOCAL+"' 		AND	" + Enter
				cSql += "	   B2_QATU	  > 0						AND	" + Enter
				cSql += "      D_E_L_E_T_ = ''							" + Enter
				If chkfile("_SB2")
					DbSelectArea("_SB2")
					DbCloseArea()
				EndIf
				TcQuery cSql Alias "_SB2" New

				//Saldo por Localizacao
				cSql := "SELECT SUM(BF_QUANT) QUANT, SUM(BF_EMPENHO) EMPENHO " + Enter
				cSql += "FROM "+RetSqlName("SBF")+" SBF					" + Enter
				cSql += "WHERE BF_FILIAL  = '"+xFilial("SBF")+"'		AND	" + Enter
				cSql += "      BF_PRODUTO = '"+_SC9->C9_PRODUTO+"'	AND	" + Enter
				cSql += "      BF_LOCAL   = '"+_SC9->C9_LOCAL+"' 		AND	" + Enter
				cSql += "      D_E_L_E_T_ = ''							" + Enter
				If chkfile("_SBF")
					DbSelectArea("_SBF")
					DbCloseArea()
				EndIf
				TcQuery cSql Alias "_SBF" New

				//Saldo a Distribuir
				cSql := "SELECT SUM(DA_SALDO) QUANT						" + Enter
				cSql += "FROM "+RetSqlName("SDA")+" SDA					" + Enter
				cSql += "WHERE DA_FILIAL = '"+xFilial("SDA")+"'		AND	" + Enter
				cSql += "	   DA_PRODUTO = '"+_SC9->C9_PRODUTO+"'	AND	" + Enter
				cSql += "	   DA_LOCAL   = '"+_SC9->C9_LOCAL+"'		AND	" + Enter
				cSql += "	   DA_SALDO > 0 						AND " + Enter
				cSql += "	   D_E_L_E_T_ = ''							" + Enter
				If chkfile("_SDA")
					DbSelectArea("_SDA")
					DbCloseArea()
				EndIf
				TcQuery cSql Alias "_SDA" New

				//Saldo por Lote
				cSql := "SELECT SUM(B8_SALDO) QUANT, SUM(B8_EMPENHO) EMPENHO " + Enter
				cSql += "FROM "+RetSqlName("SB8")+" SB8										" + Enter
				cSql += "WHERE	B8_FILIAL 	= '"+xFilial("SB8")+"'		AND	" + Enter
				cSql += "				B8_PRODUTO	= '"+_SC9->C9_PRODUTO+"'	AND " + Enter
				cSql += "				B8_LOCAL  	= '"+_SC9->C9_LOCAL+"'		AND " + Enter
				cSql += "				D_E_L_E_T_	= ''													" + Enter
				If chkfile("_SB8")
					DbSelectArea("_SB8")
					DbCloseArea()
				EndIf
				TcQuery cSql Alias "_SB8" New

				//Verifica se o Empenho SB2 X SBF X SB8 estao correto
				If (_SB2->B2_RESERVA + _SBF->EMPENHO + _SB8->EMPENHO)/3 <> _SB2->B2_RESERVA
					MsgAlert("Divergencia entre os EMPENHOS do Produto "+Alltrim(_SC9->C9_PRODUTO)+" (SB2 x SBF x SB8). Favor entrar em contato com o setor de Informática!")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

				cSql := ""
				cSql := "SELECT BF_PRODUTO, BF_LOCAL, BF_LOTECTL, ROUND(SUM(BF_QUANT),2) BF_QUANT, " + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(B8_SALDO),2)   FROM "+RetSqlName("SB8")+" WHERE B8_FILIAL = '"+xFilial("SB8")+"' AND B8_PRODUTO = BF_PRODUTO AND B8_LOTECTL = BF_LOTECTL AND B8_LOCAL = BF_LOCAL AND D_E_L_E_T_ = '' AND B8_SALDO <> 0),0) B8_SALDO,		" + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(B8_EMPENHO),2) FROM "+RetSqlName("SB8")+" WHERE B8_FILIAL = '"+xFilial("SB8")+"' AND B8_PRODUTO = BF_PRODUTO AND B8_LOTECTL = BF_LOTECTL AND B8_LOCAL = BF_LOCAL AND D_E_L_E_T_ = '' AND B8_SALDO > 0),0) B8_EMPENHO,	" + Enter
				cSql += "		ROUND(SUM(BF_EMPENHO),2) BF_EMPENHO, " + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(DA_SALDO),2)   FROM "+RetSqlName("SDA")+" WHERE DA_FILIAL = '"+xFilial("SDA")+"' AND DA_PRODUTO = BF_PRODUTO AND DA_LOTECTL = BF_LOTECTL AND DA_LOCAL = BF_LOCAL AND DA_SALDO > 0 AND D_E_L_E_T_ = ''),0) DA_SALDO, " + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(C0_QUANT),2)   FROM "+RetSqlName("SC0")+" WHERE C0_FILIAL = '"+xFilial("SC0")+"' AND C0_PRODUTO = BF_PRODUTO AND C0_LOTECTL = BF_LOTECTL AND C0_LOCAL = BF_LOCAL AND D_E_L_E_T_ = ''),0) C0_QUANT, " + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(C9_QTDLIB),2)  FROM "+RetSqlName("SC9")+" WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PRODUTO = BF_PRODUTO AND C9_LOTECTL = BF_LOTECTL AND C9_LOCAL = BF_LOCAL AND C9_NFISCAL = '' AND D_E_L_E_T_ = ''),0) C9_QTDLIB,	" + Enter
				cSql += "		ISNULL((SELECT ROUND(SUM(DC_QUANT),2)   FROM "+RetSqlName("SDC")+" WHERE DC_FILIAL = '"+xFilial("SDC")+"' AND DC_PRODUTO = BF_PRODUTO AND DC_LOTECTL = BF_LOTECTL AND DC_LOCAL = BF_LOCAL AND D_E_L_E_T_ = ''),0) DC_QUANT " + Enter
				cSql += "FROM "+RetSqlName("SBF")+" SBF 				" + Enter
				cSql += "WHERE BF_FILIAL  = '"+xFilial("SBF")+"'	AND " + Enter
				cSql += "	   	BF_PRODUTO = '"+_SC9->C9_PRODUTO+"'	AND " + Enter
				cSql += "		BF_LOTECTL = '"+_SC9->C9_LOTECTL+"'	AND " + Enter
				cSql += "		BF_LOCAL   = '"+_SC9->C9_LOCAL+"'	AND " + Enter
				cSql += "		D_E_L_E_T_ = ''							" + Enter
				cSql += "GROUP BY BF_PRODUTO, BF_LOCAL, BF_LOTECTL	" + Enter
				If chkfile("_RAN")
					dbSelectArea("_RAN")
					dbCloseArea()
				EndIf
				TCQuery cSql Alias "_RAN" New

				If _RAN->BF_QUANT+_RAN->DA_SALDO <> _RAN->B8_SALDO
					MsgAlert("Saldo do Produto "+Alltrim(_SC9->C9_PRODUTO)+" por Localização (SBF) é diferente do Saldo por Lote (SB8). Favor entrar em contato com o setor de Informática!")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

				If _RAN->BF_EMPENHO <> _RAN->B8_EMPENHO
					MsgAlert("Divergencia nos Empenhos do Produto "+Alltrim(_SC9->C9_PRODUTO)+" entre Localização (SBF) e Lote (SB8). Favor entrar em contato com o setor de Informática!")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

				If _RAN->DC_QUANT <> (_RAN->C0_QUANT+_RAN->C9_QTDLIB)
					MsgAlert("Divergencia nos Empenhos do Produto "+Alltrim(_SC9->C9_PRODUTO)+" entre Pedidos Liberados e Reserva. Favor entrar em contato com o setor de Informática!")
					lRetorno := .F.
					Return(lRetorno)
				EndIf

				//Verifica Romaneio somente para Produtos diferente de Amostra
				//Empresa14 - por Marcos Alberto Soprani em 18/09/13.
				//Empresa diferente de 07 pq LM passou a usar carga para manta - Fernando - ticket 4910 em 07/07/18
				If _SC9->C9_LOCAL <> "05" .And. lUsaCarga .And. AllTrim(CEMPANT) <> "07"  //Define se utiliza a rotina de carga

					//Verifica consistencia entre os Itens Liberados x Empenho x Romaneio
					cSql := ""
					cSql := "SELECT SUM(DC_QUANT) AS QUANT						" + Enter
					cSql += "FROM "+RetSqlName("SDC")+" SDC 					" + Enter
					cSql += "WHERE	DC_FILIAL	= '"+xFilial("SDC")+"'	 AND	" + Enter
					cSql += "		DC_PEDIDO	= '"+_SC9->C9_PEDIDO+"'	 AND	" + Enter
					cSql += "		DC_PRODUTO	= '"+_SC9->C9_PRODUTO+"' AND	" + Enter
					cSql += "		DC_LOTECTL	= '"+_SC9->C9_LOTECTL+"' AND	" + Enter
					cSql += "		DC_ITEM     = '"+_SC9->C9_ITEM+"'	 AND	" + Enter
					cSql += "		DC_SEQ      = '"+_SC9->C9_SEQUEN+"'	 AND	" + Enter
					cSql += "		D_E_L_E_T_	= ''							" + Enter
					If chkfile("X3")
						dbSelectArea("X3")
						dbCloseArea()
					EndIf
					TCQuery cSql Alias "X3" New

					cSql := ""
					cSql := "SELECT SUM(Z9_QTDLIB) AS QUANT						" + Enter
					cSql += "FROM "+RetSqlName("SZ9")+" SZ9  					" + Enter
					cSql += "WHERE	Z9_FILIAL   = '"+xFilial("SZ9")+"'	 AND	" + Enter
					cSql += "		Z9_PEDIDO	= '"+_SC9->C9_PEDIDO+"'  AND 	" + Enter
					cSql += "		Z9_PRODUTO	= '"+_SC9->C9_PRODUTO+"' AND	" + Enter
					cSql += "		Z9_LOTECTL	= '"+_SC9->C9_LOTECTL+"' AND	" + Enter
					cSql += "		Z9_AGREG 	= '"+_SC9->C9_AGREG+"'	 AND	" + Enter
					cSql += "		Z9_ITEM		= '"+_SC9->C9_ITEM+"'	 AND	" + Enter
					cSql += "		Z9_SEQUEN	= '"+_SC9->C9_SEQUEN+"'  AND	" + Enter
					cSql += "		D_E_L_E_T_	= ''
					If chkfile("X4")
						dbSelectArea("X4")
						dbCloseArea()
					EndIf
					TCQuery cSql Alias "X4" New

					//If (_SC9->C9_QTDLIB + X3->QUANT + X4->QUANT)/3 <> _SC9->C9_QTDLIB
					If (_SC9->C9_QTDLIB <> X3->QUANT) .OR. (_SC9->C9_QTDLIB <> X4->QUANT)
						MsgAlert("Divergência no produto "+Alltrim(_SC9->C9_PRODUTO)+", nas tabelas de Carga e Romaneio. Favor alterar a carga para regravar os itens do romaneio!", "M460MARK")
						MsgAlert("Após este procedimento, favor realizar o faturamento novamente!", "M460MARK")
						lRetorno := .F.
						Return(lRetorno)
					EndIf

					//Verifica consistencia entre os Itens Liberados x Empenho x Romaneio
					cSql := ""
					cSql := "SELECT DC_PEDIDO, DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ, SUM(DC_QUANT) AS QUANT " + Enter
					cSql += "FROM "+RetSqlName("SDC")+" SDC 								" + Enter
					cSql += "WHERE	DC_FILIAL   = '"+xFilial("SDC")+"'	AND	" + Enter
					cSql += "		DC_PEDIDO		= '"+_SC9->C9_PEDIDO+"'	 		AND	" + Enter
					cSql += "		DC_PRODUTO	= '"+_SC9->C9_PRODUTO+"' 		AND	" + Enter
					cSql += "		DC_LOTECTL	= '"+_SC9->C9_LOTECTL+"' 		AND	" + Enter
					cSql += "		DC_ITEM     = '"+_SC9->C9_ITEM+"'	 			AND	" + Enter
					cSql += "		DC_SEQ      = '"+_SC9->C9_SEQUEN+"'	 		AND	" + Enter
					cSql += "		D_E_L_E_T_	= ''														" + Enter
					cSql += "GROUP BY DC_PEDIDO, DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ " + Enter
					If chkfile("X5")
						dbSelectArea("X5")
						dbCloseArea()
					EndIf
					TCQuery cSql Alias "X5" New

					Do While ! X5->(EOF())

						cSql := ""
						cSql := "SELECT SUM(Z9_QTDLIB) AS QUANT									" + Enter
						cSql += "FROM "+RetSqlName("SZ9")+" SZ9  								" + Enter
						cSql += "WHERE	Z9_FILIAL   = '"+xFilial("SZ9")+"'	AND	" + Enter
						cSql += "		Z9_PEDIDO		= '"+X5->DC_PEDIDO+"'				AND	" + Enter
						cSql += "		Z9_PRODUTO	= '"+X5->DC_PRODUTO+"'			AND	" + Enter
						cSql += "		Z9_LOTECTL	= '"+X5->DC_LOTECTL+"'			AND	" + Enter
						cSql += "		Z9_LOCALIZ	= '"+X5->DC_LOCALIZ+"'			AND	" + Enter
						cSql += "		Z9_ITEM			= '"+_SC9->C9_ITEM+"'				AND	" + Enter
						cSql += "		Z9_SEQUEN		= '"+_SC9->C9_SEQUEN+"'			AND	" + Enter
						cSql += "		Z9_AGREG 		= '"+_SC9->C9_AGREG+"'			AND	" + Enter
						cSql += "		D_E_L_E_T_	= ''
						If chkfile("X6")
							dbSelectArea("X6")
							dbCloseArea()
						EndIf
						TCQuery cSql Alias "X6" New
						If X5->QUANT <> X6->QUANT
							MsgAlert("Divergencia no produto "+Alltrim(_SC9->C9_PRODUTO)+" entre a Localização do Empenho (SDC) e o Romaneio (SZ9). Favor entrar em contato com o setor de Informática!")
							lRetorno := .F.
							Return(lRetorno)
						EndIf

						X5->(DBSKIP())

					End Do
				EndIf
			EndIf
		EndIf

		//Grava o numero do proximo Pedido
		nPedido := _SC9->C9_PEDIDO

		//Muda para o proximo regisro do SC9
		_SC9->(DBSKIP())

	End Do

	//Apaga area de trabalho
	If chkfile("X")
		DbSelectArea("X")
		DbCloseArea("X")
	EndIf

	If chkfile("X1")
		DbSelectArea("X1")
		DbCloseArea("X1")
	EndIf

	If chkfile("X2")
		DbSelectArea("X2")
		DbCloseArea("X2")
	EndIf

	If chkfile("X3")
		DbSelectArea("X3")
		DbCloseArea("X3")
	EndIf

	If chkfile("X4")
		DbSelectArea("X4")
		DbCloseArea("X4")
	EndIf

	If chkfile("X5")
		DbSelectArea("X5")
		DbCloseArea("X5")
	EndIf

	If chkfile("X6")
		DbSelectArea("X6")
		DbCloseArea("X6")
	EndIf

	If chkfile("X7")
		DbSelectArea("X7")
		DbCloseArea("X7")
	EndIf

	If chkfile("_SB2")
		DbSelectArea("_SB2")
		DbCloseArea("_SB2")
	EndIf

	If chkfile("_SBF")
		DbSelectArea("_SBF")
		DbCloseArea("_SBF")
	EndIf

	If chkfile("_SB8")
		DbSelectArea("_SB8")
		DbCloseArea("_SB8")
	EndIf

	If chkfile("_RAN")
		DbSelectArea("_RAN")
		DbCloseArea("_RAN")
	EndIf

	//Volta posicionamento
	DbSelectArea(cArqSC9)
	DbSetOrder(cIndSC9)
	DbGoTo(cRegSC9)

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	RestArea(aArea)

Return(lRetorno)

Static Function TransLMSP()
	
	Local _cQuery 		:= ""
	Local _cAliasTmp	:= Nil
	Local _lRet			:= .T.
	Local _cDataEmis	:= ""
	Local _cMensagem	:= ""
	Local _lPed			:= .F.
	Local _cMsgProd		:= ""
	
	If Alltrim(_SC9->C9_GRUPO) == "PA"
		
		If (cEmpAnt == '13' .And. AllTrim(_SC9->C9_CLIENTE) == '010064') .Or. (cEmpAnt == '07' .And. AllTrim(_SC9->C9_CLIENTE) == '029954')
		
			_cQuery := " SELECT C5_EMISSAO FROM "+RetSqlName("SC5")+" 											"
			_cQuery += " WHERE	C5_FILIAL  	= '"+xFilial("SC5")+"'						AND 					" 
			_cQuery += "		C5_NUM	   	= '"+_SC9->C9_PEDIDO+"'						AND 					"
			_cQuery += "		(C5_CLIENTE = '029954' OR C5_YCLIORI = '029954')		AND 					"
			_cQuery += "		C5_YLINHA 	= '6'										AND 					"
			_cQuery += "		C5_TIPO 	= 'N'										AND 					" 
			_cQuery += "		D_E_L_E_T_ 	= '' 																" 
			
			_cAliasTmp	:= GetNextAlias()
			
			TCQUERY _cQuery NEW ALIAS (_cAliasTmp)	
			
			If !(_cAliasTmp)->(Eof())
				
				_lPed := .T.
				
				If (Date() > stod((_cAliasTmp)->C5_EMISSAO))
					
					_cDataEmis	:= dtoc(stod((_cAliasTmp)->C5_EMISSAO))
					_cMensagem	:= "A data de faturamento de pedido de transferência Cliente: (029954 - LM SP) precisa ser igual a data do pedido. Pedido: "+_SC9->C9_PEDIDO+", Data Emissão "+_cDataEmis+"."
					
					Msgbox(_cMensagem, "M460MARK","STOP")
					
					_lRet := .F.
				EndIf
				
			EndIf
			
			(_cAliasTmp)->(DbCloseArea())
			
			If (cEmpAnt == '07' .And. _lPed)
				
				//verificar problema de arredondamento
				
				_cQuery := " SELECT C6_PRODUTO FROM "+RetSqlName("SC6")+"  SC6										"
				_cQuery += " JOIN "+RetSqlName("SB2")+" SB2 ON 														"	
				_cQuery += "	B2_COD = C6_PRODUTO			AND 													"
				_cQuery += "	B2_FILIAL = C6_FILIAL		AND 													"
				_cQuery += "	B2_LOCAL = C6_LOCAL			AND														"
				_cQuery += "	SB2.D_E_L_E_T_ = ''																	"
				_cQuery += " WHERE	C6_FILIAL  	= '"+xFilial("SC6")+"'						AND 					" 
				_cQuery += "		C6_NUM	   	= '"+_SC9->C9_PEDIDO+"'						AND 					"
				_cQuery += "		C6_CLI	  = '029954'									AND 					"
				//_cQuery += "		C6_PRCVEN <> C9_PRCVEN 									AND						" 
				_cQuery += "  		(ROUND(C6_PRCVEN, 2, 1) - ROUND(B2_CM1, 2, 1)) > 0.05	AND						"
				
				_cQuery += "		SC6.D_E_L_E_T_ 	= '' 															" 
				
				_cAliasTmp	:= GetNextAlias()
				
				TCQUERY _cQuery NEW ALIAS (_cAliasTmp)	
				
				_cMensagem	:= "Produtos com divergência de preço. Favor acesso o pedido: "+_SC9->C9_PEDIDO+" e corrigir os preços produtos abaixos: "
				_cMsgProd	:= ""	
				While !(_cAliasTmp)->(Eof())
					
					_lRet := .F.
					
					If (!Empty(_cMsgProd))
						_cMsgProd += ", "	
					EndIf
					
					_cMsgProd += AllTrim((_cAliasTmp)->C6_PRODUTO)
					
					(_cAliasTmp)->(DbSkip())
					
				EndDo
				
				If (!_lRet)
					Msgbox(_cMensagem, "M460MARK","STOP")
				EndIf
				
				(_cAliasTmp)->(DbCloseArea())
				
			EndIf
			
		EndIf
		
	EndIf


Return _lRet


//fValTran
Static Function fValTran(nTipo)
	//nTipo = "1" //Validação do F3
	//nTipo = "2" //Validação do OK
	Local lRet 		:= .T.
	Local lCalcOld	:= .F. //Calcula Frete Automono baseado na Transportador original do PV
	Local lCalcNew	:= .F. //Calcula Frete Automono baseado na Transportador escolhida na Tela
	Local cMsgOld	:= "NÃO CALCULA FRETE AUTÔNOMO"
	Local cMsgNew	:= "NÃO CALCULA FRETE AUTÔNOMO"
	Local _aPeds	:=	{}
	Local _nI

	//Testa se o campo está vazio
	If Empty(xCodTra) .And. lRet
		MsgBox("Informe uma Transportadora.","M460MARK","ALERT")
		lRet := .F.
	Endif

	//Posiciona na Transportadora selecionada. 
	SA4->(DbSetOrder(1))
	SA4->(DbSeek(xFilial("SA4")+xCodTra))

	//Verifica se a Transportadora esta bloqueada para uso
	If ( Alltrim(xCodTra) $ "000051_000052_000000_000078_000079" .Or. SA4->A4_MSBLQL == "1" ) .And. lRet
		MsgBox("Transportadora está bloqueada para uso.","M460MARK","ALERT")
		lRet := .F.
	Endif

	//Para Pedidos de RA
	_aPeds	:=	fVerifRA()
	If Len(_aPeds) > 0 .And. lRet  
		For _nI := 1 to Len(_aPeds)

			//Busca informações do Cálculo da Transportadora Original do Pedido de Venda
			If _aPeds[_nI,2] == "1" .Or. (_aPeds[_nI,2] == "2" .And. !_aPeds[_nI,3] == "ES")
				lCalcOld	:= .T.
				cMsgOld		:= "CALCULA FRETE AUTÔNOMO"
			EndIf

			//Busca informações da Transportadora selecionada na Tela de Faturamento	
			If (SA4->A4_YTIPO == "1" .Or. (SA4->A4_YTIPO == "2" .And. !SA4->A4_EST == "ES")) .Or. nRadioTr == 1
				lCalcNew 	:= .T.
				cMsgNew		:= "CALCULA FRETE AUTÔNOMO"
			EndIf

			If lCalcOld <> lCalcNew				
				cMsg := "Não é possível alterar a forma de cálculo do Frete Autônomo, para Pedidos com pagamento através de RA!" + CHR(13)+CHR(10)
				cMsg += "Transportadora do Pedido	=> " + cTpTrans    + " - " + cMsgOld + CHR(13)+CHR(10)
				cMsg += "Transportadora da Tela		=> " + SA4->A4_COD + " - " + cMsgNew					
				MsgBox(cMsg,"M460MARK","ALERT")	
				lRet := .F.	
				Exit
			EndIf
		Next
	EndIf

	If !lRet 
		xCodTra  := "      "
		xNomTra  := ""
	Else
		xNomTra  := SA4->A4_NOME
		If nTipo == "1"
			nRadioTr := Val(SA4->A4_YTIPO)			
		EndIf
	EndIf

	IF (!_IsAuto)

		//Ajusta e bloqueia a alteração, de acordo com a necessidade abaixo OS 1617-15
		If (Alltrim(SA4->A4_EST) == "ES" .And. Alltrim(SA4->A4_INSEST) $ "0_1_2_3_4_5_6_7_8_9") //!Empty(Alltrim(SA4->A4_INSEST)) .And. !Alltrim(SA4->A4_INSEST)=="ISENTO"
			oRadioTr:LREADONLY := .T.
		Else
			oRadioTr:LREADONLY := .F.
		EndIf

		ObjectMethod(oSayMotor,"SetText(xNomTra)")
		ObjectMethod(oDlgTrans,"Refresh()")

	ENDIF

Return(lRet)

//Fecha tela da Transportadora.
Static Function fSair()

	If fValTran("2")
		lOkTrans := .F.
		Close(oDlgTrans)
	EndIF 

Return

//Fecha tela da Condição de Pagamento 
Static Function fFecha()

	lOk := .F.
	Close(oDlg)

Return

Static Function fPedCliFi()

	Local _lRet		:=	.F.
	Local _cAlias	:=	GetNextAlias()
	Local _cFilC9	:=	xFilial("SC9")


	If cEmpAnt == "07"
		Return .F.
	EndIf

	IF (Type("cQNumCarga") <> "U") .And. !Empty(cQNumCarga)
		BeginSql Alias _cAlias
			%NoParser%
			SELECT COUNT(*) QTD
			FROM %TABLE:SC9% SC9 
			JOIN %TABLE:SC5% SC5 ON SC9.C9_FILIAL = SC5.C5_FILIAL
			AND SC9.C9_PEDIDO = SC5.C5_NUM
			AND SC5.%NotDel%
			AND SC5.C5_CLIENTE <> '010064'
			AND SC9.C9_BLEST = ''
			AND SC9.C9_BLCRED = ''
			AND SC5.C5_TPFRETE <> 'S'
			WHERE SC9.%NotDel%
			AND SC9.C9_AGREG = %Exp:cQNumCarga%
			AND SC9.C9_FILIAL = %Exp:_cFilC9%
		EndSql
		If (_cAlias)->QTD > 0
			_lRet	:=	.T.
		EndIf
	Else 
		Return _lRet
	EndIf

	(_cAlias)->(DbCloseArea())

Return _lRet

Static Function fVerifRA()

	Local _cAlias	:=	GetNextAlias()
	Local _cFilC9	:=	xFilial("SC9")
	Local _aPeds	:=	{}


	If cEmpAnt == "07"
		Return {}
	EndIf

	IF (Type("cQNumCarga") <> "U") .And. !Empty(cQNumCarga)
		BeginSql Alias _cAlias
			%NoParser%
			SELECT  C5_NUM, C5_TRANSP, C5_TPFRETE, C5_CONDPAG, A4_YTIPO, A4_EST
			FROM %TABLE:SC9% SC9 
			JOIN %TABLE:SC5% SC5 ON SC9.C9_FILIAL = SC5.C5_FILIAL
			AND SC9.C9_PEDIDO = SC5.C5_NUM
			AND SC5.%NotDel%
			AND SC5.C5_CLIENTE <> '010064'
			AND SC9.C9_BLEST = ''
			AND SC9.C9_BLCRED = ''
			AND SC5.C5_TPFRETE <> 'S'
			JOIN %TABLE:SE4% SE4 ON SE4.E4_FILIAL = %xFilial:SE4%
			AND SE4.E4_CODIGO = SC5.C5_CONDPAG
			AND SE4.E4_YATIVO = '1' 
			AND SE4.E4_DESCRI LIKE '%ANTE%'
			AND SE4.%NotDel%
			JOIN %TABLE:SA4% SA4 ON SA4.A4_FILIAL = %xFilial:SA4%
			AND SA4.A4_COD = SC5.C5_TRANSP
			WHERE SC9.%NotDel%
			AND SC9.C9_AGREG = %Exp:cQNumCarga%
			AND SC9.C9_FILIAL = %Exp:_cFilC9%
		EndSql
		If (_cAlias)->(!EOF())
			aAdd(_aPeds,{(_cAlias)->C5_NUM,(_cAlias)->A4_YTIPO, (_cAlias)->A4_EST})
		Else
			Return {}
		EndIf
	Else 
		Return {}
	EndIf

	(_cAlias)->(DbCloseArea())

Return _aPeds