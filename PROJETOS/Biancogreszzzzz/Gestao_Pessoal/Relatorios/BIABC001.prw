#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"

User Function BIABC001()
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC001
Empresa   := Biancogres Cerâmica S/A
Data      := 11/01/19
Uso       := Gestão Pessoal
Aplicação := Relatório de alteração de Cargo: Promoções
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Local Enter := chr(13) + Chr(10)
private aPergs := {}
Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Promoções de Colaboradores"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "Matrícula"            ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Nome"                 ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Admissão"             ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Demissão"             ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Classe de Valor"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Desc. Classe de Valor",1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Dt Promoção"          ,1,4)
oExcel:AddColumn(nxPlan, nxTabl, "Função Promoção"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Função Anterior"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Salário Anterior"     ,3,2, .T.)
oExcel:AddColumn(nxPlan, nxTabl, "Função Atual"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "Salário Atual"        ,3,2, .T.)
oExcel:AddColumn(nxPlan, nxTabl, "Motivo da Alteração"  ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "e-mail Supervisor"    ,1,1)

GU004 :=	""

GU004 += "WITH TEMP AS (SELECT MAX(R7_DATA) DT_PROMO,R7_DESCFUN,R7_MAT,R7_DATA,R7_TIPO,R7_FILIAL,R7_FUNCAO" + Enter
GU004 += "                FROM " + RetSqlName("SR7") + Enter 
GU004 += "               WHERE R7_TIPO IN ('004','006','014','018')" + Enter
GU004 += "                 AND R7_DATA BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + Enter
GU004 += "			   GROUP BY R7_DESCFUN,R7_MAT,R7_DATA,R7_TIPO,R7_FILIAL,R7_FUNCAO)" + Enter

GU004 += "SELECT RA_MAT," + Enter 
GU004 += "       RA_NOME," + Enter
GU004 += "       RA_ADMISSA," + Enter
GU004 += "       RA_DEMISSA," + Enter
GU004 += "	     --" + Enter 
GU004 += "       RA_CLVL," + Enter
GU004 += "       (SELECT CTH_DESC01" + Enter 
GU004 += "          FROM CTH010" + Enter
GU004 += "         WHERE CTH_CLVL = RA_CLVL) AS DSC_CLVL," + Enter
GU004 += "       --" + Enter
GU004 += "		 DT_PROMO," + Enter
GU004 += "       --" + Enter 
GU004 += "       FIRST_VALUE(R7_DESCFUN) OVER(PARTITION BY R7_MAT ORDER BY R7_DATA DESC)FNC_PROMO," + Enter
GU004 += "       --" + Enter
GU004 += "       (SELECT DISTINCT FIRST_VALUE(R7_DESCFUN) OVER(PARTITION BY R7_MAT ORDER BY R7_DATA DESC)" + Enter
GU004 += "          FROM " + RetSqlName("SR7") + Enter
GU004 += "         WHERE R7_MAT = RA_MAT" + Enter
GU004 += "           AND R7_TIPO IN ('001','002','015')" + Enter
GU004 += "           AND R7_DATA < DT_PROMO) FNC_ANT," + Enter
GU004 += "       --" + Enter
GU004 += "       (SELECT DISTINCT FIRST_VALUE(R3_VALOR ) OVER(PARTITION BY R3_MAT ORDER BY R3_DATA DESC)" + Enter
GU004 += "          FROM " + RetSqlName("SR3") + Enter 
GU004 += "         INNER JOIN " + RetSqlName("SR7") + " ON (R3_MAT = R7_MAT AND R3_FILIAL = R7_FILIAL AND R3_DATA = R7_DATA AND R3_TIPO = R7_TIPO)" + Enter 
GU004 += "         WHERE R3_MAT = RA_MAT" + Enter
GU004 += "           AND R3_PD = '000'" + Enter
GU004 += "	         AND R7_TIPO IN ('001','002','015')" + Enter
GU004 += "           AND R7_DATA <=DT_PROMO)SL_ANT," + Enter
GU004 += "       --" + Enter  
GU004 += "		 RA_YDFUNC FNC_ATUAL," + Enter
GU004 += "       RA_SALARIO SL_ATUAL," + Enter
GU004 += "       --" + Enter  
GU004 += "		 (SELECT DISTINCT FIRST_VALUE(X5_DESCRI) OVER (PARTITION BY R7_MAT ORDER BY R7_DATA DESC)" + Enter
GU004 += "          FROM " + RetSqlName("SX5") + Enter
GU004 += "	       WHERE X5_TABELA = '41'" + Enter
GU004 += "	         AND RA_MAT = R7_MAT" + Enter
GU004 += "	         AND RA_FILIAL = R7_FILIAL" + Enter
GU004 += "           AND X5_CHAVE = R7_TIPO" + Enter
GU004 += "	         AND RA_YDFUNC <> R7_FUNCAO) AS MOTIVO," + Enter
GU004 += "	     --" + Enter
GU004 += "		 RA_YSEMAIL" + Enter
GU004 += "  FROM " + RetSqlName("SRA") + Enter
GU004 += " INNER JOIN TEMP ON (R7_MAT = RA_MAT)
GU004 += " ORDER BY 6 DESC, 2

GUcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
dbSelectArea("GU04")
dbGoTop()
ProcRegua(RecCount())

While !Eof()	

	IncProc()
		
	oExcel:AddRow(nxPlan, nxTabl, { GU04->RA_MAT,GU04->RA_NOME, stod(GU04->RA_ADMISSA),stod(GU04->RA_DEMISSA), ;
	                                GU04->RA_CLVL,GU04->DSC_CLVL,;
	                                stod(GU04->DT_PROMO),GU04->FNC_PROMO,;
	                                GU04->FNC_ANT,Round(GU04->SL_ANT,2),;
	                                GU04->FNC_ATUAL, Round(GU04->SL_ATUAL,2),;
	                                GU04->MOTIVO, GU04->RA_YSEMAIL })
	
	dbSelectArea("GU04")
	dbSkip()	
End

GU04->(dbCloseArea())
Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(GUcIndex+OrdBagExt())          //indice gerado

xArqTemp := "func_promocao_"+cEmpAnt

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

	local cLoad	    := "BIABC001"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(100)
	
	aAdd( aPergs ,{1,"Data Inicial de Promoção ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Final de Promoção   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Promoção de Colaboradores ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet


