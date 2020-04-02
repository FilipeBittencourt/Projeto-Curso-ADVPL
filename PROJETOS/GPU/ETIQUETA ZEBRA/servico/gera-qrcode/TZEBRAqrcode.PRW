#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TZEBRAqrcode
@description Classe que gera as informações para os dados do QRCODE
@author Filipe Vieira
@since 16/01/2019
@version 1.0
/*/

Class TZEBRAqrcode From LongClassName

	Data cCEPDest      //CEP destino 8
	Data cCEPComD      //Complemento do CEP  destino 5
	Data cCEPOrig      //CEP Origem 8
	Data cCEPComO      //Complemento do CEP Origem 5
	Data cValCEPD      //Validador do CEP Destino 1
	Data cIDV          //IDV 2

	//Dados Variáveis Encomenda CARACTERES

	Data cEtiquet	//Etiqueta 13
	Data cServAdd	//Serviços Adicionais (AR, MP, DD, VD) 8
	Data cCarPost	//Cartão de Postagem 10
	Data cCodServ	//Código do Serviço 5
	Data cInfoAgr	//Informação de Agrupamento 2
	Data cNLograd	//Número do Logradouro 5
	Data cCLograd	//Complemento do Logradouro 20
	Data cVlrDecl	//Valor Declarado 5
	Data cTelDest	//DDD + Telefone Destinatário 12
	Data cLatitud	//Latitude 10
	Data cLongitu	//Longitude 10
	Data cPipe	  	//Pipe "|" 1
	Data cObsCli	//Reserva para cliente



	Method New() Constructor
	Method GeraQRCODE(oZQRCODE)
	Method ValidCEPD(oZQRCODE)




EndClass

Method New() Class TZEBRAqrcode

	::cCEPDest := ""
	::cCEPComD := ""
	::cCEPOrig := ""
	::cCEPComO := ""
	::cValCEPD := ""
	::cIDV     := ""

	::cEtiquet := ""
	::cServAdd := ""
	::cCarPost := ""
	::cCodServ := ""
	::cInfoAgr := ""
	::cNLograd := ""
	::cCLograd := ""
	::cVlrDecl := ""
	::cTelDest := ""
	::cLatitud := ""
	::cLongitu := ""
	::cPipe	   := "|"
	::cObsCli  := ""


Return  Self


Method GeraQRCODE(oZQRCODE) Class TZEBRAqrcode

    Local cQRCODE 		:= ""

	cQRCODE += PADR(AllTrim(oZQRCODE:cCEPDest),8,"0")
	/*Complemento do CEP:	Ponto de entrega conforme DNE – Diretório Nacional de Endereço, será fornecido pelos
	Correios via Web Service. Obs.: Caso não possui o ponto de entrega preencher com 00000.	*/
	cQRCODE += IIF(Empty(oZQRCODE:cCEPComD), "00000", PADR(AllTrim(oZQRCODE:cCEPComD),5,"0")) //Complemento do CEP  destino 5

	cQRCODE += PADR(AllTrim(oZQRCODE:cCEPOrig),8,"0")
	cQRCODE += IIF(Empty(oZQRCODE:cCEPComO), "00000",PADR(AllTrim(oZQRCODE:cCEPComO),5,"0"))
	cQRCODE += ::ValidCEPD(oZQRCODE) // Validador do CEP Destino 1  (cValCEPD)
	cQRCODE += PADR(AllTrim(oZQRCODE:cIDV),2,"0")

	cQRCODE += PADR(AllTrim(oZQRCODE:cEtiquet),13)
	cQRCODE += PADR(AllTrim(oZQRCODE:cServAdd),12,"0")
	cQRCODE += PADR(AllTrim(oZQRCODE:cCarPost),10)
	cQRCODE += PADR(AllTrim(oZQRCODE:cCodServ),5,"0")
	cQRCODE += PADR(AllTrim(oZQRCODE:cInfoAgr),2,"0")
	cQRCODE += PADR(AllTrim(oZQRCODE:cNLograd),5,"0")
	cQRCODE += PADR(AllTrim(oZQRCODE:cCLograd),20,"")
	cQRCODE += PADL(AllTrim(oZQRCODE:cVlrDecl),5,"0")
	cQRCODE += PADL(AllTrim(oZQRCODE:cTelDest),12,"0")  //DDD + Telefone Destinatário 12 ( cTelDest )
	cQRCODE += IIF(Empty(oZQRCODE:cLatitud), "-00.000000", PADR(AllTrim(oZQRCODE:cLatitud),10,"0"))  //Latitude 10 ( cLatitud )
	cQRCODE += IIF(Empty(oZQRCODE:cLongitu), "-00.000000", PADR(AllTrim(oZQRCODE:cLongitu),10,"0"))  //Latitude 10 ( cLongitu )
	cQRCODE += PADR(AllTrim(oZQRCODE:cPipe),1)
	cQRCODE += PADR(AllTrim(oZQRCODE:cObsCli),30)


Return  cQRCODE

/*
Validador do CEP Destino:
Soma dos 8 dígitos do CEP de destino:
Subtrai-se o resultado da soma do múltiplo de 10, imediatamente superior ao resultado.
Ex: CEP: 71010050 ? 7+1+0+1+0+0+5+0 = 14
Subtrai-se 14 e 20.
Resultado é 6
*/
Method ValidCEPD(oZQRCODE) Class TZEBRAqrcode

	Local nI  := 0
	Local nSoma  := 0
	Local nRet := 0

	If !Empty(oZQRCODE:cCEPDest)

		If LEN(oZQRCODE:cCEPDest) > 0

			For nI := 1 to LEN(oZQRCODE:cCEPDest)

			    nSoma += Val(SUBSTR(oZQRCODE:cCEPDest, nI, 1))

			Next nI

			If nSoma <= 9

				nRet := 10 - nSoma

			Else

				For nI := 10 to 500 step 10

					If (nI - nSoma) >= 0

						nRet := nI - nSoma
						EXIT

					EndIf

				Next nI

			EndIf

		EndIf

	EndIf

Return  cValToChar(nRet)