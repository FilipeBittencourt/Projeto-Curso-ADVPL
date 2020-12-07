#include 'totvs.ch'

/*/{Protheus.doc} F171EXCL
PE chamado apos a exclusao da aplicacao financeira
Foi criado para extornar a movimentacao no banco original (Contrato)
@author Paulo Cesar Camata
@since 15/12/2015
@version P11 R8
@type function
/*/
user function F171EXCL()
	
	// Somente movimenta se banco do contrato estiver preenchido.
	if !Empty(SEH->EH_BCOCONT)
	
		_lUsaFlag := SuperGetMV( "MV_CTBFLAG" , .T., .F.)
		
		If SEH->EH_APLEMP == "APL"
			_cHist := "Estorno de Aplicacao " + SEH->EH_TIPO
		Else
			_cHist := "Estorno de Emprestimo " + SEH->EH_TIPO
		EndIf
		 
		Reclock("SE5", .T.)
			SE5-> E5_FILIAL  := xFilial("SEH")
			SE5-> E5_BANCO   := SEH->EH_BCOCONT
			SE5-> E5_DATA    := SEH->EH_DATA
			SE5-> E5_CONTA   := SEH->EH_CTACONT
			SE5-> E5_AGENCIA := SEH->EH_AGECONT
			SE5-> E5_VALOR   := SEH->EH_VLCRUZ
			SE5-> E5_VLMOED2 := xMoeda(SE5->E5_VALOR,1,SEH->EH_MOEDA)
			SE5-> E5_RECPAG  := Iif(SEH->EH_APLEMP=="EMP","R","P")
			SE5-> E5_TIPODOC := Iif(SEH->EH_APLEMP=="EMP","EP","AP")
			SE5-> E5_HISTOR  := _cHist
			SE5-> E5_DTDIGIT := dDataBase
			SE5-> E5_DTDISPO := SE5->E5_DATA
			SE5-> E5_MOEDA	 := "01" 
			SE5-> E5_FILORIG := SEH->EH_FILIAL
			
			If ! _lUsaFlag .and. mv_par02 == 1
				SE5-> E5_LA  := "S"
			Endif
			
			SE5->E5_DOCUMEN := SEH->EH_NUMERO+SEH->EH_REVISAO
			SE5->E5_NATUREZ := SEH->EH_NATUREZ
			
		SE5->( MSUNLOCK() )
		
		// Atualizando saldo do banco
		AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DATA, SE5->E5_VALOR, Iif( SE5->E5_RECPAG=="R", "+", "-"))
		
	endIf
	
return Nil
