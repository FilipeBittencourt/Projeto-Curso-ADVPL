#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPDMCadastro
@description Classe da Tela de Manutenção do PDM
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
#DEFINE LIN_HALF "LIN_HALF"
#DEFINE LIN_BOTTOM "LIN_BOTTOM"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_TOP 32
#DEFINE PER_LIN_HALF 32
#DEFINE PER_LIN_BOTTOM 31

// IDENTIFICADORES DE COLUNA
#DEFINE COL_TOP "COL_TOP"
#DEFINE COL_HALF "COL_HALF"
#DEFINE COL_BOTTOM "COL_BOTTOM"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL_LEFT 100
#DEFINE PER_COL_HALF 100
#DEFINE PER_COL_BOTTOM 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_TOP "WND_TOP"
#DEFINE WND_HALF "WND_HALF"
#DEFINE WND_BOTTOM "WND_BOTTOM"

#DEFINE TIT_MAIN_WND "PDM- Manutenção"
#DEFINE TIT_WND_TOP "Identificação do PDM"
#DEFINE TIT_WND_HALF "Características"
#DEFINE TIT_WND_BOTTOM "Valores da Característica"

//modos da tela
#DEFINE M_VISUALIZAR 	2
#DEFINE M_INCLUIR		3
#DEFINE M_ALTERAR 		4
#DEFINE M_EXCLUIR 		5

#DEFINE TIT_MSG "PDM"


Class TPDMCadastro From LongClassName

Data oDlg
Data oLayer 
Data oPanelTop
Data oPanelHalf
Data oPanelBottom

Data oFontLbl

Data oPDM

Data nModo
Data lOkValor

Data oHeadCarac
Data aHeadCarac
Data aColsCarac
Data oHeadValor
Data aHeadValor
Data aColsValor
Data aAltCarac
Data aAltValor
Data oBrwCarac
Data oBrwValor

//posicoes colunas caracteristica
Data nP2_Seq
Data nP2_Ordem
Data nP2_Nome
Data nP2_Obrig
Data nP2_ReqAbr
Data nP2_Ncpdes
Data nP2_Blq

//Posicoes colunas valor
Data nP3_Item
Data nP3_Descr
Data nP3_Abrev
Data nP3_Blq

Method New() Constructor

Method Show(nModo)
Method LoadDialog()
Method LoadLayer()
Method LayerTop()
Method LayerHalf()
Method LayerBotton()

Method LoadPDM()
Method F3Estrut()
Method OnCaracChange()

Method SetHCarac()
Method LoadCarac()
Method VldLinCarac()
Method VldLinValor()
Method DelLinCarac(lDelTudo)
Method DelLinValor(lDelTudo)

Method SetHValor()
Method LoadValor()
Method AddLineValor()

Method Salvar()

EndClass


Method New() Class TPDMCadastro	

	::oDlg := Nil
	::oLayer := Nil
	::oPanelTop := Nil
	::oPanelHalf := Nil
	::oPanelBottom := Nil

	::oFontLbl := TFont():New("Calibri",,010,,.T.)

	::oPDM := Nil
	::lOkValor := .T.

	::oHeadCarac	:= TGDField():New()
	::oHeadValor	:= TGDField():New()
	::aColsCarac	:= {}	
	::aColsValor	:= {}	
	::aHeadCarac	:= {}
	::aHeadValor	:= {}
	::aAltCarac		:= {}
	::aAltValor		:= {}

	::oBrwCarac		:= Nil
	::oBrwValor		:= Nil

	::nP2_Seq		:= 0
	::nP2_Ordem		:= 0
	::nP2_Nome		:= 0
	::nP2_Obrig		:= 0
	::nP2_ReqAbr	:= 0
	::nP2_Ncpdes	:= 0
	::nP2_Blq		:= 0

	::nP3_Item		:= 0
	::nP3_Descr		:= 0
	::nP3_Abrev		:= 0
	::nP3_Blq		:= 0


Return(Self)


