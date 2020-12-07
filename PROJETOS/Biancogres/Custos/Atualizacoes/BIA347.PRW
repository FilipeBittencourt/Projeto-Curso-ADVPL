#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA347
@author Marcos Alberto Soprani
@since 04/12/14
@version 1.0
@description MIX de Produção base para cálculo do C.Variável Orçamentário
@type function
/*/

User Function BIA347()

	UP005 := " UPDATE Z47 "
	UP005 += "   SET "
	UP005 += "       Z47_DESCRI = SUBSTRING(B1_DESC, 1, 75) "
	UP005 += " FROM " + RetSqlName("Z47") + " Z47 "
	UP005 += "      INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = Z47_PRODUT "
	UP005 += "                               AND SB1.D_E_L_E_T_ = ' ' "
	UP005 += " WHERE Z47_DESCRI = '' "
	UP005 += "       AND Z47.D_E_L_E_T_ = ' ' "
	TCSQLExec(UP005)

	cCadastro := "Mix de Produção"
	aRotina   := { {"Pesquisar"               ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"              ,"AxVisual"	                        ,0,2},;
	{               "Incluir"                 ,"AxInclui"	                        ,0,3},;
	{               "Alterar"                 ,"AxAltera"	                        ,0,4},;
	{               "Excluir"                 ,"AxDeleta"	                        ,0,5},;
	{               "Importar Mix Produção"   ,'ExecBlock("BIA347IMP",.F.,.F.)'     ,0,6},;
	{               "Limpar Mix Produção"     ,'ExecBlock("BIA347LMP",.F.,.F.)'     ,0,7},;
	{               "Desdobra B9/BO/C6 em C1" ,'ExecBlock("B347DPLAC",.F.,.F.)'     ,0,8} }

	dbSelectArea("Z47")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"Z47")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA347IMP ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 06.11.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA347IMP()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("Z47") + SPACE(TAMSX3("Z47_VERSAO")[1]) + SPACE(TAMSX3("Z47_REVISA")[1]) + SPACE(TAMSX3("Z47_ANOREF")[1])
	Local bWhile	    := {|| Z47_FILIAL + Z47_VERSAO + Z47_REVISA + Z47_ANOREF }   

	Local aNoFields     := {"Z47_VERSAO", "Z47_REVISA", "Z47_ANOREF", "Z47_ANO"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("Z47_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("Z47_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("Z47_ANOREF")[1])
	Private _oGAnoRef

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B347IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z47",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "MIX de Produção p/ C.VARIAVEL" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA347A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA347B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA347C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B347FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B347DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA347A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA347D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA347B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA347D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA347C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA347D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA347D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
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
		FROM %TABLE:Z47% Z47
		WHERE Z47_FILIAL = %xFilial:Z47%
		AND Z47_VERSAO = %Exp:_cVersao%
		AND Z47_REVISA = %Exp:_cRevisa%
		AND Z47_ANOREF = %Exp:_cAnoRef%
		AND Z47.%NotDel%
		) NUMREG
		FROM %TABLE:Z47% Z47
		WHERE Z47_FILIAL = %xFilial:Z47%
		AND Z47_VERSAO = %Exp:_cVersao%
		AND Z47_REVISA = %Exp:_cRevisa%
		AND Z47_ANOREF = %Exp:_cAnoRef%
		AND Z47.%NotDel%
		ORDER BY Z47_VERSAO, Z47_REVISA, Z47_ANOREF, Z47_PRODUT
	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "Z47_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "Z47"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z47_REC_WT"
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

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z47_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('Z47')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			Z47->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z47",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z47->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				Z47->(DbDelete())

			EndIf

			Z47->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("Z47",.T.)

				Z47->Z47_FILIAL  := xFilial("Z47")
				Z47->Z47_VERSAO  := _cVersao
				Z47->Z47_REVISA  := _cRevisa
				Z47->Z47_ANOREF  := _cAnoRef
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z47->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				Z47->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("Z47_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("Z47_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("Z47_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B347FOK()

	Local cMenVar    := ReadVar()
	Local vfArea     := GetArea()
	Local _cAlias
	Local _nAt       := _oGetDados:nAt
	Local _nI
	Local _zpPRODUT  := ""

	Do Case

		Case Alltrim(cMenVar) == "M->Z47_PRODUT"
		_zpPRODUT   := M->Z47_PRODUT
		If !ExistCPO("SB1")
			Return .F.
		EndIf

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpPRODUT) .and. _zpPRODUT == GdFieldGet("Z47_PRODUT",_nI)

				MsgInfo("A chave informada nesta linha só pode existir uma única vez. Na linha: " + Alltrim(Str(_nI)) + " já existe esta chave informada!!!")
				Return .F.

			EndIf

		EndIf

	Next

Return .T.

User Function B347DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de deleção para os casos em que já existir registro de orçamento associado, será necessário primeiro retirar de lá

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B347IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B347IEXC()

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
	Local cLoad	    := 'B347IEXC' + cEmpAnt
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
	Local cTabImp			:= 'Z47'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z47_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "Z47_REC_WT"})

				azPosCOD  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z47_COD"})
				azPosCOMP := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z47_COMP"})
				vtCODPos  := aScan(aCampos,{|x| AllTrim(x) == "Z47_COD"})
				vtCOMPPos := aScan(aCampos,{|x| AllTrim(x) == "Z47_COMP"})

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
¦¦¦Função    ¦ B347DPLAC ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08.11.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B347DPLAC()

	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA347C1"
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
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	TR003 := " DELETE " + RetSqlName("Z47") + " "
	TR003 += "  WHERE Z47_VERSAO = '" + _cVersao + "' "
	TR003 += "    AND Z47_REVISA = '" + _cRevisa + "' "
	TR003 += "    AND Z47_ANOREF = '" + _cAnoRef + "' "
	TR003 += "    AND SUBSTRING(Z47_PRODUT, 1, 2) IN('C1') "
	TR003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando C1 do MIX de produção...",,{|| TCSQLExec(TR003)})

	GX008 := " INSERT INTO " + RetSqlName("Z47") + " "
	GX008 += " (Z47_FILIAL, "
	GX008 += "  Z47_PRODUT, "
	GX008 += "  Z47_DESCRI, "
	GX008 += "  Z47_ANO, "
	GX008 += "  Z47_QTDM01, "
	GX008 += "  Z47_QTDM02, "
	GX008 += "  Z47_QTDM03, "
	GX008 += "  Z47_QTDM04, "
	GX008 += "  Z47_QTDM05, "
	GX008 += "  Z47_QTDM06, "
	GX008 += "  Z47_QTDM07, "
	GX008 += "  Z47_QTDM08, "
	GX008 += "  Z47_QTDM09, "
	GX008 += "  Z47_QTDM10, "
	GX008 += "  Z47_QTDM11, "
	GX008 += "  Z47_QTDM12, "
	GX008 += "  D_E_L_E_T_, "
	GX008 += "  R_E_C_N_O_, "
	GX008 += "  Z47_VERSAO, "
	GX008 += "  Z47_REVISA, "
	GX008 += "  Z47_ANOREF, "
	GX008 += "  Z47_FORNOP) "
	GX008 += " SELECT Z47_FILIAL, "
	GX008 += "        Z47_PRODUT, "
	GX008 += "        '' DESCRI, "
	GX008 += "        Z47_ANO, "
	GX008 += "        SUM(QTDM01) QTDM01, "
	GX008 += "        SUM(QTDM02) QTDM02, "
	GX008 += "        SUM(QTDM03) QTDM03, "
	GX008 += "        SUM(QTDM04) QTDM04, "
	GX008 += "        SUM(QTDM05) QTDM05, "
	GX008 += "        SUM(QTDM06) QTDM06, "
	GX008 += "        SUM(QTDM07) QTDM07, "
	GX008 += "        SUM(QTDM08) QTDM08, "
	GX008 += "        SUM(QTDM09) QTDM09, "
	GX008 += "        SUM(QTDM10) QTDM10, "
	GX008 += "        SUM(QTDM11) QTDM11, "
	GX008 += "        SUM(QTDM12) QTDM12, "
	GX008 += "        ' ' D_E_L_E_T_, "
	GX008 += "        (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("Z47") + ") + ROW_NUMBER() OVER(ORDER BY Z47_PRODUT) AS R_E_C_N_O_, "
	GX008 += "        Z47_VERSAO, "
	GX008 += "        Z47_REVISA, "
	GX008 += "        Z47_ANOREF, "
	GX008 += "        'F02' FORNOP "
	GX008 += "   FROM (SELECT Z47_FILIAL, "
	GX008 += "                (SELECT DISTINCT G1_COMP "
	GX008 += "                   FROM " + RetSqlName("SG1") + " SG1 "
	GX008 += "                  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = G1_COMP "
	GX008 += "                                       AND SB1.B1_TIPO = 'PA' "
	GX008 += "                                       AND SB1.D_E_L_E_T_ = ' ' "
	GX008 += "                  WHERE SG1.G1_COD = Z47_PRODUT "
	// Em 18/09/18... Não me recordo porque pegava a tabela SGG e ainda estamos em curso orçamentário???
	//                Bem como, não sei porque fazíamos o orçamento por PP e não por PA classe 1???
	//                Vou alterar isto (passando para PA) e vou acompanhar os próximos processos...
	//GX008 += "                  WHERE SGG.GG_COD = RTRIM(Z47_PRODUT)+'1       ' "
	// Retirado em 10/06/19 durante forecast de 2019
	//GX008 += "                    AND '" + _cAnoRef + "0101' >= SG1.G1_INI "
	GX008 += "                    AND '" + _cAnoRef + "1231' <= SG1.G1_FIM "
	GX008 += "                    AND SG1.D_E_L_E_T_ = ' ') Z47_PRODUT, "
	GX008 += "                Z47_ANO, "
	GX008 += "                ROUND(Z47_QTDM01 * 1.0000, 0) QTDM01, "
	GX008 += "                ROUND(Z47_QTDM02 * 1.0000, 0) QTDM02, "
	GX008 += "                ROUND(Z47_QTDM03 * 1.0000, 0) QTDM03, "
	GX008 += "                ROUND(Z47_QTDM04 * 1.0000, 0) QTDM04, "
	GX008 += "                ROUND(Z47_QTDM05 * 1.0000, 0) QTDM05, "
	GX008 += "                ROUND(Z47_QTDM06 * 1.0000, 0) QTDM06, "
	GX008 += "                ROUND(Z47_QTDM07 * 1.0000, 0) QTDM07, "
	GX008 += "                ROUND(Z47_QTDM08 * 1.0000, 0) QTDM08, "
	GX008 += "                ROUND(Z47_QTDM09 * 1.0000, 0) QTDM09, "
	GX008 += "                ROUND(Z47_QTDM10 * 1.0000, 0) QTDM10, "
	GX008 += "                ROUND(Z47_QTDM11 * 1.0000, 0) QTDM11, "
	GX008 += "                ROUND(Z47_QTDM12 * 1.0000, 0) QTDM12, "
	GX008 += "                ' ' D_E_L_E_T_, "
	GX008 += "                0 R_E_C_N_O_, "
	GX008 += "                Z47_VERSAO, "
	GX008 += "                Z47_REVISA, "
	GX008 += "                Z47_ANOREF "
	GX008 += "           FROM " + RetSqlName("Z47") + " "
	GX008 += "          WHERE Z47_VERSAO = '" + _cVersao + "' "
	GX008 += "            AND Z47_REVISA = '" + _cRevisa + "' "
	GX008 += "            AND Z47_ANOREF = '" + _cAnoRef + "' "
	GX008 += "            AND SUBSTRING(Z47_PRODUT, 1, 2) IN('B9', 'BO', 'C6') "
	GX008 += "            AND D_E_L_E_T_ = ' ') AS TABER "
	//GX008 += "  WHERE QTDM01 + QTDM02 + QTDM03 + QTDM04 + QTDM05 + QTDM06 + QTDM07 + QTDM08 + QTDM09 + QTDM10 + QTDM11 + QTDM12 <> 0 "
	GX008 += "  GROUP BY Z47_FILIAL, "
	GX008 += "           Z47_PRODUT, "
	GX008 += "           Z47_ANO, "
	GX008 += "           Z47_VERSAO, "
	GX008 += "           Z47_REVISA, "
	GX008 += "           Z47_ANOREF "
	U_BIAMsgRun("Aguarde... Desdobrando B9/BO/C6 em C1...",,{|| TCSQLExec(GX008)})

	MsgInfo("Registro Incluído com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA347LMP ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08.11.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA347LMP()

	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA347C1"
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
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	TR003 := " DELETE " + RetSqlName("Z47") + " "
	TR003 += "  WHERE Z47_VERSAO = '" + _cVersao + "' "
	TR003 += "    AND Z47_REVISA = '" + _cRevisa + "' "
	TR003 += "    AND Z47_ANOREF = '" + _cAnoRef + "' "
	TR003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando C1 do MIX de produção...",,{|| TCSQLExec(TR003)})

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
