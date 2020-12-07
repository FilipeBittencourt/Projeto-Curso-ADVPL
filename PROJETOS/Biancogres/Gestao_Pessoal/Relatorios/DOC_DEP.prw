#include "rwMake.ch"
#include "Topconn.ch"

User Function DOC_DEP()

/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DOC_DEP        บAutor  ณ BRUNO MADALENO     บ Data ณ  02/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIO DE DOCUMENTACAO DE SALARIO FAMILA                       บฑฑ
ฑฑบ          ณ																	                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisado  ณ	Marcos Alberto Soprani - 18/05/12                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 8 - R4                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/

Private cSQL
Private Enter := CHR(13)+CHR(10)
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa็oes do SALARIO FAMILIA"
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "DOC_DEP"
cPerg      := ""
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Salแrio Famํlia"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "DOC_DEP"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.

fPerg := "DOC_DEP"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
If nLastKey == 27
	Return
Endif

/*
cSQL := " ALTER VIEW VW_DOCUMENTOS_DEPENDENTES
cSQL += " AS
cSQL += "   SELECT RA_MAT,
cSQL += "          RA_NOME,
cSQL += "          RA_CC,
cSQL += "          Convert(Char(10),convert(datetime, RA_ADMISSA),103) RA_ADMISSA,
cSQL += "          RA_SALARIO,
cSQL += "          RA_PERICUL,
cSQL += "          RA_INSMED,
cSQL += "          RA_INSMAX,
cSQL += "          RB_NOME,
cSQL += "          RB_DTNASC,
cSQL += "          DATEDIFF(YEAR, RB_DTNASC, GETDATE()) AS IDADE,
cSQL += "          RX_TXT,
cSQL += "          TESTE = CASE
cSQL += "                    WHEN DATEDIFF(YEAR, RB_DTNASC, GETDATE()) <= 7 THEN 'VACINAวรO'
cSQL += "                    ELSE 'DECLARAวรO ESCOLAR'
cSQL += "                  END
cSQL += "     FROM "+RetSqlName("SRA")+" SRA,
cSQL += "          "+RetSqlName("SRB")+" SRB,
cSQL += "          "+RetSqlName("SRX")+" SRX
cSQL += "    WHERE RA_DEMISSA = '        '
cSQL += "      AND RB_MAT = RA_MAT
cSQL += "      AND RX_TIP = '11'
cSQL += "      AND RX_COD = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 112), 1, 6)
cSQL += "      AND DATEDIFF(YEAR, RB_DTNASC, GETDATE()) <= 14
cSQL += "      AND RA_SALARIO <= " + Alltrim(Str(MV_PAR02))
cSQL += "      AND SRA.D_E_L_E_T_ = ''
cSQL += "      AND SRB.D_E_L_E_T_ = ''
cSQL += "      AND SRX.D_E_L_E_T_ = ''
*/
cSql := " ALTER VIEW VW_DOCUMENTOS_DEPENDENTES
cSql += " AS
cSql += "   SELECT RA_MAT,
cSql += "          RA_NOME,
cSql += "          RA_CC,
cSql += "          RA_ADMISSA,
cSql += "          RA_SALARIO RA_SALARIO,
cSql += "          RA_PERICUL,
cSql += "          RA_INSMED,
cSql += "          RA_INSMAX,
cSql += "          RB_NOME,
cSql += "          RB_DTNASC,
cSql += "          IDADE,
cSql += "          RX_TXT,
cSql += "          TESTE
cSql += "     FROM (SELECT RA_MAT,
cSql += "                  RA_NOME,
cSql += "                  RA_CC,
cSql += "                  CONVERT(CHAR(10), CONVERT(DATETIME, RA_ADMISSA), 103) RA_ADMISSA,
cSql += "                  RA_SALARIO,
cSql += "                  RA_PERICUL,
cSql += "                  RA_INSMED,
cSql += "                  RA_INSMAX,
cSql += "                  RB_NOME,
cSql += "                  RB_DTNASC,
cSql += "                  DATEDIFF(YEAR, RB_DTNASC, GETDATE()) IDADE,
cSql += "                  RX_TXT,
cSql += "                  CASE
cSql += "                    WHEN DATEDIFF(YEAR, RB_DTNASC, GETDATE()) <= 7 THEN 'VACINAวรO'
cSql += "                    ELSE 'DECLARAวรO ESCOLAR'
cSql += "                  END TESTE,
cSql += "                  CASE
cSql += "                    WHEN RA_INSMED = 0 THEN
cSql += "                      CASE
cSql += "                        WHEN RA_INSMAX = 0 THEN 0
cSql += "                        ELSE CONVERT(NUMERIC, RTRIM(LTRIM(RX_TXT))) / 100 * 40
cSql += "                      END
cSql += "                    ELSE CONVERT(NUMERIC, RTRIM(LTRIM(RX_TXT))) / 100 * 20
cSql += "                  END INSALUB,
cSql += "                  CASE
cSql += "                    WHEN RA_PERICUL = 0 THEN 0
cSql += "                    ELSE RA_SALARIO / 100 * 30
cSql += "                  END PERICUL
cSql += "             FROM "+RetSqlName("SRA")+" SRA,
cSql += "                  "+RetSqlName("SRB")+" SRB,
cSql += "                  "+RetSqlName("SRX")+" SRX
cSql += "            WHERE RA_DEMISSA = '        '
cSql += "              AND RB_MAT = RA_MAT
cSql += "              AND RX_TIP = '11'
cSql += "              AND RX_COD = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 112), 1, 6)
cSql += "              AND DATEDIFF(YEAR, RB_DTNASC, GETDATE()) <= 14
cSql += "              AND SRA.D_E_L_E_T_ = ' '
cSql += "              AND SRB.D_E_L_E_T_ = ' '
cSql += "              AND SRX.D_E_L_E_T_ = ' ') FAMILIA
cSql += "     WHERE RA_SALARIO + INSALUB + PERICUL <= " + Alltrim(Str(MV_PAR02))
TcSQLExec(cSQL)

If aReturn[5]==1
	Private cOpcao:="1;0;1;Apuracao"
Else
	Private cOpcao:="3;0;1;Apuracao"
Endif
CallCrys("DOC_DEP",cEmpant,cOpcao)

Return

/*___________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFun็เo    ฆ ValidPergฆ Autor ฆ Marcos Alberto S      ฆ Data ฆ 05/07/11 ฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Empresa              ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Salแrio Famํlia      ?","","","mv_ch2","N",10,2,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
