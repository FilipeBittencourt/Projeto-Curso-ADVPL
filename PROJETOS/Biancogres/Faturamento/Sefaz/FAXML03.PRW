#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVSMAIL.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "TOPCONN.CH"

User Function FAXML03(_CFILEXML)

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Fernando Rocha
	Autor(Rev):= Marcos Alberto Soprani
	Programa  := FAXML03
	Empresa   := Biancogres Cerâmica S/A
	Data      := 14/11/11
	Data      := 21/03/12
	Uso       := Compras
	Aplicação := Importacao de XML - ExecAuto do Documento de Entrada
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local I,J
	Local aSize := MsAdvSize()
	Local LRET  := .F.
	Local _CEMP := CEMPANT+CFILANT

	Private  aButtons := {}
	Private oPanel1
	Private oPanel2
	Private oPanel3
	Private ARET
	Private oMSNewGe1
	Private oDlgNFE
	Private oFont1 := TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)

	Private _NFNUM := ""
	Private _NFSERIE := ""
	Private _NFEMIS := CTOD(" ")
	Private _CNFEMIS := ""
	Private _CCNPJFOR := ""
	Private _CCODFOR := ""
	Private _CLOJFOR := ""
	Private _CNOMEFOR := ""
	Private _FAXPED := Space(TamSx3("C7_NUM")[1])
	Private _CCHVNFE := Space(44)

	Private aColsEx := {}

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	//Carregar Dados da NF
	//ARET := U_FAXML01("0101", "001932-08882469000103.xml", .F.)
	ARET := U_FAXML01(_CEMP, _CFILEXML, .F.)

	IF ARET <> NIL

		ACAB := ARET[1]

		//Dados da NF
		_NFNUM 		:= ACAB[1]
		_NFSERIE 	:= ACAB[2]
		_NFEMIS 	:= ACAB[3]
		_CNFEMIS 	:= DTOC(_NFEMIS)

		//Buscando dados do Fornecedor
		_CCNPJFOR := ACAB[4]

		SA2->(DbSetOrder(3))
		IF SA2->(DbSeek(XFilial("SA2")+_CCNPJFOR))

			_CCODFOR  := SA2->A2_COD
			_CLOJFOR  := SA2->A2_LOJA
			_CNOMEFOR := SA2->A2_NOME

		ENDIF

		//Busca codigo do Pedido de Compra se houver
		_FAXPED := ACAB[5]

		//Preencher chave da NF-e para exibir na tela e gravar na nota
		_CCHVNFE := ACAB[6]

		APROD := ARET[2]

		For I := 1 To Len(APROD)

			AAux := {}
			AAdd(AAux,STRZERO(I,TamSx3("D1_ITEM")[1]))
			AAdd(AAux,APROD[I][1])
			AAdd(AAux,PADR(APROD[I][2],TamSx3("B1_COD")[1]))
			AAdd(AAux,APROD[I][3])
			AAdd(AAux,APROD[I][5])
			AAdd(AAux,APROD[I][6])
			AAdd(AAux,APROD[I][7])

			IF Empty(APROD[I][9]) .And. Empty(ACAB[5])
				AAdd(AAux,Space(TamSx3("C7_NUM")[1]))
				AAdd(AAux,Space(TamSx3("C7_ITEM")[1]))
			ELSE
				__cC7NUM := ""
				If !Empty(APROD[I][9])
					__cC7NUM := APROD[I][9]
				Else
					__cC7NUM := ACAB[5]
				EndIf

				__cC7IT := Space(TamSx3("C7_ITEM")[1])
				SC7->(DbSetOrder(2))
				IF SC7->(DbSeek(XFilial("SC7")+PADR(APROD[I][2],TamSx3("B1_COD")[1])+_CCODFOR+_CLOJFOR+__cC7NUM))
					__cC7IT := SC7->C7_ITEM
				ENDIF

				AAdd(AAux,__cC7NUM)
				AAdd(AAux,__cC7IT)
			ENDIF
			AAdd(AAux,APROD[I][10])

			AAdd(AAux,.F.)
			AAdd(AColsEx,AAux)

		Next I

	ENDIF

	DEFINE MSDIALOG oDlgNFE TITLE "IMPORTAÇÃO DE NOTA FISCAL ELETRÔNICA" FROM nLin*.000, nCol*.000  TO nLin*.800, nCol*.900 COLORS 0, 16777215 PIXEL

	@ 014, 000 MSPANEL oPanel1 SIZE 400, 236 OF oDlgNFE COLORS 0, 16777215 RAISED

	@ 000, 000 MSPANEL oPanel2 SIZE 399, 049 OF oPanel1 COLORS 0, 16777215 RAISED
	@ 007, 008 SAY oSay1 PROMPT "NOTA:" SIZE 026, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 038 MSGET oGetNFNUM VAR _NFNUM SIZE 060, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 006, 105 SAY oSay2 PROMPT "SÉRIE:" SIZE 026, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 134 MSGET oGetNFSERIE VAR _NFSERIE SIZE 021, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 006, 161 SAY oSay3 PROMPT "EMISSÃO:" SIZE 041, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 006, 204 MSGET oGetNFEMIS VAR _CNFEMIS SIZE 060, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 023, 008 SAY oSay4 PROMPT "FORNECEDOR:" SIZE 057, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 022, 068 MSGET oGetFORN VAR _CCODFOR SIZE 049, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 022, 121 MSGET oGetLOJA VAR _CLOJFOR SIZE 016, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 022, 142 SAY oSay5 PROMPT "NOME:" SIZE 027, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 022, 174 MSGET oGetNOME VAR _CNOMEFOR SIZE 200, 010 OF oPanel2 COLORS 0, 16777215 PIXEL WHEN(.F.)
	@ 035, 068 MSGET oGetCHVNFE VAR _CCHVNFE SIZE 307, 010 OF oPanel2 COLORS 0, 16777215 PIXEL
	@ 036, 008 SAY oSay6 PROMPT "CHAVE NF-e:" SIZE 057, 007 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL

	@ 041, 000 MSPANEL oPanel3 SIZE 399, 194 OF oPanel1 COLORS 0, 16777215 RAISED

	SetKey(VK_F9, {|| U_FAIMPPED()})

	fMSNewGe1()

	aAdd(aButtons,{"NOTE",{|| U_FAIMPPED() }, "Pedidos"})

	EnchoiceBar(oDlgNFE, {|| LRET := Salvar(), oDlgNFE:End() }, {|| oDlgNFE:End()},,aButtons)

	// Don't change the Align Order
	oPanel2:Align := CONTROL_ALIGN_TOP
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	oMSNewGe1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgNFE CENTERED

