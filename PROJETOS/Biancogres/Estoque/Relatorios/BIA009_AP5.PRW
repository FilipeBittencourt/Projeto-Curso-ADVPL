#include "rwmake.ch"
#include "topconn.ch"

User Function BIA009()
	Private nARQUIVO 	:= ""
	Private cEOL
	//���������������������������������������������������������������������Ŀ
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//�����������������������������������������������������������������������

	SetPrvt("CALIAS,LABORTPRINT,Lend,CTAMANHO,NLIMITE,CTITULO,CDESC1,AORD")
	SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,CNOMEPROG,NLASTKEY")
	SetPrvt("NL,AMESES,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1")
	SetPrvt("CSAVCOR1,CCBTXT,NCBCONT,CCABEC1,CCABEC2")
	SetPrvt("M_PAG,AORD,WNREL,ACAMPOS,_CTMP,aMes")
	SetPrvt("aAno,CTITULO2,NLOCAL,CFILIAL,CCHAVE,CPROD")
	SetPrvt("CDESCR,CTIPO,CALMOX,ASALDOS,XLOCAL,CPRODANT")
	SetPrvt("CDESCANT,CCORANT,CTIPOANT,NTOTCLASSE,NTOTCOR,NTOTREF")
	SetPrvt("NTOTFORMATO,NTOTGERAL,NTOTREGS,WOK,WPOSAT1,WPOSAT2,CNOMEREF")
	SetPrvt("CNOMECLASSE,CNOMECOR,CNOMEFORMATO,CARQTRAB")
	SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP")
	SetPrvt("CQUERY,CWHERE,CALMINI,CALMFIN")

	/*/
	�������������������������������������������������������������������������������
	���������������������������������������������������������������������������Ŀ��
	���Fun��o    � BIA009     � Autor � CESAR MAGNAGO         � Data � 23/09/99 ���
	���          �            � Alt.  � WLADIMIR ILLIUSHENKO  �      � 08/01/02 ���
	���������������������������������������������������������������������������Ĵ��
	���Descri��o � SALDO EM ESTOQUE POR PERIODO.                                ���
	���������������������������������������������������������������������������Ĵ��
	��� Uso      � Interpretador xBase                                          ���
	����������������������������������������������������������������������������ٱ�
	�������������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	/*/

	lAbortPrint := .F.
	lend        := .F.
	cTamanho    := "M"
	nLimite     := 132
	cTitulo	   := "SALDO ATUAL REF.:"
	aReturn     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha      := {}
	cNomeprog   := "BIA009"
	nLastKey    := 0
	nL          := 1
	aMeses      := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
	cDesc1	   := "Emite a posicao de saldo atual de estoque por produto e almoxarifado    "
	cDesc2	   := ""
	cDesc3	   := ""
	cAlias	   := "SB1"
	aOrd        := {" Por Produto   "}
	lGravParam  := .F.
	lPodeComp   := .T.
	lTemDic	   := .F.
	lGravParam  := .F.
	nTotRegs    := 0
	cOldAlias   := " "

	//��������������������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT.									        �
	//� Verifica Posicao do Formulario na Impressora.							        �
	//�                                          								        �
	//� Pega os valores passados como parametro: 								        �
	//� MV_PAR01 Data do saldo inicial                                           �
	//� MV_PAR02 Almoxarifado inicial                                            �
	//� MV_PAR03 Almoxarifado final                                              �
	//� MV_PAR04 Produto inicial                                                 �
	//� MV_PAR05 Produto final                                                   �
	//� MV_PAR06 Relatorio 1=Analitico 2=Sintetico                               �
	//����������������������������������������������������������������������������
	cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
	if lastkey()==27 .OR. nLastkey == 27
		Return
	endif

	Pergunte("BIA009",.F.)
	if lastkey()==27 .OR. nLastkey == 27
		Return
	endif

	SetDefault(aReturn,cAlias)
	if lastkey()==27 .OR. nLastkey == 27
		Return
	endif

	//��������������������������������������������������������������������������Ŀ
	//� Inicializa variaveis usadas no relatorio.                                �
	//����������������������������������������������������������������������������
	nL          := 80
	nCbcont	   := 1
	cCbtxt 	   := "USUARIO: "+cUserName
	m_pag 	   := 1
	nCrcControl := iif(aReturn[4]==1,15,18)
	cCabec1	   := "* Produto        Descricao                            Saldo do Periodo    Almoxfarifado                                            *"
	cCabec2	   := "*                                                                                                                                  *"
	aMes	      := MONTH(mv_par01)
	aAno	      := STR(YEAR(mv_par01),4,0)
	cTitulo2    := aMeses[aMes]
	cTitulo	   += " "+DTOC(mv_par01)
	cAlmIni     := IIF(MV_PAR02 < '01','01',IIF(MV_PAR02 > '99','99',MV_PAR02))
	cAlmFin     := IIF(MV_PAR03 < '01','01',IIF(MV_PAR03 > '99','99',MV_PAR03))

	Processa({|| fCriaTemp() })
	Processa({|| fAcumula()  })
	if nTotRegs > 0
		Processa({|| fImprime()  })
	endif
	Processa({|| fApagaTemp()})

	//��������������������������������������������������������������������������Ŀ
	//� Libera impressao.												         �
	//����������������������������������������������������������������������������
	if aReturn[5] == 1 .and. nTotRegs > 0
		set printer to
		OurSpool(cNomeArq)
	endif
	Ft_PFlush()
