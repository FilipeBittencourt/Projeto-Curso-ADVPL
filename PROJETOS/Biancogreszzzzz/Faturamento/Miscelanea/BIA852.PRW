#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA852 ºAutor  ³ Ranisses A. Corona º Data ³  04/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescr.    ³ Rotina para gravar os investimentos no SD1 e SD2         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigafat                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION BIA852()

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Rateio Investimento"
@ 8,10 TO 84,222

@ 16,12 SAY "Esta rotina tem por finalidade:                        "
@ 24,12 SAY "Ratear e gravar o valor do investimento de cada Cliente"
@ 32,12 SAY "nos faturamentos e devoluções do período.              "

@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA852", .T.)

ACTIVATE DIALOG oDlg5 CENTERED

//Fecha arquivo temporario
If chkFile("_SZO")
	dbSelectArea("_SZO")
	dbCloseArea()
EndIf

If chkFile("_INV")
	dbSelectArea("_INV")
	dbCloseArea()
EndIf

If CHKFILE("_TRB")
	dbSelectArea("_TRB")
	dbCloseArea()
EndIf

Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que realiza a transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()

If MV_PAR03 == 1 //CLIENTE
	Processa( {|| RunProcCli() } )
	Close(oDlg5)
ElseIf MV_PAR03 == 2 //EMPRESA
	Processa( {|| RunProcEmp() } )
	Close(oDlg5)
EndIf

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que rateia e grava os investimentos CLIENTE
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProcCli()
Private cSql		:= ""
Private Enter		:= CHR(13)
Private nQtdReg		:= 0
Private nNomeTMP	:= "##BIA852TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))
Private nEmp		:= ""

//Limpando os registros já gravados
If cEmpAnt == "01"
	cSql := "UPDATE SD2010 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2070 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD1010 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI IN ('1','S1') AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD1070 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

	cSql := "DELETE FROM TBL_INVEST WHERE EMP = '0101' AND MES = '"+DTOS(MV_PAR01)+"' "
	U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})
Else
	If MV_PAR04 == 1
		cSql := "UPDATE SD2050 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD2070 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD1050 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD1070 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		cSql := "DELETE FROM TBL_INVEST WHERE EMP = '0501' AND MES = '"+DTOS(MV_PAR01)+"' "
		U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})
	Else
		cSql := "UPDATE SD2050 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Bellacasa...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD2070 SET D2_YINVEST = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '3' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD1050 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Bellacasa...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD1070 SET D1_YINVEST = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '3' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEST <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		cSql := "DELETE FROM TBL_INVEST WHERE EMP = '0599' AND MES = '"+DTOS(MV_PAR01)+"' "
		U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})
	EndIf
EndIf

//Define empresa para uso na Stored Procedure
If cEmpAnt == "01"
	nEmp := "0101"
Else
	If MV_PAR04 == 1
		nEmp := "0501"  
	Else
		nEmp := "0599"  
	EndIf
EndIf

//Montando base com os Investimentos realizados no mes agrupando por Cliente
cSql := "SELECT	ZO_REPRE, ZO_CLIENTE, ZO_LOJA, SUM(ZO_VALOR) INVEST, 					" + Enter
cSql += "		ROW_NUMBER() OVER (ORDER BY ZO_REPRE DESC, ZO_CLIENTE DESC) AS LINHA	" + Enter
cSql += "FROM "+RetSqlName("SZO")+" SZO							" + Enter
cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 	" + Enter
cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 	" + Enter
cSql += "		SZO.ZO_EMP     =  '"+nEmp+"'			AND		" + Enter
cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
cSql += "		SZO.ZO_REPRE   NOT IN ('000258','999999') AND 	" + Enter
cSql += "		ZO_STATUS	   = 'Baixa Total' AND 				" + Enter
cSql += "		SZO.D_E_L_E_T_ = '' 							" + Enter
cSql += "GROUP BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA					" + Enter
cSql += "ORDER BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA					" + Enter
If CHKFILE("_SZO")
	dbSelectArea("_SZO")
	dbCloseArea()
EndIf
TcQuery cSql ALIAS "_SZO" NEW
dbSelectArea("_SZO")
dbGoTop()

//Armazena Quantidade de Registros
nQtdReg	:=	_SZO->LINHA

//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
cSql := "EXEC SP_BIA852 '"+nNomeTMP+"','"+nEmp+"','      ','ZZZZZZ','"+Dtos(MV_PAR01)+"','"+Dtos(MV_PAR02)+"' "
U_BIAMsgRun("Montando Base... Faturamento e Devolução...",,{|| TcSQLExec(cSql)})

//Monta Regua
ProcRegua(nQtdReg)

