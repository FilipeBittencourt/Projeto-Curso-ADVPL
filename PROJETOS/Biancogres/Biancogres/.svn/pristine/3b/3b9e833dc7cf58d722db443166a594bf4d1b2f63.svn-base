#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPDMTransferencia
@author Wlysses Cerqueira (Facile)
@since 22/10/2018
@project PDM
@version 1.0
@description Classe com as regras para transferencia de estoque dos produtos antigos para os novos
@type class
/*/
Class TPDMTransferencia From LongClassName
	
	Data oLista
	Data cProdDe
	Data cProdAte
	Data cGrupoDe
	Data cGrupoAte
	Data cLocalDe
	Data cLocalAte
	
	Data cLog
	Data cFileLog
	
	Data nTotOk
	Data nTotSemEfei
		
	Method New() Constructor
	Method Show()
	Method GetProdutos()
	Method Transferencia(oList)
	Method Execute()
	Method BloqueioPrdOrigem(cProduto)
	
EndClass

Method New() Class TPDMTransferencia	

	::cProdDe	:= Space(TamSx3("B1_COD")[1])
	::cProdAte	:= Space(TamSx3("B1_COD")[1])
	::cGrupoDe	:= Space(TamSx3("B1_GRUPO")[1])
	::cGrupoAte	:= Space(TamSx3("B1_GRUPO")[1])
	::cLocalDe	:= Space(TamSx3("B2_LOCAL")[1])
	::cLocalAte	:= Space(TamSx3("B2_LOCAL")[1])
		
	::oLista := ArrayList():New()
	
	::cLog	:= ""
	::cFileLog	:= ""
	
	::nTotOk  := 0
	::nTotSemEfei := 0
	
Return(Self)

Method Show() Class TPDMTransferencia
	
	Local cRefPer		:= 'TPDMTransferencia' + cEmpAnt
	Local cFileName		:= __cUserID + "_" + cRefPer
	Local aPergs		:= {}
	Local oProgress		:= {}
	
	Private cProdDe		:= ::cProdDe
	Private cProdAte	:= ::cProdAte
	Private cGrupoDe	:= ::cGrupoDe
	Private cGrupoAte	:= ::cGrupoAte
	Private cLocalDe	:= ::cLocalDe
	Private cLocalAte	:= ::cLocalAte
		
	aAdd( aPergs ,{1, "Produto Origem de:"	, cProdDe	, "@!", ".T.", "SB1"	, ".T.", 100, .F.})
	aAdd( aPergs ,{1, "Produto Origem Ate:"	, cProdAte	, "@!", ".T.", "SB1"	, ".T.", 100, .F.})
	aAdd( aPergs ,{1, "Grupo Origem de:"	, cGrupoDe	, "@!", ".T.", "SBM"	, ".T.", 100, .F.})
	aAdd( aPergs ,{1, "Grupo Origem Ate:"	, cGrupoAte	, "@!", ".T.", "SBM"	, ".T.", 100, .F.})
	aAdd( aPergs ,{1, "Local Origem de:"	, cLocalDe	, "@!", ".T.", "NNR"	, ".T.", 100, .F.})
	aAdd( aPergs ,{1, "Local Origem Ate:"	, cLocalAte	, "@!", ".T.", "NNR"	, ".T.", 100, .F.})
		
	If ParamBox(aPergs ,"Movimentacao Interna - Transferencia",,,,,,,,cRefPer,.T.,.T.)

		::cProdDe	:= ParamLoad(cFileName,,1 , cProdDe)
		::cProdAte	:= ParamLoad(cFileName,,2 , cProdAte)	
		::cGrupoDe	:= ParamLoad(cFileName,,3 , cGrupoDe)
		::cGrupoAte	:= ParamLoad(cFileName,,4 , cGrupoAte)
		::cLocalDe	:= ParamLoad(cFileName,,5 , cLocalDe)
		::cLocalAte	:= ParamLoad(cFileName,,6 , cLocalAte)
		
		Processa( {|| ::Execute() }, "Aguarde...", "Carregando produtos...", .F.)

	Else

		Return(.F.)

	EndIf

Return()

Method Execute() Class TPDMTransferencia
	
	Local nW		:= 0
	Local cNomeArq	:= ""
	Local cMsg		:= ""
	
	::cFileLog := "PDM_TRANSFERENCIA_Inicio_" + DToS(Date()) + "_" + StrTran(Time(), ":", "") + "_"
	
	::GetProdutos()
	
	ProcRegua(::oLista:GetCount())
	
	For nW := 1 To ::oLista:GetCount()
		
		IncProc("Transferindo saldo Produto...: [" + ::oLista:GetItem(nW):cProdOrigem + "] para [" + ::oLista:GetItem(nW):cProdDestino + "]")
		
		::Transferencia(::oLista:GetItem(nW))
	
	Next nW
	
	::cFileLog += "Fim_" + DToS(Date()) + "_" + StrTran(Time(), ":", "") + ".log"
	
	cNomeArq := "C:\temp\" + ::cFileLog
	
	If !lIsDir( "C:\temp\" )
			
		MakeDir( "C:\temp\" )
			
	EndIf
	
	cMsg := "Processamento finalizado! Segue abaixo total de registros processados: " + CRLF + CRLF +;
	 		"Total...........: " + cValToChar(::oLista:GetCount()) + CRLF +;
	 		"Divergencias....: " + cValToChar(::oLista:GetCount() - ::nTotOk - ::nTotSemEfei) + CRLF +;
	 		"Sem efeito......: " + cValToChar(::nTotSemEfei) + CRLF +;
	 		"Transferidos....: " + cValToChar(::nTotOk) + CRLF + CRLF +;
	 		"Log salvo em....: " + cNomeArq + CRLF + CRLF +;
	 		If(::oLista:GetCount() > 0, ::cLog, "Nao encontrado registros.") + CRLF + CRLF
	
	MemoWrite(cNomeArq, cMsg)
	
	Aviso("ATENCAO", cMsg, {"Ok"}, 3)
	 		
Return()

Method GetProdutos() Class TPDMTransferencia

	Local cAlias	:= GetNextAlias()
	Local oObj		:= Nil
	
	BeginSql Alias cAlias

		SELECT		  
					  B.B2_FILIAL  FILIAL,
		              A.B1_CODANT  PROD_ANTIGO,
		              B.B2_LOCAL   LOCAL_ANTIGO,
		              B.B2_QATU    QATU_ANTIGO,
		              B.B2_RESERVA RESEVA_ANTIGO,
		              B.B2_QACLASS QACLASS_ANTIGO,
		
					  A.B1_COD     PROD_NOVO,
		              C.B2_LOCAL   LOCAL_NOVO,
		              C.B2_QATU    QATU_NOVO,
		              C.B2_RESERVA RESEVA_NOVO,
		              C.B2_QACLASS QACLASS_NOVO
		FROM
		              %Table:SB1% A (NOLOCK)
		    INNER JOIN %Table:SB2% B (NOLOCK) ON (
			                                       A.B1_FILIAL      = ''
			                                       AND A.B1_CODANT  = B.B2_COD
			                                       AND B.D_E_L_E_T_ = ''
			                                    )
		    LEFT JOIN %Table:SB2% C (NOLOCK) ON (
			                                       A.B1_FILIAL      = ''
			                                       AND A.B1_COD     = C.B2_COD
			                                       AND C.B2_LOCAL   BETWEEN %Exp:Self:cLocalDe% AND %Exp:Self:cLocalAte%
			                                       AND C.D_E_L_E_T_ = ''
			                                    )
		WHERE
		              B1_CODANT        <> ''
		              AND A.B1_YPDM    <> ''
 		              AND A.B1_CODANT  BETWEEN %Exp:Self:cProdDe%  AND %Exp:Self:cProdAte% 
		              AND A.B1_GRUPO   BETWEEN %Exp:Self:cGrupoDe% AND %Exp:Self:cGrupoAte%
		              AND B.B2_LOCAL   BETWEEN %Exp:Self:cLocalDe% AND %Exp:Self:cLocalAte%
		              AND A.D_E_L_E_T_ = ''
		ORDER BY B.B2_FILIAL, B.B2_COD, B.B2_LOCAL
		
	EndSql
	
	While (cAlias)->(!Eof())
		
		oObj := TIPDMTransferencia():New()
		
		oObj:cFil			:= (cAlias)->FILIAL
		oObj:cProdOrigem    := (cAlias)->PROD_ANTIGO
		oObj:cLocalOrigem   := (cAlias)->LOCAL_ANTIGO
		oObj:nQatuOrigem    := (cAlias)->QATU_ANTIGO
		oObj:nReservaOrigem	:= (cAlias)->RESEVA_ANTIGO
		oObj:nQaclasOrigem  := (cAlias)->QACLASS_ANTIGO

		oObj:cProdDestino      := (cAlias)->PROD_NOVO
		oObj:cLocalDestino     := (cAlias)->LOCAL_NOVO
		oObj:nQatuDestino      := (cAlias)->QATU_NOVO
		oObj:nReservaDestino   := (cAlias)->RESEVA_NOVO
		oObj:nQaclasDestino    := (cAlias)->QACLASS_NOVO
		
		::oLista:Add(oObj)
		
		(cAlias)->(DbSkip())
		
	EndDo
	
	(cAlias)->(DbCloseArea())

Return(::oLista)

Method BloqueioPrdOrigem(cProduto) Class TPDMTransferencia

	If SB1->(DbSeek(xFilial("SB1") + cProduto))

		If SB1->B1_MSBLQL <> "1"
		
			::nTotOk++
		
			Reclock("SB1")
			SB1->B1_MSBLQL := "1"
			SB1->(MSunlock())
		
			::cLog += "Retorno..........: " + "Efetuado bloqueio produto Original." + CRLF
		
		Else
		
			::nTotSemEfei++
		
			::cLog += "Retorno..........: " + "Produto de origem ja esta bloqueado!" + CRLF
		
		EndIf
		
	Else
	
		::cLog += "Retorno..........: " + "Produto de origem nao encontrado para bloqueio." + CRLF
		
	EndIf
				
Return()

Method Transferencia(oList) Class TPDMTransferencia

	Local aAuto		:= {}
	Local aLinha 	:= {}
	Local nW		:= 0
	Local cPath		:= GetSrvProfString("Startpath","")
	Local cFileLog	:= Criatrab(,.F.) + ".log"
	Local cYLocaliz	:= ""
	
	Private lMsErroAuto := .F.
	
	If oList:cFil <> cFilAnt 
		
		RpcSetEnv("01", "01")
	
	EndIf
	
	::cLog += PadL("", 70, "-") + CRLF
	::cLog += "Produto Origem...: " + oList:cProdOrigem + " - Armazem..: " + oList:cLocalOrigem + CRLF
	::cLog += "Produto Destino..: " + oList:cProdDestino + CRLF
				
	//Origem 
	If SB1->(DbSeek(xFilial("SB1") + oList:cProdOrigem))
	
		cYLocaliz := SB1->B1_YLOCALIZ
	
		If oList:nQatuOrigem > 0
			
			aAdd(aAuto, {GetSxeNum("SD3", "D3_DOC"), dDataBase})
		
			aLinha := {}
		
			aAdd(aLinha, {"ITEM"		, '0001'				, Nil})
			aAdd(aLinha, {"D3_COD"		, SB1->B1_COD			, Nil}) //Cod Produto origem 
			aAdd(aLinha, {"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto origem 
			aAdd(aLinha, {"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida origem 
			aAdd(aLinha, {"D3_LOCAL"	, oList:cLocalOrigem	, Nil}) //armazem origem 
			aAdd(aLinha, {"D3_LOCALIZ"	, PadR("", TamSx3('D3_LOCALIZ')[1]), Nil}) //InFormar endereço origem
		
			//Destino 
			If SB1->(DbSeek(xFilial("SB1") + oList:cProdDestino))
			
				Reclock("SB1")
				SB1->B1_YLOCALIZ := cYLocaliz
				SB1->(MSunlock())
			
				If !SB2->(DbSeek(xFilial("SB2") + oList:cProdDestino + oList:cLocalOrigem))
					
					CriaSB2(oList:cProdDestino, oList:cLocalOrigem)
				
					::cLog += "Retorno..........: " + "Criado SB2 do produto destino." + CRLF
		
				EndIf
				
				aAdd(aLinha, {"D3_COD"		, SB1->B1_COD			, Nil}) //cod produto destino 
				aAdd(aLinha, {"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto destino 
				aAdd(aLinha, {"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida destino 
				aAdd(aLinha, {"D3_LOCAL"	, oList:cLocalOrigem	, Nil}) //armazem destino 
				aAdd(aLinha, {"D3_LOCALIZ"	, PadR("", TamSx3('D3_LOCALIZ')[1]), Nil}) //InFormar endereço destino
			
				aAdd(aLinha, {"D3_NUMSERI"	, ""				, Nil}) //Numero serie
				aAdd(aLinha, {"D3_LOTECTL"	, ""				, Nil}) //Lote Origem
				aAdd(aLinha, {"D3_NUMLOTE"	, ""				, Nil}) //sublote origem
				aAdd(aLinha, {"D3_DTVALID"	, ''				, Nil}) //data validade 
				aAdd(aLinha, {"D3_POTENCI"	,  0				, Nil}) // Potencia
				aAdd(aLinha, {"D3_QUANT"	,  oList:nQatuOrigem, Nil}) //Quantidade
				aAdd(aLinha, {"D3_QTSEGUM"	,  0				, Nil}) //Seg unidade medida
				aAdd(aLinha, {"D3_ESTORNO"	, ""				, Nil}) //Estorno 
				aAdd(aLinha, {"D3_NUMSEQ"	, ""				, Nil}) // Numero sequencia D3_NUMSEQ
			
				aAdd(aLinha, {"D3_LOTECTL"	, "", Nil}) //Lote destino
				aAdd(aLinha, {"D3_NUMLOTE"	, "", Nil}) //sublote destino 
				aAdd(aLinha, {"D3_DTVALID"	, '', Nil}) //validade lote destino
				aAdd(aLinha, {"D3_ITEMGRD"	, "", Nil}) //Item Grade
			
				aAdd(aLinha, {"D3_CODLAN"	, "", Nil}) //cat83 prod origem
				aAdd(aLinha, {"D3_CODLAN"	, "", Nil}) //cat83 prod destino 
			
				aAdd(aAuto, aLinha)
			
				MSExecAuto({|x,y| Mata261(x,y)}, aAuto, 3)
			
				If lMsErroAuto
		
					::cLog += "Retorno..........: " + AllTrim(MostraErro(cPath, cFileLog) + CRLF)
					
				Else
					
					::BloqueioPrdOrigem(oList:cProdOrigem)
					
					::cLog += "Retorno..........: " + "Processo concluido!" + CRLF
									
				EndIf
				
			Else
	
				::cLog += "Retorno..........: " + "Produto Destino não encontrado." + CRLF
			
			EndIf
		
		Else
		
			::cLog += "Retorno..........: " + "Quantidade produto Origem zerado." + CRLF
		
			If !SB2->(DbSeek(xFilial("SB2") + oList:cProdDestino + oList:cLocalOrigem))
					
				CriaSB2(oList:cProdDestino, oList:cLocalOrigem)
				
				::cLog += "Retorno..........: " + "Criado SB2 do produto destino." + CRLF
		
			EndIf
			
			::BloqueioPrdOrigem(oList:cProdOrigem)
			
			::cLog += "Retorno..........: " + "Processo concluido!" + CRLF
			
		EndIf
		
	Else
		
		::cLog += "Retorno..........: " + "Produto Origem não encontrado." + CRLF
	
	EndIf
	
	If oList:cFil <> cFilAnt 
		
		RpcClearEnv()
	
	EndIf
	
Return()

User Function PDMTRANS()

	Local oBj := TPDMTransferencia():New()
	
	oBj:Show()

Return()