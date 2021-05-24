#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"
#Include "rwmake.ch"

/*/{Protheus.doc} FROPRT08
@description SCHEDULE - EFETIVAR RESERVAS E REPLICA LM - CONTIGENCIA
@author Fernando Rocha
@since 20/04/2015
@version undefined
@type function
/*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

/*
Esta rotina e uma contigencia para casos onde reservas de estoque/op ficam temporarias e acabam sendo excluidas indevidamente.
Teoricamente deveriam ser efetivadas apos a inclusao do pedido, por por alguma falha ocasional, nao ocorre 100%.
Mesmo caso para pedidos que ficam sem a replica da LM para empresa de origem - o normal é o sistema fazer automaticamente apos a
colocacao do pedido na propria conexao do representante. Mas e sucessitevel a falhas.

A rotina vai testar os pedidos incluidos a mais de 0.5 (meia) hora para processar.
A funcao FROPRT07 apagar as reservas temporarias somente com mais de 2 horas de incluidas - paramentro FA_RDELRT - 
entao esta rotina tem que rodar primeiro.
*/


User Function FROPRT08()

	Local xv_Emps    := U_BAGtEmpr("07")
	Local nI


	//REPLICAR PEDIDOS PENDENTES DA LM PARA ORIGEM
	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RpcClearEnv()
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])
		//Gera o html do WF.
		Processa({|| PrcReplica()})

		RpcClearEnv()
	Next nI

	//EFETIVAR RESERVAS PENDENTES NA ORIGEM
	xv_Emps    := U_BAGtEmpr("01_05_13")

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])
		//Gera o html do WF.
		Processa({|| PrcEfetiva()})

		RpcClearEnv()
	Next nI


	/*----------------------------------------------------------------------------------------------------*/
	//Conferencia de Pedido - Ao conferir na LM - replicar o campo C5_YCONF para a empresa origem tambem
	xv_Emps    := U_BAGtEmpr("07")
	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])

		Processa({|| PrcRepConf()})

		RpcClearEnv()

	Next nI
	/*----------------------------------------------------------------------------------------------------*/

	//--------------------------------------------------------------//

	//Conferencia Automatica
	xv_Emps    := U_BAGtEmpr("01_05_07")

	For nI := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])

		Processa({|| PrcConfAut()})

		RpcClearEnv()
	Next nI
	//--------------------------------------------------------------//

	//Filipe - Facile em 18/01/2021 -Alerta  para saber quando o titulo não  é  gerado na E1 como PR
	GetErro001() // https://suporteti.biancogres.com.br/Ticket/Edit/24654 - Erro Geração de Titulos de Pedidos Antecipados

Return

Static Function PrcReplica()
	Local cAliasAux

	//Fernando/Facile em 28/10/2015 - adicionado o calculo baseado no campo C5_YHORA para so replicar pedidos incluidos a mais de 1 HORA

	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux
		%NOPARSER%

		select SC5.R_E_C_N_O_, C5_NUM
		from SC5070 SC5 
		join SC6070 SC6 on C6_FILIAL = C5_FILIAL and C6_NUM = C5_NUM
		join ZZ6010 ZZ6 on ZZ6_FILIAL = '  ' and ZZ6_COD = SUBSTRING(C6_PRODUTO,1,2)
		where
		C5_FILIAL = '01'
		and C5_TIPO = 'N'
		and C5_YPEDORI = ''
		and C5_EMISSAO >= '20150101'
		and C6_BLQ <> 'R'    
		and C5_YHORA <> ''
		and ( (select datediff( minute,  convert(smalldatetime, rtrim(C5_EMISSAO)+' '+rtrim(C5_YHORA)) , getdate())) >= 60 )
		and SC5.D_E_L_E_T_=''
		and SC6.D_E_L_E_T_=''
		and ZZ6.D_E_L_E_T_=''
		group by   
		SC5.R_E_C_N_O_,
		C5_NUM

	EndSql

	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		U_GravaPZ2((cAliasAux)->R_E_C_N_O_,"SC5",(cAliasAux)->C5_NUM,"REPL",AllTrim(FunName()),"RPL", "JOB" )

		U_FCOMRT01((cAliasAux)->C5_NUM,,.T.)

		oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, 3, "")
		oConfPedVen:Checar((cAliasAux)->C5_NUM)


		(cAliasAux)->(DbSkip())
	EndDo
	(cAliasAux)->(DbCloseArea())

