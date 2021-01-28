#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG006
@author Gabriel Rossi Mafioletti
@since 06/06/2017
@version 1.0
@description Cadastro de Caco Realizado
@type function
/*/

#DEFINE ID 1 // Id do Celula
#DEFINE OBJETO 2 // Objeto de Tela
#DEFINE DATADIA 3 // Data Completa da Celula
#DEFINE DIA 4 // Dia Ref. Data da Celula
#DEFINE MES 5 // Mes Ref. Data da Celula
#DEFINE ANO 6 // Ano Ref. Data da Celula
#DEFINE NSEMANO 7 // Semana do Ano Ref. Data da Celula
#DEFINE NSEMMES 8 // Semana do Mes Ref. Data da Celula
#DEFINE ATIVO 9 // É celula referente a um dia ativo
#DEFINE FOOTER 10 // É celula referente ao rodape
#DEFINE HEADER 11 // É celula referente ao Header
#DEFINE SEMANA 12 // É celula referente a semana 

User function BIAFG006()

	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}
	Local _aSize 		:=	{}

	Local _aButtons	:=	{}

	Private _oCalend
	Private _oDlg

	If !ValidPerg()
		Return
	EndIf

	aAdd(_aButtons,{"HISTORIC",{|| U_BIAFG009()}, "Rel. Caco Diario","Rel. Caco Diario"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	Define MsDialog _oDlg Title "Caco Realizado" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel     

	_oCalend := FWCalendar():New(MONTH(MV_PAR01),YEAR(MV_PAR01))
	_oCalend:lWeekColumn := .F.
	_oCalend:lFooterLine := .F.

	_oCalend:bldblclick	:=	{|| BrwDbClk()}

	_oCalend:Activate(_oDlg)

	CrgCCaco()

	_oDlg:ctitle	:=	"Calendário " + _oCalend:cMesano

	Activate MsDialog _oDlg Centered on Init EnchoiceBar(_oDlg, {|| _oDlg:End()}, {|| _oDlg:End()},, _aButtons)

return

Static Function CrgCCaco()

	Local nCount := 0
	Local aCli := {}

	For nCount := 1 To Len(_oCalend:aCell)	

		If _oCalend:aCell[nCount][ATIVO]

			aCli := GetCCaco(_oCalend:aCell[nCount][DATADIA])			

			_oCalend:SetInfo(_oCalend:aCell[nCount][ID], aCli)

		EndIf

	Next	

Return                 

Static Function GetCCaco(dDate,lLista)
	Local aRet := {}				
	Local cAlias := GetNextAlias()
	Local cDate	:=	dTos(dDate)    

	Default lLista	:=	.F.

	BEGINSQL Alias cAlias

		SELECT  Z94_FORMAT FORMAT,
		ZZ6.ZZ6_DESC  DESCRI,
		Z94.Z94_BAIA BAIA,
		Z94.Z94_FORNO FORNO,
		Z94.Z94_ESCOLH ESCOLH,
		Z94.Z94_CACO CACO
		FROM    %TABLE:Z94% Z94
		JOIN %TABLE:ZZ6% ZZ6 ON Z94.Z94_FORMAT = ZZ6.ZZ6_COD
		AND Z94.D_E_L_E_T_ = ''
		AND ZZ6.D_E_L_E_T_ = ''
		WHERE   ZZ6.ZZ6_FILIAL = %xFilial:ZZ6%
		AND Z94.Z94_DTREF = %Exp:cDate%
	ENDSQL

	While !(cAlias)->(Eof())	
		If lLista				
			(cAlias)->(aAdd(aRet,{FORMAT,DESCRI,BAIA,FORNO,ESCOLH,CACO}))
		Else
			(cAlias)->(aAdd(aRet,FORMAT+'-'+Alltrim(DESCRI)))
		EndIf
		(cAlias)->(DbSkip())

	EndDo

	(cAlias)->(DbCloseArea())

Return(aRet)              

Static Function BrwDbClk()

	Local _oDlgDc

	Local aHeader :=	{}
	Local aCols	:=	{}

	Local _nOpcA	:=	0

	Local cSeek	:=	xFilial("Z94") + DtoS(_oCalend:aCell[_oCalend:nAt][DATADIA])
	Local bWhile	:=	{|| Z94_FILIAL + DtoS(Z94_DTREF)}	

	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}
	Local _aSize 		:=	{}

	Private _oGdDbClk	:=	Nil

	U_BIAFG090(_oCalend:aCell[_oCalend:nAt][DATADIA],_oCalend:aCell[_oCalend:nAt][DATADIA])

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z94",1,cSeek,bWhile,,,,,,,,@aHeader,@aCols)

	If Len(aCols) > 0

		aEval(aCols,{|x| x[7] := Alltrim(x[7])})

	EndIF

	DEFINE DIALOG _oDlgDc TITLE "Dados dos Clientes" FROM _aSize[7],000 TO _aSize[6],_aSize[5] PIXEL Of oMainWnd PIXEL

	_oGdDbClk	:=	MsNewGetDados():New( _aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4],7, "U_BIAF6LOK" /*[ cLinhaOk]*/,"U_BIAF6TOK" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BIAF6FOK"/*cFieldOK*/,"U_BIAF6SDE" /*[ cSuperDel]*/, "U_BIAF6DEL"/*[ cDelOk]*/, _oDlgDc, aHeader, aCols)

	ACTIVATE DIALOG _oDlgDc CENTERED on Init EnchoiceBar(_oDlgDc, {||_nOpcA := 1, If(_oGdDbClk:TudoOk(),_oDlgDc:End(),_nOpcA := 0)}, {|| _oDlgDc:End()}) 

	if _nOpcA > 0
		fGrvDados()
	EndIf

	CrgCCaco()

