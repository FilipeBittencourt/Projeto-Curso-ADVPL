#include "rwmake.ch"
#Include "PROTHEUS.CH"
#include "topconn.ch"

#DEFINE TPPEDMUNDI 	1
#DEFINE TPPEDFORM 	2

/*/{Protheus.doc} BIAEC001
@description Tela e processo de controle de Cargas para Faturamento
@author Fernando Rocha
@since 28/01/2011
@version undefined
@type function
/*/


//"","FORNO","ARMAZEM","DT EMPENHO","PEDIDO","ITEM","SEQ.","PRODUTO","LOTE","DESCRICAO","QTDE LIBER.","QTDE CARGA","PESO","DT ENTREGA","TEMPO M."

#DEFINE nc_NUMCOLS	15  //se criar mais colunas abaixo modificar

#DEFINE nc_MARK		01
#DEFINE nc_FORNO	02
#DEFINE nc_ENTREGA	03
#DEFINE nc_TEMPOM	04
#DEFINE nc_PEDIDO	05
#DEFINE nc_ITEM		06
#DEFINE nc_SEQ		07
#DEFINE nc_PRODUTO	08
#DEFINE nc_LOTE		09
#DEFINE nc_DESCR	10
#DEFINE nc_QLIBER	11
#DEFINE nc_QCARGA	12
#DEFINE nc_PESO		13
#DEFINE nc_ARMAZEM	14
#DEFINE nc_EMPENHO	15

User Function BIAEC001()
	Local aCores 		:= {}
	Local lUsaCarga		:=	GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de
	Private _cEmpFil	:= ""
	Private aCampos1
	Private Enter1 		:= CHR(13)+CHR(10)

	Public __BECDTLORI
	Public __nRAStatus

	Public __YTPBLCT
	Public __YDTBLCT
	Public __YDTLICT

	If lUsaCarga

		_cEmpFil := Alltrim(CEMPANT)+Alltrim(CFILANT)

	Else

		MSGINFO("EMPRESA NAO HABILITADA","CONTROLE DE CARGAS")

		Return

	EndIf

	AAdd(aCores,{"EMPTY(ZZV->ZZV_DATFIM)"       , "ENABLE"     })
	AAdd(aCores,{"U_BEC01TCA()"                 , "BR_CINZA"   })
	AAdd(aCores,{"U_BEC01TAM()"                 , "BR_AMARELO" })
	AAdd(aCores,{"!EMPTY(ZZV->ZZV_DATFIM)"      , "DISABLE"    })

	Private cCadastro := "Controle de Cargas"

	Private aRotina   := {	{"Pesquisar"            	,"AxPesqui"     	,0,1},;
		{                        "Visualizar"  				,"U_BEC01MAN(2)"	,0,2},;
		{                        "Incluir"      			,"U_BEC01MAN(3)"	,0,3},;
		{                        "Alterar"      			,"U_BEC01MAN(4)"	,0,4},;
		{                        "Imprimir"      			,"U_BIAEC002()"		,0,4},;
		{                        "Alt.Dados Trans."     	,"U_BEC01MAN(6)"	,0,4},;
		{                        "Termo Responsab."	    	,"U_BIAECVAL()"		,0,4},;
		{                        "Status ECOSIS"			,"U_BEC01UST(.F.)"	,0,4},;
		{                        "Finalizar"      	    	,"U_BEC01FIM()"		,0,4},;
		{                        "Pesagem"      	    	,"U_BIA249()"	 	,0,4},;
		{                        "Car. Composta"      		,"U_BIA249C()"	 	,0,4},;
		{                        "Rel. Pesagem"   			,"U_BIA249CR()"	 	,0,4},;
		{                        "Rastro Pedido"   	    	,"U_BCPDV01()"	 	,0,4},;
		{                        "Destravar Carga" 	    	,"U_BEC01DCA()"	 	,0,4},;
		{                        "Legenda"      			,"U_BEC01LEG()"		,0,4},;
		{                        "Fat. con. sem en. ticket" ,'U_BIA249RT()'		,0, 4},;
		{  		                 "Imprimir Danfe"			,'U_BIAECID()'		,0, 4},;
		{  		                 "Liberação Sem Balança"	,'U_BIAELSB()'		,0, 4},;
		{  		                 "Liberação Coletor Ecosis"	,'U_BIALCONE()'		,0, 4}}


	// Tiago Rossini Coradini - 20/06/2016 - OS: 2420-16 - Angelo Alencar - Ajuste no indice padrão da rotina
	DbSelectArea("ZZV")
	DbSetOrder(1)
	ZZV->(MBROWSE(6,1,22,75,"ZZV",,,,,,aCores))

	//fernando em 10/12 - garantir que nao tem nenhum registro travado
	SC9->(DbUnLockAll())

Return

User Function BIAELSB()

	//TODO Adicionar usuários permitidos a liberar

	Local cAliasTemp	:= GetNextAlias()
	Local cQuery		:= ""
	Local cLoad			:= "BIAELSB" + cEmpAnt
	Local cFileName		:= RetCodUsr() +"_"+ cLoad
	Local aPergs		:= {}

	MV_PAR01			:= Space(4)
	MV_PAR02			:= Space(4)

	If (U_VALOPER('C02',.F.) .Or. U_VALOPER('C03',.F.))

		aAdd( aPergs ,{1,"Carga de"				, MV_PAR01	,"",,"",'.T.',50,.F.})
		aAdd( aPergs ,{1,"Carga até"			, MV_PAR02	,"",,"",'.T.',50,.F.})

		If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
			Return()
		EndIf

		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

		If (!Empty(MV_PAR01) .And. !Empty(MV_PAR02))

			cQuery := " SELECT ZZV_CARGA						 											"
			cQuery += " FROM " + RetSQLName("ZZV")+"														"
			cQuery += " WHERE ZZV_CARGA BETWEEN  " + ValToSQL(MV_PAR01)+"	AND	" + ValToSQL(MV_PAR02)+"	"
			cQuery += " AND	 D_E_L_E_T_	 = ''																"

			TcQuery cQuery New Alias (cAliasTemp)

			While (!(cAliasTemp)->(Eof()))

				DbSelectArea("ZZV")
				ZZV->(dbSetOrder(1))

				If ZZV->(DbSeek(xFilial("ZZV")+(cAliasTemp)->ZZV_CARGA))

					Reclock("ZZV", .F.)
					ZZV->ZZV_PREAUT	:= 'S'
					ZZV->(MsUnLock())

				EndIf

				(cAliasTemp)->(dbSkip())

			EndDo

			(cAliasTemp)->(DbCloseArea())

			MsgInfo ("Liberação realizada com sucesso", "")
		Else
			MsgInfo ("Carga de/Carga até não informada", "")
		EndIf

	Else
		MsgInfo ("Usuário não tem acesso a essa função", "")
	EndIf

Return


User Function BIAECID()

	Local lRet 		:= .F.
	Local lLEcoNE	:= GetNewPar("MV_YLECONE", .F.)
	Local aArea		:= GetArea()

	If (Empty(ZZV->ZZV_CARGA))
		Alert("<font size='3' color='red'>Código carga vazio.</font>")
		Return
	EndIf
	
	If (GetNewPar("MV_YVCONFC", .F.))
		If AllTrim(ZZV->ZZV_SCONF) == '2'
			Alert("<font size='3' color='red'>Carga conferida com erro no coletor, favor informar os responsáveis.</font>")
			/*If (!MSGYESNO("Desejar continuar o processo?", "Informação" ))
				Return
			EndIf*/
			Return
		EndIf
	EndIf
	

	If AllTrim(ZZV->ZZV_CONF) == 'S'

		If (!Empty(ZZV->ZZV_TICKET))

			If (lLEcoNE)

				//lRet := U_BIA249VE(ZZV->ZZV_TICKET, .F., .F.)

				U_FPRCARGA(ZZV->ZZV_CARGA)

			Else

				/*lRet := U_BIA249VE(ZZV->ZZV_TICKET, .F.)

				If (!lRet)

					If (MSGYESNO("Realizar a impressão mesmo com a carga não finalizada no ECOSIS?", "Informação" ))

						U_FPRCARGA(ZZV->ZZV_CARGA)

					EndIf

				Else

					U_FPRCARGA(ZZV->ZZV_CARGA)

				EndIf
				*/
				
				U_FPRCARGA(ZZV->ZZV_CARGA)
			EndIf

			DbSelectArea("ZZV")
			ZZV->(dbSetOrder(1))
			If ZZV->(DbSeek(xFilial("ZZV")+ZZV->ZZV_CARGA))
				If (ZZV->(FieldPos("ZZV_SCECOS")) > 0)
					If (Empty(ZZV->ZZV_SCECOS))
						Reclock("ZZV", .F.)
						ZZV->ZZV_SCECOS	:= IIF(lRet, 'S', 'N')
						ZZV->(MsUnLock())
					EndIf
				EndIf
			EndIf

			//U_FPRCARGA(ZZV->ZZV_CARGA)

		Else

			U_FPRCARGA(ZZV->ZZV_CARGA)

		EndIf

	Else

		Alert("<font size='3' color='red'>Carga não conferida.</font>")

	EndIf

	RestArea(aArea)

Return()

User Function BIALCONE()

	Local aArea		:= GetArea()
	If (U_VALOPER('LCE',.F.))
		If (MSGYESNO("Desejar liberar conferência manual coletor?", "Informação" ))
			DbSelectArea("ZZV")
			ZZV->(dbSetOrder(1))
			If ZZV->(DbSeek(xFilial("ZZV")+ZZV->ZZV_CARGA))
				If (ZZV->(FieldPos("ZZV_SCONF")) > 0)
					//If (Empty(ZZV->ZZV_SCONF))
						Reclock("ZZV", .F.)
						ZZV->ZZV_SCONF	:= '8'
						ZZV->(MsUnLock())
						MsgInfo ("Liberação realizada com sucesso", "")
					//EndIf
				EndIf
			EndIf
		EndIf
	Else
		MsgInfo ("Usuário não tem permissão para essa ação.", "")
	EndIf	
	
	RestArea(aArea)
	
Return

User Function BIAECVAL()

	Local lRet 		:= .F.
	Local lLEcoNE	:= GetNewPar("MV_YLECONE", .F.)
	Local aArea		:= GetArea()

	
	If AllTrim(ZZV->ZZV_CONF) == 'S'

		If (GetNewPar("MV_YVCONFC", .F.))
			If AllTrim(ZZV->ZZV_SCONF) == '2'
				Alert("<font size='3' color='red'>Carga conferida com erro no coletor, favor informar os responsáveis.</font>")
				/*If (!MSGYESNO("Desejar continuar o processo?", "Informação" ))
					Return
				EndIf*/
				Return
			EndIf
		EndIf
	
		If (!Empty(ZZV->ZZV_TICKET))

			If (lLEcoNE)

				//lRet := U_BIA249VE(ZZV->ZZV_TICKET, .F., .F.)

				U_BIAEC003()

			Else

				/*lRet := U_BIA249VE(ZZV->ZZV_TICKET, .F.)

				If (!lRet)

					If (MSGYESNO("Realizar a impressão mesmo com a carga não finalizada?", "Informação" ))

						U_BIAEC003()

					EndIf

				Else

					U_BIAEC003()

				EndIf
				*/
				
				U_BIAEC003()
			EndIf

			DbSelectArea("ZZV")
			ZZV->(dbSetOrder(1))
			If ZZV->(DbSeek(xFilial("ZZV")+ZZV->ZZV_CARGA))
				If (ZZV->(FieldPos("ZZV_SCECOS")) > 0)
					If (Empty(ZZV->ZZV_SCECOS))
						Reclock("ZZV", .F.)
						ZZV->ZZV_SCECOS	:= IIF(lRet, 'S', 'N')
						ZZV->(MsUnLock())
					EndIf
				EndIf
			EndIf

			//U_BIAEC003()

		Else

			U_BIAEC003()

		EndIf

	Else

		Alert("<font size='3' color='red'>Carga não conferida.</font>")

	EndIf

	RestArea(aArea)

Return()

User Function BEC01LEG()

	Brwlegenda(cCadastro, "Legenda",{	{"ENABLE"     ,"CARGA ABERTA"     },;
		{"DISABLE"    ,"CARGA FINALIZADA" },;
		{"BR_CINZA"   ,"CARGA CANCELADA"  },;
		{"BR_AMARELO" ,"AMOSTRA"          }})
Return


User Function BEC01MAN(nOpc)

	Local aButtons := {}
	Local oFont1 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oPanelRod
	Local oSay1
	Local oSay2
	Local _LRET := .F.

	Private aSize := MsAdvSize(,.F.)
	Private oDlgCarga
	Private oGDItems
	Private lblPeso
	Private lblQtde
	Private aTELA[0][0]  // Variáveis que serão atualizadas pela Ench
	Private aGETS[0]  // e utilizadas pela função OBRIGATORIO()

	Private nOpca := nOpc
	Private VISUAL :=  nOpca == 2
	Private INCLUI :=  nOpca == 3
	Private ALTERA :=  nOpca == 4

	//BOTOES DA ENCHOICEBAR
	IF (nOpca == 3 .OR. nOpca == 4)
		aAdd(aButtons,	{"NOVACELULA",{|| GetPedidos()}	,"Ad.Pedido"})
		aAdd(aButtons,	{"AVGARMAZEM",{|| EnvExped()}		,"Expedicao"})

		If ( ALTERA )
			aAdd(aButtons,{"AVGARMAZEM", {|| DestItem()},"Destrava ITEM"})
		EndIf

		aAdd(aButtons,	{"TICKET",{|| VisuaTicket()}		,"Ticket"})

		//teclas de atalho
		SetKey(VK_F5, {|| GetPedidos()})
	ENDIF

	IF nOpca == 2 .Or. nOpca == 4
		U_BEC01UST(.T., ZZV->ZZV_CARGA)
	ENDIF

	DEFINE MSDIALOG oDlgCarga TITLE "CONTROLE DE CARGAS" FROM aSize[7],000 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

	RegToMemory("ZZV", INCLUI, .T., .T.)

	fEnchoice()

	If (INCLUI)

		M->ZZV_DATAAG := DaySum(Date() , 1 )
		//M->ZZV_HORAAG := Substr(Time(), 1, 5)

	EndIf

	@ 224, 000 MSPANEL oPanelRod SIZE 400, 025 OF oDlgCarga COLORS 0, 16777215 RAISED
	@ 006, 158 SAY oSay1 PROMPT "QTDE TOTAL:" SIZE 051, 011 OF oPanelRod FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 006, 276 SAY oSay2 PROMPT "PESO TOTAL:" SIZE 055, 007 OF oPanelRod FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 006, 212 SAY lblQtde PROMPT "" SIZE 061, 013 OF oPanelRod FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 006, 328 SAY lblPeso PROMPT "" SIZE 063, 013 OF oPanelRod FONT oFont2 COLORS 0, 16777215 PIXEL
	fGDItems()
	SetTotal()

	// Don't change the Align Order
	oEnchoice:oBox:Align := CONTROL_ALIGN_TOP
	oPanelRod:Align := CONTROL_ALIGN_BOTTOM
	oGDItems:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//ACTIVATE MSDIALOG oDlgCarga CENTERED
	ACTIVATE MSDIALOG oDlgCarga CENTERED ON INIT (EnchoiceBar(oDlgCarga, {|| IIF(_LRET := Salvar(),oDlgCarga:End(),)}, {|| RollBackSx8(), oDlgCarga:End()},,aButtons))

	//IF (nOpc == 3)
	//	SX5->(DbSetOrder(1))
	//	IF  SX5->(DbSeek(xFilial("SX5")+"99"+SubStr(Dtos(ddatabase),1,4)))
	//		While ! Reclock("SX5",.F.) ; End
	//		IF _LRET
	//			SX5->X5_DESCRI := Soma1(Alltrim(SX5->X5_DESCRI),4)
	//		ENDIF
	//		SX5->(MsUnlock())
	//	ENDIF
	//ENDIF

	SET KEY VK_F5 TO

	SC9->(DbUnLockAll())

Return

Static Function VisuaTicket()

	Local aArea := GetArea()

	DbSelectArea("Z11")
	Z11->(DbSetOrder(1))

	If Z11->(DbSeek(XFilial("Z11")+M->ZZV_TICKET))
		ExecBlock("MOV797", .F., .F., "V")
	EndIf

	RestArea(aArea)

Return

