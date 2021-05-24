#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"

User Function PFAF0003()
	
	Local aArea 		:= Nil
	
	
	RpcSetEnv("01", "01")
		aArea 		:= GetArea()
		
		Conout("PFAF0003:  Verificar sacado não integrado - "+dtoc(Date()))
		Processa()
		
		RestArea( aArea )
	RpcClearEnv()
	
		
Return()
	
Static Function Processa()	
	
	Local cAliasTemp		:= Nil
	Local cQuery			:= ""
	
	cQuery	+= " select Nome=Convert(varchar(200), Nome), CodigoERP=Convert(varchar(6), CodigoERP), Erro=Convert(varchar(500), MensagemRetorno)			"	
	cQuery	+= " from [BPORTAL_SA].[dbo].[Sacado]						"
	cQuery	+= " WHERE 													" 
	cQuery	+= "  		StatusIntegracao						= 3		" 
	cQuery	+= "  and	Habilitado								= 1		" 
	
	
	cAliasTemp		:= GetNextAlias()
	TcQuery cQuery New Alias cAliasTemp	
		
	While !(cAliasTemp->(Eof()))
		
		cNome				:= AllTrim(cAliasTemp->Nome)
		cCodigoERP			:= AllTrim(cAliasTemp->CodigoERP) 
		cErro				:= AllTrim(cAliasTemp->Erro)
		
		Workflow(cNome, cCodigoERP, cErro) 
			
		cAliasTemp->(DbSkip())
		
	EndDo
	
	cAliasTemp->(DbCloseArea())

Return()

Static function Workflow(cNome, cCodigo, cErro) 
	
	Local cHtml := ""
    Local oMail := TAFMail():New()
    
    cHtml += '<style type="text/css">'
    cHtml += '.tg  {border-collapse:collapse;border-color:#aaa;border-spacing:0;}'
    cHtml += '.tg td{background-color:#fff;border-color:#aaa;border-style:solid;border-width:1px;color:#333;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg th{background-color:#f38630;border-color:#aaa;border-style:solid;border-width:1px;color:#fff;'
    cHtml += '  font-family:Arial, sans-serIf;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'
    cHtml += '.tg .tg-zw5y{border-color:inherit;text-align:center;text-decoration:underline;vertical-align:top}'
    cHtml += '.tg .tg-0lax{text-align:left;vertical-align:top}'
    cHtml += '</style>'

    cHtml += '<table class="tg" width="100%">'
    cHtml += '   <thead>'
    cHtml += '      <tr>'
    cHtml += '         <th class="tg-zw5y" colspan="3" style="width: 99.8856%;">'
    cHtml += '            <div style="text-align: center;">ERRO - INTEGRAÇÃO PORTAL</div>'
    cHtml += '         </th>'
    cHtml += '      </tr>'
    cHtml += '   </thead>'
    cHtml += '   <tbody>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Cliente</strong></td>'
    cHtml += '         <td colspan="2">' + cNome +'/'+cCodigo+ '</td>'
    cHtml += '      </tr>'
    cHtml += '      <tr>'
    cHtml += '         <td><strong>Erro</strong></td>'
    cHtml += '         <td colspan="2">' + cErro + '</td>'
    cHtml += '      </tr>'
    cHtml += '   </tbody>'
    cHtml += '</table>'

    oMail:cTo :=U_EmailWF('EIPORTAL', cEmpAnt)
    
    Conout(oMail:cTo)
    oMail:cSubject := "Integração Cliente Portal"
    oMail:cBody := cHtml

    oMail:Send()
    
Return()