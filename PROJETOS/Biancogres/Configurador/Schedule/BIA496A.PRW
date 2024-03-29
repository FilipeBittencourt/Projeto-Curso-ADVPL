#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"
#include "Protheus.ch"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA496A    � Autor � Wanisay William       � Data � 22.05.12      ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Envia o estoque da consulta F6 para os representantes             ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                               ���
���������������������������������������������������������������������������������ı�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
/*/{Protheus.doc} BIA496A
@description Envia workflow de estoque disponivel para os representantes
@author NDA
@since 22/05/12
@version 1.0
@type function
/*/ 

User Function BIA496A()


	Local aArea     := {}
	Local aEmp      := {}
	Local aVeder    := {}
	Local aMarca    := {}
	Local nI        := 1
	Local nK        := 1
	Local nJ        := 1
	Local cSql      := ''
	Local cMsg      := ""
	Local cQry      := GetNextAlias()
	Local aFiles := {} // O array receber� os nomes dos arquivos e do diret�rio
	Local aSizes := {} // O array receber� os tamanhos dos arquivos e do diretorio


	aEmp := {"01","05","07","13","14"}


	RpcSetType(3)
	RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SA3","SF1", "SF2"})

	If U_GETBIAPAR("REP_BLQREST",.F.)
		Conout("Consulta temporariamente indispon�vel para o relat�rio BIA496.PRW","BIAFG134.PRW")
		RpcClearEnv()
		return
	EndIf

	aArea := SA3->(GetArea())
	DbSelectArea("SA3")

	cSql :="  select  SA3.A3_YEMP, SA3.A3_COD, SA3.A3_EST FROM SA3010 as SA3 " +CRLF
	cSql +="  WHERE 0=0 " +CRLF
	cSql +="  AND SA3.A3_EMAIL <> '' " +CRLF
	cSql +="  AND SA3.A3_YATIVO = 'S' " +CRLF
	cSql +="  AND SA3.A3_YEMP  NOT LIKE '%XX%' " +CRLF
	//cSql +="  AND SA3.A3_COD   in ('000666', '000728','000025','000082') " +CRLF //000082, 000717, 999999
	cSql +="  AND SA3.D_E_L_E_T_ = '' " +CRLF
	cSql +="  ORDER BY SA3.A3_COD " +CRLF

	TcQuery cSql Alias (cQry) New
	SA3->(DbSetOrder(1))
	(cQry)->(DbGoTop())

	//Pegando todos os Representates ativos
	While !(cQry)->(Eof())
		aMarca := {}

		AADD(aMarca,StrTokArr(AllTrim((cQry)->(A3_YEMP)), "/"))
		AADD(aVeder,{(cQry)->(A3_COD), (cQry)->(A3_EST) ,aMarca[1]})
		(cQry)->(DbSkip())

	EndDo

	RestArea(aArea)
	RpcClearEnv()



	For nI := 1 To Len(aEmp) //Percorrendo empresas envolvidas

		RpcSetType(3)
		RPCSetEnv(aEmp[nI], "01", NIL, NIL, "COM", NIL, {"SA3","SF1", "SF2"})

		For nK := 1 To Len(aVeder)  //Percorrendo vendedores

			IF SA3->(DBSeek(FWXFilial("SA3")+aVeder[nK,1]))

				CREPATU := aVeder[nK,1]

				For nJ := 1 To Len(aVeder[nK,3])  //Percorrendo Marcas do Representante

					cMsg := "FILIAL: "+aEmp[nI]+ " | "
					cMsg += "Vendedor: "+aVeder[nK,1]+ " | "
					cMsg += "Marca: "+aVeder[nK,3,nJ]
					ConOut("BIA496A INICIADO em "+dtoc(dDatabase)+"-"+Time()+" - "+cMsg+"")

					If aEmp[nI] == "07" .AND. aVeder[nK,2] == "SP" .and. aVeder[nK,3,nJ] $ "1302#1301"

						U_BIA496(aEmp[1] , .F., aVeder[nK,3,nJ], "Estoque")
						U_BIA496(aEmp[1] , .T., aVeder[nK,3,nJ], "Amostra") // Envia WF de estoque de Amostra, precisa ser separado.

					Elseif left(aVeder[nK,3,nJ] ,2)  == aEmp[nI]

						U_BIA496(aEmp[1] , .F., aVeder[nK,3,nJ], "Estoque")
						U_BIA496(aEmp[1] , .T., aVeder[nK,3,nJ], "Amostra") // Envia WF de estoque de Amostra, precisa ser separado.

					EndIf

				Next nJ

			EndIf

		Next nK

		RpcClearEnv()

	Next nI

	ADir("\P10\workflow\*.*", aFiles, aSizes)
	For nK := 1 To Len(aFiles)
		FERASE("\P10\workflow\"+aFiles[nK])
	Next nK

Return()
