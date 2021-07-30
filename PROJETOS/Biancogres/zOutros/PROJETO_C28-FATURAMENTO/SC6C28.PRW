#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
	"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
	"    border-top-width: 3px; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"+;
	"QPushButton:pressed {	color: #FFFFFF; "+;
	"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
	"    border-top-width: 3px; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} SC6C28
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function SC6C28( cEmpAmb, cFilAmb )

	Local   aSay      := {}
	Local   aButton   := {}
	Local   aMarcadas := {}
	Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
	Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
	Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
	Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
	Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
	Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
	Local   cDesc6    := ""
	Local   cDesc7    := ""
	Local   cMsg      := ""
	Local   lOk       := .F.
	Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

	Private oMainWnd  := NIL
	Private oProcess  := NIL

	#IFDEF TOP
		TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
	#ENDIF

	__cInterNet := NIL
	__lPYME     := .F.

	Set Dele On

// Mensagens de Tela Inicial
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )
	aAdd( aSay, cDesc4 )
	aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
	aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	If lAuto
		lOk := .T.
	Else
		FormBatch(  cTitulo,  aSay,  aButton )
	EndIf

	If lOk

		If FindFunction( "MPDicInDB" ) .AND. MPDicInDB()
			cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram no Banco de Dados e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no formato ISAM (.dbf ou .dtc)."

			If lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( cMsg )
				ConOut( DToC(Date()) + "|" + Time() + cMsg )
			Else
				MsgInfo( cMsg )
			EndIf

			Return NIL
		EndIf

		If lAuto
			aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
		Else

			If !FWAuthAdmin()
				Final( "Atualização não Realizada." )
			EndIf

			aMarcadas := EscEmpresa()
		EndIf

		If !Empty( aMarcadas )
			If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
				oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
				oProcess:Activate()

				If lAuto
					If lOk
						MsgStop( "Atualização Realizada.", "SC6C28" )
					Else
						MsgStop( "Atualização não Realizada.", "SC6C28" )
					EndIf
					dbCloseAll()
				Else
					If lOk
						Final( "Atualização Realizada." )
					Else
						Final( "Atualização não Realizada." )
					EndIf
				EndIf

			Else
				Final( "Atualização não Realizada." )

			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
	Local   aInfo     := {}
	Local   aRecnoSM0 := {}
	Local   cAux      := ""
	Local   cFile     := ""
	Local   cFileLog  := ""
	Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
	Local   cTCBuild  := "TCGetBuild"
	Local   cTexto    := ""
	Local   cTopBuild := ""
	Local   lOpen     := .F.
	Local   lRet      := .T.
	Local   nI        := 0
	Local   nPos      := 0
	Local   nRecno    := 0
	Local   nX        := 0
	Local   oDlg      := NIL
	Local   oFont     := NIL
	Local   oMemo     := NIL

	Private aArqUpd   := {}

	If ( lOpen := MyOpenSm0(.T.) )

		dbSelectArea( "SM0" )
		dbGoTop()

		While !SM0->( EOF() )
			// Só adiciona no aRecnoSM0 se a empresa for diferente
			If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
					.AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
				aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
			EndIf
			SM0->( dbSkip() )
		End

		SM0->( dbCloseArea() )

		If lOpen

			For nI := 1 To Len( aRecnoSM0 )

				If !( lOpen := MyOpenSm0(.F.) )
					MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
					Exit
				EndIf

				SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

				RpcSetType( 3 )
				RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

				lMsFinalAuto := .F.
				lMsHelpAuto  := .F.

				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " " )
				AutoGrLog( " Dados Ambiente" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
				AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
				AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
				AutoGrLog( " Environment........: " + GetEnvServer()  )
				AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
				AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
				AutoGrLog( " Versão.............: " + GetVersao(.T.) )
				AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
				AutoGrLog( " Computer Name......: " + GetComputerName() )

				aInfo   := GetUserInfo()
				If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
					AutoGrLog( " " )
					AutoGrLog( " Dados Thread" )
					AutoGrLog( " --------------------" )
					AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
					AutoGrLog( " Estação............: " + aInfo[nPos][2] )
					AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
					AutoGrLog( " Environment........: " + aInfo[nPos][6] )
					AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
				EndIf
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " " )

				If !lAuto
					AutoGrLog( Replicate( "-", 128 ) )
					AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
				EndIf

				oProcess:SetRegua1( 8 )

				//------------------------------------
				// Atualiza o dicionário SX2
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX2()

				//------------------------------------
				// Atualiza o dicionário SX3
				//------------------------------------
				FSAtuSX3()

				//------------------------------------
				// Atualiza o dicionário SIX
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSIX()

				oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				oProcess:IncRegua2( "Atualizando campos/índices" )

				// Alteração física dos arquivos
				__SetX31Mode( .F. )

				If FindFunction(cTCBuild)
					cTopBuild := &cTCBuild.()
				EndIf

				For nX := 1 To Len( aArqUpd )

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
								!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
							TcInternal( 25, "CLOB" )
						EndIf
					EndIf

					If Select( aArqUpd[nX] ) > 0
						dbSelectArea( aArqUpd[nX] )
						dbCloseArea()
					EndIf

					X31UpdTable( aArqUpd[nX] )

					If __GetX31Error()
						Alert( __GetX31Trace() )
						MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
						AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
					EndIf

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						TcInternal( 25, "OFF" )
					EndIf

				Next nX

				//------------------------------------
				// Atualiza o dicionário SX7
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX7()

				//------------------------------------
				// Atualiza o dicionário SXB
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSXB()

				//------------------------------------
				// Atualiza os helps
				//------------------------------------
				oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuHlp()

				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
				AutoGrLog( Replicate( "-", 128 ) )

				RpcClearEnv()

			Next nI

			If !lAuto

				cTexto := LeLog()

				Define Font oFont Name "Mono AS" Size 5, 12

				Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

				@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
				oMemo:bRClicked := { || AllwaysTrue() }
				oMemo:oFont     := oFont

				Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
				Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
					MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

				Activate MsDialog oDlg Center

			EndIf

		EndIf

	Else

		lRet := .F.

	EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
	Local aEstrut   := {}
	Local aSX2      := {}
	Local cAlias    := ""
	Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
	Local cEmpr     := ""
	Local cPath     := ""
	Local nI        := 0
	Local nJ        := 0

	AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

	aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
		"X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
		"X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


	dbSelectArea( "SX2" )
	SX2->( dbSetOrder( 1 ) )
	SX2->( dbGoTop() )
	cPath := SX2->X2_PATH
	cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
	cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SC6
//
	aAdd( aSX2, { ;
		'SC6'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SC6'+cEmpr																, ; //X2_ARQUIVO
	'Itens dos Pedidos de Venda'											, ; //X2_NOME
	'Ítems de los Pedidos de Venta'											, ; //X2_NOMESPA
	'Sales Orders Items'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO'									, ; //X2_UNICO
	'C6_NUM+C6_ITEM+C6_PRODUTO'												, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	5																		} ) //X2_MODULO

