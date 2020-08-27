#INCLUDE 'FWMVCDEF.CH'
#Include "PROTHEUS.CH"
//#Include "TOPCONN.CH"
//#Include "RWMAKE.CH"
//#Include "Fileio.ch"
//#Include "tbiconn.ch"
//#Include "DBINFO.CH"
//#Include "MSGRAPHI.CH"


/*/{Protheus.doc} u_FAT8Loca
Tela de cadastro de Maquina
@author    aco
@since     20/08/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
@obs Central de acompanhmento e cobrança de locações
CADASTROS: Inclusão manual
A1_COD
A1_NOME
A1_YCPGTLO
A1_TABELA
A1_YDIAFEC	- Dia para fechamento da fatura de aluguél - Cadastro de Cliente
ZZ1_COD		- Código da Amarração
ZZ1_PRDINT	- Produto Interno (de aplicação)
ZZ1_PRDEXT	- Produto Externo (Cobrança de Locação)
===========================================================================================
MOVIMENTAÇÕES: Será gerado por procedimento mensal e ou movimentação.
ZZ2_CODLOC	- Código de Locação
ZZ2_CLIENTE	- Código do Cliente
ZZ2_LOJA	- Código da Filial (Loja)
ZZ2_SERIE	- Série da NF de Remessa
ZZ2_NOTREM	- Nota Fiscal de Remessa
ZZ2_PRDAPL	- Código Produto Aplicado
ZZ2_QTDAPL 	- Quantidade Remessa
ZZ2_QTDDEV 	- Quantidade Devolvida
ZZ2_DTAAPL	- Data de Aplicação / Remessa
ZZ2_ULTPED	- Código do Última Pedido para cobrança do aluguel
ZZ1_GRPAMA	- Grupo de Amarração
ZZ1_METINC	- Metodo de Inclusao (M=Manual, A=Automático)
ZZ1_ULTATU	- Data da última atualização
===========================================================================================
AMARRAÇÕES: As movimentações serão vinculadas pelo código de locação, para cada ocorrência
C6_YCODLOC	- Código da Locação - Pedido
E1_YCODLOC	- Código da Locação - Títulos
D2_YCODLOC	- Código da Locação - Nota de Remessa
D1_YCODLOC	- Código da Locação - Nota de Retorno
/*/
Function u_FAT8Loca()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SA1')
	oBrowse:SetDescription( 'Central de Locações' )
	oBrowse:SetMenuDef( Menudef() )
	oBrowse:Activate()

Return NIL

//Static Function MenuDef()
//
//	LOCAL aRotina
//	:= {{ STR0001,'AxPesqui'  		, 0 , K_Pesquisar  	, 0 , .F.},; //"Pesquisar"
//	{ STR0002,'PLSA090Mov'		, 0 , K_Visualizar 	, 0 , Nil},; //"Visualizar"
//	{ STR0003,'PLSA090Mov'		, 0 , K_Incluir    	, 0 , Nil},; //"Incluir"
//	{ STR0004,'NAODISP'   		, 0 , K_Alterar    	, 0 , Nil},; //"Nao Disponivel"
//	{ STR0005,'PLSA090Mov'		, 0 , K_Excluir    	, 0 , Nil},; //"Excluir"
//	{ STR0409,'PLSA090Mov'		, 0 , K_Incluir    	, 0 , Nil},;  //"Copiar"
//	{ STR0006,'PLSA090Ima'		, 0 , K_Imprimir   	, 0 , Nil},; //"Imp.Guia"
//	{ STR0007,'PLSA090Rec(.T.)'	, 0 , K_ImpRec   		, 0 , Nil},; //"Imp. Recibo"
//	{ STR0008,'PLSA090Bxt'		, 0 , K_Visualizar	, 0 , Nil},; //"Baixar Tit"
//	{ STR0009,'PLSA090Img'		, 0 , K_Imprimir		, 0 , Nil},; //"Imp.Varias Guias"
//	{ STR0010,'PLSA090Can(.F.)'	, 0 , K_Visualizar	, 0 , Nil},; //"Cancelar Guia"
//	{ STR0256, aRotConh			, 0 , 0/*K_Incluir*/		, 0 , Nil},; //"Banco de conhecimento"
//	{ STR0283,'PLSA090RAS'		, 0 , K_Imprimir		, 0 , Nil},; //"Rastrear"
//	{ STR0555,cInteracao		, 0 , K_Incluir		, 0 , Nil}} //Interação

//
//Return ( aRotina )

