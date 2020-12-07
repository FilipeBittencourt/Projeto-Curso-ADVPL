#include "protheus.ch"
#include "Topconn.ch"

/*/{Protheus.doc} CRIASXE
@author Ranisses A. Corona
@since 21/12/2017
@version 1.0
@description P.E. para buscar o sequencial das tabelas.
@type function
/*/

User Function CRIASXE()

Local cNum		:= NIL
Local cAlias    := paramixb[1] //cAlias		- Nome da tabela;
Local cCpoSx8   := paramixb[2] //cCpoSX8 	- Nome do campo que será utilizado para verificar o próximo sequencial;
Local cAliasSx8 := paramixb[3] //cAliasSX8 	- Filial e nome da tabela na base de dados que será utilizada para verificar o sequencial;
//Local nOrdSX8   := paramixb[4] //nOrdSX8 	- Índice de pesquisa a ser usada na tabela.
//Local cUsa 		:= "SE1"  // colocar os alias que irão permitir a execução do P.E.
Local cSql		:= ""

Local colFil := cAlias
if substr(cAlias, 1, 1) == "S"
	colFil:= substr(cAlias, 2, 2)
End If

//Busca sequencial somente se todas as variaveis estiverem preenchidas.
//Ex.:O alias TRB ou _CT são exclusivos do sistema e não precisam retornar sequencial pois o próprio preenche automaticamente. 
If !Empty(cAlias) .and. !Empty(cCpoSx8) .and. !Empty(cAliasSx8) 

	cAliasTmp := GetNextAlias()
	If Len(Alltrim(cAliasSx8)) > 2 .And. Alltrim(cAliasSx8) $ ("SA1_CLI#SA1_FUN#"+cEmpAnt+"SC5_REP#"+cEmpAnt+"SC5_INT#"+cEmpAnt+"SC5_BIA_REP#"+cEmpAnt+"SC5_LM_REP#"+cEmpAnt+"SC5_LM_05") //Ticket 1912
		
		If Alltrim(cAliasSx8) == "SA1_CLI"
			cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) <> '8' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
		
		ElseIf Alltrim(cAliasSx8) == "SA1_FUN"
			cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1)  = '8' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "

		Else				

			If cEmpAnt $ "01#05#07"
				
				If (AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) == '05')
					
					If Alltrim(cAliasSx8) == cEmpAnt+"SC5_LM_05"
					
						cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'V%' AND C5_FILIAL = '05' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
					
					EndIf	
					
				Else
				
				
					If Alltrim(cAliasSx8) == cEmpAnt+"SC5_REP"
						cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'D%' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
	
					ElseIf Alltrim(cAliasSx8) == cEmpAnt+"SC5_INT"					
						cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'F%' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
					
					ElseIf Alltrim(cAliasSx8) == cEmpAnt+"SC5_BIA_REP"					
						cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'B%' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
					
					ElseIf Alltrim(cAliasSx8) == cEmpAnt+"SC5_LM_REP"					
						cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'L%' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "
						
					EndIf	
				
				EndIf
				

			ElseIf cEmpAnt == "13"
				cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE SUBSTRING("+cCpoSx8+",1,1) LIKE 'M%' AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "

			ElseIf cEmpAnt == "14"
				cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "

			EndIf

		EndIf

	Else

		//Ordenação através do último campo CHAVE
		If cAlias $ "SZI#"
			cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ = '' ORDER BY "+cCpoSx8+" DESC "
		
		//Ordenação através do MAIOR campo CHAVE 
		ElseIf cAlias $ "SC1#" .Or. cCpoSx8 $ "E5_PROCTRAB#"
			cSql := "SELECT MAX("+cCpoSx8+") AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE LEN("+cCpoSx8+") = '"+Alltrim(Str(TamSX3(cCpoSx8)[01]))+"' AND D_E_L_E_T_ = '' "
			
		//Ticket 7614 - Erro ao buscar proximo sequencial na empresa JK	para pedidos de venda
		ElseIf cAlias $ "SC5#" .And. cEmpAnt == "06"
			cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ = '' and "+colFil+"_FILIAL =  '"+xFilial(cAlias)+"' ORDER BY R_E_C_N_O_ DESC "
		
		ElseIf cAlias $ "SE2#SE1" .And. cCpoSx8 $ "E2_IDCNAB#E1_IDCNAB"
		
			cSql := "SELECT MAX(" + cCpoSx8 + ") NUMSEQ FROM " + RetSqlName(cAlias) + " WHERE " + cCpoSx8 + " <> '' "
			
		//Ordenação através do último R_E_C_N_O_ - ATENDE A MAIORIA DOS CASOS
		Else
			
			cSql := "SELECT TOP 1 "+cCpoSx8+" AS NUMSEQ FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC "

		EndIf
		
	EndIf		
	TcQuery cSql Alias (cAliasTmp) New
	
	//Soma1
	If !(cAliasTmp)->(EOF())
		cNum := soma1((cAliasTmp)->NUMSEQ)		
	EndIf

	(cAliasTmp)->(DbCloseArea())

End

Return(cNum)