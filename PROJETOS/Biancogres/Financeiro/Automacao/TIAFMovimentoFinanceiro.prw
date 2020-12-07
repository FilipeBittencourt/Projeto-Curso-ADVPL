#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFMovimentoFinanceiro
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe para tratar os titulos a receber que serao integrados com a API
@type class
/*/

Class TIAFMovimentoFinanceiro From LongClassName
	
	// Dados da empresa em execucao
	Data cCnpj // Cnpj da empresa
	Data cEmp // Codigo da empresa
	Data cFil // Filial da empresa

	// Dados do titulo
	Data cPrefixo // Prefixo
	Data cNumero // Numero
	Data cParcela // Parcela
	Data cTipo // Tipo
	Data cCliFor // Codigo do cliente ou fornecedor
	Data cLoja // Loja do cliente ou fornecedor
	Data cEmail // Email do cliente
	Data nValor // Valor
	Data nSaldo // Saldo
	Data nValorBol // Valor do saldo subtraido o juros e abatimento
	Data nAbat // Abatimanto
	Data nDesc // Desconto
	Data nAcre // Acrescimo
	Data nPerJur // Percentual de juros
	Data dEmissao // Data de emissao
	Data dVencto // Data de vencimento
	Data dVencRea // Data de vencimento real
	Data cNumBor // Numero do bordero
	Data cNumBco // Numero do titulo no banco - Nosso numero 
	Data cIDCnab // Identificador de CNAB Protheus
	Data cPedido // Numero do pedido de venda
	Data lRecAnt // Identificador de recebimento antecipado
	Data nRecNo // Recno do titulo
	Data lValid // Titulo valido
	Data cFormPg
	Data cOperPg
	Data cModelo // Modelo de pagamento para bordero a pagar
	Data cTpPag // Tipo de pagamento para bordero a pagar
	Data nVlrTarifa
	Data lDescTarif
	Data cCodBar // Codigo de barras
	Data cLinDig // Linha Digitavel

	Data cArqcfg
	Data cArqUser 
	Data cAmbiente
	Data cLayout
						
	// Dados do banco
	Data cBanco // Numero do banco
	Data cAgencia // Agencia
	Data cConta // Conta corrente
	Data cSubCta // Subconta da tabela de parametros de bancos
	Data cSituacao // Situcao
	Data cEspecie // Especie
	Data cTpCom // Tipo de comunicacao 1=WS;2=Arq.Cnab
			
	// Dados bancarios do fornecedor
	Data cBancoFor // Numero do banco
	Data cAgenciaFor // Agencia
	Data cContaFor // Conta corrente
				
	// Dados do boleto a receber
	Data lJuros // Identifica se titulo possui juros
	Data nJuros // Valor do juros calculado
	Data dVencOri // Vencimento Original
	Data nSalOri // Saldo orginal
	Data nJurosDia // Valor do juros por dia
	Data nMulta // Valor da multa
	Data nCodProt // Codigo do protesto: 1=Dias corridos; 2=Dias uteis
	Data nDiaProt // Numero de dias para protesto
	Data cMsgLiv1 // Mensagem livre 1
	Data cMsgLiv2 // Mensagem livre 2
	Data cMsgLiv3 // Mensagem livre 3

	// Dados do grupo/regra de comunicacao bancaria	
	Data cGRCB // Grupo
	Data cRCB // Regra
	Data lMRCB // Regra multipla
	
	Method New() Constructor
	
EndClass


Method New() Class TIAFMovimentoFinanceiro
	
	::cCnpj := SM0->M0_CGC
	::cEmp := cEmpAnt
	::cFil := cfilAnt

	::cPrefixo := ""
	::cNumero := ""
	::cParcela := ""
	::cTipo := ""
	::cCliFor := ""
	::cLoja := ""
	::cEmail := ""
	::nValor := 0
	::nSaldo := 0
	::nValorBol := 0
	::nAbat := 0
	::nDesc := 0
	::nAcre := 0
	::nPerJur := 0
	::dEmissao := dDataBase
	::dVencto := dDatabase
	::dVencRea := dDatabase
	::cNumBor := ""
	::cNumBco := ""
	::cIDCnab := ""
	::cPedido := ""
	::lRecAnt := .F.
	::nRecNo := 0
	::nVlrTarifa := 0
	::lDescTarif := .F.
	::cCodBar := ""
	::cLinDig := ""
	
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::cSubCta := ""
	::cSituacao := ""
	::cEspecie := ""
	::cTpCom := "2"
	::cFormPg := ""
	::cOperPg := ""
	
	::cBancoFor := ""
	::cAgenciaFor := ""
	::cContaFor := ""
			
	::lJuros := .F.
	::nJuros := 0
	::dVencOri := dDataBase
	::nSalOri := 0	
	::nJurosDia := 0	
	::nMulta := 0
	::nCodProt := 1
	::nDiaProt := 0
	::cMsgLiv1 := ""
	::cMsgLiv2 := ""
	::cMsgLiv3 := ""

	::cGRCB := ""
	::cRCB := ""
	::lMRCB := .F.
	::lValid := .T.
	::cModelo := ""
	::cTpPag := ""
		
	::cArqcfg := ""
	::cArqUser := ""
	::cAmbiente := ""
	::cLayout := ""
	
Return()