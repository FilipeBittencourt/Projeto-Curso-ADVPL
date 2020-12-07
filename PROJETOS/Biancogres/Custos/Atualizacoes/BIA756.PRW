#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA756()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA756
Empresa   := Biancogres Cerâmica S/A
Data      := 20/02/14
Uso       := Estoque e Custos
Aplicação := Valorizar as Tabelas SD1 e SB6 referente CUSTO de retorno com
.            base no envio
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local xt

fPerg := "BIA756"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

oLogProc := TBiaLogProc():New()
oLogProc:LogIniProc("BIA756",fPerg)

ZT007 := " UPDATE "+RetSqlName("SB6")+" SET B6_CUSTO1 =
ZT007 += "        ROUND((SELECT B6_CUSTO1/B6_QUANT
ZT007 += "                 FROM "+RetSqlName("SB6")+" XB6
ZT007 += "                WHERE B6_FILIAL = '"+xFilial("SB6")+"'
ZT007 += "                  AND B6_PRODUTO = SB6.B6_PRODUTO
ZT007 += "                  AND B6_IDENT = SB6.B6_IDENT
ZT007 += "                  AND B6_PODER3 = 'R'
ZT007 += "                  AND D_E_L_E_T_ = ' ') * B6_QUANT, 2)
ZT007 += "   FROM "+RetSqlName("SB6")+" SB6
ZT007 += "  WHERE B6_FILIAL = '"+xFilial("SB6")+"'
ZT007 += "    AND B6_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
ZT007 += "    AND B6_CLIFOR = '003721'
ZT007 += "    AND B6_TES < '500'
ZT007 += "    AND B6_TES <> '175'
ZT007 += "    AND D_E_L_E_T_ = ' '
TCSQLExec(ZT007)

QU005 := " UPDATE "+RetSqlName("SD1")+" SET D1_CUSTO =
QU005 += "        ROUND((SELECT B6_CUSTO1/B6_QUANT
QU005 += "                 FROM "+RetSqlName("SB6")
QU005 += "                WHERE B6_FILIAL = '"+xFilial("SB6")+"'
QU005 += "                  AND B6_DOC = D1_NFORI
QU005 += "                  AND B6_PRODUTO = D1_COD
QU005 += "                  AND B6_IDENT = D1_IDENTB6
QU005 += "                  AND D_E_L_E_T_ = ' ') * D1_QUANT, 2)
QU005 += "   FROM "+RetSqlName("SD1")
QU005 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
QU005 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
QU005 += "    AND D1_FORNECE = '003721'
QU005 += "    AND ( D1_CF = '1902' OR (D1_CF = '1903' AND D1_TES = '089') )
QU005 += "    AND D_E_L_E_T_ = ' '
TCSQLExec(QU005)

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Valorizar a Tabela SB6 referente CUSTO de retorno com base no envio " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "B6_IDENT"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DT_DIGIT"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "B6_CUSTO1"       ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "B6_QUANT"        ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "B6_DTDIGIT"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "B6_TES"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "ESTOQUE"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "B6_DOC"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "B6_PRODUTO"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "EMISS_ORI"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "NEW_CT_TOTAL"    ,3,2)

