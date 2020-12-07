#include "rwmake.ch" 
#include "topconn.ch"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Bia002()

	SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
	SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
	SetPrvt("CNATUREZA,ARETURN,NOMEPROG,CPERG,NLASTKEY,LCONTINUA")
	SetPrvt("NLIN,WNREL,NBEGIN,NLINHA,CDESCRIC,NTAMNF")
	SetPrvt("CSTRING,CPEDANT,CPCANT,NLININI,XNUM_NF,XSERIE")
	SetPrvt("XEMISSAO,XTOT_FAT,XLOJA,XFRETE,XSEGURO,XBASE_ICMS")
	SetPrvt("XBASE_IPI,XVALOR_ICMS,XICMS_RET,XVALOR_IPI,XVALOR_MERC,XNUM_DUPLIC")
	SetPrvt("XCOND_PAG,XPBRUTO,XPLIQUI,XTIPO,XESPECIE,XVOLUME")
	SetPrvt("XPLACA,XUFPLACA,XDESC_NF,XFRETAUT,XICMAUTO,CPEDATU")
	SetPrvt("CITEMATU,NDESCZFR,XPED_VEND,XITEM_PED,XNUM_NFDV,XPREF_DV")
	SetPrvt("XICMS,XCOD_PRO,XLOTE,XQTD_PRO,XPRE_UNI,XPRE_TAB,XIPI")
	SetPrvt("XVAL_IPI,XDESC,XVAL_DESC,XVAL_MERC,XTES,XCF")
	SetPrvt("XICMSOL,XICM_PROD,XPESO_PRO,XPESO_UNIT,XDESCRICAO,XUNID_PRO")
	SetPrvt("XCOD_TRIB,XMEN_TRIB,XCOD_FIS,XCLAS_FIS,XMEN_POS,XISS")
	SetPrvt("XTIPO_PRO,XLUCRO,XCLFISCAL,XPESO_LIQ,I,NPELEM")
	SetPrvt("_CLASFIS,NPTESTE,XPESO_LIQUID,XPED,XPESO_BRUTO,XP_LIQ_PED")
	SetPrvt("XCLIENTE,XTIPO_CLI,XCOD_MENS,XMENSAGEM,XTPFRETE,XCONDPAG")
	SetPrvt("XMARCA,XNUMERO,XDESPESA,XCOD_VEND,XDESCONT,XDESC_PAG")
	SetPrvt("XPED_CLI,XDESC_PRO,XPESOL,XCOD_CLI,XNOME_CLI,XEND_CLI")
	SetPrvt("XBAIRRO,XCEP_CLI,XCOB_CLI,XREC_CLI,XMUN_CLI,XEST_CLI")
	SetPrvt("XCGC_CLI,XINSC_CLI,XTRAN_CLI,XTEL_CLI,XFAX_CLI,XSUFRAMA")
	SetPrvt("XCALCSUF,CSUFRAMA,ZFRANCA,XVENDEDOR,XBSICMRET,XNOME_TRANSP")
	SetPrvt("XEND_TRANSP,XMUN_TRANSP,XEST_TRANSP,XVIA_TRANSP,XCGC_TRANSP,XTEL_TRANSP")
	SetPrvt("XINSC_EST,XPARC_DUP,XVENC_DUP,XVALOR_DUP,XDUP_TOT,XDUPLICATAS")
	SetPrvt("XNATUREZA,XFORNECE,XNFORI,XPEDIDO,XPESOPROD,XFAX")
	SetPrvt("NOPC,CCOR,XB_ICMS_SOL,XV_ICMS_SOL,NTAMDET,J")
	SetPrvt("NCONT,NCOL,NTAMOBS,NCOL1,NCOL2,NCOL3")
	SetPrvt("NCOL4,NCOL5,NCOL6,NCOL7,NCOL8,NAJUSTE")
	SetPrvt("DESCONT,PRECO_CHEIO")
	SetPrvt("BB,CREGESP,CSUBTP,CA1TIPO,LCACO")

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³  Nfiscal ³ Autor ³	 Marcos Simidu      ³ Data ³ 20/12/95 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Impressao das notas fiscal de Entrada/Saida                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso		 ³ Especifico para Clientes Microsiga					      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Ambientais									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros						 ³
	//³ mv_par01  // Da Nota Fiscal									 ³
	//³ mv_par02  // Ate a Nota Fiscal								 ³
	//³ mv_par03  // Da Serie										 ³
	//³ mv_par04  // Nota Fiscal de Entrada/Saida					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xDESC_NF  := 0
	CbTxt 	  :=""
	CbCont	  :=""
	nOrdem	  := 0
	Alfa      := 0
	Z         := 0
	M         := 0
	tamanho	  :="G"
	limite	  :=220
	titulo	  :=PADC("Nota Fiscal - Nfiscal",74)
	cDesc1	  :=PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
	cDesc2	  :=""
	cDesc3	  :=PADC("da Nfiscal",74)
	cNatureza :=""
	aReturn	  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog  :="nfiscal"
	cPerg 	  :="NFSIGW"
	nLastKey  := 0
	lContinua := .T.
	nLin      := 0
	wnrel 	  := "siganf"
	nBegin	  := 0
	nLinha	  := 0
	cDescric  := ""
	cRegEsp	  := ""
	cA1TIPO   := ""
	cSUBTP    := ""
	lCaco     := .F.
	Enter1    := CHR(13)+CHR(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tamanho do formulario de Nota Fiscal (em Linhas)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTamNf:=78		// Apenas Informativo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas, busca o padrao da Nfiscal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)	  // Pergunta no SX1
	cString:="SF2"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
	if nLastKey == 27
		Return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Posicao do formulario na Impressora                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetDefault(aReturn,cString)
	if nLastKey == 27
		Return
	endif
	VerImp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio do Processamento da Nota Fiscal                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Function RptDetail
Static Function RptDetail()

	Local K, I

	IF UPPER(ALLTRIM(FUNNAME())) = "MATA460A"
		MV_PAR01 := SF2->F2_DOC
		MV_PAR02 := SF2->F2_DOC
		MV_PAR03 := SF2->F2_SERIE
		MV_PAR04 := "2"
	END IF

	//Analisa se existem notas fiscais geradas e nao impressas. Isto nao podera acontecer.
	cQuery := 	""
	cQuery +=	"SELECT COUNT(*) QUANT				        					  "	+ Enter1
	cQuery +=	"FROM "+RetSqlName("SF2")+" AS SF2	        					  "	+ Enter1
	cQuery +=	"WHERE SF2.F2_FILIAL  	 = '"+xFilial("SF2")+"'	AND      		  "	+ Enter1
	cQuery +=	"      SF2.D_E_L_E_T_ 	 = ''	   AND       					  "	+ Enter1
	cQuery += "        SF2.F2_DOC < '"+MV_PAR01+"' AND                            "	+ Enter1
	cQuery +=   "      F2_SERIE     	 = '"+MV_PAR03+"'	AND 				  " + Enter1
	cQuery +=	"      SF2.F2_YIMPRIM	<> 'S'     	        					  "	+ Enter1
	IF chkfile("_Trab")
		dbSelectArea("_Trab")
		dbCloseArea()
	ENDIF
	TCQuery cQuery Alias "_Trab" New

	IF _Trab->QUANT > 0
		MsgBox("Existe Nota Fiscal nao Impressa. Favor Verificar!!!","STOP")
	ENDIF

	if mv_par04 == 2
		dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
		dbSetOrder(1)
		dbSeek(xFilial()+mv_par01+mv_par03,.t.)

		dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
		dbSetOrder(3)
		dbSeek(xFilial()+mv_par01+mv_par03)
		cPedant := SD2->D2_PEDIDO

		dbSelectArea("SC5")                // * Cabecalho do pedido de vendas
		dbSetOrder(1)
		dbSeek(xFilial()+cPedant)
		cPcant  := SC5->C5_YPC
		cSubtp  := SC5->C5_YSUBTP

		dbSelectArea("SA1")                // * Cadastro de Clientes
		dbSetOrder(1)
		dbSeek(xFilial()+SC5->C5_CLIENTE,.T.)
	else
		dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
		DbSetOrder(1)
		dbSeek(xFilial()+mv_par01+mv_par03,.t.)

		dbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
		dbSetOrder(3)
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(Iif(Val(mv_par02)-Val(mv_par01)==0,1,Val(mv_par02)-Val(mv_par01)+1))
	if mv_par04 == 2
		dbSelectArea("SF2")
		while !SF2->(EOF()) .AND. (SF2->F2_DOC <= mv_par02) .AND.	lContinua
			if SF2->F2_SERIE #mv_par03	         // Se a Serie do Arquivo for Diferente
				//DbSkip() 						 // do Parametro Informado !!!
				SF2->(DbSkip())
				Loop
			endif
			if lAbortPrint
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			endif
			nLinIni:=nLin								  // Linha Inicial da Impressao

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio de Levantamento dos Dados da Nota Fiscal.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			// * Cabecalho da Nota Fiscal

			xNUM_NF		:=SF2->F2_DOC				  // Numero
			xSERIE		:=SF2->F2_SERIE			  // Serie
			xEMISSAO 	:=SF2->F2_EMISSAO 		      // Data de Emissao
			xTOT_FAT 	:=SF2->F2_VALFAT			  // Valor Total da Fatura

			//Se for Exportacao, grava o Valor da Mercadoria
			If Alltrim(SF2->F2_EST) == "EX"
				xTOT_FAT := SF2->F2_VALMERC
			EndIf

			If xTOT_FAT == 0
				IF SF2->F2_TIPO == 'I'
					xTOT_FAT := SF2->F2_VALICM+SF2->F2_ICMSRET
				ELSE
					xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE+SF2->F2_ICMSRET+SF2->F2_DESPESA
				ENDIF
			EndIf

			xLOJA 		:=SF2->F2_LOJA 			  // Loja do Cliente
			xFRETE		:=SF2->F2_FRETE			  // Frete
			xSEGURO		:=SF2->F2_SEGURO		  // Seguro
			xBASE_ICMS	:=SF2->F2_BASEICM         // Base do ICMS
			xBASE_IPI	:=SF2->F2_BASEIPI         // Base do IPI
			xVALOR_ICMS :=SF2->F2_VALICM		  // Valor do ICMS
			xICMS_RET	:=SF2->F2_ICMSRET 		  // Valor do ICMS Retido
			xVALOR_IPI	:=SF2->F2_VALIPI		  // Valor do IPI
			xVALOR_MERC :=SF2->F2_VALMERC 		  // Valor da Mercadoria
			xNUM_DUPLIC :=SF2->F2_DUPL 			  // Numero da Duplicata
			xCOND_PAG	:=SF2->F2_COND 			  // Condicao de Pagamento
			xPBRUTO		:=SF2->F2_PBRUTO		  // Peso Bruto
			xPLIQUI		:=SF2->F2_PLIQUI		  // Peso Liquido
			xTIPO 		:=SF2->F2_TIPO 			  // Tipo do Cliente
			xESPECIE 	:=SF2->F2_ESPECI1 		  // Especie 1 no Pedido
			xVOLUME		:=SF2->F2_VOLUME1 		  // Volume 1 no Pedido
			xPLACA		:=SF2->F2_YPLACA		  // Placa do Caminhao
			xUFPLACA 	:=SF2->F2_YUF			  // UF da Placa do Caminhao
			xDESC_NF 	:=SF2->F2_DESCONT 		  // Desconto da Nota Fiscal
			xFRETAUT 	:=SF2->F2_FRETAUT 		  // Base ICMS Frete Autonomo
			xICMAUTO 	:=SF2->F2_ICMAUTO 		  // ICMS Frete Autonomo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Itens de venda na NF de saida.                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			dbSetOrder(3)
			dbSeek(xFilial()+xNUM_NF+xSERIE)

			cPedAtu  := SD2->D2_PEDIDO
			cItemAtu := SD2->D2_ITEMPV
			nDesczfr := 0								  // Total de desconto de ICMS

			xPED_VEND:={}								  // Numero do Pedido de Venda
			xITEM_PED:={}								  // Numero do Item do Pedido de Venda
			xNUM_NFDV:={}								  // nUMERO QUANDO HOUVER DEVOLUCAO
			xPREF_DV :={}								  // Serie	quando houver devolucao
			xICMS    :={}                        		  // Porcentagem do ICMS
			xCOD_PRO :={}								  // Codigo  do Produto
			xLOTE    :={}								  // Codigo  do Lote do Produto
			xQTD_PRO :={}								  // Peso/Quantidade do Produto
			xPRE_UNI :={}								  // Preco Unitario de Venda
			xPRE_TAB :={}								  // Preco Unitario de Tabela
			xIPI	 :={}							     	// Porcentagem do IPI
			xVAL_IPI :={}								  // Valor do IPI
			xDESC    :={}                        			// Desconto por Item
			xVAL_DESC:={}								  // Valor do Desconto
			xVAL_MERC:={}								  // Valor da Mercadoria
			xTES	 :={}								  // TES
			xCF		 :={}                        			// Classificacao quanto natureza da Operacao
			xICMSOL	 :={}                        			// Base do ICMS Solidario
			xICM_PROD:={}								  // ICMS do Produto
			xCOD_TRIB:={}

			while !SD2->(EOF()) .AND. (SD2->D2_DOC	== xNUM_NF) .AND. (SD2->D2_SERIE == xSERIE)
				if SD2->D2_SERIE # mv_par03	 // Se a Serie do Arquivo for Diferente
					DbSkip() 		   			 // do Parametro Informado !!!
					Loop
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula desconto de icms.                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nDesczfr := nDesczfr + SD2->D2_DESCZFR

				AADD(xPED_VEND  ,SD2->D2_PEDIDO)
				AADD(xITEM_PED  ,SD2->D2_ITEMPV)
				AADD(xNUM_NFDV  ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
				AADD(xPREF_DV	,SD2->D2_SERIORI)
				AADD(xICMS		,Iif(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
				AADD(xCOD_PRO	,SD2->D2_COD)
				AADD(xLote   	,SD2->D2_LOTECTL)
				AADD(xQTD_PRO	,SD2->D2_QUANT)	  // Guarda as quant. da NF
				AADD(xPRE_UNI	,IIF(SD2->D2_DESCZFR>0,SD2->D2_PRUNIT,SD2->D2_PRCVEN))
				AADD(xPRE_TAB	,SD2->D2_PRUNIT)
				AADD(xIPI		,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
				AADD(xVAL_IPI	,SD2->D2_VALIPI)
				AADD(xDESC		,SD2->D2_DESC)
				AADD(xVAL_MERC  ,IIF(SD2->D2_DESCZFR>0,ROUND(SD2->D2_QUANT*SD2->D2_PRUNIT,2),SD2->D2_TOTAL))
				AADD(xTES		,SD2->D2_TES)
				AADD(xCF 		,SD2->D2_CF)
				AADD(xICM_PROD  ,Iif(Empty(SD2->D2_PICM),0,SD2->D2_PICM))

				SB1->(DbSeek(xFilial()+SD2->D2_COD))

				/*
				wsCodTrib := SB1->B1_ORIGEM
				If SD2->D2_TES $ "519_597_596_549"
				wsCodTrib := "041"
				EndIf
				If SD2->D2_TES $ "507_992_587"
				wsCodTrib := "040"
				EndIf
				If SD2->D2_TES $ "896_970"
				wsCodTrib := "050"
				EndIf
				If SD2->D2_TES $ "572"  //Solidario
				wsCodTrib := "010"
				EndIf
				If SD2->D2_TES $ "640" 
				wsCodTrib := SD2->D2_CLASFIS
				EndIf
				*/

				AADD(xCOD_TRIB  , SD2->D2_CLASFIS)

				DbSelectArea("SD2")
				SD2->(DbSkip())
			End

			xYFLAG      :=''
			xYEND       :=''
			xYEST       :=''
			xYMUN       :=''
			xYBAIRRO    :=''
			xYCEP       :=''
			xYTEL       :=''

			dbSelectArea("SC5")                // * Cabecalho do pedido de vendas
			dbSetOrder(1)
			SC5->(DbSeek(xFilial()+SF2->F2_YPEDIDO))
			xYFLAG      :=SC5->C5_YFLAG
			xYEND       := SUBSTR(SC5->C5_YEND,1,50)
			xYEST       :=SC5->C5_YEST
			xYMUN       :=SC5->C5_YMUN
			xYBAIRRO    :=SC5->C5_YBAIRRO
			xYCEP       :=SC5->C5_YCEP
			xYTEL       :=SC5->C5_YTEL
			cSubtp      :=SC5->C5_YSUBTP

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descricao Generica dos produtos.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xPESO_PRO :={} 								// Peso Liquido
			xPESO_UNIT:={} 								// Peso Unitario do Produto
			xDESCRICAO:={} 								// Descricao do Produto
			xUNID_PRO :={} 								// Unidade do Produto
			//xCOD_TRIB :={} 								// Codigo de Tributacao
			//xMEN_TRIB :={} 								// Mensagens de Tributacao
			xCOD_FIS  :={} 								// Cogigo Fiscal
			xCLAS_FIS :={} 								// Classificacao Fiscal
			xTES_FIS  :={} 								// TES
			xMEN_POS  :={} 								// Mensagem da Posicao IPI
			xISS      :={} 								// Aliquota de ISS
			xTIPO_PRO :={} 								// Tipo do Produto
			xLUCRO    :={} 								// Margem de Lucro p/ ICMS Solidario
			xCLFISCAL :={}
			xPESO_LIQ := 0

			for I:=1 to Len(xCOD_PRO)

				SB1->(DbSeek(xFilial()+xCOD_PRO[I]))

				/*wsCodTrib := SB1->B1_ORIGEM

				If xTES[I] $ "519_597_596_549"
				wsCodTrib := "041"
				EndIf

				If xTES[I] $ "507_992_587"
				wsCodTrib := "040"
				EndIf

				If xTES[I] $ "896_970"
				wsCodTrib := "050"
				EndIf

				If Alltrim(xTES[I]) $ "572"  //Solidario
				wsCodTrib := "010"
				EndIf

				If Alltrim(xTES[I]) $ "640" 
				wsCodTrib := SD2->D2_CLASFIS
				EndIf*/

				aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
				cSQLL := ""
				cSQLL := "SELECT * FROM ZZ9010 "
				cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
				cSQLL += "		ZZ9_LOTE = '" +SD2->D2_LOTECTL+ "' AND "
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
					sPESO	:= SB1->B1_PESO
					IF SB1->B1_TIPO == 'PA'
						//MsgBox("Favor Verificar o peso cadastrado para este Lote/Produto: "+SD2->D2_LOTECTL+"/"+aCODPRODUTO,"STOP")
					ENDIF
				ENDIF

				AADD(xPESO_PRO ,sPESO * xQTD_PRO[I])
				xPESO_LIQ := xPESO_LIQ + xPESO_PRO[I]
				AADD(xPESO_UNIT , sPESO)
				AADD(xUNID_PRO  , SB1->B1_UM)
				AADD(xDESCRICAO , SB1->B1_DESC)
				//AADD(xCOD_TRIB  , wsCodTrib)
				AADD(xCLAS_FIS ,  SB1->B1_CLASFIS)
				AADD(xCLFISCAL ,  SB1->B1_POSIPI)

				//if Ascan(xMEN_TRIB , SB1->B1_ORIGEM) == 0
				//	AADD(xMEN_TRIB  , SB1->B1_ORIGEM)
				//endif

				if SB1->B1_ALIQISS > 0
					AADD(xISS ,SB1->B1_ALIQISS)
				endif

				AADD(xTIPO_PRO ,SB1->B1_TIPO)
				AADD(xLUCRO	 ,SB1->B1_PICMRET)

				//
				// Calculo do Peso Liquido da Nota Fiscal
				//

				xPESO_LIQUID:=0			// Peso Liquido da Nota Fiscal
				for K:=1 to Len(xPESO_PRO)
					xPESO_LIQUID:=xPESO_LIQUID+xPESO_PRO[K]
				next
			next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pedido de Venda.                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC5")
			dbSetOrder(1)

			xPED        := {}
			xPESO_BRUTO := 0
			xP_LIQ_PED	:= 0
			for I:=1 to Len(xPED_VEND)

				SC5->(DbSeek(xFilial()+xPED_VEND[I]))

				if ASCAN(xPED,xPED_VEND[I])==0

					dbSeek(xFilial()+xPED_VEND[I])

					xCLIENTE 	:=SC5->C5_CLIENTE 			   // Codigo do Cliente
					xTIPO_CLI	:=SC5->C5_TIPOCLI 			   // Tipo de Cliente
					xCOD_MENS	:=SC5->C5_MENPAD	           // Codigo da Mensagem Padrao
					xMENSAGEM	:=SC5->C5_MENNOTA 			   // Mensagem para a Nota Fiscal
					xTPFRETE 	:=SC5->C5_TPFRETE 			   // Tipo de Entrega
					xCONDPAG 	:=SC5->C5_CONDPAG 			   // Condicao de Pagamento
					xPESO_BRUTO :=SC5->C5_PBRUTO		       // Peso Bruto
					xMARCA		:=SC5->C5_YMARCA		       // Marca
					xNUMERO		:=SC5->C5_YNUMERO 			   // Numero
					xDESPESA 	:=SC5->C5_DESPESA             // Despesa Acessoria
					xP_LIQ_PED	:=xP_LIQ_PED + SC5->C5_PESOL  // Peso Liquido
					////////////////////////////////////////
					//xYFLAF      :=SC5->C5_YFLAG
					//xYEND       :=SC5->C5_YEND
					//xYEST       :=SC5->C5_YEST
					//xYMUN       :=SC5->C5_YMUN
					//xYBAIRRO    :=SC5->C5_YBAIRRO
					//xYCEP       :=SC5->C5_YCEP
					//xYTEL       :=SC5->C5_YTEL
					////////////////////////////////////////
					xCOD_VEND	:= {SC5->C5_VEND1,;		       // Codigo do Vendedor 1
					SC5->C5_VEND2,;			                   // Codigo do Vendedor 2
					SC5->C5_VEND3,;			                   // Codigo do Vendedor 3
					SC5->C5_VEND4,;			                   // Codigo do Vendedor 4
					SC5->C5_VEND5}			                   // Codigo do Vendedor 5
					xDESCONT 	:=  SC5->C5_DESC1 			   // Desconto Global 1
					// SC5->C5_DESC2,;						   // Desconto Global 2
					// SC5->C5_DESC3,;						   // Desconto Global 3
					// SC5->C5_DESC4} 						   // Desconto Global 4
					AADD(xPED,xPED_VEND[I])
				endif

				if xP_LIQ_PED >0
					xPESO_LIQ := xP_LIQ_PED
				endif
			next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa da Condicao de Pagto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			dbSelectArea("SE4")                    // Condicao de Pagamento
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+xCONDPAG)
			xDESC_PAG := SE4->E4_DESCRI

			dbSelectArea("SC6")                    // * Itens de Pedido de Venda
			dbSetOrder(1)
			xPED_CLI  :={}						   // Numero de Pedido
			xDESC_PRO :={}						   // Descricao aux do produto
			xPESOL    :={}						   // Peso Liquido
			xYIMPNF   :={}

			for I:=1 to Len(xPED_VEND)
				dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
				AADD(xPED_CLI ,SC6->C6_PEDCLI)
				AADD(xDESC_PRO,SC6->C6_DESCRI)
				AADD(xVAL_DESC,SC6->C6_VALDESC)
				AADD(xPESOL   ,SC6->C6_YPESOL)
				AADD(xYIMPNF  ,SC6->C6_YIMPNF)
			next

			if xTIPO$'N,C,P,I,S,T,O'

				dbSelectArea("SA1")                // * Cadastro de Clientes
				dbSetOrder(1)
				dbSeek(xFilial()+xCLIENTE+xLOJA)

				xCOD_CLI := SA1->A1_COD 			 // Codigo do Cliente
				xNOME_CLI:= SA1->A1_NOME			 // Nome
				IF xYFLAG = '2'
					xEND_CLI := xYEND 			 // Endereco
					xBAIRRO  := xYBAIRRO 		 // Bairro
					xCEP_CLI := xYCEP 			 // CEP
					xMUN_CLI := xYMUN 			 // Municipio
					xEST_CLI := xYEST 			 // Estado
					xTEL_CLI := xYTEL 			 // Telefone
				ELSE
					xEND_CLI := SA1->A1_END 			 // Endereco
					xBAIRRO  := SA1->A1_BAIRRO 		 // Bairro
					xCEP_CLI := SA1->A1_CEP 			 // CEP
					xMUN_CLI := SA1->A1_MUN 			 // Municipio
					xEST_CLI := SA1->A1_EST 			 // Estado
					xTEL_CLI := SA1->A1_TEL 			 // Telefone
				ENDIF

				xCOB_CLI := SA1->A1_ENDCOB 		 // Endereco de Cobranca
				xREC_CLI := SA1->A1_ENDENT 		 // Endereco de Entrega
				xCGC_CLI := SA1->A1_CGC 			 // CGC
				xINSC_CLI:= SA1->A1_INSCR			 // Inscricao estadual
				xTRAN_CLI:= SA1->A1_TRANSP 		 // Transportadora
				xFAX_CLI := SA1->A1_FAX 			 // Fax
				xSUFRAMA := SA1->A1_SUFRAMA		 // Codigo Suframa
				xCALCSUF := SA1->A1_CALCSUF		 // Calcula Suframa
				xCodMun  := SA1->A1_CODMUN
				cSuframa := SA1->A1_SUFRAMA
				cRegEsp  := SA1->A1_YREGESP
				cA1tipo  := SA1->A1_TIPO

				// Alteracao p/ Calculo de Suframa
				zFranca:= .F.
				if !(XTIPO$'D,B') .AND. !empty(xSUFRAMA) .AND. (xCALCSUF == "S")
					zFranca := .T.
				endif
			else

				dbSelectArea("SA2")                   // * Cadastro de fornecedores
				dbSetOrder(1)
				dbSeek(xFilial()+xCLIENTE+xLOJA)

				xCOD_CLI :=SA2->A2_COD				  // Codigo do fornecedor
				xNOME_CLI:=SUBSTR(SA2->A2_NOME,1,63)  // Nome
				xEND_CLI :=SA2->A2_END				  // Endereco
				xBAIRRO  :=SA2->A2_BAIRRO			  // Bairro
				xCEP_CLI :=SA2->A2_CEP				  // CEP
				xCOB_CLI :=""                     // Endereco de Cobranca
				xREC_CLI :=""                     // Endereco de Entrega
				xMUN_CLI :=SA2->A2_MUN				  // Municipio
				xEST_CLI :=SA2->A2_EST				  // Estado
				xCGC_CLI :=SA2->A2_CGC				  // CGC
				xINSC_CLI:=SA2->A2_INSCR			  // Inscricao estadual
				xTRAN_CLI:=SA2->A2_TRANSP			  // Transportadora
				xTEL_CLI :=SA2->A2_TEL				  // Telefone
				xFAX_CLI :=SA2->A2_FAX				  // Fax

				zFranca:=.F.
			endif

			dbSelectArea("SA3")                   // * Cadastro de Vendedores
			dbSetOrder(1)
			xVENDEDOR:={}						         // Nome do Vendedor

			for I:=1 to Len(xCOD_VEND)
				dbSeek(xFilial()+xCOD_VEND[I])
				Aadd(xVENDEDOR , Alltrim(SA3->A3_NREDUZ))
			next

			if xICMS_RET > 0						   // Apenas se ICMS Retido > 0
				dbSelectArea("SF3")                   // * Cadastro de Livros Fiscais
				dbSetOrder(4)
				if dbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
					xBSICMRET:=F3_BASERET //F3_VALOBSE
				else
					xBSICMRET:=0
				endif
			else
				xBSICMRET:=0
			endif

			dbSelectArea("SA4")                   // * Transportadoras
			dbSetOrder(1)
			dbSeek(xFilial()+SF2->F2_TRANSP)

			xNOME_TRANSP :=SA4->A4_NOME		  // Nome Transportadora
			xEND_TRANSP  :=SA4->A4_END 		  // Endereco
			xMUN_TRANSP  :=SA4->A4_MUN 		  // Municipio
			xEST_TRANSP  :=SA4->A4_EST 		  // Estado
			xVIA_TRANSP  :=SA4->A4_VIA 		  // Via de Transporte
			xCGC_TRANSP  :=SA4->A4_CGC 		  // CGC
			xTEL_TRANSP  :=SA4->A4_TEL 		  // Fone
			xINSC_EST	 :=SA4->A4_INSEST 		  // Inscr Estadual

			dbSelectArea("SE1")                   // * Contas a Receber
			dbSetOrder(1)

			xPARC_DUP  :={}					  // Parcela
			xVENC_DUP  :={}					  // Vencimento
			xVALOR_DUP :={}					  // Valor
			xDUP_TOT   :=0
			xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

			while !SE1->(EOF())					  .AND.;
			(SE1->E1_NUM == xNUM_DUPLIC) .AND.;
			xDUPLICATAS

				if !("NF" $ SE1->E1_TIPO)
					dbSkip()
					Loop
				endif

				AADD(xPARC_DUP  , SE1->E1_PARCELA)
				AADD(xVENC_DUP  , SE1->E1_VENCTO)
				AADD(xVALOR_DUP , SE1->E1_VLCRUZ)
				dbSkip()
			enddo

			dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
			DbSetOrder(1)
			dbSeek(xFilial()+xTES[1])
			xNATUREZA:=SF4->F4_TEXTO			  // Natureza da Operacao

			Imprime()

			IncRegua()						      // Termometro de Impressao
			SF2->(DbSkip())				      // passa para a proxima Nota Fiscal
			nLin := 0
		enddo
	else
		dbSelectArea("SF1")              // * Cabecalho da Nota Fiscal Entrada
		dbSeek(xFilial()+mv_par01+mv_par03,.t.)

		while !SF1->(EOF())					 .AND.;
		(SF1->F1_DOC	<= mv_par02) .AND.;
		(SF1->F1_SERIE == mv_par03) .AND.;
		lContinua

			IF SF1->F1_FORMUL <> "S"
				SF1->(DbSkip())
				Loop
			end If

			if SF1->F1_SERIE #mv_par03	         // Se a Serie do Arquivo for Diferente
				DbSkip() 						 // do Parametro Informado !!!
				Loop
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa  regua de impressao                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetRegua(iif(Val(mv_par02)-Val(mv_par01)==0,1,Val(mv_par02)-Val(mv_par01)+1))
			IF lAbortPrint
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			endif
			nLinIni:=nLin						 	   // Linha Inicial da Impressao

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio de Levantamento dos Dados da Nota Fiscal			     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xNUM_NF		:=SF1->F1_DOC				  // Numero
			xSERIE		:=SF1->F1_SERIE			  // Serie
			xFORNECE 	:=SF1->F1_FORNECE 		      // Cliente/fornecedor
			xEMISSAO 	:=SF1->F1_EMISSAO 		      // Data de Emissao
			xTOT_FAT 	:=SF1->F1_VALBRUT 		      // Valor Bruto da Compra
			xLOJA 		:=SF1->F1_LOJA 			  // Loja do Cliente
			xFRETE		:=SF1->F1_FRETE			  // Frete
			xSEGURO		:=SF1->F1_DESPESA 		      // Despesa
			xBASE_ICMS	:=SF1->F1_BASEICM 		      // Base	do ICMS
			xBASE_IPI	:=SF1->F1_BASEIPI 		      // Base	do IPI
			xBSICMRET	:=SF1->F1_BRICMS			  // Base do ICMS Retido
			xVALOR_ICMS :=SF1->F1_VALICM			  // Valor	do ICMS
			xICMS_RET	:=SF1->F1_ICMSRET 		      // Valor	do ICMS Retido
			xVALOR_IPI	:=SF1->F1_VALIPI			  // Valor	do IPI
			xVALOR_MERC :=SF1->F1_VALMERC 		      // Valor	da Mercadoria
			xNUM_DUPLIC :=SF1->F1_DUPL 			  // Numero da Duplicata
			xCOND_PAG	:=SF1->F1_COND 			  // Condicao de Pagamento
			xTIPO 		:=SF1->F1_TIPO 			  // Tipo do Cliente
			xNFORI		:=SF1->F1_NFORI			  // NF Original
			xPREF_DV 	:=SF1->F1_SERIORI 		      // Serie Original

			dbSelectArea("SD1")                      // * Itens da N.F. de Compra
			dbSetOrder(1)
			dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)

			cPedAtu := SD1->D1_PEDIDO
			cItemAtu:= SD1->D1_ITEMPC

			xPEDIDO	 :={}								  // Numero do Pedido de Compra
			xITEM_PED:={}								  // Numero do Item do Pedido de Compra
			xNUM_NFDV:={}								  // Numero quando houver devolucao
			xPREF_DV :={}								  // Serie	quando houver devolucao
			xICMS 	 :={}								  // Porcentagem do ICMS
			xCOD_PRO :={}								  // Codigo  do Produto
			xLOTE    :={}								  // Codigo  do Lote do Produto
			xQTD_PRO :={}								  // Peso/Quantidade do Produto
			xPRE_UNI :={}								  // Preco Unitario de Compra
			xIPI	 :={}							      // Porcentagem do IPI
			xPESOPROD:={}								  // Peso do Produto
			xVAL_IPI :={}								  // Valor do IPI
			xDESC 	 :={}								  // Desconto por Item
			xVAL_DESC:={}								  // Valor do Desconto
			xVAL_MERC:={}								  // Valor da Mercadoria
			xTES	 :={}								  // TES
			xCF		 :={}								  // Classificacao quanto natureza da Operacao
			xICMSOL	 :={}								  // Base do ICMS Solidario
			xICM_PROD:={}								  // ICMS do Produto
			xCOD_TRIB :={} 								  // Codigo de Tributacao

			IF xDESC_NF <> 0
				xPRE_TAB:={}
			END IF
			while !SD1->(EOF()) .AND.;
			(SD1->D1_DOC == xNUM_NF .AND. SD1->D1_SERIE == xSERIE .AND. SD1->D1_FORNECE == xFORNECE .AND. SD1->D1_LOJA	== xLOJA )

				if SD1->D1_SERIE #mv_par03		  // Se a Serie do Arquivo for Diferente
					DbSkip()					  // do Parametro Informado !!!
					Loop
				endif

				AADD(xPEDIDO ,SD1->D1_PEDIDO) 			     // Ordem de Compra
				AADD(xITEM_PED  ,SD1->D1_ITEMPC)		     // Item da O.C.
				AADD(xNUM_NFDV  ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
				AADD(xPREF_DV	,SD1->D1_SERIORI) 		     // Serie Original
				AADD(xICMS		,Iif(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
				AADD(xLote   	,SD1->D1_LOTECTL)	  	     // Produto
				AADD(xCOD_PRO   ,SD1->D1_COD)				 // Lote
				AADD(xQTD_PRO	,SD1->D1_QUANT)			 // Guarda as quant. da NF
				AADD(xPRE_UNI	,SD1->D1_VUNIT)			 // Valor Unitario
				AADD(xIPI		,SD1->D1_IPI)				 // % IPI
				AADD(xVAL_IPI	,SD1->D1_VALIPI)			 // Valor do IPI
				AADD(xPESOPROD  ,SD1->D1_PESO) 			     // Peso do Produto
				AADD(xDESC		,SD1->D1_DESC) 			 // % Desconto
				AADD(xVAL_MERC  ,SD1->D1_TOTAL)			     // Valor Total
				AADD(xTES		,SD1->D1_TES)				 // Tipo de Entrada/Saida
				AADD(xCF 		,SD1->D1_CF)				 // Codigo Fiscal
				AADD(xICM_PROD  ,Iif(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
				AADD(xCOD_TRIB  ,SD1->D1_CLASFIS)			
				IF xDESC_NF <> 0
					AADD(xPRE_TAB ,SD1->D1_VUNIT)
				END IF
				dbskip()
			enddo

			xUNID_PRO :={} 								 // Unidade do Produto
			xDESC_PRO :={} 								 // Descricao do Produto
			xMEN_POS  :={} 								 // Mensagem da Posicao IPI
			xDESCRICAO:={} 								 // Descricao do Produto
			//xMEN_TRIB :={} 								 // Mensagens de Tributacao
			xCLAS_FIS :={} 								 // Classificacao Fiscal		
			xCOD_FIS  :={} 								 // Cogigo Fiscal
			xISS	  :={} 								 // Aliquota de ISS
			xTIPO_PRO :={} 								 // Tipo do Produto
			xLUCRO	  :={} 								 // Margem de Lucro p/ ICMS Solidario
			xCLFISCAL :={}
			xSUFRAMA  :=""
			xCALCSUF  :=""

			for I:=1 to Len(xCOD_PRO)

				dbSelectArea("SB1")
				dbSeek(xFilial()+xCOD_PRO[I])

				/*
				wsCodTrib := SB1->B1_ORIGEM

				If xTES[I] $ "519_597_596_549"
				wsCodTrib := "041"
				EndIf

				If xTES[I] $ "507_992_587"
				wsCodTrib := "040"
				EndIf

				If xTES[I] $ "896_970"
				wsCodTrib := "050"
				EndIf

				If Alltrim(xTES[I]) $ "572" //Solidario
				wsCodTrib := "010"
				EndIf
				*/

				AADD(xDESC_PRO , SB1->B1_DESC)
				AADD(xUNID_PRO , SB1->B1_UM)  

				//AADD(xCOD_TRIB , wsCodTrib)

				//if Ascan(xMEN_TRIB , SB1->B1_ORIGEM)==0
				//	AADD(xMEN_TRIB  , SB1->B1_ORIGEM)
				//endif

				AADD(xDESCRICAO , SB1->B1_DESC)
				AADD(xMEN_POS	 , SB1->B1_POSIPI)

				if SB1->B1_ALIQISS > 0
					AADD(xISS , SB1->B1_ALIQISS)
				endif

				AADD(xTIPO_PRO , SB1->B1_TIPO)
				AADD(xLUCRO 	, SB1->B1_PICMRET)

				AADD(xCLAS_FIS , SB1->B1_CLASFIS)
				AADD(xCLFISCAL , SB1->B1_POSIPI)
			next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa da Condicao de Pagto				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE4")                    // Condicao de Pagamento
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+xCOND_PAG)
			xDESC_PAG := SE4->E4_DESCRI

			if xTIPO$"D,B"

				dbSelectArea("SA1")                // * Cadastro de Clientes
				dbSetOrder(1)
				dbSeek(xFilial()+xFORNECE)

				xCOD_CLI := SA1->A1_COD 				// Codigo do Cliente
				xNOME_CLI:= SA1->A1_NOME				// Nome
				xEND_CLI := SA1->A1_END 				// Endereco
				xBAIRRO	 := SA1->A1_BAIRRO 			// Bairro
				xCEP_CLI := SA1->A1_CEP 				// CEP
				xCOB_CLI := SA1->A1_ENDCOB 			// Endereco de Cobranca
				xREC_CLI := SA1->A1_ENDENT 			// Endereco de Entrega
				xMUN_CLI := SA1->A1_MUN 				// Municipio
				xEST_CLI := SA1->A1_EST 				// Estado
				xCGC_CLI := SA1->A1_CGC 				// CGC
				xINSC_CLI:= SA1->A1_INSCR				// Inscricao estadual
				xTRAN_CLI:= SA1->A1_TRANSP 			// Transportadora
				xTEL_CLI := SA1->A1_TEL 				// Telefone
				xFAX_CLI := SA1->A1_FAX 				// Fax
				cSuframa := SA1->A1_SUFRAMA
				cRegEsp  := SA1->A1_YREGESP
				cA1tipo  := SA1->A1_TIPO
			else
				dbSelectArea("SA2")                      // * Cadastro de fornecedores
				dbSetOrder(1)
				dbSeek(xFilial()+xFORNECE+xLOJA)

				xCOD_CLI :=SA2->A2_COD				      // Codigo do Cliente
				xNOME_CLI:=SUBSTR(SA2->A2_NOME,1,63)      // Nome
				xEND_CLI :=SA2->A2_END					  // Endereco
				xBAIRRO	 :=SA2->A2_BAIRRO				  // Bairro
				xCEP_CLI :=SA2->A2_CEP					  // CEP
				xCOB_CLI :=""                            // Endereco de Cobranca
				xREC_CLI :=""                            // Endereco de Entrega
				xMUN_CLI :=SA2->A2_MUN					  // Municipio
				xEST_CLI :=SA2->A2_EST					  // Estado
				xCGC_CLI :=SA2->A2_CGC					  // CGC
				xINSC_CLI:=SA2->A2_INSCR				  // Inscricao estadual
				xTRAN_CLI:=SA2->A2_TRANSP				  // Transportadora
				xTEL_CLI :=SA2->A2_TEL					  // Telefone
				xFAX	 :=SA2->A2_FAX					  // Fax
			endif

			dbSelectArea("SE1")                          // * Contas a Receber
			dbSetOrder(1)
			xPARC_DUP  :={}							  // Parcela
			xVENC_DUP  :={}							  // Vencimento
			xVALOR_DUP :={}							  // Valor
			xDUP_TOT   :=0
			xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

			while !SE1->(EOF())					  .AND.;
			(SE1->E1_NUM == xNUM_DUPLIC) .AND.;
			xDUPLICATAS

				if !("NF" $ SE1->E1_TIPO)
					dbSkip()
					Loop
				endif

				AADD(xPARC_DUP ,SE1->E1_PARCELA)
				AADD(xVENC_DUP ,SE1->E1_VENCTO)
				AADD(xVALOR_DUP,SE1->E1_VLCRUZ)
				SE1->(DbSkip())
			enddo

			dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
			dbSetOrder(1)
			dbSeek(xFilial()+xTES[1])

			xNATUREZA	 :=SF4->F4_TEXTO // Natureza da Operacao
			xNOME_TRANSP :=" "           // Nome Transportadora
			xEND_TRANSP  :=" "           // Endereco
			xMUN_TRANSP  :=" "           // Municipio
			xEST_TRANSP  :=" "           // Estado
			xVIA_TRANSP  :=" "           // Via de Transporte
			xCGC_TRANSP  :=" "           // CGC
			xTEL_TRANSP  :=" "           // Fone
			xTPFRETE 	 :=" "           // Tipo de Frete
			xVOLUME		 := 0 			  // Volume
			xESPECIE 	 :=" "           // Especie
			xPESO_LIQ	 := 0 			  // Peso Liquido
			xPESO_BRUTO  := 0 			  // Peso Bruto
			xCOD_MENS	 :=" "           // Codigo da Mensagem
			xMENSAGEM	 :=" "           // Mensagem da Nota
			xPESO_LIQUID :=" "

			Imprime()

			IncRegua()							// Termometro de Impressao
			SF1->(DbSkip())					// Passa para a proxima Nota Fiscal
			nLin := 0
		enddo
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³																 ³
	//³							 FIM DA IMPRESSAO 					 ³
	//³																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fechamento do Programa da Nota Fiscal 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SF2")
	Retindex("SF2")
	dbSelectArea("SF1")
	Retindex("SF1")
	dbSelectArea("SD2")
	Retindex("SD2")
	dbSelectArea("SD1")
	Retindex("SD1")
	Set Device To Screen

	if aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	endif

	MS_FLUSH()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³																 ³
//³						 FUNCOES ESPECIFICAS 					 ³
//³																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ VERIMP	³ Autor ³	Marcos Simidu	    ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica posicionamento de papel na Impressora			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Nfiscal													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function VerImp
Static Function VerImp()

	nLin   := 0 					// Contador de Linhas
	nLinIni:= 0

	if aReturn[5]==2
		nOpc := 1
		while .T.
			SetPrc(0,0)
			dbCommitAll()
			//@ nLin ,000 PSAY " "
			//@ nLin ,004 PSAY "*"
			//@ nLin ,022 PSAY "."
			if MsgYesNo("Fomulario esta posicionado ? ")
				nOpc := 1
			elseIF MsgYesNo("Tenta Novamente ? ")
				nOpc := 2
			else
				nOpc := 3
			endif
			Do Case
				Case nOpc==1
				lContinua:=.T.
				Exit
				Case nOpc==2
				Loop
				Case nOpc==3
				lContinua:=.F.
				Return
			EndCase
		End
	endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ IMPDET	³ Autor ³	Marcos Simidu	    ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Linhas de Detalhe da Nota Fiscal			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Nfiscal													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function IMPDET
Static Function IMPDET()

	lOCAL I

	xB_ICMS_SOL:= 0			// Base	do ICMS Solidario
	xV_ICMS_SOL:= 0			// Valor do ICMS Solidario
	nTamDet	   := 17		// Tamanho da Area de Detalhe
	// Definido: 1 linha em branco e
	// 			 1 linha de mensagem livre
	J:=1

	for I:=1 to nTamDet
		if I<= Len(xCOD_PRO)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+xCOD_PRO[I])
			IF SB1->B1_YCLASSE == '5'
				lCaco := .T.
			ENDIF

			If Mv_Par04 == 2 //NF-Saida
				If SB1->B1_YCLASSE$"1_2_3" .And. xYIMPNF[I] == "D"
					@ nLin, 006  PSAY Subs(Alltrim(xCOD_PRO[I]),1,7)+"3"
					//				cDescric   := Alltrim(xDESC_PRO[I])
					//				cDescric := Subs(cDescric,1,Len(Alltrim(cDescric))-1)
				Else
					@ nLin, 006  PSAY Alltrim(xCOD_PRO[I])+Alltrim(xLOTE[I])
					//				cDescric   := Alltrim(xDESC_PRO[I])
				EndIF
				cDescric   := Alltrim(xDESC_PRO[I])
			Else
				DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
				DbSetOrder(1)
				DbSeek(xFilial()+xTES[I])

				//Alteração realiza por bruno
				cSQL := ""
				cSQL += "SELECT TOP 1(SC6.C6_YIMPNF) as IMPNF "
				cSQL += "FROM "+ RetSqlName("SF2")+" SF2, "+ RetSqlName("SC6")+" SC6  "
				cSQL += "WHERE 	SF2.F2_FILIAL 	= '"+xFilial("SF2")+"'			AND "
				cSQL += "   	SC6.C6_FILIAL 	= '"+xFilial("SC6")+"'			AND "
				cSQL += "		SF2.F2_DOC		= '"+ Alltrim(xNUM_NFDV[I]) +"' AND "
				cSQL += "		SF2.F2_SERIE	= '"+ Alltrim(xPREF_DV[I]) +"'	AND "
				cSQL += "		SC6.C6_NUM		= F2_YPEDIDO 					AND "
				cSQL += "		SF2.D_E_L_E_T_ 	= ''							AND "
				cSQL += "		SC6.D_E_L_E_T_ 	= '' "
				If chkfile("_cTrab")
					dbSelectArea("_cTrab")
					dbCloseArea()
				EndIf
				TCQUERY cSQL ALIAS "_cTrab" NEW

				If SB1->B1_YCLASSE$"1_2_3" .And. _cTrab->IMPNF == "D"
					@ nLin, 006  PSAY Subs(Alltrim(xCOD_PRO[I]),1,7)+"3"
					cDescric := Subs(Alltrim(xDESC_PRO[I]),1,(Len( Alltrim(xDESC_PRO[I]) )-1))
					//				cDescric   := Alltrim(xDESC_PRO[I])
					//				cDescric := Subs(cDescric,1,Len(Alltrim(cDescric))-1)
				Else
					@ nLin, 006  PSAY Alltrim(xCOD_PRO[I])+Alltrim(xLOTE[I])
					cDescric   := Alltrim(xDESC_PRO[I])
				EndIF

				// bruno    @ nLin, 006  PSAY Alltrim(xCOD_PRO[I])
				// bruno    cDescric   := Alltrim(xDESC_PRO[I])
			EndIf
			@ nLin, 021	PSAY SUBST(cDescric,1,60)
			@ nLin, 079	PSAY xCLAS_FIS[I]
			@ nLin, 083	PSAY xCOD_TRIB[I]
			@ nLin, 088	PSAY xUNID_PRO[I]
			@ nLin, 094	PSAY xQTD_PRO[I]				     Picture"@E 999,999.99"

			IF xDESC_NF = 0
				@ nLin, 106	PSAY xPRE_UNI[I]				 Picture"@E 9,999,999.99"
				//@ nLin, 112	PSAY PRECO_CHEIO[I]				 Picture"@E 9999.99"    // MADALENO
				@ nLin, 125	PSAY Round(xVAL_MERC[I],2) 	     Picture"@E 9,999,999.99"
				//@ nLin, 128	PSAY Round((PRECO_CHEIO[I] * xQTD_PRO[I]),2) 	     Picture"@E 999,999.99"      // MADALENO
			ELSE
				//@ nLin, 112	PSAY xPRE_UNI[I]				 Picture"@E 9999.99"
				@ nLin, 106	PSAY xPRE_TAB[I]				 Picture"@E 9,999,999.99"    // MADALENO
				//@ nLin, 128	PSAY Round(xVAL_MERC[I],2) 	     Picture"@E 999,999.99"
				@ nLin, 125	PSAY Round((xPRE_TAB[I] * xQTD_PRO[I]),2) 	     Picture"@E 9,999,999.99"      // MADALENO
			END IF

			//@ nLin, 112	PSAY xPRE_UNI[I]				 Picture"@E 9999.99"
			//@ nLin, 112	PSAY PRECO_CHEIO[I]				 Picture"@E 9999.99"    // MADALENO
			//@ nLin, 128	PSAY Round(xVAL_MERC[I],2) 	     Picture"@E 999,999.99"
			//@ nLin, 128	PSAY Round((PRECO_CHEIO[I] * xQTD_PRO[I]),2) 	     Picture"@E 999,999.99"      // MADALENO
			@ nLin, 140	PSAY xICM_PROD[I] 				 Picture"99"
			@ nLin, 145	PSAY xIPI[I]					 Picture"99.9"
			IF SF4->F4_YIMPIPI <> "2"
				@ nLin, 154	PSAY xVAL_IPI[I]				 Picture"@E 99,999.99"
			else
				@ nLin, 154	PSAY "0,00"	//			 Picture"@E 99,999.99"
			end If
			//@ nLin, 154	PSAY xVAL_IPI[I]				 Picture"@E 99,999.99"
			J:= J + 1
		endif
		nLin := nLin + 1
	next

	@ nLin, 132  PSAY Chr(18) //Descomprime Caracter

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CLASFIS	³ Autor ³	Marcos Simidu	    ³ Data ³ 16/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Array com as Classificacoes Fiscais			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Nfiscal													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function CLASFIS
Static Function CLASFIS()

	lOCAL nCont

	@ nLin,006 PSAY "Classificacao Fiscal"
	nLin := nLin + 1
	for nCont := 1 to Len(xCLFISCAL) .AND. nCont <= 12
		nCol := if(Mod(nCont,2) != 0, 06, 33)
		@ nLin, nCol	 PSAY xCLFISCAL[nCont] + "-"
		@ nLin, nCol+ 05 PSAY Transform(xCLAS_FIS[nCont],"@R 99.99.99.99.99")
		nLin := nLin + if(Mod(nCont,2) != 0, 0, 1)
	next
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ IMPMENP	³ Autor ³	Marcos Simidu	    ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao Mensagem Padrao da Nota Fiscal					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Nfiscal													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function IMPMENP
Static Function IMPMENP()

	Local nBegin

	nCol := 28

	IF Empty(xCOD_MENS)
		DO CASE
			CASE cA1TIPO = 'F' .AND. xEst_Cli <> 'MG' .AND. ALLTRIM(cSUBTP) = 'N'
			xCOD_MENS := "028"
			CASE cA1TIPO = 'F' .AND. xEst_Cli == 'MG' .AND. ALLTRIM(cSUBTP) = 'N'
			xCOD_MENS := "027"
			CASE cA1TIPO = 'S' .AND. xEst_Cli == 'MG' .AND. cempant == "01"
			xCOD_MENS := "019"
		ENDCASE
	ENDIF

	if !Empty(xCOD_MENS)
		cDescric := Alltrim(FORMULA(xCOD_MENS))
		nLinha	:= MLCount(cDescric,54)

		@ nLin,000	PSAY Chr(15)
		@ nLin,NCol PSAY MemoLine(cDescric,54,1)
		nlin := nlin + 1
		for nBegin := 2 To nLinha
			@ nLin, NCol pSay MemoLine(cDescric,54,nBegin)
			nlin := nlin + 1
		next
		@ nLin,080 PSAY Chr(18)
	endif

	if (mv_par04 == 2) .AND. (xDESCONT > 0)
		@ nLin, NCol pSay "DESCONTO CONCEDIDO: "+Transform(xDESC_NF,"@E 999,999,999.99")
		nlin := nlin + 1
	endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ DUPLIC	³ Autor ³	Marcos Simidu	    ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Parcelamento das Duplicacatas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Nfiscal													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function DUPLIC
Static Function DUPLIC()

	Local BB

	nCol1   := 8
	nCol2   := 21
	nCol3   := 35
	nCol4   := 47
	nCol5   := 61
	nCol6   := 74
	nCol7   := 87
	nCol8   := 5
	nAjuste := 0
	IF xCOND_PAG = '400' .OR.  xCOND_PAG = '900'  .OR.  xCOND_PAG = '000'  .OR.  xCOND_PAG = '208' //VERIFICANDO SE A CONDICAO DE PAGAMENTO E ANTECIPADA.
		@ nLin, nCol2		PSAY "ANTECIPADA"
		nLin := nLin + 2
		RETURN
	END IF

	if xDUPLICATAS==.T.
		@ nLin, nCol1		PSAY xNUM_DUPLIC + " " + xPARC_DUP[1]
	endif

	if xDUPLICATAS == .T.
		@ nLin, nCol2 PSAY IIF(Len(xVALOR_DUP)>=1,xVALOR_DUP[1],0) Picture("@E 9,999,999.99")
		@ nLin, nCol3 PSAY IIF(Len(xVALOR_DUP)>=1,xVENC_DUP[1]," ")
		@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=2,xVALOR_DUP[2],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=2,xVENC_DUP[2]," ")
		@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=3,xVALOR_DUP[3],0) Picture("@E 9,999,999.99")
		@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=3,xVENC_DUP[3]," ")
		nLin := nLin + 2

		for BB := 1 TO Len(xVALOR_DUP)
			xDUP_TOT := xDUP_TOT + xVALOR_DUP[BB]
		next

		@ nLin, NCol8 PSAY xDUP_TOT Picture("@E 9,999,999.99")
		@ nLin, nCol2 PSAY IIF(Len(xVALOR_DUP)>=4,xVALOR_DUP[4],0) Picture("@E 9,999,999.99")
		@ nLin, nCol3 PSAY IIF(Len(xVALOR_DUP)>=4,xVENC_DUP[4]," ")
		@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=5,xVALOR_DUP[5],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=5,xVENC_DUP[5]," ")
		@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=6,xVALOR_DUP[6],0) Picture("@E 9,999,999.99")
		@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=6,xVENC_DUP[6]," ")
	endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ IMPRIME	³ Autor ³	Marcos Simidu	    ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Nota Fiscal de Entrada e de Saida				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico RDMAKE											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Imprime
