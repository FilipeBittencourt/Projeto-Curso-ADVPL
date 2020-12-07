#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA508()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA508
Empresa   := Biancogres Cerâmica S/A
Data      := 29/09/14
Uso       := Movimentos Contábeis Gerencias
Aplicação := Browser para cadastro de MCG
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private xTotVlr := 0
Private xLinhaL := ""
Private xTpLanc := ""
Private xDebito := ""
Private xCredit := ""
Private xClvlDB := ""
Private xClvlCR := ""
Private xCCD    := ""
Private xCCC    := ""
// Para fins de controle de lançamentos
Private cTpSaldo   := "1"
Private lVldTps    := GETMV("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo

cCadastro := "Movimentos Contábeis Gerenciais"
aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
{               "Incluir"         ,'ExecBlock("B508FUNC",.F.,.F.,"I")'  ,0,3},;
{               "Alterar"         ,'ExecBlock("B508FUNC",.F.,.F.,"A")'  ,0,4},;
{               "Excluir"         ,'ExecBlock("B508FUNC",.F.,.F.,"D")'  ,0,5},;
{               "VariaçãoEstoque" ,'ExecBlock("BIA508A",.F.,.F.)'       ,0,6},;
{               "Var.Est.Excel  " ,'ExecBlock("BIA508EX",.F.,.F.)'      ,0,7} }

dbSelectArea("Z48")
dbSetOrder(1)
dbGoTop()

Z48->(mBrowse(06,01,22,75,"Z48"))

dbSelectArea("Z48")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B508FUNC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.09.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Controle de Funções para faciliar liberação para usuários  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B508FUNC()

If PARAMIXB == "I"
	AxInclui("Z48", Z48->(Recno()), 3,,,, "U_b508TudoOK()", .F.,,,,,,.T.,,,,,)
	
