#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFCnabPagar
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para geração de borderos de recebimento, agrupados por regras/banco
@type class
/*/

#DEFINE NPOSBORDE	1
#DEFINE NPOSBORATE 	2
#DEFINE NPOSBANCO	3
#DEFINE NPOSAGENCI 	4
#DEFINE NPOSCONTA	5
#DEFINE NPOSSUBCTA 	6
#DEFINE NPOSARQCFG 	7
#DEFINE NPOSAMBIEN 	8
#DEFINE NPOSLAYOUT 	9
#DEFINE NPOSARQUSR 	10
#DEFINE NPOSTPCOM 	11
#DEFINE NPOSOPPAG	12

Static aCNABItem := {}
Static oLogCnab := Nil

Class TAFCnabPagar From LongClassName

	Data oLst // Objeto com a lista titulos para criacao do bordero
	Data cTipo
	Data cOpcEnv
	Data cIDProc // Identificar do processo
	Data oLog // Objeto de Log
	Data oLogCnab
	Data aArea
	
	Method New() Constructor
	Method SetPergunte()
	Method CreatePath(cPath)
	Method NickName(cBanco, aItem)
	Method GetPrefixo(aItem)
	Method GetNameFile(aItem)
	Method Send()
	
EndClass


Method New() Class TAFCnabPagar
	
	::oLst := Nil
	::cIDProc := ""
	::oLog := TAFLog():New()
	::oLogCnab := TAFLogCnab():New()
	
	::aArea := {}
	
Return()

Method SetPergunte() Class TAFCnabPagar
	
	Local aItem := {}
	Local cPasta := ""
	
	If ( IsInCallStack("U_BAF001") .Or. IsInCallStack("U_BAF014") .Or. IsInCallStack("U_BAF015") .Or. IsInCallStack("U_BAF021") )
		
		aItem := U_TAFSELF()
		
		Pergunte("AFI420", .F.)
		
		MV_PAR01 := aItem[1][NPOSBORDE]											//Do Bordero
		MV_PAR02 := aItem[1][NPOSBORATE]											//Ate Bordero
		MV_PAR03 := AllTrim(aItem[1][NPOSARQCFG])									//Arq.Configuracao
		MV_PAR04 := ""																//Arq. Saida
		MV_PAR05 := PADR(aItem[1][NPOSBANCO], TamSX3("EE_CODIGO")[1], " ")		//Banco
		MV_PAR06 := PADR(aItem[1][NPOSAGENCI], TamSX3("EE_AGENCIA")[1], " ")	//Agencia
		MV_PAR07 := PADR(aItem[1][NPOSCONTA], TamSX3("EE_CONTA")[1], " ")		//Conta
		MV_PAR08 := PADR(aItem[1][NPOSSUBCTA], TamSX3("EE_SUBCTA")[1], " ")		//Sub-Conta
		MV_PAR09 := aItem[1][NPOSLAYOUT]											//Modelo 1/Modelo 2
		MV_PAR10 := 1																//Cons.Filiais Abaixo
		MV_PAR11 := ""																//Filial de
		MV_PAR12 := "ZZ"															//Filial Ate
		MV_PAR13 := 0																//Receita Bruta Acumulada
		MV_PAR14 := 2																//Seleciona Filiais
		
		cPasta := AllTrim(aItem[1][NPOSARQUSR]) + "\" + cEmpAnt + cFilAnt + "\PAGAMENTOS\SAIDA\"
		
		::CreatePath(cPasta)
		
		MV_PAR04 := cPasta + ::GetNameFile(aItem[1])
		
		aItem[2]:cBordeDe	:= MV_PAR01
		aItem[2]:cBordeAte 	:= MV_PAR02
		aItem[2]:cBanco		:= MV_PAR05
		aItem[2]:cAgencia	:= MV_PAR06
		aItem[2]:cConta		:= MV_PAR07
		aItem[2]:cSubCta	:= MV_PAR08
		aItem[2]:cLayout	:= cValToChar(MV_PAR09)
		aItem[2]:cArqcfg	:= SubStr(AllTrim(MV_PAR03), Rat("\", MV_PAR03) + 1, 100)
		aItem[2]:cArqUser	:= SubStr(AllTrim(MV_PAR04), Rat("\", MV_PAR04) + 1, 100)
		
		aItem[2]:Insert()
		
	Else
	
		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] " + cEmpAnt + cFilAnt + " - TAFCnabPagar - SetPergunte() " + " - DATE: "+DTOC(Date())+" TIME: "+Time() + " - NÃO EXECUTOU")
		
	EndIf
	
Return()


Method Send() Class TAFCnabPagar

	Local cPath := ""
	Local cFileLog := ""
	Local cErro := ""
	Local aItem := {}
	Local oItem := Nil
	Local nPos := 0
	Local nW := 0
	Local nX := 0
	
	Private lMsErroAuto := .F.
		
	Private INCLUI := .T.

	For nW := 1 To ::oLst:GetCount()

		oItem := ::oLst:GetItem(nW)

		nPos := aScan(aItem, {|x| x[NPOSBORDE] + x[NPOSBORATE] == oItem:cNumBor + oItem:cNumBor})

		If nPos == 0

			aAdd(aItem, {	oItem:cNumBor,;		//NPOSBORDE 	1
							oItem:cNumBor,;		//NPOSBORATE 	2
							oItem:cBanco,;		//NPOSBANCO 	3
							oItem:cAgencia,;	//NPOSAGENCI 	4
							oItem:cConta,;		//NPOSCONTA 	5
							oItem:cSubCta,;		//NPOSSUBCTA 	6
							oItem:cArqcfg,;		//NPOSARQCFG 	7
							oItem:cAmbiente,;	//NPOSAMBIEN 	8
							Val(oItem:cLayout),;//NPOSLAYOUT 	9
							oItem:cArqUser,;	//NPOSARQUSR 	10
							oItem:cTpCom,;		//NPOSTPCOM 	11
							oItem:cOperPg})		//NPOSOPPAG 	12

		EndIf

	Next nW
	
	For nW := 1 To Len(aItem)
		
		aCNABItem := @aItem[nW]
		
		::oLogCnab:SetProperty()
		
		oLogCnab := @::oLogCnab
		
		INCLUI := .T.

		For nX := 1 To Len(::aArea)
		
			RestArea(::aArea[nX])
		
		Next nX
		
		DBSelectArea("SEA")
		DBSelectArea("SE2")
		
		MsExecAuto({|x| FINA420(x)}, 2)
		
		If lMsErroAuto
				
			cPath := GetSrvProfString("Startpath", "")
				
			cFileLog := "TAFCnabPagar" + "_" + cEmpAnt + cFilAnt + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"

			cErro := MostraErro(cPath, cFileLog)
			
			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "P"
			::oLog:cTabela := RetSQLName("ZK3")
			::oLog:nIDTab := 0
			::oLog:cMetodo := "CP_CNAB"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := If(Empty(cErro), "Erro desconhecido", cErro)
			::oLog:cEnvWF := "S"
			
			::oLogCnab:cMsgCnab := ::oLog:cRetMen
			//::oLogCnab:cArqUser := ""
			
			::oLog:nIDTab := ::oLogCnab:nRecno
			
			::oLogCnab:Update()
			
			::oLog:Insert()

		Else
	
			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "P"
			::oLog:cTabela := RetSQLName("ZK3")
			::oLog:nIDTab := 0
			::oLog:cMetodo := "CP_CNAB"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Arquivo criado com sucesso"
			::oLog:cEnvWF := "S"
			
			::oLogCnab:cMsgCnab := ::oLog:cRetMen
			
			::oLog:nIDTab := ::oLogCnab:nRecno
			
			::oLogCnab:Update()

			::oLog:Insert()
						
		EndIf
		
		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] " + cEmpAnt + cFilAnt + " - TAFCnabPagar - " + "Bordero: " + aItem[nW][1] + " ate " + aItem[nW][2] + " - DATE: "+DTOC(Date())+" TIME: "+Time() + cErro)
		
	Next nW
	
Return()

Method NickName(cBanco, aItem) Class TAFCnabPagar
	
	Local cRet := ""
	
	Default cBanco := ""

	If aItem[NPOSTPCOM] == "4" // Arquivo CNAB / Web Api
	
		cRet := ::GetPrefixo(aItem)
	
	EndIf
	
	If cBanco == "001"
		
		cRet += If(Empty(cRet), "BB", "")
			
	ElseIf cBanco == "237"
		
		cRet += If(Empty(cRet), "BR", "")
			
	ElseIf cBanco == "021"
		
		cRet += If(Empty(cRet), "BA", "")

	ElseIf cBanco == "104"
		
		cRet += If(Empty(cRet), "CEF", "")
				
	Else
		
		cRet += If(Empty(cRet), "XX", "XX")
		
	EndIf

Return(cRet)

Method CreatePath(cPath) Class TAFCnabPagar
	
	Local aPath := {}
	Local nW := 0
	
	Default cPath := ""
	
	aPath := StrToKarr(cPath, "\")
	
	For nW := 1 To Len(aPath)
		
		If At(":", aPath[nW]) > 0
			
			aPath[nW + 1] := aPath[nW] + "\" + aPath[nW + 1]
			
			aDel(aPath, 1)
			
			aSize(aPath, Len(aPath) - 1 )
			
			Exit
			
		EndIf
	
	Next nW
	
	cPath := ""
	
	For nW := 1 To Len(aPath)
		
		cPath += If(nW == 1, "", "\") + aPath[nW]
		
		If ! File(cPath)
		
			If MakeDir( cPath,,.F. ) <> 0
			
				Conout("TAFCnabPagar - Erro ao criar pasta")
				
			EndIf
			
		EndIf
	
	Next nW

Return()

Method GetNameFile(aItem) Class TAFCnabPagar
	
	Local cRet := ""
	Local cSepardor := If(aItem[NPOSTPCOM] == "4", "", "_") // Arquivo CNAB / Web Api
	
	cRet := ::NickName(MV_PAR05, aItem) + cSepardor + cEmpAnt + cFilAnt + cSepardor + If(MV_PAR01 == MV_PAR02, MV_PAR01, MV_PAR01 + cSepardor + MV_PAR02) + ".REM"
	
Return(cRet)

Method GetPrefixo(aItem) Class TAFCnabPagar
	
	Local cRet := ""
	
	If aItem[NPOSOPPAG] $ "2|7" .And. aItem[NPOSLAYOUT] == 1
	
		cRet := "PFEB" // PAGAMENTO FORNECEDOR - MODELO 1 - 500 POSICOES
		
	ElseIf aItem[NPOSOPPAG] $ "2|7" .And. aItem[NPOSLAYOUT] == 2
	
		cRet := "CVCB" // PAGAMENTO FORNECEDOR - MODELO 2 - 240 POSICOES (MULTIPAG)
		
	ElseIf aItem[NPOSOPPAG] $ "4|5"
	
		cRet := "PTRB" // PAGAMENTO ELETRONICO TRIBUTOS
	
	Else
	
		cRet := "XXXX"
	
	EndIf

Return(cRet)

User Function TAFSELF()
Return({@aCNABItem, @oLogCnab})