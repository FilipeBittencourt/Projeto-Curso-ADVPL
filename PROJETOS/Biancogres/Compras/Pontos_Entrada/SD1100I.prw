#include "rwmake.ch"
#include "topconn.ch"

User Function SD1100I()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ SD1100I  ³ Autor ³ Microsiga Vit¢ria     ³ Data ³ 02/01/02 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Ponto de Entrada apos a Inclusao do item da NF de entrada. ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local fpArea := GetArea()
	Local _oMd	:=	TBiaControleMD():New()
	Local _cSolic	:=	""
	
	Public xd_NumPrc := Space(6)

	If !Empty(SD1->D1_PEDIDO)
		CSQL := "UPDATE "+RETSQLNAME("ZCN")+" "
		CSQL += "   SET ZCN_SOLIC =  "
		CSQL += "	    ISNULL((SELECT MAX(SUBSTRING(NOMFUN,1,30))           "
		CSQL += "		  		  FROM "+RETSQLNAME("SC7")+" SC7             "
		CSQL += "			     INNER JOIN VETORH..R034FUN                  "
		CSQL += "				    ON NUMEMP = "+ Subst(cEmpAnt,2,1)        
		CSQL += "                  AND TIPCOL = 1                            "
		CSQL += "				   AND NUMCAD =                              "
		CSQL += "				       (CASE WHEN LEN(LTRIM(RTRIM(C7_YMAT))) = 8 THEN "
		CSQL += "				             SUBSTRING(C7_YMAT,3,6)          "
		CSQL += "				        ELSE C7_YMAT END)                    "		 
		CSQL += "			     WHERE C7_NUM     = '" + SD1->D1_PEDIDO + "' AND "
		CSQL += "					   C7_PRODUTO = '" + SD1->D1_COD    + "' AND "
		CSQL += "					   C7_ITEM    = '" + SD1->D1_ITEMPC + "' AND "
		CSQL += "					   SC7.D_E_L_E_T_ = '' ),'')             "
		CSQL += " WHERE ZCN_COD    = '"+SD1->D1_COD+"' "
		CSQL += "	AND ZCN_LOCAL  = '"+SD1->D1_LOCAL+"' "
		CSQL += "	AND D_E_L_E_T_ = '' "

		TCSQLEXEC(CSQL)
	EndIf

	// Atualização da função do Ativo Ciap a partir da descrição do Próprio Ativo Ciap durante a gravação do Item da Nota fiscal de Entrada.
	// Regra incluida por Marcos Alberto em 10/10/11 atendendo O.S. Effettivo número: 0293-11.
	If !Empty(SD1->D1_CODCIAP)
		A0001 := " UPDATE "+RetSqlName("SF9")+" SET F9_FUNCIT = SUBSTRING(F9_DESCRI,1,30)
		A0001 += "  WHERE F9_FILIAL = '"+xFilial("SF9")+"'
		A0001 += "    AND F9_CODIGO = '"+SD1->D1_CODCIAP+"'
		A0001 += "    AND D_E_L_E_T_ = ' '
		TcSqlExec(A0001)
	EndIf

	// Processo de Devolução. Incluído por Marcos Alberto em 11/10/11 a pedido da Diretoria.
	// Rotinas envolvidas: BIA267, SF1100I, SF1100E, SD1100I, MT100LOK, MT100GRV
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
	If SD1->D1_TIPO == "D" .and. SB1->B1_TIPO == "PA"

		A0002 := " SELECT Z26_NUMPRC
		A0002 += "   FROM "+ RetSqlName("Z26")
		A0002 += "  WHERE Z26_FILIAL = '"+xFilial("Z26")+"'
		A0002 += "    AND Z26_NFISC = '"+SD1->D1_NFORI+"'
		A0002 += "    AND Z26_SERIE = '"+SD1->D1_SERIORI+"'
		A0002 += "    AND Z26_ITEMNF = '  '
		A0002 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		xd_NumPrc := A002->Z26_NUMPRC
		A002->(dbCloseArea())

		If SF4->F4_ESTOQUE == "S"
			dbSelectArea("Z26")
			RecLock("Z26",.T.)
			Z26->Z26_FILIAL  := xFilial("Z26")
			Z26->Z26_NUMPRC  := xd_NumPrc
			Z26->Z26_NFISC   := SD1->D1_NFORI
			Z26->Z26_SERIE   := SD1->D1_SERIORI
			Z26->Z26_ITEMNF  := SD1->D1_ITEMORI
			Z26->Z26_PROD    := SD1->D1_COD
			Z26->Z26_QTDORI  := SD1->D1_QUANT
			MsUnLock()
		Else
			dbSelectArea("Z25")
			dbSetOrder(1)
			If dbSeek(xFilial("Z25")+xd_NumPrc)
				RecLock("Z25",.F.)
				Z25->Z25_APRFIS := "X"
				MsUnLock()
			EndIf
		EndIf

		dbSelectArea("Z25")
		dbSetOrder(1)
		If dbSeek(xFilial("Z25")+xd_NumPrc)
			If Empty(Z25->Z25_NFLANC)
				or_AcAtu := "Incluída Nota Fiscal de Devolução!!!"
				or_DescS := "EXPEDIÇÃO / FINANCEIRO"
				U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 3)
			EndIf

			RecLock("Z25",.F.)
			Z25->Z25_NFLANC := "X"
			Z25->Z25_USLNFE := __cUserID
			Z25->Z25_DTLNFE := dDataBase
			// Retirada regra em 25/11/11 porque ainda estamos fazendo ajustes no fluxo do Processo de Devolução
			//If Z25->Z25_RETMRC == "N"
			//	Z25->Z25_APRFIS := "X"
			//EndIf
			MsUnLock()
		EndIf
	EndIf

	//************************** Cadastrar o lote automaticamente ******************************
	// Inserido por Marcos Alberto Soprani em 04/09/12 conforme OS Effettivo 1960-12
	If Alltrim(GetMv("MV_RASTRO")) == "S"
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
		If SB1->B1_RASTRO == "L"
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
			If SF4->F4_ESTOQUE == "S"
				If !Empty(SD1->D1_LOTECTL)
					dbSelectArea("ZZ9")
					dbSetOrder(2)
					dbGoTop()
					If !dbSeek(xFilial("ZZ9") + SD1->D1_COD + SD1->D1_LOTECTL)
						RecLock("ZZ9",.T.)
						ZZ9->ZZ9_LOTE 		:= SD1->D1_LOTECTL
						ZZ9->ZZ9_PRODUT 	:= SD1->D1_COD
						ZZ9->ZZ9_PESO  		:= SB1->B1_PESO
						ZZ9->ZZ9_PECA  		:= SB1->B1_YPECA
						ZZ9->ZZ9_DIVPA 		:= SB1->B1_YDIVPA
						ZZ9->ZZ9_PESEMB 	:= SB1->B1_YPESEMB
						ZZ9->ZZ9_MSBLQL 	:= '2'

						If (AllTrim(SB1->B1_YPCGMR3) <> 'J') //Vinilico

							If !Empty(Substr(SD1->D1_LOTECTL, 1, 1)) .and. Substr(SD1->D1_LOTECTL, 1, 1) < "A" .and. cEmpAnt <> "14" .and. Substr(SD1->D1_COD,1,1) <> "I"
								ZZ9->ZZ9_RESTRI     := "*"
							EndIf

						EndIf


						MsUnlock()
						MsUnlockAll()

						//Fernando/Facile em 07/07/2015 -> o ZZ9 pode ja existir - marcar o lote como restrito - OS 1607-15
					Else

						If (AllTrim(SB1->B1_YPCGMR3) <> 'J') //Vinilico

							If !Empty(Substr(SD1->D1_LOTECTL, 1, 1)) .and. Substr(SD1->D1_LOTECTL, 1, 1) < "A" .and. cEmpAnt <> "14" .and. Substr(SD1->D1_COD,1,1) <> "I"
								RecLock("ZZ9",.F.)
								ZZ9->ZZ9_RESTRI     := "*"
								MsUnlock()
								MsUnlockAll()
							EndIf

						EndIf


					EndIf
					dbSelectArea("ZZ9")
					dbSetOrder(1)
					dbGoTop()
				EndIf
			EndIf
		EndIf
	EndIf

	If Alltrim(SD1->D1_TIPO) == 'N' .And. Alltrim(SF4->F4_ESTOQUE) == 'S'  .And. _oMd:CheckMD(SD1->D1_COD,SD1->D1_LOCAL)
	    _cSolic	:=	_oMd:GetSolicNFE(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM)
	    _oMd:InsereMovimentacao(SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_LOCAL,;
	    									"001",_cSolic,_cSolic,cUserName,"MATA103",SD1->D1_DTDIGIT,"SD1",SD1->(RECNO())) //Insere Movimentação na Tabela	
			
	EndIf
	RestArea(fpArea)

	//TESTE CONEXAO INICIO
	conout(" ["+ Time() +"] Mensagem ConexãoNF-e")
	conout(" > SD1100I:")

	If Type("cEspecie") <> "U"
		conout("    cEspecie: '" + cEspecie + "'")
	else
		conout("    cEspecie não declarada")
	EndIf

	If Empty(SF1->F1_ESPECIE)
		conout("    SF1->F1_ESPECIE = ''")
	else
		conout("    SF1->F1_ESPECIE = '" + SF1->F1_ESPECIE + "'")
	EndIf
	//TESTE CONEXAO FIM

	//ATU_PROCEX()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ ATU_PROCEX   ³ Autor ³BRUNO MADALENO        ³ Data ³  24/10/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ATUALIZA DESPESAS REALIZADAS E BLOQUEAS AS MESMAS QUANDO NECESSA³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATU_PROCEX()
	LOCAL cQuery := ""
	Local I

	FOR I:= 1 TO LEN(ACOLS())
		nPosProce  := aScan(aHeader,{|x| x[2]=="D1_YPROCES"})
		SS_PROCEX := ALLTRIM(Acols[I,nPosProce])

		nPosNatu  := aScan(aHeader,{|x| x[2]=="D1_YNATURE"})
		SS_NATUR := ALLTRIM(Acols[I,nPosNatu])

		nPosVLCRZ  := aScan(aHeader,{|x| x[2]=="D1_TOTAL  "})
		SS_VALOR := ALLTRIM(Acols[I,nPosVLCRZ])

		nPosVENCREA  := aScan(aHeader,{|x| x[2]=="D1_       "})
		SS_VENC := ALLTRIM(Acols[I,nPosVENCREA])

		nPosDOC  := aScan(aHeader,{|x| x[2]=="D1_DOC    "})
		SS_DOC := ALLTRIM(Acols[I,nPosDOC])

		IF ! EMPTY(SS_PROCEX) //M->E2_YPROCEX <> ' '
			dbSelectArea("EET")
			RecLock("EET",.T.)
			EET->EET_FILIAL  	  := xFilial("EET")
			EET->EET_PEDIDO 	  := SS_PROCEX //M->E2_YPROCEX     //Nr Processo
			EET->EET_OCORRE 	  := "P"  				// Pedido ou embarque colocar sempre P
			EET->EET_DESPES	      := POSICIONE("SYB",3,xFilial("SYB")+SS_NATUR,"YB_DESP")
			EET->EET_DESADI	  	  := SS_VENC //M->E2_VENCREA  	//VENCIMENTO = HOJE + NR DIAS
			EET->EET_VALORR		  := SS_VALOR //M->E2_VLCRUZ 		//
			EET->EET_BASEAD		  := "1" 				// 1=Desp 2=Exportador
			EET->EET_DOCTO		  := SS_DOC //M->E2_NUM 			// Documento
			EET->EET_PAGOPO		  := "1"
			EET->EET_RECEBE		  := " "
			EET->EET_REFREC		  := " "
			EET->EET_CODINT		  := SS_NATUR
			EET->EET_YPRVRL		  := "R" 				//REALIZADAS
			EET->EET_YDC		  := "D"
			msUnLock()
		End If
	NEXT
	dbcommitall()
	MsgBox("Este Lancamento foi registrado para o processo de Exportação No: "+M->E2_YPROCEX, "SD1100I", "ALERT")
	Private NLIB := POSICIONE("EE7",9,xFilial("EE7")+M->E2_YPROCEX,"EE7_YLIBER")

	If NLIB = 'N'
		M->E2_YSTATUS := 'B'
	Else
		//Selecionando a despesa prevista.
		cQuery := "Select * From " + RETSQLNAME("EET") + " where EET_PEDIDO = '" + alltrim(M->E2_YPROCEX) + "' And "
		cQuery += "EET_YPRVRL = 'P' And EET_CODINT = '"+ Alltrim(M->E2_NATUREZ) +"' "
		TCQUERY cQuery ALIAS "cTrab" NEW
		cTRAB->(DbGoTop())

		//VERIFICANDO SE EXISTE DESPESAS PREVISTAS
		If !cTrab->(EOF())
			M->E2_YSTATUS := 'B'
			MsgBox("Não existe despesa prevista para esta naturea neste processo!"+Chr(13)+CHR(10)+;
			"Esta despesa ficará bloqueada para baixa.", "SD1100I", "ALERT")
			DbSelectArea("cTrab")
			DbCloseArea()
			Return
		Else
			cQuery := ""
			cQuery := "Select * From " + RETSQLNAME("SE2") + " where E2_YPROCEX = '" + alltrim(M->E2_YPROCEX) + "' And "
			cQuery += "E2_NATUREZ = '"+ Alltrim(M->E2_NATUREZ) + "'"
			TCQUERY cQuery ALIAS "cTrabRealizadas" NEW

			nValor := m->E2_VALOR
			Do While !cTrabRealizadas->(EOF())
				nValor += Round(cTrabRealizadas->E2_VALOR,2)
				cTrabRealizadas->(DbSkip())
			End

			If Round(cTrab->EET_VALORR,2) >= nValor
				M->E2_YSTATUS := 'L'
			Else
				M->E2_YSTATUS := 'B'
			End if
			DbSelectArea("cTrabRealizadas")
			DbCloseArea()
		End  If
		DbSelectArea("cTrab")
		DbCloseArea()
	End If

RETURN()
