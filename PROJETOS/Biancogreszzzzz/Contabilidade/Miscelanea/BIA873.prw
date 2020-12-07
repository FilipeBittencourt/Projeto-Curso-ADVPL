#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA873
@author Ranisses A. Corona
@since 18/07/2018
@version 1.0
@description Rotina para realizar o rateio dos valores do ICMS Credito e a Pagar para cálculo do MO2 - BI 3.0
@type function
/*/

User Function BIA873()

	Local  x

	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			Pergunte("BIA873",.F.)			
			MV_PAR01 := "05"	//Month2Str(MonthSub(dDataBase,1)) //Month2Str(dDataBase) //stod(alltrim(str(year(dDataBase)))+"0101")
			MV_PAR02 := "2018"	//Year2Str(MonthSub(dDataBase,1))  //Year2Str(dDataBase)  //Stod("20180131")//dDataBase
			MV_PAR03 := 3500000	//ICMS Creditado	
			MV_PAR04 := 1500000 //ICMS a Pagar			

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA873 " + xv_Emps[x,1])

			Processa({||RunProcCli()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA873 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else

		@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Rateio ICMS - MO2"
		@ 8,10 TO 84,222

		@ 16,12 SAY "Esta rotina tem por finalidade:                          "
		@ 24,12 SAY "Realizar o rateio dos valores do ICMS Credito e do       "
		@ 32,12 SAY "ICMS a Pagar para cálculo do MO2, utilizado no BI 3.0    "

		@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
		@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
		@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA873", .T.)

		ACTIVATE DIALOG oDlg5 CENTERED

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
	Local nNomeTMP	:= ""
	Local dDtIni	:= FirstDate(Stod(MV_PAR02+MV_PAR01+"01"))
	Local dDtFim	:= LastDate(Stod(MV_PAR02+MV_PAR01+"01"))


	If !cEmpAnt == "07"

		//Limpando os registros já gravados
		cSql := "UPDATE "+RetSqlName("SD2")+" SET D2_YICMCRE = 0 WHERE D2_FILIAL = '01' AND SUBSTRING(D2_YEMP,1,2) = '"+cEmpAnt+"' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Faturamento Empresa "+cEmpAnt+"...",,{|| TcSQLExec(cSql)})

		cSql := "UPDATE SD2070                SET D2_YICMCRE = 0 WHERE D2_FILIAL = '01' AND SUBSTRING(D2_YEMP,1,2) = '"+cEmpAnt+"' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
		U_BIAMsgRun("Limpando registros Faturamento LM ...",,{|| TcSQLExec(cSql)})	

		//Grava nome Tabela Temporaria
		nNomeTMP	:= "##BIA873ICMSCRE"+__cUserID+strzero(seconds()*3500,10)		

		//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
		cSql := "EXEC SP_BIA873 'MAR','"+cEmpAnt+"','"+nNomeTMP+"','"+Dtos(dDtIni)+"','"+Dtos(dDtFim)+"',"+Alltrim(Str(MV_PAR03))+","+Alltrim(Str(MV_PAR04))+" "
		MPSysOpenQuery( cSql, 'Qry' )

		//Monta Regua
		ProcRegua(Qry->QTD_REG)

		Do While !(Qry->(EOF()))
			IncProc("Gravando Rateio do ICMS Creditado..."+Alltrim(Str(Qry->RECNO)))

			cSql := "UPDATE SD2"+Qry->EMPRESA+"0 SET D2_YICMCRE = "+ALLTRIM(STR(ROUND(Qry->ICMSCRE,2)))+" WHERE R_E_C_N_O_ = "+Alltrim(Str(Qry->RECNO))+" "
			TcSQLExec(cSql)				

			Qry->(DBSkip())

		EndDo

	EndIf

	cSql := "UPDATE "+RetSqlName("SD2")+" SET D2_YICMPAG = 0 WHERE D2_FILIAL = '01' AND D2_EMISSAO >= '"+DTOS(dDtIni)+"' AND D2_EMISSAO <= '"+DTOS(dDtFim)+"' AND D_E_L_E_T_ = ''  "
	U_BIAMsgRun("Limpando registros Faturamento Empresa "+cEmpAnt+"...",,{|| TcSQLExec(cSql)})

	//Grava nome Tabela Temporaria
	nNomeTMP	:= "##BIA873ICMSPAG"+__cUserID+strzero(seconds()*3500,10)		

	//Montando base com o itens do fatumento e devolucao do mes (SD2 e SD1)
	cSql := "EXEC SP_BIA873 'EMP','"+cEmpAnt+"','"+nNomeTMP+"','"+Dtos(dDtIni)+"','"+Dtos(dDtFim)+"',"+Alltrim(Str(MV_PAR03))+","+Alltrim(Str(MV_PAR04))+" "
	MPSysOpenQuery( cSql, 'QryPAG' )

	//Monta Regua
	ProcRegua(QryPAG->QTD_REG)

	Do While !(QryPAG->(EOF()))
		IncProc("Gravando Rateio do ICMS a Pagar..."+Alltrim(Str(QryPAG->RECNO)))

		cSql := "UPDATE SD2"+QryPAG->EMPRESA+"0 SET D2_YICMPAG = "+ALLTRIM(STR(ROUND(QryPAG->ICMSPAG,2)))+" WHERE R_E_C_N_O_ = "+Alltrim(Str(QryPAG->RECNO))+" "
		TcSQLExec(cSql)				

		QryPAG->(DBSkip())

	EndDo

	//Fecha arquivo temporario
	If chkFile('Qry')
		dbSelectArea('Qry')
		dbCloseArea()
	EndIf

	//Fecha arquivo temporario
	If chkFile('QryPAG')
		dbSelectArea('QryPAG')
		dbCloseArea()
	EndIf

Return