Static Function Imprime()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³															     ³
	//³				  IMPRESSAO DA N.F. DA Nfiscal				     ³
	//³															     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Canhoto da N.F.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetPrc(0,0) 										// (Zera o formulario)
	@ 00, 000 PSAY chr(27)+"C"+chr(78)
	@ 00, 000 PSAY Chr(18)								// Descompressao de Impressao
	@ 02, 083 PSAY Chr(27)+Chr(14)+xNUM_NF+Chr(18)	    // Numero da Nota Fiscal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Cabecalho da N.F.	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 06, 084 PSAY Chr(27)+Chr(14)+xNUM_NF+Chr(18)	// Numero da Nota Fiscal

	if mv_par04 == 1
		@ 08, 074 PSAY "X"
	else
		@ 08, 066 PSAY "X"
	endif

	//Imprime Novo Numero da Biancogres e Incesa
	//If cempant == "01"
	//	//@ 10, 003 PSAY "NOVO TEL:(27)3421-9000"
	//ElseIf cempant == "05"
	//	@ 10, 045 PSAY "XXXXXXXXXXXXXX"
	//	@ 11, 038 PSAY "NOVO TEL:(27)3421-9100"
	//EndIf

	@ 13, 003 PSAY xNATUREZA					// Texto da Natureza de Operacao
	@ 13, 040 PSAY xCF[1] Picture"@R 9.999"     // Codigo da Natureza de Operacao

	//FOI DESABILITADO PARTE ROTINA QUE CALCULA ICMS SUBSTITUICAO PARA MG COM FRETE AUTONOMO CANCELAMENTO INSCRICAO EM MG - Ranisses em 30/09/07
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Inscr. Subst. Tribut.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(xTIPO_CLI) == "S" .AND. SF2->F2_EST == "MG"  .And. cempant == "01" //Solidario //Alterado por Ranisses no dia 27/02/09, com inicio no dia 02/03/09, para faturamento ST no Estado de SP para as empresas Biancogres e Incesa
		//	//@ 13, 050 PSAY "EM ANDAMENTO"     // Imprime Inscricao Substituicao Tributario
		@ 13, 048 PSAY "055364339.00-69"  // Imprime Inscricao Substituicao Tributario
		//	@ 13, 048 PSAY "001.066689.0005"  // Imprime Inscricao Substituicao Tributario
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao dos Dados do Cliente		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 16, 003 PSAY Alltrim(xNOME_CLI)+"   "+xCOD_CLI      // Nome do Cliente

	if !EMPTY(xCGC_CLI)										// Se o C.G.C. do Cli/forn nao for Vazio
		if Subs(xCGC_CLI,12,1) == " "
			@ 16, 066 PSAY xCGC_CLI Picture "@R 999.999.999-99"
		else
			@ 16, 066 PSAY xCGC_CLI Picture "@R 99.999.999/9999-99"
		endif
	else
		@ 16, 066 PSAY " "                                 // Caso seja vazio
	endif

	@ 16, 086 PSAY xEMISSAO 								// Data da Emissao do Documento
	@ 18, 003 PSAY SUBSTR(ALLTRIM(xEND_CLI),1,45)			// Endereco
	@ 18, 050 PSAY xBAIRRO						   			// Bairro
	@ 18, 074 PSAY xCEP_CLI Picture"@R 99999-999"           // CEP

	if mv_par04 == 2 .And. !Empty(SF2->F2_YDES)
		@ 18, 086 PSAY SF2->F2_YDES        				// Reservado  p/Data Saida/Entrada
	endif

	@ 20, 003 PSAY xMUN_CLI 								// Municipio
	@ 20, 046 PSAY xTEL_CLI 								// Telefone/FAX
	@ 20, 063 PSAY xEST_CLI 								// U.F.
	@ 20, 068 PSAY xINSC_CLI								// Insc. Estadual
	@ 20, 088 PSAY SF2->F2_YHES							// Reservado p/Hora da Saida

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Data e Hora da Saida			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF MV_PAR04 == 2
		DbSelectArea("SF2")
		Do while !RecLock("SF2",.F.);enddo
		SF2->F2_YIMPRIM = "S"
		//SF2->F2_YDES := DATE()
		//SF2->F2_YHES := SUBS(TIME(),1,5)
		MsUnLock()
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Fatura/Duplicata		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par04 == 2
		nLin := 23
		BB   := 1
		nCol := 04				                            // duplicatas
		DUPLIC()
	else
		nLin := 23
		BB   := 1
		nCol := 04
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os itens da NF.				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ nLin, 000  PSAY Chr(15) //Comprime Caracter
	nLin := 29

	ImpDet()

	//FAZENDO IMPRIMIR AS CONDIÇÕES DE PAGAMENYO
	//nlin := nlin + 1
	@ nLin, 000  PSAY Chr(15)
	IF Len(xVALOR_DUP)>6
		@ nLin, 2  PSAY " ---------------------------- INFORMACOES --------------------------------------------------------------------------- DUPLICATAS --------------------------------"
	End if
	nlin := nlin + 1
	nCol4   := 99  // 99   14
	nCol5   := 113
	nCol6   := 127
	nCol7   := 141


	if mv_par04 == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o pedido de venda.												 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//@ 42, 03 PSAY "PV NR " + cPedant picture "@X"

		//if Len(AllTrim(cPcant)) > 0
		//@ 42, 16 PSAY "PC NR " + cPcant  picture "@X"
		//endif

		if Len(AllTrim(cSuframa)) > 0
			@ nLin, 04 PSAY "SUFRAMA " + cSuframa picture "@X"
			//nLin := nlin + 1
		endif
	endif

	If Len(xVALOR_DUP)>=7
		@ nLin, nCol4 -2 PSAY "G-" ;	@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=7,xVALOR_DUP[7],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=7,xVENC_DUP[7]," ")
	end if

	if Len(xVALOR_DUP)>=8
		@ nLin, nCol6 -2 PSAY "H-" ;	@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=8,xVALOR_DUP[8],0) Picture("@E 9,999,999.99")
		@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=8,xVENC_DUP[8]," ")
	end if

	if Len(AllTrim(cSuframa)) > 0
		nlin := nlin + 1
	ELSEIf Len(xVALOR_DUP)>=7
		nlin := nlin + 1
	END IF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime frete de autonomo.											     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if ! Empty(xICMAUTO)
		@ nLin, 03 PSAY "ART 220 DO DEC 1090-R DE 25/10/02 O RICMS/ES"
		//nLin := nlin + 1
	END IF

	If Len(xVALOR_DUP)>=9
		@ nLin, nCol4 -2 PSAY "I-" ;	@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=9,xVALOR_DUP[9],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=9,xVENC_DUP[9]," ")
	END IF

	If Len(xVALOR_DUP)>=10
		@ nLin, nCol6 -2 PSAY "J-" ;	@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=10,xVALOR_DUP[10],0) Picture("@E 9,999,999.99")
		@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=10,xVENC_DUP[10]," ")
	END IF

	if ! Empty(xICMAUTO)
		nLin := nlin + 1
	ELSEIf Len(xVALOR_DUP)>=9
		nLin := nlin + 1
	END IF

	if ! Empty(xICMAUTO)
		@ nLin, 03 PSAY "Resp.Frete: "+Iif(SC5->C5_TPFRETE == "C","REMETENTE ","ADQUIRENTE ")+"Recolh.: REMETENTE"
		//nLin := nlin + 1
	endif

	If Len(xVALOR_DUP)>=11
		@ nLin, nCol4 -2 PSAY "L-" ;	@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=11,xVALOR_DUP[11],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=11,xVENC_DUP[11]," ")
	END IF

	If Len(xVALOR_DUP)>=12
		@ nLin, nCol6 -2 PSAY "M-" ;	@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=12,xVALOR_DUP[12],0) Picture("@E 9,999,999.99")
		@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=12,xVENC_DUP[12]," ")
	END IF

	if ! Empty(xICMAUTO)
		nLin := nlin + 1
	ELSEIf Len(xVALOR_DUP)>=11
		nLin := nlin + 1
	END IF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino da impressao do pedido de venda. 							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par04 == 2
		if nDesczfr #0
			//nLin := nlin + 1
			//Alterado dia 29/11/08 e devera ser tratato com a contabilidade. 
			If xtes[1] $ '587/5I7' 
				//If xtes[1] == "508"				
				@ nLin, 03 PSAY "DESCONTO CONCEDIDO REFERENTE ICMS "+TRANS(nDesczfr,"@E 99,999.99")
			Else
				//@ nLin, 03 PSAY "DESCONTO CONCEDIDO REFERENTE ICMS/PIS/COFINS "+TRANS(nDesczfr,"@E 99,999.99")
				if SF4->F4_PISCOF = "3" .AND. SF4->F4_PISCRED = "4"
					//@ nLin, 03 PSAY "DESCONTO CONCEDIDO REFERENTE ICMS/PIS/COFINS "+TRANS(nDesczfr,"@E 99,999.99")
					//nLin ++
					@ nLin, 03 PSAY "DESCONTO ICMS: "+TRANS(ROUND((nDesczfr *12) / 21.25,2),"@E 99,999.99") + "           //  DESCONTO PIS/COFINS: "+TRANS( nDesczfr - ROUND((nDesczfr *12) / 21.25,2) ,"@E 99,999.99")
				else
					@ nLin, 03 PSAY "DESCONTO CONCEDIDO REFERENTE ICMS/PIS/COFINS "+TRANS(nDesczfr,"@E 99,999.99")
				end if
			EndIf
		endif
	endif

	If Len(xVALOR_DUP)>=13
		@ nLin, nCol4 -2 PSAY "N-" ;	@ nLin, nCol4 PSAY IIF(Len(xVALOR_DUP)>=13,xVALOR_DUP[13],0) Picture("@E 9,999,999.99")
		@ nLin, nCol5 PSAY IIF(Len(xVALOR_DUP)>=13,xVENC_DUP[13]," ")
	ENDIF

	IF xDESC_NF = 0
		If Len(xVALOR_DUP)>=14
			@ nLin, nCol6 -2 PSAY "O-" ;	@ nLin, nCol6 PSAY IIF(Len(xVALOR_DUP)>=14,xVALOR_DUP[14],0) Picture("@E 9,999,999.99")
			@ nLin, nCol7 PSAY IIF(Len(xVALOR_DUP)>=14,xVENC_DUP[14]," ")
		ENDIF
	ELSE
		@ nLin, nCol6 -2 PSAY "DESCONTO INCONDICIONAL" + TRANSFORM(xDESC_NF,"@E 99,999.99")
	ENDIF
	if mv_par04 == 2 .AND. nDesczfr #0
		nLin := nlin + 1
	ELSEIf Len(xVALOR_DUP)>=13
		nLin := nlin + 1
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino da impressao de frete de autonomo.							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(xICMAUTO)
		@ nLin, 03 PSAY "Base de Calculo: R$ "+"     " + TRANS(xFRETAUT,"@E 999,999.99")
		@ nLin, 40 PSAY "  /  Aliquota: 12% - ICMS: R$ "    + TRANS(xICMAUTO,"@E 999,999.99")	
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino da impressao de Registro Especial do Cliente de MG.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(cRegEsp) .AND. cempant == "07"
		nLin := nlin + 1
		@ nLin, 03 PSAY "Destinatario detentor de Regime Especial em Minas Gerais conf. N. RE/PTA: " +Alltrim(cRegEsp)
	endif

	if mv_par04 == 2
		nTamObs := 150
		nLin := nlin + 1
		@ nLin, 20 PSAY UPPER(SUBSTR(xMENSAGEM,01,nTamObs))		// Imprime Mensagem de Observacao
	endif

	@ nLin, 132  PSAY Chr(18) //Descomprime Caracter

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo dos Impostos			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SF4->F4_YIMPICM <> '2'
		@ 53, 07  PSAY xBASE_ICMS	Picture"@E 999,999,999.99"  // Base do ICMS
		@ 53, 24  PSAY xVALOR_ICMS  Picture"@E 999,999,999.99"  // Valor do ICMS
		@ 53, 44  PSAY xBSICMRET	Picture"@E 999,999,999.99"  // Base ICMS Ret.
		@ 53, 60  PSAY xICMS_RET	Picture"@E 999,999,999.99"  // Valor  ICMS Ret.
	ENDIF

	If Alltrim(xtipo) == "I"
		@ 53, 80  PSAY 0 Picture"@E 999,999,999.99"         // Valor Tot. Prod.
	Else
		@ 53, 80  PSAY (xVALOR_MERC + xDESC_NF) Picture"@E 999,999,999.99"  // Valor Tot. Prod.
	EndIf
	@ 55, 07  PSAY xFRETE		Picture"@E 999,999,999.99"  // Valor do Frete
	@ 55, 24  PSAY xSEGURO		Picture"@E 999,999,999.99"  // Valor Seguro

	if mv_par04 == 2
		@ 55, 44 PSAY xDESPESA Picture"@E 999,999,999.99"   // Outras despesas acessorias
	endif

	If Alltrim(SF2->F2_EST) == "EX"
		@ 55, 60  PSAY xVALOR_IPI	Picture"@E 999,999,999.99"  // Valor do IPI
		@ 55, 80  PSAY (xTOT_FAT + xFRETE + xSEGURO) 	Picture"@E 999,999,999.99"  // Valor Total NF
	else
		IF SF4->F4_YIMPIPI == '2'
			@ 55, 60  PSAY "0,00"	 //			 Picture"@E 99,999.99"
			@ 55, 80  PSAY xTOT_FAT 	Picture"@E 999,999,999.99"  // Valor Total NF
		else
			@ 55, 60  PSAY xVALOR_IPI	Picture"@E 999,999,999.99"  // Valor do IPI
			@ 55, 80  PSAY xTOT_FAT 	Picture"@E 999,999,999.99"  // Valor Total NF
		end if
	end if

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao Dados da Transportadora  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 58, 003  PSAY xNOME_TRANSP						      // Nome da Transport.

	if xTPFRETE=="C"                                         // Frete por conta do
		@ 58, 059 PSAY "1"                                   // Emitente (1)
	else													  // 	 ou
		@ 58, 059 PSAY "2"                                   // Destinatario (2)
	endif

	if mv_par04 == 2
		@ 58, 063 PSAY xPLACA	Picture"@R XXX-9999"         // Res. p/Placa do Veiculo
		@ 58, 073 PSAY xUFPLACA 							 // Res. p/xEST_TRANSP								  // U.F.
	endif

	if !EMPTY(xCGC_TRANSP)									 // Se C.G.C. Transportador nao for Vazio
		if Subs(xCGC_CLI,12,1) == " "
			@ 58, 076 PSAY xCGC_TRANSP Picture"@R 999.999.999-99"
		else
			@ 58, 076 PSAY xCGC_TRANSP Picture"@R 99.999.999/9999-99"
		endif
	else
		@ 58, 076 PSAY " "                                  // Caso seja vazio
	endif

	if mv_par04 == 2
		@ 60, 003 PSAY xEND_TRANSP 							 // Endereco Transp.
		@ 60, 050 PSAY xMUN_TRANSP 							 // Municipio
		@ 60, 073 PSAY xEST_TRANSP 							 // U.F.
		@ 60, 079 PSAY xINSC_EST							 // Reservado p/Insc. Estad.
		@ 62, 005 PSAY xVOLUME	 Picture"@E 999,999"         // Quant. Volumes
		IF lCaco
			@ 62, 014 PSAY "VOLUMES" Picture"@!"                 // Especie
			@ 62, 029 PSAY " "   								 // Res para Marca
		ELSE
			@ 62, 014 PSAY xESPECIE  Picture"@!"                 // Especie
			@ 62, 029 PSAY xMARCA								 // Res para Marca
		ENDIF
		@ 62, 048 PSAY xNUMERO								 // Res para Numero
		@ 62, 069 PSAY xPBRUTO	 Picture"@E 999,999.99"      // Res para Peso Bruto
		@ 62, 084 PSAY xPLIQUI	 Picture"@E 999,999.99"      // Res para Peso Liquido
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Final da Nota Fiscal				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nLin:=65
	if Len(xNUM_NFDV) > 0  .and. !Empty(xNUM_NFDV[1])
		If xtes[1] $ '557/5F7'
			@ nLin, 015 PSAY "Complem ICMS ref.NF Orig. " + "  " + xNUM_NFDV[1] + "  " + xPREF_DV[1]
		Else
			@ nLin, 015 PSAY "Nota Fiscal Original No." + "  " + xNUM_NFDV[1] + "  " + xPREF_DV[1]
		EndIf
		nLin := nLin + 1
	endif

	//Imprime Classificacao Fiscal - MELHORAR ROTINA
	If cempant == "07"
		@ nLin, 015 PSAY "A - 6908.90.00"
		nLin := nLin + 1
	EndIf

	nLin := nLin + 1

	IF xCF[1] = "6923" .OR. xCF[1] = "6523"  .OR. xCF[1] = "5923" .OR. xCF[1] = "5116" .OR. xCF[1] = "6116"
		@ 065, 018 PSAY "Valor do IPI: "  Picture"@!"
		@ 065, 035  PSAY xVALOR_IPI	    Picture"@E 999,999,999.99"  // Valor do IPI
	end if

	ImpMenp()												// Imprime Mensagem Padrao da Nota Fiscal

	npElem := ascan(xCLAS_FIS , "F")
	if npElem > 0
		@ 71, 36 PSAY Chr(15)+xCLFISCAL[npElem]
		@ 71, 80 PSAY Chr(18)
	endif

	npElem := ascan(xCLAS_FIS , "G")
	if npElem > 0
		@ 72, 36 PSAY Chr(15)+xCLFISCAL[npElem]
		@ 72, 80 PSAY Chr(18)
	endif

	npElem := ascan(xCLAS_FIS , "H")
	if npElem > 0
		@ 73, 36 PSAY Chr(15)+xCLFISCAL[npElem]
		@ 73, 80 PSAY Chr(18)
	endif

	@ 78, 00 PSAY Chr(18)								  // Descompressao de Impressao
	@ 78, 00 PSAY chr(27)+"C"+chr(66)
Return
