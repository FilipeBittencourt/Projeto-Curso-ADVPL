User Function MT140TOK()

	Local lRet := .T.     
	Local _nI			

	lRet:= U_GTPE011()

	If lRet .And. !FwIsInCallStack('U_GATI001')

		For _nI	:=	1 to Len(aCols)

			IF !GdDeleted(_nI) .And. !Empty(GdFieldGet("D1_CONTA",_nI)) .And. Substr(GdFieldGet("D1_CONTA",_nI),1,1) == '6' .And. !Empty(GdFieldGet("D1_CLVL",_nI)) 
				CTH->(DbSetOrder(1))
				IF CTH->(DbSeek(xFilial("CTH")+GdFieldGet("D1_CLVL",_nI))) .And. CTH->CTH_YATRIB == "C"
					If Empty(GdFieldGet("D1_YAPLIC",_nI)) .or. GdFieldGet("D1_YAPLIC",_nI) == "0" 			
						MsgStop("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!")
						lRet	:=	.F.
						Exit
					EndIf
				EndIf
			EndIf

			IF !GdDeleted(_nI) .And. !Empty(GdFieldGet("D1_CONTA",_nI)) .And. !Empty(GdFieldGet("D1_CLVL",_nI)) 
				If U_BFG81VCL(GdFieldGet("D1_CLVL",_nI)) .And. U_BFG81VCO(GdFieldGet("D1_CONTA",_nI))
					If Empty(GdFieldGet("D1_YDRIVER",_nI))
						MsgStop("A conta e a classe de valor selecionadas exigem que o driver seja informado! Linha: " + Alltrim(Str(_nI)))
						lRet	:=	.F.
						Exit
					EndIF
				EndIf					
			EndIf

		Next

	EndIf

Return lRet
