#include 'protheus.ch'
#include 'totvs.ch'
#include "RWMAKE.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FPINVL02
@description Função para validar a regra01 ao selecionar o cliente
@author Filipe Vieira
@since 03/12/2018
@version 1.0
@type function
@OBS.: X3 VALIDAÇÃO DE USUARIO NO CAMPO UA_CLIENTE U_FPINVL02()
/*/


User Function FPINVL02(cXCodCli,cXLoja)
	
	Local oClienteC  	:= Nil
    Local oClienteM  	:= Nil
	Local oTVLDBLPC 	:= Nil
	Local cRetorno		:= ""
	Local lRet			:= .T. 

	Default cXCodCli	:= ""
	Default cXLoja		:= ""

	

	If Upper(AllTrim(FunName())) == "MATA415"
		cXCodCli	:= M->CJ_CLIENTE
		cXLoja		:= M->CJ_LOJA
	Else
		cXCodCli	:= M->UA_CLIENTE
		cXLoja		:= M->UA_LOJA
	EndIf



	oClienteC  := TINClienteController():New() // Instancia o controller
   	oClienteM  := oClienteC:GetCliLoja(XFilial("SA1"),cXCodCli,cXLoja)	 // Recuperar o modelo do negócio
	oTVLDBLPC  := TINAvaliaBloqueioPedidoController():New()  // Instancia a rotina de regras


	If !Empty(oClienteM:cCGC)

		If lRet .And. oTVLDBLPC:Regra01(oClienteM)
			cRetorno += " Regra 01 -> Cliente com mais de 6 meses sem revisão de cadastro." + CRLF +;
						" Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
						" Última Revisão: " + DtoC(oClienteM:dRevisao) + CRLF+;
						" Favor considerar abrir um chamado no OCOMON."+ CRLF + CRLF

			//|Mostra log de regras bloqueadas |
			lRet := U_FPINTE03(cRetorno,"FPINVL01","2")

		EndIf


		If verifCli(cXCodCli,cXLoja)			
			ApMsgInfo("Este cliente tem pedidos em análise de crédito. Por favor, salve o mesmo como <b>ATENDIMENTO</b>.")  
		EndIf	 

	EndIf


Return lRet


Static Function verifCli(cXCodCli,cXLoja)	

	Local cQuery := ""
	Local lContinua := .F.	
 
	cQuery	+= " SELECT *  "
	cQuery	+= " FROM " + RetSqlName("ZZ8")
	cQuery	+= " WHERE  D_E_L_E_T_ = ''   "
	cQuery	+= " AND ZZ8_CLIENT = " + ValToSql(cXCodCli)
	cQuery	+= " AND ZZ8_LOJA   = " + ValToSql(cXLoja)
	cQuery	+= " AND ZZ8_STATUS = '5' ;"	
 
	TcQuery cQuery New Alias "TBZZ8"	 
	
	TBZZ8->(dbGoTop())

	If !TBZZ8->(EoF()) //Achou
		If TBZZ8->ZZ8_STATUS == '5'				 
			lContinua	:= .T.	 		 
		EndIf
	EndIf
	
	TBZZ8->(dbCloseArea()) 
	
Return lContinua
 
 