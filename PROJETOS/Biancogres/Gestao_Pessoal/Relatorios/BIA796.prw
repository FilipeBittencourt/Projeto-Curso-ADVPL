#include "topconn.ch"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include "tbiconn.ch"

User Function BIA796()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA796
Empresa   := Biancogres Cerâmica S/A
Data      := 03/06/14
Uso       := Gestão de Pessoal
Aplicação := Desoneração da folha
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

fPerg := "BIA296"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

// 1 - desoneração - Provisão de férias - VENCIDAS quando não tira férias no mês - A VENCER
// VENCIDAS quando não tira férias no mês;
// e, A VENCER
WS001 := " UPDATE "+RetSqlName("SRT")
WS001 += "        SET RT_VALOR =
WS001 += "        ISNULL((SELECT SUM(RT_VALOR)
WS001 += "                  FROM "+RetSqlName("SRT")+" SRT
WS001 += "                 WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS001 += "                   AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR01+"'
WS001 += "                   AND RT_MAT = BASESRT.RT_MAT
WS001 += "                   AND RT_VERBA IN('803')
WS001 += "                   AND RT_TIPPROV = BASESRT.RT_TIPPROV
WS001 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) + ROUND((ISNULL((SELECT SUM(RT_VALOR)
WS001 += "                                                                    FROM "+RetSqlName("SRT")+" SRT
WS001 += "                                                                   WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS001 += "                                                                     AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS001 += "                                                                     AND RT_MAT = BASESRT.RT_MAT
WS001 += "                                                                     AND RT_VERBA IN('800','801','802')
WS001 += "                                                                     AND RT_TIPPROV = BASESRT.RT_TIPPROV
WS001 += "                                                                     AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
WS001 += "                                                                                                               FROM "+RetSqlName("SRT")+" SRT
WS001 += "                                                                                                              WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS001 += "                                                                                                                AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR01+"'
WS001 += "                                                                                                                AND RT_MAT = BASESRT.RT_MAT
WS001 += "                                                                                                                AND RT_VERBA IN('800','801','802')
WS001 += "                                                                                                                AND RT_TIPPROV = BASESRT.RT_TIPPROV
WS001 += "                                                                                                                AND SRT.D_E_L_E_T_ = ' '), 0)) * '"+Alltrim(Str(MV_PAR03))+"' / 100, 2)
WS001 += "   FROM "+RetSqlName("SRT")+" BASESRT
WS001 += "  WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS001 += "    AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS001 += "    AND RT_VERBA = '803'
WS001 += "    AND RT_MAT NOT IN(SELECT RT_MAT
WS001 += "                        FROM "+RetSqlName("SRT")
WS001 += "                       WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS001 += "                         AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS001 += "                         AND RT_TIPPROV <> '3'
WS001 += "                         AND RT_DFERVEN = 30
WS001 += "                         AND RT_DFERPRO = 0
WS001 += "                         AND RT_TIPPROV = '1'
WS001 += "                         AND D_E_L_E_T_ = ' ')
WS001 += "    AND BASESRT.D_E_L_E_T_ = ' '
TcSQLExec(WS001)

// 2 - desoneração - Provisão de férias - apenas VENCIDAS quando tira férias no mês
// apenas vencida quando tira férias no mês
WS002 := " UPDATE "+RetSqlName("SRT")
WS002 += "        SET RT_VALOR =
WS002 += "        ROUND(ISNULL((SELECT SUM(RT_VALOR)
WS002 += "                        FROM "+RetSqlName("SRT")+" SRT
WS002 += "                       WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS002 += "                         AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR01+"'
WS002 += "                         AND RT_MAT = BASESRT.RT_MAT
WS002 += "                         AND RT_VERBA IN('803')
WS002 += "                         AND RT_TIPPROV IN('1')
WS002 += "                         AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
WS002 += "                                                                   FROM "+RetSqlName("SRT")+" SRT
WS002 += "                                                                  WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS002 += "                                                                    AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS002 += "                                                                    AND RT_MAT = BASESRT.RT_MAT
WS002 += "                                                                    AND RT_VERBA IN('803')
WS002 += "                                                                    AND RT_TIPPROV IN('1')
WS002 += "                                                                    AND SRT.D_E_L_E_T_ = ' '), 0),2)
WS002 += "   FROM "+RetSqlName("SRT")+" BASESRT
WS002 += "  WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS002 += "    AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS002 += "    AND RT_VERBA = '808'
WS002 += "    AND RT_TIPPROV = '1'
WS002 += "    AND RT_MAT NOT IN(SELECT RT_MAT
WS002 += "                        FROM "+RetSqlName("SRT")
WS002 += "                       WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS002 += "                         AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS002 += "                         AND RT_TIPPROV <> '3'
WS002 += "                         AND RT_DFERVEN = 30
WS002 += "                         AND RT_DFERPRO = 0
WS002 += "                         AND RT_TIPPROV = '1'
WS002 += "                         AND D_E_L_E_T_ = ' ')
WS002 += "    AND BASESRT.D_E_L_E_T_ = ' '
TcSQLExec(WS002)

// 4 - Provisão de férias - VENCIDAS quando vira a data base do funcionário no mês da desoneração
// VENCIDAS quando no tira férias no mês; A VENCER
// (FOI NECESSÁRIO FILTRAR OS FUNCIONÁRIOS QUE TIRARAM VIRAVAM A DATA BASE DE FÉRIAS NESTE MES)
WS004 := " UPDATE "+RetSqlName("SRT")
WS004 += "        SET RT_VALOR =
WS004 += "        ISNULL((SELECT SUM(RT_VALOR)
WS004 += "                  FROM "+RetSqlName("SRT")+" SRT
WS004 += "                 WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS004 += "                   AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR01+"'
WS004 += "                   AND RT_MAT = BASESRT.RT_MAT
WS004 += "                   AND RT_VERBA IN('803')
WS004 += "                   AND RT_TIPPROV = '2'
WS004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) + ROUND((ISNULL((SELECT SUM(RT_VALOR)
WS004 += "                                                                    FROM "+RetSqlName("SRT")+" SRT
WS004 += "                                                                   WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS004 += "                                                                     AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS004 += "                                                                     AND RT_MAT = BASESRT.RT_MAT
WS004 += "                                                                     AND RT_VERBA IN('800','801','802')
WS004 += "                                                                     AND RT_TIPPROV = BASESRT.RT_TIPPROV
WS004 += "                                                                     AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
WS004 += "                                                                                                               FROM "+RetSqlName("SRT")+" SRT
WS004 += "                                                                                                              WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS004 += "                                                                                                                AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR01+"'
WS004 += "                                                                                                                AND RT_MAT = BASESRT.RT_MAT
WS004 += "                                                                                                                AND RT_VERBA IN('800','801','802')
WS004 += "                                                                                                                AND RT_TIPPROV = '2'
WS004 += "                                                                                                                AND SRT.D_E_L_E_T_ = ' '), 0)) * '"+Alltrim(Str(MV_PAR03))+"' / 100, 2)
WS004 += "   FROM "+RetSqlName("SRT")+" BASESRT
WS004 += "  WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS004 += "    AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS004 += "    AND RT_TIPPROV <> '3'
WS004 += "    AND RT_TIPPROV = '1'
WS004 += "    AND RT_VERBA = '803'
WS004 += "    AND RT_MAT IN(SELECT RT_MAT
WS004 += "                    FROM "+RetSqlName("SRT")
WS004 += "                   WHERE RT_FILIAL = '"+xFilial("SRT")+"'
WS004 += "                     AND SUBSTRING(RT_DATACAL,1,6) = '"+MV_PAR02+"'
WS004 += "                     AND RT_TIPPROV <> '3'
WS004 += "                     AND RT_DFERVEN = 30
WS004 += "                     AND RT_DFERPRO = 0
WS004 += "                     AND RT_TIPPROV = '1'
WS004 += "                     AND D_E_L_E_T_ = ' ')
WS004 += "    AND D_E_L_E_T_ = ' '
TcSQLExec(WS004)

Aviso('BIA796','Complementação da Desoneração - Fim do Processamento',{'Ok'},3)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Ano Mes Anterior     ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ano Mes Atual        ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Percentual           ?","","","mv_ch3","N",10,4,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