Static Function fEnchoice()

	Local aFields := {"ZZV_CARGA","ZZV_TICKET","ZZV_TICKEX", "ZZV_PLACA","ZZV_CODMOT","ZZV_MOTOR","ZZV_DOCMOT","ZZV_PL_UF","ZZV_PL_MUN","ZZV_PL_DMU","ZZV_TRANSP","ZZV_NTRANS","ZZV_OBS","ZZV_CFRETE","NOUSER","ZZV_TPAGEN", "ZZV_DATAAG","ZZV_HORAAG", "ZZV_GALPAO", "ZZV_OBSNF1"}
	Local aAlterFields

	IF nOpca == 6
		aAlterFields := {"ZZV_PLACA","ZZV_CODMOT","ZZV_DOCMOT","ZZV_PL_UF","ZZV_PL_MUN", "ZZV_OBSNF1"}
	ELSE
		aAlterFields := {"ZZV_TICKET","ZZV_TICKEX", "ZZV_PLACA","ZZV_CODMOT", "ZZV_MOTOR", "ZZV_DOCMOT","ZZV_PL_UF","ZZV_PL_MUN","ZZV_TRANSP","ZZV_OBS","ZZV_CFRETE", "ZZV_TPAGEN", "ZZV_DATAAG", "ZZV_HORAAG", "ZZV_OBSNF1"}
	ENDIF

	Static oEnchoice

	If aSize[5] < 1000
		oEnchoice := MsMGet():New("ZZV",0,nOpca,,,,aFields,{14,0,110,470},aAlterFields,,,,,oDlgCarga,,.T.)
	Else
		oEnchoice := MsMGet():New("ZZV",0,nOpca,,,,aFields,{14,0,117,aSize[3]-5},aAlterFields,,,,,oDlgCarga,,.T.)
	EndIf

Return


Static Function fGDItems()

	Local nX
	Local aHeaderEx		:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"ZZW_CLIENT","ZZW_PEDIDO","ZZW_ITEM","ZZW_SEQUEN","ZZW_DPRO","ZZW_ROM_QT","ZZW_ROM_PS","ZZW_NUMOCE","ZZW_STATUS"}
	Local aAlterFields	:= {}
	Local nOpc
	Local cAliasTmp
	Local cExpCliente
	Local nSA1 			:= RetSqlName("SA1")
	Local nSC5 			:= RetSqlName("SC5")

	IF INCLUI .OR. ALTERA
		nOpc := GD_DELETE
	ELSE
		nOpc := 0
	ENDIF

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	IF !INCLUI

		cExpCliente := "% CASE WHEN ZZW_CCLI = '010064' THEN '* ' ELSE '' END + (SELECT RTRIM(A1_NOME) FROM "+nSA1+" SA1 (nolock) WHERE A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_NUM = ZZW_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),ZZW_CCLI+ZZW_LCLI) AND SA1.D_E_L_E_T_<>'*')  %"

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp

			SELECT 
			%Exp:cExpCliente% A1_NOME
			,ZZW_PEDIDO
			,ZZW_ITEM
			,ZZW_SEQUEN
			,B1_DESC
			,C9_QTDLIB
			,PESOBR = CASE WHEN B1_TIPCONV = 'M'
			THEN (C9_QTDLIB  * 
			ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
			+ ((C9_QTDLIB * B1_CONV) * 
			ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
		ELSE (C9_QTDLIB  * ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_PESO))
			+ ((C9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.D_E_L_E_T_<>'*'),B1_YPESEMB))
		END
		,ZZW_NUMOCE
		,ZZW_STATUS

		FROM %Table:ZZW% ZZW (nolock)
		LEFT JOIN %Table:SC9% SC9 (nolock) ON C9_FILIAL = ZZW_FILIAL AND C9_PEDIDO = ZZW_PEDIDO AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW_SEQUEN AND SC9.D_E_L_E_T_<>'*'
		LEFT JOIN %Table:SB1% SB1 (nolock) ON B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_<>'*'
		LEFT JOIN %Table:SA1% SA1 (nolock) ON A1_COD = C9_CLIENTE AND A1_LOJA = C9_LOJA AND SA1.D_E_L_E_T_<>'*'
		WHERE
		ZZW.D_E_L_E_T_<>'*'
		AND ZZW.ZZW_CARGA = %Exp:ZZV->ZZV_CARGA% 
		AND ZZW.ZZW_FILIAL = %Exp:ZZV->ZZV_FILIAL%
		    
		ORDER BY ZZW_CARGA, A1_NOME, ZZW_PEDIDO, ZZW_ITEM, ZZW_SEQUEN

	EndSql

	(cAliasTmp)->(DbGoTop())
	While .Not. (cAliasTmp)->(Eof())

		aFieldFill := {}
		Aadd(aFieldFill, (cAliasTmp)->A1_NOME)
		Aadd(aFieldFill, (cAliasTmp)->ZZW_PEDIDO)
		Aadd(aFieldFill, (cAliasTmp)->ZZW_ITEM)
		Aadd(aFieldFill, (cAliasTmp)->ZZW_SEQUEN)
		Aadd(aFieldFill, (cAliasTmp)->B1_DESC)
		Aadd(aFieldFill, (cAliasTmp)->C9_QTDLIB )
		Aadd(aFieldFill, (cAliasTmp)->PESOBR)
		Aadd(aFieldFill, (cAliasTmp)->ZZW_NUMOCE)
		Aadd(aFieldFill, (cAliasTmp)->ZZW_STATUS)

		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

ENDIF

oGDItems := MsNewGetDados():New( 110, 000, 224, 400, nOpc, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "U_BEC01DOK", oDlgCarga, aHeaderEx, aColsEx)

Return


User Function BEC01VTK()

	ZZV->(dbSetOrder(2))
	If ZZV->(dbSeek(xFilial("ZZV")+M->ZZV_TICKET))

		If (ZZV->ZZV_DATINC == dDataBase) .Or. (ZZV->ZZV_DATINC == DaySub(dDataBase, 1)) //.And. Empty(M->ZZV_PLACA)
			If !MSGNOYES("Esse TICKET já está associado a outra(s) carga(s)."+CRLF+" Tem certeza que gostaria de associar o TICKET a uma carga de AMOSTRA/COMPLEMENTAR?","COMPOSICAO DE TICKET")
				Return(.F.)
			Else
				If EhCompos()
					MSGALERT("Não é possível associar a CARGA " +ZZV->ZZV_CARGA+ " pois o TICKET está associado a uma CARGA COMPOSTA" )
					Return(.F.)
				EndIf
			EndIf
		Else
			Z11->(dbSetOrder(1))
			If Z11->(dbSeek(XFilial("Z11")+M->ZZV_TICKET))

				If Z11->Z11_DATAIN == dDataBase //.And. Empty(M->ZZV_PLACA)
					If !MSGNOYES("Esse TICKET j?est?associado a outra(s) carga(s)."+CRLF+" Tem certeza que gostaria de associar o TICKET a uma carga de AMOSTRA/COMPLEMENTAR?","COMPOSICAO DE TICKET")
						Return(.F.)
					Else
						If EhCompos()
							MSGALERT("Não é possível associar a CARGA " +ZZV->ZZV_CARGA+ " pois o TICKET está associado a uma CARGA COMPOSTA" )
							Return(.F.)
						EndIf
					EndIf
				Else
					MSGALERT("TICKET JA ASSOCIADO A CARGA: "+ZZV->ZZV_CARGA)
					Return(.F.)
				EndIf
			Else
				MSGALERT("TICKET JA ASSOCIADO A CARGA: "+ZZV->ZZV_CARGA)
				Return(.F.)
			EndIf
		EndIf
	EndIf

	Z11->(dbSetOrder(1))
	If Z11->(dbSeek(XFilial("Z11")+M->ZZV_TICKET))

		If !Empty(Z11->Z11_DATASA)
			MSGALERT("TICKET COM SAIDA EFETUADA")
			Return(.F.)
		ElseIf Z11->Z11_MERCAD == 1
			MSGALERT("ESSE TICKET NÃO PODE SER ASSOCIADO POIS ?DE DESCARGA.")
			Return(.F.)
		Else

			M->ZZV_PLACA := Z11->Z11_PCAVAL

			DbSelectArea("DA3")
			DA3->(dbSetOrder(3))
			If DA3->(dbSeek(xFilial("DA3")+Substr(Z11->Z11_PCAVAL,1,3)+Substr(Z11->Z11_PCAVAL,4,4)))

				M->ZZV_PL_UF	:= DA3->DA3_ESTPLA
				M->ZZV_PL_MUN	:= DA3->DA3_YCODMN
				M->ZZV_PL_DMU 	:= DA3->DA3_MUNPLA
				M->ZZV_CODMOT	:= Z11->Z11_CODMOT //DA3->DA3_MOTORI
				M->ZZV_MOTOR	:= Posicione("DA4", 1, xFilial("DA4") + Z11->Z11_CODMOT, "DA4_NOME") //Posicione("DA4", 1, xFilial("DA4") + DA3->DA3_MOTORI, "DA4_NOME")
				M->ZZV_DOCMOT	:= Posicione("DA4", 1, xFilial("DA4") + Z11->Z11_CODMOT, "DA4_NUMCNH") //Posicione("DA4", 1, xFilial("DA4") + DA3->DA3_MOTORI, "DA4_NUMCNH")
				M->ZZV_TRANSP	:= Z11->Z11_CODTRA //DA3->DA3_YTRANS
				M->ZZV_NTRANS 	:= Posicione("SA4", 1, xFilial("SA4") + Z11->Z11_CODTRA, "A4_NOME") //Posicione("SA4", 1, xFilial("SA4") + DA3->DA3_YTRANS, "A4_NOME")

			EndIf

		EndIf

		// Implementado em 19/09/13 por Marcos Alberto Soprani
		If Z11->Z11_MERCAD == 1
			MsgALERT("Tipo da pesagem deste ticket incorreta (ENTREGA). Necessário verificar.")
			Return(.F.)
		EndIf

	EndIf

Return(.T.)

//----------------------------------------------------------------------------
Static Function EhCompos()

	Local cAliasTmp	:= GetNextAlias()
	Local cEmprTmp	:= cEmpAnt + '01'
	Local cPesTmp  	:= M->ZZV_TICKET
	Local lEhCompos	:= .F.

	BeginSql Alias cAliasTmp
		SELECT COUNT(0) QTD 
		FROM Z43010 (nolock)
		WHERE Z43_PESAGE  = %Exp:cPesTmp%
		AND Z43_EMPR    = %Exp:cEmprTmp%
		AND %NOTDEL% 
	EndSql

	lEhCompos := ((cAliasTmp)->QTD > 0)
	(cAliasTmp)->(dbCloseArea())

Return lEhCompos


User Function BEC01DOK()

	Local _aCols := oGDItems:ACols

	IF _aCols[N][9] <> '1'
		MSGALERT("PRODUTO/CARGA JÁ INTEGRADO - NÃO PERMITIDO EXCLUSÃO","VALIDACAO DA CARGA")
		Return(.F.)
	ENDIF

	SC9->(DbSetOrder(1))
	If !Empty(_aCols[N][2]) .And. SC9->(DbSeek(XFilial("SC9")+_aCols[N][2]+_aCols[N][3]+_aCols[N][4])) .And. !Empty(SC9->C9_NFISCAL)
		MsgAlert("O Item Selecionado já está FATURADO."+CRLF+"NÃO É POSSÍVEL EXCLUIR este item.","VALIDACAO DA CARGA")
		Return(.F.)
	EndIf


Return(.T.)


Static Function SetTotal()

	Local I
	Local _aCols := oGDItems:ACols
	Local _nQtde := 0
	Local _nPeso := 0

	FOR I := 1 To Len(_aCols)

		_nQtde += _aCols[I][6]
		_nPeso += _aCols[I][7]

	NEXT I

	lblQtde:cCaption :=  Transform(_nQtde,"@E 999,999,999.99")+" m2"
	lblPeso:cCaption :=  Transform(_nPeso,"@E 999,999,999.99")+" Kg"

Return


Static Function Salvar()

	Local lRet := .T.

	IF nOpca == 2
		Return(.T.)
	ENDIF

	If (!CheckTipoAgen())
		Return (.F.)
	EndIf

	IF !Obrigatorio(aGets,aTela) /*Valida o cabecalho*/
		Return(.F.)
	ENDIF

	//__oSemaforo				:=	tBiaSemaforo():New()
	//__oSemaforo:cGrupo		:=	"FATURAMENTO"
	//__oSemaforo:lShowMsg	:= .T. //Nao Exibir mensagem de LOCK
	//If __oSemaforo:GeraSemaforo("FAT:Montagem de Carga")

	U_BIAMsgRun("SALVANDO CARGA...",,{|| lRet := SalvProc()})

	//	__oSemaforo:LiberaSemaforo()
	//else
	//	Return(.F.)
	//EndIf

Return(lRet)

Static Function CheckTipoAgen()

	Local lRet := .T.

	If (M->ZZV_TPAGEN == 'A')

		If (Empty(M->ZZV_DATAAG) .Or. Empty(StrTran(AllTrim(M->ZZV_HORAAG) , ":", "" )))
			lRet := .F.
			MsgAlert("Os campos 'Data Age.' e 'Hora Age.' são obrigatórios para tipo de agendamento='Agendado'.","Atenção !!!")
		EndIf

	ElseIf (M->ZZV_TPAGEN == 'E')

		If (Empty(M->ZZV_DATAAG))
			lRet := .F.
			MsgAlert("Os campos 'Data Age.' é obrigatórios para tipo de agendamento='Encaixe'.","Atenção !!!")
		EndIf

	EndIf

	If (INCLUI)

		If (!Empty(M->ZZV_DATAAG) .And. M->ZZV_DATAAG < dDataBase)

			lRet := .F.
			MsgAlert("A data do carregamento informada e menor que data atual.","Atenção !!!")

		EndIf

	EndIf

Return lRet


Static Function SalvProc()

	Local I
	Local _aRet := {}
	Local _aCols := AClone(oGDItems:ACols)
	Local lCredito
	Local lEstoque
	Local lAvalCred
	Local cAntTkT 	:= ''
	Local cNovoTkT 	:= ''

	U_GravaPZ2(0,"ZZV",M->ZZV_CARGA,"INICIO","EMP:"+CEMPANT,"SAV",CUSERNAME)

	BEGIN TRANSACTION

		ZZV->(DbSetOrder(1))
		ZZW->(DbSetOrder(1))
		Z11->(DbSetOrder(1))

		//GRAVA DADOS DO CABECALHO DA CARGA
		IF ZZV->(DbSeek(XFilial("ZZV")+M->ZZV_CARGA))
			RecLock("ZZV",.F.)
		ELSE
			RecLock("ZZV",.T.)
			ZZV->ZZV_FILIAL	:= XFILIAL("ZZV")
			ZZV->ZZV_CARGA	:= M->ZZV_CARGA
			ZZV->ZZV_DATINC	:= dDataBase
			ZZV->ZZV_USU	:= cUserName
		ENDIF

		//(22/12/14 - Thiago) -> Guarda os Tickets
		cAntTkT 	:= ZZV->ZZV_TICKET
		cNovoTkT 	:= M->ZZV_TICKET

		ZZV->ZZV_TICKET	:= M->ZZV_TICKET
		ZZV->ZZV_PLACA	:= M->ZZV_PLACA
		ZZV->ZZV_CODMOT	:= M->ZZV_CODMOT
		ZZV->ZZV_MOTOR	:= M->ZZV_MOTOR
		ZZV->ZZV_DOCMOT	:= M->ZZV_DOCMOT
		ZZV->ZZV_PL_UF	:= M->ZZV_PL_UF
		ZZV->ZZV_PL_MUN	:= M->ZZV_PL_MUN
		ZZV->ZZV_TRANSP	:= M->ZZV_TRANSP
		ZZV->ZZV_OBS	:= M->ZZV_OBS
		ZZV->ZZV_CFRETE	:= M->ZZV_CFRETE
		ZZV->ZZV_DATAAG	:= M->ZZV_DATAAG
		ZZV->ZZV_HORAAG	:= M->ZZV_HORAAG
		ZZV->ZZV_GALPAO	:= M->ZZV_GALPAO
		ZZV->ZZV_TICKEX	:= M->ZZV_TICKEX
		ZZV->ZZV_TPAGEN	:= M->ZZV_TPAGEN

		If ZZV->(FieldPos("ZZV_OBSNF1")) > 0
			ZZV->ZZV_OBSNF1	:= M->ZZV_OBSNF1
		EndIf

		ZZV->(MsUnlock())

		IF INCLUI
			ConfirmSx8()
		ENDIF

		//SALVAR AS ALTERACOES DO CABECALHO NA OC NO ECOSIS
		//EXECUTAR STORED PROCEDURE PARA IMPORTACAO DA OC PARA O ECOSIS
		IF TCSPEXIST(U_GSPName("EOS_UPDATE_ROMANEIO"))
			_aRet := TCSPEXEC(U_GSPName("EOS_UPDATE_ROMANEIO"),_cEmpFil,M->ZZV_CARGA)

			If Type("_aRet") == "A" .And. Len(_aRet) > 0 .AND. _aRet[1] > 0
				MSGALERT("EXISTEM ORDENS DE CARREGAMENTO JÁ IMPRESSAS PELA EXPEDIÇÃO."+CRLF+CRLF+;
					"FAVOR SOLICITAR O CANCELAMENTO DA IMPRESSÃO, "+CRLF+;
					"OU NÃO SERÁ POSSÍVEL ALTERAR OS DADOS DO CABEÇALHO DAS MESMAS.", "ATUALIZAÇÃO DE CARGA")
			EndIf
		ENDIF

		//SE ALTERANDO DADOS DO TRANSPORTE - FINALIZA TRANSACAO E ENCERRA.
		IF !(nOpca == 6)

			//Inclui/Altera todas as linhas nao integradas
			FOR I := 1 To Len(_aCols)

				//DELETAR LINHAS EXCLUIDAS - LIBERAR ITENS DOS PEDIDOS
				IF _aCols[I][Len(oGDItems:AHeader)+1] .And. _aCols[I][9] == "1"
					IF ZZW->(DbSeek(XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))
						While .Not. ZZW->(Eof()) .AND. ZZW->(ZZW_FILIAL+ZZW_PEDIDO+ZZW_ITEM+ZZW_SEQUEN) == (XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4])
							IF ZZW->ZZW_STATUS <> 'X'
								RecLock("ZZW",.F.)
								ZZW->(DbDelete())
								ZZW->(MsUnlock())

								SC9->(DbSetOrder(1))
								IF SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))
									RecLock("SC9",.F.)
									SC9->C9_AGREG = ""
									SC9->(MsUnlock())
								ENDIF
							ENDIF
							ZZW->(DbSkip())
						EndDo
					ENDIF
					loop
				ENDIF

				//BUSCAR NOVO SEQUENCIAL DO SC9 PARA CASOS DE CANCELAMENTO E NOVA LIBERACAO
				SC9->(DbSetOrder(1))
				IF !SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))

					//APAGAR O ZZW SE EXISTIR - VAI GRAVAR NOVAMENTE NO FINAL DO PROCESSO
					IF ZZW->(DbSeek(XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))
						While .Not. ZZW->(Eof()) .AND. ZZW->(ZZW_FILIAL+ZZW_PEDIDO+ZZW_ITEM+ZZW_SEQUEN) == (XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4])
							IF ZZW->ZZW_STATUS <> 'X'
								RecLock("ZZW",.F.)
								ZZW->(DbDelete())
								ZZW->(MsUnlock())
							ENDIF
							ZZW->(DbSkip())
						EndDo
					ENDIF

					//Procurar nova sequencia gerada no SC9
					_NSeq := ""
					IF SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]))

						While .Not. SC9->(Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == (XFilial("SC9")+_aCols[I][2]+_aCols[I][3])
							If (Empty(SC9->C9_AGREG))
								_NSeq := SC9->C9_SEQUEN
								Exit
							EndIf
							SC9->(DbSkip())
						EndDo

						_aCols[I][4] := _NSeq

					ENDIF

					If (Empty(_NSeq))
						DisarmTransaction()
						MSGALERT("ERRO AO ENCONTRAR NOVA SEQUENCIA DE LIBERAÇÃO"+CRLF+"REFAÇA AS LIBERAÇÕES OU VERIFIQUE AS QUANTIDADES DA CARGA","LIBERAÇÃO DE CARGA")
						Return(.F.)
					Else
						MSGALERT("FOI ENCONTRADA ALTERAÇÃO NA LIBERAÇÃO DO PEDIDO "+_aCols[I][2]+CRLF+"REFAÇA AS LIBERAÇÕES OU VERIFIQUE AS QUANTIDADES DA CARGA","LIBERAÇÃO DE CARGA")
					EndIf

				ENDIF

				IF !Empty(_aCols[I][1])  .And. _aCols[I][9] == "1"

					SC9->(DbSetOrder(1))
					IF SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))

						//VALIDAR A QUANTIDADE A LIBERAR DO PEDIDO  - GERAL - VERIFICANDO SE O PEDIDO ESTA COM SALDO A LIBERAR MENOR QUE ZERO
						IF !ChkSalPed(SC9->C9_PEDIDO, SC9->C9_ITEM, 0)
							DisarmTransaction()
							Return(.F.)
						ENDIF

						_nQtdLib := 0
						_nQtdDif := 0

						//POSICIONAR SC5 PARA AS FUNCOES PADROES
						SC5->(DbSetOrder(1))
						SC5->(DbSeek(XFilial("SC5")+SC9->C9_PEDIDO))

						//ESTORNAR TODOS OS ITENS E GERAR AS LIBERAOES CORRETAS - ITENS NAO FATURADOS
						If Empty(SC9->C9_NFISCAL) .AND. (SC9->C9_QTDLIB <> _aCols[I][6])

							U_GravaPZ2(0,"ZZV",M->ZZV_CARGA,"INI_ALTEMP","EMP:"+CEMPANT,"EMP",CUSERNAME)

							__BECDTLORI := SC9->C9_DATALIB
							__nRAStatus := SC9->C9_YRASTAT

							__YTPBLCT	:= SC9->C9_YTPBLCT
							__YDTBLCT	:= SC9->C9_YDTBLCT
							__YDTLICT	:= SC9->C9_YDTLICT

							_NSeq := ""
							_nQtdDifOri := SC9->C9_QTDLIB - _aCols[I][6]
							SC9->(a460Estorna())

							lCredito 	:= .T.
							lEstoque 	:= .T.
							lAvalCred 	:= .T.

							//SE TIVER PEDIDO CADASTRADO PARA LIBERACAO NAO AVALIAR CREDITO.
							SZN->(DbSetOrder(1))
							IF	SZN->(DbSeek(XFilial("SZN")+SC9->C9_PEDIDO)) .And. (SZN->ZN_DATALIM >= dDataBase) .And. (SZN->ZN_DATAINI <= dDataBase)
								lAvalCred := .F.
							ENDIF

							//SE FOR PEDIDO DE RA E ESTIVER LIBERADO, ARMAZENA VARIAVEL PARA GRAVAÇÃO, APÓS ALTERAÇÃO DA QUANTIDADE
							If Alltrim(SC9->C9_YRASTAT) == "1"
								lAvalCred 	:= .F.
							EndIf

							SC6->(DbSetOrder(1))
							IF SC6->(DbSeek(XFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM)))

								//VALIDAR A QUANTIDADE A LIBERAR DO PEDIDO - 1a LIBERACAO
								IF !ChkSalPed(SC9->C9_PEDIDO, SC9->C9_ITEM, _aCols[I][6])
									DisarmTransaction()
									Return(.F.)
								ENDIF

								_nQtdLib2  := ConvUM(SC6->C6_PRODUTO, _aCols[I][6], 0, 2)

								_nQtdLib := MaLibDoFat(SC6->(RecNo()),_aCols[I][6],@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,_nQtdLib2)
								If (_nQtdDifOri > 0)

									//VALIDAR A QUANTIDADE A LIBERAR DO PEDIDO - 2a LIBERACAO DIFERENCA
									IF !ChkSalPed(SC9->C9_PEDIDO, SC9->C9_ITEM, _nQtdDifOri)
										DisarmTransaction()
										Return(.F.)
									ENDIF

									//Fernando - 14/06 - alterado para usar a funcao correta para calcular a segunda unidade de medida
									_nQtdLib2  := ConvUM(SC6->C6_PRODUTO, _nQtdDifOri, 0, 2)
									_nQtdDif := MaLibDoFat(SC6->(RecNo()),_nQtdDifOri,@lCredito,@lEstoque,lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,_nQtdLib2)
								EndIf
							ENDIF

							__BECDTLORI := Nil
							__nRAStatus := Nil

							__YTPBLCT	:= Nil
							__YDTBLCT	:= Nil
							__YDTLICT	:= Nil

							IF (lEstoque == .F.)
								MSGALERT("BLOQUEIO DE ESTOQUE PARA O PEDIDO: "+SC9->C9_PEDIDO+" ITEM: "+SC9->C9_ITEM+CRLF+"VERIFIQUE COM O SETOR RESPONSÁVEL.","LIBERAÇÃO DE CARGA - ESTOQUE")
							ELSEIF (lCredito == .F.)
								MSGALERT("BLOQUEIO DE CRÉDITO PARA O PEDIDO: "+SC9->C9_PEDIDO+" ITEM: "+SC9->C9_ITEM+CRLF+"VERIFIQUE COM O SETOR RESPONSÁVEL.","LIBERAÇÃO DE CARGA - CRÉDITO")
							ENDIF

							If (_nQtdLib <> _aCols[I][6]) .OR. (_nQtdDif <> _nQtdDifOri)
								DisarmTransaction()
								MSGALERT("ERRO NA ALTERAÇÃO DOS PEDIDOS LIBERADOS"+CRLF+"REFAÇA AS LIBERAÇÕES OU VERIFIQUE AS QUANTIDADES DA CARGA","LIBERAÇÃO DE CARGA")
								Return(.F.)
							EndIf

							//Procurar nova sequencia gerada no SC9
							SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]))
							While .Not. SC9->(Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == (XFilial("SC9")+_aCols[I][2]+_aCols[I][3])
								If (SC9->C9_QTDLIB == _nQtdLib) .And. (Empty(SC9->C9_AGREG))
									_NSeq := SC9->C9_SEQUEN
									Exit
								EndIf

								//Fernando/Facile em 27/03/2015 - registrar os campos de arremate de lote apos gerar novo SC9 liberado
								If SC9->(FieldPos("C9_YARELOT")) > 0 .And. SC9->(FieldPos("C9_YLOTTOT")) > 0 .And. Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. !Empty(SC9->C9_LOTECTL) .And. (SC9->C9_DATALIB >= dDataBase)
									U_FR2C9LOT()
								EndIf

								SC9->(DbSkip())
							EndDo

							If (Empty(_NSeq))
								DisarmTransaction()
								MSGALERT("ERRO AO ENCONTRAR NOVA SEQUENCIA DE LIBERAÇÃO"+CRLF+"REFAÇA AS LIBERAÇÕES OU VERIFIQUE AS QUANTIDADES DA CARGA","LIBERAÇÃO DE CARGA")
								Return(.F.)
							EndIf

							//APAGAR O ZZW SE EXISTIR - VAI GRAVAR NOVAMENTE NO FINAL DO PROCESSO
							IF ZZW->(DbSeek(XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))
								While .Not. ZZW->(Eof()) .AND. ZZW->(ZZW_FILIAL+ZZW_PEDIDO+ZZW_ITEM+ZZW_SEQUEN) == (XFilial("ZZW")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4])
									IF ZZW->ZZW_STATUS <> 'X'
										RecLock("ZZW",.F.)
										ZZW->(DbDelete())
										ZZW->(MsUnlock())
									ENDIF
									ZZW->(DbSkip())
								EndDo
							ENDIF

							_aCols[I][4] := _NSeq

							U_GravaPZ2(0,"ZZV",M->ZZV_CARGA,"FIM_ALTEMP","EMP:"+CEMPANT,"EMP",CUSERNAME)

						EndIf
					ENDIF
				ENDIF

				//REGRAVAR DADOS DA CARGA - LIBERACOES E ROMANEIO -- TEM QUE SER FEITO TODA HORA PARA CASOS DE CANCELAMENTO APOS INTEGRACAO COM ECOSIS
				SC9->(DbSetOrder(1))
				IF SC9->(DbSeek(XFilial("SC9")+_aCols[I][2]+_aCols[I][3]+_aCols[I][4]))

					_lZZWOk := .F.

					IF ZZW->(DbSeek(XFilial("ZZW")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
						While .Not. ZZW->(Eof()) .AND. ZZW->(ZZW_FILIAL+ZZW_PEDIDO+ZZW_ITEM+ZZW_SEQUEN) == (XFilial("ZZW")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN)
							IF ZZW->ZZW_STATUS <> 'X'
								_lZZWOk := .T.
								exit
							ENDIF
							ZZW->(DbSkip())
						EndDo
					ENDIF

					IF _lZZWOk
						RecLock("ZZW",.F.)
					ELSE
						RecLock("ZZW",.T.)
						ZZW->ZZW_FILIAL := XFILIAL("ZZW")
						ZZW->ZZW_PEDIDO := SC9->C9_PEDIDO
						ZZW->ZZW_ITEM	:= SC9->C9_ITEM
						ZZW->ZZW_CARGA	:= M->ZZV_CARGA
						ZZW->ZZW_SEQUEN	:= SC9->C9_SEQUEN
						ZZW->ZZW_STATUS	:= "1"
					ENDIF

					ZZW->ZZW_CCLI 	:= SC9->C9_CLIENTE
					ZZW->ZZW_LCLI 	:= SC9->C9_LOJA
					ZZW->(MsUnlock())

					//Fernando/Facile em 21/09/2015 - essa funcao fUpdIntPes abaixo estava desposicionando o SC9
					__aAreaC9 := SC9->(GetArea())

					fUpdIntPes(ZZW->ZZW_CARGA, ZZW->ZZW_STATUS)

					SC9->(RestArea(__aAreaC9))

					RecLock("SC9",.F.)
					SC9->C9_AGREG = M->ZZV_CARGA
					SC9->(MsUnlock())

					/////////////////////////////////////////////////////////////////////////////////////////////
					//GRAVAR SZ9 PARA MANTER AS ROTINAS ANTIGAS FUNCIONANDO - PROVISORIO/////////////////////////
					SZ9->(DbSetOrder(4))
					IF SZ9->(DbSeek(XFILIAL("SZ9")+SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN)))
						While .Not. SZ9->(Eof()) .AND. SZ9->(Z9_FILIAL+Z9_PEDIDO+Z9_ITEM+Z9_SEQUEN) == (XFILIAL("SZ9")+SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN))
							RecLock("SZ9",.F.)
							SZ9->(DbDelete())
							SZ9->(MsUnlock())

							SZ9->(DbSkip())
						EndDo
					ENDIF

					SDC->(DbSetOrder(4))
					IF SDC->(DbSeek(XFilial("SDC")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
						While .Not. SDC->(Eof()) .And. SDC->(DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_SEQ) == (XFilial("SDC")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN)

							RecLock("SZ9",.T.)
							SZ9->Z9_FILIAL	:= XFILIAL("SZ9")
							SZ9->Z9_PEDIDO	:= SC9->C9_PEDIDO
							SZ9->Z9_ITEM	:= SC9->C9_ITEM
							SZ9->Z9_SEQUEN	:= SC9->C9_SEQUEN
							SZ9->Z9_NUMERO	:= SUBSTR(DTOS(dDataBase),1,4)+M->ZZV_CARGA
							SZ9->Z9_AGREG	:= M->ZZV_CARGA
							SZ9->Z9_PRODUTO	:= SC9->C9_PRODUTO
							SZ9->Z9_DESCRIC	:= POSICIONE("SB1",1,XFILIAL("SB1")+SC9->C9_PRODUTO,"B1_DESC")
							SZ9->Z9_QTDLIB	:= SDC->DC_QUANT
							SZ9->Z9_QTDLIB2	:= SDC->DC_QTSEGUM
							SZ9->Z9_QTDORI	:= SDC->DC_QUANT
							SZ9->Z9_LOCALIZ	:= SDC->DC_LOCALIZ
							SZ9->Z9_EMISSAO	:= dDataBase
							SZ9->Z9_LOCAL	:= SC9->C9_LOCAL
							SZ9->Z9_ORIGEM	:= "S"
							SZ9->Z9_PESOBR	:= RECALPESO(SC9->C9_PRODUTO, SC9->C9_LOTECTL, SDC->DC_QUANT)
							SZ9->Z9_LOTECTL	:= SC9->C9_LOTECTL
							SZ9->(MsUnlock())

							SDC->(DbSkip())
						EndDo
					ENDIF

				ENDIF

			NEXT I

			//VERIFICA SE FORAM APAGADOS TODOS OS ITENS PARA APAGAR O CABECALHO
			ZZW->(DbSetOrder(2))
			IF !ZZW->(DbSeek(XFilial("ZZW")+M->ZZV_CARGA))
				RecLock("ZZV",.F.)
				ZZV->(DbDelete())
				ZZV->(MsUnlock())
			ENDIF

			//VERIFICA SE A CARGA E DE AMOSTRA E FINALIZA AUTOMATICAMENTE
			ZZV->(DbSetOrder(1))
			IF ZZV->(DbSeek(XFilial("ZZV")+M->ZZV_CARGA))
				IF U_BEC01TAM()
					RecLock("ZZV",.F.)
					ZZV->ZZV_DATFIM	:= dDataBase
					ZZV->(MsUnlock())
				ENDIF
			ENDIF

			//Atualiza o TICKET
			dbSelectArea("Z11")
			Z11->(dbSetOrder(1))

			If(Empty(AllTrim(cAntTkT)))
				If Z11->(dbSeek(XFilial("Z11")+cNovoTkT))
					Reclock("Z11",.F.)
					Z11->Z11_SITUAC := "A"
					MsUnLock()
				EndIf
			Else
				If Z11->(dbSeek(XFilial("Z11")+cAntTkT))
					Reclock("Z11",.F.)
					Z11->Z11_SITUAC := "C"
					MsUnLock()
				EndIf

				If Z11->(dbSeek(XFilial("Z11")+cNovoTkT))
					Reclock("Z11",.F.)
					Z11->Z11_SITUAC := "A"
					MsUnLock()
				EndIf

			EndIf

			//atualiza galpao
			If ( AllTrim(CEMPANT) <> "07")   //Carga na Empresa 07 - VINILICO - Fernando em 28/01/20

				ZZV->(DbSetOrder(1))
				If ZZV->(DbSeek(XFilial("ZZV")+M->ZZV_CARGA))
					RecLock("ZZV",.F.)
					ZZV->ZZV_GALPAO	:= AtuGalpao(M->ZZV_CARGA)
					ZZV->(MsUnlock())
				EndIf

			EndIf

		ENDIF

	END TRANSACTION

	U_GravaPZ2(0,"ZZV",M->ZZV_CARGA,"FIM","EMP:"+CEMPANT,"SAV",CUSERNAME)

Return(.T.)

Static Function AtuGalpao(cCarga)

	Local cQuery		:= ""
	Local cDesc			:= ""
	Local cAliasTrab	:= Nil
	Local cBanco		:= ""
	Local aLista		:= ""
	Local nI			:= 0

	If (AllTrim(cEmpAnt) $ '01/05/13')
	
		If(AllTrim(cEmpAnt) == '01')
			cBanco		:= "DADOSEOS"
		ElseIf(AllTrim(cEmpAnt) == '05')
			cBanco		:= "DADOS_05_EOS"
		ElseIf(AllTrim(cEmpAnt) == '13')
			cBanco		:= "DADOS_13_EOS"
		EndIf
	
	
		cQuery += "SELECT 																																		"
		cQuery += "	DISTINCT GALPAO=T3.dsc_local 																												"
		cQuery += "	FROM ["+cBanco+"].[dbo].[cep_etiqueta_pallet] T1																							"
		cQuery += "	JOIN ["+cBanco+"].[dbo].[cep_etiqueta_endereco]			T2 ON T1.cod_endereco = T2.cod_endereco												"
		cQuery += "	JOIN ["+cBanco+"].[dbo].[cep_cad_local]					T3 ON T2.end_local = T3.end_local	AND T2.cod_deposito	= T3.cod_deposito			"
		cQuery += "	JOIN (																									"
		cQuery += "		SELECT PRODUTO=C9_PRODUTO, LOTE=C9_LOTECTL FROM "+RetSQLName("ZZW")+" ZZW											"
		cQuery += "		JOIN "+RetSQLName("SC9")+" SC9 ON  C9_PEDIDO = ZZW_PEDIDO AND C9_FILIAL = ZZW_FILIAL AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW.ZZW_SEQUEN AND  SC9.D_E_L_E_T_ = ''	"
		cQuery += "		WHERE 																								"
		cQuery += "		ZZW_CARGA = '"+AllTrim(cCarga)+"'																	"
		cQuery += "		AND ZZW.D_E_L_E_T_ = ''																				"
		cQuery += "	) T4 ON cod_produto COLLATE Latin1_General_BIN = RTRIM(T4.PRODUTO)  AND etiq_lote COLLATE Latin1_General_BIN =	RTRIM(T4.LOTE)		"
		cQuery += "	WHERE 																									"
		cQuery += "	nf_numero = ''																							"
		cQuery += "	AND etiq_cancelada <> 1
	
		cAliasTrab 	:= GetNextAlias()
		TCQUERY cQuery NEW ALIAS (cAliasTrab)
	
		While !((cAliasTrab)->(Eof()))
			cDesc	+= AllTrim((cAliasTrab)->GALPAO)+"#"
			(cAliasTrab)->(DbSkip())
		EndDo
		(cAliasTrab)->(DbCloseArea())
	
		aLista	:= StrTokArr( AllTrim(cDesc), "#")
		cDesc	:= ""
	
		For nI:=1 To Len (aLista)
	
			If (!Empty(aLista[nI]))
	
				cDesc += aLista[nI]
				If (nI == Len(aLista)-1)
					cDesc := AllTrim(cDesc)
					If (!Empty(cDesc))
						cDesc += " e "
					EndIf
				ElseIf (nI < Len(aLista))
					cDesc += " "
				EndIf
	
			EndIf
	
		Next nI
	EndIf
	

Return cDesc


Static Function EnvExped()

	IF !TCSPEXIST(U_GSPName("EOS_EXPORT_ROMANEIO"))
		Return
	ENDIF

	//Libera botao de Exportacao de Dados Ecosis
	If !U_VALOPER("004",.F.)
		MsgAlert("USUÁRIO SEM ACESSO A ESTA OPERAÇÃO","OP 004 - INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	IF !MSGNOYES("Tem certeza que deseja integrar esta carga com a Expedição (ECOSIS)?"+CRLF+"Não ser?mais possível a manutenção nestes items","INTEGRAÇÃO ECOSIS")
		Return
	ENDIF

	IF Salvar()
		U_BIAMsgRun("INTEGRANDO COM ECOSIS...",, {|| EnvExpPrc() })
		oGDItems:oBrowse:Refresh()
	ENDIF

Return


Static Function EnvExpPrc()

	Local _aCols := AClone(oGDItems:ACols)
	Local _nLin
	Local cSQL

	//EXECUTAR STORED PROCEDURE PARA VALIDAR DADOS DO ECOSIS
	IF TCSPEXIST(U_GSPName("EOS_VALID_EXP_OC"))

		_aRet := TCSPEXEC(U_GSPName("EOS_VALID_EXP_OC"),_cEmpFil,M->ZZV_CARGA)

		If Type("_aRet") == "A"
			IF Len(_aRet) > 0 .AND. _aRet[1] <> '0'
				MSGALERT(_aRet[2], "VALIDAÇÃO DE EXPORTAÇÃO DE CARGA")
				Return
			ENDIF
		Else
			MSGALERT("ERRO!!  OCORREU UM ERRO AO EXPORTAR A OC PARA O ECOSIS.  ENTRE EM CONTATO COM A T.I.")
		EndIf

	ENDIF

	private _cArquivo := "EXPECOSIS"+AllTrim(CEMPANT)+".TMP"
	private _nHandle
	bErro := ErrorBlock( { |oErr| IIf(File(_cArquivo), DelSemaf(_nHandle, _cArquivo),), MsgAlert(oErr:Description,"CONTROLE DE CARGA: ERRO INTEGRAÇÃO COM ECOSIS") })

	BEGIN SEQUENCE
		BEGIN TRANSACTION

			If !File(_cArquivo)
				_nHandle := fCreate(_cArquivo)
			Else
				DisarmTransaction()
				MsgAlert("Processo já está sendo executado em outra estação!","Exportação ECOSIS")
				Return
			EndIf

			cSQL := "EXEC "+U_GSPName("EOS_EXPORT_ROMANEIO")+" '"+_cEmpFil+"', '"+cUserName+"' , '"+M->ZZV_CARGA+"', '', '' "

			TCQuery cSQL Alias "TRBTMP" New

			TRBTMP->(DbGoTop())

			//TICKET 7975 - tratamento quando ocorre erro no retorno da SP
			If TRBTMP->(FieldPos("ErrorNumber")) > 0

				U_FROPMSG("EOS_EXPORT_ROMANEIO", TRBTMP->ErrorMessage,,,"Erro na execução da SP de integração")
				IIf(File(_cArquivo), DelSemaf(_nHandle,_cArquivo),)
				Return

			EndIf


			While .Not. TRBTMP->(Eof())

				ZZW->(DbSetOrder(1))
				IF ZZW->(DbSeek(XFilial("ZZW")+TRBTMP->(PEDIDO+ITEM+SEQUEN)))

					RecLock("ZZW",.F.)
					ZZW->ZZW_STATUS := "2"
					ZZW->ZZW_NUMOCE := TRBTMP->NUMORD
					ZZW->(MsUnlock())

					fUpdIntPes(ZZW->ZZW_CARGA, ZZW->ZZW_STATUS)

				ENDIF

				_nLin := AScan(_aCols, {|x|  x[2] == TRBTMP->PEDIDO .And. x[3] == TRBTMP->ITEM .And. x[4] == TRBTMP->SEQUEN })
				IF (_nLin > 0)
					oGDItems:ACols[_nLin][8] := TRBTMP->NUMORD
					oGDItems:ACols[_nLin][9] := "2"
					oGDItems:oBrowse:Refresh()
				ENDIF

				TRBTMP->(DbSkip())
			EndDo

			TRBTMP->(DbCloseArea())

			IIf(File(_cArquivo), DelSemaf(_nHandle,_cArquivo),)
		END TRANSACTION
	END SEQUENCE
	ErrorBlock( bErro )

	oGDItems:oBrowse:Refresh()

Return


Static Function DelSemaf(_nHandle,_cArquivo)

	fClose(_nHandle)
	fErase(_cArquivo)

Return


Static Function GetPedidos()

	Local aButtons := {}
	Local oFont1 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oPanelRod
	Local oPanelTop
	Local oSay1

	Private oDlgPed
	Private getPedido
	Private cetPedido := SPACE(6)
	Private getCCli
	Private cetCCli   := SPACE(6)
	Private getNCli
	Private cetNCli   := SPACE(40)

	Private SC9Pedido	:= ""
	Private SC9Qtdlib	:= 0
	Private SC9Item		:= ""
	Private SC9Nfiscal	:= ""
	Private SC9BlCred	:= ""
	Private SC9DtLbMn	:= ""

	Private oCB1
	Private lCB1 := .F.
	Private lblGetPeso := Transform(0,"@E 999,999,999.99")
	Private lblGetQtde := Transform(0,"@E 999,999,999.99")

	Private listItems
	Private aListPed := {}
	Private _lMarcado := .F.

	DEFINE MSDIALOG oDlgPed TITLE "SELECIONAR PEDIDOS" FROM 000, 000  TO 500, 1100 COLORS 0, 16777215 PIXEL


	@ 014, 000 MSPANEL oPanelTop SIZE 600, 030 OF oDlgPed COLORS 0, 16777215 RAISED
	@ 011, 036 MSGET getPedido VAR cetPedido SIZE 047, 012 OF oPanelTop PICTURE "@!" COLORS 0, 16777215 FONT oFont1 PIXEL VALID lGetPed()
	@ 012, 005 SAY oSay1 PROMPT "Pedido:" SIZE 029, 009 OF oPanelTop FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 012, 099 SAY oSay2 PROMPT "Cliente:" SIZE 029, 009 OF oPanelTop FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 011, 133 MSGET getCCli VAR cetCCli SIZE 039, 012 OF oPanelTop PICTURE "@!" COLORS 0, 16777215 FONT oFont1 PIXEL VALID lGetPed()
	@ 011, 176 MSGET getNCli VAR cetNCli SIZE 154, 012 OF oPanelTop COLORS 0, 16777215 FONT oFont1 READONLY PIXEL
	@ 012, 345 CHECKBOX oCB1 VAR lCB1 PROMPT "Exibir Itens Faturados" SIZE 095, 008 OF oPanelTop COLORS 0, 16777215 FONT oFont1 PIXEL ON CHANGE CB1Change()
	@ 183, 000 MSPANEL oPanelRod SIZE 400, 017 OF oDlgPed COLORS 0, 16777215 RAISED
	@ 005, 139 SAY oSay3 PROMPT "QTDE TOTAL:" SIZE 056, 013 OF oPanelRod FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ 005, 201 SAY lblGetQtde PROMPT "" SIZE 080, 013 OF oPanelRod FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 005, 288 SAY oSay5 PROMPT "PESO TOTAL:" SIZE 054, 013 OF oPanelRod FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ 005, 346 SAY lblGetPeso PROMPT "" SIZE 080, 013 OF oPanelRod FONT oFont1 COLORS 0, 16777215 PIXEL

	fListBox1()
	CalcGetTot()

	// Don't change the Align Order
	oPanelTop:Align := CONTROL_ALIGN_TOP
	oPanelRod:Align := CONTROL_ALIGN_BOTTOM
	listItems:Align := CONTROL_ALIGN_ALLCLIENT

	getNCli:Disable()

	getPedido:SetFocus()

	//ACTIVATE MSDIALOG oDlgPed CENTERED
	ACTIVATE MSDIALOG oDlgPed CENTERED ON INIT (EnchoiceBar(oDlgPed, {|| IIF(GetPedProc(),oDlgPed:End(),)}, {|| oDlgPed:End()},,aButtons))

Return


Static Function CB1Change()

	IF !Empty(cetPedido)
		lGetPed()
	ENDIF

Return


Static Function fListBox1()

	Local oOk 	   := LoadBitmap( GetResources(), "LBOK" )
	Local oNo 	   := LoadBitmap( GetResources(), "LBNO" )

	@ 044, 000 LISTBOX listItems FIELDS ;
		HEADER "","FORNO","ARMAZEM", "PEDIDO","ITEM","SEQ.","PRODUTO","LOTE","DESCRICAO","QTDE LIBER.","QTDE CARGA","PESO","DT ENTREGA","DT EMPENHO","TEMPO M.";
		SIZE 600, 139 OF oDlgPed COLORS 0, 16777215 PIXEL;
		ColSizes 10,20,30,40,25,15,20,20,50,50,50,40,50,40

	//Propriedade da listbox
	listItems:lHscroll := .T.

	aAux := Array(nc_NUMCOLS)
	aAux[nc_MARK	] := .F.
	aAux[nc_FORNO	] := Space(3)
	aAux[nc_ARMAZEM	] := Space(2)
	aAux[nc_EMPENHO	] := DTOC(CTOD(" "))
	aAux[nc_PEDIDO	] := Space(6)
	aAux[nc_ITEM	] := Space(2)
	aAux[nc_SEQ		] := Space(3)
	aAux[nc_PRODUTO	] := Space(15)
	aAux[nc_LOTE	] := Space(10)
	aAux[nc_DESCR	] := Space(30)
	aAux[nc_QLIBER	] := 0
	aAux[nc_QCARGA	] := 0
	aAux[nc_PESO	] := 0
	aAux[nc_ENTREGA	] := DTOC(CTOD(" "))
	aAux[nc_TEMPOM	] := 0

	AAdd(aListPed,aAux)

	//Preenchendo dados
	IF Len(aListPed) > 0

		//Metodos da listbox
		listItems:bLDblClick := {|| IIF(listItems:ColPos==1,;
			Eval({|| aListPed[listItems:nAt,nc_MARK] := !(aListPed[listItems:nAt,nc_MARK]) , ValidaPrazo(listItems:nAt) }),;
			TLBEditCell(listItems,aListPed,AllTrim(Str(nc_QCARGA)),nc_QCARGA)) }

		//Prepara a funcao de clicar no cabecalho para marcar/desmarcar tudo
		listItems:bHeaderClick := { |oObj,nCol| iif( nCol == 1, Eval({|| MarcTudo() , CalcGetTot() }),) }

		/*
		#DEFINE nc_MARK		01
		#DEFINE nc_FORNO	02
		#DEFINE nc_ENTREGA	03
		#DEFINE nc_TEMPOM	04
		#DEFINE nc_PEDIDO	05
		#DEFINE nc_ITEM		06
		#DEFINE nc_SEQ		07
		#DEFINE nc_PRODUTO	08
		#DEFINE nc_LOTE		09
		#DEFINE nc_DESCR	10
		#DEFINE nc_QLIBER	11
		#DEFINE nc_QCARGA	12
		#DEFINE nc_PESO		13
		#DEFINE nc_ARMAZEM	14
		#DEFINE nc_EMPENHO	15
		*/

		listItems:SetArray(aListPed)
		listItems:bLine 		:= {|| {;
			If(	aListPed[listItems:nAT,nc_MARK],oOk,oNo),;
				aListPed[listItems:nAT,nc_FORNO],;
				aListPed[listItems:nAT,nc_ARMAZEM],;
				aListPed[listItems:nAT,nc_PEDIDO],;
				aListPed[listItems:nAT,nc_ITEM],;
				aListPed[listItems:nAT,nc_SEQ],;
				SubStr(aListPed[listItems:nAT,nc_PRODUTO],1,8),;
				SubStr(aListPed[listItems:nAT,nc_LOTE],1,10),;
				SubStr(aListPed[listItems:nAT,nc_DESCR],1,50),;
				Transform(aListPed[listItems:nAT,nc_QLIBER],"@E 999,999,999.99"),;
				Transform(aListPed[listItems:nAT,nc_QCARGA],"@E 999,999,999.99"),;
				Transform(aListPed[listItems:nAT,nc_PESO],"@E 999,999,999.99"),;
				aListPed[listItems:nAT,nc_ENTREGA],;
				aListPed[listItems:nAT,nc_EMPENHO],;
				aListPed[listItems:nAT,nc_TEMPOM]}}

		ENDIF

		Return


Static Function TLBEditCell(_oListBox,_aListBox,_cCols,_nCol)

	Local aOld := 0

	If (Len(_aListBox) > 0)

		aOld := _aListBox[_oListBox:nAt,_nCol]

		IF STR(_nCol,2) $ _cCols
			//Edita a celula selecionada
			lEditCell( _aListBox, _oListBox, IIF(ValType(_aListBox[_oListBox:nAt,_nCol]) == "N","@E 999,999,999.99","@!"), _nCol)
			//Edit a proxima celula se confirmar a alteracao
			If (aOld <> _aListBox[_oListBox:nAt,_nCol]) .And. (_nCol <> Val(Right(_cCols,1)))
				TLBEditCell(_oListBox,_aListBox,_cCols,   Val(SubStr(_cCols,AT(STR(_nCol,1),_cCols)+1,1)))
			EndIf
		ENDIF

		//Validar qtde digitada
		If (_aListBox[_oListBox:nAt,12]	> _aListBox[_oListBox:nAt,11])
			MsgInfo("Somente é possível reduzir a quantidade original liberada!"+CRLF+"Para aumentar altere ou faça nova liberação do pedido de vendas.","LIBERAÇÃO DE CARGA")
			_aListBox[_oListBox:nAt,12] := _aListBox[_oListBox:nAt,11]
		Endif

		//AJUSTAR QUANTIDADE DE CAIXAS
		_aListBox[_oListBox:nAt,12] := QTDSEGUN(_aListBox[_oListBox:nAt,8], _aListBox[_oListBox:nAt,12])

		//AJUSTAR O PESO
		_aListBox[_oListBox:nAt,13] := RECALPESO(_aListBox[_oListBox:nAt,8], _aListBox[_oListBox:nAt,9], _aListBox[_oListBox:nAt,12])

		//Atualizar o Total
		CalcGetTot()

	EndIf
Return


Static Function QTDSEGUN(_cProd, wnQtdOrig)

	Local wnUnsven
	Local wxInteiro
	Local wxDecimal

	Local wnQtdven := wnQtdOrig

	SB1->(DbSetOrder(1))
	IF SB1->(DbSeek(xFilial("SB1")+_cProd))

		If AllTrim(_cProd) <> "0000C500" .And. AllTrim(_cProd) <> "0000C700" .And. 	AllTrim(_cProd) <> "0000C800"
			If SB1->B1_TIPCONV == "D"
				wnUnsven:= (wnQtdven / SB1->B1_CONV)
			Else
				wnUnsven:= (wnQtdven * SB1->B1_CONV)
			EndIf

			If SB1->B1_TIPO == "PA"
				wxInteiro := INT(wnUnsven)
				wxDecimal := (wnUnsven - INT(wnUnsven))

				If wxDecimal == 0
					wnQtdven := wnQtdOrig
				Else
					wnUnsven := wxInteiro + 1

					If SB1->B1_TIPCONV == "D"
						wnQtdven := (wnUnsven * SB1->B1_CONV)
					Else
						wnQtdven := (wnUnsven / SB1->B1_CONV)
					EndIf
				EndIf
			EndIf

			If wnQtdven <> wnQtdOrig
				MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"INC068_5")
			EndIf
		ENDIF

	ENDIF

RETURN(wnQtdven)


Static Function RECALPESO(_cProd, _cLote, _QtdLib)

	Local _PESOBR := 0
	Local _PESOEMB := 0

	ZZ9->(DbSetOrder(1))

	SB1->(DbSetOrder(1))
	IF SB1->(DbSeek(xFilial("SB1")+_cProd))

		IF ZZ9->(DbSeek(XFILIAL("ZZ9")+_cLote+_cProd))
			_PESOBR = _QtdLib * ZZ9->ZZ9_PESO
			_PESOEMB := ZZ9->ZZ9_PESEMB
		ELSE
			_PESOBR = _QtdLib * SB1->B1_PESO
			_PESOEMB := SB1->B1_YPESEMB
		ENDIF

		IF SB1->B1_TIPCONV == 'M'
			_PESOBR += ((_QtdLib * SB1->B1_CONV) * _PESOEMB)
		ELSE
			_PESOBR += ((_QtdLib / SB1->B1_CONV) * _PESOEMB)
		ENDIF

	ENDIF

Return(_PESOBR)


Static Function lGetPed()

	Local lRet := .T.
	Local lDigCli := .F.

	If AllTrim(ReadVar()) == "CETPEDIDO"

		If Empty(cetPedido)

			cetCCli := Space(6)
			cetNCli := ""
			getCCli:Enable()
			getCCli:SetFocus()
			oDlgPed:Refresh()
			Return(.T.)

		Else

			SC5->(DbSetOrder(1))
			If !SC5->(DbSeek(XFilial("SC5")+cetPedido))
				MsgAlert("PEDIDO NÃO EXISTE.","CONTROLE DE CARGAS")

				cetCCli := Space(6)
				cetNCli := ""
				cetPedido := Space(6)
				getCCli:Disable()
				getPedido:SetFocus()
				oDlgPed:Refresh()
				Return(.F.)
			EndIf

		EndIf

	ElseIf AllTrim(ReadVar()) == "CETCCLI"

		lDigCli := .T.

		If Empty(cetCCli)

			cetCCli := Space(6)
			cetNCli := ""
			cetPedido := Space(6)
			getCCli:Disable()
			getPedido:SetFocus()
			oDlgPed:Refresh()
			Return(.T.)

		Else

			SA1->(DbSetOrder(1))
			If !SA1->(DbSeek(XFilial("SA1")+cetCCli))
				MsgAlert("CLIENTE NÃO EXISTE.","CONTROLE DE CARGAS")

				cetCCli := Space(6)
				cetNCli := ""
				getCCli:Enable()
				getCCli:SetFocus()
				oDlgPed:Refresh()
				Return(.F.)

			EndIf

		EndIf

		If !Empty(cetPedido)
			Return(.T.)
		EndIf

	EndIf

	U_BIAMsgRun("Aguarde... Carregando Pedidos... ",,{|| lRet := lGetPedPrc(lDigCli) })

	If AllTrim(ReadVar()) == "CETPEDIDO" .And.  !Empty(cetPedido)

		getCCli:Disable()
		oDlgPed:Refresh()

	EndIf

Return(lRet)

Static Function lGetPedPrc(lDigCli)

	Local cAliasTmp
	Local _aCols 		:= AClone(oGDItems:ACols)
	Local _cWherePed, _cExpJCli, _cExpNCli
	Local _cWhereCli
	Local _nLin, _QtdLib,_PesoBR
	Local nSC5 			:= RetSqlName("SC5")
	Local nFil 			:= xFilial("SC5")
	Local rRet 			:= ""
	Local lRet 			:= .T.
	Local cLogRet 		:= ""
	Local lTemAmostra	:= .F.
	Local aAux

	Local cAliasTrab	:= Nil
	Local aLinha		:= {}
	Local aDados		:= {}

	Default lDigCli := .F.

	If !lDigCli .And. !Empty(cetPedido)
		_cWhereCli := "% SC9.C9_PEDIDO = '"+cetPedido+"' %"
	ElseIf lDigCli .And. !Empty(cetCCli)
		_cWhereCli := "% A1_COD = '"+cetCCli+"' %"
	Else
		Return(.T.)
	EndIf

	If !lCB1
		_cWherePed := "% (SC9.C9_BLEST = '  '	AND SC9.C9_BLCRED = '  ') %"
	Else
		_cWherePed := "% ((SC9.C9_BLEST = '  '	AND SC9.C9_BLCRED = '  ') OR (SC9.C9_BLEST = '10'	AND SC9.C9_BLCRED = '10')) %"
	EndIf

	_cExpJCli := "% A1_COD+A1_LOJA = ISNULL((select C5_YCLIORI+C5_YLOJORI from "+nSC5+" SC5 (nolock) where C5_FILIAL = '"+nFil+"' AND C5_NUM = C9_PEDIDO AND SC5.C5_YCLIORI<>'' AND SC5.D_E_L_E_T_<>'*'),C9_CLIENTE+C9_LOJA) AND SA1.D_E_L_E_T_<>'*' %"
	_cExpNCli := "% CASE WHEN C9_CLIENTE = '010064' THEN '* ' ELSE '' END + A1_NOME A1_NOME%"

	//SELECIONA PEDIDOS LIBERADOS - OU JA FATURADOS
	cAliasTmp := GetNextAlias()
	Beginsql Alias cAliasTmp
		%NOPARSER%

		SELECT  
		RECSC9 = SC9.R_E_C_N_O_, 
		A1_COD, 
		%Exp:_cExpNCli%, 
		C9_ITEM, 
		C9_SEQUEN, 
		C9_PRODUTO, 
		C9_LOTECTL, 
		B1_DESC,
		B1_YFORMAT,
		ZZ6_FORNOP = ISNULL(ZZ6_FORNOP,"N/A"),
		C9_QTDLIB, 
		C9_BLEST, 
		C9_BLCRED, 
		C9_NFISCAL, 
		C9_CLIENTE, 
		C9_LOJA, 
		C9_PEDIDO,
		C9_LOCAL, 
		C9_GRUPO,  
		C9_YRASTAT, 
		C9_YDTLICT, 
		C9_YDTBLCT, 
		C9_YTPBLCT, 
		C9_DATALIB,
		ROUND(C9_QTDLIB2-ROUND(C9_QTDLIB2,0,1),2) AS DIF,

		PESOBR = CASE WHEN B1_TIPCONV = 'M'
		THEN (C9_QTDLIB  * 
		ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9.ZZ9_FILIAL = %xFilial:ZZ9% AND ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.%NotDel%),B1_PESO))
		+ ((C9_QTDLIB * B1_CONV) * 
		ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9.ZZ9_FILIAL = %xFilial:ZZ9% AND ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.%NotDel%),B1_YPESEMB))
	ELSE (C9_QTDLIB  * ISNULL((SELECT ZZ9_PESO FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9.ZZ9_FILIAL = %xFilial:ZZ9% AND ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.%NotDel%),B1_PESO))
		+ ((C9_QTDLIB / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM %Table:ZZ9% ZZ9 (nolock) WHERE ZZ9.ZZ9_FILIAL = %xFilial:ZZ9% AND ZZ9_PRODUT = C9_PRODUTO AND ZZ9_LOTE = C9_LOTECTL AND ZZ9.%NotDel%),B1_YPESEMB)) END

		FROM %Table:SC9% SC9 (nolock)
		JOIN %Table:SC6% SC6 (nolock) ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM
		JOIN %Table:SB1% SB1 (nolock) ON B1_COD = C9_PRODUTO 
		JOIN %Table:SA1% SA1 (nolock) ON %Exp:_cExpJCli%
		LEFT JOIN %Table:ZZ6% ZZ6 (nolock) ON ZZ6_COD = substring(B1_COD,1,2) AND ZZ6.%NotDel%

		WHERE
		SB1.B1_FILIAL = %xFilial:SB1%
		AND SC9.C9_FILIAL = %xFilial:SC9%
		AND %Exp:_cWherePed%
		AND %Exp:_cWhereCli%	  
		AND (SELECT COUNT(*) FROM %Table:ZZW% ZZW (nolock) WHERE ZZW_FILIAL = %xFilial:ZZW% AND ZZW_PEDIDO = C9_PEDIDO AND ZZW_ITEM = C9_ITEM AND ZZW_SEQUEN = C9_SEQUEN AND ZZW_STATUS <> 'X' AND ZZW.%NotDel% ) <= 0
		AND SC9.%NotDel%
		AND SC6.%NotDel%
		AND SB1.%NotDel%

		ORDER BY ZZ6_FORNOP, C6_LOCAL, C9_DATALIB, C9_PEDIDO, C9_ITEM, C9_SEQUEN

	EndSql


	//Fernando em 10/12/2015 - bloquear de duas pessoas montarem carga do mesmo pedido ao mesmo tempo
	(cAliasTmp)->(DbGoTop())
	While .Not. (cAliasTmp)->(Eof())

		If !SC9->(DBRLock((cAliasTmp)->RECSC9))
			SC9->(DbUnlockAll())
			cLogRet += "PEDIDO "+ (cAliasTmp)->C9_PEDIDO + " ==> ESTÁ BLOQUEADO POR OUTRO USUÁRIO."+CRLF
		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbGoTop())


	//CHECKAGEM DE PEDIDOS DE AMOSTRAS
	//Verifica se existe pedidos de amostras em aberto para este cliente.
	If !Empty(cetPedido)

		//Posiciona no pedido de venda para buscar o cliente origem se houver.
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+cetPedido))
		IF !EMPTY(SC5->C5_YCLIORI)
			cCliente := SC5->C5_YCLIORI
			cLoja    := SC5->C5_YLOJORI
		ELSE
			cCliente := SC5->C5_CLIENT
			cLoja    := SC5->C5_LOJACLI
		ENDIF


		//Posiciona no primeiro item do pedido de venda para descobrir a empresa do pedido, analisando o produto para acessar a tabela ZZ7*
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+cetPedido+'01'))

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

		ZZ7->(DbSetOrder(1))
		ZZ7->(DbSeek(xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ))

		A00 := "  SELECT C5_NUM, C6_ITEM, C5_YSUBTP, C6_QTDVEN, C6_QTDENT, (CASE WHEN LTRIM(C6_YDTNECE) <> '' THEN C6_YDTNECE ELSE C6_ENTREG END) AS C6_ENTREG "	+ Enter1

		A00 += "  ,PESOBR = CASE WHEN B1_TIPCONV = 'M' "	+ Enter1
		A00 += "  		   THEN ((C6_QTDVEN - C6_QTDENT) *  "	+ Enter1
		A00 += "  				ISNULL((SELECT ZZ9_PESO FROM "+RetSqlName("ZZ9")+" AS ZZ9 (nolock) WHERE ZZ9_PRODUT = C6_PRODUTO AND ZZ9_LOTE = C6_LOTECTL AND ZZ9.D_E_L_E_T_ = ''),B1_PESO)) "	+ Enter1
		A00 += "  				+ (((C6_QTDVEN - C6_QTDENT) * B1_CONV) *  "	+ Enter1
		A00 += "  				ISNULL((SELECT ZZ9_PESEMB FROM  "+RetSqlName("ZZ9")+" AS ZZ9 (nolock) WHERE ZZ9_PRODUT = C6_PRODUTO AND ZZ9_LOTE = C6_LOTECTL AND ZZ9.D_E_L_E_T_ = ''),B1_YPESEMB)) "	+ Enter1
		A00 += "  		   ELSE ((C6_QTDVEN - C6_QTDENT) * ISNULL((SELECT ZZ9_PESO FROM "+RetSqlName("ZZ9")+" AS ZZ9 (nolock) WHERE ZZ9_PRODUT = C6_PRODUTO AND ZZ9_LOTE = C6_LOTECTL AND ZZ9.D_E_L_E_T_ = ''),B1_PESO)) "	+ Enter1
		A00 += "  		   	    + (((C6_QTDVEN - C6_QTDENT) / B1_CONV) * ISNULL((SELECT ZZ9_PESEMB FROM "+RetSqlName("ZZ9")+" AS ZZ9 (nolock) WHERE ZZ9_PRODUT = C6_PRODUTO AND ZZ9_LOTE = C6_LOTECTL AND ZZ9.D_E_L_E_T_ = ''),B1_YPESEMB)) "	+ Enter1
		A00 += "  		   END "	+ Enter1

		A00 += "  FROM 			"	+ Enter1

		A00 += "		(SELECT CLIENTE = CASE										"	+ Enter1
		A00 += "	 						WHEN C5_YCLIORI = '' THEN C5_CLIENT		"	+ Enter1
		A00 += "	 						ELSE C5_YCLIORI							"	+ Enter1
		A00 += "	 					END, 										"	+ Enter1
		A00 += "				LOJA = CASE											"	+ Enter1
		A00 += "							WHEN C5_YLOJORI = '' THEN C5_LOJACLI	"	+ Enter1
		A00 += "	      					ELSE C5_YLOJORI							"	+ Enter1
		A00 += "	      				END, *										"	+ Enter1

		IF SUBSTR(ZZ7->ZZ7_EMP,1,2) = '01'
			A00 += "	      FROM SC5010 (nolock)) AS SC5 , 							"	+ Enter1
		ELSE
			A00 += "	      FROM SC5050 (nolock)) AS SC5 , 							"	+ Enter1
		ENDIF

		IF SUBSTR(ZZ7->ZZ7_EMP,1,2) = '01'
			A00 += "  SC6010 AS SC6 (nolock), SB1010 AS SB1 (nolock) "	+ Enter1
		ELSE
			A00 += "  SC6050 AS SC6 (nolock), SB1010 AS SB1 (nolock) "	+ Enter1
		ENDIF

		A00 += "  WHERE C5_FILIAL  = '" + xFilial("SC5") + "' AND " 	+ Enter1
		A00 += "        C6_FILIAL  = '" + xFilial("SC6") + "' AND " 	+ Enter1
		A00 += "        B1_FILIAL  = '" + xFilial("SB1") + "' AND " 	+ Enter1
		A00 += "        C5_NUM     = C6_NUM AND " 	+ Enter1
		A00 += "        C6_PRODUTO = B1_COD AND " 	+ Enter1
		A00 += "        CLIENTE    = '"+cCliente+"' AND " 	+ Enter1
		A00 += "        LOJA       = '"+cLoja+"'    AND " 	+ Enter1
		A00 += "        C5_NUM    <> '"+cetPedido+"'  AND " 	+ Enter1
		A00 += "        (C5_YSUBTP  IN ('A','F') OR (C5_YSUBTP IN ('O', 'M') AND SUBSTRING(B1_GRUPO,1,3) = '216')) AND " 	+ Enter1
		A00 += "        C6_QTDENT <> C6_QTDVEN        AND " 	+ Enter1
		A00 += "        C6_BLQ NOT IN ('S','R')       AND " 	+ Enter1
		A00 += "        C5_TIPO = 'N'                 AND " 	+ Enter1
		A00 += "        SC5.D_E_L_E_T_ = ' '          AND "  + Enter1
		A00 += "        SC6.D_E_L_E_T_ = ' '          AND "  + Enter1
		A00 += "        SB1.D_E_L_E_T_ = ' '              "	+ Enter1


		cAliasTrab := GetNextAlias()
		TCQUERY A00 ALIAS (cAliasTrab) NEW

		While !(cAliasTrab)->(EOF())

			aLinha := {}

			AAdd(aLinha,(cAliasTrab)->C5_NUM)
			AAdd(aLinha,(cAliasTrab)->C6_ITEM)
			AAdd(aLinha,(cAliasTrab)->C5_YSUBTP)
			AAdd(aLinha,(cAliasTrab)->C6_QTDVEN - (cAliasTrab)->C6_QTDENT)
			AAdd(aLinha,(cAliasTrab)->PESOBR)

			Aadd(aDados, aLinha)

			(cAliasTrab)->(DbSkip())
		EndDo

		(cAliasTrab)->(DbCloseArea())

		If lTemAmostra
			Markbrow1("", aDados)
		EndIf

		//(21/08/2014 - Thiago Dantas) -> Verifica se tem pedido na Mundi.
		If !Empty(SC5->C5_YCLIORI)
			LstPed(SC5->C5_YCLIORI,TPPEDMUNDI)
			LstPed(SC5->C5_YCLIORI,TPPEDFORM)
		Else
			LstPed(SC5->C5_CLIENTE,TPPEDMUNDI)
			LstPed(SC5->C5_YCLIORI,TPPEDFORM)
		EndIf

	EndIf

	//PREENCHER ARRAY DA LISTBOX
	aListPed := {}
	(cAliasTmp)->(DbGoTop())
	While .Not. (cAliasTmp)->(Eof())

		//POSICIONA TABELAS
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+(cAliasTmp)->C9_PEDIDO))

		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+(cAliasTmp)->C9_PEDIDO+(cAliasTmp)->C9_ITEM))

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))

		//VERIFICA SE A QUANTIDADE LIBERADA ESTA MAIOR QUE A QUANTIDADE DO PEDIDO
		cSC6 := GetNextAlias()
		BeginSql Alias cSC6
			SELECT SUM(C6_QTDEMP+C6_QTDENT) QUANT_SC6 FROM %Table:SC6% (nolock) WHERE C6_NUM = %Exp:(cAliasTmp)->C9_PEDIDO% AND C6_FILIAL = %xFilial:SC6% AND  C6_PRODUTO = %Exp:(cAliasTmp)->C9_PRODUTO% AND C6_ITEM = %Exp:(cAliasTmp)->C9_ITEM% AND %NotDel%
		EndSql
		cSC9 := GetNextAlias()
		BeginSql Alias cSC9
			SELECT SUM(C9_QTDLIB) QUANT_SC9 FROM %Table:SC9% (nolock) WHERE C9_PEDIDO = %Exp:(cAliasTmp)->C9_PEDIDO% AND C9_FILIAL = %xFilial:SC9% AND C9_PRODUTO = %Exp:(cAliasTmp)->C9_PRODUTO% AND C9_ITEM = %Exp:(cAliasTmp)->C9_ITEM% AND C9_NFISCAL = ' ' AND %NotDel%
		EndSql
		cSD2 := GetNextAlias()
		BeginSql Alias cSD2
			SELECT SUM(D2_QUANT) QUANT_SD2 FROM %Table:SD2% (nolock) WHERE D2_PEDIDO = %Exp:(cAliasTmp)->C9_PEDIDO% AND D2_FILIAL = %xFilial:SD2% AND D2_COD = %Exp:(cAliasTmp)->C9_PRODUTO% AND D2_ITEMPV = %Exp:(cAliasTmp)->C9_ITEM% AND %NotDel%
		EndSql

		//RUBENS JUNIOR - BUSCAR DADOS PARA COLUNA DE TEMPO MEDIO E PRAZO DE ENTREGA
		cSC6_2 := GetNextAlias()
		BeginSql Alias cSC6_2

			SELECT (CASE WHEN C6_YDTNECE <> '' THEN C6_YDTNECE ELSE C6_ENTREG END) AS C6_ENTREG, C6_PRCVEN, C6_DESCONT, A1_YTPSEG 
			FROM %Table:SC6% SC6 (nolock) 
			INNER JOIN %Table:SA1% SA1 (nolock) 
			ON A1_COD = C6_CLI 
			AND A1_LOJA = C6_LOJA 
			AND SA1.%NotDel% 
			WHERE C6_NUM = %Exp:(cAliasTmp)->C9_PEDIDO% 
			AND C6_FILIAL = %xFilial:SC6%
			AND C6_PRODUTO = %Exp:(cAliasTmp)->C9_PRODUTO% 
			AND C6_ITEM = %Exp:(cAliasTmp)->C9_ITEM% 
			AND SC6.%NotDel%

		EndSql

		cSC9_2 := GetNextAlias()
		BeginSql Alias cSC9_2
			SELECT C9_DATALIB, C9_PRCVEN FROM %Table:SC9% (nolock) WHERE C9_PEDIDO = %Exp:(cAliasTmp)->C9_PEDIDO% AND C9_FILIAL = %xFilial:SC9% AND C9_PRODUTO = %Exp:(cAliasTmp)->C9_PRODUTO% AND C9_ITEM = %Exp:(cAliasTmp)->C9_ITEM% AND C9_NFISCAL = ' ' AND %NotDel%
		EndSql

		//Verifica se o C6_PREVEN está diferente do C9_PRCVEN, sem informar o DESCONTO INCONDICIONAL
		If (cSC6_2)->C6_PRCVEN <> (cSC9_2)->C9_PRCVEN .And. (cSC6_2)->C6_DESCONT == 0

			cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ->ITEM/SEQ "+ALLTRIM((cAliasTmp)->C9_ITEM)+"/"+ALLTRIM((cAliasTmp)->C9_SEQUEN)+" ==> O PREÇO DE VENDA DA LIBERAÇÃO (R$ "+Alltrim(Str((cSC9_2)->C9_PRCVEN))+"), ESTÁ DIFERENTE DO PREÇO DE VENDA (R$ "+Alltrim(Str((cSC6_2)->C6_PRCVEN))+")."+CRLF

			(cAliasTmp)->(DbSkip())
			(cSC6)->(dbCloseArea())
			(cSC9)->(dbCloseArea())
			(cSD2)->(dbCloseArea())
			(cSC6_2)->(dbCloseArea())
			(cSC9_2)->(dbCloseArea())
			loop
		EndIf

		// FIM - RUBENS JUNIOR
		If (cSC6)->QUANT_SC6 <> (cSC9)->QUANT_SC9+(cSD2)->QUANT_SD2

			cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ->ITEM/SEQ "+ALLTRIM((cAliasTmp)->C9_ITEM)+"/"+ALLTRIM((cAliasTmp)->C9_SEQUEN)+" ==> A QUANTIDADE LIBERADA ESTA MAIOR QUE A QUANTIDADE DO PEDIDO."+CRLF

			(cAliasTmp)->(DbSkip())
			(cSC6)->(dbCloseArea())
			(cSC9)->(dbCloseArea())
			(cSD2)->(dbCloseArea())
			(cSC6_2)->(dbCloseArea())
			(cSC9_2)->(dbCloseArea())
			loop
		EndIf

		//Verifica se a quantidade de caixas esta correta.
		/*Ticket 27211 - (Pablo S Nascimento 08/10/2020) 
			Exceção para pedidos do formato RP (20x20), conforme consequência do ticket 26760, 
			onde a mesma exceção foi feita para entrada dos pedidos nesse formato com caixa aberta.
			Para isso a function FNC_ROP_PESQUISA_LOTE_01 foi alterada na linhas 90, 91 e 169. 
		*/
		If Alltrim((cAliasTmp)->C9_GRUPO) == "PA" .AND. Alltrim((cAliasTmp)->B1_YFORMAT) != "RP" .AND. !(cAliasTmp)->C9_LOCAL == "05" .AND. (cAliasTmp)->DIF <> 0 .And. AllTrim(CEMPANT) <> "14"

			cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ->ITEM/SEQ "+ALLTRIM((cAliasTmp)->C9_ITEM)+"/"+ALLTRIM((cAliasTmp)->C9_SEQUEN)+" ==> A QUANTIDADE DE CAIXAS PARA O ITEM "+(cAliasTmp)->C9_ITEM+" DESTE PEDIDO ESTA INCORRETA. FAVOR COMUNICAR A TI."+CRLF

			(cAliasTmp)->(DbSkip())
			(cSC6)->(dbCloseArea())
			(cSC9)->(dbCloseArea())
			(cSD2)->(dbCloseArea())
			(cSC6_2)->(dbCloseArea())
			(cSC9_2)->(dbCloseArea())
			loop
		EndIf

		//Posiciona no Cabecalho do Pedido
		cSC5_2 := GetNextAlias()
		BeginSql Alias cSC5_2
			SELECT C5_NUM, C5_CONDPAG FROM %Table:SC5% (nolock) WHERE C5_NUM = %Exp:(cAliasTmp)->C9_PEDIDO% 
			AND C5_FILIAL = %xFilial:SC5%
			AND %NotDel%
		EndSql

		//OS 1836-14
		//Verifica se ?condição de antecipado - RA
		If ( U_fValidaRA((cSC5_2)->C5_CONDPAG) .OR. Alltrim((cSC5_2)->C5_CONDPAG) $ "145_975" ) .And. !GetMv("MV_YVLDRA")

			//Verifica se o Pedido est?sem Saldo de RA
			If Alltrim((cAliasTmp)->C9_YRASTAT) <> "1"

				cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ->ITEM/SEQ "+ALLTRIM((cAliasTmp)->C9_ITEM)+"/"+ALLTRIM((cAliasTmp)->C9_SEQUEN)+" ==> SALDO DE RA INSUFICIENTE."+CRLF

				(cAliasTmp)->(DbSkip())
				(cSC6)->(dbCloseArea())
				(cSC9)->(dbCloseArea())
				(cSD2)->(dbCloseArea())
				(cSC6_2)->(dbCloseArea())
				(cSC9_2)->(dbCloseArea())
				loop
			EndIf
			(cSC5_2)->(dbCloseArea())
			//EndIf

		Else

			//Grava variaveis para ser utilizadas na Funcao MAAVCRED
			SC9Pedido		:= (cAliasTmp)->C9_PEDIDO
			SC9Qtdlib 		:= (cAliasTmp)->C9_QTDLIB
			SC9Item   		:= (cAliasTmp)->C9_ITEM
			SC9Nfiscal		:= (cAliasTmp)->C9_NFISCAL
			SC9BlCred		:= (cAliasTmp)->C9_BLCRED

			rRet := ExecBlock("MAAVCRED",.F.,.F.)
			If !Empty(Alltrim(rRet)) .Or. ( Substr(nTpBlq,1,2) == "06" .And. Empty(Alltrim((cAliasTmp)->C9_YDTLICT)) )

				//00 LIBERADO
				//01 CREDITO LC
				//02 CREDITO RA
				//03 RISCO
				//04 VENCIMENTO
				//05 TITULOS EM ABERTO
				//06 CONTRATO
				//07 ENGENHARIA

				If nTpBlq == "01"
					cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTÁ BLOQUEADO PARA CARGA, POIS ULTRAPASSA O LIMITE DE CRÉDITO!"+CRLF
				ElseIf nTpBlq == "02"
					cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ->ITEM/SEQ "+ALLTRIM((cAliasTmp)->C9_ITEM)+"/"+ALLTRIM((cAliasTmp)->C9_SEQUEN)+" ->QUANT. "+Alltrim(Str((cAliasTmp)->C9_QTDLIB))+" ==> "+"SALDO DE RA É INSUFICIENTE!"+CRLF
				ElseIf nTpBlq == "03"
					cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTÁ BLOQUEADO PARA CARGA, POIS O CLIENTE ESTÁ COM RISCO 'E'!"+CRLF
				ElseIf nTpBlq == "04"
					cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTÁ BLOQUEADO PARA CARGA, POIS O CLIENTE ESTÁ COM LIMITE DE CRÉDITO VENCIDO!"+CRLF
				ElseIf nTpBlq == "05"
					cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTÁ BLOQUEADO PARA CARGA, POIS O CLIENTE ESTÁ COM TITULOS EM ATRASO!"+CRLF
				ElseIf nTpBlq == "061"
					cLogRet += "PEDIDO DE CONTRATO "+(cAliasTmp)->C9_PEDIDO +" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTA BLOQUEADO PARA CARGA, POIS TEVE ALTERAÇÃO NA DATA DE ENTREGA APROVADA!"+CRLF
				ElseIf nTpBlq == "062"
					cLogRet += "PEDIDO DE CONTRATO "+(cAliasTmp)->C9_PEDIDO +" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTA BLOQUEADO PARA CARGA, POIS TEVE ALTERAÇÃO NOS VALORES APROVADOS!"+CRLF
				ElseIf nTpBlq == "063"
					cLogRet += "PEDIDO DE CONTRATO "+(cAliasTmp)->C9_PEDIDO +" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTA BLOQUEADO PARA CARGA, POIS ESTA ESTA SENDO LIBERADO ANTES DA DATA DE ENTREGA!"+CRLF
				ElseIf nTpBlq == "064"
					cLogRet += "PEDIDO DE CONTRATO "+(cAliasTmp)->C9_PEDIDO +" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTA BLOQUEADO PARA CARGA, POIS ESTA COM TÍTULOS DE CONTRATO EM ATRASO!"+CRLF
				ElseIf nTpBlq == "07"
					cLogRet += "PEDIDO DE ENGENHARIA "+(cAliasTmp)->C9_PEDIDO +" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"ESTE PEDIDO ESTA BLOQUEADO PARA CARGA, POIS ESTÁ AGUARDANDO LIBERAÇÃO DO SETOR DE CRÉDITO E COBRANÇA!"+CRLF
				EndIf

				//Atualiza Status do Contrato
				If Substr(nTpBlq,1,2) == "06" .And. nTpBlq <> "065"
					fBlqCont((cAliasTmp)->C9_PEDIDO,(cAliasTmp)->C9_ITEM,(cAliasTmp)->C9_SEQUEN,(cAliasTmp)->C9_PRODUTO)
				EndIf

				(cAliasTmp)->(DbSkip())
				(cSC6)->(dbCloseArea())
				(cSC9)->(dbCloseArea())
				(cSD2)->(dbCloseArea())
				(cSC6_2)->(dbCloseArea())
				(cSC9_2)->(dbCloseArea())
				loop

			EndIF

		EndIf

		//VERIFICA BLOQUEIO DE ESTOQUE
		If (cAliasTmp)->C9_BLEST <> '  ' .And. (cAliasTmp)->C9_BLEST <> '10'

			cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"BLOQUEADO POR ESTOQUE."

			(cAliasTmp)->(DbSkip())
			(cSC6)->(dbCloseArea())
			(cSC9)->(dbCloseArea())
			(cSD2)->(dbCloseArea())
			(cSC6_2)->(dbCloseArea())
			(cSC9_2)->(dbCloseArea())
			loop
		EndIf

		//VERIFICA BLOQUEIO DE CREDITO
		If (cAliasTmp)->C9_BLCRED <> '  ' .And. (cAliasTmp)->C9_BLCRED <> '10'

			cLogRet += "PEDIDO "+(cAliasTmp)->C9_PEDIDO+" ->PRODUTO "+ALLTRIM((cAliasTmp)->C9_PRODUTO)+" ==> "+"BLOQUEADO POR CRÉDITO."

			(cAliasTmp)->(DbSkip())
			(cSC6)->(dbCloseArea())
			(cSC9)->(dbCloseArea())
			(cSD2)->(dbCloseArea())
			(cSC6_2)->(dbCloseArea())
			(cSC9_2)->(dbCloseArea())
			loop
		EndIf

		//VERIFICA SE ITEM JA FOI ADICIONADO PARA PEGAR OS MESMOS DADOS
		_QtdLib := (cAliasTmp)->C9_QTDLIB
		_PesoBR := (cAliasTmp)->PESOBR
		If (_nLin := aScan(_aCols, {|x| x[2] == (cAliasTmp)->C9_PEDIDO .AND. x[3] == (cAliasTmp)->C9_ITEM .AND. x[4] == (cAliasTmp)->C9_SEQUEN })) > 0
			_QtdLib := _aCols[_nLin][6]
			_PesoBR := _aCols[_nLin][7]
		EndIf


		If (AllTrim(cetNCli) <> AllTrim((cAliasTmp)->A1_NOME))
			If !lDigCli

				cetCCli := (cAliasTmp)->A1_COD
				cetNCli := (cAliasTmp)->A1_NOME
				getCCli:Disable()

			Else

				cetNCli := (cAliasTmp)->A1_NOME

			EndIf
		EndIf

		//COLUNAS DO GRIS ALISTPED
		//HEADER "","FORNO","ARMAZEM","DT EMPENHO","PEDIDO","ITEM","SEQ.","PRODUTO","LOTE","DESCRICAO","QTDE LIBER.","QTDE CARGA","PESO","DT ENTREGA","TEMPO M.";

		aAux := Array(nc_NUMCOLS)

		aAux[nc_MARK	] := IIF(_nLin>0,.T.,.F.)
		aAux[nc_FORNO	] := (cAliasTmp)->ZZ6_FORNOP
		aAux[nc_ARMAZEM	] := (cAliasTmp)->C9_LOCAL
		aAux[nc_EMPENHO	] := DTOC(STOD((cAliasTmp)->C9_DATALIB))
		aAux[nc_PEDIDO	] := (cAliasTmp)->C9_PEDIDO
		aAux[nc_ITEM	] := (cAliasTmp)->C9_ITEM
		aAux[nc_SEQ		] := (cAliasTmp)->C9_SEQUEN
		aAux[nc_PRODUTO	] := (cAliasTmp)->C9_PRODUTO
		aAux[nc_LOTE	] := (cAliasTmp)->C9_LOTECTL
		aAux[nc_DESCR	] := ALLTRIM((cAliasTmp)->B1_DESC)
		aAux[nc_QLIBER	] := (cAliasTmp)->C9_QTDLIB
		aAux[nc_QCARGA	] := _QtdLib
		aAux[nc_PESO	] := _PesoBR
		aAux[nc_ENTREGA	] := DTOC(STOD((cSC6_2)->C6_ENTREG))
		aAux[nc_TEMPOM	] := dDatabase-STOD((cSC9_2)->C9_DATALIB)

		AAdd(aListPed,aAux)


		(cAliasTmp)->(DbSkip())

		(cSC6)->(dbCloseArea())
		(cSC9)->(dbCloseArea())
		(cSD2)->(dbCloseArea())
		(cSC6_2)->(dbCloseArea())
		(cSC9_2)->(dbCloseArea())

	EndDo


	IF !Empty(cLogRet)

		U_FROPMSG("CONTROLE DE CARGAS: Log de Pedidos bloqueados para montagem de carga",cLogRet)

	ENDIF

	//VERIFICA SE ACHOU PEDIDO LIBERADO
	IF Len(aListPed) <= 0

		U_FROPMSG("CONTROLE DE CARGAS","NÃO FORAM ENCONTRADOS PEDIDOS, OU NÃO HÁ ITENS LIBERADOS "+CRLF+"OU JÁ FORAM ADICIONADOS A OUTRA CARGA")
		cetCCli := Space(6)
		cetNCli := ""
		cetPedido := Space(6)
		getCCli:Disable()
		getPedido:SetFocus()
		oDlgPed:Refresh()

	ENDIF


	(cAliasTmp)->(DbCloseArea())

	listItems:aArray := AClone(aListPed)
	listItems:Refresh()
	CalcGetTot()
	oDlgPed:Refresh()

Return(lRet)


Static Function CalcGetTot()

	Local I
	Local _nQtd := 0, _nPeso := 0

	FOR I := 1 To Len(aListPed)
		If aListPed[I][nc_MARK]
			_nQtd += aListPed[I][nc_QCARGA]
			_nPeso += aListPed[I][nc_PESO]
		EndIf
	NEXT I

	lblGetQtde:cCaption := Transform(_nQtd,"@E 999,999,999.99")
	lblGetPeso:cCaption := Transform(_nPeso,"@E 999,999,999.99")
	oDlgPed:Refresh()

Return


Static Function MarcTudo()

	Local I
	_lMarcado := !_lMarcado

	For I := 1 to len(aListPed)
		If !_lMarcado
			aListPed[I][nc_MARK] := _lMarcado
		Else
			aListPed[I][nc_MARK] := ValidaPrazo(I)
		EndIf
	Next I

	listItems:Refresh()

Return


Static Function GetPedProc()

	Local I
	Local aAux
	Local _aCols := AClone(oGDItems:ACols)
	Local _nLin

	//Limpar Acols se primeira selecao
	if Len(_aCols) > 0 .AND. Empty(_aCols[1][1])
		_aCols := {}
	endif

	FOR I := 1 To Len(aListPed)

		IF aListPed[I][nc_MARK]

			//ATUALIZAR ACOLS QUANDO ADICIONANDO MESMO ITEM
			IF (_nLin := aScan(_aCols, {|x| x[2] == aListPed[I][nc_PEDIDO] .AND. x[3] == aListPed[I][nc_ITEM] .AND. x[4] == aListPed[I][nc_SEQ] })) > 0

				_aCols[_nLin][6] := aListPed[I][nc_QCARGA]
				_aCols[_nLin][7] := aListPed[I][nc_PESO]

				loop
			ENDIF

			aAux := {}
			Aadd(aAux, cetNCli )
			Aadd(aAux, aListPed[I][nc_PEDIDO] )
			Aadd(aAux, aListPed[I][nc_ITEM] )
			Aadd(aAux, aListPed[I][nc_SEQ] )
			Aadd(aAux, aListPed[I][nc_DESCR] )
			Aadd(aAux, aListPed[I][nc_QCARGA] )
			Aadd(aAux, aListPed[I][nc_PESO] )
			Aadd(aAux, Space(10) )
			Aadd(aAux, "1" )

			Aadd(aAux, .F.)
			Aadd(_aCols, aAux)

		ENDIF

	NEXT I

	oGDItems:ACols := AClone(_aCols)
	oGDItems:oBrowse:Refresh()
	SetTotal()

