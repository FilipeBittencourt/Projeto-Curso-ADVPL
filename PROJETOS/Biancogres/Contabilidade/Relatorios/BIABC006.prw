#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC006
Empresa   := Biancogres Cerâmica S/A
Data      := 04/04/19
Uso       := Contabilidade
Aplicação := Retorna informações de razão das contas de um determinado período, 
para as contas de débito ou crédito (61601022 e 31141019)e 
as classes de valor de débito ou crédito (3130,3110,3150,3200,3250,2100,2150,1240,2200,2250,1241)
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function BIABC006()
Private cEnter := CHR(13)+CHR(10)
private aPergs := {}
Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Razão das contas de débito e crédito"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "Lote"			,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Doc"			,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Ct Dédito"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Ct Crédito"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Ct Origem"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Valor"		,3,2, .T.)
oExcel:AddColumn(nxPlan, nxTabl, "Histórico"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Histórico"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CV Débito"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CV Crédito"	,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Data"			,1,4)

GU004 :=	""

GU004 += "SELECT CT2_LOTE, CT2_DOC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_YHIST, CT2_HIST, CT2_CLVLDB, CT2_CLVLCR, CT2_ORIGEM," + cEnter 
GU004 += "(CASE CT2_DATA WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,CT2_DATA),103) END) AS CT2_DATA" + cEnter
GU004 += "  FROM " + RetSQLName("CT2")+ CEnter
GU004 += " WHERE CT2_DATA BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
GU004 += "   AND (CT2_DEBITO IN ('61601022','31141019') OR " + cEnter
GU004 += "        CT2_CREDIT IN ('61601022','31141019'))" + cEnter
GU004 += "   AND (CT2_CLVLDB IN ('3130','3110','3150','3200','3250','2100','2150','1240','2200','2250','1241') OR " + cEnter
GU004 += "        CT2_CLVLCR IN ('3130','3110','3150','3200','3250','2100','2150','1240','2200','2250','1241')) " + cEnter
GU004 += "   AND D_E_L_E_T_ = ''" + cEnter
GU004 += "   AND CT2_FILIAL  = " + ValToSQL(xFilial("CT2"))
GUcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
dbSelectArea("GU04")
dbGoTop()
ProcRegua(RecCount())

While !Eof()	

	IncProc()
		
	oExcel:AddRow(nxPlan, nxTabl, { GU04->CT2_LOTE,GU04->CT2_DOC, ;
	                                GU04->CT2_DEBITO,GU04->CT2_CREDIT,;
	                                GU04->CT2_ORIGEM,Round(GU04->CT2_VALOR,2),;
	                                GU04->CT2_YHIST,GU04->CT2_HIST,;
	                                GU04->CT2_CLVLDB,GU04->CT2_CLVLCR,;
	                                GU04->CT2_DATA })
	
	dbSelectArea("GU04")
	dbSkip()	
End

GU04->(dbCloseArea())
Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GUcIndex+OrdBagExt())          //indice gerado

xArqTemp := "razao_contabil_"+cEmpAnt

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

	local cLoad	    := "BIABC006"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(100)
	
	aAdd( aPergs ,{1,"Data Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Final   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Promoção de Colaboradores ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet
