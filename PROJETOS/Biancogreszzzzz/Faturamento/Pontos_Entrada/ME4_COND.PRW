#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ME4_COND
@description Calcula valor da Parcela, e sendo menor que o parametro - MV_YLIMFAT, o sistema procura outra Cond. Pagamento  
@author Ranisses A. Corona / Revisao por Fernando no projeto Faturamento Automatico
@since 29/09/09 
@version 1.0
@type function
/*/

User Function ME4_COND()
	Local lAlt		:= .F.
	Local aCond		:= {}	//Ira retornar a nova condicao de Pagamento
	Local cQuery	:= ""
	Local Enter 	:= CHR(13)+CHR(10)

	//Faturamento Automatico - a condicao ja deve estar setada no Pedido
	If Type("nNovaCond") == "U"
		Return(Nil)
	EndIf

	//Variaveis de Posicionamento
	Private aArea	:= GetArea()

	dbSelectArea("SF2")
	Private cArqSF2	:= Alias()
	Private cIndSF2	:= IndexOrd()
	Private cRegSF2	:= Recno()

	dbSelectArea("SE4")
	Private cArqSE4	:= Alias()
	Private cIndSE4	:= IndexOrd()
	Private cRegSE4	:= Recno()

	If Empty(Alltrim(nNovaCond)) //Se a variavel estiver vazia, ira armazenar a Condicao Original
		//Posiciona e armazena a condicao de pagamento original da NF
		Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_CODIGO")

		//Se for diferente do tipo B (multiplas condições)
		If Alltrim(SE4->E4_TIPO) <> "B"
			aCond := {SE4->E4_CODIGO , SE4->E4_COND, SE4->E4_TIPO, SE4->E4_DDD, SE4->E4_IPI, SE4->E4_SOLID}
		Else
			aCond := Nil
		EndIf

	Else

		//Posiciona e armazena a NOVA CONDICAO DE PAGAMENTO da NF
		Posicione("SE4",1,xFilial("SE4")+nNovaCond,"E4_CODIGO")
		aCond := {SE4->E4_CODIGO , SE4->E4_COND, SE4->E4_TIPO, SE4->E4_DDD, SE4->E4_IPI, SE4->E4_SOLID}

		//Atualiza a Condicao no Cabecalho da NF
		DbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_COND :=	_SE4->E4_CODIGO
		MsUnLock()			

	EndIf

	If cArqSF2 <> ""
		dbSelectArea(cArqSF2)
		dbSetOrder(cIndSF2)
		dbGoTo(cRegSF2)
	EndIf

	If cArqSE4 <> ""
		dbSelectArea(cArqSE4)
		dbSetOrder(cIndSE4)
		dbGoTo(cRegSE4)
	EndIf

	RestArea(aArea)

Return(aCond)