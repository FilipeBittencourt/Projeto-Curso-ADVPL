#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function GT1VCTE()

	Local cTipCte	:= PARAMIXB[1]
	Local aCab		:= PARAMIXB[2]
	Local aNFOri	:= PARAMIXB[3]
	Local _lRet		:= .T.
	
	//validação só vai ocorrer quando o parametro do conexão nfe tiver falso
	//If (!SUPERGETMV("MV_XGTBCTE", .F., .T.)) 
	/*
	If (VNFEOCTE(aNFOri))
		_lRet := .T.
	Else
		_lRet := .F.
	EndIf
	
	*/
	
	//EndIf			
Return _lRet


	

Static Function VNFEOCTE(aNFOri)
	Local _lRet 		:= .T.
	Local _aArea		:= GetArea()
	Local nI			:= 0
	Local cMsg			:= ""
	
	For nI := 1 To Len(aNFOri)
		DbSelectArea("SF1")
		SF1->(DbSetOrder(1))
		If !SF1->(DbSeek(xFilial("SF1") + aNFOri[nI][1][2]) )
			_lRet 	:= .F.
			cMsg 	+=  aNFOri[nI][1][2]+CHR(13)+CHR(13) 
		EndIf
	Next nI
	
	Conout("GT1VCTE : MSG => "+cMsg+", "+cvaltochar(_lRet))
	
	If (!_lRet)
		cMsg := CHR(13)+CHR(13)+cMsg
		
		MsgAlert('<p style="color:red">Nota fiscal de referência do CTE não foi encontrada. Favor incluir a nota para depois da entrada no CTE.'+cMsg+'</p>', 'GT1VCTE')
	EndIf		

	RestArea(_aArea)
	
Return(_lRet)