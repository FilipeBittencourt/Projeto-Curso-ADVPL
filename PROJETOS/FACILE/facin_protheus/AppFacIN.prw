/*/{Protheus.doc} AppFacIN
@importante: Precisa criar os campos de auditoria USERLGI e USERLGA nas tabelas:
SA1, SB1, SBM, SAH, SE4, SC5, SB2

@importante: Precisa criar os campos abaixo:
	C5_YFACIN  - tipo numerico, valor padrão zero. - Salva o Id do pedido de venda vindo do FACIN
	C5_YFASYNC - tipo caracter. - 
				 Sincronizacao com o FacIN para não chamar varias vezes.  
				 Sincronizado?  (S) para sim <<APENAS QUANDO EXISTIR NF C5_NOTA>> ou (N) para não.

@author Filipe Bittencourt / Facile Sistemas
@since 13/08/2019
@version 1.0
/*/

#include "tbiconn.ch"
#include "protheus.ch"


User Function AppFacIN(xParam1,xParam2)

  Local cEmp			:= ""
  Local cFil			:= ""
  Local cEmpX			:= ""
  Local cFilX			:= ""
  Default xParam1 := "99"
  Default xParam2 := "01"

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

  RpcSetType(3)
  RpcSetEnv(cEmp,cFil,,,"FAT")

  cCliShare		:= SuperGetMV("ZF_SA1SHAR", .F., .T.)
  cProdShare	:= SuperGetMV("ZF_SB1SHAR", .F., .T.)
  cGrupShare	:= SuperGetMV("ZF_SBMSHAR", .F., .T.)
  cUnMedShare	:= SuperGetMV("ZF_SAHSHAR", .F., .T.)
	/*
		SFM - Tes Inteligente. O cadastro das regras de preenchimento do código do TES está 
		vinculado com um código de tipo de 	movimentação (FM_TIPO), por exemplo: 
		01 - Venda de Mercadorias,
		02 - Simples Remessa de Material, 
		03 - Venda para Consumidor Final
	*/
  cTipOTES 	:= SuperGetMV("ZF_TIPOTES", .F., "03")

  //|Cria os parametros utilizados na rotina |
  U_LFParam()

  //------------------CLIENTE--------------------------------------
  ConOut("=======================================================")
  ConOut(" CLIENTE ")
  ConOut("=======================================================")
  If cCliShare

    U_fIntCliente()

  else

    dbSelectArea("SM0")
    SM0->(dbSetOrder(1))
    SM0->(dbSeek(cEmp))

    While !SM0->(EoF()) .And. AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp)

      cFilX	:= SM0->M0_CODFIL
      cEmpX	:= SM0->M0_CODIGO

      RESET ENVIRONMENT

      Sleep(100)

      //|Inicializa ambiente |
      RpcSetType(3)
      RpcSetEnv(cEmpX,cFilX,,,"FAT")

      U_fIntCliente()

      SM0->(dbSkip())

    EndDo

  EndIf


  //------------------Unidade de Medida-----------------------------

  // oObJ := TFacINUnidadeMedidaController():New()
  // ConOut("=======================================================")
  // ConOut(" Unidade de Medida ")
  // ConOut("=======================================================")
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN
  // oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN



  //------------------GRUPO de PRODUTO-----------------------------  100%
  //oObJ := TFacINProdutoGrupoController():New()
  //ConOut("=======================================================")
  //ConOut(" GRUPO de PRODUTO")
  //ConOut("=======================================================")
  //oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  //oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN


  //------------------PRODUTO--------------------------------------
  oObJ := TFacINProdutoController():New()
  ConOut("=======================================================")
  ConOut(" PRODUTO")
  ConOut("=======================================================")
  oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  //oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN


  //------------------PEDIDO DE VENDA--------------------------------------
  // oObJ := TFacINCondicaoPagamentoController():New()
  // ConOut("=======================================================")
  // ConOut(" CONDICAO DE PAGEMENTO ")
  // ConOut("=======================================================")
  // oObJ:CriarFacIN()  // Dados do PROTHEUS  para o FACIN
  // oObJ:EditarFacIN() // Dados do PROTHEUS  para o FACIN
  // oObJ:CriarPTH() // Dados do PROTHEUS  para o FACIN


  //------------------PEDIDO DE VENDA--------------------------------------
  // oObJ := TFacINPedidoVendaController():New()
  // ConOut("=======================================================")
  // ConOut(" PEDIDO DE VENDA ")
  // ConOut("=======================================================")
  // oObJ:CriarPTH()


  // //------------------PEDIDO DE VENDA--------------------------------------
  // oObJ := TFacINNFeController():New()
  // ConOut("=======================================================")
  // ConOut(" NF-e  de Venda -  SD2 ")
  // ConOut("=======================================================")
  // oObJ:EditarFacIN()




Return .T.


User Function fIntCliente(lAll)

  Local oObJ 			:= ""

	/*oObJ := TFacINClienteController():New()*/
  // oObj:EditarFacIN() // Dados do PROTHEUS  para o FACIN
	/*oObj:CriarFacIN()  // Dados do PROTHEUS  para o FACIN*/
  // oObj:CriarPTH()    // Dados do FACIN para o PROTHEUS


Return
