#include "rwMake.ch"
#include "Topconn.ch"

User Function EXAM_PERI()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � EXAM_PERI      篈utor  � BRUNO MADALENO     � Data �  22/09/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砇elatorio em Crystal para gerar OS EXAMES PERIODICOS              罕�
北�          �																																	罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP 7                                                             罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Private cSQL
Private Enter := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa鏾es dos exames peri骴icos"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "EXA_PERI"
cPerg      := ""
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informa鏾es sobre ferias vencidas"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "EXA_PERI"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.

wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
If nLastKey == 27
	Return
Endif

cSQL := ""
cSQL += "ALTER VIEW VW_EXAMES_PERIO AS " + Enter
cSQL += "SELECT RA_MAT, RA_CC , RA_NOME, CAST(RA_ADMISSA AS SMALLDATETIME) AS RA_ADMISSA, RJ_DESC, " + Enter
//Alterado por Wanisay no dia 13/05/11 de acordo com e-mail enviado pela Claudia
//cSQL += "		DATEADD(YEAR, 1, DATA) AS PROXIMO, SQB.QB_YPCMSO QB_DESCRIC,  " + Enter
cSQL += "		DATA AS PROXIMO, SQB.QB_YPCMSO QB_DESCRIC,  " + Enter
cSQL += "		'Peri骴ico' AS EXAME, SQB.QB_YEXAMES, CAST(RA_NASC AS SMALLDATETIME) AS RA_NASC " + Enter
cSQL += "FROM	"+RETSQLNAME("SRA")+" SRA, "+RETSQLNAME("SQB")+" SQB, "+RETSQLNAME("SRJ")+" SRJ, " + Enter
//Alterado por Wanisay no dia 13/05/11 de acordo com e-mail enviado pela Claudia
//cSQL += "		(SELECT RC8_MAT, MAX(RC8_DATA) AS DATA FROM "+RETSQLNAME("RC8")+" WHERE D_E_L_E_T_ = '' AND RC8_EXTIPO <> '6' GROUP BY RC8_MAT) RC8 " + Enter
cSQL += "		(SELECT RC8_MAT, MAX(RC8_YDATA) AS DATA FROM "+RETSQLNAME("RC8")+" WHERE D_E_L_E_T_ = '' GROUP BY RC8_MAT) RC8 " + Enter
cSQL += "WHERE	SRA.RA_DEPTO = SQB.QB_DEPTO AND " + Enter
cSQL += "		SRA.RA_CODFUNC = RJ_FUNCAO AND  " + Enter
cSQL += "		SRA.RA_MAT = RC8.RC8_MAT AND " + Enter
cSQL += "		SRA.RA_DEMISSA = '' AND  " + Enter
cSQL += "		SRA.D_E_L_E_T_ = '' AND " + Enter
cSQL += "		SQB.D_E_L_E_T_ = '' AND " + Enter
cSQL += "		SRJ.D_E_L_E_T_ = '' " + Enter
TcSQLExec(cSQL)

If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Apuracao"
Endif

//AtivaRel()
callcrys("EXA_PERIODICOS",cEmpant,cOpcao)

Return
