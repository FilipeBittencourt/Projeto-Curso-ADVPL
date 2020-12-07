#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

User Function BIA705()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA705
Empresa   := Biancogres Ceramica S.A.
Data      := 19/02/13
Uso       := Estoque / Custos
Aplicação := Gera devolução valorizada no estoque para cada nota de retor-
.            de remessa a fim de compor o custo total da operação de indus-
.            trialização que é: Nota de Serviço (1124) + Ret.Remessa (1902) e
.            eventualmente Quebra (1903)
.            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
.            Necessário rodar a query que ajusta o D1_CUSTO antes de rodar
.            esta rotina
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local vf

cHInicio := Time()
fPerg := "BIA705"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
	MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA705 - Data de Fechamento!!!")
	Return
EndIf

If dDataBase <> GetMV("MV_YULMES")
	MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA705 - Data de Fechamento!!!")
	Return
EndIf

oLogProc := TBiaLogProc():New()
oLogProc:LogIniProc("BIA705",fPerg)

QI005 := " SELECT D1_DOC,
QI005 += "        D1_DTDIGIT,
QI005 += "        D1_YCODREF,
QI005 += "        SUM(D1_CUSTO) CUSTO
QI005 += "   FROM "+RetSqlName("SD1")+" SD1
QI005 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
QI005 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
QI005 += "    AND D1_FORNECE = '003721'
QI005 += "    AND ( D1_CF = '1902' OR (D1_CF = '1903' AND D1_TES = '089') )
QI005 += "    AND D_E_L_E_T_ = ' '
QI005 += "  GROUP BY D1_DOC, D1_DTDIGIT, D1_YCODREF
QI005 += "  ORDER BY D1_DOC, D1_DTDIGIT, D1_YCODREF
QI005 := ChangeQuery(QI005)
cIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QI005),'QI05',.T.,.T.)
aStru1 := ("QI05")->(dbStruct())
/*   Exporta os dados do resultado de uma  |
| Query para um arquivo temporário normal */
If !chkfile("QI06")
	QI06 := U_BIACrTMP(aStru1)
	dbUseArea( .T.,, QI06, "QI06", .F., .F. )
EndIf
dbSelectArea("QI06")
APPEND FROM ("QI05")
If Select("QI05") > 0
	QI05->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado
Endif

dbSelectArea("QI06")
dbGoTop()
ProcRegua(RecCount())
kkjjCont := 0
While !Eof()
	
	kkjjCont ++
	IncProc("Proc... " + QI06->D1_DOC + " " + Alltrim(Str(kkjjCont)))
	
	az_clvl := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+QI06->D1_YCODREF))
	jh_Custo := QI06->CUSTO
	
	kk_TM := "015"
	kk_CF := "DE6"
	
	RecLock("SD3",.T.)
	SD3->D3_FILIAL   := xFilial("SD3")
	SD3->D3_TM       := kk_TM
	SD3->D3_COD      := QI06->D1_YCODREF
	SD3->D3_UM       := SB1->B1_UM
	SD3->D3_LOCAL    := SB1->B1_LOCPAD
	SD3->D3_CC       := "3000"
	SD3->D3_CLVL     := az_clvl
	SD3->D3_CONTA    := SB1->B1_CONTA
	SD3->D3_TIPO     := SB1->B1_TIPO
	SD3->D3_GRUPO    := SB1->B1_GRUPO
	SD3->D3_CUSTO1   := Round(ABS(jh_Custo),2)
	SD3->D3_EMISSAO  := stod(QI06->D1_DTDIGIT)
	SD3->D3_DOC      := QI06->D1_DOC
	SD3->D3_USUARIO  := cUserName
	SD3->D3_CF       := kk_CF
	SD3->D3_NUMSEQ   := ProxNum()
	SD3->D3_CHAVE    := "E0"
	SD3->D3_YRFCUST  := "BIA705"
	SD3->D3_YOBS     := "Devolução Valorizada referente Retorno de Poder de Terceiros"
	MsUnlock()
	
	dbSelectArea("QI06")
	dbSkip()
End

QI06->(dbCloseArea())
Ferase(QI06+GetDBExtension())     //arquivo de trabalho
Ferase(QI06+OrdBagExt())          //indice gerado

// Grava XML
oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Verificar gravação - Poder de Terceiros para custo " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TM"           ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCR"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DOC"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CUSTO1"       ,3,2)

PL008 := " SELECT D3_EMISSAO EMISSAO,
PL008 += "        D3_TM TM,
PL008 += "        D3_COD PRODUTO,
PL008 += "        SUBSTRING(B1_DESC,1,50) DESCR,
PL008 += "        D3_DOC DOC,
PL008 += "        D3_CUSTO1 CUSTO1
PL008 += "   FROM "+RetSqlName("SD3")+" SD3
PL008 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
PL008 += "                       AND B1_COD = D3_COD
PL008 += "                       AND SB1.D_E_L_E_T_ = ' '
PL008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
PL008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
PL008 += "    AND D3_YRFCUST = 'BIA705'
PL008 += "    AND SD3.D_E_L_E_T_ = ' '
PLcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,PL008),'PL08',.F.,.T.)
dbSelectArea("PL08")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(PL08->EMISSAO)), PL08->TM, PL08->PRODUTO, PL08->DESCR, PL08->DOC, PL08->CUSTO1 })
	
	dbSelectArea("PL08")
	dbSkip()
	
End

PL08->(dbCloseArea())
Ferase(PLcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(PLcIndex+OrdBagExt())          //indice gerado

xArqTemp := "verificargrvp3 - " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

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

MsgINFO("........: Fim do Processamento : ........")

oLogProc:LogFimProc()
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
aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
