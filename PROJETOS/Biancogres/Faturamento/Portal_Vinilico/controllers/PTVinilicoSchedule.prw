#include 'totvs.ch'
#include 'topconn.ch'
#include 'fileio.ch'

/*/{Protheus.doc} PTVinilicoSchedule
Classe responsável por gerenciar os schedules
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 25/08/2020
/*/
Class PTVinilicoSchedule From PTVinilicoAbstractAPI

  Data cFilExec
  Data cEmpExec
  Data cDirLog
  Data cFileLog
  Data nHnd

  Method New() Constructor

  Method PrepareEnv()
  Method GetFiliais()

  Method BeginLog()
  Method LogMessage()
  Method EndLog()

  Method CreateFolder()
  Method EraseOld()

  Method BeginMutex()
  Method EndMutex()

EndClass


/*/{Protheus.doc} PTVinilicoSchedule::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 03/09/2020
/*/
Method New() Class PTVinilicoSchedule

  _Super:New()

  ::cFilExec    := ""
  ::cEmpExec    := ""
  ::cFileLog    := ""
  ::cDirLog     := IIf(IsSrvUnix(),"/facile/nao_apagar/vinilico/", "\facile\nao_apagar\vinilico\")
  ::nHnd        := 0

  //|Cria diretorio para os logs |
  ::CreateFolder()
  ::EraseOld()

Return


/*/{Protheus.doc} PTVinilicoSchedule::PrepareEnv
Realiza a inicialização do ambiente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 03/09/2020
@return logical, informa se conseguiu preparar o ambiene
/*/
Method PrepareEnv() Class PTVinilicoSchedule

  Local lOk       := .F.
  Local lRpcSet   := .T.
  Local aTables   := { "SC5", "SC6", "SE4", "DA0", "DA1", "SB1", "SB5", "SB2" }

  //|Caso já tenha ambiente aberto |
  If Select("SX6") > 0

    lRpcSet := !( cEmpAnt == ::cEmpExec .And. ::cFilExec == cFilAnt )

    If lRpcSet
      RpcClearEnv()
    Else
      lOk := .T.
    EndIf

  EndIf

  //|Inicializa ambiente |
  If lRpcSet

    RpcSetType(3)
    RpcSetEnv( ::cEmpExec, ::cFilExec,,, "FAT",, aTables,,,, )

    lOk   := .T.

  EndIf

Return lOk


/*/{Protheus.doc} PTVinilicoSchedule::GetFiliais
Método para retornar os dados das filiais da empresa
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 03/09/2020
@return array, filiais da empresa
/*/
Method GetFiliais() Class PTVinilicoSchedule

  Local nI          := 0
  Local aSM0	      := FWLoadSM0()
  Local aFiliais    := {}
  Local jFilial	    := Nil

  For nI := 1 To Len(aSM0)

    If aSM0[nI, 1] == ::cEmpExec

      jFilial	  := JsonObject():New()

      jFilial["M0_GRPEMP"]	  := aSM0[nI, 1]
      jFilial["M0_CODFIL"]	  := aSM0[nI, 2]
      jFilial["M0_EMPRESA"]	  := aSM0[nI, 3]
      jFilial["M0_UNIDNEG"]	  := aSM0[nI, 4]
      jFilial["M0_FILIAL"]	  := aSM0[nI, 5]
      jFilial["M0_NOME"]		  := aSM0[nI, 6]
      jFilial["M0_NOMRED"]	  := aSM0[nI, 7]
      jFilial["M0_SIZEFIL"]	  := aSM0[nI, 8]
      jFilial["M0_LEIAUTE"]	  := aSM0[nI, 9]
      jFilial["M0_EMPOK"]		  := aSM0[nI, 10]
      jFilial["M0_USEROK"]	  := aSM0[nI, 11]
      jFilial["M0_RECNO"]		  := aSM0[nI, 12]
      jFilial["M0_LEIAEMP"]	  := aSM0[nI, 13]
      jFilial["M0_LEIAUN"]	  := aSM0[nI, 14]
      jFilial["M0_LEIAFIL"]	  := aSM0[nI, 15]
      jFilial["M0_STATUS"]	  := aSM0[nI, 16]
      jFilial["M0_NOMECOM"]	  := aSM0[nI, 17]
      jFilial["M0_CGC"]	      := aSM0[nI, 18]
      jFilial["M0_DESCEMP"]	  := aSM0[nI, 19]
      jFilial["M0_DESCUN"]	  := aSM0[nI, 20]
      jFilial["M0_DESCGRP"]	  := aSM0[nI, 21]
      jFilial["M0_IDMID"]		  := aSM0[nI, 22]
      jFilial["M0_PICTURE"]	  := aSM0[nI, 23]

      aAdd( aFiliais, jFilial )

    EndIf

  Next nI

Return aFiliais


/*/{Protheus.doc} PTVinilicoSchedule::CreateFolder
Método para criar o diretório para os logs
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Method CreateFolder() Class PTVinilicoSchedule

  If !ExistDir( ::cDirLog )

    FWMakeDir( ::cDirLog )

  EndIf

Return


/*/{Protheus.doc} PTVinilicoSchedule::EraseOld
Método para limpar logs antigos
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Method EraseOld() Class PTVinilicoSchedule

  Local nDiasManter   := 10
  Local nS            := 0
  Local aLogs         := {}

  aLogs := Directory( ::cDirLog + "*.log" )

  For nS := 1 To Len( aLogs )

    //|Apaga log antigo |
    If DateDiffDay( Date() , aLogs[nS, 3] ) > nDiasManter
      FErase( ::cDirLog + aLogs[nS, 1] )
    EndIf

  Next nS

Return


/*/{Protheus.doc} PTVinilicoSchedule::BeginLog
Metódo para criar o arquivo de log
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
@return logical, informa se conseguiu criar o arquivo
/*/
Method BeginLog() Class PTVinilicoSchedule

  Local lOk   := .T.

  ::nHnd := fCreate( ::cDirLog + ::cFileLog )

  If ::nHnd == -1
    _Super:Comunica("Falha ao criar arquivo [" +::cDirLog + ::cFileLog + "]","FERROR "+cValToChar( fError() ) )
    lOk   := .F.
  Endif

Return lOk


/*/{Protheus.doc} PTVinilicoSchedule::LogMessage
Método para gravar a informação do log
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
@param cMsgLog, character, Mensagem a ser escrita
/*/
Method LogMessage( cMsgLog ) Class PTVinilicoSchedule

  Local cPreMsg   := DtoC( Date() ) + " - " + Time() + ' - ' + cEmpAnt + '/' + cFilAnt + ' - '

  cMsgLog := cPreMsg + cMsgLog

  fWrite( ::nHnd, cMsgLog )

  ConOut(cMsgLog)

Return


/*/{Protheus.doc} PTVinilicoSchedule::EndLog
Método para finalizar o arquivo de log
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Method EndLog() Class PTVinilicoSchedule

  //|Fecha o arquivo de log |
  fClose( ::nHnd )

Return


/*/{Protheus.doc} PTVinilicoSchedule::BeginMutex
Método para iniciar o controle de semaforo
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 08/09/2020
@param cLockName, character, nome do arquivo de lock
@return logical, indica se conseguiu dar lock no nome
/*/
Method BeginMutex( cLockName ) Class PTVinilicoSchedule

  Local lOk     := .F.

  lOk   := LockByName( cLockName, .T., .T. )

Return lOk


/*/{Protheus.doc} PTVinilicoSchedule::EndMutex
Desbloqueia o controle de lock
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 29/12/2020
@param cLockName, character, nome do lock
/*/
Method EndMutex( cLockName ) Class PTVinilicoSchedule

  UnLockByName( cLockName, .T., .T. )

Return
