#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TAFApiLote
@description Classe com struct do lote para agrupamentos de boletos
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiLote from LongClassName

	Data Numero
	Data GArqRem
	Data CMovRem
	Data TpArquivo
	Data Operacao
	Data Parcial
	Data EmailCopia
	Data Boletos
	Data aLstFields // Vetor de conversao de propriedades para nos longos da API 
	
	Method New() Constructor

EndClass


Method New() Class TAFApiLote

	::Numero := ""
	::GArqRem := Nil   		//Gerar Arquivo de Remessa "S ou "N"
	::CMovRem := Nil  		//Codigo Movimento Remessa - Exemplo: 06 = Alterar Vencimento no Banco
	::TpArquivo := Nil   	//Tipo de Arquivo  0 = CNAB240,  1 = CNAB400
	::Operacao := Nil	 	//Operacao 1 = Receber , 2 = Pagar
	::Parcial	:= Nil
	::EmailCopia := Nil	
	::Boletos := {}	
	

	::aLstFields := TAFApiListFields():New
	::aLstFields:AddField("Numero", "Numero")
	::aLstFields:AddField("NomArq", "NomeArquivo")
	::aLstFields:AddField("NSeqRem", "NumeroSequencialRemessa")
	::aLstFields:AddField("GArqRem", "GerarArquivoRemessa")
	::aLstFields:AddField("CMovRem", "CodigoMovimentoRemessa")	
	::aLstFields:AddField("TpArquivo", "TipoArquivo")
	::aLstFields:AddField("Operacao", "Operacao")
	::aLstFields:AddField("Boletos", "Boletos")
	::aLstFields:AddField("Parcial", "Parcial")
	::aLstFields:AddField("EmailCopia", "EmailCopia")

Return()