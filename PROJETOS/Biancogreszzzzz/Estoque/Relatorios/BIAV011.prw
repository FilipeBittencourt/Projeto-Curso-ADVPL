#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"

User Function BIAV011()
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcus Vinicius Siqueira Nascimento
Programa  := BIAV011
Empresa   := Biancogres Cerâmica S/A
Data      := 08/07/19
Uso       := Almoxarifado
Aplicação := Relatório de pré-requisições
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Local Enter := chr(13) + Chr(10)
private aPergs := {}
Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Pré-requisições"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "Documento"            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Status"                 ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Emissão"             ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Req/Dev"             ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Centro de Custo"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Classe de valor",1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Matrícula"          ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Nome"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Cod Produto"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Produto"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Unidade"     ,3,2, .T.)
oExcel:AddColumn(nxPlan, nxTabl, "Aplicação"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TAG"        ,3,2, .T.)
oExcel:AddColumn(nxPlan, nxTabl, "Localização"  ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Quantidade"    ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Custo Unitário"    ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Custo Total"    ,1,1)

GU004 :=	""


GU004 += " SELECT ZI_DOC," + Enter 
GU004 += "       ZI_BAIXA," + Enter
GU004 += "       ZI_EMISSAO," + Enter
GU004 += "       ZI_TIPO," + Enter
GU004 += "       ZI_CC," + Enter
GU004 += "       ZI_CLVL," + Enter
GU004 += "       ZI_MATRIC," + Enter
GU004 += "       ZI_NOME," + Enter
GU004 += "       ZJ_COD," + Enter
GU004 += "       ZJ_DESCRI," + Enter
GU004 += "       ZJ_UM," + Enter
GU004 += "       ZJ_APLIC," + Enter
GU004 += "       ZJ_TAG," + Enter
GU004 += "       ZJ_LOCAL," + Enter
GU004 += "       ZJ_QUANT," + Enter
GU004 += "       round(ZJ_VLRTOT/ZJ_QUANT, 2) CUS_UNI," + Enter
GU004 += "       ZJ_VLRTOT" + Enter


GU004 += "  FROM " + RetSqlName("SZI") + " a " + Enter
GU004 += " INNER JOIN "+ RetSqlName("SZJ") + " b " +" ON (ZI_FILIAL = ZJ_FILIAL and ZI_DOC = ZJ_DOC)" + Enter

GU004 += " WHERE ZI_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + Enter
GU004 += " AND ZI_CLVL BETWEEN '"+ MV_PAR03+ "' AND '"+ MV_PAR04+ "'" + Enter
GU004 += " AND ZI_MATRIC BETWEEN '"+ MV_PAR05+ "' AND '"+ MV_PAR06+ "'" + Enter
GU004 += " AND ZJ_COD BETWEEN '"+ MV_PAR07+ "' AND '"+ MV_PAR08+ "'" + Enter
GU004 += " AND a.D_E_L_E_T_ = '' and b.D_E_L_E_T_ = '' " + Enter

GUcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
dbSelectArea("GU04")
dbGoTop()
ProcRegua(RecCount())

While !Eof()	

	IncProc()
		
	oExcel:AddRow(nxPlan, nxTabl, { GU04->ZI_DOC,GU04->ZI_BAIXA, stod(GU04->ZI_EMISSAO),GU04->ZI_TIPO, ;
	                                GU04->ZI_CC,GU04->ZI_CLVL,;
	                                GU04->ZI_MATRIC,GU04->ZI_NOME,;
	                                GU04->ZJ_COD,GU04->ZJ_DESCRI,;
	                                GU04->ZJ_UM, GU04->ZJ_APLIC,;
	                                GU04->ZJ_TAG, GU04->ZJ_LOCAL,;
	                                  round(GU04->ZJ_QUANT, 2), round(GU04->CUS_UNI, 2), round(GU04->ZJ_VLRTOT, 2) })
	
	dbSelectArea("GU04")
	dbSkip()	
End

GU04->(dbCloseArea())
Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GUcIndex+OrdBagExt())          //indice gerado

xArqTemp := "pre_requisicao_"+cEmpAnt

If File("C:\TEMP\"+xArqTemp+".xml")
	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf
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

Static Function ValidPerg()

	local cLoad	    := "BIAV011"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(4)
	MV_PAR04 := SPACE(4)
	MV_PAR05 := SPACE(8)
	MV_PAR06 := SPACE(8)
	MV_PAR07 := space(TamSx3("B1_COD")[1])
	MV_PAR08 := space(TamSx3("B1_COD")[1])
	
	aAdd( aPergs ,{1,"Emissão Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Emissão Final ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"CLVL Inicial ", MV_PAR03, "", "", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"CLVL Final ", MV_PAR04, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Matrícula Inicial ", MV_PAR05, "", "", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Matrícula Final ", MV_PAR06, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Produto Inicial ", MV_PAR07,"@!","EXISTCPO('SB1')"		,"SB1",'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto Final ", MV_PAR08,"@!","EXISTCPO('SB1')"		,"SB1",'.T.',50,.T.})

	If ParamBox(aPergs ,"Pré-requisições ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05) 
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07) 
		MV_PAR08 := ParamLoad(cFileName,,8,MV_PAR08)

	EndIf
Return lRet


