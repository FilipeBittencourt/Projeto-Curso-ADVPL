#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BIA719
@author Marcos Alberto Soprani
@since 20/12/18
@version 1.0
@description Cadastro de Drivers Contábeis
@type function
/*/

User Function BIA719()

	Local oBrowse 		:= Nil
	Local aArea 		:= GetArea()
	Private cCadastro 	:= 'Cadastro de Drivers Contábeis'

	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias('ZBE')
	oBrowse:SetMenuDef('BIA719')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return

Static Function MenuDef

	Local aRotina := {}

	Add Option aRotina Title 'Pesquisar' 		Action 'AxPesqui' 		  	            Operation 1 Access 0
	Add Option aRotina Title 'Visualizar' 		Action 'VIEWDEF.BIA719' 	            Operation 2 Access 0
	Add Option aRotina Title 'Incluir' 			Action 'VIEWDEF.BIA719' 	            Operation 3 Access 0
	Add Option aRotina Title 'Alterar' 			Action 'VIEWDEF.BIA719' 	            Operation 4 Access 0
	Add Option aRotina Title 'Excluir' 			Action 'VIEWDEF.BIA719' 	            Operation 5 Access 0
	Add Option aRotina Title "Importar Driver"  Action 'ExecBlock("BIA719IMP",.F.,.F.)' Operation 6 Access 0
	Add Option aRotina Title "Limpar Driver"    Action 'ExecBlock("BIA719LMP",.F.,.F.)' Operation 7 Access 0
	Add Option aRotina Title "Driver to OBZ"    Action 'ExecBlock("BIA719Z98",.F.,.F.)' Operation 8 Access 0
	//Add Option aRotina Title 'Imprimir' 		Action 'VIEWDEF.BIA719' 	            Operation 9 Access 0

Return(aRotina)

Static Function ModelDef

	Local oModel 	:= Nil
	Local oStruHead	:= FwFormStruct(1,'ZBE')
	Local oStruGrid := FwFormStruct(1,'ZBN')

	//Monta o modelo principal
	oModel	:= MpFormModel():New('BIA719MVC',/*PreValidacao*/,{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)})

	//Monta os dados do cabeçalho
	oModel:AddFields('ModelHead',,oStruHead)
	oModel:SetPrimaryKey({"ZBE_FILIAL", "ZBE_VERSAO", "ZBE_REVISA", "ZBE_ANOREF", "ZBE_DRIVER"})

	oModel:GetModel('ModelHead'):SetDescription('Driver')

	//Monta os dados dos itens
	oModel:AddGrid('ModelGrid','ModelHead',oStruGrid,,/*bLinOk*/,/*bPreGrid*/,/*bProsGrid*/)
	oModel:SetRelation('ModelGrid',{ {"ZBN_FILIAL","ZBE_FILIAL"},{"ZBN_VERSAO","ZBE_VERSAO"}, {"ZBN_REVISA","ZBE_REVISA"}, {"ZBN_ANOREF","ZBE_ANOREF"}, {"ZBN_DRIVER","ZBE_DRIVER"} }, ZBN->(IndexKey(1)) )

	oModel:GetModel('ModelGrid'):SetDescription('Contábeis')
	oModel:GetModel('ModelGrid'):SetDelAllLine(.T.)
	oModel:GetModel('ModelGrid'):SetOptional(.T.)
	oModel:GetModel('ModelGrid'):SetUniqueLine({'ZBN_CONTA','ZBN_CLVL'})

	//Seta o nome da rotina na enchoice
	oModel:SetDescription('Cadastro de Drivers Contábeis')

Return(oModel)

