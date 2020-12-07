#include "rwMake.ch"
#include "Topconn.ch"

User Function BIA403()

/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BIA403         บAutor  ณWANISAY WILLIAM     บ Data ณ  30/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal para gerar relacao de notas fiscais c/irrf   บฑฑ
ฑฑบ          ณOBS: FUNCAO UTLIZADA PARA GERAR A  VIEW DO RELATORIO              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
Private cSQL

fPerg := "BIA403"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()

lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Notas Fiscais com IRRF"
cTitulo    := "Relacao de Notas Fiscais com IRRF."
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BIA403"
cPerg      := "BIA403"
aLinha     := {}
nLastKey   := 0
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "BIA403"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

If nLastKey == 27
	Return
Endif

dDataIni := MV_PAR01
dDataFim := MV_PAR02
cTitulo := "Relacao de Notas Fiscais com IRRF."

//*************************************************************************
//View para trazer as informacoes do processo e os produtos que o pertence
//*************************************************************************
cSQL := "ALTER VIEW VW_BIA403 AS "
//cSQL += "SELECT "
//cSQL += "    SF1.F1_DOC AS F1_DOC, SA2.A2_NATUREZ AS A2_NATUREZ, "
//cSQL += "    SUBSTRING(SF1.F1_DTDIGIT,7,2)+'/'+SUBSTRING(SF1.F1_DTDIGIT,5,2)+'/'+SUBSTRING(SF1.F1_DTDIGIT,3,2) AS F1_DTDIGIT, "
//cSQL += "    SUBSTRING(SF1.F1_EMISSAO,7,2)+'/'+SUBSTRING(SF1.F1_EMISSAO,5,2)+'/'+SUBSTRING(SF1.F1_EMISSAO,3,2) AS F1_EMISSAO, "
//cSQL += "    SUBSTRING(SA2.A2_CGC,1,2)+'.'+SUBSTRING(SA2.A2_CGC,3,3)+'.'+SUBSTRING(SA2.A2_CGC,6,3)+'/'+SUBSTRING(SA2.A2_CGC,9,4)+'-'+SUBSTRING(SA2.A2_CGC,13,2) AS A2_CGC, "
//cSQL += "    SA2.A2_NOME AS A2_NOME, SF1.F1_VALBRUT AS F1_VALBRUT, SF1.F1_BASEIR AS F1_BASEIR, SF1.F1_IRRF AS F1_IRRF, SF1.F1_VALCSLL AS F1_VALCSLL, "
//cSQL += "    SF1.F1_VALCOFI AS F1_VALCOFI, SF1.F1_VALPIS AS F1_VALPIS "
//cSQL += "FROM "
//cSQL += RetSqlName("SF1") + " SF1, "
//cSQL += RetSqlName("SA2") + " SA2 "
//cSQL += "WHERE "
//cSQL += "	SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
//cSQL += "	SF1.F1_DTDIGIT BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' AND "
//cSQL += "	SA2.A2_NATUREZ BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
//cSQL += "	SA2.A2_NATUREZ <> '" + MV_PAR05 + "' AND "
//cSQL += "	SF1.F1_FORNECE = SA2.A2_COD AND "
//cSQL += "	SF1.F1_IRRF <> 0    AND "
//cSQL += "	SF1.D_E_L_E_T_ = '' AND "
//cSQL += "	SA2.D_E_L_E_T_ = '' "
//cSQL += "UNION ALL "
/*
cSQL += "SELECT "
cSQL += "    SE2.E2_NUM AS F1_DOC, SE2.E2_NATUREZ AS A2_NATUREZ, "
cSQL += "    SUBSTRING(SE2.E2_EMIS1,7,2)+'/'+SUBSTRING(SE2.E2_EMIS1,5,2)+'/'+SUBSTRING(SE2.E2_EMIS1,3,2) AS F1_DTDIGIT, "
cSQL += "    SUBSTRING(SE2.E2_EMISSAO,7,2)+'/'+SUBSTRING(SE2.E2_EMISSAO,5,2)+'/'+SUBSTRING(SE2.E2_EMISSAO,3,2) AS F1_EMISSAO, "
cSQL += "    SUBSTRING(SA2.A2_CGC,1,2)+'.'+SUBSTRING(SA2.A2_CGC,3,3)+'.'+SUBSTRING(SA2.A2_CGC,6,3)+'/'+SUBSTRING(SA2.A2_CGC,9,4)+'-'+SUBSTRING(SA2.A2_CGC,13,2) AS A2_CGC, "
cSQL += "    SA2.A2_NOME AS A2_NOME, SF1.F1_VALBRUT AS F1_VALBRUT, (SE2.E2_VALOR+SE2.E2_VRETIRF+SE2.E2_VRETPIS+SE2.E2_VRETCOF+SE2.E2_VRETCSL+SE2.E2_ISS+SE2.E2_VRETINS) AS F1_BASEIR, "
cSQL += "    SE2.E2_IRRF AS F1_IRRF, SE2.E2_CSLL AS F1_VALCSLL, SE2.E2_COFINS AS VALCOFI, SE2.E2_PIS AS VALPIS, SE2.E2_CODRET CODRET, SE2.E2_DIRF DIRF, E2_EMIS1 "
cSQL += "FROM "
cSQL += RetSqlName("SE2") + " SE2, "
cSQL += RetSqlName("SF1") + " SF1, "
cSQL += RetSqlName("SA2") + " SA2 "
cSQL += "WHERE "
cSQL += "	SE2.E2_FILIAL  = '" + xFilial("SE2") + "' AND "
cSQL += "	SE2.E2_EMIS1 BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' AND "
cSQL += "	SA2.A2_NATUREZ BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
//cSQL += "	SA2.A2_NATUREZ <> '" + MV_PAR05 + "' AND "
cSQL += "	SE2.E2_FORNECE = SA2.A2_COD AND "

If !Empty(MV_PAR05)
df_FilNat := U_BIAGetLike(Alltrim(MV_PAR05))
cSQL += "	SA2.A2_NATUREZ NOT IN("+df_FilNat+") AND "
EndIf

cSQL += "	SF1.F1_FORNECE = SA2.A2_COD AND "
cSQL += "	SF1.F1_DOC     = SE2.E2_NUM AND "
cSQL += "	SF1.F1_SERIE   = SE2.E2_PREFIXO AND "
cSQL += "	SF1.F1_DTDIGIT BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' AND "

cSQL += "	SE2.E2_IRRF <> 0    AND "
cSQL += "	SE2.D_E_L_E_T_ = '' AND "
cSQL += "	SF1.D_E_L_E_T_ = '' AND "
cSQL += "	SA2.D_E_L_E_T_ = '' "
//cSQL += "	ORDER BY E2_EMIS1
*/

