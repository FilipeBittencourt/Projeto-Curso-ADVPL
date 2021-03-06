#include "rwmake.ch" 
#INCLUDE "TOPCONN.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA998     � Autor � MILEIR XAVIER         � Data � 20/12/04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � AXCADASTRO CADASTRO referencias de linhas de produto         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
User Function BIA998()
Local aRotAdic :={}

aadd(aRotAdic,{ "Dt. Produ玢o","U_fAtuProd", 0 , 6 })

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

lRet := MsgBox("Esta rotina ir� gravar a Data de Produ玢o de acordo com a informa玢o cadastrada na tabela de Ordem de Produ玢o. Deseja continuar? ","Aten玢o","YesNo")

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

		IncProc("Atualizando Data Produ玢o..."+RAC1->COD_FORMATO+"-"+RAC1->COD_LINHA)

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
	
	MsgBox("Atualiza玢o realizada com sucesso!","BIA998","INFO")

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