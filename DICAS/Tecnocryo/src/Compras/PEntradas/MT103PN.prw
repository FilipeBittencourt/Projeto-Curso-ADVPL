#include "Protheus.ch"
#include "rwmake.ch"

/*
------------------------------------------------------------------------------------------------------------
Função		: MT103PN
Tipo			: Funcao do usuario
Descrição		: 
Uso			: 
Parâmetros	:
Retorno		:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 09/11/2015 - Pontin - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
User Function MT103PN()      

	Local lAtvXML	:= SuperGetMV("ZZ_ATVXML",.F.,.F.)
	
	If lAtvXML .And. SubStr(Alltrim(FunName()),1,3) == 'PTX'
		//MsgRun("Calculando impostos, aguarde...","Processando",{|| U_PTX0015(.T.) })	
		FWMsgRun(, {|| U_PTX0015(.T.) }, "Processando!", "Calculando impostos, aguarde...")			
	EndIf
	
Return .T.