//
// Atualizando dicionário
//
	oProcess:SetRegua2( Len( aSX2 ) )

	dbSelectArea( "SX2" )
	dbSetOrder( 1 )

	For nI := 1 To Len( aSX2 )

		oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

		If !SX2->( dbSeek( aSX2[nI][1] ) )

			If !( aSX2[nI][1] $ cAlias )
				cAlias += aSX2[nI][1] + "/"
				AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
			EndIf

			RecLock( "SX2", .T. )
			For nJ := 1 To Len( aSX2[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
						FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
					Else
						FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
					EndIf
				EndIf
			Next nJ
			MsUnLock()

		Else

			If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
				RecLock( "SX2", .F. )
				SX2->X2_UNICO := aSX2[nI][12]
				MsUnlock()

				If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
					TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				EndIf

				AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
			EndIf

			RecLock( "SX2", .F. )
			For nJ := 1 To Len( aSX2[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
						FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
					EndIf

				EndIf
			Next nJ
			MsUnLock()

		EndIf

	Next nI

	AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
	Local aEstrut   := {}
	Local aSX3      := {}
	Local cAlias    := ""
	Local cAliasAtu := ""
	Local cMsg      := ""
	Local cSeqAtu   := ""
	Local cX3Campo  := ""
	Local cX3Dado   := ""
	Local lTodosNao := .F.
	Local lTodosSim := .F.
	Local nI        := 0
	Local nJ        := 0
	Local nOpcA     := 0
	Local nPosArq   := 0
	Local nPosCpo   := 0
	Local nPosOrd   := 0
	Local nPosSXG   := 0
	Local nPosTam   := 0
	Local nPosVld   := 0
	Local nSeqAtu   := 0
	Local nTamSeek  := Len( SX3->X3_CAMPO )

	AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

	aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
		{ "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
		{ "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
		{ "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
		{ "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
		{ "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
		{ "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

	aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATENÇÃO ---
// Coloque .F. na 2a. posição de cada elemento do array, para os dados do SX3
// que não serão atualizados quando o campo já existir.
//

//
// Campos Tabela SC6
//
	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
	{ 'Sucursal del Sistema'												, .T. }, ; //X3_DESCSPA
	{ 'System Branch'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item'																, .T. }, ; //X3_TITULO
	{ 'Item'																, .T. }, ; //X3_TITSPA
	{ 'Item'																, .T. }, ; //X3_TITENG
	{ 'Numero do Item no Pedido'											, .T. }, ; //X3_DESCRIC
	{ 'Numero del Item del Pedid'											, .T. }, ; //X3_DESCSPA
	{ 'Item Number in Order'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(129) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PRODUTO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Produto'																, .T. }, ; //X3_TITULO
	{ 'Producto'															, .T. }, ; //X3_TITSPA
	{ 'Product'																, .T. }, ; //X3_TITENG
	{ 'Codigo do Produto'													, .T. }, ; //X3_DESCRIC
	{ 'Código del producto'													, .T. }, ; //X3_DESCSPA
	{ 'Product Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.(A093Prod().And.a410Produto().And.A410MultT())'			, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SB1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_FRRT03V3() .And. U_FCOMVL01()'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '030'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DESCRI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descricao'															, .T. }, ; //X3_TITULO
	{ 'Descripcion'															, .T. }, ; //X3_TITSPA
	{ 'Description'															, .T. }, ; //X3_TITENG
	{ 'Descricao Auxiliar'													, .T. }, ; //X3_DESCRIC
	{ 'Descripcion Auxiliar'												, .T. }, ; //X3_DESCSPA
	{ 'Support Description'													, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'C6_UM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Unidade'																, .T. }, ; //X3_TITULO
	{ 'Unidad'																, .T. }, ; //X3_TITSPA
	{ 'Measure Unit'														, .T. }, ; //X3_TITENG
	{ 'Unidade de Medida Primar.'											, .T. }, ; //X3_DESCRIC
	{ 'Unidad de Medida Primaria'											, .T. }, ; //X3_DESCSPA
	{ 'Unit of Measure'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SAH")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SAH'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '122'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDVEN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Quantidade'															, .T. }, ; //X3_TITULO
	{ 'Cantidad'															, .T. }, ; //X3_TITSPA
	{ 'Quantity'															, .T. }, ; //X3_TITENG
	{ 'Quantidade Vendida'													, .T. }, ; //X3_DESCRIC
	{ 'Cantidad vendida'													, .T. }, ; //X3_DESCSPA
	{ 'Sold Quantity'														, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ 'A410QTDGRA() .AND. A410SegUm().and.A410MultT().and.a410Refr("C6_QTDVEN")', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(155) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'positivo() .And. U_FRRT03V1()'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YQTDPC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd em PC'															, .T. }, ; //X3_TITULO
	{ 'Qtd em PC'															, .T. }, ; //X3_TITSPA
	{ 'Qtd em PC'															, .T. }, ; //X3_TITENG
	{ 'Qtd em PC'															, .T. }, ; //X3_DESCRIC
	{ 'Qtd em PC'															, .T. }, ; //X3_DESCSPA
	{ 'Qtd em PC'															, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPRCTAB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Preco Tabela'														, .T. }, ; //X3_TITULO
	{ 'Preco Tabela'														, .T. }, ; //X3_TITSPA
	{ 'Preco Tabela'														, .T. }, ; //X3_TITENG
	{ 'Preco Tabela'														, .T. }, ; //X3_DESCRIC
	{ 'Preco Tabela'														, .T. }, ; //X3_DESCSPA
	{ 'Preco Tabela'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999.9999'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDPAL'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Paletizado'															, .T. }, ; //X3_TITULO
	{ 'Paletizado'															, .T. }, ; //X3_TITSPA
	{ 'Paletizado'															, .T. }, ; //X3_TITENG
	{ 'Desconto de Paletizado'												, .T. }, ; //X3_DESCRIC
	{ 'Desconto de Paletizado'												, .T. }, ; //X3_DESCSPA
	{ 'Desconto de Paletizado'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPERC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Politica'															, .T. }, ; //X3_TITULO
	{ 'Politica'															, .T. }, ; //X3_TITSPA
	{ 'Politica'															, .T. }, ; //X3_TITENG
	{ 'Politica'															, .T. }, ; //X3_DESCRIC
	{ 'Politica'															, .T. }, ; //X3_DESCSPA
	{ 'Politica'															, .T. }, ; //X3_DESCENG
	{ '@E 999.999'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'SA1->A1_EST<>"EX"'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDNV'																, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Norma'																, .T. }, ; //X3_TITULO
	{ 'Norma'																, .T. }, ; //X3_TITSPA
	{ 'Norma'																, .T. }, ; //X3_TITENG
	{ 'Norma de venda'														, .T. }, ; //X3_DESCRIC
	{ 'Norma de venda'														, .T. }, ; //X3_DESCSPA
	{ 'Norma de venda'														, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'POSITIVO()'															, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDESP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Outros(%)'															, .T. }, ; //X3_TITULO
	{ 'Outros(%)'															, .T. }, ; //X3_TITSPA
	{ 'Outros(%)'															, .T. }, ; //X3_TITENG
	{ 'Outros Descontos'													, .T. }, ; //X3_DESCRIC
	{ 'Outros Descontos'													, .T. }, ; //X3_DESCSPA
	{ 'Outros Descontos'													, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SEGUM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Segunda UM'															, .T. }, ; //X3_TITULO
	{ 'Segunda UM'															, .T. }, ; //X3_TITSPA
	{ '2nd U.Meas.'															, .T. }, ; //X3_TITENG
	{ 'Segunda Unidade de Medida'											, .T. }, ; //X3_DESCRIC
	{ 'Segunda Unidad de Medida'											, .T. }, ; //X3_DESCSPA
	{ '2nd. Unit of Measure'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SAH")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SAH'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'EMPTY(M->C6_SEGUM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '122'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDACO'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.AO(%)'															, .T. }, ; //X3_TITULO
	{ 'Desc.AO(%)'															, .T. }, ; //X3_TITSPA
	{ 'Desc.AO(%)'															, .T. }, ; //X3_TITENG
	{ 'Desconto Acordo Objetivo'											, .T. }, ; //X3_DESCRIC
	{ 'Desconto Acordo Objetivo'											, .T. }, ; //X3_DESCSPA
	{ 'Desconto Acordo Objetivo'											, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDVER'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Verba(%)'															, .T. }, ; //X3_TITULO
	{ 'Verba(%)'															, .T. }, ; //X3_TITSPA
	{ 'Verba(%)'															, .T. }, ; //X3_TITENG
	{ 'Desconto de Verba(%)'												, .T. }, ; //X3_DESCRIC
	{ 'Desconto de Verba(%)'												, .T. }, ; //X3_DESCSPA
	{ 'Desconto de Verba(%)'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDEMP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qt Empenhada'														, .T. }, ; //X3_TITULO
	{ 'Ctd.Reservad'														, .T. }, ; //X3_TITSPA
	{ 'Qty.Employed'														, .T. }, ; //X3_TITENG
	{ 'Quantidade Empenhada'												, .T. }, ; //X3_DESCRIC
	{ 'Cantidad Reservada'													, .T. }, ; //X3_DESCSPA
	{ 'Alloccated Quantity'													, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDENT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Entregue'														, .T. }, ; //X3_TITULO
	{ 'Ctd.Entregad'														, .T. }, ; //X3_TITSPA
	{ 'Qty.Delivery'														, .T. }, ; //X3_TITENG
	{ 'Quantidade Entregue'													, .T. }, ; //X3_DESCRIC
	{ 'Cantidad Entregada'													, .T. }, ; //X3_DESCSPA
	{ 'Quantity Delivered'													, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDAI'																, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Dsc.Out.AI %'														, .T. }, ; //X3_TITULO
	{ 'Dsc.Out.AI %'														, .T. }, ; //X3_TITSPA
	{ 'Dsc.Out.AI %'														, .T. }, ; //X3_TITENG
	{ 'Desconto de Outras AIs'												, .T. }, ; //X3_DESCRIC
	{ 'Desconto de Outras AIs'												, .T. }, ; //X3_DESCSPA
	{ 'Desconto de Outras AIs'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDFRA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Fracionado%'															, .T. }, ; //X3_TITULO
	{ 'Fracionado%'															, .T. }, ; //X3_TITSPA
	{ 'Fracionado%'															, .T. }, ; //X3_TITENG
	{ 'Fracionado%'															, .T. }, ; //X3_DESCRIC
	{ 'Fracionado%'															, .T. }, ; //X3_DESCSPA
	{ 'Fracionado%'															, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDESC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desc. Total'															, .T. }, ; //X3_TITULO
	{ 'Desc. Total'															, .T. }, ; //X3_TITSPA
	{ 'Desc. Total'															, .T. }, ; //X3_TITENG
	{ '% Desconto Total'													, .T. }, ; //X3_DESCRIC
	{ '% Desconto Total'													, .T. }, ; //X3_DESCSPA
	{ '% Desconto Total'													, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PRCVEN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Prc Unitario'														, .T. }, ; //X3_TITULO
	{ 'Prc Unitario'														, .T. }, ; //X3_TITSPA
	{ 'Unitary Pric'														, .T. }, ; //X3_TITENG
	{ 'Preco Unitario Liquido'												, .T. }, ; //X3_DESCRIC
	{ 'Precio unitario neto'												, .T. }, ; //X3_DESCSPA
	{ 'Net Unitary Price'													, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999.9999'												, .T. }, ; //X3_PICTURE
	{ 'A410QtdGra() .And. A410MultT() .And. A410Zera() .And. MTA410TROP(n)'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'positivo() .And. U_BPOLVL01()'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'EXECBLOCK("BIA452") .And. !IsInCallStack("U_M410RPRC")'				, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '22'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VALOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vlr.Total'															, .T. }, ; //X3_TITULO
	{ 'Vlr.Total'															, .T. }, ; //X3_TITSPA
	{ 'Total Vl'															, .T. }, ; //X3_TITENG
	{ 'Valor Total do Item'													, .T. }, ; //X3_DESCRIC
	{ 'Valor total del ítem'												, .T. }, ; //X3_DESCSPA
	{ 'Item Total Value'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'A410MultT()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(155) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'positivo() .And. U_BPOLVL01()'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!IsInCallStack("U_M410RPRC")'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '23'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YTPEST'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tp.Reserva'															, .T. }, ; //X3_TITULO
	{ 'Tp.Reserva'															, .T. }, ; //X3_TITSPA
	{ 'Tp.Reserva'															, .T. }, ; //X3_TITENG
	{ 'Tipo de reserva'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de reserva'														, .T. }, ; //X3_DESCSPA
	{ 'Tipo de reserva'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'E=Estoque Imediato;R=Reserva de OP;V=Vincular OP Futura;P=Estoque Empenhado;N=Nao Reservado', .T. }, ; //X3_CBOX
	{ 'E=Estoque Imediato;R=Reserva de OP;V=Vincular OP Futura;P=Estoque Empenhado;N=Nao Reservado', .T. }, ; //X3_CBOXSPA
	{ 'E=Estoque Imediato;R=Reserva de OP;V=Vincular OP Futura;P=Estoque Empenhado;N=Nao Reservado', .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(cRepAtu)'														, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '24'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LA'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Controles'															, .T. }, ; //X3_TITULO
	{ 'Controles'															, .T. }, ; //X3_TITSPA
	{ 'Controls'															, .T. }, ; //X3_TITENG
	{ 'Campo de Controle'													, .T. }, ; //X3_DESCRIC
	{ 'Campo de Control'													, .T. }, ; //X3_DESCSPA
	{ 'Control Field'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '25'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ENTREG'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Entrega'																, .T. }, ; //X3_TITULO
	{ 'Entrega'																, .T. }, ; //X3_TITSPA
	{ 'Delivery'															, .T. }, ; //X3_TITENG
	{ 'Data da Entrega'														, .T. }, ; //X3_DESCRIC
	{ 'Fecha de la Entrega'													, .T. }, ; //X3_DESCSPA
	{ 'Delivery Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410MultT()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'dDataBase'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '26'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDTNECE'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Nec.Engen'														, .T. }, ; //X3_TITULO
	{ 'Dt.Nec.Engen'														, .T. }, ; //X3_TITSPA
	{ 'Dt.Nec.Engen'														, .T. }, ; //X3_TITENG
	{ 'Dt Necessidade Engenharia'											, .T. }, ; //X3_DESCRIC
	{ 'Dt Necessidade Engenharia'											, .T. }, ; //X3_DESCSPA
	{ 'Dt Necessidade Engenharia'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_FRRT04V1()'														, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'U_FSEGORI(M->C5_NUM)=="E" .And. !IsInCallStack("U_M410RPRC")'		, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '28'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DATFAT'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'DT Ult.Fat.'															, .T. }, ; //X3_TITULO
	{ 'Fch.Ult.Fac.'														, .T. }, ; //X3_TITSPA
	{ 'Lst Inv.Date'														, .T. }, ; //X3_TITENG
	{ 'Data do Faturamento'													, .T. }, ; //X3_DESCRIC
	{ 'Fecha de la Facturacion'												, .T. }, ; //X3_DESCSPA
	{ 'Invoicing Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'ddatabase'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '28'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDTNERE'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Nec.Clien'														, .T. }, ; //X3_TITULO
	{ 'Dt.Nec.Clien'														, .T. }, ; //X3_TITSPA
	{ 'Dt.Nec.Clien'														, .T. }, ; //X3_TITENG
	{ 'Data Necessidade Cliente'											, .T. }, ; //X3_DESCRIC
	{ 'Data Necessidade Cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Data Necessidade Cliente'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'U_FSEGORI(M->C5_NUM)=="E" .And. !IsInCallStack("U_M410RPRC")'		, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '29'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YNRESER'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num Reserva'															, .T. }, ; //X3_TITULO
	{ 'Num Reserva'															, .T. }, ; //X3_TITSPA
	{ 'Num Reserva'															, .T. }, ; //X3_TITENG
	{ 'Num Reserva'															, .T. }, ; //X3_DESCRIC
	{ 'Num Reserva'															, .T. }, ; //X3_DESCSPA
	{ 'Num Reserva'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '30'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPRTBAT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Pr.Tab.Atual'														, .T. }, ; //X3_TITULO
	{ 'Pr.Tab.Atual'														, .T. }, ; //X3_TITSPA
	{ 'Pr.Tab.Atual'														, .T. }, ; //X3_TITENG
	{ 'Preço de tabela atual'												, .T. }, ; //X3_DESCRIC
	{ 'Preço de tabela atual'												, .T. }, ; //X3_DESCSPA
	{ 'Preço de tabela atual'												, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999.9999'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '31'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDIFTAB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '%Dif.Tab'															, .T. }, ; //X3_TITULO
	{ '%Dif.Tab'															, .T. }, ; //X3_TITSPA
	{ '%Dif.Tab'															, .T. }, ; //X3_TITENG
	{ '%Diferenca de Tabelas'												, .T. }, ; //X3_DESCRIC
	{ '%Diferenca de Tabelas'												, .T. }, ; //X3_DESCSPA
	{ '%Diferenca de Tabelas'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '32'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPREAJU'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'P.Reajust(%)'														, .T. }, ; //X3_TITULO
	{ 'P.Reajust(%)'														, .T. }, ; //X3_TITSPA
	{ 'P.Reajust(%)'														, .T. }, ; //X3_TITENG
	{ 'Percentual de Reajuste'												, .T. }, ; //X3_DESCRIC
	{ 'Percentual de Reajuste'												, .T. }, ; //X3_DESCSPA
	{ 'Percentual de Reajuste'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ 'POSITIVO() .AND. U_PREAVL01()'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IsInCallStack("U_M410RPRC")'											, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '33'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YREAJOK'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Reajustar?'															, .T. }, ; //X3_TITULO
	{ 'Reajustar?'															, .T. }, ; //X3_TITSPA
	{ 'Reajustar?'															, .T. }, ; //X3_TITENG
	{ 'Reajustar?'															, .T. }, ; //X3_DESCRIC
	{ 'Reajustar?'															, .T. }, ; //X3_DESCSPA
	{ 'Reajustar?'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'N=Nao;S=Sim'															, .T. }, ; //X3_CBOX
	{ 'N=Nao;S=Sim'															, .T. }, ; //X3_CBOXSPA
	{ 'N=Nao;S=Sim'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '34'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PRUNIT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Prc Lista'															, .T. }, ; //X3_TITULO
	{ 'Precio Lista'														, .T. }, ; //X3_TITSPA
	{ 'Price List'															, .T. }, ; //X3_TITENG
	{ 'Preco Unitario de Tabela'											, .T. }, ; //X3_DESCRIC
	{ 'Precio Unitario de Tabla'											, .T. }, ; //X3_DESCSPA
	{ 'Unit List Price'														, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999.9999'												, .T. }, ; //X3_PICTURE
	{ 'A410MultT()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(155) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '35'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPERCMC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% MC'																, .T. }, ; //X3_TITULO
	{ '% MC'																, .T. }, ; //X3_TITSPA
	{ '% MC'																, .T. }, ; //X3_TITENG
	{ '% MC'																, .T. }, ; //X3_DESCRIC
	{ '% MC'																, .T. }, ; //X3_DESCSPA
	{ '% MC'																, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 6																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '36'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDLIB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Liberada'														, .T. }, ; //X3_TITULO
	{ 'Ctd Aprobada'														, .T. }, ; //X3_TITSPA
	{ 'Amt Approved'														, .T. }, ; //X3_TITENG
	{ 'Quantidade Liberada'													, .T. }, ; //X3_DESCRIC
	{ 'Cantidad Aprobada'													, .T. }, ; //X3_DESCSPA
	{ 'Amount Approved'														, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ 'A410QTDGRA() .AND. A440Qtdl() .and. a410MultT().and.a410Refr("C6_QTDLIB")', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'positivo()'															, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIf(FunName()=="MATA410".And.M->C5_TIPO=="N",.F.,.T.)'				, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '37'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SLDALIB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Sld a Liber.'														, .T. }, ; //X3_TITULO
	{ 'Saldo Aprob.'														, .T. }, ; //X3_TITSPA
	{ 'Bal. Approve'														, .T. }, ; //X3_TITENG
	{ 'Saldo a Liberar'														, .T. }, ; //X3_DESCRIC
	{ 'Saldo por Aprobar'													, .T. }, ; //X3_DESCSPA
	{ 'Balance to Approve'													, .T. }, ; //X3_DESCENG
	{ '@e 999999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'Ma440SaLib()'														, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '38'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TES'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Saida'															, .T. }, ; //X3_TITULO
	{ 'Tipo Salida'															, .T. }, ; //X3_TITSPA
	{ 'Outflow Type'														, .T. }, ; //X3_TITENG
	{ 'Tipo de Saida do Item'												, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Salida del Item'												, .T. }, ; //X3_DESCSPA
	{ 'Type of Item Outflow'												, .T. }, ; //X3_DESCENG
	{ '@9'																	, .T. }, ; //X3_PICTURE
	{ 'A410MultT() .And. A410SitTrib()'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SF4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Alltrim(M->C5_YSUBTP)$ "DC/O"'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '39'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CF'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Fiscal'															, .T. }, ; //X3_TITULO
	{ 'Cód. Fiscal'															, .T. }, ; //X3_TITSPA
	{ 'Fiscal Code'															, .T. }, ; //X3_TITENG
	{ 'Codigo Fiscal da Operacao'											, .T. }, ; //X3_DESCRIC
	{ 'Cód Fiscal de operación'												, .T. }, ; //X3_DESCSPA
	{ 'Oper Fiscal Code'													, .T. }, ; //X3_DESCENG
	{ '@9'																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio().and.AvalCFO("SC6",M->C6_CF).And.MaFisGet("IT_CF")'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '13'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '40'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YMOTFRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mot.Rj.Sug.'															, .T. }, ; //X3_TITULO
	{ 'Mot.Rj.Sug.'															, .T. }, ; //X3_TITSPA
	{ 'Mot.Rj.Sug.'															, .T. }, ; //X3_TITENG
	{ 'Motivo Rejeicao Sugestao'											, .T. }, ; //X3_DESCRIC
	{ 'Motivo Rejeicao Sugestao'											, .T. }, ; //X3_DESCSPA
	{ 'Motivo Rejeicao Sugestao'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'PZ7'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '41'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDMOTFR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_TITULO
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_TITSPA
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_TITENG
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_DESCRIC
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_DESCSPA
	{ 'Desc.Mot.Rej'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(!INCLUI, POSICIONE("PZ7",1,XFILIAL("PZ7")+SC6->C6_YMOTFRA,"PZ7_DESCRI"), "")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(65)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'POSICIONE("PZ7",1,XFILIAL("PZ7")+SC6->C6_YMOTFRA,"PZ7_DESCRI")'		, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '42'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YBLQLOT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Blq.Lote'															, .T. }, ; //X3_TITULO
	{ 'Blq.Lote'															, .T. }, ; //X3_TITSPA
	{ 'Blq.Lote'															, .T. }, ; //X3_TITENG
	{ 'Tipo Bloqueio de Lote'												, .T. }, ; //X3_DESCRIC
	{ 'Tipo Bloqueio de Lote'												, .T. }, ; //X3_DESCSPA
	{ 'Tipo Bloqueio de Lote'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"00"'																, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '10=Rejeicao;01=Lote Restrito;11=Rejeicao/Lot.Restrito'				, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '43'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NFORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'N.F.Original'														, .T. }, ; //X3_TITULO
	{ 'Factura Orig'														, .T. }, ; //X3_TITSPA
	{ 'Original Inv'														, .T. }, ; //X3_TITENG
	{ 'N.F.Original'														, .T. }, ; //X3_DESCRIC
	{ 'Factura Original'													, .T. }, ; //X3_DESCSPA
	{ 'Original Invoice'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410NfOrig()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '018'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '44'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YQTDFAT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Quant. Fatur'														, .T. }, ; //X3_TITULO
	{ 'Quant. Fatur'														, .T. }, ; //X3_TITSPA
	{ 'Quant. Fatur'														, .T. }, ; //X3_TITENG
	{ 'Quantidade Faturada'													, .T. }, ; //X3_DESCRIC
	{ 'Quantidade Faturada'													, .T. }, ; //X3_DESCSPA
	{ 'Quantidade Faturada'													, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'SC6->C6_QTDENT'														, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'SC6->C6_QTDENT'														, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '45'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YSTATUS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Status Pedid'														, .T. }, ; //X3_TITULO
	{ 'Status Pedid'														, .T. }, ; //X3_TITSPA
	{ 'Status Pedid'														, .T. }, ; //X3_TITENG
	{ 'Status Pedido'														, .T. }, ; //X3_DESCRIC
	{ 'Status Pedido'														, .T. }, ; //X3_DESCSPA
	{ 'Status Pedido'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(SC6->C6_BLQ='R','R', IF(SC6->C6_QTDVEN-SC6->C6_QTDENT=0,'F','P'))"	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'R=Residuo;F=Faturado;P=Pendente'										, .T. }, ; //X3_CBOX
	{ 'R=Residuo;F=Faturado;P=Pendente'										, .T. }, ; //X3_CBOXSPA
	{ 'R=Residuo;F=Faturado;P=Pendente'										, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ "IF(SC6->C6_BLQ='R','R', IF(SC6->C6_QTDVEN-SC6->C6_QTDENT=0,'F','P'))"	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '46'																	, .T. }, ; //X3_ORDEM
	{ 'C6_IPIDEV'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. IPI Dev.'														, .T. }, ; //X3_TITULO
	{ 'Vlr.IPI Dev.'														, .T. }, ; //X3_TITSPA
	{ 'IPI Ret. Vl.'														, .T. }, ; //X3_TITENG
	{ 'Vl.IPI qdo.nota devolucao'											, .T. }, ; //X3_DESCRIC
	{ 'Vlr.IPI Cdo. Fact Devuel.'											, .T. }, ; //X3_DESCSPA
	{ 'IPI Return Value'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'a410DevIPI().And.MaFisGet("IT_VALIPI")'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '47'																	, .T. }, ; //X3_ORDEM
	{ 'C6_IDENTB6'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ident.Poder3'														, .T. }, ; //X3_TITULO
	{ 'Ident.Poder3'														, .T. }, ; //X3_TITSPA
	{ 'Ident.Power3'														, .T. }, ; //X3_TITENG
	{ 'Identificador Poder Terc.'											, .T. }, ; //X3_DESCRIC
	{ 'Identificador Poder 3o'												, .T. }, ; //X3_DESCSPA
	{ 'Identifier of Third Posse'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '48'																	, .T. }, ; //X3_ORDEM
	{ 'C6_BLQ'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bloqueio'															, .T. }, ; //X3_TITULO
	{ 'Estatus Blq'															, .T. }, ; //X3_TITSPA
	{ 'Block Status'														, .T. }, ; //X3_TITENG
	{ 'Bloqueio Pedido'														, .T. }, ; //X3_DESCRIC
	{ 'Estatus de Bloqueo Pedido'											, .T. }, ; //X3_DESCSPA
	{ 'Order Block Status'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410QtdGra() .And. ExistCpo("SX5","F1"+M->C6_BLQ) .AND. A410MULTT()'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'F1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '49'																	, .T. }, ; //X3_ORDEM
	{ 'C6_UNSVEN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd Ven 2 UM'														, .T. }, ; //X3_TITULO
	{ 'Ctd.Ven 2aUM'														, .T. }, ; //X3_TITSPA
	{ 'Qty.Sold 2UM'														, .T. }, ; //X3_TITENG
	{ 'Quant. Vend. na 2 Unid M.'											, .T. }, ; //X3_DESCRIC
	{ 'Ctd. Vend. en 2a.Unid.Med'											, .T. }, ; //X3_DESCSPA
	{ 'Quantity Sold 2 Meas.Unit'											, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ 'A410Quant().and.(positivo().or.vazio())'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'EMPTY(M->C6_UNSVEN)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '50'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YOBS'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Observação'															, .T. }, ; //X3_TITULO
	{ 'Observação'															, .T. }, ; //X3_TITSPA
	{ 'Observação'															, .T. }, ; //X3_TITENG
	{ 'Observação'															, .T. }, ; //X3_DESCRIC
	{ 'Observação'															, .T. }, ; //X3_DESCSPA
	{ 'Observação'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '51'																	, .T. }, ; //X3_ORDEM
	{ 'C6_GRADE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Grade'																, .T. }, ; //X3_TITULO
	{ 'Grilla'																, .T. }, ; //X3_TITSPA
	{ 'Range'																, .T. }, ; //X3_TITENG
	{ 'Ind.se prod.digitado Grad'											, .T. }, ; //X3_DESCRIC
	{ 'Ind. si prod. dig. grilla'											, .T. }, ; //X3_DESCSPA
	{ 'Inf. if typed Prod. Grid'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("SN ")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'S=Sim;N=Nao'															, .T. }, ; //X3_CBOX
	{ 'S=Si;N=No'															, .T. }, ; //X3_CBOXSPA
	{ 'S=Yes;N=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '52'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMGRD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Grade'															, .T. }, ; //X3_TITULO
	{ 'Item Grilla'															, .T. }, ; //X3_TITSPA
	{ 'Item Range'															, .T. }, ; //X3_TITENG
	{ 'Item de Grade'														, .T. }, ; //X3_DESCRIC
	{ 'Item de Grilla'														, .T. }, ; //X3_DESCSPA
	{ 'Item of grid'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '53'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOTECTL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lote'																, .T. }, ; //X3_TITULO
	{ 'Lote'																, .T. }, ; //X3_TITSPA
	{ 'Lot'																	, .T. }, ; //X3_TITENG
	{ 'Lote'																, .T. }, ; //X3_DESCRIC
	{ 'Lote'																, .T. }, ; //X3_DESCSPA
	{ 'Lot'																	, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410LotCTL()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ZZ9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_BPOLVLC6()'														, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '068'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '54'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMLOTE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sub-Lote'															, .T. }, ; //X3_TITULO
	{ 'Sublote'																, .T. }, ; //X3_TITSPA
	{ 'Sublot'																, .T. }, ; //X3_TITENG
	{ 'Sub-Lote'															, .T. }, ; //X3_DESCRIC
	{ 'Num. del Sublote'													, .T. }, ; //X3_DESCSPA
	{ 'Sublot'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A440Lote() .and. A410Zera() .And. A410LotCTL()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '55'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOCAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Almoxarifado'														, .T. }, ; //X3_TITULO
	{ 'Deposito'															, .T. }, ; //X3_TITSPA
	{ 'Warehouse'															, .T. }, ; //X3_TITENG
	{ 'Almoxarifado'														, .T. }, ; //X3_DESCRIC
	{ 'Deposito'															, .T. }, ; //X3_DESCSPA
	{ 'Warehouse'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("NNR") .And. A410Local()'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NNR'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'PERTENCE("01#02#03#04#05#6B#6I#6V#07#6T#20")'						, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '024'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '56'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMORC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'N.Or‡amento'															, .T. }, ; //X3_TITULO
	{ 'Nro. Presup.'														, .T. }, ; //X3_TITSPA
	{ 'Budget No.'															, .T. }, ; //X3_TITENG
	{ 'Numero do Or‡amento'													, .T. }, ; //X3_DESCRIC
	{ 'Numero del Presupuesto'												, .T. }, ; //X3_DESCSPA
	{ 'Budget Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SCK")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '57'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DESCONT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ '% Correcao'															, .T. }, ; //X3_TITULO
	{ '% Descuento'															, .T. }, ; //X3_TITSPA
	{ '% Discount'															, .T. }, ; //X3_TITENG
	{ 'Percentual de Desconto'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Descuento'												, .T. }, ; //X3_DESCSPA
	{ 'Discount Percentage'													, .T. }, ; //X3_DESCENG
	{ '@E 99.9999'															, .T. }, ; //X3_PICTURE
	{ '(positivo().or.vazio()).And.A410MultT()'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '58'																	, .T. }, ; //X3_ORDEM
	{ 'C6_OPC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 80																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Opcional PV'															, .T. }, ; //X3_TITULO
	{ 'Opcional PV'															, .T. }, ; //X3_TITSPA
	{ 'Sales Order'															, .T. }, ; //X3_TITENG
	{ 'Opcionais utilizados p/PV'											, .T. }, ; //X3_DESCRIC
	{ 'Opcionales Usados por PV'											, .T. }, ; //X3_DESCSPA
	{ 'Optional used in Sale Ord'											, .T. }, ; //X3_DESCENG
	{ '@!S40'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '59'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VALDESC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vlr Correcao'														, .T. }, ; //X3_TITULO
	{ 'Vlr Descuent'														, .T. }, ; //X3_TITSPA
	{ 'Disc Value'															, .T. }, ; //X3_TITENG
	{ 'Valor do Desconto do Item'											, .T. }, ; //X3_DESCRIC
	{ 'Valor descuento del ítem'											, .T. }, ; //X3_DESCSPA
	{ 'Item Discount Value'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ '(Positivo().Or.Vazio()).And.A410MultT()'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '60'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMSERI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num de Serie'														, .T. }, ; //X3_TITULO
	{ 'Nro.de Serie'														, .T. }, ; //X3_TITSPA
	{ 'Series No.'															, .T. }, ; //X3_TITENG
	{ 'Num de Serie do Produto'												, .T. }, ; //X3_DESCRIC
	{ 'Nro.de Serie del Producto'											, .T. }, ; //X3_DESCSPA
	{ 'Product Series Number'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(172) + Chr(212) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(137) + Chr(192) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(130) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '61'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMOP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Numero OP'															, .T. }, ; //X3_TITULO
	{ 'Num.Ord.Prod'														, .T. }, ; //X3_TITSPA
	{ 'PO Number'															, .T. }, ; //X3_TITENG
	{ 'Num. da OP gerada por PV'											, .T. }, ; //X3_DESCRIC
	{ 'Num.de OP Generada por PV'											, .T. }, ; //X3_DESCSPA
	{ 'PO Number generated by SO'											, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '62'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMOP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item da OP'															, .T. }, ; //X3_TITULO
	{ 'Item de OP'															, .T. }, ; //X3_TITSPA
	{ 'Pr.Ord.Item'															, .T. }, ; //X3_TITENG
	{ 'Item da OP gerada por PV'											, .T. }, ; //X3_DESCRIC
	{ 'Item de OP Generada p/PV'											, .T. }, ; //X3_DESCSPA
	{ 'Prod.Ord.It.Gen.Sal.Ord.'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '63'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CLASFIS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sit.Tribut.'															, .T. }, ; //X3_TITULO
	{ 'Sit.Tribut.'															, .T. }, ; //X3_TITSPA
	{ 'Tax Situat.'															, .T. }, ; //X3_TITENG
	{ 'Situacao Tributaria'													, .T. }, ; //X3_DESCRIC
	{ 'Situacion Tributaria'												, .T. }, ; //X3_DESCSPA
	{ 'Taxation Status'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'MAFISGET("IT_CLASFIS")'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"000"'																, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(149) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '64'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CLI'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cliente'																, .T. }, ; //X3_TITULO
	{ 'Cliente'																, .T. }, ; //X3_TITSPA
	{ 'Customer'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Cliente'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Customer Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'existcpo("SA1")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '65'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOJA'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja'																, .T. }, ; //X3_TITULO
	{ 'Tienda'																, .T. }, ; //X3_TITSPA
	{ 'Unit'																, .T. }, ; //X3_TITENG
	{ 'Loja do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Tienda del Cliente'													, .T. }, ; //X3_DESCSPA
	{ "Customer's Unit"														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '66'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NOTA'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nota Fiscal'															, .T. }, ; //X3_TITULO
	{ 'Factura'																, .T. }, ; //X3_TITSPA
	{ 'Invoice'																, .T. }, ; //X3_TITENG
	{ 'Numero da Nota Fiscal'												, .T. }, ; //X3_DESCRIC
	{ 'Numero de la Factura'												, .T. }, ; //X3_DESCSPA
	{ 'Invoice Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '018'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '67'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SERIE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Serie NF'															, .T. }, ; //X3_TITULO
	{ 'Serie Fact.'															, .T. }, ; //X3_TITSPA
	{ 'Series'																, .T. }, ; //X3_TITENG
	{ 'Serie da Nota Fiscal'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de la Factura'													, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '094'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '68'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Pedido'															, .T. }, ; //X3_TITULO
	{ 'Nro Pedido'															, .T. }, ; //X3_TITSPA
	{ 'Order Number'														, .T. }, ; //X3_TITENG
	{ 'Numero do Pedido'													, .T. }, ; //X3_DESCRIC
	{ 'Numero del Pedido'													, .T. }, ; //X3_DESCSPA
	{ 'Order Number'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '69'																	, .T. }, ; //X3_ORDEM
	{ 'C6_COMIS1'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 1'															, .T. }, ; //X3_TITULO
	{ 'Comision 1'															, .T. }, ; //X3_TITSPA
	{ 'Commission 1'														, .T. }, ; //X3_TITENG
	{ 'Percentual Comissao 1'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Comision 1'											, .T. }, ; //X3_DESCSPA
	{ 'Percentage Commission 1'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '70'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOCALIZ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Localizacao'															, .T. }, ; //X3_TITULO
	{ 'Ubicacion'															, .T. }, ; //X3_TITSPA
	{ 'Address'																, .T. }, ; //X3_TITENG
	{ 'Localizacao Fisica'													, .T. }, ; //X3_DESCRIC
	{ 'Ubicacion'															, .T. }, ; //X3_DESCSPA
	{ 'Address'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'VldLocaliz( "A440" )'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SBE'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '71'																	, .T. }, ; //X3_ORDEM
	{ 'C6_COMIS2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 2'															, .T. }, ; //X3_TITULO
	{ 'Comision 2'															, .T. }, ; //X3_TITSPA
	{ 'Commission 2'														, .T. }, ; //X3_TITENG
	{ 'Percentual Comissao 2'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Comision 2'											, .T. }, ; //X3_DESCSPA
	{ 'Percentage Commission 2'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '72'																	, .T. }, ; //X3_ORDEM
	{ 'C6_COMIS3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 3'															, .T. }, ; //X3_TITULO
	{ 'Comision 3'															, .T. }, ; //X3_TITSPA
	{ 'Commission 3'														, .T. }, ; //X3_TITENG
	{ 'Percentual Comissao 3'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Comision 3'											, .T. }, ; //X3_DESCSPA
	{ 'Percentage Commission 3'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '73'																	, .T. }, ; //X3_ORDEM
	{ 'C6_COMIS4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 4'															, .T. }, ; //X3_TITULO
	{ 'Comision 4'															, .T. }, ; //X3_TITSPA
	{ 'Commission 4'														, .T. }, ; //X3_TITENG
	{ 'Percentual Comissao 4'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Comision 4'											, .T. }, ; //X3_DESCSPA
	{ 'Percentage Commission 4'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '74'																	, .T. }, ; //X3_ORDEM
	{ 'C6_COMIS5'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 5'															, .T. }, ; //X3_TITULO
	{ 'Comision 5'															, .T. }, ; //X3_TITSPA
	{ 'Commission 5'														, .T. }, ; //X3_TITENG
	{ 'Percentual Comissao 5'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de Comision 5'											, .T. }, ; //X3_DESCSPA
	{ 'Percentage Commission 5'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '75'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPALLET'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Paletizado'															, .T. }, ; //X3_TITULO
	{ 'Paletizado'															, .T. }, ; //X3_TITSPA
	{ 'Paletizado'															, .T. }, ; //X3_TITENG
	{ 'Paletizado'															, .T. }, ; //X3_DESCRIC
	{ 'Paletizado'															, .T. }, ; //X3_DESCSPA
	{ 'Paletizado'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("SN")'														, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '76'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PEDCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped Cliente'															, .T. }, ; //X3_TITULO
	{ 'Ped Cliente'															, .T. }, ; //X3_TITSPA
	{ 'Custom.Order'														, .T. }, ; //X3_TITENG
	{ 'Numero do Pedido Cliente'											, .T. }, ; //X3_DESCRIC
	{ 'Nro.de Pedido del Cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Customer Order No.'													, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!"TMK"$M->C6_PEDCLI'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '77'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDENT2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Seg Ent.'														, .T. }, ; //X3_TITULO
	{ 'Ctd.Seg Ent.'														, .T. }, ; //X3_TITSPA
	{ 'Qty.2nd Del.'														, .T. }, ; //X3_TITENG
	{ 'Qtd.Seg. UM Entregue'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd. Seg. UM Entregada'												, .T. }, ; //X3_DESCSPA
	{ 'Sec. Unit Delivered Qtt.'											, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '78'																	, .T. }, ; //X3_ORDEM
	{ 'C6_BLOQUEI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bloqueio'															, .T. }, ; //X3_TITULO
	{ 'Bloqueo'																, .T. }, ; //X3_TITSPA
	{ 'Block'																, .T. }, ; //X3_TITENG
	{ 'Bloqueio do Pedido'													, .T. }, ; //X3_DESCRIC
	{ 'Bloqueo del Pedido'													, .T. }, ; //X3_DESCSPA
	{ 'Order Blocking'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '79'																	, .T. }, ; //X3_ORDEM
	{ 'C6_GEROUPV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Gerou previs'														, .T. }, ; //X3_TITULO
	{ 'Genero Prev.'														, .T. }, ; //X3_TITSPA
	{ 'Gener.Forcst'														, .T. }, ; //X3_TITENG
	{ 'Se gerou previsao de vend'											, .T. }, ; //X3_DESCRIC
	{ 'Si Genero Prev. Ventas'												, .T. }, ; //X3_DESCSPA
	{ 'Generated Sales Forecasts'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '80'																	, .T. }, ; //X3_ORDEM
	{ 'C6_RESERVA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Reserva'															, .T. }, ; //X3_TITULO
	{ 'Nro. Reserva'														, .T. }, ; //X3_TITSPA
	{ 'Reserv. No.'															, .T. }, ; //X3_TITENG
	{ 'Numero da reserva'													, .T. }, ; //X3_DESCRIC
	{ 'Numero de la Reserva'												, .T. }, ; //X3_DESCSPA
	{ 'Reserv. Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'vazio().or.A410Reserv()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SC0'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '81'																	, .T. }, ; //X3_ORDEM
	{ 'C6_OP'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'OP Gerada'															, .T. }, ; //X3_TITULO
	{ 'OP Generada'															, .T. }, ; //X3_TITSPA
	{ 'Prod.Or.Gen.'														, .T. }, ; //X3_TITENG
	{ 'Flag de geracao de OP'												, .T. }, ; //X3_DESCRIC
	{ 'Flag de Generacion de OP'											, .T. }, ; //X3_DESCSPA
	{ 'Flag of Production Order'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("S ")'														, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '82'																	, .T. }, ; //X3_ORDEM
	{ 'C6_OK'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ok'																	, .T. }, ; //X3_TITULO
	{ 'OK'																	, .T. }, ; //X3_TITSPA
	{ 'OK'																	, .T. }, ; //X3_TITENG
	{ 'Ok para Emissao de O.P.'												, .T. }, ; //X3_DESCRIC
	{ 'OK para Emision de OP'												, .T. }, ; //X3_DESCSPA
	{ 'Ok to Issue the Prod.Ord.'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '83'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SERIORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Serie Orig.'															, .T. }, ; //X3_TITULO
	{ 'Serie Orig.'															, .T. }, ; //X3_TITSPA
	{ 'Orig.Series'															, .T. }, ; //X3_TITENG
	{ 'Serie da N.F. Original'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de Factura Original'											, .T. }, ; //X3_DESCSPA
	{ 'Original Invoice Series'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410NfOrig()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '094'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '84'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item NF.Orig'														, .T. }, ; //X3_TITULO
	{ 'Item Fact.Or'														, .T. }, ; //X3_TITSPA
	{ 'Src.Inv.Item'														, .T. }, ; //X3_TITENG
	{ 'Nr.Item da N.Fiscal Orig.'											, .T. }, ; //X3_DESCRIC
	{ 'Nro.Item Factura Original'											, .T. }, ; //X3_DESCSPA
	{ 'Source Inv. Item No.'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410NfOrig()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '85'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PICMRET'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Icm Retido'															, .T. }, ; //X3_TITULO
	{ 'ICM Retenido'														, .T. }, ; //X3_TITSPA
	{ 'ICM Withhold'														, .T. }, ; //X3_TITENG
	{ 'Icm Retido (Margem Lucro)'											, .T. }, ; //X3_DESCRIC
	{ 'ICM Retenido Margen Lucro'											, .T. }, ; //X3_DESCSPA
	{ 'ICM Withhold(Profit Marg)'											, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_MARGEM")'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '86'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDEMP2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qt Seg. Emp'															, .T. }, ; //X3_TITULO
	{ 'Ctd Seg. Res'														, .T. }, ; //X3_TITSPA
	{ 'Qty.2dn All.'														, .T. }, ; //X3_TITENG
	{ 'Qtd. Seg. UN Empenhada'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd. Seg. UN Reservada'												, .T. }, ; //X3_DESCSPA
	{ 'Sec. Unit Allocated Qtt.'											, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '87'																	, .T. }, ; //X3_ORDEM
	{ 'C6_OPER'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tp. Operacao'														, .T. }, ; //X3_TITULO
	{ 'Tp.Operacion'														, .T. }, ; //X3_TITSPA
	{ 'Oper. Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Operacao'													, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Operacion'													, .T. }, ; //X3_DESCSPA
	{ 'Operation type'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SX5","DJ"+M->C6_OPER) .And. A410SitTrib() .And. MTA410OPER(n)', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DJ'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '88'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODISS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Serv.ISS'														, .T. }, ; //X3_TITULO
	{ 'Cod.Serv.ISS'														, .T. }, ; //X3_TITSPA
	{ 'ISS S.Cod.'															, .T. }, ; //X3_TITENG
	{ 'C¢digo de Servi‡o do ISS'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo de Servicio de ISS'											, .T. }, ; //X3_DESCSPA
	{ 'ISS Service Code'													, .T. }, ; //X3_DESCENG
	{ '@9'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '60'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '023'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '89'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DTVALID'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Valid. Lote'															, .T. }, ; //X3_TITULO
	{ 'Vald.Lote'															, .T. }, ; //X3_TITSPA
	{ 'Lot Validity'														, .T. }, ; //X3_TITENG
	{ 'Validade do Lote Inform.'											, .T. }, ; //X3_DESCRIC
	{ 'Validez del Lote Infor'												, .T. }, ; //X3_DESCSPA
	{ 'Informed Lot Validity'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(172) + Chr(144) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(137) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'Ctod("")'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '90'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CHASSI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 25																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Chassi'																, .T. }, ; //X3_TITULO
	{ 'Chasis'																, .T. }, ; //X3_TITSPA
	{ 'Chassis'																, .T. }, ; //X3_TITENG
	{ 'Codigo do Chassi'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Chasis'													, .T. }, ; //X3_DESCSPA
	{ 'Chassis Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(137) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(130) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '91'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPESOL'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 11																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Peso Liquido'														, .T. }, ; //X3_TITULO
	{ 'Peso Liquido'														, .T. }, ; //X3_TITSPA
	{ 'Peso Liquido'														, .T. }, ; //X3_TITENG
	{ 'Peso Liquido'														, .T. }, ; //X3_DESCRIC
	{ 'Peso Liquido'														, .T. }, ; //X3_DESCSPA
	{ 'Peso Liquido'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999.9999'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(255) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '92'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDRESE'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Reserva'															, .T. }, ; //X3_TITULO
	{ 'Ctd. Reserva'														, .T. }, ; //X3_TITSPA
	{ 'Reserv. Qty.'														, .T. }, ; //X3_TITENG
	{ 'Quant. Reservada'													, .T. }, ; //X3_DESCRIC
	{ 'Cantidad Reservada'													, .T. }, ; //X3_DESCSPA
	{ 'Allocated Quantity'													, .T. }, ; //X3_DESCENG
	{ '@r 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '.F.'																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '93'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMOS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr.OS'																, .T. }, ; //X3_TITULO
	{ 'Num. OS'																, .T. }, ; //X3_TITSPA
	{ 'SO Number'															, .T. }, ; //X3_TITENG
	{ 'Nr. da Ordem de Servico'												, .T. }, ; //X3_DESCRIC
	{ 'Num. de Orden de Servicio'											, .T. }, ; //X3_DESCSPA
	{ 'Service Order Number'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '94'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMOSFA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr.OS.Fabric'														, .T. }, ; //X3_TITULO
	{ 'Nro.OS.Fabri'														, .T. }, ; //X3_TITSPA
	{ 'SO Manuf.Nr.'														, .T. }, ; //X3_TITENG
	{ 'Nr.OS do Fabricante'													, .T. }, ; //X3_DESCRIC
	{ 'Nro. OS del Fabricante'												, .T. }, ; //X3_DESCSPA
	{ 'Manifaturer Serv. Order'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '95'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODFAB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Fabricante'															, .T. }, ; //X3_TITULO
	{ 'Fabricante'															, .T. }, ; //X3_TITSPA
	{ 'Manufacturer'														, .T. }, ; //X3_TITENG
	{ 'Codigo do Fabricante'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Fabricante'												, .T. }, ; //X3_DESCSPA
	{ 'Manufacturer Code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'a410VldFab()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '96'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOJAFA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja Fabric.'														, .T. }, ; //X3_TITULO
	{ 'Tda. Fabric.'														, .T. }, ; //X3_TITSPA
	{ 'Manuf. Unit'															, .T. }, ; //X3_TITENG
	{ 'Loja do Fabricante'													, .T. }, ; //X3_DESCRIC
	{ 'Tienda del Fabricante'												, .T. }, ; //X3_DESCSPA
	{ 'Manufacturer Unit'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'a410VldFab()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '97'																	, .T. }, ; //X3_ORDEM
	{ 'C6_MOPC'																, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'M. Opcional'															, .T. }, ; //X3_TITULO
	{ 'M. Opcional'															, .T. }, ; //X3_TITSPA
	{ 'Same Option.'														, .T. }, ; //X3_TITENG
	{ 'Mesmo Opcional'														, .T. }, ; //X3_DESCRIC
	{ 'Mismo Opcional'														, .T. }, ; //X3_DESCSPA
	{ 'Same Optional'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(156) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '98'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPOP'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Op'																, .T. }, ; //X3_TITULO
	{ 'Tipo Op'																, .T. }, ; //X3_TITSPA
	{ 'Type of PO'															, .T. }, ; //X3_TITENG
	{ 'Tipo da Ordem de Produ‡„o'											, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Orden de Producc.'											, .T. }, ; //X3_DESCSPA
	{ 'Type of Production Order'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("FP")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"F"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(194) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'F=Firme;P=Prevista'													, .T. }, ; //X3_CBOX
	{ 'F=Firme;P=Prevista'													, .T. }, ; //X3_CBOXSPA
	{ 'F=Confirmed;P=Expected'												, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ '99'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMSC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Numero SC'															, .T. }, ; //X3_TITULO
	{ 'Numero SC'															, .T. }, ; //X3_TITSPA
	{ 'PR number'															, .T. }, ; //X3_TITENG
	{ 'Num. da SC gerada por PV'											, .T. }, ; //X3_DESCRIC
	{ 'Nº de SC generada por PV'											, .T. }, ; //X3_DESCSPA
	{ 'PR  nbr. generated by SO'											, .T. }, ; //X3_DESCENG
	{ '@x'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMSC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item SC'																, .T. }, ; //X3_TITULO
	{ 'Item SC'																, .T. }, ; //X3_TITSPA
	{ 'PR Item'																, .T. }, ; //X3_TITENG
	{ 'Item da SC gerada por PV'											, .T. }, ; //X3_DESCRIC
	{ 'Item de SC gener. por PV'											, .T. }, ; //X3_DESCSPA
	{ 'PR item generated by SO'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_REVISAO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Revisao Estr'														, .T. }, ; //X3_TITULO
	{ 'Revis.Estr.'															, .T. }, ; //X3_TITSPA
	{ 'Struct.Revis'														, .T. }, ; //X3_TITENG
	{ 'Revisao da Estrutura'												, .T. }, ; //X3_DESCRIC
	{ 'Revision de la Estructura'											, .T. }, ; //X3_DESCSPA
	{ 'Structure Revision'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YEMISSA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Emissao'																, .T. }, ; //X3_TITULO
	{ 'Emissao'																, .T. }, ; //X3_TITSPA
	{ 'Emissao'																, .T. }, ; //X3_TITENG
	{ 'Data de emissao do pedido'											, .T. }, ; //X3_DESCRIC
	{ 'Data de emissao do pedido'											, .T. }, ; //X3_DESCSPA
	{ 'Data de emissao do pedido'											, .T. }, ; //X3_DESCENG
	{ '@D'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_USERLGI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 17																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Log de Inclu'														, .T. }, ; //X3_TITULO
	{ 'Log de Inclu'														, .T. }, ; //X3_TITSPA
	{ 'Log de Inclu'														, .T. }, ; //X3_TITENG
	{ 'Log de Inclusäo'														, .T. }, ; //X3_DESCRIC
	{ 'Log de Inclusäo'														, .T. }, ; //X3_DESCSPA
	{ 'Log de Inclusäo'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'L'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_USERLGA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 17																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Log de Alter'														, .T. }, ; //X3_TITULO
	{ 'Log de Alter'														, .T. }, ; //X3_TITSPA
	{ 'Log de Alter'														, .T. }, ; //X3_TITENG
	{ 'Log de Alteraçäo'													, .T. }, ; //X3_DESCRIC
	{ 'Log de Alteraçäo'													, .T. }, ; //X3_DESCSPA
	{ 'Log de Alteraçäo'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'L'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YIMPNF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desclas.NF'															, .T. }, ; //X3_TITULO
	{ 'Desclas.NF'															, .T. }, ; //X3_TITSPA
	{ 'Desclas.NF'															, .T. }, ; //X3_TITENG
	{ 'Desclass.NF'															, .T. }, ; //X3_DESCRIC
	{ 'Desclass.NF'															, .T. }, ; //X3_DESCSPA
	{ 'Desclass.NF'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_QTDLIB2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Lib 2aUM'														, .T. }, ; //X3_TITULO
	{ 'Ctd.Lib 2aUM'														, .T. }, ; //X3_TITSPA
	{ 'Qt.Rls.2UoM'															, .T. }, ; //X3_TITENG
	{ 'Quantidade Liberada 2a UM'											, .T. }, ; //X3_DESCRIC
	{ 'Cantidad Aprobada 2a UM'												, .T. }, ; //X3_DESCSPA
	{ 'Quantity Released 2nd UOM'											, .T. }, ; //X3_DESCENG
	{ '@E 999999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'positivo()'															, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SERVIC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Servico'																, .T. }, ; //X3_TITULO
	{ 'Servicio'															, .T. }, ; //X3_TITSPA
	{ 'Service'																, .T. }, ; //X3_TITENG
	{ 'Tipo de Servico'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Servicio'													, .T. }, ; //X3_DESCSPA
	{ 'Service Type'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('DC5')"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DC5'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '012'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ENDPAD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'End. Destino'														, .T. }, ; //X3_TITULO
	{ 'Dir. Destino'														, .T. }, ; //X3_TITSPA
	{ 'Dest.Address'														, .T. }, ; //X3_TITENG
	{ 'Endere‡o Destino'													, .T. }, ; //X3_DESCRIC
	{ 'Ubicacion Destino'													, .T. }, ; //X3_DESCSPA
	{ 'Destination Address'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('SBE', M->C6_ENDPAD, 9)"						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SBE'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'A9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CONTRT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Contrato'															, .T. }, ; //X3_TITULO
	{ 'Contrato'															, .T. }, ; //X3_TITSPA
	{ 'Contract'															, .T. }, ; //X3_TITENG
	{ 'Contrato de Servico'													, .T. }, ; //X3_DESCRIC
	{ 'Contrato de Servicio'												, .T. }, ; //X3_DESCSPA
	{ 'Service Contract'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AA'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPCONTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Contrat'														, .T. }, ; //X3_TITULO
	{ 'Tipo Contrat'														, .T. }, ; //X3_TITSPA
	{ 'Contract Tp'															, .T. }, ; //X3_TITENG
	{ 'Item/Contrato de Servico'											, .T. }, ; //X3_DESCRIC
	{ 'Item/Contrato de Servicio'											, .T. }, ; //X3_DESCSPA
	{ 'Service Agreement/Item'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'pertence("123")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Servicos;2=WMS;3=Manutenção'										, .T. }, ; //X3_CBOX
	{ '1=Servicios;2=WMS;3=Manutenimiento'									, .T. }, ; //X3_CBOXSPA
	{ '1=Services;2=WMS;3=Maintenance'										, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AB'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITCONTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'It. Contrato'														, .T. }, ; //X3_TITULO
	{ 'It. Contrato'														, .T. }, ; //X3_TITSPA
	{ 'Contract It.'														, .T. }, ; //X3_TITENG
	{ 'Item/Contrato de Servico'											, .T. }, ; //X3_DESCRIC
	{ 'Item/Contrato de Servicio'											, .T. }, ; //X3_DESCSPA
	{ 'Service Contract/Item'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ '.F.'																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '.F.'																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AC'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PROJPMS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Projeto'															, .T. }, ; //X3_TITULO
	{ 'Cod.Proyecto'														, .T. }, ; //X3_TITSPA
	{ 'Project Code'														, .T. }, ; //X3_TITENG
	{ 'Codigo do Projeto'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Proyecto'													, .T. }, ; //X3_DESCSPA
	{ 'Project Code'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .OR. (ExistCpo("AF8") .AND. PmsVldFase("AF8",M->C6_PROJPMS,"84"))', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'AF8'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '097'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AD'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TASKPMS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Tarefa'															, .T. }, ; //X3_TITULO
	{ 'Cod.Tarea'															, .T. }, ; //X3_TITSPA
	{ 'Task Code'															, .T. }, ; //X3_TITENG
	{ 'Codigo da Tarefa'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo de la Tarea'													, .T. }, ; //X3_DESCSPA
	{ 'Task Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.A410VldPrj()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'AF9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'PmsSetF3("AF9",4)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '014'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AE'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LICITA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Licitac.'														, .T. }, ; //X3_TITULO
	{ 'Cod.Licitac.'														, .T. }, ; //X3_TITSPA
	{ 'Bidding Code'														, .T. }, ; //X3_TITENG
	{ 'Codigo da licitacao'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo de licitacion'												, .T. }, ; //X3_DESCSPA
	{ 'Bidding Code'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCpo("AH9")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'AH9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AF'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CONTRAT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'No.Contrato'															, .T. }, ; //X3_TITULO
	{ 'Nro.Contrato'														, .T. }, ; //X3_TITSPA
	{ 'Contract No.'														, .T. }, ; //X3_TITENG
	{ 'Nr. do Contrato Parceria'											, .T. }, ; //X3_DESCRIC
	{ 'Nro. del Contrato Socied.'											, .T. }, ; //X3_DESCSPA
	{ 'Partnership Contract No.'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ '.F.'																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '.F.'																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AG'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMCON'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Contr.'															, .T. }, ; //X3_TITULO
	{ 'Item Contr.'															, .T. }, ; //X3_TITSPA
	{ 'Contrac.Item'														, .T. }, ; //X3_TITENG
	{ 'Item de Contr. Parcerias'											, .T. }, ; //X3_DESCRIC
	{ 'Item de Contr. Socios'												, .T. }, ; //X3_DESCSPA
	{ 'Partner Contract Item'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AH'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPESTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Estr.Fisica'															, .T. }, ; //X3_TITULO
	{ 'Estr.Fisica'															, .T. }, ; //X3_TITSPA
	{ 'Phys.Struct.'														, .T. }, ; //X3_TITENG
	{ 'Cod. da Estrutura Fisica'											, .T. }, ; //X3_DESCRIC
	{ 'Cod. de Estructura Fisica'											, .T. }, ; //X3_DESCSPA
	{ 'Physical Structure Code'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("DC8")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DC8'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AI'																	, .T. }, ; //X3_ORDEM
	{ 'C6_EDTPMS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. EDT'															, .T. }, ; //X3_TITULO
	{ 'Cod. EDT'															, .T. }, ; //X3_TITSPA
	{ 'WBS Code'															, .T. }, ; //X3_TITENG
	{ 'Codigo da EDT'														, .T. }, ; //X3_DESCRIC
	{ 'Codigo de la EDT'													, .T. }, ; //X3_DESCSPA
	{ 'WBS Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. A410VldPrj()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'AFC'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'PmsSetF3("AFC",4)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '014'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AJ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TRT'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Seq. Empenho'														, .T. }, ; //X3_TITULO
	{ 'Sec. Reserva'														, .T. }, ; //X3_TITSPA
	{ 'Alloc. seq.'															, .T. }, ; //X3_TITENG
	{ 'Sequencia do Empenho'												, .T. }, ; //X3_DESCRIC
	{ 'Secuencia de la Reserva'												, .T. }, ; //X3_DESCSPA
	{ 'Allocation sequence'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'PmsTrtSC6()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AK'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PROJET'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Contrato Tec'														, .T. }, ; //X3_TITULO
	{ 'Contrato Tec'														, .T. }, ; //X3_TITSPA
	{ 'Tec. Cont.'															, .T. }, ; //X3_TITENG
	{ 'Contrato / Field Service'											, .T. }, ; //X3_DESCRIC
	{ 'Contrato / Field Service'											, .T. }, ; //X3_DESCSPA
	{ 'Contract / Field Service'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AL'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITPROJ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'It.Contrato'															, .T. }, ; //X3_TITULO
	{ 'It. Contrato'														, .T. }, ; //X3_TITSPA
	{ 'Cont. Item'															, .T. }, ; //X3_TITENG
	{ 'It.Contrato/Field Service'											, .T. }, ; //X3_DESCRIC
	{ 'It.Contrato/Field Service'											, .T. }, ; //X3_DESCSPA
	{ 'Contract item/Field serv.'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AM'																	, .T. }, ; //X3_ORDEM
	{ 'C6_POTENCI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Potencia'															, .T. }, ; //X3_TITULO
	{ 'Potencia'															, .T. }, ; //X3_TITSPA
	{ 'Potency'																, .T. }, ; //X3_TITENG
	{ 'Potencia de Lote'													, .T. }, ; //X3_DESCRIC
	{ 'Potencia de Lote'													, .T. }, ; //X3_DESCSPA
	{ 'Lot Potency'															, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AN'																	, .T. }, ; //X3_ORDEM
	{ 'C6_REGWMS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Regra WMS'															, .T. }, ; //X3_TITULO
	{ 'Regla WMS'															, .T. }, ; //X3_TITSPA
	{ 'WMS Rule'															, .T. }, ; //X3_TITENG
	{ 'Regra de apanhe do WMS'												, .T. }, ; //X3_DESCRIC
	{ 'Regla de recolec del WMS'											, .T. }, ; //X3_DESCSPA
	{ 'WMS Picking Rule'													, .T. }, ; //X3_DESCENG
	{ '9'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. Pertence("1234")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Lote;2=Nr de Serie;3=Data/Seq.Abastecimento;4=Data'				, .T. }, ; //X3_CBOX
	{ '1=Lote;2=Num de Serie;3=Fecha'										, .T. }, ; //X3_CBOXSPA
	{ '1=Lot;2=Serial Nbr.;3=Date'											, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AO'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMCP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Comp. Fut.'															, .T. }, ; //X3_TITULO
	{ 'Comp. Fut.'															, .T. }, ; //X3_TITSPA
	{ 'Fut. Comm.'															, .T. }, ; //X3_TITENG
	{ 'Compromisso Futuro'													, .T. }, ; //X3_DESCRIC
	{ 'Compromiso Futuro'													, .T. }, ; //X3_DESCSPA
	{ 'Future Commitment'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("NO1")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AP'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SUGENTR'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ent.Sugerida'														, .T. }, ; //X3_TITULO
	{ 'Ent.Sugerida'														, .T. }, ; //X3_TITSPA
	{ 'Deliv.Sugges'														, .T. }, ; //X3_TITENG
	{ 'Entrega Sugerida pelo APS'											, .T. }, ; //X3_DESCRIC
	{ 'Entrega Sugerida por APS'											, .T. }, ; //X3_DESCSPA
	{ 'Delivery suggested by APS'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'dDataBase'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'TipoAPS(.F.,"DRUMMER")'												, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AQ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPRCIMP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Prc. Imposto'														, .T. }, ; //X3_TITULO
	{ 'Prc. Imposto'														, .T. }, ; //X3_TITSPA
	{ 'Prc. Imposto'														, .T. }, ; //X3_TITENG
	{ 'Preco com Imposto'													, .T. }, ; //X3_DESCRIC
	{ 'Preco com Imposto'													, .T. }, ; //X3_DESCSPA
	{ 'Preco com Imposto'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999.9999'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AR'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YCOD'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Codigo Ant.'															, .T. }, ; //X3_TITULO
	{ 'Codigo Ant.'															, .T. }, ; //X3_TITSPA
	{ 'Codigo Ant.'															, .T. }, ; //X3_TITENG
	{ 'Codigo Ant.'															, .T. }, ; //X3_DESCRIC
	{ 'Codigo Ant.'															, .T. }, ; //X3_DESCSPA
	{ 'Codigo Ant.'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AS'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLIMP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl Imp. Item'														, .T. }, ; //X3_TITULO
	{ 'Vl Imp. Item'														, .T. }, ; //X3_TITSPA
	{ 'Vl Imp. Item'														, .T. }, ; //X3_TITENG
	{ 'Valor Imposto p/ Item'												, .T. }, ; //X3_DESCRIC
	{ 'Valor Imposto p/ Item'												, .T. }, ; //X3_DESCSPA
	{ 'Valor Imposto p/ Item'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AT'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDESCLI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITULO
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITENG
	{ 'Desconto Max. Cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Desconto Max. Cliente'												, .T. }, ; //X3_DESCSPA
	{ 'Desconto Max. Cliente'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AU'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YREGRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Regra Desc.'															, .T. }, ; //X3_TITULO
	{ 'Regra Desc.'															, .T. }, ; //X3_TITSPA
	{ 'Regra Desc.'															, .T. }, ; //X3_TITENG
	{ 'Regra Desconto'														, .T. }, ; //X3_DESCRIC
	{ 'Regra Desconto'														, .T. }, ; //X3_DESCSPA
	{ 'Regra Desconto'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AV'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ICMSRET'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'ICMS ST Comp'														, .T. }, ; //X3_TITULO
	{ 'ICMS ST Comp'														, .T. }, ; //X3_TITSPA
	{ 'ICMS ST Comp'														, .T. }, ; //X3_TITENG
	{ 'ICMS ST Complementar'												, .T. }, ; //X3_DESCRIC
	{ 'ICMS ST Complementar'												, .T. }, ; //X3_DESCSPA
	{ 'ICMS ST Complementar'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_VALSOL")'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AW'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YEMP'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Empresa'																, .T. }, ; //X3_TITULO
	{ 'Empresa'																, .T. }, ; //X3_TITSPA
	{ 'Empresa'																, .T. }, ; //X3_TITENG
	{ 'Empresa'																, .T. }, ; //X3_DESCRIC
	{ 'Empresa'																, .T. }, ; //X3_DESCSPA
	{ 'Empresa'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AX'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YEMPPED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Emp.Estoque'															, .T. }, ; //X3_TITULO
	{ 'Emp.Estoque'															, .T. }, ; //X3_TITSPA
	{ 'Emp.Estoque'															, .T. }, ; //X3_TITENG
	{ 'Empresa do Estoque do Ped'											, .T. }, ; //X3_DESCRIC
	{ 'Empresa do Estoque do Ped'											, .T. }, ; //X3_DESCSPA
	{ 'Empresa do Estoque do Ped'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AY'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ABATISS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Abatim. ISS'															, .T. }, ; //X3_TITULO
	{ 'Desc. ISS'															, .T. }, ; //X3_TITSPA
	{ 'ISS Writeoff'														, .T. }, ; //X3_TITENG
	{ 'Valor abatimento / ISS'												, .T. }, ; //X3_DESCRIC
	{ 'Valor descuento / ISS'												, .T. }, ; //X3_DESCSPA
	{ 'Write-off Value / ISS'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_ABVLISS").And.Positivo()'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'AZ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ABATMAT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Abat. Mat.'															, .T. }, ; //X3_TITULO
	{ 'Desc. Mat.'															, .T. }, ; //X3_TITSPA
	{ 'Mat. Disc.'															, .T. }, ; //X3_TITENG
	{ 'Abatimento ISS material'												, .T. }, ; //X3_DESCRIC
	{ 'Descuento ISS material'												, .T. }, ; //X3_DESCSPA
	{ 'ISS discount - material'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_ABMATISS").And.Positivo()'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ABSCINS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Ab INSS Sub'															, .T. }, ; //X3_TITULO
	{ 'Desc INSS Su'														, .T. }, ; //X3_TITSPA
	{ 'Ded INSS Sub'														, .T. }, ; //X3_TITENG
	{ 'Abat. INSS Subcontrat.'												, .T. }, ; //X3_DESCRIC
	{ 'Descuento INSS Subcontrat'											, .T. }, ; //X3_DESCSPA
	{ 'Deduct INSS sub-contr.'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_ABSCINS")'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDTRESI'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Elim.Resi'														, .T. }, ; //X3_TITULO
	{ 'Dt.Elim.Resi'														, .T. }, ; //X3_TITSPA
	{ 'Dt.Elim.Resi'														, .T. }, ; //X3_TITENG
	{ 'Data Eliminação Residuo'												, .T. }, ; //X3_DESCRIC
	{ 'Data Eliminação Residuo'												, .T. }, ; //X3_DESCSPA
	{ 'Data Eliminação Residuo'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLTIPI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. IPI'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. IPI'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. IPI'														, .T. }, ; //X3_TITENG
	{ 'Valor Total IPI'														, .T. }, ; //X3_DESCRIC
	{ 'Valor Total IPI'														, .T. }, ; //X3_DESCSPA
	{ 'Valor Total IPI'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLTST'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. Sol'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. Sol'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. Sol'														, .T. }, ; //X3_TITENG
	{ 'Valor Total ICMS Solid.'												, .T. }, ; //X3_DESCRIC
	{ 'Valor Total ICMS Solid.'												, .T. }, ; //X3_DESCSPA
	{ 'Valor Total ICMS Solid.'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Medicao'														, .T. }, ; //X3_TITULO
	{ 'Item Medic.'															, .T. }, ; //X3_TITSPA
	{ 'Measur. item'														, .T. }, ; //X3_TITENG
	{ 'Item da Medição'														, .T. }, ; //X3_DESCRIC
	{ 'Item de Medicion'													, .T. }, ; //X3_DESCSPA
	{ 'Measurement item'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVENDRC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vend. Resc.'															, .T. }, ; //X3_TITULO
	{ 'Vend. Resc.'															, .T. }, ; //X3_TITSPA
	{ 'Vend. Resc.'															, .T. }, ; //X3_TITENG
	{ 'Vendedor Rescisão'													, .T. }, ; //X3_DESCRIC
	{ 'Vendedor Rescisão'													, .T. }, ; //X3_DESCSPA
	{ 'Vendedor Rescisão'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'EXISTCPO("SA3")'														, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLCREC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITULO
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITENG
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 9.999.999,99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPCREC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Com.Rescis'														, .T. }, ; //X3_TITULO
	{ '% Com.Rescis'														, .T. }, ; //X3_TITSPA
	{ '% Com.Rescis'														, .T. }, ; //X3_TITENG
	{ '% Comissão Rescisão'													, .T. }, ; //X3_DESCRIC
	{ '% Comissão Rescisão'													, .T. }, ; //X3_DESCSPA
	{ '% Comissão Rescisão'													, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODLAN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Cat83'															, .T. }, ; //X3_TITULO
	{ 'Cod. CAT83'															, .T. }, ; //X3_TITSPA
	{ 'CAT83 Cd'															, .T. }, ; //X3_TITENG
	{ 'Código Lançamento CAT83'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo CAT/83'														, .T. }, ; //X3_DESCSPA
	{ 'CAT/83 Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('CDZ')"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CDZ'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'B9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YSI'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sol. Inv.'															, .T. }, ; //X3_TITULO
	{ 'Sol. Inv.'															, .T. }, ; //X3_TITSPA
	{ 'Sol. Inv.'															, .T. }, ; //X3_TITENG
	{ 'Solicitação de Investimen'											, .T. }, ; //X3_DESCRIC
	{ 'Solicitação de Investimen'											, .T. }, ; //X3_DESCSPA
	{ 'Solicitação de Investimen'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BA'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLTPIS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITENG
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCRIC
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCSPA
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BB'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLTCOF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. COF'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. COF'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. COF'														, .T. }, ; //X3_TITENG
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCRIC
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCSPA
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BC'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLTICM'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITENG
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCRIC
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCSPA
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BD'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDESCZF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desc Zona Fr'														, .T. }, ; //X3_TITULO
	{ 'Desc Zona Fr'														, .T. }, ; //X3_TITSPA
	{ 'Desc Zona Fr'														, .T. }, ; //X3_TITENG
	{ 'Desconto Zona Franca'												, .T. }, ; //X3_DESCRIC
	{ 'Desconto Zona Franca'												, .T. }, ; //X3_DESCSPA
	{ 'Desconto Zona Franca'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BE'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YRESULT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Result. Emp.'														, .T. }, ; //X3_TITULO
	{ 'Result. Emp.'														, .T. }, ; //X3_TITSPA
	{ 'Result. Emp.'														, .T. }, ; //X3_TITENG
	{ 'Resultado Empresa'													, .T. }, ; //X3_DESCRIC
	{ 'Resultado Empresa'													, .T. }, ; //X3_DESCSPA
	{ 'Resultado Empresa'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOX
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOXSPA
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BF'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YRESUL2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Result.Emp.2'														, .T. }, ; //X3_TITULO
	{ 'Result.Emp.2'														, .T. }, ; //X3_TITSPA
	{ 'Result.Emp.2'														, .T. }, ; //X3_TITENG
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCRIC
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCSPA
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'S=Sim;N=Nao'															, .T. }, ; //X3_CBOX
	{ 'S=Sim;N=Nao'															, .T. }, ; //X3_CBOXSPA
	{ 'S=Sim;N=Nao'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BG'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YMRGCLI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Mrg. Regra'														, .T. }, ; //X3_TITULO
	{ '% Mrg. Regra'														, .T. }, ; //X3_TITSPA
	{ '% Mrg. Regra'														, .T. }, ; //X3_TITENG
	{ '% Margem Regra'														, .T. }, ; //X3_DESCRIC
	{ '% Margem Regra'														, .T. }, ; //X3_DESCSPA
	{ '% Margem Regra'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BH'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YREGMRG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Regra Margem'														, .T. }, ; //X3_TITULO
	{ 'Regra Margem'														, .T. }, ; //X3_TITSPA
	{ 'Regra Margem'														, .T. }, ; //X3_TITENG
	{ 'Regra Margem'														, .T. }, ; //X3_DESCRIC
	{ 'Regra Margem'														, .T. }, ; //X3_DESCSPA
	{ 'Regra Margem'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BI'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PROGRAM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Programa'															, .T. }, ; //X3_TITULO
	{ 'Programa'															, .T. }, ; //X3_TITSPA
	{ 'Program'																, .T. }, ; //X3_TITENG
	{ 'Programa'															, .T. }, ; //X3_DESCRIC
	{ 'Programa'															, .T. }, ; //X3_DESCSPA
	{ 'Program'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BJ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FCICOD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 36																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Codigo FCI'															, .T. }, ; //X3_TITULO
	{ 'Codigo FCI'															, .T. }, ; //X3_TITSPA
	{ 'FCI Code'															, .T. }, ; //X3_TITENG
	{ 'Codigo FCI'															, .T. }, ; //X3_DESCRIC
	{ 'Codigo FCI'															, .T. }, ; //X3_DESCSPA
	{ 'FCI Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BK'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VDMOST'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo de Peça'														, .T. }, ; //X3_TITULO
	{ 'Tipo Pieza'															, .T. }, ; //X3_TITSPA
	{ 'Part Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Peça'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo Peça'															, .T. }, ; //X3_DESCSPA
	{ 'Part Type'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("NMS")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'N=Normal;M=Mostruario;S=Saldao'										, .T. }, ; //X3_CBOX
	{ 'N=Normal;M=Mostrador;S=Saldo'										, .T. }, ; //X3_CBOXSPA
	{ 'N=Regular;M=Display;S=On Sale'										, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BL'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VDOBS'															, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Obs. Peça'															, .T. }, ; //X3_TITULO
	{ 'Obs. Pieza'															, .T. }, ; //X3_TITSPA
	{ 'Part Remark'															, .T. }, ; //X3_TITENG
	{ 'Observação da Peça'													, .T. }, ; //X3_DESCRIC
	{ 'Observacio de la Pieza'												, .T. }, ; //X3_DESCSPA
	{ 'Part Remark'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BM'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVENDR2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vend. 2 Resc'														, .T. }, ; //X3_TITULO
	{ 'Vend. 2 Resc'														, .T. }, ; //X3_TITSPA
	{ 'Vend. 2 Resc'														, .T. }, ; //X3_TITENG
	{ 'Vendedor 2 Rescisão'													, .T. }, ; //X3_DESCRIC
	{ 'Vendedor 2 Rescisão'													, .T. }, ; //X3_DESCSPA
	{ 'Vendedor 2 Rescisão'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BN'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVENDR3'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vend. 3 Resc'														, .T. }, ; //X3_TITULO
	{ 'Vend. 3 Resc'														, .T. }, ; //X3_TITSPA
	{ 'Vend. 3 Resc'														, .T. }, ; //X3_TITENG
	{ 'Vendedor 3 Rescisão'													, .T. }, ; //X3_DESCRIC
	{ 'Vendedor 3 Rescisão'													, .T. }, ; //X3_DESCSPA
	{ 'Vendedor 3 Rescisão'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BO'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVENDR4'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vend. 4 Resc'														, .T. }, ; //X3_TITULO
	{ 'Vend. 4 Resc'														, .T. }, ; //X3_TITSPA
	{ 'Vend. 4 Resc'														, .T. }, ; //X3_TITENG
	{ 'Vendedor 4 Rescisão'													, .T. }, ; //X3_DESCRIC
	{ 'Vendedor 4 Rescisão'													, .T. }, ; //X3_DESCSPA
	{ 'Vendedor 4 Rescisão'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BP'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVENDR5'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vend. 5 Resc'														, .T. }, ; //X3_TITULO
	{ 'Vend. 5 Resc'														, .T. }, ; //X3_TITSPA
	{ 'Vend. 5 Resc'														, .T. }, ; //X3_TITENG
	{ 'Vendedor 5 Rescisão'													, .T. }, ; //X3_DESCRIC
	{ 'Vendedor 5 Rescisão'													, .T. }, ; //X3_DESCSPA
	{ 'Vendedor 5 Rescisão'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BQ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPCREC2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Com. 2 Res'														, .T. }, ; //X3_TITULO
	{ '% Com. 2 Res'														, .T. }, ; //X3_TITSPA
	{ '% Com. 2 Res'														, .T. }, ; //X3_TITENG
	{ '% Comissão 2 Rescisão'												, .T. }, ; //X3_DESCRIC
	{ '% Comissão 2 Rescisão'												, .T. }, ; //X3_DESCSPA
	{ '% Comissão 2 Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BR'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YCODREF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Ref PA'															, .T. }, ; //X3_TITULO
	{ 'Cod. Ref PA'															, .T. }, ; //X3_TITSPA
	{ 'Cod. Ref PA'															, .T. }, ; //X3_TITENG
	{ 'Cod. Ref PA'															, .T. }, ; //X3_DESCRIC
	{ 'Cod. Ref PA'															, .T. }, ; //X3_DESCSPA
	{ 'Cod. Ref PA'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SB1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Vazio() .Or. ExistCpo("SB1")'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BS'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPCREC3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Com. 3 Res'														, .T. }, ; //X3_TITULO
	{ '% Com. 3 Res'														, .T. }, ; //X3_TITSPA
	{ '% Com. 3 Res'														, .T. }, ; //X3_TITENG
	{ '% Comissão 3 Rescisão'												, .T. }, ; //X3_DESCRIC
	{ '% Comissão 3 Rescisão'												, .T. }, ; //X3_DESCSPA
	{ '% Comissão 3 Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BT'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPCREC4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Com. 4 Res'														, .T. }, ; //X3_TITULO
	{ '% Com. 4 Res'														, .T. }, ; //X3_TITSPA
	{ '% Com. 4 Res'														, .T. }, ; //X3_TITENG
	{ '% Comissão 4 Rescisão'												, .T. }, ; //X3_DESCRIC
	{ '% Comissão 4 Rescisão'												, .T. }, ; //X3_DESCSPA
	{ '% Comissão 4 Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BU'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPCREC5'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Com. 5 Res'														, .T. }, ; //X3_TITULO
	{ '% Com. 5 Res'														, .T. }, ; //X3_TITSPA
	{ '% Com. 5 Res'														, .T. }, ; //X3_TITENG
	{ '% Comissão 5 Rescisão'												, .T. }, ; //X3_DESCRIC
	{ '% Comissão 5 Rescisão'												, .T. }, ; //X3_DESCSPA
	{ '% Comissão 5 Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BV'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLCRE2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.2 Rec'														, .T. }, ; //X3_TITULO
	{ 'Vl.Com.2 Rec'														, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.2 Rec'														, .T. }, ; //X3_TITENG
	{ 'Valor Comissão 2 Rescisão'											, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão 2 Rescisão'											, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão 2 Rescisão'											, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BW'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLCRE3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.3 Rec'														, .T. }, ; //X3_TITULO
	{ 'Vl.Com.3 Rec'														, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.3 Rec'														, .T. }, ; //X3_TITENG
	{ 'Valor Comissão 3 Rescisão'											, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão 3 Rescisão'											, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão 3 Rescisão'											, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BX'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLCRE4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.4 Rec'														, .T. }, ; //X3_TITULO
	{ 'Vl.Com.4 Rec'														, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.4 Rec'														, .T. }, ; //X3_TITENG
	{ 'Valor Comissão 4 Rescisão'											, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão 4 Rescisão'											, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão 4 Rescisão'											, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'BZ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVLCRE5'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.5 Rec'														, .T. }, ; //X3_TITULO
	{ 'Vl.Com.5 Rec'														, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.5 Rec'														, .T. }, ; //X3_TITENG
	{ 'Valor Comissão 5 Rescisão'											, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão 5 Rescisão'											, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão 5 Rescisão'											, .T. }, ; //X3_DESCENG
	{ '@E 999,999.99'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FUNRURA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Funrural'															, .T. }, ; //X3_TITULO
	{ 'Funrural'															, .T. }, ; //X3_TITSPA
	{ 'FUNRURAL'															, .T. }, ; //X3_TITENG
	{ 'Valor do Funrural'													, .T. }, ; //X3_DESCRIC
	{ 'Valor del Funrural'													, .T. }, ; //X3_DESCSPA
	{ 'FUNRURAL Value'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FETAB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Fetab'																, .T. }, ; //X3_TITULO
	{ 'Fetab'																, .T. }, ; //X3_TITSPA
	{ 'FETAB'																, .T. }, ; //X3_TITENG
	{ 'Valor do Fetab'														, .T. }, ; //X3_DESCRIC
	{ 'Valor del Fetab'														, .T. }, ; //X3_DESCSPA
	{ 'FETAB Value'															, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODROM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod Romaneio'														, .T. }, ; //X3_TITULO
	{ 'Cod List Emb'														, .T. }, ; //X3_TITSPA
	{ 'Pack List Cd'														, .T. }, ; //X3_TITENG
	{ 'Codigo do Romaneio'													, .T. }, ; //X3_DESCRIC
	{ 'Cod de Lista de Embarque'											, .T. }, ; //X3_DESCSPA
	{ 'Packing List Code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Vazio() .Or. ExistCpo("NPR")'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VLIMPOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Import'															, .T. }, ; //X3_TITULO
	{ 'Vl.Import'															, .T. }, ; //X3_TITSPA
	{ 'Import Vl'															, .T. }, ; //X3_TITENG
	{ 'Valor da Importação'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la importacion'												, .T. }, ; //X3_DESCSPA
	{ 'Import Value'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NRSEQCQ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nro.Seq. CQ'															, .T. }, ; //X3_TITULO
	{ 'Nro.Sec. CC'															, .T. }, ; //X3_TITSPA
	{ 'Seq. No. CQ'															, .T. }, ; //X3_TITENG
	{ 'Nro. Sequencial do CQ'												, .T. }, ; //X3_DESCRIC
	{ 'Nro. Secuencial de CC'												, .T. }, ; //X3_DESCSPA
	{ 'Sequence No. of the CQ'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_INFAD'															, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 80																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Inf. Ad. Pro'														, .T. }, ; //X3_TITULO
	{ 'Inf. Ad. Pro'														, .T. }, ; //X3_TITSPA
	{ 'Prod.Add.Inf'														, .T. }, ; //X3_TITENG
	{ 'Inf. Adicional do produto'											, .T. }, ; //X3_DESCRIC
	{ 'Inf. Adicionales Prod'												, .T. }, ; //X3_DESCSPA
	{ 'Product Additional Info'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'E_MSMM(SC6->C6_CODINF,80)'											, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YQTDSUG'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_TITULO
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_TITSPA
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_TITENG
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_DESCRIC
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_DESCSPA
	{ 'Qtd.Sug.Lote'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPDEDUZ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Deduz'															, .T. }, ; //X3_TITULO
	{ 'Tipo Deducci'														, .T. }, ; //X3_TITSPA
	{ 'Deduc. Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Dedução'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Deduccion'													, .T. }, ; //X3_DESCSPA
	{ 'Deduction Type'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Percentual;2=Valor'												, .T. }, ; //X3_CBOX
	{ '1=Porcentaje;2=Valor'												, .T. }, ; //X3_CBOXSPA
	{ '1=Percentage;2=Value'												, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_MOTDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mot Deduz'															, .T. }, ; //X3_TITULO
	{ 'Mot Deduccio'														, .T. }, ; //X3_TITSPA
	{ 'Deduct. Reas'														, .T. }, ; //X3_TITENG
	{ 'Motivo da Dedução'													, .T. }, ; //X3_DESCRIC
	{ 'Motivo de Deduccion'													, .T. }, ; //X3_DESCSPA
	{ 'Reason of Deduction'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Despesas com Materiais;2=Despesas com Sub-empreitada'				, .T. }, ; //X3_CBOX
	{ '1=Gastos con Materiales;2=Gastos con Sub-contratada'					, .T. }, ; //X3_CBOXSPA
	{ '1=Expenses with Materials;2=Expenses with Sub-pieceworks'			, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FORDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'For. Ded.'															, .T. }, ; //X3_TITULO
	{ 'Prov. Ded'															, .T. }, ; //X3_TITSPA
	{ 'Deduc.Suppl'															, .T. }, ; //X3_TITENG
	{ 'Fornecedor Ded.'														, .T. }, ; //X3_DESCRIC
	{ 'Proveedor Deduccion'													, .T. }, ; //X3_DESCSPA
	{ 'Deduction Supplier'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ 'S'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'C9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YLOTSUG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lot.Sugerido'														, .T. }, ; //X3_TITULO
	{ 'Lot.Sugerido'														, .T. }, ; //X3_TITSPA
	{ 'Lot.Sugerido'														, .T. }, ; //X3_TITENG
	{ 'Lot.Sugerido'														, .T. }, ; //X3_DESCRIC
	{ 'Lot.Sugerido'														, .T. }, ; //X3_DESCSPA
	{ 'Lot.Sugerido'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CA'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YLOTTOT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_TITULO
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_TITSPA
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_TITENG
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_DESCRIC
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_DESCSPA
	{ 'Tot.Lot.Sug.'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CB'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PEDVINC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped. Vinculo'														, .T. }, ; //X3_TITULO
	{ 'Ped. Vinculo'														, .T. }, ; //X3_TITSPA
	{ 'Ass. Order'															, .T. }, ; //X3_TITENG
	{ 'Numero do Pedido Vinculad'											, .T. }, ; //X3_DESCRIC
	{ 'Numero Pedido Vinculado'												, .T. }, ; //X3_DESCSPA
	{ 'Association Order Number'											, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SC5",M->C6_PEDVINC,1)'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SC5VIN'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CC'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDTDISP'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Disp.OP'															, .T. }, ; //X3_TITULO
	{ 'Dt.Disp.OP'															, .T. }, ; //X3_TITSPA
	{ 'Dt.Disp.OP'															, .T. }, ; //X3_TITENG
	{ 'Data Disponibilidade OP'												, .T. }, ; //X3_DESCRIC
	{ 'Data Disponibilidade OP'												, .T. }, ; //X3_DESCSPA
	{ 'Data Disponibilidade OP'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CD'																	, .T. }, ; //X3_ORDEM
	{ 'C6_REVPROD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Revisão'																, .T. }, ; //X3_TITULO
	{ 'Revision'															, .T. }, ; //X3_TITSPA
	{ 'Review'																, .T. }, ; //X3_TITENG
	{ 'Revisão do produto'													, .T. }, ; //X3_DESCRIC
	{ 'Revision del producto'												, .T. }, ; //X3_DESCSPA
	{ 'Product Review'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(190) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CE'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PRODFIN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Prod Final'															, .T. }, ; //X3_TITULO
	{ 'Prod Final'															, .T. }, ; //X3_TITSPA
	{ 'Final Prod.'															, .T. }, ; //X3_TITENG
	{ 'Produto Final'														, .T. }, ; //X3_DESCRIC
	{ 'Producto Final'														, .T. }, ; //X3_DESCSPA
	{ 'Final Product'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .or. ExistCPO("SB1")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SB1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '030'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CF'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YMOTIVO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mot.Canc/Exc'														, .T. }, ; //X3_TITULO
	{ 'Mot.Canc/Exc'														, .T. }, ; //X3_TITSPA
	{ 'Mot.Canc/Exc'														, .T. }, ; //X3_TITENG
	{ 'Motivo Cancel. ou Excl.'												, .T. }, ; //X3_DESCRIC
	{ 'Motivo Cancel. ou Excl.'												, .T. }, ; //X3_DESCSPA
	{ 'Motivo Cancel. ou Excl.'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ZZ'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CG'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDCAT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'DCAT'																, .T. }, ; //X3_TITULO
	{ 'DCAT'																, .T. }, ; //X3_TITSPA
	{ 'DCAT'																, .T. }, ; //X3_TITENG
	{ 'Desconto Categoria Politi'											, .T. }, ; //X3_DESCRIC
	{ 'Desconto Categoria Politi'											, .T. }, ; //X3_DESCSPA
	{ 'Desconto Categoria Politi'											, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CH'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDREG'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'DREG'																, .T. }, ; //X3_TITULO
	{ 'DREG'																, .T. }, ; //X3_TITSPA
	{ 'DREG'																, .T. }, ; //X3_TITENG
	{ 'Desconto Regiao'														, .T. }, ; //X3_DESCRIC
	{ 'Desconto Regiao'														, .T. }, ; //X3_DESCSPA
	{ 'Desconto Regiao'														, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CI'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDMIX'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'DGER'																, .T. }, ; //X3_TITULO
	{ 'DGER'																, .T. }, ; //X3_TITSPA
	{ 'DGER'																, .T. }, ; //X3_TITENG
	{ 'Desconto Mix'														, .T. }, ; //X3_DESCRIC
	{ 'Desconto Mix'														, .T. }, ; //X3_DESCSPA
	{ 'Desconto Mix'														, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CJ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YENTREG'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Copia Dt.Ent'														, .T. }, ; //X3_TITULO
	{ 'Copia Dt.Ent'														, .T. }, ; //X3_TITSPA
	{ 'Copia Dt.Ent'														, .T. }, ; //X3_TITENG
	{ 'Copia Data Entrega'													, .T. }, ; //X3_DESCRIC
	{ 'Copia Data Entrega'													, .T. }, ; //X3_DESCSPA
	{ 'Copia Data Entrega'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CK'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVALOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Copia Vl.Tot'														, .T. }, ; //X3_TITULO
	{ 'Copia Vl.Tot'														, .T. }, ; //X3_TITSPA
	{ 'Copia Vl.Tot'														, .T. }, ; //X3_TITENG
	{ 'Copia Valor Total'													, .T. }, ; //X3_DESCRIC
	{ 'Copia Valor Total'													, .T. }, ; //X3_DESCSPA
	{ 'Copia Valor Total'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CL'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YEORICH'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Emp.Ori.PCha'														, .T. }, ; //X3_TITULO
	{ 'Emp.Ori.PCha'														, .T. }, ; //X3_TITSPA
	{ 'Emp.Ori.PCha'														, .T. }, ; //X3_TITENG
	{ 'Empresa Origem Ped Chao'												, .T. }, ; //X3_DESCRIC
	{ 'Empresa Origem Ped Chao'												, .T. }, ; //X3_DESCSPA
	{ 'Empresa Origem Ped Chao'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CM'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YPITCHA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped.It.Chao'															, .T. }, ; //X3_TITULO
	{ 'Ped.It.Chao'															, .T. }, ; //X3_TITSPA
	{ 'Ped.It.Chao'															, .T. }, ; //X3_TITENG
	{ 'Nro do pedido de chao ref'											, .T. }, ; //X3_DESCRIC
	{ 'Nro do pedido de chao ref'											, .T. }, ; //X3_DESCSPA
	{ 'Nro do pedido de chao ref'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CN'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YRAVLOT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Autz.Lot.Dif'														, .T. }, ; //X3_TITULO
	{ 'Autz.Lot.Dif'														, .T. }, ; //X3_TITSPA
	{ 'Autz.Lot.Dif'														, .T. }, ; //X3_TITENG
	{ 'Autoriza Lote Diferente?'											, .T. }, ; //X3_DESCRIC
	{ 'Autoriza Lote Diferente?'											, .T. }, ; //X3_DESCSPA
	{ 'Autoriza Lote Diferente?'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CO'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YLOTBAS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lot.Base'															, .T. }, ; //X3_TITULO
	{ 'Lot.Base'															, .T. }, ; //X3_TITSPA
	{ 'Lot.Base'															, .T. }, ; //X3_TITENG
	{ 'Lote para res.pedido base'											, .T. }, ; //X3_DESCRIC
	{ 'Lote para res.pedido base'											, .T. }, ; //X3_DESCSPA
	{ 'Lote para res.pedido base'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CP'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YOSBAS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'OP.Base'																, .T. }, ; //X3_TITULO
	{ 'OP.Base'																, .T. }, ; //X3_TITSPA
	{ 'OP.Base'																, .T. }, ; //X3_TITENG
	{ 'OP para res.pedido base'												, .T. }, ; //X3_DESCRIC
	{ 'OP para res.pedido base'												, .T. }, ; //X3_DESCSPA
	{ 'OP para res.pedido base'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CQ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YFATMUL'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 6																		, .T. }, ; //X3_DECIMAL
	{ 'Fator Multip'														, .T. }, ; //X3_TITULO
	{ 'Fator Multip'														, .T. }, ; //X3_TITSPA
	{ 'Fator Multip'														, .T. }, ; //X3_TITENG
	{ 'Fator Multiplicador'													, .T. }, ; //X3_DESCRIC
	{ 'Fator Multiplicador'													, .T. }, ; //X3_DESCSPA
	{ 'Fator Multiplicador'													, .T. }, ; //X3_DESCENG
	{ '@E 999.999999'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CR'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YFATRED'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 6																		, .T. }, ; //X3_DECIMAL
	{ 'Fat. Redutor'														, .T. }, ; //X3_TITULO
	{ 'Fat. Redutor'														, .T. }, ; //X3_TITSPA
	{ 'Fat. Redutor'														, .T. }, ; //X3_TITENG
	{ 'Fat. Redutor de preco LM'											, .T. }, ; //X3_DESCRIC
	{ 'Fat. Redutor de preco LM'											, .T. }, ; //X3_DESCSPA
	{ 'Fat. Redutor de preco LM'											, .T. }, ; //X3_DESCENG
	{ '@E 999.999999'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CS'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YECONAM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'N. Am. Eco'															, .T. }, ; //X3_TITULO
	{ 'N. Am. Eco'															, .T. }, ; //X3_TITSPA
	{ 'N. Am. Eco'															, .T. }, ; //X3_TITENG
	{ 'Numero Amostra Ecosis'												, .T. }, ; //X3_DESCRIC
	{ 'Numero Amostra Ecosis'												, .T. }, ; //X3_DESCSPA
	{ 'Numero Amostra Ecosis'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CT'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YSTTSAM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Stat Am. Eco'														, .T. }, ; //X3_TITULO
	{ 'Stat Am. Eco'														, .T. }, ; //X3_TITSPA
	{ 'Stat Am. Eco'														, .T. }, ; //X3_TITENG
	{ 'Status da Amostra Ecosis'											, .T. }, ; //X3_DESCRIC
	{ 'Status da Amostra Ecosis'											, .T. }, ; //X3_DESCSPA
	{ 'Status da Amostra Ecosis'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CU'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMGAR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Gar Est'														, .T. }, ; //X3_TITULO
	{ 'Item Gar Ext'														, .T. }, ; //X3_TITSPA
	{ 'Ext War Item'														, .T. }, ; //X3_TITENG
	{ 'Item Garantia Estendida'												, .T. }, ; //X3_DESCRIC
	{ 'Item Garantia Extendida'												, .T. }, ; //X3_DESCSPA
	{ 'Extended Warranty Item'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CV'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ORCGAR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Orca Gar Est'														, .T. }, ; //X3_TITULO
	{ 'Pres Gar Ext'														, .T. }, ; //X3_TITSPA
	{ 'Ext War Quot'														, .T. }, ; //X3_TITENG
	{ 'Orcamento Garantia Estend'											, .T. }, ; //X3_DESCRIC
	{ 'Presup. Gar. Extendida'												, .T. }, ; //X3_DESCSPA
	{ 'Extended Warranty Quotati'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'CW'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SDOCORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série Orig.'															, .T. }, ; //X3_TITULO
	{ 'Serie Orig.'															, .T. }, ; //X3_TITSPA
	{ 'Orig. Series'														, .T. }, ; //X3_TITENG
	{ 'Série da N.F. Original'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de Fact. Original'												, .T. }, ; //X3_DESCSPA
	{ 'Original Invoice Series'												, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '095'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_LOJDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loj. Ded.'															, .T. }, ; //X3_TITULO
	{ 'Tienda Ded'															, .T. }, ; //X3_TITSPA
	{ 'Deduc. Unit'															, .T. }, ; //X3_TITENG
	{ 'Loja Ded.'															, .T. }, ; //X3_DESCRIC
	{ 'Tienda  Ded.'														, .T. }, ; //X3_DESCSPA
	{ 'Deduc. Store'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SDOC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série Doc.'															, .T. }, ; //X3_TITULO
	{ 'Serie Doc.'															, .T. }, ; //X3_TITSPA
	{ 'Inv. Series'															, .T. }, ; //X3_TITENG
	{ 'Série do Documento Fiscal'											, .T. }, ; //X3_DESCRIC
	{ 'Serie de Documento Fiscal'											, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '095'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SERDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ser. Ded.'															, .T. }, ; //X3_TITULO
	{ 'Ser. Ded.'															, .T. }, ; //X3_TITSPA
	{ 'Deduct. Ser.'														, .T. }, ; //X3_TITENG
	{ 'Serie NF Ded.'														, .T. }, ; //X3_DESCRIC
	{ 'Serie Fact Deduccion'												, .T. }, ; //X3_DESCSPA
	{ 'Series Deduction Invoice'											, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '094'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NFDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'NF. Ded.'															, .T. }, ; //X3_TITULO
	{ 'Fact. Ded.'															, .T. }, ; //X3_TITSPA
	{ 'Deduct. NF'															, .T. }, ; //X3_TITENG
	{ 'NF Ded.'																, .T. }, ; //X3_DESCRIC
	{ 'Fact. Deduccion'														, .T. }, ; //X3_DESCSPA
	{ 'Deduction Invoice'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '018'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VLNFD'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 16																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Val NF Ded.'															, .T. }, ; //X3_TITULO
	{ 'Val Fac Ded.'														, .T. }, ; //X3_TITSPA
	{ 'Val. Ded. NF'														, .T. }, ; //X3_TITENG
	{ 'Valor de NF Ded'														, .T. }, ; //X3_DESCRIC
	{ 'Val Fact. Ded.'														, .T. }, ; //X3_DESCSPA
	{ 'Val Deduc. Invoice'													, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PCDED'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Ded.'																, .T. }, ; //X3_TITULO
	{ '% Ded.'																, .T. }, ; //X3_TITSPA
	{ '% Ded.'																, .T. }, ; //X3_TITENG
	{ 'Percentual de dedução'												, .T. }, ; //X3_DESCRIC
	{ 'Porcentuje de Deduccion'												, .T. }, ; //X3_DESCSPA
	{ 'Deduction Percentage'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SDOCDED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sér. Ded.'															, .T. }, ; //X3_TITULO
	{ 'Ser. Ded.'															, .T. }, ; //X3_TITSPA
	{ 'Ded. Ser.'															, .T. }, ; //X3_TITENG
	{ 'Série NF Dedução'													, .T. }, ; //X3_DESCRIC
	{ 'Serie Fact Deduccion'												, .T. }, ; //X3_DESCSPA
	{ 'Invoice Deduction Series'											, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '095'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_VLDED'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 16																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Val Ded.'															, .T. }, ; //X3_TITULO
	{ 'Val Ded.'															, .T. }, ; //X3_TITSPA
	{ 'Ded. Val.'															, .T. }, ; //X3_TITENG
	{ 'Valor de dedução'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Deduccion'												, .T. }, ; //X3_DESCSPA
	{ 'Deduction Value'														, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PVCOMOP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'PV com OP'															, .T. }, ; //X3_TITULO
	{ 'PV con OP'															, .T. }, ; //X3_TITSPA
	{ 'SO with PO'															, .T. }, ; //X3_TITENG
	{ 'PV com OP'															, .T. }, ; //X3_DESCRIC
	{ 'Pedido de Venta con OP'												, .T. }, ; //X3_DESCSPA
	{ 'Sales Order with PO'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_RATEIO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Rateio'																, .T. }, ; //X3_TITULO
	{ 'Prorrateo'															, .T. }, ; //X3_TITSPA
	{ 'Apport.'																, .T. }, ; //X3_TITENG
	{ 'Rateio'																, .T. }, ; //X3_DESCRIC
	{ 'Prorrateo'															, .T. }, ; //X3_DESCSPA
	{ 'Apportionment'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "'2'"																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Nao'															, .T. }, ; //X3_CBOX
	{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SDOCSD1'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série Doc.'															, .T. }, ; //X3_TITULO
	{ 'Serie Doc.'															, .T. }, ; //X3_TITSPA
	{ 'Inv. Series'															, .T. }, ; //X3_TITENG
	{ 'Série do Documento Fiscal'											, .T. }, ; //X3_DESCRIC
	{ 'Serie de Documento Fiscal'											, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '095'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_MSEXP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ident.Exp.'															, .T. }, ; //X3_TITULO
	{ 'Ident.Exp.'															, .T. }, ; //X3_TITSPA
	{ 'Ident.Exp.'															, .T. }, ; //X3_TITENG
	{ 'Ident.Exp.Dados'														, .T. }, ; //X3_DESCRIC
	{ 'Ident.Exp.Dados'														, .T. }, ; //X3_DESCSPA
	{ 'Ident.Exp.Dados'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'L'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'D9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YSTAT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Status'																, .T. }, ; //X3_TITULO
	{ 'Status'																, .T. }, ; //X3_TITSPA
	{ 'Status'																, .T. }, ; //X3_TITENG
	{ 'Status Pedido'														, .T. }, ; //X3_DESCRIC
	{ 'Status Pedido'														, .T. }, ; //X3_DESCSPA
	{ 'Status Pedido'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DA'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CTVAR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cultivar'															, .T. }, ; //X3_TITULO
	{ 'Cultivar'															, .T. }, ; //X3_TITSPA
	{ 'Cultivate'															, .T. }, ; //X3_TITENG
	{ 'Cultivar'															, .T. }, ; //X3_DESCRIC
	{ 'Cultivar'															, .T. }, ; //X3_DESCSPA
	{ 'Cultivate'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio()  .Or. ExistCpo('NP4',M->C6_CTVAR,1)"							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NP4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DB'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CATEG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Categoria'															, .T. }, ; //X3_TITULO
	{ 'Categoría'															, .T. }, ; //X3_TITSPA
	{ 'Category'															, .T. }, ; //X3_TITENG
	{ 'Categoria'															, .T. }, ; //X3_DESCRIC
	{ 'Categoría'															, .T. }, ; //X3_DESCSPA
	{ 'Category'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio()  .Or. ExistCpo('SX5','K1'+M->C6_CATEG,1)"					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'K1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DC'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PENE'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Peneira'																, .T. }, ; //X3_TITULO
	{ 'Tamiz'																, .T. }, ; //X3_TITSPA
	{ 'Sieve'																, .T. }, ; //X3_TITENG
	{ 'Peneira'																, .T. }, ; //X3_DESCRIC
	{ 'Tamiz'																, .T. }, ; //X3_DESCSPA
	{ 'Sieve'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('NP7',M->C6_PENE,1)"							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NP7'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DD'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CULTRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cultura'																, .T. }, ; //X3_TITULO
	{ 'Cultivo'																, .T. }, ; //X3_TITSPA
	{ 'Culture'																, .T. }, ; //X3_TITENG
	{ 'Cultura'																, .T. }, ; //X3_DESCRIC
	{ 'Cultivo'																, .T. }, ; //X3_DESCSPA
	{ 'Culture'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('NP3',M->C6_CULTRA,1)"							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NP3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DE'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YOBSMOT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 250																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Obs Mot Canc'														, .T. }, ; //X3_TITULO
	{ 'Obs Mot Canc'														, .T. }, ; //X3_TITSPA
	{ 'Obs Mot Canc'														, .T. }, ; //X3_TITENG
	{ 'Obs motivo cancelamento'												, .T. }, ; //X3_DESCRIC
	{ 'Obs motivo cancelamento'												, .T. }, ; //X3_DESCSPA
	{ 'Obs motivo cancelamento'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DF'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPREPAS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Repasse'														, .T. }, ; //X3_TITULO
	{ 'Tipo de tran'														, .T. }, ; //X3_TITSPA
	{ 'Transfer Typ'														, .T. }, ; //X3_TITENG
	{ 'Tipo de Repasse'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de transferencia'												, .T. }, ; //X3_DESCSPA
	{ 'Type of Transfer'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .OR. ExistCpo("SX5","0G"+M->C6_TPREPAS)'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '0G'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DG'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDELTBI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 19																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Delta BI'															, .T. }, ; //X3_TITULO
	{ 'Delta BI'															, .T. }, ; //X3_TITSPA
	{ 'Delta BI'															, .T. }, ; //X3_TITENG
	{ 'Delta BI'															, .T. }, ; //X3_DESCRIC
	{ 'Delta BI'															, .T. }, ; //X3_DESCSPA
	{ 'Delta BI'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DH'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YDTPP'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Pisc.Ped'														, .T. }, ; //X3_TITULO
	{ 'Dt. Pisc.Ped'														, .T. }, ; //X3_TITSPA
	{ 'Dt. Pisc.Ped'														, .T. }, ; //X3_TITENG
	{ 'Data Piscina Pedido'													, .T. }, ; //X3_DESCRIC
	{ 'Data Piscina Pedido'													, .T. }, ; //X3_DESCSPA
	{ 'Data Piscina Pedido'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DL'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVFRTUN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Frete Unt.'															, .T. }, ; //X3_TITULO
	{ 'Frete Unt.'															, .T. }, ; //X3_TITSPA
	{ 'Frete Unt.'															, .T. }, ; //X3_TITENG
	{ 'Frete Unt.'															, .T. }, ; //X3_DESCRIC
	{ 'Frete Unt.'															, .T. }, ; //X3_DESCSPA
	{ 'Frete Unt.'															, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.9999'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'DM'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YVSEGUN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_TITULO
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_TITSPA
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_TITENG
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_DESCRIC
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_DESCSPA
	{ 'Vlr. Seg./M2'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.9999'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'E4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ABATINS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Abatim. INSS'														, .T. }, ; //X3_TITULO
	{ 'Desc. INSS'															, .T. }, ; //X3_TITSPA
	{ 'INSS Deduc.'															, .T. }, ; //X3_TITENG
	{ 'Valor abatimento / INSS'												, .T. }, ; //X3_DESCRIC
	{ 'Valor descuento / INSS'												, .T. }, ; //X3_DESCSPA
	{ 'INSS/Deduction Value'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'MaFisGet("IT_ABVLINSS").And.Positivo()'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'E6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TNATREC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tab. Nat. Re'														, .T. }, ; //X3_TITULO
	{ 'Tab.Mod.Ing.'														, .T. }, ; //X3_TITSPA
	{ 'Rev Clas Tb'															, .T. }, ; //X3_TITENG
	{ 'Tab. Nat. Receita'													, .T. }, ; //X3_DESCRIC
	{ 'Tab. Mod. Ingresos'													, .T. }, ; //X3_DESCSPA
	{ 'Revenue Class Table'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('CCZ')"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CCZ'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'E7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_BASVEIC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 16																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Base Veiculo'														, .T. }, ; //X3_TITULO
	{ 'V.Tot.F.Ent.'														, .T. }, ; //X3_TITSPA
	{ 'Inv. Total V'														, .T. }, ; //X3_TITENG
	{ 'Base Veiculo'														, .T. }, ; //X3_DESCRIC
	{ 'Valor Total Fact. Entrada'											, .T. }, ; //X3_DESCSPA
	{ 'Inflow Invoice Total Val.'											, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'EJ'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DATAEMB'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data Ini Emb'														, .T. }, ; //X3_TITULO
	{ 'Fch Ini Emb'															, .T. }, ; //X3_TITSPA
	{ 'Dep srt dt'															, .T. }, ; //X3_TITENG
	{ 'Data Inicio Embarque'												, .T. }, ; //X3_DESCRIC
	{ 'Fecha Inicial Embarque'												, .T. }, ; //X3_DESCSPA
	{ 'Departure start date'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(136) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'DDATABASE'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'EK'																	, .T. }, ; //X3_ORDEM
	{ 'C6_YMOTREJ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mtv Rejeição'														, .T. }, ; //X3_TITULO
	{ 'Mtv Rejeição'														, .T. }, ; //X3_TITSPA
	{ 'Mtv Rejeição'														, .T. }, ; //X3_TITENG
	{ 'Mtv Rejeição'														, .T. }, ; //X3_DESCRIC
	{ 'Mtv Rejeição'														, .T. }, ; //X3_DESCSPA
	{ 'Mtv Rejeição'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CNATREC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod Nat Rece'														, .T. }, ; //X3_TITULO
	{ 'Cod.Mod.Ing.'														, .T. }, ; //X3_TITSPA
	{ 'Rev Nat Code'														, .T. }, ; //X3_TITENG
	{ 'Cod Nat Receita'														, .T. }, ; //X3_DESCRIC
	{ 'Cod.Mod.Ingresos'													, .T. }, ; //X3_DESCSPA
	{ 'Revenue Nat Code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("CCZ",M->C6_TNATREC+M->C6_CNATREC)'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_GRPNATR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Grp.Nat.Rec.'														, .T. }, ; //X3_TITULO
	{ 'Grp.Mod.Ing.'														, .T. }, ; //X3_TITSPA
	{ 'Rev Nt Grp'															, .T. }, ; //X3_TITENG
	{ 'Grupo Natureza Receita'												, .T. }, ; //X3_DESCRIC
	{ 'Grupo Modalidad Ingreso'												, .T. }, ; //X3_DESCSPA
	{ 'Revenue Nature Group'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TURNO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Turno'																, .T. }, ; //X3_TITULO
	{ 'Turno'																, .T. }, ; //X3_TITSPA
	{ 'Shift'																, .T. }, ; //X3_TITENG
	{ 'Manhã,Tarde e Noite'													, .T. }, ; //X3_DESCRIC
	{ 'Manana,Tarde y Noche'												, .T. }, ; //X3_DESCSPA
	{ 'Morning,Afternoon, Night'											, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(149) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITPC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item PC'																, .T. }, ; //X3_TITULO
	{ 'Item PC'																, .T. }, ; //X3_TITSPA
	{ 'PO Item'																, .T. }, ; //X3_TITENG
	{ 'Item Ped.Compra Vinc.PV'												, .T. }, ; //X3_DESCRIC
	{ 'Item Ped.Compra Vinc.PV'												, .T. }, ; //X3_DESCSPA
	{ 'Purch.Order Item PV assoc'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DTFIMNT'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Fim N. R.'														, .T. }, ; //X3_TITULO
	{ 'Fc.Fin M.Ing'														, .T. }, ; //X3_TITSPA
	{ 'Rev Nat E Dt'														, .T. }, ; //X3_TITENG
	{ 'Data Fim Nat. Receita'												, .T. }, ; //X3_DESCRIC
	{ 'Fecha fin mod.ingreso'												, .T. }, ; //X3_DESCSPA
	{ 'Revenue Nat End Date'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_FILPED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Fil.Ped.Comp'														, .T. }, ; //X3_TITULO
	{ 'Suc.Ped.Comp'														, .T. }, ; //X3_TITSPA
	{ 'Purch.Ord.Br'														, .T. }, ; //X3_TITENG
	{ 'Filial do Pedido de Compr'											, .T. }, ; //X3_DESCRIC
	{ 'Sucursal Pedido de Compr'											, .T. }, ; //X3_DESCSPA
	{ 'Purchase Order Branch'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'F9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PEDCOM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped.Compra'															, .T. }, ; //X3_TITULO
	{ 'Ped.Compra'															, .T. }, ; //X3_TITSPA
	{ 'Purch.Order'															, .T. }, ; //X3_TITENG
	{ 'Ped.Compra Vinc.ao PV'												, .T. }, ; //X3_DESCRIC
	{ 'Ped.Compra Vinc.al PV'												, .T. }, ; //X3_DESCSPA
	{ 'Purch.Order PV associated'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'WmsComCons()'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SC7WMS'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'G1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITLPRE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item L.Pres.'														, .T. }, ; //X3_TITULO
	{ 'Item L.Pres.'														, .T. }, ; //X3_TITSPA
	{ 'Roll Call I'															, .T. }, ; //X3_TITENG
	{ 'Item da Lista de Presente'											, .T. }, ; //X3_DESCRIC
	{ 'Item de la Lista de Ptes.'											, .T. }, ; //X3_DESCSPA
	{ 'Roll Call Item'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'G2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_D1SERIE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Serie NF'															, .T. }, ; //X3_TITULO
	{ 'Serie Fac.'															, .T. }, ; //X3_TITSPA
	{ 'Inv.Series'															, .T. }, ; //X3_TITENG
	{ 'Serie Nota Fiscal'													, .T. }, ; //X3_DESCRIC
	{ 'Serie Factura'														, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '094'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'G3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_D1DOC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Doc.Ent.'														, .T. }, ; //X3_TITULO
	{ 'Num.Doc.Ent.'														, .T. }, ; //X3_TITSPA
	{ 'Inf.Doc.No.'															, .T. }, ; //X3_TITENG
	{ 'Num. Doc. Entrada'													, .T. }, ; //X3_DESCRIC
	{ 'Num. Doc. Entrada'													, .T. }, ; //X3_DESCSPA
	{ 'Inflow Doc. Number'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'G4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODLPRE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lista Pres.'															, .T. }, ; //X3_TITULO
	{ 'Lista Pres.'															, .T. }, ; //X3_TITSPA
	{ 'Roll Call'															, .T. }, ; //X3_TITENG
	{ 'Lista de Presentes'													, .T. }, ; //X3_DESCRIC
	{ 'Lista de Presentes'													, .T. }, ; //X3_DESCSPA
	{ 'Roll Call'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'G5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_D1ITEM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item NF.'															, .T. }, ; //X3_TITULO
	{ 'Item Fac.'															, .T. }, ; //X3_TITSPA
	{ 'Inv.Item'															, .T. }, ; //X3_TITENG
	{ 'Item Nota Fiscal'													, .T. }, ; //X3_DESCRIC
	{ 'Item Factura'														, .T. }, ; //X3_DESCSPA
	{ 'Invoice Item'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'I6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CODINF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Inf.'															, .T. }, ; //X3_TITULO
	{ 'Cod. Inf.'															, .T. }, ; //X3_TITSPA
	{ 'Info Code'															, .T. }, ; //X3_TITENG
	{ 'Cod. Informacao do prod'												, .T. }, ; //X3_DESCRIC
	{ 'Cod. Informacion Producto'											, .T. }, ; //X3_DESCSPA
	{ 'Product Info Code'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'I8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMPC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item.Ped.Com'														, .T. }, ; //X3_TITULO
	{ 'Item.Ped.Com'														, .T. }, ; //X3_TITSPA
	{ 'Purch Ord It'														, .T. }, ; //X3_TITENG
	{ 'Item.Ped.Comp.'														, .T. }, ; //X3_DESCRIC
	{ 'Item.Ped.Comp.'														, .T. }, ; //X3_DESCSPA
	{ 'Purchase Order Item'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'I9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_NUMPCOM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Ped.Comp'														, .T. }, ; //X3_TITULO
	{ 'Num.Ped.Comp'														, .T. }, ; //X3_TITSPA
	{ 'Purch Ord No'														, .T. }, ; //X3_TITENG
	{ 'Num.Ped.Comp.'														, .T. }, ; //X3_DESCRIC
	{ 'Num.Ped.Comp.'														, .T. }, ; //X3_DESCSPA
	{ 'Purchase Order No.'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_HORENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Hora Entrega'														, .T. }, ; //X3_TITULO
	{ 'Hora Entrega'														, .T. }, ; //X3_TITSPA
	{ 'Delivery Tm.'														, .T. }, ; //X3_TITENG
	{ 'Hora da Entrega'														, .T. }, ; //X3_DESCRIC
	{ 'Hora da Entrega'														, .T. }, ; //X3_DESCSPA
	{ 'Delivery Time'														, .T. }, ; //X3_DESCENG
	{ '@R 99:99'															, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. AtVldHora(M->C6_HORENT)'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_PMSID'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'ID Protheus'															, .T. }, ; //X3_TITULO
	{ 'ID Protheus'															, .T. }, ; //X3_TITSPA
	{ 'Protheus ID'															, .T. }, ; //X3_TITENG
	{ 'ID Protheus'															, .T. }, ; //X3_DESCRIC
	{ 'ID Protheus'															, .T. }, ; //X3_DESCSPA
	{ 'Protheus ID'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'C. de Custo'															, .T. }, ; //X3_TITULO
	{ 'C.Costo'																, .T. }, ; //X3_TITSPA
	{ 'Cost Center'															, .T. }, ; //X3_TITENG
	{ 'Centro de Custo'														, .T. }, ; //X3_DESCRIC
	{ 'Centro de costo'														, .T. }, ; //X3_DESCSPA
	{ 'Cost Center'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. CTB105CC()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '004'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CONTA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'C Contabil'															, .T. }, ; //X3_TITULO
	{ 'C Contable'															, .T. }, ; //X3_TITSPA
	{ 'Led Acc'																, .T. }, ; //X3_TITENG
	{ 'Conta Contábil'														, .T. }, ; //X3_DESCRIC
	{ 'Cuenta contable'														, .T. }, ; //X3_DESCSPA
	{ 'Ledger Account'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'vazio() .or. Ctb105Cta()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CT1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '003'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ITEMCTA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Conta'															, .T. }, ; //X3_TITULO
	{ 'Ítem cuenta'															, .T. }, ; //X3_TITSPA
	{ 'Acc Item'															, .T. }, ; //X3_TITENG
	{ 'Item da Conta Contabil'												, .T. }, ; //X3_DESCRIC
	{ 'Ítem de Cta Contable'												, .T. }, ; //X3_DESCSPA
	{ 'Ledger Account Item'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. Ctb105Item()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTD'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '005'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'K8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CLVL'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Classe Valor'														, .T. }, ; //X3_TITULO
	{ 'Clase valor'															, .T. }, ; //X3_TITSPA
	{ 'Val Class'															, .T. }, ; //X3_TITENG
	{ 'Classe Valor Contabil'												, .T. }, ; //X3_DESCRIC
	{ 'Clase valor contable'												, .T. }, ; //X3_DESCSPA
	{ 'Accounting Val Class'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. Ctb105ClVl()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTH'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '006'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'M8'																	, .T. }, ; //X3_ORDEM
	{ 'C6_SOLCOM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Solicit'														, .T. }, ; //X3_TITULO
	{ 'Num. Solicit'														, .T. }, ; //X3_TITSPA
	{ 'Req. Nr.'															, .T. }, ; //X3_TITENG
	{ 'Número da Solicitação de'											, .T. }, ; //X3_DESCRIC
	{ 'Numero de Solicitud de'												, .T. }, ; //X3_DESCSPA
	{ 'Number of Request of'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'M9'																	, .T. }, ; //X3_ORDEM
	{ 'C6_ALMTERC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Armz Terc.'															, .T. }, ; //X3_TITULO
	{ 'Alm. Terc.'															, .T. }, ; //X3_TITSPA
	{ 'Th Warehouse'														, .T. }, ; //X3_TITENG
	{ 'Armazem de Terceiros'												, .T. }, ; //X3_DESCRIC
	{ 'Almacen de Terceros'													, .T. }, ; //X3_DESCSPA
	{ 'Third Party Warehouse'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'IsAlmTerc(M->C6_ALMTERC)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N0'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CCUSTO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'C. de Custo'															, .T. }, ; //X3_TITULO
	{ 'C. de Costo'															, .T. }, ; //X3_TITSPA
	{ 'Cost Center'															, .T. }, ; //X3_TITENG
	{ 'Centro de Custo'														, .T. }, ; //X3_DESCRIC
	{ 'Centro de Costo'														, .T. }, ; //X3_DESCSPA
	{ 'Cost Center'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Vazio() .Or. ExistCpo("CTT")'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '004'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N1'																	, .T. }, ; //X3_ORDEM
	{ 'C6_DATCPL'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Integ'															, .T. }, ; //X3_TITULO
	{ 'Fch. Integ'															, .T. }, ; //X3_TITSPA
	{ 'Integr Dt'															, .T. }, ; //X3_TITENG
	{ 'Data da integracao'													, .T. }, ; //X3_DESCRIC
	{ 'Fecha de la integración'												, .T. }, ; //X3_DESCSPA
	{ 'Integration Date'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_HORCPL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Hr. Int'																, .T. }, ; //X3_TITULO
	{ 'Hr. Int'																, .T. }, ; //X3_TITSPA
	{ 'Int Time'															, .T. }, ; //X3_TITENG
	{ 'Hora Integracao'														, .T. }, ; //X3_DESCRIC
	{ 'Hora integración'													, .T. }, ; //X3_DESCSPA
	{ 'Integration Time'													, .T. }, ; //X3_DESCENG
	{ '99:99:99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N3'																	, .T. }, ; //X3_ORDEM
	{ 'C6_INTROT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Int. Rot.'															, .T. }, ; //X3_TITULO
	{ 'Int. Planif.'														, .T. }, ; //X3_TITSPA
	{ 'Script Integ'														, .T. }, ; //X3_TITENG
	{ 'Integracao Roteirizador'												, .T. }, ; //X3_DESCRIC
	{ 'Integración planificador'											, .T. }, ; //X3_DESCSPA
	{ 'Script Integration'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("1234")'													, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Não Integrado;2=Integrado;3=Falha de Integração;4=Integrado Parcial'	, .T. }, ; //X3_CBOX
	{ '1=No Integrado;2=Integrado;3=Falla de integración;4=Integrado parcialmente', .T. }, ; //X3_CBOXSPA
	{ '1=Not Integrated;2=Integrated;3=Integration Failure;4=Partially Integrated', .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N4'																	, .T. }, ; //X3_ORDEM
	{ 'C6_GCPIT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'GCP Item'															, .T. }, ; //X3_TITULO
	{ 'GCP Ítem'															, .T. }, ; //X3_TITSPA
	{ 'GCP Item'															, .T. }, ; //X3_TITENG
	{ 'GCP Item'															, .T. }, ; //X3_DESCRIC
	{ 'GCP Ítem'															, .T. }, ; //X3_DESCSPA
	{ 'GCP Item'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N5'																	, .T. }, ; //X3_ORDEM
	{ 'C6_GCPLT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'GCP Lote'															, .T. }, ; //X3_TITULO
	{ 'GCP Lote'															, .T. }, ; //X3_TITSPA
	{ 'GCP Lot'																, .T. }, ; //X3_TITENG
	{ 'GCP Lote'															, .T. }, ; //X3_DESCRIC
	{ 'GCP Lote'															, .T. }, ; //X3_DESCSPA
	{ 'GCP Lot'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N6'																	, .T. }, ; //X3_ORDEM
	{ 'C6_IPITRF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'IPI Transf'															, .T. }, ; //X3_TITULO
	{ 'IPI Transf'															, .T. }, ; //X3_TITSPA
	{ 'IPI Transf'															, .T. }, ; //X3_TITENG
	{ 'Base do IPI para transfer'											, .T. }, ; //X3_DESCRIC
	{ 'Base IPI para Transfer'												, .T. }, ; //X3_DESCSPA
	{ 'IPI Base for transfer'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'N7'																	, .T. }, ; //X3_ORDEM
	{ 'C6_TPPROD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tp. Prod.'															, .T. }, ; //X3_TITULO
	{ 'Tp. Prod.'															, .T. }, ; //X3_TITSPA
	{ 'Prod Tp'																, .T. }, ; //X3_TITENG
	{ 'Tipo do Produto'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de producto'													, .T. }, ; //X3_DESCSPA
	{ 'Product Type'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Venda; 2=Desenvolvimento'											, .T. }, ; //X3_CBOX
	{ '1=Venta; 2=Desarrollo'												, .T. }, ; //X3_CBOXSPA
	{ '1=Sales;2=Development'												, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC6'																	, .T. }, ; //X3_ARQUIVO
	{ 'O2'																	, .T. }, ; //X3_ORDEM
	{ 'C6_CSTPIS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'CST PIS'																, .T. }, ; //X3_TITULO
	{ 'CST PIS'																, .T. }, ; //X3_TITSPA
	{ 'PIS CST'																, .T. }, ; //X3_TITENG
	{ 'CST PIS'																, .T. }, ; //X3_DESCRIC
	{ 'CST PIS'																, .T. }, ; //X3_DESCSPA
	{ 'CST PIS'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME


//
// Atualizando dicionário
//
	nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
	nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
	nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
	nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
	nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
	nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

	aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )

	oProcess:SetRegua2( Len( aSX3 ) )

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )
	cAliasAtu := ""

	For nI := 1 To Len( aSX3 )

		//
		// Verifica se o campo faz parte de um grupo e ajusta tamanho
		//
		If !Empty( aSX3[nI][nPosSXG][1] )
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
				If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
					aSX3[nI][nPosTam][1] := SXG->XG_SIZE
					AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
						AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
						" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
				EndIf
			EndIf
		EndIf

		SX3->( dbSetOrder( 2 ) )

		If !( aSX3[nI][nPosArq][1] $ cAlias )
			cAlias += aSX3[nI][nPosArq][1] + "/"
			aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
		EndIf

		If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )

			//
			// Busca ultima ocorrencia do alias
			//
			If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
				cSeqAtu   := "00"
				cAliasAtu := aSX3[nI][nPosArq][1]

				dbSetOrder( 1 )
				SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
				dbSkip( -1 )

				If ( SX3->X3_ARQUIVO == cAliasAtu )
					cSeqAtu := SX3->X3_ORDEM
				EndIf

				nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
			EndIf

			nSeqAtu++
			cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

			RecLock( "SX3", .T. )
			For nJ := 1 To Len( aSX3[nI] )
				If     nJ == nPosOrd  // Ordem
					SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

				ElseIf aEstrut[nJ][2] > 0
					SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )

				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

			AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )

		Else

			//
			// Verifica se o campo faz parte de um grupo e ajsuta tamanho
			//
			If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
				SXG->( dbSetOrder( 1 ) )
				If SXG->( MSSeek( SX3->X3_GRPSXG ) )
					If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
						aSX3[nI][nPosTam][1] := SXG->XG_SIZE
						AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
							AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
							"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
					EndIf
				EndIf
			EndIf

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSX3[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aSX3[nI][nJ][2]
					cX3Campo := AllTrim( aEstrut[nJ][1] )
					cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

					If  aEstrut[nJ][2] > 0 .AND. ;
							PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
							PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
							!cX3Campo == "X3_ORDEM"

						cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " está com o " + cX3Campo + ;
							" com o conteúdo" + CRLF + ;
							"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
							"que será substituído pelo NOVO conteúdo" + CRLF + ;
							"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
							"Deseja substituir ? "

						If      lTodosSim
							nOpcA := 1
						ElseIf  lTodosNao
							nOpcA := 2
						Else
							nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
							lTodosSim := ( nOpcA == 3 )
							lTodosNao := ( nOpcA == 4 )

							If lTodosSim
								nOpcA := 1
								lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
							EndIf

							If lTodosNao
								nOpcA := 2
								lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
							EndIf

						EndIf

						If nOpcA == 1
							AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
								"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
								"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

							RecLock( "SX3", .F. )
							FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
							MsUnLock()
						EndIf

					EndIf

				EndIf

			Next

		EndIf

		oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

	Next nI

	AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
	Local aEstrut   := {}
	Local aSIX      := {}
	Local lAlt      := .F.
	Local lDelInd   := .F.
	Local nI        := 0
	Local nJ        := 0

	AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

	aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
		"DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SC6
//
	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO'									, ; //CHAVE
	'Num. Pedido + Item + Produto'											, ; //DESCRICAO
	'Nro Pedido + Item + Producto'											, ; //DESCSPA
	'Order Number + Item + Product'											, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+SB1'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM'									, ; //CHAVE
	'Produto + Num. Pedido + Item'											, ; //DESCRICAO
	'Producto + Nro Pedido + Item'											, ; //DESCSPA
	'Product + Order Number + Item'											, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'C6_FILIAL+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM'								, ; //CHAVE
	'Entrega + Num. Pedido + Item'											, ; //DESCRICAO
	'Entrega + Nro Pedido + Item'											, ; //DESCSPA
	'Delivery + Order Number + Item'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'C6_FILIAL+C6_NOTA+C6_SERIE'											, ; //CHAVE
	'Nota Fiscal + Serie NF'												, ; //DESCRICAO
	'Factura + Serie Fact.'													, ; //DESCSPA
	'Invoice + Series'														, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI'	, ; //CHAVE
	'Cliente + Loja + Produto + N.F.Original + Serie Orig. + Item NF.Orig'		, ; //DESCRICAO
	'Cliente + Tienda + Producto + Factura Orig + Serie Orig. + Item Fact.O'	, ; //DESCSPA
	'Customer + Unit + Product + Original Inv + Orig.Series + Src.Inv.Item'		, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA1+XXX+SB1'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C6_FILIAL+C6_CONTRT+C6_TPCONTR+C6_ITCONTR'								, ; //CHAVE
	'Contrato + Tipo Contrat + It. Contrato'								, ; //DESCRICAO
	'Contrato + Tipo Contrat + It. Contrato'								, ; //DESCSPA
	'Contract + Contract Tp + Contract It.'									, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'C6_FILIAL+C6_NUMOP+C6_ITEMOP'											, ; //CHAVE
	'Numero OP + Item da OP'												, ; //DESCRICAO
	'Num.Ord.Prod + Item de OP'												, ; //DESCSPA
	'PO Number + Pr.Ord.Item'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'C6_FILIAL+C6_PROJPMS+C6_TASKPMS+C6_EDTPMS'								, ; //CHAVE
	'Cod.Projeto + Cod.Tarefa + Cod. EDT'									, ; //DESCRICAO
	'Cod.Proyecto + Cod.Tarea + Cod. EDT'									, ; //DESCSPA
	'Project Code + Task Code + WBS Code'									, ; //DESCENG
	'S'																		, ; //PROPRI
	'AF8+AF9+AFC'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'C6_FILIAL+C6_NUMSC+C6_ITEMSC'											, ; //CHAVE
	'Numero SC + Item SC'													, ; //DESCRICAO
	'Numero SC + Item SC'													, ; //DESCSPA
	'PR number + PR Item'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'C6_FILIAL+C6_FILPED+C6_PEDCOM+C6_ITPC'									, ; //CHAVE
	'Fil.Ped.Comp + Ped.Compra + Item PC'									, ; //DESCRICAO
	'Suc.Ped.Comp + Ped.Compra + Item PC'									, ; //DESCSPA
	'Purch.Ord.Br + Purch.Order + PO Item'									, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'C6_FILIAL+C6_CLI+C6_LOJA+C6_PEDCLI'									, ; //CHAVE
	'Cliente + Loja + Ped Cliente'											, ; //DESCRICAO
	'Cliente + Tienda + Ped Cliente'										, ; //DESCSPA
	'Customer + Unit + Custom.Order'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM'									, ; //CHAVE
	'Num. Pedido + Produto + Num. Solicit'									, ; //DESCRICAO
	'Nro Pedido + Producto + Num. Solicit'									, ; //DESCSPA
	'Order Number + Product + Req. Nr.'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'C6_FILIAL+C6_NOTA+C6_SDOC'												, ; //CHAVE
	'Nota Fiscal + Série Doc.'												, ; //DESCRICAO
	'Factura + Serie Doc.'													, ; //DESCSPA
	'Invoice + Inv. Series'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SDOCORI+C6_ITEMORI'	, ; //CHAVE
	'Cliente + Loja + Produto + N.F.Original + Série Orig. + Item NF.Orig'		, ; //DESCRICAO
	'Cliente + Tienda + Producto + Factura Orig + Serie Orig. + Item Fact.O'	, ; //DESCSPA
	'Customer + Unit + Product + Original Inv + Orig. Series + Src.Inv.Item'	, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA1+XXX+SB1'															, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'C6_FILIAL+C6_PRODUTO+C6_PEDCOM+C6_ITPC'								, ; //CHAVE
	'Produto + Ped.Compra + Item PC'										, ; //DESCRICAO
	'Producto + Ped.Compra + Item PC'										, ; //DESCSPA
	'Product + Purch.Order + PO Item'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'C6_FILIAL+DTOS(C6_YEMISSA)+C6_PRODUTO'									, ; //CHAVE
	'EMISSAO+PRODUTO'														, ; //DESCRICAO
	'EMISSAO+PRODUTO'														, ; //DESCSPA
	'EMISSAO+PRODUTO'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'EMISPROD'																, ; //NICKNAME
	''																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'H'																		, ; //ORDEM
	'C6_FILIAL+C6_YRESULT'													, ; //CHAVE
	'Result. Emp.'															, ; //DESCRICAO
	'Result. Emp.'															, ; //DESCSPA
	'Result. Emp.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC6'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'C6_FILIAL+C6_MSEXP'													, ; //CHAVE
	'Ident.Exp.'															, ; //DESCRICAO
	'Ident.Exp.'															, ; //DESCSPA
	'Ident.Exp.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
	oProcess:SetRegua2( Len( aSIX ) )

	dbSelectArea( "SIX" )
	SIX->( dbSetOrder( 1 ) )

	For nI := 1 To Len( aSIX )

		lAlt    := .F.
		lDelInd := .F.

		If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
			AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
		Else
			lAlt := .T.
			aAdd( aArqUpd, aSIX[nI][1] )
			If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
					StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
				AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
				lDelInd := .T. // Se for alteração precisa apagar o indice do banco
			EndIf
		EndIf

		RecLock( "SIX", !lAlt )
		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ
		MsUnLock()

		dbCommit()

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
		EndIf

		oProcess:IncRegua2( "Atualizando índices..." )

	Next nI

	AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
	Local aEstrut   := {}
	Local aAreaSX3  := SX3->( GetArea() )
	Local aSX7      := {}
	Local cAlias    := ""
	Local nI        := 0
	Local nJ        := 0
	Local nTamSeek  := Len( SX7->X7_CAMPO )

	AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

	aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
		"X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo C6_DESCONT
//
	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA015",.F.,.F.)*M->C6_QTDVEN'								, ; //X7_REGRA
	'C6_VALOR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA017",.F.,.F.)'											, ; //X7_REGRA
	'C6_DESCONT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'IF(M->C6_DESCONT==0,M->C6_PRUNIT,M->C6_PRCVEN)'						, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'M->C6_QTDVEN*M->C6_PRCVEN'												, ; //X7_REGRA
	'C6_VALOR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'M->C6_DESCONT'															, ; //X7_REGRA
	'C6_YDESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'0'																		, ; //X7_REGRA
	'C6_DESCONT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'0'																		, ; //X7_REGRA
	'C6_VALDESC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'M->C6_PRCVEN'															, ; //X7_REGRA
	'C6_PRUNIT'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA013",.F.,.F.)'											, ; //X7_REGRA
	'C6_DESCONT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	'IIF(EXECBLOCK("BIA013",.F.,.F.)==0,0,M->C6_VALDESC)'					, ; //X7_REGRA
	'C6_VALDESC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_DESCONT'															, ; //X7_CAMPO
	'011'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA015",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

//
// Campo C6_OPER
//
	aAdd( aSX7, { ;
		'C6_OPER'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$' + SIMPLES + 'DB' + SIMPLES + ',' + DUPLAS  + 'F' + DUPLAS  + ',' + DUPLAS  + 'C' + DUPLAS  + '),M->C6_PRODUTO,' + DUPLAS  + 'C6_TES' + DUPLAS  + ')', ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_OPER'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'CodSitTri()'															, ; //X7_REGRA
	'C6_CLASFIS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'!(Trim(FunName())$"FCOMRT01#RPC")'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_OPER'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SF4->F4_CODLAN'														, ; //X7_REGRA
	'C6_CODLAN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_PRCVEN
//
	aAdd( aSX7, { ;
		'C6_PRCVEN'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA012",.F.,.F.)'											, ; //X7_REGRA
	'C6_VALOR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'1=2'																	} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRCVEN'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_PRODUTO
//
	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'CodSitTri()'															, ; //X7_REGRA
	'C6_CLASFIS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SF4'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'IIf(!Empty(SB1->B1_TS),xFilial("SF4")+SB1->B1_TS,xFilial("SF4")+M->C6_TES)', ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SF4->F4_CODLAN'														, ; //X7_REGRA
	'C6_CODLAN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SB5->B5_VERSAO'														, ; //X7_REGRA
	'C6_REVPROD'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB5")+M->C6_PRODUTO'											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'SB5->B5_SERVSAI'														, ; //X7_REGRA
	'C6_SERVIC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB5")+M->C6_PRODUTO'											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'INTDL(M->C6_PRODUTO)'													} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'SB5->B5_ENDSAI'														, ; //X7_REGRA
	'C6_ENDPAD'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB5")+M->C6_PRODUTO'											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'INTDL(M->C6_PRODUTO)'													} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'SBE->BE_ESTFIS'														, ; //X7_REGRA
	'C6_TPESTR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SBE'																	, ; //X7_ALIAS
	9																		, ; //X7_ORDEM
	'xFilial("SBE")+M->C6_ENDPAD'											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'INTDL(M->C6_PRODUTO)'													} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	"Posicione('SB1',1,xfilial('SB1')+M->C6_PRODUTO, 'B1_CC')"				, ; //X7_REGRA
	'C6_CC'																	, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'A410ENTCTB()'															} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	"Posicione('SB1',1,xfilial('SB1')+M->C6_PRODUTO, 'B1_CONTA')"			, ; //X7_REGRA
	'C6_CONTA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'A410ENTCTB()'															} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	"Posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO, 'B1_ITEMCC')"			, ; //X7_REGRA
	'C6_ITEMCTA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'A410ENTCTB()'															} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	"Posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO, 'B1_CLVL')"			, ; //X7_REGRA
	'C6_CLVL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	'A410ENTCTB()'															} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'011'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA006",.F.,.F.)'											, ; //X7_REGRA
	'C6_DESCRI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'012'																	, ; //X7_SEQUENC
	'M->C5_EMISSAO'															, ; //X7_REGRA
	'C6_YEMISSA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'013'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA611",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRODUTO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'014'																	, ; //X7_SEQUENC
	'IF(SB1->B1_TIPO=="PA",SB1->B1_PESO,1)'									, ; //X7_REGRA
	'C6_YPESOL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->C6_PRODUTO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'015'																	, ; //X7_SEQUENC
	'EXECBLOCK("PRE_TES",.F.,.F.)'											, ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'1=2'																	} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'016'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA338",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRODUTO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'017'																	, ; //X7_SEQUENC
	'IF(SB1->B1_MSBLQL = "1","",M->C6_PRODUTO)'								, ; //X7_REGRA
	'C6_PRODUTO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->C6_PRODUTO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'018'																	, ; //X7_SEQUENC
	'M->C5_YSUBTP'															, ; //X7_REGRA
	'C6_OPER'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PRODUTO'															, ; //X7_CAMPO
	'019'																	, ; //X7_SEQUENC
	'MaTesInt(2,M->C6_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$' + SIMPLES + 'DB' + SIMPLES + ',' + DUPLAS  + 'F' + DUPLAS  + ',' + DUPLAS  + 'C' + DUPLAS  + '),M->C6_PRODUTO,' + DUPLAS  + 'C6_TES' + DUPLAS  + ')', ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_PROJPMS
//
	aAdd( aSX7, { ;
		'C6_PROJPMS'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SPACE(LEN(SC6->C6_TASKPMS))'											, ; //X7_REGRA
	'C6_TASKPMS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_PROJPMS'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SPACE(LEN(AFC->AFC_EDT))'												, ; //X7_REGRA
	'C6_EDTPMS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_QTDLIB
//
	aAdd( aSX7, { ;
		'C6_QTDLIB'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA142",.F.,.F.)'											, ; //X7_REGRA
	'C6_QTDLIB'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDLIB'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA342",.F.,.F.)'											, ; //X7_REGRA
	'C6_QTDLIB'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'UPPER(ALLTRIM(FUNNAME()))=="MATA440"'									} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDLIB'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'U_FROPGA03()'															, ; //X7_REGRA
	'C6_QTDLIB'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_QTDVEN
//
	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA611",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRODUTO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA068",.F.,.F.)'											, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA853",.F.,.F.)'											, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'U_FROPGA02()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_TES
//
	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'CodSitTri()'															, ; //X7_REGRA
	'C6_CLASFIS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SF4'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial()+M->C6_TES'													, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SF4->F4_CODLAN'														, ; //X7_REGRA
	'C6_CODLAN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'ExecBlock("BIA898",.F.,.F.)'											, ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA133",.F.,.F.)'											, ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA045",.F.,.F.)'											, ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'1=2'																	} ) //X7_CONDIC

//
// Campo C6_YDACO
//
	aAdd( aSX7, { ;
		'C6_YDACO'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDACO'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDAI
//
	aAdd( aSX7, { ;
		'C6_YDAI'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDAI'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDESC
//
	aAdd( aSX7, { ;
		'C6_YDESC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDESP
//
	aAdd( aSX7, { ;
		'C6_YDESP'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDESP'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDESP'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'U_BIA868()'															, ; //X7_REGRA
	'C6_YDESP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_YDFRA
//
	aAdd( aSX7, { ;
		'C6_YDFRA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDFRA'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDNV
//
	aAdd( aSX7, { ;
		'C6_YDNV'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDNV'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDTNECE
//
	aAdd( aSX7, { ;
		'C6_YDTNECE'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_FROPGA02()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'AllTrim(FunName()) == "MATA410"'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDTNECE'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'AllTrim(FunName()) == "MATA410"'										} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDTNECE'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YDVER
//
	aAdd( aSX7, { ;
		'C6_YDVER'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YDVER'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YNRESER
//
	aAdd( aSX7, { ;
		'C6_YNRESER'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_FROPGA04()'															, ; //X7_REGRA
	'C6_YNRESER'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_YPERC
//
	aAdd( aSX7, { ;
		'C6_YPERC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->C5_TIPO == "N"'														} ) //X7_CONDIC

//
// Campo C6_YPREAJU
//
	aAdd( aSX7, { ;
		'C6_YPREAJU'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C6_YQTDPC
//
	aAdd( aSX7, { ;
		'C6_YQTDPC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA432",.F.,.F.)'											, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YQTDPC'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'U_FROPGA02()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YQTDPC'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'U_BPOLGA01()'															, ; //X7_REGRA
	'C6_QTDVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C6_YQTDPC'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA436",.F.,.F.)'											, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
	oProcess:SetRegua2( Len( aSX7 ) )

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )

	dbSelectArea( "SX7" )
	dbSetOrder( 1 )

	For nI := 1 To Len( aSX7 )

		If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

			If !( aSX7[nI][1] $ cAlias )
				cAlias += aSX7[nI][1] + "/"
				AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
			EndIf

			RecLock( "SX7", .T. )
		Else

			If !( aSX7[nI][1] $ cAlias )
				cAlias += aSX7[nI][1] + "/"
				AutoGrLog( "Foi alterado o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
			EndIf

			RecLock( "SX7", .F. )
		EndIf

		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

		oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

	Next nI

	RestArea( aAreaSX3 )

	AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
	Local aEstrut   := {}
	Local aSXB      := {}
	Local cAlias    := ""
	Local cMsg      := ""
	Local lTodosNao := .F.
	Local lTodosSim := .F.
	Local nI        := 0
	Local nJ        := 0
	Local nOpcA     := 0

	AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

	aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
		"XB_WCONTEM", "XB_CONTEM" }


//
// Consulta AF8
//
	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Projetos'																, ; //XB_DESCRI
	'Proyectos'																, ; //XB_DESCSPA
	'Projects'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF8'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Projeto'																, ; //XB_DESCRI
	'Proyecto'																, ; //XB_DESCSPA
	'Project'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Projeto'																, ; //XB_DESCRI
	'Proyecto'																, ; //XB_DESCSPA
	'Project'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF8_PROJET'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF8_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Fecha'																	, ; //XB_DESCSPA
	'Date'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF8_DATA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	''																		, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF8->AF8_PROJET'														} ) //XB_CONTEM

//
// Consulta AF9
//
	aAdd( aSXB, { ;
		'AF9'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Tarefas'																, ; //XB_DESCRI
	'Tareas'																, ; //XB_DESCSPA
	'Tasks'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PmsTskPad()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AF9'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AF9->AF9_TAREFA'														} ) //XB_CONTEM

//
// Consulta AFC
//
	aAdd( aSXB, { ;
		'AFC'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'EDTs'																	, ; //XB_DESCRI
	'EDT'																	, ; //XB_DESCSPA
	'WBSs'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AFC'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AFC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PMSEDTPad()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AFC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AFC->AFC_EDT'															} ) //XB_CONTEM

//
// Consulta AH9
//
	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Licitacao'																, ; //XB_DESCRI
	'Licitacion'															, ; //XB_DESCSPA
	'Bidding'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Licitacao'																, ; //XB_DESCRI
	'Licitacion'															, ; //XB_DESCSPA
	'Bidding'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Licitacao'																, ; //XB_DESCRI
	'Licitacion'															, ; //XB_DESCSPA
	'Bidding'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9_CODLIC'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9_DESCLI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Data inicio'															, ; //XB_DESCRI
	'Fecha inicio'															, ; //XB_DESCSPA
	'Initial Date'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9_DTINIC'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Data fim'																, ; //XB_DESCRI
	'Fecha fin'																, ; //XB_DESCSPA
	'Final Date'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9_DTFIM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'AH9'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	''																		, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AH9->AH9_CODLIC'														} ) //XB_CONTEM

//
// Consulta CCZ
//
	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Natureza da Receita'													, ; //XB_DESCRI
	'Modalidad del ingres'													, ; //XB_DESCSPA
	'Revenue Class'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela + Codigo + Gr'													, ; //XB_DESCRI
	'Tabla + Código + Gr'													, ; //XB_DESCSPA
	'Table + Code + Gr'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_TABELA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_GRUPO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Aliq. PIS'																, ; //XB_DESCRI
	'Alíc. PIS'																, ; //XB_DESCSPA
	'PIS Rate'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_ALQPIS'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Aliq. COF'																, ; //XB_DESCRI
	'Alíc. COF'																, ; //XB_DESCSPA
	'COF Rate'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_ALQCOF'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Dt. Fim'																, ; //XB_DESCRI
	'Fch. Final'															, ; //XB_DESCSPA
	'End Dt'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ_DTFIM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ->CCZ_TABELA'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ->CCZ_COD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ->CCZ_GRUPO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CCZ->CCZ_DTFIM'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CCZ'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#XFUNFiltNR()'														} ) //XB_CONTEM

//
// Consulta CDZ
//
	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cod.Lcto Cat83'														, ; //XB_DESCRI
	'Cód.Asto Cat83'														, ; //XB_DESCSPA
	'Entry Code Cat83'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CDZ'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod.Lcto Cat83'														, ; //XB_DESCRI
	'Cód.Asto Cat83'														, ; //XB_DESCSPA
	'Entry Code Cat83'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CDZ_CODLAN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CDZ_DESCR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CDZ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CDZ->CDZ_CODLAN'														} ) //XB_CONTEM

//
// Consulta CT1
//
	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Contas Contabeis'														, ; //XB_DESCRI
	'Cuentas contables'														, ; //XB_DESCSPA
	'Ledger Account'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Cuenta'																, ; //XB_DESCSPA
	'Account'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Reduzida'																, ; //XB_DESCRI
	'Reducida'																, ; //XB_DESCSPA
	'Reduced'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_CONTA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_CONTA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Cod Reduz'																, ; //XB_DESCRI
	'Codif. Reducida'														, ; //XB_DESCSPA
	'Red Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_RES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CT1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CT1->CT1_CONTA'														} ) //XB_CONTEM

//
// Consulta CTD
//
	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Item Contabil'															, ; //XB_DESCRI
	'Item Contable'															, ; //XB_DESCSPA
	'Accounting Item'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_RES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'If(FunName()$' + DUPLAS  + 'CTBA080,CONA010' + DUPLAS  + ',' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + '+CTD->CTD_ITEM+' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + ',CTD->CTD_ITEM)'} ) //XB_CONTEM

//
// Consulta CTH
//
	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Classe Valor'															, ; //XB_DESCRI
	'Clase Valor'															, ; //XB_DESCSPA
	'Value Class'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_CLVL'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_CLVL'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_RES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTH_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'If(FunName()$' + DUPLAS  + 'CTBA080,CONA010' + DUPLAS  + ',' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + '+CTH->CTH_CLVL+' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + ',CTH->CTH_CLVL)'} ) //XB_CONTEM

//
// Consulta CTT
//
	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost Center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#CtbA030Inc'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_CUSTO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_CUSTO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_RES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTT'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT->CTT_CUSTO'														} ) //XB_CONTEM

//
// Consulta DC5
//
	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Servico X Tarefa'														, ; //XB_DESCRI
	'Servicio vs Tarea'														, ; //XB_DESCSPA
	'Serv x Task'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Servico'														, ; //XB_DESCRI
	'Código servicio'														, ; //XB_DESCSPA
	'Service code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo Tarefa'															, ; //XB_DESCRI
	'Codigo tarea'															, ; //XB_DESCSPA
	'Task code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#WMSA070XBI#WMSA070XBV'												} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Servico'														, ; //XB_DESCRI
	'Código servicio'														, ; //XB_DESCSPA
	'Service code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5_SERVIC'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao Servico'														, ; //XB_DESCRI
	'Descripción servicio'													, ; //XB_DESCSPA
	'Service description'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"Tabela('L4', DC5->DC5_SERVIC, .F.)"									} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo Tarefa'															, ; //XB_DESCRI
	'Código tarea'															, ; //XB_DESCSPA
	'Task code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5_TAREFA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao Tarefa'														, ; //XB_DESCRI
	'Descripción tarea'														, ; //XB_DESCSPA
	'Task description'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"Tabela('L2', DC5->DC5_TAREFA, .F.)"									} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo Tarefa'															, ; //XB_DESCRI
	'Código tarea'															, ; //XB_DESCSPA
	'Task code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5_TAREFA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Descricao Tarefa'														, ; //XB_DESCRI
	'Descripción tarea'														, ; //XB_DESCSPA
	'Task description'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"Tabela('L2', DC5->DC5_TAREFA, .F.)"									} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Codigo Servico'														, ; //XB_DESCRI
	'Código servicio'														, ; //XB_DESCSPA
	'Service code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5_SERVIC'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Descricao Servico'														, ; //XB_DESCRI
	'Descripción servicio'													, ; //XB_DESCSPA
	'Service description'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"Tabela('L4', DC5->DC5_SERVIC, .F.)"									} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5->DC5_SERVIC'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC5'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC5->DC5_ORDEM == WmsConsDC5()'										} ) //XB_CONTEM

//
// Consulta DC8
//
	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Estrutura Fisica/Pad'													, ; //XB_DESCRI
	'Estruct Fisic/Estand'													, ; //XB_DESCSPA
	'Phys./Stan. Struct.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estrutura'																, ; //XB_DESCRI
	'Estructura'															, ; //XB_DESCSPA
	'Structure'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estrutura'																, ; //XB_DESCRI
	'Estructura'															, ; //XB_DESCSPA
	'Structure'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_CODEST'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_DESEST'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Largura'																, ; //XB_DESCRI
	'Ancho'																	, ; //XB_DESCSPA
	'Width'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_LARGUR'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Altura'																, ; //XB_DESCRI
	'Altura'																, ; //XB_DESCSPA
	'Height'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_ALTURA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Comprimento'															, ; //XB_DESCRI
	'Largo'																	, ; //XB_DESCSPA
	'Length'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_COMPRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Capacidade'															, ; //XB_DESCRI
	'Capacidad'																, ; //XB_DESCSPA
	'Capacity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_CAPACI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Armazem'																, ; //XB_DESCRI
	'Almacen'																, ; //XB_DESCSPA
	'Warehouse'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_LOCPAD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Unitizada'																, ; //XB_DESCRI
	'Unitizada'																, ; //XB_DESCSPA
	'Unitized'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_STATUS'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_DESEST'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Estrutura'																, ; //XB_DESCRI
	'Estructura'															, ; //XB_DESCSPA
	'Structure'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_CODEST'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Largura'																, ; //XB_DESCRI
	'Ancho'																	, ; //XB_DESCSPA
	'Width'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_LARGUR'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Altura'																, ; //XB_DESCRI
	'Alto'																	, ; //XB_DESCSPA
	'Height'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_ALTURA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Comprimento'															, ; //XB_DESCRI
	'Largo'																	, ; //XB_DESCSPA
	'Length'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_COMPRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Capacidade'															, ; //XB_DESCRI
	'Capacidad'																, ; //XB_DESCSPA
	'Capacity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_CAPACI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Armazem'																, ; //XB_DESCRI
	'Deposito'																, ; //XB_DESCSPA
	'Warehouse'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_LOCPAD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Unitizada'																, ; //XB_DESCRI
	'Unitizada'																, ; //XB_DESCSPA
	'Unitized'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8_STATUS'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DC8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DC8->DC8_CODEST'														} ) //XB_CONTEM

//
// Consulta NNR
//
	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Locais de Estoque'														, ; //XB_DESCRI
	'Lugares stock'															, ; //XB_DESCSPA
	'Stock Locations'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NNR'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NNR_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NNR_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NNR->NNR_CODIGO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NNR'																	, ; //XB_ALIAS
	'9'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'AC'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AGRA045'																} ) //XB_CONTEM

//
// Consulta NP3
//
	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Culturas'																, ; //XB_DESCRI
	'Cultivos'																, ; //XB_DESCSPA
	'Cultures'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP3->NP3_CODIGO'														} ) //XB_CONTEM

//
// Consulta NP4
//
	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cultivares'															, ; //XB_DESCRI
	'Cultivos'																, ; //XB_DESCSPA
	'Cultures'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP4_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP4_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP4->NP4_CODIGO'														} ) //XB_CONTEM

//
// Consulta NP7
//
	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Peneiras'																, ; //XB_DESCRI
	'Coladores'																, ; //XB_DESCSPA
	'Sieves'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP7'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP7_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP7_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NP7'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NP7->NP7_CODIGO'														} ) //XB_CONTEM

//
// Consulta PZ7
//
	aAdd( aSXB, { ;
		'PZ7'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'MOTIVO REJEICAO LOTE'													, ; //XB_DESCRI
	'MOTIVO REJEICAO LOTE'													, ; //XB_DESCSPA
	'MOTIVO REJEICAO LOTE'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PZ7'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'PZ7'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.motivo'															, ; //XB_DESCRI
	'Desc.motivo'															, ; //XB_DESCSPA
	'Desc.motivo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'PZ7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Motivo'															, ; //XB_DESCRI
	'Desc.Motivo'															, ; //XB_DESCSPA
	'Desc.Motivo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PZ7_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'PZ7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PZ7_CODIGO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'PZ7'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PZ7->PZ7_CODIGO'														} ) //XB_CONTEM

//
// Consulta SA1
//
	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A030INCLUI#A030VISUAL'												} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#CRMXFilSXB("SA1")'													} ) //XB_CONTEM

//
// Consulta SA3
//
	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Vendedor'																, ; //XB_DESCRI
	'Vendedor'																, ; //XB_DESCSPA
	'Sales Representative'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA3'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Nome Reduzido'															, ; //XB_DESCRI
	'Nome Reduzido'															, ; //XB_DESCSPA
	'Nome Reduzido'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome Reduzid'															, ; //XB_DESCRI
	'Nomb  Reduc.'															, ; //XB_DESCSPA
	'Short Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NREDUZ'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA3->A3_COD'															} ) //XB_CONTEM

//
// Consulta SAH
//
	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Unidades de Medida'													, ; //XB_DESCRI
	'Unidades de Medida'													, ; //XB_DESCSPA
	'Units of Measurement'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SAH'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descr. Resumida'														, ; //XB_DESCRI
	'Descr. Resumida'														, ; //XB_DESCSPA
	'Summarized Desc.'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SAH->AH_UMRES'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SAH->AH_UNIMED'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SAH->AH_DESCPO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SAH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SAH->AH_UNIMED'														} ) //XB_CONTEM

//
// Consulta SB1
//
	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1FA093SB1();Config;SBP->BP_BASE'										} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A010INCLUI#A010VISUL'												} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_GRUPO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SB1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SBE
//
	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Localização Fisica'													, ; //XB_DESCRI
	'Localización física'													, ; //XB_DESCSPA
	'Physical Location'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBE'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Local+Localização'														, ; //XB_DESCRI
	'Local+Localización'													, ; //XB_DESCSPA
	'Location+Location'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Local'																	, ; //XB_DESCRI
	'Lugar'																	, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BE_LOCAL'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Localiz'																, ; //XB_DESCRI
	'Lugariz'																, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BE_LOCALIZ'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBE->BE_LOCALIZ'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SBE'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'If(FWIsInCallStack("MATA265"), SBE->BE_LOCAL==SDA->DA_LOCAL, .T.)'		} ) //XB_CONTEM

//
// Consulta SC0
//
	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Reserva de Faturam.'													, ; //XB_DESCRI
	'Reserva Facturacion'													, ; //XB_DESCSPA
	'Invoicing Reserve'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC0'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_QUANT'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Solicitante'															, ; //XB_DESCRI
	'Solicitante'															, ; //XB_DESCSPA
	'Petitioner'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_SOLICIT'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Validade'																, ; //XB_DESCRI
	'Validez'																, ; //XB_DESCSPA
	'Validity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_VALIDA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_QUANT'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Validade'																, ; //XB_DESCRI
	'Validez'																, ; //XB_DESCSPA
	'Validity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_VALIDA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC0->C0_NUM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC0'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C0_QUANT>0'															} ) //XB_CONTEM

//
// Consulta SC5VIN
//
	aAdd( aSXB, { ;
		'SC5VIN'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Pedidos Vinculados'													, ; //XB_DESCRI
	'Pedidos Vinculados'													, ; //XB_DESCSPA
	'Associated Orders'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5VIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A410ConPad()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5VIN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'VAR_IXB'																} ) //XB_CONTEM

//
// Consulta SC6
//
	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Item do Ped. Venda'													, ; //XB_DESCRI
	'Item de Ped. Venta'													, ; //XB_DESCSPA
	'Sales Order Item'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero+Item+Cod.Prod'													, ; //XB_DESCRI
	'Numero+Item+Cod.Prod'													, ; //XB_DESCSPA
	'Number+Item+Prod.Cd.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod.Prod+Numero+Item'													, ; //XB_DESCRI
	'Cod.Prod+Numero+Item'													, ; //XB_DESCSPA
	'Prod.Cd.+Number+Item'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registro Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#MATA410(,,3)#MATA410(,,2)'											} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod.Produto'															, ; //XB_DESCRI
	'Cod.Producto'															, ; //XB_DESCSPA
	'Product Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_QTDVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Prc.Venda'																, ; //XB_DESCRI
	'Prc.Venta'																, ; //XB_DESCSPA
	'Sales Proc.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRCVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Total'																	, ; //XB_DESCRI
	'Total'																	, ; //XB_DESCSPA
	'Total'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_VALOR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Cod.Produto'															, ; //XB_DESCRI
	'Cod.Producto'															, ; //XB_DESCSPA
	'Product Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_QTDVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Prc.Venda'																, ; //XB_DESCRI
	'Prc.Venta'																, ; //XB_DESCSPA
	'Sales Proc.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRCVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Total'																	, ; //XB_DESCRI
	'Total'																	, ; //XB_DESCSPA
	'Total'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_VALOR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_NUM+SC6->C6_ITEM'												} ) //XB_CONTEM

//
// Consulta SC6Z61
//
	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Pedido Venda Obra'														, ; //XB_DESCRI
	'Pedido Venda Obra'														, ; //XB_DESCSPA
	'Pedido Venda Obra'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero+Item+Cod.Prod'													, ; //XB_DESCRI
	'Numero+Item+Cod.Prod'													, ; //XB_DESCSPA
	'Number+Item+Prod.Cd.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod.Prod+Numero+Item'													, ; //XB_DESCRI
	'Cod.Prod+Numero+Item'													, ; //XB_DESCSPA
	'Prod.Cd.+Number+Item'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod.Produto'															, ; //XB_DESCRI
	'Cod.Producto'															, ; //XB_DESCSPA
	'Product Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_QTDVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Prc.Venda'																, ; //XB_DESCRI
	'Prc.Venta'																, ; //XB_DESCSPA
	'Sales Proc.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRCVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Total'																	, ; //XB_DESCRI
	'Total'																	, ; //XB_DESCSPA
	'Total'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_VALOR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod.Produto'															, ; //XB_DESCRI
	'Cod.Producto'															, ; //XB_DESCSPA
	'Product Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Quantidade'															, ; //XB_DESCRI
	'Cantidad'																, ; //XB_DESCSPA
	'Quantity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_QTDVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Prc.Venda'																, ; //XB_DESCRI
	'Prc.Venta'																, ; //XB_DESCSPA
	'Sales Proc.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRCVEN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Total'																	, ; //XB_DESCRI
	'Total'																	, ; //XB_DESCSPA
	'Total'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_VALOR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_NUM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_ITEM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_PRODUTO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC6Z61'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U___SC6_Filter()'													} ) //XB_CONTEM

//
// Consulta SC7WMS
//
	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Itens Ped. Compra'														, ; //XB_DESCRI
	'Ítems Ped. Compra'														, ; //XB_DESCSPA
	'Purchase Order Items'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC7'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Produto + Numero PC'													, ; //XB_DESCRI
	'Producto + Nº PC'														, ; //XB_DESCSPA
	'Product + PC Number'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C7_FILIAL'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C7_PRODUTO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Numero PC'																, ; //XB_DESCRI
	'Número PC'																, ; //XB_DESCSPA
	'PC Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C7_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Ítem'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C7_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC7->C7_NUM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC7->C7_ITEM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC7->C7_FILIAL'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC7WMS'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC7->C7_PRODUTO == FiltSC7WMS()'										} ) //XB_CONTEM

//
// Consulta SF4
//
	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Tipo de Entr. Saída'													, ; //XB_DESCRI
	'Tipo de Entr. Salida'													, ; //XB_DESCSPA
	'Type of Inf./Outflow'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SF4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A081Inclui#A081Visual'												} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'COD'																	, ; //XB_DESCRI
	'COD'																	, ; //XB_DESCSPA
	'COD'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'TP'																	, ; //XB_DESCRI
	'TP'																	, ; //XB_DESCSPA
	'TP'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_TIPO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CF'																	, ; //XB_DESCRI
	'CF'																	, ; //XB_DESCSPA
	'CF'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_CF'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'DUP'																	, ; //XB_DESCRI
	'DUP'																	, ; //XB_DESCSPA
	'DUP'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_DUPLIC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'EST'																	, ; //XB_DESCRI
	'EST'																	, ; //XB_DESCSPA
	'EST'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_ESTOQUE'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'ICM'																	, ; //XB_DESCRI
	'ICM'																	, ; //XB_DESCSPA
	'ICM'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_ICM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CRICM'																	, ; //XB_DESCRI
	'CRICM'																	, ; //XB_DESCSPA
	'CRICM'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_CREDICM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'IPI'																	, ; //XB_DESCRI
	'IPI'																	, ; //XB_DESCSPA
	'IPI'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_IPI'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'CRIPI'																	, ; //XB_DESCRI
	'CRIPI'																	, ; //XB_DESCSPA
	'CRIPI'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_CREDIPI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'%Red.do ICMS'															, ; //XB_DESCRI
	'%Red. ICMS'															, ; //XB_DESCSPA
	'Red. ICMS %'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_BASEICM'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'LFICM'																	, ; //XB_DESCRI
	'LFICM'																	, ; //XB_DESCSPA
	'LFICM'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_LFICM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'LFIPI'																	, ; //XB_DESCRI
	'LFIPI'																	, ; //XB_DESCSPA
	'LFIPI'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_LFIPI'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'14'																	, ; //XB_COLUNA
	'TEXTO'																	, ; //XB_DESCRI
	'TEXTO'																	, ; //XB_DESCSPA
	'TEXT'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_TEXTO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'15'																	, ; //XB_COLUNA
	'FINALIDADE'															, ; //XB_DESCRI
	'FINALIDAD'																, ; //XB_DESCSPA
	'PURPOSE'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'F4_FINALID'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SF4->F4_CODIGO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SF4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SF4->F4_CODIGO'														} ) //XB_CONTEM

//
// Consulta ZZ9
//
	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Lotes'																	, ; //XB_DESCRI
	'Lotes'																	, ; //XB_DESCSPA
	'Lotes'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Lote+produto'															, ; //XB_DESCRI
	'Lote+produto'															, ; //XB_DESCSPA
	'Lote+produto'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto+lote'															, ; //XB_DESCRI
	'Produto+lote'															, ; //XB_DESCSPA
	'Produto+lote'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Lote'																	, ; //XB_DESCRI
	'Lote'																	, ; //XB_DESCSPA
	'Lote'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_LOTE'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Produto'																, ; //XB_DESCSPA
	'Produto'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PRODUT'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Peso Embalag'															, ; //XB_DESCRI
	'Peso Embalag'															, ; //XB_DESCSPA
	'Peso Embalag'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PESEMB'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Conv.Pallets'															, ; //XB_DESCRI
	'Conv.Pallets'															, ; //XB_DESCSPA
	'Conv.Pallets'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_DIVPA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Peso Liquido'															, ; //XB_DESCRI
	'Peso Liquido'															, ; //XB_DESCSPA
	'Peso Liquido'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PESO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Pecas p/ CX'															, ; //XB_DESCRI
	'Pecas p/ CX'															, ; //XB_DESCSPA
	'Pecas p/ CX'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PECA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Lote'																	, ; //XB_DESCRI
	'Lote'																	, ; //XB_DESCSPA
	'Lote'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_LOTE'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Produto'																, ; //XB_DESCSPA
	'Produto'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PRODUT'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Peso Embalag'															, ; //XB_DESCRI
	'Peso Embalag'															, ; //XB_DESCSPA
	'Peso Embalag'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PESEMB'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Conv.Pallets'															, ; //XB_DESCRI
	'Conv.Pallets'															, ; //XB_DESCSPA
	'Conv.Pallets'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_DIVPA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Peso Liquido'															, ; //XB_DESCRI
	'Peso Liquido'															, ; //XB_DESCSPA
	'Peso Liquido'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PESO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Pecas p/ CX'															, ; //XB_DESCRI
	'Pecas p/ CX'															, ; //XB_DESCSPA
	'Pecas p/ CX'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9_PECA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZ9'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZ9->ZZ9_LOTE'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
	oProcess:SetRegua2( Len( aSXB ) )

	dbSelectArea( "SXB" )
	dbSetOrder( 1 )

	For nI := 1 To Len( aSXB )

		If !Empty( aSXB[nI][1] )

			If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

				If !( aSXB[nI][1] $ cAlias )
					cAlias += aSXB[nI][1] + "/"
					AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
				EndIf

				RecLock( "SXB", .T. )

				For nJ := 1 To Len( aSXB[nI] )
					If FieldPos( aEstrut[nJ] ) > 0
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
					EndIf
				Next nJ

				dbCommit()
				MsUnLock()

			Else

				//
				// Verifica todos os campos
				//
				For nJ := 1 To Len( aSXB[nI] )

					//
					// Se o campo estiver diferente da estrutura
					//
					If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
							!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
							StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

						cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
							" com o conteúdo" + CRLF + ;
							"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
							", e este é diferente do conteúdo" + CRLF + ;
							"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
							"Deseja substituir ? "

						If      lTodosSim
							nOpcA := 1
						ElseIf  lTodosNao
							nOpcA := 2
						Else
							nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
							lTodosSim := ( nOpcA == 3 )
							lTodosNao := ( nOpcA == 4 )

							If lTodosSim
								nOpcA := 1
								lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
							EndIf

							If lTodosNao
								nOpcA := 2
								lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
							EndIf

						EndIf

						If nOpcA == 1
							RecLock( "SXB", .F. )
							FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
							dbCommit()
							MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

						EndIf

					EndIf

				Next

			EndIf

		EndIf

		oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

	Next nI

	AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
	Local aHlpPor   := {}
	Local aHlpEng   := {}
	Local aHlpSpa   := {}

	AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


	oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SC6
//
	aHlpPor := {}
	aAdd( aHlpPor, 'Código que identifica a filial da' )
	aAdd( aHlpPor, 'empre-sa usuária do sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FILIAL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do ítem no pedido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador do produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PRODUTO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PRODUTO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Selecione outro código do produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC6_PRODUTO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C6_PRODUTO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Descrição  do  produto  a ser emitido na' )
	aAdd( aHlpPor, 'nota.É apresentado como default o  nome' )
	aAdd( aHlpPor, 'que está no cadastro de produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DESCRI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DESCRI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Unidade de medida principal do ítem' )
	aAdd( aHlpPor, 'dopedido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_UM     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_UM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade original do pedido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDVEN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDVEN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Segunda unidade de medida do pedido' )
	aAdd( aHlpPor, 'devendas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SEGUM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SEGUM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade liberada porém não faturada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDEMP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDEMP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade já entregue/faturada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Preço unitário líquido. Preço de  tabela' )
	aAdd( aHlpPor, 'com aplicação dos descontos e acréscimos' )
	aAdd( aHlpPor, 'financeiros.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PRCVEN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PRCVEN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor total do ítem líquido, já' )
	aAdd( aHlpPor, 'considerado todos os descontos e  com' )
	aAdd( aHlpPor, 'base na quantidade.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VALOR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VALOR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo de controle interno.' )
	aAdd( aHlpPor, 'Ex.: Pré-nota já emitida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LA     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data prevista da entrega do pedido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ENTREG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ENTREG" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data do último faturamento deste ítem.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DATFAT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DATFAT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do preço unitário da tabela.' )
	aAdd( aHlpPor, 'Utilizado também para venda a Zona' )
	aAdd( aHlpPor, 'Franca, quando necessário imprimir o' )
	aAdd( aHlpPor, 'valor  do desconto de 7% de acordo com' )
	aAdd( aHlpPor, 'incentivos fiscais.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PRUNIT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PRUNIT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo utilizado para informar a' )
	aAdd( aHlpPor, 'quantidade a ser liberada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDLIB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Saldo do pedido a liberar.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SLDALIB", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SLDALIB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo  de  saída  do ítem, este tipo pode' )
	aAdd( aHlpPor, 'ser:' )
	aAdd( aHlpPor, 'Entrada - Códigos menor ou igual a 500' )
	aAdd( aHlpPor, 'Saída   - Códigos maior que 500' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TES    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TES" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código Fiscal da operação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CF     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da Nota Fiscal de Entrada caso o' )
	aAdd( aHlpPor, 'tipo de pedido seja "D" (Devolução de' )
	aAdd( aHlpPor, 'Compras).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NFORI  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NFORI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do IPI quando o pedido de venda' )
	aAdd( aHlpPor, 'se tratar de uma devolucão de compra.' )
	aAdd( aHlpPor, 'Caso este campo não seja preenchido o' )
	aAdd( aHlpPor, 'valor do IPI será calculado normalmente' )
	aAdd( aHlpPor, 'na preparação da Nota Fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_IPIDEV ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_IPIDEV" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Este campo é o identificador do poder' )
	aAdd( aHlpPor, 'deTerceiros.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_IDENTB6", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_IDENTB6" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Bloqueio Manual do  Pedido,  impede' )
	aAdd( aHlpPor, 'queeste Pedido seja liberado' )
	aAdd( aHlpPor, 'automaticamen-te, também utilizado para' )
	aAdd( aHlpPor, 'eliminação  deresíduo. ( "S" =' )
	aAdd( aHlpPor, 'Bloqueado, "N" ou " " =Não Bloqueado,' )
	aAdd( aHlpPor, '"R" = Resíduo ).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_BLQ    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_BLQ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade original do pedido na unidade' )
	aAdd( aHlpPor, 'secundária.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_UNSVEN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_UNSVEN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Identifica se o produto digitado é uma' )
	aAdd( aHlpPor, 'referência da grade de produtos.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_GRADE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_GRADE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do item da grade de produto' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMGRD", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMGRD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Numeração do Lote criada pelo próprio' )
	aAdd( aHlpPor, 'usuário.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOTECTL", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOTECTL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do Lote do Produto (Rastreabili-' )
	aAdd( aHlpPor, 'dade).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMLOTE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMLOTE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Armazem do qual será Retirado' )
	aAdd( aHlpPor, 'o produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOCAL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOCAL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Selecione outro código do almoxarifado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC6_LOCAL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C6_LOCAL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do orçamento de venda.' )
	aAdd( aHlpPor, 'Integridade referencial com a rotina de' )
	aAdd( aHlpPor, 'Orçamento' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMORC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMORC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto a  nível  de' )
	aAdd( aHlpPor, 'item, trabalha  em  cascata com os' )
	aAdd( aHlpPor, 'demais descontos.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DESCONT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DESCONT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo que contém os opcionais' )
	aAdd( aHlpPor, 'utilizadospara este item do Pedido de' )
	aAdd( aHlpPor, 'Venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_OPC    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_OPC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor de Desconto para este item.' )
	aAdd( aHlpPor, 'Tambem poderá ser calculado através do' )
	aAdd( aHlpPor, 'percentual informado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VALDESC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VALDESC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número de Série do produto utilizado no' )
	aAdd( aHlpPor, 'Pedido de Venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMSERI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMSERI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da OP gerada autom' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMOP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMOP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo usado para amarrar o Pedido de' )
	aAdd( aHlpPor, 'Venda com a Ordem de Produç„o gerada' )
	aAdd( aHlpPor, 'para este.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMOP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMOP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Classificação Fiscal do Produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CLASFIS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CLASFIS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código  que identifica o  cliente do' )
	aAdd( aHlpPor, 'pe-dido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CLI    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CLI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo que identifica cada uma das' )
	aAdd( aHlpPor, 'lojasdo cliente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOJA   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOJA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da última nota fiscal onde o' )
	aAdd( aHlpPor, 'ítemfoi faturado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NOTA   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NOTA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série da última nota fiscal emitida' )
	aAdd( aHlpPor, 'parao pedido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SERIE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SERIE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número  do identificador do pedido' )
	aAdd( aHlpPor, 'juntoao sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do primeiro' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_COMIS1 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_COMIS1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Endereço do item do Pedido de Venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOCALIZ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOCALIZ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do segundo' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_COMIS2 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_COMIS2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do terceiro' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_COMIS3 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_COMIS3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do quarto' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_COMIS4 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_COMIS4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do quinto' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_COMIS5 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_COMIS5" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do pedido no cliente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PEDCLI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PEDCLI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade entregue na segunda unidade' )
	aAdd( aHlpPor, 'de medida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDENT2", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDENT2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Bloqueio Manual do Pedido (Sim/Não),' )
	aAdd( aHlpPor, 'im-pede que este pedido seja liberado' )
	aAdd( aHlpPor, 'auto-maticamente. Campo também utilizado' )
	aAdd( aHlpPor, 'paraEliminação de Resíduo (R).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_BLOQUEI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_BLOQUEI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo utilizado para informar se  gerou' )
	aAdd( aHlpPor, 'previsão de vendas (Interno).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_GEROUPV", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_GEROUPV" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da reserva  cadastrada para' )
	aAdd( aHlpPor, 'esteitem.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_RESERVA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_RESERVA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Flag de geração da ordem de produção.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_OP     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_OP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'uso Interno' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_OK     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_OK" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série da Nota Fiscal de Entrada caso o' )
	aAdd( aHlpPor, 'tipo de pedido seja "D"(Devolução de' )
	aAdd( aHlpPor, 'Vendas).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SERIORI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SERIORI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do item, no caso de devolução de' )
	aAdd( aHlpPor, 'compras.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMORI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMORI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de ICMS Retido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PICMRET", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PICMRET" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade empenhada na segunda unidade' )
	aAdd( aHlpPor, 'de medida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDEMP2", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDEMP2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo de operação a ser utilizado para o' )
	aAdd( aHlpPor, 'preenchimento do TES utilizando o' )
	aAdd( aHlpPor, 'recurso do TES inteligente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_OPER   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_OPER" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código de Serviço do ISS, utilizado para' )
	aAdd( aHlpPor, 'descriminar o tipo de operação perante o' )
	aAdd( aHlpPor, 'município tributador.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODISS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data de Validade do Lote.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DTVALID", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DTVALID" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do chassi.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CHASSI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CHASSI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade reservada vinculada a este' )
	aAdd( aHlpPor, 'item do pedido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDRESE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDRESE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da ordem de serviço. Integridade' )
	aAdd( aHlpPor, 'referencial com a rotina de Ordem de' )
	aAdd( aHlpPor, 'serviço' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMOS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMOS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da Ordem de serviço do' )
	aAdd( aHlpPor, 'fabricante. Integridade referencial com' )
	aAdd( aHlpPor, 'a rotina de ordem de serviço' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMOSFA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMOSFA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Fabricante' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODFAB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODFAB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Loja do fabricante' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOJAFA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOJAFA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe memo opcional.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_MOPC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_MOPC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo da Ordem de Produção a ser gerada' )
	aAdd( aHlpPor, 'por este pedido:' )
	aAdd( aHlpPor, 'F - Firme' )
	aAdd( aHlpPor, 'P - Prevista' )
	aAdd( aHlpPor, '(Utilizado qdo gera OP por Vendas)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPOP   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPOP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'No. da Solicitação de compras gerada' )
	aAdd( aHlpPor, 'para o Pedido de Vendas' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMSC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMSC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item da Solicitação de Compras gerada' )
	aAdd( aHlpPor, 'para o Pedido de Vendas' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMSC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMSC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Revisão da Estrutura do Produto' )
	aAdd( aHlpPor, '(Utilizado qdo gera OP por Vendas)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_REVISAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_REVISAO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo utilizado para informar a' )
	aAdd( aHlpPor, 'quantidade a ser liberada na segunda' )
	aAdd( aHlpPor, 'unidade de medida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_QTDLIB2", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da execuçao de serviço do WMS.' )
	aAdd( aHlpPor, '[F3] disponivel' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SERVIC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SERVIC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do endereço para envio do' )
	aAdd( aHlpPor, 'produto. Utilizado no mapa de separaçao' )
	aAdd( aHlpPor, 'do WMS.[F3] Disponivel' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ENDPAD ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ENDPAD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do contrato de serviço.' )
	aAdd( aHlpPor, 'Integridade referencial com a rotina de' )
	aAdd( aHlpPor, 'contratos de serviço' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CONTRT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CONTRT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo do contrato (Serviço, WMS ou' )
	aAdd( aHlpPor, 'Manutenção).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPCONTR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPCONTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item do contrato de serviço. Integridade' )
	aAdd( aHlpPor, 'referencial com a rotina de contrato de' )
	aAdd( aHlpPor, 'serviço' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITCONTR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITCONTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código de referência do projeto' )
	aAdd( aHlpPor, 'vinculado ao documento de saida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PROJPMS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PROJPMS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da tarefa do projeto vinculado ao' )
	aAdd( aHlpPor, 'documento de saida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TASKPMS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TASKPMS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da licitação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LICITA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LICITA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do contrato de parceria.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CONTRAT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CONTRAT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item do contrato de parceria.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMCON", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMCON" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo de Estrutura Fisica para onde os' )
	aAdd( aHlpPor, 'produtos serao  enviados.' )
	aAdd( aHlpPor, 'Utilizado na integração com o WMS.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPESTR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPESTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da EDT do projeto vinculado ao' )
	aAdd( aHlpPor, 'documento de saida.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_EDTPMS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_EDTPMS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo que diferencia componentes de uma' )
	aAdd( aHlpPor, 'mesma estrutura.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TRT    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TRT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Contrato / Field Service.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PROJET ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PROJET" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item do contrato / field service.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITPROJ ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITPROJ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Potencia do lote informada.Utilizada no' )
	aAdd( aHlpPor, 'cálculo de necessidade quando o produto' )
	aAdd( aHlpPor, 'tem potencia variavel por lote/sub-lote.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_POTENCI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_POTENCI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Regra a ser utilizada no Apanhe:' )
	aAdd( aHlpPor, '1 = Ordem de Lote/Sub-Lote;' )
	aAdd( aHlpPor, '2 = Ordem de Número de Serie;' )
	aAdd( aHlpPor, '3 = Ordem de Data de Validade (Default).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_REGWMS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_REGWMS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Neste campo vocè irá informar o número' )
	aAdd( aHlpPor, 'do compromisso.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMCP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMCP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data de entrega sugerida pelo' )
	aAdd( aHlpPor, 'processamento do APS. Este campo é' )
	aAdd( aHlpPor, 'somente informativo e cabe ao gestor da' )
	aAdd( aHlpPor, 'Área usa-lo ou não. Depende de' )
	aAdd( aHlpPor, 'integração com software APS.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SUGENTR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SUGENTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do abatimento na base de cálculo' )
	aAdd( aHlpPor, 'do ISS calculado no faturamento do' )
	aAdd( aHlpPor, 'serviço, referente aos valores de' )
	aAdd( aHlpPor, 'subempreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ABATISS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ABATISS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do abatimento na base de cálculo' )
	aAdd( aHlpPor, 'do ISS calculado no faturamento do' )
	aAdd( aHlpPor, 'serviço, referente aos valores de' )
	aAdd( aHlpPor, 'material utilizado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ABATMAT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ABATMAT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o valor do INSS retido pela' )
	aAdd( aHlpPor, 'Subcontratada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ABSCINS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ABSCINS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item da medição do contrato' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo CAT/83' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODLAN ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODLAN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Programa.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PROGRAM", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PROGRAM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Preencha o Código da FCI informado no' )
	aAdd( aHlpPor, 'Documento Fiscal do remetente em que a' )
	aAdd( aHlpPor, 'mercadoria foi adquirida. Preencha em' )
	aAdd( aHlpPor, 'caso de revenda do produto adquirido ou' )
	aAdd( aHlpPor, 'quando não utilizar o preenchimento' )
	aAdd( aHlpPor, 'automático do código da FCI no' )
	aAdd( aHlpPor, 'faturamento.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FCICOD ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FCICOD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indicador de venda de item de mostruário' )
	aAdd( aHlpPor, 'ou saldão.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VDMOST ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VDMOST" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Observações sobre a venda de um' )
	aAdd( aHlpPor, 'mostruário/saldão' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VDOBS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VDOBS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do Funrural.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FUNRURA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FUNRURA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do Fetab.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FETAB  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FETAB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo do romaneio.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODROM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODROM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor da importação, que corresponde  ao' )
	aAdd( aHlpPor, 'valor da base de cálculo do ICMS' )
	aAdd( aHlpPor, 'incidente na operação de Importação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VLIMPOR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VLIMPOR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa para rotina de pedido de vendas' )
	aAdd( aHlpPor, '(MATA410) se devera considerar o saldo' )
	aAdd( aHlpPor, 'do armazem de para realizar as' )
	aAdd( aHlpPor, 'transferencias        entre filiais' )
	aAdd( aHlpPor, 'atraves da rotina MATA310.' )
	aAdd( aHlpPor, ',;' )
	aAdd( aHlpPor, 'Importante: Para utilizacao do processo' )
	aAdd( aHlpPor, 'e necessario habilitar o campo' )
	aAdd( aHlpPor, 'F4_TRANFIL e F4_TRANCQ.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NRSEQCQ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NRSEQCQ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informações Adicionais do Produto' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_INFAD  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_INFAD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo de dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPDEDUZ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPDEDUZ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Motivo da dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_MOTDED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_MOTDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo do fornecedor da NF de dedução' )
	aAdd( aHlpPor, '.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FORDED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FORDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'O campo permite vincular um pedido de' )
	aAdd( aHlpPor, 'venda com outro pedido de venda para o' )
	aAdd( aHlpPor, 'caso da necessidade de se imprimir na' )
	aAdd( aHlpPor, 'DANFE informações contidas em outra nota' )
	aAdd( aHlpPor, 'fiscal. Exemplo:' )
	aAdd( aHlpPor, 'Para a operação triangular em que há um' )
	aAdd( aHlpPor, 'Depositante de outro estado, deve' )
	aAdd( aHlpPor, 'constar na NF de retorno simbólico,' )
	aAdd( aHlpPor, 'informações da NF de conta e ordem.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PEDVINC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PEDVINC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Revisão do produto.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_REVPROD", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_REVPROD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Produto final para leitura do' )
	aAdd( aHlpPor, 'NCM do produto principal nas obrigações' )
	aAdd( aHlpPor, 'fiscais.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PRODFIN", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PRODFIN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Grava o numero do Item Garantia' )
	aAdd( aHlpPor, 'correspondente da tabela SL2' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMGAR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMGAR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Grava o Orcamento Garantia' )
	aAdd( aHlpPor, 'correspondente da tabela SL1' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ORCGAR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ORCGAR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série da N.F. Original' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SDOCORI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SDOCORI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Loja do Fornecedor da nota de dedução' )
	aAdd( aHlpPor, 'referenteà Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_LOJDED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_LOJDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série do Documento Fiscal' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SDOC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SDOC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Serie da Nota de dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SERDED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SERDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Nota de dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NFDED  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NFDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor da NF referente à Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VLNFD  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VLNFD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PCDED  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PCDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série NF Dedução' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SDOCDED", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SDOCDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor de dedução referente à' )
	aAdd( aHlpPor, 'Sub-empreitada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_VLDED  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_VLDED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Pedido de Venda com Ordem de Produção' )
	aAdd( aHlpPor, 'vinculada.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PVCOMOP", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PVCOMOP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Rateio' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_RATEIO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_RATEIO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série do Documento Fiscal' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SDOCSD1", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SDOCSD1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da cultivar no' )
	aAdd( aHlpPor, 'sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CTVAR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CTVAR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da categoria no' )
	aAdd( aHlpPor, 'sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CATEG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CATEG" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da peneira no' )
	aAdd( aHlpPor, 'sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PENE   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PENE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da cultura no' )
	aAdd( aHlpPor, 'sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CULTRA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CULTRA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo de repasse, conforme tabela do' )
	aAdd( aHlpPor, 'REINF.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPREPAS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPREPAS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do abatimento na base de cálculo' )
	aAdd( aHlpPor, 'do INSS calculado no faturamento do' )
	aAdd( aHlpPor, 'serviço, referente aos valores de' )
	aAdd( aHlpPor, 'material utilizado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ABATINS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ABATINS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da tabela da Natureza da Receita.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TNATREC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TNATREC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor total da nota fiscal de entrada' )
	aAdd( aHlpPor, 'referente ao veículo usado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_BASVEIC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_BASVEIC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data Inicio de Embarque do produto no' )
	aAdd( aHlpPor, 'Veículo.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DATAEMB", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DATAEMB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da Natureza de Receita.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CNATREC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CNATREC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe Grupo da Nat. da Receita.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_GRPNATR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_GRPNATR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Manhã,Tarde e Noite.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TURNO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TURNO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item do Pedido Compra da Filial de' )
	aAdd( aHlpPor, 'Necessidade que está vinculado ao Pedido' )
	aAdd( aHlpPor, 'de Venda' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITPC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITPC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data Final de escrituração da Natureza' )
	aAdd( aHlpPor, 'da Receita.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DTFIMNT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DTFIMNT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'X' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_FILPED ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_FILPED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Pedido Compra da Filial de Necessidade' )
	aAdd( aHlpPor, 'que está vinculado ao Pedido de Venda' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PEDCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PEDCOM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Relaciona com o Item da lista de' )
	aAdd( aHlpPor, 'presente' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITLPRE ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITLPRE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Serie Nota Fiscal' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_D1SERIE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_D1SERIE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Documento gerado para a lista de' )
	aAdd( aHlpPor, 'presente' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_D1DOC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_D1DOC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Relaciona o item da venda com o código' )
	aAdd( aHlpPor, 'da lista de presente' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODLPRE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODLPRE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item Nota Fiscal' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_D1ITEM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_D1ITEM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código referente a informação adicional' )
	aAdd( aHlpPor, 'do produto' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CODINF ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CODINF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o Item do Pedido de Compra. Este' )
	aAdd( aHlpPor, 'campo será utilizado para NF-e - Nota' )
	aAdd( aHlpPor, 'Fiscal Eletrônica, para controle do  B2B' )
	aAdd( aHlpPor, '- (tag nItemPed)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMPC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMPC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o Numero do Pedido de Compra.' )
	aAdd( aHlpPor, 'Este campo será utilizado para NF-e -' )
	aAdd( aHlpPor, 'Nota Fiscal Eletrônica, para controle do' )
	aAdd( aHlpPor, 'B2B - (tag xPed)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_NUMPCOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_NUMPCOM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Hora da entrega do pedido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_HORENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_HORENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Identificador do Totvs Obras e Projetos.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_PMSID  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_PMSID" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Centro de Custo' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CC     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Conta Contabil' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CONTA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CONTA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item da Conta Contabil' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ITEMCTA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ITEMCTA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Classe Valor Contabil' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CLVL   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CLVL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Numero de Solicitação de Compras para' )
	aAdd( aHlpPor, 'Pedido sem estoque' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_SOLCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_SOLCOM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo utilizado para definir o armazem' )
	aAdd( aHlpPor, 'para a movimentação de saldo de' )
	aAdd( aHlpPor, 'terceiros.  Este processo somente aceita' )
	aAdd( aHlpPor, 'armazens definidos atraves do parametro' )
	aAdd( aHlpPor, 'MV_ALMTERC.   Importante: para utilizar' )
	aAdd( aHlpPor, 'o conceito de transferencia de saldos' )
	aAdd( aHlpPor, 'para o  armazem   de terceiros' )
	aAdd( aHlpPor, 'configurar o parametro MV_CONTERC.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_ALMTERC", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_ALMTERC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Centro de Custo.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CCUSTO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CCUSTO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data da integração do pedido de venda ao' )
	aAdd( aHlpPor, 'roteirizador Cockpit Logístico.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_DATCPL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_DATCPL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Hora da integração do pedido de venda ao' )
	aAdd( aHlpPor, 'roteirizador Cockpit Logístico.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_HORCPL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_HORCPL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Status da integração do pedido de venda' )
	aAdd( aHlpPor, 'com o roteirizador Cockpit Logístico.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_INTROT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_INTROT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Item proveniente do processo licitatório' )
	aAdd( aHlpPor, '(GCP - Gestão de Compras Públicas)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_GCPIT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_GCPIT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Lote proveniente do processo licitatório' )
	aAdd( aHlpPor, '(GCP - Gestão de Compras Públicas)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_GCPLT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_GCPLT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor da base de calculo do IPI na' )
	aAdd( aHlpPor, 'transferência de produtos entre filiais.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_IPITRF ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_IPITRF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa se o item criou Pendência de' )
	aAdd( aHlpPor, 'Desenvolvimento de Produto junto ao' )
	aAdd( aHlpPor, 'SIGADPR.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_TPPROD ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_TPPROD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da Situação Tributária' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_CSTPIS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C6_CSTPIS" )

	AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
	Local   aRet      := {}
	Local   aSalvAmb  := GetArea()
	Local   aSalvSM0  := {}
	Local   aVetor    := {}
	Local   cMascEmp  := "??"
	Local   cVar      := ""
	Local   lChk      := .F.
	Local   lOk       := .F.
	Local   lTeveMarc := .F.
	Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
	Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

	Local   aMarcadas := {}


	If !MyOpenSm0(.F.)
		Return aRet
	EndIf


	dbSelectArea( "SM0" )
	aSalvSM0 := SM0->( GetArea() )
	dbSetOrder( 1 )
	dbGoTop()

	While !SM0->( EOF() )

		If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
			aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
		EndIf

		dbSkip()
	End

	RestArea( aSalvSM0 )

	Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

	oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

	oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

	@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
	oLbx:SetArray(  aVetor )
	oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
		aVetor[oLbx:nAt, 2], ;
		aVetor[oLbx:nAt, 4]}}
	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll

	@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
		on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
	@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
	@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
		Message "Máscara Empresa ( ?? )"  Of oDlg
	oSay:cToolTip := oMascEmp:cToolTip

	@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Inverter Seleção" Of oDlg
	oButInv:SetCss( CSSBOTAO )
	@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
	oButMarc:SetCss( CSSBOTAO )
	@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
	oButDMar:SetCss( CSSBOTAO )
	@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "SC6C28" ) ) ) ;
		Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
	oButOk:SetCss( CSSBOTAO )
	@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
		Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
	oButCanc:SetCss( CSSBOTAO )

	Activate MSDialog  oDlg Center

	RestArea( aSalvAmb )
	dbSelectArea( "SM0" )
	dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI

	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI

	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
	Local  nI    := 0

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
		EndIf
	Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0

	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] := lMarDes
			EndIf
		EndIf
	Next

	oLbx:nAt := nPos
	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
	Local lTTrue := .T.
	Local nI     := 0

	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI

	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
	Local lOpen := .F.
	Local nLoop := 0
	lShared := .T.

	If FindFunction( "_OpenSM0Excl" )
		For nLoop := 1 To 20
			If OpenSM0Excl(,.F.)
				lOpen := .T.
				Exit
			EndIf
			Sleep( 500 )
		Next nLoop
	Else
		For nLoop := 1 To 20
			dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

			If !Empty( Select( "SM0" ) )
				lOpen := .T.
				dbSetIndex( "SIGAMAT.IND" )
				Exit
			EndIf
			Sleep( 500 )
		Next nLoop
	EndIf

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ;
			IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
	EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
	Local cRet  := ""
	Local cFile := NomeAutoLog()
	Local cAux  := ""

	FT_FUSE( cFile )
	FT_FGOTOP()

	While !FT_FEOF()

		cAux := FT_FREADLN()

		If Len( cRet ) + Len( cAux ) < 1048000
			cRet += cAux + CRLF
		Else
			cRet += CRLF
			cRet += Replicate( "=" , 128 ) + CRLF
			cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
			cRet += "LOG Completo no arquivo " + cFile + CRLF
			cRet += Replicate( "=" , 128 ) + CRLF
			Exit
		EndIf

		FT_FSKIP()
	End

	FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
