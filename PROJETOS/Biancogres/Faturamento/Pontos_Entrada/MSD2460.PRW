#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MSD2460
@description Grava o Preco de Tabela e a Politica no Item da NF Saida. Esta informacao sera utilizada em Relat. p/ apuracao desconto. 
@author Ranisses A. Corona
@since 24/10/2008
@version undefined
@history 18/05/2017, Ranisses A. Corona, Gravação automatica da tabela SA5, para vendas intragrupo.
@type function
/*/

User Function MSD2460()

Local _oMd	:=	TBiaControleMD():New()

//Variaveis de Posicionamento
//--------------------------------
Private aArea	:= GetArea()
//--------------------------------

// Implementado em 19/04/13 por Marcos Alberto Soprani a fim preencher as Classe Valor para os registros que não foram gravados. Isto irá ajudar a contabilização do CPV.
xcCLVL := ""
If cEmpAnt == "01"
	xcCLVL := "2100"
	
ElseIf cEmpAnt == "05"
	If SF2->F2_SERIE == "1  "
		xcCLVL := "2200"
	ElseIf SF2->F2_SERIE == "2  "
		xcCLVL := "2210"
	EndIf
	
ElseIf cEmpAnt == "07"

	If SF2->F2_SERIE == "1  "
		xcCLVL := "2100"
	ElseIf SF2->F2_SERIE == "2  "
		xcCLVL := "2200"
	ElseIf SF2->F2_SERIE == "3  "
		xcCLVL := "2210"

	//Mundialli
	ElseIf SF2->F2_SERIE == "4  "
		xcCLVL := "1085"

	EndIf
	
EndIf

If Alltrim(cempant) $ "01_05_07_13_14"
	RecLock("SD2",.F.)
	SD2->D2_YPRCTAB		:=	SC6->C6_YPRCTAB 
	SD2->D2_YPERC		:=	SC6->C6_YPERC
	SD2->D2_YVENDRC		:=	SC6->C6_YVENDRC
	SD2->D2_YEMP		:=	SC5->C5_YEMP 		//Grava Empresa
	SD2->D2_YRESULT		:=	SC5->C5_YRESULT		//Grava Resultado
	SD2->D2_YRESUL2		:=	SC5->C5_YRESUL2		//Grava Resultado para empresa INCESA -> LM
	SD2->D2_YVFRTUN		:=	SC6->C6_YVFRTUN			
	SD2->D2_YVSEGUN		:=	SC6->C6_YVSEGUN		
	
	If Empty(SD2->D2_CLVL)
		SD2->D2_CLVL        := xcCLVL
	EndIf	
	SD2->(MsUnLock())
EndIf

// Empresa14 - Tratamento feito para gravação do CodRef do produto acabado resultante de processamento de industrialização na Vitcer. Por Marcos Alberto Soprani - 08/10/13
If Alltrim(cEmpAnt) == "14"
	RecLock("SD2",.F.)
	SD2->D2_YCODREF		:=	SC6->C6_YCODREF
	SD2->(MsUnLock())
EndIf

//Busca Fornecedor para gravar tabela SA5 - Amarracao Produto x Fornecedor (Intragrupo)  
cSql 	:= " SELECT A2_COD, A2_LOJA FROM VW_INTRAGRUPO WHERE CGC = '"+SM0->M0_CGC+"' AND A2_COD <> '' "
cSql 	:= ChangeQuery(cSql)
cIndSA1	:= CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'KR01',.T.,.T.)
dbSelectArea("KR01")	

If !KR01->(EOF())
	U_fGrvPdFr(KR01->A2_COD, KR01->A2_LOJA, SD2->D2_COD, SD2->D2_COD)
EndIf
/*
SF4->(DbSetOrder(1))
SF4->(DbSeek(xFilial("SF4")+SF2->F2_FILIAL))

If SF2->F2_TIPO == 'D' .And. Alltrim(SF4->F4_ESTOQUE) == 'S' .And. _oMd:CheckMD(SD2->D2_COD,SD2->D2_LOCAL)
	_oMd:DevolucaoNF(SD2->D2_NFORI,SD2->D2_SERIORI,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ITEMORI,SD2->D2_DOC,SD2->D2_SERIE,;
	SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_QUANT,cUserName,FunName(),;
    							SD2->D2_EMISSAO,"SD2",SD2->(Recno()))
EndIf
*/
KR01->(dbCloseArea())
Ferase(cIndSA1+GetDBExtension())	//arquivo de trabalho
Ferase(cIndSA1+OrdBagExt())			//indice gerado

RestArea(aArea)

Return