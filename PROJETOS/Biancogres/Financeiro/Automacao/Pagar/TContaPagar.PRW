#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TContaPagar From LongClassName
	
	Public Data oObj
	Public Data oResult
	
	Method New() Constructor
	Method Incluir() 
	Method RetNumTit()

EndClass

Method New() Class TContaPagar
	::oObj		:= Nil
	::oResult	:= TContaPagarResultStruct():New()
Return()

Method RetNumTit() Class TContaPagar

	Local cQuery 		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local cNumTitulo	:= ""

	cQuery := " SELECT ISNULL(MAX(E2_NUM), '000000000') AS E2_NUM 			"
	cQuery += " FROM " + RetSQLName("SE2")+"								"		
	cQuery += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE1"))+"			"		
	cQuery += " AND E2_PREFIXO	= " + ValToSQL(::oObj:cPrefixo)+"			"
	cQuery += " AND E2_TIPO 	= " + ValToSQL(::oObj:cTipo	)+" 			"
	cQuery += " AND E2_FORNECE 	= " + ValToSQL(::oObj:cFornecedor)+" 		"
	cQuery += " AND E2_LOJA 	= " + ValToSQL(::oObj:cLoja)+"	 			"
	cQuery += " AND D_E_L_E_T_ = '' 										"

	TcQuery cQuery New Alias (cAliasTemp)

	cNumTitulo := Soma1((cAliasTemp)->E2_NUM)

	(cAliasTemp)->(DbCloseArea())

Return(cNumTitulo)


Method Incluir(_oObj) Class TContaPagar

	Local aCabec			:= {}
	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local nI				:= 0
	
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.
	
	::oObj 			:= _oObj

	
	varinfo("::oObj", ::oObj )
	
	::oObj:cNumero 		:= oContaPagar::RetNumTit()
	
	::oObj:cPrefixo		:= PADR(::oObj:cPrefixo		, TamSX3("E2_PREFIXO")[1])
	::oObj:cNumero		:= PADR(::oObj:cNumero		, TamSX3("E2_NUM")[1])
	::oObj:cParcela		:= PADR(::oObj:cParcela		, TamSX3("E2_PARCELA")[1])
	::oObj:cTipo		:= PADR(::oObj:cTipo		, TamSX3("E2_TIPO")[1])
	::oObj:cNatureza	:= PADR(::oObj:cNatureza	, TamSX3("E2_NATUREZ")[1])
	::oObj:cFornecedor	:= PADR(::oObj:cFornecedor	, TamSX3("E2_FORNECE")[1])
	::oObj:cLoja		:= PADR(::oObj:cLoja		, TamSX3("E2_LOJA")[1])

	aAdd(aCabec, {"E2_PREFIXO", 		::oObj:cPrefixo, Nil})
	aAdd(aCabec, {"E2_NUM", 			::oObj:cNumero, Nil})
	aAdd(aCabec, {"E2_PARCELA", 		::oObj:cParcela, Nil})
	aAdd(aCabec, {"E2_TIPO", 			::oObj:cTipo, Nil})
	aAdd(aCabec, {"E2_NATUREZ", 		::oObj:cNatureza, Nil})
	aAdd(aCabec, {"E2_FORNECE", 		::oObj:cFornecedor, Nil})
	aAdd(aCabec, {"E2_LOJA", 			::oObj:cLoja, Nil})
	aAdd(aCabec, {"E2_EMISSAO",			::oObj:dEmissao, Nil})
	aAdd(aCabec, {"E2_VENCTO", 			::oObj:dVencto, Nil})
	aAdd(aCabec, {"E2_VALOR", 			::oObj:nValor, Nil})
	aAdd(aCabec, {"E2_PORCJUR", 		::oObj:nPerJur, Nil})
	aAdd(aCabec, {"E2_DESDOBR", 		'N', Nil})
	
	//aAdd(aCabec, {"E2_VENCREA", 		::oObj:dVencReal, Nil})
	//aAdd(aCabec, {"E2_VENCORI", 		::oObj:dVencOri, Nil})
	//aAdd(aCabec, {"E2_SALDO", 		::oObj:nSaldo, Nil})
	
	
	Begin Transaction
	
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1)) //E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_D_E_L_
		
		_cChave := xFilial('SE2')
		_cChave += ::oObj:cPrefixo
		_cChave += ::oObj:cNumero
		_cChave += ::oObj:cParcela
		_cChave += ::oObj:cTipo
		_cChave += ::oObj:cFornecedor
		_cChave += ::oObj:cLoja
		 	
		If !SE2->(DbSeek(_cChave))
			
			MSExecAuto({|x,y,z| FINA050(x,y,z)},aCabec,,3) //3-Inclusao //5-Exclusao
			
			If (!lMsErroAuto)
					
				lOk			:= .T.
				cMsgLog 	:= "[Conta a Pagar Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cPrefixo+'/'+::oObj:cNumero+'/'+::oObj:cParcela+'/'+::oObj:cTipo+'/'+::oObj:cFornecedor+'/'+::oObj:cLoja+"] => incluido com sucesso."
			
			Else
				
				DisarmTransaction()
				
				lOk			:= .F.
				cMsgLog 	:= "[Conta a Pagar Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja: "+::oObj:cPrefixo+'/'+::oObj:cNumero+'/'+::oObj:cParcela+'/'+::oObj:cTipo+'/'+::oObj:cFornecedor+'/'+::oObj:cLoja+"] Erro => "+ CRLF
		
				aErroAuto	:= GetAutoGRLog()
				
				For nI := 1 To Len(aErroAuto)
					cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
				Next nI		
				
			EndIf
		
			::oResult:Add(lOk, cMsgLog)	
			
		Else
				
			DisarmTransaction()
				
			lOk			:= .F.
			cMsgLog 	:= "[Conta a Pagar Prefixo: "+::oObj:cPrefixo+'/'+::oObj:cNumero+'/'+::oObj:cParcela+'/'+::oObj:cTipo+'/'+::oObj:cFornecedor+'/'+::oObj:cLoja+"] => já existe."
		EndIf
	
		
	End Transaction 
	
