#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG087
@author Gabriel Rossi Mafioletti
@since 13/05/2019
@version 1.0
@description Tela de Consulta Padrão de Tes mais que Inteligente
@type function
/*/

User Function BIAFG087()

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aArea		:=	GetArea()
	
	Local _nOpcA	:=	0
	
	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFntMsg		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)
	
	
	Private _aPosObj		:=	{}
	
	Public uCRet1	:=  Space(3)
	
	Private _oDlg
	
	Private _oGetTes
	
	
	Private _nTes	:=	0
	
	Private _cErrTes	:=	""
	
	Private _oGdNota	:= Nil
	Private _oGdBases	:= Nil
	Private _oGdCredit	:= Nil
	
	
	PRIVATE _cClassif	:=	""
	PRIVATE _cGrupo		:=	""
	PRIVATE _cAtrib		:=	""
	PRIVATE _cEstoque	:=	"S"
	PRIVATE _cFinanc	:=	""
	PRIVATE _cICMS		:=	""
	PRIVATE _cAtivo		:=	""
	PRIVATE _cCfop		:=	""
	PRIVATE _cUF		:=	Iif(IsInCallStack("MATA140"),cUfOrigP,cUfOrig)
	Private _cTpProd	:=	""
	PRIVATE _cIPI		:=	""
	PRIVATE _cClVl		:=	""
	
	Private oLblMsg		:=	""
	Private cMsgErr		:=	"Os Campos com [#] são obrigatórios."
	
	Private oTimer		:=	Nil
	
	
	_cICMS	:=	Iif(GdFieldGet("D1_PICM",n) > 0,"S","N")
	_cIPI	:=	Iif(GdFieldGet("D1_IPI",n) > 0,"S","N")
	_cClVl	:=	GdFieldGet("D1_CLVL",n)
	
	If Empty(GdFieldGet("D1_COD",n))
		uCRet1	:=	SPACE(TamSX3("D1_TES")[1])
		MsgInfo("O Campo Código do Produto Precisa estar preenchido para definição da TES")
		Return .T.
	EndIf
	
	DbSelectArea("SA5")
	SA5->(DbSetOrder(1))
	If SA5->(DbSeek(xFilial("SA5")+cA100For+cLoja+GdFieldGet("D1_COD",n))) .And. !Empty(SA5->A5_YTES) 
		uCRet1	:=	SA5->A5_YTES
		RestArea(_aArea)
		Return .T.
	EndIf	
	
	If !Empty(_cClVl)
		_cAtrib	:=	Posicione("CTH",1,xFilial("CTH")+GdFieldGet("D1_CLVL",n),"CTH_YATRIB")
	EndIf
	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 25, .T. , .T. })
	AAdd(_aObjects, {100, 25, .T. , .T. })
	AAdd(_aObjects, {100, 25, .T. , .T. })
	AAdd(_aObjects, {100, 15, .T. , .T. })
	AAdd(_aObjects, {100, 10, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )
	
	
	DEFINE MSDIALOG _oDlg TITLE "Regras de TES" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL
	
	    
	//Painel das Notas
	@ _aPosObj[1][1], _aPosObj[1][2] GROUP oGpMRP1 TO _aPosObj[1][3], _aPosObj[1][4] PROMPT "Dados da Nota..." OF _oDlg COLOR 0, 16777215 PIXEL    
	
		fGdNota()
	
	//Painel das Bases
	@ _aPosObj[2][1], _aPosObj[2][2] GROUP oGpMRP1 TO _aPosObj[2][3], _aPosObj[2][4] PROMPT "Bases..." OF _oDlg COLOR 0, 16777215 PIXEL    
	    fGdBases()
	    
	//Painel das Créditos
	@ _aPosObj[3][1], _aPosObj[3][2] GROUP oGpMRP1 TO _aPosObj[3][3], _aPosObj[3][4] PROMPT "Creditos e Afins..." OF _oDlg COLOR 0, 16777215 PIXEL    
	    fGdCredit()
	    
	@ _aPosObj[4][1]+3 + ((_aPosObj[4][3]-_aPosObj[4][1])/2),_aPosObj[4][2] SAY "TES:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aPosObj[4][1] + ((_aPosObj[4][3]-_aPosObj[4][1])/2),_aPosObj[4][2]+30 MSGET _oGetTes VAR uCRet1  SIZE 50, 11 OF _oDlg PIXEL WHEN .F.
	
	@ _aPosObj[5][1]+10, _aPosObj[5][2]+05 SAY oLblMsg PROMPT cMsgErr SIZE 446, 011 OF _oDlg FONT oFntMsg COLORS 255, 16777215 PIXEL
	
	oTimer := TTimer():New(7000, {|| fMsgPad() }, _oDlg )
    
    If !Empty(GdFieldGet("D1_YCFFORN",n))
    	If fRecCf(GdFieldGet("D1_YCFFORN",n))
    		GdFieldPut("CFOFOR",GdFieldGet("D1_YCFFORN",n),1,_oGdNota:aHeader,_oGdNota:Acols,.F.)    	
    	EndIf
    EndIf

    If !Empty(GdFieldGet("D1_YCSTFOR",n))
    	If fRecCst(GdFieldGet("D1_YCSTFOR",n))
    		GdFieldPut("CSTSN",GdFieldGet("D1_YCSTFOR",n),_oGdBases:nAt,_oGdBases:aHeader,_oGdBases:Acols,.F.)
    	EndIf
    EndIf
    
	
	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1,Iif(fValidTes(),_oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()},,)
	
	If _nOpcA	==	0
	
		uCRet1	:=	SPACE(TamSX3("D1_TES")[1])

	EndIf
	
	
	RestArea(_aArea)
	
Return .T.


Static Function fGdNota()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}
	Local _cProd	:=	GdFieldGet("D1_COD",n)
	Local _cDscProd	:=	""
	Local _cGrpProd	:=	""
	Local _cDscGrp	:=	""
	
	aAdd(_aHeader,{"CF NF Forn[#]"         ,"CFOFOR" ,"@!"               , 4   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"CF Entrada"         ,"CFOENT" ,"@!"               , 4   , 0,,, "C",, })      	// 2
	aAdd(_aHeader,{"Cod. Prod."         ,"CODPRO" ,"@!"               , TAMSX3("B1_COD")[1]   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Dsc. Prod."         ,"DESPRO" ,"@S50"               , TAMSX3("B1_DESC")[1]   , 0,,, "C",, })      	// 4
	aAdd(_aHeader,{"Grp. Prod."         ,"GRPPRO" ,"@!"               , TAMSX3("B1_GRUPO")[1]   , 0,,, "C",, })      	// 5
	aAdd(_aHeader,{"Dsc. Grup."         ,"DESGRP" ,"@S30"              , TAMSX3("BM_DESC")[1]   , 0,,, "C",, })      	// 6
	aAdd(_aHeader,{"Classific."         ,"CLSGRP" ,"@!"               , TAMSX3("BM_YCLASSI")[1]   , 0,,, "C",,,fRetCBox("BM_YCLASSI") })      	// 8

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+_cProd))
		_cDscProd	:=	SB1->B1_DESC
		_cGrupo	:=	SB1->B1_GRUPO
		_cTpProd	:=	SB1->B1_TIPO
		SBM->(DbSetOrder(1))
		If SBM->(DbSeek(xFilial("SBM")+_cGrupo))
			_cDscGrp	:=	SBM->BM_DESC
			_cClassif	:=	SBM->BM_YCLASSI
		EndIf
	EndIf
	_aCols	:=	{{;
					SPACE(4),;
					SPACE(4),;
					_cProd,;
					_cDscProd,;
					_cGrupo,;
					_cDscGrp,;
					_cClassif,;
					.F.;
				}}

	_oGdNota := MsNewGetDados():New(_aPosObj[1,1]+10, _aPosObj[1,2]+5, _aPosObj[1,3]-5, _aPosObj[1,4]-5, GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/,{"CFOFOR"} /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_FG87NFOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

Return

Static Function fGdBases()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}
	
	aAdd(_aHeader,{"CLVL"         ,"CLVL" ,"@!"               , TAMSX3("CTH_CLVL")[1]   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Estoque?[#]"         ,"ESTOQUE" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_ESTOQUE") })      	// 2
	aAdd(_aHeader,{"Financeiro?"         ,"FINANC" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_DUPLIC") })      	// 2
	aAdd(_aHeader,{"ICMS?"         ,"ICMS" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_ICM") })      	// 2
	aAdd(_aHeader,{"IPI?"         ,"IPI" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_IPI") })      	// 2
	aAdd(_aHeader,{"CST da NF?[#]"         ,"CSTSN" ,"@!"               , 4   , 0,,, "C",,, })      	// 2
	aAdd(_aHeader,{"CST ICMS?"         ,"CSTICMS" ,"@!"               , 4   , 0,,, "C",,, })      	// 2
	aAdd(_aHeader,{"%Red ICMS[#]"         ,"PREDICM" ,"@E 999.99"               , 6   , 2,,, "N",,, })      	// 2
	aAdd(_aHeader,{"IPI na BC[#]"         ,"IPIBC" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_INCIDE") })      	// 2
	aAdd(_aHeader,{"UF Fornec."         ,"UFFOR" ,"@!"               , 2   , 0,,, "C",,, })      	// 2
	
			
	_aCols	:=	{{;
					GdFieldGet("D1_CLVL",n),;
					"S",;
					Space(1),;
					_cICMS,;
					_cIPI,;
					Space(4),;
					Space(4),;
					0,;
					"N",;
					_cUF,;
					.F.;
				}}
	
	_oGdBases := MsNewGetDados():New(_aPosObj[2,1]+10, _aPosObj[2,2]+5, _aPosObj[2,3]-5, _aPosObj[2,4]-5, GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/,{"ESTOQUE","PREDICM","IPIBC","CSTSN"} /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/,"U_FG87BFOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

Return


Static Function fGdCredit()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	aAdd(_aHeader,{"PIS/COFINS"         ,"PISCOF" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_PISCRED") })      	// 1
	aAdd(_aHeader,{"Ativo Fixo?"         ,"ATIVO" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_ATUATF") })      	// 2
	aAdd(_aHeader,{"Tipo"         ,"TIPPROD" ,"@!"               , TAMSX3("B1_TIPO")[1]   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"CIAP?"         ,"CIAP" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_CIAP") })      	// 2
	aAdd(_aHeader,{"DIFAL?"         ,"DIFAL" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_COMPL")})      	// 2
	aAdd(_aHeader,{"Cred. ICMS?"         ,"CRDICM" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_CREDICM") })      	// 2
	aAdd(_aHeader,{"Cred IPI?"         ,"CRDIPI" ,"@!"               , 1   , 0,,, "C",,,fRetCbox("F4_CREDIPI") })      	// 2
	
	
	_aCols	:=	{{;
					SPACE(1),;
					SPACE(1),;
					_cTpProd,;
					SPACE(1),;
					SPACE(1),;
					SPACE(1),;
					SPACE(1),;
					,.F.;
				}}
	
	_oGdCredit := MsNewGetDados():New(_aPosObj[3,1]+10, _aPosObj[3,2]+5, _aPosObj[3,3]-5, _aPosObj[3,4]-5, 0, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

Return


Static Function fRetCBox(_cCampo)

	Local _cCBox	:=	""
	Local _aArea	:=	GetArea()
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	If SX3->(DbSeek(PADR(_cCampo,10)))
	
		_cCBox	:=	X3Cbox()
	
	EndIf
	RestArea(_aArea)
Return _cCBox


User Function FG87NFOK()

	Local _lRet	:=	.T.
	Local _cCpo	:=	ReadVar()

	
	
//Todos os gets somente terão a linha 1
	If _cCpo == "M->CFOFOR"
		_lRet	:= fRecCF(M->CFOFOR)
	EndIf
	
	_oGdBases:ReFresh()
	
	fRecalc(_cCpo)
	
Return _lret

User Function FG87BFOK()

	Local _cCpo	:=	ReadVar()
	Local _lRet	:=	.T.
	
	If _cCpo == "M->CSTSN"
	
		_lRet	:=	fRecCSt(M->CSTSN)
	
	ElseIf _cCpo == "M->ESTOQUE"
		_cEstoque	:=	M->ESTOQUE
	EndIf

	_oGdBases:Refresh()

	fRecalc(_cCpo)

Return _lRet

Static Function fRecalc(_cCpo)

	Local _cChave	:=	""
	Local _cFormula	:=	""
	
	Local _aCols	:=	{{;
					SPACE(1),;
					SPACE(1),;
					_cTpProd,;
					SPACE(1),;
					SPACE(1),;
					SPACE(1),;
					SPACE(1),;
					,.F.;
				}}
	
	_oGdCredit:aCols	:=	_aCols
	
	_oGdCredit:Refresh()
	
	uCRet1	:=	SPACE(3)

	//Procura as Fórmulas
	
	DbSelectArea("ZE2")
	ZE2->(DbSetORder(2))
	
	
	//Pis/Cofins
	_cChave	:=	xFilial("ZE2")+'1'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("PISCOF",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf
	
	//Ativo
	_cChave	:=	xFilial("ZE2")+'2'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("ATIVO",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				_cAtivo	:=	Alltrim(ZE2->ZE2_RETORN)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf	
	
	//CIAP
	_cChave	:=	xFilial("ZE2")+'3'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("CIAP",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf	

	//DIFAL
	_cChave	:=	xFilial("ZE2")+'4'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("DIFAL",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf	

	//Cred ICMS
	_cChave	:=	xFilial("ZE2")+'5'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("CRDICM",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf	
	
	//Cred IPI
	_cChave	:=	xFilial("ZE2")+'6'
	If ZE2->(DbSeek(_cChave))
	
		While ZE2->(!EOF()) .And. ZE2->ZE2_FILIAL+ZE2_TIPO == _cChave
			
			_cFormula	:=	fReplace(ZE2->ZE2_FORMUL)
		
			If &(_cFormula)
				GdFieldPut("CRDIPI",Alltrim(ZE2->ZE2_RETORN),1,_oGdCredit:aHeader,_oGdCredit:Acols,.F.)
				Exit
			EndIf
			ZE2->(DbSkip())
		EndDo
	EndIf	

	fBuscaTes(_cCpo)

	_oGdCredit:Refresh()

	

Return

Static Function fReplace(_cFormula)

	_cFormula	:=	Replace(_cFormula,"@@CLASSIF@@"	,"Alltrim(_cClassif)")
	_cFormula	:=	Replace(_cFormula,"@@GRUPO@@"	,"Alltrim(_cGrupo)")
	_cFormula	:=	Replace(_cFormula,"@@ATRIB@@"	,"Alltrim(_cAtrib)")
	_cFormula	:=	Replace(_cFormula,"@@ESTOQUE@@"	,"Alltrim(_cEstoque)")
	_cFormula	:=	Replace(_cFormula,"@@FINANC@@"	,"Alltrim(_cFinanc)")
	_cFormula	:=	Replace(_cFormula,"@@ICMS@@"	,"Alltrim(_cICMS)")
	_cFormula	:=	Replace(_cFormula,"@@ATIVO@@"	,"Alltrim(_cAtivo)")
	_cFormula	:=	Replace(_cFormula,"@@CFOP@@"	,"Alltrim(_cCfop)")
	_cFormula	:=	Replace(_cFormula,"@@UF@@"		,"Alltrim(_cUF)")
	_cFormula	:=	Replace(_cFormula,"@@TIPO@@"	,"Alltrim(_cTpProd)")
	_cFormula	:=	Replace(_cFormula,"@@IPI@@"		,"Alltrim(_cIPI)")
	_cFormula	:=	Replace(_cFormula,"@@CLVL@@"	,"Alltrim(_cClVl)")
Return _cFormula

Static Function fBuscaTes(_cCpo)

	Local _cAlias	:=	GetNextAlias()
	
	Local _cStIcms	:=	GdFieldGet("CSTICMS",1,.F.,_oGdBases:aHeader,_oGdBases:Acols)
	Local _nRedIcm	:=	Iif(_cCpo == "M->PREDICM",M->PREDICM,GdFieldGet("PREDICM",1,.F.,_oGdBases:aHeader,_oGdBases:Acols))
	Local _cIpiBc	:=	Iif(_cCpo == "M->IPIBC",M->IPIBC,GdFieldGet("IPIBC",1,.F.,_oGdBases:aHeader,_oGdBases:Acols))
	Local _cPisCred	:=	GdFieldGet("PISCOF",1,.F.,_oGdCredit:aHeader,_oGdCredit:Acols)
	Local _cCiap	:=	GdFieldGet("CIAP",1,.F.,_oGdCredit:aHeader,_oGdCredit:Acols)
	Local _cDifal	:=	GdFieldGet("DIFAL",1,.F.,_oGdCredit:aHeader,_oGdCredit:Acols)
	Local _cCrdIcm	:=	GdFieldGet("CRDICM",1,.F.,_oGdCredit:aHeader,_oGdCredit:Acols)
	Local _cCrdIpi	:=	GdFieldGet("CRDIPI",1,.F.,_oGdCredit:aHeader,_oGdCredit:Acols)


	Local _cWEstoque	:=	""
	Local _cWFinanc		:=	""
	
	Local _cWIcms	:=	""
	Local _cWIPI	:=	""
	Local _cWIPIBC	:=	""
	Local _cWAtivo	:=	""
	Local _cWCiap	:=	""
	Local _cWDifal	:=	""
	Local _cWCrdIcm	:=	""
	Local _cWCrdIpi	:=	""
	
	//Tratativa de Variáveis
	
	
	//Estoque
	If _cEstoque <> "S"
	
		_cWEstoque := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWEstoque := "%"+"= 'S'"+"%"
	
	EndIf

	//Financeiro
	If _cFinanc <> "S"
	
		_cWFinanc := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWFinanc := "%"+"= 'S'"+"%"
	
	EndIf

	//ICMS
	If _cIcms <> "S"
	
		_cWIcms := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWIcms := "%"+"= 'S'"+"%"
	
	EndIf

	//ICMS
	If _cIpi <> "S"
	
		_cWIPI := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWIPI := "%"+"= 'S'"+"%"
	
	EndIf

	//Incide IPI
	If _cIpiBc <> "S"
	
		_cWIPIBC := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWIpiBC := "%"+"= 'S'"+"%"
	
	EndIf

	//Ativo
	If _cAtivo <> "S"
	
		_cWAtivo := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWAtivo := "%"+"= 'S'"+"%"
	
	EndIf

	//CIAP
	If _cCiap <> "S"
	
		_cWCiap := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWCiap := "%"+"= 'S'"+"%"
	
	EndIf

	//CIAP
	If _cDifal <> "S"
	
		_cWDifal := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWDifal := "%"+"= 'S'"+"%"
	
	EndIf

	//Cred Icm
	If _cCrdIcm <> "S"
	
		_cWCrdIcm := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWCrdIcm := "%"+"= 'S'"+"%"
	
	EndIf

	//Cred Ipi
	If _cCrdIpi <> "S"
	
		_cWCrdIpi := "%"+"<> 'S'"+"%"
	
	Else
	
		_cWCrdIpi := "%"+"= 'S'"+"%"
	
	EndIf	


	uCRet1	:=	SPACE(3)

	


	BeginSql Alias _cAlias
	
		SELECT *
		FROM %TABLE:SF4% SF4
		WHERE F4_FILIAL = %XFILIAL:SF4%
			AND F4_CF = %Exp:_cCfop%
			AND F4_ESTOQUE %Exp:_cWEstoque%
			AND F4_DUPLIC  %Exp:_cWFinanc%
			AND F4_ICM  %Exp:_cWIcms%
			AND F4_IPI  %Exp:_cWIpi%
			AND F4_SITTRIB = %Exp:_cStIcms%
			AND F4_BASEICM = %Exp:_nRedIcm%
			AND F4_INCIDE  %Exp:_cWIpiBc%
			AND F4_PISCRED = %Exp:_cPisCred%
			AND F4_ATUATF  %Exp:_cWAtivo%
			AND F4_CIAP  %Exp:_cWCiap%
			AND F4_COMPL %Exp:_cWDifal%
			AND F4_CREDICM  %Exp:_cWCrdIcm%
			AND F4_CREDIPI  %Exp:_cWCrdIPI%
			AND F4_CODIGO < '500'
			AND F4_MSBLQL <> '1'
			AND %NotDel%
			
	EndSql
	
	_nTes	:=	0
	
	If (_cAlias)->(!EOF())
	
		uCRet1	:=	(_cAlias)->F4_CODIGO
		_ntes	:=	0
		_cErrTes	:=	uCRet1
		While (_cAlias)->(!EOF())
			If _nTes >= 1
				_cErrTes	+=	";" + (_cAlias)->F4_CODIGO
			EndIf
			_nTes++
		
			(_cAlias)->(DbSkip())
		EndDo
	
	EndIf
	(_cAlias)->(DbCloseArea())
	
	If _nTes <= 1
		_cErrTes	:=	""
	EndIf
	
	_oGetTes:Refresh()
	_oDlg:Refresh()
Return

Static Function fValidTes()

	Local _lRet	:=	.T.

	If !Empty(_cErrTes)
		cMsgErr := "Os Seguintes TES possuem atributos Iguais: " + _cErrTes
		_lRet	:=	.F.
	EndIf
oLblMsg:Refresh()
oTimer:Activate()
Return _lRet

Static Function fMsgPad()

	cMsgErr	:=	"Os Campos com [#] são obrigatórios."
	oLblMsg:Refresh()
	oTimer:DeActivate()
Return

Static Function fRecCf(_cCf)

	Local _lEspec	:=	.F.
	Local _lAchou	:=	.F.
	Local _lRet		:=	.T.

	DbSelectArea("ZE0")
	ZE0->(DbSetOrder(1))
	If ZE0->(DbSeek(xFilial("ZE0")+_cCF))
		//Busca regras na qual se encaixe
		While ZE0->(!EOF()) .And. ZE0->ZE0_FILIAL + ZE0->ZE0_CFS == xFilial("ZE0")+_cCF
			If _cClassif == ZE0->ZE0_CLASSIF .And.;
				_cClVl == ZE0->ZE0_CLVL
				GdFieldPut("CFOENT",ZE0->ZE0_CFE,1,_oGdNota:aHeader,_oGdNota:Acols,.F.)
				GdFieldPut("FINANC",ZE0->ZE0_FINANC,1,_oGdBases:aHeader,_oGdBases:Acols,.F.)
				_cFinanc	:=	ZE0->ZE0_FINANC	
				_cCfop		:=	ZE0->ZE0_CFE
				_lEspec		:=	.T.
				_lAchou		:=	.T.
			ElseIf !_lEspec .And.;
					_cClassif == ZE0->ZE0_CLASSIF .And.;
					Alltrim(ZE0->ZE0_CLVL) == "*" .And.;
					Alltrim(ZE0->ZE0_ATRIB) == _cAtrib
				GdFieldPut("CFOENT",ZE0->ZE0_CFE,1,_oGdNota:aHeader,_oGdNota:Acols,.F.)
				GdFieldPut("FINANC",ZE0->ZE0_FINANC,1,_oGdBases:aHeader,_oGdBases:Acols,.F.)
				_cFinanc	:=	ZE0->ZE0_FINANC	
				_cCfop		:=	ZE0->ZE0_CFE
				_lAchou		:=	.T.					
			EndIf

			ZE0->(DbSkip())
		EndDo			
	EndIf	


	If !_lAchou
		MsgInfo("Não foi possível encontrar uma relação entre CF do Fornecedor e CF de Entrada")
		GdFieldPut("CFOENT",SPACE(4),1,_oGdNota:aHeader,_oGdNota:Acols,.F.)
		GdFieldPut("FINANC",SPACE(1),1,_oGdBases:aHeader,_oGdBases:Acols,.F.)
		_cFinanc	:=	""
		_cCfop		:=	""
		_lRet	:=	.F.
	EndIf

	fRecalc("")

Return _lRet

Static Function fRecCst(_cCst)

	Local _lret	:=	.T.

	DbSelectArea("ZE1")
	ZE1->(DbSetOrder(2))
	If ZE1->(DbSeek(xFilial("ZE1")+_cCst+_cTpProd))
		GdFieldPut("CSTICMS",ZE1->ZE1_CST,_oGdBases:nAt,_oGdBases:aHeader,_oGdBases:Acols,.F.)
	Else
		_lRet	:=	.F.
		MsgInfo("Não foi encontrada uma correspondência para o CST informado!")
	EndIf

	fRecalc("")

Return _lRet