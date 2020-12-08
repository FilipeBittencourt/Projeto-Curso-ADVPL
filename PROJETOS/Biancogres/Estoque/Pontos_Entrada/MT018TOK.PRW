#include "rwmake.ch"
#include "topconn.ch"

User function MT018TOK()

/*���������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT018TOK  �Autor  �Ranisses A. Corona  � Data �  26/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida alteracao do campo BZ_YCOMUM, verificando saldos     ���
���          �no almoxarifado 6                                           ���
�������������������������������������������������������������������������͹��
���Uso       �Estoque                                                     ���
�������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������*/

Local lRet := .T.
Local _cAlias
Local _cNum
Local _aSaldos	:=	{}

If (INCLUI .Or. ALTERA) .and. cEmpAnt $ "01/05" 			//Executa validacao na Inclusao e Alteracao do Indicador. A partir de 14/04/14 passar a ser �tilizado apenas para as empresa 01 e 05. Por Marcos Alberto Soprani
	
	//Valida Almoxarifado com Produto Comum
	
	/*If (Substr(M->BZ_LOCPAD,1,1) == "6" .And. M->BZ_YCOMUM == "N") .Or. Substr(M->BZ_LOCPAD,1,1) <> "6" .And. M->BZ_YCOMUM == "S"
		If Substr(M->BZ_LOCPAD,1,1) == "6"
			MsgBox("Para utilizar o Almoxarifado 6, � necess�rio informar o campo Produto Comum = SIM!","MT018TOK","STOP")
		Else
			MsgBox("Para utilizar Produto Comum, o Almoxarifado deve estar preenchido com 6B ou 6I!","MT018TOK","STOP")
		EndIf
		lRet := .F.
	EndIf*/                              
	                                    
	//Fernando/Facile em 03/12/2015 -> acabar com o armazem de produto comum - cada empresa passa a comprar seu produto (Comentado o bloco acima)
	If ( Substr(M->BZ_LOCPAD,1,1) == "6" )
		MsgBox("O uso de Produto Comum foi encerrado. N�o � mais poss�vel cadastrar o Almoxarifado 6B ou 6I!","MT018TOK","STOP")
		lRet := .F.
	EndIf
	
	//Thiago Haagensen - Ticket 27094 - Regra antiga e n�o mais necess�ria.
	/*
	//Verifica se o produto Comum possui Saldo no Almoxarifado 6
	If  M->BZ_YCOMUM == "N"
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT SUM(QUANT) QUANT
			FROM
			(SELECT ISNULL(SUM(B2_QATU),0) QUANT FROM SB2010 WHERE B2_COD = %Exp:M->BZ_COD% AND SUBSTRING(B2_LOCAL,1,1) = '6' AND %NOTDEL%
			UNION ALL
			SELECT ISNULL(SUM(B2_QATU),0) QUANT FROM SB2050 WHERE B2_COD = %Exp:M->BZ_COD% AND SUBSTRING(B2_LOCAL,1,1) = '6' AND %NOTDEL%) AS WWW
		EndSql
		
		//Caso o produto tenha saldo, faz o bloqueio da alteracao.
		If (cAliasTmp)->QUANT > 0
			MsgBox("Este produto possui saldo no Almoxarifado 6. Antes de alterar o campo Comum favor transferir o saldo do Almoxarifado 6 para 01!","MT018TOK","STOP")
			lRet := .F.
		EndIf
		
		(cAliasTmp)->(dbCloseArea())
		
	EndIf
	*/
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
			Z09->Z09_OBS	 := "Politica Atual: " + M->BZ_YPOLIT + "/" + "Valor Unit�rio: " + Alltrim(TransForm(_aSaldos[2]/_aSaldos[1],"@E 999,999,999.99")) + "/" + "Valor Total: " + Alltrim(TransForm(_aSaldos[2],"@E 999,999,999.99"))   
		Z09->(MsUnlock())
		
	EndIF
EndIf

Return(lRet)