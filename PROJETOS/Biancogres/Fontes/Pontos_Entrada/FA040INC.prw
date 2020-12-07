#INCLUDE "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} FA040INC
@description PE ao incluir conta a receber - Revisado por Fernando no Lobo Guara
@author ferna
@since 09/12/2019
@version 1.0
@type function
/*/
User Function FA040INC()
	Local nret := .T.

	//Verificar % de Comissao para Titulos <> NF
	If Alltrim(M->E1_TIPO) $ GetMV("MV_YNPCOM") .and. (M->E1_COMIS1 > 0 .or. M->E1_COMIS2 > 0 .or. M->E1_COMIS3 > 0 .or. M->E1_COMIS4 > 0 .or. M->E1_COMIS5 > 0)
		Help( ,, 'HELP',, "Esse tipo de titulo nao pode ter percentual diferente de zero nos campos % DE COMISSAO", 1, 0)
		nret := .F.
	EndIf

	//Executa teste apenas na Rotina de Inclusao do Contas a Receber
	If !( Upper(Alltrim(FUNNAME())) $ ("FINA280#FINA460") )
		//Verifica o preenchimento do campo Vendedor
		If Alltrim(M->E1_VEND1) == "" .And. !Alltrim(M->E1_TIPO) $ "BOL" 
			Help( ,, 'HELP',, "Favor preencher o campo Vendedor!", 1, 0)
			nret := .F.
		EndIf
	EndIf

	//Grava o NossoNumero para Titulos de ST, incluidos Manualmente do Contas a Receber - Somente para Biancogres
	If Alltrim(M->E1_TIPO) == "ST" .And. Alltrim(M->E1_NATUREZ) == "1230" .And. Alltrim(M->E1_NUMBCO) == "" //LIBERADO PARA TODAS AS EMPRESAS 
		E1_YCLASSE	:= "1" //Classe ST - Substituicao Tributaria
	EndIf

	If Alltrim(M->E1_TIPO) == "BOL" .And. Alltrim(M->E1_PREFIXO) == "CT"
		E1_YCLASSE	:= "2" //Classe BOL - Contratos
		E1_NUMBCO	:= U_fGeraNossoNumero("2")
	EndIf

Return(nret)	