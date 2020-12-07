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

//Checkar se a baixa do titulo correspondente ja foi feita na LM - se nao bloqueia
If AllTrim(CEMPANT) <> "07" .And. SE1->E1_CLIENTE == "010064" .And. SE1->E1_TIPO == "NF "  

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%
	
		select TOP 1 E1_NUM, E1_PARCELA, E1_VENCTO, E1_VALOR, E1_BAIXA
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
			
			and SE1.D_E_L_E_T_=''
			and SC9.D_E_L_E_T_=''
	
	EndSql
	
	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof()) .And. Empty((cAliasTmp)->E1_BAIXA)
	
		lRet := .F.
		MsgAlert("ATENÇÃO! O título No.: "+(cAliasTmp)->E1_NUM+" - Parcela: "+(cAliasTmp)->E1_PARCELA+" - Vencto: "+DTOC(STOD((cAliasTmp)->E1_VENCTO))+CRLF+;
		"Valor: R$ "+AllTrim(Str((cAliasTmp)->E1_VALOR,14,2))+""+CRLF+;
		"na empresa LM ainda não foi baixado.","Valida baixa LM - FA070CHK")	
	
	EndIf

EndIf

RestArea(aArea)
Return(lRet) 