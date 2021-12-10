#include "rwmake.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT018TOK  ºAutor  ³Ranisses A. Corona  º Data ³  26/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida alteracao do campo BZ_YCOMUM, verificando saldos     º±±
±±º          ³no almoxarifado 6                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Estoque                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User function MT018TOK()

	Local lRet := .T.
	Local _cAlias
	Local _cNum
	Local _aSaldos	:=	{}

	If (INCLUI .Or. ALTERA) .and. cEmpAnt $ "01/05" 			//Executa validacao na Inclusao e Alteracao do Indicador. A partir de 14/04/14 passar a ser útilizado apenas para as empresa 01 e 05. Por Marcos Alberto Soprani

		//Fernando/Facile em 03/12/2015 -> acabar com o armazem de produto comum - cada empresa passa a comprar seu produto (Comentado o bloco acima)
		If ( Substr(M->BZ_LOCPAD,1,1) == "6" )
			MsgBox("O uso de Produto Comum foi encerrado. Não é mais possível cadastrar o Almoxarifado 6B ou 6I!","MT018TOK","STOP")
			lRet := .F.
		EndIf

		If ALTERA .And. M->BZ_YPOLIT <> SBZ->BZ_YPOLIT

			_cAlias	:=	GetNextAlias()
			BeginSql Alias _cAlias
				SELECT  ISNULL(MAX(Z08_NUMPRC), '000000000') NUM
				FROM    %TABLE:Z08% Z08
				WHERE   Z08_FILIAL = %xFilial:Z08%
				AND Z08.%NotDel%
				AND Z08_NUMPRC <> '1'
			EndSql

			_cNum	:=	SOMA1((_cAlias)->NUM)

			(_cAlias)->(DbCLoseArea())
			RecLock("Z08",.T.)
			Z08->Z08_FILIAL  := xFilial("Z08")
			Z08->Z08_NUMPRC  := _cNum  
			Z08->Z08_DTPRC   := dDataBase
			Z08->Z08_HRPRC   := Time()
			Z08->Z08_USRPRC  := UsrRetName(RetCodUsr())
			Z08->Z08_DTSYSP  := Date()
			Z08->Z08_ORIGPR  := "7"
			Z08->(MsUnLock())

			_aSaldos := CalcEst(M->BZ_COD,"01",ddatabase+1)

			RecLock("Z09",.T.)
			Z09->Z09_FILIAL  := xFilial("Z09")
			Z09->Z09_NUMPRC  := _cNum
			Z09->Z09_PRODUT  := M->BZ_COD 
			Z09->Z09_POLITI  := SBZ->BZ_YPOLIT
			Z09->Z09_QATU	 :=	_aSaldos[1]
			Z09->Z09_OBS	 := "Politica Atual: " + M->BZ_YPOLIT + "/" + "Valor Unitário: " + Alltrim(TransForm(_aSaldos[2]/_aSaldos[1],"@E 999,999,999.99")) + "/" + "Valor Total: " + Alltrim(TransForm(_aSaldos[2],"@E 999,999,999.99"))   
			Z09->(MsUnlock())

		EndIF

	EndIf

Return(lRet)
