#Include "Totvs.ch"

/*
##############################################################################################################
# PROGRAMA...: AT040ROT         
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 01/07/2015                      
# DESCRICAO..: Ponto de entrada para inclus�o de bot�es na enchoice rotina TECA040
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/

User Function AT040ROT()

aBotao := {} 

AAdd( aBotao, { "Revis�es", "U_CADSZ4()",  0, 4, 0, .T. } )


Return( aBotao )