Return(.T.)


User Function BEC01UST(_lAuto, _cNCarga)

	Default _cNCarga = ""

	IF (_cEmpFil == Nil) .Or. (Empty(_cEmpFil))
		_cEmpFil := Alltrim(CEMPANT)+Alltrim(CFILANT)
	ENDIF

	U_BIAMsgRun("Processando atualização de status ECOSIS...",,{|| UEcoProc(_lAuto,_cNCarga) })

Return


Static Function UEcoProc(_lAuto,_cNCarga)

	Local _aRet := {}

	IF TCSPEXIST(U_GSPName("EOS_UPDATE_STATUS_OC"))

		_aRet := TCSPEXEC(U_GSPName("EOS_UPDATE_STATUS_OC"),_cEmpFil,_cNCarga)

		ZZW->(DbSetOrder(2))
		ZZW->(DbSeek(XFILIAL("ZZW")+_cNCarga))

		fUpdIntPes(ZZW->ZZW_CARGA, ZZW->ZZW_STATUS)

		If !_lAuto .And. Type("_aRet") == "A" .And. Len(_aRet) > 0
			MsgInfo("FORAM ATUALIZADOS OS STATUS DE "+ AllTrim(Str(_aRet[1])) +" OC's","ATUALIZACAO DE CARGA")
		EndIf

	ENDIF

