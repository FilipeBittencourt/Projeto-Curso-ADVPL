#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA672()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA672
Empresa   := Biancogres Cerâmica S/A
Data      := 18/04/16
Uso       := Custos
Aplicação := Relatório pré Contabilização para encontro de contas de custo
.            do consumo de MP para produção de PI no mês
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local xt

fPerg := "BIA672"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Consumo de MP para produção de PP no mês"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "EMPR    "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DOC     "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "NUMOP   "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TM   	  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CF   	  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "LOCD3   "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "GRUPO   "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DGRUPO  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCR   "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DEBITO  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DDEBITO "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CREDIT  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DCREDIT "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CLVL    "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "ITEMCTA "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CCUSTO  "            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "QUANT   "            ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "CUSTO	  "            ,3,2)

XV005 := " SELECT D3_DOC DOC, "
XV005 += "        D3_NUMSEQ NUMSEQ, "
XV005 += "        D3_OP NUMOP, "
XV005 += "        D3_EMISSAO EMISSAO, "
XV005 += "        D3_TM TM, "
XV005 += "        D3_CF CF, "
XV005 += "        D3_LOCAL LOCD3, "
XV005 += "        SB1.B1_GRUPO GRUPO, "
XV005 += "        SBM.BM_DESC DGRUPO, "
XV005 += "        D3_COD PRODUTO, "
XV005 += "        SUBSTRING(SB1.B1_DESC,1,50) DESCR, "
XV005 += "        SB1.B1_YCTRIND DEBITO, "
XV005 += "        CT1.CT1_DESC01 DDEBITO, "
XV005 += "        XB1.B1_YCTRIND CREDIT, "
XV005 += "        XT1.CT1_DESC01 DCREDIT, "
XV005 += "        D3_CLVL CLVL, "
XV005 += "        D3_ITEMCTA ITEMCTA, "
XV005 += "        D3_CC CCUSTO, "
XV005 += "        D3_QUANT QUANT, "
XV005 += "        D3_CUSTO1 CUSTO "
XV005 += "   FROM "+RetSqlName("SD3")+" SD3 "
XV005 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
XV005 += "                       AND SB1.B1_COD = SD3.D3_COD "
XV005 += "                       AND SB1.D_E_L_E_T_ = ' ' "
XV005 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
XV005 += "                       AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP,1,6) "
XV005 += "                       AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP,7,2) "
XV005 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP,9,3) "
XV005 += "                       AND SC2.D_E_L_E_T_ = ' ' "
XV005 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"' "
XV005 += "                       AND XB1.B1_COD = SC2.C2_PRODUTO "
XV005 += "                       AND XB1.B1_CONTA = SD3.D3_CONTA "
XV005 += "                       AND XB1.D_E_L_E_T_ = ' ' "
XV005 += "  INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' "
XV005 += "                       AND SBM.BM_GRUPO = SB1.B1_GRUPO "
XV005 += "                       AND SBM.D_E_L_E_T_ = ' ' "
XV005 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
XV005 += "                       AND CT1.CT1_CONTA = SB1.B1_YCTRIND "
XV005 += "                       AND CT1.D_E_L_E_T_ = ' ' "
XV005 += "  INNER JOIN "+RetSqlName("CT1")+" XT1 ON XT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
XV005 += "                       AND XT1.CT1_CONTA = XB1.B1_YCTRIND "
XV005 += "                       AND XT1.D_E_L_E_T_ = ' ' "
XV005 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
XV005 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
XV005 += "    AND D3_TM = '999' "
XV005 += "    AND D3_CONTA < '6' "
XV005 += "    AND D3_TIPO = 'MP' "
XV005 += "    AND SD3.D_E_L_E_T_ = ' ' "
XVcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,XV005),'XV05',.F.,.T.)
dbSelectArea("XV05")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc("Processamento1")
	
	oExcel:AddRow(nxPlan, nxTabl, { cEmpAnt                       ,;
	XV05->DOC                                                     ,;
	XV05->NUMSEQ                                                  ,;
	XV05->NUMOP                                                   ,;
	dtoc(stod(XV05->EMISSAO))                                     ,;
	XV05->TM                                                      ,;
	XV05->CF                                                      ,;
	XV05->LOCD3                                                   ,;
	XV05->GRUPO                                                   ,;
	XV05->DGRUPO                                                  ,;
	XV05->PRODUTO                                                 ,;
	XV05->DESCR                                                   ,;
	XV05->DEBITO                                                  ,;
	XV05->DDEBITO                                                 ,;
	XV05->CREDIT                                                  ,;
	XV05->DCREDIT                                                 ,;
	XV05->CLVL                                                    ,;
	XV05->ITEMCTA                                                 ,;
	XV05->CCUSTO                                                  ,;
	XV05->QUANT                                                   ,;
	XV05->CUSTO                                                   })
	
	dbSelectArea("XV05")
	dbSkip()
	
End

XV05->(dbCloseArea())
Ferase(XVcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(XVcIndex+OrdBagExt())          //indice gerado

xArqTemp := "consumo_mp_to_pi - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
	Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!', {'Ok'}, 3)
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
