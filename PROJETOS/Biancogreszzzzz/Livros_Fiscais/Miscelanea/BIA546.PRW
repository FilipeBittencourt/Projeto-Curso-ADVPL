#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA546()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA546
Empresa   := Biancogres Cerêmicas S/A
Data      := 03/02/16
Uso       := Livros fiscais
Aplicação := Acerta CDA
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi

cHInicio := Time()
fPerg := "BIA545"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

jyGrvCDA := .T.
oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Registros faltantes no CDA"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_FILIAL"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_TPMOVI"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_ESPECI"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_FORMUL"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_NUMERO"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_SERIE"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_CLIFOR"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_LOJA"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_NUMITE"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_SEQ"           ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_CALPRO"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_BASE"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_ALIQ"          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_VALOR"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "D_E_L_E_T_"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "R_E_C_N_O_"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_TPREG"         ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_CODOLD"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "R_E_C_D_E_L_"      ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_CODLAN"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_IFCOMP"        ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CDA_TPLANC"        ,1,1)

IJ004 := " SELECT '"+xFilial("CDA")+"' CDA_FILIAL,
IJ004 += "        'E' CDA_TPMOVI,
IJ004 += "        ISNULL((SELECT F1_ESPECIE
IJ004 += "                  FROM " + RetSqlName("SF1")
IJ004 += "                 WHERE F1_FILIAL = '"+xFilial("SF1")+"'
IJ004 += "                   AND F1_DOC = D1_DOC
IJ004 += "                   AND F1_SERIE = D1_SERIE
IJ004 += "                   AND F1_FORNECE = D1_FORNECE
IJ004 += "                   AND F1_LOJA = D1_LOJA
IJ004 += "                   AND D_E_L_E_T_ = ' '), '   ') CDA_ESPECI,
IJ004 += "        ' ' CDA_FORMUL,
IJ004 += "        D1_DOC CDA_NUMERO,
IJ004 += "        D1_SERIE CDA_SERIE,
IJ004 += "        D1_FORNECE CDA_CLIFOR,
IJ004 += "        D1_LOJA CDA_LOJA,
IJ004 += "        D1_ITEM CDA_NUMITE,
IJ004 += "        SUBSTRING(D1_ITEM,2,3) CDA_SEQ,
IJ004 += "        '1' CDA_CALPRO,
IJ004 += "        D1_BASEICM CDA_BASE,
IJ004 += "        D1_PICM CDA_ALIQ,
IJ004 += "        D1_ICMSCOM CDA_VALOR,
IJ004 += "        ' ' DELET,
IJ004 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+RetSqlName("CDA")+") + ROW_NUMBER() OVER(ORDER BY SD1.R_E_C_N_O_) AS NOVOREC,
IJ004 += "        ' ' CDA_TPREG,
IJ004 += "        ' ' CDA_CODOLD,
IJ004 += "        0 NODEL,
IJ004 += "        CC7_CODLAN CDA_CODLAN,
IJ004 += "        CC7_IFCOMP CDA_IFCOMP,
IJ004 += "        '2' CDA_TPLANC
IJ004 += "   FROM "+RetSqlName("SD1")+" SD1
IJ004 += "   LEFT JOIN "+RetSqlName("CC7")+" CC7 ON CC7_FILIAL = '"+xFilial("CC7")+"'
IJ004 += "                       AND CC7_TES = D1_TES
IJ004 += "                       AND CC7.D_E_L_E_T_ = ' '
IJ004 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
IJ004 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
IJ004 += "    AND D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA IN(SELECT F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA
IJ004 += "                                                FROM " + RetSqlName("SF3")
IJ004 += "                                               WHERE F3_FILIAL = '"+xFilial("SF3")+"'
IJ004 += "                                                 AND F3_ENTRADA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
IJ004 += "                                                 AND F3_CFO < '5000'
IJ004 += "                                                 AND F3_ICMSCOM <> 0
IJ004 += "                                                 AND D_E_L_E_T_ = ' ')
IJ004 += "    AND D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM NOT IN(SELECT CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE
IJ004 += "                                                            FROM " + RetSqlName("CDA")
IJ004 += "                                                           WHERE CDA_FILIAL = '"+xFilial("CDA")+"'
IJ004 += "                                                             AND D_E_L_E_T_ = ' ')
IJ004 += "    AND D1_ICMSCOM <> 0
IJ004 += "    AND D1_TIPO NOT IN('D')
IJ004 += "    AND SD1.D_E_L_E_T_ = ' '
IJcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,IJ004),'IJ04',.F.,.T.)
dbSelectArea("IJ04")
dbGoTop()
ProcRegua(RecCount())
xContad := 0
While !Eof()
	
	xContad ++
	IncProc(Alltrim(Str(xContad)))
	
	If Empty(IJ04->CDA_CODLAN)
		jyGrvCDA := .F.
	EndIf
	
	oExcel:AddRow(nxPlan, nxTabl, { IJ04->CDA_FILIAL  ,;
	IJ04->CDA_TPMOVI                                  ,;
	IJ04->CDA_ESPECI                                  ,;
	IJ04->CDA_FORMUL                                  ,;
	IJ04->CDA_NUMERO                                  ,;
	IJ04->CDA_SERIE                                   ,;
	IJ04->CDA_CLIFOR                                  ,;
	IJ04->CDA_LOJA                                    ,;
	IJ04->CDA_NUMITE                                  ,;
	IJ04->CDA_SEQ                                     ,;
	IJ04->CDA_CALPRO                                  ,;
	IJ04->CDA_BASE                                    ,;
	IJ04->CDA_ALIQ                                    ,;
	IJ04->CDA_VALOR                                   ,;
	IJ04->DELET                                       ,;
	IJ04->NOVOREC                                     ,;
	IJ04->CDA_TPREG                                   ,;
	IJ04->CDA_CODOLD                                  ,;
	IJ04->NODEL                                       ,;
	IJ04->CDA_CODLAN                                  ,;
	IJ04->CDA_IFCOMP                                  ,;
	IJ04->CDA_TPLANC                                  })
	
	dbSelectArea("IJ04")
	dbSkip()
	