cSql += " SELECT SE2.E2_NUM AS F1_DOC,
cSql += "        SE2.E2_NATUREZ AS A2_NATUREZ,
cSql += "        SUBSTRING(SE2.E2_EMIS1, 7, 2) + '/' + SUBSTRING(SE2.E2_EMIS1, 5, 2) + '/' + SUBSTRING(SE2.E2_EMIS1, 3, 2) AS F1_DTDIGIT,
cSql += "        SUBSTRING(SE2.E2_EMISSAO, 7, 2) + '/' + SUBSTRING(SE2.E2_EMISSAO, 5, 2) + '/' + SUBSTRING(SE2.E2_EMISSAO, 3, 2) AS F1_EMISSAO,
cSql += "        SUBSTRING(SA2.A2_CGC, 1, 2) + '.' + SUBSTRING(SA2.A2_CGC, 3, 3) + '.' + SUBSTRING(SA2.A2_CGC, 6, 3) + '/' + SUBSTRING(SA2.A2_CGC, 9, 4) + '-' + SUBSTRING(SA2.A2_CGC, 13, 2) AS A2_CGC,
cSql += "        SA2.A2_NOME AS A2_NOME,
cSql += "        F1_VALBRUT AS F1_VALBRUT,
cSql += "        ( SE2.E2_VALOR + SE2.E2_VRETIRF + SE2.E2_VRETPIS + SE2.E2_VRETCOF + SE2.E2_VRETCSL + SE2.E2_ISS + SE2.E2_VRETINS )  AS F1_BASEIR,
cSql += "        SE2.E2_IRRF AS F1_IRRF,
cSql += "        SE2.E2_CSLL AS F1_VALCSLL,
cSql += "        SE2.E2_COFINS AS VALCOFI,
cSql += "        SE2.E2_PIS AS VALPIS,
cSql += "        SE2.E2_CODRET CODRET,
cSql += "        (SELECT XE2.E2_DIRF
cSql += "           FROM "+RetSqlName("SE2")+" XE2
cSql += "          WHERE XE2.E2_FILIAL = '"+xFilial("SE2")+"'
cSql += "            AND XE2.E2_PREFIXO = SE2.E2_PREFIXO
cSql += "            AND XE2.E2_NUM = SE2.E2_NUM
cSql += "            AND XE2.E2_TITPAI = SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cSql += "            AND XE2.E2_VALOR = SE2.E2_IRRF
cSql += "            AND XE2.E2_TIPO = 'TX '
//cSql += "            AND XE2.E2_NATUREZ <> 'CSLL      '
cSql += "			 AND RTRIM(XE2.E2_NATUREZ)	NOT IN ('CSLL','PIS','COFINS')
cSql += "            AND XE2.D_E_L_E_T_ = ' ') DIRF,
cSql += "        E2_EMIS1
cSql += "   FROM "+RetSqlName("SE2")+" SE2
cSql += "  INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"'
cSql += "                       AND A2_COD = E2_FORNECE
cSql += "                       AND A2_LOJA = E2_LOJA
cSql += "                       AND A2_NATUREZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
If !Empty(MV_PAR05)
	df_FilNat := U_BIAGetLike(Alltrim(MV_PAR05))
	cSQL += "	                      AND A2_NATUREZ NOT IN("+df_FilNat+")
EndIf
cSql += "                       AND SA2.D_E_L_E_T_ = ' '
cSql += "  INNER JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = '"+xFilial("SF1")+"'
cSql += "                       AND F1_DOC = SE2.E2_NUM
cSql += "                       AND F1_SERIE = SE2.E2_PREFIXO
cSql += "                       AND F1_FORNECE = SE2.E2_FORNECE
cSql += "                       AND F1_LOJA = E2_LOJA
cSql += "                       AND F1_EMISSAO = E2_EMISSAO
cSql += "                       AND SF1.D_E_L_E_T_ = ' '
cSql += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"'
cSql += "    AND E2_EMIS1 BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dDataFim)+"'
cSql += "    AND E2_IRRF <> 0
cSql += "    AND SE2.D_E_L_E_T_ = ' '
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

CallCrys("BIA403", cEmpant, cOpcao)

Return

/*___________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFun็เo    ฆ ValidPergฆ Autor ฆ Wanisay William       ฆ Data ฆ 13.02.08 ฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/
Static Function ValidPerg()
local j,i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da Data                     ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data                    ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Da  Natureza                ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SED"})
aAdd(aRegs,{cPerg,"04","Ate Natureza                ?","","","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SED"})
aAdd(aRegs,{cPerg,"05","Exceto varias Naturezas (,) ?","","","mv_ch5","C",70,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
