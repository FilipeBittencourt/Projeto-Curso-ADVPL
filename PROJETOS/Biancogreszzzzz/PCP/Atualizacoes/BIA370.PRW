#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA370
@author Marcos Alberto Soprani
@since 06/01/15
@version 1.0
@description Checa Empenho (SD4) versus Estrutura (SG1) a parir das OP (SC2)
@type function
/*/

User Function BIA370()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private fh_Esc   := .F.
	Private oDlg1
	Private lNegEstr  := GETMV("MV_NEGESTR")
	Private xMkDesMk  := .T.


	private bErro := ErrorBlock( { |oErr|  MsgAlert(oErr:Description) })


	cHInicio := Time()
	fPerg := "BIA370"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	fCabec   := "Checa Empenho vs Estrutura"

	// Resumo para Excel
	aDados2 := {}

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	oFont1     := TFont():New( "Arial Black",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "Courier New",0,-10,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( nLin*.001, nCol*.001, nLin*.88, nCol*.705, fCabec,,,.F.,,,,,,.T.,,,.T. )

	xkMarca := GetMark()
	BIA370A()

	dbSelectArea("MARK")
	ky_Vet := {{"OK"     ,"" ,"Ok"          ,"@!"},;
	{           "LINHA"  ,"" ,"Linha"       ,"@!"},;
	{           "NUMOP"  ,"" ,"NumOP"       ,"@!"},;
	{           "REVISAO","" ,"RevOp"       ,"@!"},;
	{           "STATREV","" ,"StatusR"     ,"@!"},;
	{           "PRODUTO","" ,"Produto"     ,"@!"},;
	{           "DESCR"  ,"" ,"Descr"       ,"@!"},;
	{           "QUANT"  ,"" ,"Quant"       ,"@E 999,999,999.99"},;
	{           "DTINI"  ,"" ,"Data INI"    ,"@!"},;
	{           "DTFIM"  ,"" ,"Data FIM"    ,"@!"},;
	{           "QUJE"   ,"" ,"Quje"        ,"@E 999,999,999.99"} }

	oBrw1      := MsSelect():New( "MARK","OK","",ky_Vet,.F.,@xkMarca,{nLin*.008,nCol*.005,nLin*.410,nCol*.350},,,oDlg1 )
	oBtn1      := TButton()  :New( nLin*.415,nCol*.290,"Fechar"          ,oDlg1,{|| MARK->(dbCloseArea()), fh_Esc := .T., oDlg1:End()                            },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. )
	If MV_PAR06 == 1 // Em Linha
		oBtn2      := TButton()  :New( nLin*.415,nCol*.255,"Processar"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA370B",.F.,.F.), MARK->(dbCloseArea())           },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. )
	Else             // Vencidas
		oBtn2      := TButton()  :New( nLin*.415,nCol*.255,"Processar"       ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA370R",.F.,.F.), MARK->(dbCloseArea())           },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. )
	EndIf

	oBtn3      := TButton()  :New( nLin*.415,nCol*.005,"Marca/Desmarca"  ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA370M",.F.,.F.)                                  },nLin*.050,nCol*.008,,,,.T.,,"",,,,.F. )

	ACTIVATE MSDIALOG oDlg1 CENTERED VALID fh_Esc

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA370A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Cria temporario para o Alias: MARK                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA370A()

	Local aFds := {}
	Local cTmp

	Aadd( aFds , {"OK"      ,"C",002,000} )
	Aadd( aFds , {"LINHA"   ,"C",003,000} )
	Aadd( aFds , {"NUMOP"   ,"C",013,000} )
	Aadd( aFds , {"PRODUTO" ,"C",015,000} )
	Aadd( aFds , {"REVISAO" ,"C",003,000} )
	Aadd( aFds , {"STATREV" ,"C",015,000} )
	Aadd( aFds , {"DESCR"   ,"C",050,000} )
	Aadd( aFds , {"QUANT"   ,"N",014,002} )
	Aadd( aFds , {"DTINI"   ,"D",008,000} )
	Aadd( aFds , {"DTFIM"   ,"D",008,000} )
	Aadd( aFds , {"QUJE"    ,"N",014,002} )

	cTmp := CriaTrab( aFds, .T. )
	Use (cTmp) Alias MARK New Exclusive

	QD003 := " SELECT (SELECT MAX(ZZC2.C2_LINHA)
	QD003 += "           FROM "+RetSqlName("SC2")+" ZZC2 WITH(NOLOCK) 
	QD003 += "          WHERE ZZC2.C2_FILIAL = '"+xFilial("SC2")+"'
	QD003 += "            AND ZZC2.C2_NUM = SC2.C2_NUM
	QD003 += "            AND ZZC2.C2_SEQUEN = '001'
	QD003 += "            AND ZZC2.D_E_L_E_T_ = ' ') C2_LINHA,
	QD003 += "        C2_NUM+C2_ITEM+C2_SEQUEN NUMOP,
	QD003 += "        C2_PRODUTO,
	QD003 += "        C2_REVISAO,
	QD003 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	QD003 += "        C2_QUANT,
	QD003 += "        C2_DATPRI,
	QD003 += "        C2_DATPRF,
	QD003 += "        C2_QUJE,
	QD003 += "        (SELECT COUNT(*)
	QD003 += "           FROM " + RetSqlName("SG1") + " WITH (NOLOCK)
	QD003 += "          WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	QD003 += "            AND G1_COD = C2_PRODUTO
	QD003 += "            AND C2_REVISAO >= G1_REVINI
	QD003 += "            AND C2_REVISAO <= G1_REVFIM
	QD003 += "            AND G1_INI <= '"+dtos(dDataBase)+"'
	QD003 += "            AND G1_FIM >= '"+dtos(dDataBase)+"'
	QD003 += "            AND G1_TRT = C2_REVISAO
	QD003 += "            AND D_E_L_E_T_ = ' ') CONTAD
	QD003 += "   FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK)
	QD003 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	QD003 += "                       AND B1_COD = C2_PRODUTO
	QD003 += "                       AND B1_TIPO = '"+MV_PAR01+"'
	QD003 += "                       AND SB1.D_E_L_E_T_ = ' '
	QD003 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	QD003 += "    AND C2_NUM BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
	QD003 += "    AND C2_PRODUTO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	QD003 += "    AND C2_DATRF = '        '
	QD003 += "    AND (SELECT COUNT(*)
	QD003 += "           FROM " + RetSqlName("SG1") + " WITH (NOLOCK)
	QD003 += "          WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	QD003 += "            AND G1_COD = C2_PRODUTO
	QD003 += "            AND C2_REVISAO >= G1_REVINI
	QD003 += "            AND C2_REVISAO <= G1_REVFIM
	QD003 += "            AND G1_INI <= '"+dtos(dDataBase)+"'
	QD003 += "            AND G1_FIM >= '"+dtos(dDataBase)+"'
	QD003 += "            AND G1_TRT = C2_REVISAO
	If MV_PAR06 == 1  // Em Linha
		QD003 += "            AND D_E_L_E_T_ = ' ') > 0
	Else              // Vencidas
		QD003 += "            AND D_E_L_E_T_ = ' ') = 0
	EndIf
	QD003 += "    AND SC2.D_E_L_E_T_ = ' '
	QD003 += "  ORDER BY C2_LINHA, C2_DATPRI, C2_PRIOR, C2_NUM, C2_SEQUEN
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QD003),'QD03',.T.,.T.)
	dbSelectArea("QD03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		dbSelectArea("MARK")
		RecLock("MARK",.T.)
		MARK->OK      := xkMarca
		MARK->LINHA   := QD03->C2_LINHA
		MARK->NUMOP   := QD03->NUMOP
		MARK->PRODUTO := QD03->C2_PRODUTO
		MARK->REVISAO := QD03->C2_REVISAO
		MARK->STATREV := IIF(QD03->CONTAD > 0, "EM LINHA", "==>> VENCIDA")
		MARK->DESCR   := QD03->DESCR
		MARK->QUANT   := QD03->C2_QUANT
		MARK->DTINI   := stod(QD03->C2_DATPRI)
		MARK->DTFIM   := stod(QD03->C2_DATPRF)
		MARK->QUJE    := QD03->C2_QUJE
		MsUnLock()

		dbSelectArea("QD03")
		dbSkip()

	End
	QD03->(dbCloseArea())
	Ferase(cIndex+OrdBagExt())

	dbSelectArea("MARK")
	dbGoTop()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA370B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Processamento da conciliação                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA370B()

	#IFDEF WINDOWS
	Processa({|| RptB1Dtl()})
Return
Static Function RptB1Dtl()
	#ENDIF

		_Camp := { {"NUM_OP"    , "C", 13, 0},;
		{           "PRODUTO"   , "C", 15, 0},;
		{           "DESCRPR"   , "C", 50, 0},;
		{           "INSUMO"    , "C", 15, 0},;
		{           "UM"        , "C", 02, 0},;
		{           "GRUPO"     , "C", 04, 0},;
		{           "DESCRI"    , "C", 45, 0},;
		{           "EMPENH"    , "N", 18, 7},;
		{           "QTDESTRU"  , "N", 18, 7},;
		{           "DIFERE"    , "N", 18, 4},;
		{           "REGSD4"    , "N", 18, 0},;
		{           "TRT"       , "C", 03, 0} }
		T001 := CriaTrab(_Camp)
		cInd   := CriaTrab(Nil,.F.)
		DbUseArea(.T.,,T001,"T001",.F.,.F.)
		dbCreateInd(T001,"NUM_OP+INSUMO",{|| "NUM_OP+INSUMO" })
	
		dbSelectArea("MARK")
		dbGoTop()

	BEGIN SEQUENCE

		If !fCriaSem()
			fh_Esc := .T.
			oDlg1:End()
			Return
		EndIf
	
		ProcRegua(RecCount())
		While !Eof()                                                       // Empenhos
			**************************************************************************
	
			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Empenho - Tempo: "+cTempo)
	
			If MARK->OK == xkMarca
	
				dbSelectArea("SD4")
				dbSetOrder(2)
				If dbSeek(xFilial("SD4")+MARK->NUMOP)
	
					While !Eof() .and. SD4->D4_FILIAL == xFilial("SD4") .and. SD4->D4_OP == MARK->NUMOP
	
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD))
						dbSelectArea("T001")
						If !dbSeek(MARK->NUMOP+SD4->D4_COD)
							RecLock("T001",.T.)
							T001->NUM_OP  := MARK->NUMOP
							T001->PRODUTO := MARK->PRODUTO
							T001->DESCRPR := MARK->DESCR
							T001->INSUMO  := SD4->D4_COD
							T001->UM      := SB1->B1_UM
							T001->GRUPO   := SB1->B1_GRUPO
							T001->DESCRI  := SB1->B1_DESC
							T001->REGSD4  := SD4->(Recno())
							T001->TRT     := SD4->D4_TRT
						Else
							RecLock("T001",.F.)
						EndIf
						T001->EMPENH += SD4->D4_QTDEORI
						MsUnLock()
	
						dbSelectArea("SD4")
						dbSkip()
	
					End
	
				EndIf
	
			EndIf
	
			dbSelectArea("MARK")
			dbSkip()
	
		End
	
		dbSelectArea("MARK")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()                                                     // Estruturas
			**************************************************************************
	
			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Estrutura - Tempo: "+cTempo)
	
			If MARK->OK == xkMarca
	
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+MARK->PRODUTO)
	
				nEstru     := 0
				wProduto   := SB1->B1_COD
				wQtd       := MARK->QUANT
				cArqTmp    := ""
				cAliasTRB  := cArqTRB := "Estrut"
	
				cNome      := Processa({|| StrutBia(wProduto, wQtd, cAliasTRB, cArqTRB, .F.) })
				cArqTRB    := cArqTmp
				ESTRUT->(dbGoTop())
				While ESTRUT->(!Eof())
					cTempo := Alltrim(ElapTime(cHInicio, Time()))
					IncProc("Produto: "+wProduto+"  Tempo: "+cTempo)
	
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+ESTRUT->COMP))
					dbSelectArea("T001")
					If !dbSeek(MARK->NUMOP+ESTRUT->COMP)
						RecLock("T001",.T.)
						T001->NUM_OP  := MARK->NUMOP
						T001->PRODUTO := MARK->PRODUTO
						T001->DESCRPR := MARK->DESCR
						T001->INSUMO  := ESTRUT->COMP
						T001->UM      := SB1->B1_UM
						T001->GRUPO   := SB1->B1_GRUPO
						T001->DESCRI  := SB1->B1_DESC
						T001->TRT     := ESTRUT->TRT
					Else
						RecLock("T001",.F.)
					EndIf
					T001->QTDESTRU += Round(ESTRUT->QUANT,2)
					MsUnLock()
	
					ESTRUT->(dbSkip())
				End
				U_BIAFimStru(cAliasTRB,cArqTRB)
	
			EndIf
	
			dbSelectArea("MARK")
			dbSkip()
		End
	
		dbSelectArea("T001")
		dbGoTop()
		While !Eof()
	
			If MV_PAR02 == 1
				If T001->EMPENH == T001->QTDESTRU
					dbSelectarea("T001")
					dbSkip()
					Loop
				EndIf
			EndIf
	
			If MV_PAR03 == 1
				Aadd(aDados2, { T001->NUM_OP,;
				T001->PRODUTO,;
				T001->DESCRPR,;
				T001->INSUMO,;
				T001->UM,;
				T001->GRUPO,;
				T001->DESCRI,;
				T001->EMPENH,;
				T001->QTDESTRU,;
				T001->EMPENH-T001->QTDESTRU,;
				T001->REGSD4,;
				T001->TRT })
			Else
				Aadd(aDados2, { T001->NUM_OP,;
				T001->PRODUTO,;
				T001->DESCRPR,;
				T001->INSUMO,;
				T001->UM,;
				T001->GRUPO,;
				T001->DESCRI,;
				Transform(T001->EMPENH,"@E 99,999,999.9999999"),;
				Transform(T001->QTDESTRU,"@E 99999,999,999.9999"),;
				Transform(T001->EMPENH-T001->QTDESTRU,"@E 99,999,999.9999999"),;
				Transform(T001->REGSD4,"@E 999999999999999999"),;
				T001->TRT } )
			EndIf
	
			dbSkip()
		End
	
		T001->(dbCloseArea())
	
		If MV_PAR02 == 1 .and. MV_PAR03 == 1
			Processa({|| fxAtuSD4() })
		Else
			U_BIAxExcel(aDados2, _Camp, T001)
		EndIf
	
		fh_Esc := .T.
		oDlg1:End()


	END SEQUENCE

	ErrorBlock( bErro )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA370M  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Marca / Desmarca todos                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA370M()

	Local rtMrk := Space(2)
	If xMkDesMk
		xMkDesMk := .F.
	Else
		xMkDesMk := .T.
		rtMrk    := xkMarca
	EndIf

	dbSelectArea("MARK")
	dbGoTop()
	While !Eof()
		RecLock("MARK",.F.)
		MARK->OK := rtMrk
		MsUnLock()
		dbSelectArea("MARK")
		dbSkip()
	End
	dbGoTop()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ StrutBia ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function StrutBia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow)

	LOCAL nRegi:=0,nQuantItem:=0
	LOCAL aCampos:={},aTamSX3:={},lAdd:=.F.
	LOCAL nRecno
	cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant:=IF(nQuant == NIL,1,nQuant)
	lAsShow:=IF(lAsShow==NIL,.F.,lAsShow)
	nEstru++
	If nEstru == 1
		// Cria arquivo de Trabalho
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COMP")
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		cArqTrab := CriaTrab(aCampos)
		If Select(cAliasEstru) > 0
			dbSelectArea(cAliasEstru)
			dbCloseArea()
		EndIf
		Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
		IndRegua(cAliasEstru,cArqTrab,"CODIGO+COMP+TRT",,,"Selecionando Registros...")
		dbSetIndex(cArqtrab+OrdBagExt())
	EndIf

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc(wProduto+" 1 Tempo: "+cTempo)

	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial("SG1")+cProduto)

	While !Eof() .and. Alltrim(SG1->G1_FILIAL+SG1->G1_COD) == Alltrim(xFilial("SG1")+cProduto)
		nRegi:=Recno()
		If SG1->G1_COD != SG1->G1_COMP
			lAdd:=.F.
			If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM

				nQuantItem := xBia370E(nQuant)

				If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))

					SBZ->(dbSetOrder(1))
					SBZ->(dbSeek(xFilial("SBZ")+SG1->G1_COMP))
					If SBZ->BZ_FANTASM <> "S"

						SBZ->(dbSetOrder(1))
						SBZ->(dbSeek(xFilial("SBZ")+SG1->G1_COD))
						If wProduto == SG1->G1_COD .or. SBZ->BZ_FANTASM == "S"

							dbSelectArea(cAliasEstru)
							If !dbSeek(SG1->G1_COD+SG1->G1_COMP+SG1->G1_TRT)
								RecLock(cAliasEstru,.T.)
								ESTRUT->CODIGO := SG1->G1_COD
								ESTRUT->COMP   := SG1->G1_COMP
								ESTRUT->TRT    := SG1->G1_TRT
								ESTRUT->QUANT  := nQuantItem
							Else
								ESTRUT->QUANT  += nQuantItem
							EndIf
							MsUnlock()
							lAdd:=.T.
						EndIf
					EndIf

				EndIf
				dbSelectArea("SG1")

				// Verifica se existe sub-estrutura
				nRecno:=Recno()
				IF dbSeek(xFilial("SG1")+SG1->G1_COMP)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
					StrutBia(SG1->G1_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow)
					nEstru --
				Endif

			EndIf

		EndIf

		dbGoto(nRegi)
		dbSkip()

	End
	cArqTmp := cArqTrab

Return cArqTrab

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ xBia370E  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Explode Estrutura de Produto para obter a quantidade       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xBia370E(nQuant, dDataStru)

	LOCAL nQuantItem:=0, cUnidMod, nG1Quant:=0, nQBase:=0, nDecimal:=0, nBack:=0
	LOCAL aTamSX3:={}
	LOCAL cAlias:=Alias(), nRecno:=Recno(), nOrder:=IndexOrd()
	LOCAL lOk:=.T.
	LOCAL nDecOrig:=Set(3,8)

	aTamSX3:=TamSX3("G1_QUANT")
	nDecimal:=aTamSX3[2]

	// Verifica a data de validade
	dDataStru := If((dDataStru == NIL), dDataBase, dDataStru)
	If dDataStru >= SG1->G1_INI .And. dDataStru <= SG1->G1_FIM .And. lOk
		cUnidMod := GetMv("MV_UNIDMOD")
		dbSelectArea("SB1")
		dbSeek(xFilial()+SG1->G1_COD)
		nQBase := B1_QB
		dbSeek(xFilial()+SG1->G1_COMP)
		dbSelectArea("SG1")
		nG1Quant := G1_QUANT
		If IsProdMod(G1_COMP)
			cTpHr := GetMv("MV_TPHR")
			If cTpHr == "N"
				nG1Quant := Int(nG1Quant)
				nG1Quant += ((G1_QUANT-nG1Quant)/60)*100
			EndIf
		EndIf
		If G1_FIXVAR $ " V"
			If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
				nQuantItem := ((nQuant / nG1Quant) / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
			EndIf
			nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
		Else
			If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			EndIf
		Endif
		nQuantItem:=Round(nQuantitem,nDecimal)
	EndIf

	Do Case
		Case (SB1->B1_TIPODEC == "A")
		nBack := Round( nQuantItem,0 )
		Case (SB1->B1_TIPODEC == "I")
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
		Case (SB1->B1_TIPODEC == "T")
		nBack := Int( nQuantItem )
		OtherWise
		nBack := nQuantItem
	EndCase

	Set(3,nDecOrig)

Return( nBack )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ fxAtuSD4  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua ajuste do Emprenho (SD4) quando encontra diferenças ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fxAtuSD4()

	Local nt
	Local _nAux	:=	0
	Local _cLocal	:=	""
	Local _lRetLoc	:=	.F.
	Local _cAlias

	For nt := 1 To Len(aDados2)

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Ajustando - Tempo: "+cTempo)

		If aDados2[nt][11] == 0                                    // Se não existe registro no SD4
			***************************************************************************************

			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+aDados2[nt][01]))
			_cAlias	:=	GetNextAlias()
			BeginSql Alias _cAlias
				
				SELECT C2_LINHA
				FROM %TABLE:SC2% SC2
				WHERE C2_FILIAL = %XFILIAL:SC2%
					AND C2_NUM = %Exp:SC2->C2_NUM%
					AND C2_ITEM = %Exp:SC2->C2_ITEM%
					AND C2_SEQUEN = '001'
					AND %NotDel%
				
			EndSql
			
			If !Empty((_cAlias)->C2_LINHA) 
				U_BFG73LIN((_cAlias)->C2_LINHA,aDados2[nt][04],@_cLocal,.F.)
			EndIf
			
			(_cAlias)->(DbCloseArea())
			
			jiQuant := aDados2[nt][09]
			If SC2->C2_QUJE > 0
				jiQuant := SC2->C2_QUJE / SC2->C2_QUANT * aDados2[nt][09]
			EndIf
			_nAux := ConvUm(aDados2[nt][04], jiQuant, 0, 2)
			dbSelectArea("SD4")
			RecLock("SD4",.T.)
			SD4->D4_FILIAL   := xFilial("SD4")
			SD4->D4_COD      := aDados2[nt][04]
			If !Empty(_cLocal)
				SD4->D4_LOCAL    :=	_cLocal
			Else
				SD4->D4_LOCAL    := Posicione("SBZ", 1, xFilial("SBZ")+aDados2[nt][04], "BZ_LOCPAD")
			EndIf
			SD4->D4_OP       := aDados2[nt][01]
			SD4->D4_DATA     := SC2->C2_DATPRF
			SD4->D4_QTDEORI  := aDados2[nt][09]
			SD4->D4_QUANT    := jiQuant
			SD4->D4_QTSEGUM  := _nAux
			SD4->D4_YQTDFLX  := aDados2[nt][09]
			SD4->D4_TRT      := aDados2[nt][12]
			MsUnLock()

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
				_nAux	:=	ConvUm(SB2->B2_COD, SB2->B2_QEMP, 0, 2)
				RecLock("SB2",.F.)
				SB2->B2_QEMP   += jiQuant
				SB2->B2_QEMP2  := _nAux
				MsUnLock()
			EndIf

		Else                                                      // Caso já existe registro no SD4
			***************************************************************************************

			If aDados2[nt][09] == 0                      // Caso não exista quantidade em estrutura
				***********************************************************************************

				dbSelectArea("SD4")
				dbGoTo(aDados2[nt][11])

				dbSelectArea("SB2")
				dbSetOrder(1)
				If dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
					_nAux	:=	ConvUm(SB2->B2_COD, SB2->B2_QEMP, 0, 2)
					RecLock("SB2",.F.)
					SB2->B2_QEMP   -= SD4->D4_QUANT
					SB2->B2_QEMP2  := _nAux
					MsUnLock()
				EndIf

				dbSelectArea("SD4")
				RecLock("SD4",.F.)
				DELETE
				MsUnLock()

			Else               // Caso exista quantidade em estrutura mas seja diferente do empenho
				***********************************************************************************

				kMudQtd := aDados2[nt][10] * (-1)
				dbSelectArea("SD4")
				dbGoTo(aDados2[nt][11])
				RecLock("SD4",.F.)
				SD4->D4_QTDEORI  += kMudQtd
				SD4->D4_YQTDFLX  := SD4->D4_QTDEORI
				MsUnLock()

				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+aDados2[nt][01]))
				jiQuant := SD4->D4_QTDEORI
				If SC2->C2_QUJE > 0
					jiQuant := SC2->C2_QUJE / SC2->C2_QUANT * SD4->D4_QTDEORI
				EndIf

				dbSelectArea("SD4")
				dbGoTo(aDados2[nt][11])
				_nAux	:=	ConvUm(SD4->D4_COD, SD4->D4_QUANT, 0, 2)
				RecLock("SD4",.F.)
				SD4->D4_QUANT    := jiQuant
				SD4->D4_QTSEGUM  := _nAux
				MsUnLock()

				dbSelectArea("SB2")
				dbSetOrder(1)
				If dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
					_nAux	:=	ConvUm(SB2->B2_COD, SB2->B2_QEMP, 0, 2)
					RecLock("SB2",.F.)
					SB2->B2_QEMP   += kMudQtd
					SB2->B2_QEMP2  := _nAux
					MsUnLock()
				EndIf

			EndIf

		EndIf

		//    Necessário para que não ocorram redundâncias. Em 03/01/13. Por Marcos Alberto Soprani
		*******************************************************************************************
		If Round(SD4->D4_QTDEORI,2) == 0
			dbSelectArea("SD4")
			RecLock("SD4",.F.)
			DELETE
			MsUnLock()
		EndIf

	Next nt

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA370R     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 06/01/15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Apaga as Ordens de Produção com revisão vencidas e recria  ¦¦¦
¦¦¦          ¦ com a revisão do produto atualizada                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA370R()

	#IFDEF WINDOWS
	Processa({|| RptR2Dtl()})
Return
Static Function RptR2Dtl()
	#ENDIF
	Local _cAlias
	Local _cLocal	:=	""

	Private lMsErroAuto := .F.

		dbSelectArea("MARK")
		dbGoTop()
	
	BEGIN SEQUENCE

		If !fCriaSem()
			fh_Esc := .T.
			oDlg1:End()
			Return
		EndIf

	
		ProcRegua(RecCount())
		While !Eof()

			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Empenho - Tempo: "+cTempo)

			If MARK->OK == xkMarca

				If Alltrim(MARK->STATREV) ==  "==>> VENCIDA"

					If MARK->QUJE == 0

						SC2->(dbSetOrder(1))
						SC2->(dbSeek(xFilial("SC2") + MARK->NUMOP ))

						If Empty(SC2->C2_YSTAOPR) // .and. SC2->C2_DATPRF >= dDataBase

							Begin Transaction                     // Controle de Transação
								**************************************************************

								fhNumOP   := SC2->C2_NUM
								fhItnOP   := SC2->C2_ITEM
								fhSeqOP   := SC2->C2_SEQUEN
								fhProdut  := SC2->C2_PRODUTO
								nGet1q    := SC2->C2_QUANT
								fhPRInDt  := IIF(SC2->C2_DATPRI < dDataBase, dDataBase, SC2->C2_DATPRI)
								fhPRFiDt  := IIF(SC2->C2_DATPRF < dDataBase, dDataBase, SC2->C2_DATPRF)
								fhDtEmiss := SC2->C2_EMISSAO
								fhObserv  := SC2->C2_OBS
								fhQtRtFc  := SC2->C2_YQTRTFC
								fhOpREF   := "OP ORIGINAL " + MARK->NUMOP
								fhPrior   := SC2->C2_PRIOR
								fhLinha   := MARK->LINHA
								fhDtFrm   := SC2->C2_YDTFIRM
								fhSeqPai  := SC2->C2_SEQPAI
								
								_cAlias	:=	GetNextAlias()
								BeginSql Alias _cAlias
									
									SELECT C2_LINHA
									FROM %TABLE:SC2% SC2
									WHERE C2_FILIAL = %XFILIAL:SC2%
										AND C2_NUM = %Exp:SC2->C2_NUM%
										AND C2_ITEM = %Exp:SC2->C2_ITEM%
										AND C2_SEQUEN = '001'
										AND %NotDel%
									
								EndSql
								
								If !Empty((_cAlias)->C2_LINHA) 
									U_BFG73LIN((_cAlias)->C2_LINHA,fhProdut,@_cLocal,.F.)
								EndIf
								
								(_cAlias)->(DbCloseArea())
								DbSelectArea("SB1")
								SB1->(dbSetOrder(1))
								SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
								aArrayOp  := {{'C2_NUM'      ,SC2->C2_NUM                        ,NIL},;
								{              'C2_ITEM'     ,SC2->C2_ITEM                       ,NIL},;
								{              'C2_SEQUEN'   ,SC2->C2_SEQUEN                     ,NIL},;
								{              'C2_PRODUTO'  ,SC2->C2_PRODUTO                    ,NIL},;
								{              'C2_LOCAL'    ,SC2->C2_LOCAL                      ,NIL},;
								{              'C2_QUANT'    ,SC2->C2_QUANT                      ,NIL},;
								{              'C2_QTSEGUM'  ,SC2->C2_QTSEGUM                    ,NIL},;
								{              'C2_UM'       ,SC2->C2_UM                         ,NIL},;
								{              'C2_CC'       ,SC2->C2_CC                         ,NIL},;
								{              'C2_SEGUM'    ,SC2->C2_SEGUM                      ,NIL},;
								{              'C2_DATPRI'   ,SC2->C2_DATPRI                     ,NIL},;
								{              'C2_REVISAO'  ,SC2->C2_REVISAO                    ,NIL},;
								{              'C2_TPOP'     ,SC2->C2_TPOP                       ,NIL},;
								{              'C2_SEQPAI'   ,SC2->C2_SEQPAI                     ,NIL},;
								{              'C2_ROTEIRO'  ,SC2->C2_ROTEIRO                    ,NIL} }
								MsExecAuto({|x,Y| Mata650(x,Y)},aArrayOp,5)
								If lMsErroAuto
									Mostraerro()
									DisarmTransaction()
									Break
									lMostraErro:= .F.
								Else

									MsUnLockAll()
									Sleep(1000)

									SB1->(dbSetOrder(1))
									SB1->(dbSeek(xFilial("SB1")+fhProdut))
									SBZ->(dbSetOrder(1))
									SBZ->(dbSeek(xFilial("SBZ") + fhProdut))
									
									aMata650  := {{'C2_SEQUEN'   ,fhSeqOP                             ,NIL},;
									{              'C2_ITEM'     ,fhItnOP                             ,NIL},;
									{              'C2_NUM'      ,fhNumOP                             ,NIL},;
									{              'C2_LINHA'    ,fhLinha                             ,NIL},;
									{              'C2_PRODUTO'  ,fhProdut                            ,NIL},;
									{              'C2_QUANT'    ,nGet1q                              ,NIL},;
									{              'C2_QTSEGUM'  ,ConvUm(fhProdut,nGet1q,0,2)         ,NIL},;
									{              'C2_UM'       ,SB1->B1_UM                          ,NIL},;
									{              'C2_CC'       ,SB1->B1_CC                          ,NIL},;
									{              'C2_SEGUM'    ,SB1->B1_SEGUM                       ,NIL},;
									{              'C2_DATPRI'   ,fhPRInDt                            ,NIL},;
									{              'C2_DATPRF'   ,fhPRFiDt                            ,NIL},;
									{              'C2_REVISAO'  ,SB1->B1_REVATU                     ,NIL},;
									{              'C2_TPOP'     ,"F"                                 ,NIL},;
									{              'C2_EMISSAO'  ,fhDtEmiss                           ,NIL},;
									{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                     ,NIL},;
									{              'C2_OPC'      ,""                                  ,NIL},;
									{              'C2_YOPQREF'  ,fhOpREF                             ,NIL},;
									{              'C2_OBS'      ,fhObserv                            ,NIL},;
									{              'C2_YQTRTFC'  ,fhQtRtFc                            ,NIL},;
									{              'C2_PRIOR'    ,fhPrior                             ,NIL},;
									{              'C2_YDTFIRM'  ,fhDtFrm                             ,NIL},;
									{              'C2_SEQPAI'   ,fhSeqPai                            ,NIL},;
									{              'AUTEXPLODE'  ,'S'                                 ,NIL} }
									MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
									If lMsErroAuto
										Mostraerro()
										DisarmTransaction()
										Break
										lMostraErro:= .F.
									EndIf

								EndIf

							End Transaction                       // Controle de Transação
							**************************************************************

						EndIf

					EndIf

				EndIf

			EndIf

			dbSelectArea("MARK")
			dbSkip()

		End

		fh_Esc := .T.
		oDlg1:End()

	
	END SEQUENCE


	ErrorBlock( bErro )



Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	Local i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Tipo do Produto             ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Listar apenas diferenças    ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Atualizar Empenhos          ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","De Produto (da OP)          ?","","","mv_ch4","C",15,0,0,"C","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Ate Produto (da OP)         ?","","","mv_ch5","C",15,0,0,"C","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Quanto a Revisao do Produto ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Em Linha","","","","","Vencidas","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","De OP                       ?","","","mv_ch7","C",06,0,0,"C","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SC2"})
	aAdd(aRegs,{cPerg,"08","Ate  OP                     ?","","","mv_ch8","C",06,0,0,"C","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SC2"})

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

Static Function fCriaSem(_cLocal)

	Local _lRet	:=	.T.
	Local _cSql	:=	""

	Default _cLocal	:=	""

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do CMV', ".F." )
	EndIf

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para CMV está ativado!","BIA370")
		Return .F.
	EndIF	

	
Return _lRet