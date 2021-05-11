#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function PNFM0010()

	Local cQuery		:= ""
	Local cAliasTemp	:= Nil
	Local cChave		:= ""
	
	RpcSetEnv('01', '01')
	
	//TODO AJUSTAR FILTRO LIKE TABELA ZLL
	
	cAliasTemp := GetNextAlias()
	cQuery += " select CHAVE=ZAA_CHAVE from "+RetSQLName("ZAA")+" ZAA (nolock)				"+ Chr(13) + Chr(10)
	cQuery += " where                                                                       "+ Chr(13) + Chr(10)
	cQuery += " 1=1                                                                         "+ Chr(13) + Chr(10)
	cQuery += " AND D_E_L_E_T_			= ''                                                "+ Chr(13) + Chr(10)
	cQuery += " AND ZAA.ZAA_FILIAL		= '"+xFilial('ZAA')+"'								"+ Chr(13) + Chr(10)
	cQuery += " AND not exists (                                                            "+ Chr(13) + Chr(10)
	cQuery += " 	select 1 from "+RetSQLName("SF1")+" SF1 (nolock)						"+ Chr(13) + Chr(10)
	cQuery += " 		where                                                               "+ Chr(13) + Chr(10)
	cQuery += " 		1=1                                                                 "+ Chr(13) + Chr(10)
	cQuery += " 		AND SF1.F1_FILIAL		= ZAA_FILIAL                                "+ Chr(13) + Chr(10)
	cQuery += " 		AND SF1.F1_CHVNFE		= ZAA_CHAVE                                 "+ Chr(13) + Chr(10)
	cQuery += " 		AND SF1.D_E_L_E_T_		= ''                                        "+ Chr(13) + Chr(10)
	cQuery += " )                                                                           "+ Chr(13) + Chr(10)
	cQuery += " AND exists (                                                                "+ Chr(13) + Chr(10)
	cQuery += " 	select  1 from "+RetSQLName("ZLL")+" ZLL  (nolock)                      "+ Chr(13) + Chr(10)
	cQuery += " 	 where	                                                                "+ Chr(13) + Chr(10)
	cQuery += " 	 1=1													                "+ Chr(13) + Chr(10)
	cQuery += " 	 AND ZLL.ZLL_FILIAL								= '"+xFilial('ZLL')+"'	"+ Chr(13) + Chr(10)
	cQuery += " 	 AND LTRIM(cast(ZLL_CHCTE as varchar(max)))		= ZAA_CHAVE             "+ Chr(13) + Chr(10)
	cQuery += " 	 AND ZLL.D_E_L_E_T_								= ''                    "+ Chr(13) + Chr(10)
	cQuery += " 	 AND ZLL.ZLL_CHCTE								<> ''                   "+ Chr(13) + Chr(10)
	cQuery += " )                                                                           "+ Chr(13) + Chr(10)
	
	ConOut(cQuery)
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	While (!(cAliasTemp)->(EoF()))
		
		cChave := (cAliasTemp)->CHAVE
		
		ConOut('Importando CTE: '+cChave)
		
		U_PNFM0003(cChave)
		
		(cAliasTemp)->(DbSkip())
	
	EndDo
	
	(cAliasTemp)->(DbCloseArea())	
	
Return 