Return


Static Function PrcEfetiva()
	Local cAliasAux

	//RESERVAS DE ESTOQUE
	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux
		%NOPARSER%

		SELECT C5_NUM, C5_EMISSAO, C5_YCHVRES
		FROM %TABLE:SC5% SC5
		JOIN %TABLE:SC6% SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM
		JOIN %TABLE:SB1% SB1 ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO
		JOIN %TABLE:SC0% SC0 ON C0_FILIAL = '01' and C0_SOLICIT = C5_YCHVRES and C0_YTEMP = 'S' and SC0.D_E_L_E_T_ = ''

		WHERE
		C5_FILIAL = '01'
		and C5_TIPO = 'N'
		and C5_YLINHA <> '4'
		and C5_EMISSAO >= '20150101'
		and C5_YSUBTP NOT IN ('A','RI')
		and C6_BLQ <> 'R'
		and B1_TIPO = 'PA'
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %TABLE:SC9% SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0
		and SC5.D_E_L_E_T_=''
		and SC6.D_E_L_E_T_=''
		and SB1.D_E_L_E_T_=''

	EndSql

	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		_cUserName 	:= (cAliasAux)->C5_YCHVRES

		SC0->(DbSetOrder(5))
		If SC0->(DbSeek(XFilial("SC0")+_cUserName))
			While !SC0->(Eof()) .And. AllTrim(SC0->(C0_FILIAL+C0_SOLICIT)) == AllTrim((XFilial("SC0")+_cUserName))
				//Efetiva reservas temporarias pela chave do usuario e confirma numero do pedido que pode ter mudado
				If SC0->C0_YTEMP == "S"

					U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"EFET_TEMP",AllTrim(FunName()),"EFT", "JOB")

					RecLock("SC0",.F.)
					SC0->C0_YPEDIDO 	:= (cAliasAux)->C5_NUM
					SC0->C0_YTEMP		:= "N"
					SC0->(MsUnlock())

				EndIf
				SC0->(DbSkip())
			EndDo
		EndIf
		//segundo loop - alterar o usuario da chave temporaria para o definitivo
		SC0->(DbOrderNickName("PEDIDO"))
		If SC0->(DbSeek(XFilial("SC0")+(cAliasAux)->C5_NUM))
			While !SC0->(Eof()) .And. SC0->(C0_FILIAL+C0_YPEDIDO) == (XFilial("SC0")+(cAliasAux)->C5_NUM)

				If SC0->C0_YTEMP == "N" .And. AllTrim(SC0->C0_SOLICIT) == _cUserName
					RecLock("SC0",.F.)
					SC0->C0_SOLICIT := CUSERNAME
					SC0->(MsUnlock())
				EndIf

				SC0->(DbSkip())
			EndDo
		EndIf

		(cAliasAux)->(DbSkip())
	EndDo
	(cAliasAux)->(DbCloseArea())


	//RESERVAS DE OP
	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux
		%NOPARSER%

		SELECT C5_NUM, C5_EMISSAO, C5_YCHVRES
		FROM %TABLE:SC5% SC5
		JOIN %TABLE:SC6% SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM
		JOIN %TABLE:SB1% SB1 ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO
		JOIN %TABLE:PZ0% PZ0 ON PZ0_FILIAL = '01' and PZ0_USUINC = C5_YCHVRES and PZ0_STATUS = 'T' and PZ0.D_E_L_E_T_ = ''

		WHERE
		C5_FILIAL = '01'
		and C5_TIPO = 'N'
		and C5_YLINHA <> '4'
		and C5_EMISSAO >= '20150101'
		and C5_YSUBTP NOT IN ('A','RI')
		and C6_BLQ <> 'R'
		and B1_TIPO = 'PA'
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %TABLE:SC9% SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0
		and SC5.D_E_L_E_T_=''
		and SC6.D_E_L_E_T_=''
		and SB1.D_E_L_E_T_=''

	EndSql

	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		_cUserName 	:= (cAliasAux)->C5_YCHVRES

		//Reservas de OP
		PZ0->(DbSetOrder(4))
		If PZ0->(DbSeek(XFilial("PZ0")+_cUserName))
			While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_USUINC)) == AllTrim((XFilial("PZ0")+_cUserName))

				//Efetiva reservas temporarias pela chave do usuario e confirma numero do pedido que pode ter mudado
				If PZ0->PZ0_STATUS == "T"

					U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"EFET_TEMP",AllTrim(FunName()),"EFT", "JOB")

					RecLock("PZ0",.F.)
					PZ0->PZ0_PEDIDO := (cAliasAux)->C5_NUM
					PZ0->PZ0_STATUS := "P"
					PZ0->(MsUnlock())

				EndIf

				PZ0->(DbSkip())
			EndDo
		EndIf
		//segundo loop - alterar o usuario da chave temporaria para o definitivo
		PZ0->(DbSetOrder(2))
		If PZ0->(DbSeek(XFilial("PZ0")+(cAliasAux)->C5_NUM))
			While !PZ0->(Eof()) .And. PZ0->(PZ0_FILIAL+PZ0_PEDIDO) == (XFilial("PZ0")+(cAliasAux)->C5_NUM)

				If PZ0->PZ0_STATUS == "P" .And. AllTrim(PZ0->PZ0_USUINC) == _cUserName
					RecLock("PZ0",.F.)
					PZ0->PZ0_USUINC := CUSERNAME
					PZ0->(MsUnlock())
				EndIf

				PZ0->(DbSkip())
			EndDo
		EndIf

		(cAliasAux)->(DbSkip())
	EndDo
	(cAliasAux)->(DbCloseArea())

