#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TAFApiImprimirBoleto from LongClassName
	
	Method New() Constructor
	Method GetPDF()
	Method DadosPorId(Id, DataRef)

EndClass


Method New() Class TAFApiImprimirBoleto

Return()


//Metodo Privado
Method DadosPorId(cListaId, DataRef) Class TAFApiImprimirBoleto
	
	Local ImpBolDados	:= Nil
	Local cCnpj			:= SM0->M0_CGC
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local nValorAbat	:= 0
	Local dDataVenc		:= Date() 
	Local nValorAcres	:= 0
	Local nValorDesc	:= 0
	Local nValorOri		:= 0
	Local oRecAnt		:= TRecebimentoAntecipado():New()
	Local aListaBol		:= TAFApiImprimirBoletoListaDados():New()
	Local cRegistro		:= ""
	
	cQuery	+= "SELECT * FROM "+RetSQLName("SE1")+"					"
	cQuery	+= " WHERE 												" 
	cQuery	+= " R_E_C_N_O_	IN "+FormatIn(cListaId,'_')+"			" 
	
	TcQuery cQuery New Alias cAliasTrab	
		
	While !(cAliasTrab->(Eof()))
	
		ImpBolDados := TAFApiImprimirBoletoDados():New()
		 
		ImpBolDados:Banco 			:= AllTrim(cAliasTrab->E1_PORTADO)
		ImpBolDados:CNPJ	 		:= AllTrim(cCnpj)   
		ImpBolDados:Convenio 		:= ""//Alltrim(cAliasTrab->E1_PORTADO) + Alltrim(cAliasTrab->E1_AGEDEP) + Alltrim(cAliasTrab->E1_CONTA)   
		ImpBolDados:NossoNumero 	:= AllTrim(cAliasTrab->E1_NUMBCO)	 
		ImpBolDados:NumConPar		:= cValToChar(cAliasTrab->R_E_C_N_O_)
		ImpBolDados:ValorJuros 		:= 0
		ImpBolDados:ValorAcrescimo	:= 0
		ImpBolDados:ValorDesconto	:= 0
		ImpBolDados:MsgInstrucoes	:= ""
		
		dDataVenc := stod(cAliasTrab->E1_VENCTO)
		
		ImpBolDados:DataVenc	:= dDataVenc 		
		
		
		If dDataVenc < DataRef
			
			cRegistro := cAliasTrab->E1_PREFIXO+"/"+cAliasTrab->E1_NUM+"/"+cAliasTrab->E1_PARCELA
			
			If MsgNOYES("Deseja calcular o juros para este registro ("+cRegistro+")?")
				ImpBolDados:ValorJuros	:= NOROUND(cAliasTrab->E1_PORCJUR * cAliasTrab->E1_VALOR/100, 2) * (DataRef-dDataVenc) 
			
				nValorAbat := SomaAbat(cAliasTrab->E1_PREFIXO, cAliasTrab->E1_NUM, cAliasTrab->E1_PARCELA,"R", 1, , cAliasTrab->E1_CLIENTE, cAliasTrab->E1_LOJA)		
			
				nValorOri				:= cAliasTrab->E1_SALDO - nValorAbat
				ImpBolDados:DataVenc	:= DataRef 
				ImpBolDados:ValorTitulo	:= cAliasTrab->E1_SALDO + ImpBolDados:ValorJuros - nValorAbat 
				
				
				If oRecAnt:TituloPr(cAliasTrab->E1_NUMBCO) .And. cAliasTrab->E1_DECRESC > 0
				
					nValorDesc					:= cAliasTrab->E1_DECRESC
					ImpBolDados:ValorDesconto	:= nValorDesc
					ImpBolDados:ValorTitulo		:= ImpBolDados:ValorTitulo - nValorDesc
				
				EndIf
				
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+cAliasTrab->E1_CLIENTE+cAliasTrab->E1_LOJA,.T.))
				
				If SA1->A1_YTFGNRE == "S" //Apenas para clientes com cobranca de GNRE
					
					If cAliasTrab->E1_YCLASSE == "1"
						
						oTafNFRE	:= TAFTarifaGNRE():New()
						nValorAcres	:= oTafNFRE:TarifaPorEstado(cAliasTrab->E1_YUFCLI)
						
						ImpBolDados:ValorAcrescimo	:= nValorAcres
						ImpBolDados:ValorTitulo		:= ImpBolDados:ValorTitulo + nValorAcres
				
					EndIf
					
				EndIf
			
				/*ImpBolDados:MsgInstrucoes := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " +dtoc(ImpBolDados:DataVenc)+""
				ImpBolDados:MsgInstrucoes += " VENCIMENTO ORIGINAL: " +dtoc(dDataVenc)+""
				ImpBolDados:MsgInstrucoes += " VALOR ORIGINAL: " +Alltrim(Transform(nValorOri, "@E 99,999,999.99"))+""
				ImpBolDados:MsgInstrucoes += " ENCARGOS: " +Alltrim(Transform(ImpBolDados:ValorJuros, "@E 99,999,999.99"))+""
				
				If (ImpBolDados:ValorAcrescimo > 0)
					ImpBolDados:MsgInstrucoes += " TARIFA DE GNRE: " +Alltrim(Transform(ImpBolDados:ValorAcrescimo, "@E 99,999,999.99"))+""
				EndIf
				
				If (ImpBolDados:ValorDesconto > 0)
					ImpBolDados:MsgInstrucoes += " DESCONTO CONCEDIDO: " +Alltrim(Transform(ImpBolDados:ValorDesconto, "@E 99,999,999.99"))+""
				EndIf
				*/
				//ImpBolDados:MsgInstrucoes := ""
				
			EndIf
			
		EndIf
		
		AAdd(aListaBol:Boletos, ImpBolDados)
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())	
		
