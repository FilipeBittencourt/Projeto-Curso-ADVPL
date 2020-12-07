#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA286
@author Marcos Alberto Soprani
@since 01/03/12
@version 1.0
@description Importação do arquivo txt do Plano de Saúde - Unimed - para nova
.            tabela de controle do Protheus
@type function
/*/

User Function BIA286()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private cString := ""
	Private cArqTxt
	Private nHdl
	Private cEOL    := "CHR(13)+CHR(10)"
	Private nTamFile, nTamLin, cBuffer, nBtLidos

	Private xf_NumPlan := ""
	Private xf_Tipo    := ""
	Private xf_Cpf     := ""
	Private xf_DtLanc  := ""
	Private xf_Valor   := ""
	Private rt_Matr    := ""
	Private rt_CCus    := ""
	Private rt_Verb    := ""
	Private rt_Valo    := 0
	Private rt_Titul
	Private rt_tpdep   := ""
	Private rt_coddep  := ""
	Private rt_DtLa
	Private rt_Gravl
	Private rt_CntRg   := 0

	cHInicio := Time()
	fPerg := "BIA286"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	cArqTxt := Alltrim(MV_PAR01)
	nHdl    := fOpen(cArqTxt,68)
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	// Inicio da Leitura do Arquivo
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 486+Len(cEOL)
	cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

	vrfcTXT := FwCutOff(cBuffer, .T.)
	If Substr(vrfcTXT,1,9) <> "NUMFATURA" .or. Substr(vrfcTXT,486,1) <> ";"
		MsgSTOP("O arquivo não possui as configurações adequadas para a importação. Favor corrigir a primeira coluna e a ultima do arquivo da primeira linha do arquivo antes de prosseguir!!!")
		Return
	EndIf

	ProcRegua(RecCount()) // Numero de registros a processar
	While nBtLidos >= nTamLin

		rt_CntRg += 1
		IncProc("Linhas Processadas: " + Alltrim(Str(rt_CntRg)))

		// Processamento
		TXT := FwCutOff(cBuffer, .T.)
		rt_Gravl := .F.
		wp_FGera()

		If rt_Gravl
			hw_RegRHO := 0
			dbSelectArea("RHO")
			dbSetOrder(1)
			If dbSeek(xFilial("RHO")+rt_Matr+dtos(rt_DtLa))
				While !Eof() .and. RHO->RHO_FILIAL+RHO->RHO_MAT+dtos(RHO->RHO_DTOCOR) == xFilial("RHO")+rt_Matr+dtos(rt_DtLa)
					If RHO->RHO_FILIAL+RHO->RHO_MAT+dtos(RHO->RHO_DTOCOR)+RHO->RHO_TPFORN+RHO->RHO_CODFOR+RHO->RHO_ORIGEM+RHO->RHO_CODIGO+RHO->RHO_PD+RHO->RHO_COMPPG == ;
					xFilial("RHO")+rt_Matr+dtos(rt_DtLa)+"1"+IIF(cEmpAnt == "13", "001", "003")+rt_tpdep+rt_coddep+rt_Verb+Substr(dtos(rt_DtLa),1,6)
						hw_RegRHO := Recno()
					EndIf
					dbSelectArea("RHO")
					dbSkip()
				End
			EndIf

			If hw_RegRHO == 0
				RecLock("RHO",.T.)
				RHO->RHO_FILIAL := xFilial("RHO")
				RHO->RHO_MAT    := rt_Matr
				RHO->RHO_DTOCOR := rt_DtLa
				RHO->RHO_TPFORN := "1"
				RHO->RHO_CODFOR := IIF(cEmpAnt == "13", "001", "003")
				RHO->RHO_ORIGEM := rt_tpdep
				RHO->RHO_CODIGO := rt_coddep
				RHO->RHO_PD     := rt_Verb
				RHO->RHO_COMPPG := Substr(dtos(rt_DtLa),1,6)
				RHO->RHO_TPLAN  := "1"
				RHO->RHO_VLRFUN := rt_Valo
				RHO->RHO_VLREMP := 0
				RHO->RHO_OBSERV	:= "Importado BIA286"
			Else
				dbSelectArea("RHO")
				dbGoTo(hw_RegRHO)
				RecLock("RHO",.F.)
				RHO->RHO_VLRFUN += rt_Valo
			EndIf
			MsUnLock()
		EndIf

		nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

		dbSkip()
	End

	fClose(nHdl)

	MsgINFO("....: Importação executada com sucesso :....")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wp_FGera ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 01/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wp_FGera()

	Local aAreaAnt := GetArea()
	xf_NumPlan := Substr(TXT,17,3)+Substr(TXT,22,4)+Substr(TXT,33,6)+Substr(TXT,40,2)
	xf_Tipo    := Substr(TXT,14,2)
	xf_Cpf     := Substr(TXT,472,14)
	xf_DtLanc  := dtos(Ultimodia(dDataBase))
	xf_Valor   := StrTran( Substr(TXT,384,15) ,",",".") //Substr(TXT,384,15)
	rt_Matr    := Space(6)
	rt_CCus    := Space(4)
	rt_Verb    := Space(3)
	rt_Valo    := 0
	rt_TpUsr   := .T.
	rt_tpdep   := "1"
	rt_coddep  := Space(2)
	rt_DtLa    := stod(xf_DtLanc)

	If xf_Tipo == "TN"

		rt_Gravl := .T.

		A0001 := " SELECT (SELECT RA_MAT
		A0001 += "           FROM " + RetSqlName("SRA")
		A0001 += "          WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "            AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "            AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "            AND RA_CATFUNC <> 'A'
		A0001 += "            AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "            AND D_E_L_E_T_ = ' ') MATRIC,
		A0001 += "        (SELECT RA_CLVL
		A0001 += "           FROM " + RetSqlName("SRA")
		A0001 += "          WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "            AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "            AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "            AND RA_CATFUNC <> 'A'
		A0001 += "            AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "            AND D_E_L_E_T_ = ' ') CCUSTO,
		A0001 += "        (SELECT RB_YVBCOOP
		A0001 += "           FROM " + RetSqlName("SRB")
		A0001 += "          WHERE RB_FILIAL = '"+xFilial("SRB")+"'
		A0001 += "            AND RB_MAT IN(SELECT RA_MAT
		A0001 += "                            FROM " + RetSqlName("SRA")
		A0001 += "                           WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                             AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "                             AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "                             AND RA_CATFUNC <> 'A'
		A0001 += "                             AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "                             AND D_E_L_E_T_ = ' ')
		A0001 += "            AND SUBSTRING(RB_YCODPLS,1,3)+SUBSTRING(RB_YCODPLS,5,3)+
		A0001 += "                SUBSTRING(RB_YCODPLS,9,6)+SUBSTRING(RB_YCODPLS,16,2)+
		A0001 += "                SUBSTRING(RB_YCODPLS,19,1) = '"+xf_NumPlan+"'
		A0001 += "            AND D_E_L_E_T_ = ' ') VB_DEP,
		A0001 += "        (SELECT RB_TPDEPAM
		A0001 += "           FROM " + RetSqlName("SRB")
		A0001 += "          WHERE RB_FILIAL = '"+xFilial("SRB")+"'
		A0001 += "            AND RB_MAT IN(SELECT RA_MAT
		A0001 += "                            FROM " + RetSqlName("SRA")
		A0001 += "                           WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                             AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "                             AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "                             AND RA_CATFUNC <> 'A'
		A0001 += "                             AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "                             AND D_E_L_E_T_ = ' ')
		A0001 += "            AND SUBSTRING(RB_YCODPLS,1,3)+SUBSTRING(RB_YCODPLS,5,3)+
		A0001 += "                SUBSTRING(RB_YCODPLS,9,6)+SUBSTRING(RB_YCODPLS,16,2)+
		A0001 += "                SUBSTRING(RB_YCODPLS,19,1) = '"+xf_NumPlan+"'
		A0001 += "            AND D_E_L_E_T_ = ' ') TPDEP,
		A0001 += "        (SELECT RB_COD
		A0001 += "           FROM " + RetSqlName("SRB")
		A0001 += "          WHERE RB_FILIAL = '"+xFilial("SRB")+"'
		A0001 += "            AND RB_MAT IN(SELECT RA_MAT
		A0001 += "                            FROM " + RetSqlName("SRA")
		A0001 += "                           WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                             AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "                             AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "                             AND RA_CATFUNC <> 'A'
		A0001 += "                             AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "                             AND D_E_L_E_T_ = ' ')
		A0001 += "            AND SUBSTRING(RB_YCODPLS,1,3)+SUBSTRING(RB_YCODPLS,5,3)+
		A0001 += "                SUBSTRING(RB_YCODPLS,9,6)+SUBSTRING(RB_YCODPLS,16,2)+
		A0001 += "                SUBSTRING(RB_YCODPLS,19,1) = '"+xf_NumPlan+"'
		A0001 += "            AND D_E_L_E_T_ = ' ') CODDEP
		TcQuery A0001 ALIAS "A001" NEW
		dbSelectArea("A001")
		dbGoTop()

		rt_Matr := A001->MATRIC
		rt_CCus := A001->CCUSTO
		If Empty(A001->VB_DEP)
			If cEmpAnt == "01"
				rt_Verb := "533"
			ElseIf cEmpAnt == "05"
				rt_Verb := "533"
			ElseIf cEmpAnt == "13"
				rt_Verb := "533"
			EndIf
		Else
			rt_Verb   := A001->VB_DEP
			rt_tpdep  := IIF(A001->TPDEP == "1", "2", "3")
			rt_coddep := A001->CODDEP
			rt_TpUsr   := .F.
		EndIf
		rt_Valo := Val(Alltrim(xf_Valor))

		dbCloseArea("A001")

	EndIf

	RestArea(aAreaAnt)

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
	aRegs := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Informe o arquivo   ?","","","mv_ch1","C",50,0,0,"G","U_BIAPesqPD('TXT', 'BIA286    ', '01', 'mv_par01')","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
