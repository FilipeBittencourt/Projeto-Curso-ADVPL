#include "rwmake.ch"

User Function BIA213C()

	/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
	北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
	北矲un噭o    � BIA213C    � Autor � Marcelo Ventura Felix � Data �13/04/2000潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
	北矰escri噭o � Autoriza嚻o de Entrega - valid da qtd solicitada             潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
	北� Uso      � Interpretador xBase                                          潮�
	北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
	北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/
	Local J
	SetPrvt("NQTDSOL,NOCOR,J,")

	If M->QTDSOL #0.00
		If M->QTDSOL <= aColsS[n,8]
			nQtdSol := 0.00
			nOcor   := 0
			For J := 1 to len(aCols)
				If alltrim(aCols[J,2]) == alltrim(aCols[n,2])
					if J #n
						nQtdSol := nQtdSol + aCols[J,3]
					else
						nQtdSol := nQtdSol + M->QTDSOL
					Endif
					nOcor   := nOcor + 1
				Endif
			Next
			If aColsS[n,8] >= nQtdSol
				Return(.t.)
			Else
				msgstop(iif(nOcor>1,"Soma da ","")+"Qtd Solicitada maior que"+chr(10)+"Qtd Entrega!"+str(aColsS[n,8]))
				Return(.f.)
			EndIf
		Else
			msgstop("Qtd Solicitada maior que"+chr(10)+"Qtd Entrega!"+str(aColsS[n,8]))
			Return(.f.)
		EndIf
	Else
		Return(.t.)
	EndIf

Return

