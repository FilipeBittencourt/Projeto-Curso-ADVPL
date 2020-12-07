#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPDMWPdmProduto
@description Classe para a tela de cadastro de PDM x Produto
@author Wlysses Cerqueira (Facile)
@since 21/11/2018
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

#DEFINE TIT_MAIN_WND "PDM - PDM x Produto"
#DEFINE TIT_WND_TOP "PDM - PDM x Produto"

#DEFINE TIT_MSG "PDM"


Class TPDMWPdmProduto From LongClassName

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

	Method New() Constructor

	Method Show()
	Method LoadDialog()
	Method LoadLayer()
	Method LayerTop()

	Method SetH()
	Method LoadMarcas()

EndClass


Method New() Class TPDMWPdmProduto

	::oDlg 				:= Nil
	::oLayer 			:= Nil
	::oPanelTop 		:= Nil

	::oFontLbl 			:= TFont():New("Calibri",,010,,.T.)

	::oHeadMarca		:= TGDField():New()
	::aColsMarca		:= {}
	::aHeadMarca		:= {}
	::aAltMarca			:= {}

	::oBrwMarca			:= Nil

	::cProduto			:= M->B1_COD

Return Self

Method Show() Class TPDMWPdmProduto

	::LoadDialog()

	::LoadLayer()

	aButtons := {}

	EnchoiceBar(::oDlg, {|| ::oDlg:End() }, {|| ::oDlg:End()}, , aButtons)

	::oDlg:Activate()

Return


Method LoadDialog() Class TPDMWPdmProduto

	::oDlg := MsDialog():New(0, 0, 450, 1050, TIT_MAIN_WND,,,,,,,,oMainWnd,.T.)
	::oDlg:cName := "oDlgPMarca"
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.

Return()


Method LoadLayer() Class TPDMWPdmProduto

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN_TOP, PER_LIN_TOP, .F.)

	::LayerTop()

Return()

Method LayerTop() Class TPDMWPdmProduto

	Local cLinhaOk 	:= "Allwaystrue"
	Local cTudoOk  	:= "Allwaystrue"
	Local cFieldOk 	:= "Allwaystrue"
	Local cDelOk   	:= "Allwaystrue"
	Local cIniCpos 	:= ""
	Local nOper			:= 0

	::oLayer:AddCollumn(COL_TOP, PER_COL_LEFT, .T., LIN_TOP)

	::oLayer:AddWindow(COL_TOP, WND_TOP, TIT_WND_TOP, 100, .F. ,.T.,, LIN_TOP, { || })

	::oPanelTop := ::oLayer:GetWinPanel(COL_TOP, WND_TOP, LIN_TOP)

	::aHeadMarca := ::SetH()

	::LoadMarcas()

	::oBrwMarca := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltMarca,,99,cFieldOk, "", cDelOk, ::oPanelTop, ::aHeadMarca, ::aColsMarca)

	::oBrwMarca:bLinhaOk 			:= {|| ::LinhaOk() }
	//::oBrwMarca:oBrowse:bldblclick 	:= {|| ::oBrwMarca:EditCell(),) }

	::oBrwMarca:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
	::oBrwMarca:oBrowse:lHScroll 	:= .T.
	::oBrwMarca:oBrowse:lVScroll 	:= .T.

	::oBrwMarca:oBrowse:lUseDefaultColors := .F.

Return()


Method SetH()  Class TPDMWPdmProduto

	::oHeadMarca:Clear()

	::oHeadMarca:AddField("ZD7_PDM")
	::oHeadMarca:AddField("ZD7_SEQUEN")
	::oHeadMarca:AddField("ZD1_NOME")
	::oHeadMarca:AddField("ZD7_ITEM")
	//::oHeadMarca:AddField("ZD7_REV")	
	//::oHeadMarca:AddField("ZD7_PRODUT")				
	::oHeadMarca:AddField("ZD2_DESCR")
	::oHeadMarca:AddField("ZD2_ABREV")

	//Campos editaveis
	::aAltMarca := {}

Return(::oHeadMarca:GetHeader())


Method LoadMarcas() Class TPDMWPdmProduto

	Local I
	Local aAux

	::aColsMarca := {}

	ZD7->(DbSetOrder(2)) // ZD7_FILIAL, ZD7_PRODUT, ZD7_PDM, ZD7_REV, ZD7_SEQUEN, ZD7_ITEM, R_E_C_N_O_, D_E_L_E_T_
	
	ZD1->(DbSetOrder(1)) // ZD1_FILIAL, ZD1_CODIGO, ZD1_REV, ZD1_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
	
	ZD2->(DBSetOrder(1)) // ZD2_FILIAL, ZD2_CODIGO, ZD2_REV, ZD2_SEQUEN, ZD2_ITEM, R_E_C_N_O_, D_E_L_E_T_
	
	If ZD7->(DbSeek(XFilial("ZD7") + ::cProduto))

		While !ZD7->(Eof()) .And. ZD7->(ZD7_FILIAL + ZD7_PRODUT) == xFilial("ZD7") + ::cProduto

			aAux := {}
			
			If ZD1->(DbSeek(xFilial("ZD1") + ZD7->(ZD7_PDM + ZD7_REV + ZD7_SEQUEN)))
			
				If ZD2->(DbSeek(xFilial("ZD2") + ZD7->(ZD7_PDM + ZD7_REV + ZD7_SEQUEN)))
			
					AAdd(aAux, ZD7->ZD7_PDM)
					AAdd(aAux, ZD7->ZD7_SEQUEN)
					AAdd(aAux, ZD1->ZD1_NOME)
					AAdd(aAux, ZD7->ZD7_ITEM)
					//AAdd(aAux, ZD7->ZD7_REV)
					//AAdd(aAux, ZD7->ZD7_PRODUT)		
					AAdd(aAux, ZD2->ZD2_DESCR)
					AAdd(aAux, ZD2->ZD2_ABREV)
					AAdd(aAux, .F.)
		
					aAdd(::aColsMarca, aAux)

					ZD7->(DbSkip())
			
				EndIf
			
			EndIf
			
		EndDo

	Else

		aAux := {}
		
		AAdd(aAux, CriaVar("ZD7_PDM" ))
		AAdd(aAux, CriaVar("ZD7_SEQUEN" ))
		AAdd(aAux, CriaVar("ZD1_NOME" ))
		AAdd(aAux, CriaVar("ZD7_ITEM" ))
		//AAdd(aAux, CriaVar("ZD7_REV" ))
		//AAdd(aAux, CriaVar("ZD7_PRODUT" ))		
		AAdd(aAux, CriaVar("ZD2_DESCR" ))
		AAdd(aAux, CriaVar("ZD2_ABREV" ))
		AAdd(aAux, .F.)

		aAdd(::aColsMarca, aAux)

	EndIf

Return()