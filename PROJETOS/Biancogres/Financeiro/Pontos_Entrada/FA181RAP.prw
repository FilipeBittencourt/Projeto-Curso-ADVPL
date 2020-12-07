#include 'totvs.ch'

/*/{Protheus.doc} FA181RAP
PE apos o resgate de aplicacao financeira
foi criado para debitar o valor da conta do contrato (Aplicacao)
@author Paulo Cesar Camata
@since 15/12/2015
@version P11 R8
@type function
/*/
user function FA181RAP()
	
	if !(Empty(SEH->EH_BCOCONT))
		// Valor anterior
		_nValor := SE5->E5_VALOR
		
		Reclock("SE5",.T.)
			SE5->E5_FILIAL  := xFilial("SE5")
			SE5->E5_BANCO   := SEH->EH_BCOCONT
			SE5->E5_AGENCIA := SEH->EH_AGECONT
			SE5->E5_CONTA   := SEH->EH_CTACONT
			SE5->E5_DATA    := dDataBase
			SE5->E5_VALOR   := _nValor
			SE5->E5_RECPAG  := "P"
			SE5->E5_TIPODOC := "RF"
			SE5->E5_LA      := Iif(mv_par02==1,"S"," ")
			SE5->E5_NATUREZ := cA181Nat
			SE5->E5_HISTOR  := "Resgate de aplicacao " + SEH->EH_TIPO
			SE5->E5_DTDIGIT := dDataBase
			SE5->E5_DTDISPO := SE5->E5_DATA
			SE5->E5_DOCUMEN := SEH->EH_NUMERO+SEH->EH_REVISAO+SEI->EI_SEQ
			SE5->E5_MOEDA	:= "01"
			SE5->E5_FILORIG	:= cFilAnt
			
		SE5->(MsUnlock())
		
		// Atualiza saldo do banco
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,IIf(SE5->E5_RECPAG=="R","+","-"))
	endif
return Nil
