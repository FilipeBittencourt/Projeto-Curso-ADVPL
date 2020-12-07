#include "rwMake.ch"


/*/{Protheus.doc} MA030ROT
@description Ponto de Entrada para adicionar botões no aRotina do cadastro de cliente
@author Fernando Rocha
@since 24/02/2017
@version undefined
@type function
/*/
User Function MA030ROT()  
	
	Local oAceTela 			:= TAcessoTelemarketing():New()
	
	ARETORNO:= {}
	
	If (!oAceTela:UserTelemaketing())
		
		AADD( ARETORNO,  { "Ped. Aten" 		,"U_BIA086"    		, 2 , 0  } )
		AADD( ARETORNO,  { "Ped Não Aten"	,"U_BIA789"    		, 2 , 0  } )
		AADD( ARETORNO,  { "Altera Dados"	,"U_M030ACOB"    	, 4 , 0  } )
	
		// Tiago Rossini Coradini - 02/05/16 - OS: 4647-15 - Vagner Amaro - Consulta CCB
		aAdd(aRetorno, {"Consulta CCB", "U_BIAF033(SA1->A1_COD, SA1->A1_LOJA)", 2, 0})
		
	EndIf
	

RETURN(ARETORNO) 


/*/{Protheus.doc} M030ACOB
@description Alterar o cadastro de cliente somente com alguns campos habilitados conforme acesso
@author Fernando Rocha
@since 24/02/2017
@version undefined

@type function
/*/
User Function M030ACOB()  
        
	Local aCpoVis := {}  
	Local aCpoAlt := {}
	Local cSql	  := ""
	Local nOpcao
	Local nOpcAlt

	//Acesso a alterar endereco de cobranca
	IF U_VALOPER("001",.F.)
		aCpoVis := {"A1_ENDCOB","A1_BAIRROC","A1_CEPC","NOUSER"}  
		aCpoAlt := {"A1_ENDCOB","A1_BAIRROC","A1_CEPC"}
		nOpcAlt := 1
	ENDIF

	//Acesso a alterar nome da loja                         
	IF U_VALOPER("041",.F.)
		aCpoVis := {"A1_COD","A1_LOJA","A1_NOME","A1_CGC","A1_NREDUZ","A1_END","A1_BAIRRO","A1_MUN","A1_EST","A1_CEP","A1_YNLOJA","NOUSER"}  
		aCpoAlt := {"A1_YNLOJA"}
		nOpcAlt := 2
	ENDIF

	If !Empty(aCpoAlt)
		DbSelectArea("SA1")                                       

		nOpcao := AXALTERA("SA1", SA1->(RecNo()),4,aCpoVis, aCpoAlt)

		If nOpcao == 1
			Replicar(nOpcAlt)
		EndIf
	Else
		MsgAlert("Usuário não tem acesso a esta operação!","M030ACOB")
	EndIf

Return

/*/{Protheus.doc} Replicar
@description Replicar as alterações de casmpos do cliente para todas as empresas
@author Fernando Rocha
@since 24/02/2017
@version undefined
@param _nOpc, , descricao
@type function
/*/
Static Function Replicar(_nOpc)

	Local aEmp	:= {"01","05","07","12","13","14"} 
	Local x		:= 0

	For x := 1 to Len(aEmp)	
		If ( aEmp[x] <> AllTrim(CEMPANT) )

			If (_nOpc == 1)

				cSql:= "UPDATE SA1"+aEmp[x]+"0 SET A1_ENDCOB = '"+SA1->A1_ENDCOB+"', A1_BAIRROC = '"+SA1->A1_BAIRROC+"', A1_CEPC = '"+SA1->A1_CEPC+"' WHERE A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' "		
				TcSQLExec(cSQL)

			ElseIf (_nOpc == 2)

				cSql:= "UPDATE SA1"+aEmp[x]+"0 SET A1_YNLOJA = '"+SA1->A1_YNLOJA+"' WHERE A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' "		
				TcSQLExec(cSQL)

			EndIf

		EndIf
	Next
	
Return()