#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//--------------------------------------------------------------------------
User Function BIA199()

/*
Private oBrowse 		:= FWBrowse():New()
Private lPodeIncluir  	:= .F.
Private lCarMestre		:= .F.
Private lCarDetal		:= .F.
Private cNovoId			:= ''
                                                  
NEW MODEL ; 
TYPE 2 ; 
DESCRIPTION "Composição de Carregamento" BROWSE oBrowse ;
SOURCE "BIA199" ; 
MODELID "BIA199M" ;
MASTER "Z43" ;
HEADER { 'Z43_TKT','Z43_EMPPES'} ;
RELATION { { 'Z43_FILIAL', 'xFilial("Z43")' }, {'Z43_TKT', 'Z43_TKT'}} ;
PRIMARYKEY { 'Z43_FILIAL','Z43_TKT','Z43_PESAGE', 'Z43_EMPPES'};
UNIQUELINE { 'Z43_EMPR', 'Z43_PESAGE'};
ORDERKEY Z43->( IndexKey( 1 ) )
*/

Return Nil

//--------------------------------------------------------------------------
User Function BIA199M()

	Local aParam := PARAMIXB
	
	Local oModel 		:= FWModelActive()
	Local oView 		:= FWViewActive()
	Local aSaveLines 	:= FWSaveRows()
	Local xRet 			:= .T.
	Local lIsGrid 		:= .F.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local nOperation 	:= -1
	Local oObj 		
	Local oModeloZ43
	Local oModeloGRID
	Local cStInicio  	:= 'MODELPRE_FORMPRE_FORMLINEPRE'
	Local cStConfirm 	:= 'MODELPOS_FORMPOS_FORMLINEPOS_MODELCOMMITTTS_FORMCOMMITTTSPOS_FORMCOMMITTTSPRE'
	Local cEmpVld	 	:= '0101_0501_1301'

	    //----------------------------------------------------------------------------
		//	MODELPRE 			- antes da alteração de qualquer campo do modelo
		//	MODELPOS 			- na validação total do modelo
		// 	FORMPRE  			- antes da alteração de qualquer campo do formulario
		//	FORMPOS  			- na validação total do formulario
		//	FORMLINEPRE 		- antes da alteração da linha do formulario FWFORMGRID            
		//	FORMLINEPOS 		- na validação total da linha do formulario FWFORMGRID
		//	MODELCOMMITTTS 		- após a gravação total do modelo e dentro da transação
		//  MODELCOMMITNTTS 	- após a gravação total do modelo e fora da transação
		//	FORMCOMMITTTSPRE 	- antes da gravação da tabela do formulário
		//	FORMCOMMITTTSPOS 	- após a gravação da tabela do formulário
		//	FORMCANCEL 			- no cancelamento do botão
		//	MODELVLDACTIVE 		- na ativação do modelo
		//	BUTTONBAR 			- para a inclusão de botões na ControlBar
		//----------------------------------------------------------------------------
		
	if oModel <> NIL
		nOperation 	:= oModel:GetOperation()
		oModeloZ43 	:= oModel:GetModel('BIA199_Z43')
		oModeloGRID := oModel:GetModel('BIA199_GRID')
	EndIf
	
	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto 	:= aParam[2]
		cIdModel 	:= aParam[3]
		lIsGrid 	:= ( Len( aParam ) > 3 )
		
		//se form... 
		If (oModeloZ43 <> Nil) .And. cIdModel == 'BIA199_Z43'
			if Inclui .And. cIdPonto $ cStInicio
			    // ao Carregar a tela e ao Editar a tela é chamado esse evento.
				If cIdPonto == 'FORMPRE' //pre-validação do Form.
					if nOperation  == 3
                    	lCarMestre		:= .T.
					EndIf
				EndIf
			EndIf
			If cIdPonto == 'MODELCANCEL'
				lCarMestre		:= .F.
			EndIf
		EndIf
		
		//se grid...
		If oModeloGRID <> NIL .And. cIdModel == 'BIA199_GRID'
			If Inclui
				
				If cIdPonto == 'FORMPRE' //pre-validação do Form.
					If nOperation  == 3
                    	lCarDetal := .T.
					EndIf
				EndIf
				
				If cIdPonto == 'MODELCANCEL'
					lCarDetal := .F.
				EndIf
			EndIf
			
			If Inclui .Or. Altera
				If cIdPonto == 'FORMLINEPRE' // pre-validação da Linha
					cLinEvent  	:= aParam[5]	
					cFieldGrid 	:= aParam[6]
					nPosEMPR  	:= aScan( oObj:aHeader, { |x| AllTrim( x[2] ) == 'Z43_EMPR' 	} )
					nPosPES  	:= aScan( oObj:aHeader, { |x| AllTrim( x[2] ) == 'Z43_PESAGE' 	} )
					nLin 		:= oObj:nLine
					
					If cFieldGrid == 'Z43_EMPR'
						If (oObj:aHeader <> NIL)
							
							cAuxEmp := oModeloGRID:GetValue("Z43_EMPR")
							cAuxPes := oModeloGRID:GetValue("Z43_PESAGE")
							
							if !Empty(cAuxPes) .And. (Altera .Or. cLinEvent == 'CANSETVALUE')
								MsgStop("Não é possível alterar/exluir o campo Empresa. Favor excluir primeiramente o TICKET.","Informação")
				    			xRet := .F.
							ElseIf !Empty(cAuxPes) .And. !Empty(cAuxEmp)
								xRet := ValidLin(cAuxEmp,cAuxPes, oObj)
							EndIf
							/*Elseif (Empty(cAuxEmp) .Or. ! (cAuxEmp $ cEmpVld)) .And. cLinEvent == 'SETVALUE'  
								MsgStop("Favor informar uma empresa de pesagem válida.","Informação")
				    			xRet := .F.
							EndIf*/
															
						EndIf 
					EndIf
					If cFieldGrid == 'Z43_PESAGE'
						If (oObj:aHeader <> NIL)
							
							cAuxEmp := oModeloGRID:GetValue("Z43_EMPR")
							cAuxPes := oModeloGRID:GetValue("Z43_PESAGE")
							                           
							if (Empty(cAuxEmp) .Or. ! (cAuxEmp $ cEmpVld)) .And. cLinEvent == 'CANVALUE'  
								MsgStop("Favor informar uma empresa de pesagem válida.","Informação")
				    			xRet := .F.
				    		Else
				    			If !Empty(cAuxPes) .And. cLinEvent == 'SETVALUE'
				    				xRet := ValidLin(cAuxEmp,cAuxPes, oObj)
				    			EndIf		    			
							EndIf
						EndIf
					EndIF
				EndIf
			EndIf
		EndIf
		
		lPodeIncluir := lCarMestre .And. lCarDetal
	
		if lPodeIncluir .And. Empty(cNovoId)
			If(oModeloZ43 <> Nil) 
				cNovoId := GetProxId()
				xRet := oModeloZ43:SetValue('Z43_TKT', cNovoId) 
				lCarMestre := .F.  
				lCarDetal := .F.
				oView:Refresh()
				Return xRet					
			EndIf
		EndIf
		
		If cIdPonto $ 'MODELCOMMITTTS_MODELCANCEL' .And. Inclui
			cNovoId 	:= ''
			lCarMestre	:= .F.
			lCarDetal 	:= .F.	
		EndIf	
	EndIf
	
