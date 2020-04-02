#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINNeurotechModel
@description Classe para buscar montar dados de envio para neurotech
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/
Class TINNeurotechModel From LongClassName

    Data oCliente   
    Data nNumProp 
    Data cNrPedido  
    Data dDtPedido
    Data cObserv


    Data cNrNF      
    Data cIdadeFund 
    Data cUFEmpresa 
    Data cTipoContr 
    Data cCEPEntreg 
    Data nTempRelac 
    Data cTipoClien 
    Data nVlrCpraAt 
    Data nAtrasoAtu 
    Data nMDAHist   
    Data nMDA03m    
    Data nMDA12m    
    Data nVlrTotVen 
    Data nTempUltCo 
    Data nQtdCAVist 
    Data nVlrTotCRe 
    Data nVlrTotC03 
    Data nVlrTotC12 
    Data nQtdTotC03 
    Data nVlrTotCPH 
    Data nQtdTotCPH 
    Data nQtdTotC12 
    Data nQtdTotCan 
    Data nAtraMes01 
    Data nAtraMes02 
    Data nAtraMes03 
    Data nAtraMes04 
    Data nAtraMes05 
    Data nAtraMes06 
    Data nAtraMes07 
    Data nAtraMes08 
    Data nAtraMes09 
    Data nAtraMes10 
    Data nAtraMes11 
    Data nAtraMes12 
    Data nMDA12M     

    Data cDescGrEco //DESC_GRUPO_ECONOMICO
    Data cNomeClie  //NOME_CLIENTE		
    Data cCGC
    Data nLCredUlt  //LIMITE_CREDITO_SENDO_UTILIZADO
    Data nLCredCli  //LIMITE_CREDITO_CLIENTE
    Data nLCredGrp  //LIMITE_CREDITO_GRUPO
    Data dVencCred  //VENCIMENTO_CREDITO
    Data nLCredUGE  //LIMITE_CREDITO_UTILIZADO_GRUPO_ECONOMICO


    Data cE1TIPO
    Data cE1NUM
    Data cE1EMISSAO
    Data cE1VENCREA
    Data cE1VALOR
    Data cDiasAtra

    Method New() Constructor
	 

EndClass


//|Metódo construtor da classe |
Method New() Class TINNeurotechModel	
    
    ::oCliente := ""
    ::nNumProp := ""
    ::nVlrTotVen := ""
    ::cObserv := ""

    ::nTempRelac  := 0
    ::nVlrCpraAt  := 0
    ::nAtrasoAtu  := 0
    ::nMDAHist    := 0
    ::nMDA03m     := 0
    ::nMDA12m     := 0
    ::nVlrTotVen  := 0
    ::nTempUltCo  := 0
    ::nQtdCAVist  := 0
    ::nVlrTotCRe  := 0
    ::nVlrTotC03  := 0
    ::nVlrTotC12  := 0
    ::nQtdTotC03  := 0
    ::nVlrTotCPH  := 0
    ::nQtdTotCPH  := 0
    ::nQtdTotC12  := 0
    ::nQtdTotCan  := 0
    ::nAtraMes01  := 0
    ::nAtraMes02  := 0
    ::nAtraMes03  := 0
    ::nAtraMes04  := 0
    ::nAtraMes05  := 0
    ::nAtraMes06  := 0
    ::nAtraMes07  := 0
    ::nAtraMes08  := 0
    ::nAtraMes09  := 0
    ::nAtraMes10  := 0
    ::nAtraMes11  := 0
    ::nAtraMes12  := 0
    ::nMDA12M    := 0 
    ::nLCredUlt   := 0
    ::nLCredCli   := 0
    ::nLCredGrp   := 0 
    ::nLCredUGE   := 0

Return Self