Static Function ViewDef

	Local oView		:= Nil
	Local oModel	:= FwLoadModel('BIA719')
	Local oStruHead	:= FwFormStruct(2,'ZBE')
	Local oStruGrid := FwFormStruct(2,'ZBN')

	//Não exibe o folder visual caso algum campo esteja inserido em um
	oStruHead:SetNoFolder()

	oView:= FwFormView():New()
	oView:SetModel(oModel)

	//Crio o cabeçalho e os grids de acordo com o modelo
	oView:AddField('ViewHead', oStruHead, 'ModelHead')
	oView:AddGrid ('ViewGrid', oStruGrid, 'ModelGrid')

	//Crio uma layer com 20% da tela e outra com 80% da tela, similar a FwLayer
	oView:CreateHorizontalBox('MAIN',30)
	oView:CreateHorizontalBox('GRID',70)

	//Informo os devidos títulos das telas
	oView:EnableTitleView('ViewHead','Driver')
	oView:EnableTitleView('ViewGrid','Contábeis')

	//Informo a porcentagem da tela que cada view deve ocupar
	oView:SetOwnerView('ViewHead','MAIN')
	oView:SetOwnerView('ViewGrid','GRID')

Return(oView)

Static Function fTudoOK(oModel)

	Local lRet		:= .T.
	Local nX   		:= 0
	local nOpc 		:= oModel:GetOperation()
	Local oField    := oModel:GetModel("ModelHead")
	Local oGrid     := oModel:GetModel("ModelGrid")
	Local cVersao	:= oField:GetValue('ZBE_VERSAO')
	Local cRevisa	:= oField:GetValue('ZBE_REVISA')
	Local cAnoref	:= oField:GetValue('ZBE_ANOREF')
	Local cDriver	:= oField:GetValue('ZBE_DRIVER')

	Local nRecno	:=	ZBE->(RECNO())

	Local cConta
	Local cClvl

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		If nOpc == MODEL_OPERATION_INSERT 

			ZBE->(DbSetOrder(1))
			If ZBE->(DbSeek(xFilial("ZBE")+cVersao+cRevisa+cAnoRef+cDriver))
				MsgInfo("O registro de Driver já existe no cadastro, favor alterar o existente!")
				ZBE->(DbGoto(nRecno))
				Return .F.
			EndIf
		EndIf

		ZBE->(DbGoto(nRecno))

		For nX := 1 To oGrid:GetQtdLine()

			oGrid:GoLine(nX)

			cConta	:=	oGrid:GetValue('ZBN_CONTA')
			cClVl	:=	oGrid:GetValue('ZBN_CLVL')

			if !oGrid:IsDeleted()
				lRet := fVerZBZ(cVersao,cRevisa,cAnoref,cDriver,cConta,cClvl)
			endif	
			If !lRet
				Msginfo("Já existe configuração no orçamento para driver "+cDriver+", conta "+ cConta +" e classe de valor "+cClvl+"!")			
				Exit
			EndIf

		Next nX	

	endif

Return lRet

Static Function fVerZBZ(cVersao,cRevisa,cAnoref,cDriver,cConta,cClvl)

	Local _lRet	:=	.T.
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT COUNT(*)QTD
		FROM %TABLE:ZBZ% ZBZ
		WHERE ZBZ_FILIAL = %XFILIAL:ZBZ%
		AND ZBZ_VERSAO = %Exp:cVersao%
		AND ZBZ_REVISA = %Exp:cRevisa%
		AND ZBZ_ANOREF = %Exp:cAnoRef%
		AND ((ZBZ_DRVDB = %Exp:cDriver% 
		AND ZBZ_DEBITO = %Exp:cConta%
		AND ZBZ_CLVLDB = %Exp:cClVl%
		) 
		OR (ZBZ_DRVCR = %Exp:cDriver% 
		AND ZBZ_CREDIT = %Exp:cConta%
		AND ZBZ_CLVLCR = %Exp:cClVl%
		) 
		)  
		AND %NotDel%

	EndSql

	If (_cAlias)->QTD > 0
		_lRet	:=	.F.
	EndIf

	(_cAlias)->(DbCloseArea())

Return _lRet

