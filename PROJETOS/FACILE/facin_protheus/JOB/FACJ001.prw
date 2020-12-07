#Include "rwmake.ch"
#Include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} FACJ001
Job para sincronizar os clientes com o FacIN

@author Augusto Pontin
@since 09.01.2020
@version 1.00
/*/

#Define cEOL Chr(13)+Chr(10)

User Function FACJ001(xParam1,xParam2)

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

  cCliShare := SuperGetMV("ZF_SA1SHAR", .F., .T.)

  ConOut('=========#INICIO JOB FACJ001#=========')

  //------------------CLIENTE--------------------------------------
  ConOut("=======================================================")
  ConOut(" CLIENTE ")
  ConOut("=======================================================")
  If cCliShare

    cDateTime	:= DTOC(Date()) + " - " + Time()
    ConOut(cDateTime + ' #FACJ001 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO CLIENTES #')
    U_FACJ001A()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      //|Ponto de entrada para validar se irá executar a filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ001FIL") )
        If !ExecBlock("FJ001FIL",.f.,.f.,{cEmpX,cFilX})
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
      ConOut(cDateTime + ' #FACJ001 - EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + ' - SINCRONIZANDO CLIENTES #')
      U_FACJ001A()

      //|Ponto de entrada para customização no final do processamento de cada filial |
      aAreaSM0 := SM0->(GetArea())
      If ( ExistBlock("FJ001FIM") )
        ExecBlock("FJ001FIM",.f.,.f.,{cEmpX,cFilX})
      EndIf
      RestArea(aAreaSM0)

      Sleep(2000)

      SM0->(dbSkip())

    EndDo

  EndIf

  cDateTime	:= DTOC(Date()) + " - " + Time()
  ConOut(cDateTime + ' #FACJ001 - FINAL EMPRESA ' + cEmpAnt + ' FILIAL ' + cFilAnt + '#')
  ConOut('=========#FIM JOB FACJ001#=========')
  ConOut("")

  RESET ENVIRONMENT

Return


User Function FACJ001A()

  Local oObJ 			:= ""

  oObJ := TFacINClienteController():New()
  // oObj:EditarFacIN() // Dados do PROTHEUS  para o FACIN
  oObj:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  // oObj:CriarPTH()    // Dados do FACIN para o PROTHEUS


Return