Return xRet
//--------------------------------------------------------------------------
Static Function GetProxId()
	Local aArea := GetArea()

	if Empty(cNovoId) 
		dbSelectArea("Z43")
		if Z43->(EOF())
			cNovoId := '000001'
		Else
			Z43->(DBGoBottom ( ))
			cNovoId := Soma1(Z43->Z43_TKT)
		EndiF
		Z43->(dbCloseArea())
	EndIf
	RestArea( aArea )
Return cNovoId
//--------------------------------------------------------------------------
Static Function ValidLin(cAuxEmp,cAuxPes, oObj)
Local nAuxLin 	:= oObj:nLine
Local cFilPes 	:= ''
Local cFilEmp 	:= ''
Local cVWPES 	:= GetNextAlias()
Local lRet 		:= .T.
    				
If Len(oObj:aCols)>1
	If nAuxLin != 1
		cFilPes := oObj:GetValue("Z43_PESAGE", 1) //oObj:aCols[1][nPosPES] 
		cFilEmp	:= oObj:GetValue("Z43_EMPR", 1) //oObj:aCols[1][nPosEMPR]
	Else
		cFilPes := oObj:GetValue("Z43_PESAGE", 2)
		cFilEmp	:= oObj:GetValue("Z43_EMPR", 2)
	EndIf