Return(LRET)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fMSNewGe1   ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Montagem do Grid dos Itens                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMSNewGe1()

	Local nX
	Local aHeaderEx := {}
	Local aFieldFill := {}
	Local aFields := {}
	Local aAlterFields := {"CODPRO","PEDIDO","ITEMPC"}

	//Carrega aHead
	aHeadEx := {}
	Aadd(aHeadEx,{"Item"         ,"ITEM"          ,"@!"                ,04,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Prod.Fornece" ,"CODFOR"        ,"@!"                ,20,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Prod.Interno" ,"CODPRO"        ,"@!"                ,15,0 ,"","€€€€€€€€€€€€€€ ","C","SB1","R","",""})
	Aadd(aHeadEx,{"Descricao"    ,"DESPRO"        ,"@!"                ,50,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Qtde"         ,"QTDE"          ,"@E 999,999.99"     ,10,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Vl.Unit"      ,"VALUNIT"       ,"@E 999,999,999.99" ,12,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Vl.Total"     ,"VALTOTAL"      ,"@E 999,999,999.99" ,12,0 ,"","€€€€€€€€€€€€€€ ","N","","R","",""})
	Aadd(aHeadEx,{"Pedido"       ,"PEDIDO"        ,"@!"                ,06,0 ,"U_FA03APC()","€€€€€€€€€€€€€€ ","C","SC7XML","R","",""})
	Aadd(aHeadEx,{"Item.PC"      ,"ITEMPC"        ,"@!"                ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})
	Aadd(aHeadEx,{"Unid"         ,"UNID"          ,"@!"                ,02,0 ,"","€€€€€€€€€€€€€€ ","C","","R","",""})

	oMSNewGe1 := MsNewGetDados():New( 000, 000, 178, 398, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oPanel3, aHeadEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Salvar      ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Gravacao de dados e execauto de documentos de entrada      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Salvar()

	Local LRET := .F.

	U_BIAMsgRun("Aguarde... Salvando Dados Amarracao Produto x Fornecedor (SA5)",, {|| SaveSA5() })

	U_BIAMsgRun("Processando entrada da nota fiscal",, {|| LRET := ExecSF1() })

Return(LRET)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ SaveSA5     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Processar e gravar SA5 para codigos internos nao encontr.  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static function SaveSA5()

	Local I
	Local aColsEx := AClone(oMSNewGe1:ACols)

	FOR I := 1 To Len(aColsEx)

		SA5->(DbSetOrder(1))
		IF !Empty(aColsEx[I][3])

			IF !SA5->(DbSeek(XFilial("SA5")+_CCODFOR+_CLOJFOR+aColsEx[I][3]))
				RecLock("SA5",.T.)
				SA5->A5_FILIAL := XFILIAL("SA5")
				SA5->A5_FORNECE := _CCODFOR
				SA5->A5_LOJA := _CLOJFOR
				SA5->A5_NOMEFOR := _CNOMEFOR
				SA5->A5_PRODUTO := aColsEx[I][3]
				SA5->A5_NOMPROD := aColsEx[I][4]
				SA5->A5_CODPRF := aColsEx[I][2]
				SA5->(MsUnlock())
			ELSEIF Empty(SA5->A5_CODPRF)
				RecLock("SA5",.F.)
				SA5->A5_CODPRF := aColsEx[I][2]
				SA5->(MsUnlock())
			ENDIF

		ENDIF

	NEXT I

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ FA03APC     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FA03APC()

	//MsgAlert("TESTE")

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExecSF1     ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Processar e fazer o execauto do documento de entrada       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ExecSF1()

	Local I
	Local ADADOS := AClone(oMSNewGe1:ACols)
	Local _aAutoErro
	Local _cLogTxt := ""

	Private LFXIMP := .T.
	PRIVATE LMSERROAUTO := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	//Parametro para listar Fornecedores SA2 que utilizam 2a Unidade de medida
	Private _CSA2SEGUM := AllTrim(SuperGetMV("MV_YSA2SUM",.F.,""))

	SB1->(DbSetOrder(1))

	ACABS	 		:= {}

	//Posiciona fornecedor
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(XFilial("SA2")+_CCODFOR+_CLOJFOR))

	//Definir condicao de pagamento
	__CCOND := ""
	IF !Empty(ADADOS[1][8])
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(XFilial("SC7")+ADADOS[1][8]))
			__CCOND := SC7->C7_COND
		EndIf
	ELSE
		//procura primeira tabela de preço válida do fornecedor/produto
		__cAliasTmp := GetNextAlias()
		BeginSql Alias __cAliasTmp
			SELECT TOP 1 AIA_CONDPG COND
			FROM %TABLE:AIB% AIB
			JOIN %TABLE:AIA% AIA ON AIA_CODFOR = AIB_CODFOR AND AIA_LOJFOR = AIB_LOJFOR AND AIA_CODTAB = AIB_CODTAB AND AIA.D_E_L_E_T_=' '
			WHERE
			AIB_CODFOR = %EXP:_CCODFOR%
			AND AIB_LOJFOR = %EXP:_CLOJFOR%
			AND AIB_CODPRO = %EXP:ADADOS[1][3]% //primeiro produto
			AND AIA_DATATE >= %EXP:DTOS(dDataBase)%
			AND AIB.D_E_L_E_T_=' '
		EndSql
		If !(__cAliasTmp)->(Eof())
			__CCOND := (__cAliasTmp)->COND
		EndIf
		(__cAliasTmp)->(DbCloseArea())
	ENDIF

	ACABS:= {	{'F1_TIPO   '	, 'N'       	 				    , NIL},;
	{          'F1_DOC    '	, _NFNUM		 				      , NIL},;
	{          'F1_SERIE  '	, _NFSERIE						    , NIL},;
	{          'F1_EMISSAO'	, _NFEMIS						     	, NIL},;
	{          'F1_FORNECE'	, _CCODFOR    					  , NIL},;
	{          'F1_LOJA   '	, _CLOJFOR 			     		  , NIL},;
	{          'F1_EST    '	, SA2->A2_EST	  					, NIL},;
	{          'F1_DTDIGIT'	, dDataBase							  , NIL},;
	{          'F1_ESPECIE'	, 'SPED'							    , NIL},;
	{          'F1_FORMUL ' , 'N'             	  		, NIL},;
	{          'F1_CHVNFE ' , _CCHVNFE        	  		, NIL} }

	If !Empty(__CCOND)
		AADD(ACABS,	{'F1_COND ',__CCOND, NIL})
	EndIf

	AITENS := {}
	FOR I := 1 To Len(ADADOS)

		If Empty(ADADOS[I][3])
			loop
		EndIf

		//Posicionar Produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFILIAL("SB1")+ADADOS[I][3]))

		//Posicionar Indicador de Produto
		SBZ->(DbSetOrder(1))
		SBZ->(DbSeek(XFILIAL("SB1")+ADADOS[I][3]))

		//Posicionar Pedido
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(XFILIAL("SC7")+ADADOS[I][8]+ADADOS[I][9]))

		// Por Marcos Alberto Soprani em 29/03/12
		If !Empty(aDados[I][8])
			If Alltrim(SB1->B1_UM) <> aDados[I][10]
				MsgSTOP("A unidade de medida do produto no arquivo XML é: " + aDados[I][10] + ". "+CHR(13)+CHR(13)+"No cadastro de produto está cadastrado como: " + Alltrim(SB1->B1_UM) )
			EndIf
		EndIf

		_AAUX := {}
		AADD(_AAUX, {'D1_DOC    ', _NFNUM						  	, NIL})
		AADD(_AAUX, {'D1_SERIE  ', _NFSERIE						  , NIL})
		AADD(_AAUX, {'D1_FORNECE', _CCODFOR							, NIL})
		AADD(_AAUX, {'D1_LOJA   ', _CLOJFOR					    , NIL})
		AADD(_AAUX, {'D1_UM     ', SB1->B1_UM						, NIL})
		AADD(_AAUX, {'D1_COD    ', SB1->B1_COD					, NIL})
		AADD(_AAUX, {'D1_LOCAL  ', SB1->B1_LOCPAD				, NIL})

		If !Empty(aDados[I][8])
			AADD(_AAUX, {'D1_PEDIDO ', ADADOS[I][8]					, NIL})
			AADD(_AAUX, {'D1_ITEMPC ', ADADOS[I][9]					, NIL})
		EndIf

		//Adiciona a QTDE da segunda unidade de medida caso Fornecedor configurado
		IF !Empty(_CSA2SEGUM) .And. ((_CCODFOR+_CLOJFOR) $ _CSA2SEGUM)
			AADD(_AAUX, {'D1_QTDSEUM', ADADOS[I][5]				, NIL})
		ELSE
			AADD(_AAUX, {'D1_QUANT  ', ADADOS[I][5]				, NIL})
			AADD(_AAUX, {'D1_VUNIT  ', ADADOS[I][6]				, NIL}) //Retirado por Marcos Alberto em 30/03/12 porque dispara gatilhos que diferem do valor do pedido
			AADD(_AAUX, {'D1_TOTAL  ', ADADOS[I][7]				, NIL}) //Retirado por Marcos Alberto em 03/04/12 porque estava gerando problema de arredondamento do valor unitário pela quantidade do pedido.
		ENDIF

		If !Empty(SC7->C7_TES) .and. fRetSF4(SC7->C7_TES)
			AADD(_AAUX, {'D1_TES    ', SC7->C7_TES 				, NIL})
		ElseIf !Empty(SBZ->BZ_TE) .and. fRetSF4(SBZ->BZ_TE)
			AADD(_AAUX, {'D1_TES    ', SBZ->BZ_TE 				, NIL})
		ElseIf !Empty(SB1->B1_TE) .and. fRetSF4(SB1->B1_TE)
			AADD(_AAUX, {'D1_TES    ', SB1->B1_TE 				, NIL})
		Else
			A0001 := " SELECT MIN(F4_CODIGO) TES
			A0001 += "   FROM " + RetSqlName("SF4")
			A0001 += "  WHERE F4_FILIAL = '"+xFilial("SF4")+"'
			A0001 += "    AND F4_MSBLQL <> '1'
			A0001 += "    AND D_E_L_E_T_ = ' '
			TCQUERY A0001 New Alias "A001"
			dbSelectArea("A001")
			dbGoTop()
			AADD(_AAUX, {'D1_TES    ', A001->TES 					, NIL})
			A001->(dbCloseArea())
		EndIf

		AADD(AITENS,_AAUX)

	Next I

	LMSERROAUTO := .F.
	lMsHelpAuto := .T.
	lAutoErrNoFile := .T.

	SetKey(VK_F9,{||})

	MSExecAuto({|x,y,z,w| Mata103(x,y,z,w)},ACABS,AITENS,3,.T.)

	IF LMSERROAUTO
		//Grava log de erro para consulta posterior
		_aAutoErro := GETAUTOGRLOG()
		_cLogTxt += XCONVERRLOG(_aAutoErro)
		MsgAlert(_cLogTxt,"LOG DA IMPORTAÇÃO")
	ENDIF

	//TESTAR SE A NOTA FOI INCLUIDA PARA RETORNAR .T.
	SF1->(DbSetOrder(1))
	IF !SF1->(DbSeek(XFILIAL("SF1")+PADR(_NFNUM,TamSX3("F1_DOC")[1])+PADR(_NFSERIE,TamSX3("F1_SERIE")[1])+PADR(_CCODFOR,TamSX3("F1_FORNECE")[1])+PADR(_CLOJFOR,TamSX3("F1_LOJA")[1])+'N'))
		Return(.F.)
	ENDIF

	SetKey(VK_F9, {|| U_FAIMPPED()})

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ XCONVERRLOG ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Converter log de erro para texto simples                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
STATIC FUNCTION XCONVERRLOG(aAutoErro)

	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+" - "
	NEXT nX

