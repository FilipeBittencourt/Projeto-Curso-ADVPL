#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} FA070CHK
@author Fernando Rocha
@since 22/09/2016
@version 1.0
@description Ponto de entrada para validar baixa de titulo a Receber
@type function
/*/

User Function FA070CHK
Local lRet := .T.
Local aArea := GetArea()
Local cAliasTmp
Local _lRet := .T.
Local _cID	:= SE1->(Recno())
Local cPre	:= ""
Local cNum  := ""


//Checkar se a baixa do titulo correspondente ja foi feita na LM - se nao bloqueia
If AllTrim(CEMPANT) <> "07" .And. SE1->E1_CLIENTE == "010064" .And. SE1->E1_TIPO == "NF " .And. SE1->E1_YFDCVAL == 0

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%
	
		select TOP 1 E1_NUM, E1_PARCELA, E1_VENCTO, E1_VALOR, E1_BAIXA, E1_FATPREF, E1_FATURA
		from SE1070 SE1
		join SC9070 SC9 on C9_FILIAL = E1_FILIAL and C9_NFISCAL = E1_NUM and C9_SERIENF = E1_PREFIXO
		
		where
			E1_FILIAL = %XFILIAL:SE1%
			and C9_BLINF like %Exp:AllTrim(CEMPANT)+SE1->(E1_NUM+E1_PREFIXO)%+'%'
			
			and E1_PARCELA =	case when exists (select 1 from SE1070 X 
										where X.E1_FILIAL	= SE1.E1_FILIAL 
										and X.E1_NUM 		= SE1.E1_NUM 
										and X.E1_PREFIXO 	= SE1.E1_PREFIXO 
										and X.E1_TIPO 		= SE1.E1_TIPO
										and X.E1_NATUREZ 	= '1230') 
								then 
									(select top 1 E1_PARCELA from SE1070 X 
													where X.E1_FILIAL 	= SE1.E1_FILIAL 
													and X.E1_NUM 		= SE1.E1_NUM 
													and X.E1_PREFIXO 	= SE1.E1_PREFIXO 
													and X.E1_TIPO 		= SE1.E1_TIPO
													and X.E1_NATUREZ 	<> '1230      '
													and X.E1_PARCELA > case when %Exp:SE1->E1_PARCELA% = ' ' then 'A' else %Exp:SE1->E1_PARCELA% end)
								else %Exp:SE1->E1_PARCELA%
								end
			
			and SE1.E1_YFDCVAL = 0
			and SE1.D_E_L_E_T_=''
			and SC9.D_E_L_E_T_=''
	
	EndSql
	
	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof()) .And. Empty((cAliasTmp)->E1_BAIXA) .And. Empty((cAliasTmp)->E1_FATURA)
	
		lRet := .F.
		MsgAlert("ATENÇÃO! O título No.: "+(cAliasTmp)->E1_NUM+" - Parcela: "+(cAliasTmp)->E1_PARCELA+" - Vencto: "+DTOC(STOD((cAliasTmp)->E1_VENCTO))+CRLF+;
		"Valor: R$ "+AllTrim(Str((cAliasTmp)->E1_VALOR,14,2))+""+CRLF+;
		"na empresa LM ainda não foi baixado.","Valida baixa LM - FA070CHK")	

	EndIf

	cPre  := Alltrim((cAliasTmp)->E1_FATPREF)
	cNum  := Alltrim((cAliasTmp)->E1_FATURA)
	(cAliasTmp)->(DbCloseArea())


	//Verificacao se o titulo do Cliente na empresa 07-LM foi baixado atraves de Fatura.
	//Neste caso será necessário verificar se a fatura gerada atraves do Titulo NF esta em atraso (não é possível verificar parcela = parcela)
	If !Empty(cNum) .And. cNum <> "NOTFAT" 

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%

			SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_SALDO, E1_VENCTO
			FROM SE1070
			WHERE E1_FILIAL 	= '01' 
				AND E1_PREFIXO	= %Exp:cPre% 
				AND E1_NUM 		= %Exp:cNum% 
				AND E1_CLIIENTE = %Exp:SE1->E1_CLIENTE%
				AND E1_LOJA		= %Exp:SE1->E1_LOJA%
				AND E1_VENCTO   < CONVERT(NVARCHAR,GETDATE(),112) 
				AND E1_SALDO	> 0
				AND E1_TIPO 	= 'FT'  AND D_E_L_E_T_ = ''

		EndSql
	
		(cAliasTmp)->(DbGoTop())
		If !(cAliasTmp)->(Eof())

			lRet := .F.
			MsgAlert("ATENÇÃO! A Fatura No.: "+(cAliasTmp)->E1_NUM+" - Parcela: "+(cAliasTmp)->E1_PARCELA+" - Vencto: "+DTOC(STOD((cAliasTmp)->E1_VENCTO))+CRLF+;
			"Valor: R$ "+AllTrim(Str((cAliasTmp)->E1_VALOR,14,2))+""+CRLF+;
			"na empresa LM ainda não foi baixada.","Valida baixa LM - FA070CHK")	

		EndIf

		(cAliasTmp)->(DbCloseArea())

	EndIf

EndIf

	
If (!IsBlind())
	oBlqCR	:= TBloqueioContaReceber():New()
	_lRet	:= oBlqCR:CheckPorRecno(_cID)
	If(_lRet)
		MsgAlert('<p style="color:red">Titulo FIDC não e possivel realizar "Baixa Manual".</p>', 'FA070CHK')
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return(lRet) 
