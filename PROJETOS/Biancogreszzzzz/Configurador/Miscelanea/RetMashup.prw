#include "protheus.ch"

/*
##############################################################################################################
# PROGRAMA...: RetMashup
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/10/2013                      
# DESCRICAO..: PONTO DE ENTRADA PARA TRATAR O RETORNO DO MASHUP (CONCATENAR CAMPO ENDERECO COM END + NUM + COMP)
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function RetMashup()       

Local cAlias := ParamIXB[1]  		// Alias da tabela
Local cMashup := ParamIXB[2] 		// Nome do serviço do Mashup
Local cDescri := ParamIXB[3]		// Descrição do retorno
Local cCampo := ParamIXB[4]			// Campo de retorno
Local xConteudo := ParamIXB[5]      // Conteúdo
Local xRet
Local cCampoEnd   
		
If cMashup == "ReceitaFederal.CNPJ"	    //NOME DO MASHUP QUE ESTA SENDO TRATADO 
	
	cCampoEnd := Substr(cAlias,2,2)+'_END'
        
	If cDescri == "Numero"		                        
		If !Empty(xConteudo) 
			M->(&cCampoEnd) := Alltrim(M->(&cCampoEnd)) + "," + xConteudo
			If (Empty(M->(&cCampo)))
				xRet := ''
			Else          
				xRet := M->(&cCampo)
			EndIf
		EndIf
	EndIf  
	If cDescri == "Complemento"
		If !Empty(xConteudo)
			cCompl := xConteudo
			M->(&cCampoEnd) := Alltrim(M->(&cCampoEnd)) + "-" + xConteudo
			If (Empty(M->(&cCampo)))
				xRet := ''
			Else          
				xRet := M->(&cCampo)
			EndIf
		EndIf
	EndIf
EndIf

Return xRet