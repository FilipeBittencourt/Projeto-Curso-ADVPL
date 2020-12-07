#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Rel_Bala       บAutor  ณ BRUNO MADALENO     บ Data ณ  08/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar informacoes da BALANCA            บฑฑ
ฑฑบ          ณ																 																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Rel_Bala()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSQL
Private Enter := CHR(13)+CHR(10) 
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa็oes do BALANวA"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BALAN"
cPerg      := "BALAN"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informa็oes da Balan็a"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "BALAN"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t. 
      
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

CCSERIE		:= MV_PAR01
cSQL := "ALTER VIEW VW_RELBALANCA AS  " + Enter
cSQL += "SELECT	 Z11_PALADC, Z11.Z11_OBSER, CONVERT(VARCHAR,CONVERT(DATETIME,Z11.Z11_DATAIN),103) AS Z11_DATAIN, Z11.Z11_PCAVAL, SUM(Z11.Z11_PESLIQ) AS Z11_PESLIQ, ISNULL(F2_YPALLET,0) AS F2_YPALLET,   (ISNULL(F2_YPALLET + Z11_PALADC,0) * "+ALLTRIM(STR(GETMV("MV_YPESOPL")))+") as PESOPALLET,   " + Enter
cSQL += "		ISNULL(F2_PBRUTO,0) AS F2_PBRUTO,   " + Enter
cSQL += "		(SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) )) DIFERENCA,    " + Enter
cSQL += "		((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) DIFE_PERCE     " + Enter
cSQL += "		,ASTATUS = CASE WHEN ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 )  <= "+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" AND ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) >= -"+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" THEN 'LIBERADO'    " + Enter
cSQL += "						ELSE 'CONFERIR CAMINHรO' END   " + Enter
cSQL += "FROM "+RETSQLNAME("Z11")+" Z11 ,  " + Enter
If cempant == "05"
	cSQL += "			(SELECT F2_YSEQB, F2_YPLACA, F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET FROM  " + Enter
	cSQL += "				( SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET	" + Enter
	cSQL += "				FROM SF2050 SF2, SD2050  SD2, SF4050 SF4	" + Enter
	cSQL += "				WHERE	SF2.F2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SD2.D2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF4.F4_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF2.F2_DOC		= D2_DOC		AND " + Enter
	cSQL += "						SF2.F2_SERIE	= D2_SERIE		AND " + Enter
	cSQL += "						SF2.F2_CLIENTE	= D2_CLIENTE	AND " + Enter
	cSQL += "						SF2.F2_LOJA		= D2_LOJA		AND " + Enter
	cSQL += "						SD2.D2_TES		= F4_CODIGO		AND " + Enter
	cSQL += "						SF2.F2_SERIE IN('1','S1') AND  " + Enter
	cSQL += "						SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'  AND " + Enter
	cSQL += "						SF4.F4_ESTOQUE = 'S' AND " + Enter
	cSQL += "						SF2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SD2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SF4.D_E_L_E_T_ = ''   " + Enter
	cSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES							" + Enter
	cSQL += "				UNION 					  " + Enter
	cSQL += "				SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET	" + Enter
	cSQL += "				FROM SF2010 SF2, SD2010  SD2, SF4010 SF4	" + Enter
	cSQL += "				WHERE	SF2.F2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SD2.D2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF4.F4_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF2.F2_DOC		= D2_DOC		AND " + Enter
	cSQL += "						SF2.F2_SERIE	= D2_SERIE		AND " + Enter
	cSQL += "						SF2.F2_CLIENTE	= D2_CLIENTE	AND " + Enter
	cSQL += "						SF2.F2_LOJA		= D2_LOJA		AND " + Enter
	cSQL += "						SD2.D2_TES		= F4_CODIGO		AND " + Enter
	cSQL += "						SF2.F2_SERIE IN('2','S2') AND  " + Enter
	cSQL += "						SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'  AND " + Enter
	cSQL += "						SF4.F4_ESTOQUE = 'S' AND " + Enter
	cSQL += "						SF2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SD2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SF4.D_E_L_E_T_ = ''   " + Enter
	cSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES	" + Enter
	cSQL += "				UNION  " + Enter
	cSQL += "				SELECT F2_YSEQB, F2_YPLACAB, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET	" + Enter
	cSQL += "				FROM SF2050 SF2, SD2050  SD2, SF4050 SF4	" + Enter
	cSQL += "				WHERE	SF2.F2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SD2.D2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF4.F4_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF2.F2_DOC		= D2_DOC		AND " + Enter
	cSQL += "						SF2.F2_SERIE	= D2_SERIE		AND " + Enter
	cSQL += "						SF2.F2_CLIENTE	= D2_CLIENTE	AND " + Enter
	cSQL += "						SF2.F2_LOJA		= D2_LOJA		AND " + Enter
	cSQL += "						SD2.D2_TES		= F4_CODIGO		AND " + Enter
	cSQL += "						SF2.F2_SERIE IN('1','S1') AND  " + Enter
	cSQL += "						SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'  AND " + Enter
	cSQL += "						SF4.F4_ESTOQUE = 'S' AND " + Enter 
	cSQL += "						SF2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SD2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SF4.D_E_L_E_T_ = ''   " + Enter
	cSQL += "				GROUP BY F2_YSEQB, F2_YPLACAB, F2_YDES							" + Enter
	cSQL += "				UNION 					  " + Enter
	cSQL += "				SELECT F2_YSEQB, F2_YPLACAB, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET	" + Enter
	cSQL += "				FROM SF2010 SF2, SD2010  SD2, SF4010 SF4	" + Enter
	cSQL += "				WHERE	SF2.F2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SD2.D2_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF4.F4_FILIAL = '01' AND 	" + Enter
	cSQL += "						SF2.F2_DOC		= D2_DOC		AND " + Enter
	cSQL += "						SF2.F2_SERIE	= D2_SERIE		AND " + Enter
	cSQL += "						SF2.F2_CLIENTE	= D2_CLIENTE	AND " + Enter
	cSQL += "						SF2.F2_LOJA		= D2_LOJA		AND " + Enter
	cSQL += "						SD2.D2_TES		= F4_CODIGO		AND " + Enter
	cSQL += "						SF2.F2_SERIE IN('2','S2') AND  " + Enter
	cSQL += "						SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'  AND " + Enter
	cSQL += "						SF4.F4_ESTOQUE = 'S' AND " + Enter
	cSQL += "						SF2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SD2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "						SF4.D_E_L_E_T_ = ''   " + Enter
	cSQL += "				GROUP BY F2_YSEQB, F2_YPLACAB, F2_YDES ) AS SF2  " + Enter
	cSQL += "		GROUP BY F2_YSEQB, F2_YPLACA, F2_EMISSAO) AS SF2 " + Enter

