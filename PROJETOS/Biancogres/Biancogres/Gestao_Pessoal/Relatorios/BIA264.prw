#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA264()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA264
Empresa   := Biancogres Cerâmica S/A
Data      := 31/08/11
Uso       := Gestão de Pessoal
Aplicação := Impressão de etiquetas para preenchimento da carteira de tra-
.            balho
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Private NpTToDlg
Private oButton1
Private oGet1
Private nGet1 := 0
Private oSay1
Private cEspecialidade := ''

cHInicio := Time()
fPerg := "BIA264"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
fCabec   := "Etiquetas Diversas"

wnPag    := 0
nRow1    := 0

oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7n  := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetPortrait()
oPrint:Setup()

cTempo := Alltrim(ElapTime(cHInicio, Time()))
IncProc("Armazenando....   Tempo: "+cTempo)

If MV_PAR01 == "01"
	*********************************************************************************** // Contrato de Trabalho
	// Referencia Pimaco 8296 --> MÁXIMOS 3 linhas, 3 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 100
	yk_LinIn2 := 1050
	yk_LinIn3 := 2025
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 10
	yk_ColIn2 := 850
	yk_ColIn3 := 1750
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_NOME,
	A0001 += "        RJ_DESC,
	A0001 += "        RJ_CODCBO RA_CBO,
	A0001 += "        RA_CATFUNC,
	A0001 += "        RA_ADMISSA,
	A0001 += "        RA_MAT,
	A0001 += "        RA_SALARIO,
	A0001 += "        RA_PERICUL,
	A0001 += "        RA_ADCINS
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "  INNER JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"'
	A0001 += "                       AND RJ_FUNCAO = RA_CODFUNC
	A0001 += "                       AND SRJ.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_ADMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND RA_DEMISSA = '        '
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		ik_Pericu := IIF(A001->RA_PERICUL <> 0, " soma ao salário 30% de periculosidade", "")
		ik_InsMed := IIF(A001->RA_ADCINS == "3", " soma ao salário 20% de insalubridade", "")
		ik_InsMax := IIF(A001->RA_ADCINS == "4", " soma ao salário 40% de insalubridade", "")
		
		ik_TpPgto := IIF(A001->RA_CATFUNC $ "M*C", " POR MES", IIF(A001->RA_CATFUNC == "H", " POR HRS", " POR DIA"))
		ik_SalExt := "R$ " + Alltrim(Transform(A001->RA_SALARIO,"@E 999,999,999.99")) +" ("+ Alltrim(Extenso(A001->RA_SALARIO)) +") "+ ik_Pericu + ik_InsMed + ik_InsMax + ik_TpPgto
		ik_MunEst := Alltrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB
		
