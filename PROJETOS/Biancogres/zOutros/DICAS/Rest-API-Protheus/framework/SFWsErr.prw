#Include 'Protheus.ch'

// Define o Carriage Return (CR) e Line Feed (LF)
// CR = Retorna o carro (referência a maquinas de escrever)
// LF = Alimenta nova linha
#DEFINE CRLF (Chr(13)+Chr(10))

/*/{Protheus.doc} SFWSErr
Formata mensagem de erro para uso complementar no restFault do webservice
@type function
@author Giovani
@since 19/09/2017
@version 1.0
@param
cErro, character, mensem de erro gerada pelo MostraErro() do MsExecAuto()
aRelation, array, array de correlacionamento de dados da estrutura WS X Protheus
@return cParam, string formatada com aspas duplas
@example
u_SFWSErr(cErro,aRelation)
/*/
User Function SFWSErr(cErro,aRelation)

	Local cMensagem := ''
	Local nI := 0
	Local nY := 0
	Local nCnt := 0
	Local aErro := {}
	Local lRelation := .F.

	Default cErro := ''
	Default aRelation := {}

	If !Empty(cErro) .And. !Empty(aRelation)

		// Converte cErro para array conforme CRLF
		aErro := StrToKarr(cErro,CRLF)

		// Identifica o campo inválido
		For nI:=1 to Len(aErro)
			If At('< --',aErro[nI]) > 0
				For nY:=1 To Len(aRelation)
					If At(aRelation[nY,2],aErro[nI]) > 0
						cMensagem := 'invalid content for field ' + aRelation[nY,1] + ' ('
						lRelation := .T.
						Exit
					EndIf
				Next
				Exit
			EndIf
		Next

		// Remove quebras de linha
		cMensagem += StrTran(cErro,CRLF,' ')

		// Remove espaçamentos duplicados
		nCnt := 1
		While At('  ',cMensagem) > 0 .Or. nCnt == 2000
			cMensagem := StrTran(cMensagem,'  ',' ')
			nCnt++ // permite no máximo 2000 iterações
		EndDo

		// Remove acentuação
		cMensagem := FWnoAccent(cMensagem)

		// Remove caixa alta
		cMensagem := Lower(cMensagem)

		If lRelation
			cMensagem += ')'
		EndIf

	EndIf

Return(cMensagem)
