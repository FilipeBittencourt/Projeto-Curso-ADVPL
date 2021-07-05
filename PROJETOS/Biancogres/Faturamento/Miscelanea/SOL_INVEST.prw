#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} SOL_INVEST
@description Tela de inclusao e manutencao de AI (Solicitacoes de Investimento)
@author Madalena
@since 12/11/07 
@version 1.0
@return ${return}, ${return_description}
@version XX revisada em 30/10/2018 por Fernando Rocha adequando comentarios e fazendo alteracoes para projeto consolida��o
@type function
/*/
USER FUNCTION SOL_INVEST()

	LOCAL I
	Local nLinha := 0
	PRIVATE ACAMPOS0
	PRIVATE CSQL
	PRIVATE CREPRESENTANTE := SPACE(6)
	PRIVATE CNOMEUSUARIO
	PRIVATE CCODUSUARIO
	PRIVATE ENTER 	:= CHR(13) + CHR(10)
	PRIVATE NRADIO	:= 8
	PRIVATE NOVO_NRADIO 		:= ""
	PRIVATE CDATADE, CDATAATE
	PRIVATE S_TOT_FILTRO 		:= ""
	PRIVATE oGetPesq, cGetPesq 	:= SPACE(20)
	Private aSize      			:= MsAdvSize(,.F. )
	Private auxCont
	Private cGetCli 	:= Space(6)
	Private cGetGrpCli 	:= Space(6)
	Private cAuxItem 	:= ''
	Private CMARCA   	:= 'TODAS'
	Private lDiretor	:= .F.
	Private cTipoAprov	:= ""

	Private oTableMain	:= Nil
	Private cAliasTrab	:= GetNextAlias()

	If !cEmpAnt $ "01_05"
		MsgBox("Esta rotina s� pode ser utilizada nas empresas Biancogres e Incesa.","Solicita��o de Investimento (AI)","STOP")
		Return
	EndIf

	If ;
			(AllTrim(cEmpAnt) == "01" .And. U_VALOPER("SI2", .F.) ) .Or.	;
			(AllTrim(cEmpAnt) == "05" .And. U_VALOPER("SI3", .F.) ) .Or.	;  //Fernando/Facile OS 4525-15 - acesso de diretor
		(AllTrim(cEmpAnt) == "01" .And. TempValOper("SI2")) 	.Or.	;
			(AllTrim(cEmpAnt) == "05" .And. TempValOper("SI3"))				;

		NRADIO := 1
		cTipoAprov := "1"
	ElseIf U_VALOPER("SI1",.F.,.T.) .Or. TempValOper("SI1")
		NRADIO := 2
		cTipoAprov := "2"

	ElseIf (UserGeren())
		NRADIO := 3
		cTipoAprov := "3"
	EndIf

	DEFINE MSDIALOG DLG_SOL FROM aSize[7],000 TO aSize[6],aSize[5] TITLE "" PIXEL

	// DEFININDO AS FONTES QUE SER�O USADAS NA TELA
	DEFINE FONT OBOLD_8  	NAME "ARIAL" SIZE 0, -08 BOLD
	DEFINE FONT OBOLD_9  	NAME "ARIAL" SIZE 0, -09 BOLD
	DEFINE FONT OBOLD_10  	NAME "ARIAL" SIZE 0, -10 BOLD
	DEFINE FONT OBOLD_12 	NAME "ARIAL" SIZE 0, -12 BOLD
	DEFINE FONT OBOLD_16 	NAME "ARIAL" SIZE 0, -16 BOLD
	DEFINE FONT OBOL_TITULO NAME "ARIAL" SIZE 0, -20 BOLD
	// BUSCANDO INFORMACOES DOS USUARIOS
	BUSCA_USUARIOS()

	// CABECALHO
	oGrTitle	:= TGroup():New( 000,000,20,225,"",DLG_SOL,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGrTitle:Align := CONTROL_ALIGN_TOP
	@ 005,020  SAY "SOLICITA��ES DE INVESTIMENTO (AI)"  COLOR CLR_BLUE FONT OBOL_TITULO PIXEL OF oGrTitle

	// GRUPO LATERAL DE BOTOES
	OSCR:= TSCROLLBOX():NEW(DLG_SOL,035,005,260,80,.T.,.T.,.T.) // FRAME LATERAL
	OSCR:Align := CONTROL_ALIGN_LEFT

	nLinha := 01
	// *****************************  OPCOES DE PESQUISA ***************************************
	OSAY1:= TSAY():NEW(nLinha,01,{|| REPLICATE(" ",14) + "PESQUISA" },OSCR,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_BLUE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.
	@ 014, 005 MSGET oGetPesq VAR cGetPesq SIZE 054, 010 PICTURE "@!" OF OSCR PIXEL
	@ 014, 060 BUTTON oButPesq PROMPT ">>>" SIZE 016, 012 OF OSCR PIXEL ACTION(FPesqGrd())

	nLinha += 30

	// *****************************  OPCOES DE FILTRO ***************************************
	OSAY1:= TSAY():NEW(nLinha,01,{|| REPLICATE(" ",18) + "FILTRO" },OSCR,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_BLUE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	nLinha += 10

	CDATADE := ctod("01/01/" + SUBSTRING(ALLTRIM(STR(YEAR(DDATABASE))),3,2) )
	CDATAATE := ctod("31/12/" + SUBSTRING(ALLTRIM(STR(YEAR(DDATABASE))),3,2) )

	@ nLinha,001 Say "DATA DE?" Size 50,07 COLOR CLR_BLUE PIXEL OF OSCR FONT OBOLD_10
	@ nLinha,040 Say "DATA ATE?" Size 30,07 COLOR CLR_BLUE PIXEL OF OSCR FONT OBOLD_10
	nLinha += 10
	@ nLinha,001 GET CDATADE    SIZE 30,10 FONT OBOLD_10 PIXEL OF OSCR WHEN .T.
	@ nLinha,040 GET CDATAATE    SIZE 30,10 FONT OBOLD_10 PIXEL OF OSCR WHEN .T.

	nLinha += 20
	// FILTRO DO STATUS
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",18) + "STATUS" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	//Fernando/Facile em 13/04/2016 -> criado o statua Aguarda aprov dir para casos que exigem duas aprovacores - OS 4525-15
	nLinha += 10
	@ nLinha,01 RADIO NRADIO 3D PROMPT "Aguard. Aprov. Dir.", "Aguard. Aprov. Sup.", "Aguard. Aprov. Ger.", "Aprovado", "Reprovado", "Baixa Total", "Baixa Parcial", "Todos" SIZE  77,9 OF OSCR PIXEL

	nLinha += 75
	//FILTRO DO ITEM CONTABIL
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",10) + "ITEM CONTABIL" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.
	ITEM_CONT  :={}
	CITEM_CONT := "TODOS"

	CSQL := " SELECT * FROM "+RETSQLNAME("CTD")
	CSQL += " WHERE SUBSTRING(CTD_ITEM,1,1) = 'I' AND CTD_BLOQ = '2' AND D_E_L_E_T_ = ''
	CSQL += " AND (CTD_ITEM LIKE 'I01%' OR CTD_ITEM LIKE 'I02%') " // OS 0516-15
	CSQL += " ORDER BY CTD_ITEM "

	IF CHKFILE("_ITEM")
		DBSELECTAREA("_ITEM")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_ITEM" NEW
	DO WHILE ! _ITEM->(EOF())
		cNovoItm := ALLTRIM(_ITEM->CTD_ITEM)+'-'+ALLTRIM(_ITEM->CTD_DESC01)
		AADD(ITEM_CONT, cNovoItm )
		_ITEM->(DBSKIP())
	END DO
	AADD(ITEM_CONT,"TODOS")
	nLinha += 10
	@ nLinha,01 COMBOBOX OGET01 VAR CITEM_CONT ITEMS ITEM_CONT FONT OBOLD_12 PIXEL OF OSCR SIZE 70,54

	nLinha += 15
	//FILTRO DFO PAGAMENTO
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",10) + "TIPO PAGAMENTO" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.
	PAGAMENTO :={}
	CPAGAMENTO := "TODOS"
	AADD(PAGAMENTO,"BONIFICACAO")
	AADD(PAGAMENTO,"DESCONTO PEDIDO")
	AADD(PAGAMENTO,"PAGAMENTO R$")
	AADD(PAGAMENTO,"DESC.INCONDICIONAL")
	AADD(PAGAMENTO,"OUTROS ")
	AADD(PAGAMENTO,"TODOS")
	nLinha += 10
	@ nLinha,01 COMBOBOX OGET02 VAR CPAGAMENTO ITEMS PAGAMENTO FONT OBOLD_12 PIXEL OF OSCR SIZE 70,54

	nLinha += 15
	//FILTRO DE CLIENTE
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",10) + "CLIENTE" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	nLinha += 10
	@ nLinha, 005 MSGET oGetPesq VAR cGetCli SIZE 054, 010 PICTURE "@!" F3 "SA1" OF OSCR PIXEL
	nLinha += 15

	//FILTRO DE MARCA
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",10) + "MARCA" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	nLinha += 10

	aMarcas :={"TODAS","BIANCOGRES", "PEGASUS", "INCESA","BELLACASA"}
	CMARCA := "TODAS"
	@ nLinha,01 COMBOBOX OGET03 VAR CMARCA ITEMS aMarcas FONT OBOLD_12 PIXEL OF OSCR SIZE 70,54

	nLinha += 15
	//FILTRO DE GRUPO DE CLIENTES
	OSAY1:= TSAY():NEW(nLinha,01,{||  REPLICATE(" ",10) + "GRUPO CLIENTE" },OSCR,,OBOLD_10,,,,.T.,CLR_BLACK,CLR_WHITE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	nLinha += 10
	@ nLinha, 005 MSGET oGetPesq VAR cGetGrpCli SIZE 054, 010 PICTURE "@!" F3 "ACY" OF OSCR PIXEL

	nLinha += 15
	@ nLinha,05 BUTTON "FILTRAR" SIZE 70,14 OF OSCR PIXEL ACTION U_BIAMsgRun("Aguarde... Consultando Dados...",, {|| SQL_FILTRO() })

	// *****************************  OPCOES DE BOTOES ***************************************
	nLinha += 15
	OSAY1:= TSAY():NEW(nLinha,01,{|| REPLICATE(" ",13) + "FERRAMENTAS" },OSCR,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_BLUE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	nLinha += 10
	@ nLinha,05 BUTTON "INCLUIR" SIZE 70,14 OF OSCR PIXEL ACTION UNOVO()
	nLinha += 15


	@ nLinha,05 BUTTON "EXCLUIR" SIZE 70,14 OF OSCR PIXEL ACTION EXCLUI_INVES()


	// CRIANDO O BROWSE PRINCIPAL
	SQL_TODOS()
	U_BIAMsgRun("Aguarde... Consultando Dados...",, {|| ATUALIZA_TELA() })
	oBrowse := IW_Browse(035,100,296,500,cAliasTrab,,,ACAMPOS0)
	oBrowse:OBROWSE:BLDBLCLICK := {|| DETALHES() }
	oBrowse:OBROWSE:ALIGN := CONTROL_ALIGN_ALLCLIENT

	//EVENTO AO CLICAR NAS COLUNAS PARA ORDENACAO - Fernando - 12/08/2010
	//nomear colunar pelo arquivo de trabalho
	FOR I := 1 To LEN(ACAMPOS0)
		oBrowse:OBROWSE:aColumns[I]:cMsg := ACAMPOS0[I][1]
	NEXT I
	Private _nLastCol := 0
	oBrowse:oBrowse:bHeaderClick := {|oBrw,nCol| FOrderCol(oBrw,nCol) }

	OSAY1:= TSAY():NEW(300,100,{||   + "TOTAL DE INVESTIMENTOS:      R$ " + TRANSFORM(S_TOT_FILTRO,"@E 999,999,999.99") },DLG_SOL,,OBOLD_16,,,,.T.,CLR_WHITE,CLR_BLUE,200,15)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.
	CMARCA := 'TODAS'

	//Ordem inicial do browse
	FOrderCol(oBrowse:OBROWSE,1)

	ACTIVATE MSDIALOG DLG_SOL CENTERED ON INIT Eval( {||  MsAguarde(), (cAliasTrab)->(DbGoTop()), oBrowse:oBrowse:Refresh(), } )

	oTableMain:Delete()

RETURN

Static Function fCriaArquivo(lRefresh)

	Local nW		:= 0
	Local cOrdIndex	:= "00"
	Local _ACAMPOS	:= {}

	If lRefresh

		oTableMain:Delete()

	EndIf

	AADD(_ACAMPOS, {"CCODIGO"		, "C", 06, 0})
	AADD(_ACAMPOS, {"SI"			, "C", 06, 0})
	AADD(_ACAMPOS, {"CSTATUS"		, "C", 25, 0})
	AADD(_ACAMPOS, {"SERIE"			, "C", 02, 0})
	AADD(_ACAMPOS, {"DATA_INV"		, "D", 08, 0})
	AADD(_ACAMPOS, {"COD_CLI"		, "C", 06, 0})
	AADD(_ACAMPOS, {"LOJ_CLI"		, "C", 02, 0})
	AADD(_ACAMPOS, {"CLIENTE"		, "C", 25, 0})
	AADD(_ACAMPOS, {"MUN"			, "C", 20, 0})
	AADD(_ACAMPOS, {"EST"			, "C", 02, 0})
	AADD(_ACAMPOS, {"COD_REP"		, "C", 06, 0})
	AADD(_ACAMPOS, {"REPRE"			, "C", 25, 0})
	AADD(_ACAMPOS, {"IT_CONT"		, "C", 09, 0})
	AADD(_ACAMPOS, {"FOR_PAG"		, "C", 25, 0})
	AADD(_ACAMPOS, {"ARECNO"		, "C", 25, 0})
	AADD(_ACAMPOS, {"AAOBS"			, "M", 25, 0})
	AADD(_ACAMPOS, {"AAOBS_APR"		, "M", 25, 0})
	AADD(_ACAMPOS, {"COMPRO"		, "C", 50, 0})
	AADD(_ACAMPOS, {"VALOR"			, "C", 16, 0})
	AADD(_ACAMPOS, {"MARCA"			, "C", 16, 0})
	AADD(_ACAMPOS, {"GRUPO"			, "C", 40, 0})
	AADD(_ACAMPOS, {"AUT_DE_INVEST"			, "C", 10, 0})

	ACAMPOS0 := {}

	AADD(ACAMPOS0, {"CCODIGO"		, "C�DIGO"			      	, 08})
	AADD(ACAMPOS0, {"CSTATUS"		, "STATUS"				    , 08})
	AADD(ACAMPOS0, {"DATA_INV"		, "DATA INV." 				, 18})
	AADD(ACAMPOS0, {"CLIENTE"		, "NOME CLIENTE" 			, 18})
	AADD(ACAMPOS0, {"COD_REP"		, "REPRE."  				, 06})
	AADD(ACAMPOS0, {"REPRE"			, "NOME REP." 		  		, 25})
	AADD(ACAMPOS0, {"IT_CONT"		, "ITEM CONTABIL" 			, 09})
	AADD(ACAMPOS0, {"FOR_PAG"		, "FORMA PAGAMENTO"			, 20})
	AADD(ACAMPOS0, {"VALOR"			, "VALOR" 				  	, 18})
	AADD(ACAMPOS0, {"MARCA"			, "MARCA" 				  	, 18})
	AADD(ACAMPOS0, {"GRUPO"		      	, "GRUPO CLIENTE" 			, 40})
	AADD(ACAMPOS0, {"AUT_DE_INVEST"			, "AUT DE INVEST" 			, 40})

	oTableMain := FWTemporaryTable():New(cAliasTrab, /*aFields*/)

	oTableMain:SetFields(_ACAMPOS)

	For nW := 1 To Len(ACAMPOS0)

		cOrdIndex := Soma1(cOrdIndex)

		oTableMain:AddIndex(cOrdIndex, {ACAMPOS0[nW][1]})

	Next nW

	oTableMain:Create()