Return     

Static Function fGrvDados()

	Local _nI
	Local nPosDtRef 	:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_DTREF"})
	local nPosRec	    := aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_REC_WT"})
	local nPosForm	    := aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_FORMAT"})
	local nPosBaia	    := aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_BAIA"})
	local nPosForno	    := aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_FORNO"})
	local nPosEsc		:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_ESCOLH"})	
	local nPosCaco		:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_CACO"})
	Local nPosProduc	:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_PRODUC"})
	Local nPosCacoAj	:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_CACOAJ"})
	Local nPosMeta		:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_META"})
	Local nPosPrCaco	:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_PRCACO"})
	Local nPosEquipe	:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_EQUIPE"})	
	Local nPosTurno		:= aScan(_oGdDbClk:aHeader,{|x| AllTrim(x[2]) == "Z94_TURNO"})

	local nPosDel	:=	Len(_oGdDbClk:aHeader) + 1

	DbSelectArea('Z94')
	for _nI	:=	1 to Len(_oGdDbClk:aCols)
		If _oGdDbClk:aCols[_nI,nPosRec] > 0
			Z94->(DbGoTo(_oGdDbClk:aCols[_nI,nPosRec]))
			Reclock("Z94",.F.)
			If !_oGdDbClk:aCols[_nI,nPosDel]
				Z94->Z94_DTREF 	:=	_oGdDbClk:aCols[_nI,nPosDtRef]
				Z94->Z94_FORMAT	:=	_oGdDbClk:aCols[_nI,nPosForm]
				Z94->Z94_BAIA	:=	_oGdDbClk:aCols[_nI,nPosBaia]
				Z94->Z94_FORNO	:=	_oGdDbClk:aCols[_nI,nPosForno]
				Z94->Z94_ESCOLH	:=	_oGdDbClk:aCols[_nI,nPosEsc]
				Z94->Z94_CACO	:=	_oGdDbClk:aCols[_nI,nPosCaco]
				Z94->Z94_PRODUC	:=	_oGdDbClk:aCols[_nI,nPosProduc]
				Z94->Z94_CACOAJ	:=	_oGdDbClk:aCols[_nI,nPosCacoAj]
				Z94->Z94_META	:=	_oGdDbClk:aCols[_nI,nPosMeta]
				Z94->Z94_PRCACO	:=	_oGdDbClk:aCols[_nI,nPosPrCaco]
				Z94->Z94_EQUIPE	:=	_oGdDbClk:aCols[_nI,nPosEquipe]
				Z94->Z94_TURNO	:=	_oGdDbClk:aCols[_nI,nPosTurno]
			Else
				Z94->(DbDelete())
			EndIf
			Z94->(MsUnlock())
		Else
			Reclock("Z94",.T.)
			Z94->Z94_FILIAL	:=	xFilial("Z94")
			Z94->Z94_DTREF 	:=	_oGdDbClk:aCols[_nI,nPosDtRef]
			Z94->Z94_FORMAT	:=	_oGdDbClk:aCols[_nI,nPosForm]
			Z94->Z94_BAIA	:=	_oGdDbClk:aCols[_nI,nPosBaia]
			Z94->Z94_FORNO	:=	_oGdDbClk:aCols[_nI,nPosForno]
			Z94->Z94_ESCOLH	:=	_oGdDbClk:aCols[_nI,nPosEsc]
			Z94->Z94_CACO	:=	_oGdDbClk:aCols[_nI,nPosCaco]
			Z94->Z94_PRODUC	:=	_oGdDbClk:aCols[_nI,nPosProduc]
			Z94->Z94_CACOAJ	:=	_oGdDbClk:aCols[_nI,nPosCacoAj]
			Z94->Z94_META	:=	_oGdDbClk:aCols[_nI,nPosMeta]
			Z94->Z94_PRCACO	:=	_oGdDbClk:aCols[_nI,nPosPrCaco]
			Z94->Z94_EQUIPE	:=	_oGdDbClk:aCols[_nI,nPosEquipe]
			Z94->Z94_TURNO	:=	_oGdDbClk:aCols[_nI,nPosTurno]			

			Z94->(MsUnlock())			
		EndIf
	next