Return


//Conferencia de Pedido - Ao conferir na LM - replicar o campo C5_YCONF para a empresa origem tambem
Static Function PrcRepConf()

	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local cRet			:= ""

	cQuery += " SELECT C5_NUM, C5_YPEDORI, C5_YAPROV FROM SC5070 SC5_7 			"+ CRLF
	cQuery += " INNER JOIN SC6070 SC6_7 ON                                      "+ CRLF
	cQuery += " 		SC6_7.C6_FILIAL = SC5_7.C5_FILIAL                       "+ CRLF
	cQuery += " 		AND SC6_7.C6_NUM = SC5_7.C5_NUM                         "+ CRLF
	cQuery += " 		AND SC6_7.D_E_L_E_T_	= ''                            "+ CRLF
	cQuery += " WHERE                                                           "+ CRLF
	cQuery += " SC5_7.C5_FILIAL			= '01'                                  "+ CRLF
	cQuery += " AND SC5_7.C5_TIPO		= 'N'                                   "+ CRLF
	cQuery += " AND SC5_7.C5_EMISSAO	>= '20190101'                           "+ CRLF
	cQuery += " AND SC5_7.C5_YCONF		= 'S'                                   "+ CRLF
	cQuery += " AND SC5_7.D_E_L_E_T_	= ''                                    "+ CRLF
	cQuery += " AND SC5_7.C5_YPEDORI    <> ''                                   "+ CRLF
	cQuery += " AND C6_BLQ				<> 'R'                                  "+ CRLF
	cQuery += " AND (                                                           "+ CRLF

	cQuery += " (SELECT COUNT(*) FROM SC5010 SC5_1                              "+ CRLF
	cQuery += " WHERE                                                           "+ CRLF
	cQuery += " SC5_1.C5_YCONF <> 'S'                                           "+ CRLF
	cQuery += " AND SC5_1.D_E_L_E_T_ = ''                                       "+ CRLF
	cQuery += " AND SC5_1.C5_NUM = SC5_7.C5_YPEDORI			                    "+ CRLF
	cQuery += " AND SC5_7.C5_YEMPPED = '01') > 0								"+ CRLF

	cQuery += " OR																"+ CRLF

	cQuery += " (SELECT COUNT(*) FROM SC5050 SC5_1                              "+ CRLF
	cQuery += " WHERE                                                           "+ CRLF
	cQuery += " SC5_1.C5_YCONF <> 'S'                                           "+ CRLF
	cQuery += " AND SC5_1.D_E_L_E_T_ = ''                                       "+ CRLF
	cQuery += " AND SC5_1.C5_NUM = SC5_7.C5_YPEDORI			                    "+ CRLF
	cQuery += " AND SC5_7.C5_YEMPPED = '05') > 0								"+ CRLF

	cQuery += " )																"+ CRLF

	cQuery += " AND ((SELECT datediff( MINUTE,  convert(smalldatetime, rtrim(C5_EMISSAO)+' '+rtrim(C5_YHORA)) , getdate())) >= 60 ) "+ CRLF
	cQuery += " GROUP BY  C5_NUM, C5_YPEDORI, C5_YAPROV							"+ CRLF


	TCQuery cQuery New Alias cAliasTrab

	While !cAliasTrab->(EoF())

		ConOut("FROPRT08 => Replicando C5_YCONF  Ped.: "+cAliasTrab->C5_NUM+", Ped. Ori: "+cAliasTrab->C5_YPEDORI+",  Aprov: "+cAliasTrab->C5_YAPROV+" Hora: "+Time())

		cRet := U_FRUTCONF(cAliasTrab->C5_NUM, cAliasTrab->C5_YPEDORI, cAliasTrab->C5_YAPROV)
		If !Empty(cRet)
			ConOut("FROPRT08 => Replicando C5_YCONF Retorno: "+cRet)
		EndIf

		cAliasTrab->(DbSkip())
	EndDo

	cAliasTrab->(DbCloseArea())

