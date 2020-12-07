#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiRemessa
@description Classe para agrupar a geracao de varios titulos em Boletos / Arquivos de Remessa (Bordero)
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiRemessa from LongClassName

	Data cCodEmp
	Data cCodFil
	Data cCodBanco
	Data oCedente
	Data GArqRem
	Data CMovRem

	//dados para criacao de Lote
	Data cLoteNumero
	Data aLstBoleto

	Method New(cCodEmp, cCodFil) Constructor
	Method SetParametros(cCNPJ, cBanco, cAgencia, cConta, cSubCta)  //Setar os parametros do Banco/Conta usada para a remessa
	Method Clear()
	Method AddBoleto()
	Method Send()

EndClass


Method New(cCodEmp, cCodFil) Class TAFApiRemessa

	::cCodEmp	:= cCodEmp
	::cCodFil	:= cCodFil
	::cCodBanco := ""
	::oCedente := Nil

	::cLoteNumero	:= Nil
	::aLstBoleto := {}

Return()


Method SetParametros(cCNPJ, cBanco, cAgencia, cConta, cSubCta) Class TAFApiRemessa

	::cCodBanco	:= cBanco

	::oCedente := TAFApiCedente():New(cCNPJ, cBanco, cAgencia, cConta, cSubCta)

Return


Method Clear() Class TAFApiRemessa

	::aLstBoleto := {}

Return


Method AddBoleto() Class TAFApiRemessa
	Local oBoleto

	If ::oCedente <> Nil

		oBoleto := TAFApiBoleto():New(::cCodBanco,::oCedente)

		aAdd(::aLstBoleto, oBoleto)

	EndIf

Return(oBoleto)


Method Send() Class TAFApiRemessa
	Local oRet := Nil
	Local oApi := TAFApiNet():New()
	Local oLote := TAFApiLote():New()
	Local oBol := Nil
	Local nCount := 0

	// Conectar api e buscar token de acesso
	oRet := oApi:GetAcessToken()

	If oRet:Ok

		oLote := TAFApiLote():New()

		oLote:Numero := ::cLoteNumero
		oLote:GArqRem := ::GArqRem

		If !Empty(::CMovRem)
			
			oLote:CMovRem := ::CMovRem

			If ::cCodBanco == "001"
			
				oLote:TpArquivo := 0  //240 BB
			
			Else // Bradesco
				
				oLote:TpArquivo := 1

			EndIf

		Else

			oLote:TpArquivo := 1
		
		EndIf
		
		//banestes
		If ::cCodBanco == "021"
			oLote:TpArquivo := 0  //240 
		EndIf
		
		oLote:Operacao := 1
		//oLote:EmailCopia := UsrRetMail(__cUserId)

		For nCount := 1 To Len(::aLstBoleto)

			oBol := ::aLstBoleto[nCount]

			AAdd(oLote:Boletos, oBol)

		Next nCount

		oRet := oApi:PostObj("/Lote", oLote)


		//Nao enviar para PORTAL processos de alteracao de dados Bancarios via arquivo remessa
		If Empty(::CMovRem)

			/*
			GRAVANDO BOLETOS NA STAGE AREA PARA PORTAL DE CLIENTES
			Fernando Rocha - 19/19/2019
			*/
			ConOut("TAFApiRemessa [EMPRESA "+CEMPANT+"] => [SINCRONIZA STAGE AREA PORTAL] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
			_oStage := TAFSendStagePortal():New(CEMPANT, CFILANT)
			_oStage:oCedente 	:= ::oCedente
			_oStage:oLote 		:= oLote
			_oStage:SendStage()
			ConOut("TAFApiRemessa [EMPRESA "+CEMPANT+"] => [SINCRONIZA STAGE AREA PORTAL] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

		EndIf


	EndIf

Return(oRet)