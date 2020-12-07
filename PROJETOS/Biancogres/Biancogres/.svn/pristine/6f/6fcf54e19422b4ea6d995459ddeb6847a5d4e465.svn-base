#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA865
# AUTOR......: Ranisses A. Corona
# DATA.......: 19/11/2014
# DESCRICAO..: Rotina para realizar o rateio dos investimentos acumulado no exercicio.
#			   O valor do rateio é gravado nas tabelas SD2 e SD1.
#
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

USER FUNCTION BIA865()

	Local x

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			Pergunte("BIA865",.F.)
			MV_PAR01 := stod(alltrim(str(year(dDataBase)))+"0101")
			MV_PAR02 := dDataBase

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA865 " + xv_Emps[x,1])

			Processa({||RunProcCli()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA865 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else

		@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Rateio Invest. Acumulado"
		@ 8,10 TO 84,222

		@ 16,12 SAY "Esta rotina tem por finalidade:                          "
		@ 24,12 SAY "Ratear e gravar o valor do investimento Cliente e Empresa"
		@ 32,12 SAY "nos faturamentos e devoluções do período acumuluado (ano)"

		@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
		@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
		@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA865", .T.)

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

	Local x

	Private cSql		:= ""
	Private Enter		:= CHR(13)
	Private nQtdReg		:= 0
	Private nNomeTMP	:= ""
	Private nEmp		:= {}

	//Limpando os registros já gravados
	If cEmpAnt == "01"
		//Apaga Marca 0101
		//cSql := "UPDATE SD2010 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2010 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1010 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI IN ('1','S1') AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1010 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI IN ('1','S1') AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0101' AND MES >= '"+DTOS(MV_PAR01)+"' AND MES <= '"+DTOS(MV_PAR02)+"' "
		cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0101' AND MES >= '"+DTOS(MV_PAR01)+"' "
		U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})
	Else
		//Apaga Marca 0501
		//cSql := "UPDATE SD2050 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2050 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1050 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1050 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0501' AND MES >= '"+DTOS(MV_PAR01)+"' AND MES <= '"+DTOS(MV_PAR02)+"' "
		cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0501' AND MES >= '"+DTOS(MV_PAR01)+"'  "
		U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})

		//Apaga Marca 0599
		//cSql := "UPDATE SD2050 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2050 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Bellacasa...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '3' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD2070 SET D2_YINCLAC = 0, D2_YINCLAP = 0, D2_YINEMGE = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '3' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND (D2_YINCLAC <> 0 OR D2_YINCLAP <> 0 OR D2_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1050 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1050 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Bellacasa...",,{|| TcSQLExec(cSql)})

		//cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '3' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		cSql := "UPDATE SD1070 SET D1_YINCLAC = 0, D1_YINCLAP = 0, D1_YINEMGE = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '3' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND (D1_YINCLAC <> 0 OR D1_YINCLAP <> 0 OR D1_YINEMGE <> 0) AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(cSql)})

		//cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0599' AND MES >= '"+DTOS(MV_PAR01)+"' AND MES <= '"+DTOS(MV_PAR02)+"' "
		cSql := "DELETE FROM TBL_INVEST_ACUMULADO WHERE EMP = '0599' AND MES >= '"+DTOS(MV_PAR01)+"'  "
		U_BIAMsgRun("Limpando registros TBL_INVEST...",,{|| TcSQLExec(cSql)})
	EndIf

	//Define empresa para uso na Stored Procedure
	If cEmpAnt == "01"
		aadd(nEmp, "0101")
	Else
		aadd(nEmp, "0501")
		aadd(nEmp, "0599")
	EndIf


	For x := 1 to Len(nEmp)

		//Grava nome Tabela Temporaria
		nNomeTMP	:= "##BIA865TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

		//RATEIO POR CLIENTE
		//Montando base com os Investimentos realizados no mes agrupando por Cliente
		cSql := "SELECT	ZO_REPRE, ZO_CLIENTE, ZO_LOJA, A1_YTPSEG, A1_EST, SUM(ZO_VALOR) INVEST, " + Enter
		cSql += "		ROW_NUMBER() OVER (ORDER BY ZO_REPRE DESC, ZO_CLIENTE DESC) AS LINHA	" + Enter
		cSql += "FROM "+RetSqlName("SZO")+" SZO, SA1"+cEmpAnt+"0 SA1	" + Enter
		cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
		cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_EMP     =  '"+nEmp[x]+"'			AND		" + Enter
		cSql += "		SZO.ZO_CLIENTE = SA1.A1_COD  			AND		" + Enter
		cSql += "		SZO.ZO_LOJA    = SA1.A1_LOJA 			AND		" + Enter
		cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
		cSql += "		SZO.ZO_REPRE   NOT IN ('000258','999999') AND 	" + Enter
		cSql += "		ZO_STATUS	   = 'Baixa Total' 			AND		" + Enter
		cSql += "		SZO.D_E_L_E_T_ = ''				 		AND		" + Enter
		cSql += "		SA1.D_E_L_E_T_ = '' 							" + Enter
		cSql += "GROUP BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA, A1_YTPSEG, A1_EST	" + Enter
		cSql += "ORDER BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA, A1_YTPSEG, A1_EST	" + Enter
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
		cSql := "EXEC SP_BIA865 '"+nNomeTMP+"','"+nEmp[x]+"','      ','ZZZZZZ','"+Dtos(MV_PAR01)+"','"+Dtos(MV_PAR02)+"' "
		U_BIAMsgRun("Montando Base... Faturamento e Devolução...",,{|| TcSQLExec(cSql)})

		//Monta Regua
		ProcRegua(nQtdReg)

		//Verifica todos os clientes com Investimento
		Do While !_SZO->(EOF())
			IncProc("Gravando Rateio Cliente..."+_SZO->ZO_CLIENTE+"/"+_SZO->ZO_LOJA)

			//01 - Rateia o valor do Investimento do CLIENTE
			cSql := "SELECT INVEST = CASE																				" + Enter
			cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND VEND1 = '"+_SZO->ZO_REPRE+"' ) <> 0 THEN										" + Enter
			cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND VEND1 = '"+_SZO->ZO_REPRE+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
			cSql += "					ELSE 0 END, * 																	" + Enter
			cSql += "FROM "+nNomeTMP+" 																					" + Enter
			cSql += "WHERE CLIENTE = '"+_SZO->ZO_CLIENTE+"' AND LOJA = '"+_SZO->ZO_LOJA+"' AND TABELA IN ('SD1','SD2') AND VEND1 = '"+_SZO->ZO_REPRE+"' " + Enter
			If chkfile("_INV")
				dbSelectArea("_INV")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "_INV"

			//01 - Grava o rateio do Investimento para as vendas do CLIENTE + VENDEDOR			
			If !_INV->(EOF()) .And. _INV->INVEST <> 0

				Do While !_INV->(EOF())

					cSql := "UPDATE "+_INV->TABELA+Substr(_INV->EMP,1,2)+"0 SET "+Substr(_INV->TABELA,2,2)+"_YINCLAC = "+Substr(_INV->TABELA,2,2)+"_YINCLAC + ROUND("+ALLTRIM(STR(ROUND(_INV->INVEST,2)))+",2), "+Substr(_INV->TABELA,2,2)+"_YINCLAP = "+Substr(_INV->TABELA,2,2)+"_YINCLAP + ROUND("+ALLTRIM(STR(ROUND(_INV->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
					TcSQLExec(cSql)				

					_INV->(DBSKIP())

				EndDo

			Else

				//Posicina no Cliente para verificar o sem ou não Grupo 
				SA1->(DbSetOrder(1))
				SA1->(DBSeek(xFilial("SA1")+_SZO->ZO_CLIENTE+_SZO->ZO_LOJA))

				If !Empty(Alltrim(SA1->A1_GRPVEN))

					//02 - Rateia o valor do Investimento do GRUPO DO CLIENTE + VENDEDOR
					cSql := "SELECT INVEST = CASE																					" + Enter
					cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND VEND1 = '"+_SZO->ZO_REPRE+"' ) <> 0 THEN									" + Enter
					cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND VEND1 = '"+_SZO->ZO_REPRE+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
					cSql += "					ELSE 0 END, * 																		" + Enter
					cSql += "FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ''	" + Enter
					cSql += "WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND TABELA IN ('SD1','SD2') AND VEND1 = '"+_SZO->ZO_REPRE+"' 	" + Enter
					If chkfile("_INV1")
						dbSelectArea("_INV1")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_INV1"

					//02 - Grava o rateio do Investimento para as vendas do GRUPO DO CLIENTE + VENDEDOR
					If !_INV1->(EOF()) .And. _INV1->INVEST <> 0

						Do While !_INV1->(EOF())

							cSql := "UPDATE "+_INV1->TABELA+Substr(_INV1->EMP,1,2)+"0 SET "+Substr(_INV1->TABELA,2,2)+"_YINCLAC = "+Substr(_INV1->TABELA,2,2)+"_YINCLAC + ROUND("+ALLTRIM(STR(ROUND(_INV1->INVEST,2)))+",2), "+Substr(_INV1->TABELA,2,2)+"_YINCLAP = "+Substr(_INV1->TABELA,2,2)+"_YINCLAP + ROUND("+ALLTRIM(STR(ROUND(_INV1->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV1->RECNO))+" "
							TcSQLExec(cSql)

							_INV1->(DBSKIP())

						EndDo

					Else

						//03 - Rateia o valor do Investimento do GRUPO DO CLIENTE + ESTADO
						cSql := "SELECT INVEST = CASE																					" + Enter
						cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_EST = '"+_SZO->A1_EST+"' ) <> 0 THEN									" + Enter
						cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_EST = '"+_SZO->A1_EST+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
						cSql += "					ELSE 0 END, * 																		" + Enter
						cSql += "FROM "+nNomeTMP+" INNER JOIN SA1010 SA1 ON CLIENTE = A1_COD AND LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ''	" + Enter
						cSql += "WHERE A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND TABELA IN ('SD1','SD2') AND A1_EST = '"+_SZO->A1_EST+"' 	" + Enter
						If chkfile("_INV2")
							dbSelectArea("_INV2")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_INV2"

						//03 - Grava o rateio do Investimento para as vendas do GRUPO DO CLIENTE + ESTADO
						If !_INV2->(EOF()) .And. _INV2->INVEST <> 0

							Do While !_INV2->(EOF())

								cSql := "UPDATE "+_INV2->TABELA+Substr(_INV2->EMP,1,2)+"0 SET "+Substr(_INV2->TABELA,2,2)+"_YINCLAC = "+Substr(_INV2->TABELA,2,2)+"_YINCLAC + ROUND("+ALLTRIM(STR(ROUND(_INV2->INVEST,2)))+",2), "+Substr(_INV2->TABELA,2,2)+"_YINCLAP = "+Substr(_INV2->TABELA,2,2)+"_YINCLAP + ROUND("+ALLTRIM(STR(ROUND(_INV2->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV2->RECNO))+" "
								TcSQLExec(cSql)

								_INV2->(DBSKIP())

							EndDo

						Else

							//04 - Rateia o valor do Investimento do REPRESENTANTE
							cSql := "SELECT INVEST = CASE																				" + Enter
							cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE VEND1 = '"+_SZO->ZO_REPRE+"' ) <> 0 THEN									" + Enter
							cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE VEND1 = '"+_SZO->ZO_REPRE+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
							cSql += "					ELSE 0 END, * 																	" + Enter
							cSql += "FROM "+nNomeTMP+" 																					" + Enter
							cSql += "WHERE TABELA IN ('SD1','SD2') AND VEND1 = '"+_SZO->ZO_REPRE+"' " + Enter
							If chkfile("_INV3")
								dbSelectArea("_INV3")
								dbCloseArea()
							EndIf
							TcQuery cSql New Alias "_INV3"

							If !_INV3->(EOF()) .And. _INV3->INVEST <> 0

								//04 - Grava o rateio do Investimento para as vendas do REPRESENTANTE
								Do While !_INV3->(EOF())

									cSql := "UPDATE "+_INV3->TABELA+Substr(_INV3->EMP,1,2)+"0 SET "+Substr(_INV3->TABELA,2,2)+"_YINCLAC = "+Substr(_INV3->TABELA,2,2)+"_YINCLAC + ROUND("+ALLTRIM(STR(ROUND(_INV3->INVEST,2)))+",2), "+Substr(_INV3->TABELA,2,2)+"_YINCLAP = "+Substr(_INV3->TABELA,2,2)+"_YINCLAP + ROUND("+ALLTRIM(STR(ROUND(_INV3->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV3->RECNO))+" "
									TcSQLExec(cSql)

									_INV3->(DBSKIP())

								EndDo

							Else

								//05 - Prepara os valores para rateio por PRODUTO  
								//Montando base com os Investimentos realizados no mes por Cliente
								cSql := "SELECT	ZO_DATA, ZO_REPRE, ZO_CLIENTE, A1_YTPSEG, ZO_LOJA, ZO_VALOR	" + Enter
								cSql += "FROM "+RetSqlName("SZO")+" SZO, SA1"+cEmpAnt+"0 SA1				" + Enter
								cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 									" + Enter
								cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 				" + Enter
								cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 				" + Enter
								cSql += "		SZO.ZO_EMP     =  '"+nEmp[x]+"'			AND					" + Enter
								cSql += "		SZO.ZO_CLIENTE = SA1.A1_COD  			AND					" + Enter
								cSql += "		SZO.ZO_LOJA    = SA1.A1_LOJA 			AND					" + Enter
								cSql += "		SZO.ZO_REPRE   = '"+_SZO->ZO_REPRE+"'	AND					" + Enter
								cSql += "		SZO.ZO_CLIENTE = '"+_SZO->ZO_CLIENTE+"'	AND					" + Enter
								cSql += "		SZO.ZO_LOJA    = '"+_SZO->ZO_LOJA+"'	AND 				" + Enter
								cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND					" + Enter
								cSql += "		SZO.ZO_REPRE   NOT IN ('000258','999999') AND 				" + Enter
								cSql += "		ZO_STATUS	   = 'Baixa Total' 			AND 				" + Enter
								cSql += "		SZO.D_E_L_E_T_ = '' 					AND					" + Enter
								cSql += "		SA1.D_E_L_E_T_ = '' 										" + Enter
								If CHKFILE("_RAC")
									dbSelectArea("_RAC")
									dbCloseArea()
								EndIf
								TcQuery cSql ALIAS "_RAC" NEW
								dbSelectArea("_RAC")
								dbGoTop()

								//05 - Grava valores para rateio por PRODUTO
								Do While !_RAC->(EOF())

									cSql := "INSERT INTO TBL_INVEST_ACUMULADO (EMP, MES, REPRES, CLIENTE, LOJA, TPSEG, VLR_INV) VALUES ('"+nEmp[x]+"','"+(_RAC->ZO_DATA)+"','"+_RAC->ZO_REPRE+"','"+_RAC->ZO_CLIENTE+"','"+_RAC->ZO_LOJA+"','"+_RAC->A1_YTPSEG+"',"+Alltrim(Str(_RAC->ZO_VALOR))+") "
									TcSQLExec(cSql)

									_RAC->(DBSKIP())

								EndDo

							EndIf

						EndIf	

					EndIf

				Else

					//04 - Rateia o valor do Investimento do REPRESENTANTE
					cSql := "SELECT INVEST = CASE																				" + Enter
					cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE VEND1 = '"+_SZO->ZO_REPRE+"' ) <> 0 THEN									" + Enter
					cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE VEND1 = '"+_SZO->ZO_REPRE+"')*"+Alltrim(Str(_SZO->INVEST))+",2)	" + Enter
					cSql += "					ELSE 0 END, * 																	" + Enter
					cSql += "FROM "+nNomeTMP+" 																					" + Enter
					cSql += "WHERE TABELA IN ('SD1','SD2') AND VEND1 = '"+_SZO->ZO_REPRE+"' " + Enter
					If chkfile("_INV2")
						dbSelectArea("_INV2")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_INV2"

					If !_INV2->(EOF()) .And. _INV2->INVEST <> 0

						//04 - Grava o rateio do Investimento para as vendas do REPRESENTANTE
						Do While !_INV2->(EOF())

							cSql := "UPDATE "+_INV2->TABELA+Substr(_INV2->EMP,1,2)+"0 SET "+Substr(_INV2->TABELA,2,2)+"_YINCLAC = "+Substr(_INV2->TABELA,2,2)+"_YINCLAC + ROUND("+ALLTRIM(STR(ROUND(_INV2->INVEST,2)))+",2), "+Substr(_INV2->TABELA,2,2)+"_YINCLAP = "+Substr(_INV2->TABELA,2,2)+"_YINCLAP + ROUND("+ALLTRIM(STR(ROUND(_INV2->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV2->RECNO))+" "
							TcSQLExec(cSql)

							_INV2->(DBSKIP())

						EndDo

					Else

						//05 - Prepara os valores para rateio por PRODUTO
						//Montando base com os Investimentos realizados no mes por Cliente
						cSql := "SELECT	ZO_DATA, ZO_REPRE, ZO_CLIENTE, A1_YTPSEG, ZO_LOJA, ZO_VALOR	" + Enter
						cSql += "FROM "+RetSqlName("SZO")+" SZO, SA1"+cEmpAnt+"0 SA1				" + Enter
						cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 									" + Enter
						cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 				" + Enter
						cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 				" + Enter
						cSql += "		SZO.ZO_EMP     =  '"+nEmp[x]+"'			AND					" + Enter
						cSql += "		SZO.ZO_CLIENTE = SA1.A1_COD  			AND					" + Enter
						cSql += "		SZO.ZO_LOJA    = SA1.A1_LOJA 			AND					" + Enter
						cSql += "		SZO.ZO_REPRE   = '"+_SZO->ZO_REPRE+"'	AND					" + Enter
						cSql += "		SZO.ZO_CLIENTE = '"+_SZO->ZO_CLIENTE+"'	AND					" + Enter
						cSql += "		SZO.ZO_LOJA    = '"+_SZO->ZO_LOJA+"'	AND 				" + Enter
						cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND					" + Enter
						cSql += "		SZO.ZO_REPRE   NOT IN ('000258','999999') AND 				" + Enter
						cSql += "		ZO_STATUS	   = 'Baixa Total' 			AND 				" + Enter
						cSql += "		SZO.D_E_L_E_T_ = '' 					AND					" + Enter
						cSql += "		SA1.D_E_L_E_T_ = '' 										" + Enter
						If CHKFILE("_RAC")
							dbSelectArea("_RAC")
							dbCloseArea()
						EndIf
						TcQuery cSql ALIAS "_RAC" NEW
						dbSelectArea("_RAC")
						dbGoTop()

						//05 - Grava valores para rateio por PRODUTO
						Do While !_RAC->(EOF())

							cSql := "INSERT INTO TBL_INVEST_ACUMULADO (EMP, MES, REPRES, CLIENTE, LOJA, TPSEG, VLR_INV) VALUES ('"+nEmp[x]+"','"+(_RAC->ZO_DATA)+"','"+_RAC->ZO_REPRE+"','"+_RAC->ZO_CLIENTE+"','"+_RAC->ZO_LOJA+"','"+_RAC->A1_YTPSEG+"',"+Alltrim(Str(_RAC->ZO_VALOR))+") "
							TcSQLExec(cSql)

							_RAC->(DBSKIP())

						EndDo											

					EndIf	

				EndIf 

			EndIf

			_SZO->(DBSKIP())
		EndDo

		//RATEIO POR EMPRESA
		//Montando base com os Investimentos Empresa realizados no mes agrupando por Representante
		cSql := "SELECT	SUM(ZO_VALOR) INVEST_EMP						" + Enter
		cSql += "FROM "+RetSqlName("SZO")+" SZO							" + Enter
		cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
		cSql += "		SZO.ZO_DATA    >= '"+Dtos(MV_PAR01)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_DATA    <= '"+Dtos(MV_PAR02)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_EMP     =  '"+nEmp[x]+"'			AND		" + Enter
		cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
		cSql += "		SZO.ZO_REPRE   IN ('000258','999999') 	AND 	" + Enter
		cSql += "		ZO_STATUS	   = 'Baixa Total' AND 				" + Enter
		cSql += "		SZO.D_E_L_E_T_ = '' 							" + Enter
		If CHKFILE("_SZO")
			dbSelectArea("_SZO")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_SZO" NEW
		dbSelectArea("_SZO")
		dbGoTop()

		//RATEIO PRODUTOS SEM VENDA
		//Montando base com os Investimentos realizados no mes agrupando por Cliente
		cSql := "SELECT	SUM(VLR_INV) AS INVEST_PROD			" + Enter
		cSql += "FROM TBL_INVEST_ACUMULADO					" + Enter
		cSql += "WHERE	EMP = '"+nEmp[x]+"'			AND		" + Enter   
		cSql += "		MES >= '"+DTOS(MV_PAR01)+"'	AND		" + Enter   
		cSql += "		MES <= '"+DTOS(MV_PAR02)+"'			" + Enter   	
		If CHKFILE("_SZO2")
			dbSelectArea("_SZO2")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_SZO2" NEW
		dbSelectArea("_SZO2")
		dbGoTop()


		//Rateia o valor do Investimento de acordo com a movimentacao do Cliente
		cSql := "SELECT INVEST_EMP = CASE																			   												" + Enter
		cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') ) <> 0 THEN											" + Enter
		cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') )*"+Alltrim(Str(_SZO->INVEST_EMP))+",2)	" + Enter
		cSql += "					ELSE 0 END, 																													" + Enter
		cSql += "		INVEST_PROD = CASE																			   												" + Enter
		cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') ) <> 0 THEN											" + Enter
		cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') )*"+Alltrim(Str(_SZO2->INVEST_PROD))+",2)	" + Enter
		cSql += "					ELSE 0 END, 																	" + Enter
		cSql += "					(SELECT COUNT(*) FROM "+nNomeTMP+") LINHA, *				   					" + Enter
		cSql += "FROM "+nNomeTMP+" 																					" + Enter
		cSql += "WHERE TABELA IN ('SD1','SD2') " + Enter
		If chkfile("_INV")
			dbSelectArea("_INV")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "_INV"

		//Armazena Quantidade de Registros
		nQtdReg	:= _INV->LINHA

		//Monta Regua
		ProcRegua(nQtdReg)

		If !_INV->(EOF())

			//Grava o valor do Investimento de acordo com a movimentacao do Cliente
			Do While !_INV->(EOF())

				//If Alltrim(Str(_INV->RECNO)) $ ('651071_651072_651073')
				//	MsgAlert("ALERT")
				//EndIf		
				IncProc("Gravando Rateio Empresa...")

				//Rateio Empresa
				cSql := "UPDATE "+_INV->TABELA+Substr(_INV->EMP,1,2)+"0 SET "+Substr(_INV->TABELA,2,2)+"_YINEMGE = ROUND("+ALLTRIM(STR(ROUND(_INV->INVEST_EMP,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
				TcSQLExec(cSql)

				//Rateio Cliente por Produto			
				cSql := "UPDATE "+_INV->TABELA+Substr(_INV->EMP,1,2)+"0 SET "+Substr(_INV->TABELA,2,2)+"_YINCLAP = ROUND("+Substr(_INV->TABELA,2,2)+"_YINCLAP + "+ALLTRIM(STR(ROUND(_INV->INVEST_PROD,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
				TcSQLExec(cSql)

				_INV->(DBSKIP())
			EndDo
		EndIf

	Next

	//Fecha arquivo temporario
	If chkFile("_SZO")
		dbSelectArea("_SZO")
		dbCloseArea()
	EndIf

	If chkFile("_INV")
		dbSelectArea("_INV")
		dbCloseArea()
	EndIf

Return