Return

Static Function PrcConfAut()

	Local cAliasTmp 	:= GetNextAlias()
	Local cQuery		:= ""

	If (cEmpAnt == '07')

		cQuery += " select C5_NUM from SC5070 SC5																									"
		cQuery += " join SA1010 SA1 ON A1_COD+A1_LOJA = C5_CLIENTE+C5_LOJACLI AND SA1.D_E_L_E_T_ = ''                                                "
		cQuery += " where                                                                                                                            "
		cQuery += " SC5.D_E_L_E_T_					= ''		AND                                                                                  "
		cQuery += " A1_YTPSEG						= 'R'		AND                                                                                  "
		cQuery += " C5_YAPROV						<> ''		AND                                                                                  "
		cQuery += " C5_YOBS							IS NULL		AND                                                                                  "
		cQuery += " convert(date, C5_EMISSAO)		>= convert(date, DATEADD(day, -2, GETDATE()))	AND                                              "
		cQuery += " C5_YSUBTP						NOT IN	('M', 'O', 'F', 'G', 'B', 'A')			AND                                              "
		cQuery += " C5_TIPO							= 'N'		AND		                                                                             "
		cQuery += " C5_YPEDORI						<> ''		AND                                                                                  "
		cQuery += " C5_YHORA						<> ''		                                                                                     "
		cQuery += " AND ( EXISTS                                                                                                                     "
		cQuery += " (                                                                                                                                "
		cQuery += " 	SELECT NULL FROM SC0010 SC0                                                                                                  "
		cQuery += " 		WHERE SC0.C0_YPEDIDO = SC5.C5_YPEDORI AND SC0.D_E_L_E_T_ = ''                                                            "
		cQuery += " 	UNION ALL                                                                                                                    "
		cQuery += " 	SELECT NULL FROM SC0050 SC0                                                                                                  "
		cQuery += " 		WHERE SC0.C0_YPEDIDO = SC5.C5_YPEDORI AND SC0.D_E_L_E_T_ = ''                                                            "
		cQuery += " )                                                                                                                                "
		cQuery += " OR (EXISTS                                                  		                                                                 "
		cQuery += " (                                                                                                                                "
		cQuery += " 	select NULL from PZ0010 PZ0                                                                                                  "
		cQuery += " 		where PZ0_PEDIDO = SC5.C5_YPEDORI AND PZ0.D_E_L_E_T_ = ''                                                                "
		cQuery += " 	union all                                                                                                                    "
		cQuery += " 	select NULL from PZ0050 PZ0                                                                                                  "
		cQuery += " 		where PZ0_PEDIDO = SC5.C5_YPEDORI AND PZ0.D_E_L_E_T_ = ''	                                                             "
		cQuery += " ) AND C5_YCONF = 'N'))                                                                                                                               "

		cQuery += " and ( (select datediff( minute,  convert(smalldatetime, rtrim(C5_EMISSAO)+' '+rtrim(C5_YHORA)) , getdate())) >= 10 )             "
		cQuery += "                                                                                                                                  "

	Else

		cQuery += " SELECT DISTINCT C5_NUM FROM "+ RetSqlName("SC5")+" SC5                                                                           "
		cQuery += " join SA1010 SA1 ON A1_COD+A1_LOJA = C5_CLIENTE+C5_LOJACLI AND SA1.D_E_L_E_T_ = ''                                                "
		cQuery += " join "+ RetSqlName("SC6")+" SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM                                 					 "
		cQuery += " where                                                                                                                            "
		cQuery += " SC5.D_E_L_E_T_					= ''		AND                                                                                  "
		cQuery += " SC6.D_E_L_E_T_					= ''		AND                                                                                  "
		cQuery += " A1_YTPSEG						= 'R'		AND                                                                                  "
		cQuery += " C5_YAPROV						<> ''		AND                                                                                  "
		cQuery += " C5_YOBS							IS NULL		AND                                                                                  "
		cQuery += " convert(date, C5_EMISSAO)		>= convert(date, DATEADD(day, -2, GETDATE()))	AND                                              "
		cQuery += " C5_YSUBTP						NOT IN	('M', 'O', 'F', 'G', 'B', 'A')				AND                                          "
		cQuery += " C5_TIPO							= 'N'		AND		                                                                             "
		cQuery += " C5_YHORA						<> ''		                                                                                     "
		cQuery += " AND( EXISTS                                                                                                                      "
		cQuery += " (                                                                                                                                "
		cQuery += " 	SELECT NULL FROM "+ RetSqlName("SC0")+" SC0                                                                                  "
		cQuery += " 		WHERE SC0.C0_YPEDIDO = SC5.C5_NUM AND SC0.D_E_L_E_T_ = ''                                                                "
		cQuery += " )                                                                                                                                "
		cQuery += " OR( EXISTS                                                                                                                   	 "
		cQuery += " (                                                                                                                                "
		cQuery += " 	SELECT NULL FROM "+ RetSqlName("PZ0")+" PZ0                                                                                  "
		cQuery += " 		WHERE PZ0_PEDIDO = SC5.C5_NUM AND PZ0.D_E_L_E_T_ = ''                                                                    "
		cQuery += " ) AND C5_YCONF = 'N'))                                                                                                           "                    "
		cQuery += " AND NOT EXISTS                                                                                                                   "
		cQuery += " (                                                                                                                                "
		cQuery += " 	SELECT NULL FROM SC5070 SC5_7                                                                                                "
		cQuery += " 		WHERE SC5_7.C5_YPEDORI = SC5.C5_NUM AND SC5_7.D_E_L_E_T_ = ''                                                            "
		cQuery += " )                                                                                                                                "
		cQuery += " AND NOT EXISTS																												     "
		cQuery += " (																																 "
		cQuery += " SELECT 1 FROM "+ RetSqlName("SC9")+" SC9 																						 "
		cQuery += " WHERE C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_=''	                                 "
		cQuery += " ) 																															     "
		cQuery += " and ( (select datediff( minute,  convert(smalldatetime, rtrim(C5_EMISSAO)+' '+rtrim(C5_YHORA)) , getdate())) >= 20 )             "


	EndIf

	Conout('TConferenciaPedidoVenda: Automatica Schedule => Query: '+cQuery)

	TcQuery cQuery New Alias (cAliasTmp)

	While (!(cAliasTmp)->(Eof()))

		cNumPed := (cAliasTmp)->C5_NUM

		Conout('TConferenciaPedidoVenda: Automatica Schedule => Pedido: '+cNumPed+', Empresa: '+cEmpAnt)

		oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, 3, "")
		oConfPedVen:Checar(cNumPed)

		(cAliasTmp)->(DbSkip())
	EndDo()

	(cAliasTmp)->(DbCloseArea())

