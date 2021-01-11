#Include "rwmake.ch"
#Include "topconn.ch"

User Function MS520DEL()
	
	If cEmpAnt == "02"
		Return Nil
	EndIf
		
	
	DelGnreManual()
	
Return Nil


Static Function DelGnreManual()

	Local cQuery		:= ""
	Local cAliasSE1 	:= GetNextAlias()
	Local cAliasSE2 	:= GetNextAlias()
		
	cQuery := "SELECT ISNULL(COUNT(E1_NUM),0) AS AUXIL FROM "+RETSQLNAME("SE1")+" "
	cQuery += "WHERE	E1_PREFIXO	= '"+SF2->F2_SERIE+"'	AND "
	cQuery += "		E1_NUM		= '"+SF2->F2_DOC+"'	AND "
	cQuery += "		E1_TIPO		= 'ST'	AND "
	cQuery += "		E1_NUMBOR	<>	''		AND "
	cQuery += "		D_E_L_E_T_  = '' AND "
	cQuery += "		E1_FILIAL	=	'"+xFilial('SE1')+"'	"
		
	TcQuery cQuery New Alias (cAliasSE1)
	
	cQuery := "SELECT ISNULL(COUNT(E2_NUM),0) AS AUXIL FROM "+RETSQLNAME("SE2")+" "
	cQuery += "WHERE	E2_PREFIXO	=	'"+SF2->F2_SERIE+"'	AND "
	cQuery += "		E2_NUM		=	'"+SF2->F2_DOC+"'	AND "
	cQuery += "		E2_NUMBOR	<>	''		AND "
	cQuery += "		E2_TIPO		=	'ST'	AND "
	cQuery += "		D_E_L_E_T_	=	'' AND "
	cQuery += "		E2_FILIAL	=	'"+xFilial('SE2')+"'	"
		
	TcQuery cQuery New Alias (cAliasSE2)
	
	If (cAliasSE1)->AUXIL == 0 .And. (cAliasSE2)->AUXIL == 0
		
		cQuery := "UPDATE "+RETSQLNAME("SE1")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE	E1_PREFIXO = '"+SF2->F2_SERIE+"' AND "
		cQuery += "		E1_NUM = '"+SF2->F2_DOC+"' AND "
		cQuery += "		E1_TIPO = 'ST' AND "
		cQuery += "		D_E_L_E_T_  = '' AND "
		cQuery += "		E1_FILIAL	=	'"+xFilial('SE1')+"'	"
		
		TCSqlExec(cQuery)
		
		cQuery := "UPDATE "+RETSQLNAME("SE2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE	E2_PREFIXO = '"+SF2->F2_SERIE+"' AND "
		cQuery += "		E2_NUM = '"+SF2->F2_DOC+"' AND "
		cQuery += "		E2_TIPO = 'ST' AND "
		cQuery += "		D_E_L_E_T_  = '' AND "
		cQuery += "		E2_FILIAL	=	'"+xFilial('SE2')+"'	"
			
		TCSqlExec(cQuery)
		
		Conout("MS520DEL => Atualizando Registro ==> E1_PREFIXO: "+SF2->F2_SERIE+", E1_NUM: "+SF2->F2_DOC+", SE1: "+cvaltochar((cAliasSE1)->AUXIL)+", SE2: "+cvaltochar((cAliasSE2)->AUXIL))
	
		
		If (cEmpAnt == '07' .And. cFilAnt == '01')
			If (SF2->F2_CLIENTE == '029954') //LM SP
				
				cQuery := "UPDATE "+RETSQLNAME("SE2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
				cQuery += "WHERE	E2_PREFIXO = '"+SF2->F2_SERIE+"'	AND	"
				cQuery += "		E2_NUM 		= '"+SF2->F2_DOC+"'			AND "
				cQuery += "		E2_TIPO 	= 'ST' 						AND "
				cQuery += "		D_E_L_E_T_  = '' 						AND "
				cQuery += "		E2_FILIAL	=	'05'						"
				
				conout(cQuery)
				
				TCSqlExec(cQuery)
								
				cQuery := "UPDATE "+RETSQLNAME("SF6")+" SET D_E_L_E_T_ = '*' --, R_E_C_D_E_L_ = R_E_C_N_O_ "
				cQuery += "WHERE F6_SERIE 	= '"+SF2->F2_SERIE+"' 	AND "
				cQuery += "		F6_DOC		= '"+SF2->F2_DOC+"' 	AND "
				cQuery += "		F6_CLIFOR	= '029954'				AND "
				cQuery += "		F6_LOJA		= '01'					AND "
				cQuery += "		D_E_L_E_T_  = '' 					AND "
				cQuery += "		F6_FILIAL	= '05'						"
				
				conout(cQuery)
					
				TCSqlExec(cQuery)
				
				Conout("MS520DEL => Atualizando Registro => FILIAL: 05 ")
			
				
			EndIf
		EndIf
		
	
	Else
	
		Conout("MS520DEL => Registro em bordero ==> E1_PREFIXO: "+SF2->F2_SERIE+", E1_NUM: "+SF2->F2_DOC+" ")
	
	EndIf
	
	(cAliasSE1)->(DbCloseArea())
	(cAliasSE2)->(DbCloseArea())

Return 