#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0023; Return()

/*
|-----------------------------------------------------------|
| Classe: | TContaReceber																    |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 04/05/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Classe para tratamento de titulos provisorios 	|
|-----------------------------------------------------------|
| OS:			|	1307-15 - Vagner Salles													|
|					|	1308-15 - Vagner Salles													|
|					|	3084-15 - Carolina Zanetti 											|
|					|	3071-15 - Nadine Souza													|
|-----------------------------------------------------------|
*/

Class TContaReceber From FWSerialize

	Data cPrefixo // Prefixo
	Data cNumero // Numero
	Data cParcela // Parcela
	Data cTipo // Tipo
	Data cNatureza // Natureza
	Data cCliente // Cliente
	Data cLoja // Loja
	Data dEmissao // Data de emissão
	Data dVencto // Data de vencimento
	Data nJuros // Valro do juros cobrados
	Data nValor // Valor
	Data nPerJur // Percentual de juros
	Data cClasse // Classe
	Data cNumBco // Numero do banco - Nosso numero
	Data cNumPed // Numero do pedido de venda
	Data cVend1 // Vendedor do pedido de venda
	Data cTipPag // Tipo de pagamento 1=Banco;2=Cheque;3=OP;4=CT
	Data cErro // Guarda erro execAuto

	// Propriedades para baixa e recebimento antecipado
	Data cMotBx // Motivo da baixa
	Data cBanco // Banco da baixa
	Data cAgencia // Agencia da baixa
	Data cConta // Conta da baixa
	Data dBaixa // Data da baixa
	Data dCredito // Data do credito
		
	Method New() Constructor // Metodo construtor
	Method Incluir() // Inclui titulo
	Method Excluir() // Exlui titulo
	Method Baixar() // Baixa titulo
	Method Substituir() // Substitui titulo provisorio

EndClass


Method New() Class TContaReceber

	::cPrefixo := ""
	::cNumero := ""
	::cParcela := ""
	::cTipo := ""
	::cNatureza := ""
	::cCliente := ""
	::cLoja := ""
	::dEmissao := dDataBase
	::dVencto := dDataBase
	::nJuros := 0
	::nValor := 0
	::nPerJur := 0
	::cClasse := ""
	::cNumBco	:= ""
	::cNumPed := ""
	::cVend1 := ""
	::cTipPag := "1"
	
	::cMotBx := ""
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::dBaixa := dDataBase
	::dCredito := dDataBase

	::cErro := ""

Return()


