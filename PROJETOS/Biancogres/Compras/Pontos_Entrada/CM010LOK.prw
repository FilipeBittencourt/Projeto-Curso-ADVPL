#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function CM010LOK()
Local lRetVld 	:= .T. 
Local cFornece 	:= M->AIA_CODFOR	
Local cLoja  	:= M->AIA_LOJFOR 
Local cTabela   := M->AIA_CODTAB
Local cProduto  := ''
Local cAliasT	:= GetNextAlias()
Local dDataIni  := M->AIA_DATDE
Local dDataFin  := M->AIA_DATATE
Local dVigProd  
Local nIxAux	:= 0
Local nPosProd	:= 0  
Local nPosVigPro:= 0  


   	nPosProd 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == 'AIB_CODPRO' } )
   	nPosVigPro 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == 'AIB_DATVIG' } )
	
	cProduto 	:= aCols[n,nPosProd]
	dVigProd  	:= aCols[n,nPosVigPro]
		
	BeginSql Alias cAliasT
		SELECT AIB_CODTAB
		FROM  %Table:AIA% A
		INNER JOIN %Table:AIB% B ON AIA_CODFOR = AIB_CODFOR AND AIA_LOJFOR = AIB_LOJFOR AND AIA_CODTAB = AIB_CODTAB AND B.D_E_L_E_T_ = ''
		WHERE AIB_CODFOR 	= %Exp:cFornece%
		AND AIB_LOJFOR 		= %Exp:cLoja%
		AND AIB_CODPRO 		= %Exp:cProduto%
		AND AIB_CODTAB 		<> %Exp:cTabela%
		AND ((AIA_DATDE BETWEEN %Exp:dDataIni% AND %Exp:dDataFin%) OR (AIA_DATATE BETWEEN %Exp:dDataIni% AND %Exp:dDataFin%))
		AND (AIB_DATVIG BETWEEN %Exp:dDataIni% AND %Exp:dVigProd%)
		AND A.D_E_L_E_T_ = ''
	EndSql
	
	If !(cAliasT)->(Eof())
		MsgBox('Produto: '+ALLTRIM(cProduto)+' já cadastrado e vigente na tabela ' +AllTrim((cAliasT)->AIB_CODTAB)+".","Atenção","STOP")
		lRetVld := .F.
	EndIf

Return lRetVld