EH003 := " SELECT B6_IDENT,
EH003 += "        (SELECT B6_DTDIGIT
EH003 += "           FROM "+RetSqlName("SB6")+" XB6
EH003 += "          WHERE B6_FILIAL = '"+xFilial("SB6")+"'
EH003 += "           AND B6_PRODUTO = SB6.B6_PRODUTO
EH003 += "           AND B6_IDENT = SB6.B6_IDENT
EH003 += "           AND B6_PODER3 = 'R'
EH003 += "           AND D_E_L_E_T_ = ' ') DT_DIGIT,
EH003 += "        B6_CUSTO1,
EH003 += "        B6_QUANT,
EH003 += "        B6_DTDIGIT,
EH003 += "        B6_TES,
EH003 += "        (SELECT F4_ESTOQUE
EH003 += "           FROM "+RetSqlName("SF4")
EH003 += "          WHERE F4_FILIAL = '"+xFilial("SF4")+"'
EH003 += "            AND F4_CODIGO = B6_TES
EH003 += "            AND D_E_L_E_T_ = ' ') ESTOQUE,
EH003 += "        B6_DOC,
EH003 += "        B6_PRODUTO,
EH003 += "        (SELECT B6_EMISSAO
EH003 += "           FROM "+RetSqlName("SB6")+" XB6
EH003 += "          WHERE B6_FILIAL = '"+xFilial("SB6")+"'
EH003 += "            AND B6_PRODUTO = SB6.B6_PRODUTO
EH003 += "            AND B6_IDENT = SB6.B6_IDENT
EH003 += "            AND B6_PODER3 = 'R'
EH003 += "            AND D_E_L_E_T_ = ' ') EMISS_ORI,
EH003 += "        ROUND((SELECT B6_CUSTO1/B6_QUANT
EH003 += "                 FROM "+RetSqlName("SB6")+" XB6
EH003 += "                WHERE B6_FILIAL = '"+xFilial("SB6")+"'
EH003 += "                  AND B6_PRODUTO = SB6.B6_PRODUTO
EH003 += "                  AND B6_IDENT = SB6.B6_IDENT
EH003 += "                  AND B6_PODER3 = 'R'
EH003 += "                  AND D_E_L_E_T_ = ' ') * B6_QUANT, 2) NEW_CT_TOTAL
EH003 += "   FROM "+RetSqlName("SB6")+" SB6
EH003 += "  WHERE B6_FILIAL = '"+xFilial("SB6")+"'
EH003 += "    AND B6_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
EH003 += "    AND B6_CLIFOR = '003721'
EH003 += "    AND B6_TES < '500'
EH003 += "    AND B6_TES <> '175'
EH003 += "    AND D_E_L_E_T_ = ' '
EHcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,EH003),'EH03',.F.,.T.)
dbSelectArea("EH03")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	oExcel:AddRow(nxPlan, nxTabl, { EH03->B6_IDENT, dtoc(stod(EH03->DT_DIGIT)), EH03->B6_CUSTO1, EH03->B6_QUANT, dtoc(stod(EH03->B6_DTDIGIT)), EH03->B6_TES, EH03->ESTOQUE, EH03->B6_DOC, EH03->B6_PRODUTO, dtoc(stod(EH03->EMISS_ORI)), EH03->NEW_CT_TOTAL })
	
	dbSelectArea("EH03")
	dbSkip()
	
End

EH03->(dbCloseArea())
Ferase(EHcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(EHcIndex+OrdBagExt())          //indice gerado

nxPlan := "Planilha 02"
nxTabl := "Valorizar a Tabela SD1 referente CUSTO de retorno com base no envio " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "D1_CUSTO"        ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "D1_IDENTB6"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "D1_YCODREF"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "D1_MEDIO"        ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "B6_MEDIO"        ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "B6_CUSTO"        ,3,2)

GF004 := " SELECT D1_CUSTO,
GF004 += "        D1_IDENTB6,
GF004 += "        D1_YCODREF,
GF004 += "        ROUND(D1_CUSTO/D1_QUANT,4) D1_MEDIO,
GF004 += "        ROUND((SELECT B6_CUSTO1/B6_QUANT
GF004 += "                 FROM " + RetSqlName("SB6")
GF004 += "                WHERE B6_FILIAL = '"+xFilial("SB6")+"'
GF004 += "                  AND B6_DOC = D1_NFORI
GF004 += "                  AND B6_PRODUTO = D1_COD
GF004 += "                  AND B6_IDENT = D1_IDENTB6
GF004 += "                  AND D_E_L_E_T_ = ' ') , 4) B6_MEDIO,
GF004 += "        ROUND((SELECT B6_CUSTO1/B6_QUANT
GF004 += "                 FROM " + RetSqlName("SB6")
GF004 += "                WHERE B6_FILIAL = '"+xFilial("SB6")+"'
GF004 += "                  AND B6_DOC = D1_NFORI
GF004 += "                  AND B6_PRODUTO = D1_COD
GF004 += "                  AND B6_IDENT = D1_IDENTB6
GF004 += "                  AND D_E_L_E_T_ = ' ') * D1_QUANT, 2) B6_CUSTO
GF004 += "   FROM "+RetSqlName("SD1")
GF004 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
GF004 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
GF004 += "    AND D1_FORNECE = '003721'
GF004 += "    AND ( D1_CF = '1902' OR (D1_CF = '1903' AND D1_TES = '089') )
GF004 += "    AND D_E_L_E_T_ = ' '
GFcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GF004),'GF04',.F.,.T.)
dbSelectArea("GF04")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	oExcel:AddRow(nxPlan, nxTabl, { GF04->D1_CUSTO, GF04->D1_IDENTB6, GF04->D1_YCODREF, GF04->D1_MEDIO, GF04->B6_MEDIO, GF04->B6_CUSTO })
	
	dbSelectArea("GF04")
	dbSkip()
	
End

GF04->(dbCloseArea())
Ferase(GFcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GFcIndex+OrdBagExt())          //indice gerado

xArqTemp := "checacustoval-p3-" + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

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

oLogProc:LogFimProc()
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