Return


User Function BEC01FIM()

	Local _aRet := {}
	Local _cNCarga := ZZV->ZZV_CARGA

	//VALIDAR ENTRADA NA TELA
	IF !Empty(ZZV->ZZV_DATFIM)
		MsgAlert("CARGA FINALIZADA OU CANCELADA"+CRLF+"NÃO É POSSÍVEL PROSSEGUIR!","CONTROLE DE CARGAS")
		Return
	ENDIF

	IF !MSGNOYES("TEM CERTEZA QUE DESEJA FINALIZAR ESTA CARGA?"+CRLF+"Não ser?mais possível a manutenção nestes items","FINALIZAR CARGA")
		Return
	ENDIF

	IF TCSPEXIST(U_GSPName("EOS_FINALIZAR_OC"))

		_aRet := TCSPEXEC(U_GSPName("EOS_FINALIZAR_OC"),_cEmpFil,_cNCarga)

		If Type("_aRet") == "A" .And. Len(_aRet) > 0
			IF _aRet[1] == 1
				MsgInfo("OC FINALIZADA COM SUCESSO","ATUALIZACAO DE CARGA")
			ELSE
				MsgStop("NÃO FOI POSSÍVEL FINALIZADA A OC"+CRLF+"VERIFICAR STATUS DO CARREGAMENTO NO ECOSIS","FINALIZAR CARGA")
			ENDIF
		EndIf

	ENDIF