EndIf

cSql :="	SELECT COUNT(0) AS QTD 
cSql +=" 	FROM Z43010 Z43 WITH(NOLOCK)
cSql +=" 	WHERE Z43_PESAGE 	= '" +cAuxPes + "' "
cSql +=" 	AND Z43_EMPR   		= '" +cAuxEmp + "' "
cSql +=" 	AND Z43.Z43_TKT  <> '"+ cValToChar(Z43->Z43_TKT) + "' "
//cSql +=" 	AND Z43.R_E_C_N_O_  <> '"+ cValToChar(Z43->(RECNO())) + "' "
cSql +="	AND Z43.D_E_L_E_T_ = ''

TCQUERY cSql ALIAS "_Z43" NEW
dbSelectArea("_Z43")
dbGoTop()
 
If _Z43->QTD > 0
	MsgStop("Essa pesagem foi cadastrada. Favor informar uma pesagem válida.","Informação")
	lRet := .F.
EndIf
_Z43->(DbCloseArea())

//--> SQL    				
If lRet
	BeginSql ALIAS cVWPES
	
	   /*SELECT COUNT(0) AS QTD 
	   FROM VW_ZZV_EMP P1
	   INNER JOIN VW_ZZV_EMP P2	 ON P2.ZZV_PLACA = P1.ZZV_PLACA AND P2.ZZV_DATINC  = P1.ZZV_DATINC
	   WHERE 	P1.ZZV_DATINC	= %EXP:dDatabase%
	   AND 		P1.EMPRESA 		= %EXP:cAuxEmp%	
	   AND		P1.ZZV_TICKET	= %EXP:cAuxPes% 
	   AND 		(P2.EMPRESA 	= %EXP:cFilEmp% OR %EXP:cFilEmp% = '' ) 
	   AND 		(P2.ZZV_TICKET  = %EXP:cFilPes% OR %EXP:cFilPes% = '' )
	   */ 				
	   SELECT COUNT(0) AS QTD 
	   FROM VW_Z11_EMP P1 
	   INNER JOIN VW_Z11_EMP P2	  ON P2.Z11_PCAVAL = P1.Z11_PCAVAL
	   INNER JOIN VW_ZZV_EMP ZZV  ON ZZV.EMPRESA   = P2.EMPRESA    AND ZZV.ZZV_TICKET = P2.Z11_PESAGE
	   WHERE 	P1.Z11_DATAIN BETWEEN %EXP:dDatabase-1% AND %EXP:dDatabase%
	   AND 		P2.Z11_DATAIN BETWEEN %EXP:dDatabase-1% AND %EXP:dDatabase%
	   AND 		P1.EMPRESA 		= %EXP:cAuxEmp%	
	   AND		P1.Z11_PESAGE	= %EXP:cAuxPes% 
	   AND 		(P2.EMPRESA 	= %EXP:cFilEmp% OR %EXP:cFilEmp% = '' ) 
	   AND 		(P2.Z11_PESAGE  = %EXP:cFilPes% OR %EXP:cFilPes% = '' )
	EndSql
	//<-- SQL
	
	If (cVWPES)->(QTD) == 0
		MsgStop("Favor informar uma pesagem válida desta empresa.","Informação")
		lRet := .F.
	EndIf
	
	(cVWPES)->(DbCloseArea())
	
EndIf

If lRet
	
	BeginSql ALIAS cVWPES
	
		SELECT COUNT(0) AS QTD
    	FROM   VW_ZZV_EMP
    	WHERE  EMPRESA 	= %EXP:cAuxEmp%
    	AND ZZV_TICKET	= %EXP:cAuxPes% 
    
	EndSql
	
	If (cVWPES)->(QTD) > 1
		MsgStop("Este Ticket é Composto e não pode ser associado a uma Carga Composta!","Informação")
		lRet := .F.
	EndIf
	
	(cVWPES)->(DbCloseArea()) 
EndIf	
	
Return lRet
//--------------------------------------------------------------------------