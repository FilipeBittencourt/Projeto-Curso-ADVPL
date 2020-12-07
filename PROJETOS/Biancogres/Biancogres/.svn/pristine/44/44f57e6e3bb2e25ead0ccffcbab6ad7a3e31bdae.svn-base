#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} M460FIL
@author Ranisses A. Corona
@since 17/02/2011
@version 1.0
@description Ponto de entrada para adicionar filtro no SC9 - MATA460 / Deve ser utilizado junto com o P.E. M460QRY 
@type function
/*/

User Function M460FIL()
	Local cFiltro 	:= ".T."
	Local lUsaCarga	:= GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga

	//Variaveis de Posicionamento
	//--------------------------------
	Private aArea	:= GetArea()

	Private cArq 	:= Alias()
	Private cInd	:= IndexOrd()
	Private cReg	:= Recno()
	//--------------------------------

	//MT461A    
	IF lUsaCarga 
		IF !Empty(MV_PAR19) .And. !Empty(MV_PAR20)
			IF !Empty(cFiltro)
				cFiltro += " .And. "
			ENDIF
			cFiltro += " (SC9->C9_AGREG >= '"+MV_PAR19+"' .AND. SC9->C9_AGREG <= '"+MV_PAR20+"') "
		ENDIF
	ENDIF

	//Realiza Filtro dos Pedidos Liberados na LM, atraves das Cargas na Biancogres e/ou Incesa.
	If cEmpAnt == "07" .And. Len(aPedOri) > 0
		If (!Empty(MV_PAR19) .And. !Empty(MV_PAR20)) .Or. (!Empty(MV_PAR05) .And. !Empty(MV_PAR06))
			/*If !Empty(cFiltro)
			cFiltro += " .And. "
			EndIf
			If aPedOri[4]
			cFiltro	+= " ( Alltrim(SC9->C9_PEDIDO) $ ('"+aPedOri[1]+"') .AND. Alltrim(SC9->C9_PRODUTO)+SC9->C9_ITEM+SC9->C9_SEQUEN $ ('"+aPedOri[2]+"') .AND. Alltrim(Str(Round(SC9->C9_QTDLIB,2))) $ ('"+aPedOri[3]+"') ) "
			Else
			cFiltro	+= " ( Alltrim(SC9->C9_PEDIDO) $ ('"+aPedOri[1]+"') .AND. Alltrim(SC9->C9_PRODUTO)+SC9->C9_ITEM $ ('"+aPedOri[2]+"') .AND. Alltrim(Str(Round(SC9->C9_QTDLIB,2))) $ ('"+aPedOri[3]+"') ) "
			EndIf*/

			//Fernando/Ranisses em 04/07/2018 - nova versão do filtro pelo campo empresa origem gravado no SC9 (Comentado versao antiga acima)
			If !Empty(cFiltro)
				cFiltro += " .AND. "
			EndIf
			cFiltro	+= " ( Alltrim(SC9->C9_YEMPORI) == '"+MV_PAR21+"' )"

		EndIf
	EndIf


	#IfDef __DEBUG_FACILE

	// Tiago Rossini Coradini - 25/04/2016 - OS: 4329-15 - Dalvina Maria - Adiciona filtro de Serie na Nota Fiscal de Saida, especifico para LM
	If cEmpAnt == "07"

		cFiltro += " .AND. U_BIAF031(SC9->C9_PEDIDO) "

	EndIf

	#EndIf

	If cArq <> ""
		dbSelectArea(cArq)
		dbSetOrder(cInd)
		dbGoTo(cReg)
	EndIf

	__cCargaDe := MV_PAR19
	__cCargaAte := MV_PAR20

	//alterar automaticamente respostas na segunda pergunta do faturamento
	u_zAtuPerg("MT460A", "MV_PAR09", __cCargaDe)
	u_zAtuPerg("MT460A", "MV_PAR10", __cCargaAte)
	Pergunte("MT461A",.F.)  //recuperar na memoria a pergunta original primeira

	RestArea(aArea)

Return(cFiltro)