RETURN( NIL )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria tabela temporaria.                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FUNCTION fCriaTemp()
	aCampos := {}
	AADD(aCampos,{"PRODUTO", "C", 15, 0})
	AADD(aCampos,{"DESCR"  , "C", 30, 0})
	AADD(aCampos,{"TIPO"   , "C", 02, 0})
	AADD(aCampos,{"ALMOX"  , "C", 02, 0})
	AADD(aCampos,{"SALDO"  , "N", 14, 3})
	cArqTrab := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cArqTrab,"REL")
	DbCreateInd(cArqTrab,"PRODUTO",{||PRODUTO})
return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � fAcumula � Autor � WLADIMIR ILLIUSHENKO					  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Acumula os dados no arquivo temporario.                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fAcumula()

	Local nLocal

	//��������������������������������������������������������������������������Ŀ
	//� Verifica a existencia de registros para serem relatados                  �
	//����������������������������������������������������������������������������
	cQuery := ""
	cWhere := ""
	cQuery += "SELECT COUNT(SB1.B1_COD) AS TOTREGS "
	cWhere += "FROM "  +RetSQLName("SB1")+" SB1 "
	cWhere += "WHERE                                               "
	cWhere += "   (SB1.B1_FILIAL   = '"+xFilial("SB1")+"'                   ) AND  "
	cWhere += "   (SB1.B1_COD    BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"') AND  "        
	//Mudanca do codigo do produto
	IF DTOS(MV_PAR01) <= "20080512" 
		cWhere += "   (SB1.D_E_L_E_T_ = ''                      ) "
	ELSE
		cWhere += "   (SB1.D_E_L_E_T_ = ''                      )  AND	SB1.B1_RASTRO = 'L' "
	ENDIF

	cQuery := cQuery + cWhere
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cQuery  := ""
		cQuery  += "SELECT "
		//cQuery  += "       B1_YFORMAT+B1_YFATOR+B1_YLINHA+B1_YCLASSE AS B1_COD,  "
		cQuery  += "       B1_COD,  "
		cQuery  += "       SB1.B1_TIPO, "
		cQuery  += "       SB1.B1_DESC  "
		cQuery  := cQuery + cWhere  //+ " AND SUBSTRING(B1_COD,1,2) = 'A0' "
		TCQuery cQuery Alias "QRY" New

		//������������������������������������������������������������������������Ŀ
		//� Monta a linha da regua				                                   �
		//��������������������������������������������������������������������������
		ProcRegua(nTotRegs)

		//������������������������������������������������������������������������Ŀ
		//� Inicia o calculo para a posterior impressao 						   �
		//��������������������������������������������������������������������������

		//If Empty(cEOL)
		//    cEOL := CHR(13)+CHR(10)
		//Else
		//    cEOL := Trim(cEOL)
		//    cEOL := &cEOL
		//Endif
		//cArqTxt		:= "\PONTO\BIANCO\TESTE.TXT" // Exporta��o para conferencia se necessqario
		//nARQUIVO    := fCreate(cArqTxt) // Exporta��o para conferencia se necessqario

		While QRY->(!EOF())
			IncProc("Coletando dados...")

			cDesc := QRY->B1_DESC
			for nLocal := val(cAlmIni) TO val(cAlmFin)
				aSaldos := CalcEst(QRY->B1_COD,STRZERO(nLocal,2,0),MV_PAR01)

				if aSaldos[1] <> 0
					RecLock("REL",.T.)
					REL->PRODUTO := QRY->B1_COD
					REL->TIPO    := QRY->B1_TIPO
					REL->DESCR   := cDesc
					REL->ALMOX   := STRZERO(nLocal,2,0)
					REL->SALDO   := aSaldos[1]
					cDesc        := ""
					REL->(MsUnlock())
					//fWrite(nARQUIVO,  PADR(QRY->B1_COD,25) + ALLTRIM(STR(aSaldos[1])) + cEOL) // Exporta��o para conferencia se necessqario
				endif			
			next
			QRY->(DbSkip())
		endDo
		QRY->(DbCloseArea())
	else
		alert("Nao ha dados que satisfacam os parametros para serem listados.")
	endif

	fClose(nARQUIVO)
	RETURN