Static Function fCommit(oModel)

	Local nX   		 := 0
	Local nY		 := 0
	local nOpc 		 := oModel:GetOperation()
	Local oForm		 := oModel:GetModel('ModelHead')
	Local oGrid		 := oModel:GetModel('ModelGrid')
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	If(nOpc == MODEL_OPERATION_INSERT)

		RecLock('ZBE',.T.)

		ZBE->ZBE_FILIAL	:=	xFilial("ZBE")
		For nY := 1 To Len(aCposForm)

			If(ZBE->(FieldPos(aCposForm[nY,3])) > 0)

				If(aCposForm[nY,3] = 'ZBE_FILIAL')

					ZBE->&(aCposForm[nY,3]) := xFilial("ZBE")
				Else
					ZBE->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
				EndIf

			EndIf

		Next nY

		ZBE->(MsUnlock())

		For nX := 1 To oGrid:GetQtdLine()

			oGrid:GoLine(nX)

			RecLock('ZBN',.T.)
			For nY := 1 To Len(aCposGrid)

				ZBN->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

			Next nY

			ZBN->ZBN_FILIAL	:=	xFilial("ZBN")
			ZBN->ZBN_VERSAO	:=	ZBE->ZBE_VERSAO
			ZBN->ZBN_REVISA	:=	ZBE->ZBE_REVISA
			ZBN->ZBN_ANOREF	:=	ZBE->ZBE_ANOREF
			ZBN->ZBN_DRIVER	:=	ZBE->ZBE_DRIVER
			ZBN->(MsUnlock())

		Next

	ElseIf(nOpc == MODEL_OPERATION_UPDATE)

		RecLock('ZBE',.F.)

		For nY := 1 To Len(aCposForm)

			If(ZBE->(FieldPos(aCposForm[nY,3])) > 0)

				ZBE->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

			EndIf

		Next nY

		ZBE->(MsUnlock())

		For nX := 1 To oGrid:GetQtdLine()

			oGrid:GoLine(nX)
			ZBN->(DbGoTo(oGrid:GetDataID()))

			If(oGrid:IsDeleted())

				If ZBN->(!EOF())

					RecLock('ZBN',.F.)
					ZBN->(DbDelete())
					ZBN->(MsUnlock())

				EndIf
			Else

				RecLock('ZBN',ZBN->(EoF()))

				For nY := 1 To Len(aCposGrid)

					ZBN->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

				Next nY

				ZBN->ZBN_FILIAL	:=	xFilial("ZBN")
				ZBN->ZBN_VERSAO	:=	ZBE->ZBE_VERSAO
				ZBN->ZBN_REVISA	:=	ZBE->ZBE_REVISA
				ZBN->ZBN_ANOREF	:=	ZBE->ZBE_ANOREF
				ZBN->ZBN_DRIVER	:=	ZBE->ZBE_DRIVER

				ZBN->(MsUnlock())

			EndIf

		Next

	ElseIf(nOpc == MODEL_OPERATION_DELETE)

		RecLock('ZBE',.F.)
		ZBE->(DbDelete())
		ZBE->(MsUnlock())

		For nX := 1 To oGrid:GetQtdLine()

			oGrid:GoLine(nX)
			ZBN->(DbGoTo(oGrid:GetDataID()))

			If ZBN->(!EOF())
				RecLock('ZBN',.F.)
				ZBN->(DbDelete())
				ZBN->(MsUnlock())
			EndIf
		Next

	Endif

