#include "TOTVS.CH"       
#include "rwMake.ch"
#include "Topconn.ch"

/*/{Protheus.doc} M040SE1
@author Fernando Rocha
@since 10/10/2015
@version 1.0
@description P.E. apos gravar titulo a receber (Faturamento ou Manual)
@obs OS: 0504-17 - Jaqueline - Preparar sistema para para tratamento de condições de pagamento do Tipo 3 
@type function
/*/

User Function M040SE1
Local aVenc		:= {}
Local cTpOri	:= ""
Local cTpRpl	:= ""
Local aNewVenc	:= {} //Retorno da função Exceção de Vencimento
Local lVldFIDLM := U_fVlFIDCLM(SE1->E1_PEDIDO) //Valida se o Pedido de Venda é FIDC
Local cQrySA1	:= GetNextAlias()
Local cSQL		:= ""
Local nDiaVenc	:= 0

//Posiciona na Condição de Pagamento Original da NF
SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+SF2->F2_COND))
cTpOri := SE4->E4_TIPO

//Posiciona na Condição de Pagamento de Replicação (Origem)
SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+SE4->E4_YCOND))
cTpRpl := SE4->E4_TIPO


//Thiago Haagensen - Ticket 27234 - Adicionado os clientes (010064/007871/000481/004536) para não calcular juros
IF  ALLTRIM(SE1->E1_CLIENTE) $"010064/007871/000481/004536" 
	SE1->E1_PORCJUR	:=	0
ENDIF

