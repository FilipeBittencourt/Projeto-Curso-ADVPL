#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG063
@author Gabriel Rossi Mafioletti
@since 10/09/2018
@version 1.0
@description Tela de Lançamentos não Gerenciáveis
@type function

/*/

User Function BIAFG063()

	If !ValidPerg()
		Return
	EndIf

	fProcessa()

Return

Static Function fProcessa()

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}

	Local _aHeader		:=	{}          
	Local _aCols		:=	{}

	Local cSeek	:=	xFilial("ZCI") + MV_PAR01
	Local bWhile	:=	{|| ZCI_FILIAL + ZCI_ANOREF }                    

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _nOpcA	:=	0

	Local _aButtons	:=	{}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _cAnoRef		:=	MV_PAR01
	Private _oGAnoRef

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZCI",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	Define MsDialog _oDlg Title "Lançamentos não Gerenciáveis" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Ano:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,040 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL WHEN .F.

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_BFG63LOK"/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999, "U_BFG63FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_BFG63DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG063" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(4)

	aAdd( aPergs ,{1,"Ano Base " 	  				,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.T.})

	If ParamBox(aPergs ,"Lançamentos não Gerenciáveis",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet

User Function BFG63FOK()

	Local _lRet	:=	.T.
	Local _cField	:= ReadVar()
	Local _cName	:=	""

	Do Case

		Case Alltrim(_cField)	==	"M->ZCI_CLVL"
		If GdFieldGet("ZCI_REC_WT",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) <> 0
			MsgInfo("Não é possível alterar o campo pois o registro já se encontra gravado! ")
			_lRet	:=	.F.
		Else
			_cName	:=	POSICIONE("CTH",1,xFilial("CTH")+M->ZCI_CLVL,"CTH_DESC01")
			GdFieldPut("ZCI_DSCLVL",_cName,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)
		EndIf
		Case Alltrim(_cField)	==	"M->ZCI_CONTA"
		If GdFieldGet("ZCI_REC_WT",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) <> 0
			MsgInfo("Não é possível alterar o campo pois o registro já se encontra gravado! ")
			_lRet	:=	.F.
		Else
			_cName	:=	POSICIONE("CT1",1,xFilial("CT1")+M->ZCI_CONTA,"CT1_DESC01")
			GdFieldPut("ZCI_DSCONT",_cName,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:aCols)
		EndIf

	EndCase 

Return _lRet

User Function BFG63DOK()

	Local _lRet	:=	.T.

	If GdFieldGet("ZCI_REC_WT",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) <> 0
		_lRet	:= .F.
		MsgInfo("Não será possível excluir registros já gravados!")
	EndIf

Return _lRet

User Function BFG63LOK()

	Local _lRet	:=	.T.
	Local _nI
	Local _nPosDel	:=	Len(_oGetDados:aHeader) + 1

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If GdFieldGet("ZCI_CLVL",_nI) == GdFieldGet("ZCI_CLVL",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And.;
		GdFieldGet("ZCI_CONTA",_nI) == GdFieldGet("ZCI_CONTA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		_nI <> _oGetDados:nAt .And. !_oGetDados:aCols[_nI,_nPosDel]

			MsgInfo("Registro já incluído para o ano em questao! Não será possível incluir duplicado!")
			_lRet	:= .F.
			Exit

		EndIf

	Next

Return _lRet

Static Function fGrvDados()

	Local _nI

	For _nI	:= 1 to Len(_oGetDados:aCols)

		If !GdDeleted(_nI,_oGetDados:aHeader,_oGetDados:aCols)

			If GdFieldGet("ZCI_REC_WT",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == 0
				Reclock("ZCI",.T.)
			Else
				ZCI->(DbGoTo(GdFieldGet("ZCI_REC_WT",_nI,,_oGetDados:aHeader,_oGetDados:aCols)))
				If ZCI->(!EOF())
					Reclock("ZCI",.F.)
				Else
					Reclock("ZCI",.T.)
				EndIf
			EndIf 

			ZCI->ZCI_ANOREF	:=	MV_PAR01
			ZCI->ZCI_FILIAL	:=	xFilial("ZCI")
			ZCI->ZCI_CLVL	:=	GdFieldGet("ZCI_CLVL",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			ZCI->ZCI_DSCLVL	:=	GdFieldGet("ZCI_DSCLVL",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			ZCI->ZCI_CONTA	:=	GdFieldGet("ZCI_CONTA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			ZCI->ZCI_DSCONT	:=	GdFieldGet("ZCI_DSCONT",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			ZCI->ZCI_GERENC	:=	GdFieldGet("ZCI_GERENC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)

			ZCI->(MsUnlock())
		EndIf
	Next

	// Retirado de uso até segunda ordem, pois o reflexo dos Update que esta função realiza, fariam com que o delta de carga
	// do GMCD 1.0 fosse muito afetado.
	// Além disso, ainda está faltando ajustar a rotina para atualizar as tabelas Z48 e ZBF

	//Processa({||fAlterCT2()})

	_oDlg:End()

Return

Static Function fAlterCT2()

	Local _cAlias	:= GetNextAlias()

	BeginSql Alias _cAlias
	SELECT CT2.R_E_C_N_O_ REC,
	ZCI_GERENC,
	'D' TPOP
	FROM %TABLE:CT2% CT2
	INNER JOIN %TABLE:ZCI% ZCI ON ZCI.ZCI_CLVL = CT2.CT2_CLVLDB
	AND ZCI.ZCI_CONTA = CT2.CT2_DEBITO
	AND ZCI.ZCI_ANOREF = %Exp:MV_PAR01%
	AND ZCI.ZCI_ANOREF = SUBSTRING(CT2.CT2_DATA, 1, 4)
	AND ZCI.%NotDel%
	WHERE CT2_DATA BETWEEN %Exp:MV_PAR01 + '0101'% AND %Exp:MV_PAR01 + '1231'%
	AND CT2.%NotDel%
	UNION ALL
	SELECT CT2.R_E_C_N_O_ REC,
	ZCI_GERENC,
	'C' TPOP
	FROM %TABLE:CT2% CT2
	INNER JOIN %TABLE:ZCI% ZCI ON ZCI.ZCI_CLVL = CT2.CT2_CLVLCR
	AND ZCI.ZCI_CONTA = CT2.CT2_CREDIT
	AND ZCI.ZCI_ANOREF = %Exp:MV_PAR01%
	AND ZCI.ZCI_ANOREF = SUBSTRING(CT2.CT2_DATA, 1, 4)
	AND ZCI.%NotDel%
	WHERE CT2_DATA BETWEEN %Exp:MV_PAR01 + '0101'% AND %Exp:MV_PAR01 + '1231'%
	AND CT2.%NotDel%
	EndSql

	While (_cAlias)->(!EOF())
		CT2->(DbGoto((_cAlias)->REC))
		If CT2->(!EOF())
			Reclock("CT2",.F.)
			If (_cAlias)->TPOP == 'C'
				CT2->CT2_YGERCR	:= (_cAlias)->ZCI_GERENC
			Else 
				CT2->CT2_YGERDB	:= (_cAlias)->ZCI_GERENC
			EndIf
			CT2->(MsUnlock())
		EndIf	
		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())

	MsgInfo("Atualização concluída com sucesso!")

Return
