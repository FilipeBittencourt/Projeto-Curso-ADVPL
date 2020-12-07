#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BIA038   ³ Autor ³ SIGA Vitoria          ³ Data ³ 20/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao de Romaneio                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function bia038()

	SetPrvt("LFIM_PL,WOPCAO,AHEADER_PL,WPL_AGREG,WPL_PEDIDO,WPL_PRODUTO")
	SetPrvt("WPL_ITEM,WPL_SEQUEN,WPL_DESCRI,WPL_QTDLIB,WPL_QTDLI2,WPL_LOCAL")
	SetPrvt("WPL_LOCALIZ,WPL_ORIGEM,WPL_DELET,AHEADER_RQ,WRQ_DOC,WRQ_COD")
	SetPrvt("WRQ_DESCRIC,WRQ_QUANT,WRQ_QUANT2,WRQ_EMISSAO,WRQ_LOCALIZ,WRQ_NUMSEQ")
	SetPrvt("WRQ_AGREG,WRQ_DELET,ACOLS_PL,ACOLS_OR,ACOLS_RQ,ACOLS_NRQ")
	SetPrvt("ACOLS_N,AQTDLIB,AQTDLIB2,ALOCAL,ALOCALIZ,APESO")
	SetPrvt("APESOEMB,AFATCONV,WPESOTOT,WQTDRQ,WQTDRQ2,APRCVEN")
	SetPrvt("WQTDITEM,WQTDITEM2,WQTDBAL,WIGUAL,LOK,LINCLUIR")
	SetPrvt("LEXCLUIR,WMOTOR,WPLACA,WUF,WPESOLIQC,WPESOBR")
	SetPrvt("WFILIAL,WCLIENTE,WLOJA,WGRUPO,WPEDIDO,WAGREG")
	SetPrvt("WNUMERO,WNUMITEM,AHEADER,ACOLS,WLCOLS,WNUMITRQ")
	SetPrvt("I,LFIM_RQ,WEX,Z,WPRODUTO,AEL")
	SetPrvt("WLOCAL,WLOCALIZ,WERRO,WQTDCALC,WQTDCALC2,WNUMCALC")
	SetPrvt("WOLD,WNEW,NI,WI,NPOS,WPBPICT")
	SetPrvt("WQTDPICT,WQTDPICT2,WQTRQPICT,WQTRQPICT2,LERRO1,LERRO2,MSG,CMSG")
	SetPrvt("WNUMSEQ,WQTD,LIQC,_PESO,CQUERY,CCONDQRY,NTOTREGS,WITEM,NSOMA")
	SetPrvt("WLOJA,WDELET,ARADIO,NRADIO,WFIM,")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFim_PL := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica tipo de processamento                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wOpcao := paramixb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader - Pedidos Liberados                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader_PL  := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	wPL_Agreg   := 1;dbSeek("Z9_AGREG  ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Pedido  := 2;dbSeek("Z9_PEDIDO ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Produto := 3;dbSeek("Z9_PRODUTO");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Item    := 4;dbSeek("Z9_ITEM   ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Sequen  := 5;dbSeek("Z9_SEQUEN ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Descri  := 6;dbSeek("Z9_DESCRIC");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_QtdLib  := 7;dbSeek("Z9_QTDLIB ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_QtdLi2  := 8;dbSeek("Z9_QTDLIB2");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Local   := 9;dbSeek("C6_LOCAL  ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Localiz :=10;dbSeek("C6_LOCALIZ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Lote    :=11;dbSeek("Z9_LOTECTL");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Origem  :=12;dbSeek("Z9_ORIGEM ");aadd(aHeader_PL,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wPL_Delet   :=13

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader - Requisicoes                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader_RQ  := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	wRQ_Doc     := 1;dbSeek("ZZ_DOC    ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Cod     := 2;dbSeek("ZZ_COD    ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Descric := 3;dbSeek("ZZ_DESCRI ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Quant   := 4;dbSeek("ZZ_QUANT  ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Quant2  := 5;dbSeek("ZZ_QUANT2 ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Emissao := 6;dbSeek("ZZ_EMISSAO");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Localiz := 7;dbSeek("ZZ_LOCALIZ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Lote    := 8;dbSeek("ZZ_LOTECTL");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_NumSeq  := 9;dbSeek("ZZ_NUMSEQ ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Agreg   :=10;dbSeek("ZZ_AGREG  ");aadd(aHeader_RQ,{trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	wRQ_Delet   :=11

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols_PL    := {}
	aCols_Or    := {}
	aCols_RQ    := {}
	aCols_nRQ   := {}
	aCols_N     := {}
	aQtdLib     := {}
	aQtdLib2    := {}
	aLocal      := {}
	aLocaliz    := {}
	aLote       := {}
	aPeso       := {}
	aPesoEmb    := {}
	aFatConv    := {}
	wPesoTot    := 0
	wQtdRQ      := 0
	wQtdRQ2     := 0
	aPrcVen     := {}
	wQtdItem    := 0
	wQtdItem2   := 0
	wQtdBal     := 0
	wIgual      := {}
	lOk         := .T.
	lIncluir    := .F.
	lExcluir    := .F.
	wMotor      := Space(20)
	wPlaca      := Space(7)
	wUF         := Space(2)
	wPesoLiqC   := 0
	wPesoBr     := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona pedidos lib. e ainda nao faturados do cliente selecionado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wFilial     := xFilial("SC9")
	wCliente    := SC9->C9_CLIENTE
	wLoja       := SC9->C9_LOJA
	wGrupo      := SC9->C9_GRUPO
	wPedido     := SC9->C9_PEDIDO
	wAgreg      := SC9->C9_AGREG
	wItem       := SC9->C9_ITEM
	wNumero     := subs(dtos(ddatabase),1,4)+wAgreg+Space(2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Opcao                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case wOpcao == "I"
		lIncluir := .T.
		aadd(aCols_RQ,{space(6),space(15),Space(30),0,0,ctod("  /  /  "),space(15),space(10),space(6),space(4),.F.})
		aCols_nRQ := ACLONE(aCols_RQ)
		Rot_IncPed()
		Case wOpcao == "A"
		lIncluir := .F.
		Rot_AltRQ()
		Rot_AltPed()
		Case wOpcao == "E"
		lIncluir := .F.
		lExcluir := .T.
		Rot_AltRQ()
		Rot_AltPed()
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela Principal                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lOk
		Rot_Tela()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>         Execute(Rot_Tela)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a concistencia dos dados entre a tabela SZ9 e a tabela SC9. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(Z9_QTDLIB) AS SUM_SZ9 "
	cCondQry  += "FROM "+RetSqlName("SZ9")+" SZ9 "
	cCondQry  += "WHERE "
	cCondQry  += "     SZ9.Z9_FILIAL  = '01' AND "
	cCondQry  += "     SZ9.Z9_AGREG   = '"+wAgreg +"' AND "
	cCondQry  += "     SZ9.Z9_PEDIDO  = '"+wPedido+"' AND "
	cCondQry  += "     SZ9.D_E_L_E_T_ = ' ' "
	cQuery    += cCondQry
	TCQuery cQuery Alias "TMP1" New

	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(C9_QTDLIB) AS SUM_SC9 "
	cCondQry  += "FROM "+RetSqlName("SC9")+" SC9 "
	cCondQry  += "WHERE "
	cCondQry  += "     SC9.C9_FILIAL  = '01' AND "
	cCondQry  += "     SC9.C9_CLIENTE = '"+wCliente+"' AND "
	cCondQry  += "     SC9.C9_LOJA    = '"+wLoja   +"' AND "
	cCondQry  += "     SC9.C9_PEDIDO  = '"+wPedido +"' AND "
	cCondQry  += "     SC9.C9_AGREG   = '"+wAgreg  +"' AND "
	cCondQry  += "     SC9.C9_NFISCAL IN (' ')         AND "
	cCondQry  += "     SC9.D_E_L_E_T_ = ' ' "
	cQuery    += cCondQry
	TCQuery cQuery Alias "TMP2" New

	nSoma := TMP1->SUM_SZ9 - TMP2->SUM_SC9
	TMP1->(DbCloseArea())
	TMP2->(DbCloseArea())
	if nSoma <> 0
		cMsg := ""
		cMsg += "ATENCAO!! "+chr(13)
		cMsg += ""+chr(13)
		cMsg += "Inconcistencia entre os PRODUTOS LIBERADOS (SC9) e o ROMANEIO GERADO (SZ9)."+chr(13)
		cMsg += "VOCE DEVE VERIFICAR O ROMANEIO COM O PEDIDO E SE FOR O CASO, ESTONAR O PEDIDO E LIBERAR NOVAMENTE!"+chr(13)
		MsgBox(cMsg,"","STOP")
	endif
	Return
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a concistencia dos dados entre a tabela SZ9 e a tabela SDC. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(DC_QUANT) AS SUM_SDC "
	cCondQry  += "FROM "+RetSqlName("SDC")+" SDC "
	cCondQry  += "WHERE "
	cCondQry  += "     SDC.DC_FILIAL  = '01'          AND "
	cCondQry  += "     SDC.DC_PEDIDO  = '"+wPedido+"' AND "
	cCondQry  += "     SDC.DC_ORIGEM  = 'SC6'         AND "  //Incluido por Edson Junior
	cCondQry  += "     SDC.D_E_L_E_T_ = ' ' "   // nao considerar controle de reservas
	cQuery    += cCondQry       // numeracao a revelia em 09/12/02
	TCQuery cQuery Alias "TMP1" New

	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(Z9_QTDLIB) AS SUM_SZ9 "
	cCondQry  += "FROM "+RetSqlName("SZ9")+" SZ9 "
	cCondQry  += "WHERE "
	cCondQry  += "     SZ9.Z9_FILIAL  = '01' AND "
	cCondQry  += "     SZ9.Z9_AGREG   = '"+wAgreg +"' AND "
	cCondQry  += "     SZ9.Z9_PEDIDO  = '"+wPedido+"' AND "
	cCondQry  += "     SZ9.D_E_L_E_T_ = ' ' "
	cQuery    += cCondQry
	TCQuery cQuery Alias "TMP2" New

	nSoma := TMP1->SUM_SDC - TMP2->SUM_SZ9
	TMP1->(DbCloseArea())
	TMP2->(DbCloseArea())
	if nSoma <> 0
		cMsg := ""
		cMsg += "ATENCAO!! "+chr(13)
		cMsg += ""+chr(13)
		cMsg += "Inconcistencia entre os produtos empenhados e o Romaneio gerado."+chr(13)
		cMsg += "VOCE DEVE VERIFICAR O ROMANEIO COM O PEDIDO E SE FOR O CASO, ESTONAR O PEDIDO E LIBERAR NOVAMENTE!"+chr(13)
		MsgBox(cMsg,"","STOP")
	endif
Return


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Rot_IncPed                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Rot_IncPed()

	//Armazena Numero Romaneio
	wAgreg := GETSXENUM("ZZV","ZZV_CARGA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a concistencia dos dados entre a tabela SC9 e a tabela SDC. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(DC_QUANT) AS SUM_SDC "
	cCondQry  += "FROM "+RetSqlName("SDC")+" SDC "
	cCondQry  += "WHERE "
	cCondQry  += "     SDC.DC_FILIAL  = '01'          AND "
	cCondQry  += "     SDC.DC_PEDIDO  = '"+wPedido+"' AND "
	cCondQry  += "     SDC.DC_ORIGEM  = 'SC6'         AND "   // Incluido por Edson Junior
	cCondQry  += "     SDC.D_E_L_E_T_ = ' ' "                 // Para nao levar em conta o
	cQuery    += cCondQry   //Controle de reservas onde a numeracao e dada a revelia em 09/12/02
	TCQuery cQuery Alias "TMP1" New

	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(C9_QTDLIB) AS SUM_SC9 "
	cCondQry  += "FROM "+RetSqlName("SC9")+" SC9 "
	cCondQry  += "WHERE "
	cCondQry  += "     SC9.C9_FILIAL  = '01' AND "
	cCondQry  += "     SC9.C9_CLIENTE = '"+wCliente+"' AND "
	cCondQry  += "     SC9.C9_LOJA    = '"+wLoja   +"' AND "
	cCondQry  += "     SC9.C9_PEDIDO  = '"+wPedido +"' AND "
	cCondQry  += "     SC9.C9_NFISCAL IN (' ')         AND "
	cCondQry  += "     SC9.D_E_L_E_T_ = ' ' "
	cQuery    += cCondQry
	TCQuery cQuery Alias "TMP2" New

	nSoma := TMP1->SUM_SDC - TMP2->SUM_SC9
	TMP1->(DbCloseArea())
	TMP2->(DbCloseArea())
	if nSoma <> 0
		cMsg := ""
		cMsg += "ATENCAO!! "+chr(13)
		cMsg += ""+chr(13)
		cMsg += "Inconsistencia entre os produtos empenhados e os produtos liberados."+chr(13)
		cMsg += "VOCE DEVE ESTORNAR O PEDIDO E LIBERAR NOVAMENTE!"+chr(13)
		MsgBox(cMsg,"","STOP")
		lOk := .F.
		RollBackSx8()
		Return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carga Inicial                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC9")
	DbSetOrder(2)
	If  DbSeek(wFilial+wCliente+wLoja+wPedido,.T.)
		While !eof() .and. SC9->C9_FILIAL == wFilial .and. SC9->C9_CLIENTE == wCliente .and. SC9->C9_LOJA == wLoja .and. SC9->C9_PEDIDO == wPedido
			If empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. empty(SC9->C9_AGREG)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona SC6                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.T.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona SC5                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SC5")
				DbSetOrder(1)
				DbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
				If !Alltrim(SC5->C5_TIPO) $ "N_B" 
					DbSelectArea("SC9")
					DbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona Apenas Romaneio de PA      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(SC9->C9_GRUPO) <> "PA" 
					DbSelectArea("SC9")
					DbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona SB1                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

				aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
				cSQLL := ""							
				cSQLL := "SELECT * FROM ZZ9010 "
				cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
				cSQLL += "		ZZ9_LOTE = '" +SC9->C9_LOTECTL+ "' AND "
				cSQLL += "		D_E_L_E_T_ = '' "
				IF chkfile("_ZZ9")
					dbSelectArea("_ZZ9")
					dbCloseArea()
				ENDIF
				TCQuery cSQLL Alias "_ZZ9" New							
				IF ! _ZZ9->(EOF())
					sPESEMB := _ZZ9->ZZ9_PESEMB
					sPESO	:= _ZZ9->ZZ9_PESO
					sDIVPA	:= _ZZ9->ZZ9_DIVPA
				ELSE
					sPESEMB := SB1->B1_YPESEMB
					sPESO	:= SB1->B1_PESO
					sDIVPA	:= SB1->B1_YDIVPA
				END IF															

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona SDC                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SDC")
				DbSetOrder(1)
				If  dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC6->C6_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_LOTECTL,.T.)
					While ! Eof() .And. xFilial("SDC")  == SDC->DC_FILIAL  ;
					.And. SC9->C9_PRODUTO == SDC->DC_PRODUTO ;
					.And. SC6->C6_LOCAL   == SDC->DC_LOCAL   ;
					.And. SC9->C9_PEDIDO  == SDC->DC_PEDIDO  ;
					.And. SC9->C9_ITEM    == SDC->DC_ITEM    ;
					.And. SC9->C9_SEQUEN  == SDC->DC_SEQ     ;
					.And. SC9->C9_LOTECTL == SDC->DC_LOTECTL
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adiciona Acols                                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aadd(aCols_PL,{SC9->C9_AGREG,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC6->C6_DESCRI,SDC->DC_QUANT,IIF(SB1->B1_TIPCONV=="M",SDC->DC_QUANT*SB1->B1_CONV,SDC->DC_QUANT/SB1->B1_CONV),SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_LOTECTL,"S",iif(empty(SC9->C9_AGREG),.F.,.T.)})
						aadd(aQtdLib,SDC->DC_QUANT)
						aadd(aQtdLib2,IIF(SB1->B1_TIPCONV=="M",SDC->DC_QUANT*SB1->B1_CONV,SDC->DC_QUANT/SB1->B1_CONV))
						aadd(aPrcVen,SC9->C9_PRCVEN)
						aadd(aLocal,SDC->DC_LOCAL)
						aadd(aLocaliz,SDC->DC_LOCALIZ)
						aadd(aLote,SDC->DC_LOTECTL)
						aadd(aPeso,sPESO)
						aadd(aPesoEmb,sPESEMB)
						aadd(aFatConv,SB1->B1_CONV)
						wPesoLiqC := ( SDC->DC_QUANT  * sPESO )
						If SB1->B1_TIPCONV == "M"
							wPesoBr  := (( SDC->DC_QUANT * SB1->B1_CONV ) * sPESEMB ) + wPesoBr + wPesoLiqC
						Else
							wPesoBr  := (( SDC->DC_QUANT / SB1->B1_CONV ) * sPESEMB ) + wPesoBr + wPesoLiqC  // ALTERADO POR RANISSES NA VIRADA
						EndIF
						dbSkip()
					EndDo				
					wPesoTot := wPesoBr
				Else
					MSGSTOP("Problemas na Rotina Rot_IncPed - Nao encontrou dados no Arquivo SDC")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculos                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				wQtdItem := wQtdItem + SC9->C9_QTDLIB
				wQtdItem2:= wQtdItem2+IIF(SB1->B1_TIPCONV=="M",SC9->C9_QTDLIB*SB1->B1_CONV,SC9->C9_QTDLIB/SB1->B1_CONV)
				wQtdBal  := wQtdBal  + SC9->C9_QTDLIB
			Endif
			dbSelectArea("SC9")
			dbSkip()
		End
	Else
		MsgBox("ERRO. Nenhum pedido foi encontrado. Avise a Microsiga","Nenhum pedido encontrado","INFO")
		lOk := .F.
		RollBackSx8()
		Return
	EndIf
	If  Len(aCols_PL) == 0
		MsgBox("Nenhum pedido foi encontrado para o Cliente especificado.","Nenhum pedido encontrado","INFO")
		lOk := .F.
		RollBackSx8()
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona proximo numero do romaneio                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	dbSetOrder(1)
	If !dbSeek(xFilial("SX5")+"99"+Subs(Dtos(ddatabase),1,4)+"  ",.F.)
		Reclock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := "99"
		SX5->X5_CHAVE  := Subs(Dtos(ddatabase),1,4)
		SX5->X5_DESCRI := "0000"
		MsUnLock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a preexistencia do novo romaneio.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT COUNT(SZ9.Z9_NUMERO) AS TOTREGS "
	cCondQry  += "FROM "+RetSqlName("SZ9")+" SZ9 "
	cCondQry  += "WHERE "
	cCondQry  += "     SZ9.Z9_NUMERO = '"+Subs(Dtos(Ddatabase),1,4)+Soma1(Alltrim(SX5->X5_DESCRI),4)+"' AND "
	cCondQry  += "     SZ9.D_E_L_E_T_ <> '*'"
	cQuery    += cCondQry
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())
	if nTotRegs > 0
	MsgBox("Romaneio ["+Subs(Dtos(Ddatabase),1,4)+Soma1(Alltrim(SX5->X5_DESCRI),4)+"] ja existente. Verifique a numeracao do romaneio junto a informatica.","","STOP")
	IF SM0->M0_CODIGO == '05' 
	//Corrige numeracao do romaneio na Incesa
	cQuery    := ""	
	cQuery    += "	UPDATE SX5050 SET X5_DESCRI = (SELECT MAX(Z9_AGREG) AGREG FROM SZ9050 WHERE Z9_EMISSAO >= '"+Alltrim(Str(Year(dDatabase)))+"0101"+"' AND D_E_L_E_T_ = '') "
	cQuery    += "	WHERE X5_TABELA = '99' AND D_E_L_E_T_ ='' AND X5_CHAVE = '"+Alltrim(Str(Year(dDatabase)))+"' "
	TCSQLExec(cQuery)         
	ENDIF
	lOk := .F.
	Return
	endif


	If Reclock("SX5",.F.)
	wAgreg   	:= Soma1(Alltrim(SX5->X5_DESCRI),4)
	Else
	Alert("Romaneio travado por outro usuario")
	Endif 
	*/

	wNumero  := Subs(Dtos(ddatabase),1,4)+wAgreg+Space(2)
	aHeader  := aHeader_PL
	aCols    := aCols_PL
	aCols_Or := ACLONE(aCols)
	wLCols   := Len(aCols_PL)

Return

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Rot_AltRQ                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Rot_AltRQ()
	Local  i 
	aHeader := aHeader_RQ
	aCols   := aCols_RQ
	If  wAgreg == Space(4)
		Return
	EndIf
	dbSelectArea("SZ9")
	dbSetOrder(1)
	If  dbSeek(xFilial("SZ9")+wNumero)
		While ! eof() .and. SZ9->Z9_FILIAL  == xFilial("SZ9") ;
		.and. SZ9->Z9_NUMERO  == wNumero
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona Acols                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  SZ9->Z9_PEDIDO == SPACE(6)
				dbSelectArea("SD3")
				dbSetOrder(4)
				If  dbSeek(xFilial("SD3")+SZ9->Z9_NUMSEQ,.T.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona SB1                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1")+SZ9->Z9_PRODUTO)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona  no Acols                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aadd(aCols_RQ,{SD3->D3_DOC,SZ9->Z9_PRODUTO,SZ9->Z9_DESCRIC,SZ9->Z9_QTDLIB,SZ9->Z9_QTDLIB2,SZ9->Z9_EMISSAO,SZ9->Z9_LOCALIZ,ZZ9->Z9_LOTECTL,SZ9->Z9_NUMSEQ,SZ9->Z9_AGREG,.F.})
				EndIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proximo Registro                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndIf
			dbSelectArea("SZ9")
			dbSkip()
		End
		wQtdRQ   := 0
		wQtdRQ2  := 0
		wNumItRQ := 0
		For i    := 1 to len(aCols)
			If  ! aCols[i,wRQ_Delet]
				wQtdRQ   := wQtdRQ   + aCols[i,wRQ_Quant]
				wQtdRQ2  := wQtdRQ2  + aCols[i,wRQ_Quant2]
				wNumItRQ := wNumItRQ + 1
			EndIf
		Next
	EndIf
	If Len(Acols) == 0
		aadd(aCols_RQ,{space(6),space(15),space(30),0,0,ctod("  /  /  "),space(15),space(10),space(6),space(4),.F.})
	EndIF
	aHeader_RQ := aHeader
	aCols_RQ   := aCols
	aCols_nRQ  := ACLONE(aCols_RQ)
Return


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Rot_AltPed                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Rot_AltPed()
	aHeader := aHeader_PL
	aCols   := aCols_PL
	If SC9->C9_BLEST  == "10" .Or.;
	SC9->C9_BLCRED == "10"
		MsgBox("Nota Fiscal: "+SC9->C9_SERIENF+"/"+SC9->C9_NFISCAL+" j  Emitida para o Pedido: "+wPedido,"Nota Fiscal j  Emitida","STOP")
		lOk := .F.
		Return
	EndIf
	If wAgreg == Space(4)
		MsgBox("Atencao, nao ha nenhum romaneio relacionado a este pedido.","Nenhum Romaneio Relacionado","STOP")
		lOk := .F.
		Return
	EndIf
	dbSelectArea("SZ9")
	dbSetOrder(1)
	If  dbSeek(xFilial("SZ9")+wNumero)
		wMotor := SZ9->Z9_MOTOR
		wPlaca := SZ9->Z9_PLACA
		wUF    := SZ9->Z9_UF
		While ! eof() .and. SZ9->Z9_FILIAL  == xFilial("SZ9") ;
		.and. SZ9->Z9_NUMERO  == wNumero
			If  SZ9->Z9_PEDIDO <> SPACE(6)
				aadd(aCols_PL,{SZ9->Z9_AGREG,SZ9->Z9_PEDIDO,SZ9->Z9_PRODUTO,SZ9->Z9_ITEM,SZ9->Z9_SEQUEN,SZ9->Z9_DESCRIC,SZ9->Z9_QTDLIB,SZ9->Z9_QTDLIB2,SZ9->Z9_LOCAL,SZ9->Z9_LOCALIZ,SZ9->Z9_LOTECTL,"S",.F.})
				aadd(aQtdLib,SZ9->Z9_QTDLIB)
				aadd(aQtdLib2,IIF(SB1->B1_TIPCONV=="M",SZ9->Z9_QTDLIB*SB1->B1_CONV,SZ9->Z9_QTDLIB/SB1->B1_CONV))
				aadd(aLocal,SZ9->Z9_LOCAL)
				aadd(aLocaliz,SZ9->Z9_LOCALIZ)
				aadd(aLote,SZ9->Z9_LOTECTL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acessa SC9                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC9")
				dbSetOrder(1)
				If  dbSeek(wFilial+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN,.F.)
					aadd(aPrcVen,SC9->C9_PRCVEN)
				EndIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acessa SB1                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SZ9->Z9_PRODUTO,.F.)

				/*aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
				DbSelectArea("ZZ9")
				DbSetOrder(2)
				IF !DbSeek(xFilial("ZZ9")+ aCODPRODUTO + SD2->D2_LOTECTL )
				sPESEMB := ZZ9->ZZ9_PESEMB
				sPESO	:= ZZ9->ZZ9_PESO
				sDIVPA	:= ZZ9->ZZ9_DIVPA
				END IF */
				aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
				cSQLL := ""							
				cSQLL := "SELECT * FROM ZZ9010 "
				cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
				cSQLL += "		ZZ9_LOTE = '" +SZ9->Z9_LOTECTL+ "' AND "
				cSQLL += "		D_E_L_E_T_ = '' "
				IF chkfile("_ZZ9")
					dbSelectArea("_ZZ9")
					dbCloseArea()
				ENDIF
				TCQuery cSQLL Alias "_ZZ9" New							
				IF ! _ZZ9->(EOF())
					sPESEMB := _ZZ9->ZZ9_PESEMB
					sPESO	:= _ZZ9->ZZ9_PESO
					sDIVPA	:= _ZZ9->ZZ9_DIVPA
				ELSE
					sPESEMB := SB1->B1_YPESEMB
					sPESO	:= SB1->B1_PESO
					sDIVPA	:= SB1->B1_YDIVPA
				END IF															

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculo do Peso Bruto                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//aadd(aPeso,SB1->B1_PESO)
				aadd(aPeso,sPESO)
				//aadd(aPesoEmb,SB1->B1_YPESEMB)
				aadd(aPesoEmb,sPESEMB)
				aadd(aFatConv,SB1->B1_CONV)
				wPesoBr  := SZ9->Z9_PESOBR
				wPesoTot := wPesoBr
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculos                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				wQtdItem := wQtdItem + SZ9->Z9_QTDLIB
				wQtdItem2:= wQtdItem2+IIF(SB1->B1_TIPCONV=="M",SC9->C9_QTDLIB*SB1->B1_CONV,SC9->C9_QTDLIB/SB1->B1_CONV)
				wQtdBal  := wQtdBal  + SZ9->Z9_QTDLIB
			Endif
			dbSelectArea("SZ9")
			dbSkip()
		End
	Else
		MsgBox("Nenhum registro relacionado a este pedido no SZ9","Nenhum registro relacionado","STOP")
		lOk := .F.
	EndIf
	aHeader  := aHeader_PL
	aCols    := aCols_PL
	aCols_Or := ACLONE(aCols)
	wLCols   := Len(aCols_PL)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Rot_Tela                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Rot_Tela
Static Function Rot_Tela()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe dialogo                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader  := aHeader_PL
	aCols    := aCols_PL
	lFim_PL  := .F.
	While ! lFim_PL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tela de Atualizacao de Romaneio                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case wOpcao == "I"
			@ 134,000 to 424,632 Dialog oDlgPL Title "Inclusao de Romaneio"
			@ 005,005 to 115,310 Multiline Modify Delete Valid Verif_Linha()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>                @ 005,005 to 115,310 Multiline Modify Delete Valid Execute(Verif_Linha)
			Case wOpcao == "A"
			@ 134,000 to 424,632 Dialog oDlgPL Title "Atualizacao de Romaneio"
			@ 005,005 to 115,310 Multiline Modify Delete Valid Verif_Linha()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>                @ 005,005 to 115,310 Multiline Modify Delete Valid Execute(Verif_Linha)
			Case wOpcao == "E"
			@ 134,000 to 424,632 Dialog oDlgPL Title "Exclusao de Romaneio"
			@ 005,005 to 115,310 Multiline
		EndCase
		@ 117,010 say "Qtd Total 1UM: "
		@ 125,010 say "Qtd Total 2UM: "
		@ 117,060 say alltrim(trans(wQtdItem ,"@E  999,999.99")) OBJECT oSayQtd
		@ 125,060 say alltrim(trans(wQtdItem2,"@E  999,999.99")) OBJECT oSayQtd2
		@ 117,090 say "Qtd Total REQ 1UM:"
		@ 125,090 say "Qtd Total REQ 2UM: "
		@ 117,140 say alltrim(trans(wQtdRQ ,"@E  999,999.99")) OBJECT oSayRQ
		@ 125,140 say alltrim(trans(wQtdRQ2,"@E  999,999.99")) OBJECT oSayRQ2
		@ 133,010 say "Peso Bruto:"
		@ 133,060 say alltrim(trans(wPesoBr ,"@E 999,999,999.999")) OBJECT oSayPB
		@ 133,104 say "Romaneio:"
		@ 133,135 Get wNumero SIZE 35,10 When Subs(wNumero,5,4) <= "0001"
		//@ 126,197 Button "_Requisicoes" Size 50,10 Action Inclui_Req()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>        //@ 126,197 Button "_Requisicoes" Size 50,10 Action Execute(Inclui_Req)
		@ 119,197 Button "_Requisicoes" Size 50,10 Action Inclui_Req()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>        @ 119,197 Button "_Requisicoes" Size 50,10 Action Execute(Inclui_Req)
		@ 133,197 Button "_Motorista  " Size 50,10 Action Inclui_Mot()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>        @ 133,197 Button "_Motorista  " Size 50,10 Action Execute(Inclui_Mot)
		If  lExcluir
			@ 125,250 BmpButton Type  1  Action Inclui_Req()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            @ 125,250 BmpButton Type  1  Action Execute(Inclui_Req)
			@ 125,280 BmpButton Type  2  Action Close_PL()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            @ 125,280 BmpButton Type  2  Action Execute(Close_PL)
		Else
			@ 125,250 BmpButton Type  1  Action _Romaneio()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            @ 125,250 BmpButton Type  1  Action Execute(_Romaneio)
			@ 125,280 BmpButton Type  2  Action Close_PL()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            @ 125,280 BmpButton Type  2  Action Execute(Close_PL)
		EndIf
		MsUnlock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza SX5 - tabelas (Romaneio)                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		IF ! lExcluir
		dbSelectArea("SX5")
		dbSetOrder(1)
		If  dbSeek(xFilial("SX5")+"99"+Subs(Dtos(ddatabase),1,4)+"  ",.F.)
		While ! Reclock("SX5",.F.) ; End
		SX5->X5_DESCRI := wAgreg
		MsUnlock()
		EndIf	
		END IF	
		*/

		Activate Dialog oDlgPL
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim do programa                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Inclui_Req                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Inclui_Req
Static Function Inclui_Req()

	Local i 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva aHeader / aCols do dialogo anterior                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader_PL := aHeader
	aCols_PL   := aCols
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha dialogo anterior                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Close(oDlgPL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader / aCols                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aHeader_RQ
	aCols   := aCols_RQ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe janela p/ informar requisicoes                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFim_RQ := .F.
	While ! lFim_RQ
		If  wOpcao  == "I"
			@ 134,000 to 424,632 Dialog oDlgRQ Title "Inclusao de Requisicoes"
			@ 005,005 to 115,310 Multiline Modify Delete Valid Valida_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            @ 005,005 to 115,310 Multiline Modify Delete Valid Execute(Valida_RQ)
		Else
			If  wOpcao  == "A"
				@ 134,000 to 424,632 Dialog oDlgRQ Title "Alteracao de Requisicoes"
				@ 005,005 to 115,310 Multiline Modify Delete Valid Valida_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>                @ 005,005 to 115,310 Multiline Modify Delete Valid Execute(Valida_RQ)
			Else
				@ 134,000 to 424,632 Dialog oDlgRQ Title "Exclusao de Requisicoes"
				@ 005,005 to 115,310 Multiline
			EndIf
		EndIf

		wEx := .T.
		@ 125,250 BmpButton Type  1  Action Close_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>         @ 125,250 BmpButton Type  1  Action Execute(Close_RQ)
		@ 125,280 BmpButton Type  2  Action Dele_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>         @ 125,280 BmpButton Type  2  Action Execute(Dele_RQ)

		Activate Dialog oDlgRQ
	End
	If  wOpcao == "E"
		If  wEx == .T.
			Exclui_Rom()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>             Execute(Exclui_romaneio)
		Else
			Close_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>             Execute(Close_RQ)
		EndIf
	Else
		wQtdRQ   := 0
		wQtdRQ2  := 0
		wNumItRQ := 0
		For i    := 1 to len(aCols)
			If  ! aCols[i,wRQ_Delet]
				wQtdRQ   := wQtdRQ   + aCols[i,wRQ_Quant]
				wQtdRQ2  := wQtdRQ2  + aCols[i,wRQ_Quant2]
				wNumItRQ := wNumItRQ + 1
			EndIf
		Next
	EndIf
	//Close(oDlgRQ)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura aHeader / aCols do dialogo anterior                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aHeader_PL
	aCols   := aCols_PL
Return

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ _Romaneio                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Romaneio()

	Local  i , ni

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza SC9 - Pedidos Liberados - Caso tenha alterado a quantidade  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= aHeader_PL
	aCols  := aCols_PL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza totais                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF  n > wLCols
		aadd(aQtdLib,0)
		aadd(aQtdLib2,0)
		aadd(aLocal,"  ")
		aadd(aLocaliz,Space(15))
		aadd(aLote,Space(10))
		wLCols := Len(aCols_PL)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criticas                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 to Len(aCols)
		If  ! aCols[i,wPL_Delet]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o produto nao faz parte do pedido original       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  aCols[i,wPL_Origem] <> "S"
				z        := 0
				wProduto := aCols[i,wPL_Produto]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ver explicacao desta rotina abaixo                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  Empty(ASCAN(aCols,{|ael| If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])==Alltrim(wProduto))}))
					MsgBox("Este produto nao faz parte do Pedido Original. Para aceita-lo, favor alterar o Pedido Original","Pedido Original","STOP")
					Return(.F.)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ha repeticao de localizacao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  aCols[i,wPL_Origem] <> "S"
				z        := 0
				wProduto := aCols[i,wPL_Produto]
				wLocal   := aCols[i,wPL_Local]
				wLocaliz := aCols[i,wPL_Localiz]
				wLote    := aCols[i,wPL_Lote]
				If  ! Empty(ASCAN(aCols,{|ael| If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])+Alltrim(ael[9])+Alltrim(ael[10])==Alltrim(wProduto)+Alltrim(wLocal)+Alltrim(wLocaliz)+Alltrim(wLote))}))
					MsgBox("Atencao: Localizacao/Lote em Duplicidade. Reveja as localizacoes/Lotes.","Localizacao/Lote em Duplicidade","STOP")
					Return(.F.)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Local e a Localizacao estao digitados                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			wErro := .F.
			If  aCols[i,wPL_Local] == Space(2)
				MsgBox("Favor Informar Local Padrao.","Informar Local Padrao","STOP")
				Return(.F.)
			EndIf
			If  aCols[i,wPL_Localiz] == Space(15)
				MsgBox("Favor Informar a Localizacao.","Informar a Localizacao","STOP")
				Return(.F.)
			EndIf
			If  aCols[i,wPL_Lote] == Space(10)
				MsgBox("Favor Informar o Lote.","Informar o Lote","STOP")
				Return(.F.)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ha estoque sufuciente em SBF                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  aCols[i,wPL_Local]   <> aLocal[i]   .Or.  ;
			aCols[i,wPL_Localiz] <> aLocaliz[i] .Or.  ;
			aCols[i,wPL_Lote]    <> aLote[i]
				dbSelectArea("SBF")
				dbSetOrder(1)
				If  dbSeek(xFilial("SBF")+aCols[i,wPL_Local]+aCols[i,wPL_Localiz]+aCols[i,wPL_Produto]+SPACE(20)+aCols[i,wPL_Lote],.T.)
					If  SBF->BF_QUANT - SBF->BF_EMPENHO - aCols[i,wPL_QtdLib] < 0
						MsgBox("Nao ha estoque suficiente nesta localizacao/Lote"," Nao ha estoque suficiente","STOP")
						Return(.F.)
					Endif
				Else
					MsgBox("Localizacao/Lote inexistente para este Produto.","Localizacao/Lote inexistente","STOP")
					Return(.F.)
				EndIf
				aLocal[n]   := aCols[i,wPL_Local]
				aLocaliz[n] := aCols[i,wPL_Localiz] 
				aLote[n]    := aCols[i,wPL_Lote]			
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula totais                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			wQtdCalc := 0
			wQtdCalc2:= 0
			wNumCalc := 0
			For  i   := 1 to len(aCols_PL)
				If  !aCols[i,wPL_Delet]
					wNumCalc := wNumCalc + 1
					wQtdCalc := wQtdCalc + aCols[i,wPL_QtdLib]
					wQtdCalc2:= wQtdCalc2+ aCols[i,wPL_QtdLi2]
				Endif
			Next
			If  wQtdCalc > wQtdBal
				MsgBox("Atencao, Quantidade Total digitada: "+alltrim(trans(wQtdCalc,"@E  999,999"))+" esta maior que a Quantidade Total Original: "+alltrim(trans(wQtdBal,"@E  999,999")),"Quantidade Total digitada","INFO")
				//Return(.T.)
			EndIf
			If  wQtdCalc < wQtdBal
				MsgBox("Atencao, Quantidade Total digitada: "+alltrim(trans(wQtdCalc,"@E  999,999"))+" esta menor que a Quantidade Total Original: "+alltrim(trans(wQtdBal,"@E  999,999")),"Quantidade Total digitada","INFO")
				//Return(.T.)
			EndIf
		EndIF
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do Peso Bruto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wPesoBr   := 0
	wPesoLiqC := 0
	For i:= 1 to Len(aCols)
		If ! aCols[i,wPL_Delet]
			wPesoLiqC := ( aCols[i,wPL_QtdLib] * aPeso[i] )
			If  SB1->B1_TIPCONV == "M"
				wPesoBr := (( aCols[i,wPL_QtdLib] * aFatConv[i] ) * aPesoEmb[i] ) + wPesoBr + wPesoLiqC
			Else
				wPesoBr := (( aCols[i,wPL_QtdLib] / aFatConv[i] ) * aPesoEmb[i] ) + wPesoBr + wPesoLiqC
			EndIF
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara aCols Original com aCols Atual                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 to Len(aCols_Or)
		wOld := 0
		wNew := 0
		For ni := 1 to Len(aCols)
			If  (aCols_Or[i,wPL_Pedido]+aCols_Or[i,wPL_Produto]+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz]+aCols_Or[i,wPL_Lote] == ;
			aCols[ni,wPL_Pedido]+aCols[ni,wPL_Produto]+aCols[ni,wPL_Item]+aCols[ni,wPL_Sequen]+aCols[ni,wPL_Local]+aCols[ni,wPL_Localiz]+aCols[ni,wPL_Lote])
				If   ! aCols[ni,wPL_Delet]
					wOld := ni
					wNew := i
				EndIf
			EndIf
		Next
		// SE A LINHA DO ACOLS ANTERIOR NAO EXISTIR NO ACOLS ATUAL - APAGA REG. DE EMPENHO E LOCALIZACAO
		If  wOld == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atera Local                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SDC")
			//DbSetOrder(3)        
			DbSetOrder(1)       
			If  DbSeek(xFilial("SDC")+aCols_Or[i,wPL_Produto]+aCols_Or[i,wPL_Local]+"SC6"+aCols_Or[i,wPL_Pedido]+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Lote]+SPACE(6)+aCols_Or[i,wPL_Localiz]+SPACE(20),.T.)
				//If  dbSeek(xFilial("SDC")+aCols_Or[i,wPL_Pedido]+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz]+aCols_Or[i,wPL_Lote],.T.)
				If aCols_Or[i,wPL_Origem] <> "S"
					While ! Reclock("SDC",.F.) ; End
					SDC->DC_YEXCLUI := "BIA038"
					dbDelete()
					MsUnlock()
					dbSelectArea("SBF")
					dbSetOrder(1)
					If  dbSeek(xFilial("SBF")+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz]+aCols_Or[i,wPL_Produto]+SPACE(20)+aCols_Or[i,wPL_Lote]+SPACE(6),.T.)
						While ! Reclock("SBF",.F.) ; End
						SBF->BF_EMPENHO := SBF->BF_EMPENHO - aCols_Or[i,wPL_Qtdlib]
						MsUnlock()
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Deleta SZ9                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SZ9")
					dbSetOrder(3)
					If  dbSeek(xFilial("SZ9")+wNumero+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz]+aCols_Or[i,wPL_Lote],.T.)
						While ! Reclock("SZ9",.F.) ; End
						dbDelete()
						MsUnlock()
					EndIf
				EndIf
			EndIf
		Else
			aCols_N := ACLONE(aCols)
			wi      := wOld
			Inc_SZ9()    // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>            Execute(Inc_SZ9)
			If  aCols_Or[wNew,wPL_QtdLib] <> aCols[wOld,wPL_QtdLib]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera Qtde                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SDC")
				//DbSetOrder(3)        
				DbSetOrder(1)       
				If  DbSeek(xFilial("SDC")+aCols[wOld,wPL_Produto]+aCols[wOld,wPL_Local]+"SC6"+aCols[wOld,wPL_Pedido]+aCols[wOld,wPL_Item]+aCols[wOld,wPL_Sequen]+aCols[wOld,wPL_Lote]+SPACE(6)+aCols[wOld,wPL_Localiz]+SPACE(20),.T.)			
					//If  dbSeek(xFilial("SDC")+aCols[wOld,wPL_Pedido]+aCols[wOld,wPL_Item]+aCols[wOld,wPL_Sequen]+aCols[wOld,wPL_Local]+aCols[wOld,wPL_Localiz],.T.)
					While ! Reclock("SDC",.F.) ; End
					SDC->DC_YALTERA := "BIA038"				
					SDC->DC_QUANT   := SDC->DC_QUANT - aCols_Or[wNew,wPL_QtdLib] + aCols[wOld,wPL_QtdLib]
					MsUnlock()
					dbSelectArea("SBF")
					dbSetOrder(1)
					If  dbSeek(xFilial("SBF")+aCols[wOld,wPL_Local]+aCols[wOld,wPL_Localiz]+aCols[wOld,wPL_Produto]+SPACE(20)+aCols[wOld,wPL_Lote],.T.)
						While ! Reclock("SBF",.F.) ; End
						SBF->BF_EMPENHO := SBF->BF_EMPENHO - aCols_Or[wNew,wPL_QtdLib] + aCols[wOld,wPL_QtdLib]
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara aCols Atual com aCols Original                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ni := 1 to Len(aCols)
		If ! aCols[ni,wPL_Delet]
			wNew := 0                                     
			For i := 1 to Len(aCols_Or)
				If  aCols[ni,wPL_Pedido]+aCols[ni,wPL_Produto]+aCols[ni,wPL_Item]+aCols[ni,wPL_Sequen]+aCols[ni,wPL_Local]+aCols[ni,wPL_Localiz]+aCols[ni,wPL_Lote] == ;
				aCols_Or[i,wPL_Pedido]+aCols_Or[i,wPL_Produto]+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz]+aCols_Or[i,wPL_Lote]
					wNew := i
				EndIf
			Next
			// SE EXISTIR ALGUMA LINHA NO ACOLS QUE NAO EXISTA NO ACOLS ANTERIOR
			If  wNew == 0
				Inc_Local()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>             Execute(Inc_Local)
				wi      := ni
				aCols_N := aCols
				Inc_SZ9()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>             Execute(Inc_SZ9)
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Requisicoes                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= aHeader_RQ
	aCols  := aCols_RQ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara aCols Original com aCols Atual                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 to Len(aCols_nRQ)
		wOld := 0
		For ni := 1 to Len(aCols)
			If  (aCols_nRQ[i,wRQ_Doc]+aCols_nRQ[i,wRQ_Cod] == ;
			aCols[ni,wRQ_Doc]+aCols[ni,wRQ_Cod])   .And. ;
			! aCols[ni,wRQ_Delet]
				wOld := i
			EndIf
		Next
		If  wOld == 0
			If  aCols_nRQ[i,wRQ_Doc]+aCols_nRQ[i,wRQ_Cod] > Space(21)
				dbSelectArea("SZ9")
				dbSetOrder(1)
				If  dbSeek(xFilial("SZ9")+wNumero+"  "+"  "+aCols[i,wRQ_NumSeq])
					While ! Reclock("SZ9",.F.) ; End
					dbDelete()
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acerta SD3                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SD3")
					dbSetOrder(4)
					If  dbSeek(xFilial("SD3")+aCols[i,wRQ_NumSeq],.T.)
						While ! Reclock("SD3",.F.) ; End
						SD3->D3_YROM := "N"
						MsUnlock()
					EndIf
				Else
					Reclock("SZ9",.T.)
					SZ9->Z9_FILIAL  := xFilial("SZ9")
					SZ9->Z9_NUMERO  := wNumero
					SZ9->Z9_AGREG   := wAgreg
					SZ9->Z9_PRODUTO := aCols[i,wRQ_Cod]
					SZ9->Z9_DESCRIC := aCols[i,wRQ_Descric]
					SZ9->Z9_QTDLIB  := aCols[i,wRQ_Quant]
					SZ9->Z9_QTDORI  := aCols[i,wRQ_Quant]
					SZ9->Z9_LOCALIZ := aCols[i,wRQ_Localiz]
					SZ9->Z9_LOTECTL := aCols[i,wRQ_Lote]
					SZ9->Z9_EMISSAO := aCols[i,wRQ_Emissao]
					SZ9->Z9_NUMSEQ  := aCols[i,wRQ_NumSeq]
					SZ9->Z9_MOTOR   := wMotor
					SZ9->Z9_PLACA   := wPlaca
					SZ9->Z9_UF      := wUF
					_Verpeso()
					SZ9->Z9_PESOBR  := _peso
					MsUnlock()
					ConfirmSX8()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acerta SD3                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SD3")
					dbSetOrder(4)
					If  dbSeek(xFilial("SD3")+aCols[i,wRQ_NumSeq],.T.)
						While ! Reclock("SD3",.F.) ; End
						SD3->D3_YROM := "S"
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara aCols Atual com aCols Original                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ni := 1 to Len(aCols)
		wNew := 0
		For i := 1 to Len(aCols_nRQ)
			If  aCols_nRQ[i,wRQ_Doc]+aCols_nRQ[i,wRQ_Cod] == ;
			aCols[ni,wRQ_Doc]+aCols[ni,wRQ_Cod]
				wNew := i
			EndIf
		Next
		If  wNew == 0
			If  aCols[ni,wRQ_Doc] > Space(6)
				dbSelectArea("SZ9")
				dbSetOrder(1)
				If  ! dbSeek(xFilial("SZ9")+wNumero+"  "+"  "+aCols[ni,wRQ_NumSeq])
					Reclock("SZ9",.T.)
					SZ9->Z9_FILIAL  := xFilial("SZ9")
					SZ9->Z9_NUMERO  := wNumero
					SZ9->Z9_AGREG   := wAgreg
					SZ9->Z9_PRODUTO := aCols[ni,wRQ_Cod]
					SZ9->Z9_DESCRIC := aCols[ni,wRQ_Descric]
					SZ9->Z9_QTDLIB  := aCols[ni,wRQ_Quant]
					SZ9->Z9_QTDORI  := aCols[ni,wRQ_Quant]
					SZ9->Z9_LOCALIZ := aCols[ni,wRQ_Localiz]
					SZ9->Z9_LOTECTL := aCols[ni,wRQ_Lote]
					SZ9->Z9_EMISSAO := aCols[ni,wRQ_Emissao]
					SZ9->Z9_NUMSEQ  := aCols[ni,wRQ_NumSeq]
					SZ9->Z9_MOTOR   := wMotor
					SZ9->Z9_PLACA   := wPlaca
					SZ9->Z9_UF      := wUF
					_Verpeso()
					SZ9->Z9_PESOBR  := _peso
					MsUnlock()
					ConfirmSX8()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acerta SD3                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SD3")
					dbSetOrder(4)
					If  dbSeek(xFilial("SD3")+aCols[ni,wRQ_NumSeq],.T.)
						While ! Reclock("SD3",.F.) ; End
						SD3->D3_YROM := "S"
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	aHeader := aHeader_PL
	aCols   := aCols_PL
	lFim_PL := .T.
	Close(oDlgPL)

	aHeader := aHeader_RQ
	aCols   := aCols_RQ
	lFim_RQ := .T.
	//    Close(oDlgRQ)
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Inc_Local                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Inc_Local
Static Function Inc_Local()
	DbSelectArea("SDC")
	//dbSetOrder(3) 
	DbSetOrder(1)
	If  !DbSeek(xFilial("SDC")+aCols[ni,wPL_Produto]+aCols[ni,wPL_Local]+"SC6"+aCols[ni,wPL_Pedido]+aCols[ni,wPL_Item]+aCols[ni,wPL_Sequen]+aCols[ni,wPL_Lote]+SPACE(6)+aCols[ni,wPL_Localiz]+SPACE(20),.T.)			
		//If  ! dbSeek(xFilial("SDC")+aCols[ni,wPL_Pedido]+aCols[ni,wPL_Produto]+aCols_Or[i,wPL_Item]+aCols_Or[i,wPL_Sequen]+aCols_Or[i,wPL_Local]+aCols_Or[i,wPL_Localiz],.T.)
		Reclock("SDC",.T.)
		SDC->DC_FILIAL  := xFilial("SDC")
		SDC->DC_ORIGEM  := "SC6"
		SDC->DC_PRODUTO := aCols[ni,wPL_Produto]
		SDC->DC_LOCAL   := aCols[ni,wPL_Local]
		SDC->DC_LOCALIZ := aCols[ni,wPL_Localiz]
		SDC->DC_LOTECTL := aCols[ni,wPL_Lote]
		SDC->DC_QUANT   := aCols[ni,wPL_Qtdlib]
		SDC->DC_PEDIDO  := aCols[ni,wPL_Pedido]
		SDC->DC_ITEM    := aCols[ni,wPL_Item]
		SDC->DC_QTDORIG := aCols[ni,wPL_Qtdlib]
		SDC->DC_SEQ     := aCols[ni,wPL_Sequen]
		SDC->DC_YINCLUI := "BIA038"
		MsUnlock()
	EndIf
	dbSelectArea("SBF")
	dbSetOrder(1)
	// ATUALIZA QTD EMPENHADA
	If  dbSeek(xFilial("SBF")+aCols[ni,wPL_Local]+aCols[ni,wPL_Localiz]+aCols[ni,wPL_Produto]+SPACE(20)+aCols[ni,wPL_Lote],.T.)
		While ! Reclock("SBF",.F.) ; End
		SBF->BF_EMPENHO := SBF->BF_EMPENHO + aCols[ni,wPL_QtdLib]
		MsUnlock()
	EndIf
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Inc_SZ9                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Inc_SZ9
Static Function Inc_SZ9()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o Valor da Parcela das Duplicatas e compara com o Limite a ser Faturado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery    := ""
	cCondQry  := ""
	cQuery    += "SELECT SUM(C9_QTDLIB*C9_PRCVEN) AS TOT_VLR_PV, MAX(C5_CONDPAG) AS COND "
	cCondQry  += "FROM "+RetSqlName("SC9")+" SC9,"+RetSqlName("SC5")+" SC5 "
	cCondQry  += "WHERE "
	cCondQry  += "     SC9.C9_FILIAL  = '01' AND "
	cCondQry  += "     SC9.C9_CLIENTE = '"+wCliente+"' AND "
	cCondQry  += "     SC9.C9_LOJA    = '"+wLoja   +"' AND "
	cCondQry  += "     SC9.C9_PEDIDO  = '"+wPedido +"' AND "
	cCondQry  += "     SC9.C9_NFISCAL IN (' ')         AND "
	cCondQry  += "     SC9.D_E_L_E_T_ = ' '           AND "
	cCondQry  += "     SC5.D_E_L_E_T_ = ' '           AND  "
	cCondQry  += "     SC9.C9_PEDIDO = SC5.C5_NUM  "
	cQuery    += cCondQry
	TCQuery cQuery Alias "TMP3" New

	//Localiza o Estado do Cliente
	cSql := ""
	cSql += " SELECT A1_COD, A1_EST "
	cSql += " FROM " +RetSqlName("SA1")+ " SA1          "
	cSql += " WHERE SA1.A1_COD     = '"+wCliente+"' AND "
	cSql += "       SA1.A1_LOJA    = '"+wLoja   +"' AND "
	cSql += "       SA1.D_E_L_E_T_ = ''                  "
	TCQuery cSql Alias "RAN3" New

	//Inicializa Variaveis
	nTotProd := 0
	nTotIPI  := 0
	nTotVLR  := 0
	nTotal   := 0
	nBaseIcmsSubst := 0
	nIcmsSubst := 0

	//Valor do Produtos
	nTotProd := TMP3->TOT_VLR_PV
	//Valor do IPI
	nTotIPI  := (nTotProd*5/100) //ALTERADO O PERCENTUAL DE IPI
	//Valor Total com IPI
	nTotVLR  := nTotProd + (nTotProd*10/100)
	//Verifica se o estado e MG
	If Alltrim(RAN3->A1_EST) = "MG"
		//Base Icms Substituicao
		nBaseIcmsSubst := nTotVLR + (nTotVLR*35/100)
		//ICMS Substituicao  =  Base Icms Sub *18        ICMS
		nIcmsSubst     := (nBaseIcmsSubst*18/100) - (nTotProd*12/100)
	EndIf
	//Valor Total da NF
	nTotal := nTotProd + nTotIPI + nIcmsSubst

	cCond     := TMP3->COND

	//Fecha Arquivo Temporario
	RAN3->(DbCloseArea())
	TMP3->(DbCloseArea())

	nLimite := GETMV("MV_YLIMFAT")
	//Condicao(valorproduto,codcondicao,valoripi,dDataBase,valoricmsretido)
	aParc := Condicao(nTotal,cCond,nTotIPI,dDataBase,nIcmsSubst)

	If Len(aParc) > 0
		If Len(aParc) > 1
			ValParc := aParc[2,2]
		Else
			ValParc := aParc[1,2]
		EndIf
		If ValParc < nLimite .AND. ValParc <> 0
			cMsg := ""
			cMsg += "ATENCAO!! "+chr(13)
			cMsg += ""+chr(13)
			cMsg += "VLR PARC. TIT. RECEBER R$ "+ALLTRIM(TRANS(ValParc,"@E 9,999,999.99"))+"  MENOR QUE O LIMITE R$  " +ALLTRIM(TRANS(nLimite,"@E 999.99"))+chr(13)
			MsgBox(cMsg,"","STOP")
			aRadio := {"SIM   ","NAO   "}
			nRadio := 2
			wFim := .T.
			While wFim
				@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "Continua com o ROMANEIO '(S/N) ?'"
				@ 000,010 TO 30,70 TITLE "Opcoes"
				@ 007,020 RADIO aRadio VAR nRadio
				@ 010,087 BMPBUTTON TYPE 1 ACTION Grava_SZ9()
				ACTIVATE DIALOG oDlg1 CENTER
			EndDo
		Else
			nRadio := 1
			Grava_SZ9()
		EndIf
	Else
		nRadio := 1
		Grava_SZ9()
	EndIf

