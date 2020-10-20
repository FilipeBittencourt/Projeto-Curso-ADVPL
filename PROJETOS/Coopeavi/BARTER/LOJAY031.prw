#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.ch" 
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
//------------------------------------------------------------------------
/*/{Protheus.doc} LOJAY031
@description Consulta padrão de produtos com campo auxiliar de observação B5_YOBS.
@author Fabio Junior Braga
@since 02.08.2017
@version 1.0
/*/
//------------------------------------------------------------------------

User Function LOJAY031(_cCodigo)

	Local aArea			:= GetArea()
	Local aPos			:= {}
	//Local cRetorno		:= ""
	//Local cVar	  		:= ReadVar()
	Local cPesquisa 	:= Space(100)
	Local lRetorno 		:= .F.
	Local aProdutos		:= {}

	Static  oGet2
	Static  oGet3
	Static  oGet4

	Static  cGet2			:= ""
	Static  cGet3			:= ""
	Static  cGet4			:= ""

	// Browse 1
	Private nPosLogi	:= 1
	Private nPosB1Leg	:= 2
	Private nPosB1Prod	:= 3 // Codigo do produto
	Private nPosB1Desc	:= 4 // Descricao do produto
	Private nPosB1Prec	:= 5 // Preco do produto
	Private nPosB1Est	:= 6 // Estoque do produto
	Private nPosB1Agr	:= 7 // Codigo do Agrupador



	Private acols2 		:= LOJAY31A(_cCodigo)

	Private oLbOk    	:= LoadBitmap(GetResources(), "LBOK")
	Private oLbNo    	:= LoadBitmap(GetResources(), "LBNO")


	Private cOrdenar	:= "C"
	Private nOrdenar	:= 0
	Private lOrdenar	:= .T.
	Private _oBrowse	:= NIL


	Private oFont 		:= TFont():New('Courier new',,-12,.T.)
	Private cCadastro	:= "Cadastro de Produtos"



	//---------------------------------------------------------------------------
	//Definicao do Dialog e todos os seus componentes.                        
	//---------------------------------------------------------------------------
	SetPrvt("oDlg","oBtn1","oBtn2","oBtn3","oGet1","oBtn5")
	SetPrvt("oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10","oSay11","oSay17","oSay18","oSay19")
	SetPrvt("oSBox1","oSBox2","oSBox3","oSBox4","oSBox5","oSBox7","oSBox8","oSBox9")
	//SetPrvt("oGet2, oGet3, oGet4")
	//SetPrvt("cGet2, cGet3, cGet4")

	If !Empty(acols2)
	
		oDlg       := MSDialog():New( 000,000,410,534,"Produtos Sugeridos",,,.F.,,,,,,.T.,,,.T. )
	
		oBtn4      := TButton():New( 188,175,"Cancelar",oDlg,{|| oDlg:End() },037,012,,,,.T.,,"",,,,.F. )	
		oBtn5      := TButton():New( 188,220,"Confirmar",oDlg,{||lRetorno := .T., oDlg:End()},037,012,,,,.T.,,"",,,,.F. )
	
		oSay2      := TSay():New( 010,010,{||"Produtos Sugeridos"},oDlg,,,.F.,.F.,.F.,.T.,,,060,008)
	
		// Monta Browse de seleção de produtos (consulta Padrão)
		_oBrowse := TCBrowse():New(020, 004, 265, 160,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.) //
	
		_oBrowse:SetArray(acols2)
		_oBrowse:AddColumn(TCColumn():New(" "		 , {|| IIf(_oBrowse:aArray[_oBrowse:nAt,01],oLbOk,oLbNo) },,,,,,.T.,.F.,,,,.F., ) )
		_oBrowse:AddColumn(TCColumn():New(" "        , {|| _oBrowse:aArray[_oBrowse:nAt, nPosB1Leg]},,,,,,.T.,.F.,,,,.F., ))
		_oBrowse:AddColumn(TCColumn():New("Codigo"	 , {|| _oBrowse:aArray[_oBrowse:nAt, nPosB1Prod]},,,,"LEFT",25,.F.,.F.,,,,.F.,))
		_oBrowse:AddColumn(TCColumn():New("Descricao", {|| _oBrowse:aArray[_oBrowse:nAt, nPosB1Desc]},,,,"LEFT",155,.F.,.F.,,,,.F.,))
		_oBrowse:AddColumn(TCColumn():New("Preco"	 , {|| _oBrowse:aArray[_oBrowse:nAt, nPosB1Prec]},,,,"RIGHT",35,.F.,.F.,,,,.F.,))
		_oBrowse:AddColumn(TCColumn():New("Estoque"	 , {|| _oBrowse:aArray[_oBrowse:nAt, nPosB1Est]	},,,,"RIGHT",25,.F.,.F.,,,,.F.,))
		_oBrowse:bLDblClick		:= { || _oBrowse:aArray[_oBrowse:nAt,01] := !_oBrowse:aArray[_oBrowse:nAt,01]}
		_oBrowse:lHScroll		:= .F.
	
	
		// Legendas
	
		oBmp1 := TBitmap():Create(oDlg)
		oBmp1:cResName 			:= "BR_AZUL"
		oBmp1:lAutoSize	 		:= .F.
		oBmp1:nLeft				:= 008
		oBmp1:nTop  			:= 380
		oBmp1:nHeight 			:= 015
		oBmp1:nWidth 			:= 015
	
		oSay6 					:= TSay():Create(oDlg)
		oSay6:cCaption 			:= "Básico"
		oSay6:nLeft 			:= 030
		oSay6:nTop 				:= 380
		oSay6:nWidth 			:= 060
		oSay6:nHeight 			:= 015
	
		oBmp2 := TBitmap():Create(oDlg)
		oBmp2:cResName 			:= "BR_VERDE"
		oBmp2:lAutoSize	 		:= .F.
		oBmp2:nLeft				:= 080
		oBmp2:nTop  			:= 380
		oBmp2:nHeight 			:= 015
		oBmp2:nWidth 			:= 015
	
		oSay7 					:= TSay():Create(oDlg)
		oSay7:cCaption 			:= "Estratégico"
		oSay7:nLeft 			:= 102
		oSay7:nTop 				:= 380
		oSay7:nWidth 			:= 060
		oSay7:nHeight 			:= 015
	
		oBmp3 := TBitmap():Create(oDlg)
		oBmp3:cResName 			:= "BR_BRANCO"
		oBmp3:lAutoSize	 		:= .F.
		oBmp3:nLeft				:= 172
		oBmp3:nTop  			:= 380
		oBmp3:nHeight 			:= 015
		oBmp3:nWidth 			:= 015
	
		oSay8 					:= TSay():Create(oDlg)
		oSay8:cCaption 			:= "Âncora"
		oSay8:nLeft 			:= 194
		oSay8:nTop 				:= 380
		oSay8:nWidth 			:= 060
		oSay8:nHeight 			:= 015
	
	
		oBmp4 := TBitmap():Create(oDlg)
		oBmp4:cResName 			:= "BR_VERMELHO"
		oBmp4:lAutoSize	 		:= .F.
		oBmp4:nLeft				:= 246
		oBmp4:nTop  			:= 380
		oBmp4:nHeight 			:= 015
		oBmp4:nWidth 			:= 015
	
		oSay9 					:= TSay():Create(oDlg)
		oSay9:cCaption 			:= "Lançamento"
		oSay9:nLeft 			:= 268
		oSay9:nTop 				:= 380
		oSay9:nWidth 			:= 060
		oSay9:nHeight 			:= 015
	
		//Desabilita as teclas de atalho.

		//Por questao de compatiblidade, utiliza sempre a rotina do VENDA ASSISTIDA.
		Lj7SetKeys(.F.)
	
		oDlg:Activate()
	
		//Habilita novamente as teclas de atalho.

		//Por questao de compatiblidade, utiliza sempre a rotina do VENDA ASSISTIDA.
		Lj7SetKeys(.T.)
	
		//&cVar := cRetorno
	
		If lRetorno
			aProdutos := LOJAY031B()
		Endif
	
		
	Endif

	RestArea(aArea)
	
