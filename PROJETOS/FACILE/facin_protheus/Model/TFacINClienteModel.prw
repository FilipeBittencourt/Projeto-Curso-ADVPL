#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINClienteModel
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINClienteModel From LongClassName

	Data nIdFacIN 	  //"Id": 932,
	Data cCodigo  //"CodigoLegado": "",
	Data cNome	  //"Nome": "5",
	Data cNomeFan //"NomeFantasia": "5 PISTA",
	Data cPessoa  //"TipoPessoa": "J",
	Data cCGC     //"CpfCnpj": "00414742000163",
	Data cEmail   //"Email": "4pistas@4pistas.com.br",
	Data cCEP     //"Cep": "29215002",
	Data cEnderec //"Endereco": "AVE GOV JONES DOS SANTOS NEVES, 3325",
	Data cNumero  //"Numero": "497",
	Data cComplem //"Complemento": "",
	Data cBairro  //"Bairro": "ITARARE",
	Data cInscES  //"InscricaoEstadual": "081893213",
	Data cDDD1    //"DDD1": "97",
	Data cDDD2    //"DDD2": "",
	Data cTel1    //"Telefone1": "454545444",
	Data cTel2    //"Telefone2": "",
	Data nLimCred //"LimiteCredito": 0.0,
	Data dVenCred //"VencimentoLimiteCredito": "2019-07-04 13:27:43",
	Data cCodSA1
	Data cLojaSA1

	Data cVend1Id //"Vendedor1Id": 57,
	Data cVend2Id //"Vendedor2Id": 0,
	Data cCodMun  //"MunicipioId": 1742
	Data cUF      //"MunicipioId": 1742

	Data cStatus
	Data cDeleted

	Method New() Constructor

EndClass

Method New() Class TFacINClienteModel

	::nIdFacIN 	:= 0
	::cCodigo   := ""
	::cNome	    := ""
	::cNomeFan  := ""
	::cPessoa   := ""
	::cCGC      := ""
	::cEmail    := ""
	::cCEP      := ""
	::cEnderec  := ""
	::cNumero   := ""
	::cComplem  := ""
	::cBairro   := ""
	::cInscES   := ""
	::cDDD1     := ""
	::cDDD2     := ""
	::cTel1     := ""
	::cTel2     := ""
	::nLimCred  := ""
	::dVenCred  := ""
	::dVenCred  := ""
	::cVend1Id  := ""
	::cVend2Id  := ""
	::cCodMun   := ""
	::cUF       := ""
	::cStatus   := ""
	::cDeleted	:= ""
	::cCodSA1		:= 0
	::cLojaSA1	:= 0

Return Self
