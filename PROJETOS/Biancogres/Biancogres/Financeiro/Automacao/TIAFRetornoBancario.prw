#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFRetornoBancario
@author Tiago Rossini Coradini
@since 29/01/2019
@project Automação Financeira
@version 1.0
@description Classe de interface para processamento de retornos bancarios
@type class
/*/

Class TIAFRetornoBancario From LongClassName

	Data dData // Data de processamento
	Data cEmp // Empresa
	Data cFil // Filial
	Data cTipo // Tipo: P=Pagar; R=Receber
	Data cBanco // Banco
	Data cAgencia // Agencia
	Data cConta // Conta
	Data cCnpjEmissor // CNPJ da empresa emissora
	
	Data cNumero // Numero identificador enviado para o banco
	Data cEspecie // Especie
	Data cNosNum // Nosso numero
	Data cCodBar // Codigo de barras do titulo
	Data cIdCnab // Identificador unico do CNAB
	
	Data nVlOri // Valor original
	Data nVlRec // Valor recebido - Tipo: R=Receber
	Data nVlPag // Valor pago - Tipo: P=Pagar
	Data nVlDesp // Valor de despesas
	Data nVlDesc // Valor de desconto
	Data nVlAbat // Valor de abatimento
	Data nVlJuro // Valor juros
	Data nVlMult // Valor multa
	Data nVlTar // Valor da tarifa bancaria
	Data nVlIOF // Valor do IOF
	Data nVlOCre // Valor outros creditos
	
	Data dDtLiq // Data de liquidacao
	Data dDtCred // Data do credito
	Data dDtDeb // Data de debito
	Data dDtVenc // Data de vencimento
	
	Data cCodSeg // Codigo do segmento do retorno
	Data cCodOco // Codigo da ocorrencia retornada pelo banco
	Data cCodRej // Codigo de rejeicao
	
	Data cNumFor // Numero do titulo no fornecedor - Utilizado no DDA
	Data cCnpjFor // CNPJ do fornecedor
	
	Data cStatus // Status da integracao - 1=Integrado; 2=Processado; 3=Baixado
	Data nID // Identificador do registro
	
	Data cFile // Nome do arquivo de retorno (Pasta + Nome)
	Data cIDProcAPI // Identificar do processo da API
	Data cRecord // Dados do arquivo de retorno
	Data cErrorLog // Log de erro no processamento das baixas
	
	//Propriedades Baixas a Pagar
	Data cFBanco
	Data cFAge
	Data cFDAge
	Data cFConta
	Data cFDConta
	Data cFDSegCta
	Data cOcoRet
	Data cCamara
	Data cFDoc
	Data cFNome
	Data cOutras
	Data cChvAut
	
	//Propriedades do retorno de GNRE
	Data nVLATUL
	Data nVLTOT
	Data dDTAGEN
	Data cCODUF
	Data cIDGUIA
	Data cCODREC
	Data cPERREF
	Data cAUTDEB
	Data cNUMAGE
	
	// Retorno de conciliacao
	Data cNumSeq // Numero sequencial do arquivo: Utiliado para validar duplicidade
	Data cCodNat // Natureza do lancamento
	Data cTpComp // Tipo do complemento lancamento
	Data cComple // Complemento lancamento
	Data dDtCont // Data de contabilizacao
	Data dDtLanc // Data do lancamento
	Data cTpLanc // Tipo de lancamento: D=Debito; C=Credito
	Data cCatego // Categoria do lancamento: 101 a 199 D=Debito; 201 a 299 C=Credito
	Data cCdHist // Código do historico do lancamento no banco
	Data cDsHist // Descricao do historico do lancamento no banco
	Data cNatFin // Natureza financeira
	
Method New() Constructor

EndClass


Method New() Class TIAFRetornoBancario

	::dData := dDatabase
	::cEmp := cEmpAnt
	::cFil := cFilAnt
	::cTipo := "P"
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::cCnpjEmissor := ""	

	::cNumero := ""
	::cEspecie := ""
	::cNosNum := ""
	::cCodBar := ""
	::cIdCnab := ""

	::nVlOri := 0
	::nVlRec := 0
	::nVlPag := 0
	::nVlDesp := 0
	::nVlDesc := 0
	::nVlAbat := 0
	::nVlJuro := 0
	::nVlMult := 0
	::nVlTar := 0
	::nVlIOF := 0
	::nVlOCre := 0

	::dDtLiq := cToD("")
	::dDtCred := cToD("")
	::dDtDeb := cToD("")
	::dDtVenc := cToD("")

	::cCodSeg := ""
	::cCodOco := ""
	::cCodRej := ""

	::cNumFor := ""
	::cCnpjFor := ""

	::cStatus := "1"
	::nID := 0

	::cFile := ""
	::cIDProcAPI := ""
	::cRecord := ""
	::cErrorLog := ""

	::cFBanco := ""
	::cFAge := ""
	::cFDAge := ""
	::cFConta := ""
	::cFDConta := ""
	::cFDSegCta := ""
	::cOcoRet := ""
	::cCamara := ""
	::cFDoc := ""
	::cFNome := ""
	::cOutras := ""
	::cChvAut	:= ""

	::nVLATUL := 0
	::nVLTOT := 0
	::dDTAGEN := cToD("")
	::cCODUF := ""
	::cIDGUIA := ""
	::cCODREC := ""
	::cPERREF := ""
	::cAUTDEB := ""
	::cNUMAGE := ""
	
	::cNumSeq := ""
	::cCodNat := ""
	::cTpComp := ""
	::cComple := ""
	::dDtCont	:= cToD("")
	::dDtLanc	:= cToD("")
	::cTpLanc := ""
	::cCatego := ""
	::cCdHist := ""
	::cDsHist := ""
	::cNatFin := ""		

Return()