#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA512()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA512
Empresa   := Biancogres Cerâmica S/A
Data      := 06/11/14
Uso       := Estoque e Custos
Aplicação := Checa amarrações do retorno de porder de terceiros para fecha-
.            mento do custo mensal.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local xt

fPerg := "BIA512"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

oLogProc := TBiaLogProc():New()
oLogProc:LogIniProc("BIA512",fPerg)


oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Checa amarrações do retorno de poder de terceiros " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DTDIGIT"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "FORMATOORI"    ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "FORMATORET"    ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CF"            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TES"           ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DOC"           ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "ITEM"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCX"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "QUANT"         ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "VUNIT"         ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "TOTAL"         ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"         ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "IDENTB6"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "NFORI"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CODREF"        ,1,1)

XY001 := " SELECT D1_EMISSAO EMISSAO,
XY001 += "        D1_DTDIGIT DTDIGIT,
XY001 += "        SB1.B1_YFORMAT FORMATOORI,
XY001 += "        XB1.B1_YFORMAT FORMATORET,
XY001 += "        D1_CF CF,
XY001 += "        D1_TES TES,
XY001 += "        D1_DOC DOC,
XY001 += "        D1_ITEM ITEM,
XY001 += "        D1_COD PRODUTO,
XY001 += "        SUBSTRING(SB1.B1_DESC,1,50) DESCX,
XY001 += "        D1_QUANT QUANT,
XY001 += "        D1_VUNIT VUNIT,
XY001 += "        D1_TOTAL TOTAL,
XY001 += "        D1_CUSTO CUSTO,
XY001 += "        D1_IDENTB6 IDENTB6,
XY001 += "        D1_NFORI NFORI,
XY001 += "        D1_YCODREF CODREF
// Obrigatoriamente tem que pegar a informação da tabela da Biancogres.
XY001 += "   FROM SD1010 SD1
XY001 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
XY001 += "                       AND SB1.B1_COD = D1_COD
XY001 += "                       AND SB1.D_E_L_E_T_ = ' '
XY001 += "   LEFT JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
XY001 += "                       AND XB1.B1_COD = D1_YCODREF
XY001 += "                       AND XB1.D_E_L_E_T_ = ' '
XY001 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
XY001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
XY001 += "    AND D1_FORNECE = '003721'
//XY001 += "    AND ( D1_CF = '1902' OR (D1_CF = '1903' AND D1_TES = '089') )
//XY001 += "    AND ( D1_YCODREF = '               ' OR SUBSTRING(D1_COD,1,2) = SUBSTRING(D1_YCODREF,1,2) OR LEN(RTRIM(D1_YCODREF)) = 7 )
XY001 += "    AND SD1.D_E_L_E_T_ = ' '
XY001 += "  ORDER BY SD1.D1_DOC, SD1.D1_ITEM
XYcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY001),'XY01',.F.,.T.)
dbSelectArea("XY01")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	xCodRef := IIf(!Empty(XY01->CODREF), XY01->CODREF, XY01->PRODUTO)
	
	oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(XY01->EMISSAO)), dtoc(stod(XY01->DTDIGIT)), XY01->FORMATOORI, XY01->FORMATORET, XY01->CF, XY01->TES, XY01->DOC, XY01->ITEM, XY01->PRODUTO, XY01->DESCX, XY01->QUANT, XY01->VUNIT, XY01->TOTAL, XY01->CUSTO, XY01->IDENTB6, XY01->NFORI, xCodRef })
	
	dbSelectArea("XY01")
	dbSkip()
	
End

XY01->(dbCloseArea())
Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(XYcIndex+OrdBagExt())          //indice gerado

xArqTemp := "checacustoret-vt-tot-" + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

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
