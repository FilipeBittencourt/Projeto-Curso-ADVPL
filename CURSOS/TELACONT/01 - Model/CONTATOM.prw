//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
Função: CONTATOC
------------------------------------------------------------------------------------------------------------
Escopo         : CONTATOC.prw
Descrição/Uso  : Regras de negócio e validações do fonte CONTATO.prw
Parâmetros     : Nenhum
Retorno        : Nulo
------------------------------------------------------------------------------------------------------------
Atualizações   : 99/99/9999 - FILIPE VIEIRA FACILE - Construção inicial
------------------------------------------------------------------------------------------------------------
*/


Class CONTATOM From LongClassName 

    Data cNome
    Data cSobreNome
    Data nIdade
    
    Data lResponse
    Data cResponse
	 
	Method New() Constructor
	Method Validate()
	
EndClass

METHOD New() Class CONTATOM  
    
Return Self
