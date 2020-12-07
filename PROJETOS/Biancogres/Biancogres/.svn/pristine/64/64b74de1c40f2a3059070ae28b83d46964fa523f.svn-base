#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPDMWProdMarca
@description Classe para a tela de cadastro de Produtos x Marcas
@author Fernando Rocha
@since 07/08/2018
@version 1.0
@type class
/*/

//ESTADOS DO MODELO
#DEFINE _UNCHANGED 0
#DEFINE _NEW 1
#DEFINE _UPDATE 2
#DEFINE _DELETE 3

// IDENTIFICADORES DE LINHA
#DEFINE LIN_TOP "LIN_TOP"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_TOP 85

// IDENTIFICADORES DE COLUNA
#DEFINE COL_TOP "COL_TOP"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL_LEFT 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_TOP "WND_TOP"

#DEFINE TIT_MAIN_WND "PDM - Marcas do Produto"
#DEFINE TIT_WND_TOP "PDM - Marcas do Produto"

#DEFINE TIT_MSG "PDM"


Class TPDMWProdMarca From LongClassName

Data oDlg
Data oLayer 
Data oPanelTop

Data oFontLbl

Data oHeadMarca
Data aHeadMarca
Data aColsMarca
Data aAltMarca
Data oBrwMarca

Data cProduto  //codigo produto
Data OpAltera

//posicoes colunas
Data nP1_Codigo
Data nP1_Descricao
Data nP1_Referencia
Data nP1_InfAdicional

Method New() Constructor

Method Show()
Method LoadDialog()
Method LoadLayer()
Method LayerTop()

Method SetH()
Method LoadMarcas()
Method CanEditCell()
Method LinhaOk()

Method Salvar()

EndClass


Method New() Class TPDMWProdMarca	

	::oDlg 				:= Nil
	::oLayer 			:= Nil
	::oPanelTop 		:= Nil

	::oFontLbl 			:= TFont():New("Calibri",,010,,.T.)

	::oHeadMarca				:= TGDField():New()
	::aColsMarca				:= {}	
	::aHeadMarca				:= {}
	::aAltMarca				:= {}

	::oBrwMarca				:= Nil

	::nP1_Codigo		:= 0
	::nP1_Descricao		:= 0
	::nP1_Referencia	:= 0
	::nP1_InfAdicional	:= 0

	::cProduto			:= M->B1_COD
	::OpAltera			:= .F.

Return Self

Method Show() Class TPDMWProdMarca	

	::LoadDialog()

	::LoadLayer()

	aButtons := {}

	EnchoiceBar(::oDlg, {|| IIf(::Salvar(), ::oDlg:End(),) }, {|| ::oDlg:End()}, , aButtons)

	::oDlg:Activate()

Return


Method LoadDialog() Class TPDMWProdMarca

	::oDlg := MsDialog():New(0, 0, 450, 600, TIT_MAIN_WND,,,,,,,,oMainWnd,.T.)
	::oDlg:cName := "oDlgPMarca"
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T. 

Return()


Method LoadLayer() Class TPDMWProdMarca

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN_TOP, PER_LIN_TOP, .F.)

	::LayerTop()

Return() 

Method LayerTop() Class TPDMWProdMarca 

	Local cLinhaOk 	:= "Allwaystrue"
	Local cTudoOk  	:= "Allwaystrue"
	Local cFieldOk 	:= "Allwaystrue"
	Local cDelOk   	:= "Allwaystrue"
	Local cIniCpos 	:= ""
	Local nOper		:= GD_INSERT + GD_UPDATE + GD_DELETE

	If !(::OpAltera)
		nOper := 0
	EndIf

	::oLayer:AddCollumn(COL_TOP, PER_COL_LEFT, .T., LIN_TOP)	

	::oLayer:AddWindow(COL_TOP, WND_TOP, TIT_WND_TOP, 100, .F. ,.T.,, LIN_TOP, { || })

	::oPanelTop := ::oLayer:GetWinPanel(COL_TOP, WND_TOP, LIN_TOP)

	::aHeadMarca := ::SetH()	 

	::LoadMarcas()

	::oBrwMarca := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltMarca,,99,cFieldOk, "", cDelOk, ::oPanelTop, ::aHeadMarca, ::aColsMarca)

	::oBrwMarca:bLinhaOk 			:= {|| ::LinhaOk() }
	::oBrwMarca:oBrowse:bldblclick 	:= {|| IIF(::CanEditCell(),::oBrwMarca:EditCell(),) }

	::oBrwMarca:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT	
	::oBrwMarca:oBrowse:lHScroll 	:= .F.	
	::oBrwMarca:oBrowse:lVScroll 	:= .T.

	::oBrwMarca:oBrowse:lUseDefaultColors := .F.

Return()


Method SetH()  Class TPDMWProdMarca

	::oHeadMarca:Clear()

	::oHeadMarca:AddField("ZD6_CODMAR")	
	::oHeadMarca:AddField("ZD6_MARCA")
	::oHeadMarca:AddField("ZD6_REFER")
	::oHeadMarca:AddField("ZD6_INFADI")

	//Posicoes conforme acima
	::nP1_Codigo		:= 1
	::nP1_Descricao		:= 2
	::nP1_Referencia	:= 3
	::nP1_InfAdicional	:= 4

	//Campos editaveis
	::aAltMarca := {"ZD6_CODMAR","ZD6_REFER","ZD6_INFADI"}

Return(::oHeadMarca:GetHeader())


Method LoadMarcas() Class TPDMWProdMarca

	Local I
	Local aAux

	::aColsMarca := {}

	ZD6->(DbSetOrder(1))

	If ZD6->(DbSeek(XFilial("ZD6")+::cProduto))

		While !ZD6->(Eof()) .And. ZD6->(ZD6_FILIAL+ZD6_COD) == (XFilial("ZD6")+::cProduto)

			aAux := {}
			AAdd(aAux, ZD6->ZD6_CODMAR )
			AAdd(aAux, ZD6->ZD6_MARCA )
			AAdd(aAux, ZD6->ZD6_REFER )
			AAdd(aAux, ZD6->ZD6_INFADI )
			AAdd(aAux, .F.)

			aAdd(::aColsMarca, aAux)

			ZD6->(DbSkip())
		EndDo

	Else

		aAux := {}
		AAdd(aAux, CriaVar("ZD6_CODMAR") )
		AAdd(aAux, CriaVar("ZD6_MARCA") )
		AAdd(aAux, CriaVar("ZD6_REFER") )
		AAdd(aAux, CriaVar("ZD6_INFADI") )
		AAdd(aAux, .F.)

		aAdd(::aColsMarca, aAux)

	EndIf

Return


Method CanEditCell() Class TPDMWProdMarca

	Local lRet		:= .T.
	Local nLin 		:= ::oBrwMarca:nAT
	Local nCol 		:= ::oBrwMarca:oBrowse:nColPos

	If nLin <= Len(::aColsMarca) .And. nCol < 4 .And. ! Empty(::aColsMarca[::oBrwMarca:nAT][::nP1_Codigo])

		MsgAlert("Não pode alterar Marcar/Referências. Delete e inclua nova linha.","TPDMWProdMarca - Marcas X Produtos.")

		lRet := .F.

	EndIf

Return(lRet)


Method LinhaOk() Class TPDMWProdMarca

	Local lRet		:= .T.
	Local nLin 		:= ::oBrwMarca:nAT
	Local nx

	For nx := 1 To Len(::oBrwMarca:aCols)	

		If ( nx <> nLin ) .And. ( ::oBrwMarca:aCols[nLin][::nP1_Codigo] == ::oBrwMarca:aCols[nx][::nP1_Codigo] ) .And. ( ::oBrwMarca:aCols[nLin][::nP1_Referencia] == ::oBrwMarca:aCols[nx][::nP1_Referencia] )

			MsgAlert("Marca/Referência já adicionada.","TPDMWProdMarca - Marcas X Produtos.")

			lRet := .F.
			
			exit

		EndIf

	Next nx

Return(lRet)


Method Salvar() Class TPDMWProdMarca

	Local lRet := .T.
	Local nx
	Local oPrdMarca
	
	If (!::oBrwMarca:TudoOk())
	
		Return(.F.)
		
	EndIf

	For nx := 1 To Len(::oBrwMarca:aCols)	

		oPrdMarca := TPDMProdutoMarca():Get(::cProduto, ::oBrwMarca:aCols[nx][::nP1_Codigo], ::oBrwMarca:aCols[nx][::nP1_Referencia])

		If !(::oBrwMarca:aCols[nx][Len(::oBrwMarca:aHeader)+1])

			If Empty(oPrdMarca:Produto)

				oPrdMarca := TPDMProdutoMarca():New()

				oPrdMarca:Filial 		:= XFilial("ZD6")
				oPrdMarca:Produto 		:= ::cProduto
				oPrdMarca:CodMarca		:= ::oBrwMarca:aCols[nx][::nP1_Codigo]
				oPrdMarca:Marca			:= ::oBrwMarca:aCols[nx][::nP1_Descricao]
				oPrdMarca:Referencia 	:= ::oBrwMarca:aCols[nx][::nP1_Referencia]

			EndIf

			oPrdMarca:InfAdicional 	:= ::oBrwMarca:aCols[nx][::nP1_InfAdicional]

			oPrdMarca:Save()

			oPrdMarca := Nil

		Else

			If !Empty(oPrdMarca:Produto)

				oPrdMarca:DbState := _DELETE
				oPrdMarca:Save()

			EndIf

			oPrdMarca := Nil

		EndIf

	Next nx

Return(lRet)