#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#include "RWMAKE.CH"

User Function BIARO005()
	
	Local xv_Emps := U_BAGtEmpr("01_05_07_12_13_") // --> PERGUNTAR QUAIS EMPRESAS PODERÃO SER APROVAÇÃO DE NF Serviço
	Local x
	
	For x := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)		
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])	
		ConOut("Hora: "+TIME()+" - Iniciando a Integração PROTHEUS x BIZAGI para o Processo Aprovação de NF de Serviço - " + xv_Emps[x,1])		
		Processa({|| BIARO005() })		
		ConOut("Hora: "+TIME()+" - Finalizando a Integração PROTHEUS x BIZAGI para o Processo Aprovação de NF de Serviço - " + xv_Emps[x,1])	
		//Finaliza o ambiente criado
		RpcClearEnv()

	Next

Return()

//--------------------------------------------------------------------------
// Executa a função que contém as regras de integração do Processo Aprovação de NF de Serviço
//--------------------------------------------------------------------------
Static Function BIARO005()
			
		Local cFlagBZ := ""
		Local cProcBZ := ""		
		Local cListaRecno := ""		
		Local cPref := ""		
		Local _lRet := .T.				
		Local cSQL := ""
		Local cUpdSQL := ""

		Private cNota := ""		
		Private cFornec := ""		
		Private cLoja := ""
		
		cSQL += "SELECT "
		cSQL += "ID "
		cSQL += ",DATA_INTEGRACAO_BIZAGI "
		cSQL += ",DATA_INTEGRACAO_PROTHEUS "
		cSQL += ",STATUS "
		cSQL += ",DADOS_ENTRADA "
		cSQL += ",DADOS_RETORNO "
		cSQL += ",PROCESSO_BIZAGI "
		cSQL += ",RECNO_RETORNO "
		cSQL += ",EMPRESA "
		cSQL += ",FILIAL "
		cSQL += "FROM BZINTEGRACAO "
		cSQL += "WHERE STATUS IN ('IB') "
		cSQL += "AND PROCESSO_NOME = 'ASP' "
		cSQL += "AND EMPRESA = '" + cEmpAnt + "' "
		cSQL += "AND FILIAL = '" + cFilAnt + "' "
		cSQL += "AND EM_PROCESSAMENTO = ''"
				
		GUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'cSQL',.F.,.T.)
		dbSelectArea("cSQL")
		dbGoTop()
		ProcRegua(RecCount())
		
		While !Eof()		
			
			BEGIN TRANSACTION
			
			//999999;N;N;000003;;[201A172|4|1000.0000];1000;1000;C;004976;2019-04-12 12:00:00;Administrador do Portal;Victor Bragatto Luchi;
			RecRetorno(cSQL->DADOS_RETORNO)
						
			cProcBZ := cSQL->PROCESSO_BIZAGI
			cFlagBZ := 'S'
												
			If !DbSeek(xFilial("SD1")+cNota+cPref+cFornec+cLoja,.T.)
			
				MsgAlert("Nao encontrou a registro referente a esta Nota Fiscal.",)
				Return
				
			EndIf
			
			If !RecLock("SD1",.F.)
			
				MsgAlert("Registro em uso por outra estação. Aguarde um instante e tente novamente.")
				Return
				
			Else			
				
				SD1->D1_YFLAGBZ := cFlagBZ
				SD1->D1_YPROCBZ := cProcBZ
				
				cUpdSQL := " UPDATE BZINTEGRACAO SET "
				cUpdSQL += "  EM_PROCESSAMENTO = 'S', STATUS = 'AP', RECNO_RETORNO = '" + cListaRecno + '" 
				cUpdSQL += "WHERE ID = " + cSQL->ID
				
				If TcSqlExec(cUpdSQL) <> 0
					_lRet := .F.
				EndIf			
							
			EndIf
			
			dbSelectArea("cSQL")
			dbSkip()	
			
			END TRANSACTION

		End	

Return

Static Function RecRetorno(cRetorno)
	
	aString := strtokarr (cRetorno, ";")

Return