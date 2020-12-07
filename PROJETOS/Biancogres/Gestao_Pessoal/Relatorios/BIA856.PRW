#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BIA856
@author Julio Almeida
@since 06/02/12
@version 1.0
@description Relatorio de afastados
@type function
/*/

User Function BIA856()

	Private aOrd       := {"NOME","CCLVL+NOME"}
	Private CbTxt      := ""
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private limite     := 220
	Private tamanho    := "G"
	Private nomeprog   := "BIA856" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 15
	Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cPerg      := "BIA856"
	Private LI         := 80
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "BIA856" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString    := "SR8"
	Private titulo     := "Empregados Afastados"
	Private Cabec1     := "Ctr.Custo Funcionario                      Funcao                        Admissao   Afastamento                                     Inicio     Fim   DIAS CID Doenca               "
	Private Cabec2     := ""
	Private cCabec2    := "Total de Funcionários no Centro de Custo - "
	Private cCabec3    := "Total de Funcionários:"
	Private cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	Private cDesc2     := "de acordo com os parametros informados pelo usuario."
	Private cDesc3     := "Empregados afastados"
	Private imprime    := .T.

	fPerg := "BIA856"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	pergunte(cPerg,.F.)

	cFilDe   := mv_par01
	cFilAte  := mv_par02
	cMatDe   := mv_par03
	cMatAte  := mv_par04
	cCCDe    := mv_par05
	cCCAte   := mv_par06
	dDataDe  := mv_par07
	dDataAte := mv_par08
	cMotDe   := mv_par09
	cMotAte  := mv_par10
	cSitua   := mv_par11
	nDias    := mv_par12
	cCAfsDe  := mv_par13
	cCAfsAt  := mv_par14

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodEmp := SM0->M0_CODIGO
	nReg := SM0->(RecNo())

	MsAguarde({|| RunTrab() },"Processando",,.T.)
	MsAguarde({|| RunReport() },"Imprimindo",,.T.)

	SM0->(DbGoTo(nReg))

	TRB->(dbCloseArea())

Return

Static Function RunTrab()

	Local cSql, cChave
	cChave := "R8_FILIAL, RA_NOME, R8_DATAINI"
	If aReturn[8] == 2
		cChave := "R8_FILIAL, RA_CLVL, RA_NOME, R8_DATAINI"
	EndIf
	cSql := " SELECT R8_FILIAL,"
	cSql += "        R8_MAT,"
	cSql += "        RA_CLVL,"
	cSql += "        CTH_DESC01,"
	cSql += "        RA_NOME,"
	cSql += "        RA_SITFOLH,"
	cSql += "        RJ_DESC,"
	cSql += "        RA_ADMISSA,"
	cSql += "        R8_TIPO,"
	cSql += "        X5_DESCRI,"
	cSql += "        R8_DATAINI,"
	cSql += "        R8_DATAFIM,"
	cSql += "        X5_DESCRI, "
	cSql += "        R8_CID, "
	cSql += "        ISNULL(TMR_DOENCA,'') AS TMR_DOENCA "
	cSql += " FROM " + RetSqlName("SR8") + " SR8 "
	cSql += " INNER JOIN " + RetSqlName("SX5") + " ON SUBSTRING(X5_CHAVE,1,1) = R8_TIPO "
	cSql += " INNER JOIN " + RetSqlName("SRA") + " ON RA_FILIAL = R8_FILIAL AND RA_MAT = R8_MAT "
	cSql += " INNER JOIN " + RetSqlName("SRJ") + " ON RJ_FUNCAO = RA_CODFUNC "
	cSql += " INNER JOIN " + RetSqlName("CTH") + " ON RA_CLVL = CTH_CLVL "
	cSql += " LEFT OUTER JOIN " + RetSqlName("TMR") + " ON TMR_CID = R8_CID "
	cSql += " WHERE SR8.D_E_L_E_T_ = ' '"
	cSql += "       AND RA_RESCRAI <> '31'"
	cSql += "       AND X5_TABELA   = '30'"
	cSql += "       AND R8_FILIAL  >= '"+cFilDe+"' AND R8_FILIAL <= '"+cFilAte+"'"
	cSql += "       AND R8_MAT     >= '"+cMatDe+"' AND R8_MAT    <= '"+cMatAte+"'"
	cSql += "       AND RA_CLVL      >= '"+cCCDe+"'  AND RA_CLVL     <= '"+cCCAte+"'"
	cSql += "       AND ((R8_DATAINI    >= '"+DToS(dDataDe)+"' AND R8_DATAINI <= '"+DToS(dDataAte)+"'"
	cSql += "             OR R8_DATAFIM >= '"+DToS(dDataDe)+"' AND R8_DATAFIM <= '"+DToS(dDataAte)+"')"
	cSql += "           OR (R8_DATAINI  <= '"+DToS(dDataDe)+"' AND R8_DATAFIM  = ' '))"
	cSql += "       AND ( ( DATEDIFF(D, R8_DATAINI, R8_DATAFIM) >= "+Alltrim(Str(nDias))+") or (DATEDIFF(D, R8_DATAFIM, R8_DATAINI) >= "+Alltrim(Str(nDias))+" ))"
	cSql += "       AND ((R8_TIPO >= '"+cMotDe+"' AND R8_TIPO <= '"+cMotAte+"') AND R8_TIPO <> 'F') "
	
	IF MV_PAR15 == 2
		cSql += "       AND ((R8_TIPOAFA >= '" + cCAfsDe + "' AND R8_TIPOAFA <= '" + cCAfsAt + "') AND R8_TIPOAFA <> '001') " 
	ELSE
		cSql += "       AND R8_TIPOAFA = '001' "	
	ENDIF
	
	cSql += " ORDER BY "+cChave

	TcQuery cSql New Alias "TRB"                                                       

Return

Static Function RunReport()

	Local nEspaco := 1
	Local nTotal := 0
	Local nTotalGeral := 0
	Local nQtDias := 0

	dbSelectArea("TRB")
	TRB->(dbGoTop())

	_cCLVL := TRB->RA_CLVL

	cCodFil := TRB->R8_FILIAL

	While !TRB->(EOF())

		If  ! TRB->RA_SITFOLH $ cSitua
			TRB->(dbSkip())
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			@++LI,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		MsProcTxt(TRB->R8_FILIAL+TRB->R8_MAT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If LI > 60 .Or. TRB->R8_FILIAL # cCodFil
			_cInicio := substring(DToS(dDataDe),7,2)+"/"+substring(DToS(dDataDe),5,2)+"/"+substring(DToS(dDataDe),1,4)
			_cFim    := substring(DToS(dDataAte),7,2)+"/"+substring(DToS(dDataAte),5,2)+"/"+substring(DToS(dDataAte),1,4)

			LI := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			SM0->(DbSeek(cCodEmp+TRB->R8_FILIAL))
			@++LI,00 PSay "Empresa: "+SM0->M0_NOMECOM+"  Filial: "+SM0->M0_FILIAL + "     Periodo: " + _cInicio +" a "+ _cFim
			++LI
			++LI
		EndIf

		If TRB->R8_FILIAL # cCodFil
			cCodFil := TRB->R8_FILIAL
		EndIf

		If aReturn[8] == 2
			If TRB->RA_CLVL <> _cCLVL
				@++LI,00 PSAY Replicate("-",220)
				@++LI,00 PSAY cCabec2 + Space(1) + _cDesc + " : " + cValToChar(nTotal)
				@++LI,00 PSAY Replicate("-",220)
				LI++
				nTotal := 0
			EndIf
		EndIf

		nQtDias := DateDiffDay(StoD(TRB->R8_DATAFIM),StoD(TRB->R8_DATAINI)) 

		nQtDias++

		@++LI,00 PSAY TRB->RA_CLVL+;
		Space(nEspaco)+TRB->R8_MAT+;
		Space(nEspaco)+Substr(TRB->RA_NOME,1,25)+;
		Space(nEspaco)+TRB->RJ_DESC+;
		Space(nEspaco)+DToC(SToD(TRB->RA_ADMISSA))+;
		Space(nEspaco)+TRB->R8_TIPO+;
		Space(nEspaco)+Substr(TRB->X5_DESCRI,1,45)+;
		Space(nEspaco)+DToC(SToD(TRB->R8_DATAINI))+;
		Space(nEspaco)+DToC(SToD(TRB->R8_DATAFIM))+;
		Space(nEspaco)+cValToChar(nQtDias)+;
		Space(nEspaco+4)+Substr(TRB->R8_CID, 1, 10)+;
		Space(nEspaco)+Substr(TRB->TMR_DOENCA, 1, 30)
		_cCLVL := TRB->RA_CLVL
		_cDesc := AllTrim(TRB->CTH_DESC01)
		nTotal++
		nTotalGeral++
		TRB->(dbSkip())
	EndDo

	If aReturn[8] == 2
		@++LI,00 PSAY Replicate("-",220)
		@++LI,00 PSAY cCabec2 + Space(1) + AllTrim(_cDesc) + " : " + cValToChar(nTotal)
		@++LI,00 PSAY Replicate("-",220)
		LI++
		nTotal := 0
	EndIf

	@++LI,00 PSAY Replicate("-",220)
	@++LI,00 PSAY cCabec3 + Space(nEspaco) + cValToChar(nTotalGeral)
	@++LI,00 PSAY Replicate("-",220)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg, "01", "Filial de?                    ", "", "", "mv_ch1", "C", 02, 00, 00,"G", ""            ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial ate?                   ", "", "", "mv_ch2", "C", 02, 00, 00,"G", ""            ,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Matricula de?                 ", "", "", "mv_ch3", "C", 06, 00, 00,"G", ""            ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg, "04", "Matricula ate?                ", "", "", "mv_ch4", "C", 06, 00, 00,"G", ""            ,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg, "05", "Centro de custo de?           ", "", "", "mv_ch5", "C", 09, 00, 00,"G", ""            ,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	aAdd(aRegs,{cPerg, "06", "Centro de custo ate?          ", "", "", "mv_ch6", "C", 09, 00, 00,"G", ""            ,"MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	aAdd(aRegs,{cPerg, "07", "Data de?                      ", "", "", "mv_ch7", "D", 08, 00, 00,"G", ""            ,"MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "08", "Data ate?                     ", "", "", "mv_ch8", "D", 08, 00, 00,"G", ""            ,"MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "09", "Motivo de?                    ", "", "", "mv_ch9", "C", 01, 00, 00,"G", ""            ,"MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","30"})
	aAdd(aRegs,{cPerg, "10", "Motivo ate?                   ", "", "", "mv_cha", "C", 01, 00, 00,"G", ""            ,"MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","30"})
	aAdd(aRegs,{cPerg, "11", "Situacoes  a Imprimir?        ", "", "", "mv_chb", "C", 05, 00, 00,"G", "fSituacao() ","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "12", "Maior que ?? Dias.            ", "", "", "mv_chc", "N", 02, 00, 00,"G", ""            ,"MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "13", "Código Afastamento De?        ", "", "", "mv_chd", "C", 03, 00, 00,"G", ""            ,"MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","RCM"})
	aAdd(aRegs,{cPerg, "14", "Código Afastamento Até?       ", "", "", "mv_che", "C", 03, 00, 00,"G", ""            ,"MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","RCM"})
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