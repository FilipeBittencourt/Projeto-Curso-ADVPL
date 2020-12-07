#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} BIA933
@author Wlysses Cerqueira (Facile)
@since 21/03/2019
@project Automação Financeira
@version 1.0
@description Classe para efetuar baixa automatica de pagamentos
@type class
/*/

Class BIA933 From LongClassName
	
	Data oReport
	Data oSection1
	Data oSection2
	Data oSection3
	Data oSection4
	Data oSection5
	Data oFont1
	Data cTitle

	Data nComBord
	Data nSemBord
	Data nFolha
	Data nCheque
	Data nComDPCh
	Data nTotal
    	
	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cFilDe
	Data cFilAte
	
	Data cVencrDe
	Data cVencrAte
	Data cBorDe
	Data cBorAte
	Data cNumDe
	Data cNumAte
	Data cPrefDe
	Data cPrefAte
	Data cTipoDe
	Data cTipoAte
	Data cParcDe
	Data cParcAte
	Data cForneceDe
	Data cForneceAte
	Data cLojaDe
	Data cLojaAte
	Data cNotFornec
	
	Method New() Constructor
	Method Relatorio()
	Method Pergunte()
	Method Load()
	Method Print()
	Method SemBordero()
	Method Folha()
	Method ComBordero()
	Method Movimento()
	Method Cheque()
	Method Resumo()
 	
EndClass


Method New() Class BIA933
	
	::oReport := Nil
	::oSection1 := Nil
	::oSection2 := Nil
	::oSection3 := Nil
	::oSection4 := Nil
	::oSection5 := Nil
	::cTitle := "Conferencia - Movimento a pagar diario"
	::oFont1 := TFont():New("Courier New",8,8,.T.,.T.,5,.T.,5,.T.,.F.)
	
	::cName := "BIA933"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.

	::nComBord := 0
	::nSemBord := 0
	::nFolha := 0
	::nCheque := 0
	::nComDPCh := 0
	::nTotal := 0
 
 	::cFilDe := Space(TamSx3("E2_FILIAL")[1])
	::cFilAte := Space(TamSx3("E2_FILIAL")[1])
	::cVencrDe := StoD("  /  /  ")
	::cVencrAte := StoD("  /  /  ")
	::cBorDe := Space(TamSx3("E2_NUMBOR")[1])
	::cBorAte := Space(TamSx3("E2_NUMBOR")[1])
	::cNumDe := Space(TamSx3("E2_NUM")[1])
	::cNumAte := Space(TamSx3("E2_NUM")[1])
	::cPrefDe := Space(TamSx3("E2_PREFIXO")[1])
	::cPrefAte := Space(TamSx3("E2_PREFIXO")[1])
	::cTipoDe := Space(TamSx3("E2_TIPO")[1])
	::cTipoAte := Space(TamSx3("E2_TIPO")[1])
	::cParcDe := Space(TamSx3("E2_PARCELA")[1])
	::cParcAte := Space(TamSx3("E2_PARCELA")[1])
	::cForneceDe := Space(TamSx3("E2_FORNECE")[1])
	::cForneceAte := Space(TamSx3("E2_FORNECE")[1])
	::cLojaDe := Space(TamSx3("E2_LOJA")[1])
	::cLojaAte := Space(TamSx3("E2_LOJA")[1])
	::cNotFornec := Space(((TamSx3("E2_FORNECE")[1])+1) * 5)
	
Return()

Method Load() Class BIA933
	
	::oReport := TReport():New(::cName, ::cTitle, {|| ::Pergunte()}, {|oReport| ::Print()}, ::cTitle)
	::oReport:lBold := .T.
	
	//SemBordero
	::oSection1:= TRSection():New(::oReport,"Conferencia de titulos", {(cQry1)})
	::oSection1:SetTotalInLine(.F.)
	
	::oSection1:lBold := .T.
	
	TRCell():New(::oSection1,"E2_FILIAL"	,(cQry1))
	TRCell():New(::oSection1,"E2_PREFIXO"	,(cQry1))
	TRCell():New(::oSection1,"E2_TIPO"		,(cQry1))
	TRCell():New(::oSection1,"E2_PARCELA"	,(cQry1))
	TRCell():New(::oSection1,"E2_NATUREZ"	,(cQry1))
	TRCell():New(::oSection1,"E2_NUM"		,(cQry1))
	TRCell():New(::oSection1,"E2_FORNECE"	,(cQry1))
	TRCell():New(::oSection1,"E2_LOJA"		,(cQry1))
	TRCell():New(::oSection1,"A2_NREDUZ"	,(cQry1))
	TRCell():New(::oSection1,"E2_PORTADO"	,(cQry1))
	TRCell():New(::oSection1,"E2_EMISSAO"	,(cQry1))
	TRCell():New(::oSection1,"E2_VENCREA"	,(cQry1))
	TRCell():New(::oSection1,"E2_SALDO"		,(cQry1), "Saldo a pagar")
	TRCell():New(::oSection1,"E2_VALOR"		,(cQry1))
	TRCell():New(::oSection1,"E2_NUMBOR"	,(cQry1))
			   
	oBreak1 := TRBreak():New(::oSection1,{|| (cQry1)->E2_NUMBOR})
	
	TRFunction():New(::oSection1:Cell("E2_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(::oSection1:Cell("E2_SALDO"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	
	//Folha
	::oSection2 := TRSection():New(::oReport,"Conferencia de titulos", {(cQry2)})
	::oSection2:SetTotalInLine(.F.)
	
	TRCell():New(::oSection2,"E2_FILIAL"	,(cQry1))
	TRCell():New(::oSection2,"E2_PREFIXO"	,(cQry2))
	TRCell():New(::oSection2,"E2_TIPO"		,(cQry2))
	TRCell():New(::oSection2,"E2_PARCELA"	,(cQry2))
	TRCell():New(::oSection2,"E2_NATUREZ"	,(cQry2))
	TRCell():New(::oSection2,"E2_NUM"		,(cQry2))
	TRCell():New(::oSection2,"E2_FORNECE"	,(cQry2))
	TRCell():New(::oSection2,"E2_LOJA"		,(cQry2))
	TRCell():New(::oSection2,"A2_NREDUZ"	,(cQry2))
	TRCell():New(::oSection2,"E2_PORTADO"	,(cQry2))
	TRCell():New(::oSection2,"E2_EMISSAO"	,(cQry2))
	TRCell():New(::oSection2,"E2_VENCREA"	,(cQry2))
	TRCell():New(::oSection2,"E2_SALDO"		,(cQry2), "Saldo a pagar")
	TRCell():New(::oSection2,"E2_VALOR"		,(cQry2))
	TRCell():New(::oSection2,"E2_NUMBOR"	,(cQry2))
			   
	oBreak1 := TRBreak():New(::oSection2,{|| (cQry2)->E2_NUMBOR})

	TRFunction():New(::oSection2:Cell("E2_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(::oSection2:Cell("E2_SALDO"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	
	//ComBordero
	::oSection3:= TRSection():New(::oReport,"Conferencia de titulos", {(cQry3)})
	::oSection3:SetTotalInLine(.F.)
	
	TRCell():New(::oSection3,"E2_NUMBOR"	,(cQry3))
	TRCell():New(::oSection3,"E2_SALDO"		,(cQry3), "Saldo a pagar")
	TRCell():New(::oSection3,"E2_VALOR"		,(cQry3))
	
	oBreak1 := TRBreak():New(::oSection3,{|| .T.})
	
	TRFunction():New(::oSection3:Cell("E2_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(::oSection3:Cell("E2_SALDO"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	
	//Movimento
	::oSection4:= TRSection():New(::oReport,"Conferencia de titulos", {(cQry4)})
	::oSection4:SetTotalInLine(.F.)
	
	TRCell():New(::oSection4,"E2_FILIAL"	,(cQry1))
	TRCell():New(::oSection4,"E2_PREFIXO"	,(cQry4))
	TRCell():New(::oSection4,"E2_TIPO"		,(cQry4))
	TRCell():New(::oSection4,"E2_PARCELA"	,(cQry4))
	TRCell():New(::oSection4,"E2_NATUREZ"	,(cQry4))
	TRCell():New(::oSection4,"E2_NUM"		,(cQry4))
	TRCell():New(::oSection4,"E2_FORNECE"	,(cQry4))
	TRCell():New(::oSection4,"E2_LOJA"		,(cQry4))
	TRCell():New(::oSection4,"A2_NREDUZ"	,(cQry4))
	TRCell():New(::oSection4,"E2_PORTADO"	,(cQry4))
	TRCell():New(::oSection4,"E2_EMISSAO"	,(cQry4))
	TRCell():New(::oSection4,"E2_VENCREA"	,(cQry4))
	TRCell():New(::oSection4,"E2_SALDO"		,(cQry4), "Saldo a pagar")
	TRCell():New(::oSection4,"E2_VALOR"		,(cQry4))
	TRCell():New(::oSection4,"E2_NUMBOR"	,(cQry4))
			   
	oBreak1 := TRBreak():New(::oSection4,{|| (cQry4)->E2_NUMBOR})

	TRFunction():New(::oSection4:Cell("E2_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(::oSection4:Cell("E2_SALDO"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)

	//Cheque
	::oSection5 := TRSection():New(::oReport,"Conferencia de titulos", {(cQry5)})
	::oSection5:SetTotalInLine(.F.)
	
	TRCell():New(::oSection5,"E5_FILIAL"	,(cQry5))
	TRCell():New(::oSection5,"E5_PREFIXO"	,(cQry5))
	TRCell():New(::oSection5,"E5_TIPO"		,(cQry5))
	TRCell():New(::oSection5,"E5_PARCELA"	,(cQry5))
	TRCell():New(::oSection5,"E5_NATUREZ"	,(cQry5))
	TRCell():New(::oSection5,"E5_NUMERO"	,(cQry5))
	TRCell():New(::oSection5,"E5_FORNECE"	,(cQry5))
	TRCell():New(::oSection5,"E5_LOJA"		,(cQry5))
	TRCell():New(::oSection5,"A2_NREDUZ"	,(cQry5))
	TRCell():New(::oSection5,"E5_BANCO"		,(cQry5))
	TRCell():New(::oSection5,"E5_DATA"		,(cQry5))
	TRCell():New(::oSection5,"E5_VALOR"		,(cQry5))
	TRCell():New(::oSection5,"E5_NUMCHEQ"	,(cQry5))
	
	TRFunction():New(::oSection5:Cell("E5_VALOR"),Nil,"SUM",, Nil, Nil, Nil, .F., .F.)
		
Return()

Method Print() Class BIA933
	
	::SemBordero()
	
	::Folha()
	
	::ComBordero()
	
	::Cheque()
	
	::Resumo()
	
	::Movimento()
 	
Return()

Method SemBordero() Class BIA933
	
	Local lNomSessao := .T.
	
	::oSection1:BeginQuery()
	
	BeginSql Alias cQry1
	
		SELECT E2_FILIAL, E2_PREFIXO, E2_TIPO, E2_PARCELA, E2_NATUREZ, E2_NUM, E2_FORNECE, E2_LOJA,
		A2_NREDUZ, E2_PORTADO, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NUMBOR
		FROM %Table:SE2% SE2
		INNER JOIN %Table:SA2%  SA2 ON
		(
		A2_FILIAL = %Exp:xFilial("SA2")% AND 
		A2_COD  	= E2_FORNECE AND
		A2_LOJA		= E2_LOJA AND
		SA2.D_E_L_E_T_ = ''
		)
		WHERE E2_FILIAL BETWEEN	%Exp:Self:cFilDe%	AND %Exp:Self:cFilAte%
		AND E2_FORNECE	BETWEEN	%Exp:Self:cForneceDe%	AND %Exp:Self:cForneceAte%
		AND E2_LOJA		BETWEEN	%Exp:Self:cLojaDe%		AND %Exp:Self:cLojaAte%
		AND E2_NUM 		BETWEEN	%Exp:Self:cNumDe%		AND %Exp:Self:cNumAte%
		AND E2_PREFIXO 	BETWEEN	%Exp:Self:cPrefDe%		AND %Exp:Self:cPrefAte%
		AND E2_NUMBOR 	BETWEEN	%Exp:Self:cBorDe%		AND %Exp:Self:cBorAte%
		AND E2_PARCELA 	BETWEEN	%Exp:Self:cParcDe%		AND %Exp:Self:cParcAte%
		AND E2_TIPO 	BETWEEN	%Exp:Self:cTipoDe%		AND %Exp:Self:cTipoAte%
		AND E2_VENCREA	BETWEEN	%Exp:Self:cVencrDe%		AND %Exp:Self:cVencrAte%
		AND %Exp:Self:cNotFornec%
		AND E2_SALDO > 0
		AND E2_NUMBOR = ''
		AND E2_PREFIXO NOT IN ('GPE')
		AND E2_TIPO NOT IN ('NDF')
		AND SE2.D_E_L_E_T_ = ''
		ORDER BY E2_NUMBOR DESC, E2_TIPO, E2_PREFIXO, E2_SALDO
	
	EndSql
	
	::oSection1:EndQuery()
	
	(cQry1)->(DBGoTop())
	
	While !::oReport:Cancel() .And. !(cQry1)->(EOF())
    	
		If ::oReport:Cancel()
		
			Exit
			
		EndIf
		
		::oSection1:Init()
				
		If lNomSessao
		
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "| A PAGAR SEM BORDERO |" , ::oFont1)
			::oReport:SkipLine(1)
						
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:SkipLine(1)
			
			lNomSessao := .F.
		
		EndIf
		
		::nSemBord += (cQry1)->E2_SALDO
		
		::oSection1:PrintLine()
		
		(cQry1)->(DBSkip())
		
	EndDo
    
	::oSection1:Finish()
   
	(cQry1)->(DBCloseArea())
	
Return()

Method Folha() Class BIA933
	
	Local lNomSessao := .T.

	::oSection2:BeginQuery()
	
	BeginSql Alias cQry2
	
		SELECT E2_FILIAL, E2_PREFIXO, E2_TIPO, E2_PARCELA, E2_NATUREZ, E2_NUM, E2_FORNECE, E2_LOJA,
		A2_NREDUZ, E2_PORTADO, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NUMBOR
		FROM %Table:SE2% SE2
		INNER JOIN %Table:SA2%  SA2 ON
		(
		A2_FILIAL = %Exp:xFilial("SA2")% AND
		A2_COD  	= E2_FORNECE AND
		A2_LOJA		= E2_LOJA AND
		SA2.D_E_L_E_T_ = ''
		)
		WHERE E2_FILIAL BETWEEN	%Exp:Self:cFilDe%	AND %Exp:Self:cFilAte%
		AND E2_FORNECE	BETWEEN	%Exp:Self:cForneceDe%	AND %Exp:Self:cForneceAte%
		AND E2_LOJA		BETWEEN	%Exp:Self:cLojaDe%		AND %Exp:Self:cLojaAte%
		AND E2_NUM 		BETWEEN	%Exp:Self:cNumDe%		AND %Exp:Self:cNumAte%
		AND E2_PREFIXO 	BETWEEN	%Exp:Self:cPrefDe%		AND %Exp:Self:cPrefAte%
		AND E2_NUMBOR 	BETWEEN	%Exp:Self:cBorDe%		AND %Exp:Self:cBorAte%
		AND E2_PARCELA 	BETWEEN	%Exp:Self:cParcDe%		AND %Exp:Self:cParcAte%
		AND E2_TIPO 	BETWEEN	%Exp:Self:cTipoDe%		AND %Exp:Self:cTipoAte%
		AND E2_VENCREA	BETWEEN	%Exp:Self:cVencrDe%		AND %Exp:Self:cVencrAte%
		AND %Exp:Self:cNotFornec%
		AND E2_SALDO > 0
		AND E2_NUMBOR = ''
		AND E2_PREFIXO = 'GPE'
		AND E2_TIPO NOT IN ('NDF')
		AND SE2.D_E_L_E_T_ = ''
		ORDER BY E2_NUMBOR DESC, E2_TIPO, E2_PREFIXO, E2_SALDO
	
	EndSql
	
	::oSection2:EndQuery()
   	
	(cQry2)->(DBGoTop())
	
	While !::oReport:Cancel() .And. !(cQry2)->(EOF())
     		
		If ::oReport:Cancel()
		
			Exit
			
		EndIf

		::oSection2:Init()

		If lNomSessao
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|    A PAGAR FOLHA    |" , ::oFont1)
			::oReport:SkipLine(1)
						
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
						
			lNomSessao := .F.
		
		EndIf
		
		::nFolha += (cQry2)->E2_SALDO
		
		::oSection2:PrintLine()

		(cQry2)->(DBSkip())
		
	EndDo

	::oSection2:Finish()
    
	(cQry2)->(DBCloseArea())

Return()

Method ComBordero() Class BIA933
	
	Local lNomSessao := .T.
	
	::oSection3:BeginQuery()

	BeginSql Alias cQry3
	
		SELECT	E2_NUMBOR,
		SUM(E2_SALDO) E2_SALDO,
		SUM(E2_VALOR) E2_VALOR
		FROM %Table:SE2% SE2
		INNER JOIN %Table:SA2%  SA2 ON
		(
		A2_FILIAL = %Exp:xFilial("SA2")% AND
		A2_COD  	= E2_FORNECE AND
		A2_LOJA		= E2_LOJA AND
		SA2.D_E_L_E_T_ = ''
		)
		WHERE E2_FILIAL BETWEEN	%Exp:Self:cFilDe%	AND %Exp:Self:cFilAte%
		AND E2_FORNECE	BETWEEN	%Exp:Self:cForneceDe%	AND %Exp:Self:cForneceAte%
		AND E2_LOJA		BETWEEN	%Exp:Self:cLojaDe%		AND %Exp:Self:cLojaAte%
		AND E2_NUM 		BETWEEN	%Exp:Self:cNumDe%		AND %Exp:Self:cNumAte%
		AND E2_PREFIXO 	BETWEEN	%Exp:Self:cPrefDe%		AND %Exp:Self:cPrefAte%
		AND E2_NUMBOR 	BETWEEN	%Exp:Self:cBorDe%		AND %Exp:Self:cBorAte%
		AND E2_PARCELA 	BETWEEN	%Exp:Self:cParcDe%		AND %Exp:Self:cParcAte%
		AND E2_TIPO 	BETWEEN	%Exp:Self:cTipoDe%		AND %Exp:Self:cTipoAte%
		AND E2_VENCREA	BETWEEN	%Exp:Self:cVencrDe%		AND %Exp:Self:cVencrAte%
		AND %Exp:Self:cNotFornec%
		AND E2_SALDO > 0
		AND E2_NUMBOR <> ''
		AND E2_TIPO NOT IN ('NDF')
		AND SE2.D_E_L_E_T_ = ''
		GROUP BY E2_NUMBOR
	
	EndSql
	
	::oSection3:EndQuery()
   	
	(cQry3)->(DBGoTop())
	
	While !::oReport:Cancel() .And. !(cQry3)->(EOF())
  
		If ::oReport:Cancel()
		
			Exit
			
		EndIf

		::oSection3:Init()
				
		If lNomSessao
		
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "| A PAGAR COM BORDERO |" , ::oFont1)
			::oReport:SkipLine(1)
						
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
									
			lNomSessao := .F.
		
		EndIf
		
		::nComBord += (cQry3)->E2_SALDO
		
		::oSection3:PrintLine()

		(cQry3)->(DBSkip())
		
	EndDo
    
	::oSection3:Finish()
    
	(cQry3)->(DBCloseArea())

Return()


Method Cheque() Class BIA933
	
	Local lNomSessao := .T.
	
	::oSection5:BeginQuery()
	
	::cNotFornec := Replace(::cNotFornec, "E2_FORNECE", "E5_FORNECE")

	BeginSql Alias cQry5
	
		SELECT 
		E5_FILIAL,
		E5_PREFIXO,
		E5_TIPO,	
		E5_PARCELA,
		E5_NATUREZ,
		E5_NUMERO,
		E5_FORNECE,
		E5_LOJA,	
		A2_NREDUZ,
		E5_BANCO,	
		E5_DATA,	
		E5_VALOR,
		E5_NUMCHEQ
		FROM %Table:SE5% SE5
		INNER JOIN %Table:SA2%  SA2 ON
		(
		A2_FILIAL = %Exp:xFilial("SA2")% AND
		A2_COD  	= E5_FORNECE AND
		A2_LOJA		= E5_LOJA AND
		SA2.D_E_L_E_T_ = ''
		)
		WHERE E5_FILIAL BETWEEN	%Exp:Self:cFilDe%		AND %Exp:Self:cFilAte%
		AND E5_FORNECE	BETWEEN	%Exp:Self:cForneceDe%	AND %Exp:Self:cForneceAte%
		AND E5_LOJA		BETWEEN	%Exp:Self:cLojaDe%		AND %Exp:Self:cLojaAte%
		AND E5_NUMERO	BETWEEN	%Exp:Self:cNumDe%		AND %Exp:Self:cNumAte%
		AND E5_PREFIXO 	BETWEEN	%Exp:Self:cPrefDe%		AND %Exp:Self:cPrefAte%
		AND E5_PARCELA 	BETWEEN	%Exp:Self:cParcDe%		AND %Exp:Self:cParcAte%
		AND E5_TIPO 	BETWEEN	%Exp:Self:cTipoDe%		AND %Exp:Self:cTipoAte%
		AND E5_DATA		BETWEEN	%Exp:Self:cVencrDe%		AND %Exp:Self:cVencrAte%
		AND %Exp:Self:cNotFornec%
		AND E5_NUMCHEQ <> ''
		AND SE5.D_E_L_E_T_ = ''
	
	EndSql
	
	::cNotFornec := Replace(::cNotFornec, "E5_FORNECE", "E2_FORNECE")
	
	::oSection5:EndQuery()
   	
	(cQry5)->(DBGoTop())
	
	While !::oReport:Cancel() .And. !(cQry5)->(EOF())
  
		If ::oReport:Cancel()
		
			Exit
			
		EndIf

		::oSection5:Init()
				
		If lNomSessao
		
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|       CHEQUE        |" , ::oFont1)
			::oReport:SkipLine(1)
						
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
									
			lNomSessao := .F.
		
		EndIf
		
		::nCheque += (cQry5)->E5_VALOR
		
		::oSection5:PrintLine()

		(cQry5)->(DBSkip())
		
	EndDo
    
	::oSection5:Finish()
    
	(cQry5)->(DBCloseArea())

Return()

Method Movimento() Class BIA933
	
	Local lNomSessao := .T.

	::oSection4:BeginQuery()
	
	BeginSql Alias cQry4
	
		SELECT E2_FILIAL, E2_PREFIXO, E2_TIPO, E2_PARCELA, E2_NATUREZ, E2_NUM, E2_FORNECE, E2_LOJA,
		A2_NREDUZ, E2_PORTADO, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NUMBOR
		FROM %Table:SE2% SE2
		INNER JOIN %Table:SA2%  SA2 ON
		(
		A2_FILIAL = %Exp:xFilial("SA2")% AND
		A2_COD  	= E2_FORNECE AND
		A2_LOJA		= E2_LOJA AND
		SA2.D_E_L_E_T_ = ''
		)
		WHERE E2_FILIAL BETWEEN	%Exp:Self:cFilDe%	AND %Exp:Self:cFilAte%
		AND E2_FORNECE	BETWEEN	%Exp:Self:cForneceDe%	AND %Exp:Self:cForneceAte%
		AND E2_LOJA		BETWEEN	%Exp:Self:cLojaDe%		AND %Exp:Self:cLojaAte%
		AND E2_NUM 		BETWEEN	%Exp:Self:cNumDe%		AND %Exp:Self:cNumAte%
		AND E2_PREFIXO 	BETWEEN	%Exp:Self:cPrefDe%		AND %Exp:Self:cPrefAte%
		AND E2_NUMBOR 	BETWEEN	%Exp:Self:cBorDe%		AND %Exp:Self:cBorAte%
		AND E2_PARCELA 	BETWEEN	%Exp:Self:cParcDe%		AND %Exp:Self:cParcAte%
		AND E2_TIPO 	BETWEEN	%Exp:Self:cTipoDe%		AND %Exp:Self:cTipoAte%
		AND E2_VENCREA	BETWEEN	%Exp:Self:cVencrDe%		AND %Exp:Self:cVencrAte%
		AND %Exp:Self:cNotFornec%
		AND E2_SALDO > 0
		AND E2_TIPO NOT IN ('NDF')
		AND SE2.D_E_L_E_T_ = ''
		ORDER BY E2_NUMBOR DESC, E2_TIPO, E2_PREFIXO, E2_SALDO
	
	EndSql
	
	::oSection4:EndQuery()
   	
	(cQry4)->(DBGoTop())
	
	While !::oReport:Cancel() .And. !(cQry4)->(EOF())

		If ::oReport:Cancel()
		
			Exit
			
		EndIf

		::oSection4:Init()
		
		If lNomSessao
		
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
			::oReport:SkipLine(1)
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
			
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|      MOVIMENTO      |" , ::oFont1)
			::oReport:SkipLine(1)
						
			::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
			::oReport:SkipLine(1)
									
			lNomSessao := .F.
		
		EndIf

		::oSection4:PrintLine()
			
		(cQry4)->(DBSkip())
		
	EndDo

	::oSection4:Finish()
    
	(cQry4)->(DBCloseArea())
	
Return()

Method Resumo() Class BIA933
	
	::nComDPCh := ::nComBord + ::nFolha + ::nCheque
	
	::nTotal := ::nComBord + ::nSemBord + ::nFolha + ::nCheque
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "" , ::oFont1)
	::oReport:SkipLine(1)
			
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
	::oReport:SkipLine(1)
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|       RESUMO        |" , ::oFont1)
	::oReport:SkipLine(1)
				
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "|---------------------|" , ::oFont1)
	::oReport:SkipLine(1)

	::oReport:ThinLine()
	//::oReport:SkipLine()

	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total com bordero...............: " + Transform(::nComBord	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)

	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total sem bordero...............: " + Transform(::nSemBord	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total folha.....................: " + Transform(::nFolha	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total cheque....................: " + Transform(::nCheque	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total com bordero/folha/cheque..: " + Transform(::nComDPCh	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)
	
	::oReport:Say( ::oReport:Row() , ::oReport:Col() , "Total geral.....................: " + Transform(::nTotal	, "@E 999,999,999.99") , ::oFont1)
	::oReport:SkipLine(1)

	::oReport:ThinLine()
	::oReport:SkipLine()

	::oReport:EndPage()
	::oReport:StartPage()
		  
Return()

Method Relatorio() Class BIA933

	::Pergunte()

	::Load()
	
	::oReport:PrintDialog()

Return()

Method Pergunte() Class BIA933

	Local lRet := .F.
	Local nTam := 0
	
	::bConfirm := {|| .T. }
	
	::aParam := {}
	
	::aParRet := {}
	
	aAdd(::aParam, {1, "Filial de"		, ::cFilDe		, "@!", ".T.","SM0"	,".T.",,.F.})
	aAdd(::aParam, {1, "Filial ate"		, ::cFilAte		, "@!", ".T.","SM0"	,".T.",,.F.})

	aAdd(::aParam, {1, "Venc. Real de"	, ::cVencrDe	, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Venc. Real ate"	, ::cVencrAte	, "@!", ".T.",		,".T.",,.F.})
			
	aAdd(::aParam, {1, "Bordero de"		, ::cBorDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Bordero ate"	, ::cBorAte		, "@!", ".T.",		,".T.",,.F.})
	
	aAdd(::aParam, {1, "Num. Titulo de"	, ::cNumDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Num. Titulo ate", ::cNumAte		, "@!", ".T.",		,".T.",,.F.})
	
	aAdd(::aParam, {1, "Prefixo de"		, ::cPrefDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Prefixo ate"	, ::cPrefAte	, "@!", ".T.",		,".T.",,.F.})
		
	aAdd(::aParam, {1, "Tipo de"		, ::cTipoDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Tipo ate"		, ::cTipoAte	, "@!", ".T.",		,".T.",,.F.})
	
	aAdd(::aParam, {1, "Parcela de"		, ::cParcDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Parcela ate"	, ::cParcAte	, "@!", ".T.",		,".T.",,.F.})
		
	aAdd(::aParam, {1, "Fornecedor de"	, ::cForneceDe	, "@!", ".T.","SA2",".T.",,.F.})
	aAdd(::aParam, {1, "Fornecedor ate"	, ::cForneceAte , "@!", ".T.","SA2",".T.",,.F.})
		
	aAdd(::aParam, {1, "Loja de"		, ::cLojaDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Loja ate"		, ::cLojaAte	, "@!", ".T.",		,".T.",,.F.})

	aAdd(::aParam, {1, "Cod Fornec. nao contem", ::cNotFornec, "@!", ".T.","SA2",".T.",,.F.})
							
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		nTam++
		
		::cFilDe	    := ::aParRet[nTam++]
		::cFilAte 	    := ::aParRet[nTam++]
		::cVencrDe 	    := ::aParRet[nTam++]
		::cVencrAte		:= ::aParRet[nTam++]
		::cBorDe 	    := ::aParRet[nTam++]
		::cBorAte       := ::aParRet[nTam++]
		::cNumDe 	    := ::aParRet[nTam++]
		::cNumAte       := ::aParRet[nTam++]
		::cPrefDe       := ::aParRet[nTam++]
		::cPrefAte      := ::aParRet[nTam++]
		::cTipoDe       := ::aParRet[nTam++]
		::cTipoAte      := ::aParRet[nTam++]
		::cParcDe       := ::aParRet[nTam++]
		::cParcAte      := ::aParRet[nTam++]
		::cForneceDe    := ::aParRet[nTam++]
		::cForneceAte	:= ::aParRet[nTam++]
		::cLojaDe 		:= ::aParRet[nTam++]
		::cLojaAte 		:= ::aParRet[nTam++]
		::cNotFornec	:= ::aParRet[nTam++]
		
		If Empty(::cNotFornec)
		
			::cNotFornec := '% 1 = 1 %'
			
		
		Else
		
			::cNotFornec := "% E2_FORNECE NOT IN " + FormatIn(AllTrim(::cNotFornec), ",") + " %"
		
		EndIf
				
	EndIf
	
Return(lRet)

User Function BIA933()
	
	Local oObj := BIA933():New()

	Private cQry1 := GetNextAlias()
	Private cQry2 := GetNextAlias()
	Private cQry3 := GetNextAlias()
	Private cQry4 := GetNextAlias()
	Private cQry5 := GetNextAlias()
		
	oObj:Relatorio()

Return()