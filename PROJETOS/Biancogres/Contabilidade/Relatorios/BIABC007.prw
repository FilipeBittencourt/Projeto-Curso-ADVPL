#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC007
Empresa   := Biancogres Cerâmica S/A
Data      := 12/04/19
Uso       := Contabilidade
Aplicação := Relatório de Requisições excluídas
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function BIABC007()
Private cEnter := CHR(13)+CHR(10)
private aPergs := {}
Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Requisições excluídas"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "Filial"		,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Almox"		,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Produto"		,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Requisitante"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Requis. Excl"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Qtd Excl"		,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Emissão Excl"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Requis. Nova"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Qtd Nova"		,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Emissão Nova"	,1,1)

GU004 := ""

GU004 += "WITH EXCLUIDO AS (SELECT 	ZJ_FILIAL EXC_FILIAL, 	" + cEnter
GU004 += "							ZJ_LOCAL EXC_LOCAL,   	" + cEnter
GU004 += "							ZJ_DOC EXC_DOC,  		" + cEnter
GU004 += "							ZJ_EMPRESA EXC_EMPRESA, " + cEnter
GU004 += "							ZJ_COD EXC_COD, 		" + cEnter
GU004 += "							ZJ_QUANT EXC_QUANT, 	" + cEnter
GU004 += "							ZJ_VLRTOT EXC_VLRTOT, 	" + cEnter
GU004 += "							ZI_EMISSAO EXC_EMISSAO,	" + cEnter
GU004 += "							ZI_MATRIC EXC_MATRIC	" + cEnter					
GU004 += "					  FROM 	" + RetSQLName("SZJ")+" SZJ WITH (NOLOCK)" + cEnter 
GU004 += "					 INNER  JOIN " + RetSQLName("SZI")+" SZI WITH (NOLOCK) ON " + cEnter
GU004 += "							(ZJ_FILIAL = ZI_FILIAL AND " + cEnter
GU004 += "							 ZJ_DOC = ZI_DOC AND " + cEnter
GU004 += "							 ZJ_EMPRESA = ZI_EMPRESA AND " + cEnter
GU004 += "							 SZJ.D_E_L_E_T_ = '*' AND " + cEnter
GU004 += "							 SZI.D_E_L_E_T_ = '*'))" + cEnter

GU004 += "SELECT * FROM " + cEnter
GU004 += "(" + cEnter
GU004 += "	SELECT	ZJ_FILIAL, " + cEnter
GU004 += "			ZJ_LOCAL, 
GU004 += "			RTRIM(LTRIM(ZJ_COD)) + ' - ' + RTRIM(LTRIM((SELECT B1_DESC FROM SB1010 WHERE B1_COD = SZJ.ZJ_COD))) AS PRODUTO," + cEnter
GU004 += "			ZI_MATRIC + ' - ' + ZI_NOME AS REQUISITANTE," + cEnter
GU004 += "			ZJ_DOC, " + cEnter
GU004 += "			ZJ_QUANT, " + cEnter
GU004 += "			CONVERT(VARCHAR(10),CONVERT(DATETIME,ZI_EMISSAO),103) ZI_EMISSAO, " + cEnter
GU004 += "       	EXC_DOC, " + cEnter
GU004 += "	   		EXC_QUANT, " + cEnter
GU004 += "	   		CONVERT(VARCHAR(10),CONVERT(DATETIME,EXC_EMISSAO),103) EXC_EMISSAO," + cEnter
GU004 += "	   		RANK() OVER (PARTITION BY EXC_DOC ORDER BY ZJ_DOC) AS ORDEM  " + cEnter
GU004 += "	  FROM 	" + RetSQLName("SZJ")+" SZJ WITH (NOLOCK)" + cEnter 
GU004 += "   INNER 	JOIN " + RetSQLName("SZI")+" SZI WITH (NOLOCK) ON " + cEnter
GU004 += "			(ZJ_FILIAL = ZI_FILIAL AND " + cEnter
GU004 += "			 ZJ_DOC = ZI_DOC AND " + cEnter
GU004 += "			 ZJ_EMPRESA = ZI_EMPRESA AND " + cEnter
GU004 += "			 SZJ.D_E_L_E_T_ = '' AND " + cEnter
GU004 += "			 SZI.D_E_L_E_T_ = '')" + cEnter
GU004 += "	 INNER 	JOIN EXCLUIDO ON " + cEnter
GU004 += "			(SZJ.ZJ_FILIAL = EXC_FILIAL AND" + cEnter
GU004 += "			 SZJ.ZJ_EMPRESA = EXC_EMPRESA AND" + cEnter
GU004 += "			 SZJ.ZJ_LOCAL = EXC_LOCAL AND " + cEnter
GU004 += "			 SZJ.ZJ_COD = EXC_COD AND" + cEnter
GU004 += "			 SZJ.ZJ_DOC > EXC_DOC AND" + cEnter
GU004 += "			 SZJ.ZJ_QUANT < EXC_QUANT AND" + cEnter
GU004 += "			 SZI.ZI_EMISSAO >= EXC_EMISSAO AND" + cEnter
GU004 += "			 SZI.ZI_MATRIC =  EXC_MATRIC)" + cEnter
GU004 += "	 WHERE 	EXC_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
GU004 += ") T" + cEnter
GU004 += "WHERE T.ORDEM = 1" + cEnter
GU004 += "ORDER BY EXC_EMISSAO DESC, ZJ_LOCAL, ZJ_DOC, PRODUTO" + cEnter


GUcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
dbSelectArea("GU04")
dbGoTop()
ProcRegua(RecCount())

While !Eof()	

	IncProc()
		
	oExcel:AddRow(nxPlan, nxTabl, { GU04->ZJ_FILIAL, GU04->ZJ_LOCAL, ;
	                                GU04->PRODUTO, GU04->REQUISITANTE,;
	                                GU04->EXC_DOC, GU04->EXC_QUANT, GU04->EXC_EMISSAO,;
	                                GU04->ZJ_DOC, GU04->ZJ_QUANT, GU04->ZI_EMISSAO})
	
	dbSelectArea("GU04")
	dbSkip()	
End

GU04->(dbCloseArea())
Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GUcIndex+OrdBagExt())          //indice gerado

xArqTemp := "req_excl_"+cEmpAnt+"_"+dtos(MV_PAR01)+"_"+dtos(MV_PAR02)

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

	local cLoad	    := "BIABC007"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(100)
	
	aAdd( aPergs ,{1,"Data Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Final   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Relatório de Requisições excluídas ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet
