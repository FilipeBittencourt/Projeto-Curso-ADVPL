#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "TOPCONN.CH"

User Function BACP0015(_cCarga, lJob)

	Default lJob := .F.
	//Local _cCarga := 'Z008'
	
	
	If (lJob)
		
		//RpcSetEnv('01','01')
		
		oTDadosCarga	:= TDadosCarga():New(_cCarga)
	
		aList := oTDadosCarga:GetListaMDF()
		
		StartJob("U_BACPMPDF", GetEnvServer(), .T., _cCarga, cEmpAnt, cFilAnt, aList, lJob)
		
		//U_BACPMPDF(_cCarga, cEmpAnt, cFilAnt, aList, lJob)
		
	EndIf	
	
Return

User Function BACPMPDF(_cCarga,_cEmpOri, _cFilOri, aListMDF, lJob)

	Local cIdEnt 		:= ""
	Local oDanfe		:= Nil
	Local oSetup		:= Nil
	Local cLocal		:= ""
	Local cNomeArq		:= ""
	Local nI			:= 0
	
	Local cNumero 		:= ""
	Local cSerie		:= ""
	Local cEmpMDF		:= ""
	Local nCont			:= 0
	Local aAux			:= {}
	Local oObjMDfe		:= Nil
	Local aRetorno 		:= {}
	
	For nI := 1 To Len(aListMDF)
	
		If aScan(aAux, {|x| x[1] + x[2] + x[3] == aListMDF[nI][1] + aListMDF[nI][2] + aListMDF[nI][3]}) == 0
		
			aAdd(aAux, {aListMDF[nI][1], aListMDF[nI][2], aListMDF[nI][3]})
		
		EndIf
	
	Next nI
	
	aListMDF := aAux
		
	If (lJob)
		cLocal 		:= "\P10\AUTOMACAO\MONITOR_IMPRESSAO\"
		cNomeArq	:= Upper(AllTrim(_cCarga)+"_"+_cEmpOri + '_MDFE')
	EndIf
	
	oDanfe := FWMSPrinter():New(cNomeArq, IMP_PDF, .F., '\spool\', .T., , ,, .T., .F.)
	
	oDanfe:lViewPDF		:= .F.
	oDanfe:cPathPDF		:= cLocal
	oDanfe:lServer  	:= .T.
	
	For nI := 1 To Len (aListMDF)
		
		cEmpMDF	:= aListMDF[nI][1]
		cNumero	:= aListMDF[nI][2]
		cSerie	:= aListMDF[nI][3]

		Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " - Inicio")

		If (nI == 1  .Or. cEmpAnt <> cEmpMDF)

			RpcClearEnv()
			
			RPCSetType(3)
			RPCSetEnv(cEmpMDF, "01")

			oObjMDfe := TMDFeAutomatico():New(.T.)
	
		EndIf
		
		DBSelectArea("CC0")
		CC0->(DBSetOrder(1)) // CC0_FILIAL, CC0_SERMDF, CC0_NUMMDF, R_E_C_N_O_, D_E_L_E_T_

		If CC0->(DBSeek(xFilial("CC0") + cSerie + cNumero))
		
			cIdEnt := GetCfgEntidade()

			If CC0->CC0_STATUS <> "3"
			
				aRetorno := oObjMDfe:MonitoraMDFe(cSerie, cNumero, cNumero) 
				
				// A funcao oObj:CargaOk((cAliasTemp)->CARGA) na BACP0017, faz select na SPED050 devido performance, com isso nao monitora a mdf-e e precisa estar com status 3.
				// Por isso esse tratamento.
				StaticCall(SPEDMDFE, UpdCC0, aRetorno)

			EndIf

			Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " u_fautdmdf - Inicio - CC0_STATUS " + CC0->CC0_STATUS)

			u_fautdmdf(cIdEnt, oDanfe, oSetup, cNomeArq, cNumero, cSerie)	

			Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " u_fautdmdf - Fim - CC0_STATUS " + CC0->CC0_STATUS)
			
			nCont += 1

		Else

			Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " NÃO ACHOU MDFE, VOU TENTAR GERAR MESMO ASSIM!")

			cIdEnt := GetCfgEntidade()

			u_fautdmdf(cIdEnt, oDanfe, oSetup, cNomeArq, cNumero, cSerie)

			nCont += 1
			
		EndIf

		Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " - Fim")
		
	Next nI
	
	If nCont > 0
		
		oDanfe:Print()

		Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " oDanfe:Print()")
		 
	Else

		Conout("BACP0017 ==> Carga: " + _cCarga + " [" + Time() + "] - Gerando documentos [MDF-e] - BACP0015 - " + cNumero + "/" + cSerie + " FERASE(" + cLocal + cNomeArq + ")")

		FERASE(cLocal + cNomeArq) //caso não encontrou nenhum registro valido
	
	EndIf
	
	FreeObj(oDanfe)
	oDanfe := Nil
	
	RpcClearEnv()
	
Return()