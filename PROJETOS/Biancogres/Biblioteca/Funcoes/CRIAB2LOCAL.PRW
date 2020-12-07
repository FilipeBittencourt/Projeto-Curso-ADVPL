

User Function FACRIAB2()

	Local _cAlias
	
	RpcSetType(3)
	RpcSetEnv("01","01")
	
		_cAlias	:=	GetNextAlias()
		
		BeginSql Alias _cAlias
		
			SELECT *
			FROM %TABLE:SB2% B201
			WHERE B201.B2_FILIAL = %XFILIAL:SB2%
				AND B201.B2_LOCAL = '01'
				AND B201.%NotDel%
				AND B201.B2_COD BETWEEN '1'
					AND '6Z'
				AND B201.B2_QATU > 0
				AND NOT EXISTS (
					SELECT 1
					FROM %TABLE:SB2% B220
					WHERE B220.B2_FILIAL = B201.B2_FILIAL
						AND B220.B2_COD = B201.B2_COD
						AND B220.B2_LOCAL = '20'
						AND B220.%NotDel%
					)
		
		EndSql
	
		While (_cAlias)->(!EOF())
		
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+(_cAlias)->B2_COD+'20'))
				CriaSB2((_cAlias)->B2_COD,"20")
			EndIf
		
			(_cAlias)->(DbSkip())
		EndDo


	RpcClearEnv()

Return