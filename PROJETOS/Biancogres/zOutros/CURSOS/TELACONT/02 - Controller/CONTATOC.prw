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


Class CONTATOC From LongClassName 

    Data lResponse
    Data cResponse
	 
	Method New() Constructor
    
	Method Validate()
	
EndClass

METHOD New() Class CONTATOC  
    ::lResponse := .T.
Return Self

METHOD Validate(oContato) Class CONTATOC    
    
    If oContato:cNome  == "" .OR. EMPTY(oContato:cNome)
       oContato:lResponse := .F.
       oContato:cResponse := "O nomde do user Não pode ser Vazio"
    Else
        oContato:cResponse := "Tudo certo"
    EndIf

Return oContato
