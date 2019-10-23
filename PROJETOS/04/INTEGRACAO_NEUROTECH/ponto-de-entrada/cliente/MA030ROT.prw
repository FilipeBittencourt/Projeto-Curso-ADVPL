#Include 'Protheus.ch'

/*/{Protheus.doc} MA030ROT
(long_description)
@type function
@author jose.brittes
@since 13/10/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MA030ROT()

    aRetorno := {}
    AAdd( aRetorno, { "Cons. Historico", "U_TkHistCli(2)", 2, 0 } )
    AAdd( aRetorno, { "NEUROTECH", "U_ZNEUCLI", 2, 0 } )

Return( aRetorno )

//---------------------------------------------------------------------//
// Funcao para atualizar limite de credito do cliente via neurotec.   //
//-------------------------------------------------------------------//
User Function ZNEUCLI() 
    //chamando a função U_NEUROCLI do PE MA030BUT
    FWMsgRun(, {|| U_NEUROCLI(SA1->A1_COD, SA1->A1_LOJA)}, "Aguarde!", "Processando a rotina NEUROTECH...")     
Return .T.



