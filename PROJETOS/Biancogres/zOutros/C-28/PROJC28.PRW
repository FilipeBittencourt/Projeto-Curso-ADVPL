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
/*/{Protheus.doc} PROJC28
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  29/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function PROJC28( cEmpAmb, cFilAmb )

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

      aMarcadas := EscEmpresa()
    EndIf

    If !Empty( aMarcadas )
      If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
        oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
        oProcess:Activate()

        If lAuto
          If lOk
            MsgStop( "Atualização Realizada.", "PROJC28" )
          Else
            MsgStop( "Atualização não Realizada.", "PROJC28" )
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
@since  29/07/21
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
        // Atualiza o dicionário SX3
        //------------------------------------
        FSAtuSX3()

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
        // Atualiza o dicionário SXB
        //------------------------------------
        oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
        FSAtuSXB()

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
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  29/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
  Local aEstrut   := {}
  Local aSX3      := {}
  Local cAlias    := ""
  Local cAliasAtu := ""
  Local cSeqAtu   := ""
  Local cX3Campo  := ""
  Local cX3Dado   := ""
  Local nI        := 0
  Local nJ        := 0
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
// Campos Tabela PZ5
//
  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '04'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TPACOR'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 2																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo Acordo'															, .T. }, ; //X3_TITULO
  { 'Tipo Acordo'															, .T. }, ; //X3_TITSPA
  { 'Tipo Acordo'															, .T. }, ; //X3_TITENG
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCRIC
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCSPA
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCENG
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
  { 'S'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { '€'																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOX
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOXSPA
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '28'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PRODFO'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 50																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Prod. Format'														, .T. }, ; //X3_TITULO
  { 'Prod. Format'														, .T. }, ; //X3_TITSPA
  { 'Prod. Format'														, .T. }, ; //X3_TITENG
  { 'Prod. Format'														, .T. }, ; //X3_DESCRIC
  { 'Prod. Format'														, .T. }, ; //X3_DESCSPA
  { 'Prod. Format'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'ZZ6A'																, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
  { ''																	, .T. }, ; //X3_CHECK
  { ''																	, .T. }, ; //X3_TRIGGER
  { 'U'																	, .T. }, ; //X3_PROPRI
  { 'N'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
// Campos Tabela PZ6
//
  aAdd( aSX3, { ;
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '13'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAF1'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Rec. 1'															, .T. }, ; //X3_TITULO
  { 'Meta Rec. 1'															, .T. }, ; //X3_TITSPA
  { 'Meta Rec. 1'															, .T. }, ; //X3_TITENG
  { 'Meta Rec. 1'															, .T. }, ; //X3_DESCRIC
  { 'Meta Rec. 1'															, .T. }, ; //X3_DESCSPA
  { 'Meta Rec. 1'															, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '14'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAF2'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Rec. 2'															, .T. }, ; //X3_TITULO
  { 'Meta Rec. 2'															, .T. }, ; //X3_TITSPA
  { 'Meta Rec. 2'															, .T. }, ; //X3_TITENG
  { 'Meta Rec. 2'															, .T. }, ; //X3_DESCRIC
  { 'Meta Rec. 2'															, .T. }, ; //X3_DESCSPA
  { 'Meta Rec. 2'															, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '15'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAF3'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Rec. 3'															, .T. }, ; //X3_TITULO
  { 'Meta Rec. 3'															, .T. }, ; //X3_TITSPA
  { 'Meta Rec. 3'															, .T. }, ; //X3_TITENG
  { 'Meta Rec. 3'															, .T. }, ; //X3_DESCRIC
  { 'Meta Rec. 3'															, .T. }, ; //X3_DESCSPA
  { 'Meta Rec. 3'															, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '16'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAF4'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Rec. 4'															, .T. }, ; //X3_TITULO
  { 'Meta Rec. 4'															, .T. }, ; //X3_TITSPA
  { 'Meta Rec. 4'															, .T. }, ; //X3_TITENG
  { 'Meta Rec. 4'															, .T. }, ; //X3_DESCRIC
  { 'Meta Rec. 4'															, .T. }, ; //X3_DESCSPA
  { 'Meta Rec. 4'															, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '17'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAF5'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Rec. 5'															, .T. }, ; //X3_TITULO
  { 'Meta Rec. 5'															, .T. }, ; //X3_TITSPA
  { 'Meta Rec. 5'															, .T. }, ; //X3_TITENG
  { 'Meta Rec. 5'															, .T. }, ; //X3_DESCRIC
  { 'Meta Rec. 5'															, .T. }, ; //X3_DESCSPA
  { 'Meta Rec. 5'															, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '18'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_VALREA'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'R. Realizada'														, .T. }, ; //X3_TITULO
  { 'R. Realizada'														, .T. }, ; //X3_TITSPA
  { 'R. Realizada'														, .T. }, ; //X3_TITENG
  { 'R. Realizada'														, .T. }, ; //X3_DESCRIC
  { 'R. Realizada'														, .T. }, ; //X3_DESCSPA
  { 'R. Realizada'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '29'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAP1'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Posit 1'														, .T. }, ; //X3_TITULO
  { 'Meta Posit 1'														, .T. }, ; //X3_TITSPA
  { 'Meta Posit 1'														, .T. }, ; //X3_TITENG
  { 'Meta Posit 1'														, .T. }, ; //X3_DESCRIC
  { 'Meta Posit 1'														, .T. }, ; //X3_DESCSPA
  { 'Meta Posit 1'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '30'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAP2'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Posit 2'														, .T. }, ; //X3_TITULO
  { 'Meta Posit 2'														, .T. }, ; //X3_TITSPA
  { 'Meta Posit 2'														, .T. }, ; //X3_TITENG
  { 'Meta Posit 2'														, .T. }, ; //X3_DESCRIC
  { 'Meta Posit 2'														, .T. }, ; //X3_DESCSPA
  { 'Meta Posit 2'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '31'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAP3'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Posit 3'														, .T. }, ; //X3_TITULO
  { 'Meta Posit 3'														, .T. }, ; //X3_TITSPA
  { 'Meta Posit 3'														, .T. }, ; //X3_TITENG
  { 'Meta Posit 3'														, .T. }, ; //X3_DESCRIC
  { 'Meta Posit 3'														, .T. }, ; //X3_DESCSPA
  { 'Meta Posit 3'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '32'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAP4'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Posit 4'														, .T. }, ; //X3_TITULO
  { 'Meta Posit 4'														, .T. }, ; //X3_TITSPA
  { 'Meta Posit 4'														, .T. }, ; //X3_TITENG
  { 'Meta Posit 4'														, .T. }, ; //X3_DESCRIC
  { 'Meta Posit 4'														, .T. }, ; //X3_DESCSPA
  { 'Meta Posit 4'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '33'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_METAP5'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'Meta Posit 5'														, .T. }, ; //X3_TITULO
  { 'Meta Posit 5'														, .T. }, ; //X3_TITSPA
  { 'Meta Posit 5'														, .T. }, ; //X3_TITENG
  { 'Meta Posit 5'														, .T. }, ; //X3_DESCRIC
  { 'Meta Posit 5'														, .T. }, ; //X3_DESCSPA
  { 'Meta Posit 5'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'PZ6'																	, .T. }, ; //X3_ARQUIVO
  { '34'																	, .T. }, ; //X3_ORDEM
  { 'PZ6_PREALI'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 18																	, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'P. Realizada'														, .T. }, ; //X3_TITULO
  { 'P. Realizada'														, .T. }, ; //X3_TITSPA
  { 'P. Realizada'														, .T. }, ; //X3_TITENG
  { 'P. Realizada'														, .T. }, ; //X3_DESCRIC
  { 'P. Realizada'														, .T. }, ; //X3_DESCSPA
  { 'P. Realizada'														, .T. }, ; //X3_DESCENG
  { '@E 999,999,999,999,999.99'											, .T. }, ; //X3_PICTURE
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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

//
// Campos Tabela SB1
//
  aAdd( aSX3, { ;
    { 'SB1'																	, .T. }, ; //X3_ARQUIVO
  { '[4'																	, .T. }, ; //X3_ORDEM
  { 'B1_YDVLGL'															, .T. }, ; //X3_CAMPO
  { 'D'																	, .T. }, ; //X3_TIPO
  { 8																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Dt.Val.Galer'														, .T. }, ; //X3_TITULO
  { 'Dt.Val.Galer'														, .T. }, ; //X3_TITSPA
  { 'Dt.Val.Galer'														, .T. }, ; //X3_TITENG
  { 'Dt.Val.Galer'														, .T. }, ; //X3_DESCRIC
  { 'Dt.Val.Galer'														, .T. }, ; //X3_DESCSPA
  { 'Dt.Val.Galer'														, .T. }, ; //X3_DESCENG
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
// Campos Tabela SZO
//
  aAdd( aSX3, { ;
    { 'SZO'																	, .T. }, ; //X3_ARQUIVO
  { '34'																	, .T. }, ; //X3_ORDEM
  { 'ZO_YTPACOR'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 2																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo Acordo'															, .T. }, ; //X3_TITULO
  { 'Tipo Acordo'															, .T. }, ; //X3_TITSPA
  { 'Tipo Acordo'															, .T. }, ; //X3_TITENG
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCRIC
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCSPA
  { 'Tipo Acordo'															, .T. }, ; //X3_DESCENG
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
  { 'S'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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
    { 'SZO'																	, .T. }, ; //X3_ARQUIVO
  { '35'																	, .T. }, ; //X3_ORDEM
  { 'ZO_YDTVLD'															, .T. }, ; //X3_CAMPO
  { 'D'																	, .T. }, ; //X3_TIPO
  { 8																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Dt Validade'															, .T. }, ; //X3_TITULO
  { 'Dt Validade'															, .T. }, ; //X3_TITSPA
  { 'Dt Validade'															, .T. }, ; //X3_TITENG
  { 'Dt Validade'															, .T. }, ; //X3_DESCRIC
  { 'Dt Validade'															, .T. }, ; //X3_DESCSPA
  { 'Dt Validade'															, .T. }, ; //X3_DESCENG
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
  { ''																	, .F. }, ; //X3_OBRIGAT
  { ''																	, .F. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { ''																	, .F. }, ; //X3_WHEN
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

        If aSX3[nI][nJ][2]
          cX3Campo := AllTrim( aEstrut[nJ][1] )
          cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

          If  aEstrut[nJ][2] > 0 .AND. ;
              PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
              PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
              !cX3Campo  == "X3_ORDEM"

            AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
              "   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
              "            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

            RecLock( "SX3", .F. )
            FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
            MsUnLock()
          EndIf
        EndIf
      Next

    EndIf

    oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

  Next nI

  AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  29/07/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
  Local aEstrut   := {}
  Local aSXB      := {}
  Local cAlias    := ""
  Local nI        := 0
  Local nJ        := 0

  AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

  aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
    "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta ALT
//
  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ALT'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta B00
//
  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Itemes'														, ; //XB_DESCSPA
  'Items File'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item Group/Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+RetGrupo()'												} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B00'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+RetGrupo()'												} ) //XB_CONTEM

//
// Consulta B01
//
  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Registro de ítems'														, ; //XB_DESCSPA
  'Items Register'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp and Item Cd'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B01'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B01")'													} ) //XB_CONTEM

//
// Consulta B02
//
  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B02'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B02")'													} ) //XB_CONTEM

//
// Consulta B03
//
  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B03")'													} ) //XB_CONTEM

//
// Consulta B03A
//
  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03A'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B03A")'													} ) //XB_CONTEM

//
// Consulta B03B
//
  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B03B'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B03B")'													} ) //XB_CONTEM

//
// Consulta B04
//
  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo Interno'														, ; //XB_DESCRI
  'Código interno'														, ; //XB_DESCSPA
  'Internal Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B04'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B04")'													} ) //XB_CONTEM

//
// Consulta B05
//
  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B05'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B05")'													} ) //XB_CONTEM

//
// Consulta B06
//
  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B06'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B06")'													} ) //XB_CONTEM

//
// Consulta B07
//
  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item registration'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item grp & item code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código do Item'														, ; //XB_DESCSPA
  'Item code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B07'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

//
// Consulta B08
//
  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Items'														, ; //XB_DESCSPA
  'Item file'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item grp and item cd'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del Item'														, ; //XB_DESCSPA
  'Item group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO==M->VE8_GRUITE .or. Empty(M->VE8_GRUITE)'				} ) //XB_CONTEM

//
// Consulta B08KIT
//
  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B08KIT'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B08KIT")'													} ) //XB_CONTEM

//
// Consulta B09
//
  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Items'														, ; //XB_DESCSPA
  'Item file'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item grp and item cd'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del Item'														, ; //XB_DESCSPA
  'Item group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B09'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO==M->VE8_GRUKIT .or. Empty(M->VE8_GRUKIT)'				} ) //XB_CONTEM

//
// Consulta B10
//
  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B10'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B10")'													} ) //XB_CONTEM

//
// Consulta B11
//
  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grupo e Codigo'														, ; //XB_DESCRI
  'Grupo y Código'														, ; //XB_DESCSPA
  'Group and Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B11'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B11")'													} ) //XB_CONTEM

//
// Consulta B12
//
  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Items Register'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Group and Item'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B12'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B12")'													} ) //XB_CONTEM

//
// Consulta B13
//
  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B13'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B13")'													} ) //XB_CONTEM

//
// Consulta B14
//
  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Items'														, ; //XB_DESCSPA
  'Item file'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item grp and item cd'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del Item'														, ; //XB_DESCSPA
  'Item group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO==M->VEH_GRUKIT .or. Empty(M->VEH_GRUKIT)'				} ) //XB_CONTEM

//
// Consulta B14KIT
//
  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B14KIT'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B14KIT")'													} ) //XB_CONTEM

//
// Consulta B15
//
  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item grp and item co'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B15'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO  = @#M->VOK_GRUITE'											} ) //XB_CONTEM

//
// Consulta B16
//
  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Itemes'														, ; //XB_DESCSPA
  'Items File'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item Group/Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del Item'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+cGruIte'												} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B16'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+cGruIte'												} ) //XB_CONTEM

//
// Consulta B17
//
  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B17'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B17")'													} ) //XB_CONTEM

//
// Consulta B18
//
  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B18'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B18")'													} ) //XB_CONTEM

//
// Consulta B19
//
  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Itemes'														, ; //XB_DESCSPA
  'Items File'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item Group/Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del Item'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  ''																		, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'BAQ->BAQ_CODESP'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  ''																		, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+M->VVM_GRUITE'											} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B19'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+M->VVM_GRUITE'											} ) //XB_CONTEM

//
// Consulta B1Q
//
  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1Q'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_REQUIS $ "13" .AND. SB1->B1_TIPO == SUBS(M->GBQ_CODTES,3,2)'		} ) //XB_CONTEM

//
// Consulta B1R
//
  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1R'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "SB1->B1_TIPO $ '01/02/06/20/16'"										} ) //XB_CONTEM

//
// Consulta B1S
//
  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1S'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'If(M->GAI_REQUIS==' + DUPLAS  + '4' + DUPLAS  + ',.t.,IF(M->GAI_REQUIS ==' + SIMPLES + '1' + SIMPLES + ',SB1->B1_REQUIS $ ' + SIMPLES + '13' + SIMPLES + ',SB1->B1_TIPO = SUBS(M->GAJ_CODTES,3,2))) .AND. SB1->B1_LOCPAD = M->GAI_ALMORI'} ) //XB_CONTEM

//
// Consulta B1SELO
//
  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto Selo'															, ; //XB_DESCRI
  'Producto Selo'															, ; //XB_DESCSPA
  'Seal Product'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SELO'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "SB1->B1_TIPO == 'SL'"													} ) //XB_CONTEM

//
// Consulta B1SGA
//
  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descripcion + Codigo'													, ; //XB_DESCSPA
  'Description + Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo + Codigo'														, ; //XB_DESCRI
  'Grupo + Codigo'														, ; //XB_DESCSPA
  'Group + Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B1SGA'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_TIPO = "RE"'													} ) //XB_CONTEM

//
// Consulta B20
//
  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B20'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B20")'													} ) //XB_CONTEM

//
// Consulta B21
//
  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo do Item'															, ; //XB_DESCRI
  'Grupo del ítem'														, ; //XB_DESCSPA
  'Item Group'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Cod Item'																, ; //XB_DESCRI
  'Cód. Ítem'																, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B21")'													} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+M->VAJ_GRUPEC'											} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B21'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+M->VAJ_GRUPEC'											} ) //XB_CONTEM

//
// Consulta B22
//
  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Cod Item'																, ; //XB_DESCRI
  'Cód. Ítem'																, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B22'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B22")'													} ) //XB_CONTEM

//
// Consulta B23
//
  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'B23'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("B23")'													} ) //XB_CONTEM

//
// Consulta BIAREA
//
  aAdd( aSXB, { ;
    'BIAREA'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Áea Stage'																, ; //XB_DESCRI
  'Aea Stage'																, ; //XB_DESCSPA
  'Stage Area'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'BIAREA'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'BIXSelAreas(@MV_PAR04)'												} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'BIAREA'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '.T.'																	} ) //XB_CONTEM

//
// Consulta BIPROF
//
  aAdd( aSXB, { ;
    'BIPROF'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Perfil de Extração'													, ; //XB_DESCRI
  'Perfil de extracción'													, ; //XB_DESCSPA
  'Extraction Profile'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'BIPROF'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'BIXPrfSXBProfile( @MV_PAR05 )'											} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'BIPROF'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '.T.'																	} ) //XB_CONTEM

//
// Consulta DDT
//
  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DDT'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  ''																		, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '(B1_TIPO == "PA")'														} ) //XB_CONTEM

//
// Consulta DE6
//
  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'DE6'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

//
// Consulta EB1
//
  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta EYUPRD
//
  aAdd( aSXB, { ;
    'EYUPRD'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EYUPRD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'AE109F3PRD()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'EYUPRD'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SYD'																	} ) //XB_CONTEM

//
// Consulta G1Q
//
  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '09'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '10'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '11'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '12'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1Q'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_REQUIS $ "13" .AND. SB1->B1_TIPO == SUBS(M->GBQ_CODTES,3,2)'		} ) //XB_CONTEM

//
// Consulta G1R
//
  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Cod Barras'															, ; //XB_DESCRI
  'Cod Barras'															, ; //XB_DESCSPA
  'Bar Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODBAR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Cod Barra'																, ; //XB_DESCRI
  'Cod Barra'																, ; //XB_DESCSPA
  'Bar Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODBAR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '09'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '10'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1R'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#HS_FILG1R'															} ) //XB_CONTEM

//
// Consulta G1S
//
  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Produto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '09'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '10'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '11'																	, ; //XB_COLUNA
  'Unidade de Consumo'													, ; //XB_DESCRI
  'Unidad de Consumo'														, ; //XB_DESCSPA
  'Consumption Unit'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_SEGUM'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '12'																	, ; //XB_COLUNA
  'Apresentacao'															, ; //XB_DESCRI
  'Presentacion'															, ; //XB_DESCSPA
  'Presentation'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'G1S'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'HS_LOCPAD(SB1->B1_COD, M->GAI_ALMORI)'									} ) //XB_CONTEM

//
// Consulta GBI
//
  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Cod. Lista de Precio'													, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Lista Prec. Mat/Med'													, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GBI'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'IIF(FUNNAME()=="HSPAHM19",SB1->B1_GRUPO==ACOLS[N,NGO1_CODTES], .T.)'		} ) //XB_CONTEM

//
// Consulta GRD
//
  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grade'																	, ; //XB_DESCRI
  'Cuadricula'															, ; //XB_DESCSPA
  'Grid'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'If(A410ProdRf(SB1->B1_COD),SB4->B4_COD,SB1->B1_COD)'					} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'GRD'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'If(a410ProdRf(SB1->B1_COD),PadR(SB4->B4_COD,15),SB1->B1_COD)'			} ) //XB_CONTEM

//
// Consulta HSP001
//
  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Cod Barras'															, ; //XB_DESCRI
  'Cod Barras'															, ; //XB_DESCSPA
  'Barcode'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODBAR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Cod Barras'															, ; //XB_DESCRI
  'Cod Barras'															, ; //XB_DESCSPA
  'Barcode'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODBAR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODBAR'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSP001'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#HS_FILG1R()'															} ) //XB_CONTEM

//
// Consulta HSPSB1
//
  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo Produto'														, ; //XB_DESCRI
  'Codigo Producto'														, ; //XB_DESCSPA
  'Product Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo Produto'														, ; //XB_DESCRI
  'Codigo Producto'														, ; //XB_DESCSPA
  'Product Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Codigo Produto'														, ; //XB_DESCRI
  'Codigo Producto'														, ; //XB_DESCSPA
  'Product Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'HSPSB1'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#HS_FilHB1'															} ) //XB_CONTEM

//
// Consulta MDTEPI
//
  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTEPI'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SXBMDTEPI()'															} ) //XB_CONTEM

//
// Consulta MDTSB1
//
  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'MDTSB1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta N8NPRO
//
  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto Aut. Carrega'													, ; //XB_DESCRI
  'Prod Aut. Carga'														, ; //XB_DESCSPA
  'Product Auto Load'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Filial'																, ; //XB_DESCRI
  'Sucursal'																, ; //XB_DESCSPA
  'Branch'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_FILIAL'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N8NPRO'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#AGRA540FPR()'															} ) //XB_CONTEM

//
// Consulta N92SB1
//
  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto x Tp Oper'														, ; //XB_DESCRI
  'Producto vs Tp Oper'													, ; //XB_DESCSPA
  'Product X Op Tp'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcíon'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'N92SB1'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#AX500PRTP()'															} ) //XB_CONTEM

//
// Consulta NGSB1
//
  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição + Código'													, ; //XB_DESCRI
  'Descripción + Código'													, ; //XB_DESCSPA
  'Description + Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGSB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta NGV
//
  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos com Local'													, ; //XB_DESCRI
  'Productos con Ubic.'													, ; //XB_DESCSPA
  'Prod.in Location'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descripcion + Codigo'													, ; //XB_DESCSPA
  'Description + Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade'																, ; //XB_DESCRI
  'Unidad'																, ; //XB_DESCSPA
  'Unit'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Armazem Pad.'															, ; //XB_DESCRI
  'Almacen Est.'															, ; //XB_DESCSPA
  'Std.Warehouse'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_LOCPAD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Unidade'																, ; //XB_DESCRI
  'Unidad'																, ; //XB_DESCSPA
  'Unit'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_UM'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Armazem Pad.'															, ; //XB_DESCRI
  'Almacen Est.'															, ; //XB_DESCSPA
  'Std.Warehouse'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_LOCPAD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'NGV'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_LOCPAD'														} ) //XB_CONTEM

//
// Consulta PRL
//
  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRL'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '" "'																	} ) //XB_CONTEM

//
// Consulta PRO
//
  aAdd( aSXB, { ;
    'PRO'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRO'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'A060F3Pr()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRO'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta PRT
//
  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '05'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Fornecedor'															, ; //XB_DESCRI
  'Proveedor'																, ; //XB_DESCSPA
  'Supplier'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '05'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Fornecedor'															, ; //XB_DESCRI
  'Proveedor'																, ; //XB_DESCSPA
  'Supplier'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_PROC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '05'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '05'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'PRT'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta QB1
//
  aAdd( aSXB, { ;
    'QB1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'QB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'QB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'QB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'QB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta RE2
//
  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Consulta Produto'														, ; //XB_DESCRI
  'Consulta Produto'														, ; //XB_DESCSPA
  'Consulta Produto'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Referencia Produto+c'													, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Codigo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Ref. Produto'															, ; //XB_DESCRI
  'Ref. Produto'															, ; //XB_DESCSPA
  'Ref. Produto'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREF'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Codigo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Ref. Produto'															, ; //XB_DESCRI
  'Ref. Produto'															, ; //XB_DESCSPA
  'Ref. Produto'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREF'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'RE2'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_LOCPAD$CLINHAATU .AND. SUBSTR(SB1->B1_COD,(LEN(alltrim(SB1->B1_COD))-1),2)=="00"'} ) //XB_CONTEM

//
// Consulta REF
//
  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Referencia Produto'													, ; //XB_DESCRI
  'Referencia Produto'													, ; //XB_DESCSPA
  'Referencia Produto'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Referencia Produto+c'													, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Codigo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREF'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Codigo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREF'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'REF'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_YREF'															} ) //XB_CONTEM

//
// Consulta SB1ARM
//
  aAdd( aSXB, { ;
    'SB1ARM'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Consulta Armamentos'													, ; //XB_DESCRI
  'Consulta armamentos'													, ; //XB_DESCSPA
  'Arsenal query'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ARM'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxProdArm(1)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ARM'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta SB1ATF
//
  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Produtos'													, ; //XB_DESCRI
  'Archivo de Productos'													, ; //XB_DESCSPA
  'Product Register'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1ATF'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SB1AY
//
  aAdd( aSXB, { ;
    'SB1AY'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Publicação de preço'													, ; //XB_DESCRI
  'Publicacion precio'													, ; //XB_DESCSPA
  'Price Discl.'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1AY'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1AY'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1AY'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1AY'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

//
// Consulta SB1BLQ
//
  aAdd( aSXB, { ;
    'SB1BLQ'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos Active'														, ; //XB_DESCRI
  'Productos Activ.'														, ; //XB_DESCSPA
  'Active Products'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1BLQ'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '.T.'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1BLQ'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1BLQ()'																} ) //XB_CONTEM

//
// Consulta SB1CMP
//
  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto Componente'													, ; //XB_DESCRI
  'Producto componente'													, ; //XB_DESCSPA
  'Component Product'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descripción + Código'													, ; //XB_DESCSPA
  'Description + Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo + Codigo'														, ; //XB_DESCRI
  'Grupo + Código'														, ; //XB_DESCSPA
  'Group + Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Tipo + Codigo'															, ; //XB_DESCRI
  'Tipo + Código'															, ; //XB_DESCSPA
  'Type + Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Tipo'																	, ; //XB_DESCRI
  'Tipo'																	, ; //XB_DESCSPA
  'Type'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_TIPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '08'																	, ; //XB_COLUNA
  'Tipo'																	, ; //XB_DESCRI
  'Tipo'																	, ; //XB_DESCSPA
  'Type'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_TIPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '09'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '10'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '11'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '12'																	, ; //XB_COLUNA
  'Tipo'																	, ; //XB_DESCRI
  'Tipo'																	, ; //XB_DESCSPA
  'Type'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_TIPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '13'																	, ; //XB_COLUNA
  'Tipo'																	, ; //XB_DESCRI
  'Tipo'																	, ; //XB_DESCSPA
  'Type'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_TIPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '14'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '15'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '16'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1CMP'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'PCPA134SB1()'															} ) //XB_CONTEM

//
// Consulta SB1COL
//
  aAdd( aSXB, { ;
    'SB1COL'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Consulta de coletes'													, ; //XB_DESCRI
  'Consulta de chalecos'													, ; //XB_DESCSPA
  'Vest query'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1COL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxProdArm(2)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1COL'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta SB1DEF
//
  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'SB1DEF'																, ; //XB_DESCRI
  'SB1DEF'																, ; //XB_DESCSPA
  'SB1DEF'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descripcion + Codigo'													, ; //XB_DESCSPA
  'Description + Produc'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Formato'																, ; //XB_DESCRI
  'Formato'																, ; //XB_DESCSPA
  'Formato'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YFORMAT'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Formato'																, ; //XB_DESCRI
  'Formato'																, ; //XB_DESCSPA
  'Formato'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YFORMAT'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DEF'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_MSBLQL<>"1" .AND. !EMPTY(B1_YFORMAT) .AND. B1_YCLASSE$"2"'			} ) //XB_CONTEM

//
// Consulta SB1DES
//
  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1DES'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

//
// Consulta SB1FIL
//
  aAdd( aSXB, { ;
    'SB1FIL'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Consulta Prod Filial'													, ; //XB_DESCRI
  'Consulta Prod Sucurs'													, ; //XB_DESCSPA
  'Branch Prod. Query'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1FIL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'MAT311SB1()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1FIL'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SB1GE
//
  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Prod Garantia Estend'													, ; //XB_DESCRI
  'Prod Garantia Extend'													, ; //XB_DESCSPA
  'Exted.Warranty Prod.'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Filial'																, ; //XB_DESCRI
  'Sucursal'																, ; //XB_DESCSPA
  'Branch'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_FILIAL'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GE'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GARANT == "1"'													} ) //XB_CONTEM

//
// Consulta SB1GEL
//
  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos Garantia'														, ; //XB_DESCRI
  'Prod. Garantía'														, ; //XB_DESCSPA
  'Warranty Products'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo + Código'														, ; //XB_DESCRI
  'Grupo + Código'														, ; //XB_DESCSPA
  'Group + Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1GEL'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_TIPO == SuperGetMv("MV_LJTPGAR",,"GE") .OR. (SB1->B1_TIPO == SuperGetMv("MV_LJTPSF",,"SF") .AND. POSICIONE("MG8",2,xFilial("MG8")+SB1->B1_COD,"MG8_TPXPRD") == "1")'} ) //XB_CONTEM

//
// Consulta SB1LC2
//
  aAdd( aSXB, { ;
    'SB1LC2'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos Outras Fili'													, ; //XB_DESCRI
  'Productos Otras Suc'													, ; //XB_DESCSPA
  'Other Branch Product'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1LC2'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'At820PrdF3()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1LC2'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'At820PrdRt()'															} ) //XB_CONTEM

//
// Consulta SB1LIK
//
  aAdd( aSXB, { ;
    'SB1LIK'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1LIK'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'STPesqLike()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1LIK'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'STPesqRetVA()'															} ) //XB_CONTEM

//
// Consulta SB1MOD
//
  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto Mão de Obra'													, ; //XB_DESCRI
  'Prod. Mano de obra'													, ; //XB_DESCSPA
  'Labor Product'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MOD'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#MNTA020PMO()'															} ) //XB_CONTEM

//
// Consulta SB1MUN
//
  aAdd( aSXB, { ;
    'SB1MUN'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Consulta Muniçao'														, ; //XB_DESCRI
  'Cons Munición'															, ; //XB_DESCSPA
  'Ammo query'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MUN'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxProdArm(3)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1MUN'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta SB1NGL
//
  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos não Garan'													, ; //XB_DESCRI
  'Prod. no Garant.'														, ; //XB_DESCSPA
  'Non-Warranty Prod.'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NGL'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '(SB1->B1_TIPO <> SuperGetMv("MV_LJTPGAR",, "GE") .AND. SB1->B1_GARANT == "1") .OR. (SB1->B1_TIPO <> SuperGetMv("MV_LJTPSF",, "SF") .AND. POSICIONE("SB0", 1, xFilial("SB0") + SB1->B1_COD, "B0_SERVFIN") == "1")'} ) //XB_CONTEM

//
// Consulta SB1NT3
//
  aAdd( aSXB, { ;
    'SB1NT3'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NT3'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "J99F3SB1('NT3MASTER','NT3_FILDES')"									} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1NT3'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SB1PAI
//
  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PAI'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Empty(SB1->B1_PRODPAI) .Or. (SB1->B1_COD == SB1->B1_PRODPAI)'			} ) //XB_CONTEM

//
// Consulta SB1PCP
//
  aAdd( aSXB, { ;
    'SB1PCP'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos PCP SG1-SGG'													, ; //XB_DESCRI
  'Prod. PCP SG1-SGG'														, ; //XB_DESCSPA
  'PCP SG1-SGG Products'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PCP'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'PCPPergSB1(3)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PCP'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PCP'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_REVATU'														} ) //XB_CONTEM

//
// Consulta SB1PG1
//
  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos Estr.PCP'														, ; //XB_DESCRI
  'Productos Estr.PCP'													, ; //XB_DESCSPA
  'PCP Str. Products'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descricao + Código'													, ; //XB_DESCSPA
  'Description + Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Rev.Estrutura'															, ; //XB_DESCRI
  'Rev.Estructura'														, ; //XB_DESCSPA
  'Structure Rev.'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_REVATU'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Rev.Estrutura'															, ; //XB_DESCRI
  'Rev.Estructura'														, ; //XB_DESCSPA
  'Structure Rev.'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_REVATU'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_REVATU'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PG1'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'PCPPergSB1(1)'															} ) //XB_CONTEM

//
// Consulta SB1PGG
//
  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos P.Estr.PCP'													, ; //XB_DESCRI
  'Prod. P.Estr.PCP'														, ; //XB_DESCSPA
  'PCP Str. P. Products'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PGG'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'PCPPergSB1(2)'															} ) //XB_CONTEM

//
// Consulta SB1PRD
//
  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Código Grupo'															, ; //XB_DESCRI
  'Código Grupo'															, ; //XB_DESCSPA
  'Group Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Código Grupo'															, ; //XB_DESCRI
  'Código Grupo'															, ; //XB_DESCSPA
  'Group Code'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRD'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'MDT183VPRD(.T.)'														} ) //XB_CONTEM

//
// Consulta SB1PRO
//
  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Produtos'																, ; //XB_DESCSPA
  'Produtos'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao + Codigo'													, ; //XB_DESCRI
  'Descripcion + Codigo'													, ; //XB_DESCSPA
  'Description + Produc'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '09'																	, ; //XB_COLUNA
  'Referencia Produto+c'													, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  'Referencia Produto+c'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'REFCOD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Ref. Produto'															, ; //XB_DESCRI
  'Ref. Produto'															, ; //XB_DESCSPA
  'Ref. Produto'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREF'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1PRO'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SB1SFI
//
  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto Garant/Serv.'													, ; //XB_DESCRI
  'Producto Garant/Serv'													, ; //XB_DESCSPA
  'Warr./Serv. Product'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SFI'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_TIPO == SuperGetMv("MV_LJTPSF",, "SF")'						} ) //XB_CONTEM

//
// Consulta SB1SG1
//
  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto produzido'														, ; //XB_DESCRI
  'Producto producido'													, ; //XB_DESCSPA
  'Product produced'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SG1'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#MNT060SB1F()'															} ) //XB_CONTEM

//
// Consulta SB1SUB
//
  aAdd( aSXB, { ;
    'SB1SUB'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Subfamilia'															, ; //XB_DESCRI
  'Subfamilia'															, ; //XB_DESCSPA
  'Subfamily'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SUB'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1SUB()'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1SUB'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_BASE2'															} ) //XB_CONTEM

//
// Consulta SB1VD
//
  aAdd( aSXB, { ;
    'SB1VD'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VD'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VD'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VD'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

//
// Consulta SB1VG
//
  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB1VG'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

//
// Consulta SB2
//
  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SB2'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "SB1->B1_CONTRAT $ 'A*S'"												} ) //XB_CONTEM

//
// Consulta SL2
//
  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_TIPO <> SuperGetMV("MV_LJTPGAR", ,"GE")'						} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SL2'																	, ; //XB_ALIAS
  '8'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'LJ110SXB8("SB1", SB1->(Recno()))'										} ) //XB_CONTEM

//
// Consulta SM0SB1
//
  aAdd( aSXB, { ;
    'SM0SB1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Filial Nivel SB1'														, ; //XB_DESCRI
  'Sucurs.Nivel SB1'														, ; //XB_DESCSPA
  'Branch Level SB1'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SM0SB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'At001F3Fil()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SM0SB1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'At001FilRet()'															} ) //XB_CONTEM

//
// Consulta SZ1
//
  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Produto'																, ; //XB_DESCSPA
  'Produto'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'C¢digo'																, ; //XB_DESCRI
  'C¢digo'																, ; //XB_DESCSPA
  'C¢digo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descri‡„o'																, ; //XB_DESCRI
  'Descri‡„o'																, ; //XB_DESCSPA
  'Descri‡„o'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Grupo'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Cadastra Novo'															, ; //XB_DESCSPA
  'Cadastra Novo'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'C¢digo'																, ; //XB_DESCRI
  'C¢digo'																, ; //XB_DESCSPA
  'C¢digo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descri‡„o'																, ; //XB_DESCRI
  'Descri‡„o'																, ; //XB_DESCSPA
  'Descri‡„o'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREFPV'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'C¢digo'																, ; //XB_DESCRI
  'C¢digo'																, ; //XB_DESCSPA
  'C¢digo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descri‡„o'																, ; //XB_DESCRI
  'Descri‡„o'																, ; //XB_DESCSPA
  'Descri‡„o'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREFPV'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Grupo'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descri‡„o'																, ; //XB_DESCRI
  'Descri‡„o'																, ; //XB_DESCSPA
  'Descri‡„o'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREFPV'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Referencia'															, ; //XB_DESCRI
  'Referencia'															, ; //XB_DESCSPA
  'Referencia'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_YREFPV'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descricao'																, ; //XB_DESCSPA
  'Descricao'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'C¢digo'																, ; //XB_DESCRI
  'C¢digo'																, ; //XB_DESCSPA
  'C¢digo'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'SZ1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_YREFPV'														} ) //XB_CONTEM

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
// Consulta TD2
//
  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Geradores de Gases'													, ; //XB_DESCRI
  'Generadores de Gases'													, ; //XB_DESCSPA
  'Gas Generators'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "01#SG470F3('TD2',0,3)#SG470F3('TD2',0,2,SB1->B1_COD)"					} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TD2'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  "(TD2->(dbSetOrder(1)), TD2->(dbSeek(xFilial('TD2')+SB1->B1_COD)))"		} ) //XB_CONTEM

//
// Consulta TECARM
//
  aAdd( aSXB, { ;
    'TECARM'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Consulta Armamentos'													, ; //XB_DESCRI
  'Consulta Armamentos'													, ; //XB_DESCSPA
  'Query Weapons'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TECARM'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TECFilArm()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TECARM'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TECRetArm()'															} ) //XB_CONTEM

//
// Consulta TECPRD
//
  aAdd( aSXB, { ;
    'TECPRD'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Pesquisa Produtos'														, ; //XB_DESCRI
  'Consulta productos'													, ; //XB_DESCSPA
  'Products Search'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TECPRD'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TECFilSB1()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TECPRD'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TECRetProd()'															} ) //XB_CONTEM

//
// Consulta TMK007
//
  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK007'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '@#Tk510JFilter(2)'														} ) //XB_CONTEM

//
// Consulta TMK019
//
  aAdd( aSXB, { ;
    'TMK019'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produto x Filial'														, ; //XB_DESCRI
  'Producto vs Sucursal'													, ; //XB_DESCSPA
  'Product x Branch'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK019'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TK510PRFIL()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMK019'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta TMKAG8
//
  aAdd( aSXB, { ;
    'TMKAG8'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produtos'																, ; //XB_DESCRI
  'Productos'																, ; //XB_DESCSPA
  'Products'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMKAG8'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TMKAG8()'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMKAG8'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta TMSB1
//
  aAdd( aSXB, { ;
    'TMSB1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Prod.NF - TMS(DTC)'													, ; //XB_DESCRI
  'Prod.NF - TMS(DTC)'													, ; //XB_DESCSPA
  'Prod.NF - TMS(DTC)'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMSB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TM050CPad()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TMSB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'VAR_IXB'																} ) //XB_CONTEM

//
// Consulta TPARMA
//
  aAdd( aSXB, { ;
    'TPARMA'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produto Tipo Arma'														, ; //XB_DESCRI
  'Producto tipo arma'													, ; //XB_DESCSPA
  'Product type wheapon'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPARMA'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxPrdArma(1)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPARMA'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta TPCOLE
//
  aAdd( aSXB, { ;
    'TPCOLE'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produto Tipo Colete'													, ; //XB_DESCRI
  'Prod. Tipo chaleco'													, ; //XB_DESCSPA
  'Product type vest'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPCOLE'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxPrdArma(2)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPCOLE'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta TPMUNI
//
  aAdd( aSXB, { ;
    'TPMUNI'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Produto Tipo Munição'													, ; //XB_DESCRI
  'Prod. Tipo munición'													, ; //XB_DESCSPA
  'Product type ammo'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPMUNI'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxPrdArma(3)'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'TPMUNI'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'TxRetArm()'															} ) //XB_CONTEM

//
// Consulta VAH
//
  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de Itemes'														, ; //XB_DESCSPA
  'Items File'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Item y Cod Item'													, ; //XB_DESCSPA
  'Item Group/Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Codigo del Item'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+ACOLS[N,FG_POSVAR("VAJ_GRUPEC")'						} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VAH'																	, ; //XB_ALIAS
  '7'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'xFilial("SB1")+ACOLS[N,FG_POSVAR("VAJ_GRUPEC")'						} ) //XB_CONTEM

//
// Consulta VB1
//
  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de Itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Grp Item e Cod Item'													, ; //XB_DESCRI
  'Grp Ítem y Cód Ítem'													, ; //XB_DESCSPA
  'Item Grp & Item Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao e Codigo'													, ; //XB_DESCRI
  'Descripción y Código'													, ; //XB_DESCSPA
  'Description & Code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("VB1")'													} ) //XB_CONTEM

//
// Consulta VB1A
//
  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Itens Alternativos'													, ; //XB_DESCRI
  'Itens Alternativos'													, ; //XB_DESCSPA
  'Alternative Items'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_COD'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_COD'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB1A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '04'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

//
// Consulta VB3
//
  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro de itens'														, ; //XB_DESCRI
  'Archivo de ítems'														, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo e codigo do it'													, ; //XB_DESCRI
  'Grupo y código del í'													, ; //XB_DESCSPA
  'Item group and code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao e codigo d'													, ; //XB_DESCRI
  'Descripción y código'													, ; //XB_DESCSPA
  'Description and code'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Código'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VB3'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("VB3")'													} ) //XB_CONTEM

//
// Consulta VPDA
//
  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Itens relacionados'													, ; //XB_DESCRI
  'Items relacionados'													, ; //XB_DESCSPA
  'Listed items'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo e Codigo'														, ; //XB_DESCRI
  'Grupo y Codigo'														, ; //XB_DESCSPA
  'Group and Code'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '05'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '06'																	, ; //XB_COLUNA
  'Codigo'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VPDA'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'iif(Empty(cGrp),.t.,Alltrim(SB1->B1_GRUPO)==Alltrim(cGrp))'			} ) //XB_CONTEM

//
// Consulta VR4
//
  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Produto'																, ; //XB_DESCRI
  'Producto'																, ; //XB_DESCSPA
  'Product'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '03'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_DESC'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '04'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_GRUPO'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Registra Nuevo'														, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Código'																, ; //XB_DESCRI
  'Codigo'																, ; //XB_DESCSPA
  'Code'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_GRUPO'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '03'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descrição'																, ; //XB_DESCRI
  'Descripcion'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VR4'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

//
// Consulta VZ6SB1
//
  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Cadastro Item'															, ; //XB_DESCRI
  'Archivo Ítem'															, ; //XB_DESCSPA
  'Item Register'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '07'																	, ; //XB_COLUNA
  'Cod Item'																, ; //XB_DESCRI
  'Cód. Ítem'																, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Codigo do Item'														, ; //XB_DESCRI
  'Código del ítem'														, ; //XB_DESCSPA
  'Item Code'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_CODITE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'B1_DESC'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SB1->B1_CODITE'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'VZ6SB1'																, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '#FMX_FILSXB("VZ6SB1")'													} ) //XB_CONTEM

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

            RecLock( "SXB", .F. )
            FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
            dbCommit()
            MsUnLock()

            If !( aSXB[nI][1] $ cAlias )
              cAlias += aSXB[nI][1] + "/"
              AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
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
  @ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "PROJC28" ) ) ) ;
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
@since  29/07/21
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
@since  29/07/21
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
