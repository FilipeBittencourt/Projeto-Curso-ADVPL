#include "rwmake.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} CT105LOK
@description Ponto de entrada no momento da abertura da tela de contabilização
@author Gabriel Rossi Mafioletti
@since 15/04/2019
@version undefined
@type function
/*/

USER FUNCTION CT102DLG()

	Local _aArea	:=	GetArea()
	Local cCVcred
	Local cCVdeb

	TMP->(DbGoTop())

	While TMP->(!EOF())

		cCVcred := TMP->CT2_CLVLCR
		cCVdeb  := TMP->CT2_CLVLDB

		If IsInCallStack('BIA798') .or. IsInCallStack('BIA554') .or. IsInCallStack('BIA799')

			TMP->CT2_YAPLIC   := "1"   // Aplicação Produção
			If !Empty(TMP->CT2_CLVLCR)
				TMP->CT2_YDRVCR   := aArrayCt[hj][13]
			ElseIf !Empty(TMP->CT2_CLVLDB)
				TMP->CT2_YDRVDB   := aArrayCt[hj][13]
			EndIf

		Else

			fGravaApli()
			
			fGravaSubItem()

		EndIf

		//TICKET 22710 - Incluindo bloco abaixo com intencao de preencher o campo CT2_YAPLIC para LP de Faturamento quando RPV que usa CV de CUSTO
		If IsInCallStack("MATA460A") .Or. IsInCallStack("MATA460") .Or. IsInCallStack('BACP0010') .Or. IsInCallStack('BACP0014') .Or. ( CLOTE == "008820" )

			IF SUBSTR(cCvCred,1,1) $ '3' .Or. SUBSTR(cCvDeb,1,1) $ '3'
				TMP->CT2_YAPLIC	:=	"1"
				TMP->CT2_TPSALD :=  "1"  //para tentar forçar a não gerar como pre-lancamento
			ENDIF

		EndIf
		//FIM >>> TICKET 22710

		TMP->(DbSkip())

	EndDo

	TMP->(DbGoTop())
	RestArea(_aArea)

Return


Static Function fGravaApli()

	Local _aArea	:=	GetArea()

	Local _cKey		:=	""
	Local _cAlias	:=	""
	Local _nOrder	:=	0
	Local _cAplic	:=	""
	Local _cDriver	:=	""

	CTL->( dbSetOrder(1) )
	If CTL->( dbSeek( xFilial("CTL") + TMP->CT2_LP ) )

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey   := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1"
			&(_cAlias)->( dbSetOrder(_nOrder) )
			If &(_cAlias)->( dbSeek( Alltrim(TMP->CT2_KEY) ) )
				If Alltrim(_cAlias) == "SD3"
					_cAplic		:=	SD3->D3_YAPLIC
					_cDriver	:=	SD3->D3_YDRIVER
				ElseIf Alltrim(_cAlias) == "SD1"
					_cAplic		:=	SD1->D1_YAPLIC
					_cDriver	:=	SD1->D1_YDRIVER
				Else
					RestArea(_aArea)
					Return
				EndIf
				If Empty(TMP->CT2_YAPLIC)
					TMP->CT2_YAPLIC   := _cAplic
				EndIf
				If !Empty(TMP->CT2_CLVLCR) .And. Empty(TMP->CT2_YDRVCR)
					TMP->CT2_YDRVCR   := _cDriver
				EndIf
				If !Empty(TMP->CT2_CLVLDB) .And. Empty(TMP->CT2_YDRVDB)
					TMP->CT2_YDRVDB   := _cDriver
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(_aArea)

Return


Static Function fGravaSubItem()
Local _aArea := GetArea()
Local _cKey := ""
Local _cAlias	:= ""
Local _nOrder	:= 0
Local _cSubItem := ""

	CTL->(dbSetOrder(1))
	If CTL->(dbSeek(xFilial("CTL") + TMP->CT2_LP))

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1/SE2"
		
			&(_cAlias)->(dbSetOrder(_nOrder))
			
			If &(_cAlias)->(dbSeek(Alltrim(TMP->CT2_KEY)))
			
				If Alltrim(_cAlias) == "SD3"
				
					_cSubItem	:= SD3->D3_YSUBITE
					
				ElseIf Alltrim(_cAlias) == "SD1"
					
					_cSubItem	:= SD1->D1_YSUBITE
					
				ElseIf Alltrim(_cAlias) == "SE2"
				
					_cSubItem	:= SE2->E2_YSUBITE
					
				Else
					
					RestArea(_aArea)
					
					Return()
					
				EndIf
								
				If !Empty(TMP->CT2_CLVLCR) .And. Empty(TMP->CT2_YSUBCR)
					
					TMP->CT2_YSUBCR := _cSubItem
					
				EndIf
				
				If !Empty(TMP->CT2_CLVLDB) .And. Empty(TMP->CT2_YSUBDB)
					
					TMP->CT2_YSUBDB := _cSubItem
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf

	RestArea(_aArea)

Return()