Return

//Grid - Linha OK
User Function BIAF6LOK(oGd,nLinha)

	local lRet		:= .T.

Return lRet

User Function BIAF6TOK(oGd)

	local nx   := 0
	local lRet := .T.

	For nx:=1 to Len(_oGdDbClk:aCols)
		if !GDdeleted(nx)
			lRet := U_BIAF6LOK(oGd,nx)
			if !lRet
				Exit
			endif 
		endif	
	Next nx

Return lRet

User Function BIAF6FOK()

	Local cMenVar   := ReadVar()
	Local _nI
	Local _lRet		:=	.T.
	Local _nAt		:=	_oGdDbClk:nAt
	Local _cAlias	:=	""
	Local vfArea    := GetArea()
	Local _cData	:= DtoS(_oCalend:aCell[_oCalend:nAt][DATADIA])
	Local _nValor	:=	0
	Local _cForm	:=	""
	Local _cEquipe	:=	""
	Local _cTurno	:=	""
	Local _cInLinha	:=	""

	Do Case

		Case Alltrim(cMenVar) $ "M->Z94_FORMAT/M->Z94_TURNO/M->Z94_EQUIPE/M->Z94_FORNO"   
		Do Case

			Case cMenVar == "M->Z94_FORMAT"
			_cForm		:=	M->Z94_FORMAT
			_cEquipe	:=	GdFieldGet("Z94_EQUIPE",n)
			_cTurno		:=	GdFieldGet("Z94_TURNO",n)				
			_cInLinha		:=	"%('" + "L" + Substr(GdFieldGet("Z94_FORNO",n),2,2) + "')%"
			If _cForm $ "C6/BO/B9"
				_cInLinha := "%('E03','E04')%"
			EndIf			

			Case Alltrim(cMenVar) == "M->Z94_TURNO"
			_cForm		:=	GdFieldGet("Z94_FORMAT",n)
			_cEquipe	:=	GdFieldGet("Z94_EQUIPE",n)
			_cTurno		:=	M->Z94_TURNO
			_cInLinha		:=	"%('" + "L" + Substr(GdFieldGet("Z94_FORNO",n),2,2) + "')%"
			If _cForm $ "C6/BO/B9"
				_cInLinha := "%('E03','E04')%"
			EndIf				

			Case Alltrim(cMenVar) == "M->Z94_EQUIPE"
			_cForm		:=	GdFieldGet("Z94_FORMAT",n)
			_cEquipe	:=	M->Z94_EQUIPE
			_cTurno		:=	GdFieldGet("Z94_TURNO",n)
			_cInLinha		:=	"%('" + "L" + Substr(GdFieldGet("Z94_FORNO",n),2,2) + "')%"
			If _cForm $ "C6/BO/B9"
				_cInLinha := "%('E03','E04')%"
			EndIf			

			Case Alltrim(cMenVar) == "M->Z94_FORNO"
			_cForm		:=	GdFieldGet("Z94_FORMAT",n)
			_cEquipe	:=	GdFieldGet("Z94_EQUIPE",n)
			_cTurno		:=	GdFieldGet("Z94_TURNO",n)
			_cInLinha		:=	"%('" + "L" + Substr(GdFieldGet("Z94_FORNO",n),2,2) + "')%"
			If _cForm $ "C6/BO/B9"
				_cInLinha := "%('E03','E04')%"
			EndIf			

		EndCase

		If cMenVar == "M->Z94_FORMAT"
			If !ExistCPo("ZZ6")
				Return .F.
			Else
				_cAlias	:=	GetNextAlias()

				BeginSql Alias _cAlias
					SELECT ISNULL(Z93_PERMET,0) AS META
					FROM %TABLE:Z93% 
					WHERE Z93_FILIAL = %XFILIAL:Z93%
					AND %Exp:_cData% BETWEEN Z93_DATADE AND Z93_DATAAT
					AND Z93_FORMAT = %Exp:M->Z94_FORMAT%
					AND %NotDel%
				EndSql
				RestArea(vfArea)
				GdFieldPut("Z94_DESFOR",Posicione("ZZ6",1,xFilial("ZZ6")+M->Z94_FORMAT,"ZZ6_DESC"),_nAt)
				GdFieldPut("Z94_META",(_cAlias)->META,_nAt)
				(_cAlias)->(DbCloseArea())
			EndIf
		EndIF

		For _nI	:= 1 to Len(_oGdDbClk:aCols)
			If !GDdeleted(_nI) .And. _nI <> _nAt  .And. ;
			_cForm == GdFieldGet("Z94_FORMAT",_nI) .And.;
			_cEquipe == GdFieldGet("Z94_EQUIPE",_nI) .And. ;
			_cTurno == GdFieldGet("Z94_TURNO",_nI)    
				MsgInfo("Formato já Cadastrado na Data Atual")
				Return .F.
			EndIf  
		Next

		RestArea(vfArea)

		If !Empty(_cForm) .And. !Empty(_cTurno) .and. !Empty(_cEquipe) .and. !Empty(_cInLinha)
			_nValor	:=	fCalcPrd(_cForm, _cTurno, _cEquipe, _cInLinha)
			GdFieldPut("Z94_PRODUC",_nValor,_nAt)
		Else
			GdFieldPut("Z94_PRODUC",0,_nAt)
		EndIf

		RestArea(vfArea)

	EndCase

	fAvgCaco(_nAt)