Return aProdutos


//------------------------------------------------------------------------
/*/{Protheus.doc} LOJAY31A
@description Busca os produtos relacionados sugeridos para serem (ou não) selecionados na grid.
@author Alexandre Fortunato Ribeiro
@since 12.09.2018
@version 1.0
/*/
//------------------------------------------------------------------------

Static Function LOJAY31A(_cCodigo)

	Local aLinhas 	:= {}
	Local aRecnos 	:= {}
	//Local cQuery 	:= GetNextAlias()
	Local cQuery2 	:= GetNextAlias()
	Local cCodAgr	:= ""
	Local cRelacao	:= ""
	Local cQtvendas := ""

//-----------------------------	adicionar os produtos sugeridos e complementares
//	cRelacao := "5" //relação referente ao produtos sugeridos
	BeginSql ALIAS cQuery2
			SELECT
				ZCB.ZCB_CLAMIX,
				SB5_2.B5_COD,
				ZC8_TIPO
			FROM %TABLE:SB5% SB5_1			
			JOIN %TABLE:ZC8% ZC8   ON ZC8.ZC8_FILIAL = SB5_1.B5_FILIAL AND ZC8.ZC8_AGRU01 = SB5_1.B5_YCODAGR AND ZC8.%NOTDEL%
			JOIN %TABLE:SB5% SB5_2 ON SB5_2.B5_FILIAL = ZC8.ZC8_FILIAL AND SB5_2.B5_YCODAGR = ZC8.ZC8_AGRU02 AND SB5_2.%NOTDEL%
			JOIN %TABLE:ZCB% ZCB	ON ZCB.ZCB_CODIGO = SB5_2.B5_YCODAGR AND ZCB.%NOTDEL%
			WHERE SB5_1.%NOTDEL%
			  AND SB5_1.B5_COD 	= %Exp:_cCodigo%
			  AND (ZC8.ZC8_TIPO = '5' OR ZC8.ZC8_TIPO 	= '1')
		EndSql

	Do While (cQuery2)->(!Eof())

		SB1->(DbSetOrder(1))
		SB2->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1") + (cQuery2)->B5_COD))
	
			Aadd(aLinhas, Array(6))
			aLinhas[Len(aLinhas), nPosLogi] 	:= .F.
			cClamix := (cQuery2)->ZCB_CLAMIX			
			If cClamix == "4"
				aLinhas[Len(aLinhas), nPosB1Leg ] := "BR_VERMELHO"		
			ElseIf cClamix == "3"
				aLinhas[Len(aLinhas), nPosB1Leg ] := "BR_BRANCO"
			ElseIf cClamix == "2"
				aLinhas[Len(aLinhas), nPosB1Leg ] := "BR_VERDE"
			Else
				aLinhas[Len(aLinhas), nPosB1Leg ] := "BR_AZUL"
			EndIf
			
			aLinhas[Len(aLinhas), nPosB1Prod] 	:= AllTrim(SB1->B1_COD)
			aLinhas[Len(aLinhas), nPosB1Desc] 	:= AllTrim(SB1->B1_DESC)
			aLinhas[Len(aLinhas), nPosB1Prec] 	:= Transform(SB1->B1_PRV1, "@E 999,999,999.99")
			aLinhas[Len(aLinhas), nPosB1Est]	:= If (SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD)), SaldoSB2(), 0)
		EndIf

		(cQuery2)->(DbSkip())
	EndDo

	(cQuery2)->(DbCloseArea())
	

Return aLinhas




//------------------------------------------------------------------------
/*/{Protheus.doc} LOJAY031B
@description Monta o Array de produtos selecionados no checkbok.
@author Alexandre Fortunato Ribeiro
@since 12.09.2018
@version 1.0
/*/
//------------------------------------------------------------------------
Static Function LOJAY031B()
	Local aProdutos := {}
	Local nI		:= 1

	WHILE nI <= Len(acols2)
		If acols2[nI,nPosLogi]
			AAdd (aProdutos, acols2[nI,nPosB1Prod])
		Endif
		nI++
	Enddo

Return aProdutos