Return


User Function BEC01TCA()

	ZZW->(DbSetOrder(2))
	IF ZZW->(DbSeek(XFILIAL("ZZW")+ZZV->ZZV_CARGA)) .AND. ZZW->ZZW_STATUS = 'X'
		Return(.T.)
	ENDIF

Return(.F.)


User Function BEC01TAM()

	ZZW->(DbSetOrder(2))
	IF ZZW->(DbSeek(XFILIAL("ZZW")+ZZV->ZZV_CARGA))
		SC9->(DbSetOrder(1))
		IF SC9->(DbSeek(XFilial("SC9")+ZZW->(ZZW_PEDIDO+ZZW_ITEM+ZZW_SEQUEN))) .And. SC9->C9_LOCAL = '05'
			Return(.T.)
		ENDIF
	ENDIF

Return(.F.)


Static Function ChkSalPed(_cPedido, _cItem, _nQtdLib)

	Local _nSaldo := 0
	Local _cSQL := ""

	_cSQL +="	SELECT ROUND( "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(C6_QTDVEN) FROM "+RetSQLName("SC6")+" "+CRLF
	_cSQL +="					WHERE C6_NUM = '"+_cPedido+"' AND C6_FILIAL = '"+xFilial('SC5')+"' AND C6_ITEM = '"+_cItem+"' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					- "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(D2_QUANT) FROM "+RetSQLName("SD2")+" "+CRLF
	_cSQL +="					WHERE D2_PEDIDO = '"+_cPedido+"' AND D2_FILIAL = '"+xFilial('SD2')+"' AND D2_ITEMPV = '"+_cItem+"' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					- "+CRLF
	_cSQL +="					ISNULL((SELECT SUM(C9_QTDLIB) FROM "+RetSQLName("SC9")+" "+CRLF
	_cSQL +="					WHERE C9_PEDIDO = '"+_cPedido+"' AND C9_FILIAL = '"+xFilial('SC9')+"' AND C9_ITEM = '"+_cItem+"' AND C9_BLEST = ' ' AND C9_BLCRED = ' ' AND C9_NFISCAL = ' ' AND D_E_L_E_T_= ' '),0) "+CRLF
	_cSQL +="					,2) as SALDO "+CRLF
	TCQuery _cSQL Alias "QRYVAL" New

	QRYVAL->(DbGoTop())
	If (!QRYVAL->(Eof()))
		_nSaldo := QRYVAL->SALDO
	EndIf
	QRYVAL->(DbCloseArea())

	IF _nSaldo < _nQtdLib
		MsgAlert("OCORREU UM PROBLEMA COM A LIBERAÇÃO DO PEDIDO: "+_cPedido+" ITEM: "+_cItem+CRLF+"VERIFICAR OS SALDOS A FATURAR.","MONTAGEM DE CARGA")
		Return(.F.)
	ENDIF

Return(.T.)


User Function GSPName(_CNAME)

	Local _CEMP := CEMPANT+CFILANT
	Local _CRET := _CNAME+"_"+_CEMP

Return(_CRET)



User Function BCPDV01()

	Private CargaPDVoDlg
	Private oButton1
	Private oGet1
	Private cGet1 := Space(6)
	Private oSay1

	Private nX
	Private aHeaderEx    := {}
	Private aColsEx      := {}
	Private aFieldFill   := {}
	Private aFields      := {"ZZW_CARGA","ZZW_PEDIDO","ZZW_ITEM","ZZW_SEQUEN","ZZW_NUMOCE","ZZW_STATUS"}
	Private aAlterFields := {"ZZW_CARGA","ZZW_PEDIDO","ZZW_ITEM","ZZW_SEQUEN","ZZW_NUMOCE","ZZW_STATUS"}
	Private oNGetPDV

	DEFINE MSDIALOG CargaPDVoDlg TITLE "Amarração de Pedido ?Carga" FROM 000, 000  TO 360, 500 COLORS 0, 16777215 PIXEL

	fNGetPDV()
	@ 161, 206 BUTTON oButton1 PROMPT "Fecha" SIZE 037, 012 OF CargaPDVoDlg Action Close(CargaPDVoDlg) PIXEL
	@ 161, 069 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF CargaPDVoDlg  VALID fGrvPDVc() COLORS 0, 16777215 PIXEL
	@ 161, 005 SAY oSay1 PROMPT "Informe o Pedido:" SIZE 059, 007 OF CargaPDVoDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG CargaPDVoDlg

Return