Return	_lRet

User function BIAF6SDE() 

Return .T.

User function BIAF6DEL() 

Return .T.

Static Function fCalcPrd(cFormat, _cTurno, _cEquipe, _cInLinha)

	Local _nProd	:=	0
	Local _cAlias	:=	GetNextALias()
	Local _cData	:= DtoS(_oCalend:aCell[_oCalend:nAt][DATADIA])	

	BeginSql Alias _cAlias

		SELECT  ISNULL(SUM(CASE WHEN SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' )
		THEN Z75.Z75_BKQTD
		ELSE Z75_QUANT
	END), 0) QUANT
	FROM    %TABLE:Z75% Z75
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
	AND B1_YFORMAT = %Exp:cFormat%
	AND SB1.D_E_L_E_T_ = ' '
	WHERE   Z75_FILIAL = %XFILIAL:Z75%
	AND Z75_DATARF = %Exp:_cData%
	AND Z75_TPMOV IN ('ETQ','RET')
	AND Z75.Z75_TURNO = %EXP:_cTurno%
	AND Z75.Z75_LINHA IN %EXP:_cInLinha%
	AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE','BW','BV','CC','CD') AND Z75_TPPROD = 'PP') OR ( B1_YFORMAT NOT IN('BM', 'BF', 'BD', 'BE','BW','BV','CC','CD') AND Z75_TPPROD <> 'PP') )
	AND ( ( SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = '1'
	AND Z75.Z75_BKEQUI = %Exp:_cEquipe%
	)
	OR ( SB1.B1_YFORMAT NOT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = %Exp:_cEquipe%
	)
	)
	AND Z75.%NotDel%

	EndSql

	_nProd	:=	(_cAlias)->QUANT

	(_cAlias)->(DbCloseArea())

