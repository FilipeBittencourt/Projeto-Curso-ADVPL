#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
|-------------------------------------------------------------|
| Função:	| BIAF022										  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas	 	  |
| Data:		| 08/06/15										  |
|-------------------------------------------------------------|
| Desc.:	| Rotina para controle de parcelas de contrato via|
| 			| pedidos de venda 								  |
|-------------------------------------------------------------|
| OS:	    | XXXX-XX - Usuário: Vagner Amaro   		 	  |
|-------------------------------------------------------------|
*/

User Function BIAF022()
	Local aArea			:= GetArea()				//Salva a area anterior
	Local aHeadAnt		:= aClone(aHeader)			//Salva o aHeader
	Local aColsAnt		:= aClone(aCols)			//Salva o aCols
	Local nAnt 			:= n
	Local nLinha
	Private cParcela	:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
	Private nNumParc 	:= GetMv("MV_NUMPARC", .F., 12)
	Private OK
	Private oDlgParc
	Private aColsEx 	:= {}
	Private aFieldFill 	:= {}
	Private aFields 	:= {"L4_VALOR","L4_DATA"}
	Private aAlterFields := {}
	Private aHeaderEx 	:= {}
	Private nVlrTotPed 	:= U_fValPed(.F.,.T.) //Considera Saldo Pedido / Atualiza Impostos  //U_VLTOTPED(M->C5_NUM,.F.)
	Private oMSNewGetDados1
	Private ap_Esc 		:= .F.

	If Alltrim(M->C5_YFORMA) <> "4"
		MsgBox('Este Pedido não permite a inclusão de Parcelas para Contrato. Favor rever as informações no Pedido.','Parcelas Contrato - BIAF022','STOP')
		Return
	EndIf

	If INCLUI .Or. ALTERA
		aAlterFields:= {"L4_VALOR","L4_DATA"}
	EndIf

	// Regra não utilzada pela Vitcer
	If cEmpAnt <> "14"
		If !VerQtdPed(aHeadAnt, aColsAnt)
			Return()
		EndIf		
	EndIf

	aHeader := {}
	aCols := {}

	aHeader := fHeader()
	aColsEx := fGetAcols()

	If Len(aColsEx) > 0	

		For nLinha := 1 To Len(aColsEx)

			aAdd(aCols, {0, cToD(""), .F.})

			aCols[nLinha][1] := aColsEx[nLinha][1]  //Valor
			aCols[nLinha][2] := aColsEx[nLinha][2]  //Data
			aCols[nLinha][3] := .F.

		Next

	EndIf


	DEFINE MSDIALOG oDlgParc FROM 10,20 TO 200,450 TITLE "Valor da Parcela e Vencimento" COLORS 0, 16777215 PIXEL

	oMSNewGetDados1 := MsNewGetDados():New(01, 02, 80, 215, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, nNumParc, "AllwaysTrue", "", "AllwaysTrue", oDlgParc, aHeader, aCols)							

	If INCLUI .Or. ALTERA
		@ 82,150 BUTTON OK PROMPT "Salvar" SIZE 065, 012 OF oDlgParc ACTION fSalvaParc() PIXEL
	Else
		@ 82,150 BUTTON OK PROMPT "Sair" SIZE 065, 012  OF oDlgParc  ACTION (ap_Esc := .T., oDlgParc:End())  PIXEL
	EndIf	

	ACTIVATE MSDIALOG oDlgParc VALID ap_Esc


	aHeader	:= aClone(aHeadAnt)
	aCols := aClone(aColsAnt)
	n	:= nAnt
	RestArea(aArea)

Return()


Static Function fGetAcols()
	Local aAcolAux 	:= {}
	Local cCampoData:= ""
	Local cCampoVal	:= ""
	Local nCount	:= 0

	DbSelectArea("Z60")
	DbSetOrder(1)
	Z60->(DbSeek(xFilial("Z60") + M->C5_NUM))

	For nCount := 1 To nNumParc

		cCampoVal := "Z60_PARC" +Subs(cParcela,nCount,1)
		cCampoData := "Z60_DATA" +Subs(cParcela,nCount,1)

		If !Empty(Z60->&(cCampoData)) .And. !Empty(Z60->&(cCampoVal))
			aAdd(aAcolAux, {Z60->&(cCampoVal) , Z60->&(cCampoData)} )
		EndIf

	Next

