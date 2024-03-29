#Include 'Protheus.ch'

#Define CR Chr(10)+Chr(13)

User Function PE01NFESEFAZ()
	
	Local aProd		:= PARAMIXB[1]
	Local cMensCli	:= PARAMIXB[2]
	Local cMensFis	:= PARAMIXB[3]
	Local aDest		:= PARAMIXB[4] 
	Local aNota   	:= PARAMIXB[5]
	Local aInfoItem	:= PARAMIXB[6]
	Local aDupl		:= PARAMIXB[7]
	Local aTransp	:= PARAMIXB[8]
	Local aEntrega	:= PARAMIXB[9]
	Local aRetirada	:= PARAMIXB[10]
	Local aVeiculo	:= PARAMIXB[11]
	Local aReboque	:= PARAMIXB[12]
	Local aNfVincRur:= PARAMIXB[13]
	Local aEspVol	:= PARAMIXB[14]
	Local aNfVinc	:= PARAMIXB[15]	
	Local aRetorno	:= {}
	Local cMsg		:= ""
	Local aAreaSBM	:= SBM->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSE1	:= SE1->(GetArea())
	Local aArea		:= GetArea()
   
	
	//|Abertura das tabelas utilizadas |
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	
	//|Altera descri��o do produto para: Descricao + referencia |
	For nI := 1 To Len(aProd)
		
		If SB1->(dbSeek(xFilial("SB1")+aProd[nI,2]))
			
			//|S� altera descri��o para produtos de venda |
			If !Empty(SB1->B1_YREF)      
				aProd[nI,4]	:= AllTrim(SB1->B1_DESC) + " * Ref. : " + AllTrim(SB1->B1_YREF)
			EndIf
			
		EndIf
			
	Next nI
	
	// retorno deve ser exatamente nesta ordem e passando o conte�do completo dos arrays
	//pois no rdmake nfesefaz � atribuido o retorno completo para as respectivas vari�veis
	//Ordem:
	//		aRetorno[1] -> aProd
	//		aRetorno[2] -> cMensCli
	//		aRetorno[3] -> cMensFis
	//		aRetorno[4] -> aDest
	//		aRetorno[5] -> aNota
	//		aRetorno[6] -> aInfoItem
	//		aRetorno[7] -> aDupl
	//		aRetorno[8] -> aTransp
	//		aRetorno[9] -> aEntrega
	//		aRetorno[10] -> aRetirada
	//		aRetorno[11] -> aVeiculo
	//		aRetorno[11] -> aReboque
	
	//|Montagem do array de Retorno |
	aAdd(aRetorno,aProd)
	aAdd(aRetorno,cMensCli)
	aAdd(aRetorno,cMensFis)
	aAdd(aRetorno,aDest)
	aAdd(aRetorno,aNota)
	aAdd(aRetorno,aInfoItem)
	aAdd(aRetorno,aDupl)
	aAdd(aRetorno,aTransp)
	aAdd(aRetorno,aEntrega)
	aAdd(aRetorno,aRetirada)
	aAdd(aRetorno,aVeiculo)
	aAdd(aRetorno,aReboque)
	aAdd(aRetorno,aNfVincRur)
	aAdd(aRetorno,aEspVol)
	aAdd(aRetorno,aNfVinc)
	
	//|Restaura��o das areas |
	RestArea(aAreaSBM)
	RestArea(aAreaSB1)
	RestArea(aAreaSE1)
	RestArea(aArea)
	
Return aRetorno

