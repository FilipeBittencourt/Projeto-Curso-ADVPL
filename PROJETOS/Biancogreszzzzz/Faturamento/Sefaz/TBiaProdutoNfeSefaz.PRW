#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0044; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaProdutoNfeSefaz															|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de produtos    |
| 				| da nota fiscal eletrônica 											|
|-----------------------------------------------------------|
*/


// Indices do array de produtos
#DEFINE IDX_Item 1
#DEFINE IDX_CodPrd 2
#DEFINE IDX_CodBar 3
#DEFINE IDX_DscPrd 4
#DEFINE IDX_Ncm 5
#DEFINE IDX_ExNcm 6
#DEFINE IDX_Cfop 7
#DEFINE IDX_UM 8
#DEFINE IDX_Quant 9
#DEFINE IDX_Total 10
#DEFINE IDX_UmDipi 11
#DEFINE IDX_ConvDip 12
#DEFINE IDX_Frete 13
#DEFINE IDX_Seguro 14
#DEFINE IDX_Desc 15
#DEFINE IDX_PrcUnt 16
#DEFINE IDX_CodSimp 17
#DEFINE IDX_CodIf 18
#DEFINE IDX_Lote 19
#DEFINE IDX_NumLote 20
#DEFINE IDX_OutDesp 21
#DEFINE IDX_RedBc 22
#DEFINE IDX_Cst 23
#DEFINE IDX_TipOpe 24
#DEFINE IDX_InfAdic 25
#DEFINE IDX_DescZf 26
#DEFINE IDX_Tes 27
#DEFINE IDX_ProtCon 28
#DEFINE IDX_DescIcm 29
#DEFINE IDX_TotImp 30
#DEFINE IDX_DescZfp 31
#DEFINE IDX_DescZfc 32
#DEFINE IDX_Picm 33
#DEFINE IDX_TribMun 34
#DEFINE IDX_TotFed 35
#DEFINE IDX_TotEst 36
#DEFINE IDX_TotMun 37


// Classe de interface
Class TIProdutoNfeSefaz From LongClassName
		
	Data nItem
	Data cCodPrd
	Data cCodBar
	Data cDscPrd
	Data cNcm
	Data cExNcm
	Data cCfop
	Data cUM
	Data nQuant
	Data nTotal
	Data cUmDipi
	Data cConvDip
	Data nFrete
	Data nSeguro
	Data nDesc
	Data nPrcUnt
	Data cCodSimp
	Data cCodIf
	Data cLote
	Data cNumLote
	Data nOutDesp
	Data nRedBc
	Data cCst
	Data cTipOpe
	Data cInfAdic
	Data nDescZf
	Data cTes
	Data cProtCon
	Data nDescIcm
	Data nTotImp
	Data nDescZfp
	Data nDescZfc
	Data nPicm
	Data nTribMun
	Data nTotFed
	Data nTotEst
	Data nTotMun	
			
	Method New() Constructor
	
EndClass


Method New() Class TIProdutoNfeSefaz

Return()



Class TBiaProdutoNfeSefaz From LongClassName	
	
	Data aProduto
	
	Data oLst
	
	Data oInfoItem // Informacoes do item 
				
	Method New(aParam, aParam2) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam, aParam2) Class TBiaProdutoNfeSefaz
	               
	::aProduto := aClone(aParam)
	
	::oLst := ArrayList():New()
	
	::oInfoItem := TBiaInfoItemNfeSefaz():New(aParam2)
	
	::Get()
	
Return()


