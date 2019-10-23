#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TFZImprimeEtiqueta
@description Classe para impressão de etiqueta zebra
@author Pontin
@since 14.01.19
@version 1.0
/*/
Class TFZImprimeEtiqueta From LongClassName

	Data cQrCode		//|Armazena a string para o QrCode |
	Data cEtiqZPL		//|Código ZPL para impressão da etiqueta |
	Data cRastro		//|Codigo do rastreio |
	Data cCodServ		//|Codigo do serviço A4_YSERVIC |
	Data nVlrDeclarado	//|Valor declarado F2_VALBRUT |
	Data cNumLog		//|Numero do logradouro |
	Data cPLP			//|Numero da PLP |
	Data cContrato		//|Contrato |
	Data cTpContrato	//|Tipo de Contrato |
	Data cCartao		//|Cartão Postal |
	Data cPrinter		//|Impressora selecionada |

	Data cChvSC5
	Data nSC5Indice

	Data cChvSA1
	Data nSA1Indice

	Method New() Constructor

	Method ImprimeZPL()
	Method MontaZPL()
	Method LimpVar()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
description método construtor da classe
@author  Pontin
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class TFZImprimeEtiqueta

	::LimpVar()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da rotina
@author  Pontin
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LimpVar() Class TFZImprimeEtiqueta

	::cQrCode		:= ""
	::cEtiqZPL		:= ""
	::cRastro		:= ""
	::cCodServ		:= ""
	::nVlrDeclarado	:= 0
	::cNumLog		:= "0"
	::cPLP			:= ""
	::cContrato		:= ""
	::cTpContrato	:= ""
	::cCartao		:= ""
	::cPrinter		:= ""

	::cChvSC5		:= ""
	::nSC5Indice	:= 1

	::cChvSA1		:= ""
	::nSA1Indice	:= 1

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaQrCode
description Monta o código ZPL para etiquetas de contrato
@author  Pontin
@since   15.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method MontaZPL() Class TFZImprimeEtiqueta

	Local cZPLModelo	:= ""
	Local cCarimbo		:= ""
	Local cLocalZPL		:= "\FACILE\ZPL_MODELO.txt"
	Local cLocalPac		:= "\FACILE\PAC.txt"
	Local cLocalSedex	:= "\FACILE\SEDEX.txt"
	Local cBusca		:= ""
	Local oFile			:= Nil
	Local oPedVendD		:= Nil
	Local oPedVenda		:= Nil
	Local oClienteD		:= Nil
	Local oCliente		:= Nil
	Local oQrCode		:= Nil
	Local lRet			:= .F.

	If Type('oSigep') <> 'O'
		oSigep	:= ServSigep():New()
	EndIf

	//|Busca o ZPL de modelo |
	oFile := FWFileReader():New(cLocalZPL)
	If (oFile:Open())

		While (oFile:HasLine())
			cZPLModelo += oFile:GetLine()
		EndDo

		oFile:Close()

	EndIf

	//|Busca Carimbo dos Correios |
	If ::cTpContrato == "PAC"
		oFile := FWFileReader():New(cLocalPac)
	Else
		oFile := FWFileReader():New(cLocalSedex)
	EndIf

	If (oFile:Open())

		While (oFile:HasLine())
			cCarimbo += oFile:GetLine()
		EndDo

		oFile:Close()

	EndIf

	If !Empty(cZPLModelo)

		//|Busca dados do pedido |
		oPedVendD 	:= TEZPedidoVendaController():New()
		oPedVenda	:= oPedVendD:Get(::cChvSC5, ::nSC5Indice)

		//|Busca dados do cliente |
		oClienteD 	:= TEZClienteController():New()
		oCliente 	:= oClienteD:Get(::cChvSA1, ::nSA1Indice)

		//|Monta o QRCode |
		oQrCode		:= TZEBRAqrcode():New()
		oQrCode:cCEPDest	:= oCliente:cCEP
		oQrCode:cCEPOrig	:= SM0->M0_CEPCOB
		oQrCode:cIDV		:= "51"
		oQrCode:cEtiquet	:= SubStr(::cRastro, 1, 13)
		oQrCode:cServAdd	:= "250119"
		oQrCode:cCarPost	:= oSigep:cCartao
		oQrCode:cCodServ	:= SubStr(::cCodServ, 1, 5)
		oQrCode:cInfoAgr	:= "00"
		oQrCode:cNLograd	:= ::cNumLog
		oQrCode:cCLograd	:= oCliente:cComplem
		oQrCode:cVlrDecl	:= cValTochar(Round(::nVlrDeclarado, 0))
		oQrCode:cTelDest	:= AllTrim(oCliente:cDDD) + AllTrim(oCliente:cTelefone)

		::cQrCode	:= oQrCode:GeraQRCODE(oQrCode)

		//|Carimbo dos Correios |
		cBusca		:= "<CARIMBO_CORREIOS>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,cCarimbo))

		//|DataMatrix |
		cBusca		:= "<DATAMATRIX>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,::cQrCode))

		//|Nota Fiscal |
		cBusca		:= "<NOTA_FISCAL>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,oPedVenda:cPedNF))

		//|Numero do PLP |
		cBusca		:= "<PLP>"
		//cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,::cPLP))
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,''))

		//|Numero do Contrato |
		cBusca		:= "<CONTRATO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,::cContrato))

		//|Tipo do Contrato |
		cBusca		:= "<TIPO_CONTRATO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,::cTpContrato))

		//|Codigo de barras - Rastro |
		cBusca		:= "<RASTREIO_BARCODE>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,::cRastro))

		//|Nome do Destinatário |
		cBusca		:= "<NOME_DEST>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cRazClient)))

		//|Endereço do Destinatário |
		cBusca		:= "<ENDERECO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cEndereco)))

		//|Complemento do Destinatário |
		cBusca		:= "<COMPLEMENTO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cComplem)))

		//|Cidade do Destinatário |
		cBusca		:= "<CIDADE>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cMunClient)))

		//|CEP do Destinatário |
		cBusca		:= "<CEP_DESTINO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cCEP)))

		//|UF do Destinatário |
		cBusca		:= "<UF_DEST>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cUF)))

		//|Codigo de barras do CEP do Destinatário |
		cBusca		:= "<CEP_DEST_BARCODE>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(oCliente:cCEP)))

		//|Nome da Empresa |
		cBusca		:= "<SM0_EMPRESA>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_NOME)))

		//|Endereço da Empresa |
		cBusca		:= "<SM0_ENDERECO>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_ENDCOB)))

		//|Cidade da Empresa |
		cBusca		:= "<SM0_CIDADE>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_CIDCOB)))

		//|Complemento do endereço da Empresa |
		cBusca		:= "<SM0_COMPLEM>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_COMPCOB)))

		//|Complemento do endereço da Empresa |
		cBusca		:= "<SM0_CEP>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_CEPCOB)))

		//|UF da Empresa |
		cBusca		:= "<SM0_UF>"
		cZPLModelo	:= AllTrim(StrTran(cZPLModelo,cBusca,AllTrim(SM0->M0_ESTCOB)))

		ConOut(cZPLModelo)

		::cEtiqZPL	:= cZPLModelo

		//|Envia a impressão para a Zebra |
		lRet		:= ::ImprimeZPL()

	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ImprimeZPL
description Envia o código ZPL para a impressora zebra
@author  Pontin
@since   21.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method ImprimeZPL() Class TFZImprimeEtiqueta

	Local _cPrinter		:= ::cPrinter //'ZEBRA'
	Local lRet			:= .F.
	//Local _cPorta     := "COM1:9600,8,N,1"

	If !Empty(::cEtiqZPL) .And. !Empty(_cPrinter)

		If CB5SetImp(_cPrinter)

			MSCBBEGIN(1,6)

			//|Envia o código ZPL para impressora |
			MSCBWrite(::cEtiqZPL)

			//|Finaliza o arquivo de impressao |
			MSCBEND()

			//|Fecha conexao com a aimpressora |
			MSCBClosePrinter()

			lRet	:= .T.

		EndIf

	EndIf

Return lRet