Return(aListaBol)


Method GetPDF(cListaId, DataRef) Class TAFApiImprimirBoleto

	Local oRet 			:= Nil
	Local oApi 			:= TAFApiNet():New()
	Local aListaBol		:= {}
	
	// Conectar api e buscar token de acesso
	oRet := oApi:GetAcessToken()

	If oRet:Ok

		aListaBol	:= ::DadosPorId(cListaId, DataRef)
		
		If (Len(aListaBol:Boletos) > 0)
			oRet := oApi:PostObj("/Boleto/GetPDF", aListaBol)
		Else
			Return Nil
		EndIf
		
	EndIf

Return(oRet)


//Classe struct de imprimir boleto

Class TAFApiImprimirBoletoListaDados from LongClassName

	Data Boletos
	Data aLstFields // Vetor de conversao de propriedades para nos longos da API 
	
	Method New() Constructor

EndClass

Method New() Class TAFApiImprimirBoletoListaDados

	::Boletos 		:= {}
	::aLstFields 	:= TAFApiListFields():New()
	
	::aLstFields:AddField("Boletos"	, "Boletos")
	
Return()


Class TAFApiImprimirBoletoDados from LongClassName

	Data Banco
	Data CNPJ
	Data Convenio
	Data NossoNumero
	Data NumConPar
	Data DataVenc
	Data ValorJuros
	Data ValorTitulo
	Data ValorDesconto
	Data ValorAcrescimo
	Data MsgInstrucoes
	
	Data aLstFields // Vetor de conversao de propriedades para nos longos da API 
	
	Method New() Constructor

EndClass

Method New() Class TAFApiImprimirBoletoDados

	::Banco 		:= ""
	::CNPJ	 		:= ""   
	::Convenio 		:= ""   
	::NossoNumero 	:= ""	 
	::NumConPar		:= ""
	::DataVenc		:= ""
	::ValorTitulo	:= 0
	::ValorJuros	:= 0
	::ValorDesconto	:= 0
	::ValorAcrescimo:= 0	
	::MsgInstrucoes	:= ""

	::aLstFields 	:= TAFApiListFields():New()
	
	::aLstFields:AddField("Banco"			, "codBanco")
	::aLstFields:AddField("CNPJ"			, "cedenteCNPJ")
	::aLstFields:AddField("Convenio"		, "convenio")
	::aLstFields:AddField("NossoNumero"		, "nossoNumero")
	::aLstFields:AddField("NumConPar"		, "numeroControleParticipante")
	::aLstFields:AddField("DataVenc"		, "dataVenc")
	::aLstFields:AddField("ValorTitulo"		, "valorTitulo")
	::aLstFields:AddField("ValorJuros"		, "valorJuros")
	::aLstFields:AddField("ValorDesconto"	, "valorDesconto")	
	::aLstFields:AddField("ValorAcrescimo"	, "valorAcrescimo")	
	::aLstFields:AddField("MsgInstrucoes"	, "mensagemInstrucoesCaixa")		
	
Return()
