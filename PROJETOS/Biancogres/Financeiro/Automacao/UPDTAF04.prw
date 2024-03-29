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
/*/{Protheus.doc} UPDTAF04
Fun��o de update de dicion�rios para compatibiliza��o

@author TOTVS Protheus
@since  25/03/19
@obs    Gerado por EXPORDIC - V.6.1.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDTAF04( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZA��O DE DICION�RIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun��o fazer  a atualiza��o  dos dicion�rios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n�o podem haver outros"
Local   cDesc3    := "usu�rios  ou  jobs utilizando  o sistema.  � EXTREMAMENTE recomendav�l  que  se  fa�a um"
Local   cDesc4    := "BACKUP  dos DICION�RIOS  e da  BASE DE DADOS antes desta atualiza��o, para que caso "
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

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		If !FWAuthAdmin()
			Final( "Atualiza��o n�o Realizada." )
		EndIf

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualiza��o dos dicion�rios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualiza��o Realizada.", "UPDTAF04" )
				Else
					MsgStop( "Atualiza��o n�o Realizada.", "UPDTAF04" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualiza��o Realizada." )
				Else
					Final( "Atualiza��o n�o Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualiza��o n�o Realizada." )

		EndIf

	Else
		Final( "Atualiza��o n�o Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Fun��o de processamento da grava��o dos arquivos

@author TOTVS Protheus
@since  25/03/19
@obs    Gerado por EXPORDIC - V.6.1.0.1 EFS / Upd. V.5.0.0 EFS
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
		// S� adiciona no aRecnoSM0 se a empresa for diferente
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
				MsgStop( "Atualiza��o da empresa " + aRecnoSM0[nI][2] + " n�o efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZA��O DOS DICION�RIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora �nicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Vers�o.............: " + GetVersao(.T.) )
			AutoGrLog( " Usu�rio TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usu�rio da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Esta��o............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conex�o............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicion�rio SX5
			//------------------------------------
			oProcess:IncRegua1( "Dicion�rio de tabelas sistema" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX5()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualiza��o concluida." From 3, 0 to 340, 417 Pixel

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
/*/{Protheus.doc} FSAtuSX5
Fun��o de processamento da grava��o do SX5 - Indices

@author TOTVS Protheus
@since  25/03/19
@obs    Gerado por EXPORDIC - V.6.1.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX5()
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local cFilSX5   := xFilial( "SX5" )
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX5->X5_FILIAL )

AutoGrLog( "�nicio da Atualiza��o SX5" + CRLF )

aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

//
// Tabela 00
//
aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'00'																	, ; //X5_TABELA
	'58'																	, ; //X5_CHAVE
	'FORMA DE LANCAMENTO - SISPAG'											, ; //X5_DESCRI
	'FORMA DE LANCAMENTO - SISPAG'											, ; //X5_DESCSPA
	'FORMA DE LANCAMENTO - SISPAG'											} ) //X5_DESCENG