Return _nProd

Static Function fAvgCaco(_nAt)

	Local _aCacos	:=	{}
	Local _nI		:=	{}
	Local _npos		:=	0
	Local _nValor	:=	0
	Local cMenVar	:=	ReadVar()
	Local _nPerCaco	:=	0
	Local _nPeso	:=	0
	Local _aArea	:=	GetArea()
	Local _cBaia	:=	If(cMenVar == "M->Z94_BAIA",M->Z94_BAIA,GdFieldGet("Z94_BAIA",_nAt))	
	Local _cFormat	:=	If(cMenVar == "M->Z94_FORMAT",M->Z94_FORMAT,GdFieldGet("Z94_FORMAT",_nAt))
	Local _nCaco	:=	If(cMenVar == "M->Z94_CACO",M->Z94_CACO,GdFieldGet("Z94_CACO",_nAt))
	Local _nProd	:=	If(cMenVar == "M->Z94_PRODUC",M->Z94_PRODUC,GdFieldGet("Z94_PRODUC",_nAt))
	Local _cTurno	:=	If(cMenVar == "M->Z94_TURNO",M->Z94_TURNO,GdFieldGet("Z94_TURNO",_nAt))
	Local _cEquipe	:=	If(cMenVar == "M->Z94_EQUIPE",M->Z94_EQUIPE,GdFieldGet("Z94_EQUIPE",_nAt))

	/*
	_aCacos
	[1] = Baia
	[2] = Soma da Producao na Baia
	*/

	If _cFormat $ "B9/BO/C6" .And. _nProd == 0
		RestArea(_aArea)
		GdFieldPut("Z94_CACOAJ",_nCaco,_nAt)
		GdFieldPut("Z94_PRCACO",1,_nAt)
		Return
	EndIf

	For _nI	:=	1 to Len(_oGdDbClk:aCols)

		_nPeso := fCalcPes(Iif(_nI==_nAt,_cFormat,GdFieldGet("Z94_FORMAT",_nI)),;
		Iif(_nI==_nAt,_cTurno,GdFieldGet("Z94_TURNO",_nI)),;
		Iif(_nI==_nAt,_cEquipe,GdFieldGet("Z94_EQUIPE",_nI)))

		If (_nPos := aScan(_aCacos,{|x| x[1] == Iif(_nI==_nAt,_cBaia,GdFieldGet("Z94_BAIA",_nI)) .and. x[2] == Iif(_nI==_nAt,_cTurno,GdFieldGet("Z94_TURNO",_nI)) })) > 0

			_aCacos[_nPos,4] +=	Iif(_nI==_nAt,_nProd,GdFieldGet("Z94_PRODUC",_nI)) * _nPeso /1000 

		Else

			aAdd(_aCacos,{Iif(_nI==_nAt,_cBaia,GdFieldGet("Z94_BAIA",_nI)),Iif(_nI==_nAt,_cTurno,GdFieldGet("Z94_TURNO",_nI)),Iif(_nI==_nAt,_cEquipe,GdFieldGet("Z94_EQUIPE",_nI)),Iif(_nI==_nAt,_nProd,GdFieldGet("Z94_PRODUC",_nI)) * _nPeso/1000})

		EndIf 
	Next

	For _nI	:=	1 to Len(_oGdDbClk:aCols)

		_nPeso := fCalcPes(Iif(_nI==_nAt,_cFormat,GdFieldGet("Z94_FORMAT",_nI)),;
		Iif(_nI==_nAt,_cTurno,GdFieldGet("Z94_TURNO",_nI)),;
		Iif(_nI==_nAt,_cEquipe,GdFieldGet("Z94_EQUIPE",_nI)))

		If (_nPos := aScan(_aCacos,{|x| x[1] == Iif(_nI==_nAt,_cBaia,GdFieldGet("Z94_BAIA",_nI)) .and. x[2] == Iif(_nI==_nAt,_cTurno,GdFieldGet("Z94_TURNO",_nI))  })) > 0

			_nValor	:=	Iif(_nI==_nAt,_nCaco,GdFieldGet("Z94_CACO",_nI)) * ; //CACO
			Iif(_nI==_nAt,_nProd,GdFieldGet("Z94_PRODUC",_nI)) * _nPeso /1000 / ; //Produção da linha em Toneladas
			_aCacos[_nPos,4]	//Soma das Produções para aquela baia

			RestArea(_aArea)

			GdFieldPut("Z94_CACOAJ",_nValor,_nI)

			_nPerCaco	:=	_nValor / ; //Caco Ajustado
			(Iif(_nI==_nAt,_nProd,GdFieldGet("Z94_PRODUC",_nI)) * _nPeso /1000 +; //Produção da Linha em Toneladas
			_nValor)
			GdFieldPut("Z94_PRCACO",_nPerCaco,_nI)

		EndIf

	Next

