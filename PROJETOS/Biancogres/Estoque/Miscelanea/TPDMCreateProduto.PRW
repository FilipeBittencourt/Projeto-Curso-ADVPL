#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPDMCadastro
@description Classe para inclusao de novo produto pelas regras do PDM
@author Fernando Rocha
@since 07/08/2018
@version 1.0
@type class
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN_TOP "LIN_TOP"
#DEFINE LIN_HALF "LIN_HALF"
#DEFINE LIN_BOTTOM "LIN_BOTTOM"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_TOP 30
#DEFINE PER_LIN_HALF 35
#DEFINE PER_LIN_BOTTOM 35

// IDENTIFICADORES DE COLUNA
#DEFINE COL_TOP "COL_TOP"
#DEFINE COL_HALF"COL_HALF"
#DEFINE COL_BOTTOM "COL_BOTTOM"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL_LEFT 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_TOP "WND_TOP"
#DEFINE WND_HALF "WND_HALF"
#DEFINE WND_BOTTOM "WND_BOTTOM"

#DEFINE TIT_MAIN_WND "PDM - Criar Produto"
#DEFINE TIT_WND_TOP "Identificação do PDM"
#DEFINE TIT_WND_HALF "Características"
#DEFINE TIT_WND_BOTTOM "PDM - Marcas do Produto"

#DEFINE TIT_MSG "PDM"


Class TPDMCreateProduto From LongClassName

Data oDlg
Data oLayer 
Data oPanelTop
Data oPanelHalf
Data oPanelBottom

Data oFontLbl

Data oHeadCarac
Data aHeadCarac
Data aColsCarac
Data aAltCarac
Data oBrwCarac

Data oHeadMarca
Data aHeadMarca
Data aColsMarca
Data aAltMarca
Data oBrwMarca

Data nP1_Codigo
Data nP1_Descricao
Data nP1_Referencia
Data nP1_InfAdicional

//posicoes colunas caracteristica
Data nP2_Seq
Data nP2_Nome
Data nP2_Item
Data nP2_Descr
Data nP2_Abrev

Data oPDMProduto

Data cProduto  //codigo produto

Method New() Constructor

Method Show()
Method LoadDialog()
Method LoadLayer()
Method LayerTop()
Method LayerHalf()
Method LayerBotton()
Method CanEditCell()

Method F3Estrut()

Method SetHCarac()
Method SetHMarca()
Method LoadPDM()
Method LoadMarcas()
Method VldDescVlr()
Method LinhaOkMarca()
Method Salvar()
Method SalvarMarca()

EndClass


Method New() Class TPDMCreateProduto	

	::oDlg := Nil
	::oLayer := Nil
	::oPanelTop := Nil
	::oPanelHalf := Nil
	::oPanelBottom := Nil

	::oFontLbl := TFont():New("Calibri",,010,,.T.)

	::oPDMProduto := Nil

	::oHeadCarac	:= TGDField():New()
	::aColsCarac	:= {}	
	::aHeadCarac	:= {}
	::aAltCarac		:= {}

	::oHeadMarca	:= TGDField():New()
	::aColsMarca	:= {}	
	::aHeadMarca	:= {}
	::aAltMarca		:= {}
	
	::oBrwCarac		:= Nil
	::oBrwMarca		:= Nil

	::nP2_Seq		:= 0
	::nP2_Nome		:= 0
	::nP2_Item		:= 0
	::nP2_Descr		:= 0
	::nP2_Abrev		:= 0

	::nP1_Codigo		:= 0
	::nP1_Descricao		:= 0
	::nP1_Referencia	:= 0
	::nP1_InfAdicional	:= 0
	
	::cProduto	:= Space(TamSX3("B1_COD")[1])

Return Self

Method Show() Class TPDMCreateProduto	

	::oPDMProduto := TPDMProduto():New()

	::LoadDialog()

	aButtons := {}

	EnchoiceBar(::oDlg, {|| IIf(::Salvar(), ::oDlg:End(),) }, {|| ::oDlg:End()}, , aButtons)

	::LoadLayer()

	::oDlg:Activate()

