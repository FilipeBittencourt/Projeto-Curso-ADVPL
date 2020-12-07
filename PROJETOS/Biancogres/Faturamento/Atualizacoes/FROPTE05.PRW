#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FROPTE05
@description Liberacao de bloqueios de Lote
@author Fernando Rocha
@since 02/07/2014
@version undefined
@type function
/*/
User Function FROPTE05
	Local aArea 	:= GetArea()
	Local cAlias	:= "SC6"
	Local aCores	:= {}
	Local cFiltra
	Local aFixe		:= {}
	Local cSQL := ""

	Private _cALIAS := GetNextAlias()

	//Variaveis Private da Rotina
	Private	cCadastro     := "Liberação de Bloqueios de Lote" //Define Nome da Tela

	SC6->(DbSetOrder(1))

	AAdd(aCores,{""+_cALIAS+"->C6_YBLQLOT=='10'"		, "BR_AMARELO"     	})
	AAdd(aCores,{""+_cALIAS+"->C6_YBLQLOT=='01'"		, "BR_VERMELHO"   	})
	AAdd(aCores,{""+_cALIAS+"->C6_YBLQLOT=='11'"		, "BR_PRETO" 		})

	aRotina   := { 	{"Pesquisar"    		,"AxPesqui"      		,0,1},;
	{"Visualizar"     		,"U_FRT05VPE()"	      	,0,2},;
	{"Lib. Rej. Sugestao"	,"U_FRT05LSU()"    		,0,4},;
	{"Lib. Lote Restrito"   ,"U_FRT05LRE()"    	  	,0,4},;
	{"Legenda"				,"U_FRT05LEG()"    		,0,4}}

	LoadPed()

	private cMarca := GetMark()

	aCampos := {}
	aAdd(aCampos, {"MARCA",,"",""})
	aAdd(aCampos, {"C6_YEMISSA",,"Emissao",""})
	aAdd(aCampos, {"C6_NUM",,"Pedido","@!"})
	aAdd(aCampos, {"C6_CLI",,"Cod Cliente","@!"})
	aAdd(aCampos, {"A1_NOME",10,"Nome","@S20"})
	aAdd(aCampos, {"C6_ITEM",,"Item","@S2"})
	aAdd(aCampos, {"C6_PRODUTO",,"Produto","@S8"})
	aAdd(aCampos, {"C6_DESCRI",,"Descricao","@S20"})
	aAdd(aCampos, {"C6_QTDVEN",,"Qtd Ped.","@E 99,999.99"})
	aAdd(aCampos, {"C6_PRCVEN",,"Prc Uni.","@E 999,999.99"})
	aAdd(aCampos, {"C6_YDESC",,"Desconto","@E 999.99"})
	aAdd(aCampos, {"C6_LOTECTL",,"Lote","@S5"}) 
	aAdd(aCampos, {"ZZ9_RESTRI",,"Restr.","@!"}) 
	aAdd(aCampos, {"MOTIVO",,"Motivo","@S20"})
	aAdd(aCampos, {"QT_UM_PAL",,"Q.Pallet","@E 999.99"})
	aAdd(aCampos, {"C6_YQTDSUG",,"Qt.Sugerida","@E 99,999.99"})
	aAdd(aCampos, {"C6_YLOTSUG",,"Lt.Sugerido","@S5"})
	aAdd(aCampos, {"C6_YLOTTOT",,"Sal.Lot.Sug","@E 999,999.99"})

	MarkBrow(_cALIAS, "MARCA", ,aCampos, .F., @cMarca, /*"U_bMarkAll()"*/, , , , /*"U_bMark()"*/,,,,aCores)

	//Recupera area de trabalho
	RestArea(aArea)
	If Select(_cALIAS) > 0
		(_cALIAS)->(DbCloseArea())
	EndIf

Return

User Function FRT05LEG()

	Brwlegenda(cCadastro, "Legenda",{	{"BR_AMARELO"    	,"Bloq. Rejeição de Sugestão"     },;
	{"BR_VERMELHO"    	,"Bloq. Lote Restrito" },;
	{"BR_PRETO"		  	,"Ambos"  }})
Return

User Function FRT05VPE()

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+(_cALIAS)->C6_NUM),.T.)
	A410Visual("SC5",SC5->(RecNo()),2)

return

Static Function LoadPed()
	U_BIAMsgRun("Aguarde... Carregando pedidos bloqueados.",,{|| LPedPrc() })
Return

Static Function LPedPrc()
	Local cSQL

	cSQL := " SELECT "+CRLF
	cSQL += " MARCA = '  ', "+CRLF
	cSQL += " C6_YBLQLOT, "+CRLF
	cSQL += " C6_NUM, "+CRLF
	cSQL += " C6_CLI = CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C6_CLI END, "+CRLF
	cSQL += " C6_LOJA = CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C6_LOJA END, "+CRLF
	cSQL += " A1_NOME, "+CRLF
	cSQL += " C6_ITEM, "+CRLF
	cSQL += " C6_PRODUTO, "+CRLF
	cSQL += " C6_DESCRI, "+CRLF
	cSQL += " C6_QTDVEN, "+CRLF
	cSQL += " C6_PRCVEN, "+CRLF
	cSQL += " C6_YDESC, "+CRLF
	cSQL += " C6_LOTECTL, "+CRLF
	cSQL += " C6_YQTDSUG, "+CRLF
	cSQL += " C6_YLOTSUG, "+CRLF
	cSQL += " C6_YLOTTOT,  "+CRLF 
	cSQL += " C6_YEMISSA,  "+CRLF 
	cSQL += " ZZ9_RESTRI,  "+CRLF
	cSQL += " QT_UM_PAL = (select top 1 cast(( B1_YDIVPA * B1_CONV ) as decimal(15,2)) from SB1010 where B1_COD = C6_PRODUTO and D_E_L_E_T_ = ''), "+CRLF
	cSQL += " MOTIVO = PZ7.PZ7_DESCRI "+CRLF
	cSQL += " FROM "+RetSQLName("SC6")+" SC6 "+CRLF
	cSQL += " JOIN "+RetSQLName("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_YCONF = 'S' "+CRLF
	cSQL += " JOIN "+RetSQLName("SA1")+" SA1 ON A1_FILIAL = ' ' AND A1_COD = (CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C6_CLI END) AND A1_LOJA = (CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C6_LOJA END) "+CRLF
	cSQL += " JOIN "+RetSQLName("ZZ6")+" ZZ6 ON ZZ6_FILIAL = ' ' AND ZZ6_COD = Substring(C6_PRODUTO,1,2) "+CRLF
	cSQL += " LEFT JOIN PZ7010 PZ7 ON PZ7_FILIAL = '  ' AND PZ7_CODIGO = C6_YMOTFRA AND PZ7.D_E_L_E_T_='' "+CRLF
	cSQL += " left join ZZ9010 ZZ9 on ZZ9_FILIAL = '  ' and ZZ9_LOTE = C6_LOTECTL and ZZ9_PRODUT = C6_PRODUTO and ZZ9.D_E_L_E_T_='' "+CRLF
	cSQL += " WHERE "+CRLF
	cSQL += " C6_YBLQLOT <> ' ' "+CRLF
	cSQL += " AND C6_YBLQLOT <> '00' "+CRLF

	//Atendende passa a ver e liberar todos os bloqueios - solicitacao Patelli em 06/04/15
	/*If U_VALOPER("R04",.F.,.F.)
	cSQL += " AND SubString(C6_YBLQLOT,1,1) = '1' "+CRLF
	Else                                                    
	cSQL += " AND SubString(C6_YBLQLOT,2,1) = '1' "+CRLF
	EndIf*/

	cSQL += " AND SC6.D_E_L_E_T_ = ' ' "+CRLF
	cSQL += " AND SA1.D_E_L_E_T_ = ' ' "+CRLF
	cSQL += " AND ZZ6.D_E_L_E_T_ = ' ' "+CRLF

	cSQL += " ORDER BY C6_NUM, C6_ITEM "+CRLF

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	TcQuery cSQL new Alias "QRY"

	TCSetField("QRY", "C6_YEMISSA", "D", 8, 0)

	DbSelectArea("QRY") 


	aStru := {}
	AADD(aStru,{ "MARCA"		, "C",  02, 0})
	AADD(aStru,{ "C6_YBLQLOT"	, "C",  02, 0})
	AADD(aStru,{ "C6_YEMISSA"  	, "D",  08, 0})
	AADD(aStru,{ "C6_NUM"   	, "C",  06, 0})
	AADD(aStru,{ "C6_CLI"   	, "C",  06, 0})
	AADD(aStru,{ "C6_LOJA"   	, "C",  02, 0})
	AADD(aStru,{ "A1_NOME"   	, "C",  30, 0})
	AADD(aStru,{ "C6_ITEM"   	, "C",  02, 0})
	AADD(aStru,{ "C6_PRODUTO"  	, "C",  08, 0})
	AADD(aStru,{ "C6_DESCRI"   	, "C",  20, 0})
	AADD(aStru,{ "C6_QTDVEN"   	, "N",  08, 2})
	AADD(aStru,{ "C6_PRCVEN"   	, "N",  10, 2})
	AADD(aStru,{ "C6_YDESC"  	, "N",  6, 2})
	AADD(aStru,{ "C6_LOTECTL"  	, "C",  05, 0}) 
	AADD(aStru,{ "ZZ9_RESTRI"  	, "C",  01, 0})
	AADD(aStru,{ "C6_YQTDSUG"  	, "N",  08, 2})
	AADD(aStru,{ "C6_YLOTSUG"  	, "C",  05, 0})
	AADD(aStru,{ "C6_YLOTTOT"  	, "N",  10, 2})
	AADD(aStru,{ "QT_UM_PAL"   	, "N",  08, 2})
	AADD(aStru,{ "MOTIVO"   	, "C",  20, 0})                      	


	ARQ := CriaTrab(aStru)
	If Select(_cALIAS) > 0
		(_cALIAS)->(DbCloseArea())
	EndIf                                      
	DbUseArea( .T., ,ARQ, _cALIAS, .T., .F. )

	dbCreateInd(ARQ,"C6_NUM",{||C6_NUM})

	DbSelectArea(_cALIAS)
	Append from QRY

	QRY->(DbCloseArea())

	//IND := (_cALIAS)->(DbCreateIndex(""+_cALIAS+__CUSERID+".cdx","C6_NUM"))

	DBSelectArea(_cALIAS)
	(_cALIAS)->(DBGotop())

	FilBrowse(_cALIAS,{},/* Filtro */)

Return


User Function FRT05LSU()
	Local lAcesso := .T.

	//Atendende passa a ver e liberar todos os bloqueios - solicitacao Patelli em 06/04/15

	//verificar acesso a operacao liberar sugestao de lote
	//If !U_VALOPER("R04",.F.,.F.)
	//If !(CUSERNAME $ AllTrim(U_FRGERADM((_cALIAS)->C6_NUM)))  //Alterado para considerar o Gerente de cada empresa - nao usar mais o acesso R04
	//	lAcesso := .F.
	//EndIf

	//If !lAcesso
	//	U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Esta operação deve ser executada pelo:"+CRLF+"GERENTE ADM DE VENDAS",,,"SEM ACESSO A OPERAÇÃO")
	//	Return
	//EndIf

	aButtons := {"CANCELAR","LIBERAR"}
	nRet := U_FROPMSG("LIBERAÇÃO BLOQUEIO LOTE",;
	"Tem certeza que deseja liberar os ITENS SELECIONADOS?";
	,aButtons,,;
	"Bloqueio por Rejeição de Sugestão de Lote")

	If nRet == 2

		(_cALIAS)->(DbGoTop())
		While !(_cALIAS)->(Eof())

			If (_cALIAS)->MARCA == cMarca

				SC6->(DbSetOrder(1))
				IF SC6->(DbSeek(xFilial("SC6")+(_cALIAS)->(C6_NUM+C6_ITEM),.F.)) 

					//Bloqueio por ponta - somente esse tem que ser o gerente  
					__cGerente := U_FRGERADM((_cALIAS)->C6_NUM)
					If (SC6->C6_YMOTFRA == "998") .And. !(CUSERNAME $ AllTrim(__cGerente))
						U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","BLOQUEIO POR GERAÇÃO DE PONTA."+CRLF+"Esta operação deve ser executada por:"+CRLF+AllTrim(__cGerente),,,"SEM ACESSO A OPERAÇÃO")
						(_cALIAS)->(DbSkip())
						loop
					EndIf

					RecLock("SC6",.F.)
					SC6->C6_YBLQLOT := STUFF(SC6->C6_YBLQLOT,1,1,"0")
					SC6->(MsUnlock())

					//Enviar email do cliente se liberacao do pedido completa 
					If Upper(AllTrim(getenvserver())) == "PRODUCAO" 
						EmailCliente()
					EndIf

				ENDIF

			EndIf

			(_cALIAS)->(DbSkip())
		EndDo

	EndIf

	LoadPed()
	__oObj := GetObjBrow()
	__oObj:Refresh()

Return

User Function FRT05LRE()
	Local lAcesso := .T.
	Local cAliasTmp

	//verificar acesso a operacao liberar lotes restritos
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFilial("SC5")+(_cALIAS)->C6_NUM),.T.)

	aButtons := {"CANCELAR","LIBERAR"}
	nRet := U_FROPMSG("LIBERAÇÃO BLOQUEIO LOTE",;
	"Tem certeza que deseja liberar os ITENS SELECIONADOS";
	,aButtons,,;
	"Bloqueio por uso de Lote Restrito")

	If nRet == 2

		(_cALIAS)->(DbGoTop())
		While !(_cALIAS)->(Eof())

			If (_cALIAS)->MARCA == cMarca

				SC6->(DbSetOrder(1))
				IF SC6->(DbSeek(xFilial("SC6")+(_cALIAS)->(C6_NUM+C6_ITEM),.F.))

					RecLock("SC6",.F.)
					SC6->C6_YBLQLOT := STUFF(SC6->C6_YBLQLOT,2,1,"0")
					SC6->(MsUnlock())

					//Enviar email do cliente se liberacao do pedido completa
					If Upper(AllTrim(getenvserver())) == "PRODUCAO" 
						EmailCliente()
					EndIf

				ENDIF

			EndIf

			(_cALIAS)->(DbSkip())
		EndDo

	EndIf

	LoadPed()
	__oObj := GetObjBrow()
	__oObj:Refresh()

Return


Static Function EmailCliente()

	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(XFilial("SC5")+SC6->C6_NUM),.T.)

		//Enviar o email de liberacao de pedido somente apos a liberacao das rejeicoes
		If U_FROPVLPV(SC5->C5_NUM, .F., .F.) .And. U_fVlLbDes(SC5->C5_NUM,SC5->C5_YCLIORI)   

			If cEmpAnt <> "07" .And. !Empty(SC5->C5_YCLIORI)
				__cChvCli := SC5->C5_YCLIORI+SC5->C5_YLOJORI
			Else
				__cChvCli := SC5->C5_CLIENTE+SC5->C5_LOJACLI
			EndIf

			//Codigo para envio de email de pedido - Transposto do fonte BIA319 - verificar se nao pode fazer uma funcao generica
			SEMAIL := Posicione("SA1",1,xFilial("SA1")+__cChvCli,"A1_YEMAIL") // MADALENO
			If SC5->C5_YCONF == "S" .AND. (SEMAIL = "S") .AND. (SC5->C5_YENVIO <> "S") .And. (SC5->C5_TIPO == "N") //.And. (Alltrim(SC5->C5_YAPROV) <> "")

				//(Thiago - 17/04/15) -> Envitar o envio do pedido errado.
				cEmpPed := cEmpAnt

				If !Empty(SC5->C5_YEMPPED)
					cEmpPed := SC5->C5_YEMPPED
				EndIf

				//Se for liberacao na empresa origem - faturamento por LM - rodar o email na empresa LM
				If cEmpAnt <> "07" .And. SC5->C5_CLIENTE == "010064"

					U_FROPCPRO("07","01","U_Env_Pedido", SC5->C5_NUM, .T., .T., cEmpPed, .T.)
					U_FROPCPRO("07","01","U_BIA188", SC5->C5_NUM, cEmpPed, .T.)

					//Fernando/Facile em 02/09 - atualizar data das reservas de acordo com vencimento dodo boleto antecipado
					U_FR2VLRES(SC5->C5_NUM)

				Else

					U_Env_Pedido(SC5->C5_NUM, .T., .T., cEmpPed)
					U_BIA188()	   

					//Fernando/Facile em 02/09 - atualizar data das reservas de acordo com vencimento dodo boleto antecipado
					U_FR2VLRES(SC5->C5_NUM)

				EndIf

			EndIf

		EndIf

	EndIf

Return