Return

Static Function Grava_SZ9()
	If nRadio == 2
		Close(oDlg1)
		wFim := .F.
		Return
	EndIf
	dbSelectArea("SZ9")
	dbSetOrder(3)
	If  ! dbSeek(xFilial("SZ9")+wNumero+aCols_N[wi,wPL_Item]+aCols_N[wi,wPL_Sequen]+aCols_N[wi,wPL_Local]+aCols_N[wi,wPL_Localiz]+aCols_N[wi,wPL_Lote],.T.)
		Reclock("SZ9",.T.)
		SZ9->Z9_FILIAL  := xFilial("SZ9")
		SZ9->Z9_NUMERO  := wNumero
		SZ9->Z9_AGREG   := wAgreg
		SZ9->Z9_QTDORI  := aCols_N[wi,wPL_QtdLib]
		SZ9->Z9_EMISSAO := DDATABASE  // DATE()
		SZ9->Z9_NUMSEQ  := Space(6)
		SZ9->Z9_PEDIDO  := aCols_N[wi,wPL_Pedido]
		SZ9->Z9_ITEM    := aCols_N[wi,wPL_Item]
		SZ9->Z9_SEQUEN  := aCols_N[wi,wPL_Sequen]
		SZ9->Z9_PRODUTO := aCols_N[wi,wPL_Produto]
		SZ9->Z9_DESCRIC := aCols_N[wi,wPL_Descri]
		SZ9->Z9_QTDLIB  := aCols_N[wi,wPL_QtdLib]
		SZ9->Z9_QTDLIB2 := aCols_N[wi,wPL_QtdLi2]
		SZ9->Z9_LOCAL   := aCols_N[wi,wPL_Local]
		SZ9->Z9_LOCALIZ := aCols_N[wi,wPL_Localiz]
		SZ9->Z9_LOTECTL := aCols_N[wi,wPL_Lote]
		SZ9->Z9_ORIGEM  := aCols_N[wi,wPL_Origem]
		SZ9->Z9_MOTOR   := wMotor
		SZ9->Z9_PLACA   := wPlaca
		SZ9->Z9_UF      := wUF
		_Verpeso()
		SZ9->Z9_PESOBR  := _peso
		ConfirmSX8()
	Else
		While ! Reclock("SZ9",.F.) ; End
		SZ9->Z9_QTDLIB  := aCols_N[wi,wPL_QtdLib]
		SZ9->Z9_QTDLIB2 := aCols_N[wi,wPL_QtdLi2]
		SZ9->Z9_LOCAL   := aCols_N[wi,wPL_Local]
		SZ9->Z9_LOCALIZ := aCols_N[wi,wPL_Localiz]
		SZ9->Z9_LOTECTL := aCols_N[wi,wPL_Lote]
		SZ9->Z9_MOTOR   := wMotor
		SZ9->Z9_PLACA   := wPlaca
		SZ9->Z9_UF      := wUF
		_Verpeso()
		SZ9->Z9_PESOBR  := _peso
	EndIf
	SZ9->(MsUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha alertacoes no SC9                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC9")
	dbSetOrder(1)
	If  dbSeek(xFilial("SC9")+aCols_N[wi,wPL_Pedido]+aCols_N[wi,wPL_Item]+aCols_N[wi,wPL_Sequen],.T.)
		If  SZ9->Z9_AGREG  <> SC9->C9_AGREG
			While ! Reclock("SC9",.F.) ; End
			SC9->C9_AGREG  := SZ9->Z9_AGREG
			MsUnlock()
		EndIf
	EndIf

	If Len(aParc) > 0
		If ValParc < nLimite
			Close(oDlg1)
			wFim := .F.
		EndIf
	EndIf

Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Exclui_Romaneio                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Exclui_Romaneio
Static Function Exclui_Rom()
	local i
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusao Liberacao Pedido                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= aHeader_PL
	aCols  := aCols_PL
	For  i := 1 to len(aCols)
		If  ! aCols[i,wPL_Delet]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ha alteracoes no SC9                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC9")
			dbSetOrder(1)
			If  dbSeek(xFilial("SC9")+aCols[i,wPL_Pedido]+aCols[i,wPL_Item]+aCols[i,wPL_Sequen],.T.) ;
			.and. SC9->C9_AGREG <> "    "
				While ! Reclock("SC9",.F.) ; End
				SC9->C9_AGREG  := "    "
				MsUnlock()
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui registro no SZ9                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ9")
	dbSetOrder(1)
	If  dbSeek(xFilial("SZ9")+wNumero,.T.)
		While ! Eof() .And. SZ9->Z9_NUMERO == wNumero
			While ! Reclock("SZ9",.F.) ; End
			dbDelete()
			MsUnlock()
			dbSkip()   // Antonio - Verificar Caso Set Delet On
		End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusao Requisicoes                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:= aHeader_RQ
	aCols  := aCols_RQ
	If  len(aCols) > 0
		For  i := 1 to len(aCols)
			If  ! aCols[i,wRQ_Delet]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acerta SD3                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD3")
				dbSetOrder(4)
				If  dbSeek(xFilial("SD3")+aCols[i,wRQ_NumSeq],.T.)
					While ! Reclock("SD3",.F.) ; End
					SD3->D3_YROM := "N"
					MsUnlock()
				EndIf
			EndIf
		Next
	EndIf
	lFim_PL := .T.
	lFim_RQ := .T.
	Close(oDlgPL)
	//Close(oDlgRQ)
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Close_PL                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Close_PL
Static Function Close_PL()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha dialogo                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Close(oDlgPL)
	lFim_PL := .T.
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Verif_Linha                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Verif_Linha
Static Function Verif_Linha()
	Local i
	aHeader := aHeader_PL
	aCols   := aCols_PL
	If  ! aCols[n,wPL_Delet]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza totais                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF  n > wLCols
			aadd(aQtdLib,0)
			aadd(aQtdLib2,0)
			aadd(aLocal,"  ")
			aadd(aLocaliz,Space(15))
			aadd(aLote,Space(10))
			aadd(aPeso,0)
			aadd(aFatConv,0)
			wLCols := Len(aCols_PL)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o produto nao faz parte do pedido original               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  aCols[n,wPL_Origem] <> "S"
			z        := 0
			wProduto := aCols[n,wPL_Produto]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Esta rotina permite que se pesquise produtos que estavam na carga ini-³
			//³ cial do SC9.                                                          ³
			//³ Empty()       -> Se .T., significa que o produto nao estava na carga  ³
			//³                  inicial                                              ³
			//³ ASCAN()       -> Como esta montado, com "ael",  faz pesquisa em todos ³
			//³                  as linhas do array.                                  ³
			//³ aCols,{|ael|} -> Acessa todos os elementos da linha.                  ³
			//³                                                                       ³
			//³If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])==Alltrim(wProduto))³
			//³-> Onde, n = Linha atual do Acols                                      ³
			//³         z = varia de 1 ate Len(Acols)                                 ³
			//³         ael[Len(ael)] = Ultima coluna do elemento atual (wPL_Delet)   ³
			//³         o que provoca a leitura de todas as linhas  				  ³
			//³         A expressao: If(ael[Len(ael)].Or.(z:=z+1)==n...               ³
			//³         Se o elemento encontrado for o da linha do multiline sera     ³
			//³         desconsiderado                                                ³
			//³         Se o elemento encontrado for diferente da linha atual do      ³
			//³         multiline, sera comparado Alltrim(ael[3])==Alltrim(wProduto)  ³
			//³         Se nao existir nenhum produto previamente no multiline, sera  ³
			//³         executado a MSGBOX.                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Empty(ASCAN(aCols,{|ael| If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])==Alltrim(wProduto))}))
				MsgBox("Este produto nao faz parte do Pedido Original. Para aceita-lo, favor alterar o Pedido Original","Pedido Original","STOP")
				Return(.F.)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o item conforme o Produto                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  aCols[n,wPL_Item] == "  "
					z                 := 0
					nPos              := ASCAN(aCols,{|ael| If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])==Alltrim(wProduto))})
					aCols[n,wPL_Item] := aCols[nPos,wPL_Item]
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do Peso Bruto                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		wPesoBr   := 0
		wPesoLiqC := 0
		For i:= 1 to Len(aCols)
			If ! aCols[i,wPL_Delet]
				wPesoLiqC := ( aCols[i,wPL_QtdLib] * aPeso[i] )
				If  SB1->B1_TIPCONV == "M"
					wPesoBr := (( aCols[i,wPL_QtdLib] * aFatConv[i] ) * aPesoEmb[i] ) + wPesoBr + wPesoLiqC
				Else
					wPesoBr := (( aCols[i,wPL_QtdLib] / aFatConv[i] ) * aPesoEmb[i] ) + wPesoBr + wPesoLiqC
				EndIF
			EndIf
		Next
		If wPesoTot <> wPesoBr
			wPesoTot := wPesoBr
			wPBPict  := alltrim(trans(wPesoBr ,'@E 999,999,999.999'))
			ObjectMethod(oSayPB,"SetText(wPBPict)")
			ObjectMethod(oDlgPL,"Refresh()")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha repeticao de localizacao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  aCols[n,wPL_Origem] <> "S"
			z        := 0
			wProduto := aCols[n,wPL_Produto]
			wLocal   := aCols[n,wPL_Local]
			wLocaliz := aCols[n,wPL_Localiz]
			wLote    := aCols[n,wPL_Lote]
			If  ! Empty(ASCAN(aCols,{|ael| If(ael[Len(ael)].Or.(z:=z+1)==n,.F.,Alltrim(ael[3])+Alltrim(ael[9])+Alltrim(ael[10])==Alltrim(wProduto)+Alltrim(wLocal)+Alltrim(wLocaliz)+Alltrim(wLote))}))
				MsgBox("Atencao: Localizacao/Lote em Duplicidade. Reveja as localizacoes/Lotes.","Localizacao/Lote em Duplicidade","STOP")
				Return(.F.)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Local e a Localizacao estao digitados                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		wErro := .F.
		If  aCols[n,wPL_Local] == Space(2)
			MsgBox("Favor Informar Local Padrao.","Informar Local Padrao","STOP")
			Return(.F.)
		EndIf
		If  aCols[n,wPL_Localiz] == Space(15)
			MsgBox("Favor Informar a Localizacao.","Informar a Localizacao","STOP")
			Return(.F.)
		EndIf
		If  aCols[n,wPL_Lote] == Space(10)
			MsgBox("Favor Informar o Lote.","Informar o Lote","STOP")
			Return(.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha estoque sufuciente em SBF                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  aCols[n,wPL_Local]   <> aLocal[n]   .Or.  ;
		aCols[n,wPL_Localiz] <> aLocaliz[n] .Or.  ;
		aCols[n,wPL_Lote]    <> aLote[n]
			dbSelectArea("SBF")
			dbSetOrder(1)
			If  dbSeek(xFilial("SBF")+aCols[n,wPL_Local]+aCols[n,wPL_Localiz]+aCols[n,wPL_Produto]+SPACE(20)+aCols[n,wPL_Lote],.T.)
				If  SBF->BF_QUANT - SBF->BF_EMPENHO - aCols[n,wPL_QtdLib] < 0
					MsgBox("Nao ha estoque suficiente nesta localizacao/Lote"," Nao ha estoque suficiente","STOP")
					Return(.F.)
				Endif
			Else
				MsgBox("Localizacao/Lote inexistente para este Produto.","Localizacao/Lote inexistente","STOP")
				Return(.F.)
			EndIf
			aLocal[n]   := aCols[n,wPL_Local]
			aLocaliz[n] := aCols[n,wPL_Localiz]
			aLote[n] := aCols[n,wPL_Lote]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula totais                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		wQtdCalc := 0
		wQtdCalc2:= 0
		wNumCalc := 0
		For  i   := 1 to len(aCols_PL)
			If  !aCols[i,wPL_Delet]
				wNumCalc := wNumCalc + 1
				wQtdCalc := wQtdCalc + aCols[i,wPL_QtdLib]
				wQtdCalc2:= wQtdCalc2+ aCols[i,wPL_QtdLi2]
			Endif
		Next
		If  wQtdCalc > wQtdBal
			MsgBox("Atencao, Quantidade Total digitada: "+alltrim(trans(wQtdCalc,"@E  999,999"))+" esta maior que a Quantidade Total Original: "+alltrim(trans(wQtdBal,"@E  999,999")),"Quantidade Total digitada","INFO")
		EndIf
		If  wQtdCalc < wQtdBal
			MsgBox("Atencao, Quantidade Total digitada: "+alltrim(trans(wQtdCalc,"@E  999,999"))+" esta menor que a Quantidade Total Original: "+alltrim(trans(wQtdBal,"@E  999,999")),"Quantidade Total digitada","INFO")
		EndIf
		If  wQtdCalc  <> wQtdItem  .Or. ;
		wQtdCalc2 <> wQtdItem2
			wQtdItem := wQtdCalc
			wQtdItem2:= wQtdCalc2
			wQtdPict  := alltrim(trans(wQtdItem ,'@E  999,999.99'))
			wQtdPict2 := alltrim(trans(wQtdItem2,'@E  999,999.99'))
			wQtRQPict := alltrim(trans(wQtdRQ   ,'@E  999,999.99'))
			wQtRQPict2:= alltrim(trans(wQtdRQ2  ,'@E  999,999.99'))
			ObjectMethod(oSayQtd,"SetText(wQtdPict)")
			ObjectMethod(oSayQtd2,"SetText(wQtdPict2)")
			ObjectMethod(oSayRQ,"SetText(wQtRQPict)")
			ObjectMethod(oSayRQ2,"SetText(wQtRQPict2)")
			ObjectMethod(oDlgPL,"Refresh()")
		EndIf
	EndIF

	aHeader_PL := aHeader
	aCols_PL   := aCols
Return(.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Dele_RQ                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Dele_RQ
Static Function Dele_RQ()
	If  wOpcao <> "E"
		aCols_RQ := {}
		aadd(aCols_RQ,{space(6),space(15),Space(30),0,0,ctod("  /  /  "),space(15),space(10),space(6),space(4),.F.})
	EndIf
	aHeader := aHeader_RQ
	aCols   := aCols_RQ
	Close_RQ()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     Execute(Close_RQ)
	wEx := .F.
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Close_RQ                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Close_RQ
Static Function Close_RQ()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha dialog                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Close(oDlgRQ)
	lFim_RQ := .T.
Return
//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Valida_RQ                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Valida_RQ
Static Function Valida_RQ()
	local i
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifique duplicidade                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lErro1 := .F.
	lErro2 := .F.
	For  i  := 1 to len(aCols)
		If  ! aCols[i,wRQ_Delet]
			If  empty(aCols[i,wRQ_Doc])
				lErro1 := .T.
			Endif
			wi      := i
			wNumSeq := aCols[i,wRQ_NumSeq]
			wQtd    := 0
			For  i   := 1 to len(aCols)
				If  ! aCols[i,wRQ_Delet]
					If  aCols[i,wRQ_NumSeq] == wNumSeq
						wQtd := wQtd + 1
					Endif
				Endif
			Next
			If  wQtd > 1
				lErro2 := .T.
			Endif
			i := wi
		Endif
	Next
	If  lErro1 .or. lErro2
		If  lErro1
			MsgBox("Linhas sem requisicao informada. Verifique.","Linha vazia","STOP")
			Return(.F.)
		Endif
		If  lErro2
			MsgBox("Linhas com requisicoes em duplicidade. Verifique.","Duplicidade","STOP")
			Return(.F.)
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva aHeader / aCols                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader_RQ := aHeader
	aCols_RQ   := aCols
	lFim_RQ    := .F.
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³ Inclui_Mot                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Inclui_Mot
Static Function Inclui_Mot()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ monta a persiana em WINDOWS                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 204,000 TO 289,600 DIALOG oWin010 TITLE "Cadastro de Motorista"
	//@ 005,005 TO 025,295

	@ 05,10 Say "Motorista:"
	@ 05,68 Get wMotor       picture "@!"
	@ 15,10 Say "Placa:"
	@ 15,68 Get wPlaca       picture "@R !!!-9999"
	@ 25,10 Say "UF:"
	@ 25,68 Get wUF          picture "@!" F3 "12"

	@ 030,240 BMPBUTTON TYPE 4 ACTION _Digita()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    @ 030,240 BMPBUTTON TYPE 4 ACTION Execute(_Digita)
	@ 030,270 BMPBUTTON TYPE 2 ACTION Close(oWin010)
	ACTIVATE DIALOG oWin010
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function _Digita
Static Function _Digita()
	Close(oWin010)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function _Verpeso
Static Function _Verpeso()

	DbSelectArea("SB1")
	DbSetOrder(1)
	Dbseek(xFilial("SB1")+SZ9->Z9_PRODUTO)

	sPESEMB := ""
	sPESO	:= ""
	sDIVPA	:= ""
	/*aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
	DbSelectArea("ZZ9")
	DbSetOrder(1)
	IF !DbSeek(xFilial("ZZ9")+ aCODPRODUTO + SD2->D2_LOTECTL )
	sPESEMB := ZZ9->ZZ9_PESEMB
	sPESO	:= ZZ9->ZZ9_PESO
	sDIVPA	:= ZZ9->ZZ9_DIVPA
	END IF */
	aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
	cSQLL := ""							
	cSQLL := "SELECT * FROM ZZ9010 "
	cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
	cSQLL += "		ZZ9_LOTE = '" +SZ9->Z9_LOTECTL+ "' AND "
	cSQLL += "		D_E_L_E_T_ = '' "
	IF chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	ENDIF
	TCQuery cSQLL Alias "_ZZ9" New							
	IF ! _ZZ9->(EOF())
		sPESEMB := _ZZ9->ZZ9_PESEMB
		sPESO	:= _ZZ9->ZZ9_PESO
		sDIVPA	:= _ZZ9->ZZ9_DIVPA
	ELSE
		sPESEMB := SB1->B1_YPESEMB
		sPESO	:= SB1->B1_PESO
		sDIVPA	:= SB1->B1_YDIVPA
	END IF															

	//LiqC := ( SZ9->Z9_QTDLIB  * SB1->B1_PESO ) //peso liq.
	LiqC := ( SZ9->Z9_QTDLIB  * sPESO ) //peso liq.
	If SB1->B1_TIPCONV == "M"
		//_peso  := LiqC + (( SZ9->Z9_QTDLIB * SB1->B1_CONV ) * SB1->B1_YPESEMB ) //peso liq + peso embalagem
		_peso  := LiqC + (( SZ9->Z9_QTDLIB * SB1->B1_CONV ) * sPESEMB ) //peso liq + peso embalagem
	Else
		//_peso  := LiqC + (( SZ9->Z9_QTDLIB / SB1->B1_CONV ) * SB1->B1_YPESEMB )//peso liq + peso embalagem
		_peso  := LiqC + (( SZ9->Z9_QTDLIB / SB1->B1_CONV ) * sPESEMB ) //peso liq + peso embalagem
	EndIf
Return