Return ::oResult	

Class TContaPagarStruct From LongClassName
	
	Public Data cPrefixo 
	Public Data cNumero 
	Public Data cParcela 
	Public Data cTipo 
	Public Data cNatureza 
	Public Data cFornecedor 
	Public Data cLoja 
	Public Data dEmissao 
	Public Data dVencto 
	Public Data nJuros // Valro do juros cobrados
	Public Data nValor // Valor
	Public Data nPerJur // Percentual de juros
	Public Data dVencReal 
	Public Data dVencOri 
	Public Data nSaldo 	
	Public Data nValorOri	
	
		
	Public Method New() Constructor
	
EndClass

Method New() Class TContaPagarStruct

	::cPrefixo 		:= ""
	::cNumero 		:= ""
	::cParcela 		:= ""
	::cTipo 		:= ""
	::cNatureza 	:= ""
	::cFornecedor	:= ""
	::cLoja			:= ""
	::dEmissao		:= dDataBase
	::dVencto		:= dDataBase
	::nJuros 		:= 0
	::nValor 		:= 0
	::nPerJur 		:= 0
	::dVencReal		:= dDataBase
	::dVencOri 		:= dDataBase
	::nSaldo 		:= 0
	::nValorOri		:= 0	

Return()


Class TContaPagarResultStruct From LongClassName

	Data lOk			as logical
	Data cMensagem	as character
	Data cID			as numeric

	Method New() Constructor
	Method Add()

EndClass

Method New() Class TContaPagarResultStruct

	::lOk		:= .T.
	::cMensagem	:= ""
	::cID		:= 0

Return()

Method Add(lOk, cMensagem, cID) Class TContaPagarResultStruct

	::lOk		:= lOk
	::cMensagem	+= cMensagem
	::cID		:= cID

Return()
