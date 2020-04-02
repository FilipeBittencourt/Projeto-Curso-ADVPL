#Include "rwmake.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "fileio.ch"
#Include "colors.ch"
#Include "TBICONN.CH"
#Include "TOTVS.CH"
#Include "PROTHEUS.CH"


/*
##############################################################################################################
# PROGRAMA...: FCACWF01
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 20/05/2015
# DESCRICAO..: Programa para envio e-mail
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/

User Function SendMail(_aTO,_aCC,_aCCO,_cSUBJECT,_cBODY,_aAnexo,_lFormTexto)
Local _cServidor, _cConta, _cSenha, _lResult, _cErro
_aTO           := iif(valtype(_aTO)<>"A",{},_aTO)
_aCC           := iif(valtype(_aCC)<>"A",{},_aCC)
_aCCO          := iif(valtype(_aCCO)<>"A",{},_aCCO)
_aAnexo        := iif(valtype(_aAnexo)<>"A",{},_aAnexo)
_lFormTexto    := iif(valtype(_lFormTexto)<>"L",.F.,_lFormTexto)
_cServidor     := "smtp.gmail.com:587" //alltrim(GETMV("MV_RELSERV"))
_cConta        := "workflow@centraldearcomprimido.com.br" //alltrim(GETMV("MV_RELACNT"))
_cSenha        := "W05KF10WProtheus" //alltrim(GETMV("MV_RELPSW"))
_cErro         := ""


CONNECT SMTP SERVER _cServidor ACCOUNT _cConta PASSWORD _cSenha RESULT _lResult
if _lResult
	// Autenticacao de e-mail
	MailAuth(_cConta, _cSenha)
	_lResult := MailSend( _cConta, _aTO, _aCC, _aCCO, _cSUBJECT, _cBODY, _aAnexo, _lFormTexto )
endif
if !_lResult
	GET MAIL ERROR _cErro
endif
DISCONNECT SMTP SERVER  

Return {_lResult,_cErro}