Method Incluir(lRecAnt) Class TContaReceber

	Local aTit := {}
	Local dDataAux := dDataBase
	Local cPath := ""
	Local cFileLog := ""

	Private lMsErroAuto := .F.
	Default lRecAnt := .F.

	aAdd(aTit, {"E1_PREFIXO", ::cPrefixo, Nil})
	aAdd(aTit, {"E1_NUM", ::cNumero, Nil})
	aAdd(aTit, {"E1_PARCELA", ::cParcela, Nil})
	aAdd(aTit, {"E1_TIPO", ::cTipo, Nil})
	aAdd(aTit, {"E1_NATUREZ", ::cNatureza, Nil})
	aAdd(aTit, {"E1_CLIENTE", ::cCliente, Nil})
	aAdd(aTit, {"E1_LOJA", ::cLoja, Nil})
	aAdd(aTit, {"E1_YUFCLI", Posicione("SA1", 1, xFilial("SA1") + ::cCliente + ::cLoja, "A1_EST"), Nil})
	aAdd(aTit, {"E1_EMISSAO", ::dEmissao, Nil})
	aAdd(aTit, {"E1_VENCTO", ::dVencto, Nil})
	aAdd(aTit, {"E1_VALOR", ::nValor, Nil})
	aAdd(aTit, {"E1_PORCJUR", ::nPerJur, Nil})
	aAdd(aTit, {"E1_YCLASSE", ::cClasse, Nil})
	aAdd(aTit, {"E1_NUMBCO", If (lRecAnt, "", ::cNumBco), Nil})
	aAdd(aTit, {"E1_YNUMBCO", ::cNumBco, Nil})
	aAdd(aTit, {"E1_PEDIDO", ::cNumPed, Nil})
	aAdd(aTit, {"E1_VEND1", ::cVend1, Nil})
	aAdd(aTit, {"E1_YFORMA", ::cTipPag, Nil})
	
	// Recebimento antecipado
	If lRecAnt
						
		// Altera a data do sistema para ajustar a data da contabilidade
		dDataBase := ::dVencto
		
		cBcoAuto := ::cBanco
		cAgeAuto := ::cAgencia
		cCtaAuto := ::cConta
		
		aAdd(aTit, {"CBCOAUTO", ::cBanco, Nil})
		aAdd(aTit, {"CAGEAUTO", ::cAgencia, Nil})
		aAdd(aTit, {"CCTAAUTO", ::cConta, Nil})
		
	EndIf
		
	MsExecAuto({|x,y| Fina040(x,y)}, aTit, 3)
	
	If lMsErroAuto
		
		// Se a rotina esta sendo chamada via RPC
		If IsBlind()
			
			cPath := GetSrvProfString("Startpath", "")
				
			cFileLog := "TContaReceber" + "_" + cEmpAnt + cFilAnt + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"
	
			::cErro := MostraErro(cPath, cFileLog)
			
			Conout("TContaReceber => " + cValToChar(::cErro))
			
		Else
		
			MostraErro()
			
		EndIf
		
	EndIf
	
	dDataBase := dDataAux
	  	    
Return(!lMsErroAuto)


Method Excluir() Class TContaReceber

	Local aTit := {}
	Local cPath := ""
	Local cFileLog := ""

	Private lMsErroAuto := .F.

	aAdd(aTit, {"E1_PREFIXO", ::cPrefixo, Nil})
	aAdd(aTit, {"E1_NUM", ::cNumero, Nil})
	aAdd(aTit, {"E1_PARCELA", ::cParcela, Nil})
	aAdd(aTit, {"E1_TIPO", ::cTipo, Nil})
	aAdd(aTit, {"E1_CLIENTE", ::cCliente, Nil})
	aAdd(aTit, {"E1_LOJA", ::cLoja, Nil})
	
	MsExecAuto({|x,y| Fina040(x,y)}, aTit, 5)
	
	If lMsErroAuto
		
		If IsBlind()
			
			cPath := GetSrvProfString("Startpath", "")
				
			cFileLog := "TContaReceber" + "_" + cEmpAnt + cFilAnt + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"
	
			::cErro := MostraErro(cPath, cFileLog)
			
		Else
		
			MostraErro()
			
		EndIf
		
	EndIf
	  	    
Return(!lMsErroAuto)


Method Baixar() Class TContaReceber
	Local aTit := {}
	Local cPath := ""
	Local cFileLog := ""
	
	Private lMsErroAuto := .F.

	aAdd(aTit, {"E1_PREFIXO", ::cPrefixo, Nil})
	aAdd(aTit, {"E1_NUM", ::cNumero, Nil})
	aAdd(aTit, {"E1_PARCELA", ::cParcela, Nil})
	aAdd(aTit, {"E1_TIPO", ::cTipo, Nil})
	aAdd(aTit, {"AUTMOTBX", ::cMotBx, Nil})
	aAdd(aTit, {"AUTBANCO", ::cBanco, Nil})
	aAdd(aTit, {"AUTAGENCIA", ::cAgencia, Nil})
	aAdd(aTit, {"AUTCONTA", ::cConta, Nil})
	aAdd(aTit, {"AUTDTBAIXA", ::dBaixa, Nil})
	aAdd(aTit, {"AUTDTCREDITO", ::dCredito, Nil})
	aAdd(aTit, {"AUTJUROS", ::nJuros, Nil,.T.})
	//aAdd(aTit, {"AUTHIST", ::cHist, Nil})
	  
	// Tiago Rossini Coradini - 28/01/16 - OS: 0361-16 - Clebes Jose - Ajuste no calculo de juros
	If ::nJuros > 0

		// Se for prefixo PR adicona o valor do juros ao valor total do titulo, pois o juro sera somado no valor do RA
		// Se for prefixo CT (Contrato) não efetua a soma, poi o valor do juro é recebido em outra baixa e contabilizado separadamente
		If SubStr(::cPrefixo, 1, 2) == "PR"
			::nValor += ::nJuros
		EndIf
		
	EndIf
	
	aAdd(aTit, {"AUTVALREC", ::nValor, Nil})
	
	MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)
	
	If lMsErroAuto
		
		If IsBlind()
		
			cPath := GetSrvProfString("Startpath", "")
				
			cFileLog := "TContaReceber" + "_" + cEmpAnt + cFilAnt + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"
	
			::cErro := MostraErro(cPath, cFileLog)
		
		Else
		
			MostraErro()
		
		EndIf
				
	EndIf
		  	    
Return(!lMsErroAuto)


Method Substituir() Class TContaReceber

	Local aTit := {}
	Local aTitPrv := {}
	Local aAux := {}
	Local cPath := ""
	Local cFileLog := ""

	Private lMsErroAuto := .F.

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	
	If (SE1->(DbSeek(xFilial("SE1") + ::cPrefixo + ::cNumero + ::cParcela + ::cTipo)))
		
		aAdd(aTit, {"E1_PREFIXO", "RA" + SubStr(::cPrefixo, 3, 1), Nil})
		aAdd(aTit, {"E1_NUM", SE1->E1_NUM, Nil})
		aAdd(aTit, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
		aAdd(aTit, {"E1_TIPO", "RA", Nil})
		aAdd(aTit, {"E1_PORTADO", SE1->E1_PORTADO, Nil})
		aAdd(aTit, {"E1_AGEDEP", SE1->E1_AGEDEP, Nil})
		aAdd(aTit, {"E1_CONTA", SE1->E1_CONTA, Nil})
		aAdd(aTit, {"E1_NATUREZ", SE1->E1_NATUREZ, Nil})
		aAdd(aTit, {"E1_CLIENTE", SE1->E1_CLIENTE, Nil})
		aAdd(aTit, {"E1_LOJA", SE1->E1_LOJA, Nil})
		aAdd(aTit, {"E1_EMISSAO", SE1->E1_EMISSAO, Nil})
		aAdd(aTit, {"E1_VENCTO" ,SE1->E1_VENCTO, Nil})
		aAdd(aTit, {"E1_VENCREA", SE1->E1_VENCTO, Nil})
		aAdd(aTit, {"E1_VENCORI", SE1->E1_VENCTO, Nil})
		aAdd(aTit, {"E1_VALOR", SE1->E1_VALOR, Nil})
		
		aAux := {}
		aAdd(aAux, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
		aAdd(aAux, {"E1_NUM", SE1->E1_NUM, Nil})
		aAdd(aAux, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
		aAdd(aAux, {"E1_TIPO", SE1->E1_TIPO, Nil})
		aAdd(aAux, {"E1_CLIENTE", SE1->E1_CLIENTE, Nil})
		aAdd(aAux, {"E1_LOJA", SE1->E1_LOJA, Nil})
		
		aAdd(aTitPrv, aAux)
		
		MSExecAuto({|x,y,z| FINA040(x,y,z)}, aTit, 6, aTitPrv)
		
		If lMsErroAuto
		
			If IsBlind()
				
				cPath := GetSrvProfString("Startpath", "")
					
				cFileLog := "TContaReceber" + "_" + cEmpAnt + cFilAnt + "_" + dToS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG"
		
				::cErro := MostraErro(cPath, cFileLog)
				
			Else
			
				MostraErro()
				
			EndIf
		
		EndIf
		
	EndIf
	  	    
Return(!lMsErroAuto)