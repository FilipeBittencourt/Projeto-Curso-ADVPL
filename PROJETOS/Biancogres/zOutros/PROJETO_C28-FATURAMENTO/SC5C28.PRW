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
/*/{Protheus.doc} SC5C28
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  30/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function SC5C28( cEmpAmb, cFilAmb )

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
						MsgStop( "Atualização Realizada.", "SC5C28" )
					Else
						MsgStop( "Atualização não Realizada.", "SC5C28" )
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
// Tabela SC5
//
	aAdd( aSX2, { ;
		'SC5'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SC5'+cEmpr																, ; //X2_ARQUIVO
	'Pedidos de Venda'														, ; //X2_NOME
	'Pedidos de Venta'														, ; //X2_NOMESPA
	'Sales Orders'															, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'C5_FILIAL+C5_NUM'														, ; //X2_UNICO
	'C5_NUM+C5_CLIENTE+C5_LOJACLI+C5_CONDPAG'								, ; //X2_DISPLAY
	'MATA410'																, ; //X2_SYSOBJ
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
// Campos Tabela SC5
//
	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FILIAL'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NUM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Numero'																, .T. }, ; //X3_TITULO
	{ 'Numero'																, .T. }, ; //X3_TITSPA
	{ 'Number'																, .T. }, ; //X3_TITENG
	{ 'Numero do Pedido'													, .T. }, ; //X3_DESCRIC
	{ 'Numero del Pedido'													, .T. }, ; //X3_DESCSPA
	{ 'Order Number'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio().And.ExistChav("SC5")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ 'U_FCOMIP01()'														, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TIPO'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Pedido'															, .T. }, ; //X3_TITULO
	{ 'Tipo pedido'															, .T. }, ; //X3_TITSPA
	{ 'Order Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Pedido'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de pedido'														, .T. }, ; //X3_DESCSPA
	{ 'Type of Order'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("NCIPDB").and.A410Limpa()'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '&N=Normal;C=Compl.Preco/Quantidade;I=Compl.ICMS;P=Compl.IPI;D=Dev.Compras;B=Utiliza Fornecedor', .T. }, ; //X3_CBOX
	{ '&N=Normal;C=Compl.Precio/Cantidad;I=Compl.ICMS;P=Compl.IPI;D=Dev.Compras;B=Utiliza proveedor', .T. }, ; //X3_CBOXSPA
	{ '&N=Normal;C=Compl.Price/Quantity;I=Compl.ICMS;P=Compl.IPI;D=Deb.Purchase;B=Uses Supplier', .T. }, ; //X3_CBOXENG
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YLINHA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Marca'																, .T. }, ; //X3_TITULO
	{ 'Marca'																, .T. }, ; //X3_TITSPA
	{ 'Marca'																, .T. }, ; //X3_TITENG
	{ 'Marca/Linha do Produto'												, .T. }, ; //X3_DESCRIC
	{ 'Marca/Linha do Produto'												, .T. }, ; //X3_DESCSPA
	{ 'Marca/Linha do Produto'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(255) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_VC5_YLINHA()'														, .T. }, ; //X3_VLDUSER
	{ '#U_FOPLINHA()'														, .T. }, ; //X3_CBOX
	{ '#U_FOPLINHA()'														, .T. }, ; //X3_CBOXSPA
	{ '#U_FOPLINHA()'														, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YSUBTP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Venda'															, .T. }, ; //X3_TITULO
	{ 'Tipo Venda'															, .T. }, ; //X3_TITSPA
	{ 'Tipo Venda'															, .T. }, ; //X3_TITENG
	{ 'Tipo da Venda'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo da Venda'														, .T. }, ; //X3_DESCSPA
	{ 'Tipo da Venda'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DJBIA'																, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_FROPVL01(M->C5_YSUBTP) .And. U_FCOMVL01()'							, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'C5_LOJAENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja Entrega'														, .T. }, ; //X3_TITULO
	{ 'Tda. Entrega'														, .T. }, ; //X3_TITSPA
	{ 'Deliv. Unit'															, .T. }, ; //X3_TITENG
	{ 'Codigo da Loja de Entrega'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo Tienda de Entrega'											, .T. }, ; //X3_DESCSPA
	{ 'Code of Delivery Unit'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'A410LojEnt()'														, .T. }, ; //X3_VALID
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
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(M->C5_TIPO$"DB",.F.,.T.)'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YTPCRED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Crédito'														, .T. }, ; //X3_TITULO
	{ 'Tipo Crédito'														, .T. }, ; //X3_TITSPA
	{ 'Tipo Crédito'														, .T. }, ; //X3_TITENG
	{ 'Tipo Crédito'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo Crédito'														, .T. }, ; //X3_DESCSPA
	{ 'Tipo Crédito'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"0"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ 'pertence("0/3/4")'													, .T. }, ; //X3_VLDUSER
	{ '0=Rotina Crédito;2=Contrato;3=Del Credere;4=Termo Resp.;5=Eng.'		, .T. }, ; //X3_CBOX
	{ '0=Rotina Crédito;2=Contrato;3=Del Credere;4=Termo Resp.;5=Eng.'		, .T. }, ; //X3_CBOXSPA
	{ '0=Rotina Crédito;2=Contrato;3=Del Credere;4=Termo Resp.;5=Eng.'		, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'M->C5_YTPCRED == "0" .AND. INCLUI'									, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CLIENTE'															, .T. }, ; //X3_CAMPO
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
	{ 'A410Cli().And.A410ReCalc()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1REP'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_FCOMVL01() .And. U_FROPTE06()'										, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'INCLUI .And. Empty(M->C5_CONDPAG)'									, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'C5_LOJACLI'															, .T. }, ; //X3_CAMPO
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
	{ 'A410Loja().And.A410ReCalc()'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'IIF(Type("CREPATU")=="U".Or.Empty(CREPATU),INCLUI,.F.)'				, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCATCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Categ Bianco'														, .T. }, ; //X3_TITULO
	{ 'Categ Bianco'														, .T. }, ; //X3_TITSPA
	{ 'Categ Bianco'														, .T. }, ; //X3_TITENG
	{ 'Categoria cliente Biancog'											, .T. }, ; //X3_DESCRIC
	{ 'Categoria cliente Biancog'											, .T. }, ; //X3_DESCSPA
	{ 'Categoria cliente Biancog'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ZCAT'																, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YRECR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cli. Distrib'														, .T. }, ; //X3_TITULO
	{ 'Cli. Distrib'														, .T. }, ; //X3_TITSPA
	{ 'Cli. Distrib'														, .T. }, ; //X3_TITENG
	{ 'Cliente é Distribuidor?'												, .T. }, ; //X3_DESCRIC
	{ 'Cliente é Distribuidor?'												, .T. }, ; //X3_DESCSPA
	{ 'Cliente é Distribuidor?'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TRANSP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Transp.'																, .T. }, ; //X3_TITULO
	{ 'Transp.'																, .T. }, ; //X3_TITSPA
	{ 'Carrier'																, .T. }, ; //X3_TITENG
	{ 'Codigo da Transportadora'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Transportador'											, .T. }, ; //X3_DESCSPA
	{ 'Carrier Code'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'vazio() .or. existcpo("SA4")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ 'M->C5_TPFRETE<>"S" .And. !IsInCallStack("U_M410RPRC")'				, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TIPOCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Cliente'														, .T. }, ; //X3_TITULO
	{ 'Tipo Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Customer Ty.'														, .T. }, ; //X3_TITENG
	{ 'Tipo do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Cliente'														, .T. }, ; //X3_DESCSPA
	{ 'Type of Customer'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'pertence("FLRSUX")'													, .T. }, ; //X3_VLDUSER
	{ 'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao', .T. }, ; //X3_CBOX
	{ 'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacion/Importacion', .T. }, ; //X3_CBOXSPA
	{ 'F=Final Cons.;L=Rural Prod.;R=Reseller;S=Solidary;X=Export/Import'		, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CONDPAG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cond. Pagto'															, .T. }, ; //X3_TITULO
	{ 'Cond. Pago'															, .T. }, ; //X3_TITSPA
	{ 'Payment Term'														, .T. }, ; //X3_TITENG
	{ 'Condicao de Pagamento'												, .T. }, ; //X3_DESCRIC
	{ 'Condicion de Pago'													, .T. }, ; //X3_DESCSPA
	{ 'Payment Term'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SE4").And.A410AcrFin().And.MaVldTabPrc(M->C5_TABELA,M->C5_CONDPAG,,M->C5_EMISSAO) .And. A410Recalc()', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SE4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(131) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_Z07CPVLD()'														, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YFORMA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Pagto'															, .T. }, ; //X3_TITULO
	{ 'Tipo Pagto'															, .T. }, ; //X3_TITSPA
	{ 'Tipo Pagto'															, .T. }, ; //X3_TITENG
	{ 'Tipo do pagamento'													, .T. }, ; //X3_DESCRIC
	{ 'Tipo do pagamento'													, .T. }, ; //X3_DESCSPA
	{ 'Tipo do pagamento'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(255) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ 'iif(Posicione("SA1",1,xFILIAL("SA1")+M->C5_CLIENTE,"A1_TIPO")$"XU" .AND. !M->C5_YFORMA$"23",.F.,.T.)', .T. }, ; //X3_VLDUSER
	{ '1=Banco;2=Cheque;3=OP;4=CT'											, .T. }, ; //X3_CBOX
	{ '1=Banco;2=Cheque;3=OP;4=CT'											, .T. }, ; //X3_CBOXSPA
	{ '1=Banco;2=Cheque;3=OP;4=CT'											, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMAXCND'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 6																		, .T. }, ; //X3_DECIMAL
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_TITULO
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_TITSPA
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_TITENG
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_DESCRIC
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_DESCSPA
	{ 'Max Cnd Pgt'															, .T. }, ; //X3_DESCENG
	{ '@E 99.999999'														, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Empty(CREPATU),M->C5_YMAXCND>0,.F.)'								, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPERC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
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
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPRZINC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Inc.Vencto.'															, .T. }, ; //X3_TITULO
	{ 'Inc.Vencto.'															, .T. }, ; //X3_TITSPA
	{ 'Inc.Vencto.'															, .T. }, ; //X3_TITENG
	{ 'Incremento no Vencto.'												, .T. }, ; //X3_DESCRIC
	{ 'Incremento no Vencto.'												, .T. }, ; //X3_DESCSPA
	{ 'Incremento no Vencto.'												, .T. }, ; //X3_DESCENG
	{ '@E 999'																, .T. }, ; //X3_PICTURE
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
	{ 'U_BIA194()'															, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDTINC'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data Inc.'															, .T. }, ; //X3_TITULO
	{ 'Data Inc.'															, .T. }, ; //X3_TITSPA
	{ 'Data Inc.'															, .T. }, ; //X3_TITENG
	{ 'Data Incremento'														, .T. }, ; //X3_DESCRIC
	{ 'Data Incremento'														, .T. }, ; //X3_DESCSPA
	{ 'Data Incremento'														, .T. }, ; //X3_DESCENG
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
	{ 'U_BIA194_2()'														, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCONF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Conferido?'															, .T. }, ; //X3_TITULO
	{ 'Conferido?'															, .T. }, ; //X3_TITSPA
	{ 'Conferido?'															, .T. }, ; //X3_TITENG
	{ 'Pedido Conferido?'													, .T. }, ; //X3_DESCRIC
	{ 'Pedido Conferido?'													, .T. }, ; //X3_DESCSPA
	{ 'Pedido Conferido?'													, .T. }, ; //X3_DESCENG
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
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_fVldConf()'														, .T. }, ; //X3_VLDUSER
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOX
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOXSPA
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNPRENG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr.Proposta'															, .T. }, ; //X3_TITULO
	{ 'Nr.Proposta'															, .T. }, ; //X3_TITSPA
	{ 'Nr.Proposta'															, .T. }, ; //X3_TITENG
	{ 'Numero da Proposta Engenh'											, .T. }, ; //X3_DESCRIC
	{ 'Numero da Proposta Engenh'											, .T. }, ; //X3_DESCSPA
	{ 'Numero da Proposta Engenh'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'C5PENG'																, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'U_PENGVLC5()'														, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '22'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped.Compra'															, .T. }, ; //X3_TITULO
	{ 'Ped.Compra'															, .T. }, ; //X3_TITSPA
	{ 'Ped.Compra'															, .T. }, ; //X3_TITENG
	{ 'Pedido Compra Cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Pedido Compra Cliente'												, .T. }, ; //X3_DESCSPA
	{ 'Pedido Compra Cliente'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '23'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VLRFRET'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Vlr. Seguro'															, .T. }, ; //X3_TITULO
	{ 'Vlr. Seguro'															, .T. }, ; //X3_TITSPA
	{ 'Vlr. Seguro'															, .T. }, ; //X3_TITENG
	{ 'Valor do Seguro'														, .T. }, ; //X3_DESCRIC
	{ 'Valor do Seguro'														, .T. }, ; //X3_DESCSPA
	{ 'Valor do Seguro'														, .T. }, ; //X3_DESCENG
	{ '@E  99.999'															, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '24'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YFRETE'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Frete R$'															, .T. }, ; //X3_TITULO
	{ 'Frete R$'															, .T. }, ; //X3_TITSPA
	{ 'Frete R$'															, .T. }, ; //X3_TITENG
	{ 'Frete R$'															, .T. }, ; //X3_DESCRIC
	{ 'Frete R$'															, .T. }, ; //X3_DESCSPA
	{ 'Frete R$'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '25'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLRREV'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Acrescimo PV'														, .T. }, ; //X3_TITULO
	{ 'Acrescimo PV'														, .T. }, ; //X3_TITSPA
	{ 'Acrescimo PV'														, .T. }, ; //X3_TITENG
	{ 'Valor Acrescimo PV'													, .T. }, ; //X3_DESCRIC
	{ 'Valor Acrescimo PV'													, .T. }, ; //X3_DESCSPA
	{ 'Valor Acrescimo PV'													, .T. }, ; //X3_DESCENG
	{ '@E 99.999'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '26'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCLIDEL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cli.Del Cred'														, .T. }, ; //X3_TITULO
	{ 'Cli.Del Cred'														, .T. }, ; //X3_TITSPA
	{ 'Cli.Del Cred'														, .T. }, ; //X3_TITENG
	{ 'Cliente Del Credere'													, .T. }, ; //X3_DESCRIC
	{ 'Cliente Del Credere'													, .T. }, ; //X3_DESCSPA
	{ 'Cliente Del Credere'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '27'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPERDEL'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Del Cred.'															, .T. }, ; //X3_TITULO
	{ '% Del Cred.'															, .T. }, ; //X3_TITSPA
	{ '% Del Cred.'															, .T. }, ; //X3_TITENG
	{ 'Percentual de Del Credere'											, .T. }, ; //X3_DESCRIC
	{ 'Percentual de Del Credere'											, .T. }, ; //X3_DESCSPA
	{ 'Percentual de Del Credere'											, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '28'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YBAIDEL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Baixa D.Cred'														, .T. }, ; //X3_TITULO
	{ 'Baixa D.Cred'														, .T. }, ; //X3_TITSPA
	{ 'Baixa D.Cred'														, .T. }, ; //X3_TITENG
	{ 'Baixa o Del Credere ?'												, .T. }, ; //X3_DESCRIC
	{ 'Baixa o Del Credere ?'												, .T. }, ; //X3_DESCSPA
	{ 'Baixa o Del Credere ?'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '29'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNFDEL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'NF Del Cred.'														, .T. }, ; //X3_TITULO
	{ 'NF Del Cred.'														, .T. }, ; //X3_TITSPA
	{ 'NF Del Cred.'														, .T. }, ; //X3_TITENG
	{ 'Nr NF Orig. Del Credere'												, .T. }, ; //X3_DESCRIC
	{ 'Nr NF Orig. Del Credere'												, .T. }, ; //X3_DESCSPA
	{ 'Nr NF Orig. Del Credere'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '30'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TABELA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tabela'																, .T. }, ; //X3_TITULO
	{ 'Tabla'																, .T. }, ; //X3_TITSPA
	{ 'Table'																, .T. }, ; //X3_TITENG
	{ 'Codigo da Tabela de Preco'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo Tabla de Precios'												, .T. }, ; //X3_DESCSPA
	{ 'Price List Code'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'MaVldTabPrc(M->C5_TABELA,M->C5_CONDPAG,,M->C5_EMISSAO) .And. A410ReCalc()', .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DA0'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Existcpo("DA0")'														, .T. }, ; //X3_VLDUSER
	{ '1=Tabela 1;2=tabela 2;3=Tabela 3;4=Tabela 4;5=Tabela 5;6=Tabela6;7=tabela 7', .T. }, ; //X3_CBOX
	{ '1=Tabla 1;2=Tabla 2;3=Tabla 3;4=Tabla 4;5=Tabla 5;6=Tabla 6;7=Tabla 7'	, .T. }, ; //X3_CBOXSPA
	{ '1=LPrice1;2=LPrice2;3=LPrice3;4=LPrice4;5=LPrice5;6=LPrice6;7=LPrice7'	, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '31'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEND1'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vendedor 1'															, .T. }, ; //X3_TITULO
	{ 'Vendedor 1'															, .T. }, ; //X3_TITSPA
	{ 'Seller 1'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Vendedor 1'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Vendedor 1'												, .T. }, ; //X3_DESCSPA
	{ 'Seller Code 1'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'a410Vend() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ 'NaoVazio()'															, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '32'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COMIS1'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 1'															, .T. }, ; //X3_TITULO
	{ 'Comision 1'															, .T. }, ; //X3_TITSPA
	{ 'Commission 1'														, .T. }, ; //X3_TITENG
	{ 'Comissao do Vendedor 1'												, .T. }, ; //X3_DESCRIC
	{ 'Comision del Vendedor 1'												, .T. }, ; //X3_DESCSPA
	{ 'Commission of Seller 1'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '33'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEND2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vendedor 2'															, .T. }, ; //X3_TITULO
	{ 'Vendedor 2'															, .T. }, ; //X3_TITSPA
	{ 'Seller 2'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Vendedor 2'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Vendedor 2'												, .T. }, ; //X3_DESCSPA
	{ 'Seller Code 2'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'a410Vend() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '34'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COMIS2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 2'															, .T. }, ; //X3_TITULO
	{ 'Comision 2'															, .T. }, ; //X3_TITSPA
	{ 'Commission 2'														, .T. }, ; //X3_TITENG
	{ 'Comissao do Vendedor 2'												, .T. }, ; //X3_DESCRIC
	{ 'Comision del Vendedor 2'												, .T. }, ; //X3_DESCSPA
	{ 'Commission of Seller 2'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '35'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEND3'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vendedor 3'															, .T. }, ; //X3_TITULO
	{ 'Vendedor 3'															, .T. }, ; //X3_TITSPA
	{ 'Seller 3'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Vendedor 3'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Vendedor 3'												, .T. }, ; //X3_DESCSPA
	{ 'Seller Code 3'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'a410Vend() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '36'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COMIS3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 3'															, .T. }, ; //X3_TITULO
	{ 'Comision 3'															, .T. }, ; //X3_TITSPA
	{ 'Commission 3'														, .T. }, ; //X3_TITENG
	{ 'Comissao do Vendedor 3'												, .T. }, ; //X3_DESCRIC
	{ 'Comision del Vendedor 3'												, .T. }, ; //X3_DESCSPA
	{ 'Commission of Seller 3'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '37'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEND4'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vendedor 4'															, .T. }, ; //X3_TITULO
	{ 'Vendedor 4'															, .T. }, ; //X3_TITSPA
	{ 'Seller 4'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Vendedor 4'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Vendedor 4'												, .T. }, ; //X3_DESCSPA
	{ 'Seller Code 4'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'a410Vend() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '38'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COMIS4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 4'															, .T. }, ; //X3_TITULO
	{ 'Comision 4'															, .T. }, ; //X3_TITSPA
	{ 'Commission 4'														, .T. }, ; //X3_TITENG
	{ 'Comissao do Vendedor 4'												, .T. }, ; //X3_DESCRIC
	{ 'Comision del Vendedor 4'												, .T. }, ; //X3_DESCSPA
	{ 'Commission of Seller 4'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '39'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEND5'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vendedor 5'															, .T. }, ; //X3_TITULO
	{ 'Vendedor 5'															, .T. }, ; //X3_TITSPA
	{ 'Seller 5'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Vendedor 5'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Vendedor 5'												, .T. }, ; //X3_DESCSPA
	{ 'Seller Code 5'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'a410Vend() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA3'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '40'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COMIS5'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Comissao 5'															, .T. }, ; //X3_TITULO
	{ 'Comision 5'															, .T. }, ; //X3_TITSPA
	{ 'Commission 5'														, .T. }, ; //X3_TITENG
	{ 'Comissao do Vendedor 5'												, .T. }, ; //X3_DESCRIC
	{ 'Comision del Vendedor 5'												, .T. }, ; //X3_DESCSPA
	{ 'Commission of Seller 5'												, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '41'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESC1'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desconto 1'															, .T. }, ; //X3_TITULO
	{ 'Descuento 1'															, .T. }, ; //X3_TITSPA
	{ 'Discount 1'															, .T. }, ; //X3_TITENG
	{ 'Desconto 1'															, .T. }, ; //X3_DESCRIC
	{ 'Descuento 1'															, .T. }, ; //X3_DESCSPA
	{ 'Discount 1'															, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ '(Positivo() .or. vazio()) .and. a410Recalc()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '42'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESC2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desconto 2'															, .T. }, ; //X3_TITULO
	{ 'Descuento 2'															, .T. }, ; //X3_TITSPA
	{ 'Discount 2'															, .T. }, ; //X3_TITENG
	{ 'Desconto 2'															, .T. }, ; //X3_DESCRIC
	{ 'Descuento 2'															, .T. }, ; //X3_DESCSPA
	{ 'Discount 2'															, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ '(Positivo() .or. vazio()) .and. a410Recalc()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '43'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESC3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desconto 3'															, .T. }, ; //X3_TITULO
	{ 'Descuento 3'															, .T. }, ; //X3_TITSPA
	{ 'Discount 3'															, .T. }, ; //X3_TITENG
	{ 'Desconto 3'															, .T. }, ; //X3_DESCRIC
	{ 'Descuento 3'															, .T. }, ; //X3_DESCSPA
	{ 'Discount 3'															, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ '(Positivo() .or. vazio()) .and. a410Recalc()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '44'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESC4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desconto 4'															, .T. }, ; //X3_TITULO
	{ 'Descuento 4'															, .T. }, ; //X3_TITSPA
	{ 'Discount 4'															, .T. }, ; //X3_TITENG
	{ 'Desconto 4'															, .T. }, ; //X3_DESCRIC
	{ 'Descuento 4'															, .T. }, ; //X3_DESCSPA
	{ 'Discount 4'															, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ '(Positivo() .or. vazio()) .and. a410Recalc()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '45'																	, .T. }, ; //X3_ORDEM
	{ 'C5_BANCO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Banco'																, .T. }, ; //X3_TITULO
	{ 'Banco'																, .T. }, ; //X3_TITSPA
	{ 'Bank'																, .T. }, ; //X3_TITENG
	{ 'Codigo do Banco'														, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Banco'													, .T. }, ; //X3_DESCSPA
	{ 'Bank Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .or. Existcpo("SA6")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'BCO'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '007'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '46'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESCFI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.Financ.'														, .T. }, ; //X3_TITULO
	{ 'Dsct.Financ.'														, .T. }, ; //X3_TITSPA
	{ 'Financ.Disc.'														, .T. }, ; //X3_TITENG
	{ 'Desconto Financeiro'													, .T. }, ; //X3_DESCRIC
	{ 'Descuento Financiero'												, .T. }, ; //X3_DESCSPA
	{ 'Financial Discount'													, .T. }, ; //X3_DESCENG
	{ '99'																	, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '47'																	, .T. }, ; //X3_ORDEM
	{ 'C5_EMISSAO'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'DT Emissao'															, .T. }, ; //X3_TITULO
	{ 'Fch Emision'															, .T. }, ; //X3_TITSPA
	{ 'Issue Date'															, .T. }, ; //X3_TITENG
	{ 'Data da Emissao'														, .T. }, ; //X3_DESCRIC
	{ 'Fecha de la Emision'													, .T. }, ; //X3_DESCSPA
	{ 'Issue Date'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'MaVldTabPrc(M->C5_TABELA,M->C5_CONDPAG,,M->C5_EMISSAO)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'ddatabase'															, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '48'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YHORA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Hora Inc.Ped'														, .T. }, ; //X3_TITULO
	{ 'Hora Inc.Ped'														, .T. }, ; //X3_TITSPA
	{ 'Hora Inc.Ped'														, .T. }, ; //X3_TITENG
	{ 'Hora Inclusão Pedido'												, .T. }, ; //X3_DESCRIC
	{ 'Hora Inclusão Pedido'												, .T. }, ; //X3_DESCSPA
	{ 'Hora Inclusão Pedido'												, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '49'																	, .T. }, ; //X3_ORDEM
	{ 'C5_COTACAO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Licitacao'															, .T. }, ; //X3_TITULO
	{ 'Licitacion'															, .T. }, ; //X3_TITSPA
	{ 'Bidding'																, .T. }, ; //X3_TITENG
	{ 'Numero da Licitacao'													, .T. }, ; //X3_DESCRIC
	{ 'Numero de la Licitacion'												, .T. }, ; //X3_DESCSPA
	{ 'Bidding Number'														, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'AH9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '50'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC1'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 1'															, .T. }, ; //X3_TITULO
	{ 'Cuota 1'																, .T. }, ; //X3_TITSPA
	{ 'Installment'															, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 1'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la cuota 1'													, .T. }, ; //X3_DESCSPA
	{ 'Installment Value 1'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '51'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA1'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 1'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento1'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt1'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 1'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 1'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date1'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '52'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 2'															, .T. }, ; //X3_TITULO
	{ 'Cuota 2'																, .T. }, ; //X3_TITSPA
	{ 'Installment'															, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 2'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la cuota 2'													, .T. }, ; //X3_DESCSPA
	{ 'Installment Value 2'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '53'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA2'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 2'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento2'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt2'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 2'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 2'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date2'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '54'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 3'															, .T. }, ; //X3_TITULO
	{ 'Cuota 3'																, .T. }, ; //X3_TITSPA
	{ 'Installment'															, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 3'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la cuota 3'													, .T. }, ; //X3_DESCSPA
	{ 'Installment Value 3'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '55'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESPESA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Despesa'																, .T. }, ; //X3_TITULO
	{ 'Gasto'																, .T. }, ; //X3_TITSPA
	{ 'Expense'																, .T. }, ; //X3_TITENG
	{ 'Valor Despesa Acessoria'												, .T. }, ; //X3_DESCRIC
	{ 'Valor Gasto Adicional'												, .T. }, ; //X3_DESCSPA
	{ 'Discretionary Exp Value'												, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '56'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FRETAUT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Frete Auton.'														, .T. }, ; //X3_TITULO
	{ 'Flete Auton.'														, .T. }, ; //X3_TITSPA
	{ 'Freight Auto'														, .T. }, ; //X3_TITENG
	{ 'Frete Autonomo'														, .T. }, ; //X3_DESCRIC
	{ 'Flete autónomo'														, .T. }, ; //X3_DESCSPA
	{ 'Indep Freight'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'positivo()'															, .T. }, ; //X3_VALID
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '57'																	, .T. }, ; //X3_ORDEM
	{ 'C5_REAJUST'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Reajust'														, .T. }, ; //X3_TITULO
	{ 'Tipo Reajust'														, .T. }, ; //X3_TITSPA
	{ 'Adjt Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Reajuste Usado'												, .T. }, ; //X3_DESCRIC
	{ 'Tipo de reajuste usado'												, .T. }, ; //X3_DESCSPA
	{ 'Used Adjust Type'													, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCpo("SM4")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SM4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '58'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MOEDA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Moeda'																, .T. }, ; //X3_TITULO
	{ 'Moneda'																, .T. }, ; //X3_TITSPA
	{ 'Currency'															, .T. }, ; //X3_TITENG
	{ 'Moeda do Pedido de Venda'											, .T. }, ; //X3_DESCRIC
	{ 'Moneda de pedido de venta'											, .T. }, ; //X3_DESCSPA
	{ 'Sales Order Currency'												, .T. }, ; //X3_DESCENG
	{ '@E 9'																, .T. }, ; //X3_PICTURE
	{ 'M->C5_MOEDA > 0 .AND. M->C5_MOEDA <= MOEDFIN() .And. a410Recalc()'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '1'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(152) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '59'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA3'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 3'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento3'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt3'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 3'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 3'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date3'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '60'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 4'															, .T. }, ; //X3_TITULO
	{ 'Cuota 4'																, .T. }, ; //X3_TITSPA
	{ 'Installment'															, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 4'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la cuota 4'													, .T. }, ; //X3_DESCSPA
	{ 'Installment Value 4'													, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '61'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA4'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 4'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento4'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt4'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 4'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 4'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date4'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '62'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TPFRETE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Frete'															, .T. }, ; //X3_TITULO
	{ 'Tipo Flete'															, .T. }, ; //X3_TITSPA
	{ 'Tipo Freight'														, .T. }, ; //X3_TITENG
	{ 'Tipo do Frete Utilizado'												, .T. }, ; //X3_DESCRIC
	{ 'Tipo del flete utilizado'											, .T. }, ; //X3_DESCSPA
	{ 'Tp of Used Freight'													, .T. }, ; //X3_DESCENG
	{ 'X'																	, .T. }, ; //X3_PICTURE
	{ 'pertence("CFTRDS")'													, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IIF(Type("CREPATU")<>"U", IIF(Empty(CREPATU),"","F")  ,"")'			, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ 'pertence("CFTRDS")'													, .T. }, ; //X3_VLDUSER
	{ 'C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete'						, .T. }, ; //X3_CBOX
	{ 'C=CIF;F=FOB;T=Por cta terceros;S=Sin flete'							, .T. }, ; //X3_CBOXSPA
	{ 'C=CIF;F=FOB;T=Due to Third Party;S=No freight'						, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '63'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FRETE'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Frete /p Dev'														, .T. }, ; //X3_TITULO
	{ 'Flete'																, .T. }, ; //X3_TITSPA
	{ 'Freight'																, .T. }, ; //X3_TITENG
	{ 'Valor do Frete'														, .T. }, ; //X3_DESCRIC
	{ 'Valor del flete'														, .T. }, ; //X3_DESCSPA
	{ 'Freight Value'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '64'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SEGURO'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Seguro'																, .T. }, ; //X3_TITULO
	{ 'Seguro'																, .T. }, ; //X3_TITSPA
	{ 'Insurance'															, .T. }, ; //X3_TITENG
	{ 'Valor do Seguro'														, .T. }, ; //X3_DESCRIC
	{ 'Valor del seguro'													, .T. }, ; //X3_DESCSPA
	{ 'Insurance Value'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '65'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PESOL'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Peso Liquido'														, .T. }, ; //X3_TITULO
	{ 'Peso neto'															, .T. }, ; //X3_TITSPA
	{ 'Net Wght'															, .T. }, ; //X3_TITENG
	{ 'Peso Liquido'														, .T. }, ; //X3_DESCRIC
	{ 'Peso neto'															, .T. }, ; //X3_DESCSPA
	{ 'Net Weight'															, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '66'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PBRUTO'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Peso Bruto'															, .T. }, ; //X3_TITULO
	{ 'Peso Bruto'															, .T. }, ; //X3_TITSPA
	{ 'Gross Wght'															, .T. }, ; //X3_TITENG
	{ 'Peso Bruto'															, .T. }, ; //X3_DESCRIC
	{ 'Peso Bruto'															, .T. }, ; //X3_DESCSPA
	{ 'Gross Weight'														, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '67'																	, .T. }, ; //X3_ORDEM
	{ 'C5_REIMP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Qt Pre-Notas'														, .T. }, ; //X3_TITULO
	{ 'Ctd Fct Prev'														, .T. }, ; //X3_TITSPA
	{ 'Qty Proforma'														, .T. }, ; //X3_TITENG
	{ 'Quant. Pre-Notas Impr.'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd facturas previas impr'											, .T. }, ; //X3_DESCSPA
	{ 'Qty proforma print'													, .T. }, ; //X3_DESCENG
	{ '9'																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '68'																	, .T. }, ; //X3_ORDEM
	{ 'C5_REDESP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Redespacho'															, .T. }, ; //X3_TITULO
	{ 'Redespacho'															, .T. }, ; //X3_TITSPA
	{ 'Redispatch'															, .T. }, ; //X3_TITENG
	{ 'Codigo Transp. Redespacho'											, .T. }, ; //X3_DESCRIC
	{ 'Código Transp. Redespacho'											, .T. }, ; //X3_DESCSPA
	{ 'Redispatch Transp Code'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCpo("SA4")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '69'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VOLUME1'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Volume 1'															, .T. }, ; //X3_TITULO
	{ 'Volumen 1'															, .T. }, ; //X3_TITSPA
	{ 'Volume 1'															, .T. }, ; //X3_TITENG
	{ 'Qtde de Volumes tipo 1'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd de volúmenes tipo 1'												, .T. }, ; //X3_DESCSPA
	{ 'Qty of Volumes type 1'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '70'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VOLUME2'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Volume 2'															, .T. }, ; //X3_TITULO
	{ 'Volumen 2'															, .T. }, ; //X3_TITSPA
	{ 'Volume 2'															, .T. }, ; //X3_TITENG
	{ 'Qtde de Volumes tipo 2'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd de volúmenes tipo 2'												, .T. }, ; //X3_DESCSPA
	{ 'Qty of Volumes type 2'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '71'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VOLUME3'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Volume 3'															, .T. }, ; //X3_TITULO
	{ 'Volumen 3'															, .T. }, ; //X3_TITSPA
	{ 'Volume 3'															, .T. }, ; //X3_TITENG
	{ 'Qtde de Volumes tipo 3'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd de volúmenes tipo 3'												, .T. }, ; //X3_DESCSPA
	{ 'Qty of Volumes type 3'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '72'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VOLUME4'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Volume 4'															, .T. }, ; //X3_TITULO
	{ 'Volumen 4'															, .T. }, ; //X3_TITSPA
	{ 'Volume 4'															, .T. }, ; //X3_TITENG
	{ 'Qtde de Volumes tipo 4'												, .T. }, ; //X3_DESCRIC
	{ 'Ctd de volúmenes tipo 4'												, .T. }, ; //X3_DESCSPA
	{ 'Qty of Volumes type 4'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '73'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ESPECI1'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Especie 1'															, .T. }, ; //X3_TITULO
	{ 'Clase 1'																, .T. }, ; //X3_TITSPA
	{ 'Class 1'																, .T. }, ; //X3_TITENG
	{ 'Especie do Volume tipo 1'											, .T. }, ; //X3_DESCRIC
	{ 'Clase de volumen tipo 1'												, .T. }, ; //X3_DESCSPA
	{ 'Class of volume type 1'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '74'																	, .T. }, ; //X3_ORDEM
	{ 'C5_INCISS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'ISS Incluso'															, .T. }, ; //X3_TITULO
	{ 'Incl. ISS'															, .T. }, ; //X3_TITSPA
	{ 'ISS Included'														, .T. }, ; //X3_TITENG
	{ 'ISS incluso no Pre‡o'												, .T. }, ; //X3_DESCRIC
	{ 'ISS Incluido en Precio'												, .T. }, ; //X3_DESCSPA
	{ 'Price including ISS'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("SN")'														, .T. }, ; //X3_VLDUSER
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '75'																	, .T. }, ; //X3_ORDEM
	{ 'C5_LIBEROK'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Liber. Total'														, .T. }, ; //X3_TITULO
	{ 'Liber. Total'														, .T. }, ; //X3_TITSPA
	{ 'Total Releas'														, .T. }, ; //X3_TITENG
	{ 'Pedido Liberado Total'												, .T. }, ; //X3_DESCRIC
	{ 'Pedido Liberado Total'												, .T. }, ; //X3_DESCSPA
	{ 'Total Released Order'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(144) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'pertence("S ")'														, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '76'																	, .T. }, ; //X3_ORDEM
	{ 'C5_OK'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'OK'																	, .T. }, ; //X3_TITULO
	{ 'OK'																	, .T. }, ; //X3_TITSPA
	{ 'OK'																	, .T. }, ; //X3_TITENG
	{ 'OK'																	, .T. }, ; //X3_DESCRIC
	{ 'OK'																	, .T. }, ; //X3_DESCSPA
	{ 'OK'																	, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '77'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NOTA'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nota Fiscal'															, .T. }, ; //X3_TITULO
	{ 'Factura'																, .T. }, ; //X3_TITSPA
	{ 'Invoice'																, .T. }, ; //X3_TITENG
	{ 'Numero da Nota Fiscal'												, .T. }, ; //X3_DESCRIC
	{ 'Número de la factura'												, .T. }, ; //X3_DESCSPA
	{ 'Invoice Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '78'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SERIE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Serie'																, .T. }, ; //X3_TITULO
	{ 'Serie'																, .T. }, ; //X3_TITSPA
	{ 'Series'																, .T. }, ; //X3_TITENG
	{ 'Serie da Nota Fiscal'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de la factura'													, .T. }, ; //X3_DESCSPA
	{ 'Invoice Series'														, .T. }, ; //X3_DESCENG
	{ '!!!'																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '79'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ESPECI2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Especie 2'															, .T. }, ; //X3_TITULO
	{ 'Clase 2'																, .T. }, ; //X3_TITSPA
	{ 'Class 2'																, .T. }, ; //X3_TITENG
	{ 'Especie do Volume tipo 2'											, .T. }, ; //X3_DESCRIC
	{ 'Clase del volumen tipo 2'											, .T. }, ; //X3_DESCSPA
	{ 'Class of Volume type 2'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '80'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ESPECI3'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Especie 3'															, .T. }, ; //X3_TITULO
	{ 'Clase 3'																, .T. }, ; //X3_TITSPA
	{ 'Class 3'																, .T. }, ; //X3_TITENG
	{ 'Especie do Volume tipo 3'											, .T. }, ; //X3_DESCRIC
	{ 'Clase de volumen tipo 3'												, .T. }, ; //X3_DESCSPA
	{ 'Class of Volume type 3'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '81'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ESPECI4'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Especie 4'															, .T. }, ; //X3_TITULO
	{ 'Clase 4'																, .T. }, ; //X3_TITSPA
	{ 'Class 4'																, .T. }, ; //X3_TITENG
	{ 'Especie do Volume tipo 4'											, .T. }, ; //X3_DESCRIC
	{ 'Clase de volumen tipo 4'												, .T. }, ; //X3_DESCSPA
	{ 'Class of Volume type 4'												, .T. }, ; //X3_DESCENG
	{ '@X'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '82'																	, .T. }, ; //X3_ORDEM
	{ 'C5_OS'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Gerado p/ OS'														, .T. }, ; //X3_TITULO
	{ 'Gener p/ OS'															, .T. }, ; //X3_TITSPA
	{ 'Gener for SO'														, .T. }, ; //X3_TITENG
	{ 'Numero da OS geradora'												, .T. }, ; //X3_DESCRIC
	{ 'Número de la OS generador'											, .T. }, ; //X3_DESCSPA
	{ 'Gener SO Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(137) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '83'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ACRSFIN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Acr. Financ'															, .T. }, ; //X3_TITULO
	{ 'Aumto.Financ'														, .T. }, ; //X3_TITSPA
	{ 'Fin.Increase'														, .T. }, ; //X3_TITENG
	{ 'Acrescimo Financeiro'												, .T. }, ; //X3_DESCRIC
	{ 'Aumento Financiero'													, .T. }, ; //X3_DESCSPA
	{ 'Financial Increase'													, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo() .or. vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '84'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MENNOTA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 200																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mens.p/ Nota'														, .T. }, ; //X3_TITULO
	{ 'Mens.p.Fact.'														, .T. }, ; //X3_TITSPA
	{ 'NF Message'															, .T. }, ; //X3_TITENG
	{ 'Mensagem para Nota Fiscal'											, .T. }, ; //X3_DESCRIC
	{ 'Mensaje para la Factura'												, .T. }, ; //X3_DESCSPA
	{ 'Message for Invoice'													, .T. }, ; //X3_DESCENG
	{ '@S60'																, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.A410MenNo()'												, .T. }, ; //X3_VALID
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '85'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MENPAD'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mens. Padrao'														, .T. }, ; //X3_TITULO
	{ 'Mens. Estánd'														, .T. }, ; //X3_TITSPA
	{ 'Stand Msg'															, .T. }, ; //X3_TITENG
	{ 'Mensagem Padrao 1'													, .T. }, ; //X3_DESCRIC
	{ 'Mensaje estándar 1'													, .T. }, ; //X3_DESCSPA
	{ 'Standard Message 1'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCpo("SM4")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SM4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '86'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ESTPRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'UF Prestacao'														, .T. }, ; //X3_TITULO
	{ 'UF. Prest.'															, .T. }, ; //X3_TITSPA
	{ 'Prov FU'																, .T. }, ; //X3_TITENG
	{ 'UF Prestacao'														, .T. }, ; //X3_DESCRIC
	{ 'UF Prestación'														, .T. }, ; //X3_DESCSPA
	{ 'Provider FU'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .or. ExistCpo("SX5","12"+M->C5_ESTPRES)'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '12'																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
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
	{ '010'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '87'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TXMOEDA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 11																	, .T. }, ; //X3_TAMANHO
	{ 4																		, .T. }, ; //X3_DECIMAL
	{ 'Taxa Moeda'															, .T. }, ; //X3_TITULO
	{ 'Tasa Moneda'															, .T. }, ; //X3_TITSPA
	{ 'Curr Rate'															, .T. }, ; //X3_TITENG
	{ 'Taxa da Moeda'														, .T. }, ; //X3_DESCRIC
	{ 'Tasa de la moneda'													, .T. }, ; //X3_DESCSPA
	{ 'Currency Rate'														, .T. }, ; //X3_DESCENG
	{ '@E 999999.9999'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '1'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '88'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VENDA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Venda'															, .T. }, ; //X3_TITULO
	{ 'Tipo Venta'															, .T. }, ; //X3_TITSPA
	{ 'Sales Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo da Venda'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Venta'														, .T. }, ; //X3_DESCSPA
	{ 'Type of Sale'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(137) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(131) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '89'																	, .T. }, ; //X3_ORDEM
	{ 'C5_KITREP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Kit Reparo'															, .T. }, ; //X3_TITULO
	{ 'Kit Reparo'															, .T. }, ; //X3_TITSPA
	{ 'Repair Kit'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Kit de Reparo'												, .T. }, ; //X3_DESCRIC
	{ 'Código del Kit de Reparo'											, .T. }, ; //X3_DESCSPA
	{ 'Repair Part Kit Code'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A410KitRep(M->C5_KITREP)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SO4'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '90'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TIPLIB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tp Libera‡„o'														, .T. }, ; //X3_TITULO
	{ 'Tp Liberac.'															, .T. }, ; //X3_TITSPA
	{ 'Releas Tp'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Libera‡„o'													, .T. }, ; //X3_DESCRIC
	{ 'Tipo de liberación'													, .T. }, ; //X3_DESCSPA
	{ 'Release Type'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Libera por Item;2=Libera por Pedido'								, .T. }, ; //X3_CBOX
	{ '1=Libera por ítem;2=Libera por pedido'								, .T. }, ; //X3_CBOXSPA
	{ '1=Released per Item;2=Released per Order'							, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '91'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMARCA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Marca'																, .T. }, ; //X3_TITULO
	{ 'Marca'																, .T. }, ; //X3_TITSPA
	{ 'Marca'																, .T. }, ; //X3_TITENG
	{ 'Marca'																, .T. }, ; //X3_DESCRIC
	{ 'Marca'																, .T. }, ; //X3_DESCSPA
	{ 'Marca'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '92'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNUMERO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Numero'																, .T. }, ; //X3_TITULO
	{ 'Numero'																, .T. }, ; //X3_TITSPA
	{ 'Numero'																, .T. }, ; //X3_TITENG
	{ 'Numero'																, .T. }, ; //X3_DESCRIC
	{ 'Numero'																, .T. }, ; //X3_DESCSPA
	{ 'Numero'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '93'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESCONT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Indenizacao'															, .T. }, ; //X3_TITULO
	{ 'Indemnizac.'															, .T. }, ; //X3_TITSPA
	{ 'Compensation'														, .T. }, ; //X3_TITENG
	{ 'Desconto de Indenizacao'												, .T. }, ; //X3_DESCRIC
	{ 'Descuento de indemnizac.'											, .T. }, ; //X3_DESCSPA
	{ 'Compens Discount'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(154) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '94'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PEDEXP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Proc.Export.'														, .T. }, ; //X3_TITULO
	{ 'Proc.Export.'														, .T. }, ; //X3_TITSPA
	{ 'Export Proc'															, .T. }, ; //X3_TITENG
	{ 'Processo de Exportacao'												, .T. }, ; //X3_DESCRIC
	{ 'Proceso de exportación'												, .T. }, ; //X3_DESCSPA
	{ 'Export Process'														, .T. }, ; //X3_DESCENG
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '95'																	, .T. }, ; //X3_ORDEM
	{ 'C5_USERLGI'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '96'																	, .T. }, ; //X3_ORDEM
	{ 'C5_USERLGA'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '97'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YAAPROV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Aprovador'															, .T. }, ; //X3_TITULO
	{ 'Aprovador'															, .T. }, ; //X3_TITSPA
	{ 'Aprovador'															, .T. }, ; //X3_TITENG
	{ 'Aprovador'															, .T. }, ; //X3_DESCRIC
	{ 'Aprovador'															, .T. }, ; //X3_DESCSPA
	{ 'Aprovador'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '98'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YAPROV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Aprovado'															, .T. }, ; //X3_TITULO
	{ 'Aprovado'															, .T. }, ; //X3_TITSPA
	{ 'Aprovado'															, .T. }, ; //X3_TITENG
	{ 'Aprovado'															, .T. }, ; //X3_DESCRIC
	{ 'Aprovado'															, .T. }, ; //X3_DESCSPA
	{ 'Aprovado'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ '99'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDIGP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Digitado por'														, .T. }, ; //X3_TITULO
	{ 'Digitado por'														, .T. }, ; //X3_TITSPA
	{ 'Digitado por'														, .T. }, ; //X3_TITENG
	{ 'Digitado por'														, .T. }, ; //X3_DESCRIC
	{ 'Digitado por'														, .T. }, ; //X3_DESCSPA
	{ 'Digitado por'														, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YALTP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Alterado por'														, .T. }, ; //X3_TITULO
	{ 'Alterado por'														, .T. }, ; //X3_TITSPA
	{ 'Alterado por'														, .T. }, ; //X3_TITENG
	{ 'Alterado por'														, .T. }, ; //X3_DESCRIC
	{ 'Alterado por'														, .T. }, ; //X3_DESCSPA
	{ 'Alterado por'														, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YOBS'																, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Observacao'															, .T. }, ; //X3_TITULO
	{ 'Observacao'															, .T. }, ; //X3_TITSPA
	{ 'Observacao'															, .T. }, ; //X3_TITENG
	{ 'Observacao'															, .T. }, ; //X3_DESCRIC
	{ 'Observacao'															, .T. }, ; //X3_DESCSPA
	{ 'Observacao'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TPCARGA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Carga'																, .T. }, ; //X3_TITULO
	{ 'Carga'																, .T. }, ; //X3_TITSPA
	{ 'Load'																, .T. }, ; //X3_TITENG
	{ 'Carga'																, .T. }, ; //X3_DESCRIC
	{ 'Carga'																, .T. }, ; //X3_DESCSPA
	{ 'Load'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Pertence('12')"														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ "'2'"																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Utiliza;2=Nao utiliza'												, .T. }, ; //X3_CBOX
	{ '1=Utiliza;2=No utiliza'												, .T. }, ; //X3_CBOXSPA
	{ '1=Use;2=Not use'														, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PREPEMB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Status Embar'														, .T. }, ; //X3_TITULO
	{ 'Estatus Emba'														, .T. }, ; //X3_TITSPA
	{ 'Shipm status'														, .T. }, ; //X3_TITENG
	{ 'Status do embarque'													, .T. }, ; //X3_DESCRIC
	{ 'Estatus del embarque'												, .T. }, ; //X3_DESCSPA
	{ 'Shipment status'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '0=Nao;1=Sim'															, .T. }, ; //X3_CBOX
	{ '0=No;1=Si'															, .T. }, ; //X3_CBOXSPA
	{ '0=No;1=Yes'															, .T. }, ; //X3_CBOXENG
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
	{ 'N'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CLIENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cli.Entrega'															, .T. }, ; //X3_TITULO
	{ 'Cli.Entrega'															, .T. }, ; //X3_TITSPA
	{ 'Cus.Delivery'														, .T. }, ; //X3_TITENG
	{ 'Cliente da Entrega'													, .T. }, ; //X3_DESCRIC
	{ 'Cliente de la entrega'												, .T. }, ; //X3_DESCSPA
	{ 'Customer Delivery'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. (A410Cli().And.A410ReCalc())'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(130) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'IIF(M->C5_TIPO$"DB",.F.,.T.)'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PDESCAB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '%Indenizacao'														, .T. }, ; //X3_TITULO
	{ '%Indemnizac.'														, .T. }, ; //X3_TITSPA
	{ '%Compensatio'														, .T. }, ; //X3_TITENG
	{ 'Percentual de indenizacao'											, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje de indenizació'											, .T. }, ; //X3_DESCSPA
	{ 'Compensation percentage'												, .T. }, ; //X3_DESCENG
	{ '@e 99.99'															, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YFLAG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Opcao Ender.'														, .T. }, ; //X3_TITULO
	{ 'Opcao Ender.'														, .T. }, ; //X3_TITSPA
	{ 'Opcao Ender.'														, .T. }, ; //X3_TITENG
	{ 'Opcao Ender.'														, .T. }, ; //X3_DESCRIC
	{ 'Opcao Ender.'														, .T. }, ; //X3_DESCSPA
	{ 'Opcao Ender.'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
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
	{ '1=Endereco 1;2=Endereco 2'											, .T. }, ; //X3_CBOX
	{ '1=Endereco 1;2=Endereco 2'											, .T. }, ; //X3_CBOXSPA
	{ '1=Endereco 1;2=Endereco 2'											, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YEND'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Endereco'															, .T. }, ; //X3_TITULO
	{ 'Endereco'															, .T. }, ; //X3_TITSPA
	{ 'Endereco'															, .T. }, ; //X3_TITENG
	{ 'Endereco'															, .T. }, ; //X3_DESCRIC
	{ 'Endereco'															, .T. }, ; //X3_DESCSPA
	{ 'Endereco'															, .T. }, ; //X3_DESCENG
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
	{ 'texto()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'M->C5_YFLAG=="2"'													, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YEST'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'UF'																	, .T. }, ; //X3_TITULO
	{ 'UF'																	, .T. }, ; //X3_TITSPA
	{ 'UF'																	, .T. }, ; //X3_TITENG
	{ 'UF'																	, .T. }, ; //X3_DESCRIC
	{ 'UF'																	, .T. }, ; //X3_DESCSPA
	{ 'UF'																	, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '12'																	, .T. }, ; //X3_F3
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'A9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCODMUN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Munic.'															, .T. }, ; //X3_TITULO
	{ 'Cod. Munic.'															, .T. }, ; //X3_TITSPA
	{ 'Cod. Munic.'															, .T. }, ; //X3_TITENG
	{ 'Codigo Municipio'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo Municipio'													, .T. }, ; //X3_DESCSPA
	{ 'Codigo Municipio'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CC2END'																, .T. }, ; //X3_F3
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
	{ 'M->C5_YFLAG=="2"'													, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMUN'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 36																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Municipio'															, .T. }, ; //X3_TITULO
	{ 'Municipio'															, .T. }, ; //X3_TITSPA
	{ 'Municipio'															, .T. }, ; //X3_TITENG
	{ 'Municipio'															, .T. }, ; //X3_DESCRIC
	{ 'Municipio'															, .T. }, ; //X3_DESCSPA
	{ 'Municipio'															, .T. }, ; //X3_DESCENG
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
	{ 'UPPER()'																, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YBAIRRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro'																, .T. }, ; //X3_TITULO
	{ 'Bairro'																, .T. }, ; //X3_TITSPA
	{ 'Bairro'																, .T. }, ; //X3_TITENG
	{ 'Bairro'																, .T. }, ; //X3_DESCRIC
	{ 'Bairro'																, .T. }, ; //X3_DESCSPA
	{ 'Bairro'																, .T. }, ; //X3_DESCENG
	{ '@S15'																, .T. }, ; //X3_PICTURE
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
	{ 'UPPER()'																, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'M->C5_YFLAG=="2"'													, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCEP'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'CEP'																	, .T. }, ; //X3_TITULO
	{ 'CEP'																	, .T. }, ; //X3_TITSPA
	{ 'CEP'																	, .T. }, ; //X3_TITENG
	{ 'CEP'																	, .T. }, ; //X3_DESCRIC
	{ 'CEP'																	, .T. }, ; //X3_DESCSPA
	{ 'CEP'																	, .T. }, ; //X3_DESCENG
	{ '@R 99999-999'														, .T. }, ; //X3_PICTURE
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
	{ 'naovazio()'															, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'M->C5_YFLAG=="2"'													, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YTEL'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Telefone'															, .T. }, ; //X3_TITULO
	{ 'Telefone'															, .T. }, ; //X3_TITSPA
	{ 'Telefone'															, .T. }, ; //X3_TITENG
	{ 'Telefone'															, .T. }, ; //X3_DESCRIC
	{ 'Telefone'															, .T. }, ; //X3_DESCSPA
	{ 'Telefone'															, .T. }, ; //X3_DESCENG
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
	{ 'M->C5_YFLAG=="2"'													, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YFATOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 5																		, .T. }, ; //X3_DECIMAL
	{ 'Fator'																, .T. }, ; //X3_TITULO
	{ 'Fator'																, .T. }, ; //X3_TITSPA
	{ 'Fator'																, .T. }, ; //X3_TITENG
	{ 'Fator'																, .T. }, ; //X3_DESCRIC
	{ 'Fator'																, .T. }, ; //X3_DESCSPA
	{ 'Fator'																, .T. }, ; //X3_DESCENG
	{ '@E 9999.99999'														, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDESCLI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITULO
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITSPA
	{ 'Desc.Cliente'														, .T. }, ; //X3_TITENG
	{ 'Desconto Cliente'													, .T. }, ; //X3_DESCRIC
	{ 'Desconto Cliente'													, .T. }, ; //X3_DESCSPA
	{ 'Desconto Cliente'													, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999,999.99'												, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_RECISS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Recolhe ISS?'														, .T. }, ; //X3_TITULO
	{ '¿Paga ISS?'															, .T. }, ; //X3_TITSPA
	{ 'Collect ISS?'														, .T. }, ; //X3_TITENG
	{ 'Indica se houve recolhime'											, .T. }, ; //X3_DESCRIC
	{ '¿Paga ISS?'															, .T. }, ; //X3_DESCSPA
	{ 'Collect ISS?'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12") .And. MaFisGet("NF_RECISS")'							, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("12") .And. MaFisGet("NF_RECISS")'							, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_BLQ'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Blq. Regras'															, .T. }, ; //X3_TITULO
	{ 'Blq. Reglas'															, .T. }, ; //X3_TITSPA
	{ 'Rules Block'															, .T. }, ; //X3_TITENG
	{ 'Bloqueio de Regras'													, .T. }, ; //X3_DESCRIC
	{ 'Bloqueo de reglas'													, .T. }, ; //X3_DESCSPA
	{ 'Rules Block'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FORNISS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Forn.ISS'															, .T. }, ; //X3_TITULO
	{ 'Prov.ISS'															, .T. }, ; //X3_TITSPA
	{ 'ISS Supp'															, .T. }, ; //X3_TITENG
	{ 'Fornecedor de ISS'													, .T. }, ; //X3_DESCRIC
	{ 'Proveedor del ISS'													, .T. }, ; //X3_DESCSPA
	{ 'ISS Supplier'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SA2", M->C5_FORNISS)'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA2ISS'																, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ '001'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'B9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CONTRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Contrato'															, .T. }, ; //X3_TITULO
	{ 'Contrato'															, .T. }, ; //X3_TITSPA
	{ 'Contract'															, .T. }, ; //X3_TITENG
	{ 'Numero do contrato'													, .T. }, ; //X3_DESCRIC
	{ 'Número del contrato'													, .T. }, ; //X3_DESCSPA
	{ 'Contract Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VLR_FRT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Frete Pauta'															, .T. }, ; //X3_TITULO
	{ 'Flete Pauta'															, .T. }, ; //X3_TITSPA
	{ 'Freight Paut'														, .T. }, ; //X3_TITENG
	{ 'Valor do Frete de Pauta'												, .T. }, ; //X3_DESCRIC
	{ 'Valor del flete de pauta'											, .T. }, ; //X3_DESCSPA
	{ 'Freight Value de Pauta'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'Positivo() .Or. Vazio()'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Centro Custo'														, .T. }, ; //X3_TITULO
	{ 'Centro Custo'														, .T. }, ; //X3_TITSPA
	{ 'Centro Custo'														, .T. }, ; //X3_TITENG
	{ 'Centro Custo'														, .T. }, ; //X3_DESCRIC
	{ 'Centro Custo'														, .T. }, ; //X3_DESCSPA
	{ 'Centro Custo'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'vazio() .or. Ctb105CC()'												, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCLVL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod Cl Valor'														, .T. }, ; //X3_TITULO
	{ 'Cod Cl Valor'														, .T. }, ; //X3_TITSPA
	{ 'Cod Cl Valor'														, .T. }, ; //X3_TITENG
	{ 'Codigo Classe de Valor'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo Classe de Valor'												, .T. }, ; //X3_DESCSPA
	{ 'Codigo Classe de Valor'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTH'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'vazio().or. ( Ctb105ClVl() .and. ExecBlock("BIA555", .F., .F.) )'	, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YITEMCT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Item Contab.'														, .T. }, ; //X3_TITULO
	{ 'Item Contab.'														, .T. }, ; //X3_TITSPA
	{ 'Item Contab.'														, .T. }, ; //X3_TITENG
	{ 'Item Contabil'														, .T. }, ; //X3_DESCRIC
	{ 'Item Contabil'														, .T. }, ; //X3_DESCSPA
	{ 'Item Contabil'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTD001'																, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'vazio().or. Ctb105Item()'											, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCTRVER'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ctr. Verba'															, .T. }, ; //X3_TITULO
	{ 'Ctr. Verba'															, .T. }, ; //X3_TITSPA
	{ 'Ctr. Verba'															, .T. }, ; //X3_TITENG
	{ 'Contrato da Verba'													, .T. }, ; //X3_DESCRIC
	{ 'Contrato da Verba'													, .T. }, ; //X3_DESCSPA
	{ 'Contrato da Verba'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTVBF3'																, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'IIF(VAZIO(),.T.,EXISTCPO("ZA7"))'									, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNUMSI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'No.AI ref AO'														, .T. }, ; //X3_TITULO
	{ 'No.AI ref AO'														, .T. }, ; //X3_TITSPA
	{ 'No.AI ref AO'														, .T. }, ; //X3_TITENG
	{ 'Numero da AI ref. a  AO'												, .T. }, ; //X3_DESCRIC
	{ 'Numero da AI ref. a  AO'												, .T. }, ; //X3_DESCSPA
	{ 'Numero da AI ref. a  AO'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'U_AO_VALID(M->C5_YNUMSI)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SZOSC5'																, .T. }, ; //X3_F3
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNOUTAI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'No.AI Outras'														, .T. }, ; //X3_TITULO
	{ 'No.AI Outras'														, .T. }, ; //X3_TITSPA
	{ 'No.AI Outras'														, .T. }, ; //X3_TITENG
	{ 'Numero da AI outras'													, .T. }, ; //X3_DESCRIC
	{ 'Numero da AI outras'													, .T. }, ; //X3_DESCSPA
	{ 'Numero da AI outras'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'U_AO_VALID(M->C5_YNOUTAI)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SZOSC5'																, .T. }, ; //X3_F3
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YTPBLQ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tp. Bloqueio'														, .T. }, ; //X3_TITULO
	{ 'Tp. Bloqueio'														, .T. }, ; //X3_TITSPA
	{ 'Tp. Bloqueio'														, .T. }, ; //X3_TITENG
	{ 'Tipo de Bloqueio'													, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Bloqueio'													, .T. }, ; //X3_DESCSPA
	{ 'Tipo de Bloqueio'													, .T. }, ; //X3_DESCENG
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
	{ '0=Nenhum;1=Pol. Desc.;2=Desc. Incondic.;3=Increm. Venc.;5=Tipo Pedido;6=Pol. Margem;7=Tipo Prod.;8=Cond.Pag.Tipo 9;9=Liber. Aut.', .T. }, ; //X3_CBOX
	{ '0=Nenhum;1=Pol. Desc.;2=Desc. Incondic.;3=Increm. Venc.;5=Tipo Pedido;6=Pol. Margem;7=Tipo Prod.;8=Cond.Pag.Tipo 9;9=Liber. Aut.', .T. }, ; //X3_CBOXSPA
	{ '0=Nenhum;1=Pol. Desc.;2=Desc. Incondic.;3=Increm. Venc.;5=Tipo Pedido;6=Pol. Margem;7=Tipo Prod.;8=Cond.Pag.Tipo 9;9=Liber. Aut.', .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPEDPAI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Pedido PAI'															, .T. }, ; //X3_TITULO
	{ 'Pedido PAI'															, .T. }, ; //X3_TITSPA
	{ 'Pedido PAI'															, .T. }, ; //X3_TITENG
	{ 'Pedido PAI'															, .T. }, ; //X3_DESCRIC
	{ 'Pedido PAI'															, .T. }, ; //X3_DESCSPA
	{ 'Pedido PAI'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'C9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMEDDES'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Media Desc.'															, .T. }, ; //X3_TITULO
	{ 'Media Desc.'															, .T. }, ; //X3_TITSPA
	{ 'Media Desc.'															, .T. }, ; //X3_TITENG
	{ 'Média Desconto Ponderada'											, .T. }, ; //X3_DESCRIC
	{ 'Média Desconto Ponderada'											, .T. }, ; //X3_DESCSPA
	{ 'Média Desconto Ponderada'											, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMDESPD'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Md. Desc. Pd'														, .T. }, ; //X3_TITULO
	{ 'Md. Desc. Pd'														, .T. }, ; //X3_TITSPA
	{ 'Md. Desc. Pd'														, .T. }, ; //X3_TITENG
	{ 'Média Desconto Padrão'												, .T. }, ; //X3_DESCRIC
	{ 'Média Desconto Padrão'												, .T. }, ; //X3_DESCSPA
	{ 'Média Desconto Padrão'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YEMP'																, .T. }, ; //X3_CAMPO
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
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YEMPPED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Empresa Ped.'														, .T. }, ; //X3_TITULO
	{ 'Empresa Ped.'														, .T. }, ; //X3_TITSPA
	{ 'Empresa Ped.'														, .T. }, ; //X3_TITENG
	{ 'Empresa do Pedido Origem'											, .T. }, ; //X3_DESCRIC
	{ 'Empresa do Pedido Origem'											, .T. }, ; //X3_DESCSPA
	{ 'Empresa do Pedido Origem'											, .T. }, ; //X3_DESCENG
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
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '01=Biancogres;05=Incesa;13=Mundi'									, .T. }, ; //X3_CBOX
	{ '01=Biancogres;05=Incesa;13=Mundi'									, .T. }, ; //X3_CBOXSPA
	{ '01=Biancogres;05=Incesa;13=Mundi'									, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ORCRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Orcam.'															, .T. }, ; //X3_TITULO
	{ 'Nº Presup.'															, .T. }, ; //X3_TITSPA
	{ 'Budget No'															, .T. }, ; //X3_TITENG
	{ 'Numero do Orcamento'													, .T. }, ; //X3_DESCRIC
	{ 'Número del presupuesto'												, .T. }, ; //X3_DESCSPA
	{ 'Budget number'														, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPEDORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Pedido Orig.'														, .T. }, ; //X3_TITULO
	{ 'Pedido Orig.'														, .T. }, ; //X3_TITSPA
	{ 'Pedido Orig.'														, .T. }, ; //X3_TITENG
	{ 'Pedido Origem'														, .T. }, ; //X3_DESCRIC
	{ 'Pedido Origem'														, .T. }, ; //X3_DESCSPA
	{ 'Pedido Origem'														, .T. }, ; //X3_DESCENG
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
	{ 'S'																	, .T. }, ; //X3_BROWSE
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCLIORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cliente Orig'														, .T. }, ; //X3_TITULO
	{ 'Cliente Orig'														, .T. }, ; //X3_TITSPA
	{ 'Cliente Orig'														, .T. }, ; //X3_TITENG
	{ 'Cliente Original'													, .T. }, ; //X3_DESCRIC
	{ 'Cliente Original'													, .T. }, ; //X3_DESCSPA
	{ 'Cliente Original'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YLOJORI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lj.Cli. Orig'														, .T. }, ; //X3_TITULO
	{ 'Lj.Cli. Orig'														, .T. }, ; //X3_TITSPA
	{ 'Lj.Cli. Orig'														, .T. }, ; //X3_TITENG
	{ 'Loja Cliente Original'												, .T. }, ; //X3_DESCRIC
	{ 'Loja Cliente Original'												, .T. }, ; //X3_DESCSPA
	{ 'Loja Cliente Original'												, .T. }, ; //X3_DESCENG
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_RECFAUT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Pag.Fret.Aut'														, .T. }, ; //X3_TITULO
	{ 'Pag.Flet.Aut'														, .T. }, ; //X3_TITSPA
	{ 'Free Freight'														, .T. }, ; //X3_TITENG
	{ 'Pagto do frete autonomo'												, .T. }, ; //X3_DESCRIC
	{ 'Pago del flete autónomo'												, .T. }, ; //X3_DESCSPA
	{ 'Pagto do Indep Freight'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12") .And. MaFisGet("NF_RECFAUT")'							, .T. }, ; //X3_VALID
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
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("12") .And. MaFisGet("NF_RECFAUT")'							, .T. }, ; //X3_VLDUSER
	{ '1=Emitente;2=Transportador'											, .T. }, ; //X3_CBOX
	{ '1=Emisor;2=Transportador'											, .T. }, ; //X3_CBOXSPA
	{ '1=Issuer;2=Carrier'													, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YTPTRAN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Carga'															, .T. }, ; //X3_TITULO
	{ 'Tipo Carga'															, .T. }, ; //X3_TITSPA
	{ 'Tipo Carga'															, .T. }, ; //X3_TITENG
	{ 'Tipo Carga'															, .T. }, ; //X3_DESCRIC
	{ 'Tipo Carga'															, .T. }, ; //X3_DESCSPA
	{ 'Tipo Carga'															, .T. }, ; //X3_DESCENG
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
	{ 'Pertence("1/2/3")'													, .T. }, ; //X3_VLDUSER
	{ '1=Transportadora;2=Autônomo;3=Cliente Retira'						, .T. }, ; //X3_CBOX
	{ '1=Transportadora;2=Autônomo;3=Cliente Retira'						, .T. }, ; //X3_CBOXSPA
	{ '1=Transportadora;2=Autônomo;3=Cliente Retira'						, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'D9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MDCONTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Contrato'														, .T. }, ; //X3_TITULO
	{ 'Núm.Contrat'															, .T. }, ; //X3_TITSPA
	{ 'Contract No'															, .T. }, ; //X3_TITENG
	{ 'Numero do Contrato'													, .T. }, ; //X3_DESCRIC
	{ 'Número del contrato'													, .T. }, ; //X3_DESCSPA
	{ 'Contract Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_GERAWMS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Gera OS.WMS'															, .T. }, ; //X3_TITULO
	{ 'Gener OS.WMS'														, .T. }, ; //X3_TITSPA
	{ 'Gen SO.WMS'															, .T. }, ; //X3_TITENG
	{ 'Gera O.S./WMS'														, .T. }, ; //X3_DESCRIC
	{ 'Genera O.S./WMS'														, .T. }, ; //X3_DESCSPA
	{ 'Gen SO/WMS'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("123")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
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
	{ '1=No pedido;2=Na Montagem da Carga;3=Na Unitização da Carga'			, .T. }, ; //X3_CBOX
	{ '1=En el pedido;2=En el montaje de la carga;3=En el uso de la carga'		, .T. }, ; //X3_CBOXSPA
	{ '1=In the order;2=In the assemblage of load;3=In Unitization of Load'		, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MDNUMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Medicao'															, .T. }, ; //X3_TITULO
	{ 'Nº Medición'															, .T. }, ; //X3_TITSPA
	{ 'Measure No'															, .T. }, ; //X3_TITENG
	{ 'Numero da Medicao'													, .T. }, ; //X3_DESCRIC
	{ 'Número de la medición'												, .T. }, ; //X3_DESCSPA
	{ 'Measure Number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MDPLANI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num.Planilha'														, .T. }, ; //X3_TITULO
	{ 'Núm.Planilla'														, .T. }, ; //X3_TITSPA
	{ 'Spreadsh No'															, .T. }, ; //X3_TITENG
	{ 'Numero da Planilha'													, .T. }, ; //X3_DESCRIC
	{ 'Número de la planilla'												, .T. }, ; //X3_DESCSPA
	{ 'Spreadsheet Number'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MUNPRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mun.Prest.'															, .T. }, ; //X3_TITULO
	{ 'Mun.Prest.'															, .T. }, ; //X3_TITSPA
	{ 'Prov city'															, .T. }, ; //X3_TITENG
	{ 'Mun.Prest.'															, .T. }, ; //X3_DESCRIC
	{ 'Municipio de prestación'												, .T. }, ; //X3_DESCSPA
	{ 'City of provision'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CC2SC5'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DESCMUN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Desc.Mun.'															, .T. }, ; //X3_TITULO
	{ 'Desc.Mun.'															, .T. }, ; //X3_TITSPA
	{ 'City desc'															, .T. }, ; //X3_TITENG
	{ 'Descricão Mun.Prest.'												, .T. }, ; //X3_DESCRIC
	{ 'Descripción Mun.Prest.'												, .T. }, ; //X3_DESCSPA
	{ 'Pres city descript'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPGTO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Forma Pgto'															, .T. }, ; //X3_TITULO
	{ 'Forma Pgto'															, .T. }, ; //X3_TITSPA
	{ 'Forma Pgto'															, .T. }, ; //X3_TITENG
	{ 'Forma de pagamento'													, .T. }, ; //X3_DESCRIC
	{ 'Forma de pagamento'													, .T. }, ; //X3_DESCSPA
	{ 'Forma de pagamento'													, .T. }, ; //X3_DESCENG
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
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NFSUBST'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nf Subst.'															, .T. }, ; //X3_TITULO
	{ 'Fct Sustitui'														, .T. }, ; //X3_TITSPA
	{ 'Repl inv'															, .T. }, ; //X3_TITENG
	{ 'NF Substituída'														, .T. }, ; //X3_DESCRIC
	{ 'Factura sustituida'													, .T. }, ; //X3_DESCSPA
	{ 'Replaced invoice'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SERSUBS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Serie Subst.'														, .T. }, ; //X3_TITULO
	{ 'Serie Sust.'															, .T. }, ; //X3_TITSPA
	{ 'Subst Ser'															, .T. }, ; //X3_TITENG
	{ 'Série da Nf Substituída'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de Fact sustituida'											, .T. }, ; //X3_DESCSPA
	{ 'Substit Invoice Series'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SOLFRE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sol. Frete'															, .T. }, ; //X3_TITULO
	{ 'Sol. Flete'															, .T. }, ; //X3_TITSPA
	{ 'Sol. Freight'														, .T. }, ; //X3_TITENG
	{ 'Solicitação de Frete'												, .T. }, ; //X3_DESCRIC
	{ 'Solicitud de flete'													, .T. }, ; //X3_DESCSPA
	{ 'Freight Request'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'E9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YTIPOCO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cond. Transp'														, .T. }, ; //X3_TITULO
	{ 'Cond. Transp'														, .T. }, ; //X3_TITSPA
	{ 'Cond. Transp'														, .T. }, ; //X3_TITENG
	{ 'Condição de transporte'												, .T. }, ; //X3_DESCRIC
	{ 'Condição de transporte'												, .T. }, ; //X3_DESCSPA
	{ 'Condição de transporte'												, .T. }, ; //X3_DESCENG
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
	{ '1=Com descarga;2=Sem descarga'										, .T. }, ; //X3_CBOX
	{ '1=Com descarga;2=Sem descarga'										, .T. }, ; //X3_CBOXSPA
	{ '1=Com descarga;2=Sem descarga'										, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVENDRC'															, .T. }, ; //X3_CAMPO
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
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLCREC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITULO
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITSPA
	{ 'Vl.Com.Rec.'															, .T. }, ; //X3_TITENG
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCRIC
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCSPA
	{ 'Valor Comissão Rescisão'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPCREC'															, .T. }, ; //X3_CAMPO
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
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YENVIO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Envio WF?'															, .T. }, ; //X3_TITULO
	{ 'Envio WF?'															, .T. }, ; //X3_TITSPA
	{ 'Envio WF?'															, .T. }, ; //X3_TITENG
	{ 'Envio WF?'															, .T. }, ; //X3_DESCRIC
	{ 'Envio WF?'															, .T. }, ; //X3_DESCSPA
	{ 'Envio WF?'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
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
	{ 'PERTENCE("S/N")'														, .T. }, ; //X3_VLDUSER
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DTLANC'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Contab.'															, .T. }, ; //X3_TITULO
	{ 'Fch Contab.'															, .T. }, ; //X3_TITSPA
	{ 'Acc Dt'																, .T. }, ; //X3_TITENG
	{ 'Data de Contabilizacao'												, .T. }, ; //X3_DESCRIC
	{ 'Fecha de contabilización'											, .T. }, ; //X3_DESCSPA
	{ 'Accounting Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TXREF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Taxa Cambial'														, .T. }, ; //X3_TITULO
	{ 'Tasa Cambio'															, .T. }, ; //X3_TITSPA
	{ 'Exchange Rat'														, .T. }, ; //X3_TITENG
	{ 'Taxa Cambial'														, .T. }, ; //X3_DESCRIC
	{ 'Tasa de cambio'														, .T. }, ; //X3_DESCSPA
	{ 'Exchange rate'														, .T. }, ; //X3_DESCENG
	{ '@E 99.99'															, .T. }, ; //X3_PICTURE
	{ 'positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(156) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DTTXREF'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.R.Cambial'														, .T. }, ; //X3_TITULO
	{ 'Fch R. Cambi'														, .T. }, ; //X3_TITSPA
	{ 'Exch ref dt'															, .T. }, ; //X3_TITENG
	{ 'Data Referencia Cambial'												, .T. }, ; //X3_DESCRIC
	{ 'Fecha referencia cambiio'											, .T. }, ; //X3_DESCSPA
	{ 'Exchange reference date'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VEICULO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Veic. Transp'														, .T. }, ; //X3_TITULO
	{ 'Vehíc. Trans'														, .T. }, ; //X3_TITSPA
	{ 'Transp vehic'														, .T. }, ; //X3_TITENG
	{ 'Veiculo do Transporte'												, .T. }, ; //X3_DESCRIC
	{ 'Vehículo de transporte'												, .T. }, ; //X3_DESCSPA
	{ 'Transport vehicle'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCPO("DA3")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DA3'																	, .T. }, ; //X3_F3
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTOTP'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vlr.Tot.Ped.'														, .T. }, ; //X3_TITULO
	{ 'Vlr.Tot.Ped.'														, .T. }, ; //X3_TITSPA
	{ 'Vlr.Tot.Ped.'														, .T. }, ; //X3_TITENG
	{ 'Vlr. Total Pedido c/ Imp.'											, .T. }, ; //X3_DESCRIC
	{ 'Vlr. Total Pedido c/ Imp.'											, .T. }, ; //X3_DESCSPA
	{ 'Vlr. Total Pedido c/ Imp.'											, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'F9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTIPI'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTST'															, .T. }, ; //X3_CAMPO
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTPIS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. PIS'														, .T. }, ; //X3_TITENG
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCRIC
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCSPA
	{ 'Valor Total PIS'														, .T. }, ; //X3_DESCENG
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTCOF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tol. COF'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tol. COF'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tol. COF'														, .T. }, ; //X3_TITENG
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCRIC
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCSPA
	{ 'Valor Total COFINS'													, .T. }, ; //X3_DESCENG
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLTICM'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITULO
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITSPA
	{ 'Vl. Tot. ICM'														, .T. }, ; //X3_TITENG
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCRIC
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCSPA
	{ 'Valor Total ICMS'													, .T. }, ; //X3_DESCENG
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YSI'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cliente AI'															, .T. }, ; //X3_TITULO
	{ 'Cliente AI'															, .T. }, ; //X3_TITSPA
	{ 'Cliente AI'															, .T. }, ; //X3_TITENG
	{ 'Cliente AI'															, .T. }, ; //X3_DESCRIC
	{ 'Cliente AI'															, .T. }, ; //X3_DESCSPA
	{ 'Cliente AI'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA1")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1SI'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'EXISTCPO("SA1")'														, .T. }, ; //X3_VLDUSER
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPERCMC'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDESCZF'															, .T. }, ; //X3_CAMPO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YRESULT'															, .T. }, ; //X3_CAMPO
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
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YAPRTMP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Aprov. Temp.'														, .T. }, ; //X3_TITULO
	{ 'Aprov. Temp.'														, .T. }, ; //X3_TITSPA
	{ 'Aprov. Temp.'														, .T. }, ; //X3_TITENG
	{ 'Aprovador Temporário'												, .T. }, ; //X3_DESCRIC
	{ 'Aprovador Temporário'												, .T. }, ; //X3_DESCSPA
	{ 'Aprovador Temporário'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'G9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YRESUL2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Result Emp.2'														, .T. }, ; //X3_TITULO
	{ 'Result Emp.2'														, .T. }, ; //X3_TITSPA
	{ 'Result Emp.2'														, .T. }, ; //X3_TITENG
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCRIC
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCSPA
	{ 'Resultado Empresa 2'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FECENT'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Entrega'															, .T. }, ; //X3_TITULO
	{ 'Fch. Entrega'														, .T. }, ; //X3_TITSPA
	{ 'Delivery Dt'															, .T. }, ; //X3_TITENG
	{ 'Data de Entrega'														, .T. }, ; //X3_DESCRIC
	{ 'Fecha de entrega'													, .T. }, ; //X3_DESCSPA
	{ 'Delivery Date'														, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SOLOPC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Opc Cliente'															, .T. }, ; //X3_TITULO
	{ 'Opc Cliente'															, .T. }, ; //X3_TITSPA
	{ 'Cust Optiona'														, .T. }, ; //X3_TITENG
	{ 'Usa Opcionais do Cliente'											, .T. }, ; //X3_DESCRIC
	{ 'Usa Opcionales de cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Use Customer Optional'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
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
	{ '1=Nao;2=Sim'															, .T. }, ; //X3_CBOX
	{ '1=No;2=Si'															, .T. }, ; //X3_CBOXSPA
	{ '1=No;2=Yes'															, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SUGENT'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Sug. Ent'														, .T. }, ; //X3_TITULO
	{ 'Fch. Sug. En'														, .T. }, ; //X3_TITSPA
	{ 'Sugg Date'															, .T. }, ; //X3_TITENG
	{ 'Data sugerida de entrega'											, .T. }, ; //X3_DESCRIC
	{ 'Fecha sugerida de entrega'											, .T. }, ; //X3_DESCSPA
	{ 'Delivery suggested Date'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CODED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Edital'															, .T. }, ; //X3_TITULO
	{ 'Cód. Edital'															, .T. }, ; //X3_TITSPA
	{ 'Public Note'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Edital'													, .T. }, ; //X3_DESCRIC
	{ 'Código del edicto'													, .T. }, ; //X3_DESCSPA
	{ 'Public Note Code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_OBRA'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Obra'															, .T. }, ; //X3_TITULO
	{ 'Cód. Obra'															, .T. }, ; //X3_TITSPA
	{ 'Work code'															, .T. }, ; //X3_TITENG
	{ 'Codigo da Obra'														, .T. }, ; //X3_DESCRIC
	{ 'Código de la obra'													, .T. }, ; //X3_DESCSPA
	{ 'Work code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(148) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NUMPR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr. Processo'														, .T. }, ; //X3_TITULO
	{ 'Nr. Proceso'															, .T. }, ; //X3_TITSPA
	{ 'Process no.'															, .T. }, ; //X3_TITENG
	{ 'Numero Processo'														, .T. }, ; //X3_DESCRIC
	{ 'Número del proceso'													, .T. }, ; //X3_DESCSPA
	{ 'Process number'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 9																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ORIGEM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Origem'																, .T. }, ; //X3_TITULO
	{ 'Origen'																, .T. }, ; //X3_TITSPA
	{ 'Origin'																, .T. }, ; //X3_TITENG
	{ 'Empresa de Origem.'													, .T. }, ; //X3_DESCRIC
	{ 'Origen del pedido'													, .T. }, ; //X3_DESCSPA
	{ 'Order Origin'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YSEPARA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Separador'															, .T. }, ; //X3_TITULO
	{ 'Separador'															, .T. }, ; //X3_TITSPA
	{ 'Separador'															, .T. }, ; //X3_TITENG
	{ 'Separador'															, .T. }, ; //X3_DESCRIC
	{ 'Separador'															, .T. }, ; //X3_DESCSPA
	{ 'Separador'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMOTIVO'															, .T. }, ; //X3_CAMPO
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
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'H9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NATUREZ'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Natureza'															, .T. }, ; //X3_TITULO
	{ 'Modalidad'															, .T. }, ; //X3_TITSPA
	{ 'Nature'																, .T. }, ; //X3_TITENG
	{ 'Codigo da Nat Financeira'											, .T. }, ; //X3_DESCRIC
	{ 'Modalidad'															, .T. }, ; //X3_DESCSPA
	{ 'Nature'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'Existcpo("SED") .And. MafisGet("NF_NATUREZA")'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SED'																	, .T. }, ; //X3_F3
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
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MOEDTIT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Moeda Titulo'														, .T. }, ; //X3_TITULO
	{ 'Moneda Títul'														, .T. }, ; //X3_TITSPA
	{ 'Bill Currenc'														, .T. }, ; //X3_TITENG
	{ 'Moeda do titulo'														, .T. }, ; //X3_DESCRIC
	{ 'Moneda del título'													, .T. }, ; //X3_DESCSPA
	{ 'Bill currency'														, .T. }, ; //X3_DESCENG
	{ '99'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_KM'																, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dist.Entrega'														, .T. }, ; //X3_TITULO
	{ 'Dist.Entrega'														, .T. }, ; //X3_TITSPA
	{ 'Deliv Dist'															, .T. }, ; //X3_TITENG
	{ 'Distancia de Entrega'												, .T. }, ; //X3_DESCRIC
	{ 'Distancia de entrega'												, .T. }, ; //X3_DESCSPA
	{ 'Delivery Distance'													, .T. }, ; //X3_DESCENG
	{ '@E 9,999,999'														, .T. }, ; //X3_PICTURE
	{ 'Positivo() .And. a410FreteP()'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 5																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
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
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CNO'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod CNO'																, .T. }, ; //X3_TITULO
	{ 'Cód CNO'																, .T. }, ; //X3_TITSPA
	{ 'CNO code'															, .T. }, ; //X3_TITENG
	{ 'Codigo CNO'															, .T. }, ; //X3_DESCRIC
	{ 'Código CNO'															, .T. }, ; //X3_DESCSPA
	{ 'CNO code'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or.(ExistCpo('SON',M->C5_CNO ) .And. a410VldPMS())"			, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SON'																	, .T. }, ; //X3_F3
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NTEMPEN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 22																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nt Empenho'															, .T. }, ; //X3_TITULO
	{ 'Nt Reserva'															, .T. }, ; //X3_TITSPA
	{ 'Alloc bill'															, .T. }, ; //X3_TITENG
	{ 'Ident. Nota Empenho'													, .T. }, ; //X3_DESCRIC
	{ 'Ident. Nota Reserva'													, .T. }, ; //X3_DESCSPA
	{ 'Alloc bill ident'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TIPOBRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Obra'															, .T. }, ; //X3_TITULO
	{ 'Tipo Obra'															, .T. }, ; //X3_TITSPA
	{ 'Work Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo da Obra'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo de la obra'														, .T. }, ; //X3_DESCSPA
	{ 'Work Type'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'pertence("123")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Minha Casa Minha Vida;2=Regime Presumido;3=Regime Ordinário'		, .T. }, ; //X3_CBOX
	{ '1=Minha Casa Minha Vida;2=Regimen Presumido;3=Régimen Ordinario'		, .T. }, ; //X3_CBOXSPA
	{ '1=Minha Casa Minha Vida;2=Deemed System;3=Ordinary System'			, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_INDPRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Presenca Com'														, .T. }, ; //X3_TITULO
	{ 'Presenc Comp'														, .T. }, ; //X3_TITSPA
	{ 'Purchaser'															, .T. }, ; //X3_TITENG
	{ 'Presenca Comprador'													, .T. }, ; //X3_DESCRIC
	{ 'Presencia del comprador'												, .T. }, ; //X3_DESCSPA
	{ 'Purchaser Presence'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence(" 0/1/2/3/5/9")'											, .T. }, ; //X3_VALID
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
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '0=Não se Aplica;1=Op. presencial;2=Op. não presencial,Internet;3=Op. não presencial,Teleatendimento;9=Op. não presencial,outros', .T. }, ; //X3_CBOX
	{ '0=No se aplica;1=Op. presencial;2=Op. no presencial,Internet;3=Op. no presencial,Teleatensión;9=Op. no presencial,otros', .T. }, ; //X3_CBOXSPA
	{ '0=Not applicable;1=Op. presential;2=Op. not presential,Internet;3=Op. not presential,Phone service;9=Op. not presential,others', .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNUMOBR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Obra'															, .T. }, ; //X3_TITULO
	{ 'Num. Obra'															, .T. }, ; //X3_TITSPA
	{ 'Num. Obra'															, .T. }, ; //X3_TITENG
	{ 'Numero Obra'															, .T. }, ; //X3_DESCRIC
	{ 'Numero Obra'															, .T. }, ; //X3_DESCSPA
	{ 'Numero Obra'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ZZOSC5'																, .T. }, ; //X3_F3
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YNOMCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nome'																, .T. }, ; //X3_TITSPA
	{ 'Nome'																, .T. }, ; //X3_TITENG
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCRIC
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCSPA
	{ 'Nome do Cliente'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 5																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
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
	{ 'Posicione("SA1", 1, xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI), "A1_NOME")', .T. }, ; //X3_INIBRW
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YUSCONF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Conferente'															, .T. }, ; //X3_TITULO
	{ 'Conferente'															, .T. }, ; //X3_TITSPA
	{ 'Conferente'															, .T. }, ; //X3_TITENG
	{ 'Usuario Conferente'													, .T. }, ; //X3_DESCRIC
	{ 'Usuario Conferente'													, .T. }, ; //X3_DESCSPA
	{ 'Usuario Conferente'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'I9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC5'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 5'															, .T. }, ; //X3_TITULO
	{ 'Cuota 5'																, .T. }, ; //X3_TITSPA
	{ 'Installment5'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 5'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota 5'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment 5'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA5'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 5'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento5'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt5'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 5'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 5'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date5'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC6'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 6'															, .T. }, ; //X3_TITULO
	{ 'Cuota 6'																, .T. }, ; //X3_TITSPA
	{ 'Installment6'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 6'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota 6'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment 6'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA6'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 6'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento6'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt6'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 6'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 6'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date6'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC7'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 7'															, .T. }, ; //X3_TITULO
	{ 'Cuota 7'																, .T. }, ; //X3_TITSPA
	{ 'Installment7'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 7'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota 7'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment 7'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA7'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 7'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento7'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt7'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 7'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 7'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date7'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC8'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 8'															, .T. }, ; //X3_TITULO
	{ 'Cuota 8'																, .T. }, ; //X3_TITSPA
	{ 'Installment8'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 8'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota 8'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment 8'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA8'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 8'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento8'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt8'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 8'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 8'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date8'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARC9'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 9'															, .T. }, ; //X3_TITULO
	{ 'Cuota 9'																, .T. }, ; //X3_TITSPA
	{ 'Installment9'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela 9'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota 9'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment 9'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATA9'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento 9'														, .T. }, ; //X3_TITULO
	{ 'Vencimiento9'														, .T. }, ; //X3_TITSPA
	{ 'Maturity Dt9'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela 9'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota 9'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Date1'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'J9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 10'															, .T. }, ; //X3_TITULO
	{ 'Cuota10'																, .T. }, ; //X3_TITSPA
	{ 'Installment1'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela10'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota10'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment10'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento10'														, .T. }, ; //X3_TITULO
	{ 'Vencimient10'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D10'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela10'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota10'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat10'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCB'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 11'															, .T. }, ; //X3_TITULO
	{ 'Cuota11'																, .T. }, ; //X3_TITSPA
	{ 'Installmen11'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela11'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota11'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment11'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAB'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento11'														, .T. }, ; //X3_TITULO
	{ 'Vencimient11'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D11'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela11'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota11'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat11'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCC'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 12'															, .T. }, ; //X3_TITULO
	{ 'Cuota12'																, .T. }, ; //X3_TITSPA
	{ 'Installmen12'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela12'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota12'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment12'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAC'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento12'														, .T. }, ; //X3_TITULO
	{ 'Vencimient12'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D12'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela12'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota12'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat12'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCD'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 13'															, .T. }, ; //X3_TITULO
	{ 'Cuota13'																, .T. }, ; //X3_TITSPA
	{ 'Installmen13'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela13'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota13'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment13'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAD'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento13'														, .T. }, ; //X3_TITULO
	{ 'Vencimient13'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D13'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela13'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota13'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat13'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCE'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 14'															, .T. }, ; //X3_TITULO
	{ 'Cuota14'																, .T. }, ; //X3_TITSPA
	{ 'Installmen14'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela14'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota14'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment14'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAE'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento14'														, .T. }, ; //X3_TITULO
	{ 'Vencimient14'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D14'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela14'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota14'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat14'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'K9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PARCF'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela 15'															, .T. }, ; //X3_TITULO
	{ 'Cuota15'																, .T. }, ; //X3_TITSPA
	{ 'Installmen15'														, .T. }, ; //X3_TITENG
	{ 'Valor da Parcela15'													, .T. }, ; //X3_DESCRIC
	{ 'Valor de la Cuota15'													, .T. }, ; //X3_DESCSPA
	{ 'Value of Installment15'												, .T. }, ; //X3_DESCENG
	{ '@E 999,999,999.99'													, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DATAF'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vencimento15'														, .T. }, ; //X3_TITULO
	{ 'Vencimient15'														, .T. }, ; //X3_TITSPA
	{ 'Maturity D15'														, .T. }, ; //X3_TITENG
	{ 'Vencimento da Parcela15'												, .T. }, ; //X3_DESCRIC
	{ 'Vencimiento de la Cuota15'											, .T. }, ; //X3_DESCSPA
	{ 'Installment Due Dat15'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'A410Venc()'															, .T. }, ; //X3_VALID
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
	{ 'IIF(Type("CREPATU")<>"U",IIF(Empty(CREPATU),.T.,.F.),.T.)'			, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NUMENT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Entrega'																, .T. }, ; //X3_TITULO
	{ 'Entrega'																, .T. }, ; //X3_TITSPA
	{ 'Delivery'															, .T. }, ; //X3_TITENG
	{ 'Número da Entrega'													, .T. }, ; //X3_DESCRIC
	{ 'Número de entrega'													, .T. }, ; //X3_DESCSPA
	{ 'Delivery number'														, .T. }, ; //X3_DESCENG
	{ '@9'																	, .T. }, ; //X3_PICTURE
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ECSEDEX'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 13																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sedex EC'															, .T. }, ; //X3_TITULO
	{ 'Sedex EC'															, .T. }, ; //X3_TITSPA
	{ 'Sedex EC'															, .T. }, ; //X3_TITENG
	{ 'Sedex E-Commerce'													, .T. }, ; //X3_DESCRIC
	{ 'Sedex E-Commerce'													, .T. }, ; //X3_DESCSPA
	{ 'Sedex E-Commerce'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ECPRESN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped.Presente'														, .T. }, ; //X3_TITULO
	{ 'Ped.Presente'														, .T. }, ; //X3_TITSPA
	{ 'Pres Order'															, .T. }, ; //X3_TITENG
	{ 'Pedido Presente'														, .T. }, ; //X3_DESCRIC
	{ 'Pedido Presente'														, .T. }, ; //X3_DESCSPA
	{ 'Present order'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
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
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ECVINCU'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped Vinculad'														, .T. }, ; //X3_TITULO
	{ 'Sedex EC'															, .T. }, ; //X3_TITSPA
	{ 'Sedex EC'															, .T. }, ; //X3_TITENG
	{ 'Pedido Vinculado'													, .T. }, ; //X3_DESCRIC
	{ 'Sedex E-Commerce'													, .T. }, ; //X3_DESCSPA
	{ 'Sedex E-Commerce'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCHVRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Chv.Tmp.Res.'														, .T. }, ; //X3_TITULO
	{ 'Chv.Tmp.Res.'														, .T. }, ; //X3_TITSPA
	{ 'Chv.Tmp.Res.'														, .T. }, ; //X3_TITENG
	{ 'Chave Temporaria Reservas'											, .T. }, ; //X3_DESCRIC
	{ 'Chave Temporaria Reservas'											, .T. }, ; //X3_DESCSPA
	{ 'Chave Temporaria Reservas'											, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YCRDENG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Créd. Eng.'															, .T. }, ; //X3_TITULO
	{ 'Créd. Eng.'															, .T. }, ; //X3_TITSPA
	{ 'Créd. Eng.'															, .T. }, ; //X3_TITENG
	{ 'Crédito de Engenharia'												, .T. }, ; //X3_DESCRIC
	{ 'Crédito de Engenharia'												, .T. }, ; //X3_DESCSPA
	{ 'Crédito de Engenharia'												, .T. }, ; //X3_DESCENG
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
	{ '01=Liberado Automatico;02=Liberado Manual;03=Bloqueado'				, .T. }, ; //X3_CBOX
	{ '01=Liberado Automatico;02=Liberado Manual;03=Bloqueado'				, .T. }, ; //X3_CBOXSPA
	{ '01=Liberado Automatico;02=Liberado Manual;03=Bloqueado'				, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YOBDCOU'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Obs.Des.%Out'														, .T. }, ; //X3_TITULO
	{ 'Obs.Des.%Out'														, .T. }, ; //X3_TITSPA
	{ 'Obs.Des.%Out'														, .T. }, ; //X3_TITENG
	{ 'Obs. uso Desconto %Outros'											, .T. }, ; //X3_DESCRIC
	{ 'Obs. uso Desconto %Outros'											, .T. }, ; //X3_DESCSPA
	{ 'Obs. uso Desconto %Outros'											, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_DTESERV'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Exec.Serv'														, .T. }, ; //X3_TITULO
	{ 'Dt.Exec.Serv'														, .T. }, ; //X3_TITSPA
	{ 'Dt.Exec.Serv'														, .T. }, ; //X3_TITENG
	{ 'Dt.Exec.Serviço'														, .T. }, ; //X3_DESCRIC
	{ 'Dt.Exec.Serviço'														, .T. }, ; //X3_DESCSPA
	{ 'Dt.Exec.Serviço'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ 'S'																	, .T. }, ; //X3_PROPRI
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
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'L9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YEORIBS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Emp.Ori.PBas'														, .T. }, ; //X3_TITULO
	{ 'Emp.Ori.PBas'														, .T. }, ; //X3_TITSPA
	{ 'Emp.Ori.PBas'														, .T. }, ; //X3_TITENG
	{ 'Empresa Origem Ped Base'												, .T. }, ; //X3_DESCRIC
	{ 'Empresa Origem Ped Base'												, .T. }, ; //X3_DESCSPA
	{ 'Empresa Origem Ped Base'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YPEDBAS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr.Ped.Base'															, .T. }, ; //X3_TITULO
	{ 'Nr.Ped.Base'															, .T. }, ; //X3_TITSPA
	{ 'Nr.Ped.Base'															, .T. }, ; //X3_TITENG
	{ 'Pedido Base do Rodape'												, .T. }, ; //X3_DESCRIC
	{ 'Pedido Base do Rodape'												, .T. }, ; //X3_DESCSPA
	{ 'Pedido Base do Rodape'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CLIRET'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cli.Retirada'														, .T. }, ; //X3_TITULO
	{ 'Cli.Retiro'															, .T. }, ; //X3_TITSPA
	{ 'Withdr. Cust'														, .T. }, ; //X3_TITENG
	{ 'Cliente de Retirada'													, .T. }, ; //X3_DESCRIC
	{ 'Cliente de retiro'													, .T. }, ; //X3_DESCSPA
	{ 'Withdrawal Customer'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SA1")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
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
	{ "IIF(M->C5_TIPO$'DB',.F.,.T.)"										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_LOJARET'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lj. Retirada'														, .T. }, ; //X3_TITULO
	{ 'Td. Retiro'															, .T. }, ; //X3_TITSPA
	{ 'Withdr. Stor'														, .T. }, ; //X3_TITENG
	{ 'Loja de Retirada'													, .T. }, ; //X3_DESCRIC
	{ 'Tienda de retiro'													, .T. }, ; //X3_DESCSPA
	{ 'Withdrawal Store'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SA1",M->C5_CLIRET+M->C5_LOJARET)'							, .T. }, ; //X3_VALID
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
	{ "IIF(M->C5_TIPO$'DB',.F.,.T.)"										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MSBLQL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Status'																, .T. }, ; //X3_TITULO
	{ 'Estatus'																, .T. }, ; //X3_TITSPA
	{ 'Status'																, .T. }, ; //X3_TITENG
	{ 'Status do registro'													, .T. }, ; //X3_DESCRIC
	{ 'Estatus del registro'												, .T. }, ; //X3_DESCSPA
	{ 'Record Status'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ '"2"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Inativo;2=Ativo'													, .T. }, ; //X3_CBOX
	{ '1=Inactivo;2=Activo'													, .T. }, ; //X3_CBOXSPA
	{ '1=Inactive;2=Active'													, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TABTRF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tabela Trf.'															, .T. }, ; //X3_TITULO
	{ 'Tabla Trf.'															, .T. }, ; //X3_TITSPA
	{ 'Transf Table'														, .T. }, ; //X3_TITENG
	{ 'Tab Transf de IPI'													, .T. }, ; //X3_DESCRIC
	{ 'Tab Transf de IPI'													, .T. }, ; //X3_DESCSPA
	{ 'IPI Transf Table'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().Or.ExistCpo("DA0")'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'DA0'																	, .T. }, ; //X3_F3
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDUPLIC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Gera Duplic?'														, .T. }, ; //X3_TITULO
	{ 'Gera Duplic?'														, .T. }, ; //X3_TITSPA
	{ 'Gera Duplic?'														, .T. }, ; //X3_TITENG
	{ 'Gera Duplicata?'														, .T. }, ; //X3_DESCRIC
	{ 'Gera Duplicata?'														, .T. }, ; //X3_DESCSPA
	{ 'Gera Duplicata?'														, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TPCOMPL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Compl.'															, .T. }, ; //X3_TITULO
	{ 'Tipo Compl.'															, .T. }, ; //X3_TITSPA
	{ 'Compl Type'															, .T. }, ; //X3_TITENG
	{ 'Tipo de Complemento'													, .T. }, ; //X3_DESCRIC
	{ 'Tipo de complemento'													, .T. }, ; //X3_DESCSPA
	{ 'Complement Type'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12") .And. A410Limpa()'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"1"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Preço; 2=Quantidade'												, .T. }, ; //X3_CBOX
	{ '1=Precio; 2=Cantidad'												, .T. }, ; //X3_CBOXSPA
	{ '1=Price; 2=Quantity'													, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_REMCTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Contrato Rem'														, .T. }, ; //X3_TITULO
	{ 'Contrato Rem'														, .T. }, ; //X3_TITSPA
	{ 'Rem contract'														, .T. }, ; //X3_TITENG
	{ 'Nro Contrato Ref Remessa'											, .T. }, ; //X3_DESCRIC
	{ 'Nº Contrato Ref Remesión'											, .T. }, ; //X3_DESCSPA
	{ 'Remit ref contract no.'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
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
	{ '.F.'																	, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_REMREV'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Revisao Ctr'															, .T. }, ; //X3_TITULO
	{ 'Revisión Ctr'														, .T. }, ; //X3_TITSPA
	{ 'Contr Review'														, .T. }, ; //X3_TITENG
	{ 'Nro Revisão Ctr. Remessa'											, .T. }, ; //X3_DESCRIC
	{ 'NºRevisión Ctr. Remisión'											, .T. }, ; //X3_DESCSPA
	{ 'Review No Remitt Contr'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
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
	{ '.F.'																	, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'M9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CODEMB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Embarc.'														, .T. }, ; //X3_TITULO
	{ 'Cód. Embarc.'														, .T. }, ; //X3_TITSPA
	{ 'Shipment Cde'														, .T. }, ; //X3_TITENG
	{ 'Código da Embarcação'												, .T. }, ; //X3_DESCRIC
	{ 'Código de la embarcación'											, .T. }, ; //X3_DESCSPA
	{ 'Shipment Code'														, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("D31", M->C5_CODEMB) .OR. Vazio(M->C5_CODEMB)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
	{ 'Val(M->C5_MODANP) = 4'												, .T. }, ; //X3_WHEN
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_IMINT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 18																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Insc.mun.'															, .T. }, ; //X3_TITULO
	{ 'Insc.mun.'															, .T. }, ; //X3_TITSPA
	{ 'Mun reg'																, .T. }, ; //X3_TITENG
	{ 'Inscricao municipal'													, .T. }, ; //X3_DESCRIC
	{ 'Inscripción municipal'												, .T. }, ; //X3_DESCSPA
	{ 'Municipal registration'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_ARTOBRA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Código ART'															, .T. }, ; //X3_TITULO
	{ 'Código ART'															, .T. }, ; //X3_TITSPA
	{ 'ART code'															, .T. }, ; //X3_TITENG
	{ 'ART da Obra'															, .T. }, ; //X3_DESCRIC
	{ 'ART de la obra'														, .T. }, ; //X3_DESCSPA
	{ 'ART of work'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CGCINT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'CNPJ/CPF'															, .T. }, ; //X3_TITULO
	{ 'RCPJ/RCPF'															, .T. }, ; //X3_TITSPA
	{ 'CNPJ/CPF'															, .T. }, ; //X3_TITENG
	{ 'CNPJ/CPF'															, .T. }, ; //X3_DESCRIC
	{ 'RCPJ/RCPF'															, .T. }, ; //X3_DESCSPA
	{ 'CNPJ/CPF'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CLIINT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Razao Int.'															, .T. }, ; //X3_TITULO
	{ 'Razón Int.'															, .T. }, ; //X3_TITSPA
	{ 'Interm Ledge'														, .T. }, ; //X3_TITENG
	{ 'Razao Intermediario'													, .T. }, ; //X3_DESCRIC
	{ 'Razón Intermediario'													, .T. }, ; //X3_DESCSPA
	{ 'Intermediate Ledger'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FILGCT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial GCT'															, .T. }, ; //X3_TITULO
	{ 'Sucursal GCT'														, .T. }, ; //X3_TITSPA
	{ 'GCT Branch'															, .T. }, ; //X3_TITENG
	{ 'Filial Matriz Contrato'												, .T. }, ; //X3_DESCRIC
	{ 'Sucursal Matriz Contrato'											, .T. }, ; //X3_DESCSPA
	{ 'Contract Matrix Branch'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ '033'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SLENVT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sol.Env.Seg.'														, .T. }, ; //X3_TITULO
	{ 'Sol.Env.Seg.'														, .T. }, ; //X3_TITSPA
	{ 'Req'																	, .T. }, ; //X3_TITENG
	{ 'Sol.Env.Amost.-Testemunho'											, .T. }, ; //X3_DESCRIC
	{ 'Sol.Env.Muestra.-Testimon'											, .T. }, ; //X3_DESCSPA
	{ 'SamplSend Req - Witness'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("12")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"2"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
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
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_RET20G'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ret.20 Graus'														, .T. }, ; //X3_TITULO
	{ 'Ret.20 Graus'														, .T. }, ; //X3_TITSPA
	{ 'Ret 20 Level'														, .T. }, ; //X3_TITENG
	{ 'Retorno a 20 Graus.?'												, .T. }, ; //X3_DESCRIC
	{ '¿Vuelta a 20 Grados.?'												, .T. }, ; //X3_DESCSPA
	{ 'Return 20 levels?'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Pertence("SN")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ '"N"'																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ 'S=Sim;N=Não'															, .T. }, ; //X3_CBOX
	{ 'S=Si;N=No'															, .T. }, ; //X3_CBOXSPA
	{ 'Y=Yes;N=No'															, .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PLACA2'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Carreta'																, .T. }, ; //X3_TITULO
	{ 'Cam.Rem.'															, .T. }, ; //X3_TITSPA
	{ 'Truck'																, .T. }, ; //X3_TITENG
	{ 'Placa da Carreta'													, .T. }, ; //X3_DESCRIC
	{ 'Placa Camión Remolque'												, .T. }, ; //X3_DESCSPA
	{ 'Truck plate'															, .T. }, ; //X3_DESCENG
	{ '@R AAA-9999'															, .T. }, ; //X3_PICTURE
	{ 'DCLVV002()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PLACA1'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Truck/Cavalo'														, .T. }, ; //X3_TITULO
	{ 'Truck/Camión'														, .T. }, ; //X3_TITSPA
	{ 'Truck/Horse'															, .T. }, ; //X3_TITENG
	{ 'Placa do Truck/Cavalo'												, .T. }, ; //X3_DESCRIC
	{ 'Placa del camión tractor'											, .T. }, ; //X3_DESCSPA
	{ 'Truck/Horse Plate'													, .T. }, ; //X3_DESCENG
	{ '@R AAA-9999'															, .T. }, ; //X3_PICTURE
	{ 'DCLVV001()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'N9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_NOMMOT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Motoris'														, .T. }, ; //X3_TITULO
	{ 'Nom Conduct.'														, .T. }, ; //X3_TITSPA
	{ 'Driver Name'															, .T. }, ; //X3_TITENG
	{ 'Nome do Motorista'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del conductor'												, .T. }, ; //X3_DESCSPA
	{ "Driver's name"														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'IF(!INCLUI,Posicione("DHB",1,xFilial("DHB")+SC5->C5_CODMOT,"DHB_NOMMOT"),"")', .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
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
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_MODANP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Modal ANP'															, .T. }, ; //X3_TITULO
	{ 'Modal ANP'															, .T. }, ; //X3_TITSPA
	{ 'ANP modal'															, .T. }, ; //X3_TITENG
	{ 'Via de transp. Modal ANP'											, .T. }, ; //X3_DESCRIC
	{ 'Vía de transp. Modal ANP'											, .T. }, ; //X3_DESCSPA
	{ 'Transp way modal ANP'												, .T. }, ; //X3_DESCENG
	{ '99'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SX5", "HA"+M->C5_MODANP) .OR. Vazio(M->C5_MODANP)'			, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'HA'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CODVGLP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Vas.GLP'															, .T. }, ; //X3_TITULO
	{ 'Cód.Vas.GLP'															, .T. }, ; //X3_TITSPA
	{ 'GLP cont cd'															, .T. }, ; //X3_TITENG
	{ 'Código do Vasilhame GLP'												, .T. }, ; //X3_DESCRIC
	{ 'Código de la vajilla GLP'											, .T. }, ; //X3_DESCSPA
	{ 'GLP container code'													, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SX5", "HL"+M->C5_CODVGLP) .OR. VAZIO(M->C5_CODVGLP)'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'HL'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CODMOT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 11																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Motorist'														, .T. }, ; //X3_TITULO
	{ 'Cód.Conduct.'														, .T. }, ; //X3_TITSPA
	{ 'Driver code'															, .T. }, ; //X3_TITENG
	{ 'Cod. do Motorista'													, .T. }, ; //X3_DESCRIC
	{ 'Código del conductor'												, .T. }, ; //X3_DESCSPA
	{ 'Driver code'															, .T. }, ; //X3_DESCENG
	{ '@R 999.999.999-99'													, .T. }, ; //X3_PICTURE
	{ 'EXISTCPO("DHB",M->C5_CODMOT) .AND. DCLVV003 ()'						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(224)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_PEDECOM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ped E-Com.'															, .T. }, ; //X3_TITULO
	{ 'Ped eComm.'															, .T. }, ; //X3_TITSPA
	{ 'Ecom Order'															, .T. }, ; //X3_TITENG
	{ 'Pedido E-Commerce'													, .T. }, ; //X3_DESCRIC
	{ 'Pedido eCommerce'													, .T. }, ; //X3_DESCSPA
	{ 'E-Commerce Order'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_RASTR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Rastreio'															, .T. }, ; //X3_TITULO
	{ 'Prorrat'																, .T. }, ; //X3_TITSPA
	{ 'Tracking'															, .T. }, ; //X3_TITENG
	{ 'Rastreio do Pedido E-com.'											, .T. }, ; //X3_DESCRIC
	{ 'Prorrat del pedido eComm.'											, .T. }, ; //X3_DESCSPA
	{ 'E-com Order Tracking'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(128)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_STATUS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Status Ecom.'														, .T. }, ; //X3_TITULO
	{ 'Estatus eCom'														, .T. }, ; //X3_TITSPA
	{ 'Ecom. Status'														, .T. }, ; //X3_TITENG
	{ 'Status E-Commerce'													, .T. }, ; //X3_DESCRIC
	{ 'Estatus eCommerce'													, .T. }, ; //X3_DESCSPA
	{ 'E-Commerce Status'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '00=Gerado; 05=Em analise; 10=Pagamento confirmado; 15=Embalado; 21=Parcialmente enviado; 30=Enviado; 90=cancelado; 91=Devolvido', .T. }, ; //X3_CBOX
	{ '00=Generado; 05=En análisis 10=Pago confirmado; 15=Embalado; 21=Parcialmente enviado; 30=Enviado; 90=Anulado; 91=Devuelto', .T. }, ; //X3_CBOXSPA
	{ '00=Gen; 05=Under analysis; 10=Payment confirmed; 15=Packed; 21=Partialy sent; 30=Sent; 90=canceled; 91=Returned', .T. }, ; //X3_CBOXENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SDOC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série Doc.'															, .T. }, ; //X3_TITULO
	{ 'Serie Doc.'															, .T. }, ; //X3_TITSPA
	{ 'Doc Ser'																, .T. }, ; //X3_TITENG
	{ 'Série do Documento Fiscal'											, .T. }, ; //X3_DESCRIC
	{ 'Serie de documento fiscal'											, .T. }, ; //X3_DESCSPA
	{ 'Fiscal Document Series'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_VOLTAPS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Volta Passo'															, .T. }, ; //X3_TITULO
	{ 'Vuelve paso'															, .T. }, ; //X3_TITSPA
	{ 'Back Step'															, .T. }, ; //X3_TITENG
	{ 'Volta passo de Status'												, .T. }, ; //X3_DESCRIC
	{ 'Vuelve paso de estatus'												, .T. }, ; //X3_DESCSPA
	{ 'Back to Status step'													, .T. }, ; //X3_DESCENG
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
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
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
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_SDOCSUB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Série Subst.'														, .T. }, ; //X3_TITULO
	{ 'Serie Sust.'															, .T. }, ; //X3_TITSPA
	{ 'Subst Ser'															, .T. }, ; //X3_TITENG
	{ 'Série da Nf Substituída'												, .T. }, ; //X3_DESCRIC
	{ 'Serie de Fact sustituída'											, .T. }, ; //X3_DESCSPA
	{ 'Substit Invoice Series'												, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'O9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_TRCNUM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ac. Troca'															, .T. }, ; //X3_TITULO
	{ 'Ac. Cambio'															, .T. }, ; //X3_TITSPA
	{ 'Exchange Agr'														, .T. }, ; //X3_TITENG
	{ 'Número do Acordo de Troca'											, .T. }, ; //X3_DESCRIC
	{ 'Nº Acuerdo de cambio'												, .T. }, ; //X3_DESCSPA
	{ 'Exchange Agreem. No.'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('NKT')"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CODSAF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Safra'															, .T. }, ; //X3_TITULO
	{ 'Cód. Cosecha'														, .T. }, ; //X3_TITSPA
	{ 'Crop Code'															, .T. }, ; //X3_TITENG
	{ 'Código da Safra'														, .T. }, ; //X3_DESCRIC
	{ 'Código de la cosecha'												, .T. }, ; //X3_DESCSPA
	{ 'Crop Code'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Vazio() .Or. ExistCpo('NJU')"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(136) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NJU'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YVLFRST'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_TITULO
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_TITSPA
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_TITENG
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_DESCRIC
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_DESCSPA
	{ 'Vl.Fret.ST'															, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P2'																	, .T. }, ; //X3_ORDEM
	{ 'C5_FRTCFOP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Frete CFOP'															, .T. }, ; //X3_TITULO
	{ 'Flete CFOP'															, .T. }, ; //X3_TITSPA
	{ 'CFOP Freight'														, .T. }, ; //X3_TITENG
	{ 'CFOP Referente ao Frete'												, .T. }, ; //X3_DESCRIC
	{ 'CFOP Referente al flete'												, .T. }, ; //X3_DESCSPA
	{ 'CFOP Related to Freight'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

	aAdd( aSX3, { ;
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P3'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CMUNOR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mun.Origem'															, .T. }, ; //X3_TITULO
	{ 'Mun.Origen'															, .T. }, ; //X3_TITSPA
	{ 'Orig City'															, .T. }, ; //X3_TITENG
	{ 'Mun.Origem'															, .T. }, ; //X3_DESCRIC
	{ 'Mun.Origen'															, .T. }, ; //X3_DESCSPA
	{ 'Origin City'															, .T. }, ; //X3_DESCENG
	{ '@99999'																, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("CC2",M->C5_UFORIG+M->C5_CMUNOR)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CC2'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P4'																	, .T. }, ; //X3_ORDEM
	{ 'C5_UFDEST'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'UF Destino'															, .T. }, ; //X3_TITULO
	{ 'UF Destino'															, .T. }, ; //X3_TITSPA
	{ 'Dest State'															, .T. }, ; //X3_TITENG
	{ 'UF Destino'															, .T. }, ; //X3_DESCRIC
	{ 'UF Destino'															, .T. }, ; //X3_DESCSPA
	{ 'Destination State'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '12'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P5'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CMUNDE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Mun.Dest'															, .T. }, ; //X3_TITULO
	{ 'Mun.Dest'															, .T. }, ; //X3_TITSPA
	{ 'Dest City'															, .T. }, ; //X3_TITENG
	{ 'Mun.Dest'															, .T. }, ; //X3_DESCRIC
	{ 'Mun.Dest'															, .T. }, ; //X3_DESCSPA
	{ 'Dest City'															, .T. }, ; //X3_DESCENG
	{ '@99999'																, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("CC2",M->C5_UFDEST+M->C5_CMUNDE)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CC2'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P6'																	, .T. }, ; //X3_ORDEM
	{ 'C5_UFORIG'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'UF Origem'															, .T. }, ; //X3_TITULO
	{ 'Est/Prov/Reg'														, .T. }, ; //X3_TITSPA
	{ 'Origin State'														, .T. }, ; //X3_TITENG
	{ 'UF Origem'															, .T. }, ; //X3_DESCRIC
	{ 'Est/Prov/Regi Origen'												, .T. }, ; //X3_DESCSPA
	{ 'Origin State'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '12'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P7'																	, .T. }, ; //X3_ORDEM
	{ 'C5_CLIREM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cli. Remessa'														, .T. }, ; //X3_TITULO
	{ 'Cli. Remessa'														, .T. }, ; //X3_TITSPA
	{ 'Ship Cust'															, .T. }, ; //X3_TITENG
	{ 'Cliente da Remessa'													, .T. }, ; //X3_DESCRIC
	{ 'Cliente da Remessa'													, .T. }, ; //X3_DESCSPA
	{ 'Shipping Customer'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA1")'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA1'																	, .T. }, ; //X3_F3
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
	{ 'IIF(M->C5_TIPO$"DB",.F.,.T.)'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P8'																	, .T. }, ; //X3_ORDEM
	{ 'C5_LOJAREM'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja Remessa'														, .T. }, ; //X3_TITULO
	{ 'Loja Remessa'														, .T. }, ; //X3_TITSPA
	{ 'Ship Store'															, .T. }, ; //X3_TITENG
	{ 'Codigo da loja de Remessa'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo da loja de Remessa'											, .T. }, ; //X3_DESCSPA
	{ 'Shipping store code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio() .Or. ExistCpo("SA1",M->C5_CLIREM+M->C5_LOJAREM)'				, .T. }, ; //X3_VALID
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
	{ 'IIF(M->C5_TIPO$"DB",.F.,.T.)'										, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'P9'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YMAILEN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 100																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Email Eng Ob'														, .T. }, ; //X3_TITULO
	{ 'Email Eng Ob'														, .T. }, ; //X3_TITSPA
	{ 'Email Eng Ob'														, .T. }, ; //X3_TITENG
	{ 'Email Engenho Resp. Obra'											, .T. }, ; //X3_DESCRIC
	{ 'Email Engenho Resp. Obra'											, .T. }, ; //X3_DESCSPA
	{ 'Email Engenho Resp. Obra'											, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q0'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YIDVINI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Id Vinilico'															, .T. }, ; //X3_TITULO
	{ 'Id Vinilico'															, .T. }, ; //X3_TITSPA
	{ 'Id Vinilico'															, .T. }, ; //X3_TITENG
	{ 'ID Portal Vinilico'													, .T. }, ; //X3_DESCRIC
	{ 'ID Portal Vinilico'													, .T. }, ; //X3_DESCSPA
	{ 'ID Portal Vinilico'													, .T. }, ; //X3_DESCENG
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
		{ 'SC5'																	, .T. }, ; //X3_ARQUIVO
	{ 'Q1'																	, .T. }, ; //X3_ORDEM
	{ 'C5_YDELTBI'															, .T. }, ; //X3_CAMPO
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
// Tabela SC5
//
	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'C5_FILIAL+C5_NUM'														, ; //CHAVE
	'Numero'																, ; //DESCRICAO
	'Numero'																, ; //DESCSPA
	'Number'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM'										, ; //CHAVE
	'DT Emissao + Numero'													, ; //DESCRICAO
	'Fch Emision + Numero'													, ; //DESCSPA
	'Issue Date + Number'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM'								, ; //CHAVE
	'Cliente + Loja + Numero'												, ; //DESCRICAO
	'Cliente + Tienda + Numero'												, ; //DESCSPA
	'Customer + Unit + Number'												, ; //DESCENG
	'S'																		, ; //PROPRI
	'CLI'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'C5_FILIAL+C5_OS'														, ; //CHAVE
	'Gerado p/ OS'															, ; //DESCRICAO
	'Nr.OS Genera'															, ; //DESCSPA
	'Gen.f/S.O.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'C5_FILIAL+C5_NUMENT'													, ; //CHAVE
	'Entrega'																, ; //DESCRICAO
	'Entrega'																, ; //DESCSPA
	'Delivery'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C5_FILIAL+C5_CODED+C5_NUMPR'											, ; //CHAVE
	'Cod. Edital + Nr. Processo'											, ; //DESCRICAO
	'Cód. Edital + Nr. Proceso'												, ; //DESCSPA
	'Public Note + Process no.'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'C5_FILIAL+C5_CODEMB'													, ; //CHAVE
	'Cod. Embarc.'															, ; //DESCRICAO
	'Cód. Embarc.'															, ; //DESCSPA
	'Shipment Cde'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'C5_FILIAL+C5_MODANP'													, ; //CHAVE
	'Modal ANP'																, ; //DESCRICAO
	'Modal ANP'																, ; //DESCSPA
	'ANP Modal'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'C5_FILIAL+C5_CODVGLP'													, ; //CHAVE
	'Cod.Vas.GLP'															, ; //DESCRICAO
	'Cód.Vas.GLP'															, ; //DESCSPA
	'GLP cont cd'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'C5_FILIAL+C5_YDIGP'													, ; //CHAVE
	'DIGITADO POR'															, ; //DESCRICAO
	'DIGITADO POR'															, ; //DESCSPA
	'DIGITADO POR'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'DIGIPOR'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'C5_FILIAL+C5_YPEDORI+C5_YEMPPED'										, ; //CHAVE
	'Pedido Orig.+Empresa Ped.'												, ; //DESCRICAO
	'Pedido Orig.+Empresa Ped.'												, ; //DESCSPA
	'Pedido Orig.+Empresa Ped.'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'C5_FILIAL+C5_PEDEXP'													, ; //CHAVE
	'Proc.Export.'															, ; //DESCRICAO
	'Proc.Export.'															, ; //DESCSPA
	'Export Proc.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PROC'																	, ; //NICKNAME
	''																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'C5_FILIAL+C5_YRESULT'													, ; //CHAVE
	'Result. Emp.'															, ; //DESCRICAO
	'Result. Emp.'															, ; //DESCSPA
	'Result. Emp.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'C5_FILIAL+C5_YPC'														, ; //CHAVE
	'Ped.Compra'															, ; //DESCRICAO
	'Ped.Compra'															, ; //DESCSPA
	'Ped.Compra'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
		'SC5'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'C5_FILIAL+C5_YPEDORI'													, ; //CHAVE
	'Pedido Orig.'															, ; //DESCRICAO
	'Pedido Orig.'															, ; //DESCSPA
	'Pedido Orig.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

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
// Campo C5_CLIENT
//
	aAdd( aSX7, { ;
		'C5_CLIENT'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'A410NoDlvr()'															, ; //X7_REGRA
	'C5_LOJAENT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_CLIENTE
//
	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V1")'										, ; //X7_REGRA
	'C5_VEND1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C1")'										, ; //X7_REGRA
	'C5_COMIS1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'ExecBlock("BIA895",.F.,.F.)'											, ; //X7_REGRA
	'C5_YRECR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'1=2'																	} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA525",.F.,.F.)'											, ; //X7_REGRA
	'C5_CLIENTE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(M->C5_TIPO)=="N" .AND. 1=2'									} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'M->C5_LOJACLI'															, ; //X7_REGRA
	'C5_LOJAENT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA990",.F.,.F.)'											, ; //X7_REGRA
	'C5_CLIENTE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V2")'										, ; //X7_REGRA
	'C5_VEND2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C2")'										, ; //X7_REGRA
	'C5_COMIS2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'SA1->A1_YFORMA'														, ; //X7_REGRA
	'C5_YFORMA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA827",.F.,.F.)'											, ; //X7_REGRA
	'C5_TABELA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI'																} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'011'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V3")'										, ; //X7_REGRA
	'C5_VEND3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'012'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C3")'										, ; //X7_REGRA
	'C5_COMIS3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'013'																	, ; //X7_SEQUENC
	'Iif( Empty(Alltrim(M->C5_YCLIORI)),M->C5_CLIENTE,M->C5_YCLIORI)'		, ; //X7_REGRA
	'C5_YSI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'SUBSTR(ALLTRIM(M->C5_YITEMCT),1,1)=="I"'								} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'014'																	, ; //X7_SEQUENC
	"IIF(M->C5_CLIENTE == '010064', 'S',M->C5_TPFRETE)"						, ; //X7_REGRA
	'C5_TPFRETE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'015'																	, ; //X7_SEQUENC
	'IIF(Alltrim(M->C5_YSUBTP)<>"G","F"," ")'								, ; //X7_REGRA
	'C5_TPFRETE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'TYPE("CREPATU")<>"U".AND.!EMPTY(CREPATU)'								} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'016'																	, ; //X7_SEQUENC
	'IIF(SA1->A1_TIPO=="S","236","056")'									, ; //X7_REGRA
	'C5_CONDPAG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'AllTrim(M->C5_YSUBTP) $ "A#M"'											} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'017'																	, ; //X7_SEQUENC
	'IIF(Type("_FPCPYC5T1")<>"U".And.!Empty(_FPCPYC5T1),_FPCPYC5T1,M->C5_TRANSP)', ; //X7_REGRA
	'C5_TRANSP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI.And.AllTrim(M->C5_YSUBTP)$"A#M"'								} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'018'																	, ; //X7_SEQUENC
	'IIF(Type("_FPCPYC5T2")<>"U".And.!Empty(_FPCPYC5T2),_FPCPYC5T2,M->C5_TPFRETE)', ; //X7_REGRA
	'C5_TPFRETE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI.And.AllTrim(M->C5_YSUBTP)$"A#M"'								} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'019'																	, ; //X7_SEQUENC
	'U_BIAF049(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_YLINHA)'					, ; //X7_REGRA
	'C5_CLIENTE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CLIENTE'															, ; //X7_CAMPO
	'020'																	, ; //X7_SEQUENC
	'U_FROPGA05()'															, ; //X7_REGRA
	'C5_CONDPAG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_COMIS1
//
	aAdd( aSX7, { ;
		'C5_COMIS1'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C1")'										, ; //X7_REGRA
	'C5_COMIS1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_COMIS2
//
	aAdd( aSX7, { ;
		'C5_COMIS2'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C2")'										, ; //X7_REGRA
	'C5_COMIS2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_COMIS3
//
	aAdd( aSX7, { ;
		'C5_COMIS3'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C3")'										, ; //X7_REGRA
	'C5_COMIS3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_CONDPAG
//
	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'GETMV("MV_YMAXPRO")'													, ; //X7_REGRA
	'C5_YMAXPRO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'IIF(cEmpAnt=="13" .And. M->C5_CLIENTE=="010064",1,SE4->E4_YMAXDES)'	, ; //X7_REGRA
	'C5_YMAXCND'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SE4'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SE4")+M->C5_CONDPAG'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'GETMV("MV_YMAXPAL")'													, ; //X7_REGRA
	'C5_YMAXPAL'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'IIF(SE4->E4_YATIVO== "2","",M->C5_CONDPAG)'							, ; //X7_REGRA
	'C5_CONDPAG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SE4'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SE4")+M->C5_CONDPAG'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA801",.F.,.F.)'											, ; //X7_REGRA
	'C5_YFORMA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA806",.F.,.F.)'											, ; //X7_REGRA
	'C5_CONDPAG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_CONDPAG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_CONDPAG'															, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA525",.F.,.F.)'											, ; //X7_REGRA
	'C5_CLIENTE'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(M->C5_TIPO)=="N"'												} ) //X7_CONDIC

//
// Campo C5_MOEDA
//
	aAdd( aSX7, { ;
		'C5_MOEDA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'RecMoeda(M->C5_EMISSAO,M->C5_MOEDA)'									, ; //X7_REGRA
	'C5_TXMOEDA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_MUNPRES
//
	aAdd( aSX7, { ;
		'C5_MUNPRES'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'CC2->CC2_MUN'															, ; //X7_REGRA
	'C5_DESCMUN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'CC2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'(xFilial("CC2")+M->C5_ESTPRES+M->C5_MUNPRES)'							, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_TABELA
//
	aAdd( aSX7, { ;
		'C5_TABELA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_TABELA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_TIPO
//
	aAdd( aSX7, { ;
		'C5_TIPO'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA911",.F.,.F.)'											, ; //X7_REGRA
	'C5_TIPO'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(M->C5_TIPO)=="D"'												} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_TIPO'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA801",.F.,.F.)'											, ; //X7_REGRA
	'C5_YFORMA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(M->C5_CONDPAG)<>""'											} ) //X7_CONDIC

//
// Campo C5_VEND1
//
	aAdd( aSX7, { ;
		'C5_VEND1'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C1")'										, ; //X7_REGRA
	'C5_COMIS1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_VEND2
//
	aAdd( aSX7, { ;
		'C5_VEND2'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C2")'										, ; //X7_REGRA
	'C5_COMIS2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_VEND3
//
	aAdd( aSX7, { ;
		'C5_VEND3'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C3")'										, ; //X7_REGRA
	'C5_COMIS3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_VLRFRET
//
	aAdd( aSX7, { ;
		'C5_VLRFRET'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA346",.F.,.F.)'											, ; //X7_REGRA
	'C5_VLRFRET'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_VLRFRET'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_VLRFRET'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YCLIORI
//
	aAdd( aSX7, { ;
		'C5_YCLIORI'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1")+M->C5_YCLIORI,"A1_LOJA")'				, ; //X7_REGRA
	'C5_YLOJORI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YCLIORI'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA810",.F.,.F.)'											, ; //X7_REGRA
	'C5_YCLIORI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YCLIORI'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'Iif( Empty(Alltrim(M->C5_YCLIORI)),M->C5_CLIENTE,M->C5_YCLIORI)'		, ; //X7_REGRA
	'C5_YSI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'SUBSTR(ALLTRIM(M->C5_YITEMCT),1,1)=="I"'								} ) //X7_CONDIC

//
// Campo C5_YCLVL
//
	aAdd( aSX7, { ;
		'C5_YCLVL'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA478",.F.,.F.)'											, ; //X7_REGRA
	'C5_YCC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YDTINC
//
	aAdd( aSX7, { ;
		'C5_YDTINC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECbLOCK("VERCOND",.F.,.F.)'											, ; //X7_REGRA
	'C5_YPRZINC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YFLAG
//
	aAdd( aSX7, { ;
		'C5_YFLAG'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SA1->A1_EST'															, ; //X7_REGRA
	'C5_YEST'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YITEMCT
//
	aAdd( aSX7, { ;
		'C5_YITEMCT'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Iif( Empty(Alltrim(M->C5_YCLIORI)),M->C5_CLIENTE,M->C5_YCLIORI)'		, ; //X7_REGRA
	'C5_YSI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'SUBSTR(ALLTRIM(M->C5_YITEMCT),1,1)=="I"'								} ) //X7_CONDIC

//
// Campo C5_YLINHA
//
	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V1")'										, ; //X7_REGRA
	'C5_VEND1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C1")'										, ; //X7_REGRA
	'C5_COMIS1'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V2")'										, ; //X7_REGRA
	'C5_VEND2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C2")'										, ; //X7_REGRA
	'C5_COMIS2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'IIF(M->C5_YLINHA=="2","I",M->C5_YSUBTP)'								, ; //X7_REGRA
	'C5_YSUBTP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_YLINHA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"V3")'										, ; //X7_REGRA
	'C5_VEND3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YLINHA'																, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'ExecBlock("BIA825",.F.,.F.,"C3")'										, ; //X7_REGRA
	'C5_COMIS3'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YMAXCND
//
	aAdd( aSX7, { ;
		'C5_YMAXCND'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA344",.F.,.F.)'											, ; //X7_REGRA
	'C5_YMAXCND'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YMAXCND'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_YMAXCND'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YNPRENG
//
	aAdd( aSX7, { ;
		'C5_YNPRENG'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_PENGGAC5()'															, ; //X7_REGRA
	'C5_YNPRENG'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YPERC
//
	aAdd( aSX7, { ;
		'C5_YPERC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECBLOCK("BIA345",.F.,.F.)'											, ; //X7_REGRA
	'C5_YPERC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YPERC'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'EXECBLOCK("F02001",.F.,.F.)'											, ; //X7_REGRA
	'C5_YPERC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YPRZINC
//
	aAdd( aSX7, { ;
		'C5_YPRZINC'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'EXECbLOCK("VERCOND",.F.,.F.)'											, ; //X7_REGRA
	'C5_YPRZINC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C5_YSUBTP
//
	aAdd( aSX7, { ;
		'C5_YSUBTP'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ExecBlock("BIA897",.F.,.F.)'											, ; //X7_REGRA
	'C5_YRECR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'1=2'																	} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YSUBTP'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'IIF(ALLTRIM(M->C5_YSUBTP)="A","001",M->C5_MENPAD)'						, ; //X7_REGRA
	'C5_MENPAD'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YSUBTP'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'EXECBLOCK("ATU_PEDIDO",.F.,.F.)'										, ; //X7_REGRA
	'C5_YSUBTP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

	aAdd( aSX7, { ;
		'C5_YSUBTP'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'IIF(AllTrim(M->C5_YSUBTP)=="G"," ",M->C5_TPFRETE)'						, ; //X7_REGRA
	'C5_TPFRETE'															, ; //X7_CDOMIN
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
// Consulta BCO
//
	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Banco'																	, ; //XB_DESCRI
	'Banco'																	, ; //XB_DESCSPA
	'Bank'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA6'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Agência'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Bank Branch'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_AGENCIA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Cuenta'																, ; //XB_DESCSPA
	'Account'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_NUMCON'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_NREDUZ'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Agência'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Bank Branch'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_AGENCIA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Cuenta'																, ; //XB_DESCSPA
	'Account'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_NUMCON'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A6_NREDUZ'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA6->A6_COD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'BCO'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"IIf(SA6->(FieldPos('A6_MSBLQL'))>0,(SA6->A6_MSBLQL<>'1'),.T.)"			} ) //XB_CONTEM

//
// Consulta C5PENG
//
	aAdd( aSXB, { ;
		'C5PENG'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Propostas Engenharia'													, ; //XB_DESCRI
	'Propostas Engenharia'													, ; //XB_DESCSPA
	'Propostas Engenharia'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Z68'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'C5PENG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_C5PENGF3()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'C5PENG'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'uCRet1'																} ) //XB_CONTEM

//
// Consulta CBL
//
	aAdd( aSXB, { ;
		'CBL'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Pedido de Venda'														, ; //XB_DESCRI
	'Pedido de Venta'														, ; //XB_DESCSPA
	'Sales Order'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CBL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CBL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CBL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_CLIENTE'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CBL'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_NUM'																} ) //XB_CONTEM

//
// Consulta CC2
//
	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Município'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado + Cód. Mun'														, ; //XB_DESCRI
	'Est/Prov/Reg + Cód.'													, ; //XB_DESCSPA
	'State + City Code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Estado + Municipio'													, ; //XB_DESCRI
	'Est/Prov/Reg + Munic'													, ; //XB_DESCSPA
	'State + City'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Município	'															, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Município'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Município		'															, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Município		'															, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_CODMUN'														} ) //XB_CONTEM

//
// Consulta CC2END
//
	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Municipios Clientes'													, ; //XB_DESCRI
	'Municipios Clientes'													, ; //XB_DESCSPA
	'Municipios Clientes'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado + Codigo Ibge'													, ; //XB_DESCRI
	'Est/prov/reg + Codig'													, ; //XB_DESCSPA
	'State + Ibge Code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Município'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod.IBGE'																, ; //XB_DESCRI
	'Codigo IBGE'															, ; //XB_DESCSPA
	'IBGE Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod.IBGE'																, ; //XB_DESCRI
	'Codigo IBGE'															, ; //XB_DESCSPA
	'IBGE Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_CODMUN'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_MUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2END'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_EST==M->C5_YEST'												} ) //XB_CONTEM

//
// Consulta CC2SC5
//
	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Municipios clientes'													, ; //XB_DESCRI
	'Municipios clientes'													, ; //XB_DESCSPA
	'Customer Cities'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Município'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Município		'															, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est/Prov/Reg'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código Município'														, ; //XB_DESCRI
	'Código municipio'														, ; //XB_DESCSPA
	'City Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_CODMUN'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Município		'															, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_CODMUN'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CC2SC5'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CC2->CC2_EST==M->C5_ESTPRES'											} ) //XB_CONTEM

//
// Consulta CTD001
//
	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Item Contabil'															, ; //XB_DESCRI
	'Item Contable'															, ; //XB_DESCSPA
	'Accounting Item'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_ITEM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_RES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTD_DESC01'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTD001'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + '+RTrim(CTD->CTD_ITEM)+' + SIMPLES + '' + DUPLAS  + '' + SIMPLES + ''} ) //XB_CONTEM

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
// Consulta CTVBF3
//
	aAdd( aSXB, { ;
		'CTVBF3'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Contratos de Verba'													, ; //XB_DESCRI
	'Contratos de Verba'													, ; //XB_DESCSPA
	'Contratos de Verba'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA7'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTVBF3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_CTRVERF3()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'CTVBF3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'uCRet1'																} ) //XB_CONTEM

//
// Consulta DA0
//
	aAdd( aSXB, { ;
		'DA0'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Tabela de Preco'														, ; //XB_DESCRI
	'Tabla de Precio'														, ; //XB_DESCSPA
	'Price List'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA0'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA0->DA0_CODTAB'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA0->DA0_DESCRI'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA0->DA0_CODTAB'														} ) //XB_CONTEM

//
// Consulta DA3
//
	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Caminhoes'																, ; //XB_DESCRI
	'Camiones'																, ; //XB_DESCSPA
	'Trucks'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Veículo'																, ; //XB_DESCRI
	'Vehículo'																, ; //XB_DESCSPA
	'Vehicle'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Placa'																	, ; //XB_DESCRI
	'Placa'																	, ; //XB_DESCSPA
	'Plate'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Veículo'																, ; //XB_DESCRI
	'Vehículo'																, ; //XB_DESCSPA
	'Vehicle'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Modelo'																, ; //XB_DESCRI
	'Modelo'																, ; //XB_DESCSPA
	'Model'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Placa'																	, ; //XB_DESCRI
	'Placa'																	, ; //XB_DESCSPA
	'Plate'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_PLACA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Placa'																	, ; //XB_DESCRI
	'Placa'																	, ; //XB_DESCSPA
	'Plate'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_PLACA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Veículo'																, ; //XB_DESCRI
	'Vehículo'																, ; //XB_DESCSPA
	'Vehicle'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Modelo'																, ; //XB_DESCRI
	'Modelo'																, ; //XB_DESCSPA
	'Model'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DA3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DA3->DA3_COD'															} ) //XB_CONTEM

//
// Consulta DJBIA
//
	aAdd( aSXB, { ;
		'DJBIA'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'TIPOS DE PED VENDA'													, ; //XB_DESCRI
	'TIPOS DE PED VENDA'													, ; //XB_DESCSPA
	'TIPOS DE PED VENDA'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DJBIA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_F3_C5_YSUBTP()'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'DJBIA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur1'																} ) //XB_CONTEM

//
// Consulta NJU
//
	aAdd( aSXB, { ;
		'NJU'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Safra'																	, ; //XB_DESCRI
	'Cosecha'																, ; //XB_DESCSPA
	'Crop'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NJU'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NJU'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Safra'																	, ; //XB_DESCRI
	'Cosecha'																, ; //XB_DESCSPA
	'Crop'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NJU'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Safra'																	, ; //XB_DESCRI
	'Cosecha'																, ; //XB_DESCSPA
	'Crop'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NJU_CODSAF'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NJU'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NJU_DESCRI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'NJU'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'NJU->NJU_CODSAF'														} ) //XB_CONTEM

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
// Consulta SA1REP
//
	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Clientes'														, ; //XB_DESCRI
	'Consulta Clientes'														, ; //XB_DESCSPA
	'Consulta Clientes'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Unit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + Unit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cnpj/cpf'																, ; //XB_DESCRI
	'Cnpj/cpf'																, ; //XB_DESCSPA
	'Cnpj/cpf'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CGC/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'Municipality'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Bairro'																, ; //XB_DESCRI
	'Barrio'																, ; //XB_DESCSPA
	'District'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_BAIRRO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est.Cliente'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CGC/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'Municipality'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Bairro'																, ; //XB_DESCRI
	'Barrio'																, ; //XB_DESCSPA
	'District'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_BAIRRO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est.Cliente'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CGC/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'Municipality'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_MUN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Bairro'																, ; //XB_DESCRI
	'Barrio'																, ; //XB_DESCSPA
	'District'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_BAIRRO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Estado'																, ; //XB_DESCRI
	'Est.Cliente'															, ; //XB_DESCSPA
	'State'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_EST'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1REP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#U_F3_SA1REP()'														} ) //XB_CONTEM

//
// Consulta SA1SI
//
	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA1SI'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta SA2ISS
//
	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Fornecedor ISS'														, ; //XB_DESCRI
	'Proveedor ISS'															, ; //XB_DESCSPA
	'ISS Supplier'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA2'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CPF/CNPJ'																, ; //XB_DESCRI
	'RCPF/RCPJ'																, ; //XB_DESCSPA
	'SSN/EIN'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Storew'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SubStr(A2_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_LOJA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SubStr(A2_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'SSN/EIN'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SubStr(A2_NOME,1,30)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA2ISS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA2->A2_COD'															} ) //XB_CONTEM

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
// Consulta SA4
//
	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Transportadora'														, ; //XB_DESCRI
	'Transportista'															, ; //XB_DESCSPA
	'Carrier'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_CGC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SA4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA4->A4_COD'															} ) //XB_CONTEM

//
// Consulta SC5
//
	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Pedido de Venda'														, ; //XB_DESCRI
	'Pedido de Venta'														, ; //XB_DESCSPA
	'Sales Order'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Emissao + Numero'														, ; //XB_DESCRI
	'Emision + Numero'														, ; //XB_DESCSPA
	'Issue + Number'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Cliente + Numer'													, ; //XB_DESCRI
	'Cod. Cliente + Numer'													, ; //XB_DESCSPA
	'Custm.Code+Number'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registro Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#MATA410(,,3)#MATA410(,,2)'											} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Cliente'															, ; //XB_DESCRI
	'Cod. Cliente'															, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_CLIENTE'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_LOJACLI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Emissao'																, ; //XB_DESCRI
	'Emision'																, ; //XB_DESCSPA
	'Issue'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_EMISSAO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Emissao'																, ; //XB_DESCRI
	'Emision'																, ; //XB_DESCSPA
	'Issue'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_EMISSAO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Cod. Cliente'															, ; //XB_DESCRI
	'Cod. Cliente'															, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_CLIENTE'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_LOJACLI'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Cod. Cliente'															, ; //XB_DESCRI
	'Cod. Cliente'															, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_CLIENTE'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Numero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Emissao'																, ; //XB_DESCRI
	'Emision'																, ; //XB_DESCSPA
	'Issue'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C5_EMISSAO'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SC5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC5->C5_NUM'															} ) //XB_CONTEM

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
// Consulta SE4
//
	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cond. de Pagamento'													, ; //XB_DESCRI
	'Cond. de pago'															, ; //XB_DESCSPA
	'Payment Term'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SE4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição + Código'													, ; //XB_DESCRI
	'Descripción + Código'													, ; //XB_DESCSPA
	'Description + Code'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A360F3(3)#A360F3(1)'												} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_TIPO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Condição'																, ; //XB_DESCRI
	'Condición'																, ; //XB_DESCSPA
	'Term'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_DESCRI'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_TIPO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Condição'																, ; //XB_DESCRI
	'Condición'																, ; //XB_DESCSPA
	'Term'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_DESCRI'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'E4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SE4->E4_CODIGO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SE4'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'J070F3GRUPO()'															} ) //XB_CONTEM

//
// Consulta SED
//
	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Natureza'																, ; //XB_DESCRI
	'Modalidad'																, ; //XB_DESCSPA
	'Class'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SED'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ED_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ED_DESCRIC'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SED->ED_CODIGO'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#JFltF3SED()'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SED'																	, ; //XB_ALIAS
	'9'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'AC'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'FINA010'																} ) //XB_CONTEM

//
// Consulta SM4
//
	aAdd( aSXB, { ;
		'SM4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Fórmulas'																, ; //XB_DESCRI
	'Formulas'																, ; //XB_DESCSPA
	'Formulas'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SM4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SM4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SM4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'M4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SM4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'M4_DESCR'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SM4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SM4->M4_CODIGO'														} ) //XB_CONTEM

//
// Consulta SO4
//
	aAdd( aSXB, { ;
		'SO4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Kit de Servicos'														, ; //XB_DESCRI
	'Kit de Servicios'														, ; //XB_DESCSPA
	'Service Kit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SO4'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SO4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'O4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SO4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'O4_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SO4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Subs(O4_DESCRI,1,20)'													} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SO4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SO4->O4_CODIGO'														} ) //XB_CONTEM

//
// Consulta SON
//
	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cad.Nacional Obras'													, ; //XB_DESCRI
	'Reg.Nacional Obras'													, ; //XB_DESCSPA
	'Nat constr work reg'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SON'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ON_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ON_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ON_CODIGO'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripción'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ON_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SON'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SON->ON_CODIGO'														} ) //XB_CONTEM

//
// Consulta SZNSC5
//
	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Pedidos Venda'															, ; //XB_DESCRI
	'Pedidos Venda'															, ; //XB_DESCSPA
	'Pedidos Venda'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC5'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_F3_ZN_PEDIDO()'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur1'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur2'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur3'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZNSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur4'																} ) //XB_CONTEM

//
// Consulta SZOSC5
//
	aAdd( aSXB, { ;
		'SZOSC5'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'SOLICITAÇÕES DE INVE'													, ; //XB_DESCRI
	'SOLICITAÇÕES DE INVE'													, ; //XB_DESCSPA
	'SOLICITAÇÕES DE INVE'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SZO'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZOSC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_F3_C5_YNUMSI()'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'SZOSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'hk_Retur1'																} ) //XB_CONTEM

//
// Consulta ZCAT
//
	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'ZCAT'																	, ; //XB_DESCRI
	'ZCAT'																	, ; //XB_DESCSPA
	'ZCAT'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA2'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Categoria'																, ; //XB_DESCRI
	'Categoria'																, ; //XB_DESCSPA
	'Categoria'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Categoria'																, ; //XB_DESCRI
	'Categoria'																, ; //XB_DESCSPA
	'Categoria'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA2_COD'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA2_DESC'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Faixa Minima'															, ; //XB_DESCRI
	'Faixa Minima'															, ; //XB_DESCSPA
	'Faixa Minima'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA2_FMIN'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZCAT'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZA2->ZA2_COD'															} ) //XB_CONTEM

//
// Consulta ZZOSC5
//
	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro Obras'														, ; //XB_DESCRI
	'Cadastro Obras'														, ; //XB_DESCSPA
	'Cadastro Obras'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Número'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Número'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Emissão+vendedor+nom'													, ; //XB_DESCRI
	'Emissão+vendedor+nom'													, ; //XB_DESCSPA
	'Emissão+vendedor+nom'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Vendedor+nome Client'													, ; //XB_DESCRI
	'Vendedor+nome Client'													, ; //XB_DESCSPA
	'Vendedor+nome Client'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Número'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Número'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Emissão'																, ; //XB_DESCRI
	'Emissão'																, ; //XB_DESCSPA
	'Emissão'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_EMIS'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome Vend.'															, ; //XB_DESCRI
	'Nome Vend.'															, ; //XB_DESCSPA
	'Nome Vend.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NOMEV'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome da Obra'															, ; //XB_DESCRI
	'Nome da Obra'															, ; //XB_DESCSPA
	'Nome da Obra'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_OBRA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Número'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Número'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Emissão'																, ; //XB_DESCRI
	'Emissão'																, ; //XB_DESCSPA
	'Emissão'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_EMIS'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome Vend.'															, ; //XB_DESCRI
	'Nome Vend.'															, ; //XB_DESCSPA
	'Nome Vend.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NOMEV'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome da Obra'															, ; //XB_DESCRI
	'Nome da Obra'															, ; //XB_DESCSPA
	'Nome da Obra'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_OBRA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Número'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Número'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NUM'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Emissão'																, ; //XB_DESCRI
	'Emissão'																, ; //XB_DESCSPA
	'Emissão'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_EMIS'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome Vend.'															, ; //XB_DESCRI
	'Nome Vend.'															, ; //XB_DESCSPA
	'Nome Vend.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_NOMEV'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome da Obra'															, ; //XB_DESCRI
	'Nome da Obra'															, ; //XB_DESCSPA
	'Nome da Obra'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO_OBRA'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
		'ZZOSC5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZO->ZZO_NUM'															} ) //XB_CONTEM

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
// Helps Tabela SC5
//
	aHlpPor := {}
	aAdd( aHlpPor, 'Código que identifica a filial da' )
	aAdd( aHlpPor, 'empre-sa usuária do sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FILIAL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do pedido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NUM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NUM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'N-> Pedidos Normais.' )
	aAdd( aHlpPor, 'D-> Pedidos para Devolução de Compras.' )
	aAdd( aHlpPor, '(Excl. Brasil)' )
	aAdd( aHlpPor, 'C-> Compl. Preços/Quantidades.(Excl.' )
	aAdd( aHlpPor, 'Brasil)          P-> Compl. de IPI.' )
	aAdd( aHlpPor, 'I-> Compl. de ICMS. (Excl. Brasil)' )
	aAdd( aHlpPor, 'B-> Apres. Fornec. qdo material p/Benef.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TIPO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Selecione "N", "D"(Excl. Brasil),' )
	aAdd( aHlpPor, '"C"(Excl. Brasil), "P"(Excl. Brasil),' )
	aAdd( aHlpPor, '"I"(Excl. Brasil), ou   "B".' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC5_TIPO   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C5_TIPO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da loja de entrega.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_LOJAENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_LOJAENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Selecione um Código de Loja de Entrega' )
	aAdd( aHlpPor, 'válido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC5_LOJAENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C5_LOJAENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador do cliente ou' )
	aAdd( aHlpPor, 'Fornecedor, dependendo do tipo.' )
	aAdd( aHlpPor, 'Para consultar cadastro utilize-se' )
	aAdd( aHlpPor, 'da   tecla de função F3.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CLIENTE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CLIENTE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código que identifica cada uma das' )
	aAdd( aHlpPor, 'unidades (lojas) de  um  cliente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_LOJACLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_LOJACLI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Selecione um código de Loja válido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC5_LOJACLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C5_LOJACLI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código de identificação da' )
	aAdd( aHlpPor, 'transportadora.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TRANSP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TRANSP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do tipo de cliente. (Ver help  do' )
	aAdd( aHlpPor, 'programa).' )
	aAdd( aHlpPor, 'R = Revendedor' )
	aAdd( aHlpPor, 'S = Solidario' )
	aAdd( aHlpPor, 'F = Consumidor Final' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TIPOCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TIPOCLI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da condição de pagamento.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CONDPAG", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CONDPAG" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tabela padrão  do  preço de venda do' )
	aAdd( aHlpPor, 'cadastro de produtos para o cliente.' )
	aAdd( aHlpPor, 'Sugerido pelo sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TABELA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TABELA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'A tabela sugerida pelo sistema deve ser' )
	aAdd( aHlpPor, 'de 1 a 7.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "SC5_TABELA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado a solução do campo " + "C5_TABELA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do primeiro vendedor.' )
	aAdd( aHlpPor, 'Tecla <F3> disponível.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEND1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEND1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual  da comissão do primeiro' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COMIS1 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COMIS1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do segundo vendedor.' )
	aAdd( aHlpPor, 'Tecla <F3> disponível.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEND2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEND2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual da comissão do segundo' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COMIS2 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COMIS2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do terceiro vendedor.' )
	aAdd( aHlpPor, 'Tecla <F3> disponível.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEND3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEND3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual  da comissão do terceiro' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COMIS3 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COMIS3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do quarto vendedor.' )
	aAdd( aHlpPor, 'Tecla <F3> disponível.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEND4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEND4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual  da comissão do quarto' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COMIS4 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COMIS4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do quinto vendedor.' )
	aAdd( aHlpPor, 'Tecla <F3> disponível.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEND5  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEND5" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual  da comissão do quinto' )
	aAdd( aHlpPor, 'vendedor.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COMIS5 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COMIS5" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto 1 em cascata.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESC1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESC1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto 2 em cascata.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESC2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESC2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto 3 em cascata.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESC3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESC3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto 4 em cascata.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESC4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESC4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do banco no qual o título é' )
	aAdd( aHlpPor, 'negociado.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_BANCO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_BANCO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de desconto financeiro na' )
	aAdd( aHlpPor, 'duplicata.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESCFI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESCFI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data da emissão do pedido de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_EMISSAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_EMISSAO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da licitação que a  empresa' )
	aAdd( aHlpPor, 'concorreu.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_COTACAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_COTACAO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor ou percentual da parcela 1,' )
	aAdd( aHlpPor, 'depende da condição de  pagamento (tipo' )
	aAdd( aHlpPor, '9 da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PARC1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PARC1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data  do  vencimento  da  parcela 1,  se' )
	aAdd( aHlpPor, 'informado o valor da parcela 1  (tipo  9' )
	aAdd( aHlpPor, 'da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DATA1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DATA1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor ou percentual da parcela 2,' )
	aAdd( aHlpPor, 'depende da condição  de pagamento (tipo' )
	aAdd( aHlpPor, '9 da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PARC2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PARC2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data  do  vencimento  da  parcela 2,  se' )
	aAdd( aHlpPor, 'informado o valor da parcela 2  (tipo  9' )
	aAdd( aHlpPor, 'da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DATA2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DATA2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor ou percentual da parcela 3,' )
	aAdd( aHlpPor, 'depende da condição de  pagamento (tipo' )
	aAdd( aHlpPor, '9 da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PARC3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PARC3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor da despesa destacado no total da' )
	aAdd( aHlpPor, 'nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESPESA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESPESA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do Frete Autonômo.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FRETAUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FRETAUT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da fórmula de reajuste do  pedido' )
	aAdd( aHlpPor, 'de venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_REAJUST", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_REAJUST" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Moeda em que o pedido de venda está' )
	aAdd( aHlpPor, 'sendo digitada.' )
	aAdd( aHlpPor, 'Conforme o cadastro de moedas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MOEDA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MOEDA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data  do  vencimento  da  parcela 3,  se' )
	aAdd( aHlpPor, 'informado o valor da parcela 3  (tipo  9' )
	aAdd( aHlpPor, 'da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DATA3  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DATA3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor ou percentual da parcela 4,' )
	aAdd( aHlpPor, 'depende da condição de pagamento (tipo 9' )
	aAdd( aHlpPor, 'da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PARC4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PARC4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data  do  vencimento  da  parcela 4,  se' )
	aAdd( aHlpPor, 'informado o valor da parcela 4  (tipo  9' )
	aAdd( aHlpPor, 'da condição de pagamento).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DATA4  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DATA4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo do frete utilizado:' )
	aAdd( aHlpPor, 'C = CIF' )
	aAdd( aHlpPor, 'F = FOB' )
	aAdd( aHlpPor, 'T = Por conta de terceiros' )
	aAdd( aHlpPor, 'R = Por conta remetente' )
	aAdd( aHlpPor, 'D = Por conta destinatário' )
	aAdd( aHlpPor, 'S = Sem frete' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TPFRETE", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TPFRETE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do frete destacado do total da' )
	aAdd( aHlpPor, 'nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FRETE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FRETE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Valor do  seguro  destacado na nota' )
	aAdd( aHlpPor, 'fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SEGURO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SEGURO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Peso líquido da mercadoria impresso' )
	aAdd( aHlpPor, 'nanota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PESOL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PESOL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Peso bruto da mercadoria impresso na' )
	aAdd( aHlpPor, 'nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PBRUTO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PBRUTO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade de pré-notas impressas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_REIMP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_REIMP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da transportadora  para' )
	aAdd( aHlpPor, 'redespacho.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_REDESP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_REDESP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade de volume na espécie 1.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VOLUME1", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VOLUME1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade de volume na espécie 2.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VOLUME2", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VOLUME2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade de volume na espécie 3.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VOLUME3", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VOLUME3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Quantidade de volume na espécie 4.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VOLUME4", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VOLUME4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Espécie ou volume de embalagem 1.' )
	aAdd( aHlpPor, 'Ex.: caixas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ESPECI1", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ESPECI1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Este campo é sugerido através do cadas-' )
	aAdd( aHlpPor, 'tro de clientes. Informa ao sistema se' )
	aAdd( aHlpPor, 'o valor do ISS está incluso no preço.' )
	aAdd( aHlpPor, 'Se o valor não estiver incluso e, ao' )
	aAdd( aHlpPor, 'informar "N", o sistema inclui no Total' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_INCISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_INCISS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Utilizado pelo sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_LIBEROK", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_LIBEROK" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Flag .' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_OK     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_OK" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NOTA   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NOTA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série da nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SERIE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SERIE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Espécie ou volume de embalagem 2.' )
	aAdd( aHlpPor, 'Ex.: caixas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ESPECI2", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ESPECI2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Espécie ou volume de embalagem 3.' )
	aAdd( aHlpPor, 'Ex.: caixas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ESPECI3", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ESPECI3" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Espécie ou volume de embalagem 4.' )
	aAdd( aHlpPor, 'Ex.: caixas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ESPECI4", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ESPECI4" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da OS geradora.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_OS     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_OS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Percentual de acréscimo financeiro a ser' )
	aAdd( aHlpPor, 'aplicado sobre o preço da mercadoria.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ACRSFIN", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ACRSFIN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Mensagem definida para este pedido a ser' )
	aAdd( aHlpPor, 'impressa na nota fiscal.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MENNOTA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MENNOTA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da mensagem impressa na nota' )
	aAdd( aHlpPor, 'fiscal. Mensagem Padrão cadastrada' )
	aAdd( aHlpPor, 'atraves de uma Formula.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MENPAD ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MENPAD" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Unidade Federetiva da Prestação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ESTPRES", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ESTPRES" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Taxa da Moeda' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TXMOEDA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TXMOEDA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Kit de reparo.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_KITREP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_KITREP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Define o Criterio de Liberação do' )
	aAdd( aHlpPor, 'Pedidode Venda.' )
	aAdd( aHlpPor, '1 - Libera por Itens' )
	aAdd( aHlpPor, '2 - Libera por Pedido de Venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TIPLIB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TIPLIB" )

	aHlpPor := {}
	aAdd( aHlpPor, "Desconto Referente a Indenização, so e'" )
	aAdd( aHlpPor, "calculado na geração da NF, não e'" )
	aAdd( aHlpPor, 'considerado na liberação de credito' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESCONT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESCONT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Processo de Exportação no SIGAEIC' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PEDEXP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PEDEXP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica se o pedido entrara no mapa de' )
	aAdd( aHlpPor, 'carregamento do OMS. (S/N)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TPCARGA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TPCARGA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Status do embarque, sendo:' )
	aAdd( aHlpPor, '1 - Preparado para embarque' )
	aAdd( aHlpPor, '2 - Embarcado' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PREPEMB", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PREPEMB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica o cliente em cujo estado (UF) os' )
	aAdd( aHlpPor, 'produtos/servicos serao entregues.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CLIENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CLIENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o percentual de indenização a' )
	aAdd( aHlpPor, 'ser concedido na preparação do documento' )
	aAdd( aHlpPor, 'de saída. Na preparação do documento de' )
	aAdd( aHlpPor, 'saída, este percentual será aplicado' )
	aAdd( aHlpPor, 'sobre o valor da mercadoria.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PDESCAB", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PDESCAB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Este campo é utilizado para indicar, no' )
	aAdd( aHlpPor, 'lançamento do pedido de venda, se o ISS' )
	aAdd( aHlpPor, 'será retido na operação, independente da' )
	aAdd( aHlpPor, 'configuração lançada nos cadastros de' )
	aAdd( aHlpPor, 'clientes/fornecedores.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_RECISS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_RECISS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica se o pedido possui bloqueio de' )
	aAdd( aHlpPor, 'regras de negócio ou verbas de vendas.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_BLQ    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_BLQ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o numero do contrato.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CONTRA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CONTRA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o valor de frete de pauta.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VLR_FRT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VLR_FRT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Armazena o Numero do Orcamento gerado' )
	aAdd( aHlpPor, 'atraves da rotina de Venda Assistida,' )
	aAdd( aHlpPor, 'para possibilitar a rastreabilidade nas' )
	aAdd( aHlpPor, 'rotinas de exclusao das Vendas' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ORCRES ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ORCRES" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Este campo é utilizado para indicar, no' )
	aAdd( aHlpPor, 'lançamento do pedido de venda, se o ICMS' )
	aAdd( aHlpPor, 'sobre frete autonomo será pago pelo' )
	aAdd( aHlpPor, 'emitente ou pelo transportador.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_RECFAUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_RECFAUT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do contrato' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MDCONTR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MDCONTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica se a ordem de separação deve ser' )
	aAdd( aHlpPor, 'gerada na liberação do pedido, na' )
	aAdd( aHlpPor, 'montagem ou na unitização da carga.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_GERAWMS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_GERAWMS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da medição do contrato' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MDNUMED", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MDNUMED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da planilha do contrato' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MDPLANI", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MDPLANI" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Municipio de Prestação do serviço.' )
	aAdd( aHlpPor, 'Cod SIAFI Para DSFNET' )
	aAdd( aHlpPor, 'Cod IBGE Para ABRASF' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MUNPRES", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MUNPRES" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Descrição do Municipio de Prestação do' )
	aAdd( aHlpPor, 'serviço.' )
	aAdd( aHlpPor, 'Cod SIAFI Para DSFNET' )
	aAdd( aHlpPor, 'Cod IBGE Para ABRASF' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DESCMUN", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DESCMUN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Preencha o número do RPS que será' )
	aAdd( aHlpPor, 'substituído após transmissão para a' )
	aAdd( aHlpPor, 'prefeitura através da Rotina da Nfs-e' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NFSUBST", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NFSUBST" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Preencha a série do RPS que será' )
	aAdd( aHlpPor, 'substituído após transmissão para a' )
	aAdd( aHlpPor, 'prefeitura através da Rotina da Nfs-e' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SERSUBS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SERSUBS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Solicitaç„o de Frete.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SOLFRE ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SOLFRE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data de lançamento contábil, utilizado' )
	aAdd( aHlpPor, 'como flag de contabilização' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DTLANC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DTLANC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo que contém a taxa cambial' )
	aAdd( aHlpPor, 'referente ao dia da criação do pedido de' )
	aAdd( aHlpPor, 'vendas módulo de Controle de Exportação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TXREF  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TXREF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Campo que contém a data de embarque' )
	aAdd( aHlpPor, 'alimentado pelo módulo de Controle de' )
	aAdd( aHlpPor, 'Exportação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_DTTXREF", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_DTTXREF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Veiculo utilizado no Transporte do' )
	aAdd( aHlpPor, 'pedido.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VEICULO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VEICULO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Data de Entrega.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FECENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FECENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Usa Opcionais do Cliente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SOLOPC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SOLOPC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo do Edital de origem do pedido de' )
	aAdd( aHlpPor, 'venda' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CODED  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CODED" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo da Obra referente ao pedido de' )
	aAdd( aHlpPor, 'venda. Esse campo gerará informacoes' )
	aAdd( aHlpPor, 'para o registro Codigo da Obra.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_OBRA   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_OBRA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Numero do processo do Edital de origem' )
	aAdd( aHlpPor, 'do pedido de venda' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NUMPR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NUMPR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Designa a Origem do pedido:' )
	aAdd( aHlpPor, 'V - Vendedor.' )
	aAdd( aHlpPor, 'C - Cliente.' )
	aAdd( aHlpPor, 'N - Cliente Novo.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ORIGEM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ORIGEM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da natrueza.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NATUREZ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NATUREZ" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Moeda do Titulo a ser gerado do Contas a' )
	aAdd( aHlpPor, 'Receber independente do parametro' )
	aAdd( aHlpPor, 'MV_MOEDTIT.' )
	aAdd( aHlpPor, 'Caso o parametro esteja habilitado com' )
	aAdd( aHlpPor, 'geração de título moeda estrangeira e se' )
	aAdd( aHlpPor, 'o campo C5_MOEDTIT estiver como 1, será' )
	aAdd( aHlpPor, 'criado o titulo com moeda nacional.' )
	aAdd( aHlpPor, 'Qualquer informação neste campo' )
	aAdd( aHlpPor, 'diferente de 1 será criado um título' )
	aAdd( aHlpPor, 'respeitando o parametro MV_MOEDTIT e o' )
	aAdd( aHlpPor, 'campo C5_MOEDA.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MOEDTIT", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MOEDTIT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe a distancia de entrega para o' )
	aAdd( aHlpPor, 'calculo do frete de pauta.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_KM     ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_KM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informe o código referente ao cadastro' )
	aAdd( aHlpPor, 'nacional de obra (CNO).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CNO    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CNO" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informar a identificação da Nota de' )
	aAdd( aHlpPor, 'Empenho, quando se tratar de compras' )
	aAdd( aHlpPor, 'Públicas.' )
	aAdd( aHlpPor, 'Este campo será utilizado para NFe (tag' )
	aAdd( aHlpPor, 'xNEmp).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NTEMPEN", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NTEMPEN" )

	aHlpPor := {}
	aAdd( aHlpPor, '"Informar o Tipo de Obra para construcao' )
	aAdd( aHlpPor, 'civil. Este campo será utilizado para' )
	aAdd( aHlpPor, 'NFSe (tag tipo_obra)"' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TIPOBRA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TIPOBRA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indicador de presença do comprador no' )
	aAdd( aHlpPor, 'estabelecimento comercial no momento da' )
	aAdd( aHlpPor, 'operação.' )
	aAdd( aHlpPor, 'Este campo será utilizado para NFe a' )
	aAdd( aHlpPor, 'partir da versão 3.10 (tag indPres).' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_INDPRES", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_INDPRES" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da entrega programada que gerou o' )
	aAdd( aHlpPor, 'Pedido de Venda.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NUMENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NUMENT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa se o pedido gerado no E-Commerce' )
	aAdd( aHlpPor, 'será enviando via SEDEX' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ECSEDEX", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ECSEDEX" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa se o pedido gerado no E-Commerce' )
	aAdd( aHlpPor, 'será enviando para presente.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ECPRESN", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ECPRESN" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa se o pedido gerado no E-Commerce' )
	aAdd( aHlpPor, 'está vinculado' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ECVINCU", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ECVINCU" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Cliente de Retirada para geração do' )
	aAdd( aHlpPor, 'grupo de tag <Retirada> no arquivo xml' )
	aAdd( aHlpPor, 'para transmissão da NF-e' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CLIRET ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CLIRET" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Loja do Cliente de Retirada para geração' )
	aAdd( aHlpPor, 'do grupo de tag <Retirada> no arquivo' )
	aAdd( aHlpPor, 'xml para transmissão da NF-e.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_LOJARET", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_LOJARET" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa se o registro está habilitado' )
	aAdd( aHlpPor, '(ativo) para uso na aplicação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MSBLQL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MSBLQL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tabela de Preço para base de calculo do' )
	aAdd( aHlpPor, 'IPI na transferência de produtos entre' )
	aAdd( aHlpPor, 'filiais.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TABTRF ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TABTRF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Tipo de Complemento, sendo:' )
	aAdd( aHlpPor, '1- Preço' )
	aAdd( aHlpPor, '2- Quantidade' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TPCOMPL", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TPCOMPL" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Nro do Contrato referente a este pedido' )
	aAdd( aHlpPor, 'de Remessa de Locação.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_REMCTR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_REMCTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Nro da Revisão do Contrato referente a' )
	aAdd( aHlpPor, 'este pedido de remessa' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_REMREV ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_REMREV" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo da Embarcação' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CODEMB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CODEMB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número da inscrição municipal do' )
	aAdd( aHlpPor, 'Intermediário de Serviço.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_IMINT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_IMINT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Artigo da Obra.' )
	aAdd( aHlpPor, '(Anotação de Responsabilidade Técnica)' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_ARTOBRA", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_ARTOBRA" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Digite o CNPJ(Cadastro Nacional da' )
	aAdd( aHlpPor, 'Pessoa Jurídica) ou CPF (Cadastro de' )
	aAdd( aHlpPor, 'Pessoa Física) do Intermediário de' )
	aAdd( aHlpPor, 'Serviço.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CGCINT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CGCINT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Razao Social do Intermediário de' )
	aAdd( aHlpPor, 'Serviço.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CLIINT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CLIINT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica a filial matriz do contrato.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FILGCT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FILGCT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Sol.Env.Amost.-Testemunho' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SLENVT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SLENVT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Retorno a 20 Graus.?' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_RET20G ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_RET20G" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Placa da Carreta' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PLACA2 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PLACA2" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Placa do Truck/Cavalo' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PLACA1 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PLACA1" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Nome do Motorista' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_NOMMOT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_NOMMOT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Via de transp. Modal ANP' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_MODANP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_MODANP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Vasilhame GLP' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CODVGLP", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CODVGLP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Nome do Motorista' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CODMOT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CODMOT" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código do Pedido no e-commerce CiaShop.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_PEDECOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_PEDECOM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código de Rastreio do Pedido E-commerce.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_RASTR  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_RASTR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Status da Integração do e-commerce' )
	aAdd( aHlpPor, 'CiaShop:' )
	aAdd( aHlpPor, '-1=Volta passo' )
	aAdd( aHlpPor, '05=Em analise' )
	aAdd( aHlpPor, '10=Pagamento confirmado' )
	aAdd( aHlpPor, '15=Embalado' )
	aAdd( aHlpPor, '21=Parcialmente enviado' )
	aAdd( aHlpPor, '30=Enviado' )
	aAdd( aHlpPor, '90=Cancelado' )
	aAdd( aHlpPor, '91=Devolvido' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_STATUS ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_STATUS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série do Documento Fiscal' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SDOC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SDOC" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Informa Status que o E-commerce assumirá' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_VOLTAPS", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_VOLTAPS" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Série da Nf Substituída' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_SDOCSUB", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_SDOCSUB" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Número do Acordo de Troca.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_TRCNUM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_TRCNUM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código da Safra.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CODSAF ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CODSAF" )

	aHlpPor := {}
	aAdd( aHlpPor, 'CFOP Referente ao Frete' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_FRTCFOP", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_FRTCFOP" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo do municipio origem' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CMUNOR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CMUNOR" )

	aHlpPor := {}
	aAdd( aHlpPor, 'UF Destino' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_UFDEST ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_UFDEST" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Codigo municipio destino' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_CMUNDE ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CMUNDE" )

	aHlpPor := {}
	aAdd( aHlpPor, 'UF origem' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC5_UFORIG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_UFORIG" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Indica o cliente de remessa nos casos em' )
	aAdd( aHlpPor, 'que o local de entrega ou retirada seja' )
	aAdd( aHlpPor, 'diverso do endereço do destinatário.' )
	aHlpEng := {}
	aAdd( aHlpEng, 'Indicate the shipping customer where the' )
	aAdd( aHlpEng, 'place of delivery or pick-up is' )
	aAdd( aHlpEng, 'different from the address of the' )
	aAdd( aHlpEng, 'recipient.' )
	aHlpSpa := {}
	aAdd( aHlpSpa, 'Indica el cliente de envío en los casos' )
	aAdd( aHlpSpa, 'en los cuales el local de entrega o' )
	aAdd( aHlpSpa, 'retirada sea diferente de la dirección' )
	aAdd( aHlpSpa, 'del destinatario.' )

	PutHelp( "PC5_CLIREM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_CLIREM" )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código identificador da loja de remessa.' )
	aHlpEng := {}
	aAdd( aHlpEng, 'Identifier code of shipping store.' )
	aHlpSpa := {}
	aAdd( aHlpSpa, 'Código identificador de la tienda de' )
	aAdd( aHlpSpa, 'envío.' )

	PutHelp( "PC5_LOJAREM", aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Atualizado o Help do campo " + "C5_LOJAREM" )

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
	@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "SC5C28" ) ) ) ;
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