Method Get() Class TBiaProdutoNfeSefaz
Local nCount := 0
Local oObj := Nil	

	If Len(::aProduto) > 0
	
		For nCount := 1 To Len(::aProduto)
		
			oObj := TIProdutoNfeSefaz():New()
	
			oObj:nItem := ::aProduto[nCount, IDX_Item]
			oObj:cCodPrd := ::aProduto[nCount, IDX_CodPrd]
			oObj:cCodBar := ::aProduto[nCount, IDX_CodBar]
			oObj:cDscPrd := ::aProduto[nCount, IDX_DscPrd]
			oObj:cNcm := ::aProduto[nCount, IDX_Ncm]
			oObj:cExNcm := ::aProduto[nCount, IDX_ExNcm]
			oObj:cCfop := ::aProduto[nCount, IDX_Cfop]
			oObj:cUM := ::aProduto[nCount, IDX_UM]
			oObj:nQuant := ::aProduto[nCount, IDX_Quant]
			oObj:nTotal := ::aProduto[nCount, IDX_Total]
			oObj:cUmDipi := ::aProduto[nCount, IDX_UmDipi]
			oObj:cConvDip := ::aProduto[nCount, IDX_ConvDip]
			oObj:nFrete := ::aProduto[nCount, IDX_Frete]
			oObj:nSeguro := ::aProduto[nCount, IDX_Seguro]
			oObj:nDesc := ::aProduto[nCount, IDX_Desc]
			oObj:nPrcUnt := ::aProduto[nCount, IDX_PrcUnt]
			oObj:cCodSimp := ::aProduto[nCount, IDX_CodSimp]
			oObj:cCodIf := ::aProduto[nCount, IDX_CodIf]
			oObj:cLote := ::aProduto[nCount, IDX_Lote]
			oObj:cNumLote := ::aProduto[nCount, IDX_NumLote]
			oObj:nOutDesp := ::aProduto[nCount, IDX_OutDesp]
			oObj:nRedBc := ::aProduto[nCount, IDX_RedBc]
			oObj:cCst := ::aProduto[nCount, IDX_Cst]
			oObj:cTipOpe := ::aProduto[nCount, IDX_TipOpe]
			oObj:cInfAdic := ::aProduto[nCount, IDX_InfAdic]
			oObj:nDescZf := ::aProduto[nCount, IDX_DescZf]
			oObj:cTes := ::aProduto[nCount, IDX_Tes]
			oObj:cProtCon := ::aProduto[nCount, IDX_ProtCon]
			oObj:nDescIcm := ::aProduto[nCount, IDX_DescIcm]
			oObj:nTotImp := ::aProduto[nCount, IDX_TotImp]
			oObj:nDescZfp := ::aProduto[nCount, IDX_DescZfp]
			oObj:nDescZfc := ::aProduto[nCount, IDX_DescZfc]
			oObj:nPicm := ::aProduto[nCount, IDX_Picm]
			oObj:nTribMun := ::aProduto[nCount, IDX_TribMun]
			oObj:nTotFed := ::aProduto[nCount, IDX_TotFed]
			oObj:nTotEst := ::aProduto[nCount, IDX_TotEst]
			oObj:nTotMun := ::aProduto[nCount, IDX_TotMun]
			
			::oLst:Add(oObj)
			
		Next
		
	EndIf
	
Return()