Return()

//METODO PARA ORDENACAO DE COLUNAS NO GRID - ALTERA O INDICE DO ARQ. DE TRABALHO
Static Function FOrderCol(oBrw,nCol)

	(cAliasTrab)->(DbSetOrder(nCol))

	oBrw:SetHeaderImage(nCol,"COLDOWN")

	IF _nLastCol > 0 .And. _nLastCol <> nCol
		oBrw:SetHeaderImage(_nLastCol,"COLRIGHT")
	ENDIF

	oBrw:Refresh()
	_nLastCol := nCol

Return()


//METODO PARA PESQUISA DE DADOS DE ACORDO COM A COLUNA SELECIONADA
Static Function FPesqGrd()
	Local _cData
	Local lFound
	IF _nLastCol <= 0
		Return
	ENDIF

	IF Type("(cAliasTrab)->"+ACAMPOS0[_nLastCol][1]) == "D"
		_cData := CTOD(AllTrim(cGetPesq))
		lFound := (cAliasTrab)->(DBSEEK(DTOS(_cData)))
	ELSEIF Type("(cAliasTrab)->"+ACAMPOS0[_nLastCol][1]) == "N"
		_cData := VAL(AllTrim(cGetPesq))
		lFound := (cAliasTrab)->(DBSEEK(CVALTOCHAR(_cData)))
	ELSE
		If _nLastCol == 9 //Especifico para a coluna do valor que esta com tipo C e transformando?
			_cData := ALLTRIM(TRANSFORM(VAL(cGetPesq),'@E 999,999,999.99'))
			_cData := PADL(_cData,14)
		Else
			_cData := ALLTRIM(cGetPesq)
		EndIf
		lFound := (cAliasTrab)->(DBSEEK(_cData))
	ENDIF

	IF !lFound
		(cAliasTrab)->(DBGOTOP())
		MsgBox("DADO N�O ENCONTRADO!","PESQUISA","ALERT")
	ELSE
		oBrowse:oBrowse:SetFocus()
	ENDIF
	oBrowse:oBrowse:Refresh()

Return