ELSE

	cSQL += "		(SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET	" + Enter
	cSQL += "		FROM SF2010 SF2, SD2010  SD2, SF4010 SF4	" + Enter
	cSQL += "		WHERE	SF2.F2_FILIAL = '01' AND 	" + Enter
	cSQL += "				SD2.D2_FILIAL = '01' AND 	" + Enter
	cSQL += "				SF4.F4_FILIAL = '01' AND 	" + Enter
	cSQL += "				SF2.F2_DOC		= D2_DOC		AND " + Enter
	cSQL += "				SF2.F2_SERIE	= D2_SERIE		AND " + Enter
	cSQL += "				SF2.F2_CLIENTE	= D2_CLIENTE	AND " + Enter
	cSQL += "				SF2.F2_LOJA		= D2_LOJA		AND " + Enter
	cSQL += "				SD2.D2_TES		= F4_CODIGO		AND " + Enter
	cSQL += "				SF2.F2_SERIE IN('1','S1') AND  " + Enter
	cSQL += "				SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'  AND " + Enter
	cSQL += "				SF4.F4_ESTOQUE = 'S' AND " + Enter
	cSQL += "				SF2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "				SD2.D_E_L_E_T_ = '' AND " + Enter
	cSQL += "				SF4.D_E_L_E_T_ = ''   " + Enter
	cSQL += "		GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES) AS SF2 " + Enter

END IF
cSQL += "WHERE	Z11.Z11_FILIAL = '  ' AND " + Enter
cSQL += "		SF2.F2_YPLACA = Z11.Z11_PCAVAL AND   " + Enter
cSQL += "		SF2.F2_EMISSAO = Z11.Z11_DATASA AND   " + Enter
cSQL += "		Z11.Z11_PESLIQ <> '' AND   " + Enter
cSQL += "		Z11.D_E_L_E_T_ = ''    " + Enter
cSQL += "		AND Z11.Z11_DATASA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " + Enter
cSQL += "		--AND Z11.Z11_PCAVAL = 'JJQ0006'  " + Enter
cSQL += "		AND Z11.Z11_SEQB = '1'  " + Enter
cSQL += "		AND F2_YSEQB = Z11.Z11_SEQB AND Z11_MERCAD = '2'  " + Enter
cSQL += "GROUP BY Z11_PALADC, Z11.Z11_OBSER, Z11.Z11_DATAIN, Z11.Z11_PCAVAL, F2_PBRUTO, F2_YPALLET " + Enter
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
callcrys("RELBALA",cEmpant,cOpcao)
Return