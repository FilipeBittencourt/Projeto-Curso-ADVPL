#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} MTAGRSD4
@author Gabriel Rossi Mafioletti
@since 20/07/2017
@version 1.0
@description Ponto de Entrada após a gravação de empenho
@type function
/*/

User Function MTAGRSD4()

	Local aArea	:=	GetArea()

	SBZ->(DbSetOrder(1))
	If SBZ->(DbSeek(xFilial("SBZ")+SD4->D4_COD)) .And. SBZ->BZ_YEMPENH == "N"
		Reclock("SD4",.F.)
		SD4->(DbDelete())
		SD4->(MsUnlock())
	EndIf

	// 26/07/17... Por Marcos Alberto Soprani
	// Projeto outsourcing = Canal de comercialização Fabrica ==>> Fabrica (Originalmente Biancogres ==>> Incesa)
	// Em 24/09/18, retirado de uso
	// Em 15 de outubro 2018 . Conforme definição com Marcos e Camila. As movimentações feitas na linha 003 Incesa não gerarão empenho
	If cEmpAnt $ "05"
		spRegSc2 := SC2->(Recno())
		SC2->(dbSetOrder(1))
		If SC2->(dbSeek(xFilial("SC2") + Substr(SD4->D4_OP,1,8) + "001"))
			If Alltrim(SC2->C2_LINHA) $ ("003/L03/E3A")
				Reclock("SD4",.F.)
				SD4->(DbDelete())
				SD4->(MsUnlock())
			EndIf
		EndIf
		SC2->(dbGoTo(spRegSc2))
	EndIf

	RestArea(aArea)

Return