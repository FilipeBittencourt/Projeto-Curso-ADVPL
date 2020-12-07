#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

User Function BIA552()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA552
Empresa   := Biancogres Ceramica S.A.
Data      := 25/06/15
Uso       := Contabilidade
Aplicação := Consolidação Geral - Contabilidade Gerencial - Z48
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

If !cEmpAnt $ "90/91"
	Aviso('Aviso de Integração', 'Esta Rotina não pode ser executada dentro das Entidades. Apenas dentro da Consolidada (90) e da Unidade de Negócio (91)!', {'Ok'})
	Return
EndIf

cHInicio := Time()
fPerg := "BIA552"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

wPeriod := MV_PAR01
wPerDe  := MV_PAR01+"01"
wPerAte := dtos(UltimoDia(stod(wPerDe)))

QL002 := " INSERT INTO Z48"+cEmpAnt+"0
QL002 += " (Z48_FILIAL,
QL002 += "  Z48_DATA  ,
QL002 += "  Z48_LOTE  ,
QL002 += "  Z48_SBLOTE,
QL002 += "  Z48_DOC   ,
QL002 += "  Z48_LINHA ,
QL002 += "  Z48_DC    ,
QL002 += "  Z48_DEBITO,
QL002 += "  Z48_CREDIT,
QL002 += "  Z48_VALOR ,
QL002 += "  Z48_CLVLDB,
QL002 += "  Z48_CLVLCR,
QL002 += "  Z48_ITEMD ,
QL002 += "  Z48_ITEMC ,
QL002 += "  Z48_CCD   ,
QL002 += "  Z48_CCC   ,
QL002 += "  Z48_HIST  ,
QL002 += "  Z48_ORIGEM,
QL002 += "  Z48_TPSALD,
QL002 += "  Z48_MOEDLC,
QL002 += "  Z48_EMPORI,
QL002 += "  Z48_FILORI,
QL002 += "  Z48_ROTINA,
QL002 += "  Z48_SEQLAN,
QL002 += "  Z48_SI    ,
QL002 += "  Z48_UN    ,
QL002 += "  D_E_L_E_T_,
QL002 += "  R_E_C_N_O_,
QL002 += "  Z48_YDELTA)
QL002 += " SELECT '"+cFilAnt+"' Z48_FILIAL,
QL002 += "        Z48_DATA  ,
QL002 += "        Z48_LOTE  ,
QL002 += "        Z48_SBLOTE,
QL002 += "        Z48_DOC   ,
QL002 += "        Z48_LINHA ,
QL002 += "        Z48_DC    ,
QL002 += "        Z48_DEBITO,
QL002 += "        Z48_CREDIT,
QL002 += "        Z48_VALOR ,
QL002 += "        Z48_CLVLDB,
QL002 += "        Z48_CLVLCR,
QL002 += "        Z48_ITEMD ,
QL002 += "        Z48_ITEMC ,
QL002 += "        Z48_CCD   ,
QL002 += "        Z48_CCC   ,
QL002 += "        Z48_HIST  ,
QL002 += "        Z48_ORIGEM,
QL002 += "        Z48_TPSALD,
QL002 += "        Z48_MOEDLC,
QL002 += "        Z48_EMPORI,
QL002 += "        Z48_FILORI,
QL002 += "        Z48_ROTINA,
QL002 += "        Z48_SEQLAN,
QL002 += "        Z48_SI    ,
QL002 += "        Z48_UN    ,
QL002 += "        D_E_L_E_T_,
QL002 += "        (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM Z48"+cEmpAnt+"0) + ROW_NUMBER() OVER(ORDER BY Z48.R_E_C_N_O_) AS R_E_C_N_O_,
QL002 += "        Convert(Char(10),convert(datetime, SYSDATETIME()),112) Z48_YDELTA
QL002 += "   FROM Z48"+cFilAnt+"0 Z48
QL002 += "  WHERE D_E_L_E_T_ = ' '
QL002 += "    AND Z48_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
//QL002 += "    AND ( Z48_DEBITO IN('41399001','41399002','41399003') OR Z48_CREDIT IN('41399001','41399002','41399003') )

U_BIAMsgRun("Aguarde... Consolidando Base... ",,{|| TcSQLExec(QL002)})

MsgINFO("Fim do Processamento...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
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
aAdd(aRegs,{cPerg,"01","Período de referência  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