//
// Tabela 58
//
aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'01'																	, ; //X5_CHAVE
	'CREDITO EM CONTA CORRENTE'												, ; //X5_DESCRI
	'CREDITO EM CONTA CORRENTE'												, ; //X5_DESCSPA
	'CREDITO EM CONTA CORRENTE'												} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'02'																	, ; //X5_CHAVE
	'CHEQUE PAGAMENTO/ADMINISTRATIVO'										, ; //X5_DESCRI
	'CHEQUE PAGAMENTO/ADMINISTRATIVO'										, ; //X5_DESCSPA
	'CHEQUE PAGAMENTO/ADMINISTRATIVO'										} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'03'																	, ; //X5_CHAVE
	'DOC/TED'																, ; //X5_DESCRI
	'DOC/TED'																, ; //X5_DESCSPA
	'DOC/TED'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'04'																	, ; //X5_CHAVE
	'OP A DISPOSICAO COM AVISO PARA O FAVORECIDO'							, ; //X5_DESCRI
	'OP A DISPOSICAO COM AVISO PARA O FAVORECIDO'							, ; //X5_DESCSPA
	'OP A DISPOSICAO COM AVISO PARA O FAVORECIDO'							} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'05'																	, ; //X5_CHAVE
	'CREDITO EM CONTA POUPANCA'												, ; //X5_DESCRI
	'CREDITO EM CONTA POUPANCA'												, ; //X5_DESCSPA
	'CREDITO EM CONTA POUPANCA'												} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'07'																	, ; //X5_CHAVE
	'TED-CIP'																, ; //X5_DESCRI
	'TED-CIP'																, ; //X5_DESCSPA
	'TED-CIP'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'08'																	, ; //X5_CHAVE
	'TED-STR'																, ; //X5_DESCRI
	'TED-STR'																, ; //X5_DESCSPA
	'TED-STR'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'10'																	, ; //X5_CHAVE
	'OP A DISPOSICAO SEM AVISO PARA O FAVORECIDO'							, ; //X5_DESCRI
	'OP A DISPOSICAO SEM AVISO PARA O FAVORECIDO'							, ; //X5_DESCSPA
	'OP A DISPOSICAO SEM AVISO PARA O FAVORECIDO'							} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'11'																	, ; //X5_CHAVE
	'PAGAMENTO DE CONTAS E TRIBUTOS COM CODIGO DE BARRAS'					, ; //X5_DESCRI
	'PAGAMENTO DE CONTAS E TRIBUTOS COM CODIGO DE BARRAS'					, ; //X5_DESCSPA
	'PAGAMENTO DE CONTAS E TRIBUTOS COM CODIGO DE BARRAS'					} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'13'																	, ; //X5_CHAVE
	'PAGAMENTO A CONCESSIONARIAS'											, ; //X5_DESCRI
	'PAGAMENTO A CONCESSIONARIAS'											, ; //X5_DESCRI
	'PAGAMENTO A CONCESSIONARIAS'											} ) //X5_DESCENG
	
aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'16'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - DARF NORMAL'									, ; //X5_DESCRI
	'TAXES PAYMENT - NORMAL DARF'											, ; //X5_DESCSPA
	'PAGO DE TRIBUTOS - DARF NORMAL'										} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'17'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - GPS'											, ; //X5_DESCRI
	'TAXES PAYMENT - GPS'													, ; //X5_DESCSPA
	'PAGO DE TRIBUTOS - GPS'												} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'18'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - DARF SIMPLES'									, ; //X5_DESCRI
	'TAXES PAYMENT - SIMPLE DARF'											, ; //X5_DESCSPA
	'PAGO DE TRIBUTOS - DARF SIMPLE'										} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'19'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - IPTU PREFEITURAS'								, ; //X5_DESCRI
	'PAGAMENTO DE TRIBUTOS - IPTU PREFEITURAS'								, ; //X5_DESCSPA
	'PAGAMENTO DE TRIBUTOS - IPTU PREFEITURAS'								} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'21'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - DARJ'											, ; //X5_DESCRI
	'TAXES PAYMENT - DARJ'													, ; //X5_DESCSPA
	'PAGO DE TRIBUTOS - DARJ'												} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'25'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - IPVA'											, ; //X5_DESCRI
	'PAGAMENTO DE TRIBUTOS - IPVA'											, ; //X5_DESCSPA
	'PAGAMENTO DE TRIBUTOS - IPVA'											} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'26'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - LICENCIAMENTO'									, ; //X5_DESCRI
	'PAGAMENTO DE TRIBUTOS - LICENCIAMENTO'									, ; //X5_DESCSPA
	'PAGAMENTO DE TRIBUTOS - LICENCIAMENTO'									} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'27'																	, ; //X5_CHAVE
	'PAGAMENTO DE TRIBUTOS - DPVAT'											, ; //X5_DESCRI
	'PAGAMENTO DE TRIBUTOS - DPVAT'											, ; //X5_DESCSPA
	'PAGAMENTO DE TRIBUTOS - DPVAT'											} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'30'																	, ; //X5_CHAVE
	'LIQUIDACAO DE TITULOS EM COBRANCA NO MESMO BANCO'						, ; //X5_DESCRI
	'LIQUIDACAO DE TITULOS EM COBRANCA NO MESMO BANCO'						, ; //X5_DESCSPA
	'LIQUIDACAO DE TITULOS EM COBRANCA NO MESMO BANCO'						} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'31'																	, ; //X5_CHAVE
	'PAGAMENTO DE TITULOS EM OUTRO BANCO'									, ; //X5_DESCRI
	'PAGAMENTO DE TITULOS EM OUTRO BANCO'									, ; //X5_DESCSPA
	'PAGAMENTO DE TITULOS EM OUTRO BANCO'									} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'41'																	, ; //X5_CHAVE
	'TED - Outro Titular'													, ; //X5_DESCRI
	'TED - Another Holder'													, ; //X5_DESCSPA
	'TED - Otro Titular'													} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'43'																	, ; //X5_CHAVE
	'TED - Mesmo titular'													, ; //X5_DESCRI
	'TED - Same Holder'														, ; //X5_DESCSPA
	'TED - Mismo titular'													} ) //X5_DESCENG

