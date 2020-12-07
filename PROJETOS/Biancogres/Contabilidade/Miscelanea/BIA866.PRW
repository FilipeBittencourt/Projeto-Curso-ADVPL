#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA866
# AUTOR......: Ranisses A. Corona
# DATA.......: 26/01/2015
# DESCRICAO..: Rotina para gravar a UNIDADE DE NEGOCIO na Lançamentos Contabeis para  
#			   uso nos relatorios de DRE do BW/BPC SAP.        
#
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

USER FUNCTION BIA866()

	Local x

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05_06_07_13_14")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			Pergunte("BIA866",.F.)
			MV_PAR01 := stod("20140101")//stod(alltrim(str(year(dDataBase)))+"0101")
			MV_PAR02 := stod("20141231")//dDataBase

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA866 " + xv_Emps[x,1])

			Processa({||RunProcCli()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA866 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else

		Pergunte("BIA866",.F.)

		@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Gravação Unid. Negócio		  "
		@ 8,10 TO 84,222

		@ 16,12 SAY "Esta rotina tem por finalidade:                          "
		@ 24,12 SAY "Gravar a informação da Unidade de Negócio nos arquivos de"
		@ 32,12 SAY "Lançamentos Contábeis de acordo com as regras definidas. "

		@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
		@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
		@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA866", .T.)

		ACTIVATE DIALOG oDlg5 CENTERED

		//Fecha arquivo temporario
		If chkFile("_CT2")
			dbSelectArea("_CT2")
			dbCloseArea()
		EndIf

	EndIf

Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que realiza a transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()

	Processa( {|| RunProcCli() } )

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que rateia e grava os investimentos CLIENTE
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProcCli()
	Private cSql		:= ""
	Private Enter		:= CHR(13)
	Private nQtdReg		:= 0
	Private nEmp		:= {}
	Private nUnidNeg	:= ""
	Private nLinha		:= 1

	cSql := "SELECT CT2_DATA, CT2_LOTE, CT2_DOC, CT2_LP, CT2_KEY, CT2_CLVLCR, CT2_CLVLDB,	" + Enter
	cSql += "		ROW_NUMBER() OVER (ORDER BY CT2_DATA DESC, CT2_DOC DESC ) AS LINHA	 	" + Enter
	cSql += "FROM "+RetSqlName("CT2")+" CT2													" + Enter
	cSql += "WHERE CT2_FILIAL = '"+xFilial("CT2")+"' AND			" + Enter
	cSql += "	   CT2_DATA >= '"+Dtos(MV_PAR01)+"'  AND			" + Enter
	cSql += "      CT2_DATA <= '"+Dtos(MV_PAR02)+"'  AND 			" + Enter
	cSql += "	   CT2_YUN = '' 					 AND 			" + Enter
	//cSql += "      CT2_LP <> '' AND CT2_KEY <> '' 	 AND 			" + Enter
	cSql += "      (SUBSTRING(CT2_CREDIT,1,1) = '4' OR SUBSTRING(CT2_DEBITO,1,1) = '4' ) AND	" + Enter
	cSql += "      D_E_L_E_T_ = '' 									" + Enter
	cSql += "GROUP BY CT2_DATA, CT2_LOTE, CT2_DOC, CT2_LP, CT2_KEY, CT2_CLVLCR, CT2_CLVLDB	" + Enter
	cSql += "ORDER BY CT2_DATA, CT2_LOTE, CT2_DOC, CT2_LP, CT2_KEY, CT2_CLVLCR, CT2_CLVLDB	" + Enter
	If CHKFILE("_CT2")
		dbSelectArea("_CT2")
		dbCloseArea()
	EndIf
	TcQuery cSql ALIAS "_CT2" NEW
	dbSelectArea("_CT2")
	dbGoTop()

	//Armazena Quantidade de Registros
	nQtdReg	:=	_CT2->LINHA

	//Monta Regua
	ProcRegua(nQtdReg)

	//Verifica todos os clientes com Investimento
	Do While !_CT2->(EOF())
		IncProc( "Gravando Unid. de Negócio... Dia->"+DTOC(STOD(_CT2->CT2_DATA)) )

		nUnidNeg := fBuscaUN(_CT2->CT2_LP,_CT2->CT2_KEY,_CT2->CT2_CLVLCR,_CT2->CT2_CLVLDB)

		If !Empty(Alltrim(nUnidNeg))
			cSql := "UPDATE "+RetSqlName("CT2")+" SET CT2_YUN = '"+nUnidNeg+"' "
			cSql += "WHERE CT2_FILIAL = '"+xFilial("CT2")+"'	AND
			cSql += "	   CT2_DATA   = '"+_CT2->CT2_DATA+"'	AND
			cSql += "	   CT2_LOTE	  = '"+_CT2->CT2_LOTE+"'	AND
			cSql += "	   CT2_DOC	  = '"+_CT2->CT2_DOC+"'		AND
			cSql += "	   CT2_KEY	  = '"+_CT2->CT2_KEY+"'		AND
			cSql += "	   D_E_L_E_T_ = ''
			TcSQLExec(cSql)
		EndIf

		nLinha := nLinha + 1

		_CT2->(DBSKIP())

	EndDo


	//Fecha arquivo temporario
	If chkFile("_CT2")
		dbSelectArea("_CT2")
		dbCloseArea()
	EndIf

Return


/*
##############################################################################################################
# PROGRAMA...: fBuscaUN
# AUTOR......: Ranisses A. Corona
# DATA.......: 27/01/2015
# DESCRICAO..: Busca Unidade de Negocio direto na Origem (NF)
##############################################################################################################
*/
Static Function fBuscaUN(nLP,nKey,nClVlC,nClVlD)
	Local cTable	:= Posicione("CTL",1,xFilial("CTL")+nLP,"CTL_ALIAS")
	Local cKeySql	:= StrTran(CTL->CTL_KEY,"DTOS","")
	Local cSql		:= ""
	Local nRet		:= ""

	//Pesquisa a Unidade de Negocio através da KEY do CT2
	If !Empty(Alltrim(nKey))

		If Alltrim(cTable) == "SD2"
			cSql := "SELECT TOP 1 * FROM "+cTable+cEmpAnt+"0 WHERE "+Alltrim(cKeySql)+" = '"+nKey+"' " //AND D_E_L_E_T_ = '' "
		ElseIf Alltrim(cTable) == "SE5"
			cSql := "SELECT TOP 1 E1_YEMP											"
			cSql += "FROM "+RetSqlName("SE5")+" SE5 INNER JOIN "+RetSqlName("SE1")+" SE1 ON	"
			cSql += "		E5_PREFIXO = E1_PREFIXO	AND 							"
			cSql += "		E5_NUMERO  = E1_NUM		AND 							"
			cSql += "		E5_PARCELA = E1_PARCELA									"
			cSql += "WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "+Alltrim(cKeySql)+" = '"+nKey+"' AND SE1.D_E_L_E_T_ = '' AND SE5.D_E_L_E_T_ = '' " 
		ElseIf Alltrim(cTable) == "SD1"
			cSql := "SELECT TOP 1 D2_YEMP FROM "+RetSqlName("SD2")+" WHERE EXISTS "
			cSql += "(SELECT * FROM "+RetSqlName("SD1")+" WHERE D1_NFORI = D2_DOC AND D1_COD = D2_COD AND "+Alltrim(cKeySql)+" = '"+nKey+"' ) "
		Else
			cSql := "SELECT TOP 1 * FROM "+cTable+cEmpAnt+"0 WHERE "+Alltrim(cKeySql)+" = '"+nKey+"' " //AND D_E_L_E_T_ = '' "
		EndIf
		If CHKFILE("_XXX")
			dbSelectArea("_XXX")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_XXX" NEW
		dbSelectArea("_XXX")
		dbGoTop()

		If Alltrim(cTable) == "SD2"
			If _XXX->(FieldPos(Substr(cTable,2,2)+"_YEMP")) > 0
				nRet	:= Substr(_XXX->D2_YEMP,1,2)
			EndIf
		ElseIf Alltrim(cTable) == "SE5"
			If _XXX->(FieldPos("E1_YEMP")) > 0
				nRet	:= Substr(_XXX->E1_YEMP,1,2)
			EndIf
		ElseIf Alltrim(cTable) == "SD1"
			If _XXX->(FieldPos("D2_YEMP")) > 0
				nRet	:= Substr(_XXX->D2_YEMP,1,2)
			EndIf
		Else
			If _XXX->(FieldPos(Substr(cTable,2,2)+"_YEMP")) > 0
				nRet	:= &("_XXX->"+(Substr(cTable,2,2)+"_YEMP"))
			EndIf
		EndIf

		//Senão achou verifica se a CLVL está preenchida
		If Empty(Alltrim(nRet)).And. (!Empty(Alltrim(nClVlC)) .Or. !Empty(Alltrim(nClVlD)) )
			cSql := "SELECT CTH_YUN FROM "+RetSqlName("CTH")+" WHERE CTH_CLVL IN ('"+nClVlC+"','"+nClVlD+"') AND D_E_L_E_T_ = ''
			If CHKFILE("_CTH")
				dbSelectArea("_CTH")
				dbCloseArea()
			EndIf
			TcQuery cSql ALIAS "_CTH" NEW
			nRet := _CTH->CTH_YUN
		EndIf

	Else

		If Empty(Alltrim(nRet)) .And. ( !Empty(Alltrim(nClVlC)) .Or. !Empty(Alltrim(nClVlD)) )
			cSql := "SELECT CTH_YUN FROM "+RetSqlName("CTH")+" WHERE CTH_CLVL IN ('"+nClVlC+"','"+nClVlD+"') AND D_E_L_E_T_ = ''
			If CHKFILE("_CTH")
				dbSelectArea("_CTH")
				dbCloseArea()
			EndIf
			TcQuery cSql ALIAS "_CTH" NEW
			nRet := _CTH->CTH_YUN
		EndIf

	EndIf

	If chkFile("_XXX")
		dbSelectArea("_XXX")
		dbCloseArea()
	EndIf

	If CHKFILE("_CTH")
		dbSelectArea("_CTH")
		dbCloseArea()
	EndIf

Return(nRet)