Return aAcolAux



Static Function fHeader()
	Local aHeaderAxu := {}

	AADD(aHeaderAxu,{	"Valor da Parcela",;					//01 - X3TITULO()            //"Valor da Parcela"
	"L4_VALOR",;							//02 - X3_CAMPO
	PesqPict("SL4","L4_VALOR"),;   			//03 - X3_PICTURE
	TamSX3("L4_VALOR")[1]     ,;			//04 - X3_TAMANHO
	TamSX3("L4_VALOR")[2]     ,;			//05 - X3_DECIMAL
	"Positivo()",;							//06 - X3_VALID
	"???????????????",;						//07 - X3_USADO
	"N",;									//08 - X3_TIPO
	"",;									//09 - X3_ARQUIVO
	"" 	} )

	AADD(aHeaderAxu,{	"Data",;												//01 - X3TITULO()		//"Data"
	"L4_DATA",;												//02 - X3_CAMPO
	"",;													//03 - X3_PICTURE
	8,;														//04 - X3_TAMANHO
	0,;														//05 - X3_DECIMAL
	"NaoVazio()",;											//06 - X3_VALID
	"???????????????",;										//07 - X3_USADO
	"D",;													//08 - X3_TIPO
	"",;													//09 - X3_ARQUIVO
	"" 	} )													//10 - X3_CONTEXT

Return aHeaderAxu



Static Function fVldParcela(pNumParc)
	Local lRet := .T.
	Local nCount := 1
	Local nMinParc := GetMv("MV_YVRPARM", .F., 4000)
	Local aColsParc := aClone(oMSNewGetDados1:aCols)
	Local nVlrTotPar := 0

	// Ordena array por data
	Asort(aColsParc,,, {|x, y| x[2] < y[2] })

	While nCount <= Len(aColsParc) .And. lRet

		// Item não deletado
		If !aColsParc[nCount][3]

			// Verificar o Valor
			If aColsParc[nCount][1] > 0

				// Regra não utilzada pela Vitcer					
				If cEmpAnt <> "14" .And. aColsParc[nCount][1] < nMinParc
					MsgBox('O Valor da Parcela não pode ser menor que '+cValToChar(nMinParc)+'!','Valor da Parcela','STOP')
					lRet := .F.
				Else
					nVlrTotPar += aColsParc[nCount][1]
				EndIf

			Else
				MsgBox('Favor informar um valor válido para a Parcela!','Valor Parcela','ALERT')
				lRet := .F.
			EndIf					

		EndIf

		nCount++

	EndDo


	If nVlrTotPar <> nVlrTotPed
		MsgBox('O Valor da Total das Parcelas está diferente do Valor Total do Pedido. Favor ajustar!', 'Parcelas Contrato', 'ALERT')
		lRet := .F.
	EndIf


	// Se o valor esteja valido, avalia data
	If lRet

		nCount := 1

		While nCount <= Len(aColsParc) .And. lRet

			// Item não deletado
			If !aColsParc[nCount][3]

				If nCount > 1		

					// Data da parcela anterior
					If aColsParc[nCount-1][2] <> Nil

						// Verifica se a data da parcela é menor ou igual a da parcela anterior
						If aColsParc[nCount][2] <= aColsParc[nCount-1][2]
							MsgBox('A Data da Parcela não pode ser Menor ou Igual da Parcela Anterior!','Data da Parcela','STOP')
							lRet := .F.
						EndIf

					EndIf

				EndIf

			EndIf

			nCount++

		EndDo

	EndIf

Return(lRet)