Return


Method LoadDialog() Class TPDMCreateProduto

	::oDlg := MsDialog():New(0, 0, 550, 900, TIT_MAIN_WND,,,,,,,,oMainWnd,.T.)
	::oDlg:cName := "oDlgProdPDM"
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T. 

Return()


Method LoadLayer() Class TPDMCreateProduto

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN_TOP, PER_LIN_TOP, .F.)

	::oLayer:AddLine(LIN_HALF, PER_LIN_HALF, .F.)
	
	::oLayer:AddLine(LIN_BOTTOM, PER_LIN_BOTTOM, .F.)

	::LayerTop()
	::LayerHalf()
	::LayerBotton()
	
Return() 


Method LayerTop() Class TPDMCreateProduto 

	Local oGetCodigo, oGetRev, oGetTipo
	Local oGetGrupo, oGetSubgrupo, oGetFamilia

	::oLayer:AddCollumn(COL_TOP, PER_COL_LEFT, .T., LIN_TOP)	

	::oLayer:AddWindow(COL_TOP, WND_TOP, TIT_WND_TOP, 100, .F. ,.T.,, LIN_TOP, { || })

	::oPanelTop := ::oLayer:GetWinPanel(COL_TOP, WND_TOP, LIN_TOP)

	oGetTipo 		:= TGet():New( 000, 001,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Tipo",1,::oFontLbl)

	oGetGrupo 		:= TGet():New( 000, 008,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Grupo",1,::oFontLbl)
	oGNGru 			:= TGet():New( 000, 015, { | u | If( PCount() == 0, ::oPDMProduto:oPDM:DescGrupo, ::oPDMProduto:oPDM:DescGrupo := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome do Grupo",1,::oFontLbl)

	oGetSubgrupo 	:= TGet():New( 002, 001,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Subgrupo",1,::oFontLbl)
	oGNSubgru		:= TGet():New( 002, 008, { | u | If( PCount() == 0, ::oPDMProduto:oPDM:DescSubgrupo, ::oPDMProduto:oPDM:DescSubgrupo := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome do Subgrupo",1,::oFontLbl)

	oGetFamilia 	:= TGet():New( 002, 021,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Familia",1,::oFontLbl)
	oGNFamilia		:= TGet():New( 002, 028, { | u | If( PCount() == 0, ::oPDMProduto:oPDM:DescFamilia, ::oPDMProduto:oPDM:DescFamilia := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome da Familia",1,::oFontLbl)

	oGetTipo:cF3 			:= "02"
	oGetTipo:bSetGet		:= { | u | If( PCount() == 0, ::oPDMProduto:Tipo, ::oPDMProduto:Tipo := u ) }
	oGetTipo:bChange		:= {|| ::LoadPDM() }

	oGetGrupo:cReadVar		:= "self:oPDMProduto:oPDM:Grupo"
	oGetGrupo:cF3 			:= "PDMF3E"
	oGetGrupo:bSetGet		:= { | u | If( PCount() == 0, ::oPDMProduto:oPDM:Grupo, ::oPDMProduto:oPDM:SetGrupo(u)) }
	oGetGrupo:bChange		:= {|| ::LoadPDM() }

	oGetSubgrupo:cReadVar	:= "self:oPDMProduto:oPDM:Subgrupo"
	oGetSubgrupo:cF3 		:= "PDMF3E"
	oGetSubgrupo:bSetGet	:= { | u | If( PCount() == 0, ::oPDMProduto:oPDM:Subgrupo, ::oPDMProduto:oPDM:SetSubgrupo(u)) }
	oGetSubgrupo:bChange	:= {|| ::LoadPDM() }

	oGetFamilia:cReadVar	:= "self:oPDMProduto:oPDM:Familia"
	oGetFamilia:cF3 		:= "PDMF3E"
	oGetFamilia:bSetGet		:= { | u | If( PCount() == 0, ::oPDMProduto:oPDM:Familia, ::oPDMProduto:oPDM:SetFamilia(u)) }
	oGetFamilia:bChange		:= {|| ::LoadPDM() }

	oGNGru:Disable()
	oGNSubgru:Disable()
	oGNFamilia:Disable()

Return()


Method LayerHalf() Class TPDMCreateProduto 

	Local cLinhaOk := "Allwaystrue"
	Local cTudoOk  := "Allwaystrue"
	Local cFieldOk := "Allwaystrue"
	Local cDelOk   := "Allwaystrue"
	Local cIniCpos := "+ZD1_SEQUEN"
	Local nOper		:= GD_UPDATE + GD_DELETE

	::oLayer:AddCollumn(COL_HALF, PER_COL_LEFT, .T., LIN_HALF)	

	::oLayer:AddWindow(COL_HALF, WND_HALF, TIT_WND_HALF, 100, .F. ,.T.,, LIN_HALF, { || })

	::oPanelHalf := ::oLayer:GetWinPanel(COL_HALF, WND_HALF, LIN_HALF)

	::aHeadCarac := ::SetHCarac()	 

	::oBrwCarac := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltCarac,,99,cFieldOk, "", cDelOk, ::oPanelHalf, ::aHeadCarac, ::aColsCarac)

	::oBrwCarac:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT	

	::oBrwCarac:oBrowse:lHScroll 	:= .T.	
	::oBrwCarac:oBrowse:lVScroll 	:= .T.
	::oBrwCarac:bFieldOk 			:= {|| ::VldDescVlr() } 

	::oBrwCarac:oBrowse:lUseDefaultColors := .F.

Return()


Method LayerBotton() Class TPDMCreateProduto

	Local cLinhaOk 	:= "Allwaystrue"
	Local cTudoOk  	:= "Allwaystrue"
	Local cFieldOk 	:= "Allwaystrue"
	Local cDelOk   	:= "Allwaystrue"
	Local cIniCpos 	:= ""
	Local nOper		:= GD_INSERT + GD_UPDATE + GD_DELETE
/*
	If !(::OpAltera)
		nOper := 0
	EndIf
*/
	::oLayer:AddCollumn(COL_BOTTOM, PER_COL_LEFT, .T., LIN_BOTTOM)	

	::oLayer:AddWindow(COL_BOTTOM, WND_BOTTOM, TIT_WND_BOTTOM, 100, .F. ,.T.,, LIN_BOTTOM, { || })

	::oPanelBottom := ::oLayer:GetWinPanel(COL_BOTTOM, WND_BOTTOM, LIN_BOTTOM)

	::aHeadMarca := ::SetHMarca()	 

	::LoadMarcas()

	::oBrwMarca := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltMarca,,99,cFieldOk, "", cDelOk, ::oPanelBottom, ::aHeadMarca, ::aColsMarca)

	::oBrwMarca:bLinhaOk 			:= {|| ::LinhaOkMarca() }
	::oBrwMarca:oBrowse:bldblclick 	:= {|| IIF(::CanEditCell(), ::oBrwMarca:EditCell(),) }

	::oBrwMarca:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT	
	::oBrwMarca:oBrowse:lHScroll 	:= .T.	
	::oBrwMarca:oBrowse:lVScroll 	:= .T.

	::oBrwMarca:oBrowse:lUseDefaultColors := .F.

Return() 


Method SetHCarac()  Class TPDMCreateProduto

	::oHeadCarac:Clear()

	::oHeadCarac:AddField("ZD1_SEQUEN") 	

	::oHeadCarac:AddField("ZD1_NOME")
	::oHeadCarac:FieldName("ZD1_NOME"):cPict := "@S20"

	::oHeadCarac:AddField("ZD2_ITEM")

	::oHeadCarac:AddField("ZD2_DESCR")
	::oHeadCarac:FieldName("ZD2_DESCR"):cPict := "@S20"
	::oHeadCarac:FieldName("ZD2_DESCR"):cF3 := "PDMF3E"

	::oHeadCarac:AddField("ZD2_ABREV")
	::oHeadCarac:FieldName("ZD2_ABREV"):cPict := "@S20"
	::oHeadCarac:FieldName("ZD2_ABREV"):cF3 := "PDMF3E"

	//Posicoes conforme acima
	::nP2_Seq		:= 1
	::nP2_Nome		:= 2
	::nP2_Item		:= 3
	::nP2_Descr		:= 4
	::nP2_Abrev		:= 5

	//Campos editaveis
	::aAltCarac := {"ZD2_DESCR","ZD2_ABREV"}

Return(::oHeadCarac:GetHeader())


Method SetHMarca() Class TPDMCreateProduto

	::oHeadMarca:Clear()

	::oHeadMarca:AddField("ZD6_CODMAR")	
	::oHeadMarca:FieldName("ZD6_CODMAR"):lObrigat := ""	
	::oHeadMarca:AddField("ZD6_MARCA")
	::oHeadMarca:FieldName("ZD6_MARCA"):lObrigat := ""	
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


Method LoadMarcas() Class TPDMCreateProduto

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

Method LoadPDM() Class TPDMCreateProduto

	Local I
	Local aAux
	Local lContinua := .T.

	::aColsCarac := {}

	If Empty(::oPDMProduto:Tipo) .Or. Empty(::oPDMProduto:oPDM:Grupo) .Or. Empty(::oPDMProduto:oPDM:Subgrupo) .Or. Empty(::oPDMProduto:oPDM:Familia)
		lContinua := .F.
	EndIf

	If ( lContinua )

		If ( ::oPDMProduto:SetPDM() )


			For I := 1 To Len(::oPDMProduto:oPDM:aCaracteristicas)

				If !::oPDMProduto:oPDM:aCaracteristicas[I]:IsBloqueado()

					aAux := {}
					AAdd(aAux, ::oPDMProduto:oPDM:aCaracteristicas[I]:Sequencia)
					AAdd(aAux, ::oPDMProduto:oPDM:aCaracteristicas[I]:Nome)
					AAdd(aAux, Space(TamSX3("ZD2_ITEM")[1]))
					AAdd(aAux, Space(TamSX3("ZD2_DESCR")[1]))
					AAdd(aAux, Space(TamSX3("ZD2_ABREV")[1]))
					AAdd(aAux, .F.)

					aAdd(::aColsCarac, aAux)

				EndIf

			Next I

			::oBrwCarac:aCols := AClone(::aColsCarac)

		Else

			U_FROPMSG(TIT_MSG, "PDM não encontrado.")
			lContinua := .F.

		EndIf

	EndIf

	::oBrwCarac:oBrowse:Refresh()

Return


Method F3Estrut() Class TPDMCreateProduto 

	Local aArea   		:= GetArea()
	Local cTitulo		:= ""
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= ""								//obrigatorio
	Local cCpoChave		:= ""	 							//obrigatorio
	Local cTitCampo		:= ""								//obrigatorio
	Local cMascara		:= "@!"								//obrigatorio
	Local nTamCpo		:= 30		
	Local cRetCpo		:= "uCRet1"							//obrigatorio
	Local nColuna		:= 1
	Local aColsPesq		:= {1,2}
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão			
	Local I
	Local cPedIn		:= ""
	Local cTabPr		:= ""

	Private bRet 		:= .F. 	
	Public uCRet1		:= ""

	If AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDMProduto:oPDM:Grupo"))

		cTitulo 	:= "Grupos do PDM"
		cAlias		:= "ZD3"
		cCpoChave	:= "ZD3_GRUPO"
		cTitCampo	:= "Grupo"

		cQuery := " select ZD3_GRUPO, ZD3_DESCR from "+RetSQLName("ZD3")+" where ZD3_FILIAL = '"+XFILIAL("ZD3")+"' and D_E_L_E_T_='' "

	ElseIf AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDMProduto:oPDM:Subgrupo"))

		cTitulo 	:= "Subgrupos do PDM"
		cAlias		:= "ZD4"
		cCpoChave	:= "ZD4_SUBGRU"
		cTitCampo	:= "Subgrupo"

		cQuery := " select ZD4_SUBGRU, ZD4_DESCR from "+RetSQLName("ZD4")+" where ZD4_FILIAL = '"+XFILIAL("ZD4")+"' and ZD4_GRUPO = '"+::oPDMProduto:oPDM:Grupo+"' and D_E_L_E_T_='' "

	ElseIf AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDMProduto:oPDM:Familia"))

		cTitulo 	:= "Familias do PDM"
		cAlias		:= "ZD5"
		cCpoChave	:= "ZD5_FAMILI"
		cTitCampo	:= "Familia"

		cQuery := " select ZD5_FAMILI, ZD5_DESCR from "+RetSQLName("ZD5")+" where ZD5_FILIAL = '"+XFILIAL("ZD5")+"' and ZD5_GRUPO = '"+::oPDMProduto:oPDM:Grupo+"' and ZD5_SUBGRU = '"+::oPDMProduto:oPDM:Subgrupo+"' and D_E_L_E_T_='' "

	ElseIf AllTrim(Upper(ReadVar())) $ "M->ZD2_DESCR##M->ZD2_ABREV"

		cTitulo 	:= "Valores"
		cAlias		:= "ZD2"
		cCpoChave	:= "ZD2_ITEM"
		cTitCampo	:= "Item"

		_cSeq 		:=  ::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Seq]

		cQuery := " select ZD2_ITEM, ZD2_DESCR from "+RetSQLName("ZD2")+" where ZD2_FILIAL = '"+XFILIAL("ZD2")+"' and ZD2_CODIGO = '"+::oPDMProduto:oPDM:Codigo+"' and ZD2_REV = '"+::oPDMProduto:oPDM:Revisao+"' and ZD2_SEQUEN = '"+_cSeq+"' and D_E_L_E_T_=''

	EndIf

	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna,aColsPesq)

	RestArea( aArea )

Return()


Method VldDescVlr() Class TPDMCreateProduto

	Local cContent		:= AllTrim(Upper(&(ReadVar())))
	Local cCodigo		:= ::oPDMProduto:oPDM:Codigo
	Local cRevisao		:= ::oPDMProduto:oPDM:Revisao
	Local cSeqCarac		:=  ::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Seq]
	Local cAliasTmp
	Local cExpDesc
	Local lContinua		:= .T.
	Local lOk			:= .F.

	If !(AllTrim(ReadVar()) $ "M->ZD2_DESCR##M->ZD2_ABREV")
		Return(.T.)
	EndIf

	If Empty(cContent)

		::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Item] 	:= Space(TamSX3("ZD2_ITEM")[1])
		::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Descr] := Space(TamSX3("ZD2_DESCR")[1])
		::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Abrev] := Space(TamSX3("ZD2_ABREV")[1])

		lOk := .T.
		lContinua := .F.

	EndIf

	If lContinua

		ZD2->(DbSetOrder(1)) //ZD2_FILIAL, ZD2_CODIGO, ZD2_REV, ZD2_SEQUEN, ZD2_ITEM, R_E_C_N_O_, D_E_L_E_T_
		If ZD2->(DbSeek(XFilial("ZD2")+cCodigo+cRevisao+cSeqCarac+cContent))

			::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Item] 	:= ZD2->ZD2_ITEM

			If AllTrim(ReadVar()) == "M->ZD2_DESCR"
				M->ZD2_DESCR := ZD2->ZD2_DESCR
				::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Abrev] := ZD2->ZD2_ABREV
			Else
				::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Descr] := ZD2->ZD2_DESCR
				M->ZD2_ABREV := ZD2->ZD2_ABREV
			EndIf

			lOk := .T.

		Else

			If AllTrim(ReadVar()) == "M->ZD2_DESCR"

				cExpDesc := "% ZD2_DESCR like '%"+cContent+"%' %"

			Else

				cExpDesc := "% ZD2_ABREV like '%"+cContent+"%' %"

			EndIf

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp

				select CONT = count(*) from %Table:ZD2% where ZD2_FILIAL = %XFILIAL:ZD2% and ZD2_CODIGO = %Exp:cCodigo% and ZD2_REV = %Exp:cRevisao% and ZD2_SEQUEN = %Exp:cSeqCarac% and %Exp:cExpDesc% and %NotDel%

			EndSql

			If !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->CONT <> 1

				U_FROPMSG(TIT_MSG, "Valor não encontrado ou múltiplos valores - favor fazer pesquisa mais específica.")
				lContinua := .F.

			EndIf
			(cAliasTmp)->(DbCloseArea())

			If lContinua

				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp

					select top 1 ZD2_ITEM, ZD2_DESCR, ZD2_ABREV from %Table:ZD2% where ZD2_FILIAL = %XFILIAL:ZD2% and ZD2_CODIGO = %Exp:cCodigo% and ZD2_REV = %Exp:cRevisao% and ZD2_SEQUEN = %Exp:cSeqCarac% and %Exp:cExpDesc% and %NotDel%

				EndSql

				If !(cAliasTmp)->(Eof())

					::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Item] 	:= (cAliasTmp)->ZD2_ITEM

					If AllTrim(ReadVar()) == "M->ZD2_DESCR"
						M->ZD2_DESCR :=  (cAliasTmp)->ZD2_DESCR
						::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Abrev] :=  (cAliasTmp)->ZD2_ABREV
					Else
						::oBrwCarac:aCols[::oBrwCarac:oBrowse:nAT][::nP2_Descr] :=  (cAliasTmp)->ZD2_DESCR
						M->ZD2_ABREV :=  (cAliasTmp)->ZD2_ABREV
					EndIf

					lOk := .T.

				EndIf

				(cAliasTmp)->(DbCloseArea())

			EndIf

		EndIf

	EndIf

	::oBrwCarac:oBrowse:Refresh()

Return(lOk)


Method Salvar() Class TPDMCreateProduto

	Local lRet := .T.
	Local aRet := {}
	Local nx
	Local aAux
	
	If !::oBrwMarca:TudoOK()
	
		Return(.F.)
	
	EndIf
	
	::oPDMProduto:aLstValCar := {}

	For nx := 1 To Len(::oBrwCarac:aCols)

		If !(::oBrwCarac:aCols[nx][Len(::oBrwCarac:aHeader)+1])

			aAux := {}
			aAdd(aAux, ::oBrwCarac:aCols[nx][::nP2_Seq])
			aAdd(aAux, ::oBrwCarac:aCols[nx][::nP2_Item])

			aAdd(::oPDMProduto:aLstValCar, aAux)

		EndIf

	Next nx

	::oPDMProduto:aLstMarcas := {}

	For nx := 1 To Len(::oBrwMarca:aCols)

		If !(::oBrwMarca:aCols[nx][Len(::oBrwMarca:aHeader)+1])

			aAux := {}
			aAdd(aAux, ::oBrwMarca:aCols[nx][::nP1_Codigo])
			aAdd(aAux, ::oBrwMarca:aCols[nx][::nP1_Descricao])
			aAdd(aAux, ::oBrwMarca:aCols[nx][::nP1_Referencia])
			aAdd(aAux, ::oBrwMarca:aCols[nx][::nP1_InfAdicional])
			
			aAdd(::oPDMProduto:aLstMarcas, aAux)
			
		EndIf

	Next nx
	
	aRet := ::oPDMProduto:Valid()
	
	If aRet[1]
	
		U_FROPMSG(TIT_MSG, "Descrição Item: "+CRLF+::oPDMProduto:cDescCompl+CRLF+CRLF+"Descrição Abreviada: "+CRLF+::oPDMProduto:cDescAbrev)

	ElseIf Empty(aRet[2])
		
		U_FROPMSG(TIT_MSG, "ERRO: "+CRLF+::oPDMProduto:cErro)
		lRet := .F.
		
	Else
		
		If aRet[3]
			
			U_FROPMSG(TIT_MSG, "ERRO: " + CRLF + aRet[2])
			lRet := .F.
		
		Else
		
			If Aviso(TIT_MSG, "ERRO: " + CRLF + aRet[2], {"Aceito como novo produto", "Cancelar"}, 3) == 1
			
				lRet := .T.
				
			Else
			
				lRet := .F.
				
			EndIf
			
		EndIf
		
	EndIf

	If lRet .And. AllTrim(FunName()) == "MATA010"

		::oPDMProduto:Salvar(.T.)

	EndIf

Return(lRet)


Method CanEditCell() Class TPDMCreateProduto

	Local lRet		:= .T.
	Local nLin 		:= ::oBrwMarca:nAT
	Local nCol 		:= ::oBrwMarca:oBrowse:nColPos

	If nLin <= Len(::aColsMarca) .And. nCol < 4 .And. ! Empty(::aColsMarca[::oBrwMarca:nAT][::nP1_Codigo])

		MsgAlert("Não pode alterar Marcar/Referências. Delete e inclua nova linha.","TPDMCreateProduto - Marcas X Produtos.")

		lRet := .F.

	EndIf

Return(lRet)

Method LinhaOkMarca() Class TPDMCreateProduto

	Local lRet		:= .T.
	Local nLin 		:= ::oBrwMarca:nAT
	Local nx

	For nx := 1 To Len(::oBrwMarca:aCols)	

		If ( nx <> nLin ) .And. ( ::oBrwMarca:aCols[nLin][::nP1_Codigo] == ::oBrwMarca:aCols[nx][::nP1_Codigo] ) .And. ( ::oBrwMarca:aCols[nLin][::nP1_Referencia] == ::oBrwMarca:aCols[nx][::nP1_Referencia] )

			MsgAlert("Marca/Referência já adicionada.", "TPDMWProdMarca - Marcas X Produtos.")

			lRet := .F.
			
			Exit

		EndIf

	Next nx

Return(lRet)

Method SalvarMarca() Class TPDMCreateProduto

	Local lRet := .T.
	Local nx := 0
	Local oPrdMarca := TPDMProdutoMarca():New()
	
	_ObjCrePd_:cProduto := SB1->B1_COD
	
	For nx := 1 To Len(_ObjCrePd_:oBrwMarca:aCols)	
		
		If ! Empty(_ObjCrePd_:oBrwMarca:aCols[nx][_ObjCrePd_:nP1_Descricao])
		
			oPrdMarca:Filial 		:= XFilial("ZD6")
			oPrdMarca:Produto 		:= _ObjCrePd_:cProduto
			oPrdMarca:CodMarca		:= _ObjCrePd_:oBrwMarca:aCols[nx][_ObjCrePd_:nP1_Codigo]
			oPrdMarca:Marca			:= _ObjCrePd_:oBrwMarca:aCols[nx][_ObjCrePd_:nP1_Descricao]
			oPrdMarca:Referencia 	:= _ObjCrePd_:oBrwMarca:aCols[nx][_ObjCrePd_:nP1_Referencia]
	
			oPrdMarca:InfAdicional 	:= _ObjCrePd_:oBrwMarca:aCols[nx][_ObjCrePd_:nP1_InfAdicional]
	
			oPrdMarca:Save()
		
		EndIf

	Next nx

	oPrdMarca := Nil
	
Return(lRet)