Method Set() Class TBiaProdutoNfeSefaz
Local nCount := 0

	If Len(::aProduto) > 0
		
		For nCount := 1 To ::oLst:GetCount()
		
			::aProduto[nCount, IDX_Item] := ::oLst:GetItem(nCount):nItem
			::aProduto[nCount, IDX_CodPrd] := ::oLst:GetItem(nCount):cCodPrd
			::aProduto[nCount, IDX_CodBar] := ::oLst:GetItem(nCount):cCodBar 
			::aProduto[nCount, IDX_DscPrd] := ::oLst:GetItem(nCount):cDscPrd
			::aProduto[nCount, IDX_Ncm] := ::oLst:GetItem(nCount):cNcm
			::aProduto[nCount, IDX_ExNcm] := ::oLst:GetItem(nCount):cExNcm
			::aProduto[nCount, IDX_Cfop] := ::oLst:GetItem(nCount):cCfop
			::aProduto[nCount, IDX_UM] := ::oLst:GetItem(nCount):cUM
			::aProduto[nCount, IDX_Quant] := ::oLst:GetItem(nCount):nQuant
			::aProduto[nCount, IDX_Total] := ::oLst:GetItem(nCount):nTotal
			::aProduto[nCount, IDX_UmDipi] := ::oLst:GetItem(nCount):cUmDipi
			::aProduto[nCount, IDX_ConvDip] := ::oLst:GetItem(nCount):cConvDip
			::aProduto[nCount, IDX_Frete] := ::oLst:GetItem(nCount):nFrete
			::aProduto[nCount, IDX_Seguro] := ::oLst:GetItem(nCount):nSeguro
			::aProduto[nCount, IDX_Desc] := ::oLst:GetItem(nCount):nDesc
			::aProduto[nCount, IDX_PrcUnt] := ::oLst:GetItem(nCount):nPrcUnt
			::aProduto[nCount, IDX_CodSimp] := ::oLst:GetItem(nCount):cCodSimp
			::aProduto[nCount, IDX_CodIf] := ::oLst:GetItem(nCount):cCodIf
			::aProduto[nCount, IDX_Lote] := ::oLst:GetItem(nCount):cLote
			::aProduto[nCount, IDX_NumLote] := ::oLst:GetItem(nCount):cNumLote
			::aProduto[nCount, IDX_OutDesp] := ::oLst:GetItem(nCount):nOutDesp
			::aProduto[nCount, IDX_RedBc] := ::oLst:GetItem(nCount):nRedBc
			::aProduto[nCount, IDX_Cst] := ::oLst:GetItem(nCount):cCst
			::aProduto[nCount, IDX_TipOpe] := ::oLst:GetItem(nCount):cTipOpe
			::aProduto[nCount, IDX_InfAdic] := ::oLst:GetItem(nCount):cInfAdic
			::aProduto[nCount, IDX_DescZf] := ::oLst:GetItem(nCount):nDescZf
			::aProduto[nCount, IDX_Tes] := ::oLst:GetItem(nCount):cTes
			::aProduto[nCount, IDX_ProtCon] := ::oLst:GetItem(nCount):cProtCon
			::aProduto[nCount, IDX_DescIcm] := ::oLst:GetItem(nCount):nDescIcm
			::aProduto[nCount, IDX_TotImp] := ::oLst:GetItem(nCount):nTotImp
			::aProduto[nCount, IDX_DescZfp] := ::oLst:GetItem(nCount):nDescZfp
			::aProduto[nCount, IDX_DescZfc] := ::oLst:GetItem(nCount):nDescZfc
			::aProduto[nCount, IDX_Picm] := ::oLst:GetItem(nCount):nPicm
			::aProduto[nCount, IDX_TribMun] := ::oLst:GetItem(nCount):nTribMun
			::aProduto[nCount, IDX_TotFed] := ::oLst:GetItem(nCount):nTotFed
			::aProduto[nCount, IDX_TotEst] := ::oLst:GetItem(nCount):nTotEst
			::aProduto[nCount, IDX_TotMun] := ::oLst:GetItem(nCount):nTotMun

		Next
	
	EndIf	

Return()


