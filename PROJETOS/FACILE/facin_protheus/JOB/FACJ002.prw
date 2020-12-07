#Include "rwmake.ch"
#Include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} FACJ002
Job para sincronizar os dados com o FacIN

@author Augusto Pontin
@since 14.01.2020
@version 1.00
/*/

#Define cEOL Chr(13)+Chr(10)

User Function FACJ002(xParam1,xParam2)

  Local aAreaSM0	    := {}
  Local cEmp		      := ""
  Local cFil		      := ""
  Local cEmpX		      := ""
  Local cFilX		      := ""

  Private cCliShare		:= ""

  If ValType(xParam1) == "A"
    cEmp 		:= xParam1[1]
    cFil 		:= xParam1[2]
  ElseIf ValType(xParam1) == "C"
    cEmp 		:= xParam1
    cFil 		:= xParam2
  Else
    ConOut('## ERROR - NÃO FOI INFORMADO EMPRESA E FILIAL ##')
    ConOut('## ERROR - FIM DO JOB ##')
    Return
  EndIf

  If Empty(cEmp)
    cEmp	:= "01"
    cFil	:= "01"
  EndIf

  //|Inicializa ambiente |
  RpcSetType(3)
  PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES 'SC5' MODULO 'FAT'

  //|Cria os parametros utilizados na rotina |
  U_LFParam()

  cProdShare      := SuperGetMV("ZF_SB1SHAR", .F., .T.)
  cUnMedShare	    := SuperGetMV("ZF_SAHSHAR", .F., .T.)
  cCondPgtoShare	:= SuperGetMV("ZF_SE4SHAR", .F., .T.)
  cGrupoShare	    := SuperGetMV("ZF_SBMSHAR", .F., .T.)

  ConOut('=========#INICIO JOB FACJ002#=========')

  //------------------UNIDADE DE MEDIDA--------------------------------------
  ConOut("=======================================================")
  ConOut(" UNIDADE DE MEDIDA ")
  ConOut("=======================================================")
  If cUnMedShare

    cDateTime	:= DTOC(Date()) + " - " + Time()
    ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO UNIDADE MEDIDA #')
    U_FACJ002A()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      //|Ponto de entrada para validar se irá executar a filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIL") )
        If !ExecBlock("FJ002FIL",.f.,.f.,{cEmpX,cFilX})
          SM0->(dbSkip())
          Loop
        EndIf
      EndIf
      RestArea(aAreaSM0)

      RESET ENVIRONMENT

      Sleep(100)

      //|Inicializa ambiente |
      RpcSetType(3)
      PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX

      cDateTime	:= DtoC(Date()) + " - " + Time()
      ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO UNIDADE MEDIDA #')
      U_FACJ002A()

      //|Ponto de entrada para customização no final do processamento de cada filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIM") )
        ExecBlock("FJ002FIM",.f.,.f.,{cEmpX,cFilX})
      EndIf
      RestArea(aAreaSM0)

      Sleep(2000)

      SM0->(dbSkip())

    EndDo

  EndIf

  //------------------CONDI��O DE PAGAMENTO--------------------------------------
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut(" UNIDADE DE MEDIDA ")
  ConOut("=======================================================")
  If cCondPgtoShare

    cDateTime	:= DTOC(Date()) + " - " + Time()
    ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO CONDICAO DE PAGAMENTO #')
    U_FACJ002B()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      //|Ponto de entrada para validar se irá executar a filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIL") )
        If !ExecBlock("FJ002FIL",.f.,.f.,{cEmpX,cFilX})
          SM0->(dbSkip())
          Loop
        EndIf
      EndIf
      RestArea(aAreaSM0)

      RESET ENVIRONMENT

      Sleep(100)

      //|Inicializa ambiente |
      RpcSetType(3)
      PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX

      cDateTime	:= DtoC(Date()) + " - " + Time()
      ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO CONDICAO DE PAGAMENTO #')
      U_FACJ002B()

      //|Ponto de entrada para customização no final do processamento de cada filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIM") )
        ExecBlock("FJ002FIM",.f.,.f.,{cEmpX,cFilX})
      EndIf
      RestArea(aAreaSM0)

      Sleep(2000)

      SM0->(dbSkip())

    EndDo

  EndIf

  //------------------GRUPO DE PRODUTO--------------------------------------
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut(" GRUPO DE PRODUTO ")
  ConOut("=======================================================")
  If cGrupoShare

    cDateTime	:= DTOC(Date()) + " - " + Time()
    ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO GRUPO DE PRODUTO #')
    U_FACJ002C()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      //|Ponto de entrada para validar se irá executar a filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIL") )
        If !ExecBlock("FJ002FIL",.f.,.f.,{cEmpX,cFilX})
          SM0->(dbSkip())
          Loop
        EndIf
      EndIf
      RestArea(aAreaSM0)

      RESET ENVIRONMENT

      Sleep(100)

      //|Inicializa ambiente |
      RpcSetType(3)
      PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX

      cDateTime	:= DtoC(Date()) + " - " + Time()
      ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO GRUPO DE PRODUTO #')
      U_FACJ002C()

      //|Ponto de entrada para customização no final do processamento de cada filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIM") )
        ExecBlock("FJ002FIM",.f.,.f.,{cEmpX,cFilX})
      EndIf
      RestArea(aAreaSM0)

      Sleep(2000)

      SM0->(dbSkip())

    EndDo

  EndIf

  //------------------PRODUTOS--------------------------------------
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut("=======================================================")
  ConOut(" PRODUTOS ")
  ConOut("=======================================================")
  If cGrupoShare

    cDateTime	:= DTOC(Date()) + " - " + Time()
    ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO PRODUTOS #')
    U_FACJ002D()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      //|Ponto de entrada para validar se irá executar a filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIL") )
        If !ExecBlock("FJ002FIL",.f.,.f.,{cEmpX,cFilX})
          SM0->(dbSkip())
          Loop
        EndIf
      EndIf
      RestArea(aAreaSM0)

      RESET ENVIRONMENT

      Sleep(100)

      //|Inicializa ambiente |
      RpcSetType(3)
      PREPARE ENVIRONMENT EMPRESA cEmpX FILIAL cFilX

      cDateTime	:= DtoC(Date()) + " - " + Time()
      ConOut(cDateTime + ' #FACJ002 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO PRODUTOS #')
      U_FACJ002D()

      //|Ponto de entrada para customização no final do processamento de cada filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ002FIM") )
        ExecBlock("FJ002FIM",.f.,.f.,{cEmpX,cFilX})
      EndIf
      RestArea(aAreaSM0)

      Sleep(2000)

      SM0->(dbSkip())

    EndDo

  EndIf


  cDateTime	:= DTOC(Date()) + " - " + Time()
  ConOut(cDateTime + ' #FACJ002 - FINAL EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + '#')
  ConOut('=========#FIM JOB FACJ002#=========')
  ConOut("")

  RESET ENVIRONMENT

Return


User Function FACJ002A()

  Local oObJ 			:= ""

  oObJ := TFacINUnidadeMedidaController():New()
  ConOut("=======================================================")
  ConOut(" Unidade de Medida ")
  ConOut("=======================================================")
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN
  oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN


Return


User Function FACJ002B()

  Local oObJ 			:= ""

  oObJ := TFacINCondicaoPagamentoController():New()
  ConOut("=======================================================")
  ConOut(" CONDICAO DE PAGAMENTO ")
  ConOut("=======================================================")
  oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN
  // oObJ:CriarPTH() // Dados do PROTHEUS  para o FACIN


Return


User Function FACJ002C()

  Local oObJ 			:= ""

  oObJ := TFacINProdutoGrupoController():New()
  ConOut("=======================================================")
  ConOut(" GRUPO DE PRODUTO ")
  ConOut("=======================================================")
  oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN

Return


User Function FACJ002D()

  Local oObJ 			:= ""

  oObJ := TFacINProdutoController():New()
  ConOut("=======================================================")
  ConOut(" PRODUTO ")
  ConOut("=======================================================")
  oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN

Return