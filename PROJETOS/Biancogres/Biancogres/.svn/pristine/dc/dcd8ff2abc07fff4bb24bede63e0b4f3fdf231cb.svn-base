#include "rwmake.ch"
#include "topconn.ch"

User Function M116ACOL()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor(Rev):= Fernando Rocha
Autor     := Marcos Alberto Soprani
Programa  := M116ACOL
Empresa   := Biancogres Cerâmica S/A
Data      := 28/07/10
Data(Rev) := 22/03/12
Uso       := Inclusão de Conhecimento de Frete
Aplicação := PONTO DE ENTRADA - ATUALIZAR ACOLS NA INCLUSAO DE CTRC
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local aArea     := GetArea()
Local cAliasSD1 := PARAMIXB[1]                                       //-- Alias arq. NF Entrada itens
Local nX        := PARAMIXB[2]                                       //-- Número da linha do aCols correspondente
Local aDoc      := PARAMIXB[3]                                       //-- Vetor contendo o documento, série, fornecedor, loja e itens do documento
Local _nPosCtr  := AScan(AHeader,{|x|  AllTrim(x[2])=="D1_YCONTR"})
Local _nPosReg  := AScan(AHeader,{|x|  AllTrim(x[2])=="D1_YREGRA"})

// Criado por Marcos Alberto para tratamento de verificação quanto a duplicidade de associações de vários CTR a uma mesmo NFE - em 22/03/12
If nX == 1 .and. !Upper(Alltrim(FunName())) $ "FAXML02/BIA296"
	Public xtVetNfO
	xtVetNfO := {}
EndIf
aadd(xtVetNfO, PARAMIXB[3])

If nX <= 0
	Return
EndIf

//POSICIONAR NA NOTA DE ORIGEM DO CONHECIMENTO
SD1->(dbSetOrder(1))
If SD1->(dbSeek(xFilial("SD1")+PARAMIXB[3,1]+PARAMIXB[3,2]+PARAMIXB[3,3]+PARAMIXB[3,4]))
	//Copiando o campo de contrato da NFE origem para o CTRC
	If _nPosCtr > 0
		ACols[nX][_nPosCtr] := SD1->D1_YCONTR
	EndIf
	//Copiando o campo de origem da NFE origem para o CTRC
	If _nPosReg > 0
		ACols[nX][_nPosReg] := SD1->D1_YREGRA
	EndIf
EndIf

SetPIcms(nX, PARAMIXB[3])

RestArea(aArea)

Return


Static Function SetPIcms(nI, aParam)
	
	Local _nPosPIcm  	:= AScan(AHeader,{|x|  AllTrim(x[2]) == "D1_PICM"})
	Local _nPosNfOri 	:= AScan(AHeader,{|x|  AllTrim(x[2]) == "D1_NFORI"})
	Local _nPosSeOri  	:= AScan(AHeader,{|x|  AllTrim(x[2]) == "D1_SERIORI"})
	
	If IsInCallStack("U_PNFM0003")
		
	//	ACols[nI][_nPosNfOri] := aParam[1]
	//	ACols[nI][_nPosSeOri] := aParam[2]
		
		If (Type("__nAliqICMS") <> "U")
			//__nAliqICMS := variavel privada criada dentro do fonte PNFM0003
			If (__nAliqICMS != 0)
				ACols[nI][_nPosPIcm] := __nAliqICMS
			EndIf
		EndIf
		
		/*SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+aParam[1]+aParam[2]+aParam[3]+aParam[4]))
			If (SD1->D1_PICM != 0)
				ACols[nI][_nPosPIcm] := SD1->D1_PICM
			EndIf
		EndIf
		*/
	EndIf
	
Return 