#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} MA010BUT
@description Ponto de Entrada para inclusão de botões do usuário na barra de ferramentas do cadastro de Produtos.
@author Fernando Rocha
@since 13/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MA010BUT()

	Local aButtons := {} // botões a adicionar

	IF INCLUI

		AAdd(aButtons,{ 'NOTE', {| |  U_PDMTCPRD() }, 'Incluir pelo PDM','Incluir pelo PDM' } )
		
	ELSE
		
		AAdd(aButtons,{ 'NOTE', {| |  U_PDMTPMAR(ALTERA) 	}, 'Marcas PDM'	, 'Marcas PDM' 	} )
		AAdd(aButtons,{ 'NOTE', {| |  U_PDMPROD() 			}, 'PDM x Produto'	, 'PDM x Produto' 	} )
		
	ENDIF

Return (aButtons)
