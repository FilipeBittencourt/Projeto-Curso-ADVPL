#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA507   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 08/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao Automatica de Fatura a Receber                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BIA507(lRpc, dEmissaoDe, dEmissaoAte)
	Local lDataOk := .F.
	Local lPerg	:= "BIA507"

	Default lRpc := .F.
	Default dEmissaoDe := dDataBase
	Default dEmissaoAte := dDataBase

	If lRpc

		MV_PAR01 := dEmissaoDe
		MV_PAR02 := dEmissaoAte

		R507GERA(lRpc)

	Else

		lPerg := Pergunte("BIA507",.t.)

		If !lPerg
			Return()
		EndIf

		//(13/02/15 - Thiago Dantas) -> Geração deve ser gerada no mesmo dia [OS 0619-15]
		lDataOk := (MV_PAR01 == dDataBase .And. MV_PAR02 == dDataBase)

		If !lDataOk
			MsgBox('Data Base está diferente!','Atencao','STOP')
			Return
		EndIf

		Processa({|| R507GERA() })

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R507GERA ³ Autor ³ Ranisses A. Corona    ³ Data ³ 08/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Processamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA507                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R507GERA(lRpc)

	Local aFatura	:= {}
	Local n		 	:= 1 //Variavel para controle do Array
	Local r		 	:= 1 //Variavel para controle do Array
	Local lRet	 	:= .F.
	Local Enter		:= CHR(13)+CHR(10)
	Local nQuant	:= 0 //Total de Registro para ProcRegua
	Local nCount	:= 0 //Total de Faturas Geradas
	Local lVer 		:= .T. //Variavel para verificar se o numero da fatura ja existe na base
	Local oPro 		:= TAFProcess():New()
	Local oLog 		:= TAFLog():New()
	Local oFat 		:= TFaturaReceber():New()
	Local lRollback := .F.
	Local i

	Default lRpc := .F.

	//Executa funcao para calcular as faturas
	aFatura	:= U_fGeraFatura(MV_PAR01, MV_PAR02)

	If !lRpc

		Do While Len(aFatura[r]) <> 0
			If Len(aFatura[r]) <> 0
				nQuant := nQuant + 1
			EndIf
			r += 1
		End Do

		ProcRegua(nQuant)

	EndIf

	oPro:Start()

	Do While Len(aFatura[n]) <> 0

		If !lRpc
			IncProc("Incluindo faturas....")
		EndIf

		For i := 1 To Len(aFatura[n])
			If Alltrim(aFatura[n][i][10]) == "SIM"
				lRet := .T.
			EndIf
		Next

		If lRet

			Do While lVer

				//Armazena Numero da Fatura
				wNumFat := oFat:GetNextNumFat(aFatura[n][1][2])

				lVer := .F.

			EndDo

			If Alltrim(wNumFat) == "******"

				If !lRpc
					MsgAlert("O numero da Fatura está incorreto! Favor comunicar o Setor de TI agora!")
				EndIf

				Return()

			EndIf

			//Posiciona no primeiro titulo da Fatura
			cSql := "SELECT	TOP 1 *											 " + Enter
			cSql += "FROM "+RetSqlName("SE1")+" A, "+retsqlname("SA1") + " B " + Enter
			cSql += "WHERE	E1_FILIAL  = '"+xFilial("SE1")+"'	AND " + Enter
			cSql += "		A1_FILIAL  = '"+xFilial("SA1")+"'	AND " + Enter
			cSql += "		E1_PREFIXO = '"+aFatura[n][1][2]+"'	AND " + Enter
			cSql += "		E1_NUM	   = '"+Subst(aFatura[n][1][3],1,9)+"'	AND " + Enter
			//cSql += "		E1_PARCELA = '"+aFatura[n][1][4]+"'	AND " + Enter
			cSql += "		E1_CLIENTE = '"+aFatura[n][1][5]+"'	AND " + Enter
			cSql += "		E1_LOJA	   = '"+aFatura[n][1][6]+"'	AND " + Enter
			cSql += "		E1_TIPO    = 'NF'					AND " + Enter
			cSql += "		E1_NATUREZ <> '1230'				AND " + Enter
			cSql += "		E1_CLIENTE = A1_COD					AND " + Enter
			cSql += "		E1_LOJA    = A1_LOJA				AND " + Enter
			cSql += "		A.D_E_L_E_T_ = ''					AND " + Enter
			cSql += "		B.D_E_L_E_T_ = ''						" + Enter
			cSql += "ORDER BY E1_NUM, E1_PARCELA 					" + ENTER
			IF CHKFILE("_TIT")
				DBSELECTAREA("_TIT")
				DBCLOSEAREA()
			EndIf
			TCQUERY cSql ALIAS "_TIT" NEW

			If Empty(Alltrim(_TIT->E1_CLIENTE))

				If !lRpc
					MsgBox("Ocorreu problema na Geração de Faturas. Favor informar ao Setor de TI!","Geração Automatica de Faturas","STOP")
				EndIf

				Return()

			EndIf

			For i := 1 To Len(aFatura[n])

				Begin Transaction

					If	Len(aFatura[n]) == 1
						nParc := ""
					Else
						If i == 1
							nParc := "A"
						Else
							nParc := Soma1(nParc)
						EndIf
					EndIf

					If Empty(Alltrim(_TIT->E1_VEND1))

						If !lRpc
							MsgBox("Não foi encontrado vendedor para a Fatura "+Alltrim(wNumFat)+". Informe a TI!","Geração Automatica de Faturas","STOP")
						EndIf

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava Fatura                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SE1")
					RecLock("SE1",.T.)
					SE1->E1_FILIAL	:= xFilial("SE1")
					SE1->E1_PREFIXO	:= _TIT->E1_PREFIXO
					SE1->E1_NUM		:= wNumFat
					SE1->E1_PARCELA	:= nParc							//aFatura[n][i][4]
					SE1->E1_TIPO	:= "FT"
					SE1->E1_NATUREZ	:= _TIT->E1_NATUREZ
					SE1->E1_CLIENTE	:= _TIT->E1_CLIENTE
					SE1->E1_LOJA	:= _TIT->E1_LOJA
					SE1->E1_NOMCLI	:= _TIT->E1_NOMCLI
					SE1->E1_YUFCLI	:= _TIT->E1_YUFCLI
					SE1->E1_YFORMA	:= _TIT->E1_YFORMA		//"1" Alterado conforme solicitacao do Sr. Clebes, o sistema deve considerar a forma de pagto do titulo original
					SE1->E1_EMISSAO	:= dDataBase
					SE1->E1_VENCTO	:= STOD(aFatura[n][i][7])
					SE1->E1_VENCREA	:= DATAVALIDA(STOD(aFatura[n][i][7]))
					SE1->E1_VALOR	:= aFatura[n][i][8]
					SE1->E1_VEND1	:= _TIT->E1_VEND1
					SE1->E1_VEND2	:= _TIT->E1_VEND2
					SE1->E1_VEND3	:= _TIT->E1_VEND3
					SE1->E1_VEND4	:= _TIT->E1_VEND4
					SE1->E1_VEND5	:= _TIT->E1_VEND5
					SE1->E1_EMIS1	:= dDataBase
					SE1->E1_SITUACA	:= "0"
					SE1->E1_SALDO	:= aFatura[n][i][8]
					SE1->E1_PORCJUR	:= _TIT->E1_PORCJUR
					SE1->E1_VENCORI	:= STOD(aFatura[n][i][7])
					SE1->E1_MOEDA	:= 1
					SE1->E1_FATURA	:= "NOTFAT"
					SE1->E1_OCORREN	:= "01"
					SE1->E1_VLCRUZ	:= aFatura[n][i][8]
					SE1->E1_STATUS	:= "A"
					//SE1->E1_ORIGEM	:= "BIA507"	//"FINA280"
					SE1->E1_ORIGEM	:= "FINA280" //ALTERADO PARA FINA280 EM 29/04/15 CONFORME OS 1265-15 (LENTIDÃO CANCELAMENTO DE FATURA)
					SE1->E1_PORTADO	:= IIf(Empty(_TIT->E1_PORTADO),_TIT->A1_BCO1,_TIT->E1_PORTADO)
					SE1->E1_YBAIDEL	:= _TIT->E1_YBAIDEL
					SE1->E1_YRECR	:= _TIT->E1_YRECR
					SE1->E1_FILORIG	:= xFilial("SE1")
					SE1->E1_YEMP	:= _TIT->E1_YEMP
					SE1->E1_YCLASSE := "5" //5 - Titulos de Fatura gerados atraves desta rotina (CONFORME OS 1265-15)
					MsUnLock()
					lVer 			:= .T.

					//Posiciona nos Titulos que gerou a Parcela da Fatura
					cSql := "SELECT	*						" + Enter
					cSql += "FROM "+RetSqlName("SE1")+"		" + Enter
					cSql += "WHERE	E1_FILIAL  = '"+xFilial("SE1")+"'	  AND " + Enter
					cSql += "		R_E_C_N_O_ IN ("+aFatura[n][i][9]+") AND " + Enter
					cSql += " 		D_E_L_E_T_ = ''							  " + Enter
					cSql += "ORDER BY E1_NUM, E1_PARCELA 					  " + ENTER
					IF CHKFILE("_SE1")
						DBSELECTAREA("_SE1")
						DBCLOSEAREA()
					EndIf
					TCQUERY cSql ALIAS "_SE1" NEW

					DbSelectArea("_SE1")
					DbGotop()
					While !Eof()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza Titulos                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SE1")
						DbSetOrder(1)
						If DbSeek(xFilial("SE1")+_SE1->E1_PREFIXO+_SE1->E1_NUM+_SE1->E1_PARCELA+_SE1->E1_TIPO,.F.)
							RecLock("SE1",.F.)
							SE1->E1_BAIXA	:= dDataBase
							SE1->E1_MOVIMEN	:= dDataBase
							SE1->E1_DTFATUR	:= dDataBase
							SE1->E1_SALDO	:= 0
							SE1->E1_LA		:= "S"
							SE1->E1_VALLIQ	:= _SE1->E1_VALOR
							SE1->E1_FATPREF	:= _TIT->E1_PREFIXO
							SE1->E1_FATURA	:= wNumFat
							SE1->E1_YPARCFT	:= nParc //aFatura[n][i][4]
							SE1->E1_OK		:= "ok"
							SE1->E1_STATUS	:= "B"
							SE1->E1_FLAGFAT	:= "S"
							SE1->E1_TIPOFAT	:= "FT"
							MsUnLock()

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gera Movimentacao Bancaria                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("SE5")
							DbSetOrder(1)
							RecLock("SE5",.T.)
							SE5->E5_FILIAL	:= xFilial("SE5")
							SE5->E5_DATA	:= dDataBase
							SE5->E5_TIPO	:= SE1->E1_TIPO
							SE5->E5_VALOR	:= SE1->E1_VALOR
							SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
							SE5->E5_RECPAG	:= "R"
							SE5->E5_BENEF	:= SE1->E1_NOMCLI
							SE5->E5_HISTOR	:= "Bx.Emis.Fat."+wNumFat
							SE5->E5_TIPODOC	:= "BA"
							SE5->E5_VLMOED2	:= SE1->E1_VALOR
							SE5->E5_LA		:= "S"
							SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
							SE5->E5_NUMERO	:= SE1->E1_NUM
							SE5->E5_PARCELA	:= SE1->E1_PARCELA
							SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
							SE5->E5_LOJA	:= SE1->E1_LOJA
							SE5->E5_DTDIGIT	:= dDataBase
							SE5->E5_MOTBX	:= "FAT"
							SE5->E5_SEQ		:= "01"
							SE5->E5_DTDISPO	:= dDataBase
							SE5->E5_FILORIG	:= cFilAnt
							SE5->E5_FATURA	:= wNumFat
							SE5->E5_FATPREF	:= _TIT->E1_PREFIXO
							MsUnLock()
						EndIf
						FinXSE5(SE5->(RECNO()),3)
						DbSelectArea("_SE1")
						DbSkip()
					EndDo

					//Seleciona o Valor Total dos Titulos que geraram as faturas
					A0001 := " SELECT E1_FATURA, SUM(E1_VALOR) AS E1_VALOR "
					A0001 += " FROM "+RetSqlName("SE1")+" SE1 "
					A0001 += " WHERE E1_FATURA  = '"+wNumFat+"' "
					A0001 += " AND   E1_FATPREF = '"+_TIT->E1_PREFIXO+"' "
					A0001 += " AND   D_E_L_E_T_ = ' ' "
					A0001 += " GROUP BY E1_FATURA "
					If chkfile("A001")
						dbSelectArea("A001")
						dbCloseArea()
					EndIf
					TcQuery A0001 New Alias "A001"

					//Seleciona o Valor Total da Fatura
					A0002 := " SELECT E1_FATURA, SUM(E1_VALOR) AS E1_VALOR	"
					A0002 += " FROM "+RetSqlName("SE1")+" SE1 				"
					A0002 += " WHERE E1_NUM		= '"+wNumFat+"' 			"
					A0002 += " AND   E1_PREFIXO = '"+_TIT->E1_PREFIXO+"' 	"
					A0002 += " AND   E1_TIPO    = 'FT'	"
					A0002 += " AND   D_E_L_E_T_ = ' ' 	"
					A0002 += " GROUP BY E1_FATURA 		"
					If chkfile("A002")
						dbSelectArea("A002")
						dbCloseArea()
					EndIf
					TcQuery A0002 New Alias "A002"

					//Verificar o Valor dos Titulos x Valor da Fatura
					IF A001->E1_VALOR <> A002->E1_VALOR

						If !lRpc
							MsgBox("Valor da Fatura "+Alltrim(_TIT->E1_PREFIXO)+"-"+Alltrim(wNumFat)+" não confere com a soma dos valores dos titulos NF.","STOP")
						EndIf

						DisarmTransaction()

						oLog:cIDProc := oPro:cIDProc
						oLog:cOperac := "R"
						oLog:cMetodo := "CR_TIT_INC"
						oLog:cHrFin := Time()
						oLog:cRetMen := "Fatura " + wNumFat + " não será gerada - Total " + AllTrim(Transform(A002->E1_VALOR, "@e 999,999,999.99")) + " Total titulos: " + AllTrim(Transform(A001->E1_VALOR, "@e 999,999,999.99"))
						oLog:cEnvWF := If(lRollback, "N", "S")
						oLog:cTabela := RetSQLName("SE1")
						oLog:nIDTab := SE1->(Recno())

						oLog:Insert()

						lRollback := .T.

					EndIf

				End Transaction

			Next
			//Atualiza Parametro de Sequencial da Fatura
			//PutMV("MV_NUMFAT",wNumFat)
			nCount := nCount + 1
		EndIf
		//Reinicia variavel
		lRet	:= .F.
		//Posiciona na proxima Fatura
		n		+= 1

	EndDo

	oPro:Finish()

	If !lRpc
		MsgBox("Rotina realizada com sucesso. Foram geradas "+Alltrim(Str(nCount))+" faturas.","Geração Automatica de Faturas","INFO")
	EndIf

Return()