Static Function fNGetPDV()

	Local nX

	// Define field properties
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	If Len(aFieldFill) == 0

		For nX := 1 to Len(aFields)
			If dbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oNGetPDV := MsNewGetDados():New( 009, 004, 157, 243, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", CargaPDVoDlg, aHeaderEx, aColsEx)

Return


Static Function fGrvPDVc()

	Local nX		 := 0
	Local cAliasTrab := Nil

	aFieldFill := {}
	aColsEx    := {}
	oNGetPDV:ACOLS := {}

	QP007 := " SELECT ZZW_CARGA,
	QP007 += "        ZZW_PEDIDO,
	QP007 += "        ZZW_ITEM,
	QP007 += "        ZZW_SEQUEN,
	QP007 += "        ZZW_NUMOCE,
	QP007 += "        ZZW_STATUS
	QP007 += "   FROM " + RetSqlName("ZZW")
	QP007 += "  WHERE ZZW_FILIAL = '"+xFilial("ZZW")+"'
	QP007 += "    AND ZZW_PEDIDO = '"+cGet1+"'
	QP007 += "    AND D_E_L_E_T_ = ' '

	cAliasTrab := GetNextAlias()
	TCQUERY QP007 ALIAS (cAliasTrab) NEW

	While !(cAliasTrab)->(EOF())

		Aadd(aFieldFill, {(cAliasTrab)->ZZW_CARGA, (cAliasTrab)->ZZW_PEDIDO, (cAliasTrab)->ZZW_ITEM, (cAliasTrab)->ZZW_SEQUEN, (cAliasTrab)->ZZW_NUMOCE, (cAliasTrab)->ZZW_STATUS, .F. })

		(cAliasTrab)->(DbSkip())
	EndDo
	(cAliasTrab)->(dbCloseArea())


	// Define field values
	If Len(aFieldFill) == 0

		For nX := 1 to Len(aFields)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			If dbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(oNGetPDV:ACOLS, aFieldFill)

	Else

		oNGetPDV:ACOLS := aFieldFill

	EndIf

	oNGetPDV:oBrowse:Refresh()
	oNGetPDV:oBrowse:SetFocus()

Return( .T. )


User Function BEC01DCA
	Local _cAliasTmp
	Local _cSQL
	Local _lOk := .F.
	Local _lOkFat := .T.
	Local _cPedIt := ""
	Local _cOC := ""

	//Libera botao
	If !U_VALOPER("006",.F.)
		MsgAlert("USUÁRIO SEM ACESSO A ESTA OPERAÇÃO","OP 006 - INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	//Testar se a carga esta FINALIZADA
	If EMPTY(ZZV->ZZV_DATFIM)
		MsgAlert("ESTA OPERAÇÃO SÓ PODE SER EXECUTADA PARA CARGAS FINALIZADAS","INTEGRAÇÃO ECOSIS")
		Return
	Else
		_lOk := .T.
	EndIf

	//Testar se todos os itens da Carga não existem no Ecosis
	ZZW->(DbSetOrder(2))
	SC9->(DbSetOrder(1))

	IF ZZW->(DbSeek(XFILIAL("ZZW")+ZZV->ZZV_CARGA))
		While !ZZW->(Eof()) .And. ZZW->(ZZW_FILIAL+ZZW_CARGA) == (XFILIAL("ZZW")+ZZV->ZZV_CARGA)

			_cAliasTmp := GetNextAlias()

			_cSQL := "SELECT dbo.EOS_CHECK_OC_EXIST_"+AllTrim(cEmpAnt)+"('"+ZZW->ZZW_NUMOCE+"','"+ZZW->ZZW_FILIAL+"','"+ZZW->ZZW_PEDIDO+"','"+ZZW->ZZW_ITEM+"','"+ZZW->ZZW_SEQUEN+"') as TEST"
			TCQuery _cSQL Alias (_cAliasTmp) New

			If !(_cAliasTmp)->(Eof()) .And. (_cAliasTmp)->TEST == 1
				_lOk := .F.
				_cOC := ZZW->ZZW_NUMOCE
				exit
			EndIf

			(_cAliasTmp)->(DbCloseArea())


			//Verificar se o item esta faturado	- OS 4061-16 - Fernando/Facile em 29/11/2016
			If _lOk .And. SC9->(DbSeek(XFilial("SC9")+ZZW->ZZW_PEDIDO+ZZW->ZZW_ITEM+ZZW->ZZW_SEQUEN)) .And. !Empty(SC9->C9_NFISCAL)
				_lOkFat := .F.
				_cPedIt := ZZW->ZZW_PEDIDO+ZZW->ZZW_ITEM+ZZW->ZZW_SEQUEN
				exit
			EndIf


			ZZW->(DbSkip())
		EndDo
	ENDIF

	IF !_lOk
		MsgAlert("A OC No "+_cOC+" ESTÁ INTEGRADA COM O ECOSIS."+CRLF+"NÃO É POSSÍVEL DESTRAVAR.","INTEGRAÇÃO ECOSIS")
		Return
	ENDIF

	IF !_lOkFat
		MsgAlert("O PEDIDO:"+_cPedIt+" já está FATURADO."+CRLF+"NÃO É POSSÍVEL DESTRAVAR.","INTEGRAÇÃO ECOSIS")
		Return
	ENDIF

	IF !MSGNOYES("Tem certeza que deseja DESTRAVAR esta carga - excluida do ECOSIS?","INTEGRAÇÃO ECOSIS")
		Return
	ENDIF


	//Retornando a Carga para Nao Integrada
	BEGIN TRANSACTION

		RecLock("ZZV",.F.)
		ZZV->ZZV_DATFIM := CTOD("")
		ZZV->(MsUnlock())

		ZZW->(DbSetOrder(2))
		IF ZZW->(DbSeek(XFILIAL("ZZW")+ZZV->ZZV_CARGA))
			While !ZZW->(Eof()) .And. ZZW->(ZZW_FILIAL+ZZW_CARGA) == (XFILIAL("ZZW")+ZZV->ZZV_CARGA)

				RecLock("ZZW",.F.)
				ZZW->ZZW_STATUS := "1"
				ZZW->ZZW_NUMOCE := ""
				ZZW->(MsUnlock())

				fUpdIntPes(ZZV->ZZV_CARGA, ZZW->ZZW_STATUS)

				ZZW->(DbSkip())
			EndDo
		ENDIF

	END TRANSACTION


Return


/*/{Protheus.doc} ValidaPrazo
@description Montar colunas de TEMPO MEDIO E PRAZO DE ENTREGA AO SELECIONAR O PEDIDO
@author Rubens Junior (FACILE SISTEMAS)
@since 22/07/2014
@version 1.0
@type function
/*/
Static Function ValidaPrazo(nItem)

	//VALIDA SE ESTA FORA DO PRAZO DATA ATUAL + 7 DIAS
	Local xPedido			:= aListPed[nItem][nc_PEDIDO]
	Local xProd				:= aListPed[nItem][nc_PRODUTO]
	Local xLote				:= aListPed[nItem][nc_LOTE]
	Local dValPrazoMedio  	:= CTOD(aListPed[nItem][nc_ENTREGA])
	Local lRet				:= .T.

	//ENTREGA IMEDIATA
	cSC6_SA1 := GetNextAlias()
	BeginSql Alias cSC6_SA1
		SELECT A1_YTPSEG FROM %Table:SC5% SC5 (nolock) INNER JOIN %Table:SA1% SA1 (nolock) ON A1_COD = (CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C5_CLIENTE END) AND A1_LOJA = (CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C5_LOJACLI END) AND SA1.%NotDel% WHERE C5_NUM = %Exp:xPedido% AND C5_FILIAL = %xFilial:SC5% AND  SC5.%NotDel%
	EndSql

	//Item Selecionado ou vem da função MarcTudo OS 3248-15 em 17/08/15
	If aListPed[nItem][nc_MARK] .Or. IsInCallStack("MARCTUDO")
		If ((Alltrim((cSC6_SA1)->A1_YTPSEG) == "E") .And. !((ddatabase >= dValPrazoMedio) .Or. (dValPrazoMedio - ddatabase <= 7))) //SOMENTE PARA CLIENTES DO TIPO ENGENHARIA
			Msgbox("Para o Produto "+xProd+"/"+xLote+" não será permitido a inclusão na Carga, pois ultrapassa os 7 dias da Data de Entrega.","BIAEC001","STOP")

			aListPed[nItem,nc_MARK]	:= !(aListPed[nItem,nc_MARK])
			lRet					:= !(aListPed[nItem,nc_MARK])

		EndIF
	EndIf

	CalcGetTot()
	(cSC6_SA1)->(dbCloseArea())

Return(lRet)

//------------------------------------------------------------------------------------------------------
// 28/09/2014 - Thiago Dantas
// Função utilizada para Listar os Pedidos da Mundi do mesmo cliente, caso existam.
//------------------------------------------------------------------------------------------------------

Static Function LstPed(cpCliente, tpPed)

	Local lEmDes 	:= .F. // Em desenvolvimento
	Local cQuery	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local aDados	:= {}
	Local aLinha	:= {}

	If !lEmDes

		cQuery := GetQryPed(cpCliente, tpPed)

		TCQUERY cQuery ALIAS (cAliasTmp) NEW

		While !(cAliasTmp)->(EOF())

			aLinha := {}

			AAdd(aLinha,(cAliasTmp)->C9_PEDIDO)
			AAdd(aLinha,(cAliasTmp)->C9_ITEM)
			AAdd(aLinha,(cAliasTmp)->TIPO)
			AAdd(aLinha,(cAliasTmp)->C9_QTDLIB)
			AAdd(aLinha,(cAliasTmp)->PESOBR)

			Aadd(aDados, aLinha)

			(cAliasTmp)->(DbSkip())
		EndDo

		(cAliasTmp)->(DbCloseArea())

		If Len(aDados) > 0
			Markbrow1(tpPed, aDados)
		EndIf

	EndIf

Return


Static Function Markbrow1(tpPed, aDados)

	Local cDesc	:= ""

	If tpPed == TPPEDMUNDI
		cDesc := "PEDIDOS NA MUNDIALLI"
	ElseIf tpPed == TPPEDFORM
		cDesc := "PEDIDOS C/ PRODUTO 63X63 - INCESA"
	Else
		cDesc := "PEDIDOS E ORÇAMENTOS DE AMOSTRA"
	EndIf

	@ 96,42 TO 325,450 DIALOG oEntra01 TITLE cDesc

	oTCBrowse := TCBrowse():New(005,005,000,000,,,,oEntra01,,,,,,,,,,,,.F.,,.T.,,.F.)
	oTCBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oTCBrowse:AddColumn(TcColumn():New("Pedido"		, {|| aDados[oTCBrowse:nAt, 01]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oTCBrowse:AddColumn(TcColumn():New("Item"		, {|| aDados[oTCBrowse:nAt, 02]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oTCBrowse:AddColumn(TcColumn():New("Tipo"		, {|| aDados[oTCBrowse:nAt, 03]}, "@!"					,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oTCBrowse:AddColumn(TcColumn():New("Quantidade"	, {|| aDados[oTCBrowse:nAt, 04]}, "@E 999,999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oTCBrowse:AddColumn(TcColumn():New("Peso"		, {|| aDados[oTCBrowse:nAt, 05]}, "@E 999,999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))

	oTCBrowse:SetArray(aDados)
	oTCBrowse:Refresh()

	ACTIVATE DIALOG oEntra01 ON INIT Eval({|| MsAguarde(), oTCBrowse:Refresh(), }) Centered

Return





Static Function GetQryPed(cCliente, tpPed )
	Local cSql := ""

	cSql := " SELECT C9_PEDIDO,C9_ITEM, C9_QTDLIB ,Tipo, PESOBR
	cSql += " FROM VW_PEDIDO_LIBER_EMPR
	cSql += " WHERE CLIORI = '"+cCliente+"'  "

	If tpPed == TPPEDMUNDI
		cSql += " AND EMPRESA = '13'
	Else
		//TPPEDFORM - Formato 63X63
		cSql += " AND B1_YFORMAT = 'BE'
		cSql += " AND EMPRESA 	 = '05'
	EndIf
	cSql += " ORDER BY 1, 2
Return cSql


// Atualiza status de integracao com ECOSIS da pesagem
Static Function fUpdIntPes(cCarga, cStatus)
	Local aArea := GetArea()

	DbSelectArea("ZZV")
	DbSetOrder(1)
	If ZZV->(DbSeek(xFilial("ZZV") + cCarga))

		If !Empty(ZZV->ZZV_TICKET) .And. !U_BEC01TAM() // Tiago Rossini Coradini - OS: 2828-15 (Ângelo) - Não atualiza o status da pesagem caso a mesma seja amostra

			DbSelectArea("Z11")
			DbSetOrder(1)
			If Z11->(DbSeek(xFilial("Z11") + ZZV->ZZV_TICKET))

				Reclock("Z11", .F.)

				If cStatus == "1"
					Z11->Z11_STATUS := "N"
				ElseIf cStatus $ "2/3/4/5/6"
					Z11->Z11_STATUS := "S"
				EndIf

				MsUnLock()

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return()

//Atualiza Tipo Bloqueio de Contrato
Static Function fBlqCont(nPedido,nItem,nSeq,nProd)
	Local cSql := ""

	SC9->(DbSetOrder(1))
	If SC9->(DbSeek(XFilial("SC9")+nPedido+nItem+nSeq+nProd))
		RecLock("SC9",.F.)
		SC9->C9_YDTBLCT	:= dDataBase
		SC9->C9_YTPBLCT := nTpBlq
		SC9->(MsUnlock())
	EndIf

	If SC9->C9_CLIENTE == "010064"
		cSql := "UPDATE SZN070 SET ZN_BLQPDCT = 'S', ZN_MSEXP = '' WHERE ZN_PEDIDO IN (SELECT C5_NUM FROM SC5070 WHERE C5_YPEDORI = '"+SC9->C9_PEDIDO+"' AND D_E_L_E_T_ = '') AND D_E_L_E_T_ = '' "
		If (TCSQLExec(cSql) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
		EndIf
	Else
		//Informa Bloqueio na Tela de Liberação de PV
		SZN->(DbSetOrder(1))
		If SZN->(DbSeek(XFilial("SZN")+nPedido)) .And. SZN->ZN_BLQPDCT <> "S"
			RecLock("SZN",.F.)
			SZN->ZN_BLQPDCT := 'S'
			SZN->(MsUnlock())
		EndIf
	EndIf


Return

//Fernando/Facile em 10/12/2015 - Funcao para destravar somente um item da Carga quando o mesmo nao existir mais no ECOSIS
Static Function DestItem()
	Local _cAliasTmp
	Local _cSQL
	Local _aCols := AClone(oGDItems:ACols)
	Local _nPos := oGDItems:oBrowse:nAT
	Local _lOk := .T.

	//Libera botao
	If !U_VALOPER("006",.F.)
		MsgAlert("USUÁRIO SEM ACESSO A ESTA OPERAÇÃO","OP 006 - INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	//Testar se o item da Carga existe no Ecosis
	ZZW->(DbSetOrder(1))
	IF !Empty(_aCols[_nPos][2]) .And. ZZW->(DbSeek(XFilial("ZZW")+_aCols[_nPos][2]+_aCols[_nPos][3]+_aCols[_nPos][4]))

		_cAliasTmp := GetNextAlias()

		_cSQL := "SELECT dbo.EOS_CHECK_OC_EXIST_"+AllTrim(cEmpAnt)+"('"+ZZW->ZZW_NUMOCE+"','"+ZZW->ZZW_FILIAL+"','"+ZZW->ZZW_PEDIDO+"','"+ZZW->ZZW_ITEM+"','"+ZZW->ZZW_SEQUEN+"') as TEST"
		TCQuery _cSQL Alias (_cAliasTmp) New

		If !(_cAliasTmp)->(Eof()) .And. (_cAliasTmp)->TEST == 1
			_lOk := .F.
		EndIf

		(_cAliasTmp)->(DbCloseArea())
	ENDIF

	If !_lOk
		MsgAlert("O Item Selecionado existe no ECOSIS."+CRLF+"NÃO ?POSSÍVEL DESTRAVAR/EXCLUIR este item.","INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	SC9->(DbSetOrder(1))
	If _lOk .And. SC9->(DbSeek(XFilial("SC9")+_aCols[_nPos][2]+_aCols[_nPos][3]+_aCols[_nPos][4])) .And. !Empty(SC9->C9_NFISCAL)
		MsgAlert("O Item Selecionado já está FATURADO."+CRLF+"NÃO ?POSSÍVEL DESTRAVAR/EXCLUIR este item.","INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	If !MsgNoYes("Tem certeza que deseja DESTRAVAR E EXCLUIR o item POSICIONADO da carga?.","INTEGRAÇÃO ECOSIS")
		Return
	EndIf

	If ZZW->(DbSeek(XFilial("ZZW")+_aCols[_nPos][2]+_aCols[_nPos][3]+_aCols[_nPos][4]))

		RecLock("ZZW",.F.)

		ZZW->ZZW_PEDIDO 	:= ""
		ZZW->ZZW_ITEM		:= ""
		ZZW->ZZW_SEQUEN		:= ""
		ZZW->ZZW_STATUS		:= "1"

		ZZW->(MsUnlock())

		//Fernando/Facile em 29/11/2016 - OS 4061-16 - Limpar o campo Agreg do C9 de itens excluidos/destravados
		If SC9->(DbSeek(XFilial("SC9")+_aCols[_nPos][2]+_aCols[_nPos][3]+_aCols[_nPos][4]))

			RecLock("SC9",.F.)
			SC9->C9_AGREG := ""
			SC9->(MsUnlock())

		EndIf

		_aCols[_nPos][2] := ""
		_aCols[_nPos][3] := ""
		_aCols[_nPos][4] := ""
		_aCols[_nPos][9] := "1"

		oGDItems:ACols := AClone(_aCols)

		oGDItems:oBrowse:Refresh()
		oDlgCarga:Refresh()

	EndIf

Return