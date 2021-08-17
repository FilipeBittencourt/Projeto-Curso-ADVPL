#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA872
@author Ranisses A. Corona
@since 26/06/2018
@version 1.0
@description Rotina com as novas regras para rateio MENSAL dos Investimentos
@type function
/*/

User Function BIA872()

	Local x

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			Pergunte("BIA872",.F.)			
			MV_PAR01 := "01" //Month2Str(MonthSub(dDataBase,1)) //Month2Str(dDataBase) //stod(alltrim(str(year(dDataBase)))+"0101")
			MV_PAR02 := "2018" //Year2Str(MonthSub(dDataBase,1))  //Year2Str(dDataBase)  //Stod("20180131")//dDataBase

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA872 " + xv_Emps[x,1])

			Processa({||RunProcCli()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA872 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else

		@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Rateio Invest. Mensal"
		@ 8,10 TO 84,222

		@ 16,12 SAY "Esta rotina tem por finalidade:                          "
		@ 24,12 SAY "Realizar o rateio e gravação do valor do Investimentos   "
		@ 32,12 SAY "nas NFs de Faturamento e Devolução, no mês.              "

		@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
		@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
		@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA872", .T.)

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
	Local cSql		:= ""
	Local Enter		:= CHR(13)
	Local nQtdReg	:= 0
	Local nNomeTMP	:= ""
	Local nTempCLI	:= ""
	Local nTempVEN	:= ""
	Local aMarca	:= {"0101","0501","0599","1302","1399"}
	Local dDtIni	:= FirstDate(Stod(MV_PAR02+MV_PAR01+"01"))
	Local dDtFim	:= LastDate(Stod(MV_PAR02+MV_PAR01+"01"))
	Local dDt6Ini	:= FirstDate(MonthSub((Stod(MV_PAR02+MV_PAR01+"01")),6))
	Local dDt6Fim	:= LastDate(MonthSub((Stod(MV_PAR02+MV_PAR01+"01")),1))
	Local x

	//Limpando os registros já gravados
	cSql := "UPDATE SD2010 SET D2_YCLIINV = 0, D2_YEMPINV = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa 01 ...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2050 SET D2_YCLIINV = 0, D2_YEMPINV = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa 05 ...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2070 SET D2_YCLIINV = 0, D2_YEMPINV = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa 07 ...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2130 SET D2_YCLIINV = 0, D2_YEMPINV = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa 13 ...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE SD2140 SET D2_YCLIINV = 0, D2_YEMPINV = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa 14 ...",,{|| TcSQLExec(cSql)})

	cSql := "UPDATE ZCF010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZCF_DATA >= '"+DTOS(dDtIni)+"' AND ZCF_DATA <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Rateio ...",,{|| TcSQLExec(cSql)})


	For x := 1 to Len(aMarca)

		//RATEIO POR CLIENTE
		//Montando base com os Investimentos realizados no mes agrupando por Cliente
		cSql := "SELECT	ZO_REPRE, ZO_CLIENTE, ZO_LOJA, SUM(ZO_VALOR) INVEST,					" + Enter
		cSql += "		ROW_NUMBER() OVER (ORDER BY ZO_REPRE DESC, ZO_CLIENTE DESC) AS LINHA	" + Enter
		cSql += "FROM (SELECT * FROM SZO010 UNION ALL SELECT * FROM SZO050) SZO 				" + Enter
		cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
		cSql += "		SZO.ZO_DATA    >= '"+Dtos(dDtIni)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_DATA    <= '"+Dtos(dDtFim)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_EMP     =  '"+aMarca[x]+"'		AND		" + Enter
		cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
		cSql += "		SZO.ZO_CLIENTE NOT IN ('000481','022551','005884','005885','004536','010083','010064','025633','025634','025704','999999') AND		" + Enter
		cSql += "		SZO.ZO_STATUS  = 'Baixa Total' 			AND		" + Enter
		cSql += "		SZO.ZO_SI 	   = '999999' 				AND		" + Enter	
		cSql += "		SZO.D_E_L_E_T_ = ''				 				" + Enter
		cSql += "GROUP BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA					" + Enter
		cSql += "ORDER BY ZO_REPRE, ZO_CLIENTE, ZO_LOJA					" + Enter
		If chkFile("_SZO")
			dbSelectArea("_SZO")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_SZO" NEW
		dbSelectArea("_SZO")
		dbGoTop()

		//Armazena Quantidade de Registros
		nQtdReg	:=	_SZO->LINHA

		//Grava nome Tabela Temporaria
		nNomeTMP	:= "##BIA872TMP"+aMarca[x]+__cUserID+strzero(seconds()*3500,10)		

		//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
		cSql := "EXEC SP_BIA872 '"+nNomeTMP+"','"+aMarca[x]+"','      ','ZZZZZZ','      ','ZZZZZZ','"+Dtos(dDtIni)+"','"+Dtos(dDtFim)+"',0 "
		U_BIAMsgRun("Montando Base Marca "+aMarca[x]+"...",,{|| TcSQLExec(cSql)})

		//Monta Regua
		ProcRegua(nQtdReg)

		//Verifica todos os clientes com Investimento
		Do While !_SZO->(EOF())
			IncProc("Gravando Rateio Marca "+aMarca[x]+" / Cliente "+_SZO->ZO_CLIENTE+"/"+_SZO->ZO_LOJA)

			//01 - Rateia o valor do Investimento do CLIENTE + VENDEDOR
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
			If !_INV->(EOF())

				Do While !_INV->(EOF())

					cSql := "UPDATE "+_INV->TABELA+_INV->EMPRESA+"0 SET "+Substr(_INV->TABELA,2,2)+"_YCLIINV = "+Substr(_INV->TABELA,2,2)+"_YCLIINV + ROUND("+ALLTRIM(STR(ROUND(_INV->INVEST,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
					TcSQLExec(cSql)				

					_INV->(DBSKIP())

				EndDo

			Else

				//Não encontrou Venda no periodo, irá grava tabela auxiliar
				nTempCLI	:= "##BIA782CLI"+aMarca[x]+Alltrim(_SZO->ZO_CLIENTE)+Alltrim(_SZO->ZO_LOJA)+__cUserID+strzero(seconds()*3500,10)		

				//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
				cSql := "EXEC SP_BIA872 '"+nTempCLI+"','"+aMarca[x]+"','"+_SZO->ZO_CLIENTE+"','"+_SZO->ZO_CLIENTE+"','      ','ZZZZZZ','"+Dtos(dDt6Ini)+"','"+Dtos(dDt6Fim)+"',"+Alltrim(Str(_SZO->INVEST))+" "
				MPSysOpenQuery( cSql, 'QrySA1' )

				If !(QrySA1->(EOF()))

					//MSGALERT("NÃO VENDA NOS ULTIMOS SEIS MESES PARA TESTE CLIENTE => "+_SZO->ZO_CLIENTE)

					While !(QrySA1->(EOF()))

						ZCF->(RecLock("ZCF",.T.))
						ZCF->ZCF_FILIAL	:= xFilial("ZCF")
						ZCF->ZCF_TIPO	:= "CLI" 
						ZCF->ZCF_EMP	:= Substr(QrySA1->MARCA,1,2)
						ZCF->ZCF_UN		:= Substr(QrySA1->MARCA,1,2)
						ZCF->ZCF_MARCA	:= QrySA1->MARCA
						ZCF->ZCF_DATA	:= dDtIni
						ZCF->ZCF_VEND	:= _SZO->ZO_REPRE
						ZCF->ZCF_CLIENT	:= _SZO->ZO_CLIENTE
						ZCF->ZCF_LOJA	:= _SZO->ZO_LOJA
						ZCF->ZCF_COD	:= QrySA1->PRODUTO
						ZCF->ZCF_VLRCLI	:= QrySA1->VLR_INV
						ZCF->(MsUnLock())									

						QrySA1->(DBSkip())
					Enddo

				Else

					//Não encontrou Venda para o Cliente no periodo, irá buscar por Vendedor
					nTempVEN	:= "##BIA782VEN"+aMarca[x]+_SZO->ZO_REPRE+__cUserID+strzero(seconds()*3500,10)		

					//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
					cSql := "EXEC SP_BIA872 '"+nTempVEN+"','"+aMarca[x]+"','      ','ZZZZZZ','"+_SZO->ZO_REPRE+"','"+_SZO->ZO_REPRE+"','"+Dtos(dDt6Ini)+"','"+Dtos(dDt6Fim)+"',"+Alltrim(Str(_SZO->INVEST))+" "
					MPSysOpenQuery( cSql, 'QrySA3' )

					If !(QrySA3->(EOF()))					

						//MSGALERT("NÃO VENDA NOS ULTIMOS SEIS MESES PARA TESTE VENDEDOR => "+_SZO->ZO_REPRE)

						While !(QrySA3->(EOF()))

							ZCF->(RecLock("ZCF",.T.))
							ZCF->ZCF_FILIAL	:= xFilial("ZCF")
							ZCF->ZCF_TIPO	:= "VEN"
							ZCF->ZCF_EMP	:= Substr(QrySA3->MARCA,1,2)
							ZCF->ZCF_UN		:= Substr(QrySA3->MARCA,1,2)						
							ZCF->ZCF_MARCA	:= QrySA3->MARCA
							ZCF->ZCF_DATA	:= dDtIni
							ZCF->ZCF_VEND	:= _SZO->ZO_REPRE
							ZCF->ZCF_CLIENT	:= _SZO->ZO_CLIENTE
							ZCF->ZCF_LOJA	:= _SZO->ZO_LOJA
							ZCF->ZCF_COD	:= QrySA3->PRODUTO
							ZCF->ZCF_VLRCLI	:= QrySA3->VLR_INV
							ZCF->(MsUnLock())									

							QrySA3->(DBSkip())

						Enddo

					Else				


						//Não encontrou Venda para o Cliente no periodo, irá buscar por Vendedor
						nTempVEN	:= "##BIA782GERAL"+aMarca[x]+__cUserID+strzero(seconds()*3500,10)		

						//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
						cSql := "EXEC SP_BIA872 '"+nTempVEN+"','"+aMarca[x]+"','      ','ZZZZZZ','      ','ZZZZZZ','"+Dtos(dDt6Ini)+"','"+Dtos(dDt6Fim)+"',"+Alltrim(Str(_SZO->INVEST))+" "
						MPSysOpenQuery( cSql, 'QryGER' )

						If !(QryGER->(EOF()))					

							//MSGALERT("NÃO VENDA NOS ULTIMOS SEIS MESES PARA TESTE GERAL => "+_SZO->ZO_REPRE)

							While !(QryGER->(EOF()))

								ZCF->(RecLock("ZCF",.T.))
								ZCF->ZCF_FILIAL	:= xFilial("ZCF")
								ZCF->ZCF_TIPO	:= "EMP" 
								ZCF->ZCF_EMP	:= Substr(QryGER->MARCA,1,2)
								ZCF->ZCF_UN		:= Substr(QryGER->MARCA,1,2)							
								ZCF->ZCF_MARCA	:= QryGER->MARCA
								ZCF->ZCF_DATA	:= dDtIni
								ZCF->ZCF_VEND	:= _SZO->ZO_REPRE
								ZCF->ZCF_CLIENT	:= _SZO->ZO_CLIENTE
								ZCF->ZCF_LOJA	:= _SZO->ZO_LOJA
								ZCF->ZCF_COD	:= QryGER->PRODUTO
								ZCF->ZCF_VLRCLI	:= QryGER->VLR_INV
								ZCF->(MsUnLock())									

								QryGER->(DBSkip())

							Enddo

						EndIf

					EndIf					

				EndIf

			EndIf	

			If chkFile("QrySA1")
				dbSelectArea("QrySA1")
				dbCloseArea()
			EndIf
			If chkFile("QrySA3")
				dbSelectArea("QrySA3")
				dbCloseArea()
			EndIf
			If chkFile("QryGER")
				dbSelectArea("QryGER")
				dbCloseArea()
			EndIf

			_SZO->(DBSKIP())

		EndDo

		//RATEIO POR EMPRESA
		//Montando base com os Investimentos Empresa realizados no mes agrupando por Representante
		cSql := "SELECT	SUM(ZO_VALOR) INVEST_EMP						" + Enter
		cSql += "FROM (SELECT * FROM SZO010 UNION ALL SELECT * FROM SZO050) SZO					" + Enter
		cSql += "WHERE	SZO.ZO_FILIAL  = '01' AND 						" + Enter
		cSql += "		SZO.ZO_DATA    >= '"+Dtos(dDtIni)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_DATA    <= '"+Dtos(dDtFim)+"' 	AND 	" + Enter
		cSql += "		SZO.ZO_EMP   	=  '"+aMarca[x]+"'		AND		" + Enter
		cSql += "		SZO.ZO_FPAGTO  IN ('1','3') 			AND		" + Enter
		cSql += "		SZO.ZO_CLIENTE IN ('000481','022551','005884','005885','004536','010083','010064','025633','025634','025704','999999') AND		" + Enter
		cSql += "		SZO.ZO_STATUS  = 'Baixa Total' 			AND 	" + Enter
		cSql += "		SZO.ZO_SI  	   = '999999' 				AND		" + Enter
		cSql += "		SZO.D_E_L_E_T_ = '' 							" + Enter
		If CHKFILE("_SZO")
			dbSelectArea("_SZO")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_SZO" NEW
		dbSelectArea("_SZO")
		dbGoTop()

		//Rateia o valor do Investimento de acordo com a movimentacao do Cliente
		cSql := "SELECT INVEST_EMP = CASE																			   														" + Enter
		cSql += "					WHEN (SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') ) <> 0 THEN											" + Enter
		cSql += "					ROUND(VLR_REAL/(SELECT ROUND(SUM(VLR_REAL),2) FROM "+nNomeTMP+" WHERE TABELA IN ('SD1','SD2') )*"+Alltrim(Str(_SZO->INVEST_EMP))+",2)	" + Enter
		cSql += "					ELSE 0 END,																																" + Enter
		cSql += "					(SELECT COUNT(*) FROM "+nNomeTMP+") LINHA, *				   																			" + Enter
		cSql += "FROM "+nNomeTMP+" 																																			" + Enter
		cSql += "WHERE TABELA IN ('SD1','SD2') 																																" + Enter
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

				IncProc("Gravando Rateio Empresa Marca "+aMarca[x]+"...")

				//Rateio Empresa
				cSql := "UPDATE "+_INV->TABELA+_INV->EMPRESA+"0 SET "+Substr(_INV->TABELA,2,2)+"_YEMPINV = "+Substr(_INV->TABELA,2,2)+"_YEMPINV + ROUND("+ALLTRIM(STR(ROUND(_INV->INVEST_EMP,2)))+",2) WHERE R_E_C_N_O_ = "+Alltrim(Str(_INV->RECNO))+" "
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