Function u_FAT8Central()

	Local aCpoSA1
	Local aCpoZZ2
	Local aCpoSC6
	Local aCpoSD2
	Local aCpoSD1
	Local aCpoSE1
	Local nRecnoSA1	:= SA1-> ( Recno() )

	Local aHeadSa1	:= {}
	Local aHeadZz2 	:= {}
	Local aHeadSd1 	:= {}
	Local aHeadSe1 	:= {}
	Local aHeadSc6	:= {}
	Local aBckRotina:= aClone( aRotina )

	Local cSayCli
	//	Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

	Local nX
	//	Local oTmpTbl1
	Local aColSa1 := {}
	Local aColZz1 := {}
	Local aColSd2 := {}
	Local aColSd1 := {}
	Local aColSe1 := {}
	Local aColSc6 := {}
	Local oGetCod
	Local oGetLj
	Local oGetNom
	Local oGetDFec
	Local oGetPgt, oGetTab, cSayPgt

	Private A1_COD, A1_LOJA, A1_NOME, A1_YCPGTLO, A1_YMENNOT, A1_TABELA, A1_YDIAFEC

	Private aCoors     := FWGetDialogSize( oMainWnd )
	Private oMainDlg
	Private oFWLayer
	//	Private oWinINF
	Private oBrwZZ2, oBrwSD2, oBrwSD1 //, oBrwSE1

	IF SA1->A1_YSTAZZ2 == 'N'
		Aviso( 'Atenção', 'O cliente selecionado não participa do processo de locações', {'Ok'} )
		Return
	ENDIF

	aRotina := {}

	chkfile("SD1")
	chkfile("SD2")
	chkfile("SC5")
	chkfile("SC6")
	chkfile("SA1")
	chkfile("SB1")
	chkfile("SE1")
	chkfile("ZZ1")
	chkfile("ZZ2")
	chkfile("DA1")

	//	aObjects := {}
	//	AAdd( aObjects, { 1, 10 , .T., .T. } )
	//	AAdd( aObjects, { 1, 00 , .T., .F. } )
	//	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	//	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	//+-------------------------------------------------------------+
	//| Monta estruturas de dados 									|
	//+-------------------------------------------------------------+
	aCpoSA1	:= { "A1_COD", "A1_LOJA", "A1_NOME", "A1_YCPGTLO", "A1_YMENNOT", "A1_TABELA", "A1_YDIAFEC" }
	aCpoZZ2	:= { "ZZ2_CODLOC", "ZZ2_SERIE", "ZZ2_NOTREM", "ZZ2_PRDAPL", "ZZ2_DESCPR", "ZZ2_TES", "ZZ2_QTDAPL", "ZZ2_PRCUNI", "ZZ2_SALDO", "ZZ2_ULTCOB", "ZZ2_METINC", "ZZ2_ULTALT", "ZZ2_ULTRET", "ZZ2_DTAAPL", "ZZ2_GRPAMA", "ZZ2_CLIENT", "ZZ2_LOJA" }
	aCpoSC6	:= { "C6_NUM", "C6_ITEM", "C6_PRODUTO","C6_QTDVEN", "C6_PRCVEN", "C6_TOTAL", "C6_EMISSAO", "C6_TES", "C6_YCODLOC" }
	aCpoSD1	:= { "D1_DOC", "D1_SERIE", "D1_COD","D1_ITEM", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_EMISSAO", "D1_TES", "D1_CF",  "D1_IDENTB6", "D1_YCODLOC" }
	aCpoSE1	:= { "E1_NUM", "E1_PARCELA", "E1_PREFIXO", "E1_TIPO", "E1_EMISSAO", "E1_VENCTO", "E1_VALOR", "E1_SALDO", "E1_BAIXA", "E1_YCODLOC" }

	FAT8GetCpo( aCpoSA1, @aHeadSa1, @aColSa1 )
	FAT8GetCpo( aCpoZZ2, @aHeadZz2, @aColZz1 )
	FAT8GetCpo( aCpoSC6, @aHeadSc6, @aColSc6 )
	FAT8GetCpo( aCpoSD1, @aHeadSd1, @aColSd1 )
	FAT8GetCpo( aCpoSE1, @aHeadSE1, @aColSe1 )

	//+-------------------------------------------------------------+
	//| Criacao dos objetos de tela                                 |
	//+-------------------------------------------------------------+

	Define MsDialog oMainDlg Title 'Central de Locações' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	// Cria o container onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oMainDlg, .F., .T. )

	//DADOS DO CLIENTE
	oFWLayer:AddLine   ('CLIENTE'   , 15, .F.)
	oFWLayer:AddCollumn('CLI'   	,100, .F.,'CLIENTE'  )

	//DADOS DAS LOCAÇÕES
	oFWLayer:AddLine   ('LOCACAO'   , 40, .F.)
	oFWLayer:AddCollumn('LOC'   	,100, .F.,'LOCACAO'  )

	//DADOS DAS NOTAS DE REMESSA
	oFWLayer:AddLine   ('NF'    	, 35, .F.)
	oFWLayer:AddCollumn('NFLEFT'   	, 50, .F.,'NF'  )
	oFWLayer:AddCollumn('NFRIGTH'   , 50, .F.,'NF'  )

	//	//DADOS DOS TÍTULOS
	//	oFWLayer:AddLine   ('TITULO'  	, 20, .F.)
	//	oFWLayer:AddCollumn('TIT'   	,100, .F.,'TITULO'  )

	//	oCbcPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	//	oCbcPnlPai:CoorsUpdate()

	oPnlSA1 := oFWLayer:getColPanel('CLI'  	 , 'CLIENTE'  )
	oPnlZZ2 := oFWLayer:getColPanel('LOC'  	 , 'LOCACAO')
	oPnlSC6 := oFWLayer:getColPanel('NFLEFT' , 'NF')
	oPnlSD1 := oFWLayer:getColPanel('NFRIGTH', 'NF')
	//	oPnlSE1 := oFWLayer:getColPanel('TIT'	 , 'TITULO')

	oFWLayer:addWindow('CLI' 	,'WinSA1', 'Cliente' ,100, .F., .F., Nil, 'CLIENTE')
	oFWLayer:addWindow('LOC' 	,'WinZZ2', 'Locações',100, .F., .F., Nil, 'LOCACAO')
	oFWLayer:addWindow('NFLEFT'	,'WinSD2', 'Remessas',100, .F., .F., Nil, 'NF')
	oFWLayer:addWindow('NFRIGTH','WinSD1', 'Retornos',100, .F., .F., Nil, 'NF')
	//	oFWLayer:addWindow('TIT'	,'WinSE1', 'Remessas',100, .F., .F., Nil, 'TITULO')

	oWinSA1 := oFWLayer:getWinPanel('CLI','WinSA1','CLIENTE')
	oPnlSA1 := TPanel():New( 00, 00,, oWinSA1,,,,, Nil, 100, 100, .F., .F.)
	oPnlSA1 :Align := CONTROL_ALIGN_ALLCLIENT

	aScan( aCpoSA1, {|x| & ( "M->" + x ) := & ( "SA1->" + x ) })

	@ 0.5, 005 SAY   cSayCli PROMPT "Cliente/Loja/Nome:" 	SIZE 040, 007 OF oPnlSA1 COLORS CLR_HBLUE PIXEL
	@ 007, 005 MSGET oGetCod Var M->A1_COD  				SIZE 030, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL
	@ 007, 045 MSGET oGetLj  Var M->A1_LOJA 				SIZE 015, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL
	@ 007, 071 MSGET oGetNom Var M->A1_NOME 				SIZE 100, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL

	@ 0.5, 186 SAY   cSayTab PROMPT "Tabela:" 				SIZE 040, 007 OF oPnlSA1 COLORS CLR_HBLUE PIXEL
	@ 007, 186 MSGET oGetTab Var M->A1_TABELA    			SIZE 025, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL

	@ 0.5, 236 SAY   cSayTab PROMPT "Dia Fecham." 			SIZE 030, 007 OF oPnlSA1 COLORS CLR_HBLUE PIXEL
	@ 007, 236 MSGET oGetDFec Var M->A1_YDIAFEC    			SIZE 025, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL

	@ 0.5, 280 SAY   cSayPgt PROMPT "Cond.Pagto." 			SIZE 030, 007 OF oPnlSA1 COLORS CLR_HBLUE PIXEL
	@ 007, 280 MSGET oGetPgt Var M->A1_YCPGTLO    			SIZE 025, 010 F3 "SE4" VALID VAZIO() .OR. ExistCpo("SE4") OF oPnlSA1 COLORS 0, 16777215 PIXEL Hasbutton

	@ 0.5, 315 SAY   cSayMsg PROMPT "Mens.padrão do Cliente." SIZE 080, 007 OF oPnlSA1 COLORS CLR_HBLUE PIXEL
	@ 007, 315 MSGET oGetMsg Var M->A1_YMENNOT    			SIZE 140, 010 OF oPnlSA1 COLORS 0, 16777215 PIXEL


	oTButton1 := TButton():New( 3.4, 470, "Desabilitar"  	, oPnlSA1, {|| FWMsgRun( , { || u_F08Desab() },"", "Desabilita cálculo...") } 	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 3.4, 520, "Habilitar"		, oPnlSA1, {|| FWMsgRun( , { || u_F08Habil() },"", "Habilit	a cálculo...") } 	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 3.4, 570, "Calcula"			, oPnlSA1, {|| FWMsgRun( , { || u_F08LocCa() },"", "Cálculo único...") } 		, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 := TButton():New( 3.4, 620, "Calcula Geral"	, oPnlSA1, {|| FWMsgRun( , { || u_F08LocGe() },"", "Cálculo geral...") } 		, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	Processa( { || F08LoadSB6() } )

	//Cria Browse de LOCAÇÕES
	oBrwZZ2 := FWMBrowse():New()
	oBrwZZ2 :SetOwner( oPnlZZ2 )
	oBrwZZ2 :SetDescription('Aplicações em clientes')
	oBrwZZ2 :SetMenuDef('')
	oBrwZZ2 :SetAlias("ZZ2")
	oBrwZZ2 :SetOnlyFields({''}) //Coloquei essa função por que a rotina não estava respeitando o SetFields.
	oBrwZZ2 :SetFields(aHeadZz2)
	oBrwZZ2 :addLegend( "ZZ2_SALDO  == 0   ", "GRAY"	 ,'Cobrança Finalizada'	)
	oBrwZZ2 :addLegend( "ZZ2_STATUS  $ '1 '", "GREEN"	 ,'Cobrança Ativa'		)
	oBrwZZ2 :addLegend( "ZZ2_STATUS == '2' ", "RED" 	 ,'Cobrança Bloqueada'	)
	oBrwZZ2 :DisableReport()
	oBrwZZ2 :DisableDetails()
	oBrwZZ2 :SetProfileID('1')
	oBrwZZ2 :SetWalkThru(.F.)
	oBrwZZ2 :DisableConfig()
	oBrwZZ2 :SetUseFilter(.T.)

	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "01", /*cPergunt*/ "Cliente de?    ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch0", /*cTipo*/ "C", /*nTamanho*/ TamSx3("A1_COD")[1]		, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/"SA1"	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR01", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código do cliente para"," delimitar o início de intervalo"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "02", /*cPergunt*/ "Loja até?      ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch1", /*cTipo*/ "C", /*nTamanho*/ TamSx3("A1_LOJA")[1]	, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/""	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR02", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código da loja para"," delimitar o início de intervalo"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "03", /*cPergunt*/ "Cliente até?   ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch2", /*cTipo*/ "C", /*nTamanho*/ TamSx3("A1_COD")[1]		, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/"SA1"	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR03", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código do cliente para"," delimitar o final de intervalo"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "04", /*cPergunt*/ "Loja até?      ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch3", /*cTipo*/ "C", /*nTamanho*/ TamSx3("A1_LOJA")[1]	, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/""   	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR04", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código da loja para"," delimitar o final de intervalo"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "05", /*cPergunt*/ "Dia Fehamento? ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch4", /*cTipo*/ "C", /*nTamanho*/ 2						, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/""   	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR05", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Dia de fechamento"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "06", /*cPergunt*/ "Cond.Pagamento?", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch5", /*cTipo*/ "C", /*nTamanho*/ TamSx3("A1_YCPGTLO")[1]	, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/"SE4"	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR06", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Condição de pagamento"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "TECFAT08", /*cOrdem*/ "07", /*cPergunt*/ "Mensagem Padrão?",/*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch6", /*cTipo*/ "C", /*nTamanho*/ TamSx3("C5_MENPAD")[1]	, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/"", /*cF3*/"SM4"	, /*cGrpSxg*/ "", /*cPyme*/ ""	, /*cVar01*/ "MV_PAR07", /*cDef01*/ "", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/""	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Código da mensagem padrão"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")

	oBrwZZ2 :Activate()

	oBrwZZ2 :SetFilterDefault( "ZZ2->ZZ2_CLIENT == M->A1_COD .AND. ZZ2->ZZ2_LOJA == M->A1_LOJA" )
	ZZ2->( dbSetOrder( 1 ) )
	oBrwZZ2:Refresh(.T.)

	//Cria Browse de Pedidos de Locação
	oBrwSC6 := FWMBrowse():New()
	oBrwSC6 :SetOwner( oPnlSC6 )
	oBrwSC6 :SetDescription('Pedidos/Locações')
	oBrwSC6 :SetMenuDef('')
	oBrwSC6 :SetAlias ("SC6")
	oBrwSC6 :SetOnlyFields({''}) //Coloquei essa função por que a rotina não estava respeitando o SetFields.
	oBrwSC6 :SetFields(aHeadSc6)
	oBrwSC6 :DisableReport()
	oBrwSC6 :DisableDetails()
	oBrwSC6 :SetProfileID('2')
	oBrwSC6 :SetWalkThru(.F.)
	oBrwSC6 :ForceQuitButton()
	oBrwSC6 :DisableConfig()
	oBrwSC6 :SetUseFilter(.T.)
	oBrwSC6 :Activate()
	oBrwSC6	:Refresh(.T.)

	oBrwSC6 :SetFilterDefault( "LEFT(SC6->C6_PRODUTO,4) == '0023' .AND. xFilial('SC6')==SC6->C6_FILIAL .AND. SC6->C6_YCODLOC <> '      '" )
	oBrwSC6:Refresh(.T.)
	oBrwSC6 :bLDblClick := { || u_F08AxVis() }

	//Cria Browse de NOTAS DE RETORNO
	oBrwSD1 := FWMBrowse():New()
	oBrwSD1 :SetOwner( oPnlSD1 )
	oBrwSD1 :SetDescription('Retornos de Aplicações')
	oBrwSD1 :SetMenuDef('')
	oBrwSD1 :SetAlias("SD1")
	oBrwSD1 :SetOnlyFields({''}) //Coloquei essa função por que a rotina não estava respeitando o SetFields.
	oBrwSD1 :SetFields(aHeadSd1)
	oBrwSD1 :DisableReport()
	oBrwSD1 :DisableDetails()
	oBrwSD1 :SetProfileID('3')
	oBrwSD1 :SetWalkThru(.F.)
	oBrwSD1 :DisableConfig()
	oBrwSD1 :ForceQuitButton()
	oBrwSD1 :DisableFilter()
	oBrwSD1 :SetUseFilter(.F.)
	oBrwSD1 :Activate()
	oBrwSD1	:Refresh(.T.)

	//Cria Browse de NOTAS DE REMESSA
	//	oBrwSE1 := FWMBrowse():New()
	//	oBrwSE1 :SetOwner( oPnlSE1 )
	//	oBrwSE1 :SetDescription('Cobranças de Locações')
	//	oBrwSE1 :SetMenuDef('')
	//	oBrwSE1 :SetAlias("SE1")
	//	oBrwSE1 :SetOnlyFields({''}) //Coloquei essa função por que a rotina não estava respeitando o SetFields.
	//	oBrwSE1 :SetFields(aHeadSe1)
	//	oBrwSE1 :DisableReport()
	//	oBrwSE1 :DisableDetails()
	//	oBrwSE1 :SetProfileID('4')
	//	oBrwSE1 :SetWalkThru(.F.)
	//	oBrwSE1 :ForceQuitButton()
	//	oBrwSE1 :DisableConfig()
	//	oBrwSE1 :DisableFilter()
	//	oBrwSE1 :SetUseFilter(.F.)
	//	oBrwSE1 :Activate()
	//	oBrwSE1	:Refresh(.T.)

	oSD2Relation:= FWBrwRelation():New()
	oSD2Relation:AddRelation( oBrwZZ2  , oBrwSC6 , { {"C6_FILIAL","ZZ2_FILIAL"		}, {"C6_YCODLOC","ZZ2_CODLOC"},{"C6_CLI","ZZ2_CLIENT"},{"C6_LOJA","ZZ2_LOJA"}} )
	oSD2Relation:Activate()

	oSD1Relation:= FWBrwRelation():New()
	oSD1Relation:AddRelation( oBrwZZ2  , oBrwSD1 , { {"D1_FILIAL","ZZ2_FILIAL"		}, {"D1_IDENTB6","ZZ2_IDENB6"} } ) //, {"D1_YCODLOC","ZZ2_CODLOC"}
	oSD1Relation:Activate()

	//	oSE1Relation:= FWBrwRelation():New()
	//	oSE1Relation:AddRelation( oBrwZZ2  , oBrwSE1 , { {"E1_FILIAL",'xFilial("SE1")'	}, {"E1_YCODLOC","ZZ2_CODLOC"} } )
	//	oSE1Relation:Activate()

	Activate MSDIALOG oMainDlg CENTERED ON INIT EnchoiceBar( oMainDlg,{|| F08SalvaSA1(nRecnoSA1) },{||  oMainDlg:End() })

	aRotina := aClone( aBckRotina )

Return Nil

Function u_F08AxVis()

	Local aGetArea	:= GetArea()

	DBSELECTAREA("SC5")

	IF Posicione( "SC5", 1, xFilial("SC6") + SC6->C6_NUM, "FOUND()" )
		MatA410(Nil, Nil, Nil, Nil, "A410Visual") //executo a função padrão MatA410
	ENDIF

	RestArea( aGetArea )

Return

Static Function F08SalvaSA1(nRecnoSA1)

	SA1->( dbGoTo( nRecnoSA1 ) )

	RecLock( "SA1", .F. )
	SA1->A1_YDIAFEC := M->A1_YDIAFEC
	SA1->A1_YCPGTLO	:= M->A1_YCPGTLO
	SA1->A1_YMENNOT	:= M->A1_YMENNOT
	SA1->A1_TABELA 	:= M->A1_TABELA
	SA1-> ( msUnLock() )

Return

Static cTES := GetNewPar( "TEC_TESLOC", '570' ) //tes padrão para geração de pedidos para cobrança de locações

Static Function F08Pedido(cCliDe, cLojDe, cCliAte, cLojAte)

	Local aCalZZ2 := {}
	Local qryZZ2

	Default cCliDe	:= m->A1_COD
	Default cCliAte	:= m->A1_COD
	Default cLojDe	:= m->A1_LOJA
	Default cLojAte	:= m->A1_LOJA

	Processa( { || F08LoadSB6(cCliDe, cLojDe, cCliAte, cLojAte) }, "Carregando poder de 3o..."  )
	MsgRun( "Processando filtro ZZ2...", "Aguarde!", {|| qryZZ2 := F08LoadZZ2(cCliDe, cLojDe, cCliAte, cLojAte) } )

	IF ( qryZZ2 ) -> ( ! eof() )
		Processa( { || F08GrvPed( qryZZ2 ) }, "Gerando pedidos de locação..." )
	ENDIF

Return

Static Function F08LoadZZ2(cCliDe, cLojDe, cCliAte, cLojAte)

	Local qryZZ2 := GetNextAlias()
	Local cWhere := "%%"

	Default cCliDe 	:= ''
	Default cCliAte	:= 'ZZZZZZZZZ'
	Default cLojDe	:= ''
	Default cLojAte	:= 'ZZZZ'

	dIniPeriodo	:= DtoS( MonthSub( dDataBase, 1 ) )

	IF ! Empty( MV_PAR05 )
		cWhere := "% AND A1_YDIAFEC	= " + ValToSql(MV_PAR05) + "%"
	ENDIF


	BeginSql Alias qryZZ2

		column ZZ2_ULTCOB as date
		column ZZ2_ULTRET as date
		column ZZ2_DTAAPL as date

		SELECT *
		FROM
		%Table:ZZ2% ZZ2, %Table:SA1% SA1
		WHERE
		ZZ2_CLIENT BETWEEN %Exp:cCliDe% AND %Exp:cCliAte% AND
		ZZ2_LOJA   BETWEEN %Exp:cLojDe% AND %Exp:cLojAte% AND
		ZZ2.D_E_L_E_T_ 	= '' 					AND
		SA1.D_E_L_E_T_ 	= '' 					AND
		A1_FILIAL 		= %xFilial:SA1% 		AND
		ZZ2_FILIAL 		= %xFilial:ZZ2% 		AND
		A1_COD 			= ZZ2_CLIENT	 		AND
		A1_LOJA			= ZZ2_LOJA	 			AND
		A1_YSTAZZ2	   <> "N"					AND
		ZZ2_STATUS 	   <> '2'
		%Exp:cWhere%
		Order by A1_NOME, ZZ2_LOJA, ZZ2_CODLOC, ZZ2_PRDAPL

	EndSql

	dbSelectArea( qryZZ2 )

Return qryZZ2

Static Function F08GrvPed( qryZZ2 )

	Local nI, cMsg
	Local dIniPeriodo	:= CtoD("")
	Local aDevolucao	:= {}
	Local cPrdLoc
	Local nQtdReg		:= 0
	Local nQtdDev		:= 0
	Local nQuantFull	:= 0
//	Local aZZ2Recno		:= {}

	Local nPrd 	:= 1
	Local nEmis	:= 2
	Local nQtd	:= 3
	Local nMsg	:= 4
	Local nDias	:= 5
	Local nCli	:= 6
	Local nLoj	:= 7
	Local nNumL	:= 8
	Local nDtRet:= 9

	Local aPreItens	:= {}
	Local aDev		:= {}

	dbSelectArea( qryZZ2 )
	dbEval( {|| nQtdReg += 1 } )
	dbGoTop()

	ProcRegua( nQtdReg )

	cOldCli		:= (qryZZ2) -> ZZ2_CLIENT
	cOldLoja 	:= (qryZZ2) -> ZZ2_LOJA

	WHILE (qryZZ2) -> ( ! EOF() )

		IncProc()

		IF cOldCli + cOldLoja <> (qryZZ2) -> ZZ2_CLIENT + (qryZZ2) -> ZZ2_LOJA .AND. Len( aPreItens ) > 0
			T08SaveSX1( "TECFAT08" ) //Salva perguntas
			F08InsPedido( aPreItens, dFimPeriodo )
			T08RestSX1()
			aPreItens := {}
		ENDIF

		ZZ2 -> ( dbGoTo( (qryZZ2) -> R_E_C_N_O_ ) )

		Posicione( "SA1", 1, xFilial("SA1") + (qryZZ2) -> ZZ2_CLIENT + (qryZZ2) -> ZZ2_LOJA, "FOUND()" )

		IF ! Empty(MV_PAR05) .AND. SA1->A1_YDIAFEC <> MV_PAR05
			(qryZZ2) -> ( dbSkip() )
			LOOP
		ENDIF

		//getLastReturn() //Pega a notas e produtos retornados no período

		IF Empty( (qryZZ2) -> ZZ2_ULTCOB )

			dIniPeriodo	:= DtoS( MonthSub( dDataBase, 1 ) )

			IF SA1->A1_YDIAFEC < '30'

				dIniPeriodo	:= StoD( LEFT( dIniPeriodo, 6 ) +  MaxChar(SA1->A1_YDIAFEC,"15") ) + 1
				dFimPeriodo	:= StoD( LEFT( DtoS( MonthSum( dIniPeriodo, 1 ) ), 6 ) + MaxChar(SA1->A1_YDIAFEC,MV_PAR05) )

			ELSE

				dIniPeriodo	:= StoD( Left(DtoS( MonthSub( dDataBase, 1 ) ),6) + '01' )
				dFimPeriodo	:= StoD( Left( DtoS(dIniPeriodo), 6) + StrZero(Last_Day( dIniPeriodo),2) ) //StoD( LEFT( DtoS( MonthSum( dIniPeriodo, 1 ) ), 6 ) + SA1->A1_YDIAFEC )

			ENDIF

		ELSE

			dIniPeriodo := (qryZZ2) -> ZZ2_ULTCOB + 1

			IF SA1->A1_YDIAFEC < '30'
				dFimPeriodo	:= StoD( LEFT( DtoS( MonthSum( dIniPeriodo, 1 ) ), 6 ) + MaxChar(SA1->A1_YDIAFEC,MV_PAR05) )
			ELSE
				dFimPeriodo	:= StoD( Left( DtoS(dIniPeriodo), 6) + StrZero(Last_Day( dIniPeriodo),2) ) //StoD( LEFT( DtoS( MonthSum( dIniPeriodo, 1 ) ), 6 ) + SA1->A1_YDIAFEC )
			ENDIF

		ENDIF

		IF ZZ2->ZZ2_DTAAPL >= dFimPeriodo  //Bypass cobranças fora de período
			(qryZZ2) -> ( dbSkip() )
			LOOP
		ENDIF

		cMsg 	:= ""
		nQtdDev := 0

		IF ! Empty(ZZ2->ZZ2_ULTRET) .AND. IIF( (qryZZ2) -> ZZ2_SALDO == 0, ZZ2->ZZ2_ULTRET < dIniPeriodo, .F. )
			(qryZZ2) -> ( dbSkip() )
			LOOP
		ENDIF

//		aAdd( aZZ2Recno, (qryZZ2) -> R_E_C_N_O_ )

		//Trata remessas após a data de início do período
		IF ZZ2->ZZ2_DTAAPL > dIniPeriodo  .OR. ZZ2 -> ( IIF( ! Empty(ZZ2_ULTRET), ZZ2_ULTRET > dIniPeriodo .and. ZZ2_ULTRET < dFimPeriodo, .F.) ) //trata locações com período parcial, pelo iníco tardio ou pelo termino antecipado

			aDev := F08GetDevol( dIniPeriodo, dFimPeriodo ) //{  data devolução, quantidade }

			//Entra quando houver devoluções no mês
			IF Len( aDev ) > 0

				//Verifica se existe mais algum produto sendo devolvido no mesmo período
				FOR nI := 1 TO Len( aDev )

					//Procura se o produto já foi incluído para a quantidade de dias em questão.
					aDev[nI][nDias] := min( aDev[nI][ nDtRet ] - dIniPeriodo, 30 ) //dFimPeriodo - aDev[nI][2]
					cMsg 			:= "( dias de locação " + StrZero( aDev[nI][nDias], 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
					aDev[nI][nMsg]  := cMsg + " NF Rem: " + aDev[nI][nMsg]
					nPos 			:= aScan( aPreItens, {|x,y| aDev[nI][ nPrd ] == x[nPrd] .and. x[nDias] == aDev[nI][nDias] .and.  aDev[nI][nMsg] == x[ nMsg ] })

					//Monta array pre-itens para geração do pedido de venda
					IF nPos > 0
						aPreItens[nPos][nQtd] += aDev[nI][nQtd]
					ELSE

						aAdd( aPreItens, aDev[ nI ] )

					ENDIF

				NEXT

				//Adiciona cobrança do saldo de produto a ser devolvido
				IF ZZ2 -> ZZ2_SALDO > 0

					aDev := {}

					aAdd( aDev, { ZZ2 -> ZZ2_PRDAPL, ZZ2 -> ZZ2_DTAAPL, ZZ2 -> ZZ2_SALDO, ZZ2 -> ( ZZ2_SERIE + ZZ2_NOTREM ),  0, ZZ2 -> ZZ2_CLIENT, ZZ2 -> ZZ2_LOJA, ZZ2 -> ZZ2_CODLOC, dFimPeriodo } )

					nQtdDias 	:= min( dFimPeriodo - ZZ2->ZZ2_DTAAPL, 30 )
					IF nQtdDias < 30
						cMsg 		:= "( dias de locação " + StrZero( nQtdDias, 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
					ENDIF

					//Procura se o produto já foi incluído para a quantidade de dias em questão.
					nI			 	:= 1
					aDev[nI][nDias] := min( aDev[nI][ nDtRet ] - dIniPeriodo, 30 ) //dFimPeriodo - aDev[nI][2]
					cMsg 			:= "( dias de locação " + StrZero( aDev[nI][nDias], 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
					aDev[nI][nMsg]  := cMsg + " NF Rem: " + aDev[nI][nMsg]
					nPos 			:= aScan( aPreItens, {|x,y| aDev[nI][ nPrd ] == x[nPrd] .and. x[nDias] == nQtdDias .and. aDev[nI][nMsg] == x[nMsg] })


					//Monta array pre-itens para geração do pedido de venda
					IF nPos > 0
						aPreItens[nPos][nQtd] += aDev[nI][nQtd]
					ELSE

						aAdd( aPreItens, aDev[ nI ] )

					ENDIF
				ENDIF

			ELSE
				aDev := {}
				aAdd( aDev, { ZZ2 -> ZZ2_PRDAPL, ZZ2 -> ZZ2_DTAAPL, ZZ2 -> ZZ2_QTDAPL, ZZ2 -> ( ZZ2_SERIE + ZZ2_NOTREM ),  0, ZZ2 -> ZZ2_CLIENT, ZZ2 -> ZZ2_LOJA, ZZ2 -> ZZ2_CODLOC, dFimPeriodo } )

				nQtdDias 	:= min( dFimPeriodo - ZZ2->ZZ2_DTAAPL, 30 )
				IF nQtdDias < 30
					cMsg 		:= "( dias de locação " + StrZero( nQtdDias, 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
				ENDIF

				//Procura se o produto já foi incluído para a quantidade de dias em questão.
				nI				:= 1
				aDev[nI][nDias] := min( aDev[nI][ nDtRet ] - dIniPeriodo, 30 ) //dFimPeriodo - aDev[nI][2]
				cMsg 			:= "( dias de locação " + StrZero( aDev[nI][nDias], 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
				aDev[nI][nMsg]  := cMsg + " NF Rem: " + aDev[nI][nMsg]
				nPos 			:= aScan( aPreItens, {|x,y| aDev[nI][ nPrd ] == x[nPrd] .and. x[nDias] == nQtdDias .and. aDev[nI][nMsg] == x[nMsg] })

				//Monta array pre-itens para geração do pedido de venda
				IF nPos > 0
					aPreItens[nPos][nQtd] += aDev[nI][nQtd]
				ELSE

					aAdd( aPreItens, aDev[ nI ] )

				ENDIF

			ENDIF

		ENDIF

		IF ZZ2->ZZ2_DTAAPL <= dIniPeriodo //Trata locação período integral

			nQtdDias := 30
			aDev 	 := F08GetDevol( dIniPeriodo, dFimPeriodo ) //{  data devolução, quantidade }

			FOR nI := 1 to LEN( aDev )

				//Procura se o produto já foi incluído para a quantidade de dias em questão.
				aDev[nI][nDias] := min( aDev[nI][ nDtRet ] - dIniPeriodo, 30 ) //dFimPeriodo - aDev[nI][2]
				cMsg 			:= "( dias de locação " + StrZero( aDev[nI][nDias], 2 ) + " )" //Calcula o número de dias de locação, considerando a data de devolução com a data de início do período
				aDev[nI][nMsg]  := cMsg + " NF Rem: " + aDev[nI][nMsg]
				nPos 	 		:= aScan( aPreItens, {|x,y| aDev[nI][ nPrd ] == x[nPrd] .and. nQtdDias == x[nDias]  .and. aDev[nI][nMsg] == x[nMsg]  })

				//Monta array pre-itens para geração do pedido de venda
				IF nPos > 0
					aPreItens[nPos][nQtd] += ZZ2 -> ZZ2_SALDO //nQuantFull
				ELSE

					aAdd( aPreItens, {} )
					aAdd( aPreItens[ Len(aPreItens) ], ZZ2 -> ZZ2_PRDAPL ) 	//01
					aAdd( aPreItens[ Len(aPreItens) ], ZZ2 -> ZZ2_DTAAPL ) 	//02
					aAdd( aPreItens[ Len(aPreItens) ], aDev[nI][3] 		 ) 	//03
					aAdd( aPreItens[ Len(aPreItens) ], aDev[nI][nMsg]	 )	//04
					aAdd( aPreItens[ Len(aPreItens) ], nQtdDias 		 )	//05
					aAdd( aPreItens[ Len(aPreItens) ], ZZ2 -> ZZ2_CLIENT )	//06
					aAdd( aPreItens[ Len(aPreItens) ], ZZ2 -> ZZ2_LOJA 	 )	//07
					aAdd( aPreItens[ Len(aPreItens) ], ZZ2 -> ZZ2_CODLOC )	//08
					aAdd( aPreItens[ Len(aPreItens) ], aDev[nI][9] 		 )	//09
					
				ENDIF
			NEXT

		ENDIF

		aDev 	 := {}
		cOldCli	 := ZZ2 -> ZZ2_CLIENT
		cOldLoja := ZZ2 -> ZZ2_LOJA

		(qryZZ2) -> ( dbSkip() )

	ENDDO

	IF LEN( aPreItens ) > 0
		T08SaveSX1( "TECFAT08" ) //Salva perguntas
		F08InsPedido( aPreItens, dFimPeriodo )
		T08RestSX1()
		aPreItens := {}
	ENDIF

Return
 
Static aBkpSX1 := {}

Static Function T08SaveSX1( cGrupoSx1 ) //Salva perguntas
	aBkpSX1 := {}
	IF Posicione( "SX1", 1, PadR( cGrupoSx1, Len( SX1->X1_GRUPO ) ), "FOUND()" )
		WHILE SX1->( ! EOF() .AND. alltrim(X1_GRUPO) = "TECFAT08" )
			aAdd( aBkpSX1, SX1->&X1_VAR01 )   //{MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07}
			SX1-> ( dbSkip() )
		ENDDO
	ENDIF
Return

Static Function T08RestSX1() //Salva perguntas
	Local nI := 0
	For nI := 1 TO Len( aBkpSX1 )
		&( "MV_PAR" + StrZero(nI,2,0) ) := aBkpSX1[ nI ]
	Next
Return


Static Function MaxChar(a,b)
	IF valtype(a) <> valtype(b)
		Aviso("ERRO", "Tipos para comparação diferem: tipo de A) " + valtype(a) + " topo de B= " + valtype(a), { "Ok"} )
	ENDIF
Return IIF( a > b, a, b )

Static Function F08InsPedido( aPreItens, dFimPeriodo )

	Local aCab		:= {}
	Local aTmp		:= {}
	Local aItens	:= {}
	Local aCabExc	:= {}
	Local aItemExc	:= {}
	Local nPrd 		:= 1
	Local nEmis		:= 2
	Local nQtd		:= 3
	Local nMsg		:= 4
	Local nDias		:= 5
	Local nCli		:= 6
	Local nLoj		:= 7
	Local nCodL		:= 8
	Local nDtRet	:= 9
	Local lExcPed 	:= .F.
	Local cTabSa1	:= ""
	Local nI, cSC5Key

	Local nSc6Recno
	Local cCondPagto:= SA1->( IIF( Empty(A1_YCPGTLO), IIF(empty(MV_PAR06), "016",MV_PAR06), A1_YCPGTLO) )
	Local nOrdSc6 	:= SC6-> ( dbOrderNickName("LOCACAO"), IndexOrd() )
	Local nIt, lAchei

	IF valtype( aPreItens ) == "U" .or. LEN( aPreItens ) == 0 .OR. valtype( aPreItens[1] ) == "U" .OR. Len( aPreItens[1]) == 0 .OR. valtype( aPreItens[1][nCli] ) == "U"
		lAchei := .t.
		Return
	ENDIF

	Posicione("SA1", 1, xFilial("SA1") + aPreItens[1][ nCli ] + aPreItens[1][ nLoj ], "found()")

	cTabSa1	:= SA1->A1_TABELA

	aadd(aCab,{"C5_TIPO"    , "N"						,nil})
	aadd(aCab,{"C5_EMISSAO" , dFimPeriodo    			,nil})
	aadd(aCab,{"C5_CLIENTE" , SA1->A1_COD				,nil})
	aadd(aCab,{"C5_LOJACLI" , SA1->A1_LOJA   			,nil})
	aadd(aCab,{"C5_CLIENT"  , SA1->A1_COD  				,nil})
	aadd(aCab,{"C5_LOJAENT" , SA1->A1_LOJA     			,nil})
	aadd(aCab,{"C5_CONDPAG" , cCondPagto				,nil})
	aadd(aCab,{"C5_TABELA"  , cTabSa1		  			,nil})
	aadd(aCab,{"C5_VEND1"   , SA1->A1_VEND				,nil})
	aadd(aCab,{"C5_TIPOCLI" , "F"						,nil})
	aadd(aCab,{"C5_TPFRETE" , "S"						,nil})
	aadd(aCab,{"C5_MENPAD"  , M->MV_PAR07				,nil})
	aadd(aCab,{"C5_MENNOTA" , M->A1_YMENNOT				,nil})

	For nI := 1 TO Len( aPreItens )
		nSc6Recno := SeekSC6Recno( aPreItens[ nI ][ nCodL ], DtoS( aPreItens[ nI ][ nDtRet ]) )
		IF nSc6Recno > 0
			EXIT
		ENDIF
	Next

	//	IF ALLTRIM( SA1->A1_COD ) $ '000993021,027187087,027686179,039315841'
	//		//'009874,009878,009880,009891,009968,009971,010000,010078'
	//		lAchei := .t.
	//	ENDIF

	IF nSc6Recno > 0
		SC6 -> ( dbGoTo( nSc6Recno ) )
		lExcPed := Posicione( "SC5", 1,  xFilial("SC5") + SC6->C6_NUM, "Found()" ) .AND. Empty( SC5->C5_NOTA )
	ENDIF

	IF nSc6Recno > 0 .and. lExcPed

		aCabExc := {}
		cSC5Key	:= xFilial("SC6") + SC6->C6_NUM

		Posicione( "SC5", 1, cSC5Key, "Found()" )

		aAdd(aCabExc, {"C5_NUM", SC6->C6_NUM, Nil} )

		WHILE SC6 -> ( ! Eof() .AND. xFilial("SC6") + SC6->C6_NUM == cSC5Key)


			aAdd( aItemExc, {} )

			nIt := Len( aItemExc )

			aAdd(aItemExc[ nIt ],{"LINPOS"		,	"C6_ITEM"		,	SC6->C6_ITEM 	})
			aAdd(aItemExc[ nIt ],{"C6_PRODUTO"	,	SC6->C6_PRODUTO	,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_LOCAL" 	,	SC6->C6_LOCAL	,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_QTDVEN" 	,	SC6->C6_QTDVEN	,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_PRCVEN" 	,	SC6->C6_PRCVEN	,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_VALOR" 	,	SC6->C6_VALOR	,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_TES" 		,	SC6->C6_TES		,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_CLI" 		,	SC6->C6_CLI		,	nil				})
			aAdd(aItemExc[ nIt ],{"C6_LOJA" 	,	SC6->C6_LOJA	,	nil				})
			aAdd(aItemExc[ nIt ],{"AUTDELETA"	,	"S"				,	nil				})


			SC6 -> ( dbSkip() )

		ENDDO

	ELSEIF nSc6Recno > 0 .AND. ! Empty( SC5->C5_NOTA )

		Aviso( "Atenção", "Existe um pedido "+ SC5->C5_NUM + " faturado para a locação " + aPreItens[1][nCodL] + " na data de geração "+ DtoC(aPreItens[1][nDtRet]) + " e não é possível gerar mais de um pedido para o mesmo período de locação.", { "Ok" })
		Return

	ENDIF

	//Exclusão de pedido de locação
	IF lExcPed //Len( aCabExc ) > 0

		LMSERROAUTO := .F.

		Pergunte("MTA410",.F.)
		IF Posicione("SC5",1,xFilial("SC5")+aCabExc[1,2],"FOUND()")

			MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabExc, aItemExc, 5)
			dbcommit()

			If lMsErroAuto
				MostraErro()
			endif
		ENDIF

		nSc6Recno := SeekSC6Recno( aPreItens[1][nCodL], DtoS(aPreItens[1][nDtRet]) )

	ENDIF

	IF nSc6Recno == 0

		FOR nI := 1 TO Len( aPreItens )

			cPrdLoc	:= Posicione( "SB1", 1, xFilial("SB1") + aPreItens[ nI ][ nPrd ], "B1_YPRDLOC" ) //ZZ1_FILIAL, ZZ1_CLIENT, ZZ1_LOJA, ZZ1_PRDAPL, R_E_C_N_O_, D_E_L_E_T_

			IF Empty(cPrdLoc)
				Aviso("Atenção!", "Não encontrado AMARRAÇÃO (locação: " + aPreItens[nI][nCodL]  + ") para o produto  " + rTrim(aPreItens[nI][nPrd] ) + ' aplicado ao cliente ' + SA1->A1_COD + "-" + SA1->A1_LOJA + " " + RTRIM( SA1->A1_NOME ) + "  e NÃO SERÁ COBRADA A LOCAÇÃO. Verifique.", { "Ok" } )
				LOOP
			ENDIF

			Posicione("SB1", 1, xFilial("SB1") + cPrdLoc, "FOUND()" )

			cDescPrd	:= rTrim( SB1->B1_DESC ) + " NF Rem: " + allTrim( aPreItens[nI][ nMsg ] )
			nNumDias	:= aPreItens[nI][nDias]
			nPrecoVenda	:= F08GetPreco(cTabSa1,cPrdLoc)

			IF nPrecoVenda == 0
				Aviso( "Atenção", "O produto " + Rtrim(cPrdLoc) + " não foi encontrado na tabela de preço " + cTabSa1 + ", para o cliente " + SA1 -> ( A1_COD + '-' +  A1_LOJA + " " + RTRIM( A1_NOME ) ) + ". Não será gerada cobrança de locação para o mesmo. Verifique.", { "Ok" })
				LOOP //colocar aviso de falta de tabela de preço
			ENDIF

			IF nNumDias < 30
				nPrecoVenda	:= Round( noRound( nPrecoVenda / 30, TamSx3("C6_PRCVEN")[2] + 1 ), TamSx3("C6_PRCVEN")[2] ) * nNumDias
			ENDIF

			nQuantidade := aPreItens[nI][nQtd]

			aadd( aTmp, { "C6_ITEM" 	,	StrZero( Len(aItens)+1, TamSx3("C6_ITEM")[1] ) , NIL } )
			aadd( aTmp, { "C6_PRODUTO" 	,	cPrdLoc								, NIL } )
			aadd( aTmp, { "C6_QTDVEN"	,	nQuantidade							, NIL } )
			aadd( aTmp, { "C6_PRCVEN"	,	nPrecoVenda							, NIL } )
			aadd( aTmp, { "C6_TOTAL"	,	nPrecoVenda	* nQuantidade			, NIL } )
			aadd( aTmp, { "C6_TES"		,	cTES 								, NIL } )
			aadd( aTmp, { "C6_YCODLOC"	,	aPreItens[ nI ][ nCodL ]			, NIL } )
			aadd( aTmp, { "C6_YGERLOC"	,	aPreItens[ nI ][ nDtRet]			, NIL } )
			aadd( aTmp, { "C6_DESCRI"	,	cDescPrd   							, NIL } )
			aadd( aTmp, { "C6_SUGENTR"  ,   dFimPeriodo    						, nil})

			aAdd( aItens, aClone(aTmp) )
			aTmp := {}

		NEXT

		//Inclusão de pedido de locação
		IF Len( aItens ) > 0

			LMSERROAUTO := .F.
			Pergunte("MTA410",.F.)

			MSExecAuto( { | x ,y ,z | mata410(x ,y ,z) }, aCab, aItens, 3 )

			If lMsErroAuto
				MostraErro()
			endif

		ENDIF
	ENDIF

	aItens  	:= {}
	aCab 		:= {}
	aPreItens 	:= {}

Return

Static Function SeekSC6Recno( cCodLoc, dDtGer )

	Local nRecnoSc6 := 0

	BEGINSQL ALIAS "qrySC6"

		%noparser%

		select R_E_C_N_O_ C6_RECNO
		FROM %Table:SC6% SC6
		WHERE
		D_E_L_E_T_ 	= '' 				AND
		C6_FILIAL	= %xFilial:SC6%		AND
		C6_YCODLOC 	= %Exp:cCodLoc% 	AND
		C6_YGERLOC 	= %Exp:dDtGer%

	ENDSQL

	nRecnoSc6 := qrySC6->C6_RECNO

	qrySC6-> ( dbCloseArea() )

Return nRecnoSc6

Static Function F08GetPreco( cTabPrc, cPrdLoc )
	Local nPreco := Posicione("DA1",1, xFilial("DA1") + cTabPrc + cPrdLoc, "DA1_PRCVEN")
	//	IF nPreco == 0
	//		Aviso("Atenção!", "Não encontrado preço para o produto " + rTrim(cPrdLoc) + " na tabela " + cTabPrc + ". Verifique.", { "Ok" } )
	//	ENDIF
Return nPreco
//Busca datas e quantidades de notas com devolvoluções realizada dentro do período de locação
Static Function F08GetDevol( dIniPeriodo, dFimPeriodo )

	Local cNextArea := GetNextAlias()
	Local aDevolucao := {}

	BeginSql Alias cNextArea

		column D1_DTDIGIT 	as date
		column D1_QUANT 	as Numeric(12,4)

		SELECT
		//		(CASE WHEN D1_YDTRET = '' THEN D1_EMISSAO ELSE D1_YDTRET END) D1_EMISSAO, D1_FORNECE, D1_LOJA, sum( D1_QUANT ) D1_QUANT //D1_DOC, D1_SERIE, D1_QUANT, D1_EMISSAO
		D1_COD, D1_DOC, D1_DTDIGIT, D1_FORNECE, D1_LOJA, sum( D1_QUANT ) D1_QUANT //D1_DOC, D1_SERIE, D1_QUANT, D1_EMISSAO
		FROM %table:SD1% SD1
		WHERE
		SD1.%NotDel% AND
		D1_FILIAL	= 		%xFilial:SD1% 			AND
		D1_EMISSAO 	BETWEEN %Exp:dIniPeriodo% 		AND %Exp:dFimPeriodo% AND
		D1_NFORI 	= 		%Exp:ZZ2->ZZ2_NOTREM% 	AND
		D1_SERIORI	= 		%Exp:ZZ2->ZZ2_SERIE%  	AND
		D1_FORNECE 	= 		%Exp:ZZ2->ZZ2_CLIENT% 	AND
		D1_LOJA 	= 		%Exp:ZZ2->ZZ2_LOJA%		AND
		D1_COD		=  		%Exp:ZZ2->ZZ2_PRDAPL%	AND
		D1_IDENTB6	=		%Exp:ZZ2->ZZ2_IDENB6%

		GROUP BY D1_COD, D1_DOC, D1_DTDIGIT, D1_FORNECE, D1_LOJA

	EndSql

	dbSelectArea( cNextArea )

	//Caso tenha retornado antes do fim do período, usa data de retorno
	//  Min( dFimPeriodo, ( cNextArea )->D1_DTDIGIT )
	
	dbEval( { || aAdd( aDevolucao, { D1_COD, D1_DTDIGIT, D1_QUANT, ZZ2 -> ( ZZ2_SERIE + ZZ2_NOTREM ) + ' - Ret.: ' + (cNextArea)->D1_DOC,  0, D1_FORNECE, D1_LOJA, ZZ2 -> ZZ2_CODLOC, Min( dFimPeriodo, (cNextArea)->D1_DTDIGIT ) } ) } )
	//									1  , 	2	   , 	3	 ,  4								,  5, 	  6		,   7    , 8			    , 9
Return aClone( aDevolucao )

//Static Function F08RunTrigger( nPosGet, cCampo, nPosCpo )
//
//	IF ExistTrigger( cCampo )
//		__ReadVar := "M->" + cCampo
//		ReadVar( aCols[ nPosGet ][ nPosCpo ] )
//		RunTrigger( 2, nPosGet, nil,,cCampo)
//	ENDIF
//
//Return

//Static Function sd2Refresh()
//
//	oBrwSD2 :CleanFilter()
//	oBrwSD2 :SetFilterDefault( "SD2->D2_YCODLOC = ZZ2->ZZ2_CODLOC .AND. SD2->D2_FILIAL = ZZ2->ZZ2_FILIAL"  )
//	oBrwSD2	:ExecuteFilter(.T.)
//	oBrwSD2	:Refresh()
//
//Return .T.

//Static Function sd1Refresh()
//
//	oBrwSD1 :CleanFilter()
//	oBrwSD1 :SetFilterDefault( "SD1->D1_YCODLOC = ZZ2->ZZ2_CODLOC  .AND. SD1->D1_FILIAL = ZZ2->ZZ2_FILIAL"  )
//	oBrwSD1	:ExecuteFilter(.T.)
//	oBrwSD1	:Refresh()
//
//Return .T.

/*/{Protheus.doc} F08LoadSB6
Monta e processa registro em poder de terceiro
@author    aco
@since     20/08/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
@obs Central de acompanhmento e cobrança de locações
/*/
Static Function F08LoadSB6(cCliDe, cLojDe, cCliAte, cLojAte)

	Local qryZZ2
	Local nQtdZZ2:= 0
	Local cChave
	Local zz2Recno

	Default cCliDe	:= m->A1_COD
	Default cCliAte	:= m->A1_COD
	Default cLojDe	:= m->A1_LOJA
	Default cLojAte	:= m->A1_LOJA

	dbSelectArea("ZZ2")
	ZZ2->(DBClearFilter())

	qryZZ2 := F08qryZZ2(  GetNextAlias(), cCliDe, cLojDe, cCliAte, cLojAte )

	Private cCodLoc := ""

	dbSelectArea( "ZZ2" )
	dbSetOrder( 5 )

	dbSelectArea( qryZZ2 )

	//	IF ( qryZZ2 ) -> ( ! EOF() )

	dbEval( { || nQtdZZ2 += 1 } )

	ProcRegua( nQtdZZ2 )
	dbGoTop()

	BEGIN TRANSACTION

		dLastCob 	:= CtoD("")
		cNotaFiscal :=  ""

		//Transporta query para tabela ZZ2
		WHILE ( qryZZ2 ) -> ( ! EOF() )

			IncProc()

			cChave 	:= (qryZZ2) -> ZZ2_IDENB6+(qryZZ2) -> ZZ2_NOTREM+(qryZZ2) -> ZZ2_PRDAPL

			IF ! Posicione("ZZ2", 5, xFilial("ZZ2") + cChave, "Found()")

				lNewRecno := .T.

				IF cNotaFiscal <>  ( qryZZ2 ) -> ( ZZ2_NOTREM + ZZ2_SERIE )

					cCodLoc	:= GetSXENum( "ZZ2", "ZZ2_CODLOC" )
					lConfirmSX8 := .T.

				ENDIF
			ELSE
				lNewRecno 	:= .F.
				cCodLoc 	:= ZZ2->ZZ2_CODLOC
			ENDIF

			F08UpdZZ2( lNewRecno, qryZZ2, cCodLoc, dLastCob )

			cNotaFiscal :=  ( qryZZ2 ) -> ( ZZ2_NOTREM + ZZ2_SERIE )

			( qryZZ2 ) -> ( dbSkip() )

		ENDDO

		//Atualiza ZZ2 como base na Query
		ZZ2 -> ( dbGoTop() )

		lNewRecno := .F.

		WHILE ZZ2 -> ( ! EOF() )

			IncProc()

			cChave 	:= ZZ2 -> ZZ2_PRDAPL + ZZ2 -> ZZ2_CLIENT + ZZ2 -> ZZ2_LOJA + ZZ2 -> ZZ2_IDENB6 //1 - B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_IDENT

			IF Posicione("SB6", 1, xFilial("ZZ2") + cChave, "Found()")

				RecLock("ZZ2",.F.)
				ZZ2->ZZ2_SALDO  := SB6 -> B6_SALDO
				ZZ2->ZZ2_ULTRET := SB6 -> B6_UENT
				ZZ2-> ( msUnLock() )

			ENDIF

			dLastCob := F08LastCob( ZZ2->ZZ2_CODLOC )

			IF ! EMPTY(dLastCob) .AND. dLastCob <> ZZ2->ZZ2_ULTCOB
				RECLOCK("ZZ2",.F.)
				ZZ2->ZZ2_ULTCOB := dLastCob
				ZZ2->( msUnLock() )
			ENDIF

			ZZ2 -> ( dbSkip() )

		ENDDO

	END TRANSACTION

	//	ENDIF

	( qryZZ2 ) -> ( dbCloseArea() )

Return

Static Function SeekZZ2Recno( cSerie, cNFRem, cCliente, cLoja, cPrdAplic )

	Local nRecnoSc6 := 0

	BEGINSQL ALIAS "qryZZ2"

		%noparser%

		select R_E_C_N_O_ ZZ2_RECNO
		FROM %Table:ZZ2% ZZ2
		WHERE
		D_E_L_E_T_ 	= '' 				AND
		ZZ2_FILIAL	= %xFilial:ZZ2%		AND
		ZZ2_PRDAPL 	= %Exp:cPrdAplic% 	AND
		ZZ2_SERIE 	= %Exp:cSerie%		AND
		ZZ2_NOTREM 	= %Exp:cNFRem%		AND
		ZZ2_CLIENT	= %Exp:cCliente%	AND
		ZZ2_LOJA	= %Exp:cLoja%


	ENDSQL

	nRecnoZZ2 := qryZZ2->ZZ2_RECNO

	qryZZ2-> ( dbCloseArea() )

Return nRecnoZZ2

Static Function F08UpdZZ2( lNewRecno, qryZZ2, cCodLoc, dLastCob )

	Local aGetArea 		:= GetArea()
	Local lConfirmSX8	:= .F.
	//	Local cChave 		:= (qryZZ2) -> ZZ2_SERIE+(qryZZ2) -> ZZ2_NOTREM+(qryZZ2) -> ZZ2_CLIENT+(qryZZ2) -> ZZ2_LOJA+(qryZZ2) -> ZZ2_PRDAPL

	IF lNewRecno

		RecLock("ZZ2",.T.)

		ZZ2->ZZ2_FILIAL := ( qryZZ2 ) -> ZZ2_FILIAL
		ZZ2->ZZ2_CODLOC := cCodLoc
		ZZ2->ZZ2_CLIENT := ( qryZZ2 ) -> ZZ2_CLIENT
		ZZ2->ZZ2_LOJA   := ( qryZZ2 ) -> ZZ2_LOJA
		ZZ2->ZZ2_SERIE  := ( qryZZ2 ) -> ZZ2_SERIE
		ZZ2->ZZ2_NOTREM := ( qryZZ2 ) -> ZZ2_NOTREM
		ZZ2->ZZ2_PRDAPL := ( qryZZ2 ) -> ZZ2_PRDAPL
		ZZ2->ZZ2_QTDAPL := ( qryZZ2 ) -> ZZ2_QTDAPL
		ZZ2->ZZ2_DTAAPL	:= ( qryZZ2 ) -> ZZ2_DTAAPL
		ZZ2->ZZ2_DTAAPL := ( qryZZ2 ) -> ZZ2_DTAAPL
		ZZ2->ZZ2_METINC := ( qryZZ2 ) -> ZZ2_METINC
		ZZ2->ZZ2_PRCUNI := ( qryZZ2 ) -> ZZ2_PRUNIT
		ZZ2->ZZ2_IDENB6 := ( qryZZ2 ) -> ZZ2_IDENB6
		ZZ2->ZZ2_ULTRET := ( qryZZ2 ) -> ZZ2_ULTRET
		ZZ2->ZZ2_TES    := ( qryZZ2 ) -> ZZ2_TES
		ZZ2->ZZ2_SALDO  := ( qryZZ2 ) -> ZZ2_SALDO
		// ZZ2->ZZ2_ULTCOB := dLastCob 	//Ultima cobrança

		ZZ2-> ( msUnLock() )

		u_F08Habil()

		dbSelectArea("SD2")
		Posicione( "SD2", 3, xFilial("SD2") + ZZ2->ZZ2_NOTREM + ZZ2->ZZ2_SERIE + ZZ2->ZZ2_CLIENT, "FOUND()")

		WHILE ZZ2->( ZZ2_FILIAL + ZZ2_NOTREM + ZZ2_SERIE + ZZ2_CLIENT ) == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE ) .AND.  SD2->( ! EOF() )

			RecLock("SD2",.F.)
			SD2->D2_YCODLOC := ZZ2->ZZ2_CODLOC
			SD2-> ( msUnLock() )

			//			IF Posicione("SC6", 1, xFilial("SC6") + SD2->(D2_PEDIDO+D2_ITEMPV), "FOUND()")
			//				RecLock("SC6",.F.)
			//				SC6->C6_YCODLOC := cCodLoc
			//				SC6-> ( msUnLock() )
			//			ENDIF

			SD2->( dbSkip() )

		ENDDO

		IF 	lConfirmSX8
			ConfirmSX8()
		ENDIF
	ELSE

		RecLock("ZZ2",.F.)
		ZZ2->ZZ2_SALDO  := ( qryZZ2 ) -> ZZ2_SALDO
		ZZ2->ZZ2_ULTRET := ( qryZZ2 ) -> ZZ2_ULTRET
		// ZZ2->ZZ2_ULTCOB := dLastCob	//Ultima cobrança
		ZZ2-> ( msUnLock() )

	ENDIF

	RestArea( aGetArea )
Return

Static Function F08LastCob( cCodLoc )

	Local dUltCob := CtoD("")

	BeginSql Alias "qrySD2"

		%noparser%

		COLUMN ZZ2_ULTCOB AS DATE

		// SELECT
		// MAX( D2_EMISSAO ) ZZ2_ULTCOB
		// FROM
		// %Table:SD2% SD2
		// WHERE
		// SD2.D_E_L_E_T_ 		= '' 			AND
		// SD2.D2_FILIAL 		= %xFilial:SD2% AND
		// D2_YCODLOC			= %Exp:cCodLoc% AND
		// D2_YCODLOC			<> ''			AND
		// EXISTS ( SELECT TOP 1 1 FROM %table:SF4% WHERE F4_CODIGO = D2_TES AND D_E_L_E_T_  = '' AND F4_DUPLIC = 'S' )

		SELECT
		    MAX( C6_DATFAT ) ZZ2_ULTCOB
		FROM
		%Table:SC6% SC6
		WHERE
		SC6.D_E_L_E_T_ 		= '' 			AND
		SC6.C6_FILIAL 		= %xFilial:SC6% AND
		// SC6.C6_NOTA      = '000006750'   AND
		SC6.C6_NOTA        <> ''   			AND
		SC6.C6_YCODLOC		= %Exp:cCodLoc% AND
		SC6.C6_YCODLOC	   <> ''			AND
		EXISTS ( SELECT TOP 1 1 FROM SF4010 WHERE F4_CODIGO = C6_TES AND D_E_L_E_T_  = '' AND F4_DUPLIC = 'S' )

	EndSql

	dUltCob := qrySD2->ZZ2_ULTCOB

	qrySD2 -> ( dbCloseArea() )

Return dUltCob

Static Function F08qryZZ2( qryZZ2, cCliDe, cLojDe, cCliAte, cLojAte )

	BeginSql Alias qryZZ2

		COLUMN ZZ2_DTAAPL AS DATE
		COLUMN ZZ2_ULTRET AS DATE
		COLUMN ZZ2_QTDAPL AS NUMERIC(9,0)
		COLUMN ZZ2_SALDO  AS NUMERIC(9,0)
		COLUMN ZZ2_PRUNIT AS NUMERIC(12,2)

		%noparser%

		SELECT
		B6_FILIAL		ZZ2_FILIAL,
		B6_PRODUTO		ZZ2_PRDAPL,
		B6_DOC 			ZZ2_NOTREM,
		B6_SERIE		ZZ2_SERIE,
		B6_EMISSAO		ZZ2_DTAAPL,
		B6_CLIFOR 		ZZ2_CLIENT,
		B6_LOJA 		ZZ2_LOJA,
		B6_QUANT		ZZ2_QTDAPL,
		B6_SALDO		ZZ2_SALDO,
		B6_PRUNIT		ZZ2_PRUNIT,
		B6_TES			ZZ2_TES,
		B6_IDENT		ZZ2_IDENB6,
		'A'				ZZ2_METINC,
		ISNULL((
		SELECT MAX( D1_EMISSAO )
		FROM %table:SD1% SD1
		WHERE
		SD1.%NotDel% 				AND
		//		D1_FILIAL	= B6_FILIAL 	AND
		//		D1_NFORI 	= B6_DOC 		AND
		//		D1_SERIORI	= B6_SERIE 		AND
		//		D1_FORNECE	= B6_CLIFOR  	AND
		//		D1_LOJA		= B6_LOJA		AND
		D1_IDENTB6	= B6_IDENT
		),'') ZZ2_ULTRET
		FROM
		%Table:SB6% SB6, %Table:SB1% SB1, %Table:SA1% SA1
		WHERE
		SB6.B6_TPCF			= 'C'			AND
		SB6.D_E_L_E_T_ 		= '' 			AND
		SB6.B6_TES			> '500'			AND
		SB1.D_E_L_E_T_ 		= '' 			AND
		SA1.D_E_L_E_T_ 		= '' 			AND
		SB6.B6_FILIAL 		= %xFilial:SB6% AND
		SB1.B1_FILIAL 		= %xFilial:SB1% AND
		SA1.A1_FILIAL 		= %xFilial:SA1% AND
		SB6.B6_CLIFOR BETWEEN %Exp:cCliDe%	AND %Exp:cCliAte% AND
		SB6.B6_LOJA   BETWEEN %Exp:cLojDe%	AND %Exp:cLojAte% AND
		SB6.B6_LOCAL		= '01'			AND
		//		SB6.B6_SALDO 		> 0				AND
		SB6.B6_PODER3		= 'R'			AND
		//		LEN(SB6.B6_PRODUTO) = 10 			AND
		//		B6_PRODUTO 			LIKE '005%' 	AND
		B1_YPRDLOC 			LIKE '0023%' 	AND
		SB1.B1_COD			= SB6.B6_PRODUTO AND
		SA1.A1_COD			= SB6.B6_CLIFOR	AND
		SA1.A1_LOJA			= SB6.B6_LOJA	AND
		SA1.A1_YSTAZZ2	    = 'S'			//AND
		// NOT EXISTS (SELECT TOP 1 ( CASE WHEN ZZ2_STATUS IS NULL THEN 1 WHEN ZZ2_STATUS = '1' THEN 1 ELSE 0 END )
		// FROM ZZ2010 X
		// WHERE	X.ZZ2_FILIAL= B6_FILIAL AND B6_PRODUTO 	= ZZ2_PRDAPL AND
		// ZZ2_CLIENT = B6_CLIFOR AND ZZ2_LOJA 	= B6_LOJA 	 AND
		// ZZ2_NOTREM  = B6_DOC    AND B6_SERIE 	= ZZ2_SERIE and  D_E_L_E_T_ = '')
		ORDER BY ZZ2_CLIENT, ZZ2_LOJA, ZZ2_NOTREM, ZZ2_SERIE

		//	SB6.B6_TES 		   IN ( '757','760' ) AND
		//		ORDER BY ZZ2_NOTREM, ZZ2_SERIE, ZZ2_PRDAPL, ZZ2_DTAAPL, ZZ2_CLIENT, ZZ2_LOJA

	EndSql

Return qryZZ2
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opcoes do menu.
@author Felipe Nathan Welter
@since 26/02/2013
@version P11
/*/
//-------------------------------------------------------------------
//Static Function MenuDef()
//
//	Local aRotina := {}
//
//	ADD OPTION aRotina TITLE 'Locações' ACTION "MsgRun('Aguarde processando locações...','Central de Locações', {|| u_FAT8Central() })" OPERATION 2 ACCESS 0
//
//Return aRotina

Static Function FAT8GetCpo( aVetor, _aHead, _aCols )

	Local nX

	Default _aCols := {}
	Default aVetor := {}
	Default _aHead := {}

	dbSelectArea("SX3")
	dbSetOrder(02)

	For nX := 1 To Len( aVetor )

		If dbSeek( aVetor[ nX ] )
			aAdd ( _aHead, { TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
		EndIf

	Next nX

	_aCols := {{}}

	For nX := 1 To Len( _aHead )

		aAdd( _aCols[1], CriaVar( _aHead[ nX ][ 2 ], .F. )  )

	Next nX

	aAdd( _aCols[1], .F.  )

Return { _aHead, _aCols }

Function u_F08LocCa()

	msgRun( "Processando...","Aguarde!",{ || F08Pedido() } )

	ZZ2->( dbSetOrder( 1 ) )

	IF Type("oBrwZZ2") == "O"
		oBrwZZ2:Refresh(.T.)
	ENDIF

Return

Function u_F08LocGe()

	msgRun( "Processando...","Aguarde!",{ || IIF( PERGUNTE("TECFAT08",.T.), F08Pedido(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04), ) } )

	ZZ2->( dbSetOrder( 1 ) )

	IF Type("oBrwZZ2") == "O"
		oBrwZZ2:Refresh(.T.)
	ENDIF

Return

Function u_F08Habil()

	( RecLock("ZZ2",.F.),	ZZ2->ZZ2_STATUS := "1",	msUnLock() )

	IF Type("oBrwZZ2") == "O"
		oBrwZZ2:Refresh(.T.)
	ENDIF

Return

Function u_F08Desab()

	( RecLock("ZZ2",.F.),	ZZ2->ZZ2_STATUS := "2",	msUnLock() )

	IF Type("oBrwZZ2") == "O"
		oBrwZZ2:Refresh(.T.)
	ENDIF

Return

Function u_F08NewPrd(nOper)

	Local aArea			:= GetArea()
	Local nRecnoSB1		:= SB1->( Recno() )
	LOCAL cAlias		:= GetNextAlias()
	LOCAL MV_YCODLOC

	Default nOper 		:= 1 //1=Código do próximo produto a ser inserido 2=Insere o próximo produto na SB1

	PRIVATE B1YPRDAPL	:= Space(15)
	PRIVATE B1COD		:= Space(15)
	PRIVATE B1CONINI 	:= Space(08)
	PRIVATE B1CONTA 	:= Space(10)
	PRIVATE B1DATREF 	:= ctod("")
	PRIVATE B1DESC 		:= Space(90)
	PRIVATE B1FILIAL 	:= Space(02)
	PRIVATE B1GARANT 	:= Space(01)
	PRIVATE B1GRUPO 	:= Space(04)
	PRIVATE B1LOCPAD 	:= Space(02)
	PRIVATE B1POSIPI    := Space(08)
	PRIVATE B1TIPO 		:= Space(02)
	PRIVATE B1UM 		:= Space(02)
	PRIVATE B1YONU 		:= Space(04)

	IF ! INCLUI .or. ! M->B1_GRUPO == "0050"
		RETURN M->B1_YPRDLOC
	ENDIF

	BEGINSQL ALIAS cAlias

		SELECT
		MAX( B1_COD ) B1_YPRDLOC
		FROM
		%table:SB1% SB1
		WHERE
		SB1.B1_FILIAL 	= %xFilial:SB1% AND
		B1_COD	 	 LIKE '0023%'		AND
		B1_GRUPO 		= '0023'		AND
		SB1.D_E_L_E_T_ 	= ''


	ENDSQL

	MV_YCODLOC	:= GetNewPar( "MV_YCODLOC", "000000" )

	IF VAL( MV_YCODLOC ) == 0

		IF ! SX6->( dbSeek( xFilial( "SX6" ) + "MV_YCODLOC" ) )
			RecLock( "SX6", .T. )
			SX6->X6_FIL		:= xFilial( "SB1" )
			SX6->X6_VAR 	:= "MV_YCODLOC"
			SX6->X6_TIPO	:= "C"
			SX6->X6_PROPRI	:= "U"
			SX6->X6_DESCRIC := "Sequencia para código do produto locação"
			SX6-> ( msUnLock() )
		ENDIF

		PUTMV( "MV_YCODLOC", '000001' )
		MV_YCODLOC	:= GetMv( "MV_YCODLOC" )

	ENDIF

	m->MV_YCODLOC:= MaxChar( MV_YCODLOC, SubStr( (cAlias) -> B1_YPRDLOC, 5, 6 ) )
	m->B1YPRDLOC := '0023' + m->MV_YCODLOC

	WHILE Posicione( "SB1", 1, xFilial("SB1") + m->B1YPRDLOC, "FOUND()" )

		MV_YCODLOC  := Soma1( MV_YCODLOC )
		PUTMV( "MV_YCODLOC", MV_YCODLOC )

		m->B1YPRDLOC := '0023' + MV_YCODLOC

	ENDDO

	IF nOper == 2  // Insere o próximo produto LOCAÇÃO na SB1

		SB1->( dbGoTo( nRecnoSB1 ) )

		m->B1COD		:= m->B1YPRDLOC
		m->B1CONINI 	:= SB1->B1_CONINI
		m->B1CONTA 		:= SB1->B1_CONTA
		m->B1DATREF 	:= SB1->B1_DATREF
		m->B1DESC 		:= "LOCACAO " + ALLTRIM(SB1->B1_DESC)
		m->B1FILIAL 	:= SB1->B1_FILIAL
		m->B1GARANT 	:= SB1->B1_GARANT
		m->B1GRUPO 		:= '0023' //SB1->B1_GRUPO
		m->B1LOCPAD 	:= SB1->B1_LOCPAD
		m->B1TIPO 		:= 'SV'	//SB1->B1_TIPO
		m->B1UM 		:= SB1->B1_UM
		m->B1YONU 		:= SB1->B1_YONU


		RecLock( "SB1", .T. )

		SB1->B1_COD		 	:= m->B1COD
		SB1->B1_CONINI 		:= m->B1CONINI
		SB1->B1_CONTA 		:= m->B1CONTA
		SB1->B1_DATREF 		:= m->B1DATREF
		SB1->B1_DESC 		:= m->B1DESC
		SB1->B1_FILIAL 		:= m->B1FILIAL
		SB1->B1_GARANT 		:= m->B1GARANT
		SB1->B1_GRUPO 		:= m->B1GRUPO
		SB1->B1_LOCPAD 		:= m->B1LOCPAD
		SB1->B1_TIPO 		:= m->B1TIPO
		SB1->B1_UM 			:= m->B1UM
		SB1->B1_YONU 		:= m->B1YONU

		SB1->( msUnLock() )

	ENDIF

	RestArea( aArea )

Return m->B1YPRDLOC

User Function MsgPadrao()

	Local dDataRef := SC5->C5_EMISSAO

	IF SA1->A1_YDIAFEC < '30'
		dDataRef	:= MonthSub( SC5->C5_EMISSAO, 1 )
	ENDIF

Return MesExtenso(dDataRef)+"/"+ allTrim( Str(YEAR(dDataRef)) )