//		oPrint:Say  (nRow1, nCol1, "Empregador..: "+SM0->M0_NOMECOM                                 , oFont7)
		IF cEmpAnt == "07"
			oPrint:Say  (nRow1, nCol1, "Empregador..: "+SUBSTRING(Alltrim(SM0->M0_NOMECOM),1,28)               , oFont7)
			nRow1 += 50
			oPrint:Say  (nRow1, nCol1, SUBSTRING(Alltrim(SM0->M0_NOMECOM),29,50)               , oFont7)
			nRow1 += 50
			cEspecialidade := "COMÉRCIO ATACADISTA DE MATERIAIS DE CONSTRUÇÃO EM GERAL"
		Else
			oPrint:Say  (nRow1, nCol1, "Empregador..: "+SM0->M0_NOMECOM                                 , oFont7)
			nRow1 += 50
			cEspecialidade := "FABRICAÇÃO DE AZULEJOS E PISOS"
		Endif
		oPrint:Say  (nRow1, nCol1, "C.N.P.J.....: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")  , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Endereço....: "+Alltrim(SM0->M0_ENDCOB)                         , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Bairro......: "+Alltrim(SM0->M0_BAIRCOB)                        , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Município...: "+Substr(ik_MunEst,1,35)                          , oFont7)
		nRow1 += 50
		If !Empty(Substr(ik_MunEst,36,25))
			oPrint:Say  (nRow1, nCol1, "              "+Substr(SM0->M0_CIDCOB,36,25)                , oFont7)
			nRow1 += 50
		EndIf
		
		oPrint:Say  (nRow1, nCol1, "Esp.Estab...: "+cEspecialidade									, oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Empregado...: "+A001->RA_NOME                                   , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Cargo.......: "+A001->RJ_DESC                                   , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "C.B.O.......: "+A001->RA_CBO                                    , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Admissão....: "+dtoc(stod(A001->RA_ADMISSA))                    , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Registro....: "+A001->RA_MAT                                    , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Remuneração.: "+Substr(ik_SalExt, 1, 35)                        , oFont7)
		nRow1 += 50
		If !Empty(Substr(ik_SalExt,36,35))
			oPrint:Say  (nRow1, nCol1, Substr(ik_SalExt, 36, 49)                                      , oFont7)
			nRow1 += 50
		EndIf
		If !Empty(Substr(ik_SalExt,71,35))
			oPrint:Say  (nRow1, nCol1, Substr(ik_SalExt, 85, 49)                                      , oFont7)
			nRow1 += 50
		EndIf
		If !Empty(Substr(ik_SalExt,106,35))
			oPrint:Say  (nRow1, nCol1, Substr(ik_SalExt,134, 49)                                      , oFont7)
			nRow1 += 50
		EndIf
		If !Empty(Substr(ik_SalExt,141,35))
			oPrint:Say  (nRow1, nCol1, Substr(ik_SalExt,183, 49)                                      , oFont7)
			nRow1 += 50
		EndIf
		//If !Empty(Substr(ik_SalExt,176,35))
		//	oPrint:Say  (nRow1, nCol1, "              "+Substr(ik_SalExt,176, 35)                     , oFont7)
		//	nRow1 += 50
		//EndIf
		
		oPrint:Say  (nRow1, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),50)                                 , oFont7)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 3
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "02"
	*********************************************************************************** // Contrato de Experiência
	// Referencia Pimaco 8296 --> MÁXIMOS 3 linhas, 3 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 100
	yk_LinIn2 := 1050
	yk_LinIn3 := 2025
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 10
	yk_ColIn2 := 850
	yk_ColIn3 := 1750
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_FILIAL,
	A0001 += "        RA_MAT,
	A0001 += "        RA_NUMCP,
	A0001 += "        RA_SERCP,
	A0001 += "        RA_ADMISSA,
	A0001 += "        RA_VCTOEXP,
	A0001 += "        RA_VCTEXP2
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_ADMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND RA_DEMISSA = '        '
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		ik_Lin01 := "Fl: " + A001->RA_FILIAL +"  "+ "Mat.: " + A001->RA_MAT +"  "+ IIF(cPaisLoc == "BRA", "Cart.Prof.:"+Alltrim(A001->RA_NUMCP)+"/"+Alltrim(A001->RA_SERCP), "")
		oPrint:Say  (nRow1, nCol1, ik_Lin01                                                         , oFont7n)
		nRow1 += 50
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "O portador da presente CTPS foi admitido em "                   , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, dtoc(stod(A001->RA_ADMISSA))+" por um período de 45 dias, con-"  , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "forme contrato de trabalho  a título de ex-"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "periência e não havendo manifestação de ne-"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "nhuma das partes fica o presente prorrogado"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "automaticamente por igual período."                             , oFont7n)
		nRow1 += 30
		nRow1 += 30
		
		oPrint:Say  (nRow1+200, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),50)                            , oFont7n)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 3
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armazenando....   Tempo: "+cTempo)
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "03"
	*********************************************************************************** // Registro de FGTS
	// Referencia Pimaco A4360 --> MÁXIMOS 7 linhas, 3 colunas
	oPrint:SetPaperSize(9)
	yk_LinIn1 := 85
	yk_LinIn2 := 560
	yk_LinIn3 := 1035
	yk_LinIn4 := 1510
	yk_LinIn5 := 2000
	yk_LinIn6 := 2480
	yk_LinIn7 := 2955
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	ElseIf MV_PAR02 == 4
		nRow1 := yk_LinIn4 + 20
	ElseIf MV_PAR02 == 5
		nRow1 := yk_LinIn5 + 20
	ElseIf MV_PAR02 == 6
		nRow1 := yk_LinIn6 + 20
	ElseIf MV_PAR02 == 7
		nRow1 := yk_LinIn7 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 30
	yk_ColIn2 := 850
	yk_ColIn3 := 1675
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_NOME,
	A0001 += "        RA_OPCAO,
	A0001 += "        RA_BCDPFGT,
	A0001 += "        A6_AGENCIA,
	A0001 += "        A6_NOMEAGE,
	A0001 += "        A6_NREDUZ,
	A0001 += "        A6_NOME,
	A0001 += "        A6_MUN,
	A0001 += "        A6_EST,
	A0001 += "        RA_MAT
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "   LEFT JOIN "+RetSqlName("SA6")+" SA6 ON A6_FILIAL = '"+xFilial("SA6")+"'
	A0001 += "                       AND A6_COD = SUBSTRING(RA_BCDPFGT,1,3)
	A0001 += "                       AND A6_AGENCIA = SUBSTRING(RA_BCDPFGT,4,5)
	A0001 += "                       AND A6_EST <> '  '
	A0001 += "                       AND SA6.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_ADMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND RA_DEMISSA = '        '
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_NOME+"  Tempo: "+cTempo)
		
		oPrint:Say  (nRow1, nCol1, "Empregado: "+A001->RA_NOME                                      , oFont8)
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "     OPÇÃO              RETRATAÇÃO     "                        , oFont8)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "   "+dtoc(stod(A001->RA_OPCAO))                                 , oFont8)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "Banco Depositário: "+A001->RA_BCDPFGT+" "+A001->A6_NREDUZ       , oFont8)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "Agência: "+A6_AGENCIA+" "+A001->A6_NOMEAGE                      , oFont8)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "Praça: "+Alltrim(A001->A6_MUN)+" - "+ A001->A6_EST              , oFont8)
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),40)                                , oFont8)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 7
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "04"
	*********************************************************************************** // Rescisão de Contrato
	// Referencia Pimaco A4360 --> MÁXIMOS 7 linhas, 3 colunas
	oPrint:SetPaperSize(9)
	yk_LinIn1 := 85
	yk_LinIn2 := 560
	yk_LinIn3 := 1035
	yk_LinIn4 := 1510
	yk_LinIn5 := 2000
	yk_LinIn6 := 2480
	yk_LinIn7 := 2955
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	ElseIf MV_PAR02 == 4
		nRow1 := yk_LinIn4 + 20
	ElseIf MV_PAR02 == 5
		nRow1 := yk_LinIn5 + 20
	ElseIf MV_PAR02 == 6
		nRow1 := yk_LinIn6 + 20
	ElseIf MV_PAR02 == 7
		nRow1 := yk_LinIn7 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 30
	yk_ColIn2 := 850
	yk_ColIn3 := 1675
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_MAT,
	A0001 += "        RA_NOME,
	A0001 += "        RA_DEMISSA,
	A0001 += "        RG_TIPORES,
	A0001 += "        RG_DTAVISO,
	A0001 += "        RG_TIPORES
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "  INNER JOIN "+RetSqlName("SRG")+" SRG ON RG_FILIAL = '"+xFilial("SRG")+"'
	A0001 += "                       AND RG_MAT = RA_MAT
	A0001 += "                       AND SRG.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_DEMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_NOME
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		// Regra substituida em 20/07/12 conforme Effettivo 1573-12
		//ik_DtSai := IIF(A001->RA_DEMISSA == A001->RG_DTAVISO , stod(A001->RA_DEMISSA)+30 , stod(A001->RA_DEMISSA) )
		ik_DtSai := ""
		If A001->RG_TIPORES $ "01/07/11/12"
			ik_DtSai := stod(A001->RA_DEMISSA)
		ElseIf A001->RA_DEMISSA == A001->RG_DTAVISO
			
			xDAviso := 0
			TR004 := " SELECT RG_DAVISO
			TR004 += "   FROM " + RetSqlName("SRG")
			TR004 += "  WHERE RG_FILIAL = '"+xFilial("SRG")+"'
			TR004 += "    AND RG_MAT = '"+A001->RA_MAT+"'
			TR004 += "    AND D_E_L_E_T_ = ' '
			TcQuery TR004 New Alias "TR04"
			dbSelectArea("TR04")
			dbGoTop()
			xDAviso := TR04->RG_DAVISO
			TR04->(dbCloseArea())
			
			ik_DtSai := stod(A001->RA_DEMISSA) + xDAviso
			
		Else
			ik_DtSai := stod(A001->RA_DEMISSA)
		EndIf
		
		oPrint:Say  (nRow1, nCol1, "Empregado: "+A001->RA_NOME                                      , oFont8)
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "Data da Saída: "+dtoc(ik_DtSai)                                 , oFont8)
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),40)                                , oFont8)
		nRow1 += 30
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "COM DISPENSA CD NUMERO _ _ _ _ _ _ _ _ _"                       , oFont8)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 7
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "05"
	*********************************************************************************** // Ultimo dia Efetivamente Trabalhado
	// Referencia Pimaco A4360 --> MÁXIMOS 7 linhas, 3 colunas
	oPrint:SetPaperSize(9)
	yk_LinIn1 := 85
	yk_LinIn2 := 560
	yk_LinIn3 := 1035
	yk_LinIn4 := 1510
	yk_LinIn5 := 2000
	yk_LinIn6 := 2480
	yk_LinIn7 := 2955
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	ElseIf MV_PAR02 == 4
		nRow1 := yk_LinIn4 + 20
	ElseIf MV_PAR02 == 5
		nRow1 := yk_LinIn5 + 20
	ElseIf MV_PAR02 == 6
		nRow1 := yk_LinIn6 + 20
	ElseIf MV_PAR02 == 7
		nRow1 := yk_LinIn7 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 30
	yk_ColIn2 := 850
	yk_ColIn3 := 1675
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_FILIAL,
	A0001 += "        RA_MAT,
	A0001 += "        RA_NUMCP,
	A0001 += "        RA_SERCP,
	A0001 += "        RA_NOME,
	A0001 += "        RA_DEMISSA
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_DEMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		ik_Lin01 := "Fl: " + A001->RA_FILIAL +"  "+ "Mat.: " + A001->RA_MAT +"  "+ IIF(cPaisLoc == "BRA", "Cart.Prof.:"+Alltrim(A001->RA_NUMCP)+"/"+Alltrim(A001->RA_SERCP), "")
		
		oPrint:Say  (nRow1, nCol1, ik_Lin01                                                         , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "Em cumprimento a IN SRT Nº 15, de 14/07/10,"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "art. 17, Inciso II, parágrafo único, imfor-"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "mos que a data do último  dia  efetivamente"                    , oFont7n)
		nRow1 += 30
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, "trabalhado foi em "+dtoc(stod(A001->RA_DEMISSA))                , oFont7n)
		
		oPrint:Say  (nRow1+100, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),50)                            , oFont7n)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 7
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "06"
	*********************************************************************************** // Anotação de Férias
	// Referencia Pimaco 6287 --> MÁXIMOS 20 linhas, 4 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 065
	yk_LinIn2 := 225
	yk_LinIn3 := 385
	yk_LinIn4 := 545
	yk_LinIn5 := 705
	yk_LinIn6 := 865
	yk_LinIn7 := 1035
	yk_LinIn8 := 1200
	yk_LinIn9 := 1365
	yk_LinIn10 := 1530
	yk_LinIn11 := 1695
	yk_LinIn12 := 1860
	yk_LinIn13 := 2025
	yk_LinIn14 := 2190
	yk_LinIn15 := 2355
	yk_LinIn16 := 2520
	yk_LinIn17 := 2680
	yk_LinIn18 := 2840
	yk_LinIn19 := 3000
	yk_LinIn20 := 3160
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	ElseIf MV_PAR02 == 4
		nRow1 := yk_LinIn4 + 20
	ElseIf MV_PAR02 == 5
		nRow1 := yk_LinIn5 + 20
	ElseIf MV_PAR02 == 6
		nRow1 := yk_LinIn6 + 20
	ElseIf MV_PAR02 == 7
		nRow1 := yk_LinIn7 + 20
	ElseIf MV_PAR02 == 8
		nRow1 := yk_LinIn8 + 20
	ElseIf MV_PAR02 == 9
		nRow1 := yk_LinIn9 + 20
	ElseIf MV_PAR02 == 10
		nRow1 := yk_LinIn10 + 20
	ElseIf MV_PAR02 == 11
		nRow1 := yk_LinIn11 + 20
	ElseIf MV_PAR02 == 12
		nRow1 := yk_LinIn12 + 20
	ElseIf MV_PAR02 == 13
		nRow1 := yk_LinIn13 + 20
	ElseIf MV_PAR02 == 14
		nRow1 := yk_LinIn14 + 20
	ElseIf MV_PAR02 == 15
		nRow1 := yk_LinIn15 + 20
	ElseIf MV_PAR02 == 16
		nRow1 := yk_LinIn16 + 20
	ElseIf MV_PAR02 == 17
		nRow1 := yk_LinIn17 + 20
	ElseIf MV_PAR02 == 18
		nRow1 := yk_LinIn18 + 20
	ElseIf MV_PAR02 == 19
		nRow1 := yk_LinIn19 + 20
	ElseIf MV_PAR02 == 20
		nRow1 := yk_LinIn20 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 100
	yk_ColIn2 := 720
	yk_ColIn3 := 1340
	yk_ColIn4 := 1960
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	ElseIf MV_PAR03 == 4
		nCol1 := yk_ColIn4 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_FILIAL,
	A0001 += "        RA_MAT,
	A0001 += "        RA_NUMCP,
	A0001 += "        RA_SERCP,
	A0001 += "        RH_DATABAS,
	A0001 += "        RH_DBASEAT,
	A0001 += "        RH_DATAINI,
	A0001 += "        RH_DATAFIM,
	A0001 += "        RH_DABONPE
	A0001 += "   FROM "+RetSqlName("SRH")+" SRH
	A0001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "                       AND RA_MAT = RH_MAT
	A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RH_FILIAL = '"+xFilial("SRH")+"'
	A0001 += "    AND RH_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RH_DATAINI BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND SRH.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		ik_Abono := IIF(A001->RH_DABONPE > 0, dtoc(stod(A001->RH_DATAFIM)+1) +" a "+ dtoc(stod(A001->RH_DATAFIM)+A001->RH_DABONPE), "Não")
		zk_Lin01 := "Mat: " + A001->RA_MAT +"  "+ IIF(cPaisLoc == "BRA", "CTPS:"+Alltrim(A001->RA_NUMCP)+"/"+Alltrim(A001->RA_SERCP), "")
		zk_Lin02 := "Aquisitivo " + dtoc(stod(A001->RH_DATABAS)) +" a " + dtoc(stod(A001->RH_DBASEAT))
		zk_Lin03 := "Gozo       " + dtoc(stod(A001->RH_DATAINI)) +" a " + dtoc(stod(A001->RH_DATAFIM))
		zk_Lin04 := "Abono      " + ik_Abono
		
		oPrint:Say  (nRow1, nCol1, zk_Lin01                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin02                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin03                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin04                                                         , oFont7n)
		nRow1 += 30
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3 .or. nRefCol == 4
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 4
			nRefCol := 1
			nRefRow ++
			If nRefRow > 20
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "07"
	*********************************************************************************** // Histórico Salarial
	// Referencia Pimaco 6287 --> MÁXIMOS 20 linhas, 4 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 070
	yk_LinIn2 := 390
	yk_LinIn3 := 710
	yk_LinIn4 := 1040
	yk_LinIn5 := 1370
	yk_LinIn6 := 1700
	yk_LinIn7 := 2030
	yk_LinIn8 := 2360
	yk_LinIn9 := 2685
	yk_LinIn10 := 3005
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	ElseIf MV_PAR02 == 4
		nRow1 := yk_LinIn4 + 20
	ElseIf MV_PAR02 == 5
		nRow1 := yk_LinIn5 + 20
	ElseIf MV_PAR02 == 6
		nRow1 := yk_LinIn6 + 20
	ElseIf MV_PAR02 == 7
		nRow1 := yk_LinIn7 + 20
	ElseIf MV_PAR02 == 8
		nRow1 := yk_LinIn8 + 20
	ElseIf MV_PAR02 == 9
		nRow1 := yk_LinIn9 + 20
	ElseIf MV_PAR02 == 10
		nRow1 := yk_LinIn10 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 10
	yk_ColIn2 := 890
	yk_ColIn3 := 1790
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_FILIAL,
	A0001 += "        RA_MAT,
	A0001 += "        RA_NUMCP,
	A0001 += "        RA_SERCP,
	A0001 += "        RA_CATFUNC,
	A0001 += "        R3_DATA,
	A0001 += "        R3_VALOR,
	A0001 += "        R3_TIPO,
	A0001 += "        R7_FUNCAO
	A0001 += "   FROM "+RetSqlName("SR3")+" SR3
	A0001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "                       AND RA_MAT = R3_MAT
	A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  INNER JOIN "+RetSqlName("SR7")+" SR7 ON R7_FILIAL = '"+xFilial("SR7")+"'
	A0001 += "                       AND R7_MAT = R3_MAT
	A0001 += "                       AND R7_DATA = R3_DATA
	A0001 += "                       AND SR7.D_E_L_E_T_ = ' '
	A0001 += "  WHERE R3_FILIAL = '"+xFilial("SR3")+"'
	A0001 += "    AND R3_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND R3_DATA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND R3_PD = '000'
	A0001 += "    AND SR3.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
		
		dbSelectArea( "SX5" )
		If dbSeek( xFilial( "SX5" ) + "41" + A001->R3_TIPO )
			cMotivo := fTAcento( SubStr(SX5->X5_DESCRI,1,15) )
		Else
			cMotivo := "Nao Cad.Tab. 41"
		Endif
		cFun:= DescFun(A001->R7_FUNCAO,A001->RA_FILIAL)
		If Empty(cFun)
			cFun:= "*** Nao Cadastrado ***"
		Endif
		cTipPagto := If(A001->RA_CATFUNC$"M*C"," POR MES",IIF(A001->RA_CATFUNC="H"," POR HRS"," POR DIA"))
		dbSelectArea("A001")
		zk_Lin01 := "Aumentado em " + dtoc(stod(A001->R3_DATA)) + " p/ " + Alltrim(Transform(A001->R3_VALOR,"@E 999,999,999.99")) + cTipPagto
		zk_Lin02 := "Função: " + cFun + IIF(cPaisLoc == "BRA", "C.B.O. " + fCodCBO(A001->RA_FILIAL,A001->R7_FUNCAO,stod(A001->R3_DATA)),"")
		zk_Lin03 := "Por Motivo de " + cMotivo
		zk_Lin04 := "Mat: "+ A001->RA_MAT +"  "+ SM0->M0_NOMECOM
		
		oPrint:Say  (nRow1, nCol1, zk_Lin01                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin02                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin03                                                         , oFont7n)
		nRow1 += 30
		oPrint:Say  (nRow1, nCol1, zk_Lin04                                                         , oFont7n)
		nRow1 += 30
		
		
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 10
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "08"
	*********************************************************************************** // Termo de Transferência
	// Referencia Pimaco 8296 --> MÁXIMOS 3 linhas, 3 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 050
	yk_LinIn2 := 0925
	yk_LinIn3 := 1850
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 10
	yk_ColIn2 := 850
	yk_ColIn3 := 1750
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_ADMISSA,
	A0001 += "        RE_MATP,
	A0001 += "        RE_DATA,
	A0001 += "        RE_EMPD,
	A0001 += "        RE_FILIALD,
	A0001 += "        RE_EMPP,
	A0001 += "        RE_FILIALP
	A0001 += "   FROM "+RetSqlName("SRE")+" SRE
	A0001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "                       AND RA_MAT = RE_MATP
	A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RE_FILIAL = '"+xFilial("SRE")+"'
	A0001 += "    AND RE_MATP BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RE_DATA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND SRE.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RE_MATP
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RE_MATP+"  Tempo: "+cTempo)
		
		dbSelectarea("SM0")
		yhRegSM0 := Recno()
		dbSetOrder(1)
		dbSeek(A001->RE_EMPD+A001->RE_FILIALD)
		yhNomeD := SM0->M0_NOMECOM
		yhCnpjD := SM0->M0_CGC
		dbSetOrder(1)
		dbSeek(A001->RE_EMPP+A001->RE_FILIALP)
		yhNomeP := SM0->M0_NOMECOM
		yhCnpjP := SM0->M0_CGC
		dbgoTo(yhRegSM0)
		
		DEFINE MSDIALOG NpTToDlg TITLE "Número de Página" FROM 000, 000  TO 070, 400 COLORS 0, 16777215 PIXEL
		@ 014, 013 SAY oSay1 PROMPT "Informe o número da página: " SIZE 072, 007 OF NpTToDlg COLORS 0, 16777215 PIXEL
		@ 013, 090 MSGET oGet1 VAR nGet1 SIZE 053, 010 OF NpTToDlg PICTURE "@E 999999" COLORS 0, 16777215 PIXEL
		@ 011, 148 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF NpTToDlg ACTION (NpTToDlg:End()) PIXEL
		ACTIVATE MSDIALOG NpTToDlg
		
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "             TERMO DE TRANSFERÊNCIA                "                     , oFont7)
		nRow1 += 50
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Referente ao contrato de trabalho da página "+Alltrim(Str(nGet1))+":"    , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Em "+dtoc(stod(A001->RE_DATA))+" fica o empregado transferido da"        , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "empresa "+Alltrim(yhNomeD)+" -"                                          , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "CNPJ " + Transform(yhCnpjD, "@R 99.999.999/9999-99")                     , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "para a empresa "+Alltrim(yhNomeP)+" - "                                  , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "CNPJ " +  Transform(yhCnpjP, "@R 99.999.999/9999-99")                    , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "onde terá o número de registro "+A001->RE_MATP+", mantendo-se"           , oFont7)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "todos os direitos já adquiridos anteriormente pelo"                      , oFont7)
		If A001->RA_ADMISSA < '20130318'
			nRow1 += 50
			oPrint:Say  (nRow1, nCol1, "trabalhador, conforme cláusula 12 do termo aditivo"                      , oFont7)
			nRow1 += 50
			oPrint:Say  (nRow1, nCol1, "ao contrato de trabalho."                                                , oFont7)
		Else
			nRow1 += 50
			oPrint:Say  (nRow1, nCol1, "trabalhador, conforme cláusula 01 do contrato de"                        , oFont7)
			nRow1 += 50
			oPrint:Say  (nRow1, nCol1, "trabalho."                                                               , oFont7)
		EndIf
		nRow1 += 50
		
		nRow1 += 50
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),50)                                         , oFont7)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 3
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	
ElseIf MV_PAR01 == "11"
	*********************************************************************************** // Trabalho Externo
	// Referencia Pimaco 8296 --> MÁXIMOS 3 linhas, 3 colunas
	oPrint:SetPaperSize(1)
	yk_LinIn1 := 050
	yk_LinIn2 := 0925
	yk_LinIn3 := 1850
	nRefRow := MV_PAR02
	If MV_PAR02 == 1
		nRow1 := yk_LinIn1 + 20
	ElseIf MV_PAR02 == 2
		nRow1 := yk_LinIn2 + 20
	ElseIf MV_PAR02 == 3
		nRow1 := yk_LinIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Linha)!!!")
		Return
	EndIf
	
	yk_ColIn1 := 10
	yk_ColIn2 := 850
	yk_ColIn3 := 1750
	nRefCol := MV_PAR03
	If MV_PAR03 == 1
		nCol1 := yk_ColIn1 + 20
	ElseIf MV_PAR03 == 2
		nCol1 := yk_ColIn2 + 20
	ElseIf MV_PAR03 == 3
		nCol1 := yk_ColIn3 + 20
	Else
		MsgINFO("Erro na definição das etiquetas (Coluna)!!!")
		Return
	EndIf
	
	A0001 := " SELECT RA_NOME,
	A0001 += "        RJ_DESC,
	A0001 += "        RJ_CODCBO RA_CBO,
	A0001 += "        RA_CATFUNC,
	A0001 += "        RA_ADMISSA,
	A0001 += "        RA_MAT,
	A0001 += "        RA_SALARIO,
	A0001 += "        RA_PERICUL,
	A0001 += "        RA_ADCINS
	A0001 += "   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "  INNER JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"'
	A0001 += "                       AND RJ_FUNCAO = RA_CODFUNC
	A0001 += "                       AND SRJ.D_E_L_E_T_ = ' '
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_MAT BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	A0001 += "    AND RA_ADMISSA BETWEEN '"+dtos(MV_PAR06)+"' AND '"+dtos(MV_PAR07)+"'
	A0001 += "    AND RA_DEMISSA = '        '
	A0001 += "    AND SRA.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY RA_MAT
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armaz.... "+A001->RA_MAT+"  Tempo: "+cTempo)
				
		DEFINE MSDIALOG NpTToDlg TITLE "Número de Página" FROM 000, 000  TO 070, 400 COLORS 0, 16777215 PIXEL
		@ 014, 013 SAY oSay1 PROMPT "Informe o número da página: " SIZE 072, 007 OF NpTToDlg COLORS 0, 16777215 PIXEL
		@ 013, 090 MSGET oGet1 VAR nGet1 SIZE 053, 010 OF NpTToDlg PICTURE "@E 999999" COLORS 0, 16777215 PIXEL
		@ 011, 148 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF NpTToDlg ACTION (NpTToDlg:End()) PIXEL
		ACTIVATE MSDIALOG NpTToDlg
		
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "             DO TRABALHO EXTERNO                "                     , oFont7n)
		nRow1 += 50
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Referente ao contrato de trabalho da página " + Alltrim(Str(nGet1))    , oFont7n)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "Informamos que o colaborador por exercer", oFont7n)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "trabalho externo fica dispensado da marcação", oFont7n)
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, "de ponto, conforme Artigo 62 da CLT, " , oFont7n)
		nRow1 += 50		
		oPrint:Say  (nRow1, nCol1, "Inciso I." , oFont7n)
		
		nRow1 += 50
		nRow1 += 50
		oPrint:Say  (nRow1, nCol1, Padc(Alltrim(SM0->M0_NOMECOM),50)                                         , oFont7n)
		
		nRefCol ++
		If nRefCol == 2 .or. nRefCol == 3
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		ElseIf nRefCol > 3
			nRefCol := 1
			nRefRow ++
			If nRefRow > 3
				nRefRow := 1
				oPrint:EndPage()
			EndIf
			nRow1 := &("yk_LinIn"+Alltrim(Str(nRefRow))) + 20
			nCol1 := &("yk_ColIn"+Alltrim(Str(nRefCol))) + 20
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())	
	
EndIf

oPrint:EndPage()
oPrint:Preview()

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
aAdd(aRegs,{cPerg,"01","Etiqueta             ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","UC"})
aAdd(aRegs,{cPerg,"02","Iniciar Impr. Linha  ?","","","mv_ch2","N",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Iniciar Impr. Coluna ?","","","mv_ch3","N",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Da Matricula         ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"05","Ate Matricula        ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"06","Do Período           ?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Até Período          ?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Driver da Impressão  ?","","","mv_ch8","N",01,0,0,"C","","mv_par08","PDF","","","","","Lazer","","","","","","","","","","","","","","","","","","",""})
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