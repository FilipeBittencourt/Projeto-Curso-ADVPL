#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} BIA739
@author Ranisses A. Corona
@since 21/01/04 
@version 1.0
@description Cadastro da Pre-Requisicao - Menu
@obs RDMAKE
@type function
/*/

User Function BIA901()

	SetPrvt("CCADASTRO,AROTINA,")

	cCadastro := "Cadastro da Pre Requisicao"

	aCores    := {	{  'ZI_BAIXA = "N"'	 , 'BR_VERDE'   } ,;
		{                  'ZI_BAIXA = "S"'  , 'BR_VERMELHO'},;
		{  					'ZI_BAIXA = "X"'	 , 'BR_CINZA'   }  }

	aRotina   := { {"Pesquisar"      ,"AxPesqui"                       ,0,1},;
		{               "Visualizar"     ,'ExecBlock("BIA902",.F.,.F.,"V")',0,2},;
		{				"Incluir"        ,'ExecBlock("BIA902",.F.,.F.,"I")',0,3},;
		{               "Imprimir"       ,'ExecBlock("BIA902",.F.,.F.,"L")',0,4},;
		{               "Ctrl. Erros"    ,'U_BIAFG118()'                   ,0,5},;
		{               "Int.Bzg.Direto" ,'U_B901IBD()'                    ,0,6};
		}


	If U_VALOPER("057",.F.) // Relatório Pré-requisições

		AADD(aRotina,{"Relatório"    ,'ExecBlock("BIAV011",.F.,.F.,"B")',0,5} )

	EndIf

	If U_VALOPER("058",.F.) // Relatório Pré-requisições

		AADD(aRotina,{"Baixar"       ,'ExecBlock("BIA902",.F.,.F.,"B")',0,5} )
		AADD(aRotina,{"Excluir"      ,'ExecBlock("BIA902",.F.,.F.,"E")',0,2} )
		AADD(aRotina,{"Aprovadores"  ,'ExecBlock("B901Aprv",.F.,.F.)'  ,0,7} )

	EndIf


	AADD(aRotina,{"Cancelar"     ,'U_BIA901C()'                    ,0,8} )
	AADD(aRotina,{"Relatório Pré-requisições "  ,'U_REPR0001()'    ,0,9} )

	mBrowse(6,1,22,75,"SZI",,,,,,aCores)

Return

User Function B901Aprv()

	Local oSButton1
	Private oDlgAprv1

	If !ValidPerg()
		Return
	EndIf

	DEFINE MSDIALOG oDlgAprv1 TITLE "Aprovadores" FROM 000, 000  TO 500, 1100 COLORS 0, 16777215 PIXEL

	fMSNewGe1()
	DEFINE SBUTTON oSButton1 FROM 226, 515 TYPE 01 OF oDlgAprv1 ENABLE ACTION oDlgAprv1:End()

	ACTIVATE MSDIALOG oDlgAprv1 CENTERED

Return

Static Function fMSNewGe1()

	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local cBizagi	:= U_fGetBase("2")

	Private oMSNewGe1

	aAdd(aHeaderEx,{"Tipo"              ,"TIPO"   ,""    , 10   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"Matrícula"         ,"MATRIC" ,"@!"  , 08   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"Nome"              ,"NOME"   ,"@!"  , 50   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"CLVL"              ,"CLVL"   ,"@!"  , 09   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"C.Contábil"        ,"CONTA"  ,"@!"  , 20   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"Aplicação"         ,"APLIC"  ,"@!"  , 01   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"Aprovador"         ,"APROV"  ,"@!"  , 50   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"E-mail"            ,"EMAIL"  ,""    , 100  , 0,,, "C",, })      	// 1

	RF003 := " SELECT 'Geral' TIPO, "
	RF003 += "        '' MATRICULA, "
	RF003 += "        '' NOME, "
	RF003 += "        A.CLVL, "
	RF003 += "        A.CONTA_CONTABIL, "
	RF003 += "        A.APLICACAO, "
	RF003 += "        B.NOME APROVADOR, "
	RF003 += "        B.EMAIL "
	RF003 += " FROM VW_BZ_PRQAPRV A "
	RF003 += "      LEFT JOIN "+cBizagi+".DBO.VW_USUARIOS B ON RTRIM(B.IDUSERBZ) = RTRIM(A.MATRICULA) COLLATE Latin1_General_BIN "
	RF003 += " WHERE A.CLVL = '" + MV_PAR01 + "' "
	RF003 += "       AND A.CONTA_CONTABIL = '" + MV_PAR02 + "' "
	RF003 += "       AND A.APLICACAO = '" + MV_PAR03 + "' "
	RF003 += " UNION ALL "
	RF003 += " SELECT 'Superior' TIPO, "
	RF003 += "        A.Matricula MATRICULA, "
	RF003 += "        A.Nome NOME, "
	RF003 += "        ' ' CLVL, "
	RF003 += "        ' ' CONTA_CONTABIL, "
	RF003 += "        ' ' APLICACAO, "
	RF003 += "        B.NOME APROVADOR, "
	RF003 += "        B.EMAIL "
	RF003 += " FROM VW_BZ_PRQREQ A "
	RF003 += "      LEFT JOIN "+cBizagi+".DBO.VW_USUARIOS B ON RTRIM(B.IDUSERBZ) = RTRIM(A.IdSuperiorBZ) COLLATE Latin1_General_BIN "
	RF003 += " WHERE Matricula = '" + MV_PAR04 + "' "
	RFcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF003),'RF03',.F.,.T.)
	dbSelectArea("RF03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()
		Aadd(aFieldFill, {RF03->TIPO, RF03->MATRICULA, RF03->NOME, RF03->CLVL, RF03->CONTA_CONTABIL, RF03->APLICACAO, RF03->APROVADOR, RF03->EMAIL, .F. })
		dbSelectArea("RF03")
		dbSkip()

	End

	RF03->(dbCloseArea())
	Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RFcIndex+OrdBagExt())          //indice gerado

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, {"", "", "", "", "", "", "", "", .F. })
	EndIf

	aColsEx := aFieldFill

	oMSNewGe1 := MsNewGetDados():New(  008, 008, 221, 542, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", , , 999, "AllwaysTrue", "", "AllwaysTrue", oDlgAprv1, aHeaderEx, aColsEx)

Return

Static Function ValidPerg()

	local cLoad	    := "B901Aprv" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	Local msOpc     := {"0=Nenhum","1=Producao","2=Manutencao","3=Melhoria_Manut","4=Seguranca","5=Calibracao","6=Melhoria_Prod"}

	MV_PAR01 :=	Space(09)
	MV_PAR02 := Space(20)
	MV_PAR03 := Space(01)
	MV_PAR04 := Space(08)

	aAdd( aPergs ,{1,"Classe de Valor", MV_PAR01, ""   , "NAOVAZIO()", 'CTH', '.T.', 50, .T.})
	aAdd( aPergs ,{1,"Conta Contábil" , MV_PAR02, ""   , "NAOVAZIO()", 'CT1', '.T.', 75, .T.})
	aAdd( aPergs ,{2,"Aplicação"      , MV_PAR03, msOpc, 60          , '.T.', .T.})
	aAdd( aPergs ,{1,"Matrícula"      , MV_PAR04, ""   , "NAOVAZIO()", 'ZZY', '.T.', 50, .T.})

	If ParamBox(aPergs ,"Aprovadores",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

	EndIf

Return lRet


User Function BIA901C()

	Local cMsg		:= ""
	Local lOk		:= .F.
	Local cCodigo	:= SZI->ZI_DOC
	Local cEmp		:= SZI->ZI_EMPRESA
	Local aArea		:= GetArea()
	Local cQuery	:= ""


	If (AllTrim(SZI->ZI_BAIXA) == 'N')

		DEFINE DIALOG oDlg TITLE "Motivo do Cancelamento" FROM 180,180 TO 280, 600 PIXEL

		oTMultiget1	:= TMultiGet():new( 01, 01, {| u | if( pCount() > 0, cMsg := u, cMsg ) }, oDlg, 210, 30, , , , , , .T. )
		oTButton1 	:= TButton():New(35, 170, "Confirmar", oDlg,{|| lOk:=.T. ,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

		ACTIVATE DIALOG oDlg CENTERED

		If (lOk)

			If (!Empty(cMsg))

				DbSelectArea('SZI')
				SZI->(DbSetOrder(1))

				If (SZI->(DbSeek(xFilial('SZI')+cCodigo+cEmp)))

					Begin Transaction

						RecLock('SZI', .F.)
						SZI->ZI_BAIXA	:= 'X'
						SZI->ZI_ERROLOG	:= cMsg
						SZI->(MsUnlock())


						DbSelectArea("SZJ")
						SZJ->(DbSetOrder(1))

						SZJ->(DbSeek(xFilial("SZJ")+SZI->ZI_DOC+SZI->ZI_EMPRESA))

						While !SZJ->(Eof()) 													;
								.And. SZJ->ZJ_FILIAL			== xFilial("SZJ")				;
								.And. ALLTRIM(SZJ->ZJ_DOC)     	== ALLTRIM(SZI->ZI_DOC)			;
								.And. ALLTRIM(SZJ->ZJ_EMPRESA)	== ALLTRIM(SZI->ZI_EMPRESA)

							//Deleta o Empenho
							If Alltrim(SZI->ZI_TIPO) == "RE"

								//Apaga o empenho de acordo com a Empresa
								If SZJ->ZJ_EMPDEST == "01"
									cQuery := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
									TcSQLExec(cQuery)
								ElseIf SZJ->ZJ_EMPDEST == "14"
									cQuery := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
									TcSQLExec(cQuery)
								Else
									cQuery := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
									TcSQLExec(cQuery)
								EndIf

							EndIf

							SZJ->(DbSkip())

						EndDo

					End Transaction

				EndIf


			Else
				Alert("Informe um motivo para realizar o cancelamento.")
			EndIf

		EndIf

	Else

		Alert("Registro já cancelado/baixado.")

	EndIf

	RestArea(aArea)

Return

// Integra Bizagi Direto por problemas do Bizagi 

User Function B901IBD()

	Local _cAlias
	Local _cSql
	Local cBizagi	:= U_fGetBase("2")
	Local TbReqNIn	:= "% "+cBizagi+".dbo.VW_BZ_PRQNAOINTG %"

	Private _cErro	:=	""

	MsgINFO("Opção usada somente mediante alinhamento com a TI", "Atenção!!!")
Return

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		%NoParser%


		WITH BIZAGI
		AS (SELECT *
		FROM %Exp:TbReqNIn% )
		SELECT SZI.ZI_YBIZAGI, 
		BZG.*
		FROM BIZAGI BZG
		LEFT JOIN SZI010 SZI ON SZI.ZI_YBIZAGI COLLATE Latin1_General_BIN = BZG.PROCESSO
		ORDER BY 2

		//		WHERE SZI.ZI_YBIZAGI IS NULL
		//		AND BZG.PROCESSO NOT IN
		//		(
		//		SELECT RTRIM(PROCESSO_BIZAGI) COLLATE Latin1_General_BIN
		//		FROM BZINTEGRACAO
		//		WHERE SUBSTRING(PROCESSO_BIZAGI, 1, 3) = 'PRQ'
		//		)


		/*
		select * FROM PREREQ A
		*/

		/*
		SELECT A.*
		FROM PREREQ A
		LEFT JOIN SZI010 SZI ON RTRIM(ZI_YBIZAGI) = RTRIM(PROCESSO)
		AND ZI_BAIXA <> 'X'
		AND SZI.D_E_L_E_T_ = ' '
		LEFT JOIN SZJ010 SZJ ON ZJ_DOC = ZI_DOC
		AND ZJ_COD = PRODUTO
		AND ZJ_LOCAL = ALMOXARIFADO
		AND SZJ.D_E_L_E_T_ = ' '
		LEFT JOIN SB2010 SB2 ON B2_COD = PRODUTO
		AND B2_LOCAL = ALMOXARIFADO
		AND SB2.D_E_L_E_T_ = ' '
		WHERE ZJ_FILIAL IS NULL
		AND NOT B2_QATU IS NULL
		ORDER BY PROCESSO
		*/

	EndSql

	While (_cAlias)->(!EOF())

		_cErro		:=	""

		_msNumProc  := (_cAlias)->PROCESSO

		BEGIN TRANSACTION

			_msTpPRQ := IIF( (_cAlias)->TIPO == 1, "RE", "")

			DbSelectArea("ZZY")
			DbSetOrder(3)
			DbSeek(xFilial("ZZY") + (_cAlias)->MATRICULA)

			_msDocSZI := GetSxENum("SZI","ZI_DOC")
			SZI->(dbSetOrder(1))
			If SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
				While .T.
					_msDocSZI := GetSxENum("SZI","ZI_DOC")
					SZI->(dbSetOrder(1))
					If !SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
						Exit
					EndIf
				End
			EndIf

			RecLock("SZI",.T.)
			SZI->ZI_FILIAL	:=	xFilial("SZI")
			SZI->ZI_DOC		:=	_msDocSZI
			SZI->ZI_TIPO	:=  _msTpPRQ
			SZI->ZI_EMISSAO	:=	Date() //ctod((_cAlias)->EMISSAO)  //Date()
			SZI->ZI_CLVL	:=	(_cAlias)->CLVL
			SZI->ZI_CC		:=	U_B902BCC(SZI->ZI_CLVL)
			SZI->ZI_MATRIC	:=	(_cAlias)->MATRICULA
			SZI->ZI_NOME	:=	ZZY->ZZY_NOME
			SZI->ZI_BAIXA	:=	"N"
			SZI->ZI_EMPRESA	:=	"01"
			SZI->ZI_YLOCAL	:=	(_cAlias)->ALMOXARIFADO
			SZI->ZI_YSI		:=	IIF( Alltrim((_cAlias)->CONTRATO) $ "-", "", (_cAlias)->CONTRATO )
			SZI->ZI_ITEMCTA	:=	IIF( Alltrim((_cAlias)->ITEMCONTA) $ "-", "", (_cAlias)->ITEMCONTA )
			SZI->ZI_YBIZAGI	:=	_msNumProc
			SZI->(MsUnlock())

			While (_cAlias)->(!EOF()) .and. (_cAlias)->PROCESSO == _msNumProc

				_msAplic := Alltrim(Str((_cAlias)->APLICACAO))
				Reclock("SZJ",.T.)
				SZJ->ZJ_FILIAL	:=	xFilial("SZJ")
				SZJ->ZJ_DOC		:=	SZI->ZI_DOC
				SZJ->ZJ_COD		:=	(_cAlias)->PRODUTO
				SZJ->ZJ_DESCRI	:=	POSICIONE("SB1", 1, xFilial("SB1") + (_cAlias)->PRODUTO, "B1_DESC")
				SZJ->ZJ_LOCAL	:=	(_cAlias)->ALMOXARIFADO
				SZJ->ZJ_UM		:=	POSICIONE("SB1", 1, xFilial("SB1") + (_cAlias)->PRODUTO, "B1_UM")
				SZJ->ZJ_QUANT	:=	(_cAlias)->QUANTIDADE
				SZJ->ZJ_VLRTOT	:=	Iif(SZI->ZI_TIPO == "DU", 0.01, fRetCm(SZJ->ZJ_COD, SZJ->ZJ_LOCAL) * SZJ->ZJ_QUANT)
				SZJ->ZJ_APLIC	:=	Iif(Empty(_msAplic), '0', _msAplic )
				SZJ->ZJ_TAG		:=	(_cAlias)->TAG
				SZJ->ZJ_YLOCALI	:=	Posicione("ZCN", 2, xFilial("ZCN") + SZJ->ZJ_COD + SZJ->ZJ_LOCAL, "ZCN_LOCALI")
				SZJ->ZJ_YMELHOR	:=	IIF( Alltrim((_cAlias)->MELHORIA) $ "000000/-", "", (_cAlias)->MELHORIA )
				SZJ->ZJ_EMPRESA	:=	"01"
				SZJ->ZJ_EMPDEST	:=	"01"
				SZJ->ZJ_CONTA	:=	(_cAlias)->CONTA
				SZJ->ZJ_CLVL	:=	SZI->ZI_CLVL
				SZJ->ZJ_YPARADA	:=	(_cAlias)->PARADA
				SZJ->ZJ_QTAPROV	:=	SZJ->ZJ_QUANT
				SZJ->ZJ_YDRIVER	:=	Iif((_cAlias)->DRIVER == "-1", "", (_cAlias)->DRIVER)
				SZJ->ZJ_YJTDRV	:=	IIF( Alltrim((_cAlias)->JUSTIFICATIVADRV) $ "-", "", (_cAlias)->JUSTIFICATIVADRV )
				SZJ->(MsUnlock())

				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(xFilial("SB2") + SZJ->ZJ_COD + SZJ->ZJ_LOCAL))
					CriaSb2(SZJ->ZJ_COD,SZJ->ZJ_LOCAL)
					If !_msTpPRQ $ "DU_DN"
						_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(0)) + CRLF
					EndIf
				Else
					If !_msTpPRQ $ "DU_DN"
						If SZJ->ZJ_QUANT > (SB2->B2_QATU - SB2->B2_RESERVA)
							_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(SB2->B2_QATU - SB2->B2_RESERVA)) + CRLF
						EndIf
					EndIf
				EndIf

				If SZI->ZI_TIPO == 'RE'
					_cSql := "UPDATE "+RetSqlName("SB2")+" SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
					TcSQLExec(_cSql)
				EndIf

				(_cAlias)->(DbSkip())

			End

			If !Empty(_cErro)

				DisarmTransaction()

			EndIf

		END TRANSACTION

	End

	(_cAlias)->(DbCloseArea())

	MsgINFO("Fim do Processamento...", "BIA901")

Return

Static Function fRetCm(_cCod,_cLocal)

	Local _nCm		:=	0
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ISNULL(B2_CM1,0) B2_CM1
		FROM %TABLE:SB2% (NOLOCK)
		WHERE B2_FILIAL = %XFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND %NotDel%
	EndSql

	_nCm	:=	(_cAlias)->B2_CM1

	(_cAlias)->(DbCloseArea())

Return _nCm