IF IsInCallStack("U_BACP0010")  .OR. UPPER(ALLTRIM(FUNNAME())) == "MATA460A" .OR. UPPER(ALLTRIM(FUNNAME())) == "BIAF026" .OR. UPPER(ALLTRIM(FUNNAME())) == "M460FIM"
	
	//Ajuste de vencimento caso faturando pedido com condicao de pagamento TIPO 9 que estejam com data vencida
	//If SF2->F2_COND == "142" .And. SC5->C5_YTPCRED == "2" .And. ( SE1->E1_VENCTO < dDataBase )
	//Ticket 587
	If Alltrim(cTpOri) == "9" .And. ( SE1->E1_VENCTO < dDataBase )
		SE1->E1_VENCTO	:= dDataBase
		SE1->E1_VENCREA	:= DataValida(dDataBase)
	EndIf
	
	//Acerta o vencimento das parcelas, para a condição do Tipo 3 e com ST
	If cTpRpl == "3" .And. SE1->E1_PARCELA == "B"
		aVenc := Condicao(SF2->F2_VALBRUT,SE4->E4_CODIGO,SF2->F2_VALIPI,SF2->F2_EMISSAO,SF2->F2_ICMSRET)
		SE1->E1_VENCTO	:= aVenc[1][1]
		SE1->E1_VENCREA	:= DataValida(aVenc[1][1])
	EndIf
		
	// OS 0335-14 Zerando Juros dos Grupos Abaixo
	If (Alltrim(SA1->A1_GRPVEN) $ "000380_000026_000010_000030_000938") //OS 1487-16 - Cassol
		SE1->E1_PORCJUR	:=	0
	Else
		SE1->E1_PORCJUR	:=	0.20
	EndIf
	
	IF cEmpAnt <> "02"
		SE1->E1_YEMP	:= SC5->C5_YEMP 		//GRAVA EMPRESA ORIGINAL
		SE1->E1_YRESULT	:= SC5->C5_YRESULT 		//GRAVA RESULTADO
		SE1->E1_YRESUL2	:= SC5->C5_YRESUL2
	ENDIF
	
	SE1->E1_OCORREN	:= "01"
	SE1->E1_INSTR1	:= "01" //Cobrar Juros p/ Banco do Brasil
	SE1->E1_INSTR2	:= "07" //06 - Protestar / 00 - Protestar em 3 dias / 07 - Nao Protestar
	SE1->E1_YPRZPTO	:= "00" //Numero de dias p/ protesto, se parametro for igual a 06 Autorizado por Robson
	
	//Dados do Del-Credere
	SE1->E1_YCLIDEL	:= SC5->C5_YCLIDEL
	SE1->E1_YPERDEL	:= SC5->C5_YPERDEL
	SE1->E1_YBAIDEL	:= SC5->C5_YBAIDEL
	SE1->E1_YNFDEL	:= SC5->C5_YNFDEL
	
	//Dados para Cobranca
	SE1->E1_YUFCLI	:= SA1->A1_EST
	SE1->E1_YFORMA 	:= SC5->C5_YFORMA

	//ROTINA TRANSFERIDA DO P.E. MT461VCT - desenvolvido de forma incorreta na automacao
	//AJUSTE REALIZADO EM 04/08/2021 COM AS VALIDACOES FIDC
	//ADICIONA REGRA PARA CLIENTES ESPECIAIS, CASO TENHA O CAMPO PREENCHIDO
	If !U_fValidaRA(SF2->F2_COND)
	
		cSQL := ""
		cSQL += "SELECT A1_COD, A1_LOJA, A1_NOME, A1_GRPVEN, A1_YSUMCE, ISNULL(ACY_YSUMCE,0) ACY_YSUMCE "
		cSQL += "FROM SA1010 SA1 LEFT JOIN ACY010 ACY ON A1_GRPVEN = ACY_GRPVEN AND ACY.D_E_L_E_T_ = '' "
		If Alltrim(cempant) $ "01_05_13_14" .And. SA1->A1_COD == "010064" 
			cSQL += "WHERE A1_COD = '"+SC5->C5_YCLIORI+"' AND A1_LOJA = '"+SC5->C5_YLOJORI+"' AND SA1.D_E_L_E_T_ = ''  
		else
			cSQL += "WHERE A1_COD = '"+SF2->F2_CLIENTE+"' AND A1_LOJA = '"+SF2->F2_LOJA+"' AND SA1.D_E_L_E_T_ = '' 
		EndIf
		TcQuery cSQL New Alias (cQrySA1)

		If !(cQrySA1)->(Eof()) .And. (cQrySA1)->A1_YSUMCE > 0
			
			nDiaVenc := (cQrySA1)->A1_YSUMCE

			If (cQrySA1)->ACY_YSUMCE > 0

				nDiaVenc := (cQrySA1)->ACY_YSUMCE

			EndIf

		EndIf 

		(cQrySA1)->(DbCloseArea()) 

		If nDiaVenc > 0
			SE1->E1_VENCTO  := SE1->E1_VENCTO + nDiaVenc
			SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO)
		EndIf
	
	EndIf

	
	// tratamento para titulos de subistituicao tributaria
	If SF2->F2_ICMSRET > 0 .And. Alltrim(SF2->F2_EST) $ GetMV("MV_YUFSTCD") .And. Alltrim(SE1->E1_PARCELA) == 'A' .And. Alltrim(cEmpAnt) $ '01_05_07_14'
		
		//Se for RA e Titulos de ST, o Vencimento é sempre a DataBase
		If U_fValidaRA(SF2->F2_COND)
			SE1->E1_VENCTO	:=	dDataBase
			SE1->E1_VENCREA	:=	dDataBase
			SE1->E1_VENCORI	:=	dDataBase
		Else
			//Altera o Vencimento da ST para o ES, conforme solicitacao da Diretoria - em 30/04/13 - 05 dias fora mes - desativado em 10/05/13
			//ALTERA O VENCIMENTO DA ST PARA O ES, CONFORME solicitacao DA DIRETORIA - em 10/05/13 - 28 dias
			//If Alltrim(SF2->F2_EST) == "ES" //PARA ESTES ESTADOS A EXCESSÃO FOI TRATADA NA REGRA "PR_SC_RS"
			If Alltrim(SF2->F2_EST) == "ES" .Or. (cEmpAnt == "07" .And. Alltrim(SF2->F2_EST) $ "RJ_BA") //1004-16
				aVencOri	:=  Condicao(SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_EMISSAO,SF2->F2_ICMSRET)			
				If Len(aVencOri) > 1									
					//Ticket 7506
					If aVencOri[2][1] < SF2->F2_EMISSAO+28
						dVenc	:=	aVencOri[2][1]  
					Else 	
						dVenc	:=	SF2->F2_EMISSAO+28
					EndIf															
					SE1->E1_VENCTO	:=	dVenc
					SE1->E1_VENCREA	:=	DATAVALIDA(dVenc)
					SE1->E1_VENCORI	:=	dVenc
				EndIf
			EndIf
		EndIf
			
		If U_fValidaRA(SF2->F2_COND)
			If Alltrim(SC5->C5_YSUBTP) == "B"
				nForma := "1" 	//Forma de Pagamento (1=Banco/2=Cheque/3=OP	- Padrao 3=OP)
			Else
				nForma := "3" 	//Forma de Pagamento (1=Banco/2=Cheque/3=OP	- Padrao 3=OP)
			EndIf
		Else
			nForma	:= "1"		//Forma de Pagamento (1=Banco/2=Cheque/3=OP	- Padrao 1=Banco)
		EndIf
		
		//Grava a Naturaza Financeira para ST
		SE1->E1_NATUREZ	:= '1230'
		
		//Grava a Forma de Pagamento Padrão
		SE1->E1_YFORMA	:=	nForma
		
		//Tratamento para Exceção de Vencimento de ST
		If !Alltrim(SC5->C5_CONDPAG) $ "328_195_980_A80_331_192_982_A82_330_194"
			If Alltrim(cempant) $ "01_05_13_14" .And. SA1->A1_COD == "010064" .And. !lVldFIDLM
				aNewVenc := U_fExcVenc("ST",SC5->C5_YEMP,SC5->C5_YCLIORI,SC5->C5_YLOJORI,SF2->F2_EMISSAO,SE1->E1_VENCTO,SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_ICMSRET)
			Else
				aNewVenc := U_fExcVenc("ST",SC5->C5_YEMP,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SE1->E1_VENCTO,SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_ICMSRET)
			EndIf

			If Len(aNewVenc) > 1
				SE1->E1_VENCTO	:=	aNewVenc[1]
				SE1->E1_VENCREA	:=	DATAVALIDA(aNewVenc[1])
				SE1->E1_VENCORI	:=	aNewVenc[1]
				If !Empty(Alltrim(aNewVenc[2]))
					SE1->E1_YFORMA	:=	aNewVenc[2]
				EndIf 		
			EndIf
		EndIf					
		
		SE1->E1_YCLASSE	:= '1'
			
		/*//Grava o Nosso Numero apenas para ST fora do ES
		If Alltrim(SF2->F2_EST) == "ES"
			SE1->E1_YCLASSE	:= '4'
		Else
			
			// Somente altera a classe se o titulo for diferente de provisorio de RA
			If AllTrim(SE1->E1_YCLASSE) <> "6"
				SE1->E1_YCLASSE	:= '1'
				
				//Comentado no projeto Automacao Financeiro - Nosso numero passa a ser gerado no bordero automatico
				//SE1->E1_NUMBCO := U_fGeraNossoNumero("1") //Funcao para Geracao do NossoNumero
				
			EndIf
			
		EndIf
		*/
	EndIf
	
	//Calculo incremento para prorrogacao de titulos a receber
	If Alltrim(SE1->E1_NATUREZ) <> "1230" //Rotina foi habilitada novamente em 17/12/08 as 13:00
		If Empty(SC5->C5_YDTINC)
			If SC5->C5_YPRZINC > 0
				SE1->E1_VENCTO  := SE1->E1_VENCTO + SC5->C5_YPRZINC
				SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO)
			EndIf
		Else
			If SC5->C5_YDTINC > SE1->E1_EMISSAO
				SE1->E1_VENCTO  := SE1->E1_VENCTO + (SC5->C5_YDTINC - SE1->E1_EMISSAO)
				SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO)
			EndIf
		EndIf
	EndIf
	
	//Tratamento para Exceção de Vencimento NF (SOBRESCREVE A REGRA DE ST)
	If !Alltrim(SC5->C5_CONDPAG) $ "328_195_980_A80_331_192_982_A82_330_194"	
		If Alltrim(cempant) $ "01_05_13_14" .And. SA1->A1_COD == "010064" .And. !lVldFIDLM
			aNewVenc := U_fExcVenc("NF",SC5->C5_YEMP,SC5->C5_YCLIORI,SC5->C5_YLOJORI,SF2->F2_EMISSAO,SE1->E1_VENCTO,SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_ICMSRET)
		Else
			aNewVenc := U_fExcVenc("NF",SC5->C5_YEMP,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SE1->E1_VENCTO,SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_ICMSRET)
		EndIf
		If Len(aNewVenc) > 1
			SE1->E1_VENCTO	:=	aNewVenc[1]
			SE1->E1_VENCREA	:=	DATAVALIDA(aNewVenc[1])
			SE1->E1_VENCORI	:=	aNewVenc[1]
		EndIf						
	EndIf

	//SOLICITACAO DO SR. DIOGO E VAGNER NO DIA 23/06/09
	//INCLUIDO MUNDI NO DIA 26/03/12
	//Em 20/07/2021 - Solicitado Por Nadine  para somar 5 dias e não mais 7
	//Em 28/07/2021 - Ticket 32275 - Vencimento Coligadas - DEPOIS DE TODOS OS INCREMENTOS O SISTEMA DEVERÁ ACRESCENTAR 5 DIAS
	If Alltrim(cempant) $ "01_05_13_14" .And. SA1->A1_COD == "010064" .And. !lVldFIDLM //Ajustes FIDC em 23/07/2021
		SE1->E1_VENCTO  := SE1->E1_VENCTO + 5
		SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO)
	EndIf

		
	If SE1->E1_NATUREZ <> "1230"
		IF SA1->A1_EST == "EX"  // Venda Exportacao
			SE1->E1_NATUREZ := "1131"
			If SC5->C5_DESCFI <> 0  //Grava Desconto para Conta Grafica e A Deduzir da Fatura
				SE1->E1_DESCFIN := SC5->C5_DESCFI
			EndIf
		ELSE  // Venda Nacional
			SE1->E1_NATUREZ := SA1->A1_NATUREZ // 11/11/02 - Nilton - Sol. Marcelo
		ENDIF
	EndIf	
	
EndIf

	// Tiago Rossini Coradini - 12/07/2017 - OS: 1600-17
	U_BIAF080()

Return
