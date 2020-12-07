#INCLUDE "TOTVS.CH"
#Include 'PROTHEUS.CH'
#Include "tbiconn.ch"
#include "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIAPN002
@description Relatório com justificativas das aprovações realizadas para retirada de EPI´s não previstos ou retirados fora do prazo. (Ticket 24870)
@author Pablo S. Nascimento
@since 01/07/2020
@version 1.0
@type function
/*/

User Function BIAPN002()

	Local cSQL := ""
	Local cQry := "cQry"
	Local oExcel := nil
	private aPergs := {}
	
	//RpcSetType(3)
	//RpcSetEnv("01","01")
	
	If !fValidPerg()
		Return
	EndIf
	
	oExcel := FWMSEXCEL():New()
	
	nxPlan := "Planilha 01" //nome da planilha
	nxTabl := "Justificativas das aprovações para retiradas de EPIs não previstos - Período " + DTOC(MV_PAR01) + " - " + DTOC(MV_PAR02) //nome no header da tabela
	
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	
	//adicionando colunas
	oExcel:AddColumn(nxPlan, nxTabl, "ID PRE-REQUISICAO"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA SOLICITAÇÃO"			,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "DOCUMENTO"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOCUMENTO PROTHEUS"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATRÍCULA SOL."			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SOLICITANTE"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD PRODUTO"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"					,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATRÍCULA APROV."			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "APROVADO POR"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "JUSTIFICATIVA"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA DA APROVAÇÃO"		,1,4)
	
	//consulta dos dados
	cSQL := "SELECT [idPreRequisicao] IDPREREQUISICAO, 																										"			
	cSQL += "       [DatadaSolilcitacao] DATASOLICITACAO, 																									"							
	cSQL += "       [Documento] DOCUMENTO, 																													"	
	cSQL += "       [DocumentoProthues] DOCUMENTOPROTHEUS, 																									"						
	cSQL += "       SO.Matricula MATRICULA, 																												"				
	cSQL += "       SO.Nome NOME, 																															"		
	cSQL += "       LTRIM(RTRIM(PD.Codigo)) CODIGOPRD,																										"
	cSQL += "       LTRIM(RTRIM(PD.Descricao)) AS PRODUTO,																									"						
	cSQL += "       UPPER(UA.fullName) AS APROVADOPOR, 																										"
	cSQL += "       UPPER(UA.Matricula) AS MATRICULAAPROV,  																								"	   
	cSQL += "       ISNULL([Justificativa], '') AS JUSTIFICATIVA, 																							"
	cSQL += "       [DatadaAprovacao] DATAAPROVACAO																											"
	cSQL += "FROM ZEUS.BIZAGIPRD.dbo.[PreRequisicao] PR																										"
	cSQL += "     INNER JOIN ZEUS.BIZAGIPRD.dbo.VW_PVApp P ON P.PreRequisicao = PR.idPreRequisicao															"
	cSQL += "     INNER JOIN ZEUS.BIZAGIPRD.dbo.VW_WFCASE W ON W.idCase = P.idCase																			"
	cSQL += "     LEFT JOIN ZEUS.BIZAGIPRD.dbo.[WFUSER] UA ON UA.idUser = PR.Avaliadopor																	"
	cSQL += "     INNER JOIN ZEUS.BIZAGIPRD.dbo.[ProdutosPreRequisitados] PPR ON PR.idPreRequisicao = PPR.PreRequisicao										"
	cSQL += "     INNER JOIN ( SELECT EK.idVW_BZ_PRODUTO, P.* 																								"
	cSQL += "				   FROM ZEUS.BIZAGIPRD.dbo.[VW_BZ_PRODUTO] P 																					"
	cSQL += "				   INNER JOIN ZEUS.BIZAGIPRD.dbo.[VW_BZ_PRODUTO_EK] EK ON EK.Codigo = P.Codigo 													"
	cSQL += "																   AND EK.Empresa = P.Empresa ) PD ON PD.idVW_BZ_PRODUTO = PPR.Produto			"
	cSQL += "     INNER JOIN ( SELECT EK.idVW_BZ_PRQREQ,  P.* 																								"
	cSQL += "				   FROM ZEUS.BIZAGIPRD.dbo.[VW_BZ_PRQREQ] P 																					"
	cSQL += "				   INNER JOIN ZEUS.BIZAGIPRD.dbo.[VW_BZ_PRQREQ_EK] EK ON EK.Matricula = P.Matricula ) SO ON SO.idVW_BZ_PRQREQ = PR.Matricula	"
	cSQL += "WHERE PD.Tipo = 'EP'																															"
	cSQL += "      AND PR.AprovarRequisicao = 1																												"
	cSQL += "      AND W.idCaseState NOT IN (4)																												"
	cSQL += "	   AND [DatadaAprovacao] BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'															"
	
	if(!Empty(Alltrim(MV_PAR03)))
		cSQL += "	   AND  UA.Matricula = '" + Alltrim(MV_PAR03) + "'																										"
	endif
	
	cSQL += "ORDER BY DATASOLICITACAO DESC																													"
 
	TcQUERY cSQL New ALIAS cQry

	While (cQry)->(!Eof())			
			
		oExcel:AddRow(nxPlan, nxTabl, { cQry->IDPREREQUISICAO,;
										cQry->DATASOLICITACAO,;
										cQry->DOCUMENTO,;
										cQry->DOCUMENTOPROTHEUS,;
										cQry->MATRICULA,;
										cQry->NOME,;
										cQry->CODIGOPRD,;
										cQry->PRODUTO,;
										cQry->MATRICULAAPROV,;
										cQry->APROVADOPOR,;
										cQry->JUSTIFICATIVA,;
										cQry->DATAAPROVACAO})
	
		cQry->(DbSkip())

	End
	
	cQry->(dbCloseArea())
	Gravar(oExcel)
	
	//RESET ENVIRONMENT
	
Return

Static Function Gravar(oExcel)
		
	xArqTemp := "Just_aprov_retiradas_EPI_" + dtos(MV_PAR01)+"_"+ dtos(MV_PAR02)
	caminho := "C:\TEMP\"+xArqTemp+".xml"
	
	If File(caminho)
		If fErase(caminho) == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + caminho + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
	
	oExcel:Activate()
	oExcel:GetXMLFile(caminho)
	
	/* abrir automaticamente no Excel - se for chamado de um job, comentar esse trecho*/
	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+caminho )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open(caminho) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

Static Function fValidPerg()

	local cLoad	    := "BIAPN002"
	local cFileName := RetCodUsr() + "_JustificAprovRetiradasEPI_"+cEmpAnt
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := '        '
	
	aAdd( aPergs ,{1,"Dt Aprovação Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Dt Aprovação Final   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Matricula Aprovador: ", MV_PAR03, "", 			, "ZZY", '.T.', 50, .F.})

	If ParamBox(aPergs ,"Justificativas de Aprov. para retiradas de EPI",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		
		MV_PAR03 := PadL(Alltrim(MV_PAR03), 8, ' ')
		
		if(!Empty(Alltrim(MV_PAR03)))
			MV_PAR03 := SUBSTR(MV_PAR03, 3, 6)
		endif

	EndIf
Return lRet