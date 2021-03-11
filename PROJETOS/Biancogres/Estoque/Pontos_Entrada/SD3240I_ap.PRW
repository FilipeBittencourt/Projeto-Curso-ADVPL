#include "rwmake.ch" 

/*/{Protheus.doc} SD3240i
@author Nilton Cesar
@since 08.08.03
@version undefined
@description Zerar a quantidade para movimentacao de Argila
@type function
/*/

User Function SD3240I()

	Local x
	Local _oMd	:=	TBiaControleMD():New()
	Local _cMatOri	:=	""

	SetPrvt("AAREA,X,WP_COD,")
	Private cArqSB2	:= ""
	Private cIndSB2	:= 0
	Private cRegSB2	:= 0

	Public vp_SeqND3 := SD3->D3_NUMSEQ // Variável para o Programa BIA292. Por Marcos Alberto Soprani em 04/09/12. A partir de 31/01/13 passou a ser usada pelo fonte BIA701.

	aArea:=GetArea()

	If SD3->D3_TM > '500' .And. _oMd:CheckMd(SD3->D3_COD,SD3->D3_LOCAL)
		_cMatOri	:=	Iif(!Empty(SD3->D3_YMATORI),SD3->D3_YMATORI,SD3->D3_YMATRIC)

		_oMd:InsereMovimentacao(SD3->D3_FILIAL,SD3->D3_DOC,"","","","",SD3->D3_COD,SD3->D3_QUANT,SD3->D3_LOCAL,;
			    									"501",SD3->D3_YMATRIC,_cMatOri,cUserName,Alltrim(funname()),SD3->D3_EMISSAO,"SD3",SD3->(RECNO())) //Insere Movimentação na Tabela	

		
	EndIf

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	IF Type("_ExecAutoII") <> "U" 
		RestArea(aArea)
		Return
	ENDIF

	If Alltrim(funname())=="MATA241" .and. Alltrim(CTM)=="200" .and. cempant == "02"

		For x:=1 to Len(Acols)

			wP_COD     := aScan(aHeader,{|x| x[2]=="D3_COD    "})
			DbSelectArea("SD3")
			DbSetOrder(2)
			If DbSeek(xFilial("SD3")+CDOCUMENTO+aCols[x,wP_COD    ])
				If Reclock("SD3",.f.)
					DbSelectArea("SB2")
					cArqSB2 := Alias()
					cIndSB2 := IndexOrd()
					cRegSB2 := Recno()
					DbSetOrder(1)
					If DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)
						If RecLock("SB2",.F.)
							SB2->B2_QATU := SB2->B2_QATU - SD3->D3_QUANT
							SB2->B2_CM1  := Round(SB2->B2_VATU1 / SB2->B2_QATU,2)
							MsUnlock()
						EndIf
					EndIf
					DbSelectArea("SD3")
					SD3->D3_QUANT   := 0
					SD3->D3_QTSEGUM := 0
					MsUnlock()
				EndIf
			EndIf

		Next

	ElseIf Alltrim(funname())=="MATA240" .and. Alltrim(SD3->D3_TM)=="200" .and. cempant == "02"

		If Reclock("SD3",.f.)
			DbSelectArea("SB2")
			cArqSB2 := Alias()
			cIndSB2 := IndexOrd()
			cRegSB2 := Recno()
			DbSetOrder(1)
			If DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)
				If RecLock("SB2",.F.)
					SB2->B2_QATU := SB2->B2_QATU - SD3->D3_QUANT
					SB2->B2_CM1  := Round(SB2->B2_VATU1 / SB2->B2_QATU,2)
					MsUnlock()
				EndIf
			EndIf
			DbSelectArea("SD3")
			SD3->D3_QUANT := 0
			SD3->D3_QTSEGUM := 0

			MsUnlock()
		EndIf

	ElseIf Alltrim(funname()) == "MATA241"

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + SD3->D3_COD)
		dfConta := SD3->D3_CONTA
		If Alltrim(dfConta) <> "41301001"

			If U_B478RTCC(SD3->D3_CLVL)[2] == "D"
				dfConta := SB1->B1_YCTRADM

			ElseIf U_B478RTCC(SD3->D3_CLVL)[2] == "C"
				dfConta := SB1->B1_YCTRIND

			ElseIf U_B478RTCC(SZI->ZI_CLVL)[2] $ "A/I"
				dfConta  := "16503" + Substr(SZI->ZI_CLVL,2,8)				

			EndIf

			Reclock("SD3",.f.)
			SD3->D3_CONTA := dfConta
			MsUnlock()

		EndIf

	EndIf

	If cArqSB2 <> ""
		DbSelectArea(cArqSB2)
		DbSetOrder(cIndSB2)
		DbGoTo(cRegSB2)
		RetIndex("SB2")
	EndIf

	RestArea(aArea)

Returns
