#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE 'COLORS.CH'

/*/{Protheus.doc} BIA280
@author Marcos Alberto Soprani
@since 10/02/12
@version 1.0
@description Histograma de Produção
@obs Em 10/03/17... Por Marcos Alberto Soprani Ajustada regra para firmar OP de RODAPE
@type function
/*/

User Function BIA280()

	Local _nPosProd

	Private zx_Ambi := ""
	Private oButton1
	Private oButton2
	Private oButton3
	Private oButton4
	Private oDlg271
	Private oGroup1
	Private oGdHisto
	Private aCpFs := {}
	Private zp_Tmp
	Private xwDados7 := {}
	Private fh_Esc   := .F.
	Private cj_Fecha := .T.


	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do CMV', ".F." )
	EndIf

	cHInicio := Time()
	fPerg := "BIA280"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If IsInCallStack("fHistogr")

		_nPosProd	:=	aScan(oNGDd1Ap:aHeader,{|x| Alltrim(x[2]) == 'PROD'})

		MV_PAR01	:=	1
		MV_PAR02	:=	Date() - 365
		MV_PAR03	:=	Stod('20491231')
		MV_PAR04	:=	1
		MV_PAR05	:=	oNGDd1Ap:aCols[oNGDd1Ap:nAt,_nPosProd]
		MV_PAR06	:=	oNGDd1Ap:aCols[oNGDd1Ap:nAt,_nPosProd]
	Else
		If !Pergunte(fPerg,.T.)
			Return
		EndIf
	EndIf
	drFilSta := MV_PAR04

	Aadd( aCpFs , {"LINHA"    ,"C",003,000} )
	Aadd( aCpFs , {"DTFIRME"  ,"D",008,000} )
	Aadd( aCpFs , {"NUMOP"    ,"C",006,000} )
	Aadd( aCpFs , {"ITOP"     ,"C",002,000} )
	Aadd( aCpFs , {"SEQOP"    ,"C",003,000} )
	Aadd( aCpFs , {"PROD"     ,"C",015,000} )
	Aadd( aCpFs , {"DESCRIC"  ,"C",050,000} )
	Aadd( aCpFs , {"PrevIni"  ,"D",008,000} )
	Aadd( aCpFs , {"PrevFin"  ,"D",008,000} )
	Aadd( aCpFs , {"QtdPrev"  ,"N",014,002} )
	Aadd( aCpFs , {"Produzd"  ,"N",014,002} )
	Aadd( aCpFs , {"Diferen"  ,"N",014,002} )
	Aadd( aCpFs , {"IniProd"  ,"D",008,000} )
	Aadd( aCpFs , {"FinProd"  ,"D",008,000} )
	Aadd( aCpFs , {"ImportIn" ,"D",008,000} )
	Aadd( aCpFs , {"ImportFi" ,"D",008,000} )
	Aadd( aCpFs , {"Encerra"  ,"D",008,000} )
	Aadd( aCpFs , {"ObsEnc"   ,"C",250,000} )
	zp_Tmp := CriaTrab( aCpFs, .T. )
	Use (zp_Tmp) Alias HISTO01 New Exclusive

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight
	Processa({||fLisProd()})

	HISTO01->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fLisProd ¦ Autor ¦ Marcos Alberto S.     ¦ Data ¦ 10.02.12 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Faz a Leitura dos Dados da Produção para montagem da tela  ¦¦¦
