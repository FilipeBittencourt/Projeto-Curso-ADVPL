#include "rwmake.ch"
#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DIRECTRY.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA282
Empresa   := Biancogres Ceramica S.A.
Data      := 17/02/12
Uso       := Ponto Eletrônico
Aplicação := Rotina de Importação Automática do Ponto
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA282()

	LOCAL xv_Emps
	Local _cTo := ""
	Local _cAlias :=GetNextAlias()
	Local caminho := ""
	Local arquivo := ""
	Local _nI2
	Local _nI
	Local bgk
	Local x
	Local qax

	ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Inicio do processamento da rotina BIA282")

	xv_Emps    := U_BAGtEmpr("01")

	ConOut("DATA/HORA: "+dtos(Date())+" - Iniciando Processo BIA282 - Capturadas as empresas para processamento...")

	//Inicializa o ambiente
	RPCSetType(3)
	RPCSetEnv("01", "01", "", "", "", "", {})

	// Manipula arquivos para a perfeita importação dos dados
	ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Iniciando Processo BIA282 - Copia de Arquivos do Ponto.")
	aLOG := {}
	AADD(  aLOG , {"BATCH"    ,  "C" ,  50   , 0} )
	aLOG := CriaTrab(aLOG,.T.)
	dbUseArea(.T.,,aLOG,"aLOG")

	// Diretório onde ficam armazenados os arquivos de leitura
	// dos relógios de Ponto configurados no Protheus.
	fw_DrPro := "\p10\ponto\"
	// Deleta os arquivos correntes
	_aTRANS := {}	

	// Diretório de integração com o Suricato. Recebe os dados a
	// partir de um Job que roda no servidor ZEUS
	fw_DrSur := "\p10\ponto\AFD\"

	// OS 7608-18 Facile - Marcelo Sousa - Acerto para que no momento da execução o sistema trate se algum arquivo 
	// está faltando na integração com o suricato. Caso esteja, é enviado um e-mail para o RH informando que o mesmo não existe.
	Enter := CHR(13)+CHR(10)
	cFalta := 0
	_cIMPORT2 := ""
	_aTRANS2 := Directory(fw_DrSur+"AFD??????"+dtos(dDataBase)+"??????.txt")

	// Montando corpo do e-mail para caso haja falta de arquivos na pasta "fw_DrSur"
	cRet := ""
	cRet += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	cRet += '<head> '
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cRet += '    <title>Workflow</title> '
	cRet += '    <style type="text/css"> '        
	cRet += '        <!-- ' 		
	cRet += '        .styleDiv{ margin: auto; width:80%; font: 12px Arial, Helvetica, sans-serif; } '
	cRet += '        .styleTable{ border:0; cellpadding:3; cellspacing:2; width:100%; } '		
	cRet += '        .styleTableCabecalho{ background: #fff; color: #000000; font: 14px Arial, Helvetica, sans-serif;  font-weight: bold; } '        
	cRet += '        .styleCabecalho{ background: #0c2c65; color: #ffffff; font: 12px Arial, Helvetica, sans-serif; font-weight: bold; padding: 5px; } '		
	cRet += '        .styleLinha{ background: #f6f6f6; color: #747474; font: 11px Arial, Helvetica, sans-serif; padding: 5px; } '        
	cRet += '        .styleNumerico{ text-align: right;} '
	cRet += '        .styleRodape{ background: #CFCFCF;color: #666666;font: 12px Arial, Helvetica, sans-serif;font-weight: bold;text-align: right;padding: 5px; } '		
	cRet += '        .styleLabel{ color:#0c2c65; } '		
	cRet += '        .styleValor{ color:#747474; } '        
	cRet += '        --> '   
	cRet += '    </style> '
	cRet += '</head> '
	cRet += '<body> '
	cRet += '    <div class="styleDiv"> '	
	cRet += '        <table cellpadding="0" cellspacing="0" width="100%"> '
	cRet += '            <tbody> '
	cRet += '               <tr class="styleTableCabecalho"> '
	cRet += '                    <td colspan="2" style="text-align:center;"> '
	cRet += '                    		<span class="styleLabel">RELATÓRIO - FALTA DE ARQUIVOS ENVIADOS PELO SURICATO</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                    		<span class="styleLabel">Empresa:</span> '
	cRet += '                        <span class="styleValor">'+ Capital(FWEmpName(cEmpAnt)) +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                        <span class="styleLabel">Data:</span> '
	cRet += '                        <span class="styleValor">'+ dToC(dDataBase-1) +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '            </tbody> '
	cRet += '        </table> '
	cRet += '        <br /> '
	cRet += '        <br /> '	
	cRet += '        </tr> '
	cRet += '        <tr> '

	// Executando regra para ler se o sistema possui os arquivos do Suricato

	ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Processo BIA282 - Verificando se arquivos Suricato existem.")

	For _nI2 := 1 To Len(_aTRANS2)
		_cIMPORT2 += fw_DrPro + _aTRANS2[_nI2][1]+ '|'
	Next _nI2		

	BeginSql Alias _cAlias
		SELECT  RTRIM(LTRIM(P0_RELOGIO)) AS P0_RELOGIO, RTRIM(LTRIM(P0_DESC)) AS P0_DESC,RTRIM(LTRIM(REPLACE(UPPER(P0_ARQUIVO),'.TXT',''))) AS P0_ARQUIVO
		FROM %TABLE:SP0% SP0
		WHERE   P0_FILIAL = %XFILIAL:SP0%
		AND P0_MSBLQL IN ('','2')
		AND  P0_ARQUIVO NOT LIKE '%REFEITORIO%'
		AND   SP0.%NotDel%
		ORDER BY P0_RELOGIO
	EndSql

	(_cAlias)->(dbGoTop())

	While !(_cAlias)->(Eof())
		caminho := trim((_cAlias)->P0_ARQUIVO)
		IF !(caminho $ UPPER(_cIMPORT2))
			arquivo := REPLACE(caminho,upper(fw_DrPro),'')
			cRet += '<h1 class="styleLinha" width="500" scope="col"> Arquivo: ' +fw_DrSur+ arquivo +dtos(dDataBase)+ '.txt</h1>'
			cRet += '<h1 class="styleLinha" width="500" scope="col"> Relógio: ' + (_cAlias)->P0_RELOGIO + ' - ' + (_cAlias)->P0_DESC + '</h1>'
			cRet += '<br /> '
			cFalta := 1	
		end if
		(_cAlias)->(dbSkip())
	end

	// Envia e-mail caso não encontre algum arquivo.
	IF cFalta > 0

		cRet += '        </tr> '
		cRet += '        <br /> '
		cRet += '        <br /> '
		cRet += '        <p>Sem mais,</p> '
		cRet += '        <p><b>Departamento Pessoal</b></p> '
		cRet += '        <p>by BIA282</p> '
		cRet += '    </div> '
		cRet += '</body> '
		cRet += '</html> '

		ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Processo BIA282 - Enviando e-mail falta arquivos Suricato.")

		aArea := GetArea() 
		_cTo :=  U_EmailWF('BIA282',cEmpAnt) 
		RestArea(aArea)

		U_BIAEnvMail(, _cTo, "Arquivos Faltantes Suricato", cRet, )

	ENDIF
	// ------------------------------------------------------------------------------------------------------------------------

	// Grava arquivos atualizados

	U_B282RunSrv()

	/*
	_aTRANS := {}
	_aTRANS := Directory(fw_DrSur+"AFD??????"+dtos(dDataBase)+"??????.txt")
	For _nI := 1 To Len(_aTRANS)
	_cIMPORT := _aTRANS[_nI][1]
	CpyS2T(fw_DrSur+_cIMPORT, fw_DrPro+Substr(_cIMPORT,1,9)+".txt")
	Next
	*/

	//Finaliza o ambiente criado
	ConOut("DATA/HORA: "+dtos(Date())+" - Finalizando Processo BIA282 - Copia de Arquivos do Ponto.")
	RESET ENVIRONMENT

	For x := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		RPCSetEnv(xv_Emps[x,1],xv_Emps[x,2],"","","","",{})

		// Necessário voltar um dia no tempo para resolver a virada de período 11/xx até 10/xx
		// Implementado em 05/12/18
		dDataBase := dDataBase - 1

		kgbDtIni := dDataBase
		kgbDtFim := dDataBase
		kgbTpPrc := "1"

		// Incluído loop em 26/07/16 para tentar resolver um problema de geração de evento intrajornada (128) indevidamente. Por Marcos Alberto Soprani
		For bgk := 1 to 2 

			If bgk == 1                               // Leitura 
				//**********************************************
				//kgbDtIni := dDataBase-1
				//kgbDtFim := dDataBase
				kgbTpPrc := "1"
			Else                                  // Apontamento 
				//**********************************************
				//kgbDtIni := dDataBase-1
				//kgbDtFim := dDataBase-1
				kgbTpPrc := "2"
			EndIf

			xRelogT := ""
			yRelogA := ""
			If xv_Emps[x,1] == "01"
				xRelogT := "B01"
				yRelogA := "IZZ"
			EndIf

			ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Iniciando Processo BIA282 " + kgbTpPrc + " " + xv_Emps[x,1] )

			// Ajustar o parametro para Leitura/Apontamento. Isto é necessário para que o sistema importe automaticamente por dia
			dbSelectArea("SX1")
			dbSetOrder(1)
			dbSeek("PNM010    01") // De Filial
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "  "
			MsUnLock()
			dbSeek("PNM010    02") // Ate Filial
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "ZZ"
			MsUnLock()
			dbSeek("PNM010    03") // De CC
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "         "
			MsUnLock()
			dbSeek("PNM010    04") // até CC
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "ZZZZZZZZZ"
			MsUnLock()
			dbSeek("PNM010    05") // De Turno
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "   "
			MsUnLock()
			dbSeek("PNM010    06") // Ate Turno
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "ZZZ"
			MsUnLock()
			dbSeek("PNM010    07") // De Matricula
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "      "
			MsUnLock()
			dbSeek("PNM010    08") // Ate Matricual
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "ZZZZZZ"
			MsUnLock()
			dbSeek("PNM010    09") // De Nome
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "                              "
			MsUnLock()
			dbSeek("PNM010    10") // Ate Nome
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			MsUnLock()

			dbSeek("PNM010    11") // De Relogio
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := xRelogT
			MsUnLock()
			dbSeek("PNM010    12") // Ate Relogio
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := yRelogA
			MsUnLock()

			dbSeek("PNM010    13") // De Data
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := dtos(kgbDtIni)
			MsUnLock()
			dbSeek("PNM010    14") // Ate Data
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := dtos(kgbDtFim)
			MsUnLock()

			// Regra de Apontamento
			dbSeek("PNM010    15") // De Regra
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "07"
			MsUnLock()
			dbSeek("PNM010    16") // Ate Regra
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "09"
			MsUnLock()
			dbSeek("PNM010    17") // Processamento? 1.Leit; 2.Apont; 3.Ambos
			RecLock("SX1",.F.)
			SX1->X1_CNT01  := kgbTpPrc
			SX1->X1_PRESEL := Val(kgbTpPrc)
			MsUnLock()
			dbSeek("PNM010    18") // Leitura Apontamento? 1.Marcações
			RecLock("SX1",.F.)
			SX1->X1_CNT01  := "1"
			SX1->X1_PRESEL := 1
			MsUnLock()
			dbSeek("PNM010    19") // Reprocessar? 1.Marcações
			RecLock("SX1",.F.)
			SX1->X1_CNT01  := "1"
			SX1->X1_PRESEL := 1
			MsUnLock()
			dbSeek("PNM010    20") // Ler a parti do ? 2.Cod_Relogio
			RecLock("SX1",.F.)
			SX1->X1_CNT01  := "2"
			SX1->X1_PRESEL := 2
			MsUnLock()
			dbSeek("PNM010    21") // Categorias?
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "EM*************                                             "
			MsUnLock()
			dbSeek("PNM010    22") // Situações a Gerar
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := " ADFT                                                       "
			MsUnLock()

			// Rotina de Leitura/Apontamento Automatica
			Ponm010(.T.            ,; // lWhorkFlow      - Define que a chamada está sendo Efetuada Atraves do WorkFlow
			.T.                    ,; // lUserDefParam   - Verifica Se Devera Considerar os Parametros Pre-Definidos Pelo Usuario
			.F.                    ,; // lLimitaDataFim  - Verifica Se Devera Limitar a Data Fim a Menor Data entre a DataBase e o Periodo Final de Apontamento
			"01"                   ,; // cFil            - Filial a ser processada
			.T.                    ,; // lProcFilial     - Processo por Filial
			.T.                    ,; // lApontaNaoLidas - Se Aponta as Marcacoes para as Filiais nao Lidas
			.T.                    ,; // lForceReaponta  - Forcar o Reapontamento das Marcacoes
			)

			ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Finalizando Processo BIA282 " + xv_Emps[x,1] )

		Next bgk

		//Finaliza o ambiente criado
		RESET ENVIRONMENT

	Next x

	//  Implementado em 17/12/13 tratamento para ser chamado no final do processo de importação. Com isto, independente de quanto tempo leve para
	// importar, ao final será gerado o relatório
	//ConOut("BIA282 - Concluído processamento de leitura e apontamento... vai iniciar o WF BIA284")
	//U_BIA284() //Ticket 24702 - solicitação para parar os workflows relacionados a ponto eletronico do Protheus
	ConOut("BIA282 - Paralização do WF BIA284")
	//ConOut("BIA282 - Concluído processamento do WF BIA284")

	// Em 19/07/16, Incluindo chamada de rotina BIAF040 no final da leitura e apontamento diários do ponto, por Marcos Alberto Soprani
	ConOut("BIA282 - Concluído envio do WF de Ocorrências de Registro de Ponto... vai iniciar o WF BIAF040")
	qaEmprs    := U_BAGtEmpr("01")
	RESET ENVIRONMENT
	For qax := 1 to Len(qaEmprs)
		RPCSetType(3)
		RPCSetEnv(qaEmprs[qax,1],qaEmprs[qax,2],"","","","",{})
		//Ticket 24702 
		//U_BIAF040()
		U_BIA627()
		RESET ENVIRONMENT
	Next qax

	ConOut("BIA282 - Concluído processamento do WF BIAF040")

	ConOut("DATA/HORA: "+dtos(Date())+" "+Time()+" - Fim do processamento da rotina BIA282")

Return

User Function BA282JOB()

	cEmpAnt := "01"
	cFilAnt := "01"
	STARTJOB("U_BIA282",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

Return

User Function B282RunSrv()

	Local cCommand  := "" 
	Local cPath     := "" 
	Local lWait     := .F. 

	cCommand  := "D:\copy_afd.bat" 
	cPath     := "D:\" 

	Qout("B282RunSrv -:>^<:- Ini processamento... Data | Hora: " + dtoc(Date()) + " | " + Time() )
	WaitRunSrv( @cCommand , @lWait , @cPath )
	Qout("B282RunSrv -:>^<:- Fim processamento... Data | Hora: " + dtoc(Date()) + " | " + Time() )

Return