End

IJ04->(dbCloseArea())
Ferase(IJcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(IJcIndex+OrdBagExt())          //indice gerado

xArqTemp := "AcertandoCDA - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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

If jyGrvCDA .and. xContad > 0
	
	If MsgNOYES("Confirma a gravação do CDA?")
		
		UJ002 := " INSERT INTO " + RetSqlName("CDA")
		UJ002 += "             (CDA_FILIAL ,
		UJ002 += "             CDA_TPMOVI  ,
		UJ002 += "             CDA_ESPECI  ,
		UJ002 += "             CDA_FORMUL  ,
		UJ002 += "             CDA_NUMERO  ,
		UJ002 += "             CDA_SERIE   ,
		UJ002 += "             CDA_CLIFOR  ,
		UJ002 += "             CDA_LOJA    ,
		UJ002 += "             CDA_NUMITE  ,
		UJ002 += "             CDA_SEQ     ,
		UJ002 += "             CDA_CALPRO  ,
		UJ002 += "             CDA_BASE    ,
		UJ002 += "             CDA_ALIQ    ,
		UJ002 += "             CDA_VALOR   ,
		UJ002 += "             D_E_L_E_T_  ,
		UJ002 += "             R_E_C_N_O_  ,
		UJ002 += "             CDA_TPREG   ,
		UJ002 += "             CDA_CODOLD  ,
		UJ002 += "             R_E_C_D_E_L_,
		UJ002 += "             CDA_CODLAN  ,
		UJ002 += "             CDA_IFCOMP  ,
		UJ002 += "             CDA_TPLANC)
		UJ002 += " "
		
		UJ002 += IJ004
		
		TCSQLExec(UJ002)
		
	EndIf
	
EndIf

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
