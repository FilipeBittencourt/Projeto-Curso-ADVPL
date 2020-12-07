#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} MT250GREST
@author Gabriel Rossi Mafioletti
@since 29/05/2018
@version 1.0
@description Ponto de Entrada após o estorno de produção simples
@type function
/*/


User Function MT250GREST()

	Local _cAlias	:= GetNextAlias()
	
	BeginSql Alias _cAlias
		%NoParser%
		SELECT DISTINCT D3EMB.D3_DOC
		,D3EMB.D3_COD
		FROM (
			SELECT SD3.*
			FROM %TABLE:SD3% SD3 WITH (NOLOCK)
			JOIN %TABLE:SB1% SB1 WITH (NOLOCK) ON SD3.D3_COD = SB1.B1_COD
			WHERE SD3.%NotDel%
				AND SB1.%NotDel%
				AND SB1.B1_MSBLQL <> '1'
				AND SB1.B1_YEMPEST = '0501'
				AND SB1.B1_YCATEG = 'O'
				AND SD3.D3_DOC = %Exp:SD3->D3_DOC%
				AND SD3.D3_FILIAL = %XFILIAL:SD3%
				AND D3_TM = '010'
			) PRODUC
		JOIN %TABLE:SD3% D3EMB ON D3EMB.D3_FILIAL = PRODUC.D3_FILIAL 
			AND D3EMB.D3_YOBS LIKE '%' + PRODUC.D3_NUMSEQ + '%'
			AND D3EMB.D3_EMISSAO = PRODUC.D3_EMISSAO
			AND D3EMB.D3_ESTORNO = ''
			AND D3EMB.D3_LOCAL = '07'
			AND D3EMB.D3_GRUPO = '104A'
	EndSql

	While (_cAlias)->(!EOF())
		fEstorna((_cAlias)->D3_DOC, (_cAlias)->D3_COD)
		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())
	
	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
	
		SELECT *
		FROM %TABLE:Z18% Z18
		WHERE Z18_FILIAL = %XFILIAL:Z18%
			AND Z18_DOCSD3 = %Exp:SD3->D3_DOC%
			AND Z18_NSQSD3 = %Exp:SD3->D3_NUMSEQ%
			AND Z18_TM = 'PR0'
			AND %NotDel%
	
	EndSql
	
	If (_cALias)->(!EOF())
		fEstornaPP((_cALias)->Z18_DCD3PP,(_cAlias)->Z18_SQD3PP)
		While (_cAlias)->(!EOF())
			Z18->(DbGoTo((_cAlias)->R_E_C_N_O_))
			If Z18->(!EOF())
				Reclock("Z18",.F.)
				Z18->(DbDelete())
				Z18->(MsUnlock())
			EndIf
			(_cAlias)->(DbSkip())
		EndDo
	EndIf
	
	(_cAlias)->(DbCloseArea())
Return

Static Function fEstornaPP(_cDoc,_cNSeq)

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local aAuto		:=	{}
	
	BeginSql Alias _cAlias
		SELECT *
		FROM %TABLE:SD3%
		WHERE D3_FILIAL = %XFILIAL:SD3%	
			AND D3_DOC = %Exp:_cDoc%
			AND D3_NUMSEQ = %Exp:_cNseq%
			AND D3_TM = '010'
			AND D3_ESTORNO = ''
			AND %NotDel%
	EndSql

	If (_cAlias)->(!EOF())
		
		lMSHelpAuto := .T.
		lMSErroAuto := .F.

		cFiltro := " D3_DOC = '"+(_cAlias)->D3_DOC+"' .AND. D3_OP = '"+(_cAlias)->D3_OP+"' .AND. D3_NUMSEQ = '"+(_cAlias)->D3_NUMSEQ+"'  "

		dbSelectArea("SD3")
		Set Softseek On

		dbSetOrder(5)
		DbSetFilter({|| &cFiltro},cFiltro)
		dbSetOrder(5)
		dbGoTop()

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (_cAlias)->D3_COD))
		dbSelectArea("SD3")
		dbSetOrder(5)
		aAuto :={ {  "D3_TM"       , "010"                   ,NIL},;
		{                 "D3_COD"      , (_cAlias)->D3_COD            ,NIL},;
		{                 "D3_OP"       , (_cAlias)->D3_OP             ,NIL},;
		{                 "D3_DOC"      , (_cAlias)->D3_DOC            ,NIL} }
		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		msExecAuto({|x,Y| Mata250(x,Y)}, aAuto, 5)

		If lMsErroAuto
			MsgInfo("Erro no Estorno do PP. Favor proceder manualmente! ")
			MostraErro()
		Else
			MsgInfo("Produção do PP Vinculado ao PA estornada!")      
		EndIf
		SD3->(DbClearFilter())
		Set Softseek Off
		
		
	EndIf
	(_cAlias)->(DbCloseArea())
	RestArea(_aArea)
Return

Static Function fEstorna(_cDoc,_cProd) 

	Local aAUTO := {} 
	Local _aArea	:=	GetArea()
	Private lMsErroAuto := .F.                                           
	
	DbSelectArea("SD3") 
	SD3->(DbSetOrder(2)) 
	If SD3->(DbSeek(xFilial("SD3")+_cDoc+_cProd)) 
	
		aAuto := {}                          
		MSExecAuto({|x,y| mata261(x,y)},aAuto,6) 
		
		If !lMsErroAuto      
		     MsgInfo("Haviam Embalagens vinculadas à OP e as mesmas tiveram seu movimento de transferência estornado! ")      
		Else      
		     MsgInfo("Erro no Estorno de Transferência de Embalagem! ")       
		     MostraErro() 
		EndIf 
	
	EndIf
	
	RestArea(_aArea)

Return