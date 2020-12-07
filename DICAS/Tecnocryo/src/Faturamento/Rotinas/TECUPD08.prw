#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

//--------------------------------------------------------------------
/*/{Protheus.doc} LOCACAO
Função de update de dicionários para o processo vendor

@author PSS PARTNERS SOLUÇÕES EM SISTEMAS
@since  22/09/2014
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function TECUPD08( cEmpAmb, cFilAmb )

	Local   aSay      := {}
	Local   aButton   := {}
	Local   aMarcadas := {}
	Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS: LOCAÇÃO"
	Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
	Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
	Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
	Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
	Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
	Local   cDesc6    := ""
	Local   cDesc7    := ""
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
		If lAuto
			aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
		Else
			aMarcadas := EscEmpresa()
		EndIf

		If !Empty( aMarcadas )
			If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
				oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando LOCACAO ...", .F. )
				oProcess:Activate()

				If lAuto
					If lOk
						MsgStop( "Atualização Realizada.", "LOCACAO" )
					Else
						MsgStop( "Atualização não Realizada.", "LOCACAO" )
					EndIf
					dbCloseAll()
				Else
					If lOk
						Final( "Atualização Concluída." )
					Else
						Final( "Atualização não Realizada." )
					EndIf
				EndIf

			Else
				MsgStop( "Atualização não Realizada.", "LOCACAO" )

			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "LOCACAO" )

		EndIf

	EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas )

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
			If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
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

				cTexto += Replicate( "-", 128 ) + CRLF
				cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

				oProcess:SetRegua1( 8 )


				//------------------------------------
				// Atualiza o dicionário SX2
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX2( @cTexto )



				//------------------------------------
				// Atualiza o dicionário SX3
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de Campos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX3( @cTexto )



				//------------------------------------
				// Atualiza o dicionário SIX
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSIX( @cTexto )

				oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				oProcess:IncRegua2( "Atualizando campos/índices" )

				// Alteração física dos arquivos
				__SetX31Mode( .F. )

				If FindFunction(cTCBuild)
					cTopBuild := &cTCBuild.()
				EndIf

				For nX := 1 To Len( aArqUpd )

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND. !aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
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
						cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] + CRLF
					EndIf

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						TcInternal( 25, "OFF" )
					EndIf

				Next nX

				//------------------------------------
				// Atualiza o dicionário SX7
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX7( @cTexto )

				//------------------------------------
				// Atualiza o dicionário SXB
				//------------------------------------
//				oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
//				FSAtuSXB( @cTexto )

				//------------------------------------
				// Atualiza os helps
				//------------------------------------
//				oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
//				FSAtuHlp( @cTexto )

				RpcClearEnv()

			Next nI

			If MyOpenSm0(.T.)

				cAux += Replicate( "-", 128 ) + CRLF
				cAux += Replicate( " ", 128 ) + CRLF
				cAux += "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" + CRLF
				cAux += Replicate( " ", 128 ) + CRLF
				cAux += Replicate( "-", 128 ) + CRLF
				cAux += CRLF
				cAux += " Dados Ambiente" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
				cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
				cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
				cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
				cAux += " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
				cAux += " Environment........: " + GetEnvServer()  + CRLF
				cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
				cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
				cAux += " Versão.............: " + GetVersao(.T.)  + CRLF
				cAux += " Usuário TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
				cAux += " Computer Name......: " + GetComputerName() + CRLF

				aInfo   := GetUserInfo()
				If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
					cAux += " "  + CRLF
					cAux += " Dados Thread" + CRLF
					cAux += " --------------------"  + CRLF
					cAux += " Usuário da Rede....: " + aInfo[nPos][1] + CRLF
					cAux += " Estação............: " + aInfo[nPos][2] + CRLF
					cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
					cAux += " Environment........: " + aInfo[nPos][6] + CRLF
					cAux += " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
				EndIf
				cAux += Replicate( "-", 128 ) + CRLF
				cAux += CRLF

				cTexto := cAux + cTexto + CRLF

				cTexto += Replicate( "-", 128 ) + CRLF
				cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
				cTexto += Replicate( "-", 128 ) + CRLF

				cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

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
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2( cTexto )
	Local aEstrut   := {}
	Local aSX2      := {}
	Local cAlias    := ""
	Local cEmpr     := ""
	Local cPath     := ""
	Local nI        := 0
	Local nJ        := 0

	cTexto  += "Ínicio da Atualização" + " SX2" + CRLF + CRLF

	aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
	"X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
	"X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }

	dbSelectArea( "SX2" )
	SX2->( dbSetOrder( 1 ) )
	SX2->( dbGoTop() )
	cPath := ""//SX2->X2_PATH
//	cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
	cEmpr := Substr( SX2->X2_ARQUIVO, 4 )
/*
	//
	// Tabela ZZ1
	//
	aAdd( aSX2, { ;
	'ZZ1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZ1'+cEmpr																, ; //X2_ARQUIVO
	'ASSOCIACAO DE PRODUTOS        '										, ; //X2_NOME
	'ASSOCIACAO DE PRODUTOS        '										, ; //X2_NOMESPA
	'ASSOCIACAO DE PRODUTOS        '										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	5																		} ) //X2_MODULO
*/
	//
	// Tabela SZ2
	//
	aAdd( aSX2, { ;
	'ZZ2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZ2'+cEmpr																, ; //X2_ARQUIVO
	'CONTROLE DE LOCACOES          '										, ; //X2_NOME
	'CONTROLE DE LOCACOES          '										, ; //X2_NOMESPA
	'CONTROLE DE LOCACOES          '										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

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
				cTexto += "Foi incluída a tabela " + aSX2[nI][1] + CRLF
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

				cTexto += "Foi alterada a chave única da tabela " + aSX2[nI][1] + CRLF
			EndIf

		EndIf

	Next nI

	cTexto += CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3( cTexto )
	Local aEstrut   := {}
	Local aSX3      := {}
	Local cAlias    := ""
	Local cAliasAtu := ""
	Local cMsg      := ""
	Local cSeqAtu   := ""
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

	cTexto  += "Ínicio da Atualização" + " SX3" + CRLF + CRLF

	aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, ;
	{ "X3_TITULO" , 0 }, { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, ;
	{ "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, ;
	{ "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, ;
	{ "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, ;
	{ "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, { "X3_PYME"   , 0 }, ;
	{ "X3_AGRUP"  , 0 } }

	aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


	//
	// Campos Tabela ZZ1
	//
	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZ1_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo      '															, ; //X3_TITULO
	'Codigo      '															, ; //X3_TITSPA
	'Codigo      '															, ; //X3_TITENG
	'Codigo da Amarracao      '												, ; //X3_DESCRIC
	'Codigo da Amarracao      '												, ; //X3_DESCSPA
	'Codigo da Amarracao      '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZ1_PRDLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prod.Locacao'															, ; //X3_TITULO
	'Prod.Locacao'															, ; //X3_TITSPA
	'Prod.Locacao'															, ; //X3_TITENG
	'Produto Locacao          '												, ; //X3_DESCRIC
	'Produto Locacao          '												, ; //X3_DESCSPA
	'Produto Locacao          '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP
/*
	//
	// Campos Tabela ZZ1
	//
	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZ1_PRDAPL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prod.Aplicad'															, ; //X3_TITULO
	'Prod.Aplicad'															, ; //X3_TITSPA
	'Prod.Aplicad'															, ; //X3_TITENG
	'Produto Aplicado         '												, ; //X3_DESCRIC
	'Produto Aplicado         '												, ; //X3_DESCSPA
	'Produto Aplicado         '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZ1_CLIENT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cliente'     															, ; //X3_TITULO
	'Cliente'     															, ; //X3_TITSPA
	'Cliente'     															, ; //X3_TITENG
	'Codigo do Cliente        '												, ; //X3_DESCRIC
	'Codigo do Cliente        '												, ; //X3_DESCSPA
	'Codigo do Cliente        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZ1_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	04																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja        '															, ; //X3_TITULO
	'Loja        '															, ; //X3_TITSPA
	'Loja        '															, ; //X3_TITENG
	'Loja        '															, ; //X3_DESCRIC
	'Loja        '															, ; //X3_DESCSPA
	'Loja        '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP
	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZ1_APLDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	05																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja        '															, ; //X3_TITULO
	'Loja        '															, ; //X3_TITSPA
	'Loja        '															, ; //X3_TITENG
	'Loja        '															, ; //X3_DESCRIC
	'Loja        '															, ; //X3_DESCSPA
	'Loja        '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZ1_APLDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Aplicado'															, ; //X3_TITULO
	'Desc.Aplicado'															, ; //X3_TITSPA
	'Desc.Aplicado'															, ; //X3_TITENG
	'Desc.Aplicado'															, ; //X3_DESCRIC
	'Desc.Aplicado'															, ; //X3_DESCSPA
	'Desc.Aplicado'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ1'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZ1_LOCDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Locado'															, ; //X3_TITULO
	'Desc.Locado'															, ; //X3_TITSPA
	'Desc.Locado'															, ; //X3_TITENG
	'Desc.Locado'															, ; //X3_DESCRIC
	'Desc.Locado'															, ; //X3_DESCSPA
	'Desc.Locado'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP
*/
	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZ2_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	04																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial    '															, ; //X3_TITULO
	'Filial    '															, ; //X3_TITSPA
	'Filial    '															, ; //X3_TITENG
	'Filial    '															, ; //X3_DESCRIC
	'Filial    '															, ; //X3_DESCSPA
	'Filial    '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZ2_CODLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Locacao     '															, ; //X3_TITULO
	'Locacao     '															, ; //X3_TITSPA
	'Locacao     '															, ; //X3_TITENG
	'Locacao     '															, ; //X3_DESCRIC
	'Locacao     '															, ; //X3_DESCSPA
	'Locacao     '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	'GETSXENUM("ZZ2","ZZ2_CODLOC")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZ2_CLIENT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cliente     '															, ; //X3_TITULO
	'Cliente     '															, ; //X3_TITSPA
	'Cliente     '															, ; //X3_TITENG
	'Codigo do Cliente        '												, ; //X3_DESCRIC
	'Codigo do Cliente        '												, ; //X3_DESCSPA
	'Codigo do Cliente        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZ2_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	04																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja        '															, ; //X3_TITULO
	'Loja        '															, ; //X3_TITSPA
	'Loja        '															, ; //X3_TITENG
	'Loja        '															, ; //X3_DESCRIC
	'Loja        '															, ; //X3_DESCSPA
	'Loja        '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZ2_SERIE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	03																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Serie       '															, ; //X3_TITULO
	'Serie       '															, ; //X3_TITSPA
	'Serie       '	  														, ; //X3_TITENG
	'Serie da NF de Remessa   '												, ; //X3_DESCRIC
	'Serie da NF de Remessa   '												, ; //X3_DESCSPA
	'Serie da NF de Remessa   '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP



	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZ2_NOTREM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nota Remessa             '												, ; //X3_TITULO
	'Nota Remessa             '												, ; //X3_TITSPA
	'Nota Remessa             '	  											, ; //X3_TITENG
	'Nota Remessa             '												, ; //X3_DESCRIC
	'Nota Remessa             '												, ; //X3_DESCSPA
	'Nota Remessa             '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZ2_PRDAPL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto     '															, ; //X3_TITULO
	'Produto     '															, ; //X3_TITSPA
	'Produto     '	  														, ; //X3_TITENG
	'Codigo Produto Aplicado  '												, ; //X3_DESCRIC
	'Codigo Produto Aplicado  '												, ; //X3_DESCSPA
	'Codigo Produto Aplicado  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZ2_DESCPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto '															, ; //X3_TITULO
	'Desc.Produto '															, ; //X3_TITSPA
	'Desc.Produto '	  														, ; //X3_TITENG
	'Desc.Produto'															, ; //X3_DESCRIC
	'Desc.Produto'															, ; //X3_DESCSPA
	'Desc.Produto'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'Posicione("SB1",1,xFilial("SB1")+ZZ2_PRDAPL,"B1_DESC")'				, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZ2_QTDAPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Quantidade Remessa       '												, ; //X3_TITULO
	'Quantidade Remessa       '												, ; //X3_TITSPA
	'Quantidade Remessa       '	  											, ; //X3_TITENG
	'Quantidade Remessa       '												, ; //X3_DESCRIC
	'Quantidade Remessa       '												, ; //X3_DESCSPA
	'Quantidade Remessa       '												, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZ2_DTAAPL'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	08																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aplicado em '															, ; //X3_TITULO
	'Aplicado em '															, ; //X3_TITSPA
	'Aplicado em '	  														, ; //X3_TITENG
	'Data Inic.Aplicacao/Remes'												, ; //X3_DESCRIC
	'Data Inic.Aplicacao/Remes'												, ; //X3_DESCSPA
	'Data Inic.Aplicacao/Remes'												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP



	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZ2_GRPAMA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	04																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Amarracao   '															, ; //X3_TITULO
	'Amarracao   '															, ; //X3_TITSPA
	'Amarracao   '	  														, ; //X3_TITENG
	'Grupo de Amarracao       '												, ; //X3_DESCRIC
	'Grupo de Amarracao       '												, ; //X3_DESCSPA
	'Grupo de Amarracao       '												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZ2_METINC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	01																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.Inclusão'															, ; //X3_TITULO
	'Tp.Inclusão'															, ; //X3_TITSPA
	'Tp.Inclusão'	  														, ; //X3_TITENG
	'Metodo de Inclusao (M/A) '												, ; //X3_DESCRIC
	'Metodo de Inclusao (M/A) '												, ; //X3_DESCSPA
	'Metodo de Inclusao (M/A) '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZ2_PRCUNI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Unitar'															, ; //X3_TITULO
	'Valor Unitar'															, ; //X3_TITSPA
	'Valor Unitar'	  														, ; //X3_TITENG
	'Preco unitário           '												, ; //X3_DESCRIC
	'Preco unitário           '												, ; //X3_DESCSPA
	'Preco unitário           '												, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZ2_ULTRET'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	08																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ultimo Retor'															, ; //X3_TITULO
	'Ultimo Retor'															, ; //X3_TITSPA
	'Ultimo Retor'	  														, ; //X3_TITENG
	'Ultimo Retorno           '												, ; //X3_DESCRIC
	'Ultimo Retorno           '												, ; //X3_DESCSPA
	'Ultimo Retorno           '												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZZ2_TES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	03																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'TES'																	, ; //X3_TITULO
	'TES'																	, ; //X3_TITSPA
	'TES'	  																, ; //X3_TITENG
	'TES'																	, ; //X3_DESCRIC
	'TES'																	, ; //X3_DESCSPA
	'TES'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZZ2_SALDO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'A Devolver  '															, ; //X3_TITULO
	'A Devolver  '															, ; //X3_TITSPA
	'A Devolver  '	  														, ; //X3_TITENG
	'Saldo a Devolver         '												, ; //X3_DESCRIC
	'Saldo a Devolver         '												, ; //X3_DESCSPA
	'Saldo a Devolver         '												, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZZ2_QTDCOB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	09																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtd.a Cobrar'															, ; //X3_TITULO
	'Qtd.a Cobrar'															, ; //X3_TITSPA
	'Qtd.a Cobrar'	  														, ; //X3_TITENG
	'Quantidade a Cobrar      '												, ; //X3_DESCRIC
	'Quantidade a Cobrar      '												, ; //X3_DESCSPA
	'Quantidade a Cobrar      '												, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZZ2_ULTCOB'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	08																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ult.Cobranca'															, ; //X3_TITULO
	'Ult.Cobranca'															, ; //X3_TITSPA
	'Ult.Cobranca'	  														, ; //X3_TITENG
	'Ultima Cobranca Alugue   '												, ; //X3_DESCRIC
	'Ultima Cobranca Alugue   '												, ; //X3_DESCSPA
	'Ultima Cobranca Alugue   '												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZZ2_IDENB6'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ident. B6   '															, ; //X3_TITULO
	'Ident. B6   '															, ; //X3_TITSPA
	'Ident. B6   '	  														, ; //X3_TITENG
	'Identidade SB6           '												, ; //X3_DESCRIC
	'Identidade SB6           '												, ; //X3_DESCSPA
	'Identidade SB6           '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'ZZ2'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZZ2_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	01																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status      '															, ; //X3_TITULO
	'Status      '															, ; //X3_TITSPA
	'Status      '	  														, ; //X3_TITENG
	'Status de Cobranca       '												, ; //X3_DESCRIC
	'Status de Cobranca       '												, ; //X3_DESCSPA
	'Status de Cobranca       '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'C6_YCODLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Locacao     '															, ; //X3_TITULO
	'Locacao     '															, ; //X3_TITSPA
	'Locacao     '	  														, ; //X3_TITENG
	'Codigo da Locacao        '												, ; //X3_DESCRIC
	'Codigo da Locacao        '												, ; //X3_DESCSPA
	'Codigo da Locacao        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP		

	aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'C6_YGERLOC'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	08																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ger.Locacao'															, ; //X3_TITULO
	'Ger.Locacao'															, ; //X3_TITSPA
	'Ger.Locacao'	  														, ; //X3_TITENG
	'Data Geracao Locacao'   												, ; //X3_DESCRIC
	'Data Geracao Locacao' 													, ; //X3_DESCSPA
	'Data Geracao Locacao' 													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP		

	aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'XA'																	, ; //X3_ORDEM
	'D1_YCODLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Locacao     '															, ; //X3_TITULO
	'Locacao     '															, ; //X3_TITSPA
	'Locacao     '	  														, ; //X3_TITENG
	'Codigo da Locacao        '												, ; //X3_DESCRIC
	'Codigo da Locacao        '												, ; //X3_DESCSPA
	'Codigo da Locacao        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP		


	aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'XB'																	, ; //X3_ORDEM
	'D1_YDTRET'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	08																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Retorno Real'															, ; //X3_TITULO
	'Retorno Real'															, ; //X3_TITSPA
	'Retorno Real'	  														, ; //X3_TITENG
	'Retorno Real         '													, ; //X3_DESCRIC
	'Retorno Real         '													, ; //X3_DESCSPA
	'Retorno Real         '													, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP


	aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'E1_YCODLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Locacao     '															, ; //X3_TITULO
	'Locacao     '															, ; //X3_TITSPA
	'Locacao     '	  														, ; //X3_TITENG
	'Codigo da Locacao        '												, ; //X3_DESCRIC
	'Codigo da Locacao        '												, ; //X3_DESCSPA
	'Codigo da Locacao        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP		


	aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'D2_YCODLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	06																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Locacao     '															, ; //X3_TITULO
	'Locacao     '															, ; //X3_TITSPA
	'Locacao     '	  														, ; //X3_TITENG
	'Codigo da Locacao        '												, ; //X3_DESCRIC
	'Codigo da Locacao        '												, ; //X3_DESCSPA
	'Codigo da Locacao        '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Q1'																	, ; //X3_ORDEM
	'A1_YDIAFEC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	02																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loc.Dia Fecham.'														, ; //X3_TITULO
	'Loc.Dia Fecham.'														, ; //X3_TITSPA
	'Loc.Dia Fecham.'	  													, ; //X3_TITENG
	'Locacao Dia Fechamento '												, ; //X3_DESCRIC
	'Locacao Dia Fechamento '												, ; //X3_DESCSPA
	'Locacao Dia Fechamento '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	


	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Q1'																	, ; //X3_ORDEM
	'A1_YCPGTLO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	03																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cond.Locacao'															, ; //X3_TITULO
	'Cond.Locacao'														, ; //X3_TITSPA
	'Cond.Locacao'	  													, ; //X3_TITENG
	'Condição Pgto Locação  '												, ; //X3_DESCRIC
	'Condição Pgto Locação  '												, ; //X3_DESCSPA
	'Condição Pgto Locação  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SE4'																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Q2'																	, ; //X3_ORDEM
	'A1_YSTAZZ2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	01																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cobra Locacao'															, ; //X3_TITULO
	'Cobra Locacao'															, ; //X3_TITSPA
	'Cobra Locacao'	  														, ; //X3_TITENG
	'Cobra Locacao       '													, ; //X3_DESCRIC
	'Cobra Locacao       '													, ; //X3_DESCSPA
	'Cobra Locacao       '													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=Não'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	
	
	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Q3'																	, ; //X3_ORDEM
	'A1_YAGLLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	01																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aglut.Locac.'															, ; //X3_TITULO
	'Aglut.Locac.'															, ; //X3_TITSPA
	'Aglut.Locac.'	  														, ; //X3_TITENG
	'Aglutina Locacao       '												, ; //X3_DESCRIC
	'Aglutina Locacao       '												, ; //X3_DESCSPA
	'Aglutina Locacao       '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=Não'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	


	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Q4'																	, ; //X3_ORDEM
	'A1_YMENNOT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Mens.Padrão'															, ; //X3_TITULO
	'Mens.Padrão'															, ; //X3_TITSPA
	'Mens.Padrão'	  														, ; //X3_TITENG
	'Mensagem Padrão Nota'													, ; //X3_DESCRIC
	'Mensagem Padrão Nota'													, ; //X3_DESCSPA
	'Mensagem Padrão Nota'													, ; //X3_DESCENG
	'@!S50'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'T0'																	, ; //X3_ORDEM
	'B1_YONU'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	04																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ONU Tecnocry'															, ; //X3_TITULO
	'ONU Tecnocry'															, ; //X3_TITSPA
	'ONU Tecnocry'	  														, ; //X3_TITENG
	'ONU Tecnocry           '												, ; //X3_DESCRIC
	'ONU Tecnocry           '												, ; //X3_DESCSPA
	'ONU Tecnocry           '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP	

	aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'T2'																	, ; //X3_ORDEM
	'B1_YPRDLOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prod.Locacao'															, ; //X3_TITULO
	'Prod.Locacao'															, ; //X3_TITSPA
	'Prod.Locacao'															, ; //X3_TITENG
	'Produto Locacao          '												, ; //X3_DESCRIC
	'Produto Locacao          '												, ; //X3_DESCSPA
	'Produto Locacao          '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'N'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'M->B1_GRUPO <> "0050"'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_PYME
	''																		} ) //X3_AGRUP

	//
	// Atualizando dicionário
	//

	nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
	nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
	nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
	nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
	nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
	nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

	aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

	oProcess:SetRegua2( Len( aSX3 ) )

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )
	cAliasAtu := ""

	For nI := 1 To Len( aSX3 )

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( aSX3[nI][nPosSXG] )
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
					cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		SX3->( dbSetOrder( 2 ) )

		If !( aSX3[nI][nPosArq] $ cAlias )
			cAlias += aSX3[nI][nPosArq] + "/"
			aAdd( aArqUpd, aSX3[nI][nPosArq] )
		EndIf

		If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

			//
			// Busca ultima ocorrencia do alias
			//
			If ( aSX3[nI][nPosArq] <> cAliasAtu )
				cSeqAtu   := "00"
				cAliasAtu := aSX3[nI][nPosArq]

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
					SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

			cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

		EndIf

		oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

	Next nI

	cTexto += CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX( cTexto )
	Local aEstrut   := {}
	Local aSIX      := {}
	Local lAlt      := .F.
	Local lDelInd   := .F.
	Local nI        := 0
	Local nJ        := 0

	cTexto  += "Ínicio da Atualização" + " SIX" + CRLF + CRLF

	aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

/*
	//
	// Tabela ZZ1
	//
	aAdd( aSIX, { ;
	'ZZ1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZ1_FILIAL+ZZ1_PRDLOC'													, ; //CHAVE
	'Prod.Locacao'															, ; //DESCRICAO
	'Prod.Locacao'															, ; //DESCSPA
	'Prod.Locacao'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZ1_FILIAL+ZZ1_PRDAPL'													, ; //CHAVE
	'Prod.Aplicad'															, ; //DESCRICAO
	'Prod.Aplicad'															, ; //DESCSPA
	'Prod.Aplicad'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZZ1_FILIAL+ZZ1_COD'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ1'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZZ1_FILIAL+ZZ1_CLIENT+ZZ1_LOJA+ZZ1_PRDAPL'								, ; //CHAVE
	'Cliente+Loja+Prod.Aplicad'												, ; //DESCRICAO
	'Cliente+Loja+Prod.Aplicad'												, ; //DESCSPA
	'Cliente+Loja+Prod.Aplicad'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
*/
	//
	// Tabela ZZ2
	//
	aAdd( aSIX, { ;
	'ZZ2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZ2_FILIAL+ZZ2_CODLOC+ZZ2_PRDAPL'										, ; //CHAVE
	'Locacao+Prod. Aplica'													, ; //DESCRICAO
	'Locacao+Prod. Aplica'													, ; //DESCSPA
	'Locacao+Prod. Aplica'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ2'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZ2_FILIAL+ZZ2_CLIENT+ZZ2_LOJA+ZZ2_CODLOC'								, ; //CHAVE
	'Cliente+Loja+Locacao'													, ; //DESCRICAO
	'Cliente+Loja+Locacao'													, ; //DESCSPA
	'Cliente+Loja+Locacao'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ2'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZZ2_FILIAL+ZZ2_SERIE+ZZ2_NOTREM+ZZ2_PRDAPL'							, ; //CHAVE
	'Serie Rem.+Nota Remessa+Produto'										, ; //DESCRICAO
	'Serie Rem.+Nota Remessa+Produto'										, ; //DESCSPA
	'Serie Rem.+Nota Remessa+Produto'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'ZZ2'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZZ2_FILIAL+ZZ2_SERIE+ZZ2_NOTREM+ZZ2_CLIENT+ZZ2_LOJA+ZZ2_PRDAPL'		, ; //CHAVE
	'Serie+Nota+Cliente+Loja+Produto'										, ; //DESCRICAO
	'Serie+Nota+Cliente+Loja+Produto'										, ; //DESCSPA
	'Serie+Nota+Cliente+Loja+Produto'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
`
	aAdd( aSIX, { ;
	'ZZ2'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'ZZ2_FILIAL+ZZ2_IDENB6+ZZ2_NOTREM+ZZ2_PRDAPL'							, ; //CHAVE
	'IdentB6+NF.Remessa+Prod.Aplicado'										, ; //DESCRICAO
	'IdentB6+NF.Remessa+Prod.Aplicado'										, ; //DESCSPA
	'IdentB6+NF.Remessa+Prod.Aplicado'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'SD1'																	, ; //INDICE
	'M'																		, ; //ORDEM
	'D1_FILIAL+D1_YCODLOC'													, ; //CHAVE
	'Locacao'																, ; //DESCRICAO
	'Locacao'																, ; //DESCSPA
	'Locacao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LOCACAO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


	aAdd( aSIX, { ;
	'SD2'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'D2_FILIAL+D2_YCODLOC'													, ; //CHAVE
	'Locacao'																, ; //DESCRICAO
	'Locacao'																, ; //DESCSPA
	'Locacao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LOCACAO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'E1_FILIAL+E1_YCODLOC'													, ; //CHAVE
	'Locacao'																, ; //DESCRICAO
	'Locacao'																, ; //DESCSPA
	'Locacao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LOCACAO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

	aAdd( aSIX, { ;
	'SC6'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'C6_FILIAL+C6_YCODLOC+DTOS(C6_YGERLOC)'									, ; //CHAVE
	'Locacao'																, ; //DESCRICAO
	'Locacao'																, ; //DESCSPA
	'Locacao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LOCACAO'																, ; //NICKNAME
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
			cTexto += "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
		Else
			lAlt := .T.
			aAdd( aArqUpd, aSIX[nI][1] )
			If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
			StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
				cTexto += "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
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

	cTexto += CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7( cTexto )

	Local aEstrut   := {}
	Local aAreaSX3  := SX3->( GetArea() )
	Local aSX7      := {}
	Local cAlias    := ""
	Local nI        := 0
	Local nJ        := 0
	Local nTamSeek  := Len( SX7->X7_CAMPO )

	cTexto  += "Ínicio da Atualização" + " SX7" + CRLF + CRLF

	aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

	// Campo C7_FORNECE
	aAdd( aSX7, { ;
	'B1_GRUPO  '															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'u_F08NewPrd(1)'														, ; //X7_REGRA
	'B1_YPRDLOC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!EMPTY(M->B1_GRUPO).and.INCLUI'										} ) //X7_CONDIC

	// Atualizando dicionário
	oProcess:SetRegua2( Len( aSX7 ) )

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )

	dbSelectArea( "SX7" )
	dbSetOrder( 1 )

	For nI := 1 To Len( aSX7 )

		If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

			If !( aSX7[nI][1] $ cAlias )
				cAlias += aSX7[nI][1] + "/"
				cTexto += "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
			EndIf

			RecLock( "SX7", .T. )
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

		EndIf
		oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

	Next nI

	RestArea( aAreaSX3 )

	cTexto += CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB( cTexto )
	Local aEstrut   := {}
	Local aSXB      := {}
	Local cAlias    := ""
	Local cMsg      := ""
	Local lTodosNao := .F.
	Local lTodosSim := .F.
	Local nI        := 0
	Local nJ        := 0
	Local nOpcA     := 0

	cTexto  += "Ínicio da Atualização" + " SXB" + CRLF + CRLF

	aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
	"XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

	//
	// Consulta YSAH
	//
	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Unidade de Medid Alt'													, ; //XB_DESCRI
	'Unidade de Medid Alt'													, ; //XB_DESCSPA
	'Unidade de Medid Alt'													, ; //XB_DESCENG
	'SAH'																	} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Un. Medida'															, ; //XB_DESCRI
	'Un. Medida'															, ; //XB_DESCSPA
	'Measure Unit'															, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Un. Medida'															, ; //XB_DESCRI
	'Un. Medida'															, ; //XB_DESCSPA
	'Measure Unit'															, ; //XB_DESCENG
	'AH_UNIMED'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc. Resum.'															, ; //XB_DESCRI
	'Desc.Resum.'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	'AH_UMRES'																} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SAH->AH_UNIMED'														} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SAH->AH_UMRES'															} ) //XB_CONTEM

	aAdd( aSXB, { ;
	'YSAH'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'GDFIELDGET("C7_PRODUTO",N) == SZ2->Z2_PRODUTO'							} ) //XB_CONTEM

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
					cTexto += "Foi incluída a consulta padrão " + aSXB[nI][1] + CRLF
				EndIf

				RecLock( "SXB", .T. )

				For nJ := 1 To Len( aSXB[nI] )
					If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
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
								cTexto += "Foi alterada a consulta padrão " + aSXB[nI][1] + CRLF
							EndIf

						EndIf

					EndIf

				Next

			EndIf

		EndIf

		oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

	Next nI

	cTexto += CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp( cTexto )
	Local aHlpPor   := {}
	Local aHlpEng   := {}
	Local aHlpSpa   := {}

	cTexto  += "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF + CRLF


	oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

	//
	// Helps Tabela SC6
	//
	aHlpPor := {}
	aAdd( aHlpPor, 'UM Comercail' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_YUMCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "C6_YUMCOM" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Qtd Comercial' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC6_YQTDCOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "C6_YQTDCOM" + CRLF

	//
	// Helps Tabela ZZ1
	//
	aHlpPor := {}
	aAdd( aHlpPor, 'Um Comercial - Unidade que sera feita' )
	aAdd( aHlpPor, 'por ela conversao.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC7_YUMCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "C7_YUMCOM" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Qtd Comercial - Quantidade que sera' )
	aAdd( aHlpPor, 'convertidade para quantidade que o' )
	aAdd( aHlpPor, 'sistema reconhece.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PC7_YQUANT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "C7_YQUANT" + CRLF

	//
	// Helps Tabela SCK
	//
	aHlpPor := {}
	aAdd( aHlpPor, 'Um Comercial' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PCK_YUMCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "CK_YUMCOM" + CRLF

	//
	// Helps Tabela SD1
	//
	aHlpPor := {}
	aAdd( aHlpPor, 'Um Comercial' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PD1_YUMCOM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "D1_YUMCOM" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Qdt Comercial' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PD1_YQUANT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "D1_YQUANT" + CRLF

	//
	// Helps Tabela SZ2
	//
	aHlpPor := {}
	aAdd( aHlpPor, 'Código que identifica a filial de' )
	aAdd( aHlpPor, 'empre-sa usuária do sistema.' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_FILIAL" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Item Enumerado da Tabela' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_ITEM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_ITEM" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'UM Alternati' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_UMALT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_UMALT" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Descricao da Unidade de Medida' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_DESCRI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_DESCRI" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Fator Conversao' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_FATCONV", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_FATCONV" + CRLF

	aHlpPor := {}
	aAdd( aHlpPor, 'Produto' )
	aHlpEng := {}
	aHlpSpa := {}

	PutHelp( "PZ2_PRODUTO", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "Z2_PRODUTO" + CRLF

	cTexto += CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

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
	Local   aSalvAmb := GetArea()
	Local   aSalvSM0 := {}
	Local   aRet     := {}
	Local   aVetor   := {}
	Local   oDlg     := NIL
	Local   oChkMar  := NIL
	Local   oLbx     := NIL
	Local   oMascEmp := NIL
	Local   oMascFil := NIL
	Local   oButMarc := NIL
	Local   oButDMar := NIL
	Local   oButInv  := NIL
	Local   oSay     := NIL
	Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
	Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
	Local   lChk     := .F.
	Local   lOk      := .F.
	Local   lTeveMarc:= .F.
	Local   cVar     := ""
	Local   cNomEmp  := ""
	Local   cMascEmp := "??"
	Local   cMascFil := "??"

	Local   aMarcadas  := {}


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

	Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

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

	@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
	on Click MarcaTodos( lChk, @aVetor, oLbx )

	@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
	Message "Inverter Seleção" Of oDlg

	// Marca/Desmarca por mascara
	@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
	@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
	Message "Máscara Empresa ( ?? )"  Of oDlg
	@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
	Message "Marcar usando máscara ( ?? )"    Of oDlg
	@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
	Message "Desmarcar usando máscara ( ?? )" Of oDlg

	Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
	Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
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
@since  21/10/2013
@obs    Gerado por EXPORDIC - V.4.19.8.1 EFS / Upd. V.4.17.7 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

	Local lOpen := .F.
	Local nLoop := 0

	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf

		Sleep( 500 )

	Next nLoop

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ;
		IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
	EndIf

Return lOpen


/////////////////////////////////////////////////////////////////////////////
