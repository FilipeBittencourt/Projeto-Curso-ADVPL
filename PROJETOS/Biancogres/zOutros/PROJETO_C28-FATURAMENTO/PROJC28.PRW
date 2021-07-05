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
/*/{Protheus.doc} UPROJC28
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  28/06/21
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPROJC28( cEmpAmb, cFilAmb )

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
            MsgStop( "Atualização Realizada.", "UPROJC28" )
          Else
            MsgStop( "Atualização não Realizada.", "UPROJC28" )
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
@since  28/06/21
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
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  28/06/21
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
  { '01'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_FILIAL'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 2																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Filial'																, .T. }, ; //X3_TITULO
  { 'Sucursal'															, .T. }, ; //X3_TITSPA
  { 'Branch'																, .T. }, ; //X3_TITENG
  { 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
  { 'Sucursal'															, .T. }, ; //X3_DESCSPA
  { 'Branch of the System'												, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_IDXSRV
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '02'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CODIGO'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Cod.Acordo'															, .T. }, ; //X3_TITULO
  { 'Cod.Acordo'															, .T. }, ; //X3_TITSPA
  { 'Cod.Acordo'															, .T. }, ; //X3_TITENG
  { 'Código do Acordo'													, .T. }, ; //X3_DESCRIC
  { 'Código do Acordo'													, .T. }, ; //X3_DESCSPA
  { 'Código do Acordo'													, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { 'GETSXENUM("PZ5","PZ5_CODIGO")'										, .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
  { ''																	, .T. }, ; //X3_CHECK
  { ''																	, .T. }, ; //X3_TRIGGER
  { 'U'																	, .T. }, ; //X3_PROPRI
  { 'S'																	, .T. }, ; //X3_BROWSE
  { 'V'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
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
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '03'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_MARCA'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 4																		, .T. }, ; //X3_TAMANHO
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
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { "'9999'"																, .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
  { ''																	, .T. }, ; //X3_CHECK
  { ''																	, .T. }, ; //X3_TRIGGER
  { 'U'																	, .T. }, ; //X3_PROPRI
  { 'S'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { '€'																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { '#u_FOPMARCA(.T., .T., .F., .T.)'										, .T. }, ; //X3_CBOX
  { '#u_FOPMARCA(.T., .T., .F., .T.)'										, .T. }, ; //X3_CBOXSPA
  { '#u_FOPMARCA(.T., .T., .F., .T.)'										, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '04'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TIPCLI'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo'																, .T. }, ; //X3_TITULO
  { 'Tipo'																, .T. }, ; //X3_TITSPA
  { 'Tipo'																, .T. }, ; //X3_TITENG
  { 'Tipo'																, .T. }, ; //X3_DESCRIC
  { 'Tipo'																, .T. }, ; //X3_DESCSPA
  { 'Tipo'																, .T. }, ; //X3_DESCENG
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
  { '€'																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { '1=CLIENTE;2=GRUPO;3=REDE COMPRAS'									, .T. }, ; //X3_CBOX
  { '1=CLIENTE;2=GRUPO;3=REDE COMPRAS'									, .T. }, ; //X3_CBOXSPA
  { '1=CLIENTE;2=GRUPO;3=REDE COMPRAS'									, .T. }, ; //X3_CBOXENG
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
  { '€'																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOX
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOXSPA
  { 'AG=Acordo Galleria;AO=Acordo de Objetivos;CT=Contrato'				, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '05'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CODCLI'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Cod.Cliente'															, .T. }, ; //X3_TITULO
  { 'Cod.Cliente'															, .T. }, ; //X3_TITSPA
  { 'Cod.Cliente'															, .T. }, ; //X3_TITENG
  { 'Cod. do Cliente'														, .T. }, ; //X3_DESCRIC
  { 'Cod. do Cliente'														, .T. }, ; //X3_DESCSPA
  { 'Cod. do Cliente'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
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
  { 'M->PZ5_TIPCLI=="1"'													, .T. }, ; //X3_WHEN
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '06'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_LOJCLI'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 2																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Loja Cliente'														, .T. }, ; //X3_TITULO
  { 'Loja Cliente'														, .T. }, ; //X3_TITSPA
  { 'Loja Cliente'														, .T. }, ; //X3_TITENG
  { 'Loja Cliente'														, .T. }, ; //X3_DESCRIC
  { 'Loja Cliente'														, .T. }, ; //X3_DESCSPA
  { 'Loja Cliente'														, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { 'M->PZ5_TIPCLI=="1"'													, .T. }, ; //X3_WHEN
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '07'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_NOMCLI'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 30																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Nome Cliente'														, .T. }, ; //X3_TITULO
  { 'Nome Cliente'														, .T. }, ; //X3_TITSPA
  { 'Nome Cliente'														, .T. }, ; //X3_TITENG
  { 'Nome Cliente'														, .T. }, ; //X3_DESCRIC
  { 'Nome Cliente'														, .T. }, ; //X3_DESCSPA
  { 'Nome Cliente'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { 'IIF(!LINCLUIR,POSICIONE("SA1",1,XFILIAL("SA1")+PZ5->PZ5_CODCLI+PZ5->PZ5_LOJCLI,"A1_NOME"),"")', .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
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
  { 'POSICIONE("SA1",1,XFILIAL("SA1")+PZ5->PZ5_CODCLI+PZ5->PZ5_LOJCLI,"A1_NOME")', .T. }, ; //X3_INIBRW
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
  { '08'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CODGRP'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Grp.Clientes'														, .T. }, ; //X3_TITULO
  { 'Grp.Clientes'														, .T. }, ; //X3_TITSPA
  { 'Grp.Clientes'														, .T. }, ; //X3_TITENG
  { 'Grupo de Clientes'													, .T. }, ; //X3_DESCRIC
  { 'Grupo de Clientes'													, .T. }, ; //X3_DESCSPA
  { 'Grupo de Clientes'													, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'ACY'																	, .T. }, ; //X3_F3
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
  { 'M->PZ5_TIPCLI=="2"'													, .T. }, ; //X3_WHEN
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '09'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_DESGRP'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 30																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Des.Grupo'															, .T. }, ; //X3_TITULO
  { 'Des.Grupo'															, .T. }, ; //X3_TITSPA
  { 'Des.Grupo'															, .T. }, ; //X3_TITENG
  { 'Des.Grupo de Cliente'												, .T. }, ; //X3_DESCRIC
  { 'Des.Grupo de Cliente'												, .T. }, ; //X3_DESCSPA
  { 'Des.Grupo de Cliente'												, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { 'IIF(!LINCLUIR,POSICIONE("ACY",1,XFILIAL("ACY")+PZ5->PZ5_CODGRP,"ACY_DESCRI"),"")', .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
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
  { 'POSICIONE("ACY",1,XFILIAL("ACY")+PZ5->PZ5_CODGRP,"ACY_DESCRI")'		, .T. }, ; //X3_INIBRW
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '10'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_REDE'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Rede Compras'														, .T. }, ; //X3_TITULO
  { 'Rede Compras'														, .T. }, ; //X3_TITSPA
  { 'Rede Compras'														, .T. }, ; //X3_TITENG
  { 'Rede Compras'														, .T. }, ; //X3_DESCRIC
  { 'Rede Compras'														, .T. }, ; //X3_DESCSPA
  { 'Rede Compras'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'Z79'																	, .T. }, ; //X3_F3
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
  { 'M->PZ5_TIPCLI=="3"'													, .T. }, ; //X3_WHEN
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
  { '11'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_DESRED'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 30																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Nome Rede'															, .T. }, ; //X3_TITULO
  { 'Nome Rede'															, .T. }, ; //X3_TITSPA
  { 'Nome Rede'															, .T. }, ; //X3_TITENG
  { 'Nome Rede'															, .T. }, ; //X3_DESCRIC
  { 'Nome Rede'															, .T. }, ; //X3_DESCSPA
  { 'Nome Rede'															, .T. }, ; //X3_DESCENG
  { ''																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { 'IIF(!LINCLUIR,POSICIONE("Z79",1,XFILIAL("Z79")+PZ5->PZ5_REDE,"Z79_DESCR"),"")', .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
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
  { 'POSICIONE("Z79",1,XFILIAL("Z79")+PZ5->PZ5_REDE,"Z79_DESCR")'			, .T. }, ; //X3_INIBRW
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
  { '12'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_ANO'																, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 4																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Ano'																	, .T. }, ; //X3_TITULO
  { 'Ano'																	, .T. }, ; //X3_TITSPA
  { 'Ano'																	, .T. }, ; //X3_TITENG
  { 'Ano'																	, .T. }, ; //X3_DESCRIC
  { 'Ano'																	, .T. }, ; //X3_DESCSPA
  { 'Ano'																	, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '13'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_SEQ'																, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Sequencial'															, .T. }, ; //X3_TITULO
  { 'Sequencial'															, .T. }, ; //X3_TITSPA
  { 'Sequencial'															, .T. }, ; //X3_TITENG
  { 'Sequencial'															, .T. }, ; //X3_DESCRIC
  { 'Sequencial'															, .T. }, ; //X3_DESCSPA
  { 'Sequencial'															, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '14'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TIPCAL'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo Calculo'														, .T. }, ; //X3_TITULO
  { 'Tipo Calculo'														, .T. }, ; //X3_TITSPA
  { 'Tipo Calculo'														, .T. }, ; //X3_TITENG
  { 'Tipo Calculo'														, .T. }, ; //X3_DESCRIC
  { 'Tipo Calculo'														, .T. }, ; //X3_DESCSPA
  { 'Tipo Calculo'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { "'R'"																	, .T. }, ; //X3_RELACAO
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
  { ''																	, .T. }, ; //X3_VLDUSER
  { 'R=Receita;V=Volume'													, .T. }, ; //X3_CBOX
  { 'R=Receita;V=Volume'													, .T. }, ; //X3_CBOXSPA
  { 'R=Receita;V=Volume'													, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '15'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CODVEN'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Represent.'															, .T. }, ; //X3_TITULO
  { 'Represent.'															, .T. }, ; //X3_TITSPA
  { 'Represent.'															, .T. }, ; //X3_TITENG
  { 'Representante'														, .T. }, ; //X3_DESCRIC
  { 'Representante'														, .T. }, ; //X3_DESCSPA
  { 'Representante'														, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'SA3'																	, .T. }, ; //X3_F3
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '16'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_NOMVEN'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 30																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Nome Repr.'															, .T. }, ; //X3_TITULO
  { 'Nome Repr.'															, .T. }, ; //X3_TITSPA
  { 'Nome Repr.'															, .T. }, ; //X3_TITENG
  { 'Nome Representante'													, .T. }, ; //X3_DESCRIC
  { 'Nome Representante'													, .T. }, ; //X3_DESCSPA
  { 'Nome Representante'													, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { 'IIF(!LINCLUIR, POSICIONE("SA3",1,XFILIAL("SA3")+M->PZ5_CODVEN,"A3_NOME") ,"")', .T. }, ; //X3_RELACAO
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
  { 'POSICIONE("SA3",1,XFILIAL("SA3")+M->PZ5_CODVEN,"A3_NOME")'			, .T. }, ; //X3_INIBRW
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '17'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TIPACO'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 20																	, .T. }, ; //X3_TAMANHO
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
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '18'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TIPPAG'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 20																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo Pgto.'															, .T. }, ; //X3_TITULO
  { 'Tipo Pgto.'															, .T. }, ; //X3_TITSPA
  { 'Tipo Pgto.'															, .T. }, ; //X3_TITENG
  { 'Tipo de Pagamento'													, .T. }, ; //X3_DESCRIC
  { 'Tipo de Pagamento'													, .T. }, ; //X3_DESCSPA
  { 'Tipo de Pagamento'													, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { '01=Bonificao;02=Desconto pedido;03=Pagamento R$'						, .T. }, ; //X3_CBOX
  { '01=Bonificao;02=Desconto pedido;03=Pagamento R$'						, .T. }, ; //X3_CBOXSPA
  { '01=Bonificao;02=Desconto pedido;03=Pagamento R$'						, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '19'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_NFAIXA'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Num. Faixas'															, .T. }, ; //X3_TITULO
  { 'Num. Faixas'															, .T. }, ; //X3_TITSPA
  { 'Num. Faixas'															, .T. }, ; //X3_TITENG
  { 'Numero de Faixas'													, .T. }, ; //X3_DESCRIC
  { 'Numero de Faixas'													, .T. }, ; //X3_DESCSPA
  { 'Numero de Faixas'													, .T. }, ; //X3_DESCENG
  { ''																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { "'3'"																	, .T. }, ; //X3_RELACAO
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
  { ''																	, .T. }, ; //X3_VLDUSER
  { '1=Uma;2=Duas;3=Tres;4=Quatro;5=Cinco'								, .T. }, ; //X3_CBOX
  { '1=Uma;2=Duas;3=Tres;4=Quatro;5=Cinco'								, .T. }, ; //X3_CBOXSPA
  { '1=Uma;2=Duas;3=Tres;4=Quatro;5=Cinco'								, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '20'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_TIPFIL'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Tipo Filtro'															, .T. }, ; //X3_TITULO
  { 'Tipo Filtro'															, .T. }, ; //X3_TITSPA
  { 'Tipo Filtro'															, .T. }, ; //X3_TITENG
  { 'Tipo Filtro'															, .T. }, ; //X3_DESCRIC
  { 'Tipo Filtro'															, .T. }, ; //X3_DESCSPA
  { 'Tipo Filtro'															, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { "'1'"																	, .T. }, ; //X3_RELACAO
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
  { ''																	, .T. }, ; //X3_VLDUSER
  { '1=Somente Extra;2=Todos'												, .T. }, ; //X3_CBOX
  { '1=Somente Extra;2=Todos'												, .T. }, ; //X3_CBOXSPA
  { '1=Somente Extra;2=Todos'												, .T. }, ; //X3_CBOXENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '21'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_USER'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 20																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Usuario'																, .T. }, ; //X3_TITULO
  { 'Usuario'																, .T. }, ; //X3_TITSPA
  { 'Usuario'																, .T. }, ; //X3_TITENG
  { 'Usuario'																, .T. }, ; //X3_DESCRIC
  { 'Usuario'																, .T. }, ; //X3_DESCSPA
  { 'Usuario'																, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '22'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_DATA'															, .T. }, ; //X3_CAMPO
  { 'D'																	, .T. }, ; //X3_TIPO
  { 8																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Data'																, .T. }, ; //X3_TITULO
  { 'Data'																, .T. }, ; //X3_TITSPA
  { 'Data'																, .T. }, ; //X3_TITENG
  { 'Data'																, .T. }, ; //X3_DESCRIC
  { 'Data'																, .T. }, ; //X3_DESCSPA
  { 'Data'																, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '23'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_HORA'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 5																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Hora'																, .T. }, ; //X3_TITULO
  { 'Hora'																, .T. }, ; //X3_TITSPA
  { 'Hora'																, .T. }, ; //X3_TITENG
  { 'Hora'																, .T. }, ; //X3_DESCRIC
  { 'Hora'																, .T. }, ; //X3_DESCSPA
  { 'Hora'																, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '24'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_STATUS'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Status'																, .T. }, ; //X3_TITULO
  { 'Status'																, .T. }, ; //X3_TITSPA
  { 'Status'																, .T. }, ; //X3_TITENG
  { 'Status'																, .T. }, ; //X3_DESCRIC
  { 'Status'																, .T. }, ; //X3_DESCSPA
  { 'Status'																, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_ORTOGRA
  { ''																	, .T. }, ; //X3_TELA
  { ''																	, .T. }, ; //X3_POSLGT
  { ''																	, .T. }, ; //X3_IDXFLD
  { ''																	, .T. }, ; //X3_AGRUP
  { ''																	, .T. }, ; //X3_MODAL
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '25'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_EMAILC'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 50																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Email WF'															, .T. }, ; //X3_TITULO
  { 'Email WF'															, .T. }, ; //X3_TITSPA
  { 'Email WF'															, .T. }, ; //X3_TITENG
  { 'Email Workflow'														, .T. }, ; //X3_DESCRIC
  { 'Email Workflow'														, .T. }, ; //X3_DESCSPA
  { 'Email Workflow'														, .T. }, ; //X3_DESCENG
  { ''																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { ''																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(65)													, .T. }, ; //X3_RESERV
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
  { ''																	, .T. }} ) //X3_PYME

  aAdd( aSX3, { ;
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '26'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PROVER'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 1																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Provisiona?'															, .T. }, ; //X3_TITULO
  { 'Provisiona?'															, .T. }, ; //X3_TITSPA
  { 'Provisiona?'															, .T. }, ; //X3_TITENG
  { 'Provisiona?'															, .T. }, ; //X3_DESCRIC
  { 'Provisiona?'															, .T. }, ; //X3_DESCSPA
  { 'Provisiona?'															, .T. }, ; //X3_DESCENG
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
  { ''																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '29'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_FREDVB'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { 'F.Red.Ver(%)'														, .T. }, ; //X3_TITULO
  { 'F.Red.Ver(%)'														, .T. }, ; //X3_TITSPA
  { 'F.Red.Ver(%)'														, .T. }, ; //X3_TITENG
  { 'Fator redutor de verba'												, .T. }, ; //X3_DESCRIC
  { 'Fator redutor de verba'												, .T. }, ; //X3_DESCSPA
  { 'Fator redutor de verba'												, .T. }, ; //X3_DESCENG
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
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { ''																	, .T. }, ; //X3_OBRIGAT
  { ''																	, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { 'M->PZ5_PROVER=="S"'													, .T. }, ; //X3_WHEN
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
  { '30'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PACOTE'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 50																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Pacotes'																, .T. }, ; //X3_TITULO
  { 'Pacotes'																, .T. }, ; //X3_TITSPA
  { 'Pacotes'																, .T. }, ; //X3_TITENG
  { 'Pacotes'																, .T. }, ; //X3_DESCRIC
  { 'Pacotes'																, .T. }, ; //X3_DESCSPA
  { 'Pacotes'																, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'X5ZH'																, .T. }, ; //X3_F3
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '31'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PCTVER'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 50																	, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'Pcts p/Verba'														, .T. }, ; //X3_TITULO
  { 'Pcts p/Verba'														, .T. }, ; //X3_TITSPA
  { 'Pcts p/Verba'														, .T. }, ; //X3_TITENG
  { 'Pacotes Calculo Verba'												, .T. }, ; //X3_DESCRIC
  { 'Pacotes Calculo Verba'												, .T. }, ; //X3_DESCSPA
  { 'Pacotes Calculo Verba'												, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'X5ZH'																, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(65)													, .T. }, ; //X3_RESERV
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '32'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PPGSUG'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { '(%)Pgto.Sug.'														, .T. }, ; //X3_TITULO
  { '(%)Pgto.Sug.'														, .T. }, ; //X3_TITSPA
  { '(%)Pgto.Sug.'														, .T. }, ; //X3_TITENG
  { 'Percentual Pgto Sugerido'											, .T. }, ; //X3_DESCRIC
  { 'Percentual Pgto Sugerido'											, .T. }, ; //X3_DESCSPA
  { 'Percentual Pgto Sugerido'											, .T. }, ; //X3_DESCENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '33'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_PPGMAX'															, .T. }, ; //X3_CAMPO
  { 'N'																	, .T. }, ; //X3_TIPO
  { 6																		, .T. }, ; //X3_TAMANHO
  { 2																		, .T. }, ; //X3_DECIMAL
  { '(%)Pgto.Max.'														, .T. }, ; //X3_TITULO
  { '(%)Pgto.Max.'														, .T. }, ; //X3_TITSPA
  { '(%)Pgto.Max.'														, .T. }, ; //X3_TITENG
  { 'Percentual Maximo Pgto.'												, .T. }, ; //X3_DESCRIC
  { 'Percentual Maximo Pgto.'												, .T. }, ; //X3_DESCSPA
  { 'Percentual Maximo Pgto.'												, .T. }, ; //X3_DESCENG
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
    { 'PZ5'																	, .T. }, ; //X3_ARQUIVO
  { '34'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CLFABR'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 9																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'CLVL.Fabrica'														, .T. }, ; //X3_TITULO
  { 'CLVL.Fabrica'														, .T. }, ; //X3_TITSPA
  { 'CLVL.Fabrica'														, .T. }, ; //X3_TITENG
  { 'CLVL para provisoes emp f'											, .T. }, ; //X3_DESCRIC
  { 'CLVL para provisoes emp f'											, .T. }, ; //X3_DESCSPA
  { 'CLVL para provisoes emp f'											, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'CTH'																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
  { ''																	, .T. }, ; //X3_CHECK
  { ''																	, .T. }, ; //X3_TRIGGER
  { 'U'																	, .T. }, ; //X3_PROPRI
  { 'N'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { ''																	, .T. }, ; //X3_OBRIGAT
  { '(Vazio() .Or. ExistCpo("CTH",,1))'									, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { 'M->PZ5_PROVER=="S"'													, .T. }, ; //X3_WHEN
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
  { '35'																	, .T. }, ; //X3_ORDEM
  { 'PZ5_CLDIST'															, .T. }, ; //X3_CAMPO
  { 'C'																	, .T. }, ; //X3_TIPO
  { 9																		, .T. }, ; //X3_TAMANHO
  { 0																		, .T. }, ; //X3_DECIMAL
  { 'CLVL.LM'																, .T. }, ; //X3_TITULO
  { 'CLVL.LM'																, .T. }, ; //X3_TITSPA
  { 'CLVL.LM'																, .T. }, ; //X3_TITENG
  { 'CLVL. Empresa LM'													, .T. }, ; //X3_DESCRIC
  { 'CLVL. Empresa LM'													, .T. }, ; //X3_DESCSPA
  { 'CLVL. Empresa LM'													, .T. }, ; //X3_DESCENG
  { '@!'																	, .T. }, ; //X3_PICTURE
  { ''																	, .T. }, ; //X3_VALID
  { Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
  { ''																	, .T. }, ; //X3_RELACAO
  { 'CTH'																	, .T. }, ; //X3_F3
  { 0																		, .T. }, ; //X3_NIVEL
  { Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
  { ''																	, .T. }, ; //X3_CHECK
  { ''																	, .T. }, ; //X3_TRIGGER
  { 'U'																	, .T. }, ; //X3_PROPRI
  { 'N'																	, .T. }, ; //X3_BROWSE
  { 'A'																	, .T. }, ; //X3_VISUAL
  { 'R'																	, .T. }, ; //X3_CONTEXT
  { ''																	, .T. }, ; //X3_OBRIGAT
  { '(Vazio() .Or. ExistCpo("CTH",,1))'									, .T. }, ; //X3_VLDUSER
  { ''																	, .T. }, ; //X3_CBOX
  { ''																	, .T. }, ; //X3_CBOXSPA
  { ''																	, .T. }, ; //X3_CBOXENG
  { ''																	, .T. }, ; //X3_PICTVAR
  { 'M->PZ5_PROVER=="S"'													, .T. }, ; //X3_WHEN
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
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  28/06/21
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
// Tabela PZ5
//
  aAdd( aSIX, { ;
    'PZ5'																	, ; //INDICE
  '1'																		, ; //ORDEM
  'PZ5_FILIAL+PZ5_CODIGO'													, ; //CHAVE
  'Cod.Acordo'															, ; //DESCRICAO
  'Cod.Acordo'															, ; //DESCSPA
  'Cod.Acordo'															, ; //DESCENG
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
@since  28/06/21
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
// Campo PZ5_CODCLI
//
  aAdd( aSX7, { ;
    'PZ5_CODCLI'															, ; //X7_CAMPO
  '001'																	, ; //X7_SEQUENC
  'SA1->A1_NOME'															, ; //X7_REGRA
  'PZ5_NOMCLI'															, ; //X7_CDOMIN
  'P'																		, ; //X7_TIPO
  'S'																		, ; //X7_SEEK
  'SA1'																	, ; //X7_ALIAS
  1																		, ; //X7_ORDEM
  'XFILIAL("SA1")+M->PZ5_CODCLI+M->PZ5_LOJCLI'							, ; //X7_CHAVE
  'U'																		, ; //X7_PROPRI
  ''																		} ) //X7_CONDIC

//
// Campo PZ5_CODGRP
//
  aAdd( aSX7, { ;
    'PZ5_CODGRP'															, ; //X7_CAMPO
  '001'																	, ; //X7_SEQUENC
  'ACY->ACY_DESCRI'														, ; //X7_REGRA
  'PZ5_DESGRP'															, ; //X7_CDOMIN
  'P'																		, ; //X7_TIPO
  'S'																		, ; //X7_SEEK
  'ACY'																	, ; //X7_ALIAS
  1																		, ; //X7_ORDEM
  'XFILIAL("ACY")+M->PZ5_CODGRP'											, ; //X7_CHAVE
  'U'																		, ; //X7_PROPRI
  ''																		} ) //X7_CONDIC

//
// Campo PZ5_CODVEN
//
  aAdd( aSX7, { ;
    'PZ5_CODVEN'															, ; //X7_CAMPO
  '001'																	, ; //X7_SEQUENC
  'SA3->A3_NOME'															, ; //X7_REGRA
  'PZ5_NOMVEN'															, ; //X7_CDOMIN
  'P'																		, ; //X7_TIPO
  'S'																		, ; //X7_SEEK
  'SA3'																	, ; //X7_ALIAS
  1																		, ; //X7_ORDEM
  'XFILIAL("SA3")+M->PZ5_CODVEN'											, ; //X7_CHAVE
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
@since  28/06/21
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
// Consulta ACY
//
  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Grupos de Clientes'													, ; //XB_DESCRI
  'Grupo de clientes'														, ; //XB_DESCSPA
  'Customer Groups'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'ACY'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '3'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cadastra Novo'															, ; //XB_DESCRI
  'Incluye Nuevo'															, ; //XB_DESCSPA
  'Add New'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  '01#FATA110'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Grupo'																	, ; //XB_DESCRI
  'Grupo'																	, ; //XB_DESCSPA
  'Group'																	, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'ACY_GRPVEN'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descricao'																, ; //XB_DESCRI
  'Descripción'															, ; //XB_DESCSPA
  'Description'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'ACY_DESCRI'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'ACY->ACY_GRPVEN'														} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ACY'																	, ; //XB_ALIAS
  '6'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'J070F3GRUPO()'															} ) //XB_CONTEM

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
// Consulta X5ZH
//
  aAdd( aSXB, { ;
    'X5ZH'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Pacotes de Produtos'													, ; //XB_DESCRI
  'Pacotes de Produtos'													, ; //XB_DESCSPA
  'Pacotes de Produtos'													, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'SX5'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'X5ZH'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'U_F3PACOTE()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'X5ZH'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'U_F3RETPAC()'															} ) //XB_CONTEM

//
// Consulta Z79
//
  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'DB'																	, ; //XB_COLUNA
  'Rede de Compras'														, ; //XB_DESCRI
  'Rede de Compras'														, ; //XB_DESCSPA
  'Rede de Compras'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cód. Rede'																, ; //XB_DESCRI
  'Cód. Rede'																, ; //XB_DESCSPA
  'Cód. Rede'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descr. Rede'															, ; //XB_DESCRI
  'Descr. Rede'															, ; //XB_DESCSPA
  'Descr. Rede'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  ''																		} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cód. Rede'																, ; //XB_DESCRI
  'Cód. Rede'																, ; //XB_DESCSPA
  'Cód. Rede'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79_REDE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descr. Rede'															, ; //XB_DESCRI
  'Descr. Rede'															, ; //XB_DESCSPA
  'Descr. Rede'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79_DESCR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  'Cód. Rede'																, ; //XB_DESCRI
  'Cód. Rede'																, ; //XB_DESCSPA
  'Cód. Rede'																, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79_REDE'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '4'																		, ; //XB_TIPO
  '02'																	, ; //XB_SEQ
  '02'																	, ; //XB_COLUNA
  'Descr. Rede'															, ; //XB_DESCRI
  'Descr. Rede'															, ; //XB_DESCSPA
  'Descr. Rede'															, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79_DESCR'																} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'Z79'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'Z79->Z79_REDE'															} ) //XB_CONTEM

//
// Consulta ZZ6A
//
  aAdd( aSXB, { ;
    'ZZ6A'																	, ; //XB_ALIAS
  '1'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  'RE'																	, ; //XB_COLUNA
  'Formato produtos'														, ; //XB_DESCRI
  'Formato produtos'														, ; //XB_DESCSPA
  'Formato produtos'														, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'ZZ6'																	} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ZZ6A'																	, ; //XB_ALIAS
  '2'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  '01'																	, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'U_F3ZZ6FOR()'															} ) //XB_CONTEM

  aAdd( aSXB, { ;
    'ZZ6A'																	, ; //XB_ALIAS
  '5'																		, ; //XB_TIPO
  '01'																	, ; //XB_SEQ
  ''																		, ; //XB_COLUNA
  ''																		, ; //XB_DESCRI
  ''																		, ; //XB_DESCSPA
  ''																		, ; //XB_DESCENG
  ''																		, ; //XB_WCONTEM
  'U_F3ZZ6PFR()'															} ) //XB_CONTEM

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
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  28/06/21
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
// Helps Tabela PZ5
//
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
  @ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPROJC28" ) ) ) ;
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
@since  28/06/21
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
@since  28/06/21
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
