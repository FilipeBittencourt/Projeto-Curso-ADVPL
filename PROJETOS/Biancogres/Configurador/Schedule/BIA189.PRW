#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "FILEIO.CH" 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Thiago Dantas de Souza
Programa  := BIA189
Empresa   := Biancogres Cerâmica S/A
Data      := 27/02/14
Uso       := Faturamento Diário
Aplicação := Gera relatório para o acompanhamento do faturamento
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA189()

	Local x
	Private cDir
	Private xViaSched := (Select("SX6")== 0)

	If (xViaSched)                          
		xv_Emps    := U_BAGtEmpr("01_05")
		//cDir := "D:\Protheus11\Protheus_Data\P10\BaseFaturamento\"
		cDir := "\P10\BaseFaturamento\"


		For x := 1 to Len(xv_Emps)
			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])
			//RPCSetEnv(xv_Emps[x,1], xv_Emps[x,2],"Administrador")                        

			ConOut("HORA: "+TIME()+" - Gerando o Faturamento Diário " + xv_Emps[x,1])
			MakeFile(xv_Emps[x,1], cDir)

			ConOut("HORA: "+TIME()+" - Fim da geração do Faturamento Diário " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()
		Next
	Else
		cDir := "T:\Protheus_Data\P10\BaseFaturamento\"
		MakeFile(cempant, cDir)
	EndIf

Return //(.T.)
//---------------------------------MakeFile-------------------------------------------
Static Function MakeFile(cEmpresa,cDirTemp)

	Local nHandle
	//define o nome do arquivo XML, pegando o path de onde está sendo executada a rotina.
	cArqTemp := "Faturamento_Diario_"+Alltrim(Str(Year(dDataBase)))+"_" + cEmpresa
	cPathArq := cDirTemp + cArqTemp + ".csv"

	//cria o componente (objeto) Excel.
	//oExcel := FWMSEXCEL():New()
	nxPlan := "Planilha 01"
	nxTabl := "Faturamento diário"
	cCrLf := Chr(13) + Chr(10)

	//executa a view que traz o faturamento diário.
	cSql := "SELECT * 			" + cCrLf
	cSql += "FROM VW_FATDIARIO	" + cCrLf
	cSql += "WHERE COD_EMPRESA LIKE '"+cEmpresa+"__'" + cCrLf
	cSql += "ORDER BY EMPRESA, SEGMENTO, UF, MUNICIPIO, ANO, MES, NOME_REPRES, GRUPO_CLIENTE, NOME_CLIENTE, STATUS, CATEGORIA, ACABAMENTO, PACOTE, PACOTE2, PACOTE3, FORMATO, TIPOLINHA, DESCRICAOLINHA, PRODUTO, CLASSE"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'QRY',.F.,.T.)
	dbSelectArea('QRY')
	dbGoTop()
	//ProcRegua(RecCount())
	aStru := ("QRY")->(dbStruct())

	ConOut("BIA189 - "+cPathArq)

	If FILE(cPathArq)   
		FErase(cPathArq)	
	EndIf

	nHandle := MSFCREATE(cPathArq,0)
	ConOut("BIA189 - handle "+cvaltochar(nHandle))


	If nHandle == -1 .Or. nHandle == 0
		conout("bia189 Erro ao criar arquivo - ferror " + Str(Ferror()))              
		Return
	EndIf 

	If nHandle > 0

		//popula o componente Excel, conforme definição dos campos.
		aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) },2 )
		fWrite(nHandle, cCrLf ) // Pula linha

		While !Eof()
			FWrite(nHandle, 		 ;
			QRY->EMPRESA		+";"+;
			QRY->SEGMENTO		+";"+;
			QRY->UF				+";"+;
			QRY->MUNICIPIO		+";"+;
			QRY->ANO			+";"+;
			QRY->MES			+";"+;
			QRY->NOME_REPRES	+";"+;
			QRY->GRUPO_CLIENTE	+";"+;
			QRY->NOME_CLIENTE	+";"+;
			QRY->STATUS			+";"+;
			QRY->CATEGORIA		+";"+;
			QRY->ACABAMENTO		+";"+;
			QRY->PACOTE			+";"+;
			QRY->PACOTE2		+";"+;
			QRY->PACOTE3		+";"+;
			QRY->FORMATO		+";"+;
			QRY->TIPOLINHA		+";"+;
			QRY->DESCRICAOLINHA	+";"+;
			QRY->PRODUTO		+";"+;
			QRY->CLASSE			+";"+;
			Transform( QRY->FATLQTD, "@E 999,999,999.99999" )  +";"+;
			Transform( QRY->FATLIQ, "@E 999,999,999.99999" ) +"; "+;
			QRY->EMPRESA_ORIGEM ;
			)
			fWrite(nHandle, cCrLf ) // Pula linha
			dbSelectArea('QRY')
			dbSkip()
		End 

		FClose(nHandle)
		QRY->(dbCloseArea()) 
	EndIf
Return
//------------------------------------------------------------------------------------