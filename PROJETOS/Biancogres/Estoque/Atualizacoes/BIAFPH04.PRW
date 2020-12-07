#Include "protheus.ch" 
#Include "totvs.ch" 
#Include "tbiconn.ch"
#Include "topconn.ch"


User Function BIAFPH04()
	
	Local ListaDB		:= {'DADOSEOS'}
	Local nI			:= 0
	Local cProce		:= ""
	Local cMsg 			:= ""
	
	RpcSetType(3)
	RpcSetEnv("01", "01") 
	
	For nI:=1 To Len (ListaDB)
		
		cProce := "EXEC ["+ListaDB[nI]+"].[dbo].[TRANSFERIR_SALDO_BORDERO_PROXIMO_TURNO]"
	
		If (TCSQLExec(cProce) < 0)
			cMsg := TcSqlError()
			Conout("[BIAFPH04] => Erro na execução da Procedure : "+cMsg) 
		Else
			Conout("[BIAFPH04] => Procedure "+ cProce+" executada com sucesso.")
		EndIf					

	Next nI
	
	RpcClearEnv()

Return