#include "rwMake.ch"
#include "Topconn.ch"

User Function EXAM_PERI()

/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EXAM_PERI      บAutor  ณ BRUNO MADALENO     บ Data ณ  22/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar OS EXAMES PERIODICOS              บฑฑ
ฑฑบ          ณ																																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/

Private cSQL
Private Enter := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa็oes dos exames peri๓dicos"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "EXA_PERI"
cPerg      := ""
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informa็oes sobre ferias vencidas"
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
cSQL += "		'Peri๓dico' AS EXAME, SQB.QB_YEXAMES, CAST(RA_NASC AS SMALLDATETIME) AS RA_NASC " + Enter
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
