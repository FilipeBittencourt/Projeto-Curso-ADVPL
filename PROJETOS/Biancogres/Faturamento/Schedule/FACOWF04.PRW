#include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FACOWF04	�Autor  �Artur Antunes       � Data � 25/10/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     � Job para Workflow de clientes sem contas de   			  ���
��			   previs�o e pprovis�o cadastradas							  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FACOWF04()
	Local lRpc := Type("oMainWnd") == "U"

	If lRpc
		RESET ENVIRONMENT      
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
	EndIf
	Conout("FACOWF04 - Processando Workflow de clientes que nao possuem contas de Previsao ou Provisao")
	fProcessWF()
	Conout("FACOWF04 - Fim do Processando do Workflow")
Return


static function fProcessWF()

	Local aAreaX   		:= GetArea() 
	local nContReg 		:= 0
	local nTotReg		:= 6
	local cDataDia		:= dtos(date())
	local aAux	  		:= {}
	local cTab1	   		:= GetNextAlias()
	local oFWExcel 		:= Nil
	local cDir 			:= "\P10\DOCTEMP\"
	local cFile 	 	:= "CLIENTES_SEM_CONTAS-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	local cWorkSheet 	:= 'Clientes' 
	local cTable 	 	:= "Clientes com contratos ativos que n�o possuem contas de Previs�o ou Provis�o"
	local cAliasTab  	:= ''
	local cTempEmp		:= ''

	Conout("FACOWF04 - buscando Dados")

	IF PZ5->(FieldPos("PZ5_REDE")) > 0

		BeginSQL Alias cTab1 
		%NOPARSER%

		SELECT 
		XEMPR =
		(CASE 
		WHEN X.XEMP = '01'
		THEN 'BIANCOGRES'
		WHEN X.XEMP = '05'
		THEN 'INCESA'
		WHEN X.XEMP = '07'
		THEN 'LM' END),
		X.*  
		FROM ( 
		SELECT
		XTPGRPCLI  = CASE WHEN PZ5_TIPCLI = '1' THEN 'CLIENTE' WHEN PZ5_TIPCLI = '2' THEN 'GRUPO' ELSE 'REDE' END,
		XCODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA WHEN PZ5_TIPCLI = '2' THEN ACY_GRPVEN ELSE PZ5_REDE END,
		XNOME      = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME WHEN PZ5_TIPCLI = '2' THEN ACY_DESCRI ELSE (SELECT TOP 1 Z79_DESCR FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
		XCONTAPRO  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRO ELSE (SELECT TOP 1 Z79_YCTPRO FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
		XCONTAPRE  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRE WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRE ELSE '' END,
		TPCONTR    = 'ACORDO OBJETIVO',
		XEMP       = '01',
		XCODCTR    = PZ5.PZ5_CODIGO,
		XDTINI     = PZ6.PZ6_PERINI,
		XDTFIM     = PZ6.PZ6_PERFIM
		FROM PZ6010 (NOLOCK) PZ6
		JOIN PZ5010 (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND PZ5.PZ5_STATUS = 'S'
		AND PZ5.PZ5_PROVER = 'S'
		AND  PZ5.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN PZ6.PZ6_PERINI AND PZ6.PZ6_PERFIM 
		AND PZ6.D_E_L_E_T_ = ''

		UNION ALL		

		SELECT
		XTPGRPCLI  = CASE WHEN PZ5_TIPCLI = '1' THEN 'CLIENTE' WHEN PZ5_TIPCLI = '2' THEN 'GRUPO' ELSE 'REDE' END,
		XCODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA WHEN PZ5_TIPCLI = '2' THEN ACY_GRPVEN ELSE PZ5_REDE END,
		XNOME      = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME WHEN PZ5_TIPCLI = '2' THEN ACY_DESCRI ELSE (SELECT TOP 1 Z79_DESCR FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
		XCONTAPRO  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRO ELSE (SELECT TOP 1 Z79_YCTPRO FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
		XCONTAPRE  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRE WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRE ELSE '' END,
		TPCONTR    = 'ACORDO OBJETIVO',
		XEMP       = '05',
		XCODCTR    = PZ5.PZ5_CODIGO,
		XDTINI     = PZ6.PZ6_PERINI,
		XDTFIM     = PZ6.PZ6_PERFIM
		FROM PZ6050 (NOLOCK) PZ6
		JOIN PZ5050 (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND  PZ5.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN PZ6.PZ6_PERINI AND PZ6.PZ6_PERFIM 
		AND PZ6.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '01',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8010 (NOLOCK) ZA8
		JOIN ZA7010 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '05',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8050 (NOLOCK) ZA8
		JOIN ZA7050 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '07',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8070 (NOLOCK) ZA8
		JOIN ZA7070 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''
		) X
		WHERE (X.XCONTAPRO IS NULL OR X.XCONTAPRO = '')
		OR
		(X.XCONTAPRE IS NULL OR X.XCONTAPRE = '')
		ORDER BY X.XTPGRPCLI,X.XCODCLIGRP

		EndSQL

	ELSE

		BeginSQL Alias cTab1 
		%NOPARSER%

		SELECT 
		XEMPR =
		(CASE 
		WHEN X.XEMP = '01'
		THEN 'BIANCOGRES'
		WHEN X.XEMP = '05'
		THEN 'INCESA'
		WHEN X.XEMP = '07'
		THEN 'LM' END),
		X.*  
		FROM ( 
		SELECT
		XTPGRPCLI  = CASE WHEN PZ5_TIPCLI = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'ACORDO OBJETIVO',
		XEMP       = '01',
		XCODCTR    = PZ5.PZ5_CODIGO,
		XDTINI     = PZ6.PZ6_PERINI,
		XDTFIM     = PZ6.PZ6_PERFIM
		FROM PZ6010 (NOLOCK) PZ6
		JOIN PZ5010 (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND PZ5.PZ5_STATUS = 'S'
		AND PZ5.PZ5_PROVER = 'S'
		AND  PZ5.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN PZ6.PZ6_PERINI AND PZ6.PZ6_PERFIM 
		AND PZ6.D_E_L_E_T_ = ''

		UNION ALL		

		SELECT
		XTPGRPCLI  = CASE WHEN PZ5_TIPCLI = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'ACORDO OBJETIVO',
		XEMP       = '05',
		XCODCTR    = PZ5.PZ5_CODIGO,
		XDTINI     = PZ6.PZ6_PERINI,
		XDTFIM     = PZ6.PZ6_PERFIM
		FROM PZ6050 (NOLOCK) PZ6
		JOIN PZ5050 (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND  PZ5.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN PZ6.PZ6_PERINI AND PZ6.PZ6_PERFIM 
		AND PZ6.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '01',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8010 (NOLOCK) ZA8
		JOIN ZA7010 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '05',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8050 (NOLOCK) ZA8
		JOIN ZA7050 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''

		UNION ALL

		SELECT 
		XTPGRPCLI  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN 'CLIENTE' ELSE 'GRUPO' END,
		XCODCLIGRP = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		XNOME      = CASE WHEN ZA7.ZA7_TIPO = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		XCONTAPRO  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END,
		XCONTAPRE  = CASE WHEN ZA7.ZA7_TIPO = '1' THEN SA1.A1_YCTAPRE ELSE ACY.ACY_YCTPRE END,
		TPCONTR    = 'VERBAS',
		XEMP       = '07',
		XCODCTR    = ZA8.ZA8_CODIGO,
		XDTINI     = ZA8.ZA8_DATINI,
		XDTFIM     = ZA8.ZA8_DATFIM
		FROM ZA8070 (NOLOCK) ZA8
		JOIN ZA7070 (NOLOCK) ZA7 
		ON ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO
		AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL 
		AND ZA7.ZA7_STATUS = 'A' 
		AND  ZA7.D_E_L_E_T_ = '' 
		LEFT JOIN SA1010 (NOLOCK) SA1 	
		ON  SA1.A1_COD = ZA7.ZA7_CODCLI	 
		AND SA1.A1_LOJA = ZA7.ZA7_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN ACY010 (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = ZA7.ZA7_GRPCLI
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE %exp:cDataDia%  BETWEEN ZA8.ZA8_DATINI AND ZA8.ZA8_DATFIM
		AND ZA8.D_E_L_E_T_ = ''
		) X
		WHERE (X.XCONTAPRO IS NULL OR X.XCONTAPRO = '')
		OR
		(X.XCONTAPRE IS NULL OR X.XCONTAPRE = '')
		ORDER BY X.XTPGRPCLI,X.XCODCLIGRP

		EndSQL

	ENDIF

	(cTab1)->(DbGoTop())  

	If (cTab1)->(Eof())
		Conout("FACOWF04 - Nenhum Registro encontrado para o Workflow")
		RestArea(aAreaX)
		return	
	else

		Conout("FACOWF04 - Criando anexo")
		oFWExcel := FWMsExcel():New()
		oFWExcel:AddWorkSheet(cWorkSheet)
		oFWExcel:AddTable(cWorkSheet, cTable)

		oFWExcel:AddColumn(cWorkSheet, cTable, "TIPO CLI/GRP" 	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CODIGO " 	  	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "NOME "			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CTA PROVIS�O"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CTA PREVIS�O"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "TIPO CONTRATO"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "EMPRESA FAT"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CODIGO CTR"		, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "PERIODO DE"		, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "PERIODO AT�"	, 1, 1)

		while !(cTab1)->(Eof())

			aAux     := {}
			AAdd(aAux, (cTab1)->XTPGRPCLI  			)
			AAdd(aAux, (cTab1)->XCODCLIGRP 			)
			AAdd(aAux, (cTab1)->XNOME				)
			AAdd(aAux, (cTab1)->XCONTAPRO			)
			AAdd(aAux, (cTab1)->XCONTAPRE			)
			AAdd(aAux, (cTab1)->TPCONTR				)
			AAdd(aAux, (cTab1)->XEMPR				)
			AAdd(aAux, (cTab1)->XCODCTR				)
			AAdd(aAux, DTOC(STOD((cTab1)->XDTINI)) 	)
			AAdd(aAux, DTOC(STOD((cTab1)->XDTFIM)) 	)

			oFWExcel:AddRow(cWorkSheet, cTable,	aAux)
			(cTab1)->(DbSkip())
		end

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cDir+cFile)
		oFWExcel:DeActivate()

		SendMail(cDir + cFile)

	endif

	RestArea(aAreaX)
return



Static Function SendMail(_cArquivo)

	Local cTo      := U_EmailWF("FACOWF04",CEMPANT)
	local lRet	   := .F.
	local cSubject := "Clientes com contratos ativos que n�o possuem contas de Previs�o ou Provis�o"
	local cMens	   := "Segue (Anexo) planilha de Clientes com contratos ativos, que n�o possuem contas de Previs�o ou Provis�o."

	Conout("FACOWF04 - Enviando e-mail")
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	if !Empty(cTo)
		lRet := U_BIAEnvMail(, cTo, cSubject, cMens, "", _cArquivo)
	endif

	if lRet
		Conout("FACOWF04 - e-mail enviado com sucesso")
	endif
Return 


User Function XWF4TEST()
	STARTJOB("U_FACOWF04",GetEnvServer(),.F.,cEmpAnt,cFilAnt)
return

