#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} GP010VALPE
@author Marcos Alberto Soprani
@since 13/06/13
@version 1.0
@description Ponto de Entrada que valida a Inclusão/Alteração do cadastro de
.            funcionários.
@obs Em 16/03/17... Por Marcos Alberto Soprani... Ajustado para absorver as instruções que eram executadas pelo
.               ponto de entrada GPEA010
@type function
/*/

User Function GP010VALPE()

	Local yjValdOk  := .T.
	Local yjAreaAtu := GetArea()
	Local _TRB1     := ""

	// Marcelo - Facile - 25/03/2018 - Tratamento ticket 12964-19 para não permitir salário em branco caso funcionário
	// Não seja autônomo.	
	IF (M->RA_CATFUNC <> 'A' .AND. M->RA_CODFUNC <> '9998') .AND. M->RA_SALARIO = 0 .AND. INCLUI

		Alert("Campo Salário não pode estar vazio")
		Return .F.

	ENDIF
	
	If M->RA_PERCSAT <> 0 .and. Empty(M->RA_OCORREN)

		yjValdOk := .F.
		Aviso( 'Gp010ValPE', 'Favor verificar os campos: %Acid.Trab e Ocorrência, pois foi identificada uma inconsistência no preenchimento destes campos!!!', {'Ok'} )

	EndIf

	// Marcelo - Facile - 10/12/2018 - Tratamento ticket 10338-18 para desativar cadastro de participante antigo
	// Marcelo - Facile - 14/06/2019 - Tratamento ticket 15836-19 para desativar cadastro de participante antigo
	dbSelectArea("RD0")
	dbSetOrder(6)
	If dbSeek(xFilial("RD0")+M->RA_CIC,.T.) .AND. INCLUI

		Reclock("RD0",.F.)

			RD0->(DBDELETE())

		RD0->(MSUNLOCK())

	Endif

	If yjValdOk

		If IsInCallStack("Gpea010Inc") .Or. IsInCallStack("Gpea010Alt")

			dbSelectArea("ZZY")
			dbSetOrder(3)
			If !dbSeek(xFilial("ZZY")+cEmpAnt+M->RA_MAT,.T.)
				RecLock("ZZY",.T.)
				ZZY->ZZY_FILIAL		:= xFilial("ZZY")
				ZZY->ZZY_MATRIC		:= cEmpAnt+M->RA_MAT
				ZZY->ZZY_NOME		:= M->RA_NOME
				ZZY->ZZY_SITFUN		:= "N"
				ZZY->ZZY_EMPREG		:= cEmpAnt
				ZZY->ZZY_EMPREQ		:= cEmpAnt
				ZZY->ZZY_MSBLQL		:= "2"
				MsUnLock()
				DbCommitAll()
			Else
				RecLock("ZZY",.F.)
				ZZY->ZZY_NOME		:= M->RA_NOME
				MsUnLock()
				DbCommitAll()		
			EndIf


		EndIf

		U_BIAF043("0")

	EndIf

	RestArea(yjAreaAtu)	 

Return ( yjValdOk )