RETURN cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ FAIMPPED  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 12/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Pesquisa Pedidos em aberto para associação a NF            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAIMPPED()

	Local aArea   := GetArea()
	Private aDlgPed
	Private oGet1
	Private cGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"C7_NUM", "C7_ITEM", "C7_PRODUTO", "C7_LOCAL", "C7_EMISSAO", "C7_PRECO", "C7_QUANT", "C7_DESCRI"}
	Private oMGetDd1
	Public hk_Retur1
	Public hk_Retur2

	DEFINE MSDIALOG aDlgPed TITLE "Selecionar Pedidos de Compras" FROM nLin*.000, nCol*.000  TO nLin*.600, nCol*.750 COLORS 0, 16777215 PIXEL
	fMgDado1()
	@ nLin*.240, nCol*.350 BUTTON Retornar PROMPT "Retornar" SIZE nLin*.040, nCol*.020 OF aDlgPed ACTION( fGrDads1(), aDlgPed:End() ) PIXEL
	ACTIVATE MSDIALOG aDlgPed

	n := 1

Return .T.

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fMgDado1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fMgDado1()
	Local nX

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	If Empty(oMSNewGe1:ACols[oMSNewGe1:nAt][3])

		// Monta Arquivo de Trabalho
		_cAliasTmp := GetNextAlias()
		Beginsql Alias _cAliasTmp
			SELECT DISTINCT C7_NUM, C7_ITEM, C7_PRODUTO, C7_LOCAL, C7_EMISSAO, C7_PRECO, C7_QUANT - C7_QUJE C7QUANT, C7_DESCRI
			FROM %TABLE:SC7% SC7
			WHERE C7_FILENT = %XFILIAL:SC7%
			AND C7_FORNECE = %EXP:_CCODFOR%
			AND C7_LOJA = %EXP:_CLOJFOR%
			AND (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0
			AND C7_RESIDUO = ' '
			AND C7_TPOP <> 'P'
			AND C7_CONAPRO <> 'B'
			AND SC7.%NotDel%
		EndSql

	Else

		// Monta Arquivo de Trabalho
		_cAliasTmp := GetNextAlias()
		Beginsql Alias _cAliasTmp
			SELECT DISTINCT C7_NUM, C7_ITEM, C7_PRODUTO, C7_LOCAL, C7_EMISSAO, C7_PRECO, C7_QUANT - C7_QUJE C7QUANT, C7_DESCRI
			FROM %TABLE:SC7% SC7
			WHERE C7_FILENT = %XFILIAL:SC7%
			AND C7_FORNECE = %EXP:_CCODFOR%
			AND C7_LOJA = %EXP:_CLOJFOR%
			AND (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0
			AND C7_RESIDUO = ' '
			AND C7_TPOP <> 'P'
			AND C7_CONAPRO <> 'B'
			AND C7_PRODUTO = %EXP:oMSNewGe1:ACols[oMSNewGe1:nAt][3]%
			AND SC7.%NotDel%
		EndSql
	EndIf

	(_cAliasTmp)->(DbGoTop())
	While .Not. (_cAliasTmp)->(Eof())
		Aadd(aFieldFill, {(_cAliasTmp)->C7_NUM, (_cAliasTmp)->C7_ITEM, (_cAliasTmp)->C7_PRODUTO, (_cAliasTmp)->C7_LOCAL, STOD((_cAliasTmp)->C7_EMISSAO), (_cAliasTmp)->C7_PRECO, (_cAliasTmp)->C7QUANT, (_cAliasTmp)->C7_DESCRI, .F. })
		(_cAliasTmp)->(DbSkip())
	EndDo
	(_cAliasTmp)->(DbCloseArea())

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, { Space(6), Space(4), Space(15), Space(2), ctod("  /  /  "), 0, 0, Space(50), .F. })
	EndIf
	aColsEx := aFieldFill

	oMGetDd1 := MsNewGetDados():New( nLin*.005, nCol*.005, nLin*.225, nCol*.373, , , , , , , 999, , , , aDlgPed, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrDads1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrDads1()

	If !Empty(oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][1])
		oMSNewGe1:ACols[oMSNewGe1:nAt][3] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][3]
		oMSNewGe1:ACols[oMSNewGe1:nAt][8] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][1]
		oMSNewGe1:ACols[oMSNewGe1:nAt][9] := oMGetDd1:ACOLS[oMGetDd1:oBrowse:nAt][2]
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrDads1  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fRetSF4(wfTES)

	Local xRtTES := .F.

	SF4->(dbSetOrder(1))
	If SF4->(dbSeek(xFilial("SF4")+wfTES))
		If SF4->F4_MSBLQL <> "1"
			xRtTES := .T.
		EndIf
	EndIf

Return ( xRtTES )
