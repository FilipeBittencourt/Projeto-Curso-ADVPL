#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CNABNSN  บ Autor: Tiago Rossini Coradini บ Data ณ 07/12/07 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Incrementa nosso numero no SEE, quando a propria empresa   บฑฑ
ฑฑบ						 gera o campo NOSSO NUMERO                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo Financeiro - Contas a Receber                       บฑฑ
ฑฑบParametrosณ cCarteira := Qual a carteira do banco.                    บฑฑ
ฑฑบ----------ณ cBase := Base para o calculo do MOD11 do titulo em   banco.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TCNABNSN(cBanco)
	Local cNumero
	Local cNossoNum
	Local cConvBB := SA6->A6_NUMBCO  //"2113640"
	Local cNossBra := ""

	//incluido verificar validacao cnab banestes
	// andremiranda 18/07/08
	// referente a chamada da funcao execblock('CNABNSN') (SEM INFORMAR O BANCO)
	if empty(cBanco) .AND. FUNNAME() == 'FINA150' //ROTINA ARQUIVO DE COBRANCA
		if !SEE->(EOF())
			IF !EMPTY(SEE->EE_CODIGO)
				//IF SEE->EE_CODIGO = "356"
				//cBanco := "356"
				cBanco := SEE->EE_CODIGO
			ENDIF
		ENDIF
	endif
	//*************************
	If cBanco == '001' //BANCO DO BRASIL
		// Convenio de 6 posicoes:
		// Nosso numero = CCCCCCCNNNNNNNNNN
		// C = Convenio, N = Numero sequencial, X = Digito verificador
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)

			CriaParNN("MV_NOSSBRA")
			cNossBra := Soma1(StrZero(Val(GetMV("MV_NOSSBRA")),10))
			cNumero := cConvBB + cNossBra
			PutMV("MV_NOSSBRA", cNossBra)
			cNossoNum := cNumero
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	ElseIf cBanco == '021' //BANESTES
		If Empty(SE1->E1_NUMBCO) .OR. Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)
			CriaParNN("MV_NOSSBAN")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSBAN")),8))
			PutMV("MV_NOSSBAN", cNumero)
			cNossoNum := cNumero + BaneCDigV(cNumero)
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	ElseIf cBanco == '356' //BANCO REAL
		//alterado por AndreMiranda 18/07/08
		//IF EMPTY(SE1->E1_IDCNAB)
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)

			CriaParNN("MV_NOSSREL")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSREL")),7))
			PutMV("MV_NOSSREL", cNumero)
		Else
			cNumero := SE1->E1_IDCNAB
		Endif
		cNossoNum := cNumero
	ElseIf cBanco == '004' //BANCO NORDESTE
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)

			CriaParNN("MV_NOSSBNB")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSBNB")),7))
			PutMV("MV_NOSSBNB", cNumero)
			cNossoNum := cNumero + BnbCDigV(cNumero)
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	ElseIf cBanco == '033' //BANCO SANTANDER
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)

			CriaParNN("MV_NOSSSAN")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSSAN")),12))
			PutMV("MV_NOSSSAN", cNumero)
			cNossoNum := cNumero + SanCDigV(cNumero)
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	ElseIf cBanco == '104' //BANCO CAIXA ECONOMICA FEDERAL
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)

			CriaParNN("MV_NOSSCEF")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSCEF")),9))
			PutMV("MV_NOSSCEF", cNumero)
			cNumero := "9" + cNumero
			cNossoNum := cNumero + CEFCDigV(cNumero)
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	ElseIf cBanco == '341' //ITAU
		If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> cBanco)
			CriaParNN("MV_NOSSITA")
			cNumero := Soma1(StrZero(Val(GetMV("MV_NOSSITA")),8))
			PutMV("MV_NOSSITA", cNumero)
			cNossoNum := cNumero
		Else
			cNossoNum := SE1->E1_IDCNAB
		Endif
	Else
		cNossoNum := NossoNum() // OUTROS BANCOS
	EndIf
	//Grava campo nosso numero no titulo e nos parametros banco
	DbSelectArea("SE1")
	RecLock("SE1",.F.)
	SE1->E1_IDCNAB := cNossoNum
	SE1->(MsUnlock())
    /*                  
	dbSelectArea("SEE")
	RecLock("SEE",.F.)
	SEE->EE_FAXATU := cNossoNum
	SEE->(MsUnlock()) 
	*/
