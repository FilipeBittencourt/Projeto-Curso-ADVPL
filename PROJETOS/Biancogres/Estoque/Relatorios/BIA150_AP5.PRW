#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIAFG035
@author WLADIMIR ILLIUSHENKO
@since 21/08/2001
@version 1.0
@description Relatorio de materiais de baixo giro.
@type function
/*/

User Function Bia150()

	SetPrvt("CQUERY,CWHERE")
	SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS")
	SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP,CTIPO")
	SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
	SetPrvt("ARETURN,ACAMPOS,ACONCENC,ADCONCENC")
	SetPrvt("CANOPESQ,CMESPESQ")
	SetPrvt("NCRCCONTROL,NL,NCONCENC,NMEDIA,NTOTREGS,NTIPOS,NTOTTIPO,NTOTPARC,NTOTGERAL")

	cDesc1			:= "Este programa tem como objetivo emitir um relatorio de itens que nao tiveram   "
	cDesc2			:= "movimento no periodo especificado (sem movimentacao interna , compra, venda,   "
	cDesc3			:= "devolucao, solicitacao, autorizacao de entrega ou pedido).                     "
	cTamanho	    := "M"
	cAlias 			:= "SD3"
	cTitulo			:= "Materiais de baixo giro"
	aReturn			:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	cNomeProg 		:= "BIA150"
	nCbcont			:= 0
	cCbtxt 			:= space(10)
	m_pag 			:= 1
	aOrd			:= { }
	lGravParam 	    := .F.
	lPodeComp       := .T.
	lTemDic	        := .F.
	lGravParam      := .F.
	nL              := 80

	cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
	if lastkey()==27 .OR. nLastKey==27
		Return
	endif

	Pergunte(cNomeProg,lGravParam)
	SetDefault(aReturn, cAlias)

	nCrcControl := iif(aReturn[4]==1,15,18)
	cCabec1	   := "TIPO  CODIGO.  DESCRICAO...........................................LOCAL...  ........ESTOQUE  UND  .....CUSTO(R$)  .....TOTAL(R$)"
	cCabec2	   := ""

	Processa({|| fCriaTemp() })
	Processa({|| fAcumula()  })
	if nTotRegs > 0
		Processa({|| fImprime()  })
		Processa({|| fExportExcel()  })
	endif
	Processa({|| fApagaTemp()})

	if nTotRegs > 0

		if aReturn[5] == 1
			set printer to
			OurSpool(cNomeArq)
		endif

		Ft_PFlush()

	endif

return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria arquivo temporario para impressao do relatorio.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static FUNCTION fCriaTemp()

	aCampos := {}
	AADD(aCampos,{ "TIPO"      , "C", 02, 0 })
	AADD(aCampos,{ "CODIGO"    , "C", 07, 0 })
	AADD(aCampos,{ "DESCRICAO" , "C", 50, 0 })
	AADD(aCampos,{ "ALMOXARIF" , "C", 02, 0 })
	AADD(aCampos,{ "LOCALIZ"    , "C", 15, 0 })
	AADD(aCampos,{ "ESTOQUE"   , "N", 10, 2 })
	AADD(aCampos,{ "UNIDADE"   , "C", 03, 2 })
	AADD(aCampos,{ "ULTIMOCUST", "N", 14, 2 })
	AADD(aCampos,{ "TOTAL"     , "N", 14, 2 })
	cArqTemp := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,, cArqTemp, "REL")

return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fAcumula ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acumula os dados no arquivo temporario.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static function fAcumula()

	cQuery := ""
	cWhere := ""
	cQuery += "SELECT COUNT(DISTINCT SB1.B1_COD) AS TOTREGS "
	cWhere += "FROM                                         "
	cWhere += "     "+RetSqlName("SB1")+" SB1, "
	cWhere += "     "+RetSqlName("SB2")+" SB2,  "
	cWhere += "     "+RetSqlName("SBZ")+" SBZ,  "
	cWhere += "     "+RetSqlName("ZCN")+" ZCN  "
	cWhere += ""
	cWhere += "WHERE                                               "
	cWhere += "   (SB1.B1_FILIAL   = '"+xFilial("SB1")+"'                   ) AND  "
	cWhere += "   (LEN(SB1.B1_COD) = 7                      ) AND  "
	cWhere += "   (SUBSTRING(SB1.B1_COD,4,4) NOT IN ('0000')) AND  "
	cWhere += "   (SB1.B1_COD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') AND  "
	cWhere += "   (SB1.B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') AND  "
	cWhere += "   (SB1.B1_GRUPO NOT IN ('PA')               ) AND  "
	IF MV_PAR10 == 1
		cWhere += "  (SBZ.BZ_YATIVO <> 'N'                  ) AND  "
	ENDIF
	cWhere += "   (SB1.D_E_L_E_T_ = ''                      ) AND  "
	cWhere += ""
	cWhere += "   (SB2.B2_FILIAL  = '"+xFilial("SB2")+"'    ) AND "
	cWhere += "   (SB2.B2_COD     = SB1.B1_COD) AND "
	cWhere += "   (ZCN.ZCN_FILIAL  = '"+xFilial("ZCN")+"'    ) AND "
	cWhere += "   (ZCN.ZCN_COD     = SB1.B1_COD) AND "
	cWhere += "   (ZCN.ZCN_LOCAL     = SB2.B2_LOCAL) AND "
	cWhere += "   (ZCN.ZCN_LOCAL     BETWEEN "+ ValtoSql(MV_PAR12) +" AND " + ValtoSql(MV_PAR13) + ") AND "
	cWhere += "   (ZCN.D_E_L_E_T_ = ''                      ) AND  "	
	IF MV_PAR07 == 1
		cWhere += "   (SB2.B2_QATU    >= 1         ) AND "
	ELSE
		cWhere += "   (SB2.B2_QFIM    >= 1         ) AND "
	ENDIF
	cWhere += "   (SB2.D_E_L_E_T_ = ''        ) AND "
	cWhere += ""
	cWhere += "   (SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'      ) AND "
	cWhere += "   (SBZ.BZ_COD     = SB1.B1_COD) AND "
	cWhere += "   (SBZ.D_E_L_E_T_ = ''        ) AND "
	IF MV_PAR09 == 1
		cWhere += "   (ZCN.ZCN_MD   = 'S'       ) "
	ELSE
		cWhere += "   (ZCN.ZCN_MD   = 'N'       ) "
	ENDIF

	IF MV_PAR11 == 2 .OR. MV_PAR11 == 5
		cWhere += " AND "
		cWhere += "   (SB1.B1_COD NOT IN (SELECT SD3.D3_COD                           "   && Itens sem movimentacao interna.
		cWhere += "                       FROM "+RetSqlName("SD3")+" SD3              "
		cWhere += "                       WHERE (SD3.D3_FILIAL  =  '"+xFilial("SD3")+"'         ) AND "
		cWhere += "                             (SD3.D3_COD     =  SB1.B1_COD   ) AND "
//		cWhere += "                             (SD3.D3_LOCAL   =  SB1.B1_LOCPAD) AND "
		cWhere += "                             (SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND "
		cWhere += "                             (SD3.D_E_L_E_T_ =  ''           ))) "
	ENDIF

	IF MV_PAR11 == 1 .OR. MV_PAR11 == 5
		cWhere += " AND "
		cWhere += "  (SB1.B1_COD NOT IN (SELECT SD1.D1_COD                           "   && Itens sem NF de compra ou devolucao.
		cWhere += "                      FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4 "
		cWhere += "                      WHERE (SD1.D1_FILIAL  =  '"+xFilial("SD1")+"'         ) AND "
		cWhere += "                            (SD1.D1_COD     =  SB1.B1_COD   ) AND "
		cWhere += "                            (SD1.D1_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND "
		cWhere += "                            (SD1.D_E_L_E_T_ =  ''           ) AND "
		cWhere += "                            (SF4.F4_FILIAL  =  '"+xFilial("SF4")+"'         ) AND "
		cWhere += "                            (SF4.F4_CODIGO  = SD1.D1_TES    ) AND "
		cWhere += "                            (SF4.F4_ESTOQUE = 'S'           ) AND "
		cWhere += "                            (SF4.D_E_L_E_T_ =  ''           ))) "
	ENDIF

	IF MV_PAR11 == 3 .OR. MV_PAR11 == 5
		cWhere += " AND "
		cWhere += "  (SB1.B1_COD NOT IN (SELECT SD2.D2_COD                           "  && Itens sem NF de venda ou devolucao.
		cWhere += "                      FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4 "
		cWhere += "                      WHERE (SD2.D2_FILIAL  =  '"+xFilial("SD2")+"'         ) AND "
		cWhere += "                            (SD2.D2_COD     =  SB1.B1_COD   ) AND "
		cWhere += "                            (SD2.D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND "
		cWhere += "                            (SD2.D_E_L_E_T_ =  ''           ) AND "
		cWhere += "                            (SF4.F4_FILIAL  =  '"+xFilial("SF4")+"'         ) AND "
		cWhere += "                            (SF4.F4_CODIGO  = SD2.D2_TES    ) AND "
		cWhere += "                            (SF4.F4_ESTOQUE = 'S'           ) AND "
		cWhere += "                            (SF4.D_E_L_E_T_ =  ''           )))  "
	ENDIF

	IF MV_PAR11 == 4 .OR. MV_PAR11 == 5
		cWhere += " AND  "
		cWhere += "   (SB1.B1_COD NOT IN (SELECT SC1.C1_PRODUTO                     "  && Itens sem solicitacao de compra.
		cWhere += "                       FROM "+RetSqlName("SC1")+" SC1 "
		cWhere += "                       WHERE (SC1.C1_FILIAL  =  '"+xFilial("SC1")+"'       ) AND "
		cWhere += "                             (SC1.C1_PRODUTO =  SB1.B1_COD ) AND "
		cWhere += "                             (SC1.C1_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND "
		cWhere += "                             (SC1.D_E_L_E_T_ =  ''         ))) AND "
		cWhere += ""
		cWhere += "   (SB1.B1_COD NOT IN (SELECT SC7.C7_PRODUTO                    "  && Itens sem pedido de compra.
		cWhere += "                       FROM "+RetSqlName("SC7")+" SC7 "
		cWhere += "                       WHERE (SC7.C7_FILIAL  =  '"+xFilial("SC7")+"'      ) AND "
		cWhere += "                             (SC7.C7_PRODUTO =  SB1.B1_COD) AND "
		cWhere += "                             (SC7.C7_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"') AND "
		cWhere += "                             (SC7.D_E_L_E_T_ =  ''        )))   "
	ENDIF

	cQuery := cQuery + cWhere
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cQuery  := ""
		cQuery  += "SELECT "
		cQuery  += "       SB1.B1_TIPO                 AS TIPO,      "
		cQuery  += "       SUBSTRING(SB1.B1_COD,1,7)   AS CODIGO,    "
		cQuery  += "       SUBSTRING(SB1.B1_DESC,1,50) AS DESCRICAO, "
		cQuery  += "       ZCN.ZCN_LOCALI               AS LOCALIZ,    "
		cQuery  += "       ZCN.ZCN_LOCAL               AS ALMOXARIF,    "
		IF MV_PAR07 == 1
			cQuery  += "       SB2.B2_QATU                 AS ESTOQUE,   "
			cQuery  += "       SB1.B1_UM                   AS UNIDADE,   "
			cQuery  += "       SB2.B2_CM1                  AS CUSTO      "
		ELSE
			cQuery  += "       SB2.B2_QFIM                          AS ESTOQUE,   "
			cQuery  += "       SB1.B1_UM                            AS UNIDADE,   "
			cQuery  += "       ROUND(SB2.B2_VFIM1/SB2.B2_QFIM,2)    AS CUSTO      "
		ENDIF
		cWhere  += "ORDER BY ZCN.ZCN_LOCAL, SB1.B1_TIPO, SB1.B1_COD "
		cQuery  := cQuery + cWhere
		TCQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)
		do while QRY->(!EOF())

			IncProc("Coletando dados...")

			RecLock("REL", .T.)
			REL->TIPO       := QRY->TIPO
			REL->CODIGO     := QRY->CODIGO
			REL->DESCRICAO  := QRY->DESCRICAO
			REL->ALMOXARIF  := QRY->ALMOXARIF
			REL->LOCALIZ    := QRY->LOCALIZ
			REL->ESTOQUE    := QRY->ESTOQUE
			REL->UNIDADE    := QRY->UNIDADE
			REL->ULTIMOCUST := QRY->CUSTO
			REL->TOTAL      := QRY->CUSTO * QRY->ESTOQUE
			REL->(DbUnlock())

			QRY->(DbSkip())
		enddo
		QRY->(DbCloseArea())

	else

		alert("Nao ha dados que satisfacam os parametros para serem listados.")

	endif

return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime  ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static FUNCTION fImprime()

	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp,"REL")

	IF MV_PAR08 == 1
		REL->(DbCreateInd(cArqTemp+".001","LOCALIZ+TIPO+descend(str(TOTAL))", {||LOCALIZ+TIPO+descend(str(ESTOQUE))}))
	ELSE
		REL->(DbCreateInd(cArqTemp+".001","descend(str(TOTAL))", {||descend(str(ESTOQUE))}))
	ENDIF

	ProcRegua(REL->(LastRec()))
	REL->(DbGoTop())
	cTipo     := REL->TIPO
	nTipos    := 0
	nTotTipo  := 0
	nTotParc  := 0
	nTotGeral := 0
	do while REL->(!EOF())

		Incproc("Imprimindo...")

		If Interrupcao(@lAbortPrint)
			Return
		Endif

		if m_pag == 1
			U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
		endif

		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif

		cDados := ""
		cDados += REL->TIPO + space(04)
		cDados += REL->CODIGO + space(02)
		cDados += REL->DESCRICAO + space(02)
		cDados += REL->ALMOXARIF + space(02)
		cDados += REL->LOCALIZ + space(02)
		cDados += STR(REL->ESTOQUE,8,2) + space(02)
		cDados += REL->UNIDADE + space(02)
		cDados += STR(REL->ULTIMOCUST,14,2) + space(02)
		cDados += STR(REL->TOTAL,14,2)
		@ nL, 000 PSay cDados
		nTotParc  += REL->TOTAL
		nTotGeral += REL->TOTAL
		nTotTipo++
		nL++

		REL->(DbSkip())

		if cTipo <> REL->TIPO .OR. REL->(EOF())

			if (.NOT. REL->(EOF())) .OR. (nTipos > 1)
				nL++
				cDados := ""
				cDados := "Subtotal..................: "
				cDados += u_rtoc(nTotTipo,"@E 999,999") + IIF(nTotTipo > 1," materiais"+space(71)," material"+space(72)) +STR(nTotParc,14,2)
				@ nL, 000 PSay cDados
				nL++
				nL++
			endif

			if .NOT. REL->(EOF())
				cTipo    := REL->TIPO
				nTotTipo := 0
				nTotParc := 0
				nTipos++
			endif

		endif

	enddo

	nL += 2
	cDados := "Total de materiais listados: "
	cDados += u_rtoc(nTotRegs,"@E 999,999") + IIF(nTotRegs > 1," materiais"+space(71)," material"+space(72)) + STR(nTotGeral,14,2)
	@ nL, 000 PSay cDados

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fApagaTemp ¦ Autor ¦ WLADIMIR ILLIUSHENKO¦ Data ¦ 13/08/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static function fApagaTemp()

	REL->(DbCloseArea("REL")); FErase(cArqTemp+".*")

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fExportExcel ¦ Autor ¦ Marcos A. Soprani ¦ Data ¦ 23/03/18 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static function fExportExcel()

	local nRegAtu   := 0
	Local nTotReg	:= 0
	Local _cBaia	:= ""

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)
	local cArqXML    := "BIA150_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	private cDirDest := AllTrim(GetTempPath())

	REL->(DbGoTop())
	Count To nTotReg 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{21,25,75,245,75,75,35,75,75},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,7) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,7) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Produção por Mão de Obra ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,7)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("TIPO             ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CODIGO           ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DESCRICAO        ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("ALMOXARIF        ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("LOCALIZ          ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("ESTOQUE          ",0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("UNIDADE          ",0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("ULTIMOCUST       ",0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TOTAL            ",0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	REL->(DbGoTop())
	ProcRegua(nTotReg)
	While REL->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula(REL->TIPO             ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->CODIGO           ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->DESCRICAO        ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->ALMOXARIF        ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->LOCALIZ          ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->ESTOQUE          ,2,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->UNIDADE          ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->ULTIMOCUST       ,2,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(REL->TOTAL            ,2,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		REL->(DbSkip())

	EndDo

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

Return
