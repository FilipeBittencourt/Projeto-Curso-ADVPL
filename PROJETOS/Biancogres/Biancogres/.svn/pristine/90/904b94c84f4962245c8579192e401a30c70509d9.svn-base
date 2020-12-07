#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwcommand.ch"

User Function FCLA0050; Return()

/*/{Protheus.doc} TReplicateData
@author Tiago Rossini Coradini
@since 04/07/2016
@version 1.1
@description Classe para replicação de Tabelas entre empreas do grupo.
//@history 05/07/2016, Tiago Rossini Coradini, Adicionada user function no fonte da Classe para tratamento de geração de patch
@type class
/*/

// Indices do array de empresas/filiais
#DEFINE nEmp 1
#DEFINE nFil 2
#DEFINE nAccMod 3

// Indices do array de campos
#DEFINE nFName 1
#DEFINE nFValue 2

Class TReplicateData From LongClassName

	// Propriedades da origem dos dados
	Data cTable // Tabela de origem dos dados
	Data cKey // Chave ta tabela
	Data aField // Campos que serão replicados
	Data cOpc // 3=Insert; 4=Update; 5=Delete
	Data aEmpFil // Lista de Empresas/Filiais

	// Propriedades de destino dos dados
	Data cNewTable // Tabela de destino dos dados
	Data cAccMod // Modo de acesso a tabela
	Data aTab // Lista de tabelas abertas

	Method New()
	Method GetField() // Retorna lista de campos da tabela
	Method GetEmpFil() // Retorna lista de empresas/filias
	Method Execute() // Executa rotina
	Method Reply() // Replica dados
	Method CloseTab() // Fecha tabelas abertas

EndClass


Method New() Class TReplicateData

	::cTable := ""
	::cKey := ""
	::aField := {}
	::cOpc := ""
	::aEmpFil := {}

	::cNewTable := ""
	::cAccMod := ""
	::aTab := {}

Return()


Method GetField() Class TReplicateData
Local nFCount := 0
Local aField := {}
Local cFName := ""

	For nFCount := 1 To (::cTable)->(FCount())

		cFName := (::cTable)->(FieldName(nFCount))

		aAdd(aField, {cFName, (::cTable)->(FieldGet(FieldPos(cFName))) })

	Next

Return(aField)


Method GetEmpFil() Class TReplicateData
Local aArea := SM0->(GetArea())
Local aRet := {}
Local _aSm0	:=	{}
Local _nI

	::aTab := {}

	DbSelectArea("SM0")
	DbSetOrder(1)
	SM0->(DbGoTop())
	
	_aSm0	:=	FWLoadSM0()
	
	For _nI	:=	1 to Len(_aSM0)

		::cNewTable := ::cTable + Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP])

		// Verifica se a tabela não foi aberta
		If Select(::cNewTable) == 0

			// Abre a tabela em outra empresa
			If EmpOpenFile(::cNewTable, ::cTable, 1, .T., Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP]), @::cAccMod)

				aAdd(aRet, {Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP]), _aSM0[_nI,SM0_FILIAL], ::cAccMod})

				// Adiciona tabela aberta a lista
				aAdd(::aTab, ::cNewTable)

			EndIf

			// Se a tabela já esta aberta, avalia o modo de acesso
		ElseIf ::cAccMod == "E"
			aAdd(aRet, {Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP]), _aSM0[_nI,SM0_FILIAL], ::cAccMod})
		EndIf

	Next

	RestArea(aArea)

Return(aRet)


Method Execute() Class TReplicateData

	U_BIAMsgRun("Replicando Dados...", "Aguarde!", {|| ::Reply() })

Return()


Method Reply() Class TReplicateData
Local aArea := GetArea()
Local nCount := 1
Local nFCount := 0
Local lInsert := .T.
Local cFil := ""

	::aEmpFil := ::GetEmpFil()

	::aField := ::GetField()

	While nCount <= Len(::aEmpFil)

		::cNewTable := ::cTable + ::aEmpFil[nCount, nEmp]

		cFil := If (::aEmpFil[nCount, nAccMod] == "E", ::aEmpFil[nCount, nFil], Space(FWSizeFilial()) )

		lInsert := !(::cNewTable)->(DbSeek(cFil + ::cKey))

		Begin Transaction

		RecLock(::cNewTable, lInsert)

		// 3=Insert; 4=Update
		If ::cOpc $ '3/4'

			For nFCount := 1 To (::cNewTable)->(FCount())

				cFName := (::cNewTable)->(FieldName(nFCount))

				If "FILIAL" $ cFName

					(::cNewTable)->(FieldPut(nFCount, cFil))

				Else

					// Verifica se os campos estão na mesma ordem
					If cFName == ::aField[nFCount, nFName]

						(::cNewTable)->(FieldPut(nFCount, ::aField[nFCount, nFValue]))

					Else

						// Procura campo no array de campos
						nFPos := aScan(::aField, {|x| x[nFName] == cFName })

						// Caso o campo exista, grava o valor
						If nFPos > 0

							(::cNewTable)->(FieldPut(nFCount, ::aField[nFPos, nFValue]))

						EndIf

					EndIf

				EndIf

			Next

		// 5=Delete
		ElseIf ::cOpc == '5'

			(::cNewTable)->(DbDelete())

		EndIf

		(::cNewTable)->(MsUnlock())

		End Transaction

		nCount++

	EndDo()

	::CloseTab()

	RestArea(aArea)

Return()


Method CloseTab() Class TReplicateData
Local nCount := 0

	For nCount := 1 To Len(::aTab)
		(::aTab[nCount])->(DbCloseArea())
	Next

Return()