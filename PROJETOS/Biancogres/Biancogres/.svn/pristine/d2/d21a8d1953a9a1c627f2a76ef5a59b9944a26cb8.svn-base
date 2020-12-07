#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} MC050TREE
@author Artur Antunes
@since 28/04/17
@version 1.0
@description Ponto de entrada consulta produto - Inclusao pre-requisição
@obs compras
@obs OS 0993-17
@type function
/*/

User Function MC050TREE()

	Local cAlias	:= ''
	local cAliasTop := '' 
	local aTam		:= {}
	local cPos		:= ''
	local lExist	:= .F.
	Local _cAliasSB6	:=	GetNextAlias()
	Local _cAliasBIZ	:=	GetNextAlias()
	Local _nPos

	PUBLIC oTreeX 	:= PARAMIXB[1]  
	PUBLIC aTotaisX := {{0,0},{0,0},{0,0}}
	PUBLIC aTotAlm	:=	{}
	PUBLIC aTotReq	:=	{}
	
	cPos	:= oTreeX:GetCargo()
	cAlias	:= SubStr(cPos,3,3) 

	if !oTreeX:TreeSeek("21SZI"+StrZero(0,12))
		oTreeX:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
		oTreeX:AddItem("Pre-Requisicoes (GBI)","21SZI"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Pre-Requisicoes"
	endif

	if !oTreeX:TreeSeek("22SB6"+StrZero(0,12))
		oTreeX:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
		oTreeX:AddItem("Saldo Poder Terceiros (GBI)","22SB6"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Poder Terceiros"
	endif

	if !oTreeX:TreeSeek("23BIZ"+StrZero(0,12))
		oTreeX:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
		oTreeX:AddItem("Pre-Requisicoes Bizagi (GBI)","23BIZ"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Pre-Requisicoes"
	endif

	dbSelectArea("SZI")
	cAliasTop := CriaTrab(NIL,.f.)

	cQuery := " SELECT SZI.*,SZJ.*,SZI.R_E_C_N_O_ CQREC "
	cQuery += " FROM "+RetSqlName("SZI")+" SZI (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("SZJ")+" SZJ (NOLOCK) "
	cQuery += "  ON ZJ_DOC = ZI_DOC "
	cQuery += "  AND ZJ_COD = '" + SB1->B1_COD + "' "
	cQuery += "  AND ZJ_LOCAL BETWEEN '" +aParc050[06]+"' AND '" +aParc050[07]+"' "
	cQuery += "  AND SZJ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ZI_BAIXA NOT IN ('S', 'X') "
	cQuery += "  AND SZI.ZI_FILIAL = '"+xFilial('SZI')+"' "
	cQuery += "  AND SZI.ZI_EMPRESA = '"+cEmpAnt+"' "
	cQuery += "  AND SZI.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY "+SqlOrder(SZI->(IndexKey(1)))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aTam := TamSx3("ZJ_QUANT")
	TCSetField( cAliasTop, "ZJ_QUANT", "N", aTam[1], aTam[2])
	aTam := TamSx3("ZJ_VLRTOT")
	TCSetField( cAliasTop, "ZJ_VLRTOT", "N", aTam[1], aTam[2])

	dbSelectArea(cAliasTop)
	(cAliasTop)->(DbGoTop())

	If !Eof()
		oTreeX:TreeSeek("21SZI"+StrZero(0,12))
		While !(cAliasTop)->(Eof())  

			if !oTreeX:TreeSeek("21SZI"+StrZero((cAliasTop)->CQREC,12))
				oTreeX:TreeSeek("21SZI"+StrZero(0,12))
				oTreeX:AddItem((cAliasTop)->ZI_DOC+" ","21SZI"+StrZero((cAliasTop)->CQREC,12),"PMSDOC","PMSDOC",,,2)
			endif

			aTotaisX[1,1] += (cAliasTop)->ZJ_QUANT  // Quantidade
			aTotaisX[1,2] += (cAliasTop)->ZJ_VLRTOT // Valor

			(cAliasTop)->(dbSkip())
		End
	Endif
	(cAliasTop)->(dbCloseArea())

	BeginSql Alias _cAliasSB6
	
		SELECT B6_DOC,B6_QUANT,B6_PRUNIT, R_E_C_N_O_ REGSB6
			FROM %TABLE:SB6% SB6
			WHERE B6_FILIAL = %XFILIAL:SB6%
				AND B6_SALDO <> 0
				AND B6_PRODUTO = %Exp:SB1->B1_COD%
				AND SB6.%NotDel%
	
	EndSql
	If (_cAliasSB6)->(!EOF())
		oTreeX:TreeSeek("22SB6"+StrZero(0,12))
		While (_cAliasSB6)->(!EOF())

			if !oTreeX:TreeSeek("22SB6"+StrZero((_cAliasSB6)->REGSB6,12))
				oTreeX:TreeSeek("22SB6"+StrZero(0,12))
				oTreeX:AddItem((_cAliasSB6)->B6_DOC+" ","22SB6"+StrZero((_cAliasSB6)->REGSB6,12),"PMSDOC","PMSDOC",,,2)
			endif

			aTotaisX[2,1] += (_cAliasSB6)->B6_QUANT  // Quantidade
			aTotaisX[2,2] += (_cAliasSB6)->B6_PRUNIT * (_cAliasSB6)->B6_QUANT // Valor
			
			(_cAliasSB6)->(DbSkip())
		EndDo
	
	EndIf

	BeginSql Alias _cAliasBiz
		%NoParser%
		SELECT ek.Codigo COD
			,RIGHT('00'+CAST(prd.Armazens AS VARCHAR(2)),2) ARMAZ
			,p.Documento DOC
			,prd.Quantidade QTD
			,ROW_NUMBER() OVER (
				ORDER BY p.Documento
				) SEQ
		FROM ZEUS.BIZAGIPRD.dbo.PreRequisicao p
		INNER JOIN ZEUS.BIZAGIPRD.dbo.ProdutosPreRequisitados prd ON prd.PreRequisicao = p.idPreRequisicao
		INNER JOIN ZEUS.BIZAGIPRD.dbo.VW_BZ_PRODUTO_EK ek ON ek.idVW_BZ_PRODUTO = prd.Produto
		WHERE p.Avaliadopor IS NULL
			AND p.DocumentoProthues IS NULL
			AND p.DatadaRejeicao IS NULL
			AND p.TipodeRequisicao = 1
			AND p.CanceladoAutomaticamente IS NULL
			AND ek.Codigo = %Exp:SB1->B1_COD%
			AND RIGHT('00'+CAST(prd.Armazens AS VARCHAR(2)),2) BETWEEN %Exp:aParc050[06]% AND %Exp:aParc050[07]% 
	EndSql
	
	If (_cAliasBiz)->(!EOF())
		oTreeX:TreeSeek("23BIZ"+StrZero(0,12))
		While (_cAliasBiz)->(!EOF())
	
			If (_nPos	:=	aScan(aTotReq,{|x| x[1] == (_cAliasBiz)->DOC .And. x[2] == (_cAliasBiz)->ARMAZ})) > 0
				aTotReq[_nPos,3]	+=	(_cAliasBIZ)->QTD
			Else
				aAdd(aTotReq,{(_cAliasBiz)->DOC,(_cAliasBiz)->ARMAZ,(_cAliasBIZ)->QTD})
			EndIF			
	
			aTotaisX[3,1] += (_cAliasBIZ)->QTD  // Quantidade
			
			
			If (_nPos	:=	aScan(aTotAlm,{|x| x[1] == (_cAliasBiz)->ARMAZ})) > 0
				aTotAlm[_nPos,2]	+=	(_cAliasBIZ)->QTD
			Else
				aAdd(aTotAlm,{(_cAliasBiz)->ARMAZ,(_cAliasBIZ)->QTD})
			EndIF
			
			
			(_cAliasBiz)->(DbSkip())
		EndDo
	
	
	
	EndIf
	(_cAliasBiz)->(DbCloseArea())
	(_cAliasSB6)->(DbCloseArea())
	oTreeX:TreeSeek("23BIZ"+StrZero(0,12))
	oTreeX:TreeSeek("22SB6"+StrZero(0,12))
	oTreeX:TreeSeek("21SZI"+StrZero(0,12))
	oTreeX:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
Return


User Function MC050INF()

	Local aOrigem := ParamIXB[1] // Vetor com as informações originais
	local cAlias  := SubStr(oTreeX:GetCargo(),3,3) 
	Local _nI

	If cAlias == 'SZI'    
		if aTotaisX[1,1] > 0
			aOrigem := {}
			aAdd(aOrigem, {'O Produto Possui Pre-Requisicoes',''})   
			aAdd(aOrigem, {'Totais de Pre-Requisicoes:',''})   
			aAdd(aOrigem, {'',''})   
			aAdd(aOrigem, {'Quantidade:' ,Alltrim(TRANSFORM(aTotaisX[1,1], PESQPICT("SZJ", "ZJ_QUANT" ))) })   
			aAdd(aOrigem, {'Valor:' 	 ,Alltrim(TRANSFORM(aTotaisX[1,2], PESQPICT("SZJ", "ZJ_VLRTOT"))) })   
		endif	
	EndIf
	
	If cAlias == "SB6"
		if aTotaisX[2,1] > 0
			aOrigem := {}
			aAdd(aOrigem, {'O Produto Possui Estoque em Poder de Terceiros',''})   
			aAdd(aOrigem, {'Totais em Poder de Terceiros:',''})   
			aAdd(aOrigem, {'',''})   
			aAdd(aOrigem, {'Quantidade:' ,Alltrim(TRANSFORM(aTotaisX[2,1], PESQPICT("SB6", "B6_QUANT" ))) })   
			aAdd(aOrigem, {'Valor:' 	 ,Alltrim(TRANSFORM(aTotaisX[2,2], PESQPICT("SB6", "B6_PRUNIT"))) })   
		endif	
	EndIf

	If cAlias == "BIZ"
		if aTotaisX[3,1] > 0
			aOrigem := {}
			aAdd(aOrigem, {'O Produto Possui Requisições no Bizagi',''})
			aAdd(aOrigem, {'',''})   
			For _nI	:=	1 To Len(aTotReq)
				aAdd(aOrigem, {Alltrim(aTotReq[_nI,1]) + " / " + aTotReq[_nI,2] ,Alltrim(TRANSFORM(aTotReq[_nI,3], PESQPICT("SB6", "B6_QUANT" ))) })
			Next			
			aAdd(aOrigem, {'',''})   
			aAdd(aOrigem, {'Totais por Almoxarifado:',''})
			For _nI	:=	1 To Len(aTotAlm)
				aAdd(aOrigem, {'Almoxarifado '+ aTotAlm[_nI,1] +':' ,Alltrim(TRANSFORM(aTotAlm[_nI,2], PESQPICT("SB6", "B6_QUANT" ))) })
			Next
			aAdd(aOrigem, {'',''})   
			
			aAdd(aOrigem, {'Total Geral:' ,Alltrim(TRANSFORM(aTotaisX[3,1], PESQPICT("SB6", "B6_QUANT" ))) })
	
	   
		endif	
	EndIf

Return aOrigem 