aAdd( aSX5, { ;
	cFilSX5																	, ; //X5_FILIAL
	'58'																	, ; //X5_TABELA
	'99'																	, ; //X5_CHAVE
	'GNRE'																	, ; //X5_DESCRI
	'GNRE'																	, ; //X5_DESCSPA
	'GNRE'																	} ) //X5_DESCENG

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	oProcess:IncRegua2( "Atualizando tabelas..." )

	If !SX5->( dbSeek( PadR( aSX5[nI][1], nTamFil ) + aSX5[nI][2] + aSX5[nI][3] ) )
		AutoGrLog( "Item da tabela criado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .T. )
	Else
		AutoGrLog( "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .F. )
	EndIf

	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ

	MsUnLock()

	aAdd( aArqUpd, aSX5[nI][1] )

	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualiza��o" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Fun��o gen�rica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as sele��es feitas.
             Se n�o for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Par�metro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta s� com Empresas
// 3 - Monta s� com Filiais de uma Empresa
//
// Par�metro  aMarcadas
// Vetor com Empresas/Filiais pr� marcadas
//
// Par�metro  cEmpSel
// Empresa que ser� usada para montar sele��o
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

oDlg:cToolTip := "Tela para M�ltiplas Sele��es de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualiza��o"

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
Message "M�scara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Sele��o" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "m�scara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "m�scara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDTAF04" ) ) ) ;
Message "Confirma a sele��o e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplica��o" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Fun��o auxiliar para marcar/desmarcar todos os �tens do ListBox ativo

@param lMarca  Cont�udo para marca .T./.F.
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
Fun��o auxiliar para inverter a sele��o do ListBox ativo

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
Fun��o auxiliar que monta o retorno com as sele��es

@param aRet    Array que ter� o retorno das sele��es (� alterado internamente)
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
Fun��o para marcar/desmarcar usando m�scaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a m�scara (???)
@param lMarDes  Marca a ser atribu�da .T./.F.

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
Fun��o auxiliar para verificar se est�o todos marcados ou n�o

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
Fun��o de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  25/03/19
@obs    Gerado por EXPORDIC - V.6.1.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
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
	MsgStop( "N�o foi poss�vel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN��O" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Fun��o de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  25/03/19
@obs    Gerado por EXPORDIC - V.6.1.0.1 EFS / Upd. V.5.0.0 EFS
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
		cRet += "Tamanho de exibi��o maxima do LOG alcan�ado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