//ATUALIZA A TELA COM OS FILTROS
STATIC FUNCTION ATUALIZA_TELA(lRefresh)

	Default lRefresh := .F.

	fCriaArquivo(lRefresh)

	//SELECIONANDO TODOS OS PRODUTOS E SUAS QUANTIDADES EM ESTOQUE
	IF CHKFILE("C_CONS")
		DBSELECTAREA("C_CONS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "C_CONS" NEW
	C_CONS->(DBGOTOP())
	WHILE !C_CONS->(EOF())
		RECLOCK(cAliasTrab,.T.)

		(cAliasTrab)->CCODIGO		:= C_CONS->ZO_YCOD
		(cAliasTrab)->SI    		:= C_CONS->ZO_SI
		(cAliasTrab)->CSTATUS		:= C_CONS->ZO_STATUS
		(cAliasTrab)->SERIE		:= C_CONS->ZO_SERIE
		(cAliasTrab)->DATA_INV	:= STOD(C_CONS->ZO_DATA)
		(cAliasTrab)->COD_CLI		:= C_CONS->A1_COD
		(cAliasTrab)->LOJ_CLI		:= C_CONS->A1_LOJA
		(cAliasTrab)->CLIENTE		:= C_CONS->A1_NOME
		(cAliasTrab)->MUN			:= C_CONS->A1_MUN
		(cAliasTrab)->EST			:= C_CONS->A1_EST
		(cAliasTrab)->COD_REP		:= C_CONS->A3_COD
		(cAliasTrab)->REPRE   	:= C_CONS->A3_NOME
		(cAliasTrab)->IT_CONT 	:= ALLTRIM(C_CONS->ZO_ITEMCTA)
		(cAliasTrab)->FOR_PAG		:= ALLTRIM(C_CONS->PAGAMENTO)
		(cAliasTrab)->VALOR		:= TRANS(C_CONS->ZO_VALOR,"@E 999,999,999.99")
		(cAliasTrab)->ARECNO		:= ALLTRIM(STR(C_CONS->ARECNO))
		(cAliasTrab)->AAOBS		:= C_CONS->AAOBS
		(cAliasTrab)->AAOBS_APR	:= C_CONS->AAOBS_APR
		(cAliasTrab)->COMPRO		:= C_CONS->ZO_YCOMPRO
		(cAliasTrab)->GRUPO		:= C_CONS->ACY_DESCRI

		Do Case
		Case C_CONS->ZO_EMP == '0101'
			(cAliasTrab)->MARCA		:= 'Biancogres'
		Case C_CONS->ZO_EMP == '0199'
			(cAliasTrab)->MARCA		:= 'Pegasus'
		Case C_CONS->ZO_EMP == '0501'
			(cAliasTrab)->MARCA		:= 'Incesa'
		Case C_CONS->ZO_EMP == '0599'
			(cAliasTrab)->MARCA		:= 'Bellacasa'
		Case C_CONS->ZO_EMP == '1302'
			(cAliasTrab)->MARCA		:= 'Vinilico'
		OtherWise
			(cAliasTrab)->MARCA		:= ''
		EndCase

		MSUNLOCK()
		C_CONS->(DBSKIP())
	ENDDO

	(cAliasTrab)->(DBGOTOP())

	IF lRefresh
		OBROWSE:OBROWSE:REFRESH()
		dlgRefresh(DLG_SOL)
	ENDIF

Return


//MONTANDO A TELA PARA A INCLUSAO DA NOVA SOLICITACAO 
Static Function UNOVO()

	LOCAL _ItemsMarca
	Local I

	PRIVATE NOVO_NRADIO		:= 7
	PRIVATE cNMarca 		:= SPACE(4)
	PRIVATE cNClient 		:= SPACE(6)
	PRIVATE cNLjCli 		:= SPACE(2)
	PRIVATE cNClient1 		:= SPACE(55)
	PRIVATE cNDESCRICAO 	:= SPACE(25)
	PRIVATE cNPEDIDO 		:= SPACE(10)
	PRIVATE cNVALOR 		:= 0.00
	PRIVATE cNCOND 			:= SPACE(3)
	PRIVATE cNCOND1 		:= SPACE(50)
	PRIVATE cNOBS
	PRIVATE cNDATALIB 		:= SPACE(50)
	PRIVATE oCheckBox
	PRIVATE cNRadio
	PRIVATE aRadio2 		:= {}
	PRIVATE NAMOSTRA 		:= 0
	PRIVATE NDIVERSOS 		:= 0
	PRIVATE NEXPOSITORES	:= 0
	PRIVATE NFEIRAS 		:= 0
	PRIVATE NMIDIA 			:= 0
	PRIVATE NNEGOCIACAO 	:= 0
	PRIVATE NPONTO 			:= 0
	PRIVATE NPROMOTORAS 	:= 0
	PRIVATE NSHOW 			:= 0
	PRIVATE CCTOTAL 		:= 0
	PRIVATE GRU_NAMOSTRA 	:= 0
	PRIVATE GRU_NDIVERSOS	:= 0
	PRIVATE GRU_NEXPOSITORES := 0
	PRIVATE GRU_NFEIRAS 	:= 0
	PRIVATE GRU_NMIDIA 		:= 0
	PRIVATE GRU_NNEGOCIACAO	:= 0
	PRIVATE GRU_NPONTO 		:= 0
	PRIVATE GRU_NPROMOTORAS	:= 0
	PRIVATE GRU_NSHOW		:= 0
	PRIVATE GRU_CCTOTAL 	:= 0

	PRIVATE S_CL_PA_INV	:= 0
	PRIVATE S_CL_PA_FAT	:= 0
	PRIVATE S_CL_PA_PER	:= 0
	PRIVATE S_CL_CO_INV	:= 0
	PRIVATE S_CL_CO_FAT	:= 0
	PRIVATE S_CL_CO_PER	:= 0
	PRIVATE S_CL_PR_INV	:= 0
	PRIVATE S_CL_PR_FAT	:= 0
	PRIVATE S_CL_PR_PER	:= 0

	PRIVATE S_GR_PA_INV	:= 0
	PRIVATE S_GR_PA_FAT	:= 0
	PRIVATE S_GR_PA_PER	:= 0
	PRIVATE S_GR_CO_INV	:= 0
	PRIVATE S_GR_CO_FAT	:= 0
	PRIVATE S_GR_CO_PER	:= 0
	PRIVATE S_GR_PR_INV	:= 0
	PRIVATE S_GR_PR_FAT	:= 0
	PRIVATE S_GR_PR_PER	:= 0

	// Tiago Rossini Coradini - 02/09/2015 - OS - 2383-15
	If cEmpAnt == "05"

		If Pergunte("INVEST")

			If MV_PAR01 == 1

				MsgBox("Empresa n�o autorizada!","Solicita��o de Investimento (AI)","ALERT")

				Return()

			EndIf

		Else
			Return()
		EndIf

	EndIf

	_ItemsMarca := {"0101=BIANCOGRES","0199=PEGASUS","0501=INCESA","0599=BELLACASA","1399=MUNDIALLI", "1302=VINILICO"}
	IF ALLTRIM(CREPATU) <> ""

		_ItemsMarca := {}

		DBSELECTAREA("SA3")
		DBSETORDER(1)
		DBSEEK (xFILIAL("SA3")+CREPATU)

		IF !EMPTY(ALLTRIM(SA3->A3_YEMP))

			_aMarcas := StrToKarr(SA3->A3_YEMP,"/")

			For I := 1 To Len(_aMarcas)

				If AllTrim(_aMarcas[I]) == "0101"
					AAdd(_ItemsMarca, "0101=BIANCOGRES")
				ElseIf AllTrim(_aMarcas[I]) == "0199"
					AAdd(_ItemsMarca, "0199=PEGASUS")
				ElseIf AllTrim(_aMarcas[I]) == "0501"
					AAdd(_ItemsMarca, "0501=INCESA")
				ElseIf AllTrim(_aMarcas[I]) == "0599"
					AAdd(_ItemsMarca, "0599=BELLACASA")
				ElseIf AllTrim(_aMarcas[I]) == "1399"
					AAdd(_ItemsMarca, "1399=MUNDIALLI")
				ElseIf AllTrim(_aMarcas[I]) == "1302"
					AAdd(_ItemsMarca, "1302=VINILICO")
				ElseIf AllTrim(_aMarcas[I]) == "XXXX"
					_ItemsMarca := {"0101=BIANCOGRES","0199=PEGASUS","0501=INCESA","0599=BELLACASA","1399=MUNDIALLI","1302=VINILICO"}
					exit
				EndIf

			Next I

		ENDIF

		If Len(_ItemsMarca) <= 0

			MSGBOX("REPRESENTANTE NAO ESTA VINCULADO A NENHUMA EMPRESA/MARCA","Solicita��o de Investimento (AI)","STOP")
			RETURN

		EndIf

	ENDIF

	DEFINE MSDIALOG oDlg1 FROM 0,0 TO 280,1000 TITLE ":::::: SOLICITA��O DE INVESTIMENTO (AI) ::::::" PIXEL

	// TELA DO BOTAO NOVO
	@ 005,006	To 30,489
	@ 010,010	SAY "USUARIO:  " + cNomeUsuario //"ADMINISTRATOR" // USUARIO
	@ 020,010	SAY "DATA DA SOLICITA��O   " + ALLTRIM(DTOC(DATE())) + "  " + TIME()  // USUARIO
	@ 015,210	SAY "SOLICITA��O DE INVESTIMENTO (AI)" // USUARIO

	@ 030,006	To 130,489 // FRAME GERAL



	@ 035,010	SAY "MARCA: "
	@ 035,100 COMBOBOX OGETMARCA VAR cNMarca ITEMS _ItemsMarca PIXEL OF oDlg1 SIZE 100,10

	@ 050,010	SAY "C�DIGO DO CLIENTE:  "
	@ 050,100	GET cNClient  VALID U_BIAMsgRun("Aguarde... Atualizando Totais",,{|| .T.}) SIZE 35,10 F3 "SA1BIA" PICT "@!R"
	@ 050,145	SAY "LOJA:"
	@ 050,180	GET cNLjCli  VALID U_BIAMsgRun("Aguarde... Atualizando Totais",,{|| .T.}) SIZE 15,10 PICT "@!R"

	@ 070,010	SAY "DESCRI��O:  "
	@ 070,100 	GET cNClient1  PICT "@!R" WHEN .F.

	//FILTRO DO ITEM CONTABIL
	@ 090,010	SAY "ITEM CONTABIL"
	ITEM_CONT :={}
	CITEM_CONT := "Favor Selecionar"
	AADD(ITEM_CONT,CITEM_CONT)

	CSQL := " SELECT * FROM "+RETSQLNAME("CTD")
	CSQL += " WHERE SUBSTRING(CTD_ITEM,1,1) = 'I' AND CTD_BLOQ = '2' AND D_E_L_E_T_ = ''
	CSQL += " AND (CTD_ITEM LIKE 'I01%' OR CTD_ITEM LIKE 'I02%') "
	CSQL += " ORDER BY CTD_ITEM "

	IF CHKFILE("_ITEM")
		DBSELECTAREA("_ITEM")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_ITEM" NEW
	DO WHILE ! _ITEM->(EOF())
		cNovItBw := ALLTRIM(_ITEM->CTD_ITEM) +'-'+ ALLTRIM(_ITEM->CTD_DESC01)
		AADD(ITEM_CONT,cNovItBw)
		_ITEM->(DBSKIP())
	END DO
	@ 090,100 COMBOBOX OGET04 VAR CITEM_CONT ITEMS ITEM_CONT FONT OBOLD_12 PIXEL OF oDlg1 SIZE 110,54

	@ 110,010	SAY "VALOR DO INVESTIMENTO: "
	@ 110,100 	GET cNVALOR SIZE 50,10 Picture "@R 999,999.99"

	IF U_VALOPER("SIS",.F.,.T.)
		@ 110,150	BUTTON "INF. SHOWROOM" SIZE 45,10 ACTION INF_CALC(cNClient,cNLjCli)
	ENDIF

	@ 040,230	SAY "Descri��o da solicita��o: "
	@ 050,230   GET cNOBS    SIZE 150,70 MEMO

	@ 060, 430	Button "SALVAR" Size 50,15 Action uSALVAR()
	@ 090, 430	Button "SAIR"  Size 50,15 Action CLOSE(ODLG1)

	ACTIVATE DIALOG oDlg1 Centered

RETURN


//EXIBE OS DETALHIES DA SOLICITACAO
STATIC FUNCTION DETALHES()
	PRIVATE NOVO_NRADIO := 6
	PRIVATE cNMarca		:= SPACE(4)
	PRIVATE cNClient 	:= SPACE(6)
	PRIVATE cNClient1 := SPACE(55)
	PRIVATE cNLjCli 	:= SPACE(2)
	PRIVATE cNDESCRICAO := SPACE(25)
	PRIVATE cNPEDIDO := SPACE(10)
	PRIVATE cNVALOR := 0.00
	PRIVATE cNSALDO := 0.00
	PRIVATE cNCOND := SPACE(3)
	PRIVATE cNCOND1 := SPACE(50)
	PRIVATE cNOBS
	PRIVATE cCOMPROV
	PRIVATE cNDATALIB := SPACE(50)
	PRIVATE oCheckBox
	PRIVATE cNRadio
	PRIVATE aRadio2 := {}
	PRIVATE NAMOSTRA := 0
	PRIVATE NDIVERSOS := 0
	PRIVATE NEXPOSITORES := 0
	PRIVATE NFEIRAS := 0
	PRIVATE NMIDIA := 0
	PRIVATE NNEGOCIACAO := 0
	PRIVATE NPONTO := 0
	PRIVATE NPROMOTORAS := 0
	PRIVATE NSHOW := 0
	PRIVATE CCTOTAL := 0
	PRIVATE GRU_NAMOSTRA := 0
	PRIVATE GRU_NDIVERSOS := 0
	PRIVATE GRU_NEXPOSITORES := 0
	PRIVATE GRU_NFEIRAS := 0
	PRIVATE GRU_NMIDIA := 0
	PRIVATE GRU_NNEGOCIACAO := 0
	PRIVATE GRU_NPONTO := 0
	PRIVATE GRU_NPROMOTORAS := 0
	PRIVATE GRU_NSHOW := 0
	PRIVATE GRU_CCTOTAL := 0

	PRIVATE S_CL_PA_INV	:= 0
	PRIVATE S_CL_PA_FAT	:= 0
	PRIVATE S_CL_PA_PER	:= 0
	PRIVATE S_CL_CO_INV	:= 0
	PRIVATE S_CL_CO_FAT	:= 0
	PRIVATE S_CL_CO_PER	:= 0
	PRIVATE S_CL_PR_INV	:= 0
	PRIVATE S_CL_PR_FAT	:= 0
	PRIVATE S_CL_PR_PER	:= 0

	PRIVATE S_GR_PA_INV	:= 0
	PRIVATE S_GR_PA_FAT	:= 0
	PRIVATE S_GR_PA_PER	:= 0
	PRIVATE S_GR_CO_INV	:= 0
	PRIVATE S_GR_CO_FAT	:= 0
	PRIVATE S_GR_CO_PER	:= 0
	PRIVATE S_GR_PR_INV	:= 0
	PRIVATE S_GR_PR_FAT	:= 0
	PRIVATE S_GR_PR_PER	:= 0
	PRIVATE CIITEM_CONT := ''

	//POSICIONAR NO REGISTRO DO INVESTIMENTO SELECIONADO
	SZO->(DbSetOrder(4))
	SZO->(DbSeek(XFILIAL("SZO")+(cAliasTrab)->CCODIGO))

	DEFINE MSDIALOG oDlg1 FROM 0,0 TO 400,1000 TITLE ":::::: SOLICITA��O DE INVESTIMENTO (AI) ::::::" PIXEL

	cNClient 		:= (cAliasTrab)->COD_CLI
	cNLjCli			:= (cAliasTrab)->LOJ_CLI
	cNClient1		:= POSICIONE("SA1",1,XFILIAL("SA1")+cNClient+cNLjCli,"A1_NOME")

	CIITEM_CONT	:= ALLTRIM((cAliasTrab)->IT_CONT)

	cNVALOR			:= (cAliasTrab)->VALOR
	cNSALDO			:= TRANS(SalInvest(),"@E 999,999,999.99")
	cNOBS			:= (cAliasTrab)->AAOBS
	cNOBSAPR		:= (cAliasTrab)->AAOBS_APR
	cCOMPROV		:= (cAliasTrab)->COMPRO

	// TELA DO BOTAO NOVO
	@ 005,006	To 30,495
	@ 010,010	SAY "USUARIO:  " + cNomeUsuario //"ADMINISTRATOR" // USUARIO
	@ 020,010	SAY "DATA DA SOLICITA��O   " + DTOC((cAliasTrab)->DATA_INV)
	@ 010,210	SAY "SOLICITA��O DE INVESTIMENTO (AI): " + AllTrim((cAliasTrab)->SI)
	@ 020,100	SAY "MARCA: " + (cAliasTrab)->MARCA

	OSAY1:= TSAY():NEW(020,365,{|| "STATUS DA SOLICITA��O: " + (cAliasTrab)->CSTATUS },oDlg1,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_RED,130,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.


	@ 030,006	To 190, 495 // FRAME GERAL

	//GRUPO DOS DADOS DO CLIENTE - ALTERADO POSICOES POR FERNANDO ROCHA - 30/07/2010
	oGrCli	:= TGroup():New( 038,010,91,225,"DADOS DO CLIENTE:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	@ 045,020	SAY "C�DIGO:  "
	@ 045,075 	GET cNClient SIZE 35,10 F3 "SA1BIA" PICT "@!R" WHEN .F.
	@ 045,115	SAY "LOJA:"
	@ 045,130 	GET cNLjCli  SIZE 15,10 PICT "@!R" WHEN .F.
	@ 060,020	SAY "DESCRI��O:  "
	@ 060,075 	GET cNClient1 SIZE 120,10 PICT "@!R" WHEN .F.

	@ 075,020	SAY "MUNIC�PIO: "
	@ 075,075 	GET (cAliasTrab)->MUN  SIZE 80,10 PICT "@!R" WHEN .F.
	@ 075,160	SAY "UF: "
	@ 075,170 	GET (cAliasTrab)->EST  SIZE 5,10 PICT "@!R" WHEN .F.

	// Item + '' + Descricao
	aItem 		:= StrTokArr(CIITEM_CONT,"-")
	cAuxItem 	:= IIF(Len(aItem[1]) > 0,  aItem[1], '')

	//FILTRO DO ITEM CONTABIL
	ITEM_CONT :={}
	CSQL := "SELECT * FROM "+RETSQLNAME("CTD")+" WHERE CTD_ITEM = '"+cAuxItem+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_ITEM")
		DBSELECTAREA("_ITEM")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_ITEM" NEW

	uNovo := ALLTRIM(_ITEM->CTD_ITEM)+'-'+ALLTRIM(_ITEM->CTD_DESC01)
	CIITEM_CONT	:= uNovo

	//GRUPO DOS DADOS DO INVESTIMENTO - ALTERADO POSICOES POR FERNANDO ROCHA - 30/07/2010
	oGrInvest	:= TGroup():New( 093,010,132,225,"DADOS DO INVESTIMENTO:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

	//ITEM CONTABIL
	@ 100,020	SAY "ITEM CONTABIL"
	@ 100,075 GET CIITEM_CONT SIZE 100,10  WHEN .F.

	@ 115,020	SAY "VALOR:  "
	@ 115,075 	GET cNVALOR SIZE 50,10  WHEN .F. //Picture "@R 999.999.999,99"
	@ 115,130	SAY "SALDO:  "
	@ 115,155 	GET cNSALDO SIZE 50,10  WHEN .F. //Picture "@R 999.999.999,99"

	oGrObs	:= TGroup():New( 038,228,144,382,"Aprovadores:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	@ 047, 230	SAY "Ger.: "+AllTrim(SZO->ZO_USUAPRO)+" em "+DTOC(SZO->ZO_DATAPRO)+" as "+AllTrim(SZO->ZO_HORAAPR)+""
	cNOBSAPR := cNOBSAPR+ENTER
	@ 055, 230  GET cNOBSAPR    SIZE 150,38 MEMO WHEN .F.///!( AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Dir.' ) //OS 4525-15
	@ 95, 230	SAY "Sup.: "+AllTrim(SZO->ZO_USUASUP)+" em "+DTOC(SZO->ZO_DATASUP)+" as "+AllTrim(SZO->ZO_HORASUP)+""
	@ 102, 230	GET (SZO->ZO_OBSSUP+ENTER)    SIZE 150, 38 MEMO WHEN .F.

	IF EMPTY(CREPATU) .And. !( AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Dir.' )  //OS 4525-15

		oGrCmp	:= TGroup():New( 038,385,86,485,"COMPROVA��O:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 047,387	GET cCOMPROV    SIZE 75,35 MEMO PIXEL OF oGrCmp
		@ 047,463	Button "OK"	Size 20,15 Action GRA_COMPRO() PIXEL OF oGrCmp

	END IF

	cNOBS := cNOBS+ENTER
	oGrSup	:= TGroup():New(135,010, 186,225,"Descri��o da solicita��o:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	@ 144,016   GET cNOBS   SIZE 200,38 MEMO WHEN !( AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Dir.' ) //OS 4525-15


	//GRUPO DE BOTOES DE ACAO - ALTERADO POR FERNANDO ROCHA - 30/07/2010
	If EMPTY(CREPATU)

		//Aprovacao da diretoria - botoes diferentes - OS 4525-15 - Fernando/Facile em 13/04/2016
		//Aprovador Nivel - 3
		If ( AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Dir.' )

			If ;
					(AllTrim(cEmpAnt) == "01" .And. U_VALOPER("SI2",.F.) ) .Or. ;
					(AllTrim(cEmpAnt) == "05" .And. U_VALOPER("SI3",.F.) ) .Or.; //Fernando/Facile OS 4525-15 - acesso de diretor
				(AllTrim(cEmpAnt) == "01" .And. TempValOper("SI2")) .Or. ;
					(AllTrim(cEmpAnt) == "05" .And. TempValOper("SI3"));


				@ 092, 410	BUTTON "APROVAR"  SIZE 70,10 ACTION AprovDir("Aprovado")//ALT_DIR('Aprovado')
				@ 104, 410	BUTTON "REPROVAR" SIZE 70,10 ACTION AprovDir("Reprovado")//ALT_DIR('Reprovado')

			Else
				MsgAlert("Usu�rio sem acesso a esta opera��o.", "Aprovador Nivel 1 - CadOper: SI2/SI3")
			EndIf

		Else

			If U_VALOPER("ADMIN")

				If ( AllTrim((cAliasTrab)->CSTATUS) == 'Aprovado' )
					@ 092, 410	BUTTON "LAN�AR BAIXAS" 	SIZE 70,10 ACTION ( U_LAN_BAIXAS() , cNSALDO := TRANS(SalInvest(),"@E 999,999,999.99") , oDlg1:Refresh() )
				EndIf

				//@ 104, 410	BUTTON "ALTERAR STATUS" SIZE 70,10 ACTION ALT_STATUS()

			ElseIf ( AllTrim((cAliasTrab)->CSTATUS) == 'Aprovado' )
				@ 092, 410	BUTTON "LAN�AR BAIXAS" 	SIZE 70,10 ACTION ( U_LAN_BAIXAS() , cNSALDO := TRANS(SalInvest(),"@E 999,999,999.99") , oDlg1:Refresh() )

			/*ELSEIF  U_VALOPER("SI1",.F.,.T.)
				@ 104, 410	BUTTON "ALTERAR STATUS" SIZE 70,10 ACTION ALT_STATUS()
			*/	
			EndIf


			//Aprova��es Nivel 1 e 2
			If (AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprova��o' .Or. AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Ger.')

				//@ 104, 410	BUTTON "ALTERAR STATUS" SIZE 70,10 ACTION ALT_STATUS()

				_aRetAprov := UserAprov()
				If ( AllTrim(_aRetAprov[1]) == RetCodUsr() .Or. AllTrim(_aRetAprov[1]) $ AprovTemp())
					@ 104, 410	BUTTON "ALTERAR STATUS" SIZE 70,10 ACTION ALT_STATUS()
				Else
					MsgAlert("Usu�rio sem acesso a esta opera��o, Aprovador respons�vel: "+AllTrim(_aRetAprov[2])+".", "Aprovador Nivel 3 - Tabela: ZKP")
				EndIf

			ElseIf (AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Sup.')

				If U_VALOPER("SI1",.F.,.T.) .Or. TempValOper("SI1")
					@ 092, 410	BUTTON "APROVAR"  SIZE 70, 10 ACTION AprovSuper()
				Else
					MsgAlert("Usu�rio sem acesso a esta opera��o.","Aprovador Nivel 2 - CadOper: SI1")
				EndIf

			EndIf

		EndIf

	EndIf

	@ 116, 410	Button "HIST. APROV." 	Size 70,10 Action HistAprov()

	@ 128, 410	Button "SAIR"  			Size 70,10 Action CLOSE(ODLG1)


	ACTIVATE DIALOG oDlg1 Centered

RETURN


//GRAVANDO A SOLICITACAO DE INVESTIMENTO
Static Function uSALVAR()

	Local _nLimVDir := GetNewPar("MV_YSILDIR",5000)
	Local auxEmpre := ""
	Local auxSerie := ""

	cCodigo := CCODUSUARIO

	IF EMPTY(ALLTRIM(cNMarca)) .Or. EMPTY(ALLTRIM(cNClient)) .OR. cNVALOR = 0 .OR. EMPTY(ALLTRIM(cNLjCli))
		MSGBOX("FAVOR PREENCHER TODOS OS CAMPOS","Solicita��o de Investimento (AI)","ALERT")
		RETURN
	END IF

	If Len(Alltrim(cNLjCli))<>2
		MSGBOX("FAVOR VERIFICAR O CAMPO LOJA, POIS EST� INCORRETO!","Solicita��o de Investimento (AI)","ALERT")
		RETURN
	EndIf

	If ( CITEM_CONT == "Favor Selecionar" )
		MSGBOX("FAVOR VERIFICAR O CAMPO ITEM CONT�BIL, PREENCHIMENTO OBRIGAT�RIO.","Solicita��o de Investimento (AI)","ALERT")
		RETURN
	EndIf

	If Empty(cNOBS)
		MSGBOX("FAVOR VERIFICAR O CAMPO ITEM 'Descri��o da Solicita��o', PREENCHIMENTO OBRIGAT�RIO.","Solicita��o de Investimento (AI)","ALERT")
		RETURN
	EndIf

	//BUSCANDO O MAIOR CODIGO DA TABELA
	CSQL := "SELECT ISNULL(MAX(ZO_YCOD),0) AS MAX_COD FROM "+RETSQLNAME("SZO")+" "
	If chkfile("_MAX")
		dbSelectArea("_MAX")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_MAX" NEW
	MACODIGO := SOMA1(_MAX->MAX_COD,6)

	If cEmpAnt == "01"
		PERGUNTE("INVEST",.F.)
		MV_PAR01 := 1
	EndIf

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+ALLTRIM(cNClient)+ALLTRIM(cNLjCli),.F.)

	DO CASE
	CASE SubString(cNMarca,1,4) == "0101"
		If Empty(Alltrim(SA1->A1_VEND))
			MSGBOX("Favor preencher o campo Vendedor no Cadastro de Cliente antes de continuar!","Solicita��o de Investimento (AI)","ALERT")
			RETURN
		Else
			IF CCODUSUARIO > '999999'
				cCodigo := SA1->A1_VEND
			EndIf
		EndIf

		auxEmpre := "0101"
		auxSerie := 'S1'
	CASE SubString(cNMarca,1,4) == "0199"
		If Empty(Alltrim(SA1->A1_YVENPEG))
			MSGBOX("Favor preencher o campo Vendedor no Cadastro de Cliente antes de continuar!","Solicita��o de Investimento (AI)","ALERT")
			RETURN
		Else
			IF CCODUSUARIO > '999999'
				cCodigo := SA1->A1_YVENPEG
			EndIf
		EndIf

		auxEmpre := "0199"
		auxSerie := 'S1'


	CASE SubString(cNMarca,1,4) == "0501"
		If Empty(Alltrim(SA1->A1_YVENDI))
			MSGBOX("Favor preencher o campo Vendedor no Cadastro de Cliente antes de continuar!","Solicita��o de Investimento (AI)","ALERT")
			RETURN
		Else
			IF CCODUSUARIO > '999999'
				cCodigo := SA1->A1_YVENDI
			EndIf
		EndIf

		auxEmpre := "0501"
		auxSerie := 'S2'

	CASE SubString(cNMarca,1,4) == "0599"
		If Empty(Alltrim(SA1->A1_YVENBE1))
			MSGBOX("Favor preencher o campo Vendedor no Cadastro de Cliente antes de continuar!","Solicita��o de Investimento (AI)","ALERT")
			RETURN
		Else
			IF CCODUSUARIO > '999999'
				cCodigo := SA1->A1_YVENBE1
			EndIf
		EndIf

		auxEmpre := "0599"
		auxSerie := 'S3'

	CASE SubString(cNMarca,1,4) == "1302"
		If Empty(Alltrim(SA1->A1_YVENVI1))
			MSGBOX("Favor preencher o campo Vendedor no Cadastro de Cliente antes de continuar!","Solicita��o de Investimento (AI)","ALERT")
			RETURN
		Else
			IF CCODUSUARIO > '999999'
				cCodigo := SA1->A1_YVENVI1
			EndIf
		EndIf

		auxEmpre := "1302"
		auxSerie := 'S3'

	OTHERWISE
		MSGBOX("Favor preencher a marca!","Solicita��o de Investimento (AI)","ALERT")
		RETURN
	ENDCASE

	DBSELECTAREA("SZO")
	RecLock("SZO",.T.)
	SZO->ZO_FILIAL		:= XFILIAL("SZO")
	SZO->ZO_YCOD		:= MACODIGO
	SZO->ZO_SI  		:= MACODIGO
	SZO->ZO_DATA		:= DATE()
	SZO->ZO_CLIENTE		:= ALLTRIM(cNClient)
	SZO->ZO_LOJA		:= ALLTRIM(cNLjCli)
	SZO->ZO_REPRE		:= cCodigo
	SZO->ZO_VALOR		:= cNVALOR
	SZO->ZO_ITEMCTA 	:= SUBSTRING(CITEM_CONT,1,5)
	SZO->ZO_STATUS		:= "Aguard. Aprov. Ger."
	SZO->ZO_YOBS		:= cNOBS
	SZO->ZO_EMP			:= auxEmpre
	SZO->ZO_SERIE   	:= auxSerie
	MsUnLock()

	//ITEM CONTABIL
	CITEM_CONT := "TODOS"

	SQL_FILTRO()
	CLOSE(ODLG1)

	//TODO tratar mensagem
	/*If ( cNVALOR > _nLimVDir )
		MSGBOX("Esta AI ser� submetida a 2 n�veis de aprova��o: Gerente + Diretor","VALOR LIMITE ULTRAPASSADO","INFO")
EndIf
	*/

_TipoAprov  := TipoAprov()
If (_TipoAprov == "3")
	MSGBOX("Esta AI ser� submetida a 1 n�vel de aprova��o: Gerente Comercial","VALOR LIMITE ULTRAPASSADO","INFO")
ElseIf(_TipoAprov == "2")
	MSGBOX("Esta AI ser� submetida a 2 n�veis de aprova��o: Gerente Comercial + Gerente","VALOR LIMITE ULTRAPASSADO","INFO")
Else
	MSGBOX("Esta AI ser� submetida a 3 n�veis de aprova��o: Gerente Comercial + Gerente + Diretor","VALOR LIMITE ULTRAPASSADO","INFO")
EndIf


MSGBOX("A AI de N�mero: "+ALLTRIM(MACODIGO)+" foi inclu�da com sucesso!","Solicita��o de Investimento (AI)","INFO")

RETURN

//GRAVA A COMPROVACAO 
STATIC FUNCTION GRA_COMPRO()

	DBSELECTAREA("SZO")
	DBSETORDER(4)
	IF DBSEEK(XFILIAL("SZO")+(cAliasTrab)->CCODIGO,.T.)
		RecLock("SZO",.F.)
		SZO->ZO_YCOMPRO := cCOMPROV
		MsUnLock()
	END IF
	oDlg1:Refresh()
	SQL_FILTRO()

RETURN


//ALTERA O STATUS DAS SOLICITACOES DE INVESTIMENTOS 
STATIC FUNCTION ALT_STATUS()

	Local cDescRadio	:= ""
	PRIVATE N22RADIO	:= 1
	PRIVATE C22NOBS 	:= ALLTRIM((cAliasTrab)->AAOBS_APR)
	PRIVATE CcNVALOR 	:= 0.00

	If AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprova��o' .Or. AllTrim((cAliasTrab)->CSTATUS) = 'Aguard. Aprov. Ger.'
		N22RADIO := 1
	ElseIf (cAliasTrab)->CSTATUS = 'Aprovado'
		N22RADIO := 2
	ElseIf (cAliasTrab)->CSTATUS = 'Reprovado'
		N22RADIO := 3
	Else
		N22RADIO := 0
	EndIf

	cNClient		:= (cAliasTrab)->COD_CLI
	cNLjCli			:= (cAliasTrab)->LOJ_CLI
	cNClient1 		:= POSICIONE("SA1",1,XFILIAL("SA1")+cNClient+cNLjCli,"A1_NOME")

	CITEM_CONT := cAuxItem

	cNVALOR			:= (cAliasTrab)->VALOR
	cNOBS			:= (cAliasTrab)->AAOBS
	cNOBSAPR		:= (cAliasTrab)->AAOBS_APR
	cCOMPROV		:= (cAliasTrab)->COMPRO

	//ITEM CONTABIL
	ITEM_CONT	:={}

	CSQL := " SELECT * FROM "+RETSQLNAME("CTD")
	CSQL += " WHERE SUBSTRING(CTD_ITEM,1,1) = 'I' AND CTD_BLOQ = '2' AND D_E_L_E_T_ = ''
	CSQL += " AND (CTD_ITEM LIKE 'I01%' OR CTD_ITEM LIKE 'I02%') " // OS 0516-15
	CSQL += " ORDER BY CTD_ITEM "

	If CHKFILE("_ITEM")
		DBSELECTAREA("_ITEM")
		DBCLOSEAREA()
	EndIf

	TCQUERY CSQL ALIAS "_ITEM" NEW
	DO WHILE ! _ITEM->(EOF())
		cNovoItm := ALLTRIM(_ITEM->CTD_ITEM) +'-'+ ALLTRIM(_ITEM->CTD_DESC01)
		AADD(ITEM_CONT,cNovoItm)
		_ITEM->(DBSKIP())
	END DO

	DEFINE MSDIALOG oDlg24 FROM 0,0 TO 250,500 TITLE ":::::: SOLICITA��O DE INVESTIMENTO (AI) ::::::" PIXEL

	@ 010,010	SAY "STATUS:  "
	If AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprova��o' .Or. AllTrim((cAliasTrab)->CSTATUS) == 'Aguard. Aprov. Ger.'
		@ 017,006 RADIO N22RADIO 3D PROMPT "Aguard. Aprova��o", "Aprovado", "Reprovado" SIZE  77,9 OF oDlg24 PIXEL
	EndIf

	@ 085,006	SAY "TIPO PAGAMENTO:  "

	PAGAMENTO :={}
	CCPAGAMENTO := UPPER((cAliasTrab)->FOR_PAG)

	If Empty(CCPAGAMENTO)
		CCPAGAMENTO := "Favor Escolher..."
	EndIf

	AADD(PAGAMENTO,"Favor Escolher...")
	AADD(PAGAMENTO,"BONIFICACAO")
	AADD(PAGAMENTO,"DESCONTO PEDIDO")
	AADD(PAGAMENTO,"PAGAMENTO R$")
	AADD(PAGAMENTO,"DESC.INCONDICIONAL")
	AADD(PAGAMENTO,"OUTROS ")

	@ 095,006 COMBOBOX OGET05 VAR CCPAGAMENTO ITEMS PAGAMENTO FONT OBOLD_12 PIXEL OF oDlg24 SIZE 70,54

	CcNVALOR	:= STRTRAN((cAliasTrab)->VALOR, ",", "*")
	CcNVALOR	:= STRTRAN(CcNVALOR, ".", ",")
	CcNVALOR	:= STRTRAN(CcNVALOR, "*", ".")

	@ 10,090	SAY "VALOR DO INVESTIMENTO:  "
	@ 10,165 	GET CcNVALOR SIZE 50,10 Picture "@ 999,999.99"  WHEN .F.

	//ITEM CONTABIL
	@ 025,090	SAY "ITEM CONT.  "
	@ 025,130 COMBOBOX OGET06 VAR CIITEM_CONT ITEMS ITEM_CONT FONT OBOLD_12 PIXEL OF oDlg24 SIZE 110,54

	@ 035,090	SAY "OBSERVA��O:  "
	@ 045,090   GET c22NOBS    SIZE 150,50 MEMO

	@ 110,006 BUTTON "ALTERAR STATUS" SIZE 70,14 OF oDlg24 PIXEL ACTION USAL_STATUS()
	@ 110,170 BUTTON "CANCELAR" SIZE 70,14 OF oDlg24 PIXEL ACTION CLOSE(oDlg24)


	ACTIVATE MSDIALOG oDlg24 CENTERED ON INIT Eval( {|| } )
	oDlg1:Refresh()

RETURN

//GRAVA O STATUS NA TABELA  
STATIC FUNCTION USAL_STATUS()

	Local _nLimVDir := GetNewPar("MV_YSILDIR",5000)
	Local _nValSI
	Local _cProxStatus	:= ""
	Local _cStatusAnt	:= ""

	IF !(cAliasTrab)->(EOF())

		IF Alltrim(CCPAGAMENTO) == "Favor Escolher..."
			ALERT("FAVOR ESCOLHER A FORMA DE PAGAMENTO")
			Return
		ELSEIF N22RADIO = 7
			ALERT("N�O EXISTE O STATUS TODOS")
		ELSE

			IF N22RADIO = 1
				XSSTATUS = 'Aguard. Aprov. Ger.'
			ELSEIF N22RADIO = 2
				XSSTATUS = 'Aprovado'
			ELSEIF N22RADIO = 3
				XSSTATUS = 'Reprovado'
			ENDIF


			IF CCPAGAMENTO = "BONIFICACAO"
				CPAG := "1"
			ELSEIF CCPAGAMENTO = "DESCONTO PEDIDO"
				CPAG := "2"
			ELSEIF CCPAGAMENTO = "PAGAMENTO R$"
				CPAG := "3"
			ELSEIF CCPAGAMENTO = "DESC.INCONDICIONAL"
				CPAG := "6"
			ELSE
				CPAG := "5"
			END IF


			DBSELECTAREA("SZO")
			DBSETORDER(4)
			If DBSEEK(XFILIAL("SZO")+(cAliasTrab)->CCODIGO,.T.)

				/*__CcNVALOR	:= STRTRAN( (cAliasTrab)->VALOR  ,",","*")
				__CcNVALOR	:= STRTRAN( __CcNVALOR  ,".","")
				__CcNVALOR	:= STRTRAN( __CcNVALOR  ,"*",".")
				_nValSI 	:= VAL(__CcNVALOR)
				

				If ( XSSTATUS == 'Aprovado' ) .And. ( Alltrim(SZO->ZO_STATUS) <> XSSTATUS ) .And. ( _nValSI > _nLimVDir )
					MsgAlert("Esta SI ser� direcionada para aprova��o da DIRETORIA.","VALOR LIMITE ULTRAPASSADO")
					XSSTATUS := 'Aguard. Aprov. Dir.'
				EndIf
				*/


				If (Alltrim(SZO->ZO_STATUS) <> XSSTATUS )
					If (AllTrim(XSSTATUS) == 'Aprovado')
						_cProxStatus := ProxSequeAprov(SZO->ZO_STATUS)
						If (!Empty(_cProxStatus)) //existe proximo nivel de aprova��o
							XSSTATUS := _cProxStatus
						EndIf
					EndIf
				EndIf

				_cStatusAnt := SZO->ZO_STATUS

				RecLock("SZO",.F.)
				SZO->ZO_STATUS	:= XSSTATUS
				SZO->ZO_YOBSAPR	:= c22NOBS
				SZO->ZO_FPAGTO	:= CPAG
				SZO->ZO_DATAPRO	:= dDataBase
				SZO->ZO_HORAAPR	:= TIME()
				SZO->ZO_USUAPRO	:= ALLTRIM(cNomeUsuario)

				//ITEM CONTABIL
				aItem 			:= StrTokArr(CIITEM_CONT,"-")
				SZO->ZO_ITEMCTA	:= aItem[1] //CIITEM_CONT
				SZO->ZO_VALOR 	:= _nValSI

				MsUnLock()

				AtuHistAprov('G', XSSTATUS, _cStatusAnt)

			EndIf

			If XSSTATUS = 'Aprovado'
				EMAIL_APROVADO()
			EndIf

			CSQL := "UPDATE "+RETSQLNAME("SZO")+" SET ZO_STATUS = '"+XSSTATUS+"' WHERE R_E_C_N_O_ = '"+ALLTRIM((cAliasTrab)->ARECNO)+"' "
			TCSQLEXEC(CSQL)
		END IF
	END IF

	//Limpa Filtros.
	CITEM_CONT := "TODOS"
	cAuxItem   := CITEM_CONT

	CLOSE(oDlg24)
	CLOSE(oDlg1)
	SQL_FILTRO()
RETURN



//Altera status simples para diretoria - aprova ou reprova 
STATIC FUNCTION ALT_DIR(_XSSTATUS)

	DBSELECTAREA("SZO")
	DBSETORDER(4)
	If DBSEEK(XFILIAL("SZO")+(cAliasTrab)->CCODIGO,.T.)

		RecLock("SZO",.F.)
		SZO->ZO_STATUS	:= _XSSTATUS
		SZO->ZO_USUDIR	:= CUSERNAME
		SZO->ZO_DATADIR	:= dDataBase
		SZO->ZO_HORADIR	:= SubStr(Time(),1,5)

		SZO->(MsUnLock())

		If _XSSTATUS = 'Aprovado'
			EMAIL_APROVADO()
		EndIf

	EndIf

	CLOSE(oDlg1)
	SQL_FILTRO()
RETURN


//EXCLUI A SOLICITACAO DE INVESTIMENTO  
Static Function EXCLUI_INVES()

	Local _aRetAprov := UserAprov()

	If AllTrim(_aRetAprov[1]) == AllTrim(RetCodUsr())

		If	AllTrim((cAliasTrab)->CSTATUS) == "Aguard. Aprova��o" 	.Or. ;
				AllTrim((cAliasTrab)->CSTATUS) == "Aguard. Aprov. Ger."	.Or. ;
				AllTrim((cAliasTrab)->CSTATUS) == "Aguard. Aprov. Sup." .Or. ;
				AllTrim((cAliasTrab)->CSTATUS) == "Aguard. Aprov. Dir." .Or. ;
				AllTrim((cAliasTrab)->CSTATUS) == "Reprovado"

			If !(cAliasTrab)->(EOF())

				SZO->(DbSetOrder(4))
				If SZO->(DbSeek(XFILIAL("SZO")+(cAliasTrab)->CCODIGO,.T.))
					RecLock("SZO",.F.)
					SZO->(DBDELETE())
					SZO->(MSUNLOCK())
					SQL_FILTRO()
				EndIf

			EndIf

		Else

			MsgAlert("SI: "+(cAliasTrab)->CCODIGO+" - Status n�o permite exclus�o")

		EndIf

	Else

		MsgAlert("Usu�rio n�o tem permiss�o para essa a��o.")

	EndIf

Return


//SELECIONANDO INFORMACOES DOS USUARIOS 
STATIC FUNCTION BUSCA_USUARIOS()
	DBSELECTAREA("SA3")
	NORDEM := INDEXORD()
	DBSETORDER(7)
	_NOMEUSER := cUserName
	PSWORDER(2)	// PESQUISA POR NOME
	IF  PSWSEEK(_NOMEUSER,.T.)
		_DADUSER  		:= PSWRET(1)
		CNOMEUSUARIO 	:= _DADUSER[1,4]	// NOME DO USUARIO
		CCODUSUARIO 	:= _DADUSER[1,2]
	ENDIF
RETURN


//SELECIONANDO TODOS OS REGISTROS 
Static Function SQL_TODOS(_lDir)

	Local cAprovTemp := ""

	Default _lDir := .F.

	cSql := "SELECT	CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBSAPR)) AS AAOBS_APR, CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBS)) AS AAOBS, SZO.R_E_C_N_O_ AS ARECNO "+ENTER

	cSql += " , ZO_YCOD, ZO_SI, ZO_STATUS, ZO_DATA, ZO_SERIE, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_EST, A3_COD, A3_NOME, ZO_ITEMCTA, ZO_VALOR, ZO_YCOMPRO, ZO_EMP, ISNULL((ACY_GRPVEN +' - '+  ACY_DESCRI), '-' ) AS ACY_DESCRI, " + ENTER
	cSql += "		PAGAMENTO = CASE	WHEN ZO_FPAGTO = '1' THEN 'Bonificacao' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '2' THEN 'Desconto Pedido' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '3' THEN 'Pagamento R$' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '5' THEN 'Outros' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '6' THEN 'Desc.Incondicional' " + ENTER
	cSql += "							ELSE '' END " + ENTER

	cSql+= " FROM "+RETSQLNAME("SZO")+ " SZO "+ ENTER
	cSql+= " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SZO.ZO_FILIAL	= '01'	AND SA1.A1_COD = SZO.ZO_CLIENTE AND SA1.A1_LOJA = SZO.ZO_LOJA AND SA1.D_E_L_E_T_ = '' "+ ENTER
	cSql+= " INNER JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD	= SZO.ZO_REPRE	AND SA3.D_E_L_E_T_	= '' "+ ENTER
	cSql+= " LEFT  JOIN ACY010 ACY ON ACY.ACY_GRPVEN= A1_GRPVEN	AND ACY.D_E_L_E_T_	= '' "+ ENTER
	cSql+= " WHERE	SZO.ZO_YCOD <> '' "	+ ENTER

	IF ! EMPTY(CREPATU)
		cSql	+= "		AND SZO.ZO_REPRE =  '"+ALLTRIM(CCODUSUARIO)+"' " + ENTER
		cSql	+= "		AND SZO.ZO_SI   <> '' "	+ ENTER
	EndIf

	/*If ( _lDir )
		cSql += "		AND SZO.ZO_STATUS = 'Aguard. Aprov. Dir.' " + ENTER
EndIf*/
	
If (cTipoAprov == '1')
		cSql += " AND SZO.ZO_STATUS = 'Aguard. Aprov. Dir.'  " + ENTER
ElseIf (cTipoAprov == '2')
		cSql += " AND SZO.ZO_STATUS = 'Aguard. Aprov. Sup.'  " + ENTER
ElseIf (cTipoAprov == '3')
		cSql += " AND (SZO.ZO_STATUS = 'Aguard. Aprova��o' OR SZO.ZO_STATUS = 'Aguard. Aprov. Ger.') " + ENTER
	
		
		cSql += " AND (SELECT UGERENT from [dbo].[GET_ZKP](A1_YTPSEG, ZO_EMP, A1_EST, ZO_REPRE, '', '')) IN  	" + ENTER
		cSql += " (																							" + ENTER
		cSql += " '"+RetCodUsr()+"' 																		" + ENTER
		
		cAprovTemp := AprovTemp()
	If !(Empty(cAprovTemp))
			cSql += " ,"+cAprovTemp+" 																	" + ENTER
	EndIf
		cSql += "  )						                                                        		" + ENTER
		
		
EndIf
	
IF DTOC(CDATADE) <> "  /  /  " .AND. DTOC(CDATAATE) <> "  /  /  "
		cSql += "		AND ZO_DATA BETWEEN '"+DTOS(CDATADE)+"' AND '"+DTOS(CDATAATE)+"'  " + ENTER
END IF

	cSql +=  "		AND SZO.D_E_L_E_T_ = ''   "	+ ENTER

	// EXECUTANDO O TOTALIZADOR POR FILTRO
	C_cSql := "SELECT SUM(ZO_VALOR) AS TOT_FILTRO " + ENTER
	C_cSql += "FROM "+RETSQLNAME("SZO")+" SZO, "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("SA3")+" SA3 " + ENTER
	C_cSql += "WHERE	SZO.ZO_FILIAL = '01' AND " + ENTER
	C_cSql += "		SA1.A1_COD  = SZO.ZO_CLIENTE AND  " + ENTER
	C_cSql += "		SA1.A1_LOJA = SZO.ZO_LOJA	 AND  " + ENTER
	C_cSql += "		SA3.A3_COD  = SZO.ZO_REPRE AND " + ENTER
	C_cSql += "		SZO.ZO_YCOD <> '' AND " + ENTER
	C_cSql += "		SZO.ZO_SI  <> '' AND " + ENTER
IF ! EMPTY(CREPATU)
		C_cSql += "		SZO.ZO_REPRE =  '"+ALLTRIM(CCODUSUARIO)+"' AND " + ENTER
END IF

	/*If ( _lDir )
		C_cSql += "		SZO.ZO_STATUS = 'Aguard. Aprov. Dir.' AND " + ENTER
EndIf
	*/

If (cTipoAprov == '1')
	C_cSql += "		SZO.ZO_STATUS = 'Aguard. Aprov. Dir.' AND " + ENTER
ElseIf (cTipoAprov == '2')
	C_cSql += "		SZO.ZO_STATUS = 'Aguard. Aprov. Sup.' AND " + ENTER
ElseIf (cTipoAprov == '3')
	C_cSql += "		(SZO.ZO_STATUS = 'Aguard. Aprova��o' OR SZO.ZO_STATUS = 'Aguard. Aprov. Ger.') AND " + ENTER

	C_cSql += "  (SELECT UGERENT from [dbo].[GET_ZKP] (A1_YTPSEG, ZO_EMP, A1_EST, ZO_REPRE, '', '')) IN  	" + ENTER
	C_cSql += " (																						" + ENTER
	C_cSql += " '"+RetCodUsr()+"' 																		" + ENTER

	cAprovTemp := AprovTemp()
	If !(Empty(cAprovTemp))
		C_cSql += " ,"+cAprovTemp+" 																	" + ENTER
	EndIf
	C_cSql += "  )	AND					                                                        		" + ENTER



EndIf

C_cSql += "	 	SZO.D_E_L_E_T_ = '' AND " + ENTER
C_cSql += "		SA1.D_E_L_E_T_ = '' AND " + ENTER
C_cSql += "		SA3.D_E_L_E_T_ = ''  " + ENTER
IF DTOC(CDATADE) <> "  /  /  " .AND. DTOC(CDATAATE) <> "  /  /  "
	C_cSql += "		AND ZO_DATA BETWEEN '"+DTOS(CDATADE)+"' AND '"+DTOS(CDATAATE)+"'  " + ENTER
END IF

IF CHKFILE("_TOT_FILTRO")
	DBSELECTAREA("_TOT_FILTRO")
	DBCLOSEAREA()
ENDIF
TCQUERY C_cSql ALIAS "_TOT_FILTRO" NEW
S_TOT_FILTRO := _TOT_FILTRO->TOT_FILTRO

Return


//FILTRANDO DE ACORDO COM OS FILTROS
Static Function SQL_FILTRO()

	Local cAprovTemp := ""

	cSql := "SELECT	CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBSAPR)) AS AAOBS_APR, CONVERT(VARCHAR(500),CONVERT(BINARY(500),ZO_YOBS)) AS AAOBS, SZO.R_E_C_N_O_ AS ARECNO "+ENTER
	cSql += " , ZO_YCOD, ZO_SI, ZO_STATUS, ZO_DATA, ZO_SERIE, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_EST, A3_COD, A3_NOME, ZO_ITEMCTA, ZO_VALOR, ZO_YCOMPRO, ZO_EMP,  ISNULL((ACY_GRPVEN +' - '+  ACY_DESCRI), '-' ) AS ACY_DESCRI, " + ENTER

	cSql += "		PAGAMENTO = CASE	WHEN ZO_FPAGTO = '1' THEN 'Bonificacao' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '2' THEN 'Desconto Pedido' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '3' THEN 'Pagamento R$' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '5' THEN 'Outros' " + ENTER
	cSql += "							WHEN ZO_FPAGTO = '6' THEN 'Desc.Incondicional' " + ENTER
	cSql += "							ELSE '' END " + ENTER

	cSql+= " FROM "+RETSQLNAME("SZO")+ " SZO "+ ENTER
	cSql+= " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SZO.ZO_FILIAL	= '01'	AND SA1.A1_COD		= SZO.ZO_CLIENTE AND SA1.A1_LOJA = SZO.ZO_LOJA AND SA1.D_E_L_E_T_ = '' "+ ENTER
	cSql+= " INNER JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD		= SZO.ZO_REPRE	AND SA3.D_E_L_E_T_	= '' "+ ENTER
	cSql+= " LEFT  JOIN ACY010 ACY ON ACY.ACY_GRPVEN	= A1_GRPVEN		AND ACY.D_E_L_E_T_	= '' "+ ENTER
	cSql+= " WHERE	SZO.ZO_YCOD <> '' "	+ ENTER
	IF ! EMPTY(CREPATU)
		cSql += " AND SZO.ZO_REPRE =  '"+ALLTRIM(CCODUSUARIO)+"' " + ENTER
		cSql+= " AND SZO.ZO_SI   <> '' "	+ ENTER
		cSql+= " AND SZO.D_E_L_E_T_ = ''   "	+ ENTER
	EndIf
	IF DTOC(CDATADE) <> "  /  /  " .AND. DTOC(CDATAATE) <> "  /  /  "
		cSql += "		AND ZO_DATA BETWEEN '"+DTOS(CDATADE)+"' AND '"+DTOS(CDATAATE)+"'  " + ENTER
	END IF

	IF CPAGAMENTO <> "TODOS"
		IF CPAGAMENTO = "BONIFICACAO"
			CSQL += "		AND ZO_FPAGTO = '1'  " + ENTER
		ELSEIF CPAGAMENTO = "DESCONTO PEDIDO"
			CSQL += "		AND ZO_FPAGTO = '2'  " + ENTER
		ELSEIF CPAGAMENTO = "PAGAMENTO R$"
			CSQL += "		AND ZO_FPAGTO = '3'  " + ENTER
		ELSEIF CPAGAMENTO = "DESC.INCONDICIONAL"
			CSQL += "		AND ZO_FPAGTO = '6'  " + ENTER
		ELSE
			CSQL += "		AND ZO_FPAGTO = '5'  " + ENTER
		END IF
	END IF

	IF NRADIO <> 8
		IF NRADIO = 1
			cSql += "		AND ZO_STATUS = 'Aguard. Aprov. Dir.' " + ENTER
		ELSEIF NRADIO = 2
			cSql += "		AND ZO_STATUS = 'Aguard. Aprov. Sup.' " + ENTER
		ELSEIF NRADIO = 3
			cSql += "		AND (ZO_STATUS = 'Aguard. Aprova��o' OR ZO_STATUS = 'Aguard. Aprov. Ger.') " + ENTER
		ELSEIF NRADIO = 4
			cSql += "		AND ZO_STATUS = 'Aprovado'	 " + ENTER
		ELSEIF NRADIO = 5
			cSql += "		AND ZO_STATUS = 'Reprovado'	 " + ENTER
		ELSEIF NRADIO = 6
			cSql += "		AND ZO_STATUS = 'Baixa Total'	 " + ENTER
		ELSEIF NRADIO = 7
			cSql += "		AND ZO_STATUS = 'Baixa Parcial' " + ENTER
		END IF
	END IF

	If (cTipoAprov == '3')

		cSql += " AND (SELECT UGERENT from [dbo].[GET_ZKP] (A1_YTPSEG, ZO_EMP, A1_EST, ZO_REPRE, '', '')) IN  	" + ENTER
		cSql += " (																							" + ENTER
		cSql += " '"+RetCodUsr()+"' 																		" + ENTER

		cAprovTemp := AprovTemp()
		If !(Empty(cAprovTemp))
			cSql += " ,"+cAprovTemp+" 																	" + ENTER
		EndIf
		cSql += "  )						                                                        		" + ENTER


	EndIf

	If !Empty(cGetCli)
		CSQL += "		AND ZO_CLIENTE = '"+cGetCli+"'  " + ENTER
	EndIf

	If !Empty(cGetGrpCli)
		CSQL += "		AND A1_GRPVEN = '"+cGetGrpCli+"'  " + ENTER
	EndIf

	IF CMARCA <> "TODAS"
		IF CMARCA == "BIANCOGRES"
			CSQL += "		AND ZO_EMP = '0101'  " + ENTER
		ELSEIF CMARCA == "PEGASUS"
			CSQL += "		AND ZO_EMP = '0199'  " + ENTER
		ELSEIF CMARCA == "INCESA"
			CSQL += "		AND ZO_EMP = '0501'  " + ENTER
		ELSEIF CMARCA == "BELLACASA"
			CSQL += "		AND ZO_EMP = '0599'  " + ENTER
		ELSEIF CMARCA == "VINILICO"
			CSQL += "		AND ZO_EMP = '1302'  " + ENTER
		ENDIF
	ENDIF

	aItem 		:= StrTokArr(CITEM_CONT,"-")
	cAuxItem 	:= aItem[1]

	//ITEM CONTABIL
	IF CITEM_CONT <> "TODOS"
		cSql += "		AND ZO_ITEMCTA = '"+cAuxItem+"' " + ENTER
	ENDIF

	cSql +=  "		AND SZO.D_E_L_E_T_ = ''   "	+ ENTER

	// EXECUTANDO O TAL POR FILTRO
	C_cSql := "SELECT SUM(ZO_VALOR) AS TOT_FILTRO " + ENTER
	C_cSql += "FROM "+RETSQLNAME("SZO")+" SZO, "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("SA3")+" SA3 " + ENTER
	C_cSql += "WHERE	SZO.ZO_FILIAL = '01' AND " + ENTER
	C_cSql += "		SA1.A1_COD  = SZO.ZO_CLIENTE AND  " + ENTER
	C_cSql += "		SA1.A1_LOJA = SZO.ZO_LOJA AND  " + ENTER
	C_cSql += "		SA3.A3_COD  = SZO.ZO_REPRE AND " + ENTER
	C_cSql += "		SZO.ZO_YCOD <> '' AND " + ENTER
	C_cSql += "		SZO.ZO_SI   <> '' AND " + ENTER
	IF ! EMPTY(CREPATU)
		C_cSql += "		SZO.ZO_REPRE =  '"+ALLTRIM(CCODUSUARIO)+"' AND " + ENTER
	END IF
	C_cSql += "		SZO.D_E_L_E_T_ = '' AND " + ENTER
	C_cSql += "		SA1.D_E_L_E_T_ = '' AND " + ENTER
	C_cSql += "		SA3.D_E_L_E_T_ = ''  " + ENTER
	IF DTOC(CDATADE) <> "  /  /  " .AND. DTOC(CDATAATE) <> "  /  /  "
		C_cSql += "		AND ZO_DATA BETWEEN '"+DTOS(CDATADE)+"' AND '"+DTOS(CDATAATE)+"'  " + ENTER
	END IF
	IF CPAGAMENTO <> "TODOS"
		IF CPAGAMENTO = "BONIFICACAO"
			C_CSQL += "		AND ZO_FPAGTO = '1'  " + ENTER
		ELSEIF CPAGAMENTO = "DESCONTO PEDIDO"
			C_CSQL += "		AND ZO_FPAGTO = '2'  " + ENTER
		ELSEIF CPAGAMENTO = "PAGAMENTO R$"
			C_CSQL += "		AND ZO_FPAGTO = '3'  " + ENTER
		ELSEIF CPAGAMENTO = "DESC.INCONDICIONAL"
			C_CSQL += "		AND ZO_FPAGTO = '6'  " + ENTER
		ELSE
			C_CSQL += "		AND ZO_FPAGTO = '5'  " + ENTER
		END IF
	END IF

	IF NRADIO <> 8
		IF NRADIO = 1
			C_cSql += "		AND ZO_STATUS = 'Aguard. Aprov. Dir.' " + ENTER
		ELSEIF NRADIO = 2
			C_cSql += "		AND ZO_STATUS = 'Aguard. Aprov. Sup.' " + ENTER
		ELSEIF NRADIO = 3
			C_cSql += "		AND (ZO_STATUS = 'Aguard. Aprova��o' OR ZO_STATUS = 'Aguard. Aprov. Ger.') " + ENTER
		ELSEIF NRADIO = 4
			C_cSql += "		AND ZO_STATUS = 'Aprovado'	 " + ENTER
		ELSEIF NRADIO = 5
			C_cSql += "		AND ZO_STATUS = 'Reprovado'	 " + ENTER
		ELSEIF NRADIO = 6
			C_cSql += "		AND ZO_STATUS = 'Baixa Total'	 " + ENTER
		ELSEIF NRADIO = 7
			C_cSql += "		AND ZO_STATUS = 'Baixa Parcial' " + ENTER
		END IF
	ENDIF

	If (cTipoAprov == '3')

		C_cSql += " AND (SELECT UGERENT from [dbo].[GET_ZKP](A1_YTPSEG, ZO_EMP, A1_EST, ZO_REPRE, '', '')) IN  	" + ENTER
		C_cSql += " (																						" + ENTER
		C_cSql += " '"+RetCodUsr()+"' 																		" + ENTER

		cAprovTemp := AprovTemp()
		If !(Empty(cAprovTemp))
			C_cSql += " ,"+cAprovTemp+" 																	" + ENTER
		EndIf
		C_cSql += "  )						                                                        		" + ENTER


	EndIf


	IF !Empty(cGetCli)
		C_cSql += "		AND ZO_CLIENTE = '"+cGetCli+"'  " + ENTER
	ENDIF

	IF !Empty(cGetGrpCli)
		CSQL += "		AND A1_GRPVEN = '"+cGetGrpCli+"'  " + ENTER
	ENDIF

	IF CMARCA <> "TODAS"
		IF CMARCA == "BIANCOGRES"
			C_cSql += "		AND ZO_EMP = '0101'  " + ENTER
		ELSEIF CMARCA == "PEGASUS"
			C_cSql += "		AND ZO_EMP = '0199'  " + ENTER
		ELSEIF CMARCA == "INCESA"
			C_cSql += "		AND ZO_EMP = '0501'  " + ENTER
		ELSEIF CMARCA == "BELLACASA"
			C_cSql += "		AND ZO_EMP = '0599'  " + ENTER
		ELSEIF CMARCA == "VINILICO"
			C_cSql += "		AND ZO_EMP = '1302'  " + ENTER
		ENDIF
	ENDIF

	IF CHKFILE("_TOT_FILTRO")
		DBSELECTAREA("_TOT_FILTRO")
		DBCLOSEAREA()
	ENDIF

	conout(cSql)
	conout(C_cSql)

	TCQUERY C_cSql ALIAS "_TOT_FILTRO" NEW
	S_TOT_FILTRO := _TOT_FILTRO->TOT_FILTRO

	ATUALIZA_TELA(.T.)
Return


//ENVIA EMAIL QUANDO APROVADO A SOLICITACAO  
STATIC FUNCTION EMAIL_APROVADO()

	PRIVATE CHTML := ""
	PRIVATE TOT_PEDCOMPRA := 0


	cNClient 	:= (cAliasTrab)->COD_CLI
	cNLjCli		:= (cAliasTrab)->LOJ_CLI
	cNClient1	:= POSICIONE("SA1",1,XFILIAL("SA1")+cNClient+cNLjCli,"A1_NOME")

	CHTML := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	CHTML += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	CHTML += ' <head> '
	CHTML += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	CHTML += ' <title>Untitled Document</title> '
	CHTML += ' <style type="text/css"> '
	CHTML += ' <!-- '
	CHTML += ' .style12 {font-size: 9px; } '
	CHTML += ' .style18 {font-size: 10} '
	CHTML += ' .style35 {font-size: 10pt; } '
	CHTML += ' .style36 {font-size: 9pt; } '
	CHTML += ' .style41 { '
	CHTML += ' 	font-size: 12px; '
	CHTML += ' 	font-weight: bold;V
	CHTML += ' } '
	CHTML += ' .style43 {font-size: 10pt; font-weight: bold; color: #FFFFFF; } '
	CHTML += '  '
	CHTML += ' --> '
	CHTML += ' </style> '
	CHTML += ' </head> '
	CHTML += '  '
	CHTML += ' <body> '
	CHTML += ' <table width="674" border="1"> '
	CHTML += '   <tr> '
	CHTML += '     <th width="450" rowspan="3" scope="col">SOLICITA��O DE INVESTIMENTO APROVADA </th> '
	CHTML += '     <td width="229" class="style12"><div align="right"> DATA EMISS�O: '+ dtoC(DDATABASE) +' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td class="style12"><div align="right">HORA DA EMISS�O: '+SUBS(TIME(),1,8)+' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	IF CEMPANT = "05"
		CHTML += '    <td><div align="center" class="style41"> INCESA CERAMICA LTDA </div></td> '
	ELSE
		CHTML += '    <td><div align="center" class="style41"> BIANCOGRES CER�MICA SA </div></td> '
	END IF
	CHTML += '   </tr> '
	CHTML += ' </table> '
	CHTML += '  '
	CHTML += ' <table width="675" border="1"> '
	CHTML += '    '
	CHTML += '   <tr bordercolor="#FFFFFF"> '
	CHTML += '     <td>&nbsp;</td> '
	CHTML += '     <td>&nbsp;</td> '
	CHTML += '   </tr> '
	CHTML += '  '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43">C�digo Investimento:</span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left"> '+(cAliasTrab)->CCODIGO+' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Cliente: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left">' + cNClient + ' - ' + cNClient1 + ' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Representante: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left"> ' + (cAliasTrab)->COD_REP + ' - ' + (cAliasTrab)->REPRE + ' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Item Cont�bil: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left">'+(cAliasTrab)->IT_CONT+' </div></td> '

	CHTML += '   </tr> '


	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Valor: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left"> ' + (cAliasTrab)->VALOR + ' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Data Emiss�o: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left"> ' + DTOC((cAliasTrab)->DATA_INV) + ' </div></td> '
	CHTML += '   </tr> '
	CHTML += '   <tr> '
	CHTML += '     <td width="145" bgcolor="#0066CC" class="style18"><span class="style43"> Observa��o: </span></td> '
	CHTML += '     <td width="514" class="style35"> <div align="left"> ' + (cAliasTrab)->AAOBS + ' </div></td> '
	CHTML += '   </tr> '


	CHTML += '   <tr bordercolor="#FFFFFF" class="style18"> '
	CHTML += '     <td class="style36">&nbsp;</td> '
	CHTML += '     <td class="style36">&nbsp;</td> '
	CHTML += '   </tr> '
	CHTML += ' </table> '
	CHTML += ' Esta � uma mensagem autom�tica, favor n�o responde-la. '
	CHTML += ' </body> '
	CHTML += ' </html> '

	DbSelectArea("SA3")
	DbSetOrder(1)
	IF Dbseek(XfILIAL("SA3")+(cAliasTrab)->COD_REP)
		cEmail := ALLTRIM(SA3->A3_EMAIL)
	ENDIF

	cRecebe		:= U_EmailWF("SOL_INVEST",AllTrim(cEmpAnt))+";"+cEmail
	cRecebeCC	:= ""


	cAssunto	:= "INVESTIMENTO LIBERADO"

	U_BIAEnvMail(,cRecebe,cAssunto,CHTML)

return


//LANCAR AS BAIXAS DO INVESTIMENTO 
User Function LAN_BAIXAS()
	Local aButtons := {}
	Local oSay1

	Private oDlgBaixas
	Private oPGDBxs
	Private oGDBaixas
	Private aFieldsB
	Private aAlterFB
	Private aHeaderExB

	Private bSalTemp := {|| SalInvTmp() }

	//Nome padrao para imagens anexas para baixa de investimento
	Private bCodNome := {|| "BXI"+AllTrim((cAliasTrab)->CCODIGO)+AllTrim(oGDBaixas:ACols[oGDBaixas:oBrowse:nAT][1]) }

	//BOTOES DO ENCHOICEBAR
	aAdd(aButtons,{"NOVACELULA"	,{|| BxsIncDoc() }	,"Anexar Doc"})
	aAdd(aButtons,{"VERNOTA"	,{|| BxsVisDoc() }	,"Visual Doc"})


	DEFINE MSDIALOG oDlgBaixas TITLE "BAIXAS DE INVESTIMENTO" FROM 000, 000  TO 300, 700 PIXEL

	@ 025, 000 MSPANEL oPGDBxs SIZE 300, 125 OF oDlgBaixas COLORS 0, 16777215 RAISED
	fGDBaixas()

	OSAY1:= TSAY():NEW(014,000,{|| REPLICATE(" ",10) + "CONSULTA E LAN�AMENTO DE BAIXAS DO INVESTIMENTO " },oDlgBaixas,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_BLUE,77,08)
	OSAY1:LTRANSPARENT := .F.
	OSAY1:LWORDWRAP := .T.

	OSAY2:= TSAY():NEW(014,000,{|| REPLICATE(" ",10) + "SALDO: R$ "+Transform(Eval(bSalTemp),"@E 999,999,999,999.99") },/*oDlgBaixas*/oPGDBxs,,OBOLD_10,,,,.T.,CLR_WHITE,CLR_BLUE,77,08)
	OSAY2:LTRANSPARENT := .F.
	OSAY2:LWORDWRAP := .T.

	// Don't change the Align Order
	OSAY1:Align := CONTROL_ALIGN_TOP
	OSAY2:Align := CONTROL_ALIGN_BOTTOM
	oPGDBxs:Align := CONTROL_ALIGN_ALLCLIENT
	oGDBaixas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//eventos para atualizar o saldo no rodape automatico
	oGDBaixas:bChange := {|| OSAY2:Refresh() }
	oGDBaixas:oBrowse:bSetGet    := {||	 IIF((oGDBaixas:obrowse:nColPos == 6)  .And. (oGDBaixas:nAt > 0) .And. (oGDBaixas:nAt <= Len(oGDBaixas:aCols)), OSAY2:Refresh(),) }
	OSAY2:Refresh()

	ACTIVATE MSDIALOG oDlgBaixas CENTERED ON INIT (EnchoiceBar(oDlgBaixas, {|| IIF(BxsSave(), oDlgBaixas:End(),) }, {|| oDlgBaixas:End()},,aButtons))

Return


Static Function fGDBaixas()

	Local nX
	Local aColsEx := {}
	Local aFieldFill := {}

	aFieldsB := {"ZZQ_ITEM","ZZQ_FORNEC","ZZQ_LOJA","ZZQ_DOC","ZZQ_DATA","ZZQ_VALOR","ZZQ_ITFORN","ZZQ_SN"}
	aAlterFB := {"ZZQ_FORNEC","ZZQ_LOJA","ZZQ_DOC","ZZQ_DATA","ZZQ_VALOR","ZZQ_ITFORN"}
	aHeaderExB := {}

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFieldsB)
		If aFieldsB[nX] == "ZZQ_SN"
			Aadd(aHeaderExB, {"Anexo","ZZQ_SN","@!",1,0,,,"C",,"V","S=Sim;N=Nao","N"})
		EndIf
		If SX3->(DbSeek(aFieldsB[nX]))
			Aadd(aHeaderExB, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	//Procurando baixas do investimento selecionado
	ZZQ->(DbSetOrder(1))
	IF ZZQ->(DbSeek(XFILIAL("ZZQ")+(cAliasTrab)->CCODIGO))
		While .Not. ZZQ->(Eof()) .And. ZZQ->(ZZQ_FILIAL+ZZQ_COD) == (XFILIAL("ZZQ")+(cAliasTrab)->CCODIGO)
			aFieldFill := {}
			For nX := 1 to Len(aFieldsB)
				If SX3->(DbSeek(aFieldsB[nX]))
					Aadd(aFieldFill, &("ZZQ->"+AllTrim(SX3->X3_CAMPO)))
				EndIf
				If aFieldsB[nX] == "ZZQ_SN"
					Aadd(aFieldFill, IIF(!EMPTY(ZZQ->ZZQ_BITMAP),"S","N") )
				EndIf
			Next nX
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)

			ZZQ->(DbSkip())
		EndDo
	ELSE
		aFieldFill := {}
		For nX := 1 to Len(aFieldsB)
			If DbSeek(aFieldsB[nX])
				IF AllTrim(SX3->X3_CAMPO) == "ZZQ_ITEM"
					Aadd(aFieldFill, StrZero(1,TamSX3("ZZQ_ITEM")[1]))
				ELSE
					Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
				ENDIF
			Endif
			If aFieldsB[nX] == "ZZQ_SN"
				Aadd(aFieldFill, "N" )
			EndIf
		Next nX

		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	ENDIF

	oGDBaixas := MsNewGetDados():New( 000, 000, 124, 299, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+ZZQ_ITEM", aAlterFB,, 999, "AllwaysTrue", "", "AllwaysTrue", oPGDBxs, aHeaderExB, aColsEx)

Return


//CALCULA O SALDO DINAMICAMENTE NA DIGITACAO DAS LINHAS
Static Function SalInvTmp()
	Local _aCols := AClone(oGDBaixas:ACols)
	Local I
	Local _nTotLan := 0

	FOR I := 1 TO LEN(_aCols)
		IF _aCols[I][Len(_aCols[I])]
			loop
		ENDIF
		_nTotLan += _aCols[I][6]
	NEXT I
Return(SZO->ZO_VALOR - _nTotLan)


//SALVAR AS BAIXAS LANCADAS
Static Function BxsSave()
	Local _aCols := AClone(oGDBaixas:ACols)
	Local I,J
	Local _nTotBx := 0

	//VALIDAR DADOS PARA GRAVAR BAIXAS
	//Valor total das baixas nao pode ser maior que o investimento
	FOR I := 1 TO LEN(_aCols)
		IF _aCols[I][Len(_aCols[I])]
			loop
		ENDIF
		_nTotBx += _aCols[I][6]
	NEXT I
	IF _nTotBx > SZO->ZO_VALOR
		MsgBox("VALOR LAN�ADO DE BAIXAS MAIOR QUE O INVESTIMENTO","BAIXAS DO INVESTIMENTO","STOP")
		Return(.F.)
	ENDIF


	FOR I := 1 TO LEN(_aCols)
		//DELETAR LINHAS MARCADAS
		IF _aCols[I][Len(_aCols[I])]

			ZZQ->(DbSetOrder(1))
			IF ZZQ->(DbSeek(XFilial("ZZQ")+(cAliasTrab)->CCODIGO+_aCols[I][1]))
				RecLock("ZZQ",.F.)
				ZZQ->(DbDelete())
				ZZQ->(MsUnlock())
			ENDIF

			//Tenta deletar a imagem correspondente a linha do repositorio
			U_RIMGDEL("BXI"+AllTrim((cAliasTrab)->CCODIGO)+AllTrim(_aCols[I][1]))

			loop
		ENDIF

		ZZQ->(DbSetOrder(1))
		IF ZZQ->(DbSeek(XFilial("ZZQ")+(cAliasTrab)->CCODIGO+_aCols[I][1]))
			RecLock("ZZQ",.F.)
		ELSE
			RecLock("ZZQ",.T.)
			ZZQ->ZZQ_FILIAL	:= XFILIAL("ZZQ")
			ZZQ->ZZQ_COD 		:= (cAliasTrab)->CCODIGO
		ENDIF
		For J := 1 To Len(aFieldsB)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aFieldsB[J]))
				&("ZZQ->"+aFieldsB[J]) := _aCols[I][J]
			EndIf
		Next J

		IF _aCols[I][8] == "S"
			ZZQ->ZZQ_BITMAP := "BXI"+AllTrim(ZZQ->ZZQ_COD)+AllTrim(ZZQ->ZZQ_ITEM)
		ENDIF

		ZZQ->(MsUnlock())

	NEXT I

Return(.T.)

//FUNCOES GERAIS BAIXA DE INVESTIMENTO
//Calcular Saldo do Investimento
Static Function SalInvest()
	Local _nSal := SZO->ZO_VALOR

	ZZQ->(DbSetOrder(1))
	IF ZZQ->(DbSeek(XFilial("ZZQ")+(cAliasTrab)->CCODIGO))
		While .NOT. ZZQ->(Eof()) .And. ZZQ->(ZZQ_FILIAL+ZZQ_COD) == (XFilial("ZZQ")+(cAliasTrab)->CCODIGO)

			_nSal -= ZZQ->ZZQ_VALOR

			ZZQ->(DbSkip())
		EndDo
	ENDIF

Return(_nSal)


//ANEXAR DOCUMENTO NA BAIXA
Static Function BxsIncDoc()

	Local cPathFile := AllTrim(cGetFile("Imagens JPG|*.JPG|Imagens BMP|*.BMP","SELECIONE A IMAGEM A SER IMPORTADA ( < 900Kb )",,,.T.,,))
	Local cCodNome,cCodRet := ""

	//Nome padrao para imagens anexas para baixa de investimento
	cCodNome := Eval(bCodNome)

	//Executar funcao para inserir imagem no repositorio do protheus
	U_RIMGINC(cPathFile, cCodNome, .T., @cCodRet, "J� existe documento anexado para esta baixa de investimento.")

	//Gravar codigo da imagem gerada no arquivo
	IF !Empty(cCodRet)
		oGDBaixas:ACols[oGDBaixas:oBrowse:nAT][8] := "S"
		oGDBaixas:oBrowse:Refresh()
	ENDIF

Return

//VISUALIZAR DOCUMENTO DA BAIXA
Static Function BxsVisDoc()
	Local cCodNome

	cCodNome := Eval(bCodNome)

	U_RIMGVIEW(cCodNome,"N�o existe anexo para esta baixa!")

Return

Static Function INF_CALC(sCliente, sLoja)
	Local Enter := CHR(13) + CHR(10)
	Local sTexto
	Local sGrupo
	Local sReceita
	Local sInvest
	Local sPercInv

	If SUBS(CITEM_CONT,1,5) != "I0103"
		MsgBox("ITEM CONT�BIL PRECISA SER I0103","INFORMA��ES SHOWROOM","STOP")
		Return
	EndIf

	CSQL := "SELECT (CASE WHEN A1_YREDCOM <> '' THEN 'R-'+A1_YREDCOM WHEN A1_YREDCOM = '' AND A1_GRPVEN <> '' THEN 'G-'+A1_GRPVEN ELSE 'C-'+A1_COD END) AS GRUPO "
	CSQL += "FROM " + RETSQLNAME("SA1") + " WITH(NOLOCK) WHERE A1_FILIAL = '' AND A1_MSBLQL <> 1 AND A1_COD = '" + sCliente + "' AND A1_LOJA = '" + sLoja + "' AND D_E_L_E_T_ = ''"

	IF CHKFILE("_GRUPO")
		DBSELECTAREA("_GRUPO")
		DBCLOSEAREA()
	ENDIF

	TCQUERY CSQL ALIAS "_GRUPO" NEW

	sGrupo := _GRUPO->GRUPO

	CSQL2 := "SELECT MARCA, GRUPO, RECEITA, INVESTIMENTO AS INVEST, [% INVESTIDO] AS PERC_INV, AINVESTIR FROM VW_BZ_RECEITA_INVEST WHERE GRUPO = '" + sGrupo + "'"

	IF CHKFILE("_INV")
		DBSELECTAREA("_INV")
		DBCLOSEAREA()
	ENDIF

	TCQUERY CSQL2 ALIAS "_INV" NEW

	sReceita := Transform(_INV->RECEITA, "@E 999,999,999.99")
	sInvest := Transform(_INV->INVEST, "@E 999,999,999.99")
	sPercInv := Transform(_INV->PERC_INV, "@E 999,999,999.99")

	sTexto := Enter
	sTexto += "Faturamento do Cliente: R$" + sReceita + Enter
	sTexto += "Valor Investido: R$" + sInvest + Enter
	sTexto += "% Investido: " + sPercInv + "%" + Enter
	sTexto += "(valores referentes aos ultimos 12 meses em Exibitecnica)" + Enter

	cNOBS += sTexto
Return


Static Function HistAprov()

	Local cHistAprov := ""

	DbSelectArea("SZO")
	SZO->(DbSetOrder(4))

	If SZO->(DbSeek(xFilial("SZO")+(cAliasTrab)->CCODIGO, .T.))
		cHistAprov := SZO->ZO_HISTAPR
	EndIf

	DEFINE MSDIALOG oDlgHist FROM 0,0 TO 200, 400 TITLE ":::::: HISTORICO DOS APROVADORES ::::::" PIXEL

	@ 010,06 SAY "Aprovadores "
	@ 018,06 GET cHistAprov    SIZE 190,60 MEMO WHEN .F.

	@ 082,125 BUTTON "FECHAR" SIZE 70,14 OF oDlgHist PIXEL ACTION CLOSE(oDlgHist)

	ACTIVATE MSDIALOG oDlgHist CENTERED ON INIT Eval( {|| } )

Return


Static Function AtuHistAprov(_cTipo, _cStatus, _cStatusAnt, _cObs)

	Local cMsg		:= ""
	Default  _cObs 	:= ""

	RecLock("SZO",.F.)
	cMsg := "[Tipo: "+_cTipo+", Aprovador: "+CUSERNAME+", Data: "+dToc(dDataBase)+", Hora: "+SubStr(Time(), 1, 5)+", Status Anterior: "+_cStatusAnt+", Status Atual: "+_cStatus+", Observa��o: "+_cObs+"]"+ENTER
	SZO->ZO_HISTAPR	:= SZO->ZO_HISTAPR+cMsg
	SZO->(MsUnLock())

Return

Static Function AprovSuper()

	Local cObsAprov 	:= ""
	Local _cProxStatus	:= ""
	Local _cStatusAnt	:= ""
	Local _cStatus		:= ""
	Local _cAcao		:= ""

	DEFINE MSDIALOG oDlgASup FROM 0,0 TO 200, 400 TITLE ":::::: APROVA��O DO SUPERINTENDENTE ::::::" PIXEL

	@ 010,06 SAY "Observa��o "
	@ 018,06 GET cObsAprov    SIZE 190,60 MEMO WHEN .T.

	@ 082, 006 BUTTON "REPROVAR" SIZE 70,14 OF oDlgASup PIXEL ACTION {|| _cStatus := 'Reprovado', CLOSE(oDlgASup)}
	@ 082, 125 BUTTON "APROVAR" SIZE 70,14 OF oDlgASup PIXEL ACTION {|| _cStatus := 'Aprovado', CLOSE(oDlgASup)}

	ACTIVATE MSDIALOG oDlgASup CENTERED ON INIT Eval( {|| } )

	If (_cStatus == 'Reprovado' .Or. _cStatus == 'Aprovado')

		DbSelectArea("SZO")
		SZO->(DbSetOrder(4))

		If SZO->(DbSeek(xFilial("SZO")+(cAliasTrab)->CCODIGO))

			If (AllTrim(_cStatus) <> 'Reprovado')
				_cProxStatus := ProxSequeAprov(SZO->ZO_STATUS)
				If (!Empty(_cProxStatus))
					_cStatus := _cProxStatus
				EndIf
			EndIf

			_cStatusAnt := SZO->ZO_STATUS

			RecLock("SZO",.F.)
			SZO->ZO_STATUS	:= _cStatus
			SZO->ZO_USUASUP	:= ALLTRIM(cNomeUsuario)
			SZO->ZO_DATASUP	:= dDataBase
			SZO->ZO_HORASUP	:= TIME()
			SZO->ZO_OBSSUP	:= cObsAprov
			SZO->(MsUnLock())

			AtuHistAprov('S',_cStatus, _cStatusAnt, cObsAprov)

			If AllTrim(_cStatus) == 'Aprovado'
				EMAIL_APROVADO()
			EndIf

		EndIf

		CLOSE(oDlg1)
		SQL_FILTRO()
	EndIf

Return


Static Function AprovDir(_cStatus)

	Local _cProxStatus	:= ""
	Local _cStatusAnt	:= ""

	DbSelectArea("SZO")
	SZO->(DbSetOrder(4))
	If SZO->(DbSeek(xFilial("SZO")+(cAliasTrab)->CCODIGO, .T.))

		If (AllTrim(_cStatus) <> 'Reprovado')
			_cProxStatus := ProxSequeAprov(SZO->ZO_STATUS)
			If (!Empty(_cProxStatus))
				_cStatus := _cProxStatus
			EndIf
		EndIf

		_cStatusAnt := SZO->ZO_STATUS

		RecLock("SZO",.F.)
		SZO->ZO_STATUS	:= _cStatus
		SZO->ZO_USUDIR	:= CUSERNAME
		SZO->ZO_DATADIR	:= dDataBase
		SZO->ZO_HORADIR	:= SubStr(Time(), 1, 5)
		SZO->(MsUnLock())

		AtuHistAprov('D', _cStatus, _cStatusAnt)

		If (AllTrim(_cStatus) == 'Aprovado')
			EMAIL_APROVADO()
		EndIf

	EndIf

	CLOSE(oDlg1)
	SQL_FILTRO()

Return


Static Function TipoAprov()

	Local nValorSI	:= cNVALOR
	Local nLimite1	:= GetNewPar("MV_YSIFAP1", 6999.99)
	Local nLimite2	:= GetNewPar("MV_YSIFAP2", 14999.99)
	Local cTipo		:= ""

	If (nValorSI <= nLimite1)
		cTipo := "3"
	ElseIf ((nValorSI > nLimite1 .And. nValorSI <= nLimite2))
		cTipo := "2"
	Else
		cTipo := "1"
	EndIf

Return cTipo


Static Function ProxSequeAprov(_cAprovAtual)

	Local _nValorSI	:= 0
	Local _nLimite1	:= GetNewPar("MV_YSIFAP1", 6999.99)
	Local _nLimite2	:= GetNewPar("MV_YSIFAP2", 14999.99)
	Local _cStatus	:= ""

	_nValorSI	:= STRTRAN((cAliasTrab)->VALOR, ",", "*")
	_nValorSI	:= STRTRAN(_nValorSI, ".", "")
	_nValorSI	:= STRTRAN(_nValorSI, "*", ".")
	_nValorSI 	:= VAL(_nValorSI)

	If (_nValorSI <= _nLimite1 .And. AllTrim(_cAprovAtual) == 'Aguard. Aprov. Ger.')
		_cStatus := ""
	ElseIf ((_nValorSI > _nLimite1 .And. _nValorSI <= _nLimite2))
		_cStatus := ""
		If (AllTrim(_cAprovAtual) == 'Aguard. Aprov. Ger.')
			_cStatus := 'Aguard. Aprov. Sup.'
		EndIf
	ElseIf (_nValorSI > _nLimite2)
		_cStatus := ""
		If (AllTrim(_cAprovAtual) == 'Aguard. Aprov. Ger.')
			_cStatus := 'Aguard. Aprov. Sup.'
		ElseIf (AllTrim(_cAprovAtual) == 'Aguard. Aprov. Sup.')
			_cStatus := 'Aguard. Aprov. Dir.'
		EndIf
	EndIf

Return _cStatus


Static Function UserAprov()

	Local cQuery	:= ""
	Local aArea		:= GetArea()
	Local cAliasTmp	:= GetNextAlias()
	Local cCodUser	:= ""
	Local cNomeUser	:= ""

	DbSelectArea("SZO")
	SZO->(DbSetOrder(4))

	If (SZO->(DbSeek(xFilial('SZO')+(cAliasTrab)->CCODIGO)))

		oGerenteAtendente	:= TGerenteAtendente():New()
		oResult 			:= oGerenteAtendente:GetCliente(SZO->ZO_EMP, SZO->ZO_CLIENTE, SZO->ZO_LOJA, SZO->ZO_REPRE)

		cQuery += "SELECT TOP 1 A3_CODUSR, A3_NREDUZ													"
		cQuery += "	FROM "+ RetSqlName("SA3")+" SA3		                                            	"
		cQuery += "	WHERE	SA3.A3_COD   = '"+oResult:cGerente+"'	                                	"
		cQuery += "	AND SA3.D_E_L_E_T_ = ''                                                         	"

		TcQuery cQuery New Alias (cAliasTmp)

		If !(cAliasTmp)->(Eof())
			cCodUser	:= (cAliasTmp)->A3_CODUSR
			cNomeUser	:= (cAliasTmp)->A3_NREDUZ
		EndIf

		(cAliasTmp)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return {cCodUser, cNomeUser}

Static Function UserGeren()

	Local cQuery	:= ""
	Local aArea		:= GetArea()
	Local cAliasTmp	:= GetNextAlias()
	Local lRet		:= .F.

	cQuery += "SELECT TOP 1 A3_CODUSR																"
	cQuery += "	FROM ZKP010 ZKP		     			                                            	"
	cQuery += "	INNER JOIN "+ RetSqlName("SA3")+" SA3 ON ZKP.ZKP_GERENT = SA3.A3_COD	        	"
	cQuery += "	WHERE A3_CODUSR   = '"+RetCodUsr()+"'	                	                		"
	cQuery += "	AND ZKP.D_E_L_E_T_ = ''								                            	"
	cQuery += "	AND SA3.D_E_L_E_T_ = ''                                                         	"

	TcQuery cQuery New Alias (cAliasTmp)

	If !(cAliasTmp)->(Eof())
		lRet	:= .T.
	EndIf

	(cAliasTmp)->(DbCloseArea())

	If (!lRet)
		If !(Empty(AprovTemp()))
			lRet	:= .T.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

Static Function AprovTemp()

	Local cQuery	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local cUserTmp	:= ""

	cQuery += "SELECT  ZKQ_APROV FROM "+ RetSqlName("ZKQ")+"															"
	cQuery += "			WHERE                                                                                           	"
	cQuery += "			ZKQ_STATUS		= 1		AND                                                                     	"
	cQuery += "			D_E_L_E_T_		= ''	AND                                                                     	"
	cQuery += "			CONVERT(date, GETDATE()) BETWEEN CONVERT(date, ZKQ_DTINI) AND CONVERT(date, ZKQ_DTFIM)          	"
	cQuery += "			AND ZKQ_APROVT = '"+RetCodUsr()+"'	                                                           		"

	TcQuery cQuery New Alias (cAliasTmp)

	While !(cAliasTmp)->(Eof())

		If !(Empty((cAliasTmp)->ZKQ_APROV))

			If (!Empty(cUserTmp))
				cUserTmp += ","
			EndIf

			cUserTmp += "'"+(cAliasTmp)->ZKQ_APROV+"'"

		EndIf

		(cAliasTmp)->(dbSkip())

	EndDo

	(cAliasTmp)->(DbCloseArea())

Return cUserTmp

Static Function TempValOper(_cFuncao)

	Local aArea			:= GetArea()
	Local cAcesso		:= ""
	Local lRet			:= .F.
	Local cAprovTemp	:= AprovTemp()
	Local nI			:= 0
	Local aUsuario		:= StrTokArr(cAprovTemp , ",")

	DbSelectArea('ZZ0')
	ZZ0->(DbSetOrder(1))

	If (ZZ0->(DbSeek(XFilial('ZZ0')+_cFuncao)))
		cAcesso := Alltrim(ZZ0->ZZ0_ACESSO)

		For nI:=1 To Len(aUsuario)
			If AllTrim(StrTran( aUsuario[nI], "'", "" )) $ &(cAcesso)[2]
				lRet := .T.
				Exit
			EndIf
		Next nI

	EndIf

	RestArea(aArea)

Return lRet
