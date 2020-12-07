#INCLUDE "PROTHEUS.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA183

# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/11/2013
# DESCRICAO..: Validacao na Inclusao de Titulos à Pagar
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

User Function BIA183()

Local lRet := .T.

IF((FunName() == "FINA050") .Or. (FunName() == "FINA750"))
	If(Alltrim(M->E2_TIPO) <> "PA")
		If(__cUserID $ GetMV("MV_YBLQSE2"))
			MsgStop("Usuario Sem Acesso a Incluir Titulos à Pagar (Exceto PA)!. Verifique")
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet
