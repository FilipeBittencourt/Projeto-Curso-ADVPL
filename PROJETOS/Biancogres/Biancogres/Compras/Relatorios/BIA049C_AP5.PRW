#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.ch"
#INCLUDE "PROTHEUS.CH"

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function BIA049C()

	SetPrvt("LEND,LABORTPRINT,TAMANHO,LIMITE,TITULO,CDESC1")
	SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,NOMEPROG,NLASTKEY")
	SetPrvt("LI,CPAG,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1")
	SetPrvt("CSAVCOR1,CBTXT,CBCONT,CABEC1,CABEC2,CSTRING")
	SetPrvt("M_PAG,AORD,WNREL,_ACAMPOS,TMP,CCHAVE")
	SetPrvt("CTIPO,CTRANSP,CPRODUTO,DCHEGADA,CCTE,CNUMSEQ")
	SetPrvt("DDTDIGIT,NPRCTF,WDOC,ADOC,AFOR,DVENCTO,WSERIE")
	SetPrvt("NTOTNF,NTICKET,CFORNEC,NPRCUMP,NPRCTMP")
	SetPrvt("APRCTF,NPRCUFRET,NPESONF,CDOC,CPREFIXO")
	SetPrvt("NUMID_F,NTOTUMID_T,NTOTGUMID,NTOTDIF_F,NTOTDIF_T")
	SetPrvt("NTOTGDIF,NTOTMP_F,NTOTMP_T,NTOTGMP,NTFF,NTFT")
	SetPrvt("NTGF,NTOTNF_F,NTOTNF_T,NTOTGNF,NTOTFTICKET,NTOTTTICKET")
	SetPrvt("NTOTGTICKET,NTOTPTMP_F,NTOTPTMP_T,NTOTGPTMP,NTOTPTF_F,NTOTPTF_T")
	SetPrvt("NTOTGTF,ATRANSP,AFORNEC")
	SetPrvt("LOK,ADIF,AMP,AFRT,XDOC,XDOCCTE,CREGRA")
	
	Private nPesEnt := 0
	Private nPesSai := 0
	Private cPlaca := ""
	Private nTotFPesEnt := 0
	Private nTotFPesSai := 0
	Private nTotTPesEnt := 0
	Private nTotTPesSai := 0
	Private nTotGPesEnt := 0
	Private nTotGPesSai := 0
	
	// Posicao das colunas 
	Private nPColDoc := 000
	Private nPColPrf := 10
	Private nPColPrd := 14
	Private nPColDtCh := 36
	Private nPColDtVe := 46
	Private nPColCte := 56
	Private nPColPesNf := 67
	Private nPColPesEnt := 79
	Private nPColPesSai := 91
	Private nPColTicket := 103
	Private nPColDif := 115
	Private nPColPrUMp := 128
	Private nPColPrUFr := 140
	Private nPColPrTMp := 151
	Private nPColPrTFr := 164
	Private nPColPrCMp := 177
	Private nPColPrCFr := 190
	Private nPColPlaca := 203
		
	/*/
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
	╠╠ЁFun┤└o	 Ё BIA049	  Ё Autor Ё BIANCOGRES            Ё Data Ё 13/10/08 Ё╠╠
	╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
	╠╠ЁDescri┤└o Ё RELATORIO DE CONTROLE DE CHEGADA DE MATERIA-PRIMA	        Ё╠╠
	╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Uso		 Ё Interpretador xBase											Ё╠╠
	╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
	/*/

	lEnd		:= lAbortPrint := .F.
	tamanho	:= "G"
	limite	:= 220
	titulo	:= "Planilha de Controle Materia-Prima"
	cDesc1	:= "Emite o controle de chegada de materia-prima.                           "
	cDesc2	:= "                                                                        "
	cDesc3	:= "                                                                        "
	aReturn	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha	:= { }
	nomeprog := "BIA049C"
	nLastKey := 0
	li 		:= 1
	Cpag		:= 0

	// Em 04/09/17... Por Marcos Alberto Soprani
	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Planilha de Controle Materia-Prima"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TRANSPORTADORA"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNECEDOR"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOTA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRF"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHEGADA"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VENCTO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTE"                ,1,1)	
	oExcel:AddColumn(nxPlan, nxTabl, "PESO NOTA"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PESO ENTRADA"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PESO SAIDA"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TICKET"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DIFERENCA"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "UNIT MP"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "UNIT FRETE"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TOT MP"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TOT FRETE"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COMPL MP"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COMPL FRETE"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PLACA", 3, 2)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Vari═veis utilizadas para Impress└o do Cabe┤alho e Rodap┌	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cbtxt 	:= SPACE(10)
	cbcont	:= 0
	cabec1 := "Nota      Prf Produto               Chegada   Vencto    CTE      |-------------------RelaГЦo de Pesos (Ton)-------------------|---PreГos UnitАrios---|------PreГos Totais------|--------Nf Comp R$-------| Placa"
	cabec2 := "                                                                 |       Nota     Entrada       Saida      Ticket   Diferenca |       MP       Frete |         MP        Frete |         MP        Frete |" 	
	cString	:= "SD1"
	li 		:= 80
	m_pag 	:= 1
	aOrd		:= {" Por Transportadora+Fornecedor+Produto"}
	wnrel 	:= "BIA049C"   // nome default do relatorio em disco

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ajuste dos par┐metros da impress└o via fun┤└o SETPRINT		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wnrel:=SetPrint(cString,wnrel,"BIA049C",@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,"G")

	If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
		Return
	End

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Aceita par┐metros e faz ajustes necess═rios 				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetDefault(aReturn,cString)

	If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
		Return
	End

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao do arquivo de trabalho para totalizar por conta contabil	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_aCampos := {	 {"TRANSP" ,  "C", 06, 0},;
	{"FORNEC" ,  "C", 06, 0},;
	{"PRODUTO",  "C", 15, 0},;
	{"CHEGADA",  "D", 08, 0},;
	{"DOC"    ,  "C", 09, 0},;
	{"PREFIXO",  "C", 03, 0},;
	{"CTE"   ,  "C", 09, 0},;
	{"UMIDADE",  "N", 06, 2},;
	{"VENCTO" ,  "D", 08, 0},;
	{"PRCTMP" ,  "N", 14, 2},;
	{"PRCTF"  ,  "N", 14, 2},;
	{"PESONF" ,  "N", 10, 2},;
	{"TICKET" ,  "N", 10, 2},;
	{"PRCUMP"  , "N", 08, 2},;
	{"PRCUFRET", "N", 08, 2},;
	{"PESENT" ,  "N", 10, 2},;
	{"PESSAI" ,  "N", 10, 2},;
	{"PLACA" ,  "C", 08, 0}}

	cArqTrab := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,,cArqTrab,"TMP")
	DbCreateInd(cArqTrab,"TRANSP+FORNEC+PRODUTO",{||TRANSP+FORNEC+PRODUTO})

	Pergunte("BIA049C",.F.)

	RptStatus({|| RptDetail() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	 RptStatus({|| Execute(RptDetail) })

	fFinaliza()

Return( Nil )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION RptDetail
Static FUNCTION RptDetail()

	Local cSQL := ""
	Local cQry := GetNextAlias()              

	SetRegua( SF8 -> (RecCount()) )

	cSQL := " SELECT SF8.R_E_C_N_O_ AS RECNO_SF8, SD1.R_E_C_N_O_ AS RECNO_SD1 "
	cSQL += " FROM " + RetSQLName("SF8") + " SF8 " 
	cSQL += " INNER JOIN " + RetSQLName("SD1") + " SD1 "
	cSQL += " ON F8_FILIAL = D1_FILIAL
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 "
	cSQL += " ON D1_COD = B1_COD "
	cSQL += " AND F8_NFDIFRE = D1_DOC "
	cSQL += " AND F8_SEDIFRE = D1_SERIE "
	cSQL += " AND F8_TRANSP = D1_FORNECE "
	cSQL += " AND F8_LOJTRAN = D1_LOJA "
	cSQL += " WHERE F8_FILIAL = " + ValToSQL(xFilial("SF8"))
	cSQL += " AND F8_TRANSP BETWEEN " + ValToSQL(MV_PAR01) + " AND " + ValToSQL(MV_PAR02) 
	cSQL += " AND F8_DTDIGIT BETWEEN " + ValToSQL(MV_PAR05) + " AND " + ValToSQL(MV_PAR06)
	cSQL += " AND D1_COD BETWEEN " + ValToSQL(MV_PAR03) + " AND " + ValToSQL(MV_PAR04)
	cSQL += " AND SUBSTRING(D1_COD, 1, 3) = '101' "
	cSQL += " AND B1_TIPO = 'MP' "
	cSQL += " AND SF8.D_E_L_E_T_ = '' " 
	cSQL += " AND SD1.D_E_L_E_T_ = '' "
	cSQL += " AND SB1.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY F8_TRANSP, F8_LOJA, D1_FORNECE, D1_LOJA, F8_DTDIGIT, D1_DOC "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		IncRegua()

		DbSelectArea("SF8")
		SF8->(DbGoTo((cQry)->RECNO_SF8))

		DbSelectArea("SD1")
		SD1->(DbGoTo((cQry)->RECNO_SD1))

		WHILE !SD1->(Eof()) .And. SD1->D1_DOC == SF8->F8_NFDIFRE .And. SD1->D1_SERIE == SF8->F8_SEDIFRE .And. SD1->D1_FORNECE == SF8->F8_TRANSP .And. SD1->D1_LOJA == SF8->F8_LOJTRAN

			nReg := SD1->(Recno())

			cTransp	 := SD1->D1_FORNECE
			cProduto := SD1->D1_COD
			dChegada := SD1->D1_DTDIGIT
			cCTE     := SF8->F8_NFDIFRE
			cNumSeq	 := SD1->D1_NUMSEQ
			dDtDigit := SD1->D1_DTDIGIT
			nPrcTF 	 := SD1->D1_TOTAL - SD1->D1_VALDESC
			wDoc	   := SF8->F8_NFORIG
			wSerie   := SF8->F8_SERORIG
			cRegra   := SD1->D1_YREGRA

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura Registro do Titulo a Pagar para verificar vencto 	   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

			DbSelectArea("SE2")
			DbSetOrder(6)
			DbSeek(xFilial("SE2")+SF8->F8_FORNECE+SF8->F8_LOJA+SF8->F8_SERORIG+SF8->F8_NFORIG,.T.)

			dVencto	 := SE2->E2_VENCREA

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura Valor Total da NF-Entrada							   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectArea("SF1")
			DbSetOrder(1)
			DbSeek(xFilial("SF1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA,.T.)

			nTotNF 	 := SF1->F1_VALMERC
			DbSelectArea("SD1")
			DbSetOrder(1)
			DbSeek(xFilial("SD1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA,.T.)
			do while (SD1->D1_DOC  == SF8->F8_NFORIG)  .AND.;
			(SD1->D1_SERIE     == SF8->F8_SERORIG) .AND.;
			(SD1->D1_FORNECE   == SF8->F8_FORNECE) .AND.;
			(SD1->D1_LOJA      == SF8->F8_LOJA)    .AND.;
			!SD1->(EOF())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Monta Registro da NF-Entrada da Mat.Prima 				         	   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				IF ALLTRIM(cRegra) <> 'CP'
					nTicket	  := SD1->D1_YTICKET
					nPesoNf	  := SD1->D1_QUANT
					nPrcTMp	  := SD1->D1_TOTAL
				ELSE
					nTicket	  := 0
					nPesoNf	  := 0
					nPrcTMp	  := 0
				ENDIF

				nPrcuMp	  := SD1->D1_VUNIT
				nUmidade  := SD1->D1_YUMID
				cFornec	  := SD1->D1_FORNECE
				aPrcTF 	  := ((nPrcTF / nTotNF) * SD1->D1_TOTAL)
				nPrcUFret := (aPrcTF / SD1->D1_QUANT)
				cDoc	  := SD1->D1_DOC
				cPrefixo  := SD1->D1_SERIE

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Grava Registro do Arquivo de Trabalho						   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				RecLock("TMP",.T.)
				TMP->TRANSP	    := cTransp
				TMP->FORNEC   	:= cFornec
				TMP->PRODUTO	  := cProduto
				TMP->CHEGADA	  := dChegada
				TMP->CTE		    := cCTE
				TMP->DOC	    	:= cDoc
				TMP->UMIDADE	  := nUmidade
				TMP->PESONF	    := nPesoNf
				TMP->TICKET	    := nTicket
				TMP->PRCUMP	    := nPrcUMp
				TMP->PRCUFRET   := nPrcUFret
				TMP->PREFIXO	  := cPrefixo
				TMP->PRCTMP	    := nPrcTMp
				TMP->PRCTF 	    := aPrcTF
				TMP->VENCTO   	:= dVencto
				
				// Retorna dados da pesagem
				fPesagem(SD1->D1_YNUMTK, @nPesEnt, @nPesSai, @cPlaca)
				
				TMP->PESENT := nPesEnt / 1000 
				TMP->PESSAI	:= nPesSai / 1000
				TMP->PLACA := cPlaca
				
				MsUnLock()

				DbSelectArea("SD1")
				DbSkip()
				
			enddo

			DbSelectArea("SD1")
			DbSelectArea(1)
			SD1->(DbGoTo(nReg))
			SD1->(DbSkip())

		END

		(cQry)->(DbSkip())

	EndDo

	SetRegua( TMP -> (RecCount()) * 3 )

	nUmid_F		  := 0
	nTotUmid_T	  := 0
	nTotGUmid	  := 0

	nTotDif_F	  := 0
	nTotDif_T	  := 0
	nTotGDif 	  := 0


	nTotMp_F 	  := 0
	nTotMp_T 	  := 0
	nTotGMp		  := 0

	nTFF		  := 0
	nTFT		  := 0
	nTGF		  := 0

	nTotNf_F 	  := 0
	nTotNf_T 	  := 0
	nTotGNf		  := 0

	nTotFPesEnt := 0
	nTotFPesSai := 0
	nTotTPesEnt := 0
	nTotTPesSai := 0
	nTotGPesEnt := 0
	nTotGPesSai := 0	
	
	nTotFTicket := 0
	nTotTTicket := 0
	nTotGTicket := 0

	nTotPTMP_F	  := 0
	nTotPTMP_T	  := 0
	nTotGPTMP	  := 0

	nTotPTF_F	  := 0
	nTotPTF_T	  := 0
	nTotGTF		  := 0

	aTransp		  := SPACE(6)
	aFornec		  := SPACE(6)
	lOk			  := .T.
	aDif		  := 0
	aMp			  := 0
	aFrt		  := 0
	li 			  := 62
	//(26/01/15 - Thiago) -> [OS 0341-15]
	cNFAux		:= ''
	nQtdNF		:= 0

	Private nstict := 0, nsdift := 0, nspctot := 0, nsfortot:=0
	Private lprim := .t.

	DbSelectArea("TMP")
	DbGoTop()	

	If !EOF()
		cNFAux := TMP->DOC
		nQtdNF := 1
	EndIf

	aTransp := TMP->TRANSP
	aFornec := TMP->FORNEC
	xDoc := TMP->DOC
	xDocCTE := TMP->CTE
	aUmidad := TMP->UMIDADE

	// Imprime cabeГalho
	fCabec(aTransp, aFornec, .T.)

	While !TMP->(Eof())

		IncRegua()

		If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
			@ li, 20 PSAY "*** IMPRESSAO ABORTADA PELO USUARIO ***"
			Return
		End

		lImpCab := .F.

		If TMP->FORNEC <> aFornec .Or. TMP->TRANSP <> aTransp 

			fTotFor()			

			lImpCab := .T.

		EndIf

		If TMP->TRANSP <> aTransp

			fTotTra()				

			lImpCab := .T.

		EndIf

		//Sumariza a Qtd de CaminhУes
		If cNFAux != TMP->DOC
			nQtdNF++
			cNFAux := TMP->DOC
		EndIf									

		If lImpCab
			fCabec(TMP->TRANSP, TMP->FORNEC, .T.)
		EndIf

		fDetalhe()

		aTransp := TMP->TRANSP
		aFornec := TMP->FORNEC
		xDoc := TMP->DOC
		xDocCTE := TMP->CTE
		aUmidad := TMP->UMIDADE

		TMP->(DbSkip())

	EndDo()

	fTotFor()

	fTotTra()		

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se houve quebra de pagina 								   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If li >= 60
		cPag++
		li++
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		li++
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime o Total Geral											   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ li,00 Psay Repli("-",limite)
	
	li++
	
	@ li,011 PSay "TOTAL GERAL: "
	@ li,nPColPesNf PSay nTotGNf PICTURE "@E 999,999.99"
	@ li,nPColPesEnt PSay nTotGPesEnt	PICTURE "@E 999,999.99"
	@ li,nPColPesSai PSay nTotGPesSai	PICTURE "@E 999,999.99"
	@ li,nPColTicket PSay nTotGTicket PICTURE "@E 999,999.99"
	@ li,nPColDif PSay nTotGDif PICTURE "@E 999,999.99"
	@ li,nPColPrTMp PSay nTotGPTMP PICTURE "@E 999,999.99"
	@ li,nPColPrTFr PSay nTotGTF PICTURE "@E 999,999.99"
	@ li,nPColPrCMp PSay nTotGMp PICTURE "@E 999,999.99"
	@ li,nPColPrCFr PSay nTGF PICTURE "@E 999,999.99"
		
	li++
	
	@ li,000 Psay Repli("-",limite)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime a quantidade de caminhУes			   					   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ li,00 Psay Repli("-",limite)
	li++
	//cLinha := "QUANTIDADE DE CAMINуES: "+ space(29) + cValToChar(nQtdNF)
	@ li,011 PSay "QUANT. DE CAMINHуES: "
	@ li,032 PSay nQtdNF PICTURE "@E 999.99"
	li++
	@ li,000 Psay Repli("-",limite)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impress└o do rodap┌ 												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF  li != 80
		roda(cbcont,cbtxt,"G")
	ENDIF

	msRet := MsgNOYES("Deseja exportar para excel???", "AtenГЦo!!!")
	If msRet

		xArqTemp := "BIA049C - " + cEmpAnt

		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf

		oExcel:Activate()
		oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

		cCrLf := Chr(13) + Chr(10)
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"VocЙ poderА recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
		Else
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
			oExcel:SetVisible(.T.)
		EndIf

	EndIf

Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fFinaliza
Static FUNCTION fFinaliza()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura Tela e Set's                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SET DEVICE TO SCREEN

	#IFNDEF WINDOWS
	RESTSCREEN(3,0,24,79,cSavScr1)
	DBSETORDER(1)
	#ENDIF

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impress└o em Disco, chama SPOOL 									   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF aReturn[5] == 1		// disco
		Set Printer TO
		Commit					//grava em disco
		ourspool(wnrel)
	ENDIF

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga os arquivos temporarios										   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("TMP")
	Use
	IF  File(cArqTrab+".DBF")
		Ferase(cArqtrab+".*")
	ENDIF


	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Libera relat╒rio para Spool da Rede									   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FT_PFLUSH()

Return


StaTic Function fCabec(cCodTra, cCodFor, lImp)

	Default lImp := .F.

	If li >= 60 .Or. (lImp .And. !TMP->(Eof()))

		cPag++			

		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)

		li++

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+cCodTra)
		@ li,000 PSay "TRANSPORTADORA: "+ SA2->A2_COD +" - "+ AllTrim(SA2->A2_NOME)

		li++
		li++

		DbSeek(xFilial("SA2")+cCodFor)
		@ li,008 PSay "FORNECEDOR: "+ SA2->A2_COD +" - "+ AllTrim(SA2->A2_NOME)

		li++
		li++		

	EndIf

Return()


StaTic Function fDetalhe()

	fCabec(TMP->TRANSP, TMP->FORNEC)

	@ li,nPColDoc PSay AllTrim(TMP->DOC)
	@ li,nPColPrf PSay AllTrim(TMP->PREFIXO)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+TMP->PRODUTO)
	@ li,nPColPrd PSay Subst(SB1->B1_DESC, 1, 20)
	@ li,nPColDtCh PSay TMP->CHEGADA PICTURE "@D"
	@ li,nPColDtVe PSay TMP->VENCTO PICTURE "@D"
	@ li,nPColCte PSay TMP->CTE

	aDif := 0
	aMp	:= 0
	aFrt := 0		

	aDif := TMP->TICKET - TMP->PESONF
	aMp	:= aDif * TMP->PRCUMP
	aFrt := aDif * TMP->PRCUFRET
	
	@ li,nPColPesNf PSay TMP->PESONF PICTURE "@E 999,999.99"	
	@ li,nPColPesEnt PSay TMP->PESENT	PICTURE "@E 999,999.99"
	@ li,nPColPesSai PSay TMP->PESSAI	PICTURE "@E 999,999.99"
	@ li,nPColTicket PSay TMP->TICKET	PICTURE "@E 999,999.99"
	@ li,nPColDif PSay aDif PICTURE "@E 999,999.99"		
	@ li,nPColPrUMp PSay TMP->PRCUMP	PICTURE "@E 9,999.99"
	@ li,nPColPrUFr PSay TMP->PRCUFRET	PICTURE "@E 9,999.99"
	@ li,nPColPrTMp PSay TMP->PRCTMP	PICTURE "@E 999,999.99"
	@ li,nPColPrTFr PSay TMP->PRCTF PICTURE "@E 999,999.99"
	@ li,nPColPrCMp PSay aMp PICTURE "@E 999,999.99"
	@ li,nPColPrCFr PSay aFrt PICTURE "@E 999,999.99"
	@ li,nPColPlaca PSay TMP->PLACA

	// Em 04/09/17... Por Marcos Alberto Soprani
	oExcel:AddRow(nxPlan, nxTabl, { TMP->TRANSP + " " + Posicione("SA2", 1, xFilial("SA2") + TMP->TRANSP, "A2_NOME") ,;
	TMP->FORNEC + " " + Posicione("SA2", 1, xFilial("SA2") + TMP->FORNEC, "A2_NOME"),;
	TMP->DOC,;
	TMP->PREFIXO,;
	TMP->PRODUTO + " " + Subst(SB1->B1_DESC,1,70),;
	TMP->CHEGADA,;
	TMP->VENCTO,;
	TMP->CTE,;
	TMP->PESONF,;
	TMP->PESENT,;
	TMP->PESSAI,;
	TMP->TICKET,;
	aDif,;
	TMP->PRCUMP,;
	TMP->PRCUFRET,;
	TMP->PRCTMP,;
	TMP->PRCTF,;
	aMp,;
	aFrt,;
	TMP->PLACA })

	nTotNf_F := nTotNf_F + TMP->PESONF
	nTotNf_T := nTotNf_T + TMP->PESONF
	nTotGNf := nTotGNf + TMP->PESONF

	nTotFPesEnt := nTotFPesEnt + TMP->PESENT 
	nTotFPesSai := nTotFPesSai + TMP->PESSAI
	nTotTPesEnt := nTotTPesEnt + TMP->PESENT
	nTotTPesSai := nTotTPesSai + TMP->PESSAI
	nTotGPesEnt := nTotGPesEnt + TMP->PESENT
	nTotGPesSai := nTotGPesSai + TMP->PESSAI	

	nTotFTicket := nTotFTicket + TMP->TICKET
	nTotTTicket := nTotTTicket + TMP->TICKET
	nTotGTicket := nTotGTicket + TMP->TICKET

	nTotDif_F	:= nTotDif_F + aDif
	nTotDif_T	:= nTotDif_T + aDif
	nTotGDif := nTotGDif + aDif

	nTotMp_F := nTotMp_F + aMp
	nTotMp_T := nTotMp_T + aMp
	nTotGMp := nTotGMP + aMp

	nTotPTMP_F := nTotPTMP_F + TMP->PRCTMP
	nTotPTMP_T := nTotPTMP_T + TMP->PRCTMP
	nTotGPTMP	:= nTotGPTMP + TMP->PRCTMP

	nTotPTF_F	:= nTotPTF_F + TMP->PRCTF
	nTotPTF_T	:= nTotPTF_T + TMP->PRCTF
	nTotGTF := nTotGTF + TMP->PRCTF

	nTFF := nTFF	+ aFrt
	nTFT := nTFT	+ aFrt
	nTGF := nTGF	+ aFrt

	aDif := 0
	aMp	:= 0
	aFrt := 0		

	li++

Return()				

Static Function fTotFor()	

	@ li,00 Psay Repli("-",limite)

	li++
	
	@ li,011 PSay "TOTAL FORNECEDOR: "
	@ li,nPColPesNf PSay nTotNf_F PICTURE "@E 999,999.99"
	@ li,nPColPesEnt PSay nTotFPesEnt PICTURE "@E 999,999.99"
	@ li,nPColPesSai PSay nTotFPesSai PICTURE "@E 999,999.99"	
	@ li,nPColTicket PSay nTotFTicket PICTURE "@E 999,999.99"
	@ li,nPColDif PSay nTotDif_F	PICTURE "@E 999,999.99"
	@ li,nPColPrTMp PSay nTotPTMP_F PICTURE "@E 999,999.99"
	@ li,nPColPrTFr PSay nTotPTF_F PICTURE "@E 999,999.99"
	@ li,nPColPrCMp PSay nTotMp_F PICTURE "@E 999,999.99"
	@ li,nPColPrCFr PSay nTFF PICTURE "@E 999,999.99"

	li++

	@ li,00 Psay Repli("-",limite)

	lprim := .T.
	nTotUmid_T := nTotUmid_T + (nUmid_F / nTotFTicket)
	nTotGUmid	:= nTotGUmid + (nUmid_F / nTotFTicket)
	nTotDif_F	:= 0
	nTotMp_F := 0
	nTFF := 0
	nTotNf_F := 0
	
	nTotFPesEnt := 0 
	nTotFPesSai := 0
		
	nTotFTicket := 0
	nUmid_F := 0
	nTotPTMP_F := 0
	nTotPTF_F := 0	

Return()


Static Function fTotTra()

	@ li,00 Psay Repli("-",limite)	
	li++

	@ li,nPColPesNf PSay nTotNf_T PICTURE "@E 999,999.99"
	@ li,nPColPesEnt PSay nTotTPesEnt PICTURE "@E 999,999.99"
	@ li,nPColPesSai PSay nTotTPesSai PICTURE "@E 999,999.99"		
	@ li,nPColTicket PSay nTotTTicket PICTURE "@E 999,999.99"
	@ li,nPColDif PSay nTotDif_T PICTURE "@E 999,999.99"
	@ li,nPColPrTMp PSay nTotPTMP_T PICTURE "@E 999,999.99"
	@ li,nPColPrTFr PSay nTotPTF_T PICTURE "@E 999,999.99"
	@ li,nPColPrCMp PSay nTotMp_T PICTURE "@E 999,999.99"
	@ li,nPColPrCFr PSay nTFT PICTURE "@E 999,999.99"

	li++

	@ li,00 Psay Repli("-",limite)

	nTotUmid_T := 0 
	nTotNf_T := 0	
	
	nTotTPesEnt := 0 
	nTotTPesSai := 0
	
	nTotTTicket := 0
	nTotDif_T := 0
	nTotPTMP_T := 0
	nTotPTF_T := 0
	nTotMp_T := 0
	nTFT := 0	

Return()


Static Function fPesagem(cNumTk, nPesEnt, nPesSai, cPlaca)
Local cSQL := ""
Local cQry := GetNextAlias()
  
	cSQL := " SELECT TICKET, SUM(Z11_PESOIN) AS PESENT, SUM(Z11_PESOSA) AS PESSAI, Z11_PCAVAL AS PLACA, Z11_DATASA AS DATSAI " 
	cSQL += " FROM ( "
	cSQL += " SELECT SUBSTRING(Z11_GUARDI, 1, 6) AS TICKET, Z11_PESOIN, Z11_PESOSA, Z11_PCAVAL, Z11_DATASA " 
	cSQL += " FROM Z11010 "
	cSQL += " WHERE Z11_MERCAD = 1 "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " UNION ALL "
				
	cSQL += " SELECT Z11_PESAGE AS TICKET, Z11_PESOIN, Z11_PESOSA, Z11_PCAVAL, Z11_DATASA "
	cSQL += " FROM Z11010 "
	cSQL += " WHERE Z11_MERCAD = 1 "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " UNION ALL "
			
	cSQL += " SELECT Z11_PESAGE AS TICKET, Z11_PESOIN, Z11_PESOSA, Z11_PCAVAL, Z11_DATASA "
	cSQL += " FROM Z11050 "
	cSQL += " WHERE Z11_MERCAD = 1 "
	cSQL += " AND D_E_L_E_T_ = '' "		
	
	cSQL += " ) PESAGEM "
	cSQL += " WHERE TICKET = "+ ValToSQL(AllTrim(cNumTk))
	cSQL += " GROUP BY TICKET, Z11_PCAVAL, Z11_DATASA "
	cSQL += " ORDER BY Z11_DATASA DESC "
	
	TcQuery cSQL New Alias (cQry)			
	
	If !Empty((cQry)->TICKET)

		nPesEnt := (cQry)->PESENT
		nPesSai := (cQry)->PESSAI
		cPlaca := (cQry)->PLACA

	Else
	
		nPesEnt := 0
		nPesSai := 0
		cPlaca := ""
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return()