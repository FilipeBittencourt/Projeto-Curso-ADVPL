#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"


User Function TWTCSFJ()
	Processa( {|| StartJob("U_TWTCSF", GetEnvServer(), .T.)}, "Gerando saldo bancário", "Processando...", .T.)
Return 

User Function TWTCSF()
	
	Local _Obj		:= Nil
	Local cListaEmp := {}
	Local nI		:= 0
	
	
	RpcSetEnv('01','01')

	cListaEmp := U_BAGtEmpr("01_02_03_04_05_07_08_09_10_11_12_13_14_15_17_90_91")

	RpcClearEnv()
	
	
	For nI:=1 to Len (cListaEmp)
	
		conout("Empresa=> "+cListaEmp[nI][1]+", Filial=> "+cListaEmp[nI][2])
		RPCSetEnv(cListaEmp[nI][1], cListaEmp[nI][2])
		
		If ChkFile("ZZM")
			_Obj := TWTransferirCSF():New()
			_Obj:Execute()	
		EndIf
		
		RPCClearEnv()
		
	Next nI
	
Return 

Class TWTransferirCSF From LongClassName

	Method New() Constructor
	Method Execute()
	Method GetBanco() 

EndClass

Method New () Class TWTransferirCSF
Return 

Method Execute() Class TWTransferirCSF

	Local aBanco		:= {}	
	Local aRetMovBan	:= {}
	
	Local nI			:= 0
	Local nSalAtu		:= 0
	
	Local cBanco 		:= "" 
	Local cAgencia		:= "" 
	Local cConta 		:= ""
	Local dStartDate	:= Nil
	Local dEndDate		:= Nil
	Local nP_BRW_SALDO  := 5
	
	//Day2Str(Date()) == '01'
	If (Day2Str(Date()) >= '01' .And. Day2Str(Date()) <= '06' .And. (DataValida(Date(), .T.) == Date())) //primeiro dia do mês
		
		dStartDate	:= DaySub(Date(), 1)
		dEndDate 	:= DaySub(Date(), 1)
		
		aBanco := ::GetBanco()
		
		For nI:=1 To Len(aBanco)
		
			cBanco 			:= aBanco[nI][1]
			cAgencia		:= aBanco[nI][2] 
			cConta 			:= aBanco[nI][3]
	
			oBO 			:= TComposicaoSaldoFinanceiro():New()
			oBO:cBank 		:= cBanco
			oBO:cAgency 	:= cAgencia
			oBO:cAccount 	:= cConta
			oBO:dStartDate 	:= dStartDate
			oBO:dEndDate 	:= dEndDate
			
			aRetMovBan 			:= oBO:GetMovBan()
			
			//ConOut("Processando registro ==> "+cBanco+'/'+cAgencia+'/'+cConta)
			
			If oBO:GetSalIni(.T.) == 0
	
				
				nSalAtu := aRetMovBan[Len(aRetMovBan)][nP_BRW_SALDO]
				//ConOut("Gerando saldo registro => ("+cBanco+'/'+cAgencia+'/'+cConta+'), valor saldo => '+cvaltochar(nSalAtu))
				If nSalAtu <> 0
					ConOut("Gerando saldo registro => ("+cBanco+'/'+cAgencia+'/'+cConta+'), valor saldo => '+cvaltochar(nSalAtu))
					oBO:Generate(nSalAtu)
				Else
					ConOut("O saldo atual está zerado!")
				EndIf
				
			Else
				ConOut("O saldo inicial do mês: " + Month2Str(MonthSum(dStartDate, 1)) + "/" + Year2Str(dStartDate) + " já foi lançado!")
			EndIf
				
		Next nI
				
	EndIf

Return 


Method GetBanco() Class TWTransferirCSF

	Local aResult 		:= {}
	Local cQuery 		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local cBanco 		:= "" 
	Local cAgencia		:= "" 
	Local cConta 		:= ""
		
	cQuery := " SELECT  A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME 				"
	cQuery += "	FROM "+ RetSQLName("SA6") + " SA6 							"
	cQuery += "	INNER JOIN "+ RetSQLName("SE8") + " SE8 					"
	cQuery += "	ON A6_COD = E8_BANCO 										"
	cQuery += "	AND A6_AGENCIA = E8_AGENCIA 								"
	cQuery += "	AND A6_NUMCON = E8_CONTA 									"
	cQuery += "	WHERE A6_FILIAL = "+ ValToSQL(xFilial("SA6"))+"				"
	cQuery += "	AND A6_BLOCKED = '2' 										"
	cQuery += "	AND SA6.D_E_L_E_T_ = '' 									"
	cQuery += "	AND E8_FILIAL = "+ ValToSQL(xFilial("SE8"))+"				"	
	cQuery += "	AND SE8.D_E_L_E_T_ = '' 									"
	cQuery += "	GROUP BY A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME 			"
	cQuery += "	ORDER BY A6_COD 											"

	TcQuery cQuery New Alias (cAliasTemp)

	While !(cAliasTemp)->(Eof())	
		
		cBanco 		:= (cAliasTemp)->A6_COD 
		cAgencia	:= AllTrim((cAliasTemp)->A6_AGENCIA) 
		cConta 		:= AllTrim((cAliasTemp)->A6_NUMCON)
		
		Aadd(aResult, {cBanco, cAgencia, cConta})
		
		(cAliasTemp)->(DbSkip())

	EndDo()

	(cAliasTemp)->(DbCloseArea())

Return(aResult)
