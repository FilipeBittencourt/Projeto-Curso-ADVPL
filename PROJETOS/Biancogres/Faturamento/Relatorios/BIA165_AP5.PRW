#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/
#include "relato.ch"
#include "topconn.ch"
#include "buttom.ch"

user function BIA165()

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao basica.                                                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,CQUERY,CWHERE")
	SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP,CTIPO")
	SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
	SetPrvt("ARETURN,ACAMPOS")
	SetPrvt("NCRCCONTROL,NL,NTOTREGS")

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao particular.                                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	SetPrvt("CCLI,CPROD,CPERGUNTA,CCLIENTES")
	SetPrvt("ACLIENTES")
	SetPrvt("NQTDM2,NTOTVEND,NQTDM2CLI,NTOTVENDCLI,NQTDM2GER,NTOTVENDGER,NI")

	/*/
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � BIA165   � Autor � Cesar Magnago         � Data � 28/01/02 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇚o � Relatorio de Estatistica de Vendas (Cli x Prod) New        낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇쿢so       � Faturamento                                                낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inicializa variaveis                                                     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cDesc1     := "Este programa ira emitir um Relatorio de Estatistica de Vendas de"
	cDesc2     := "(Clientes x Produto) conforme parametros solicitados."
	cDesc3     := ""
	cTamanho   := "M"
	cAlias     := "SF2"
	aReturn    := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	cNomeprog  := "BIA165"
	nCbCont	  := 0
	cCbTxt	  := space(10)
	m_pag      := 1
	aOrd       := { }
	lGravParam := .F.
	lPodeComp  := .T.
	lTemDic	  := .F.
	lGravParam := .F.
	nL         := 80
	nLimite    := 132
	nLastKey   := 0
	cTitulo    := "Relatorio de Estatistica de Vendas (Cliente x Produto)"
	lRodape    := .F.
	lContinua  := .T.
	aClientes  := {}

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Exibe janela padrao de relatorios                                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
	if lastkey()==27 .OR. nLastKey==27
		Return
	endif

	Pergunte(cNomeProg,lGravParam)
	SetDefault(aReturn, cAlias)
	if lastkey()==27 .OR. nLastKey==27
		Return
	endif

	nCrcControl := IIF(aReturn[4]==1,15,18)
	cCabec1     := "CLIENTE  RAZAO SOCIAL                                                                                                        "
	cCabec2     := "PRODUTO                                       N.FISCAL   EMISSAO         QUANTIDADE  PRECO UNITARIO           TOTAL  VENDEDOR"
	//              XXXXXXXXXXXXXXX                                  XXXXXX/S1    XX/XX/XXXX   X.XXX.XXX,XX       XXX,XX      XXX.XXX,XX   XXXXXX
	//              0                                                49     56    62 65 68     75                 94          106          119

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Aceita par긩etros e faz ajustes necess쟲ios.                           �
	//쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
	//� mv_par01 � Do  Cliente                                                 �
	//� mv_par02 � Ate Cliente                                                 �
	//� mv_par03 � Da  Emissao                                                 �
	//� mv_par04 � Ate Emissao                                                 �
	//� mv_par05 � Do  Produto                                                 �
	//� mv_par06 � Ate Produto                                                 �
	//� mv_par07 � Do  Vendedor                                                �
	//� mv_par08 � Ate Vendedor                                                �
	//� mv_par09 � Utilizar Arq. de Selecao de Clientes (\SIGAADV\SELCLI.TXT)  �
	//� mv_par10 � Inclui Devolucao                                            �
	//읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Pede que o usuario digite a selecao de produtos caso ele opte por este...�
	//� parametro.                                                               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if MV_PAR09 == 1
		lOk       := .T.
		cClientes := ""
		do while lOk
			@ 000,000 TO 150,350 DIALOG oDialog TITLE "Selecao"
			@ 005,005 SAY "DIGITE CADA CLIENTE QUE DESEJA SEPARANDO POR VIRGULA"
			@ 020,005 GET cClientes SIZE 130,050 MEMO
			@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
			ACTIVATE DIALOG oDialog CENTERED
		enddo
		if len(aClientes) == 0
			cMsg := ""
			cMsg += "O parametro 'SELECIONAR CLIENTES' esta configurado como 'SIM', "+chr(13)
			cMsg += "portanto, se faz necessario a digitacao dos clientes no quadro "+chr(13)
			cMsg += "anterior."
			alert(cMsg)
			return
		endif
	endif

	Processa({|| fImprime() })

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Libera impressao.												                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if nTotRegs >= 0
		if aReturn[5] == 1
			set printer to
			OurSpool(cNomeArq)
		endif

		Ft_PFlush()
	endif
Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽굇
굇� fImprime   � Imprime o relatorio                                      낢굇
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function fImprime()

	LOcal nI

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Testa a existencia e quantidade de dados na condicao estabelecida pelo...�
	//� usuario.                                                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cQuery  := ""
	cWhere1 := ""
	cQuery  += "SELECT COUNT(SF2.F2_DOC) AS TOTREGS "
	cWhere1 += "FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SF4")+" SF4, "+RetSQLName("SA1")+" SA1 "
	cWhere1 += "WHERE "
	cWhere1 += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	do case && UTILIZA/NAO UTILIZA selecao aleatoria de clientes
		case MV_PAR09 == 1; cWhere1 += "SF2.F2_CLIENTE IN ("+cClientes+") AND "
		case MV_PAR09 == 2; cWhere1 += "SF2.F2_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	endcase
	cWhere1 += "SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
	cWhere1 += "SF2.F2_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	if MV_PAR10 == 2 && NAO inclui devolucoes
		cWhere1 += "SF2.F2_DOC+SF2.F2_SERIE NOT IN (SELECT DISTINCT SD1.D1_NFORI+SD1.D1_SERIORI FROM "+RetSQLName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_NFORI = SF2.F2_DOC AND SD1.D1_SERIORI = SF2.F2_SERIE AND SD1.D1_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D_E_L_E_T_ =  '') AND "
	endif
	cWhere1 += "SF2.D_E_L_E_T_ = '' AND "
	cWhere1 += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
	cWhere1 += "SD2.D2_DOC = SF2.F2_DOC AND "
	cWhere1 += "SD2.D2_SERIE = SF2.F2_SERIE AND "
	cWhere1 += "SD2.D2_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	cWhere1 += "SD2.D_E_L_E_T_ = '' AND "
	cWhere1 += "SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND "
	cWhere1 += "SF4.F4_CODIGO = SD2.D2_TES AND "
	cWhere1 += "SF4.F4_DUPLIC = 'S' AND "
	cWhere1 += "SF4.F4_ESTOQUE = 'S' AND "
	cWhere1 += "SF4.D_E_L_E_T_ = '' AND "
	cWhere1 += "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
	cWhere1 += "SA1.A1_COD = SF2.F2_CLIENTE AND "
	cWhere1 += "SA1.A1_LOJA = SF2.F2_LOJA AND "
	cWhere1 += "SA1.D_E_L_E_T_ =  '' "
	cQuery  += cWhere1
	TcQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Abre a query com os campos selecionado abaixo.                           �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cQuery  := ""
		cQuery  += "SELECT "
		cQuery  += "SF2.F2_DOC, "
		cQuery  += "SF2.F2_CLIENTE, "
		cQuery  += "SF2.F2_LOJA, "
		cQuery  += "SF2.F2_SERIE, "
		cQuery  += "SF2.F2_EMISSAO, "
		cQuery  += "SF2.F2_YAGREG, "
		cQuery  += "SF2.F2_YDES, "
		cQuery  += "SF2.F2_TIPO, "
		cQuery  += "SF2.F2_VEND1, "
		cQuery  += "SD2.D2_COD, "
		cQuery  += "SD2.D2_ITEM, "
		cQuery  += "SD2.D2_DOC, "
		cQuery  += "SD2.D2_SERIE, "
		cQuery  += "SD2.D2_QUANT, "
		cQuery  += "SD2.D2_PRCVEN, "
		cQuery  += "SD2.D2_TOTAL, "
		cQuery  += "SD2.D2_TES, "
		cQuery  += "SF4.F4_CODIGO, "
		cQuery  += "SF4.F4_DUPLIC, "
		cQuery  += "SF4.F4_ESTOQUE, "
		cQuery  += "SA1.A1_NOME "
		cQuery  += cWhere1
		cQuery  += "ORDER BY "
		cQuery  += "SF2.F2_CLIENTE, "
		cQuery  += "SD2.D2_COD "
		TcQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Inicializa os totalizadores gerais.                                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		nQtdM2Ger   := 0
		nTotVendGer := 0
		do while !QRY->(EOF())

			Incproc("Imprimindo (Faturamentos)...")

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica o cancelamento da impressao pelo usuario.                       �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If Interrupcao(@lAbortPrint)
				Return
			Endif

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Imprime parametros.                                                      �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if m_pag == 1
				cOldAlias := Alias()
				DBSelectArea("SX1")
				DBSetOrder(1)

				if SX1->(DBSeek(cNomeProg+"01"))
					do while SX1->X1_GRUPO == cNomeProg
						if nL >= 65
							nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
						endif

						cPergunta := ""
						do case
							case SX1->X1_GSC == "C"
							do case
								case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
								case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
								case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
								case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
								case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
							endcase

							case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
						endcase

						cLinDeImp := ""
						cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+cPergunta
						@ nL,000 PSay cLinDeImp
						nL+=2

						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
						//� Imprime a relacao dos produtos desejados.                                �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
						if (MV_PAR09 == 1) .AND. (SX1->X1_ORDEM == "09") && Usa selecao de clientes
							cPergunta := ""
							for nI := 1 to len(aClientes)+1
								if (len(cPergunta) < 88) .AND. (nI <= len(aClientes))
									cPergunta := cPergunta + iif(!empty(cPergunta),", ","") + aClientes[nI]
								else
									if nI < len(aClientes)
										cPergunta := cPergunta + ","
									endif
									cLinDeImp := ""
									cLinDeImp += space(35) + cPergunta
									@ nL,000 PSay cLinDeImp
									nL++
									cPergunta := "" + iif(nI <= len(aClientes),aClientes[nI],"")
								endif
							next
							nL++
						endif
						SX1->(DBSkip())
					enddo
				endif
				DBSelectArea(cOldAlias)
				nL := 99
			endif

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do cabecalho.												              �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if nL >= 65
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
			endif

			cDados := ""
			cDados += QRY->F2_CLIENTE+"/"+QRY->F2_LOJA+" - "+QRY->A1_NOME
			@nL,000 PSay cDados
			nL++
			nL++

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Grava o codigo do cliente atual e inicializa os seus totalizadores.      �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cCli        := QRY->F2_CLIENTE
			nQtdM2Cli   := 0
			nTotVendCli := 0

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Processa o cliente atual.                                                �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			do while cCli == QRY->F2_CLIENTE

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Grava o codigo do produto atual e inicializa os seus totalizadores.      �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				cProd    := QRY->D2_COD
				nQtdM2   := 0
				nTotVend := 0

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Processa todas as ocorrencias do produto atual com o cliente atual.      �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				do while cProd == QRY->D2_COD .AND. cCli == QRY->F2_CLIENTE

					IncProc("Processando NF-Saida Nr "+QRY->F2_DOC+" ...")

					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//� Impressao do cabecalho.												              �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					if nL >= 65
						nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
					endif
					cDados := ""
					cDados += padr(QRY->D2_COD,44) + space(02)
					cDados += padr(QRY->F2_DOC+"/"+QRY->F2_SERIE,09)+space(02)
					cDados += padr(dtoc(u_stod(QRY->F2_EMISSAO)),10)+space(02)
					cDados += u_rtoc(QRY->D2_QUANT,"@E 999,999,999.99")+space(06)
					cDados += u_rtoc(QRY->D2_PRCVEN,"@E 999,999.99")+space(02)
					cDados += u_rtoc(QRY->D2_TOTAL,"@E 999,999,999.99")+space(02)
					cDados += QRY->F2_VEND1
					@nL,000 PSay cDados
					nL++

					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//� Incrementa totais.         								                       �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					nQtdM2      += QRY->D2_QUANT
					nTotVend    += QRY->D2_TOTAL
					nQtdM2Cli   += QRY->D2_QUANT
					nTotVendCli += QRY->D2_TOTAL
					nQtdM2Ger   += QRY->D2_QUANT
					nTotVendGer += QRY->D2_TOTAL


					if MV_PAR10 == 1 && Inclui Devolucoes...
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
						//� Consulta a existencia de produtos devolvidos para a NF atual.            �
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
						cQuery  := ""
						cQuery  += "SELECT D1_QUANT, D1_TOTAL "
						cQuery  += "FROM "+RetSQLName("SD1")+" SD1 "
						cQuery  += "WHERE "
						cQuery  += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
						cQuery  += "SD1.D1_NFORI = '"+QRY->F2_DOC+"' AND "
						cQuery  += "SD1.D1_SERIORI = '"+QRY->F2_SERIE+"' AND "
						cQuery  += "SD1.D1_COD = '"+QRY->D2_COD+"' AND "
						cQuery  += "SD1.D1_ITEMORI = '"+QRY->D2_ITEM+"' AND "
						cQuery  += "SD1.D1_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
						cQuery  += "SD1.D_E_L_E_T_ = ''"
						cQuery  += "ORDER BY "
						cQuery  += "SD1.D1_COD, "
						cQuery  += "SD1.D1_NFORI, "
						cQuery  += "SD1.D1_SERIORI "
						TcQuery cQuery Alias "QRY2" New

						do while !QRY2->(EOF())
							cDados := space(46)
							cDados += padr("DEV",23)
							cDados += u_rtoc(QRY2->D1_QUANT*-1,"@E 999,999,999.99")+space(18)
							cDados += u_rtoc(QRY2->D1_TOTAL*-1,"@E 999,999,999.99")+space(02)
							@nL,000 PSay cDados
							nL++

							//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
							//� Decrementa totais.         								                       �
							//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
							nQtdM2      -= QRY2->D1_QUANT
							nTotVend    -= QRY2->D1_TOTAL
							nQtdM2Cli   -= QRY2->D1_QUANT
							nTotVendCli -= QRY2->D1_TOTAL
							nQtdM2Ger   -= QRY2->D1_QUANT
							nTotVendGer -= QRY2->D1_TOTAL

							QRY2->(dbSkip())
						enddo
						QRY2->(DbCloseArea())
					endif

					QRY->(dbSkip())
				enddo

				nL++

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Impressao do cabecalho.												              �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				if nL >= 65
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
				endif

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Impressao do total do produto.					                             �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				cDados := ""
				cDados += padr("TOTAL DO PRODUTO - "+cProd,46)
				CDados += padr("-----> ",23)
				cDados += u_rtoc(nQtdM2,"@E 999,999,999.99")+space(18)
				cDados += u_rtoc(nTotVend,"@E 999,999,999.99")
				@nL,000 PSay cDados
				nL++
				nL++
			enddo

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do cabecalho.												              �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if nL >= 65
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
			endif

			cDados := ""
			cDados += padr("TOTAL DO CLIENTE - "+cCli,46)
			CDados += padr("-----> ",23)
			cDados += u_rtoc(nQtdM2Cli,"@E 999,999,999.99")+space(18)
			cDados += u_rtoc(nTotVendCli,"@E 999,999,999.99")
			@nL,000 PSay cDados
			nL++
			nL++
		enddo
		QRY->(DbCloseArea())

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Impressao do cabecalho.												              �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif

		cDados := ""
		cDados += Replicate("-",nLimite)
		@nL,000 PSay cDados
		nL++

		cDados := ""
		cDados += padr("TOTAL GERAL",46)
		CDados += padr("-----> ",23)
		cDados += u_rtoc(nQtdM2Ger,"@E 999,999,999.99")+space(18)
		cDados += u_rtoc(nTotVendGer,"@E 999,999,999.99")
		@nL,000 PSay cDados
		nL++
		cDados := ""
		cDados += Replicate("-",nLimite)
		@nL,000 PSay cDados
		nL++
	endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica a existencia de clientes que nao tiveram faturamento.           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cQuery  := ""
	cWhere2 := ""
	cQuery  += "SELECT COUNT(SA1.A1_COD) AS TOTREGS "
	cWhere2 += "FROM "+RetSQLName("SA1")+" SA1 "
	cWhere2 += "WHERE "
	cWhere2 += "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
	do case && UTILIZA/NAO UTILIZA selecao aleatoria de clientes
		case MV_PAR09 == 1; cWhere2 += "SA1.A1_COD IN ("+cClientes+") AND "
		case MV_PAR09 == 2; cWhere2 += "SA1.A1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	endcase
	cWhere2 += "SA1.A1_COD+SA1.A1_LOJA NOT IN (SELECT DISTINCT SF2.F2_CLIENTE+SF2.F2_LOJA "+cWhere1+") AND "
	cWhere2 += "SA1.D_E_L_E_T_ =  '' "
	cQuery  += cWhere2
	TcQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())
	if nTotRegs > 0
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Abre a query com os campos selecionado abaixo.                           �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cQuery  := ""
		cQuery  += "SELECT "
		cQuery  += "SA1.A1_COD,  "
		cQuery  += "SA1.A1_LOJA, "
		cQuery  += "SA1.A1_NOME  "
		cQuery  += cWhere2
		cQuery  += "ORDER BY "
		cQuery  += "SA1.A1_COD "
		TcQuery cQuery Alias "QRY" New

		nL      := 90
		cCabec1 := "----------------------- CLIENTES SEM FATURAMENTO ----------------------"
		cCabec2 := "CODIGO...  NOME                                                        "
		//XXXXXX/XX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		ProcRegua(nTotRegs)

		do while !QRY->(EOF())

			Incproc("Imprimindo (Cli. S/ Fat.)...")

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica o cancelamento da impressao pelo usuario.                       �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if Interrupcao(@lAbortPrint)
				Return
			endif

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do cabecalho.												              �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if nL >= 65
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
			endif

			cDados := ""
			cDados += QRY->A1_COD+"/"+QRY->A1_LOJA+space(02)+QRY->A1_NOME
			@nL,000 PSay cDados
			nL++

			QRY->(dbSkip())
		enddo
		QRY->(DbCloseArea())
	endif
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao    � fFinaliza  � Autor � WLADIMIR ILLIUSHENKO                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Finaliza digitacao da Selecao de Produtos                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � BIA165                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function fFinaliza()

	Local nI

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Repassa os codigos digitados para uma array.                             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aClientes := {}
	do while len(cClientes) > 0
		nPosC := at(",",cClientes)
		if nPosC > 0
			cString := substr(cClientes,1,nPosC-1)
		else
			cString := substr(cClientes,1)
		endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Remove carcteres especiais do codigo.                                    �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cClie := cString
		nI    := 1
		do while .T.
			cAux := substr(cClie,nI,1)
			if ((Asc(cAux) < 32) .OR. (Asc(cAux) > 126)) .AND. (len(cClie) > 0)
				cClie := strtran(cClie,cAux,"")
				Loop
			else
				nI := nI + 1
			endif
			if nI >= len(cClie)
				Exit
			endif
		enddo
		cClie := padl(alltrim(Upper(Alltrim(cClie))),6,"0")

		if !empty(cClie) .AND. (ASCAN(aClientes,cClie) == 0)
			AADD(aClientes,cClie)
		endif

		cClientes := substr(cClientes,len(cString)+2)
	enddo

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Repassa os codigos da array para uma variavel texto.                     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	asort(aClientes)
	cClientes := ""
	for nI := 1 to len(aClientes)
		cClientes := cClientes + "'" + aClientes[nI] + "'" + iif(nI<len(aClientes),",","")
	next

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Fecha a caixa de dialogo.                                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	lOk := .F.
	Close(oDialog)
Return
