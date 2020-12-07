#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA279()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA279
Empresa   := Biancogres Cerêmicas S/A
Data      := 30/01/12
Uso       := Estoque
Aplicação := Gerador de informações de Tabelas diversas para Excel
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi
Private oDlg_Sel
Private oButton1
Private oButton2
Private oRadMenu1
Private nRadMenu1 := 1

cHInicio := Time()
fPerg := "BIA279"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

DEFINE MSDIALOG oDlg_Sel TITLE "Seleção para geração de Arquivos de conferência" FROM 000, 000  TO 120, 520 COLORS 0, 16777215 PIXEL

@ 013, 006 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Listagem de movimento de Estoque" SIZE 199, 050 OF oDlg_Sel COLOR 0, 16777215 PIXEL
@ 013, 214 BUTTON oButton1 PROMPT "Confirma" SIZE 037, 012 OF oDlg_Sel ACTION Processa({|| fExecOk()}) PIXEL
@ 032, 215 BUTTON oButton2 PROMPT "Cancela" SIZE 037, 012 OF oDlg_Sel ACTION fNaoExec() PIXEL

ACTIVATE MSDIALOG oDlg_Sel

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fExecOk  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30/01/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fExecOk()

oDlg_Sel:End()

aDados2 := {}

If nRadMenu1 == 1
	
	oExcel := FWMSEXCEL():New()
	
	nxPlan := "Planilha 01"
	nxTabl := "Movimentações de Estoque"
	
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PERIODO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TAB"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CODIGO"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TES_TM"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATMOV"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CODIGO_TES"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESTOQUE"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ALMOX"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ORIMOV"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLIFOR"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"             ,1,1)
	
	A0001 := " SELECT ' ' PERIODO,
	A0001 += "        'SD1' TAB,
	A0001 += "        D1_COD COD,
	A0001 += "        D1_TES TES_TM,
	//A0001 += "        Convert(Char(10),convert(datetime, D1_DTDIGIT),103) DATMOV,
	A0001 += "        D1_DTDIGIT DATMOV,
	A0001 += "        D1_GRUPO GRUPO,
	A0001 += "        D1_DOC DOC,
	A0001 += "        D1_CONTA CONTA,
	A0001 += "        D1_QUANT QUANT,
	A0001 += "        D1_CUSTO CUSTO,
	A0001 += "        F4_CODIGO CODIGO_TES,
	A0001 += "        F4_ESTOQUE ESTOQUE,
	A0001 += "        D1_LOCAL ALMOX,
	A0001 += "        D1_CF CF,
	A0001 += "        ' ' ORIMOV,
	A0001 += "        D1_FORNECE CLIFOR,
	A0001 += "        D1_LOJA LOJA,
	A0001 += "        D1_CLVL CLVL
	A0001 += "   FROM "+RetSqlName("SD1")+" SD1
	A0001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                       AND F4_CODIGO = D1_TES
	A0001 += "                       AND SF4.D_E_L_E_T_ = ' '
	A0001 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND D1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND SD1.D_E_L_E_T_ = ' '
	A0001 += " UNION ALL
	A0001 += " SELECT ' ' PERIODO,
	A0001 += "        'SD2' TAB,
	A0001 += "        D2_COD,
	A0001 += "        D2_TES,
	//A0001 += "        Convert(Char(10),convert(datetime, D2_EMISSAO),103),
	A0001 += "        D2_EMISSAO,
	A0001 += "        D2_GRUPO,
	A0001 += "        D2_DOC,
	A0001 += "        D2_CONTA,
	A0001 += "        D2_QUANT QUANT,
	A0001 += "        D2_CUSTO1,
	A0001 += "        F4_CODIGO,
	A0001 += "        F4_ESTOQUE,
	A0001 += "        D2_LOCAL ALMOX,
	A0001 += "        D2_CF CF,
	A0001 += "        ' ' ORIMOV,
	A0001 += "        D2_CLIENTE CLIFOR,
	A0001 += "        D2_LOJA LOJA,
	A0001 += "        D2_CLVL CLVL
	A0001 += "   FROM "+RetSqlName("SD2")+" SD2
	A0001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                       AND F4_CODIGO = D2_TES
	A0001 += "                       AND SF4.D_E_L_E_T_ = ' '
	A0001 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "    AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND D2_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND SD2.D_E_L_E_T_ = ' '
	A0001 += " UNION ALL
	A0001 += " SELECT ' ' PERIODO,
	A0001 += "        'SD3' TAB,
	A0001 += "        D3_COD,
	A0001 += "        D3_TM,
	//A0001 += "        Convert(Char(10),convert(datetime, D3_EMISSAO),103),
	A0001 += "        D3_EMISSAO,
	A0001 += "        D3_GRUPO,
	A0001 += "        D3_DOC,
	A0001 += "        D3_CONTA,
	A0001 += "        D3_QUANT QUANT,
	A0001 += "        D3_CUSTO1,
	A0001 += "        ' ' F4_CODIGO,
	A0001 += "        'S' F4_ESTOQUE,
	A0001 += "        D3_LOCAL ALMOX,
	A0001 += "        D3_CF CF,
	A0001 += "        D3_YORIMOV ORIMOV,
	A0001 += "        ' ' CLIFOR,
	A0001 += "        ' ' LOJA,
	A0001 += "        D3_CLVL CLVL
	A0001 += "   FROM "+RetSqlName("SD3")+" SD3
	A0001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND D3_CF NOT IN('DE3','RE3')
	A0001 += "    AND SD3.D_E_L_E_T_ = ' '
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		IncProc()
		
		oExcel:AddRow(nxPlan, nxTabl, { "DE "+dtoc(MV_PAR01)+" ATÉ "+dtoc(MV_PAR02)      ,;
		A001->TAB                                        ,;
		A001->COD                                        ,;
		A001->TES_TM                                     ,;
		dtoc(stod(A001->DATMOV))                         ,;
		A001->GRUPO                                      ,;
		A001->DOC                                        ,;
		A001->CONTA                                      ,;
		Transform(A001->QUANT, "@E 999,999,999.9999999") ,;
		Transform(A001->CUSTO, "@E 999,999,999.9999999") ,;
		A001->CODIGO_TES                                 ,;
		A001->ESTOQUE                                    ,;
		A001->ALMOX                                      ,;
		A001->CF                                         ,;
		A001->ORIMOV                                     ,;
		A001->CLIFOR                                     ,;
		A001->LOJA                                       ,;
		A001->CLVL                                       })
		
		dbSelectArea("A001")
		dbSkip()
	End
	aStru1 := ("A001")->(dbStruct())
	
	A001->(dbCloseArea())
	
	
	xArqTemp := "MovimentacaoEstoque-" + cEmpAnt + "-" + strzero(seconds()%3500,5)
	
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
	
EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fNaoExec ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30/01/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fNaoExec()

oDlg_Sel:End()

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
aAdd(aRegs,{cPerg,"01","Da Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Grupo            ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
aAdd(aRegs,{cPerg,"04","Ate Grupo           ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})

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
