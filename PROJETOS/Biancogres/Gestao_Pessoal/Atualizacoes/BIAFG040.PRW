#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User Function BIAFG040()


Local aArea 	:= GetArea()

	If !ValidPerg()
		Return
	EndIf

//Variaveis Private da Rotina
Private	cCadastro     := "Controle de Eventos - Período: " + TRANSFORM(MV_PAR01,"@R 9999/99") //Define Nome da Tela

Private _cData	:=	Dtos(LastDay(StoD(MV_PAR01 + "01")))
Private _cDtAnt	:=	Dtos(DaySub(FirstDate(Stod(_cData)),1))

SRA->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define procedures para cada botao                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina   := { 	{"Pesquisar"    	,"AxPesqui"      		,0,1},;
				{"Visualizar"     	,"U_BFG40V"		      	,0,2},;
				{"Manutenção"      	,"U_BFG40A"      		,0,4},;
				{"Relatório"      	,"U_BIAFG042"      		,0,5},;
				{"Processar"      	,"U_BFG40CAL"      		,0,6}}
				
				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela de browse e executra mBrowse                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SRA->(MBrowse(6,1,22,75,"SRA",,,,,,/*aCores*/))

//Recupera area de trabalho
RestArea(aArea)
Return  

User Function BFG40V(cAlias, nReg, nOpc)

Return U_BFG40TL(cAlias, nReg, nOpc,.F.)

User Function BFG40A(cAlias, nReg, nOpc)

Return U_BFG40TL(cAlias, nReg, nOpc,.T.)


