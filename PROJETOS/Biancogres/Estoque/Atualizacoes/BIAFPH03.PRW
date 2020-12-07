#Include "protheus.ch" 
#Include "totvs.ch" 
#Include "tbiconn.ch"
#Include "topconn.ch"

User Function BIAFPH03()
	
	Local ListaDB	:= {'DADOSEOS'}
	Local nI		:= 0
	Local nResult	:= 0
	Local cQuery	:= ""
	Local cBanco	:= ""
	
	RpcSetType(3)
	RpcSetEnv("01", "01") 
	
	For nI:=1 To Len (ListaDB)
		
		cBanco := ListaDB[nI]
		
		cQuery := " DELETE 																				"+CRLF	
		cQuery += " 		  FROM  																	"+CRLF
		cQuery += " 		        "+cBanco+"..cep_etiqueta_processa_itens 							"+CRLF  									
		cQuery += " 		   WHERE cod_etiqueta IN (													"+CRLF
		cQuery += " 		   SELECT DISTINCT cepi.cod_etiqueta 										"+CRLF
		cQuery += " 		   	FROM "+cBanco+"..cep_etiqueta_processa_itens cepi						"+CRLF
		cQuery += " 			INNER JOIN "+cBanco+"..cep_etiqueta_processa ctp ON 					"+CRLF
		cQuery += " 				ctp.id_bordero =  cepi.id_bordero									"+CRLF
		cQuery += " 			INNER JOIN "+cBanco+"..cep_etiqueta_pallet cep ON 						"+CRLF
		cQuery += " 				cepi.cod_etiqueta = cep.cod_etiqueta								"+CRLF
		cQuery += " 			INNER JOIN "+cBanco+"..cep_movimento_endereco cme ON					"+CRLF
		cQuery += " 				cme.cod_produto = cep.cod_produto									"+CRLF
		cQuery += " 				and cme.cod_endereco = cep.cod_endereco 							"+CRLF
		cQuery += " 				and cme.cme_lote = cep.etiq_lote 									"+CRLF
		cQuery += " 				and cme.cme_docto = cep.cod_etiqueta								"+CRLF
		
		cQuery += " 			WHERE 																	"+CRLF
		cQuery += " 				cep.cod_endereco		<>	'PEP00'									"+CRLF
		cQuery += " 				AND cme.cme_data		>	CONVERT(VARCHAR(10), DATEADD(day, -30, GETDATE()), 120) 	"+CRLF
		cQuery += " 				AND bri_modo			=	'O'										"+CRLF
		cQuery += " 				AND nf_numero			= 	''										"+CRLF
		cQuery += " 				AND cme_saldo			> 0											"+CRLF
		cQuery += " 			)   																	"+CRLF
		
		Conout("[BIAFPH03] => "+cQuery)
		
		If (TCSQLExec(cQuery) < 0)
			cMsg := TcSqlError()
			Conout("[BIAFPH03] => Erro na execução da Procedure : "+cMsg) 
		Else
			Conout("[BIAFPH03] => Query executada com sucesso.")
		EndIf					
		
	Next nI
	
	RpcClearEnv()
	

Return 