Static Function fSalvaParc()
	Local nCount := 0
	Local nPos := 0
	Local aColsParc := aClone(oMSNewGetDados1:aCols)
	Local aItDel := {}

	// Valida valor e data das parcelas
	If fVldParcela()

		DbSelectArea("Z60")
		DbSetOrder(1)
		lExist := Z60->(DbSeek(xFilial("Z60") + M->C5_NUM))

		// Limpa campos caso registro ja exista
		If lExist

			RecLock("Z60", .F.)

			Z60->Z60_PARC1 := 0
			Z60->Z60_DATA1 := cToD("")
			Z60->Z60_PARC2 := 0
			Z60->Z60_DATA2 := cToD("")
			Z60->Z60_PARC3 := 0
			Z60->Z60_DATA3 := cToD("")
			Z60->Z60_PARC4 := 0
			Z60->Z60_DATA4 := cToD("")
			Z60->Z60_PARC5 := 0
			Z60->Z60_DATA5 := cToD("")
			Z60->Z60_PARC6 := 0
			Z60->Z60_DATA6 := cToD("")
			Z60->Z60_PARC7 := 0
			Z60->Z60_DATA7 := cToD("")
			Z60->Z60_PARC8 := 0
			Z60->Z60_DATA8 := cToD("")
			Z60->Z60_PARC9 := 0
			Z60->Z60_DATA9 := cToD("")
			Z60->Z60_PARCA := 0
			Z60->Z60_DATAA := cToD("")
			Z60->Z60_PARCB := 0
			Z60->Z60_DATAB := cToD("")
			Z60->Z60_PARCC := 0
			Z60->Z60_DATAC := cToD("")

			If Z60->(FieldPos("Z60_CHVTMP")) > 0
				Z60->Z60_CHVTMP := ""
			EndIf				

			Z60->(MsUnlock())

		EndIf


		// Remove itens deletados do array	
		For nCount := 1 To Len(aColsParc)

			// Registro deletado
			If aColsParc[nCount][3]
				aAdd(aItDel, nCount)
			EndIf

		Next


		nCount := 0

		If Len(aItDel) > 0

			For nCount := 1 To Len(aItDel)
				aDel(aColsParc, aItDel[nCount])
				aSize(aColsParc, Len(aColsParc)-1)
			Next

		EndIf


		// Orden itens por data
		aSort(aColsParc,,, {|x, y| x[2] < y[2] })

		nCount := 0

		// Insere parcelas
		RecLock("Z60", !lExist)

		Z60->Z60_FILIAL := xFilial("Z60")
		Z60->Z60_NUMPED := M->C5_NUM

		If Z60->(FieldPos("Z60_CHVTMP")) > 0
			Z60->Z60_CHVTMP := M->C5_YCHVRES
		EndIf

		For nCount := 1 To Len(aColsParc)

			cCampoVal := "Z60_PARC" + SubStr(cParcela, nCount, 1)
			cCampoData := "Z60_DATA" + SubStr(cParcela, nCount, 1)

			Z60->&(cCampoVal) := aColsParc[nCount][1]
			Z60->&(cCampoData) := aColsParc[nCount][2]

		Next

		Z60->(MsUnlock())


		ap_Esc := .T.

		oDlgParc:End()

	EndIf

Return(.T.)


//------------------------------------------------------------------------------------
Static Function VerQtdPed(aHeaderPed, aColsPed)
	Local lRet := .T.
	Local aArea	:= GetArea()
	Local nQtdMin := GetMv("MV_YQTDMIN", .F., 2000) // Quantidade minima de contrato.
	Local nQtdPed := 0
	Local nLine

	For nLine := 1 To Len(aColsPed)

		If !GdDeleted(nLine, aHeaderPed, aColsPed)

			nQtdPed += GdFieldGet("C6_QTDVEN", nLine, .F., aHeaderPed, aColsPed)

		EndIf

	Next

	If nQtdPed < nQtdMin //.And. lPedTp9
		MsgBox('O Pedido não possui a Quantidade Mínima de '+ cValToChar(nQtdMin) +'m² para essa Condição de Pagamento!', 'Parcelas Contrato','ALERT')
		lRet := .F.
	EndIf

	RestArea(aArea)

Return(lRet)