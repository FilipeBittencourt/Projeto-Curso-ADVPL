#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120TEL
@author Tiago Rossini Coradini
@since 02/02/2017
@version 1.0
@description Ponto de entrada na criação dos objetos do pedido de compra 
@obs Ticket: 2204
@type function
/*/

User Function MT120TEL 
Local nOpc := ParamIxb[4]
Local nCount := 0

	Public C7_YCREINV := CriaVar("C7_YCREINV", .F.)

	aAdd(aTitles, "Crédito INVEST")

	// Copia do pedido
	If nOpc == 6
	 
		For nCount := 1 To Len(aCols)
					
			aCols[nCount][GdFieldPos("C7_DATPRF")] := dDataBase
			aCols[nCount][GdFieldPos("C7_YDATCHE")] := cToD("")			
			aCols[nCount][GdFieldPos("C7_YEMAIL")] := "N"
			aCols[nCount][GdFieldPos("C7_YDTENV")] := cToD("")
			aCols[nCount][GdFieldPos("C7_YHRENV")] := ""
			aCols[nCount][GdFieldPos("C7_YENVAUT")] := "N"
			aCols[nCount][GdFieldPos("C7_YCONFIR")] := "N"
			aCols[nCount][GdFieldPos("C7_YTPCONF")] := ""
			aCols[nCount][GdFieldPos("C7_YCOMCON")] := ""
			aCols[nCount][GdFieldPos("C7_YDATCON")] := cToD("")
			aCols[nCount][GdFieldPos("C7_YENVTRA")] := "N"
			 
		Next
		
	Endif

Return()