ElseIf PARAMIXB == "A"
	cTpSaldo    := Z48->Z48_TPSALD
	dDataEst	:= Z48->Z48_DATA
	lDataOk 	:= CtbValiDt(4,dDataEst,.F.,cTpSaldo,lVldTps)
	If lDataOk
		AxAltera("Z48", Z48->(Recno()), 4,,,,,/*"U_b508TudoOK()"*/,    ,,,,,,.T.,,,,,)
	Else
		Aviso('Calendário Contábil', 'O registro que se pretende alterar pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
	EndIf
	
ElseIf PARAMIXB == "D"
	cTpSaldo    := Z48->Z48_TPSALD
	dDataEst	:= Z48->Z48_DATA
	lDataOk 	:= CtbValiDt(5,dDataEst,.F.,cTpSaldo,lVldTps)
	If lDataOk
		AxDeleta("Z48", Z48->(Recno()), 5,,,,,,.T.,,,,,)
	Else
		Aviso('Calendário Contábil', 'O registro que se pretende deletar pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
	EndIf
EndIf

Return

**************************************************
**                                              **
**************************************************
User Function b508TudoOK()

xfRetOk     := .T.
cTpSaldo    := M->Z48_TPSALD
dDataEst	:= M->Z48_DATA
lDataOk 	:= CtbValiDt(3,dDataEst,.F.,cTpSaldo,lVldTps)
If !lDataOk
	Aviso('Calendário Contábil', 'O registro que se pretende incluir pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
	xfRetOk     := .F.
EndIf

Return ( xfRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA508A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27.04.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Calcula Variação de Estoque para DRE BPC-SAP               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA508A()

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

cHInicio := Time()
fPerg := "BIA508A"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

If GetMV("MV_ULMES") <> MV_PAR02
	Aviso('Virada Mensal', 'Favor Verificar se a Virada Mensal foi efetuda para o período em questão!!!', {'Ok'})
	Return
EndIf

xfRetOk     := .T.
cTpSaldo    := "1"
dDataEst	:= MV_PAR02
lDataOk 	:= CtbValiDt(3,dDataEst,.F.,cTpSaldo,lVldTps)
If !lDataOk
	Aviso('Calendário Contábil', 'O registro que se pretende incluir pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
	Return
EndIf

xTotVQ  := 0
xTotVC  := 0
xTotVQC := 0
xTotVE  := 0

ZP008 := " WITH B9INI AS (SELECT B9_DATA, B9_COD, B9_LOCAL, B9_QINI, B9_VINI1
ZP008 += "                  FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
ZP008 += "                 INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
ZP008 += "                                                    AND B1_COD = B9_COD
ZP008 += "                                                    AND B1_TIPO = 'PA'
ZP008 += "                                                    AND SB1.D_E_L_E_T_ = ' '
ZP008 += "                 WHERE B9_FILIAL = '"+xFilial("SB9")+"'
ZP008 += "                   AND B9_DATA = '"+dtos(MV_PAR01)+"'
If cEmpAnt == "14"
	ZP008 += "                   AND B9_LOCAL NOT IN('01','07')
EndIf
ZP008 += "                   AND SB9.D_E_L_E_T_ = ' ')
ZP008 += "      ,
ZP008 += "      B9FIN AS (SELECT B9_DATA, B9_COD, B9_LOCAL, B9_QINI, B9_VINI1
ZP008 += "                  FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
ZP008 += "                 INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
ZP008 += "                                                    AND B1_COD = B9_COD
ZP008 += "                                                    AND B1_TIPO = 'PA'
ZP008 += "                                                    AND SB1.D_E_L_E_T_ = ' '
ZP008 += "                 WHERE B9_FILIAL = '"+xFilial("SB9")+"'
ZP008 += "                   AND B9_DATA = '"+dtos(MV_PAR02)+"'
If cEmpAnt == "14"
	ZP008 += "                   AND B9_LOCAL NOT IN('01','07')
EndIf
ZP008 += "                   AND SB9.D_E_L_E_T_ = ' ')
ZP008 += " SELECT B9_DATA,
ZP008 += "        B9_COD,
ZP008 += "        B9_LOCAL,
ZP008 += "        Qi,
ZP008 += "        Qf,
ZP008 += "        Ci,
ZP008 += "        Cf,
ZP008 += "        (Qf - Qi) * Ci VQ,
ZP008 += "        (Cf - Ci) * Qi VC,
ZP008 += "        (Qf - Qi) * (Cf - Ci) VQC,
ZP008 += "        ( (Qf - Qi) * Ci ) + ( (Cf - Ci) * Qi ) + ( (Qf - Qi) * (Cf - Ci) ) VE
ZP008 += "   FROM (SELECT FIN.B9_DATA,
ZP008 += "                FIN.B9_COD,
ZP008 += "                FIN.B9_LOCAL,
ZP008 += "                ISNULL(INI.B9_QINI, 0) Qi,
ZP008 += "                ISNULL(FIN.B9_QINI, 0) Qf,
ZP008 += "                ISNULL((CASE
ZP008 += "                   WHEN INI.B9_QINI <> 0 THEN INI.B9_VINI1 / INI.B9_QINI
ZP008 += "                   ELSE 0
ZP008 += "                 END), 0) Ci,
ZP008 += "                ISNULL((CASE
ZP008 += "                   WHEN FIN.B9_QINI <> 0 THEN FIN.B9_VINI1 / FIN.B9_QINI
ZP008 += "                   ELSE 0
ZP008 += "                 END), 0) Cf
ZP008 += "           FROM B9FIN FIN
ZP008 += "           LEFT JOIN B9INI INI ON INI.B9_COD = FIN.B9_COD
ZP008 += "                              AND INI.B9_LOCAL = FIN.B9_LOCAL) AS TABL
ZP008 += "   WHERE ( Qi <> 0 OR Qf <> 0 OR Ci <> 0 OR Cf <> 0 )
ZPIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP008),'ZP08',.T.,.T.)
dbSelectArea("ZP08")
dbGoTop()
ProcRegua(RecCount())
While !Eof() //.AND. 1 == 2
	
	IncProc()
	
	/*
	If ( ZP08->Qi * ZP08->Ci ) == 0
	xTotVQ  += ZP08->VQC
	xTotVC  += 0
	xTotVQC += 0
	xTotVE  += ZP08->VE
	ElseIf ( ZP08->Qf * ZP08->Cf ) == 0
	xTotVQ  += ZP08->VQ + ZP08->VQC
	xTotVC  += ZP08->VC
	xTotVQC += 0
	xTotVE  += ZP08->VE
	Else
	xTotVQ  += ZP08->VQ
	xTotVC  += ZP08->VC
	xTotVQC += ZP08->VQC
	xTotVE  += ZP08->VE
	EndIf
	*/
	
	xTotVQ  += IIf(ZP08->Qi*ZP08->Ci == 0, ZP08->VQC, IIF(ZP08->Qf * ZP08->Cf == 0, ZP08->VQ            , ZP08->VQ  ))
	xTotVC  += IIf(ZP08->Qi*ZP08->Ci == 0, 0        , IIF(ZP08->Qf * ZP08->Cf == 0, ZP08->VC + ZP08->VQC, ZP08->VC  ))
	xTotVQC += IIf(ZP08->Qi*ZP08->Ci == 0, 0        , IIF(ZP08->Qf * ZP08->Cf == 0, 0                   , ZP08->VQC ))
	xTotVE  += ZP08->VE
	/*
	If ( ZP08->Qi * ZP08->Ci ) == 0
	xTotVQ  += ZP08->VQC
	xTotVC  += 0
	xTotVQC += 0
	xTotVE  += ZP08->VE
	ElseIf ( ZP08->Qf * ZP08->Cf ) == 0
	xTotVQ  += ZP08->VQ + ZP08->VQC
	xTotVC  += ZP08->VC
	xTotVQC += 0
	xTotVE  += ZP08->VE
	Else
	xTotVQ  += ZP08->VQ
	xTotVC  += ZP08->VC
	xTotVQC += ZP08->VQC
	xTotVE  += ZP08->VE
	EndIf
	*/
	
	dbSelectArea("ZP08")
	dbSkip()
	
End

ZP08->(dbCloseArea())
Ferase(ZPIndex+GetDBExtension())
Ferase(ZPIndex+OrdBagExt())

//                                                 Variação por Quantidade
**************************************************************************
If xTotVQ > 0
	xTotVlr := xTotVQ
	xLinhaL := "001"
	xTpLanc := "1"
	xDebito := "41399001"
	xCredit := ""
	xClvlDB := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xClvlCR := ""
	xCCD    := "3000"
	xCCC    := ""
	BIA508B()
ElseIf xTotVQ < 0
	xTotVlr := xTotVQ * (-1)
	xLinhaL := "001"
	xTpLanc := "2"
	xDebito := ""
	xCredit := "41399001"
	xClvlDB := ""
	xClvlCR := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xCCD    := ""
	xCCC    := "3000"
	BIA508B()
EndIf

//                                                      Variação por Custo
**************************************************************************
If xTotVC > 0
	xTotVlr := xTotVC
	xLinhaL := "002"
	xTpLanc := "1"
	xDebito := "41399002"
	xCredit := ""
	xClvlDB := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xClvlCR := ""
	xCCD    := "3000"
	xCCC    := ""
	BIA508B()
ElseIf xTotVC < 0
	xTotVlr := xTotVC * (-1)
	xLinhaL := "002"
	xTpLanc := "2"
	xDebito := ""
	xCredit := "41399002"
	xClvlDB := ""
	xClvlCR := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xCCD    := ""
	xCCC    := "3000"
	BIA508B()
EndIf

//                                         Variação por Quantidade e Custo
**************************************************************************
If xTotVQC > 0
	xTotVlr := xTotVQC
	xLinhaL := "003"
	xTpLanc := "1"
	xDebito := "41399003"
	xCredit := ""
	xClvlDB := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xClvlCR := ""
	xCCD    := "3000"
	xCCC    := ""
	BIA508B()
ElseIf xTotVQC < 0
	xTotVlr := xTotVQC * (-1)
	xLinhaL := "003"
	xTpLanc := "2"
	xDebito := ""
	xCredit := "41399003"
	xClvlDB := ""
	xClvlCR := If(cEmpAnt == "01", "3100", If(cEmpAnt == "05", "3200", ""))
	xCCD    := ""
	xCCC    := "3000"
	BIA508B()
EndIf

If cEmpAnt $ "06/07/13"      // CPV convertido em CVPP nas empresas comerciais
	**************************************************************************
	
	xValor := 0
	WR006 := " SELECT ROUND(ISNULL(SUM(VALOR),0), 2) VALOR
	WR006 += "   FROM (SELECT ISNULL(SUM(CT2_VALOR),0) VALOR
	WR006 += "           FROM "+RetSqlName("CT2")+" WITH (NOLOCK)
	WR006 += "          WHERE CT2_DATA BETWEEN '"+Substr(dtos(MV_PAR02),1,6)+"01' AND '"+dtos(MV_PAR02)+"'
	WR006 += "            AND ( CT2_DEBITO = '41301001' OR SUBSTRING(CT2_DEBITO,1,3) = '621' )
	WR006 += "            AND D_E_L_E_T_ = ' '
	WR006 += "          UNION ALL
	WR006 += "         SELECT ISNULL(SUM(CT2_VALOR),0) * (-1) VALOR
	WR006 += "           FROM "+RetSqlName("CT2")+" WITH (NOLOCK)
	WR006 += "          WHERE CT2_DATA BETWEEN '"+Substr(dtos(MV_PAR02),1,6)+"01' AND '"+dtos(MV_PAR02)+"'
	WR006 += "            AND ( CT2_CREDIT = '41301001' OR SUBSTRING(CT2_CREDIT,1,3) = '621' )
	WR006 += "            AND D_E_L_E_T_ = ' '
	WR006 += "          UNION ALL
	WR006 += "          SELECT ISNULL(SUM(Z48_VALOR),0) VALOR
	WR006 += "           FROM "+RetSqlName("Z48")+" WITH (NOLOCK)
	WR006 += "          WHERE Z48_DATA BETWEEN '"+Substr(dtos(MV_PAR02),1,6)+"01' AND '"+dtos(MV_PAR02)+"'
	WR006 += "            AND ( SUBSTRING(Z48_DEBITO,1,5) = '41399' OR Z48_DEBITO = '61110005' )
	WR006 += "            AND D_E_L_E_T_ = ' '
	WR006 += "          UNION ALL
	WR006 += "         SELECT ISNULL(SUM(Z48_VALOR),0) * (-1) VALOR
	WR006 += "           FROM "+RetSqlName("Z48")+" WITH (NOLOCK)
	WR006 += "          WHERE Z48_DATA BETWEEN '"+Substr(dtos(MV_PAR02),1,6)+"01' AND '"+dtos(MV_PAR02)+"'
	WR006 += "            AND ( SUBSTRING(Z48_CREDIT,1,5) = '41399' OR Z48_CREDIT = '61110005' )
	WR006 += "            AND D_E_L_E_T_ = ' ') AS TABL
	WRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,WR006),'WR06',.T.,.T.)
	dbSelectArea("WR06")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		IncProc()
		
		xValor += WR06->VALOR * (-1)
		
		dbSelectArea("WR06")
		dbSkip()
		
	End
	
	WR06->(dbCloseArea())
	Ferase(WRIndex+GetDBExtension())
	Ferase(WRIndex+OrdBagExt())
	
	//               Variação por Custo - sinal contábil tem que ser invertido
	**************************************************************************
	If xValor < 0
		xTotVlr := xValor * (-1)
		xLinhaL := "004"
		xTpLanc := "1"
		xDebito := "61110005"
		xCredit := ""
		xClvlDB := ""
		xClvlCR := ""
		xCCD    := ""
		xCCC    := ""
		BIA508B()
	ElseIf xValor < 0
		xTotVlr := xValor
		xLinhaL := "004"
		xTpLanc := "2"
		xDebito := ""
		xCredit := "61110005"
		xClvlDB := ""
		xClvlCR := ""
		xCCD    := ""
		xCCC    := ""
		BIA508B()
	EndIf
	
EndIf

// Variação de Estoque - Outros Custos
// Até esta data - 15/07/15 - nenhum tratamento automático implementado
// Mas já temos alguns indícios:
//	- Serviço da Industrialização;
//	- Venda de Energia que passa pela 41301001
//	- Estornando valor de venda de energia para a Incesa - conta 41301004

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA508B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27.04.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava registros na tabela Contabilização Gerencial - Z48   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA508B()

dbSelectArea("Z48")
RecLock("Z48",.T.)
Z48->Z48_FILIAL := xFilial("Z48")
Z48->Z48_DATA   := MV_PAR02
Z48->Z48_LOTE   := "007000"
Z48->Z48_SBLOTE := "001"
Z48->Z48_DOC    := "000555"
Z48->Z48_LINHA  := xLinhaL
Z48->Z48_DC     := xTpLanc
Z48->Z48_DEBITO := xDebito
Z48->Z48_CREDIT := xCredit
Z48->Z48_VALOR  := xTotVlr
Z48->Z48_CLVLDB := xClvlDB
Z48->Z48_CLVLCR := xClvlCR
Z48->Z48_CCD    := xCCD
Z48->Z48_CCC    := xCCC
Z48->Z48_HIST   := "VARIACAO DE ESTOQUE"
Z48->Z48_ORIGEM := "PROCESSANEMTO"
Z48->Z48_TPSALD := "1"
Z48->Z48_MOEDLC := "01"
Z48->Z48_EMPORI := cEmpAnt
Z48->Z48_FILORI := cFilAnt
Z48->Z48_ROTINA := "BIA508"
Z48->Z48_UN     := cEmpAnt
MsUnLock()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA508EX  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 26.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Lista Variação de Estoque para efeito de conferência       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA508EX()

#IFDEF WINDOWS
	Processa({|| RptExDetail()})
	Return
	Static Function RptExDetail()
#ENDIF

cHInicio := Time()
fPerg := "BIA508A"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Variação de Estoque"
oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "DATA"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"     ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCRIC"     ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "LOCAL"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Qi"          ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "Qf"          ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "Ci"          ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "Cf"          ,3,2)

xTotVQ  := 0
xTotVC  := 0
xTotVQC := 0
xTotVE  := 0

ZP001 := " WITH B9INI AS (SELECT B9_DATA, B9_COD, B9_LOCAL, B9_QINI, B9_VINI1
ZP001 += "                  FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
ZP001 += "                 INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
ZP001 += "                                                    AND B1_COD = B9_COD
ZP001 += "                                                    AND B1_TIPO = 'PA'
ZP001 += "                                                    AND SB1.D_E_L_E_T_ = ' '
ZP001 += "                 WHERE B9_FILIAL = '"+xFilial("SB9")+"'
ZP001 += "                   AND B9_DATA = '"+dtos(MV_PAR01)+"'
If cEmpAnt == "14"
	ZP001 += "                   AND B9_LOCAL NOT IN('01','07')
EndIf
ZP001 += "                   AND SB9.D_E_L_E_T_ = ' ')
ZP001 += "      ,
ZP001 += "      B9FIN AS (SELECT B9_DATA, B9_COD, B9_LOCAL, B9_QINI, B9_VINI1
ZP001 += "                  FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
ZP001 += "                 INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
ZP001 += "                                                    AND B1_COD = B9_COD
ZP001 += "                                                    AND B1_TIPO = 'PA'
ZP001 += "                                                    AND SB1.D_E_L_E_T_ = ' '
ZP001 += "                 WHERE B9_FILIAL = '"+xFilial("SB9")+"'
ZP001 += "                   AND B9_DATA = '"+dtos(MV_PAR02)+"'
If cEmpAnt == "14"
	ZP001 += "                   AND B9_LOCAL NOT IN('01','07')
EndIf
ZP001 += "                   AND SB9.D_E_L_E_T_ = ' ')
ZP001 += " SELECT B9_DATA,
ZP001 += "        B9_COD,
ZP001 += "        B9_LOCAL,
ZP001 += "        Qi,
ZP001 += "        Qf,
ZP001 += "        Ci,
ZP001 += "        Cf
ZP001 += "   FROM (SELECT FIN.B9_DATA,
ZP001 += "                FIN.B9_COD,
ZP001 += "                FIN.B9_LOCAL,
ZP001 += "                ISNULL(INI.B9_QINI, 0) Qi,
ZP001 += "                ISNULL(FIN.B9_QINI, 0) Qf,
ZP001 += "                ISNULL((CASE
ZP001 += "                   WHEN INI.B9_QINI <> 0 THEN INI.B9_VINI1 / INI.B9_QINI
ZP001 += "                   ELSE 0
ZP001 += "                 END), 0) Ci,
ZP001 += "                ISNULL((CASE
ZP001 += "                   WHEN FIN.B9_QINI <> 0 THEN FIN.B9_VINI1 / FIN.B9_QINI
ZP001 += "                   ELSE 0
ZP001 += "                 END), 0) Cf
ZP001 += "           FROM B9FIN FIN
ZP001 += "           LEFT JOIN B9INI INI ON INI.B9_COD = FIN.B9_COD
ZP001 += "                              AND INI.B9_LOCAL = FIN.B9_LOCAL) AS TABL
ZP001 += "   WHERE ( Qi <> 0 OR Qf <> 0 OR Ci <> 0 OR Cf <> 0 )
ZPIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP001),'ZP01',.T.,.T.)
dbSelectArea("ZP01")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+ZP01->B9_COD))
	
	oExcel:AddRow(nxPlan, nxTabl, { ZP01->B9_DATA   ,;
	ZP01->B9_COD                                    ,;
	Substr(SB1->B1_DESC,1,50)                       ,;
	ZP01->B9_LOCAL                                  ,;
	ZP01->Qi                                        ,;
	ZP01->Qf                                        ,;
	ZP01->Ci                                        ,;
	ZP01->Cf                                        })
	
	dbSelectArea("ZP01")
	dbSkip()
	
End

ZP01->(dbCloseArea())
Ferase(ZPIndex+GetDBExtension())
Ferase(ZPIndex+OrdBagExt())

xArqTemp := "VariaçãoEstoque - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
	Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
EndIf

oExcel:Activate()
oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

cCrLf := Chr(13) + Chr(10)
If ! ApOleClient( 'MsExcel' )
	MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
Else
	oExcel:= MsExcel():New()
	oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
	oExcel:SetVisible(.T.)
EndIf

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
aAdd(aRegs,{cPerg,"01","Dt Fechamento Anterior ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Dt Fechamento Atual    ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
