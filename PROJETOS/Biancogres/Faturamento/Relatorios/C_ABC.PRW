#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ C_ABD          บAutor  ณ HARLEY DIAS KOEHLERบ Data ณ  03/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RELATORIO DE CURVA ABC POR PRODUTO                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function C_ABC()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LOcal _j, _i
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Curva ABC por Produto"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "C_ABC"
	cPerg      := "C_ABC"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Relatorio Curva ABC por Produto"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "C_ABC"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t. 


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria parametros se nao existir e chama os parametros na tela           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ValidPerg()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT.								     ณ
	//ณ Verifica Posicao do Formulario na Impressora.				             ณ
	//ณ Solicita os parametros para a emissao do relatorio			             |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	cSQL := ""
	cSQL += "DROP TABLE CURVAABC  " + Enter
	cSQL += "CREATE TABLE [dbo].[CURVAABC]( " 	    + Enter
	cSQL += "[ABC] [int] IDENTITY (1, 1) NOT NULL," + Enter
	cSQL += "PRODUTO VARCHAR(40), " + Enter
	cSQL += "UM VARCHAR(2), " + Enter
	cSQL += "FORMATO VARCHAR(5)," + Enter 
	cSQL += "ATUAL FLOAT, " + Enter
	cSQL += "ANTER FLOAT, " + Enter
	cSQL += "DTINI VARCHAR(8)," + Enter
	cSQL += "DTFIM VARCHAR(8)," + Enter
	cSQL += "FORNE VARCHAR(5))" + Enter
	cSQL += "INSERT INTO CURVAABC (PRODUTO, UM , FORMATO , ATUAL, ANTER, DTINI, DTFIM, FORNE) " + Enter
	cSQL += "SELECT ((SUBSTRING(B1_YREF,8,LEN((SUBSTRING(B1_YREF,8,100)))-1))) PRODUTO, SB1.B1_UM, SUBSTRING(SD2.FORMATO,1,5)AS FORMATO ," + Enter
	cSQL += "        SUM(SD2.ATUAL)AS ATUAL, SUM(SD2.ANTER) AS ANTER, ZT_DTINCIO,ZT_FORALIN,ZT_COD" + Enter
	cSQL += "FROM" + Enter
	cSQL += "	(SELECT D2_COD, D2_TES, D2_TP," + Enter
	cSQL += "		(SELECT X5_DESCRI FROM "+RetSqlName("SX5")+ " SX5 "  + Enter
	cSQL += "		 WHERE 	X5_TABELA = 'U1' AND " + Enter
	cSQL += "			X5_CHAVE = SUBSTRING(D2_COD,1,1)+SUBSTRING(D2_COD,6,1)  AND" + Enter
	cSQL += "			D_E_L_E_T_ = '') AS FORMATO, " + Enter
	cSQL += "		ATUAL = CASE WHEN D2_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' THEN D2_QUANT ELSE 0 END,  " + Enter
	cSQL += "		ANTER = CASE WHEN D2_EMISSAO BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' THEN D2_QUANT ELSE 0 END" + Enter
	cSQL += "	FROM "+RetSQLName("SD2") + " SD2," + RetSQLName("SF4") + " SF4 " + Enter
	cSQL += "	WHERE 	D2_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' AND" + Enter
	cSQL += "		SF4.F4_CODIGO = SD2.D2_TES  AND" + Enter                        
	cSQL += "		F4_DUPLIC='S' AND" + Enter
	cSQL += "		SD2.D_E_L_E_T_ = '' AND" + Enter
	cSQL += "		D2_GRUPO='PA' AND" + Enter
	cSQL += "		SF4.D_E_L_E_T_ = '') AS SD2," + Enter
	cSQL += "	"+RetSQLName("SB1")+ " SB1, " + RetSQLName("SZT")+ " SZT " + Enter
	cSQL += "WHERE 	SB1.B1_COD = SD2.D2_COD AND" + Enter
	cSQL += "	SB1.D_E_L_E_T_ = ''" + Enter
	cSQL += "	AND SZT.ZT_PROJETO=SUBSTRING(D2_COD,1,5)" + Enter
	cSQL += " GROUP BY ((SUBSTRING(B1_YREF,8,LEN((SUBSTRING(B1_YREF,8,100)))-1))), SB1.B1_UM, SUBSTRING(SD2.FORMATO,1,5), ZT_DTINCIO,ZT_FORALIN, ZT_COD" + Enter
	cSQL += " ORDER BY  ANTER DESC"

	//DbSeek(xFilial("SF2")+mv_par07+Dtos(mv_par03),.T.)
	////////
	TcSQLExec(cSQL)                    	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif
	//AtivaRel()
	callcrys("curvaabc",cempant,cOpcao)
	Return

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return