Method LoadPDM() Class TPDMCadastro

	If ( ::nModo == M_INCLUIR )

		::oPDM := TPDMModelo():New()
		::oPDM:Codigo	:= CRIAVAR("ZD0_CODIGO")
		::oPDM:Revisao	:= "001"

	Else

		Processa({ || ::oPDM := TPDMModelo():Get(ZD0->ZD0_CODIGO, ZD0->ZD0_REV), ::LoadCarac() },"Aguarde...","Carregando estrutura do PDM.",.F.)

	EndIf

Return()


Method Show(nModo) Class TPDMCadastro	

	::nModo := nModo

	::LoadPDM()

	::LoadDialog()

	::LoadLayer()

	aButtons := {}

	EnchoiceBar(::oDlg, {|| IIf(::Salvar(), ::oDlg:End(),) }, {|| ::oDlg:End()}, , aButtons)

	::oDlg:Activate()

Return()


Method LoadDialog() Class TPDMCadastro

	Local aCoors := FWGetDialogSize(oMainWnd)

	::oDlg := MsDialog():New(aCoors[1], aCoors[2], aCoors[3], aCoors[4], TIT_MAIN_WND,,,,nOR(WS_VISIBLE, WS_POPUP),,,,oMainWnd,.T.)
	::oDlg:cName := "oDlgPDM"
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T. 

Return()


Method LoadLayer() Class TPDMCadastro

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN_TOP, PER_LIN_TOP, .F.)

	::oLayer:AddLine(LIN_HALF, PER_LIN_HALF, .F.)

	::oLayer:AddLine(LIN_BOTTOM, PER_LIN_BOTTOM, .F.)

	::LayerTop()
	::LayerHalf()
	::LayerBotton()

Return() 