User Function BFG40TL(cAlias, nReg, nOpc, lAlter)

	Private _nSalIni	:=	fInsSaldo()
	Private _nSalFim	:=	fFinSaldo()
	
	Private oDlgSld	:=	Nil		//Dialog
	Private oGpSld		:=	Nil		//Grupo

	Private oSyDsSld	:=	Nil
	Private cSyDsSld	:=	SPACE(250)
	Private	oFntSld		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)

	Private oEncVend	:=	Nil		//GetDados Vendedor
	Private oGdCred	:=	Nil		//Getdados de Indicadores Automaticos
	Private oGdDeb	:=	Nil		//Getdados de Indicadores Automaticos

	Private aSize := MsAdvSize(.F.) //Sem Enchoice
	
	DEFAULT lAlter	:=	.F.
	
	Private lAltGd	:=	lAlter
	
	aObjects := {}
	// Quantos mais objetos, mais o Method MsObjSize Trabalha para subdividir
	//                 | Fracionamento Horizontal
	//                      | Fracionamento Vertical

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos1                                         |
	+-------------------------------------------------------------------------*/
	AAdd( aObjects, { 100, 060, .T., .T. } )
	AAdd( aObjects, { 100, 325, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )
	Alert(MV_PAR01)
	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos2                                         |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aSize2 := aClone( aPosObj1[2] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )

	DEFINE MSDIALOG oDlgSld TITLE "Controle de Eventos" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL STYLE Nor( WS_VISIBLE, WS_POPUP)

	// Painel Vendedores
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpSld TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Período: " OF oDlgSld COLOR 0, 16777215 PIXEL
	EnChoice(cAlias, nReg, 2,,,,{"RA_MAT","RA_NOME","NOUSER"},{ aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5},,,,,,,,,,,.T.)

	// Painel Créditos
	@ aPosObj1[2][1], aPosObj1[2][2] GROUP oGpSld TO aPosObj1[2][3], aPosObj1[2][4] PROMPT "Operações..." OF oDlgSld COLOR 0, 16777215 PIXEL
	FWMsgRun(, {|| fGeraCrd()}, "Processando", "Aguarde... Carregando dados (Operações)")

	cSyDsSld	:=	"SALDO INICIAL: R$" + Alltrim(TransForm(_nSalIni,"@E 999,999,999.99")) + SPACE(20) + "SALDO FINAL: R$" + Alltrim(TRANSFORM(_nSalFim,"@E 999,999,999.99")) 

	// Painel Produto(Rodapé)
	@ aPosObj1[3][1], aPosObj1[3][2] GROUP oGpSld TO aPosObj1[3][3], aPosObj1[3][4] PROMPT "Sumário..." OF oDlgSld COLOR 0, 16777215 PIXEL
	@ aPosObj1[3][1]+10, aPosObj1[3][2]+05 SAY oSyDsSld PROMPT cSyDsSld SIZE 446, 011 OF oDlgSld FONT oFntSld COLORS 0, 16777215 PIXEL

	@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Fechar" SIZE 037, 012 OF oDlgSld ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgSld:End()) PIXEL

	ACTIVATE MSDIALOG oDlgSld CENTERED

Return

Static Function fGeraCrd(nOpc)

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	aAdd(_aHeader,{"Data"         ,"DATA" ,"@!"               , 8   , 0,,, "D",, })      	// 1
	aAdd(_aHeader,{"Operação"       	,"OPERAC" ,"@!"               , 1   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Indicador"       	,"INDIC" ,"@!"               , 20   , 0,,, "C",, })      	// 3
	aAdd(_aHeader,{"Valor"        	,"VALOR" ,"@E 999,999,999.99"               , 12   , 2,,, "N",, })      	// 4
	aAdd(_aHeader,{"Situação"       ,"SITUA" ,"@!"               , 75   , 0,,, "C",, })      	// 6
	aAdd(_aHeader,{"Observação"       ,"OBSER" ,"@!"               , 200   , 0,,, "C",, })      	// 6

	_aCols	:=	fGeraCols()
	
	aSort(_aCols,,,{|x,y| Dtos(x[1]) + x[2] < Dtos(y[1]) + y[2] })

	oGdCred	:=	MsNewGetDados():New( aPosObj1[2][1] + 10, aPosObj1[2][2] + 5, aPosObj1[2][3] - 5, aPosObj1[2][4] - 5, Iif(lAltGd,GD_UPDATE,0), "AllwaysTrue", "AllwaysTrue", "", {"OBSER"},, 999, 'U_BFG40ALT', "", "AllwaysTrue", oDlgSld, _aHeader, _aCols, { ||  } )

	If Len(_aCols) == 0
		oGdCred:Hide()
	EndIF

Return


Static Function fCalcSI()

	Local _nSaldo	:=	0
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
		SELECT ISNULL(SUM(CASE WHEN RD_PD = '124' THEN RD_VALOR ELSE RD_VALOR * -1 END),0) RD_VALOR
		FROM %TABLE:SRD% SRD
		WHERE RD_PD IN ('489','124')
			AND RD_PERIODO < %Exp:MV_PAR01%
			AND SRD.%NotDel%
			AND SRD.RD_MAT = %Exp:SRA->RA_MAT%
	EndSql
	
	_nSaldo	:=	(_cAlias)->RD_VALOR
	
	(_cAlias)->(DbCloseArea())
Return _nSaldo


Static Function ValidPerg()

	local cLoad	    := "BIAFG040" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 :=	SPACE(6)

	aAdd( aPergs ,{1,"Ano/Mês " 	  				,MV_PAR01 ,"@R 9999/99"  ,"U_BFG40VLD()",''  ,'.T.',50,.T.})

	If ParamBox(aPergs ,"Controle de Eventos",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf

Return lRet

User Function BFG40VLD()

	Local _lret	:=	.T.

	If MV_PAR01 < '201801'
		MsgInfo("Somente poderá ser utilizado período igual ou superior a Janeiro de 2018!")
		_lret	:=	.F.
	EndIf

Return _lRet

User Function BFG40CAL()

	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
		SELECT *
		FROM RCH010
		WHERE RCH_FILIAL = %XFILIAL:RCH%
			AND RCH_PER = %Exp:MV_PAR01%
			AND RCH_PROCES = '00001'
			AND RCH_ROTEIR = 'FOL'
			AND %NotDel%
	EndSql

	BEGIN TRANSACTION

		If (_cAlias)->(!EOF())
			If Empty((_cAlias)->RCH_DTFECH) //Período Aberto
				FWMsgRun(, {|| fProcA() }, "Processando", "Calculando Período Aberto")
				
			Else //Período Fechado
				FWMsgRun(, {|| fProcF() }, "Processando", "Calculando Período Fechado")
			EndIf
			FWMsgRun(, {|| fGrvSaldo() }, "Processando", "Gravando Saldos Finais")
			
		Else	
			MsgInfo("Período ainda não cadastrado!")
		EndIf

	END TRANSACTION

	(_cAlias)->(DbCloseArea())

Return


Static Function fProcA()

	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
	
		SELECT PERIODO.*
			,ISNULL(ZCE.ZCE_OBSERV, '') ZCE_OBSERV
		FROM (
			SELECT RC_FILIAL
				,RC_MAT
				,'Verba ' + RC_PD AS INDICA
				,'C' AS TPOPER
				,RC_PERIODO
				,RC_VALOR
				,COALESCE((
						SELECT TOP 1 RCM.RCM_DESCRI
						FROM %TABLE:SR8% SR8
						JOIN %TABLE:RCM% RCM ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
						WHERE SR8.R8_FILIAL = SRC.RC_FILIAL
							AND SR8.R8_MAT = SRC.RC_MAT
							AND (
								(
									%EXP:_cData% BETWEEN SR8.R8_DATAINI
										AND SR8.R8_DATAFIM
									)
								OR (%EXP:_cData% > SR8.R8_DATAINI AND  SR8.R8_DATAFIM = ' ' )
								)
							AND SR8.%NotDel%
							AND RCM.%NotDel%
						), ' ') SITUA
			FROM %TABLE:SRC% SRC
			JOIN %TABLE:SRA% SRA ON SRA.RA_FILIAL = SRC.RC_FILIAL
				AND SRC.RC_FILIAL = %XFILIAL:SRC%
				AND SRA.RA_FILIAL = %XFILIAL:SRA%
				AND SRA.RA_MAT = SRC.RC_MAT
				AND SRA.%NotDel%
			WHERE RC_PD = '124'
				AND RC_PERIODO = %Exp:MV_PAR01%
				AND SRC.%NotDel%
			
			UNION
			
			SELECT RC_FILIAL
				,RC_MAT
				,'Verba ' + RC_PD
				,'D' AS TPOPER
				,RC_PERIODO
				,RC_VALOR
				,COALESCE((
						SELECT TOP 1 RCM.RCM_DESCRI
						FROM %TABLE:SR8% SR8
						JOIN %TABLE:RCM% RCM ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
						WHERE SR8.R8_FILIAL = SRC.RC_FILIAL
							AND SR8.R8_MAT = SRC.RC_MAT
							AND (
								(
									%EXP:_cData% BETWEEN SR8.R8_DATAINI
										AND SR8.R8_DATAFIM
									)
								OR (%EXP:_cData% > SR8.R8_DATAINI AND  SR8.R8_DATAFIM = ' ' )
								)
							AND SR8.%NotDel%
							AND RCM.%NotDel%
						), ' ') SITUA
			FROM %TABLE:SRC% SRC
			JOIN %TABLE:SRA% SRA ON SRA.RA_FILIAL = SRC.RC_FILIAL
				AND SRC.RC_FILIAL = %XFILIAL:SRC%
				AND SRA.RA_FILIAL = %XFILIAL:SRA%
				AND SRA.RA_MAT = SRC.RC_MAT
				AND SRA.%NotDel%
			WHERE RC_PD = '489'
				AND RC_PERIODO = %Exp:MV_PAR01%
				AND SRC.%NotDel%
			) PERIODO
		LEFT JOIN %TABLE:ZCE% ZCE ON ZCE.ZCE_FILIAL = PERIODO.RC_FILIAL
			AND ZCE.ZCE_MAT = PERIODO.RC_MAT
			AND ZCE.ZCE_DATA = %Exp:_cData%
			AND ZCE.ZCE_INDICA = PERIODO.INDICA
			AND ZCE.%NotDel%
		ORDER BY RC_FILIAL
			,RC_MAT
			,TPOPER
			,RC_PERIODO
	
	EndSql

	_cSql	:=	"UPDATE " + RetSqlName("ZCE") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZCE_FILIAL = "+ValToSql(xFilial('ZCE'))+" AND ZCE_DATA = " + ValtoSql(_cData)
	
	TcSqlExec(_cSql)

	While (_cAlias)->(!EOF())
		RecLock("ZCE",.T.)
		ZCE->ZCE_FILIAL	:=	xFilial("ZCE")
		ZCE->ZCE_MAT	:=	(_cAlias)->RC_MAT
		ZCE->ZCE_DATA	:=	Stod(_cData)
		ZCE->ZCE_TABORI	:=	"SRC"
		ZCE->ZCE_OPERAC	:=	(_cAlias)->TPOPER
		ZCE->ZCE_INDICA	:=	(_cAlias)->INDICA
		ZCE->ZCE_VALOR	:=	Iif((_cAlias)->TPOPER == "C", (_cAlias)->RC_VALOR,(_cAlias)->RC_VALOR * -1)
		ZCE->ZCE_SITUAC	:=	(_cAlias)->SITUA
		ZCE->ZCE_OBSERV	:=	(_cAlias)->ZCE_OBSERV
		ZCE->(MsUnlock())
	
		(_cAlias)->(DbSkip())
	EndDo

Return


Static Function fProcF()

	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
	
		SELECT PERIODO.*
			,ISNULL(ZCE.ZCE_OBSERV, '') ZCE_OBSERV
		FROM (
			SELECT RD_FILIAL
				,RD_MAT
				,'Verba ' + RD_PD AS INDICA
				,'C' AS TPOPER
				,RD_PERIODO
				,RD_VALOR
				,COALESCE((
						SELECT TOP 1 RCM.RCM_DESCRI
						FROM %TABLE:SR8% SR8
						JOIN %TABLE:RCM% RCM ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
						WHERE SR8.R8_FILIAL = SRD.RD_FILIAL
							AND SR8.R8_MAT = SRD.RD_MAT
							AND (
								(
									%Exp:_cData% BETWEEN SR8.R8_DATAINI
										AND SR8.R8_DATAFIM
									)
								OR (%EXP:_cData% > SR8.R8_DATAINI AND  SR8.R8_DATAFIM = ' ' )
								)
							AND SR8.%NotDel%
							AND RCM.%NotDel%
						), ' ') SITUA
			FROM %TABLE:SRD% SRD
			JOIN %TABLE:SRA% SRA ON SRA.RA_FILIAL = SRD.RD_FILIAL
				AND SRD.RD_FILIAL = %XFILIAL:SRD%
				AND SRA.RA_FILIAL = %XFILIAL:SRA%
				AND SRA.RA_MAT = SRD.RD_MAT
				AND SRA.%NotDel%
			WHERE RD_PD = '124'
				AND RD_PERIODO = %Exp:MV_PAR01%
				AND SRD.%NotDel%
			
			UNION
			
			SELECT RD_FILIAL
				,RD_MAT
				,'Verba ' + RD_PD
				,'D' AS TPOPER
				,RD_PERIODO
				,RD_VALOR
				,COALESCE((
						SELECT TOP 1 RCM.RCM_DESCRI
						FROM %TABLE:SR8% SR8
						JOIN %TABLE:RCM% RCM ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
						WHERE SR8.R8_FILIAL = SRD.RD_FILIAL
							AND SR8.R8_MAT = SRD.RD_MAT
							AND (
								(
									%EXP:_cData% BETWEEN SR8.R8_DATAINI
										AND SR8.R8_DATAFIM
									)
								OR (%EXP:_cData% > SR8.R8_DATAINI AND  SR8.R8_DATAFIM = ' ' )
								)
							AND SR8.%NotDel%
							AND RCM.%NotDel%
						), ' ') SITUA
			FROM %TABLE:SRD% SRD
			JOIN %TABLE:SRA% SRA ON SRA.RA_FILIAL = SRD.RD_FILIAL
				AND SRD.RD_FILIAL = %XFILIAL:SRD%
				AND SRA.RA_FILIAL = %XFILIAL:SRA%
				AND SRA.RA_MAT = SRD.RD_MAT
				AND SRA.%NotDel%
			WHERE RD_PD = '489'
				AND RD_PERIODO = %Exp:MV_PAR01%
				AND SRD.%NotDel%
			) PERIODO
		LEFT JOIN %TABLE:ZCE% ZCE ON ZCE.ZCE_FILIAL = PERIODO.RD_FILIAL
			AND ZCE.ZCE_MAT = PERIODO.RD_MAT
			AND ZCE.ZCE_DATA = %Exp:_cData%
			AND ZCE.ZCE_INDICA = PERIODO.INDICA
			AND ZCE.%NotDel%
		ORDER BY RD_FILIAL
			,RD_MAT
			,TPOPER
			,RD_PERIODO
	
	EndSql

	_cSql	:=	"UPDATE " + RetSqlName("ZCE") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZCE_FILIAL = "+ValToSql(xFilial('ZCE'))+" AND ZCE_DATA = " + ValtoSql(_cData)
	
	TcSqlExec(_cSql)

	While (_cAlias)->(!EOF())
		RecLock("ZCE",.T.)
		ZCE->ZCE_FILIAL	:=	xFilial("ZCE")
		ZCE->ZCE_MAT	:=	(_cAlias)->RD_MAT
		ZCE->ZCE_DATA	:=	Stod(_cData)		
		ZCE->ZCE_TABORI	:=	"SRD"
		ZCE->ZCE_OPERAC	:=	(_cAlias)->TPOPER
		ZCE->ZCE_INDICA	:=	(_cAlias)->INDICA
		ZCE->ZCE_VALOR	:=	Iif((_cAlias)->TPOPER == "C", (_cAlias)->RD_VALOR,(_cAlias)->RD_VALOR * -1)
		ZCE->ZCE_SITUAC	:=	(_cAlias)->SITUA
		ZCE->ZCE_OBSERV	:=	(_cAlias)->ZCE_OBSERV
		ZCE->(MsUnlock())
	
		(_cAlias)->(DbSkip())
	EndDo

Return


Static Function fGeraCols()

	Local _aCols	:=	{}
	Local _cAlias	:=	GetNextAlias()
	
	
	BeginSql Alias _cAlias
	
		SELECT *
			FROM %TABLE:ZCE% ZCE
				WHERE ZCE.ZCE_FILIAL = %XFILIAL:ZCE%
					AND ZCE.ZCE_MAT = %Exp:SRA->RA_MAT%
					AND ZCE.ZCE_DATA = %Exp:_cData%
					AND ZCE.ZCE_TABORI <> "FIM"
					AND ZCE.%NotDel%
	EndSql
	
	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(_aCols,{Stod((_cAlias)->ZCE_DATA),(_cAlias)->ZCE_OPERAC,(_cAlias)->ZCE_INDICA,(_cAlias)->ZCE_VALOR,(_cAlias)->ZCE_SITUAC,(_cAlias)->ZCE_OBSERV,.F.})
			(_cAlias)->(DbSkip())
		EndDo

	EndIf

	(_cAlias)->(DbCloseArea())

Return _aCols


Static Function fInsSaldo()

	Local _cAlias	:=	GetNextAlias()
	Local _nSaldIni	:=	0
	

	BeginSql Alias _cAlias
	
		SELECT ISNULL(SUM(ZCE_VALOR),0) ZCE_VALOR
		FROM %TABLE:ZCE% ZCE
		WHERE ZCE.ZCE_FILIAL = %XFILIAL:ZCE%
			AND ZCE.ZCE_DATA = %Exp:_cDtAnt%
			AND ZCE.ZCE_TABORI = 'FIM'
			AND ZCE.ZCE_MAT	=	%Exp:SRA->RA_MAT%
			AND ZCE.%NotDel%
	
	EndSql
	
	_nSaldIni	:=	(_cAlias)->ZCE_VALOR
	
	(_cAlias)->(DbCloseArea())
	
Return _nSaldIni

Static Function fFinSaldo()

	Local _cAlias	:=	GetNextAlias()
	Local _nSaldFin	:=	0

	BeginSql Alias _cAlias
	
		SELECT ISNULL(ZCE_VALOR,0) ZCE_VALOR
		FROM %TABLE:ZCE% ZCE
		WHERE ZCE.ZCE_FILIAL = %XFILIAL:ZCE%
			AND ZCE.ZCE_DATA = %Exp:_cData%
			AND ZCE.ZCE_MAT	=	%Exp:SRA->RA_MAT%
			AND ZCE.ZCE_TABORI = 'FIM'
			AND ZCE.%NotDel%
	
	EndSql
	
	_nSaldFin	:=	(_cAlias)->ZCE_VALOR
	
	(_cAlias)->(DbCloseArea())
	
Return _nSaldFin

Static Function fGrvSaldo()

	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias

		SELECT ZCE.ZCE_FILIAL
			,ZCE.ZCE_MAT
			,ISNULL(SUM(ZCE.ZCE_VALOR), 0) + (
				SELECT ISNULL(SUM(ZCEANT.ZCE_VALOR), 0)
				FROM %TABLE:ZCE% ZCEANT
				WHERE ZCEANT.ZCE_FILIAL = ZCE.ZCE_FILIAL
					AND ZCEANT.ZCE_MAT = ZCE.ZCE_MAT
					AND ZCEANT.ZCE_TABORI = 'FIM'
					AND ZCEANT.ZCE_DATA = %Exp:_cDtAnt%
					AND ZCEANT.%NotDel%
				) SALDO
		FROM %TABLE:ZCE% ZCE
		WHERE ZCE.ZCE_FILIAL = %xFILIAL:ZCE% 
			AND ZCE.ZCE_DATA = %Exp:_cData%
			AND ZCE.%NotDel%
		GROUP BY ZCE_FILIAL
			,ZCE_MAT
	
	EndSql
	//Insere aqueles que possuíram movimentação no período
	While (_cAlias)->(!EOF())
		If (_cAlias)->SALDO <> 0
			RecLock("ZCE",.T.)
			ZCE->ZCE_FILIAL	:=	xFilial("ZCE")
			ZCE->ZCE_MAT	:=	(_cAlias)->ZCE_MAT
			ZCE->ZCE_DATA	:=	Stod(_cData)
			ZCE->ZCE_TABORI	:=	"FIM"
			ZCE->ZCE_OPERAC	:=	'Z'
			ZCE->ZCE_INDICA	:=	'Saldo Final'
			ZCE->ZCE_VALOR	:=	(_cAlias)->SALDO
			ZCE->ZCE_SITUAC	:=	""
			ZCE->ZCE_OBSERV	:=	""
			ZCE->(MsUnlock())	
		EndIf
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
	_cAlias	:=	GetNextAlias()
	
	//Insere Aqueles que possuem saldo anterior e não possuem movimentação no período
	
	BeginSql Alias _cAlias
	
		SELECT *
		FROM %TABLE:ZCE% ZCEANT
		WHERE ZCEANT.ZCE_FILIAL = %XFILIAL:ZCE%
			AND ZCEANT.ZCE_DATA = %Exp:_cDtAnt%
			AND ZCEANT.ZCE_TABORI = 'FIM'
			AND ZCEANT.ZCE_VALOR <> 0
			AND ZCEANT.%NotDel%
			AND NOT EXISTS( SELECT 1
							FROM %TABLE:ZCE% ZCE
							WHERE ZCE.ZCE_FILIAL = ZCEANT.ZCE_FILIAL
								AND ZCE.ZCE_MAT = ZCEANT.ZCE_MAT
								AND ZCE.ZCE_DATA = %Exp:_cData%
								AND ZCE.%NotDel%
							)
	EndSql
	
	While (_cAlias)->(!EOF())
		If (_cAlias)->ZCE_VALOR <> 0
			RecLock("ZCE",.T.)
			ZCE->ZCE_FILIAL	:=	xFilial("ZCE")
			ZCE->ZCE_MAT	:=	(_cAlias)->ZCE_MAT
			ZCE->ZCE_DATA	:=	Stod(_cData)
			ZCE->ZCE_TABORI	:=	"FIM"
			ZCE->ZCE_OPERAC	:=	'Z'
			ZCE->ZCE_INDICA	:=	'Saldo Final'
			ZCE->ZCE_VALOR	:=	(_cAlias)->ZCE_VALOR
			ZCE->ZCE_SITUAC	:=	""
			ZCE->ZCE_OBSERV	:=	""
			ZCE->(MsUnlock())	
		EndIf
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
	
Return

User Function BFG40ALT()

	Local _nPosIndic	:=	aScan(oGdCred:aHeader,{|x| Alltrim(x[2]) == "INDIC"})
	Local _nPosOpera	:=	aScan(oGdCred:aHeader,{|x| Alltrim(x[2]) == "OPERAC"})
	Local _cSql	:= "" 	
	
	_cSql	+=	"	UPDATE " + RetSqlName("ZCE")  
	_cSql	+=	"	SET ZCE_OBSERV = " + ValtoSql(M->OBSER)
	_cSql	+=	"	WHERE ZCE_FILIAL = " + ValtoSql(xfilial("ZCE"))
	_cSql	+=	"		AND ZCE_MAT = " + ValtoSql(SRA->RA_MAT)
	_cSql	+=	"		AND ZCE_DATA = " + ValtoSql(_cData)
	_cSql	+=	"		AND ZCE_INDICA = " + ValtoSql(oGdCred:aCols[oGdCred:nAt,_nPosIndic])
	_cSql	+=	"		AND ZCE_OPERAC = " + ValtoSql(oGdCred:aCols[oGdCred:nAt,_nPosOpera])
	_cSql	+=	"		AND D_E_L_E_T_ = ''	"

	TcSqlExec(_cSql)

Return .T.