#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TLoadEmpresa
@author Wlysses Cerqueira (Facile)
@since 26/04/2019
@project Automação Financeira
@version 1.0
@description Classe de   
@type class
/*/

#DEFINE SM0_GRPEMP	1
#DEFINE SM0_CODFIL	2
#DEFINE SM0_NOME	17
#DEFINE SM0_NOMRED	6

Class TLoadEmpresa From LongClasName
	
	Data aEmpSel

	Data cCgc
	Data cIdEnt
	Data cUf
	Data lFilial
	Data cCodEmp
	Data cCodFil

	DATA lEmpAnt

	Data lCliente
	Data cCodCli
	Data cLojaCli

	Data lFornecedor
	Data cCodFor
	Data cLojaFor

	Data cCodigosFor
	Data cCodigosCli

	Method New(lEmpAnt) Constructor
	Method Load(lEmpAnt)
	Method Seek(cCgc)
	Method SeekForCli(cCodEmp, cCodFil)
	Method SeekCli(cCodigo, cLoja)
	Method SeekFor(cCodigo, cLoja)
	Method GetCodigos()

	Method GetSelEmp(aEmpOut,lEmpAnt)
	Method MarcaTodos(lMarca, aVetor, oLbx)
	Method InvSelecao(aVetor, oLbx)
	Method RetSelecao(aRet, aVetor)
	Method MarcaMas(oLbx, aVetor, cMascEmp, lMarDes)
	Method VerTodos(aVetor, lChk, oChkMar)

EndClass

Method New(lEmpAnt) Class TLoadEmpresa

	DEFAULT lEmpAnt:=.F.

	::Load(lEmpAnt)

Return()

Method Load(lEmpAnt) Class TLoadEmpresa

	DEFAULT lEmpAnt:=.F.

	::cCgc := ""
	::cUf := ""
	::lFilial := .F.
	::cCodEmp := ""
	::cCodFil := ""
	::lCliente := .F.
	::lFornecedor := .F.
	::cCodCli := ""
	::cLojaCli := ""
	::cCodFor := ""
	::cLojaFor := ""
	::cCodigosFor := ""
	::cCodigosCli := ""
	::aEmpSel := {}
	::lEmpAnt:=lEmpAnt

Return()

Method Seek(cCgc) Class TLoadEmpresa

	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())

	::Load()

	::cCgc := AllTrim(Replace(Replace(Replace(cCgc, "/", ""), ".", ""), "-", ""))

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3)) // A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3)) // A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_

	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DBGoTop())

	While SM0->(! EOF())

		If AllTrim(SM0->M0_CGC) == ::cCgc

			::lFilial := .T.
			::cCodEmp := PADR(SM0->M0_CODIGO, 2, " ")
			::cCodFil := PADR(SM0->M0_CODFIL, 2, " ")
			::cUf	  := SM0->M0_ESTENT
			::cIdEnt  := GetCfgEntidade()

			If SA1->(DbSeek(xFilial("SA1") + SM0->M0_CGC))

				::lCliente := .T.
				::cCodCli := SA1->A1_COD
				::cLojaCli := SA1->A1_LOJA

			EndIf

			If SA2->(DbSeek(xFilial("SA2") + SM0->M0_CGC))

				::lFornecedor := .T.
				::cCodFor := SA2->A2_COD
				::cLojaFor := SA2->A2_LOJA

			EndIf

			Exit

		EndIf

		SM0->(DbSkip())

	EndDo

	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aAreaSM0)

Return(::lFilial)

Method SeekCli(cCodigo, cLoja) Class TLoadEmpresa

	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())

	::Load()

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

	If SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja))

		If ::Seek(SA1->A1_CGC)

			::lCliente := .T.
			::cCodCli := SA1->A1_COD
			::cLojaCli := SA1->A1_LOJA

		EndIf

	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSM0)

Return(::lCliente)

Method SeekFor(cCodigo, cLoja) Class TLoadEmpresa

	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())

	::Load()

	If SA2->(DbSeek(xFilial("SA2") + cCodigo + cLoja))

		If ::Seek(SA2->A2_CGC)

			::lFornecedor := .T.
			::cCodFor := SA2->A2_COD
			::cLojaFor := SA2->A2_LOJA

		EndIf

	EndIf

	RestArea(aAreaSA2)
	RestArea(aAreaSM0)

Return(::lFornecedor)

Method SeekForCli(cCodEmp, cCodFil) Class TLoadEmpresa

	Local aAreaSM0 := SM0->(GetArea())

	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DBGoTop())

	::Load()

	If SM0->(DbSeek(cCodEmp + cCodFil))

		::Seek(SM0->M0_CGC)

	EndIf

	RestArea(aAreaSM0)

Return()

Method GetCodigos() Class TLoadEmpresa

	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())

	::Load()

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3)) // A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3)) // A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_

	If SELECT("SM0")==0
		OpenSM0()
	EndIf

	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DBGoTop())

	While SM0->(! EOF())

		If SA1->(DbSeek(xFilial("SA1") + SM0->M0_CGC))

			::cCodigosCli += If(Empty(::cCodigosCli), "", "/") + SA1->A1_COD

		EndIf

		If SA2->(DbSeek(xFilial("SA2") + SM0->M0_CGC))

			::cCodigosFor += If(Empty(::cCodigosFor), "", "/") + SA2->A2_COD

		EndIf

		SM0->(DbSkip())

	EndDo

	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aAreaSM0)

Return()

Method GetSelEmp(aEmpOut,lEmpAnt) Class TLoadEmpresa

	//---------------------------------------------
	// Parâmetro  nTipo
	// 1 - Monta com Todas Empresas/Filiais
	// 2 - Monta só com Empresas
	// 3 - Monta só com Filiais de uma Empresa
	//
	// Parâmetro  aMarcadas
	// Vetor com Empresas/Filiais pré marcadas
	//
	// Parâmetro  cEmpSel
	// Empresa que será usada para montar seleção
	//---------------------------------------------

	Local   aRet      := {}
	local   aSM0Query
	Local   aSalvAmb  := GetArea()
	Local   aAreaSM0  := SM0->(GetArea())
	Local   aSalvSM0  := {}
	Local   aVetor    := {}
	Local   cMascEmp  := "??"
	Local   cVar      := ""
	Local   cSM0Filter
	Local   lChk      := .F.
	Local   lTeveMarc := .F.
	Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
	Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

	Local CSSBOTAO := "QPushButton { color: #024670; "+;
		"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
		"    border-top-width: 3px; "+;
		"    border-left-width: 3px; "+;
		"    border-right-width: 3px; "+;
		"    border-bottom-width: 3px }"+;
		"QPushButton:pressed {	color: #FFFFFF; "+;
		"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
		"    border-top-width: 3px; "+;
		"    border-left-width: 3px; "+;
		"    border-right-width: 3px; "+;
		"    border-bottom-width: 3px }"

	Local   aMarcadas := {}

	DEFAULT lEmpAnt:=::lEmpAnt
	Default aEmpOut := {}

	::lEmpAnt:=lEmpAnt
	if ::lEmpAnt
		aSM0Query:=array(0)
		cSM0Filter:="M0_CODIGO=='"+&("cEmpAnt")+"'"
		cSM0Filter+=".and."
		cSM0Filter+="M0_CODFIL=='"+PadR(&("cFilAnt"),Len(SM0->M0_CODFIL))+"'"
		MsAguarde({||FilBrowse("SM0",@aSM0Query,cSM0Filter)},"Empresas","Obtendo dados no SGBD...")
	endif

	dbSelectArea( "SM0" )
	aSalvSM0 := SM0->( GetArea() )
	dbSetOrder( 1 )
	dbGoTop()

	While SM0->( !EOF() )

		If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0 .And. aScan( aEmpOut,{|x| AllTrim(x) == AllTrim(SM0->M0_CODIGO)} ) == 0
			aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL , SM0->(RecNo()) } )
		EndIf

		SM0->(dbSkip())
	End

	RestArea( aSalvSM0 )

	Define MSDialog  oDlg Title "" From 0, 0 To 290, 395 Pixel

	oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

	oDlg:cTitle   := "Selecione a(s) Empresa(s)"

	@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
	oLbx:SetArray(  aVetor )
	oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
		aVetor[oLbx:nAt, 2], ;
		aVetor[oLbx:nAt, 4]}}
	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], ::VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll

	@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
		on Click ::MarcaTodos( lChk, @aVetor, oLbx )

	// Marca/Desmarca por mascara
	@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
	@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
		Message "Máscara Empresa ( ?? )"  Of oDlg
	oSay:cToolTip := oMascEmp:cToolTip

	@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( ::InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), ::VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Inverter Seleção" Of oDlg
	oButInv:SetCss( CSSBOTAO )
	@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( ::MarcaMas( oLbx, aVetor, cMascEmp, .T. ), ::VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
	oButMarc:SetCss( CSSBOTAO )
	@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( ::MarcaMas( oLbx, aVetor, cMascEmp, .F. ), ::VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
	oButDMar:SetCss( CSSBOTAO )
	@ 112, 157  Button oButOk   Prompt "Ok"  Size 32, 12 Pixel Action (  ::RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "TLoadEmpresa" ) ) ) ;
		Message "Confirma a seleção?" Of oDlg
	oButOk:SetCss( CSSBOTAO )
	@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
		Message "Cancela e abandona a aplicação" Of oDlg
	oButCanc:SetCss( CSSBOTAO )

	Activate MSDialog  oDlg Center

	::aEmpSel := aRet

	if ::lEmpAnt
		dbSelectArea("SM0")
		SET FILTER TO
	endif

	RestArea(aSalvAmb)
	RestArea(aAreaSM0)

Return(aRet)

Return()

Method MarcaTodos( lMarca, aVetor, oLbx ) Class TLoadEmpresa
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI

	oLbx:Refresh()

Return()

Method InvSelecao( aVetor, oLbx ) Class TLoadEmpresa
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI

	oLbx:Refresh()

Return()

Method RetSelecao( aRet, aVetor ) Class TLoadEmpresa
	Local  nI    := 0

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			aAdd( aRet,{aVetor[nI][2],aVetor[nI][3],aVetor[nI][2]+aVetor[nI][3],aVetor[nI][4],aVetor[nI][5],aVetor[nI][6]} )
		EndIf
	Next nI

Return()

Method MarcaMas( oLbx, aVetor, cMascEmp, lMarDes ) Class TLoadEmpresa

	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0

	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] := lMarDes
			EndIf
		EndIf
	Next

	oLbx:nAt := nPos
	oLbx:Refresh()

Return()

Method VerTodos( aVetor, lChk, oChkMar ) Class TLoadEmpresa

	Local lTTrue := .T.
	Local nI     := 0

	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI

	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return()
