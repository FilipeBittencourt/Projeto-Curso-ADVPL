#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ BIANCO2L ³ Autor ³ Nilton Cesar          ³ Data ³ 21.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Consiste linha - TRANSF. empenho                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BIANCO2L()
SetPrvt("LOK,WPRODUTO,WI,")
Private Enter := CHR(13)+CHR(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata somente itens nao apagados                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lOk := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao permitir localizacao de destino igual a de origem                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GdFieldGet("ZG_DESTINO",n) == GdFieldGet("ZG_ORIGEM",n) .and. GdDeleted(n) == .f.
	MsgAlert("Localizacao de destino igual a localizacao de origem.")
	lOK := .F.
EndIf


dbSelectArea("ZZ9")
dbSetOrder(1)
IF !dbSeek(xFilial("ZZ9")+GdFieldGet("ZG_LOTECTL",n)+GdFieldGet("ZG_PRODUTO",n),.T.)
	MsgAlert("Produto / Lote não existe!")
	lOK := .F.
EndIf

cSql := ""
cSql := "SELECT BF_PRODUTO, BF_LOTECTL, SUM(BF_QUANT) BF_QUANT, " + Enter
cSql += "		ISNULL((SELECT SUM(B8_SALDO)   FROM "+RetSqlName("SB8")+" WHERE B8_PRODUTO = BF_PRODUTO AND B8_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = '' AND B8_SALDO <> 0),0) B8_SALDO,		" + Enter
cSql += "		ISNULL((SELECT SUM(B8_EMPENHO) FROM "+RetSqlName("SB8")+" WHERE B8_PRODUTO = BF_PRODUTO AND B8_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = '' AND B8_SALDO  > 0),0) B8_EMPENHO,	" + Enter
cSql += "		SUM(BF_EMPENHO) BF_EMPENHO, " + Enter
cSql += "		ISNULL((SELECT SUM(DA_SALDO)   FROM "+RetSqlName("SDA")+" WHERE DA_PRODUTO = BF_PRODUTO AND DA_LOTECTL = BF_LOTECTL AND DA_SALDO > 0 AND D_E_L_E_T_ = ''),0) DA_SALDO, " + Enter
cSql += "		ISNULL((SELECT SUM(C0_QUANT)   FROM "+RetSqlName("SC0")+" WHERE C0_PRODUTO = BF_PRODUTO AND C0_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = ''),0) C0_QUANT, " + Enter
cSql += "		ISNULL((SELECT SUM(C9_QTDLIB)  FROM "+RetSqlName("SC9")+" WHERE C9_PRODUTO = BF_PRODUTO AND C9_LOTECTL = BF_LOTECTL AND C9_NFISCAL = '' AND D_E_L_E_T_ = ''),0) C9_QTDLIB,	" + Enter
cSql += "		ISNULL((SELECT SUM(DC_QUANT)   FROM "+RetSqlName("SDC")+" WHERE DC_PRODUTO = BF_PRODUTO AND DC_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = ''),0) DC_QUANT " + Enter
cSql += "FROM "+RetSqlName("SBF")+" SBF " + Enter
cSql += "WHERE BF_PRODUTO = '"+GdFieldGet("ZG_PRODUTO",n)+"' AND " + Enter
cSql += "      BF_LOTECTL = '"+GdFieldGet("ZG_LOTECTL",n)+"' AND " + Enter
cSql += "      D_E_L_E_T_ = ''				" + Enter
cSql += "GROUP BY BF_PRODUTO, BF_LOTECTL	" + Enter
If chkfile("_RAN")
	dbSelectArea("_RAN")
	dbCloseArea()
EndIf
TCQuery cSql Alias "_RAN" New

If _RAN->BF_QUANT+_RAN->DA_SALDO <> _RAN->B8_SALDO .And. lOK 
	MsgAlert("Saldo do Produto por Localização (SBF) é diferente do Saldo por Lote (SB8). Favor entrar em contato com o setor de Informática!")
	lOK := .F.
EndIf

If _RAN->BF_EMPENHO <> _RAN->B8_EMPENHO .And. lOK 
	MsgAlert("Divergencia nos Empenhos por Localização e Lote. Favor entrar em contato com o setor de Informática!")
	lOK := .F.
EndIf

If _RAN->DC_QUANT <> (_RAN->C0_QUANT+_RAN->C9_QTDLIB) .And. lOK 
	MsgAlert("Divergencia nos Empenhos dos Pedidos Liberados e Reserva. Favor entrar em contato com o setor de Informática!")
	lOK := .F.
EndIf

cSql := ""
cSql := "SELECT BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ, SUM(BF_QUANT) BF_QUANT, SUM(BF_EMPENHO) BF_EMPENHO, " + Enter
cSql += "ISNULL((SELECT SUM(C0_QUANT) FROM "+RetSqlName("SC0")+" WHERE C0_PRODUTO = BF_PRODUTO AND C0_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = '' AND C0_LOCALIZ = BF_LOCALIZ),0) C0_QUANT,  " + Enter
cSql += "ISNULL((SELECT SUM(DC_QUANT) FROM "+RetSqlName("SDC")+" WHERE DC_PRODUTO = BF_PRODUTO AND DC_LOTECTL = BF_LOTECTL AND D_E_L_E_T_ = '' AND DC_LOCALIZ = BF_LOCALIZ),0) DC_QUANT   " + Enter
cSql += "FROM "+RetSqlName("SBF")+" SBF " + Enter
cSql += "WHERE	BF_PRODUTO = '"+GdFieldGet("ZG_PRODUTO",n)+"' AND " + Enter
cSql += "		BF_LOTECTL = '"+GdFieldGet("ZG_LOTECTL",n)+"' AND " + Enter
cSql += "		BF_LOCALIZ = '"+GdFieldGet("ZG_ORIGEM" ,n)+"' AND " + Enter
cSql += "		D_E_L_E_T_ = '' " + Enter
cSql += "GROUP BY BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ " + Enter
If chkfile("_SBF")
	dbSelectArea("_SBF")
	dbCloseArea()
EndIf
TCQuery cSql Alias "_SBF" New

cSql := ""
cSql += "SELECT Z9_PRODUTO, Z9_LOTECTL, SUM(QUANT) QUANT " + Enter
cSql += "FROM " + Enter
cSql += "(SELECT Z9_PRODUTO, Z9_LOTECTL, Z9_LOCALIZ, SUM(Z9_QTDLIB) QUANT " + Enter
cSql += "FROM	"+RetSqlName("SC9")+" C9, "+RetSqlName("SZ9")+" Z9 " + Enter
cSql += "WHERE	C9.C9_PEDIDO  = Z9.Z9_PEDIDO	AND " + Enter
cSql += "	    C9.C9_PRODUTO = Z9.Z9_PRODUTO	AND " + Enter
cSql += "		C9.C9_LOTECTL = Z9.Z9_LOTECTL	AND " + Enter
cSql += "		C9.C9_AGREG   = Z9.Z9_AGREG	AND " + Enter
cSql += "		C9.C9_ITEM	  = Z9.Z9_ITEM		AND " + Enter
cSql += "		C9.C9_SEQUEN  = Z9.Z9_SEQUEN	AND " + Enter
cSql += "		C9.C9_NFISCAL = ''				AND " + Enter 
cSql += "		C9.C9_BLCRED  = ''				AND " + Enter
cSql += "		C9.C9_PRODUTO = '"+GdFieldGet("ZG_PRODUTO",n)+"' AND " + Enter 
cSql += "		C9.C9_LOTECTL = '"+GdFieldGet("ZG_LOTECTL",n)+"' AND " + Enter 
cSql += "		Z9.Z9_LOCALIZ = '"+GdFieldGet("ZG_ORIGEM" ,n)+"' AND " + Enter 
cSql += "		C9.D_E_L_E_T_ = ''				AND " + Enter
cSql += "		Z9.D_E_L_E_T_ = '' 					" + Enter
cSql += "GROUP BY Z9_PRODUTO, Z9_LOTECTL, Z9_LOCALIZ " + Enter       
cSql += "UNION ALL " + Enter
cSql += "SELECT C9_PRODUTO, C9_LOTECTL, '' C9_LOCALIZ, SUM(DC_QUANT) QUANT " + Enter
cSql += "FROM	"+RetSqlName("SC9")+" C9 , "+RetSqlName("SDC")+" DC "+ Enter
cSql += "WHERE	C9.C9_BLCRED  = ' ' AND " + Enter
cSql += "		C9.C9_NFISCAL = ''				 AND " + Enter
cSql += "		C9.C9_AGREG   = ''			   	 AND " + Enter

cSql += "		C9.C9_PEDIDO  = DC.DC_PEDIDO   	 AND " + Enter
cSql += "		C9.C9_PRODUTO = DC.DC_PRODUTO  	 AND " + Enter
cSql += "		C9.C9_LOTECTL = DC.DC_LOTECTL  	 AND " + Enter
cSql += "		C9.C9_ITEM	  = DC.DC_ITEM	   	 AND " + Enter
cSql += "		C9.C9_SEQUEN  = DC.DC_SEQ   	 AND " + Enter

cSql += "		C9.C9_PRODUTO = '"+GdFieldGet("ZG_PRODUTO",n)+"' AND " + Enter 
cSql += "		C9.C9_LOTECTL = '"+GdFieldGet("ZG_LOTECTL",n)+"' AND " + Enter 
cSql += "		DC.DC_LOCALIZ = '"+GdFieldGet("ZG_ORIGEM" ,n)+"' AND " + Enter 

cSql += "		DC.D_E_L_E_T_ = '' AND	" + Enter				
cSql += "		C9.D_E_L_E_T_ = ''		" + Enter				
cSql += "GROUP BY C9_PRODUTO, C9_LOTECTL) A " + Enter
cSql += "GROUP BY Z9_PRODUTO, Z9_LOTECTL	" + Enter

If chkfile("_SZ9")
	dbSelectArea("_SZ9")
	dbCloseArea()
EndIf
TCQuery cSql Alias "_SZ9" New

If _SBF->BF_EMPENHO <> _SBF->DC_QUANT .And. lOK 
	MsgAlert("Divergencia nos Saldos de Empenho (SBF X SDC). Favor entrar em contato com o setor de Informática!")
	lOK := .F.
EndIf

If _SBF->DC_QUANT <> (_SZ9->QUANT+_SBF->C0_QUANT) .And. lOK 
	MsgAlert("Divergencia nos Empenhos dos Pedidos Liberados/Romaneio (SZ9) e Empenho (SDC). Favor entrar em contato com o setor de Informática!")
	lOK := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementa 1 no tipo                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lok
	aCols[n,1] := StrZero(n,2)
EndIf

If chkfile("_RAN")
	dbSelectArea("_RAN")
	dbCloseArea()
EndIf

If chkfile("_SBF")
	dbSelectArea("_SBF")
	dbCloseArea()
EndIf

If chkfile("_SZ9")
	dbSelectArea("_SZ9")
	dbCloseArea()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lOk)        
