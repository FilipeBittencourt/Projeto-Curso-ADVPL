#include "rwmake.ch" 
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA998     ³ Autor ³ MILEIR XAVIER         ³ Data ³ 20/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AXCADASTRO CADASTRO referencias de linhas de produto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BIA998()
Local aRotAdic :={}

aadd(aRotAdic,{ "Dt. Produção","U_fAtuProd", 0 , 6 })

AXCADASTRO("SZ5","CADASTRO REFERENCIAS DE LINHAS",            ,          , aRotAdic, , , , , , , , , )  

Return


//Grava Data Producao
User Function fAtuProd() 	
	Processa({|| RptDetail()})
Return

Static Function RptDetail()
Local lRet 		:= .F.
Local nNomeTMP	:= ""
Local nEmp		:= ""
Local cSql		:= ""
Local nQtd		:= 0

lRet := MsgBox("Esta rotina irá gravar a Data de Produção de acordo com a informação cadastrada na tabela de Ordem de Produção. Deseja continuar? ","Atenção","YesNo")

If lRet
   
   	//Define nome tabela                
	nNomeTMP := "##TMP_BIA998"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	
	//Define Empresa
	If cEmpAnt == "01"
		nEmp := "0101"
	Else
		nEmp := "05"
	EndIf
	
	//Monta arquivo de trabalho
	cSql := "EXEC SP_DISPONIBILIDADE '"+nNomeTMP+"','"+nEmp+"','' "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(cSQL)})
	
	//Monta arquivo temporario, resultado da SP
	cSql := "SELECT *, (SELECT COUNT(*) FROM "+nNomeTMP+") AS QTDREG FROM "+nNomeTMP+" "
	If chkfile("RAC1")
		dbSelectArea("RAC1")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "RAC1"
	DbSelectArea("RAC1")
	RAC1->(DbGotop())

	nQtdReg := RAC1->QTDREG 
	ProcRegua(nQtdReg)

	Do While !RAC1->(EOF())

		IncProc("Atualizando Data Produção..."+RAC1->COD_FORMATO+"-"+RAC1->COD_LINHA)

		If Alltrim(RAC1->VENDA) == "SIM"
			If !Empty(Alltrim(RAC1->DATA))
				cSql := "UPDATE "+RetSqlName("SZ5")+" SET Z5_DATA = '' WHERE Z5_FORMATO = '"+RAC1->COD_FORMATO+"' AND Z5_LINHA = '"+RAC1->COD_LINHA+"' AND D_E_L_E_T_ = '' "
				TcSQLExec(cSql)				
			EndIf		
		Else 
			cSql := "SELECT ISNULL(MIN(C2_DATPRI),'') DATA_PROD "
			cSql += "FROM "+RetSqlName("SC2")+" "
			cSql += "WHERE C2_SEQUEN =  '001' 		AND "
			cSql += "	   C2_DATRF  =  '        '	AND	"
			cSql += "	   C2_OBS    <> 'AVULSA'	AND "
			cSql += "	   SUBSTRING(C2_PRODUTO,1,2) = '"+RAC1->COD_FORMATO+"' AND
			cSql += "	   SUBSTRING(C2_PRODUTO,4,4) = '"+RAC1->COD_LINHA+"' AND 
			cSql += "	   D_E_L_E_T_ = ''
			If chkfile("RAC2")
				dbSelectArea("RAC2")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "RAC2"

			If !Empty(Alltrim(RAC2->DATA_PROD))
				cSql := "UPDATE "+RetSqlName("SZ5")+" SET Z5_DATA = '"+Dtos(Datavalida(((Stod(RAC2->DATA_PROD))+5)))+"' WHERE Z5_FORMATO = '"+RAC1->COD_FORMATO+"' AND Z5_LINHA = '"+RAC1->COD_LINHA+"' AND D_E_L_E_T_ = '' "
				TcSQLExec(cSql)				
			EndIf
		EndIf			  

		RAC1->(DbSkip()) // Avanca o ponteiro do registro no arquivo
	End Do
	
	MsgBox("Atualização realizada com sucesso!","BIA998","INFO")

EndIf

If chkfile("RAC1")
	dbSelectArea("RAC1")
	dbCloseArea()
EndIf

If chkfile("RAC2")
	dbSelectArea("RAC2")
	dbCloseArea()
EndIf


Return 