Return


Static Function GetErro001()

	Local cSQL := ""
	Local cQry := ""
	Local cHtml := ""
	Local  cMail :=  "filipe.bittencourt@facilesistemas.com.br;nadine.araujo@biancogres.com.br"
	Local lErro := .F.


	RpcClearEnv()
	If Select("SX6") <= 0
		RPCSetEnv("07", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	EndIf

	cQry := GetNextAlias()

	cSQL := " select   " + CRLF
	cSQL += "   'LM COMERCIO' as EMPRESA,  " + CRLF
	cSQL += "   C5_FILIAL,  " + CRLF
	cSQL += "   C5_NUM,  " + CRLF
	cSQL += "   C5_CLIENTE,  " + CRLF
	cSQL += "   C5_YPEDORI ,  " + CRLF
	cSQL += "   C5_YEMPPED AS 'REPLICADO' ,  " + CRLF
	cSQL += "   C5_YLINHA AS 'LINHA DO PRODUTO',   " + CRLF
	cSQL += "   C5_EMISSAO+' '+C5_YHORA as hora,  " + CRLF
	cSQL += "   C5_YENVIO, C5_YFORMA, C5_YCONF,  " + CRLF
	cSQL += "   C5_EMISSAO, C5_CONDPAG, C5_YCONF, C5_YAPROV, C5_YAAPROV, C5_YUSCONF, C5_YHORA, C5_YPEDORI, C5_YENVIO  " + CRLF
	cSQL += "   from SC5070  SC5 with (nolock)   " + CRLF
	cSQL += "   where 1=1   " + CRLF
	cSQL += "   AND C5_FILIAL	  IN ('01','02','03','04','05','06')  " + CRLF
	cSQL += "   AND C5_EMISSAO >= '20210101'  " + CRLF
	cSQL += "   AND D_E_L_E_T_	= ''  " + CRLF
	cSQL += "   AND C5_CONDPAG	IN ('000', '208')  " + CRLF
	cSQL += "   AND C5_TIPO		= 'N'       " + CRLF
	cSQL += "   AND C5_YCONF		= 'S'   " + CRLF
	cSQL += "   AND C5_YENVIO		= 'N'   " + CRLF
	cSQL += "   AND C5_YPEDORI	<> ''       " + CRLF
	cSQL += "   AND C5_YHORA		<> ''   " + CRLF
	cSQL += "   AND C5_NOTA		= ''        " + CRLF
	cSQL += "   AND C5_YAPROV     <> ''   " + CRLF

	cSQL += "   and not exists (SELECT E1_NUM FROM SE1070 (nolock)  " + CRLF
	cSQL += "   	where   " + CRLF
	cSQL += "   	E1_FILIAL IN ('01','02','03','04','05','06') " + CRLF
	cSQL += " 	AND E1_CLIENTE	= C5_CLIENTE   " + CRLF
	cSQL += "   	AND E1_LOJA		= C5_LOJACLI     " + CRLF
	cSQL += " 	AND E1_PREFIXO	=   'PR'+C5_YLINHA   " + CRLF
	cSQL += "   	and E1_PEDIDO = C5_NUM    	     " + CRLF
	cSQL += "   	AND D_E_L_E_T_			= '' )   " + CRLF
	cSQL += "  order by R_E_C_N_O_ DESC              " + CRLF

	TcQuery cSQL New Alias (cQry)

	cHtml := " <html>"
	cHtml += " <body>"

	cHtml += " <div style='margin:0;padding:0;background-color:#ffffff;height:100%'>"

	cHtml += " <table border='1' cellpadding='0' cellspacing='0' width='100%' style='background-color:#ffffff;overflow-x:hidden'>"
	cHtml += " <tr>"
	cHtml += " <td>EMPRESA</td>"
	cHtml += " <td>FILIAL</td>"
	cHtml += " <td>CLIENTE</td>"
	cHtml += " <td>NUM. PV</td>"
	cHtml += " <td>NUM. PV. FABRICA</td>"
	cHtml += " <td>DATA</td>"
	cHtml += " </tr>"

	While (cQry)->(!EOF())

		lErro := .T.
		cHtml += " <tr>"
		cHtml += " <td>"+(cQry)->(EMPRESA)+"</td>"
		cHtml += " <td>"+(cQry)->(C5_FILIAL)+"</td>"
		cHtml += " <td>"+(cQry)->(C5_CLIENTE)+"</td>"
		cHtml += " <td>"+(cQry)->(C5_NUM)+"</td>"
		cHtml += " <td>"+(cQry)->(C5_YPEDORI)+"</td>"
		cHtml += " <td>"+(cQry)->(hora)+"</td>"
		cHtml += " </tr>"

		(cQry)->(DBSkip())

	EndDo

	cHtml += " </table> "
	cHtml += " </div> "
	cHtml += " </body> "
	cHtml += " </html>   "

	if lErro

		U_BIAEnvMail(,cMail,'Erro Geração de Titulos de Pedidos Antecipados',cHtml)

		//tenta enviar novamente o pedido em caso de erro.
		(cQry)->(DbGoTop())
		While (cQry)->(!EOF())
			u_Env_Pedido((cQry)->(C5_YPEDORI),,,(cQry)->(C5_FILIAL),.T.)
			(cQry)->(DBSkip())
		EndDo

	Endif

Return