¦¦¦          ¦do histograma de produção                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fLisProd() 

	//Fernando/Facile em 07/07/2015 - adicionado o SD1 na coluna PRODUCAO para atender a OP's VITCER - OS 2489-15

	If MV_PAR01 == 1

		A0001 := " SELECT C2_LINHA LINHA,
		A0001 += "        C2_YDTFIRM DTFIRME,
		A0001 += "        C2_NUM NUMOP,
		A0001 += "        C2_ITEM ITOP,
		A0001 += "        C2_SEQUEN SEQOP,
		A0001 += "        C2_PRODUTO PRODUTO,
		A0001 += "        SUBSTRING(B1_DESC,1,50) DESCR,
		A0001 += "        C2_DATPRI DATPRI,
		A0001 += "        C2_DATPRF DATPRF,
		A0001 += "        C2_QUANT QUANT,
		A0001 += "        ISNULL((SELECT SUM(D3_QUANT)
		A0001 += "                  FROM " + RetSqlName("SD3")  + " (NOLOCK)
		A0001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                   AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		A0001 += "                   AND D3_COD = C2_PRODUTO
		A0001 += "                   AND D3_TM = '010'
		A0001 += "                   AND D3_ESTORNO = ' '
		A0001 += "                   AND D_E_L_E_T_ = ' '), 0)
		A0001 += "       + ISNULL((SELECT SUM(D1_QUANT)
		A0001 += "       			FROM SD1010  
		A0001 += "       			WHERE D1_FILIAL = '01'               
		A0001 += "       			AND D1_YOP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '           
		A0001 += "       			AND D1_COD = C2_PRODUTO                  
		A0001 += "       			AND D_E_L_E_T_ = ' '), 0) PRODUCAO,
		A0001 += "        0 DIFER,
		A0001 += "        ISNULL((SELECT MIN(D3_EMISSAO)
		A0001 += "                  FROM " + RetSqlName("SD3")  + " (NOLOCK)
		A0001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                   AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		A0001 += "                   AND D3_COD = C2_PRODUTO
		A0001 += "                   AND D3_TM = '010'
		A0001 += "                   AND D3_ESTORNO = ' '
		A0001 += "                   AND D_E_L_E_T_ = ' '), ' ') PRI_PRO,
		A0001 += "        ISNULL((SELECT MAX(D3_EMISSAO)
		A0001 += "                  FROM " + RetSqlName("SD3")  + " (NOLOCK)
		A0001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                   AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		A0001 += "                   AND D3_COD = C2_PRODUTO
		A0001 += "                   AND D3_TM = '010'
		A0001 += "                   AND D3_ESTORNO = ' '
		A0001 += "                   AND D_E_L_E_T_ = ' '), ' ') ULT_PRO,
		A0001 += "        ISNULL((SELECT MIN(D3_YDIMPOR)
		A0001 += "                  FROM " + RetSqlName("SD3") + " (NOLOCK)
		A0001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                   AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		A0001 += "                   AND D3_COD = C2_PRODUTO
		A0001 += "                   AND D3_TM = '010'
		A0001 += "                   AND D3_ESTORNO = ' '
		A0001 += "                   AND D_E_L_E_T_ = ' '), ' ') PRI_IPR,
		A0001 += "        ISNULL((SELECT MAX(D3_YDIMPOR)
		A0001 += "                  FROM " + RetSqlName("SD3") + " (NOLOCK)
		A0001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                   AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+'  '
		A0001 += "                   AND D3_COD = C2_PRODUTO
		A0001 += "                   AND D3_TM = '010'
		A0001 += "                   AND D3_ESTORNO = ' '
		A0001 += "                   AND D_E_L_E_T_ = ' '), ' ') ULT_IPR,
		A0001 += "        C2_DATRF,
		A0001 += "        C2_YOBSFIR
		A0001 += "   FROM "+RetSqlName("SC2")+" SC2 (NOLOCK)
		A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1  (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND B1_COD = C2_PRODUTO
		A0001 += "                       AND B1_TIPO = 'PA'
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		A0001 += "    AND C2_PRODUTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		A0001 += "    AND C2_DATPRI >= '"+dtos(MV_PAR02)+"'
		A0001 += "    AND C2_DATPRF <= '"+dtos(MV_PAR03)+"'
		If MV_PAR04 == 1
			A0001 += "    AND C2_DATRF = '        '
		ElseIf MV_PAR04 == 2
			A0001 += "    AND C2_DATRF <> '        '
		EndIf
		A0001 += "    AND C2_ITEM = '01'
		A0001 += "    AND C2_SEQUEN = '001'
		A0001 += "    AND SC2.D_E_L_E_T_ = ' '
		A0001 += "  ORDER BY C2_LINHA, C2_DATPRI
		TcQuery A0001 ALIAS "A001" NEW
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Montando dados!!!")

			dbSelectArea("HISTO01")
			RecLock("HISTO01",.T.)
			HISTO01->LINHA    := A001->LINHA
			HISTO01->DTFIRME  := stod(A001->DTFIRME)
			HISTO01->NUMOP    := A001->NUMOP
			HISTO01->ITOP     := A001->ITOP
			HISTO01->SEQOP    := A001->SEQOP
			HISTO01->PROD     := A001->PRODUTO
			HISTO01->DESCRIC  := A001->DESCR
			HISTO01->PREVINI  := stod(A001->DATPRI)
			HISTO01->PREVFIN  := stod(A001->DATPRF)
			HISTO01->QTDPREV  := A001->QUANT
			HISTO01->PRODUZD  := A001->PRODUCAO
			HISTO01->DIFEREN  := A001->PRODUCAO - A001->QUANT
			HISTO01->INIPROD  := stod(A001->PRI_PRO)
			HISTO01->FINPROD  := stod(A001->ULT_PRO)
			HISTO01->IMPORTIN := stod(A001->PRI_IPR)
			HISTO01->IMPORTFI := stod(A001->ULT_IPR)
			HISTO01->ENCERRA  := stod(A001->C2_DATRF)
			HISTO01->OBSENC   := A001->C2_YOBSFIR
			MsUnLock()

			dbSelectArea("A001")
			dbSkip()
		End
		A001->(dbCloseArea())

	Else

		MsgINFO("Opção ainda não disponível!!!")

	EndIf

	DEFINE MSDIALOG oDlg271 TITLE "Histograma de Produção" FROM nLin*.000, nCol*.000  TO nLin*.850, nCol*.900 COLORS 0, 16777215 PIXEL
	@ nLin*.004, nCol*.005 GROUP oGroup1 TO nLin*.395, nCol*.447 OF oDlg271 COLOR 0, 16777215 PIXEL
	fNGDd1Ap()
	@ nLin*.400, nCol*.240 BUTTON oButton4 PROMPT "FirmarOP" SIZE nLin*.040, nCol*.010 OF oDlg271 ACTION Processa({|| gxFirmOp() }) PIXEL
	@ nLin*.400, nCol*.282 BUTTON oButton4 PROMPT "Encerrar" SIZE nLin*.040, nCol*.010 OF oDlg271 ACTION Processa({|| gxEncOp() }) PIXEL
	@ nLin*.400, nCol*.324 BUTTON oButton3 PROMPT "Excel"    SIZE nLin*.040, nCol*.010 OF oDlg271 ACTION Processa({|| gxGrExcl() }) PIXEL
	@ nLin*.400, nCol*.366 BUTTON oButton2 PROMPT "Datalhar" SIZE nLin*.040, nCol*.010 OF oDlg271 ACTION Processa({|| gxDerDad() }) PIXEL
	@ nLin*.400, nCol*.408 BUTTON oButton1 PROMPT "Fechar"   SIZE nLin*.040, nCol*.010 OF oDlg271 ACTION (cj_Fecha := .F., fh_Esc := .T., oDlg271:End()) PIXEL

	ACTIVATE MSDIALOG oDlg271 CENTERED VALID fh_Esc

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fNGDd1Ap ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 18.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fNGDd1Ap()

	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFields      := {"LINHA", "DTFIRME", "NUMOP", "ITOP", "SEQOP", "PROD", "DESCRIC", "PrevIni", "PrevFin", "QtdPrev", "Produzd", "Diferen", "IniProd", "FinProd", "ImportIn", "ImportFi", "Encerra", "ObsEnc"}
	Local aAlterFields := {"ObsEnc"}

	// Define field properties
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("C2_LINHA")
	aAdd(aHeaderEx,{"Linha"          ,"LINHA"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"DtFirme"        ,"DTFIRME"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_NUM")
	aAdd(aHeaderEx,{"NumOP"          ,"NUMOP"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("C2_ITEM")
	aAdd(aHeaderEx,{"ItOP"           ,"ITOP"     ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("C2_SEQUEN")
	aAdd(aHeaderEx,{"SeqOP"          ,"SEQOP"    ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("D3_COD")
	aAdd(aHeaderEx,{"Produto"        ,"PROD"     ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,x3_f3    ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeaderEx,{"Descrição"      ,"DESCRIC"  ,x3_picture         ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"PrevIni"        ,"PrevIni"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"PrevFin"        ,"PrevFin"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_QUANT")
	aAdd(aHeaderEx,{"QtdPrev"        ,"QtdPrev"  ,x3_picture         ,x3_tamanho,2         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_QUANT")
	aAdd(aHeaderEx,{"Produzd"        ,"Produzd"  ,x3_picture         ,x3_tamanho,2         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_QUANT")
	aAdd(aHeaderEx,{"Diferen"        ,"Diferen"  ,x3_picture         ,x3_tamanho,2         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"IniProd"        ,"IniProd"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"FinProd"        ,"FinProd"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_YDIMPOR")
	aAdd(aHeaderEx,{"IniImpor"       ,"ImportIn" ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_YDIMPOR")
	aAdd(aHeaderEx,{"FinImpor"       ,"ImportFi" ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("D3_EMISSAO")
	aAdd(aHeaderEx,{"Encerra"        ,"Encerra"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_YOBSFIR")
	aAdd(aHeaderEx,{"Obs Enc"        ,"ObsEnc"   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})

	// Define field values
	dbSelectArea("HISTO01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Montando Grid de Dados!!!")

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := HISTO01->LINHA
		aColsEx[Len(aColsEx), 2] := HISTO01->DTFIRME
		aColsEx[Len(aColsEx), 3] := HISTO01->NUMOP
		aColsEx[Len(aColsEx), 4] := HISTO01->ITOP
		aColsEx[Len(aColsEx), 5] := HISTO01->SEQOP
		aColsEx[Len(aColsEx), 6] := HISTO01->PROD
		aColsEx[Len(aColsEx), 7] := HISTO01->DESCRIC
		aColsEx[Len(aColsEx), 8] := HISTO01->PREVINI
		aColsEx[Len(aColsEx), 9] := HISTO01->PREVFIN
		aColsEx[Len(aColsEx),10] := HISTO01->QTDPREV
		aColsEx[Len(aColsEx),11] := HISTO01->PRODUZD
		aColsEx[Len(aColsEx),12] := HISTO01->DIFEREN
		aColsEx[Len(aColsEx),13] := HISTO01->INIPROD
		aColsEx[Len(aColsEx),14] := HISTO01->FINPROD
		aColsEx[Len(aColsEx),15] := HISTO01->IMPORTIN
		aColsEx[Len(aColsEx),16] := HISTO01->IMPORTFI
		aColsEx[Len(aColsEx),17] := HISTO01->ENCERRA
		aColsEx[Len(aColsEx),18] := HISTO01->OBSENC
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.

		dbSelectArea("HISTO01")
		dbSkip()
	End

	oGdHisto := MsNewGetDados():New( nLin*.013, nCol*.010, nLin*.390, nCol*.441, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg271, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxGrExcl ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 24.11.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Exporta os dados do Grid para o Excel                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxGrExcl()

	xwDados7 := {}

	dbSelectArea("HISTO01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Preparando dados para Excel!!!")

		Aadd(xwDados7, { HISTO01->LINHA  ,;
		HISTO01->DTFIRME,;
		HISTO01->NUMOP  ,;
		HISTO01->ITOP   ,;
		HISTO01->SEQOP  ,;
		HISTO01->PROD   ,;
		HISTO01->DESCRIC,;
		HISTO01->PREVINI,;
		HISTO01->PREVFIN,;
		Transform(HISTO01->QTDPREV,     "@E 999,999,999.99"),;
		Transform(HISTO01->PRODUZD,     "@E 999,999,999.99"),;
		Transform(HISTO01->DIFEREN,     "@E 999,999,999.99"),;
		HISTO01->INIPROD,;
		HISTO01->FINPROD,;
		HISTO01->IMPORTIN,;
		HISTO01->IMPORTFI,;
		HISTO01->ENCERRA,;
		HISTO01->OBSENC} )

		dbSelectArea("HISTO01")
		dbSkip()

	End

	U_BIAxExcel(xwDados7, aCpFs, fPerg+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxDerDad ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 10.02.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gera detalhes para cada linha selecionada                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxDerDad()

	MsgINFO("Em desenvolvimento!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxFirmOp ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27.12.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Tela para Confirmar o Empenho e Tornar firme a OP          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxFirmOp()

	Private oDlgFirme
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private xdConfirma

	Private sNumOpr := oGdHisto:ACOLS[oGdHisto:NAT][3]
	Private sCodPro := oGdHisto:ACOLS[oGdHisto:NAT][6]
	Private sDescPr := oGdHisto:ACOLS[oGdHisto:NAT][7]
	Private sDtFirm := oGdHisto:ACOLS[oGdHisto:NAT][2]

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para CMV está ativado!","BIA280")
		Return
	EndIF

	// Caso ainda não esteja firmada
	If Empty(sDtFirm)

		// Caso lista de OPs no grid sejam apenas de OPs Abertas
		If drFilSta == 1

			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+sNumOpr+"01"+"001"))
			fyQtdOp := SC2->C2_QUANT
			fyRevOp := SC2->C2_REVISAO

			DEFINE MSDIALOG oDlgFirme TITLE "Lista de Empenho" FROM 000, 000  TO 500, 1100 COLORS 0, 16777215 PIXEL

			@ 014, 009 SAY oSay1 PROMPT "OP:" SIZE 012, 007 OF oDlgFirme COLORS 0, 16777215 PIXEL
			@ 014, 026 SAY oSay2 PROMPT sNumOpr SIZE 025, 007 OF oDlgFirme COLORS 0, 16777215 PIXEL
			@ 014, 069 SAY oSay3 PROMPT "Produto:" SIZE 022, 007 OF oDlgFirme COLORS 0, 16777215 PIXEL
			@ 014, 095 SAY oSay4 PROMPT Alltrim(sCodPro) +" - "+ Alltrim(sDescPr) + Space(15) + "Rev.OP: " + fyRevOp + Space(35) + "Quant:" + Transform(fyQtdOp, "@E 999,999,999.99") SIZE 365, 007 OF oDlgFirme COLORS 0, 16777215 PIXEL
			fMSNGFirme()
			@ 228, 503 BUTTON xdConfirma PROMPT "Firmar" SIZE 037, 012 OF oDlgFirme ACTION (Processa({|| grvOpFirm() }), oDlgFirme:End())   PIXEL

			ACTIVATE MSDIALOG oDlgFirme

		Else

			Aviso('Firmar OP','Esta opção somente irá funcionar se o parâmetro de filtro estiver filtrando OPs Abertas!',{'Ok'})

		EndIf

	Else

		Aviso('Firmar OP','OP já foi firmada! Favor verificar',{'Ok'})

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fMSNGFirme ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 27.12.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Montagem de Grid - Firmar OP                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMSNGFirme()

	Local nX
	Local aHeaExpr := {}
	Local aColExpr := {}
	Local aFielFpr := {}
	Local aFields := {"D4_OP","D4_COD","B1_DESC","B1_UM","D4_TRT","D4_QUANT","D4_QTDEORI"}
	Local aAlterFields := {}
	Static oMSNGFirme

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			If Alltrim(aFields[nX]) == "B1_DESC"
				Aadd(aHeaExpr, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,50,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			ElseIf Alltrim(aFields[nX]) = "D4_QUANT"
				Aadd(aHeaExpr, {AllTrim("Emp.Unit"),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Else
				Aadd(aHeaExpr, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			EndIf
		Endif
	Next nX

	YR007 := " SELECT D4_OP,
	YR007 += "        D4_COD,
	YR007 += "        B1_DESC,
	YR007 += "        B1_UM,
	YR007 += "        D4_TRT,
	YR007 += "        D4_QTDEORI
	YR007 += "   FROM "+RetSqlName("SD4")+" SD4  (NOLOCK)
	YR007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1  (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	YR007 += "                       AND B1_COD = D4_COD
	YR007 += "                       AND SB1.D_E_L_E_T_ = ' '
	YR007 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	YR007 += "    AND D4_OP IN(SELECT C2_NUM+C2_ITEM+C2_SEQUEN
	YR007 += "                   FROM "+RetSqlName("SC2")+" SC2  (NOLOCK)
	YR007 += "                  INNER JOIN "+RetSqlName("SB1")+" SB1  (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	YR007 += "                                       AND B1_COD = C2_PRODUTO
	YR007 += "                                       AND B1_TIPO IN('PA','PP','PS')
	YR007 += "                                       AND SB1.D_E_L_E_T_ = ' '
	YR007 += "                  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	YR007 += "                    AND C2_NUM = '"+sNumOpr+"'
	YR007 += "                    AND SC2.D_E_L_E_T_ = ' ')
	YR007 += "    AND SD4.D_E_L_E_T_ = ' '
	YRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YR007),'YR07',.T.,.T.)

	// Define field values
	dbSelectArea("YR07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Montando Grid de Dados!!!")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + YR07->D4_COD ))
		s_B1TpIn := SB1->B1_TIPO
		s_B1GrIn := SB1->B1_GRUPO

		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+YR07->D4_OP))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
		s_B1TpPr := SB1->B1_TIPO

		If s_B1TpPr $ "PA/PS/PP"

			If !(( s_B1TpIn == "MP" .and. s_B1GrIn $ "101 " ) )

				AADD(aColExpr, Array(Len(aFields)+1) )
				aColExpr[Len(aColExpr), 1] := YR07->D4_OP
				aColExpr[Len(aColExpr), 2] := YR07->D4_COD
				aColExpr[Len(aColExpr), 3] := YR07->B1_DESC
				aColExpr[Len(aColExpr), 4] := YR07->B1_UM
				aColExpr[Len(aColExpr), 5] := YR07->D4_TRT
				aColExpr[Len(aColExpr), 6] := YR07->D4_QTDEORI/fyQtdOp
				aColExpr[Len(aColExpr), 7] := YR07->D4_QTDEORI
				aColExpr[Len(aColExpr), Len(aFields)+1] := .F.

			EndIf

		EndIf

		dbSelectArea("YR07")
		dbSkip()

	End

	YR07->(dbCloseArea())
	Ferase(YRIndex+GetDBExtension())
	Ferase(YRIndex+OrdBagExt())

	If Empty(aColExpr)
		For nX := 1 to Len(aFields)
			dbSelectArea("SX3")
			dbSetOrder(2)
			If DbSeek(aFields[nX])
				Aadd(aFielFpr, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFielFpr, .F.)
		Aadd(aColExpr, aFielFpr)
	EndIf

	oMSNGFirme := MsNewGetDados():New( 028, 009, 220, 540, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgFirme, aHeaExpr, aColExpr)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ grvOpFirm  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 27.12.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Confirma gravação dos dados da OP - Firmar OP              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function grvOpFirm()

	Local ih
	Private lMsErroAuto := .F.

	If MsgNOYES("Os itens de empenho estão corretos? Pode prosseguir com a confirmação da OP?")

		nContaOpFr := 0
		xrFirOpMae := 0
		WR005 := " SELECT COUNT(*) CONTAD
		WR005 += "   FROM " + RetSqlName("SC2") + " (NOLOCK)
		WR005 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
		WR005 += "    AND C2_PRODUTO = '"+sCodPro+"'
		WR005 += "    AND C2_DATRF = '        '
		WR005 += "    AND C2_YDTFIRM <> '        '
		WR005 += "    AND D_E_L_E_T_ = ' '
		WRIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,WR005),'WR05',.T.,.T.)
		dbSelectArea("WR05")
		dbGoTop()
		nContaOpFr := WR05->CONTAD
		WR05->(dbCloseArea())
		Ferase(WRIndex+GetDBExtension())
		Ferase(WRIndex+OrdBagExt())

		If nContaOpFr > 1

			Aviso('OPs Firmes','Existem OPs Firmes em aberto para este Produto. Favor verificar e encerrar estas OPs antes de Firmar a nova!',{'Ok'})

		ElseIf nContaOpFr == 0 .or. ( nContaOpFr == 1 .And. MsgYesno(fMsgFirme()) )

			// Grava OP's das classes B e D devivadas da OP MAE
			For ih := 1 to 2

				ftClsPr  := ih+1
				ftProdt  := Substr(sCodPro,1,7) + Alltrim(Str(ftClsPr))
				ftPercB  := 40 // Percentual sobre a quantidade da OP MAE - Produto classe A
				ftPercD  := 25  // Percentual sobre a quantidade da OP MAE - Produto classe B
				ftQtdeOp := IIf(ftClsPr == 2, fyQtdOp * ftPercB, fyQtdOp * ftPercD) / 100

				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+sNumOpr+"01"+"001"))

				SG1->(dbSetOrder(1))
				If SG1->(dbSeek(xFilial("SG1")+ftProdt))

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+ftProdt))

						If SB1->B1_YESTROK = "S"

							aMata650  := {{'C2_ITEM'     ,StrZero(ftClsPr,2)                                            ,NIL},;
							{              'C2_SEQUEN'   ,"001"                                                         ,NIL},;
							{              'C2_LINHA'    ,SC2->C2_LINHA                                                         ,NIL},;
							{              'C2_PRODUTO'  ,ftProdt                                                       ,NIL},;
							{              'C2_QUANT'    ,ftQtdeOp                                                      ,NIL},;
							{              'C2_QTSEGUM'  ,ConvUm(ftProdt,ftQtdeOp,0,2)                                  ,NIL},;
							{              'C2_UM'       ,SB1->B1_UM                                                    ,NIL},;
							{              'C2_CC'       ,SB1->B1_CC                                                    ,NIL},;
							{              'C2_SEGUM'    ,SB1->B1_SEGUM                                                 ,NIL},;
							{              'C2_DATPRI'   ,IIF(SC2->C2_DATPRI < dDataBase, dDataBase, SC2->C2_DATPRI)    ,NIL},;
							{              'C2_DATPRF'   ,IIF(SC2->C2_DATPRF < dDataBase, dDataBase, SC2->C2_DATPRF)    ,NIL},;
							{              'C2_REVISAO'  ,SB1->B1_REVATU                                               ,NIL},;
							{              'C2_TPOP'     ,"F"                                                           ,NIL},;
							{              'C2_EMISSAO'  ,dDataBase                                                     ,NIL},;
							{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                                               ,NIL},;
							{              'C2_OPC'      ,""                                                            ,NIL},;
							{              'C2_NUM'      ,sNumOpr                                                       ,NIL},;
							{              'AUTEXPLODE'  ,'S'                                                           ,NIL} }
							MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
							If lMsErroAuto
								Mostraerro()
							Else
								xrFirOpMae ++
							EndIf

						EndIf

					EndIf

				EndIf

			Next ih

			// Atualiza os campos das OPs derivadas com base na OP MAE
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+sCodPro))			
			If xrFirOpMae > 0 .or. SB1->B1_YTPPROD == "RP" .or. Substr(sCodPro,1,7) $ "A81364W,A81365E,AT0366B,AT0367B,BB0367E,BB0367B,A63368R,A63369E,A63369S,A63370E,AU0434F,AU0434L,AU0367E,AU0366B"

				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+sNumOpr+"01"+"001"))

				RU006 := " UPDATE " + RetSqlName("SC2")
				RU006 += "    SET C2_LINHA = '"+SC2->C2_LINHA+"',
				RU006 += "        C2_YDTFIRM = '"+dtos(dDataBase)+"',
				RU006 += "        C2_CC = '"+SC2->C2_CC+"',
				RU006 += "        C2_CLVL = '"+SC2->C2_CLVL+"'
				RU006 += "   FROM " + RetSqlName("SC2")
				RU006 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
				RU006 += "    AND C2_NUM = '"+sNumOpr+"'
				RU006 += "    AND C2_SEQUEN IN('001','002')
				RU006 += "    AND C2_DATRF = '        '
				RU006 += "    AND C2_YDTFIRM = '        '
				RU006 += "    AND D_E_L_E_T_ = ' '
				TCSQLExec(RU006)

				oGdHisto:ACOLS[oGdHisto:NAT][2] := dDataBase
				dbSelectArea("HISTO01")
				dbGoTo(oGdHisto:NAT)
				RecLock("HISTO01",.F.)
				HISTO01->DTFIRME := dDataBase
				MsUnLock()

			Else

				Aviso('Firmar OP','O sistema não encontrou o cadastro dos Produtos Classe B e D devidamente cadastrados no sistema. Favor verificar!',{'Ok'})

			EndIf

			oGdHisto:oBrowse:Refresh()
			oGdHisto:oBrowse:SetFocus()

		Else

			Aviso('OPs Firmes', 'Duas ou mais ordens firmadas', {'Ok'} )

		EndIf

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gxEncOp  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 20.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Encerra ordem de Produção                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gxEncOp()

	Local    msAreaAtu := GetArea()
	Local df_Dest := U_EmailWF('BIA280', cEmpAnt)
	Local df_Assu := ""
	Local df_Erro := ""
	Local _cMsg
	
	wt_NumOp := oGdHisto:ACOLS[oGdHisto:NAT][3]
	wt_ItnOp := oGdHisto:ACOLS[oGdHisto:NAT][4]
	wt_SeqOp := oGdHisto:ACOLS[oGdHisto:NAT][5]

	wt_Contin := .T.
	If Empty(oGdHisto:ACOLS[oGdHisto:NAT][18])

		wt_Contin := MsgYesNo("Nenhuma observação foi digitada. Deseja confirmar o encerramento?",'ATENCAO')

	EndIf

	If wt_Contin .and. Empty(oGdHisto:ACOLS[oGdHisto:NAT][17])

		// Tratamento implementado em 05/01/15 para atendimento do projeto - Pedido de Vendas amarrado a OP
		VR007 := " SELECT SUM(PZ0_QUANT) QUANT
		VR007 += "   FROM " + RetSqlName("PZ0") + " (NOLOCK)
		VR007 += "  WHERE PZ0_FILIAL = '"+xFilial("PZ0")+"'
		VR007 += "    AND PZ0_OPNUM = '"+wt_NumOp+"'
		VR007 += "    AND D_E_L_E_T_ = ' '
		VRIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,VR007),'VR07',.T.,.T.)
		dbSelectArea("VR07")
		dbGoTop()
		nQtdResOp := VR07->QUANT
		VR07->(dbCloseArea())
		Ferase(VRIndex+GetDBExtension())
		Ferase(VRIndex+OrdBagExt())

		If nQtdResOp == 0

			If U_BIABxEmp(wt_NumOp, "PA")

				oGdHisto:ACOLS[oGdHisto:NAT][17] := dDataBase

				dbSelectArea("HISTO01")
				dbGoTo(oGdHisto:NAT)
				RecLock("HISTO01",.F.)
				HISTO01->ENCERRA := dDataBase
				MsUnLock()

				// Tratamento implementado em 30/01/15 em atendimento a OS effettivo - 0135-15
				dbSelectArea("SC2")
				dbSetOrder(1)
				If dbSeek(xFilial("SC2") + wt_NumOp + wt_ItnOp + wt_SeqOp)
					RecLock("SC2",.F.)
					SC2->C2_YOBSFIR := oGdHisto:ACOLS[oGdHisto:NAT][18]
					MsUnLock()
				
					If SC2->C2_SEQUEN == '001' .And. SC2->C2_YITGMES == 'S'
							
						df_Assu := "Encerramento de OP - " + SC2->C2_NUM 
						df_Erro := df_Assu + " não enviado. Favor verificar!!!"	
							
						_cMsg	:=	"A OP de número " + SC2->C2_NUM + " foi encerrada e estava integrada com o TOTVS MES" 
											
						U_BIAEnvMail(, df_Dest, df_Assu, _cMsg, df_Erro)	
					
					EndIf
				
				EndIf

			EndIf

		Else

			Aviso('Encerramento', 'Não será possível encerrar a OP ' + wt_NumOp + ' porque ela possui reserva associada a Pedidos de Venda. Favor verificar!!!',{'Ok'})

		EndIf

	EndIf

	oGdHisto:oBrowse:Refresh()
	oGdHisto:oBrowse:SetFocus()

	RestArea(msAreaAtu)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ordem de geração       ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Por OP","","","","","Por Data","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Do Período             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Até Período            ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Quanto ao Status da OP ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Abertas","","","","","Encerradas","","","","","Ambas","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","De Produto             ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Ate Produto            ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
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

Static Function fMsgFirme()

	Local _cMsg	:=	""

	WR005 := " SELECT *
	WR005 += "   FROM " + RetSqlName("SC2") + " (NOLOCK)
	WR005 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	WR005 += "    AND C2_PRODUTO = '"+sCodPro+"'
	WR005 += "    AND C2_DATRF = '        '
	WR005 += "    AND C2_YDTFIRM <> '        '
	WR005 += "    AND D_E_L_E_T_ = ' '
	WRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,WR005),'WR05',.T.,.T.)
	dbSelectArea("WR05")
	WR05->(dbGoTop())
	If WR05->(!EOF())
		_cMsg	:=	"Já Existe uma OP de Número " + WR05->C2_NUM + " firme para o produto " + sCodPro + " com saldo de " + Alltrim(Str(WR05->C2_QUANT - WR05->C2_QUJE)) + " Deseja Prosseguir?" 
	EndIf
	WR05->(dbCloseArea())
	Ferase(WRIndex+GetDBExtension())
	Ferase(WRIndex+OrdBagExt())

Return _cMsg