Return (cNossoNum)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBrasCDigV บ Autor ณ Tiago Rossini Coradiniบ Data ณ  07/12/07บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o Calculo do digito verificadore do Banco do Brasil.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCarteira := Qual  a carteira do banco.                   บฑฑ
ฑฑบ----------ณ cNossoNum := Numero do titulo emm banco.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function BrasCDigV(cNossoNum)
	Local nCnt := 0
	Local cDigito := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	nTam := Len(cNossoNum)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1
		nLin ++
		nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
	Next nCnt

	cDigito := 11 - (nSoma % 11)

	IF cDigito <= 0 .OR. cDigito > 10
		cDigito :=  0
	Endif

	If (cDigito >= 10, cDigito := "X", cDigito := STR(cDigito, 1, 0))

		Return(cDigito)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBaneCDigV บ Autor ณ Tiago Rossini Coradiniบ Data ณ  15/02/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o Calculo dos digitos verificadores do Banco Banestes. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ----------ณ cNossoNum := Numero do titulo emm banco.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BaneCDigV(cNossoNum)
	Local nCnt := 0
	Local cDigito1 := 0
	Local cDigito2 := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	// Calculo digito 1
	nTam := Len(cNossoNum)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1
		nLin ++
		nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
	Next nCnt

	cDigito1 := nSoma % 11

	If (cDigito1 <= 1, cDigito1 := 0, cDigito1 := 11 - (nSoma % 11))

		// Calculo digito 2
		nTam ++

		GeraPeso(nTam, 10)
		nLin := 0
		nSoma	:= 0
		cNossoNum := cNossoNum + STR(cDigito1, 1, 0)

		For nCnt := nTam To 1 Step -1
			nLin ++
			nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
		Next nCnt

		cDigito2 := nSoma % 11

		If (cDigito2 <= 1, cDigito2 := 0, cDigito2 := 11 - (nSoma % 11))

			Return(STR(cDigito1, 1, 0) + STR(cDigito2, 1, 0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBnBCDigV บ Autor ณ Andre Mirandaบ           Data ณ  22/07/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o Calculo dos digitos verificadores do Banco Nordeste. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ----------ณ cNossoNum := Numero do titulo emm banco.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BnbCDigV(cNossoNum)
	Local nCnt := 0
	Local cDigito1 := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	// Calculo digito 1
	nTam := Len(cNossoNum)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1
		nLin ++
		nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
	Next nCnt

	If nSoma  < 11
		// Caso somatorio for menor que 11, o resultado sera 0 e o resto a ser subtraido de 11, sera o proprio somatorio
		cDigito := 11 - nSoma
	elseif (nSoma % 11) <= 1
		//caso resto da divisao for 0 ou 1, o digito verificador sera 0
		cDigito := 0
	else
		cDigito := 11 - (nSoma % 11)
	endif

Return(STR(cDigito, 1, 0))
//*******/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSanCDigV บ Autor ณ Andre Mirandaบ           Data ณ  28/07/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o Calculo dos digitos verificadores do Banco Santander บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ----------ณ cNossoNum := Numero do titulo emm banco.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SanCDigV(cNossoNum)
	Local nCnt := 0
	Local cDigito1 := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	// Calculo digito 1
	nTam := Len(cNossoNum)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1
		nLin ++
		nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
	Next nCnt

//	cDigito := 11 - (nSoma % 11)
	cDigito := (nSoma % 11)
	If cDigito  >= 10
		// Se o resto igual 10 digito = 1
		cDigito := 1
	elseif cDigito <= 1
		//caso resto da divisao for 0 ou 1, o digito verificador sera 0
		cDigito := 0
	else
		cDigito := 11 - (nSoma % 11)
	endif

Return(Alltrim(STR(cDigito)))

//*******/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCEFCDigV บ Autor ณ Andre Mirandaบ           Data ณ  25/08/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o Calculo dos digitos verificadores do Banco CEF บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ----------ณ cNossoNum := Numero do titulo emm banco.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CEFCDigV(cNossoNum)
	Local nCnt := 0
	Local cDigito1 := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	// Calculo digito 1
	nTam := Len(cNossoNum)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1
		nLin ++
		nSoma += Val(SUBS(cNossoNum, nCnt, 01)) * aPeso[nLin, 1]
	Next nCnt

	cDigito := 11 - (nSoma % 11)
	If cDigito  >= 10
		// Se o resto igual 10 digito = 1
		cDigito := 0
	elseif cDigito <= 1
		//caso resto da divisao for 0 ou 1, o digito verificador sera 0
		cDigito := 0
	else
		cDigito := 11 - (nSoma % 11)
	endif

Return(STR(cDigito, 1, 0))

Static Function GeraPeso(nTamNSN, nBase)
	Local nVal   := 1
	Local nCount := 0

	For nCount := 1 to nTamNSN
		nVal ++
		If nVal <= nBase
			aAdd(aPeso,{nVal})
		Else
			aAdd(aPeso,{2})
			nVal := 2
		EndIf
	Next nCount

Return(aPeso)


Static Function CriaParNN(cParamentro)
	Default cParamentro := ""
	If AllTrim(cParamentro) !=""
		If !GetMV(cParamentro,.T.)

			If GetMV(cParamentro,.T.) .And. Alltrim(SX6->X6_CONTEUD) $ "0123456"
				cContOrig:=GetMV(cParamentro)
				PutMv(cParamentro,"T")
			Endif

			RecLock( "SX6",.T. )
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := cParamentro
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Valor do proximo Nosso Numero"
			SX6->X6_DESC1   := ""
			SX6->X6_DESC2   := ""
			SX6->X6_CONTEUD := "00000001"
			SX6->X6_CONTSPA := "00000001"
			SX6->X6_CONTENG := "00000001"
			MsUnLock()
		EndIf
	EndIf