RETURN

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO					  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprime os dados da tabela temporaria. 					  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FUNCTION fImprime()

	//������������������������������������������������������������������������Ŀ
	//� Monta a linha da regua                                                 �
	//��������������������������������������������������������������������������
	ProcRegua(REL->(RecCount()))

	//������������������������������������������������������������������������Ŀ
	//� Inicia o procedimento de impressao dos valores obtidos                 �
	//��������������������������������������������������������������������������
	cProdAnt     := SPACE(15)
	cDescAnt     := SPACE(30)
	cCorAnt      := " "
	cTipoAnt     := "  "

	nTotClasse   := 0
	nTotCor      := 0
	nTotRef      := 0
	nTotFormato  := 0
	nTotGeral    := 0
	wOk          := .T.

	DbSelectArea("REL")
	DbGoTop()
	While !Eof()
		IncProc("Imprimindo...")

		//��������������������������������������������������������������������������Ŀ
		//� Verifica o cancelamento da impressao pelo usuario.                       �
		//����������������������������������������������������������������������������
		if Interrupcao(@lAbortPrint)
			Return
		endif

		//��������������������������������������������������������������������������Ŀ
		//� Imprime parametros.                                                      �
		//����������������������������������������������������������������������������
		if m_pag == 1
			U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
		endif

		//��������������������������������������������������������������������������Ŀ
		//� Impressao do cabecalho.											         �
		//����������������������������������������������������������������������������
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif


		cProdAnt  := REL->PRODUTO
		cDescAnt  := REL->DESCR
		cTipoAnt  := REL->TIPO
		wPosAt1   := AT(" ", cDescAnt) + 1
		wPosAt2   := AT(" ", SUBST(cDescAnt,wPosAt1))
		cCorAnt   := SUBST(cDescAnt,wPosAt1,wPosAt2)

		//�����������������������������������������������������������Ŀ
		//� Processa  Formato                                         �
		//�������������������������������������������������������������
		While SUBST(REL->PRODUTO,1,2) == SUBST(cProdAnt,1,2)

			//�����������������������������������������������������������Ŀ
			//� Processa  Referencia                                      �
			//�������������������������������������������������������������
			While SUBST(REL->PRODUTO,4,3) == SUBST(cProdAnt,4,3)

				//�����������������������������������������������������������Ŀ
				//� Processa  Cor                                             �
				//�������������������������������������������������������������
				While SUBST(REL->PRODUTO,7,1) == SUBST(cProdAnt,7,1) .And. SUBST(REL->PRODUTO,4,3) == SUBST(cProdAnt,4,3)

					//�����������������������������������������������������������Ŀ
					//� Processa  Classe                                          �
					//�������������������������������������������������������������
					While SUBST(REL->PRODUTO,8,1) == SUBST(cProdAnt,8,1) .And. ;
					SUBST(REL->PRODUTO,4,3) == SUBST(cProdAnt,4,3)

						//�����������������������������������������������������������Ŀ
						//� Movimenta o cursor da regua                               �
						//�������������������������������������������������������������
						IncProc("Imprimindo...")


						if wOk .And. MV_PAR06 == 1 .And. REL->TIPO == "PA"
							cNomeRef := SUBST(cDescAnt, 1, AT(" ", cDescAnt))
							@ nL,17 PSay cNomeRef
							nL++
							wOk := .F.
						endif

						if MV_PAR06 == 1
							nL++
							@ nL,01 PSay REL->PRODUTO
							@ nL,17 PSay REL->DESCR    PICTURE "@!"
							@ nL,55 PSay REL->SALDO    PICTURE "@E 999,999,999.999"
							@ nL,78 PSay REL->ALMOX
						endif

						nTotClasse += REL->SALDO
						DbSkip()
					endDo

					//��������������������������������������������������������������������Ŀ
					//� Quebra da Classe                                                   �
					//����������������������������������������������������������������������
					//��������������������������������������������������������������������Ŀ
					//� Checa se houve quebra de pagina                                    �
					//����������������������������������������������������������������������
					if nL >= 65
						nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
					endif

					if MV_PAR06 == 1 .And. cTipoAnt == "PA"
						nL++
						cNomeClasse := "      "
						do case
							case SUBST(cProdAnt,8,1) == "1"
							cNomeClasse := "A     "
							case SUBST(cProdAnt,8,1) == "2"
							cNomeClasse := "C     "
							case SUBST(cProdAnt,8,1) == "3"
							cNomeClasse := "D     "
							case SUBST(cProdAnt,8,1) == "4"
							cNomeClasse := "B     "
							OtherWise
							cNomeClasse := "OUTRAS"
						endcase

						//��������������������������������������������������������������������Ŀ
						//� Checa se houve quebra de pagina                                    �
						//����������������������������������������������������������������������
						if nL >= 65
							nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
						endif

						@ nL,17 PSay REPLICATE("-", 53)
						nL++
						@ nL,17 PSay "TOTAL CLASSE "+cNomeClasse
						@ nL,55 PSay nTotClasse                        PICTURE "@E 999,999,999.999"
						nL++
						@ nL,17 PSay REPLICATE("-", 53)
					endif

					nTotCor    += nTotClasse
					nTotClasse := 0
					cProdAnt   := SUBST(cProdAnt,1,7)+SUBST(REL->PRODUTO,8) //+SUBST(cProdAnt,7)
				endDo

				//�����������������������������������������������������������Ŀ
				//� Quebra da Classe                                          �
				//�������������������������������������������������������������
				//��������������������������������������������������������������������Ŀ
				//� Checa se houve quebra de pagina                                    �
				//����������������������������������������������������������������������
				if nL >= 65
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
				endif

				if MV_PAR06 == 1 .And. cTipoAnt == "PA"
					nL++
					@ nL,17 PSay REPLICATE("-", 53)
					nL++
					@ nL,17 PSay "TOTAL COR "+cCorAnt
					@ nL,55 PSay nTotCor PICTURE "@E 999,999,999.999"
					nL++
					@ nL,17 PSay REPLICATE("-", 53)
				endif

				nTotRef  := nTotRef + nTotCor
				nTotCor  := 0
				cProdAnt := SUBST(cProdAnt,1,6)+SUBST(REL->PRODUTO,7,1) + SUBST(cProdAnt,8)    //SUBST(cProdAnt,1,4)+SUBST(REL->PRODUTO,5,1)+SUBST(cProdAnt,6)
				wPosAt1  := AT(" ", REL->DESCR) + 1
				wPosAt2  := AT(" ", SUBST(REL->DESCR,wPosAt1))
				cNomeCor := SUBST(REL->DESCR,wPosAt1,wPosAt2)
				cCorAnt  := cNomeCor
			enddo

			//�����������������������������������������������������������Ŀ
			//� Quebra da Referencia                                      �
			//�������������������������������������������������������������
			//��������������������������������������������������������������������Ŀ
			//� Checa se houve quebra de pagina                                    �
			//����������������������������������������������������������������������
			if nL >= 65
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
			endif

			if MV_PAR06 == 1 .And. cTipoAnt == "PA"
				nL++
				cNomeRef    := SUBST(cDescAnt, 1, AT(" ", cDescAnt))
				@ nL,17 PSay REPLICATE("-", 53)
				nL++
				@ nL,17 PSay "TOTAL REFERENCIA "+cNomeRef
				@ nL,55 PSay nTotRef                                  PICTURE "@E 999,999,999.999"
				nL++
				@ nL,17 PSay REPLICATE("-", 53)
			endif

			nTotFormato += nTotRef
			nTotRef     := 0
			cProdAnt    := SUBST(cProdAnt,1,3)+SUBST(REL->PRODUTO,4,3)+SUBST(cProdAnt,7) //SUBST(cProdAnt,1,1)+SUBST(REL->PRODUTO,2,3)+SUBST(cProdAnt,5)
			cDescAnt    := REL->DESCR
			cNomeRef    := SUBST(cDescAnt, 1, AT(" ", cDescAnt))

			if !Eof() .And. MV_PAR06 == 1 .And. cTipoAnt == "PA"
				nL := nL + 2
				@ nL,17 PSay cNomeRef
				nL++
			endif

		endDo

		//�����������������������������������������������������������Ŀ
		//� Quebra do Formato                                         �
		//�������������������������������������������������������������
		//��������������������������������������������������������������������Ŀ
		//� Checa se houve quebra de pagina                                                                �
		//����������������������������������������������������������������������
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif

		if cTipoAnt == "PA"

			cNomeFormato := "     "                    

			cOldAlias := Alias()

			//�����������������������������������������������������������������������Ŀ
			//� Verifica Tabela U1                                                    �
			//�������������������������������������������������������������������������
			//DbSelectArea("SX5")
			//DbSetOrder(1)
			//If dbSeek(xFilial("SX5")+"U1"+SUBST(cProdAnt,1,1),.f.)
			DbSelectArea("ZZ6")
			DbSetOrder(1)
			if DbSeek(xFilial("ZZ6")+SUBST(cProdAnt,1,2))
				cNomeFormato := ZZ6->ZZ6_DESC    //Subs(ZZ6->ZZ6_DESC,1,5)   
			Else
				cNomeFormato := "OUTROS"
			EndIf

			dbSelectArea(cOldAlias)

			/*		
			do case
			case SUBST(cProdAnt,1,1) == "A"
			cNomeFormato := "30X30"
			case SUBST(cProdAnt,1,1) == "B"
			cNomeFormato := "40X40"
			case SUBST(cProdAnt,1,1) == "C"
			cNomeFormato := "25X35"
			OtherWise
			cNomeFormato := "OUTROS"
			endcase
			*/

			nL++
			@ nL,17 PSay REPLICATE("-", 53)
			nL++
			@ nL,17 PSay "TOTAL PRODUTO "+cNomeFormato
			@ nL,55 PSay nTotFormato                           PICTURE "@E 999,999,999.999"
			nL++
			@ nL,17 PSay REPLICATE("-", 53)
		endif

		nTotGeral   += nTotFormato
		nTotFormato := 0
		cProdAnt    := REL->PRODUTO
		cDescAnt    := REL->DESCR
	endDo

	//������������������������������������������������������������������������Ŀ
	//� Impress�o do Total Geral                                               �
	//��������������������������������������������������������������������������

	//��������������������������������������������������������������������Ŀ
	//� Checa se houve quebra de pagina                                    �
	//����������������������������������������������������������������������
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif

	nL++
	@ nL,17 PSay REPLICATE("-", 53)
	nL++
	@ nL,17 PSay "TOTAL GERAL "
	@ nL,55 PSay nTotGeral PICTURE "@E 999,999,999.999"
	nL++
	@ nL,17 PSay REPLICATE("-", 53)
	nL := nL + 2

	//��������������������������������������������������������������������Ŀ
	//� Checa se houve quebra de pagina                                    �
	//����������������������������������������������������������������������
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif
Return( Nil )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �fApagaTemp� Autor � WLADIMIR ILLIUSHENKO					  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exclui a tabela temporaria.							      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static function fApagaTemp()
	REL->(DbCloseArea("REL")); aeval(directory(cArqTrab+".*"),{ |aFile| FErase(aFile[1])})
return