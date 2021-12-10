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
	Local cLocal	:=	Gdfieldget("C1_LOCAL",n)
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

	If lRet .And. !GdDeleted() .And. !fCheckMd(nProd,cLocal)
		MsgStop("O Produto não poderá ser solicitado no Almoxarifado atual pois o mesmo é MD e não está cadastrado como MD nos demais almoxarifados!")
		lRet	:=	.F.
	EndIf
Return(lret)

Static Function fCheckMd(cProd,cLocal)
	
	Local _aArea	:=	GetArea()
	Local _lRet	:=	.T.
	Local _oMd	:=	tBiaControleMD():New()

	
	If _oMd:CheckMd(cProd,cLocal) 

		ZCN->(DbSetOrder(2))
		If ZCN->(DbSeek(xFilial("ZCN")+cProd))
			While ZCN->(!EOF()) .And. ZCN->(ZCN_FILIAL+ZCN_COD) == xFilial("ZCN")+cProd
				If ZCN->ZCN_LOCAL <> cLocal .And. !_oMd:CheckMd(ZCN->ZCN_COD,ZCN->ZCN_LOCAL)
					_lRet	:= .F.
				EndIf
				ZCN->(DbSkip())
			EndDo
		EndIf

	EndIf
	
	RestArea(_aArea)
Return _lRet