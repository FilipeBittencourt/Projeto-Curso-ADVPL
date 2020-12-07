#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA735()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA735
Empresa   := Biancogres Cerâmica S/A
Data      := 30/08/13
Uso       := PCP
Aplicação := Listagem para conferência e acompanhamento dos movimentos de
.            ajuste de PI - TM 120
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

fPerg := "BIA735"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

nxPlan := "TM"
nxTabl := "TM - de " + dtoc(MV_PAR01) + " até " + dtoc(MV_PAR02)

oExcel := FWMSEXCEL():New()
oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "EMISSÃO"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TP.MOV"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCRIÇÃO"       ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "UM"              ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "LOCAL"           ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "USUARIO"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2,.T.)
oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"           ,3,2,.T.)
oExcel:AddColumn(nxPlan, nxTabl, "OBS"             ,1,1)

RT001 := " SELECT D3_EMISSAO,
RT001 += "        D3_TM,
RT001 += "        D3_COD,
RT001 += "        SUBSTRING(B1_DESC, 1, 50) DESCR,
RT001 += "        D3_UM,
RT001 += "        D3_LOCAL,
RT001 += "        D3_USUARIO,
RT001 += "        CASE
RT001 += "          WHEN D3_TM < '500' THEN D3_QUANT
RT001 += "          ELSE D3_QUANT * (-1)
RT001 += "        END D3_QUANT,
RT001 += "        CASE
RT001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1
RT001 += "          ELSE D3_CUSTO1 * (-1)
RT001 += "        END D3_CUSTO1,
RT001 += "        D3_YOBS
RT001 += "   FROM "+RetSqlName("SD3")+" SD3
RT001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
RT001 += "                       AND B1_COD = D3_COD
RT001 += "                       AND SB1.D_E_L_E_T_ = ' '
RT001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
RT001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
If MV_PAR03 <> 1
	RT001 += "    AND D3_TM = '120'
Else
	RT001 += "    AND D3_TM IN('120','720')
EndIf
RT001 += "    AND D3_ESTORNO = ' '
RT001 += "    AND SD3.D_E_L_E_T_ = ' '
If MV_PAR04 == 1
	RT001 += "  UNION ALL
	RT001 += " SELECT D3_EMISSAO,
	RT001 += "        D3_TM,
	RT001 += "        D3_COD,
	RT001 += "        SUBSTRING(B1_DESC, 1, 50) DESCR,
	RT001 += "        D3_UM,
	RT001 += "        D3_LOCAL,
	RT001 += "        D3_USUARIO,
	RT001 += "        CASE
	RT001 += "          WHEN D3_TM < '500' THEN D3_QUANT
	RT001 += "          ELSE D3_QUANT * (-1)
	RT001 += "        END D3_QUANT,
	RT001 += "        CASE
	RT001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1
	RT001 += "          ELSE D3_CUSTO1 * (-1)
	RT001 += "        END D3_CUSTO1,
	RT001 += "        D3_YOBS
	RT001 += "   FROM "+RetSqlName("SD3")+" SD3
	RT001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	RT001 += "                       AND B1_COD = D3_COD
	RT001 += "                       AND B1_GRUPO = '102I'
	RT001 += "                       AND SB1.D_E_L_E_T_ = ' '
	RT001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	RT001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	RT001 += "    AND D3_TM IN('005','502')
	RT001 += "    AND D3_CF NOT IN('DE3','RE3')
	RT001 += "    AND D3_ESTORNO = ' '
	RT001 += "    AND SD3.D_E_L_E_T_ = ' '
EndIf
RT001 += "  ORDER BY D3_COD, D3_EMISSAO
RTcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT001),'RT01',.F.,.T.)
dbSelectArea("RT01")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(RT01->D3_EMISSAO)), RT01->D3_TM, RT01->D3_COD, RT01->DESCR, RT01->D3_UM, RT01->D3_LOCAL, RT01->D3_USUARIO, RT01->D3_QUANT, RT01->D3_CUSTO1, RT01->D3_YOBS })
	
	dbSelectArea("RT01")
	dbSkip()
	
End

RT01->(dbCloseArea())
Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(RTcIndex+OrdBagExt())          //indice gerado

xArqTemp := nxPlan + dtos(dDataBase)

If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
	Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
EndIf

oExcel:Activate()
oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

cCrLf := Chr(13) + Chr(10)
If ! ApOleClient( 'MsExcel' )
	MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml"  )
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
aAdd(aRegs,{cPerg,"03","Lista o TM 720 juntamente?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Listar TINTA DIGITAL     ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
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
