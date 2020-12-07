#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"
#include "Ap5Mail.ch"

/*/{Protheus.doc} BIA276
@author Marcos Alberto Soprani
@since 05/12/11
@version 1.0
@description Geração de Arquivo de remessa TXT para contracheque Banco do
.            Brasil passar a imprimir os contracheques na boca do caixa.
@type function
/*/

User Function BIA276()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local r, i

	cHInicio := Time()
	fPerg := "BIA276"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	// Estrutura para criação do arquivo txt
	df_ArqEtq := Alltrim(MV_PAR09)+"cCheq"+cEmpAnt+MV_PAR05+".txt"
	If File(df_ArqEtq)
		FERASE(df_ArqEtq)
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	Else
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	EndIf
	nTerHdl := FOPEN(df_ArqEtq,FO_WRITE)
	nTamArq := FSEEK(nTerHdl,0,0)

	// Visão 1 - Dados do arquivo (header) e cliente (empresa)
	dj_SqRmCh := Soma1(GetMV("MV_YSQRMCH"))
	dj_CtaBco := StrTran(MV_PAR03, "-", "")
	dj_CtaBco := StrTran(dj_CtaBco, ".", "")
	dj_CtaBco := If (cEmpAnt <> "14", StrZero(Val(Substr(dj_CtaBco, 1, Len(Alltrim(dj_CtaBco))-1)),11), StrZero(Val(Substr(dj_CtaBco, 1, Len(Alltrim(dj_CtaBco)))),11) )
	fr_Vis01 := +;
	Padr(Replicate("0",020)                               ,020)+;
	Padr(Replicate("0",002)                               ,002)+;
	Padr("0"                                              ,001)+;
	Padr(Substr(MV_PAR02,1,4)                             ,004)+;
	Padr(dj_CtaBco                                        ,011)+;
	Padr("EDO001"                                         ,006)+;
	Padr(Substr(MV_PAR04,1,12)                            ,012)+;
	Padr(dj_SqRmCh                                        ,006)+;
	Padr("00315"                                          ,005)+;
	Padr("00001"                                          ,005)+;
	Padr(Substr(MV_PAR05,1,4)                             ,004)+;
	Padr(Substr(MV_PAR05,5,2)                             ,002)+;
	Padr("00"                                             ,002)+;
	Padr(GravaData(MV_PAR06,.F.,5)                        ,008)+;
	Padr(Replicate(" ",012)                               ,012)
	FWRITE(nTerHdl,  fr_Vis01 + CRLF )

	dj_Matr := Space(06)
	dj_SeqLn := 0
	dj_NDest := 0
	dj_TtVen := 0
	dj_TtDes := 0

	If MV_PAR10 == 1                                         // Mensais

		A0001 := " SELECT RC_MAT MATR,
		A0001 += "        RC_PD VERB,
		A0001 += "        REPLACE(REPLACE(REPLACE(REPLACE(RV_DESC,'ª',''),'º',''),'§',''),'*','') DECR,
		A0001 += "        RC_HORAS HRS,
		A0001 += "        RC_VALOR VLR,
		A0001 += "        RV_TIPOCOD,
		A0001 += "        CASE
		A0001 += "          WHEN RV_TIPOCOD = '1' THEN 'P'
		A0001 += "          WHEN RV_TIPOCOD = '2' THEN 'D'
		A0001 += "          WHEN RV_COD 	= '066' THEN 'D'	
		A0001 += "          WHEN RV_TIPOCOD = '3' THEN 'B'
		A0001 += "        END TIPVR,
		A0001 += "        (SELECT COUNT(*) CONTAD
		A0001 += "           FROM "+RetSqlName("SRC")+" XXX
		A0001 += "          INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                               AND RV_COD = RC_PD
		A0001 += "                               AND RV_TIPOCOD IN('1','2')
		A0001 += "                               AND SRV.D_E_L_E_T_ = ' '
		A0001 += "          WHERE XXX.RC_FILIAL = '"+xFilial("SRC")+"'
		A0001 += "            AND XXX.RC_MAT = SRC.RC_MAT
		A0001 += "            AND XXX.D_E_L_E_T_ = ' ') QTDLIN
		A0001 += "   FROM "+RetSqlName("SRC")+" SRC
		A0001 += "  INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                       AND RV_COD = RC_PD
		A0001 += "                       AND ((RV_TIPOCOD IN('1','2')) OR (RV_COD = '066'))
		A0001 += "                       AND SRV.D_E_L_E_T_ = ' '
		A0001 += "  WHERE RC_FILIAL = '"+xFilial("SRC")+"'
		A0001 += "    AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
		A0001 += "    AND RC_ROTEIR <> '132'
		A0001 += "    AND SRC.D_E_L_E_T_ = ' '

	ElseIf MV_PAR10 == 2                                     // Acumulados

		A0001 := " SELECT RD_MAT MATR,
		A0001 += "        RD_PD VERB,
		A0001 += "        REPLACE(REPLACE(REPLACE(REPLACE(RV_DESC,'ª',''),'º',''),'§',''),'*','') DECR,
		A0001 += "        RD_HORAS HRS,
		A0001 += "        RD_VALOR VLR,
		A0001 += "        RV_TIPOCOD,
		A0001 += "        CASE
		A0001 += "          WHEN RV_TIPOCOD = '1' THEN 'P'
		A0001 += "          WHEN RV_TIPOCOD = '2' THEN 'D'
		A0001 += "          WHEN RV_COD 	= '066' THEN 'D'	
		A0001 += "          WHEN RV_TIPOCOD = '3' THEN 'B'
		A0001 += "        END TIPVR,
		A0001 += "        (SELECT COUNT(*) CONTAD
		A0001 += "           FROM "+RetSqlName("SRD")+" XXX
		A0001 += "          INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                               AND RV_COD = RD_PD
		A0001 += "                               AND RV_TIPOCOD IN('1','2')
		A0001 += "                               AND SRV.D_E_L_E_T_ = ' '
		A0001 += "          WHERE XXX.RD_FILIAL = '"+xFilial("SRD")+"'
		A0001 += "            AND XXX.RD_MAT = SRD.RD_MAT
		A0001 += "            AND XXX.RD_DATARQ = '"+MV_PAR05+"'
		A0001 += "            AND XXX.D_E_L_E_T_ = ' ') QTDLIN
		A0001 += "   FROM "+RetSqlName("SRD")+" SRD
		A0001 += "  INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                       AND RV_COD = RD_PD
		A0001 += "                       AND ((RV_TIPOCOD IN('1','2')) OR (RV_COD = '066'))
		A0001 += "                       AND SRV.D_E_L_E_T_ = ' '
		A0001 += "  WHERE RD_FILIAL = '"+xFilial("SRD")+"'
		A0001 += "    AND RD_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
		A0001 += "    AND RD_DATARQ = '"+MV_PAR05+"'
		A0001 += "    AND SRD.D_E_L_E_T_ = ' '

	ElseIf MV_PAR10 == 3                                     // Segunda Parcela de 13

		A0001 := " SELECT RC_MAT MATR,
		A0001 += "        RC_PD VERB,
		A0001 += "        RV_DESC DECR,
		A0001 += "        RC_HORAS HRS,
		A0001 += "        RC_VALOR VLR,
		A0001 += "        RV_TIPOCOD,
		A0001 += "        CASE
		A0001 += "          WHEN RV_TIPOCOD = '1' THEN 'P'
		A0001 += "          WHEN RV_TIPOCOD = '2' THEN 'D'
		A0001 += "          WHEN RV_TIPOCOD = '3' THEN 'B'
		A0001 += "        END TIPVR,
		A0001 += "        (SELECT COUNT(*) CONTAD
		A0001 += "           FROM "+RetSqlName("SRC")+" XXX
		A0001 += "          INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                               AND RV_COD = RC_PD
		A0001 += "                               AND RV_TIPOCOD IN ('1','2')
		A0001 += "                               AND SRV.D_E_L_E_T_ = ' '
		A0001 += "          WHERE XXX.RC_FILIAL = '"+xFilial("SRC")+"'
		A0001 += "            AND XXX.RC_MAT = SRC.RC_MAT
		A0001 += "            AND XXX.D_E_L_E_T_ = ' ') QTDLIN
		A0001 += "   FROM "+RetSqlName("SRC")+" SRC
		A0001 += "  INNER JOIN "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
		A0001 += "                       AND RV_COD = RC_PD
		A0001 += "                       AND RV_TIPOCOD IN ('1','2')
		A0001 += "                       AND SRV.D_E_L_E_T_ = ' '
		A0001 += "  WHERE RC_FILIAL = '"+xFilial("SRC")+"'
		A0001 += "    AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
		A0001 += "    AND RC_ROTEIR = '132'	
		A0001 += "    AND SRC.D_E_L_E_T_ = ' '

	EndIf

	A0001 += "  ORDER BY MATR, RV_TIPOCOD, VERB
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processando!   Matricula: " + A001->MATR)

		SRA->(dbSetOrder(1))
		SRA->(dbSeek(xFilial("SRA")+A001->MATR))

		// Tratamento para atender o ticket 1386
		If SRA->RA_SITFOLH == "D"
			dbSelectArea("A001")
			dbSkip()
			Loop		
		EndIf

		If Substr(SRA->RA_BCDEPSA,1,3) == "001" // Somente conta cadastradas no Banco do Brasil

			If dj_Matr <> A001->MATR

				dj_SeqLn := 0
				dj_NDest ++
				dj_Matr  := A001->MATR
				dj_TtVen := 0
				dj_TtDes := 0

				SRA->(dbSetOrder(1))
				SRA->(dbSeek(xFilial("SRA")+dj_Matr))

				// Visão 2 - Dados do destinatário
				// Soma SEIS linhas no total de linhas para as verbas porque é necessários informar uma verba avulsa de totalizados e outras informações do cabec
				// Como foi retirado o Salário Base tem que voltar a cinco linhas. em 06/03/12
				gt_LinAd := 6
				fr_Vis02 := +;
				Padr(StrZero(Val(dj_Matr),20)                         ,020)+;
				Padr(Replicate("0",002)                               ,002)+;
				Padr("1"                                              ,001)+;
				Padr(Substr(SRA->RA_BCDEPSA,4,4)                      ,004)+;
				Padr(StrZERO(Val(Substr(SRA->RA_CTDEPSA,2,10)),11)    ,011)+;
				Padr(StrZero(A001->QTDLIN + gt_LinAd,2)               ,002)+;
				Padr(SRA->RA_NOME                                     ,040)+;
				Padr(SRA->RA_CIC                                      ,011)+;
				Padr(Replicate(" ",009)                               ,009)
				FWRITE(nTerHdl,  fr_Vis02 + CRLF )

				// Visão 3 - Dados do documento - Cabeçalho de Informações de Empresa e Empregado
				dj_Cabec := {}
				aadd(dj_Cabec, {"Empresa: " + Alltrim(SM0->M0_NOMECOM)} )
				aadd(dj_Cabec, {"Cnpj: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") } )
				aadd(dj_Cabec, {"Matric: " + dj_Matr + " " + Alltrim(SRA->RA_NOME) } )
				aadd(dj_Cabec, {"Funcao: " + Posicione("SRJ", 1, xFilial("SRJ")+SRA->RA_CODFUNC, "RJ_DESC") } )
				aadd(dj_Cabec, {"Periodo: " + MesExtenso(Substr(MV_PAR05,5,2)) + " de "+ Substr(MV_PAR05,1,4) } )

				For i := 1 to Len(dj_Cabec)
					dj_SeqLn ++
					dj_TxtDc := dj_Cabec[i][1]
					fr_Vis03 := +;
					Padr(StrZero(Val(dj_Matr),20)                         ,020)+;
					Padr(StrZero(dj_SeqLn,2)                              ,002)+;
					Padr("2"                                              ,001)+;
					Padr(dj_TxtDc                                         ,048)+;
					Padr("0"                                              ,001)+;
					Padr(Replicate(" ",028)                               ,028)
					FWRITE(nTerHdl,  fr_Vis03 + CRLF )
				Next i

			EndIf

			// Visão 3 - Dados do documento - Verbas
			dj_SeqLn ++
			dj_TxtDc := A001->TIPVR+" "+A001->VERB+"-"+PADR(A001->DECR,TAMSX3("RV_DESC")[1])+"  "+Transform(A001->HRS, "@E 9999.99")+"  "+Transform(A001->VLR, "@E 9999,999.99")
			fr_Vis03 := +;
			Padr(StrZero(Val(dj_Matr),20)                         ,020)+;
			Padr(StrZero(dj_SeqLn,2)                              ,002)+;
			Padr("2"                                              ,001)+;
			Padr(dj_TxtDc                                         ,048)+;
			Padr("0"                                              ,001)+;
			Padr(Replicate(" ",028)                               ,028)
			FWRITE(nTerHdl,  fr_Vis03 + CRLF )

			If A001->RV_TIPOCOD == "1"
				dj_TtVen += A001->VLR
			ElseIf A001->RV_TIPOCOD == "2" .Or. A001->VERB == '066'
				dj_TtDes += A001->VLR
			EndIf

			dbSelectArea("A001")
			dbSkip()

			// Visão 3 - Dados do documento -- Totalizador Liquido a Receber
			If dj_Matr <> A001->MATR
				gt_VlrLq := dj_TtVen-dj_TtDes
				gt_VlrLq := IIF(gt_VlrLq < 0, 0, gt_VlrLq)
				dj_SeqLn ++
				dj_TxtDc := "T"+" "+"799"+"-"+"LIQUIDO A RECEBER   "+"  "+Transform(0, "@E 9999.99")+"  "+Transform(gt_VlrLq, "@E 9999,999.99")
				fr_Vis03 := +;
				Padr(StrZero(Val(dj_Matr),20)                         ,020)+;
				Padr(StrZero(dj_SeqLn,2)                              ,002)+;
				Padr("2"                                              ,001)+;
				Padr(dj_TxtDc                                         ,048)+;
				Padr("0"                                              ,001)+;
				Padr(Replicate(" ",028)                               ,028)
				FWRITE(nTerHdl,  fr_Vis03 + CRLF )
			EndIf

		Else
			dbSelectArea("A001")
			dbSkip()
		EndIf

	End
	A001->(dbCloseArea())

	// Visão 4 - Dados de fechamento do arquivo
	fr_Vis04 := +;
	Padr(Replicate("9",020)                               ,020)+;
	Padr(Replicate("9",002)                               ,002)+;
	Padr("9"                                              ,001)+;
	Padr(Replicate("9",015)                               ,015)+;
	Padr(StrZero(dj_NDest,11)                             ,011)+;
	Padr(Replicate(" ",051)                               ,051)
	FWRITE(nTerHdl,  fr_Vis04 + CRLF )

	FCLOSE(nTerHdl)

	PutMV("MV_YSQRMCH", dj_SqRmCh )

	MsgINFO("Arquivo: " + df_ArqEtq + " foi gerado!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Banco                  ?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA6"})
	aAdd(aRegs,{cPerg,"02","Agência                ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Conta                  ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Contrato Contracheque  ?","","","mv_ch4","C",12,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano - Mes Referência   ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Data do Crédito        ?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Da Matricula           ?","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"08","Ate Matricula          ?","","","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"09","Caminha p/ gravação Arq?","","","mv_ch9","C",40,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Lançamentos            ?","","","mv_cha","N",01,0,0,"C","","mv_par10","Mensais","","","","","Acumulados","","","","","Seg. Parc 13","","","","","","","","","","","","","",""})

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
