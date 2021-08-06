#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA105
@description Ponto de entrada para validação da linha dos lançamentos contabeis
@author Marcos Alberto Soprani
@since 03/08/21
@Obs Clone do Programa CT105LOK
@type function
/*/
User Function BIA105()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Reprocessamento Drivers e adjacentes"

	Private dDataIni
	Private dDataFin
	Private msEnter     := CHR(13) + CHR(10)
	Private msEmpAtu    := cEmpAnt
	Private msFilAtu    := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc    := .F.
	Private xVerRet     := .T.
	Private msErroQuery := ""
	Private msVetImp    := ""
	Private msImpArry   := {}
	Private msArryEmp   := {}

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

		//Chamada de tela para seleção da Empresa/Filial
		oEmp:GSEmpFil()		
		msArryEmp := oEmp:aEmpSel

		If Len(msArryEmp) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			//Begin Transaction

			For nW := 1 To Len(msArryEmp)

				RpcSetType(3)
				RpcSetEnv( msArryEmp[nW][1], Substr(msArryEmp[nW][2], 1, 2) )

				smMsnPrc := msArryEmp[nW][1] + "/" + Substr(msArryEmp[nW][2], 1, 2) + " - " + Alltrim(msArryEmp[nW][4])

				oProcess := MsNewProcess():New({|lEnd| Prc105EX(@oProcess) }, "Gravando...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet

				If !xVerRet

					//DisarmTransaction()
					msCanPrc  := .F.
					Exit

				EndIf

				RpcClearEnv()

			Next nW

			//End Transaction

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			MsgINFO("Fim do Processamento!!!" + msEnter + msEnter + Alltrim(ElapTime(hhTmpINI, TIME())), "Atenção!!!")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIA105" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Reprocessamento Drivers",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

Static Function Prc105EX(oProcess)

	Local aArea   := GetArea()
	Local lOK     := .T.
	Local xContad := 0
	Local pContad := 0
	Local lRet    := .T.

	X001 := GetNextAlias()
	mxSql := " SELECT CONTAD = COUNT(*) "
	mxSql += " FROM " + RetSqlName("CT2") + " CT2(NOLOCK) "
	mxSql += " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' "
	mxSql += "       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
	mxSql += "       AND CT2.D_E_L_E_T_ = ' ' "
	TcQuery mxSql New Alias (X001)

	If !(X001)->(Eof())

		xContad := (X001)->CONTAD

	EndIf
	(X001)->(DbCloseArea())

	If xContad > 0

		oProcess:SetRegua1(1)
		oProcess:SetRegua2(xContad)

		M001 := GetNextAlias()
		msSql := " SELECT REGCT2 = CT2.R_E_C_N_O_ "
		msSql += " FROM " + RetSqlName("CT2") + " CT2(NOLOCK) "
		msSql += " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' "
		msSql += "       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
		msSql += "       AND CT2.D_E_L_E_T_ = ' ' "
		TcQuery msSql New Alias (M001)

		oProcess:IncRegua1(smMsnPrc)
		While !(M001)->(Eof())

			pContad ++
			sContad := xContad - pContad 
			oProcess:IncRegua2("Reproc., LP: " + CT2->CT2_LP + " Lote:" + CT2->CT2_LOTE + " Faltantes:" + Alltrim(Str(sContad)) )

			dbSelectArea("CT2")
			dbGoTo( (M001)->REGCT2 )

			cTipo    := CT2->CT2_DC
			cDebito  := CT2->CT2_DEBITO
			cCredito := CT2->CT2_CREDIT

			cCCcred  := CT2->CT2_CCC
			cCCdeb   := CT2->CT2_CCD

			cICcred  := CT2->CT2_ITEMC
			cICdeb   := CT2->CT2_ITEMD

			cCVcred  := CT2->CT2_CLVLCR
			cCVdeb   := CT2->CT2_CLVLDB

			cATIVDeb := CT2->CT2_ATIVDE
			cATIVCrd := CT2->CT2_ATIVCR

			If Alltrim(CT2->CT2_ROTINA) == 'GPEM110' .or. ( Alltrim(CT2->CT2_ROTINA) == 'CTBA500' .and. CT2->CT2_LP = "200" )

				Reclock("CT2", .F.)
				IF !Empty(cCredito) .And. !Empty(cCVcred)
					_cDriver        := fGetDrvPad(CT2->CT2_DATA,"RH")
					If Empty(CT2->CT2_YDRVCR)
						CT2->CT2_AT02CR := 'DRV-OLD'
						CT2->CT2_AT03CR := CT2->CT2_YDRVCR
						CT2->CT2_YDRVCR := _cDriver
					EndIf
				EndIf
				IF !Empty(cDebito) .And. !Empty(cCVdeb)
					_cDriver        := fGetDrvPad(CT2->CT2_DATA,"RH")
					If Empty(CT2->CT2_YDRVDB)
						CT2->CT2_AT02DB := 'DRV-OLD'
						CT2->CT2_AT03DB := CT2->CT2_YDRVDB
						CT2->CT2_YDRVDB := _cDriver
					EndIf
				EndIf
				CT2->(MsUnlock())

				Reclock("CT2", .F.)
				Do Case
					CASE SUBSTR(cCvCred,1,3) $ '319_329'  .Or. SUBSTR(cCvDeb,1,3) $ '319_329'
					If Empty(CT2->CT2_YAPLIC)
						CT2->CT2_AT01DB := 'APL-OLD'
						CT2->CT2_AT01CR := CT2->CT2_YAPLIC
						CT2->CT2_YAPLIC	:=	'1'
					EndIf
					CASE SUBSTR(cCvCred,1,1) $ '3' .Or. SUBSTR(cCvDeb,1,1) $ '3'
					If Empty(CT2->CT2_YAPLIC)
						CT2->CT2_AT01DB := 'APL-OLD'
						CT2->CT2_AT01CR := CT2->CT2_YAPLIC
						CT2->CT2_YAPLIC	:=	'2'
					EndIf
					OtherWise
					If Empty(CT2->CT2_YAPLIC)
						CT2->CT2_AT01DB := 'APL-OLD'
						CT2->CT2_AT01CR := CT2->CT2_YAPLIC
						CT2->CT2_YAPLIC	:=	'0'
					EndIf
				EndCase
				CT2->(MsUnlock())

			EndIf

			If Alltrim(CT2->CT2_ROTINA) == "MATA103" .Or. Alltrim(CT2->CT2_ROTINA) == 'MATA330' .Or. Alltrim(CT2->CT2_ROTINA) == 'MATA331'

				fGravaApli()

				fGravaSubItem()

			EndIf

			//TICKET 22710 - Incluindo bloco abaixo com intencao de preencher o campo CT2_YAPLIC para LP de Faturamento quando RPV que usa CV de CUSTO
			If Alltrim(CT2->CT2_ROTINA) == "MATA460A" .Or. Alltrim(CT2->CT2_ROTINA) == "MATA460" .Or. Alltrim(CT2->CT2_ROTINA) == 'BACP0010' .Or. Alltrim(CT2->CT2_ROTINA) == 'BACP0014' .Or. CT2->CT2_LOTE == "008820"

				Reclock("CT2", .F.)
				Do Case
					CASE SUBSTR(cCvCred,1,1) $ '3' .Or. SUBSTR(cCvDeb,1,1) $ '3'
					If Empty(CT2->CT2_YAPLIC)
						CT2->CT2_AT01DB := 'APL-OLD'
						CT2->CT2_AT01CR := CT2->CT2_YAPLIC
						CT2->CT2_YAPLIC	:=	'1'
						CT2->CT2_TPSALD :=  "1"  //para tentar forçar a não gerar como pre-lancamento
					EndIf
					OtherWise
					If Empty(CT2->CT2_YAPLIC)
						CT2->CT2_AT01DB := 'APL-OLD'
						CT2->CT2_AT01CR := CT2->CT2_YAPLIC
						CT2->CT2_YAPLIC	:=	'0'
					EndIf
				EndCase
				CT2->(MsUnlock())

			EndIf
			//FIM >>> TICKET 22710

			If Alltrim(CT2->CT2_ROTINA) $ "BIACTBAV/MATA330" .and. CT2->CT2_LOTE = '008840'

				msRegSD3 := ""
				If CT2->CT2_LP = '668'.and. "666001 CANC" $ CT2->CT2_ORIGEM
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 50, 8)

				ElseIf CT2->CT2_LP = '668' .and. "668002" $ CT2->CT2_ORIGEM
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 50, 8)

				ElseIf CT2->CT2_LP = '668'
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 51, 8)

				ElseIf CT2->CT2_LP = '666' .and. "666002" $ CT2->CT2_ORIGEM
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 50, 8)

				ElseIf CT2->CT2_LP = '666'
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 51, 8)

				ElseIf CT2->CT2_LP = '66Z'
					msRegSD3 := Substr(CT2->CT2_ORIGEM, 39, 8)

				EndIf

				SD3->(dbGoTo(Val(Alltrim(msRegSD3))))
				_cAplic	  := SD3->D3_YAPLIC
				_cDriver  := SD3->D3_YDRIVER
				_cSubItem := SD3->D3_YSUBITE

				Reclock("CT2", .F.)
				If Empty(CT2->CT2_YAPLIC)
					CT2->CT2_AT01DB := 'APL-OLD'
					CT2->CT2_AT01CR := CT2->CT2_YAPLIC
					CT2->CT2_YAPLIC   := _cAplic
				EndIf
				If !Empty(CT2->CT2_CLVLCR) .And. Empty(CT2->CT2_YDRVCR)
					CT2->CT2_AT02CR := 'DRV-OLD'
					CT2->CT2_AT03CR := CT2->CT2_YDRVCR
					CT2->CT2_YDRVCR := _cDriver
				EndIf
				If !Empty(CT2->CT2_CLVLDB) .And. Empty(CT2->CT2_YDRVDB)
					CT2->CT2_AT02DB := 'DRV-OLD'
					CT2->CT2_AT03DB := CT2->CT2_YDRVDB
					CT2->CT2_YDRVDB   := _cDriver
				EndIf
				If !Empty(CT2->CT2_CLVLCR) .And. Empty(CT2->CT2_YSUBCR)
					CT2->CT2_AT04CR := 'SUB-OLD ' + CT2->CT2_YSUBCR 
					CT2->CT2_YSUBCR := _cSubItem
				EndIf
				If !Empty(CT2->CT2_CLVLDB) .And. Empty(CT2->CT2_YSUBDB)
					CT2->CT2_AT04DB := 'SUB-OLD ' + CT2->CT2_YSUBDB 
					CT2->CT2_YSUBDB := _cSubItem
				EndIf		
				CT2->(MsUnlock())

			EndIf

			If ( Alltrim(CT2->CT2_ROTINA) == 'BIACTBAV' .and. CT2->CT2_LOTE == '009004') .or. ( Alltrim(CT2->CT2_ROTINA) == 'BIACTBAV' .and. CT2->CT2_LOTE == '009007')
				Reclock("CT2", .F.)
				If Empty(CT2->CT2_YAPLIC)
					CT2->CT2_AT01DB := 'APL-OLD'
					CT2->CT2_AT01CR := CT2->CT2_YAPLIC
					CT2->CT2_YAPLIC   := "1"
				EndIf
				CT2->(MsUnlock())
			EndIf

			(M001)->(DbSkip())

		End

		(M001)->(DbCloseArea())

	EndIf

	RestArea(aArea)

	xVerRet := lRet

Return(lOK)

Static Function fGravaApli()

	Local _aArea    :=GetArea()
	Local _cKey     := ""
	Local _cAlias   := ""
	Local _nOrder   := 0
	Local _cAplic   := ""
	Local _cDriver  := ""

	CTL->( dbSetOrder(1) )
	If CTL->( dbSeek( xFilial("CTL") + CT2->CT2_LP ) )

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey   := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1"

			&(_cAlias)->( dbSetOrder(_nOrder) )
			If &(_cAlias)->( dbSeek( Alltrim(CT2->CT2_KEY) ) )

				If Alltrim(_cAlias) == "SD3"
					_cAplic		:=	SD3->D3_YAPLIC
					_cDriver	:=	SD3->D3_YDRIVER
				ElseIf Alltrim(_cAlias) == "SD1"
					_cAplic		:=	SD1->D1_YAPLIC
					_cDriver	:=	SD1->D1_YDRIVER
				Else
					RestArea(_aArea)
					Return
				EndIf

				Reclock("CT2", .F.)
				If Empty(CT2->CT2_YAPLIC)
					CT2->CT2_AT01DB := 'APL-OLD'
					CT2->CT2_AT01CR := CT2->CT2_YAPLIC
					CT2->CT2_YAPLIC   := _cAplic
				EndIf
				If !Empty(CT2->CT2_CLVLCR) .and. Empty(CT2->CT2_YDRVCR)
					CT2->CT2_AT02CR := 'DRV-OLD'
					CT2->CT2_AT03CR := CT2->CT2_YDRVCR
					CT2->CT2_YDRVCR := _cDriver
				EndIf
				If !Empty(CT2->CT2_CLVLDB) .and. Empty(CT2->CT2_YDRVDB)
					CT2->CT2_AT02DB := 'DRV-OLD'
					CT2->CT2_AT03DB := CT2->CT2_YDRVDB
					CT2->CT2_YDRVDB   := _cDriver
				EndIf
				CT2->(MsUnlock())

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return

Static Function fGravaSubItem()

	Local _aArea    := GetArea()
	Local _cKey     := ""
	Local _cAlias   := ""
	Local _nOrder   := 0

	CTL->(dbSetOrder(1))
	If CTL->(dbSeek(xFilial("CTL") + CT2->CT2_LP))

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey   := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1/SE2"

			&(_cAlias)->(dbSetOrder(_nOrder))
			If &(_cAlias)->(dbSeek(Alltrim(CT2->CT2_KEY)))

				If Alltrim(_cAlias) == "SD3"
					_cSubItem	:= SD3->D3_YSUBITE
				ElseIf Alltrim(_cAlias) == "SD1"
					_cSubItem	:= SD1->D1_YSUBITE
				ElseIf Alltrim(_cAlias) == "SE2"
					_cSubItem	:= SE2->E2_YSUBITE
				EndIf

				Reclock("CT2", .F.)
				If !Empty(CT2->CT2_CLVLCR) .and. Empty(CT2->CT2_YSUBCR)
					CT2->CT2_AT04CR := 'SUB-OLD ' + CT2->CT2_YSUBCR 
					CT2->CT2_YSUBCR := _cSubItem
				EndIf
				If !Empty(CT2->CT2_CLVLDB) .and. Empty(CT2->CT2_YSUBDB)
					CT2->CT2_AT04DB := 'SUB-OLD ' + CT2->CT2_YSUBDB 
					CT2->CT2_YSUBDB := _cSubItem
				EndIf
				CT2->(MsUnlock())

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return()

Static Function fGetDrvPad(_dDtRef,_cTpOrc)

	Local _cDriver	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _cAnoRef	:=	SUBSTR(DtoS(_dDtRef),1,4)
	Local _cOrca	:=	"ORCA_" + SUBSTR(DtoS(_dDtRef),3,2) 

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZBE_DRIVER), '') ZBE_DRIVER
		FROM %TABLE:ZBE% ZBE
		WHERE ZBE.ZBE_FILIAL = %XFILIAL:ZBE%
		AND ZBE.ZBE_APLDEF = %Exp:_cTpOrc%
		AND ZBE.ZBE_ANOREF = %Exp:_cAnoRef%
		AND ZBE.ZBE_VERSAO = %Exp:_cOrca%
		AND ZBE.ZBE_REVISA = (
		SELECT MAX(ZBEREV.ZBE_REVISA)
		FROM %TABLE:ZBE% ZBEREV
		WHERE ZBEREV.ZBE_FILIAL = ZBE.ZBE_FILIAL
		AND ZBEREV.ZBE_ANOREF = ZBE.ZBE_ANOREF
		AND ZBEREV.ZBE_VERSAO = ZBE.ZBE_VERSAO
		AND ZBEREV.%NotDel%
		AND ZBEREV.ZBE_APLDEF = ZBE.ZBE_APLDEF
		)
		AND ZBE.%NotDel%
	EndSql

	_cDriver	:=	(_cAlias)->ZBE_DRIVER

	(_cAlias)->(DbCloseArea())

Return _cDriver