Return .T.

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA719IMP ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 26.12.19 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA719IMP()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBE") + SPACE(TAMSX3("ZBE_VERSAO")[1]) + SPACE(TAMSX3("ZBE_REVISA")[1]) + SPACE(TAMSX3("ZBE_ANOREF")[1])
	Local bWhile	    := {|| ZBE_FILIAL + ZBE_VERSAO + ZBE_REVISA + ZBE_ANOREF }   

	Local aNoFields     := {"ZBE_VERSAO" ,"ZBE_REVISA" ,"ZBE_ANOREF" ,"ZBE_DRIVER" ,"ZBE_APLDEF" ,"ZBE_ORGDRV"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBE_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBE_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBE_ANOREF")[1])
	Private _oGAnoRef

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B719IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBE",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Drivers" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA719A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA719B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA719C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B719FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B719DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA719A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA719B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA719C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA719D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e anterior à data do dia"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'F'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:lInsert := .T.
	_oGetDados:lUpdate := .T.
	_oGetDados:lDelete := .T.

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:ZBE% ZBE
		WHERE ZBE_FILIAL = %xFilial:ZBE%
		AND ZBE_VERSAO = %Exp:_cVersao%
		AND ZBE_REVISA = %Exp:_cRevisa%
		AND ZBE_ANOREF = %Exp:_cAnoRef%
		AND ZBE.%NotDel%
		) NUMREG
		FROM %TABLE:ZBE% ZBE
		WHERE ZBE_FILIAL = %xFilial:ZBE%
		AND ZBE_VERSAO = %Exp:_cVersao%
		AND ZBE_REVISA = %Exp:_cRevisa%
		AND ZBE_ANOREF = %Exp:_cAnoRef%
		AND ZBE.%NotDel%
		ORDER BY ZBE_VERSAO, ZBE_REVISA, ZBE_ANOREF, ZBE_DRIVER

	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBE_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBE"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBE_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI
	Local _msc
	Local msAlias := GetNextAlias()

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBE_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	
	Local msLastDrv := Space(9)

	BeginSql Alias msAlias

		SELECT MAX(ZBE_DRIVER) LASTNDRV
		FROM %TABLE:ZBE% ZBE
		WHERE ZBE_FILIAL = %xFilial:ZBE%
		AND ZBE.%NotDel%

	EndSql
	msLastDrv :=  (msAlias)->(LASTNDRV)
	(msAlias)->(dbCloseArea())

	dbSelectArea('ZBE')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBE->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBE",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBE->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				ZBE->(DbDelete())

			EndIf

			ZBE->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				msLastDrv := Soma1(msLastDrv)

				Reclock("ZBE",.T.)

				ZBE->ZBE_FILIAL  := xFilial("ZBE")
				ZBE->ZBE_VERSAO  := _cVersao
				ZBE->ZBE_REVISA  := _cRevisa
				ZBE->ZBE_ANOREF  := _cAnoRef
				ZBE->ZBE_DRIVER  := msLastDrv
				ZBE->ZBE_ORGDRV  := "O"
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBE->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				ZBE->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao            := SPACE(TAMSX3("ZBE_VERSAO")[1])
	_cRevisa            := SPACE(TAMSX3("ZBE_REVISA")[1])
	_cAnoRef            := SPACE(TAMSX3("ZBE_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B719IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B719IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Índices de Variação da Quantidade da Pre-Estr."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B719IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBE'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBE_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBE_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
							EndIf
						EndIf

					Next _msc

					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA719Z98 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 26.12.19 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA719Z98()

	Local _aSize        := {} 
	Local _aObjects     := {}
	Local _aInfo        := {}
	Local _aPosObj      := {}

	Local _aHeader      := {}
	Local _aCols        := {}

	Local cSeek         := xFilial("Z98") + SPACE(TAMSX3("Z98_VERSAO")[1]) + SPACE(TAMSX3("Z98_REVISA")[1]) + SPACE(TAMSX3("Z98_ANOREF")[1])
	Local bWhile        := {|| Z98_FILIAL + Z98_VERSAO + Z98_REVISA + Z98_ANOREF }   

	//Local aNoFields     := {"Z98_VERSAO" ,"Z98_REVISA" ,"Z98_ANOREF" ,"Z98_DRIVER" ,"Z98_APLDEF" ,"Z98_ORGDRV"}
	lOCAL aYesFields    := {"Z98_IDDRV"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA        := 0
	Local _aButtons     := {}

	Private _oDlg
	Private _oGetDados  := Nil
	Private _aColsBkp   := {}
	Private _cVersao    := SPACE(TAMSX3("Z98_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa    := SPACE(TAMSX3("Z98_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef    := SPACE(TAMSX3("Z98_ANOREF")[1])
	Private _oGAnoRef

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B719Z98D() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z98",1,cSeek,bWhile,,/*aNoFields*/,aYesFields,,,,,@_aHeader,@_aCols)
	_aColsBkp := aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Drivers" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fZ98719A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fZ98719B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fZ98719C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B719FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B719DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fZ98Dados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fZ98719A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fZ98719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fZ98719B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fZ98719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fZ98719C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fZ98719D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fZ98719D()

	Local M001        := GetNextAlias()

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e anterior à data do dia"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'F'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf
	(M001)->(dbCloseArea())

	_oGetDados:lInsert := .T.
	_oGetDados:lUpdate := .T.
	_oGetDados:lDelete := .T.

	_oGetDados:aCols   := {}

	//========================================================
	// Caso suja a necessidade de implementar alguma tratativa
	// de carga, aqui é o ponto.
	//========================================================

	_oGetDados:aCols   := aClone(_aColsBkp)

	_oGetDados:Refresh()

Return .T.

Static Function fZ98Dados()

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})

	Local nPosDel   := Len(_oGetDados:aHeader) + 1

	dbSelectArea('Z98')
	For _nI := 1 to Len(_oGetDados:aCols)

		If !_oGetDados:aCols[_nI,nPosDel]

			Z98->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z98",.F.)
			For _msc := 1 to Len(_oGetDados:aHeader)

				If _oGetDados:aHeader[_msc][10] == "R"

					nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
					&("Z98->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

				EndIf

			Next _msc

			Z98->(MsUnlock())

		EndIf

	Next

	_cVersao            := SPACE(TAMSX3("Z98_VERSAO")[1])
	_cRevisa            := SPACE(TAMSX3("Z98_REVISA")[1])
	_cAnoRef            := SPACE(TAMSX3("Z98_ANOREF")[1])
	_oGetDados:aCols    := aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B719Z98D ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B719Z98D()

	Local aSays         := {}
	Local aButtons      := {}
	Local lConfirm      := .F.
	Private cArquivo    := space(100)

	fZ98Perg()

	AADD(aSays, OemToAnsi("Rotina para importação de Índices de Variação da Quantidade da Pre-Estr."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))

	AADD(aButtons, { 5,.T.,{|| fZ98Perg() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fPZ98Import() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf

Return

//Parametros
Static Function fZ98Perg()

	Local aPergs    := {}
	Local cLoad     := 'B719Z98D' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo        := space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: "   ,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fPZ98Import()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'Z98'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet  := aArquivo[1]
		nTotLin     := len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "Z98_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
							EndIf
						EndIf

					Next _msc

					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols  := aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA719LMP ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08.11.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA719LMP()

	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA719C1"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidC1Perg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao := MV_PAR01
	_cRevisa := MV_PAR02
	_cAnoRef := MV_PAR03

	If Empty(_cVersao) .and. Empty(_cRevisa) .and. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos parâmetros!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e anterior à data do dia"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'F'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	TR003 := " DELETE " + RetSqlName("ZBE") + " "
	TR003 += "  WHERE ZBE_VERSAO = '" + _cVersao + "' "
	TR003 += "    AND ZBE_REVISA = '" + _cRevisa + "' "
	TR003 += "    AND ZBE_ANOREF = '" + _cAnoRef + "' "
	TR003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando Cadastro de Driver...",,{|| TCSQLExec(TR003)})

	MsgInfo("Registro deletados com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidC1Perg ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidC1Perg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Versão                    ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão                   ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano Ref.                  ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

