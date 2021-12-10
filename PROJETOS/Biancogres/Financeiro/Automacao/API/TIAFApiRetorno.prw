#include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFApiRetorno
@author Tiago Rossini Coradini
@since 29/11/2018
@project Automação Financeira
@version 1.0
@description Classe para processamento de retorno
@type class
/*/

Class TIAFApiRetorno from TAFAbstractClass

	Data oRet // Objeto de retorno da API
	Data oApi // Objeto dos arquivos de retorno da API
	Data cCnpj // Cnpj da empresa
	Data cBanco // Banco
	Data cAgencia	// Agencia
	Data cConta // Conta
	Data cSubCta // SubConta
	Data cTipo // P=Pagar; R=Receber
	Data cIDProc // Identificador do Processo

	Method New() Constructor
	Method Receive() // Recebe titulos
	Method FormatDate(cDate) // Formata campos tipo data da API
	Method SetBranch(oObj) // Identifica filial de origem

EndClass


Method New() Class TIAFApiRetorno

	_Super:New()

	::oRet := Nil
	::oApi := TAFApiRetornoArquivo():New()
	::cCnpj := SM0->M0_CGC
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::cSubCta := ""
	::cTipo := ""
	::cIDProc := ""

Return()


Method Receive() Class TIAFApiRetorno
	Local nX := 1
	Local nY := 1
	Local oLst := ArrayList():New()
	Local lNoCed := .F.
	*	Local oMail	:= TAFMail():New()
	Local lErro := .F.
	Local cMsg := ""

	::oApi:SetParametros(::cCnpj, ::cBanco, ::cAgencia, ::cConta, ::cSubCta, ::cTipo)

	::oRet := ::oApi:Get()

	If ::oRet:Ok .And. Len(::oRet:oRetorno:Arquivos) > 0

		While nX <= Len(::oRet:oRetorno:Arquivos)

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "TIAFApiRetorno -> Processando arquivo: " + ::oRet:oRetorno:Arquivos[nX]:nome
			::oLog:cEnvWF := "N"

			::oLog:Insert()

			nY := 1

			// Se arquivo foi processado com sucesso pela API
			If ::oRet:oRetorno:Arquivos[nX]:Ok

				If (::oApi:oCedente == Nil)

					lNoCed := .T.

					::oApi:oCedente := TAFApiCedente():Get(::cCnpj, ::oRet:oRetorno:Arquivos[nX]:Banco, ::oRet:oRetorno:Arquivos[nX]:Agencia, ::oRet:oRetorno:Arquivos[nX]:Conta, Right(::oRet:oRetorno:Arquivos[nX]:CodigoCedente, 3))

				EndIf

				While nY <= Len(::oRet:oRetorno:Arquivos[nX]:Registros)

					oObj := TIAFRetornoBancario():New()

					// Operacao/banco
					oObj:cTipo := ::cTipo
					oObj:cBanco := ::oApi:oCedente:Banco
					oObj:cAgencia := ::oApi:oCedente:Agencia
					oObj:cConta := ::oApi:oCedente:Conta
					oObj:cCnpjEmissor := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CpfCnpjEmissor

					oObj:cCodigoCedente := ::oRet:oRetorno:Arquivos[nX]:CodigoCedente

					// Identificacao do titulo
					oObj:cNumero := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:NumeroDocumento
					oObj:cEspecie := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:Especie
					oObj:cNosNum := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:NossoNumero
					oObj:cCodBar := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CodigoBarras
					oObj:cIdCnab := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:NumCtPart

					// Valores do titulo
					oObj:nVlOri := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorTitulo
					oObj:nVlRec := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorPago
					oObj:nVlPag := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorPago
					oObj:nVlDesp := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorOutrasDespesas
					oObj:nVlDesc := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorDesconto
					oObj:nVlAbat := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorAbatimento
					oObj:nVlJuro := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorJurosDia
					oObj:nVlMult := 0
					oObj:nVlTar := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorTarifas
					oObj:nVlIOF := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorIOF
					oObj:nVlOCre := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:ValorOutrosCreditos

					// Datas do titulo
					oObj:dDtLiq := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:DataProcessamento)
					oObj:dDtCred := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:DataCredito)
					oObj:dDtDeb := ::FormatDate("")
					oObj:dDtVenc := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:DataVencimento)

					// Codigos de ocorrencias bancarias
					oObj:cCodSeg := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:Segmento
					oObj:cCodOco := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CodigoOcorrencia
					oObj:cCodRej := ""

					// DDA
					oObj:cNumFor := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:NumCtPart
					oObj:cCnpjFor := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CpfCnpj

					oObj:cStatus := "1"

					// Identificadores do Arquivo de Retorno
					oObj:cFile := AllTrim(::oRet:oRetorno:Arquivos[nX]:Path) + "\" + AllTrim(::oRet:oRetorno:Arquivos[nX]:Nome)
					oObj:cIDProcAPI := ::oRet:oRetorno:Arquivos[nX]:oId
					oObj:cRecord := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:RegistroArquivoRetorno

					// Pagamento
					oObj:cFBanco := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CodigoBanco
					oObj:cFAge := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:Agencia
					oObj:cFDAge := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:DigitoAgencia
					oObj:cFConta := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:Conta
					oObj:cFDConta := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:DigitoConta
					oObj:cFDSegCta := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:SegundoDigitoConta
					oObj:cOcoRet := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:OcorrenciasRetorno
					oObj:cCamara := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CodigoCamaraCentralizadora
					oObj:cFDoc := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:CPFCNPJ
					oObj:cFNome := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:Nome
					oObj:cChvAut := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:AutenticacaoBancaria

					// Pagamento - GNRE
					oObj:nVLATUL := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:valorAtualizacaoMonetaria
					oObj:nVLTOT := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:valorTotal
					oObj:dDTAGEN := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:dataAgendamento)
					oObj:cCODUF := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:codigoUF
					oObj:cIDGUIA := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:identificadorGuia
					oObj:cCODREC := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:codigoReceita
					oObj:cPERREF := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:periodoReferencia
					oObj:cAUTDEB := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:autorizacaoDebito
					oObj:cNUMAGE := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:numeroAgendamentoRemessa

					// Conciliacao Bancara
					oObj:cNumSeq := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:NumeroDocumentoBanco
					oObj:cCodNat := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:natureza
					oObj:cTpComp := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:tipoComplemento
					oObj:cComple := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:complemento
					oObj:dDtCont := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:dataContabil)
					oObj:dDtLanc := ::FormatDate(::oRet:oRetorno:Arquivos[nX]:Registros[nY]:dataLancamento)
					oObj:cTpLanc := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:tipoLancamento
					oObj:cCatego := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:categoria
					oObj:cCdHist := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:codigoHistorico
					oObj:cDsHist := ::oRet:oRetorno:Arquivos[nX]:Registros[nY]:descricaoHistorico

					// Identifica filial de origem
					::SetBranch(oObj)

					oLst:Add(oObj)

					nY++

				EndDo

				If lNoCed

					::oApi:oCedente := Nil

				EndIf

			Else

				lErro := .T.

				cMsg += ::oRet:oRetorno:Arquivos[nX]:Nome + " "

				cMsg += ::oRet:oRetorno:Arquivos[nX]:MensagemRetorno

				cMsg += cMsg += If(Len(::oRet:oRetorno:Arquivos[nX]:Registros) == 0, " ::oRet:oRetorno:Arquivos[nX]:Registros esta vazio!", "")

			EndIf

			nX++

		EndDo

	Else

		lErro := .F.

		cMsg := If(Empty(::oRet:Mensagem), "", ::oRet:Mensagem)

		If ValType(Self:oRet:oRetorno) <> "U"
			cMsg += If(ValType(Self:oRet:oRetorno:Arquivos) == "A" .And. Len(::oRet:oRetorno:Arquivos) == 0, " ::oRet:oRetorno:Arquivos esta vazio!", "")
		EndIf

	EndIf

	If lErro

		If IsBlind()

			::oPro:lAviso := .T.

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "ERRO API - " + cMsg
			::oLog:cEnvWF := "S"

			::oLog:Insert()

		Else

			Alert("Automação Financeira - ERRO API - " + cMsg)

		EndIf

	EndIf

	If ! Empty(cMsg)

		Conout("TIAFApiRetorno - " + cEmpAnt + cFilAnt + " - " + cMsg)

	EndIf

Return(oLst)


Method FormatDate(cDate) Class TIAFApiRetorno
	Local dRet := Nil

	If !Empty(cDate)

		dRet := sToD(SubStr(cDate, 1, 4) + SubStr(cDate, 6, 2) + SubStr(cDate, 9, 2))

	Else

		dRet := cToD("")

	EndIf

Return(dRet)


Method SetBranch(oObj) Class TIAFApiRetorno
	Local cSQL := ""
	Local cQry := GetNextAlias()

	If oObj:cTipo == "P"

		// DDA
		If oObj:cCodSeg == "G" .And. Empty(oObj:cIDGUIA) .And. !Empty(oObj:cCnpjEmissor)

			cSQL := " SELECT ISNULL(Z35_FIL, '') AS FILIAL "
			cSQL += " FROM " + RetSQLName("Z35")
			cSQL += " WHERE Z35_FILIAL = " + ValToSQL(xFilial("Z35"))
			cSQL += " AND Z35_EMP = " + ValToSQL(oObj:cEmp)
			cSQL += " AND Z35_CNPJ = " + ValToSQL(oObj:cCnpjEmissor)
			cSQL += " AND D_E_L_E_T_ = '' "

		Else

			cSQL := " SELECT ISNULL(E2_FILIAL, '') AS FILIAL "
			cSQL += " FROM " + RetSQLName("SE2")
			cSQL += " WHERE (E2_IDCNAB = " + ValToSQL(If (Empty(oObj:cIdCnab), "NOIDCNAB", oObj:cIdCnab))
			cSQL += " OR E2_CODBAR = " + ValToSQL(If (Empty(oObj:cCodBar), "NOCODBAR", oObj:cCodBar)) + ")"
			cSQL += " AND	D_E_L_E_T_ = '' "
			cSQL += " GROUP BY E2_FILIAL "

		EndIf

		TcQuery cSQL New Alias (cQry)

		If !Empty((cQry)->FILIAL)

			oObj:cFil := (cQry)->FILIAL

		EndIf

		(cQry)->(DbCloseArea())

	ElseIf oObj:cTipo == "R"

		cSQL := " SELECT ISNULL(E1_FILIAL, '') AS FILIAL "
		cSQL += " FROM " + RetSQLName("SE1")
		cSQL += " WHERE E1_FILIAL <> '  ' " //" WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
		cSQL += " AND ((E1_NUMBCO = " + ValToSQL(oObj:cNosNum) + ")"
		cSQL += " OR (E1_NUMBCO = LEFT(" + ValToSQL(oObj:cNosNum) + ", len(" + ValToSQL(oObj:cNosNum) + ")-1)) "
		cSQL += " OR (E1_YNUMBCO = " + ValToSQL(oObj:cNosNum) + " AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT')))"
		cSQL += " AND D_E_L_E_T_ = '' "
		cSQL += " GROUP BY E1_FILIAL "

		TcQuery cSQL New Alias (cQry)

		If !Empty((cQry)->FILIAL)

			oObj:cFil := (cQry)->FILIAL

		EndIf

		(cQry)->(DbCloseArea())

	EndIf

Return()
