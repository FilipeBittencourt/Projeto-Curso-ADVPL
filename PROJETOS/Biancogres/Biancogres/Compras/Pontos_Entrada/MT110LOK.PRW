#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT110LOK
@author Ranisses A. Corona
@since 03.03.03
@version 1.0
@description Solicitacao de Compras
@type function
/*/

User Function MT110LOK()

	Local lret      := .T.
	Local nProd	    := Gdfieldget("C1_PRODUTO",n)
	Private rtCLVL  := Gdfieldget("C1_CLVL",n)

	dbSelectArea("SBZ")
	dbSetOrder(1)
	dbSeek(xFilial("SBZ") + nProd,.T.)

	// Incluído por Marcos Alberto Soprani em 19/08/15 para atender ao novo controle de CLVL por empresa
	If lret
		lret := ExecBlock("BIA555", .F., .F., "SC1LOK1")
	EndIf

	If !GDDeleted() .and. Alltrim(GdFieldGet("C1_CONTA",n)) <> "41301001" 
		CTH->(DbSetOrder(1))
		If CTH->(DbSeek(xFilial("CTH") + rtCLVL)) .and. CTH->CTH_YATRIB == 'C' .and. GdFieldGet("C1_YAPLIC",n) $ ' _0'
			MsgStop("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!", "MT110LOK[1]")
			AutoGrLog("A Conta e a Classe de valor exigem que a Aplicação seja Informada e diferente de zero!")
			lRet	:=	.F.
		Endif
	Endif

Return(lret)