Method LayerTop() Class TPDMCadastro 

	Local oGetCodigo, oGetRev
	Local oGetGrupo, oGetSubgrupo, oGetFamilia

	::oLayer:AddCollumn(COL_TOP, PER_COL_LEFT, .T., LIN_TOP)	

	::oLayer:AddWindow(COL_TOP, WND_TOP, TIT_WND_TOP, 100, .F. ,.T.,, LIN_TOP, { || })

	::oPanelTop := ::oLayer:GetWinPanel(COL_TOP, WND_TOP, LIN_TOP)

	oGetCodigo 	:= TGet():New( 001, 001, { | u | If( PCount() == 0, ::oPDM:Codigo, ::oPDM:Codigo := u ) }, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Código",1,::oFontLbl)

	oGetRev 	:= TGet():New( 001, 008, { | u | If( PCount() == 0, ::oPDM:Revisao, ::oPDM:Revisao := u ) }, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Revisão",1,::oFontLbl)

	//oGetTipo 	:= TGet():New( 001, 015, { | u | If( PCount() == 0, ::oPDM:Tipo, ::oPDM:Tipo := u ) }, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Tipo",1,::oFontLbl)
	//oGetTipo:cF3 := "02"

	oGetGrupo 		:= TGet():New( 003, 001,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Grupo",1,::oFontLbl)
	oGNGru 			:= TGet():New( 003, 008, { | u | If( PCount() == 0, ::oPDM:DescGrupo, ::oPDM:DescGrupo := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome do Grupo",1,::oFontLbl)

	oGetSubgrupo 	:= TGet():New( 003, 021,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Subgrupo",1,::oFontLbl)
	oGNSubgru		:= TGet():New( 003, 028, { | u | If( PCount() == 0, ::oPDM:DescSubgrupo, ::oPDM:DescSubgrupo := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome do Subgrupo",1,::oFontLbl)

	oGetFamilia 	:= TGet():New( 003, 041,/*bSetGet*/, ::oPanelTop, 040, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Familia",1,::oFontLbl)
	oGNFamilia		:= TGet():New( 003, 048, { | u | If( PCount() == 0, ::oPDM:DescFamilia, ::oPDM:DescFamilia := u ) }, ::oPanelTop, 100, 010, "@!",,,,,,,,,,,,,,,,,,,,,,,,"Nome da Familia",1,::oFontLbl)

	oGetGrupo:cReadVar		:= "self:oPDM:Grupo"
	oGetGrupo:cF3 			:= "PDMF3E"
	oGetGrupo:bSetGet		:= { | u | If( PCount() == 0, ::oPDM:Grupo, ::oPDM:SetGrupo(u)) }

	oGetSubgrupo:cReadVar	:= "self:oPDM:Subgrupo"
	oGetSubgrupo:cF3 		:= "PDMF3E"
	oGetSubgrupo:bSetGet	:= { | u | If( PCount() == 0, ::oPDM:Subgrupo, ::oPDM:SetSubgrupo(u)) }

	oGetFamilia:cReadVar	:= "self:oPDM:Familia"
	oGetFamilia:cF3 		:= "PDMF3E"
	oGetFamilia:bSetGet		:= { | u | If( PCount() == 0, ::oPDM:Familia, ::oPDM:SetFamilia(u)) }

	oGNGru:Disable()
	oGNSubgru:Disable()
	oGNFamilia:Disable()

	oGetCodigo:Disable()
	oGetRev:Disable()
	oGetGrupo:Disable()
	oGetSubgrupo:Disable()
	oGetFamilia:Disable()

	If ( ::nModo == M_INCLUIR )

		oGetGrupo:Enable()
		oGetSubgrupo:Enable()
		oGetFamilia:Enable()

	EndIf	

	If ( ::nModo == M_ALTERAR )

		oGetGrupo:Enable()
		oGetSubgrupo:Enable()
		oGetFamilia:Enable()

	EndIf

Return()


Method LayerHalf() Class TPDMCadastro 

	Local cLinhaOk := "Allwaystrue"
	Local cTudoOk  := "Allwaystrue"
	Local cFieldOk := "Allwaystrue"
	Local cDelOk   := "Allwaystrue"
	Local cIniCpos := "+ZD1_SEQUEN"
	Local nOper		:= If( ::nModo == M_EXCLUIR, 0, GD_INSERT + GD_UPDATE + GD_DELETE )

	::oLayer:AddCollumn(COL_HALF, PER_COL_LEFT, .T., LIN_HALF)	

	::oLayer:AddWindow(COL_HALF, WND_HALF, TIT_WND_HALF, 100, .F. ,.T.,, LIN_HALF, { || })

	::oPanelHalf := ::oLayer:GetWinPanel(COL_HALF, WND_HALF, LIN_HALF)

	::aHeadCarac := ::SetHCarac()	 

	::oBrwCarac := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltCarac,,99,cFieldOk, "", cDelOk, ::oPanelHalf, ::aHeadCarac, ::aColsCarac)

	::oBrwCarac:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT	
	//::oBrwCarac:oBrowse:bLDblClick 	:= {|| }	
	//::oBrwCarac:bFieldOk 			:= {|| } 	
	//::oBrwCarac:oBrowse:bEditCol 	:= {|| }	
	::oBrwCarac:oBrowse:bChange 	:= {|| ::OnCaracChange() }
	::oBrwCarac:oBrowse:lHScroll 	:= .F.	
	::oBrwCarac:oBrowse:lVScroll 	:= .T.
	::oBrwCarac:bLinhaOk 			:= {|| ::VldLinCarac() }
	::oBrwCarac:bDelOk 			:= {|| ::DelLinCarac() }

	::oBrwCarac:oBrowse:lUseDefaultColors := .F.
	//::oBrwCarac:oBrowse:SetBlkBackColor({|| ::CaracBkColor(::oBrwCarac:oBrowse:nAT) })

Return()


Method LayerBotton() Class TPDMCadastro 

	Local cLinhaOk := "Allwaystrue"
	Local cTudoOk  := "Allwaystrue"
	Local cFieldOk := "Allwaystrue"
	Local cDelOk   := "Allwaystrue"
	Local cIniCpos := "+ZD2_ITEM"
	Local nOper 	:= If( ::nModo == M_EXCLUIR, 0, GD_INSERT + GD_UPDATE + GD_DELETE )

	::oLayer:AddCollumn(COL_BOTTOM, PER_COL_LEFT, .T., LIN_BOTTOM)	

	::oLayer:AddWindow(COL_BOTTOM, WND_BOTTOM, TIT_WND_BOTTOM, 100, .F. ,.T.,, LIN_BOTTOM, { || })

	::oPanelBottom := ::oLayer:GetWinPanel(COL_BOTTOM, WND_BOTTOM, LIN_BOTTOM)

	::aHeadValor := ::SetHValor()

	::oBrwValor := MSNewGetDados():New(000, 000, 000, 000, nOper, cLinhaOk, cTudoOk, cIniCpos, ::aAltValor,,9999, cFieldOk, "", cDelOk, ::oPanelBottom, ::aHeadValor, ::aColsValor)

	::oBrwValor:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT	
	//::oBrwValor:oBrowse:bLDblClick 	:= {|| }	
	//::oBrwValor:bFieldOk 			:= {|| } 	
	//::oBrwValor:oBrowse:bEditCol 	:= {|| }	
	//::oBrwValor:oBrowse:bChange 	:= {|| }
	::oBrwValor:oBrowse:lHScroll 	:= .F.	
	::oBrwValor:oBrowse:lVScroll 	:= .T.
	::oBrwValor:bLinhaOk 			:= {|| ::VldLinValor() }
	::oBrwValor:bDelOk 			:= {|| ::DelLinValor() }

Return()


Method F3Estrut() Class TPDMCadastro 

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

	If AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDM:Grupo"))

		cTitulo 	:= "Grupos do PDM"
		cAlias		:= "ZD3"
		cCpoChave	:= "ZD3_GRUPO"
		cTitCampo	:= "Grupo"

		cQuery := " select ZD3_GRUPO, ZD3_DESCR from "+RetSQLName("ZD3")+" where ZD3_FILIAL = '"+XFILIAL("ZD3")+"' and D_E_L_E_T_='' "

	ElseIf AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDM:Subgrupo"))

		cTitulo 	:= "Subgrupos do PDM"
		cAlias		:= "ZD4"
		cCpoChave	:= "ZD4_SUBGRU"
		cTitCampo	:= "Subgrupo"

		cQuery := " select ZD4_SUBGRU, ZD4_DESCR from "+RetSQLName("ZD4")+" where ZD4_FILIAL = '"+XFILIAL("ZD4")+"' and ZD4_GRUPO = '"+::oPDM:Grupo+"' and D_E_L_E_T_='' "

	ElseIf AllTrim(Upper(ReadVar())) == AllTrim(Upper("self:oPDM:Familia"))

		cTitulo 	:= "Familias do PDM"
		cAlias		:= "ZD5"
		cCpoChave	:= "ZD5_FAMILI"
		cTitCampo	:= "Familia"

		cQuery := " select ZD5_FAMILI, ZD5_DESCR from "+RetSQLName("ZD5")+" where ZD5_FILIAL = '"+XFILIAL("ZD5")+"' and ZD5_GRUPO = '"+::oPDM:Grupo+"' and ZD5_SUBGRU = '"+::oPDM:Subgrupo+"' and D_E_L_E_T_='' "

	EndIf

	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna,aColsPesq)

	RestArea( aArea )

Return()


Method SetHCarac()  Class TPDMCadastro

	::oHeadCarac:Clear()

	::oHeadCarac:AddField("ZD1_SEQUEN") 	

	::oHeadCarac:AddField("ZD1_ORDEM") 

	::oHeadCarac:AddField("ZD1_NOME")

	::oHeadCarac:AddField("ZD1_OBRIG")

	::oHeadCarac:AddField("ZD1_REQABR")

	::oHeadCarac:AddField("ZD1_NCPDES")

	::oHeadCarac:AddField("ZD1_MSBLQL")

	//Posicoes conforme acima
	::nP2_Seq		:= 1
	::nP2_Ordem		:= 2
	::nP2_Nome		:= 3
	::nP2_Obrig		:= 4
	::nP2_ReqAbr	:= 5
	::nP2_Ncpdes	:= 6
	::nP2_Blq		:= 7

	//Campos editaveis
	::aAltCarac := {"ZD1_ORDEM","ZD1_NOME","ZD1_OBRIG","ZD1_REQABR","ZD1_NCPDES","ZD1_MSBLQL"}

Return(::oHeadCarac:GetHeader())


Method LoadCarac() Class TPDMCadastro

	Local I
	Local aAux

	::aColsCarac := {}

	For I := 1 To Len(::oPDM:aCaracteristicas)

		aAux := {}
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:Sequencia)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:Ordem)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:Nome)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:Obrigatorio)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:RequerAbrev)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:NomeCompDesc)
		AAdd(aAux, ::oPDM:aCaracteristicas[I]:Bloqueio)
		AAdd(aAux, .F.)

		aAdd(::aColsCarac, aAux)

	Next I

	If Len(::aColsCarac) == 0

		aAux := {}
		AAdd(aAux, "01")
		AAdd(aAux, "01")
		AAdd(aAux, CriaVar("ZD1_NOME"))
		AAdd(aAux, CriaVar("ZD1_OBRIG"))
		AAdd(aAux, CriaVar("ZD1_REQABR"))
		AAdd(aAux, CriaVar("ZD1_NCPDES"))
		AAdd(aAux, CriaVar("ZD1_MSBLQL"))
		AAdd(aAux, .F.)

		aAdd(::aColsCarac, aAux)

	EndIf

Return


Method SetHValor() Class TPDMCadastro

	::oHeadValor:Clear()

	::oHeadValor:AddField("ZD2_ITEM") 

	::oHeadValor:AddField("ZD2_DESCR")

	::oHeadValor:AddField("ZD2_ABREV")

	::oHeadValor:AddField("ZD2_MSBLQL")

	//Posicoes
	::nP3_Item		:= 1
	::nP3_Descr		:= 2
	::nP3_Abrev		:= 3
	::nP3_Blq		:= 4	

	//Campos editaveis
	::aAltValor := {"ZD2_DESCR","ZD2_ABREV","ZD2_MSBLQL"}

Return(::oHeadValor:GetHeader())


Method LoadValor(nPosC) Class TPDMCadastro

	Local I
	Local aAux
	Local oCarac := ::oPDM:aCaracteristicas[nPosC]
	Local oValor

	::aColsValor := {}

	For I := 1 To Len(oCarac:aValores)

		oValor := oCarac:aValores[I]

		aAux := {}
		AAdd(aAux, oValor:Item)
		AAdd(aAux, oValor:Descricao)
		AAdd(aAux, oValor:Abreviatura)
		AAdd(aAux, oValor:Bloqueio)
		AAdd(aAux, .F.)

		aAdd(::aColsValor, aAux)

	Next I

	If Len(::aColsValor) == 0

		aAux := {}
		AAdd(aAux, "0001")
		AAdd(aAux, CriaVar("ZD2_DESCR"))
		AAdd(aAux, CriaVar("ZD2_ABREV"))
		AAdd(aAux, CriaVar("ZD2_MSBLQL"))
		AAdd(aAux, .F.)

		aAdd(::aColsValor, aAux)

	EndIf

Return


Method AddLineValor() Class TPDMCadastro

	Local aAux := {}

	::aColsValor := {}

	AAdd(aAux, StrZero(1,TamSX3("ZD2_ITEM")[1]) )
	AAdd(aAux, Space(TamSX3("ZD2_DESCR")[1]) )
	AAdd(aAux, Space(TamSX3("ZD2_ABREV")[1]) )
	AAdd(aAux, "2" )
	AAdd(aAux, .F. )

	aAdd(::aColsValor, aAux)

Return()


Method OnCaracChange() Class TPDMCadastro

	Local nPosC := ::oBrwCarac:oBrowse:nAT

	If nPosC > 0

		If Len(::oPDM:aCaracteristicas) == 0

			::AddLineValor()

		ElseIf Len(::oPDM:aCaracteristicas) >= nPosC

			::LoadValor(nPosC)

		ElseIf ::lOkValor

			::AddLineValor()

		EndIf

		::oBrwValor:aCols := ::aColsValor

		::oBrwValor:oBrowse:Refresh()

	EndIf

Return()

/*Method CaracBkColor(nLinha) Class TPDMCadastro

Local nRet := 16777215

If nLinha == ::oBrwCarac:oBrowse:nAT
nRet := 6539007
Endif

Return nRet*/


Method VldLinCarac() Class TPDMCadastro

	Local lRet := .T.
	Local nPos := ::oBrwCarac:oBrowse:nAT 
	Local nx
	Local oCarac

	Local _cSequencia
	Local _cOrdem 		
	Local _cNome	 	
	Local _cObrigatorio 
	Local _cRequerAbrev 
	Local _cNomeCompDesc
	Local _cBloqueio

	If (nPos > 0 .And. !::oBrwCarac:aCols[nPos][Len(::oBrwCarac:aHeader)+1])
		/*
		If ( Len(::oBrwValor:aCols) <= 0 .Or. Empty(::oBrwValor:aCols[1][::nP3_Descr]) )

		U_FROPMSG(TIT_MSG, "Característica sem valores adicionados.")
		lRet := .F.

		EndIf

		If Empty(::oBrwCarac:aCols[nPos][::nP2_Nome])

		U_FROPMSG(TIT_MSG, "Característica sem descrição informada.")
		lRet := .F.

		EndIf
		*/
		If lRet

			_cSequencia		:= ::oBrwCarac:aCols[nPos][::nP2_Seq]
			_cOrdem 		:= ::oBrwCarac:aCols[nPos][::nP2_Ordem]
			_cNome	 		:= ::oBrwCarac:aCols[nPos][::nP2_Nome]
			_cObrigatorio 	:= ::oBrwCarac:aCols[nPos][::nP2_Obrig]
			_cRequerAbrev 	:= ::oBrwCarac:aCols[nPos][::nP2_ReqAbr]
			_cNomeCompDesc	:= ::oBrwCarac:aCols[nPos][::nP2_Ncpdes]
			_cBloqueio		:= ::oBrwCarac:aCols[nPos][::nP2_Blq]

			oCarac := ::oPDM:GetCaracteristica(_cSequencia)

			::lOkValor := .T.

			If (  oCarac <> Nil )

				oCarac:Populate(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio)

			Else

				oCarac := ::oPDM:AddCaracteristica(_cOrdem, _cNome, _cObrigatorio, _cRequerAbrev, _cNomeCompDesc, _cBloqueio)

			EndIf

			For nx := 1 To Len(::oBrwValor:aCols)

				If ::VldLinValor(nx) .And. !::oBrwValor:aCols[nx][Len(::oBrwValor:aHeader)+1]

					::lOkValor := .T.

				Else

					::lOkValor := lRet := .F.

					Exit

				EndIf

			Next nx

		EndIf

	EndIf

Return(lRet)


Method VldLinValor(_nAT) Class TPDMCadastro

	Local lRet 		:= .T.
	Local nPosC 	:= ::oBrwCarac:oBrowse:nAT
	Local oCarac 	:= Nil
	Local nPosV 	:= ::oBrwValor:oBrowse:nAT

	Local _cItem
	Local _cDesc 
	Local _cAbrev
	Local _cBloqueio

	Default _nAT := 0
	/*
	If !::VldLinCarac()

	Return(.F.)

	EndIf
	*/
	If ( _nAT > 0 )

		nPosV := _nAT

	EndIf

	If (nPosC > 0 .And. !::oBrwCarac:aCols[nPosC][Len(::oBrwCarac:aHeader)+1] .And. Len(::oPDM:aCaracteristicas) >= nPosC .And. nPosV > 0 .And. !::oBrwValor:aCols[nPosV][Len(::oBrwValor:aHeader)+1])

		oCarac 	:= ::oPDM:aCaracteristicas[nPosC]

		_cItem 		:= ::oBrwValor:aCols[nPosV][::nP3_Item]
		_cDesc 		:= ::oBrwValor:aCols[nPosV][::nP3_Descr]
		_cAbrev		:= ::oBrwValor:aCols[nPosV][::nP3_Abrev]
		_cBloqueio	:= ::oBrwValor:aCols[nPosV][::nP3_Blq]

		oValor := oCarac:GetValor(_cItem)

		If ( oValor <> Nil )

			oValor:Populate(_cDesc, _cAbrev, _cBloqueio)

		EndIf

		If lRet .And. Empty(_cDesc)

			U_FROPMSG(TIT_MSG, "Obrigatório informar o Valor.")
			lRet := .F.

		EndIf

		If ( lRet .And. oCarac:RequerAbrev == "S" .And. Empty(_cAbrev) )

			U_FROPMSG(TIT_MSG, "Característica com abreviatura obrigatória e não informada no Valor.")
			lRet := .F.

		EndIf

		If ( lRet )

			oCarac:AddValor(_cDesc, _cAbrev, _cBloqueio)

		EndIf

	EndIf

Return(lRet)


Method DelLinCarac(lDelTudo) Class TPDMCadastro

	Local lRet 		:= .T.
	Local oCarac	:= Nil
	Local nW		:= 0
	Local nPos		:= 0
	Local nTot		:= 0
	Local lDelet	:= .F.

	Default lDelTudo := .F.

	If lDelTudo

		nPos := 1

		nTot := Len(::oBrwCarac:aCols)

	Else

		nPos := ::oBrwCarac:oBrowse:nAt

		nTot := nPos

	EndIf

	For nW := nPos To nTot

		lDelet := ::oBrwCarac:aCols[nW][Len(::oBrwCarac:aHeader)+1]

		_cSequencia	 := ::oBrwCarac:aCols[nW][::nP2_Seq]

		oCarac := ::oPDM:GetCaracteristica(_cSequencia)

		If ( oCarac <> Nil )

			oCarac:DbState := If(lDelet, _UPDATE, _DELETE)

		Else

			U_FROPMSG(TIT_MSG, "Item: " + cValtoChar(nW) + " Erro ao localizar característica.")

			lRet := .F.

		EndIf

	Next nW

Return(lRet)


Method DelLinValor(lDelTudo) Class TPDMCadastro

	Local lRet		:= .T.
	Local oCarac 	:= Nil
	Local nPosC 	:= ::oBrwCarac:oBrowse:nAT
	Local nPosV 	:= 0
	Local nTot		:= 0
	Local lDelet	:= .F.
	Local nW

	Default lDelTudo := .F.

	If lDelTudo

		nPosV := 1

		nTot := Len(::oBrwValor:aCols)

	Else

		nPosV := ::oBrwValor:oBrowse:nAt

		nTot := nPosV

	EndIf

	If nPosC > 0 .And. Len(::oPDM:aCaracteristicas) >= nPosC .And. nPosV > 0

		For nW := nPosV To nTot

			lDelet := ::oBrwCarac:aCols[nW][Len(::oBrwCarac:aHeader)+1]

			oCarac 	:= ::oPDM:aCaracteristicas[nPosC]

			_cItem := ::oBrwValor:aCols[nPosV][::nP3_Item]

			oValor := oCarac:GetValor(_cItem)

			If ( oValor <> Nil )

				oValor:DbState := If(lDelet, _UPDATE, _DELETE)

			Else

				If !( ::nModo == M_INCLUIR )

					U_FROPMSG(TIT_MSG, "Item: " + cValtoChar(nW) + " Erro ao localizar valor.")

					lRet := .F.

				EndIf

			EndIf

		Next nW

	EndIf

Return(lRet)


Method Salvar() Class TPDMCadastro

	Local lRet := .T.
	Local lTodosDel := .T.
	Local nW := 0

	If Empty(::oPDM:Codigo) .Or. Empty(::oPDM:Revisao) .Or. Empty(::oPDM:Grupo) .Or. Empty(::oPDM:Subgrupo) .Or. Empty(::oPDM:Familia)
		U_FROPMSG(TIT_MSG, "Campos do cabecalho não informados.")
		lRet := .F.
	EndIf

	If ( ::nModo == M_INCLUIR .And. ::oPDM:ExisteCab() )
		U_FROPMSG(TIT_MSG, "PDM já existe com o Grupo/Subgrupo/Familia informados")
		lRet := .F.
	EndIf

	For nW := 1 To Len(::oBrwCarac:aCols)

		If lTodosDel .And. !::oBrwCarac:aCols[nW][Len(::oBrwCarac:aHeader)+1]

			lTodosDel := .F.

		EndIf

	Next nW

	If lTodosDel

		U_FROPMSG(TIT_MSG, "Nescessário conter um ou mais caracteristicas!")

		lRet := .F.

	EndIf

	If ::nModo == M_EXCLUIR

		::oPDM:DbState := 3

		::DelLinCarac(.T.)

		::DelLinValor(.T.)

	EndIf

	If ( lRet )

		If ( ::oBrwCarac:LinhaOk() .And. ::oBrwValor:LinhaOk() ) 

			::oPDM:Save()

		Else

			lRet = .F.

		EndIf

	EndIf

Return(lRet)