//Verifica todos os clientes com Investimento
Do While !_SZO->(EOF())
	IncProc("Gravando Rateio Cliente..."+_SZO->ZO_CLIENTE+"/"+_SZO->ZO_LOJA)
 
	//Rateia o valor do Investimento de acordo com a movimentacao do Cliente
	cSql := "SELECT INVEST = CASE																				" + Enter
	cSql += "					WHEN (SELECT SUM(VLR_REAL) FROM "+nNomeTMP+" WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND VEND1 = '"+_SZO->ZO_REPRE+"' ) <> 0 THEN									" + Enter
	cSql += "					ROUND(VLR_REAL/(SELECT SUM(VLR_REAL) FROM "+nNomeTMP+" WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND VEND1 = '"+_SZO->ZO_REPRE+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
	cSql += "					ELSE 0 END, * 																	" + Enter
	cSql += "FROM "+nNomeTMP+" 																					" + Enter
	cSql += "WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND TABELA IN ('SD1','SD2') AND VEND1 = '"+_SZO->ZO_REPRE+"' " + Enter
	If chkfile("_INV")
		dbSelectArea("_INV")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "_INV"

	If !_INV->(EOF()) .And. _INV->INVEST <> 0
		//Grava o valor do Investimento de acordo com a movimentacao do Cliente
		Do While !_INV->(EOF())	
	
			cSql := "UPDATE "+_INV->TABELA+Substr(_INV->EMP,1,2)+"0 SET "+Substr(_INV->TABELA,2,2)+"_YINVEST = "+Alltrim(Str(_INV->INVEST))+" WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
			TcSQLExec(cSql)	
			
			_INV->(DBSKIP())
		EndDo	
	Else	
		cSql := "INSERT INTO TBL_INVEST (EMP, MES, REPRES, CLIENTE, LOJA, VLR_INV) VALUES ('"+nEmp+"','"+Dtos(MV_PAR01)+"','"+_SZO->ZO_REPRE+"','"+_SZO->ZO_CLIENTE+"','"+_SZO->ZO_LOJA+"',"+Alltrim(Str(_SZO->INVEST))+") "
		TcSQLExec(cSql)	
	EndIf

	_SZO->(DBSKIP())
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que rateia e grava os investimentos EMPRESA
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProcEmp()
Private cSql		:= ""
Private Enter		:= CHR(13)
Private nQtdReg		:= 0
Private nNomeTMP	:= "##BIA852TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))
Private nEmp		:= ""

//Limpando os registros já gravados
If cEmpAnt == "01"
	cSql := "UPDATE SD2010 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2070 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD1010 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI IN ('1','S1') AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD1070 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})
Else        
	If MV_PAR04 == 1
		cSql := "UPDATE SD2050 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD2070 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD1050 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD1070 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})
	Else
		cSql := "UPDATE SD2050 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD2070 SET D2_YINVEMP = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '3' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD1050 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})
	
		cSql := "UPDATE SD1070 SET D1_YINVEMP = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI = '3' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YINVEMP <> 0 AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})
	EndIf
	
EndIf

//Define empresa para uso na Stored Procedure
If cEmpAnt == "01"
	nEmp := "0101"
Else
	If MV_PAR04 == 1
		nEmp := "0501"
	Else
		nEmp := "0599"
	EndIf
EndIf

//Montando base com os Investimentos realizados no mes agrupando por Cliente
//cSql := "SELECT	ZO_REPRE,SUM(ZO_VALOR) INVEST, ROW_NUMBER() OVER (ORDER BY ZO_REPRE DESC) AS LINHA	" + Enter
cSql := "SELECT	SUM(ZO_VALOR) INVEST, 1 AS LINHA				" + Enter
cSql += "FROM "+RetSqlName("SZO")+" SZO							" + Enter
cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 	" + Enter
cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 	" + Enter
cSql += "		SZO.ZO_EMP     =  '"+nEmp+"'			AND		" + Enter
cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
cSql += "		SZO.ZO_REPRE   IN ('000258','999999') 	AND 	" + Enter
cSql += "		ZO_STATUS	   = 'Baixa Total' AND 				" + Enter
cSql += "		SZO.D_E_L_E_T_ = '' 							" + Enter
//cSql += "GROUP BY ZO_REPRE										" + Enter
If CHKFILE("_SZO")
	dbSelectArea("_SZO")
	dbCloseArea()
EndIf
TcQuery cSql ALIAS "_SZO" NEW
dbSelectArea("_SZO")
dbGoTop()

//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
cSql := "EXEC SP_BIA852 '"+nNomeTMP+"','"+nEmp+"','      ','ZZZZZZ','"+Dtos(MV_PAR01)+"','"+Dtos(MV_PAR02)+"' "
U_BIAMsgRun("Montando Base... Faturamento e Devolução...",,{|| TcSQLExec(cSql)})

cSql := "SELECT COUNT(*) LINHA FROM "+nNomeTMP+" "
If CHKFILE("_TRB")
	dbSelectArea("_TRB")
	dbCloseArea()
EndIf
TcQuery cSql ALIAS "_TRB" NEW

//Armazena Quantidade de Registros
nQtdReg	:= _TRB->LINHA

//Monta Regua
ProcRegua(nQtdReg)

//Verifica todos os clientes com Investimento
Do While !_SZO->(EOF())
	
	IncProc("Gravando Rateio Empresa...")	

	//Rateia o valor do Investimento de acordo com a movimentacao do Cliente
	cSql := "SELECT INVEST = CASE																				" + Enter
	cSql += "					WHEN (SELECT SUM(VLR_REAL) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') ) <> 0 THEN									" + Enter
	cSql += "					ROUND(VLR_REAL/(SELECT SUM(VLR_REAL) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') )*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
	cSql += "					ELSE 0 END, * 																	" + Enter
	cSql += "FROM "+nNomeTMP+" 																					" + Enter
	cSql += "WHERE TABELA IN ('SD1','SD2') " + Enter
	If chkfile("_INV")
		dbSelectArea("_INV")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "_INV"

	If !_INV->(EOF()) .And. _INV->INVEST <> 0
		//Grava o valor do Investimento de acordo com a movimentacao do Cliente
		Do While !_INV->(EOF())	
	
			cSql := "UPDATE "+_INV->TABELA+Substr(_INV->EMP,1,2)+"0 SET "+Substr(_INV->TABELA,2,2)+"_YINVEMP = "+Alltrim(Str(_INV->INVEST))+" WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
			TcSQLExec(cSql)	
			
			_INV->(DBSKIP())
		EndDo	
	Else	
		MsgAlert("TESTE")
	EndIf

	_SZO->(DBSKIP())
EndDo

Return