Return

Static Function fCalcPes(cFormat, cTurno, cEquipe)

	Local _nPeso		:=	0
	Local _cAliasPes	:=	GetNextALias()
	Local _cData		:= DtoS(_oCalend:aCell[_oCalend:nAt][DATADIA])	
	Local _aArea		:=	GetArea()
	BeginSql Alias _cAliasPes

		SELECT 	
		CASE
		WHEN SB1.B1_YFORMAT NOT IN ( 'B9', 'BO', 'C6' ) THEN ( CASE 
		WHEN ISNULL(SUM(Z75_QUANT),0) > 0 THEN ISNULL(SUM(Z75_QUANT * B1_PESO), 0)/ ISNULL(SUM(Z75_QUANT),0) 
		ELSE 0
	END)
	WHEN SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' ) THEN ( CASE 
	WHEN ISNULL(SUM(Z75_BKQTD),0) > 0 THEN ISNULL(SUM(Z75_BKQTD * B1_PESO), 0)/ ISNULL(SUM(Z75_BKQTD),0) 
	ELSE 0
	END)
	ELSE 0 
	END PESO
	FROM    %TABLE:Z75% Z75
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
	AND B1_YFORMAT = %Exp:cFormat%
	AND SB1.D_E_L_E_T_ = ' '
	WHERE   Z75_FILIAL = %XFILIAL:Z75%
	AND Z75_DATARF = %Exp:_cData%
	AND Z75.Z75_TURNO = %EXP:cTurno%
	AND Z75_TPMOV IN ('ETQ','RET')
	AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE', 'BW','BV','CC','CD') AND Z75_TPPROD = 'PP') OR ( B1_YFORMAT NOT IN('BM', 'BF', 'BD', 'BE','BW','BV','CC','CD') AND Z75_TPPROD <> 'PP') )
	AND ( ( SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = '1'
	AND Z75.Z75_BKEQUI = %Exp:cEquipe%
	)
	OR ( SB1.B1_YFORMAT NOT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = %Exp:cEquipe%
	)
	)
	AND Z75.%NotDel%
	GROUP BY SB1.B1_YFORMAT

	EndSql

	_nPeso	:=	(_cAliasPes)->PESO

	(_cAliasPes)->(DbCloseArea())

	RestArea(_aArea)

Return _nPeso

Static Function ValidPerg()

	local cLoad	    := "BIAFG006" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := Stod("")

	aAdd( aPergs ,{1,"Data Referência " 	   		,MV_PAR01 ,"99"  ,"NAOVAZIO()",''  ,'.T.',20,.F.})	

	If ParamBox(aPergs ,"Caco Realizado",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet
