#include "rwmake.ch"
#Include "TopConn.ch"

/*
##############################################################################################################
# PROGRAMA...: M030EXC
# AUTOR......: Ranisses A. Corona
# DATA.......: 30/05/2014
# DESCRICAO..: Exclui o Cliente em todas as empresas e também da tabela de rotas
#			   Adequação para o processo BIZAGI                                                                   
#			                                
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

User Function M030EXC()

CONOUT('Iniciando o M030EXC...')

//IsInCallStack("A030DELETA")

//Deleta cadastro na tabela DA7
CSQL := "UPDATE DA7010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	DA7_CLIENT = '"+SA1->A1_COD+"' AND DA7_ROTA = '"+SA1->A1_COD_MUN+"' AND D_E_L_E_T_ = '' "
TCSQLEXEC(CSQL)

IF cempant = "01"
	CSQL := "UPDATE SA1050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1140 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ELSEIF cempant = "05"
	CSQL := "UPDATE SA1010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1140 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ELSEIF cempant = "07"
	CSQL := "UPDATE SA1010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1140 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ELSEIF cempant = "12"
	CSQL := "UPDATE SA1010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1140 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ELSEIF cempant = "13"
	CSQL := "UPDATE SA1010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1140 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ELSEIF cempant = "14"
	CSQL := "UPDATE SA1010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
	CSQL := "UPDATE SA1130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	A1_COD = '"+SA1->A1_COD+"' AND A1_LOJA = '"+SA1->A1_LOJA+"' AND A1_CGC = '"+SA1->A1_CGC+"' AND D_E_L_E_T_ = '' "
	TCSQLEXEC(CSQL)
ENDIF

Return 