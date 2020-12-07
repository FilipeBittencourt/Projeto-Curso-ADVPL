#Include "rwmake.ch"
#Include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Felipe Zago
Autor(Rev):= Marcos Alberto Soprani
Programa  := BIA995
Empresa   := Biancogres Cerâmica S/A
Data      := 30/06/05
Data(Rev) := 09/03/12
Uso       := Gestão de Pessoal
Aplicação := Resumo da Folha de Pagamentos 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA995()

	Local 	cDesc1          := "Este programa tem como objetivo imprimir relatorio"
	Local 	cDesc2          := "de acordo com os parametros informados pelo usuario."
	Local 	cDesc3          := "Autorizacao para pagamento da folha de pagamento"
	Local 	cPict           := ""
	Local 	titulo          := Upper("Autorizacao para pagamento da folha de pagamento")
	Local 	nLin            := 80
	Local 	nCol		    := 0
	Local  	i		        := 0
	Local 	Cabec1          := ""
	Local 	Cabec2          := ""
	Local 	imprime         := .T.
	Local 	aOrd      		:= {}

	Private lEnd            := .F.
	Private lAbortPrint     := .F.
	Private CbTxt           := ""
	Private limite          := 80
	Private tamanho         := "G"
	Private nomeprog        := "BIA995"
	Private nTipo           := 18
	Private aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg           := "BIA995"
	Private cbtxt           := Space(10)
	Private cbcont          := 00
	Private CONTFL          := 01
	Private m_pag           := 01
	Private wnrel           := "BIA995"
	Private cString 		:= "SZY"

	DbSelectArea(cString)
	dbSetOrder(1)

	Pergunte(cPerg,.F.)

	Cabec1:= PADL(mv_par01,220)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  17/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local 	nOrdem	 := 0
	Local 	nIndice	 := 0
	Local 	nTam	 := 0
	Local 	aCampos	 := {}
	Local 	aArea	 := {}
	Local 	aCategs	 := {}
	Local	aDescRed := {}
	Local 	aDesc	 := {}
	Local	aDtVenc	 := {}
	Local 	wTrab	 := ""
	Local	cQuery	 := ""
	Local 	cCampo	 := ""
	Local	nTotalCC := 0	  // Total vertical  (Centros de Custo)
	Local	aTotalCat:= {}    // Total horizontal (Categorias)
	Local i

	aAdd(aCampos, {"CODCC","C",4,0})
	DbSelectArea("SZY")
	DbGoTop()
	While !Eof()
		IF SZY->ZY_COD == "16" .OR. SZY->ZY_COD == "17" .OR. SZY->ZY_COD == "18" .OR. SZY->ZY_COD == "19"
			//SZY->(DbSkip())
		ELSE
			aAdd(aCategs  , SZY->ZY_COD)
			aAdd(aDesc	  , SZY->ZY_DESC)
			aAdd(aDescRed , SZY->ZY_DESCRED)
			aAdd(aDtVenc  , SZY->ZY_VENCTO)
			aAdd(aCampos  , {"C"+SZY->ZY_COD,"N",14,2})
		END IF
		DbSkip()
	EndDo
	aAdd(aCampos, {"TOTAL","N",14,2})
	wTrab 	:= CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,wTrab,"wTrab")
	DbCreateInd(wTrab,"CODCC",{||CODCC})
	aCC:= fCentrosCusto()
	For nIndice:= 1 to Len(aCC)
		RecLock("wTrab",.T.)
		wTrab->CODCC:= aCC[nIndice]
		MsUnlock()
	Next nIndice

	dbSelectArea("SZY")
	dbSetOrder(1)

	SetRegua(RecCount())
	dbGoTop()
	While !Eof()

		IF SZY->ZY_COD == "16" .OR. SZY->ZY_COD == "17" .OR. SZY->ZY_COD == "18" .OR. SZY->ZY_COD == "19"
			//SZY->(DbSkip())
			A := "1"
		ELSE
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			//Ú---------------------------------------------------------------------¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//À---------------------------------------------------------------------Ù
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nCol := 8
				nLin := 8
				@ nLin, 01 PSAY "  CC  |"
				For i:= 1 to Len(aDescRed)
					@ nLin, nCol PSAY PADL(aDescRed[i],13)+"|"
					nCol += 14
				Next i
				@ nLin++,nCol PSAY  "    Total    |"
				//@ nLin++,01   PSAY "------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|"
				@ nLin++,01   PSAY "------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|"
			EndIf
			aTipoFunc:= {}
			cCodAtual:= SZY->ZY_COD
			Do Case
				Case cCodAtual == "01"
				aTipoFunc:= {"M","E"}
				Case cCodAtual == "02"
				aTipoFunc:= {"P"}
				Case cCodAtual == "03"
				aTipoFunc:= {"P"}
				Case cCodAtual == "04"
				aTipoFunc:= {"M","E","A"}
				Case cCodAtual == "05"
				aTipoFunc:= {"P"}
				Case cCodAtual == "06"
				aTipoFunc:= {"M","E","A"}
				Case cCodAtual == "07"
				aTipoFunc:= {"M","A"}
				Case cCodAtual == "08"
				aTipoFunc:= {"P"}
				Case cCodAtual == "09"
				aTipoFunc:= {"M","E","P"}
				Case cCodAtual == "10"
				aTipoFunc:= {"M","P"}
				Case cCodAtual == "11"
				aTipoFunc:= {"M","P"}
				Case cCodAtual == "12"
				aTipoFunc:= {"M","P","E"}
				Case cCodAtual == "13"
				aTipoFunc:= {"M"}
				Case cCodAtual == "14"
				aTipoFunc:= {"M"}
				Case cCodAtual == "15"
				aTipoFunc:= {"M"}
			EndCase

			If mv_par09 = 2
				IF cCodAtual = "01"
					fCat(cCodAtual, aTipoFunc)
				END IF
			ELSEIF mv_par09 = 3
				IF cCodAtual = "01"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "04"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "06"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "07"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "10"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "11"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "15"
					fCat(cCodAtual, aTipoFunc)				
				END IF
			ELSE
				fCat(cCodAtual, aTipoFunc)
			END IF

		END IF

		DbSelectArea("SZY")
		DbSkip()
	EndDo
	DbSelectArea("wTrab")
	DbGotop()
	nTam:= wTrab->(fCount())-1
	nTam--

	For i:= 1 to nTam
		aAdd(aTotalCat,0)
	Next i

	While !Eof()
		@ nLin ,02	 PSAY wTrab->CODCC + " |"
		nCol:= 8
		nTotalCC:= 0
		For i:= 1 to nTam
			cCampo:= "C"+aCategs[i]
			If wTrab->&cCampo == 0
				@ nLin, nCol PSAY PADL("-",8)+SPACE(5)+"|"
			Else
				nTotalCC += wTrab->&cCampo
				@ nLin, nCol PSAY wTrab->&cCampo PICTURE "@E 99,999,999.99"+"|"
			EndIf
			nCol += 14
			aTotalCat[i] += wTrab->&cCampo
		Next i
		@ nLin++, nCol PSAY abs(nTotalCC) PICTURE "@E 99,999,999.99"+"|"
		DbSkip()
	EndDo
	// Totalizadores
	@ nLin++,01	PSAY "------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|"
	@ nLin  ,01	PSAY "Total |"
	nCol:= 8
	nTotal:= 0
	For i:= 1 to nTam
		nTotal += aTotalCat[i]
		@ nLin, nCol PSAY ABS(aTotalCat[i]) PICTURE "@E 99,999,999.99"+"|"
		nCol+=14
	Next i
	@ nLin++,nCol PSAY abs(nTotal) PICTURE "@E 99,999,999.99" + "|"
	@ nLin++,01	PSAY "------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|"
	nLin++

	@ nLin++, 01 PSAY "Obs1: "+alltrim(mv_par02)+" "+mv_par03
	@ nLin++, 01 PSAY "Obs2: "+alltrim(mv_par04)+" "+mv_par05
	@ nLin++, 01 PSAY "Obs3: "+alltrim(mv_par06)

	nLin += 1
	zLiRef := nLin
	zCol01 := 000
	zCol02 := 110
	zColRf := zCol01

	// Tratamento para impressão dos quadros de assinatura porque estava estrapolando a quantidade de linhas da página.
	@ nLin++, zCol01+01 PSAY "RESUMO DO MES DE "+mv_par01+" POR CATEGORIA"
	// Quadro Assinaturas 01                            -- Quadro Assinaturas 02
	@ nLin  , zCol02+01 PSAY "----------------------------------------------------------------------------------------------"
	@ nLin++, zCol01+02 PSAY "----------------------------------------------------------------------------------------------"
	@ nLin  , zCol02+01 PSAY "Cod Descricao                                   Dt Vencto           Valor  Rubrica            "
	@ nLin++, zCol01+02 PSAY "Cod Descricao                                   Dt Vencto           Valor  Rubrica            "
	@ nLin  , zCol02+01 PSAY "----------------------------------------------------------------------------------------------"
	@ nLin++, zCol01+02 PSAY "----------------------------------------------------------------------------------------------"
	nLin++

	For i := 1 to Len(aCategs)
		@ nLin  , zColRf+02 PSAY aCategs[i]
		@ nLin  , zColRf+05 PSAY aDesc[i]
		@ nLin  , zColRf+50 PSAY aDtVenc[i]
		@ nLin  , zColRf+60 PSAY aTotalCat[i] PICTURE  "@E 999,999,999.99"
		@ nLin  , zColRf+76 PSAY "__________________"
		If zColRf == zCol01
			zColRf := zCol02
		Else
			nLin++
			zColRf := zCol01
		EndIf
	Next i

	@ nLin  , zColRf+02 PSAY "-- Ref. Plano de Saude - Diretoria: "
	@ nLin  , zColRf+50 PSAY mv_par08 PICTURE "@E 999,999,999.99"
	@ nLin  , zColRf+60 PSAY mv_par07 PICTURE "@E 999,999,999.99"
	@ nLin  , zColRf+76 PSAY "__________________"

	zColRf := zCol02
	@ nLin  , zColRf+02 PSAY "-- Ref. Plano de Saude - Outros: "
	@ nLin  , zColRf+50 PSAY mv_par11 PICTURE "@E 999,999,999.99"
	@ nLin  , zColRf+60 PSAY mv_par10 PICTURE "@E 999,999,999.99"
	@ nLin  , zColRf+76 PSAY "__________________"

	wTrab->(DbCloseArea())

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fVerbas   ¦ Autor ¦                      ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Verbas                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fVerbas(cCodCateg)

	Local i

	Private cQuery	:= ""
	Private cVerbas := ""
	Private aVerbas	:= {}
	Private i:= 0
	Private tam:= 0

	cQuery += "SELECT RV_COD FROM "+RetSqlName("SRV")+" SRV"
	cQuery += " WHERE SRV.RV_YAP LIKE '%"+cCodCateg+"%'"
	cQuery += " OR SRV.RV_YDEDUZ LIKE '%"+cCodCateg+"%'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	TcQuery cQuery New Alias "Trab"
	DbSelectArea("Trab")
	While !EOF()
		aAdd(aVerbas, Trab->RV_COD)
		DbSkip()
	EndDo
	Trab->(DbCloseArea())

	Tam:= Len(aVerbas)
	If Tam <> 0
		Private cVerbas:= "("
		For i:= 1 to Tam
			cVerbas += "'"+aVerbas[i]+"'"
			If i < Tam
				cVerbas += ","
			EndIf
		Next i
		cVerbas += ")"
	EndIf

