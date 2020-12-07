#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA673
@author Marcos Alberto Soprani
@since 27/07/2016
@version 1.0
@description Tratativa específica para controle de vencimento de contratos trabalhistas
@obs OS: 1383-16 - Claudia Mara
@type function
/*/

User Function BIA673()

	Local xt

	Private zp_EpAtu

	cv_ViaWf := .F.
	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05_06_13_14")
		For xt := 1 To Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2], "", "", "GPE", "",{"SRA"})

			cv_ViaWf := .T.
			zp_EpAtu := xv_Emps[xt,1]
			MV_PAR01 := dDataBase - 1
			MV_PAR02 := Substr(dtos(dDataBase - 30),1,6)+"11"
			ConOut("HORA: "+TIME()+" --> BIA673 - Iniciando Processo " + xv_Emps[xt,1])

			Processa({||B673PRC()})

			ConOut("HORA: "+TIME()+" --> BIA673 - Finalizando Processo " + xv_Emps[xt,1])

			RpcClearEnv()

		Next xt

	Else

		zp_EpAtu := cEmpAnt
		Aviso("Atenção (BIA673)", "Esta rotina irá ajustar o conteúdo dos campos de controle de vencimento de contrato de experiência", {"Ok"}, 3)

		Processa({||B673PRC()})

		MsgINFO("Fim do processamento...")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B673PRC  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27/07/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tela para processamento das gravações complementares       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function B673PRC()

	RY003 := " UPDATE "+RetSqlName("SRA")+" SET RA_DTFIMCT = RA_VCTEXP2 "
	RY003 += "   FROM "+RetSqlName("SRA")+" "
	RY003 += "  WHERE RA_SITFOLH <> 'D' "
	RY003 += "    AND RA_VCTOEXP < CONVERT(CHAR, getdate(), 112) "
	RY003 += "    AND RA_TPCONTR <> '1' "
	RY003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Processamento 1...",,{|| TcSQLExec(RY003)})

	RY007 := " UPDATE "+RetSqlName("SRA")+" SET RA_TPCONTR = '1' "
	RY007 += "   FROM "+RetSqlName("SRA")+" "
	RY007 += "  WHERE RA_SITFOLH <> 'D' "
	RY007 += "    AND RA_VCTEXP2 < CONVERT(CHAR, getdate(), 112) "
	RY007 += "    AND RA_TPCONTR <> '1' "
	RY007 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Processamento 2...",,{|| TcSQLExec(RY007)})

Return