Method Update() Class TBiaProdutoNfeSefaz
Local aArea := GetArea()
Local nCount := 0
Local cLote := ""
Local cSQL := ""
Local cSD1 := RetSQLName("SD1")
Local cQry := GetNextAlias()

	
	If SFT->FT_TIPOMOV == "S"
			
		For nCount := 1 To ::oInfoItem:oLst:GetCount()
		
			DbSelectArea("SD2")
			DbSetOrder(3)
			If SD2->(DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + ::oLst:GetItem(nCount):cCodPrd + ::oInfoItem:oLst:GetItem(nCount):cItNf))

				DbSelectArea("SB1")
				DbSetOrder(1)
				If SB1->(DbSeek(xFilial("SB1") + ::oLst:GetItem(nCount):cCodPrd))
				
					If SB1->B1_YCLASSE $ "1_2_3" .And. SD2->D2_YIMPNF == "D" .And. cEmpAnt == "05"
						::oLst:GetItem(nCount):cCodPrd := SubStr(SD2->D2_COD,1,7) + "3"
					EndIf

					If SubStr(SD2->D2_COD,1,1) >= "A"
					
						If cEmpAnt == "05" .And. SD2->D2_YIMPNF == "D"
							cLote := ""
						Else
							cLote := " - Lote " + Alltrim(SD2->D2_LOTECTL)
						EndIf
						
					Else 
						cLote := ""
					EndIf                 
					
					DbSelectArea("SC6")
					DbSetOrder(1)
					If SC6->(DbSeek(xFilial("SC6") + ::oInfoItem:oLst:GetItem(nCount):cNumPed + ::oInfoItem:oLst:GetItem(nCount):cItPed + ::oLst:GetItem(nCount):cCodPrd))
						
						//Thiago Haagensen - Ticket 27566 - Validação pedido pela Fabiana Corona para pegar descrição de produtos PA.
						lValida := .F.
						
						If SB1->B1_TIPO == "PA"
							::oLst:GetItem(nCount):cDscPrd := (Alltrim(SC6->C6_DESCRI) + cLote)	
							lValida := .T.
						Endif
						
						If SB1->B1_TIPO <> "PA"
						//250 CARACETERS - 40 CARACTERES - Tratativa para buscar os 40 caracteres do B1_DESC
							If SUBSTR(ALLTRIM(SB1->B1_DESC),1,40) <> Alltrim(SC6->C6_DESCRI)
								::oLst:GetItem(nCount):cDscPrd := (Alltrim(SC6->C6_DESCRI) + cLote)	
								lValida := .T.
							Endif
						Endif
						
						If !lValida
							::oLst:GetItem(nCount):cDscPrd := SUBSTR(Alltrim(SB1->B1_DESC) + cLote,1,120)						
						Endif
						
						/*If Empty(SC6->C6_DESCRI)
							::oLst:GetItem(nCount):cDscPrd := SUBSTR(Alltrim(SB1->B1_DESC) + cLote,1,120) //250 caravteres + lote
						Else					
							::oLst:GetItem(nCount):cDscPrd := SUBSTR(Alltrim(SC6->C6_DESCRI) + cLote,1,120) // 40 caracteres + loteele ta caindo aqui.. incompleto!
						EndIf*/
						
					EndIf
																			
				EndIf
				
				
				If !SD2->D2_TIPO $ "IP"
					::oLst:GetItem(nCount):nTotal := SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR
				Else
					::oLst:GetItem(nCount):nTotal := 0
				EndIf
			
			EndIf
			
		Next
		
	
	ElseIf SFT->FT_TIPOMOV == "E"
	
			For nCount := 1 To ::oInfoItem:oLst:GetCount()
			
				cSQL := " SELECT CONVERT(VARCHAR(500),CONVERT(BINARY(500),D1_YDESIMP)) AS D1_YDESIMP "
				cSQL += " FROM "+ cSD1
				cSQL += " WHERE D1_FILIAL = "+ ValToSQL(SF1->F1_FILIAL)
				cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)
				cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
				cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
				cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
				cSQL += " AND D1_FORMUL = 'S' "
				cSQL += " AND D1_COD = "+ ValToSQL(::oLst:GetItem(nCount):cCodPrd)
				cSQL += " AND D1_ITEM = "+ ValToSQL(::oInfoItem:oLst:GetItem(nCount):cItNf)
				cSQL += " AND D_E_L_E_T_ = '' "
				cSQL += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD "			
			
				TcQuery cSQL New Alias (cQry)
				
				If Empty(Alltrim((cQry)->D1_YDESIMP))
					
					DbSelectArea("SB1")
					DbSetOrder(1)
					If SB1->(DbSeek(xFilial("SB1") + ::oLst:GetItem(nCount):cCodPrd))
						::oLst:GetItem(nCount):cDscPrd := Alltrim(SB1->B1_DESC)
					EndIf
					
				Else
					::oLst:GetItem(nCount):cDscPrd := Alltrim((cQry)->D1_YDESIMP)
				EndIf
				
				(cQry)->(DbCloseArea())
				
			Next
					
	
	EndIf
	
	
	For nCount := 1 To ::oInfoItem:oLst:GetCount()				    

		//Retira caracteres especiais - Problema na NF 4.0
		::oLst:GetItem(nCount):cDscPrd := U_fDelTab(::oLst:GetItem(nCount):cDscPrd)
		
	Next
       					
	::Set()
		
	RestArea(aArea)
			
Return(::aProduto)