Return cVerbas

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fCentrosCusto   ¦ Autor ¦                ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Centro de Custo                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCentrosCusto

	aCC:= {}
	Private cQuery:= ""
	cQuery += " SELECT DISTINCT RC_CLVL
	cQuery += "   FROM " + RetSqlName("SRC")
	cQuery += "  WHERE D_E_L_E_T_ = ' '
	cQuery += "  ORDER BY RC_CLVL
	TcQuery cQuery New Alias "TrabSRC"
	DbSelectArea("TrabSRC")
	While !Eof()
		aAdd(aCC, TrabSRC->RC_CLVL)
		DbSkip()
	EndDo
	TrabSRC->(DbCloseArea())

Return aCC

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fChecaVerba   ¦ Autor ¦                  ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Centro de Custo                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fChecaVerba(cVerba, cCateg)

	DbSelectArea("SRV")
	DbSetOrder(1)
	DbSeek(xFilial("SRV")+cVerba)

	/*If Empty(Alltrim(cCateg))
	Return "X"
	EndIf*/

	If cCateg $ SRV->RV_YAP
		Return "S"
	EndIf

Return "D"

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fCat        ¦ Autor ¦                    ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Categoria padrao, onde nao ha consulta complexa e a        ¦¦¦
¦¦¦          ¦ operacao principal so depende da SRA e da SRC.             ¦¦¦
¦¦¦          ¦ cCodCat    : Codigo da Categoria                           ¦¦¦
¦¦¦          ¦ cTipoFunc  : Codigos de Tipo de Funcionario(em RA_CATFUNC) ¦¦¦
¦¦¦          ¦ Exemplo    : fCat("01","MP")  		                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCat(cCodCat, aTipoFunc, cSqlAdicional)

	Local i

	Private cQuery  	:= ""
	Private cTrab		:= ""
	Private cCampo		:= "C"+cCodCat
	Private cCatFunc    := ""
	Private i			:= 0

	For i:= 1 to Len(aTipoFunc)
		cCatFunc += "'"+aTipoFunc[i]+"'"
		If i < Len(aTipoFunc)
			cCatFunc += ','
		End
	Next i

	IF MV_PAR09 = 3
		cCatFunc := "'M','E'"
	ENDIF 

	If mv_par09 = 1
		cQuery += "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC"
		cQuery += " WHERE RA_CATFUNC IN ("+cCatFunc+")"
		cQuery += " AND RA_MAT = RC_MAT"
		cQuery += " AND SRA.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.RC_PD IN "+ iif( empty(fVerbas(cCodCat)), "('99985')",fVerbas(cCodCat))
	Endif

	If mv_par09 = 2
		cQuery := "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA  "
		cQuery += "FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC "
		cQuery += " WHERE RA_CATFUNC IN ("+cCatFunc+")" "
		cQuery += " AND RA_MAT = RC_MAT "
		cQuery += " AND SRA.D_E_L_E_T_ <> '*' "
		cQuery += " AND SRC.D_E_L_E_T_ <> '*' "
		cQuery += " AND SRC.RC_PD IN ('066') " //,'709','402','403','447') "
	Endif			

	If mv_par09 = 3
		cQuery += "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC"
		cQuery += " WHERE RA_CATFUNC IN ("+cCatFunc+")"
		cQuery += " AND RA_MAT = RC_MAT"
		cQuery += " AND SRA.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.D_E_L_E_T_ <> '*'"	

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ FOI DEFINIDO POR WANISAY E MADALENO QUE ESTARIAMOS INFORMANDO AS VERBAM QUE IRA COMPOR CADA CATEGORIA DENTRO DO ³
		³ FONTE...                                                                                                        ³
		³ ESTA DECISÃO FOI TOMADA PARA EVITAR A CRIACAO DE CAMPO OU PARAMETRO, SENDO QUE NAO IRIA FUNCIONAR               ³
		³ POIS DEVIARIAMOS CRIAR UM CONTROLE MUITO TRABALHOSO E COMPLICADO PARA OS USUARIOS DO SETOR DE RH ADMINISTRAREM. ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		IF cCodCat = "01"
			cQuery += " AND SRC.RC_PD IN ('709')"
		ELSEIF cCodCat = "04"
			cQuery += " AND SRC.RC_PD IN ('402','780','781','782','327') "
		ELSEIF cCodCat = "06"
			cQuery += " AND SRC.RC_PD IN ('730','758','759','742') "
		ELSEIF cCodCat = "07"
			cQuery +=	 " AND SRC.RC_PD IN ('403') "
		ELSEIF cCodCat = "10"
			cQuery += " AND SRC.RC_PD IN ('447','525','542') "		
		ELSEIF cCodCat = "11"
			cQuery += " AND SRC.RC_PD IN ('744') "		
		ELSEIF cCodCat = "15"
			cQuery += " AND SRC.RC_PD IN ('764') "
		END IF
	Endif

	If cSqlAdicional <> Nil
		cQuery += cSqlAdicional
	EndIf
	cQuery += " ORDER BY RA_MAT"
	TcQuery cQuery New Alias cTrab
	DbSelectArea("cTrab")
	While !cTrab->(Eof())
		DbSelectArea("wTrab")
		DbSetOrder(1)
		//Ú------------------------------------------------¿
		//³IR sobre ordenados - devemos pular os demitidos ³
		//À------------------------------------------------Ù
		//If cCodCat == "07" .And. cTrab->RA_SITFOLH == "D"  Desconsiderar Regra, conf. Sra. Claudia
		//	cTrab->(DbSkip())
		//	Loop
		//Ú------------------------------------------------------------------¿
		//³IR s/ ordenados - Nao considerar Autonomos                        ³
		//À------------------------------------------------------------------Ù
		If cCodCat == "07" .And. cTrab->RA_MAT >= "200000"
			cTrab->(DbSkip())
			Loop
		EndIf

		//Ú------------------------------------------------------------------¿
		//³FGTS - caso tenha sido demitido, devemos pular quem for <> H ou K ³
		//À------------------------------------------------------------------Ù
		// Retirado por Marcos Alberto Soprani em 30/01/18 a pedido da Jéssica Alvarenga
		//If cCodCat == "11" .And. cTrab->RA_SITFOLH == "D" .And. !(cTrab->RA_AFASFGT $ "H/K/J/S")
		//	cTrab->(DbSkip())
		//	Loop
		//EndIf

		DbSeek(cTrab->CC)
		IF ! wTrab->(EOF())
			RecLock("wTrab",.F.)
			If fChecaVerba(cTrab->VERBA, cCodCat) == "S"
				//wTrab->&cCampo += cTrab->VALOR
				wTrab->&(cCampo) := wTrab->&(cCampo) + cTrab->VALOR
			Else
				//wTrab->&cCampo -= cTrab->VALOR
				wTrab->&(cCampo) := wTrab->&(cCampo) - cTrab->VALOR
			EndIf
			MsUnlock()
		END IF
		cTrab->(DbSkip())
	EndDo
	cTrab->(DbCloseArea())

Return
