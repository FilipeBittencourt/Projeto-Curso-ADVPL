#include "TOTVS.CH"

/*/{Protheus.doc} TFacBoletoNet
@description Classe com struct do boleto
@since 01/10/2018
@version 1.0
@type class
/*/
Class TAFApiBoleto from LongClassName

	//PROPRIEDADES
	Data CodBanco 	
	Data Cedente	
	Data Sacado 	
	Data DtEmissao 
	Data DtVenc		
	Data DtProc    
	Data DtCred		
	Data Valor     
	Data Acrescimo
	
	Data NumDoc    
	Data EspDoc    
	Data MenArqRem 
	Data ChaveUnica
	Data NNumero   
	Data CodMoeda  
	Data EspMoeda  
	Data VlrMoeda  
	Data TpCarteira
	Data Carteira  
	Data VrCarteira
	Data Aceite    
	Data CodInstr1 
	Data CodInstr2 
	
	Data DtDesc    
	Data VlrDesc   
	
	Data DtMulta   
	Data PerMulta  
	Data VlrMulta  
	
	Data DtJuros   
	Data PerJurDia 
	Data VlrJurDia
	
	Data NumLote
	Data EmailSac
	Data EmailCed
	Data Reimpr
	Data TpCom
	
	Data CodProt
	Data DiaProt
	Data MsgLiv1 
	Data MsgLiv2 
	Data MsgLiv3 
	
	Data RecAnt
	
	//VETOR DE CONVERSAO PROPRIEDADE PARA NOME LONGO API
	Data aLstFields

	//METODOS
	Method New(cCodBanco, oCedente) Constructor

EndClass


Method New(cCodBanco, oCedente) Class TAFApiBoleto

	::CodBanco 		:= cCodBanco
	::Cedente 		:= oCedente
	::Sacado 		:= Nil
	::DtEmissao 	:= Nil
	::DtVenc		:= Nil
	::DtProc        := Nil
	::DtCred		:= Nil
	::Valor         := Nil
	::Acrescimo		 := Nil
	::NumDoc        := Nil
	::EspDoc        := Nil
	::MenArqRem     := Nil
	::ChaveUnica    := Nil
	::NNumero       := Nil
	::CodMoeda      := Nil
	::EspMoeda      := Nil
	::VlrMoeda      := Nil
	::TpCarteira    := Nil
	::Carteira      := Nil
	::VrCarteira    := Nil
	::Aceite        := Nil
	::CodInstr1     := Nil
	::CodInstr2     := Nil
	::DtDesc        := Nil
	::VlrDesc       := Nil
	::DtMulta       := Nil
	::PerMulta      := Nil
	::VlrMulta      := Nil
	::DtJuros       := Nil
	::PerJurDia     := Nil
	::VlrJurDia     := Nil
	::NumLote		:= Nil
	::EmailSac		:= "0"
	::EmailCed		:= "0"
	::Reimpr 		:= Nil
	::TpCom			:= ""
	
	::CodProt 		:= Nil
	::DiaProt 		:= Nil
	::MsgLiv1 		:= Nil
	::MsgLiv2 		:= Nil
	::MsgLiv3 		:= Nil
	::RecAnt  		:= .F.
	
	::aLstFields	:= TAFApiListFields():New

	::aLstFields:AddField("CodBanco"	,"CodigoBanco")
	::aLstFields:AddField("Cedente"		,"Cedente")
	::aLstFields:AddField("Sacado"		,"Sacado")
	::aLstFields:AddField("DtEmissao"	,"DataEmissao")
	::aLstFields:AddField("DtVenc"		,"DataVencimento")
	::aLstFields:AddField("DtProc"		,"DataProcessamento")
	::aLstFields:AddField("DtCred"		,"DataCredito")
	::aLstFields:AddField("Valor"		,"ValorTitulo")
	::aLstFields:AddField("Acrescimo"	,"ValorOutrosAcrescimos")
	
	::aLstFields:AddField("NumDoc"		,"NumeroDocumento")
	::aLstFields:AddField("EspDoc"		,"EspecieDocumento")
	::aLstFields:AddField("MenArqRem"	,"MensagemArquivoRemessa")
	::aLstFields:AddField("ChaveUnica"	,"NumeroControleParticipante")
	::aLstFields:AddField("NNumero"		,"NossoNumero")
	::aLstFields:AddField("CodMoeda"	,"CodigoMoeda")
	::aLstFields:AddField("EspMoeda"	,"EspecieMoeda")
	::aLstFields:AddField("VlrMoeda"	,"ValorMoeda")
	::aLstFields:AddField("TpCarteira"	,"TipoCarteira")
	::aLstFields:AddField("Carteira"	,"Carteira")
	::aLstFields:AddField("VrCarteira"	,"VariacaoCarteira")
	::aLstFields:AddField("Aceite"		,"Aceite")
	::aLstFields:AddField("CodInstr1"	,"CodigoInstrucao1")
	::aLstFields:AddField("CodInstr2"	,"CodigoInstrucao2")
	::aLstFields:AddField("DtDesc"		,"DataDesconto")
	::aLstFields:AddField("VlrDesc"		,"ValorDesconto")
	::aLstFields:AddField("DtMulta"		,"DataMulta")
	::aLstFields:AddField("PerMulta"	,"PercentualMulta")
	::aLstFields:AddField("VlrMulta"	,"ValorMulta")
	::aLstFields:AddField("DtJuros"		,"DataJuros")
	::aLstFields:AddField("PerJurDia"	,"PercentualJurosDia")
	::aLstFields:AddField("VlrJurDia"	,"ValorJurosDia")
	::aLstFields:AddField("EmailSac"	,"EnviarEmailSacado")
	::aLstFields:AddField("EmailCed"	,"EnviarEmailCedente")
	::aLstFields:AddField("NumLote"		,"NumeroLote")
	::aLstFields:AddField("Reimpr"		,"Reimpressao")
	::aLstFields:AddField("TpCom"		, "TipoComunicacao")
	
	::aLstFields:AddField("CodProt"		, "CodigoProtesto")
	::aLstFields:AddField("DiaProt"		, "DiasProtesto")
	::aLstFields:AddField("MsgLiv1"		, "MensagemLivreLinha1")
	::aLstFields:AddField("MsgLiv2"		, "MensagemLivreLinha2")
	::aLstFields:AddField("MsgLiv3"		, "MensagemLivreLinha3")	
	
	::aLstFields:AddField("RecAnt"		, "RecebimentoAntecipado")
	
	
Return()