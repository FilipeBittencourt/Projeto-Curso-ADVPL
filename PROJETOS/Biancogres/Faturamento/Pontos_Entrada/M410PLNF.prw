#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} M410PLNF
@author Ranisses A. Corona
@since 16/08/2011
@version 1.0
@description P.E. para exibir informacoes referente ao valores de ICMS ST gerado atraves de guia avulsa a NF.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@type function
/*/

User Function M410PLNF()
Local cMsg		:= ""									//
Local Enter		:= CHR(13)+CHR(10)						//
Local nVlTotal	:= MaFisRet(,"NF_TOTAL")				//Valor Total da NF
Local nVlSolid	:= MaFisRet(,"NF_VALSOL")				//Valor Total ICMS ST
Local nVlTotCr	:= 0									//Valor Total para Analise de Credito
Local cEST		:= U_fGetUF(FunName())[2]				//UF do Cliente/Fornecedor
Local cUFSTSD	:= GetMV("MV_YUFSTSD") 					//Estados SEM Destaque do ICMS ST na NF


If nVlSolid > 0 .And. Alltrim(cEST) $ cUFSTSD

	//Para empresa LM o sistema está calculando a variavel MaFisRet(,"NF_TOTAL") ja considerando o valor da variavel MaFisRet(,"NF_VALSOL"), por este motivo estamos realizando o acerto abaixo.	
	If SF4->F4_INCSOL == "S"
		nVlTotal	:=	nVlTotal-nVlSolid
		nVlTotCr	:=	nVlTotal
	Else
		nVlTotCr	:=	nVlTotal+nVlSolid 		
	EndIf
	
	cMsg := "Este pedido irá gerar Guia de ICMS ST avulsa a NF." + Enter
	cMsg += "Os valores apresentados serão considerados apenas para análise de crédito!" + Enter
	MsgBox(cMsg ,"Cálculo ICMS ST","ALERT")
	
	cMsg := "Valor Total NF		"	+ REPLICATE(".",02) + Transform(nVlTotal, 	"@E 999,999,999.99") + Enter
	cMsg += "Valor Guia ICMS ST	"	+ REPLICATE(".",02) + Transform(nVlSolid,	"@E 999,999,999.99") + Enter
	cMsg += ""	+ Enter
	cMsg += "Valor Total (Análise Crédito)	"	+ REPLICATE(".",02) + Transform(nVlTotCr,	"@E 999,999,999.99") + Enter
	MsgBox(cMsg ,"Cálculo ICMS ST","INFO")
	
EndIf

Return()