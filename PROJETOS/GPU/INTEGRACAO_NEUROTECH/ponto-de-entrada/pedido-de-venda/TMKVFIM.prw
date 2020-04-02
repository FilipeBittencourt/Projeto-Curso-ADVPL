#INCLUDE "rwmake.ch"
#include "topconn.ch"        // incluido pelo assistente de conversao do AP5 IDE em 21/03/01

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKVFIM   º Autor ³FABIO MUCELINI LOSS º Data ³  29/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³GRAVAR INFORMACOES COMPLEMENTARES NO ARQUIVO SL1            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TMKVFIM()
	
	Local aArea		:= GetArea()
	Local aAreaSL1	:= SL1->(GetArea())
	Local aAreaSL2 	:= SL2->(GetArea())
	Local aAreaSC5 	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSF4	:= SF4->(GetArea())
	Local cSql			:= ""
	Local x			:= 1
	Local lRet    	:= .F.
	Local aSolid		:= {}
	Local aTotais		:= {0,0,0}
	Local lContPag		:= .f.
	
	Private aPvlNfs		:= {}
	Private aBloqueio	:= {}
	Private QUANTITEM	:= 0
	
	If ALLTRIM(FunName()) $ "TMKA350/TMKA280"
		Return(lRet)
	Endif
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA)
	
	lRet := u_VerifCliEmp(SA1->A1_CGC) //verifica se o cliente é uma empresa do grupo
	AtualSUB()
	
	If M->UA_OPER == "2"//Gravar no SL1
		
		DbSelectArea("SL1")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SL1")+SUA->UA_NUMSL1)
			
			Reclock("SL1", .F.)
			SL1->L1_VEND2	:= SUA->UA_YVENDX
			SL1->L1_YOBS	:= SUA->UA_YOBS
			SL1->L1_YOBS2	:= SUA->UA_YOBS2
			SL1->L1_ESPECIE	:= "VOLUME"
			SL1->L1_HORCANC	:= TIME()
			SL1->L1_IMPRIME	:= Alltrim(Str(GETMV("MV_LOJAOPI")))+"N"
			SL1->L1_YSTATUS	:= '1'
			SL1->L1_ESTE	:= SA1->A1_EST
			SL1->L1_YNOME	:= SUBSTR(SA1->A1_NOME,1,40)
			SL1->L1_COODAV	:= ""
			SL1->L1_YCGC	:= SUBSTR(SUA->UA_YCONDPG,1,2)
			SL1->L1_TPFRET	:= SUA->UA_TPFRETE
			SL1->(MsUnlock())
			
			SA1->(dbSetOrder(1))
			
			If SA1->(dbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
				
				If SA1->A1_TEMVIS > 0
					
					Reclock("SL1",.f.)
					SL1->L1_DTLIM := DDATABASE + SA1->A1_TEMVIS
					SL1->(MsUnlock())
					
				EndIf
				
			EndIf
			
			U_XLogLoja("SL1", "", "", "TMKVFIM", 0, Time() )
			
		EndIf
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		DbSelectArea("SF4")
		SF4->(DbSetOrder(1))
		
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		
		If SL2->(DbSeek(xFilial("SL2")+SUA->UA_NUMSL1))
		
			Do while !Eof() .and. L2_FILIAL == xFilial("SL2") .and. L2_NUM == SUA->UA_NUMSL1
				
				If !GDDeleted(x)
					
					SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
					
					SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
					
					Reclock("SL2", .F.)
					SL2->L2_DESCRI	:= SB1->B1_DESC
					SL2->L2_YDECRES 	:= GdFieldget("UB_YDECRES",x)
					SL2->L2_YACRESC	:= GdFieldget("UB_YACRESC",x)
					SL2->L2_VEND		:= SUA->UA_VEND
					SL2->L2_TABELA	:= GdFieldget("UB_TABELA",x)
					SL2->L2_YPILOT	:= GdFieldget( "UB_YPILOT",x)
					SL2->L2_YCUSTO	:= GdFieldget( "UB_YCUSTO",x) 	
					SL2->L2_YCMV	:= GdFieldget( "UB_YCMV",x) 	
					SL2->L2_YLUCRO	:= GdFieldget( "UB_YLUCRO",x)	
					SL2->L2_YPRCTAB	:= GdFieldget( "UB_PRCTAB",x)
					
					If SL2->L2_YPILOT == ''
						SL2->L2_YPILOT	:= U_PILOTO(GdFieldget( "UB_PRODUTO",x))                                                                             
					EndIf
					
					If SL2->L2_YCUSTO == 0
						SL2->L2_YCUSTO	:= POSICIONE('SB1', 1, xFilial("SB1")+GdFieldget( "UB_PRODUTO",x), 'SB1->B1_CUSTD')                                                                                       
					EndIf
					
					If SL2->L2_YCMV == 0
						SL2->L2_YCMV	:= POSICIONE('SB2', 1, xFilial("SB2")+GdFieldget( "UB_PRODUTO",x), 'SB2->B2_CM1')					                                                            
					EndIf
					
					If SL2->L2_YLUCRO == 0
						SL2->L2_YLUCRO	:= U_RENTAB(GdFieldget( "UB_PRODUTO",x))
					EndIf
					
					
					SL2->L2_PRCTAB	:= Round(GdFieldget("UB_VRUNIT",x),2)
					SL2->L2_CLASFIS	:= SB1->B1_ORIGEM + SF4->F4_SITTRIB
					SL2->L2_ORIGEM	:= SB1->B1_ORIGEM
					
					//RATEIO DOS VALORES DE FRETE E DESPESAS VINDOS DO CALL CENTER
					SL2->L2_VALFRE	:= (SL1->L1_FRETE/SL1->L1_VALMERC)*SL2->L2_VLRITEM
					SL2->L2_SEGURO	:= (SL1->L1_SEGURO/SL1->L1_VALMERC)*SL2->L2_VLRITEM
					SL2->L2_DESPESA	:= (SL1->L1_DESPESA/SL1->L1_VALMERC)*SL2->L2_VLRITEM
					
					If lRet .and. FieldPos("L2_YINSTAL") > 0
						SL2->L2_YINSTAL := '0000'
					EndIf
					
					/*
					//Tratamento para alteração do valor unitario para calculo de vendas REOA
					//Variavel private para o ponto de entrada
					nPerICM		:= AliqIcms("N",'S',SA1->A1_TIPO)
					QUANTITEM	:= SL2->L2_QUANT
					aSolid 		:= u_VIXSOLI(SL2->L2_PRODUTO,SL2->L2_LOCAL,SL2->L2_TES,nPerICM)
					
					If aSolid[2] > 0
						
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
						
						SF4->(DbSetOrder(1))
						SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
						
						If SF4->(FieldPos("F4_YTESIRE")) > 0 .and. !Empty(SF4->F4_YTESIRE)
							
							SF4->(DbSetOrder(1))
							If SF4->(DbSeek(xFilial("SF4")+SF4->F4_YTESIRE))
								
								nValOld			:= SL2->L2_VLRITEM
								SL2->L2_TES 	:= SF4->F4_CODIGO
								
								SL2->L2_VRUNIT	:= Round(SL2->L2_VRUNIT-(aSolid[2]/SL2->L2_QUANT),TamSX3("L2_VRUNIT")[2])
								SL2->L2_PRCTAB	:= Round(SL2->L2_PRCTAB-(aSolid[2]/SL2->L2_QUANT),TamSX3("L2_PRCTAB")[2])
								SL2->L2_VLRITEM	:= Round(SL2->L2_VRUNIT*SL2->L2_QUANT,TamSX3("L2_VLRITEM")[2])
								
								SL2->L2_BASEICM	:= SL2->L2_VLRITEM
								SL2->L2_VALICM	:= SL2->L2_VLRITEM*(nPerICM/100)
								
								SL2->L2_BRICMS	:= aSolid[1]
								SL2->L2_ICMSRET	:= aSolid[2]
								
								aTotais[1] += aSolid[1]
								aTotais[2] += aSolid[2]
								aTotais[3] += SL2->L2_VLRITEM
								
							EndIf
							
						EndIf
						
					EndIf
					*/
					
					SL2->(MsUnlock())
					
					SL2->(DbSkip())
					
				EndIf
				x:= x + 1
				
			EndDo
			
			/*
			Reclock("SL1",.f.)
			SL1->L1_BRICMS	:= aTotais[1]
			SL1->L1_ICMSRET	:= aTotais[2]
			SL1->L1_VALMERC := aTotais[3]
			SL1->(MsUnlock())
			*/
			
		EndIF
		
		RestArea(aAreaSL1)
		RestArea(aAreaSL2)
		RestArea(aAreaSF4)
		RestArea(aAreaSB1)
		RestArea(aArea)
		
	Else //Gravar no SC5/SC6
		
		DbSelectArea("SC5")
		aAreaSC5 := GetArea()
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
			
			Reclock("SC5",.f.)
			SC5->C5_FRETE	:= SUA->UA_FRETE
			SC5->C5_TPFRETE	:= SUA->UA_TPFRETE
			SC5->C5_CONDPAG	:= SUA->UA_CONDPG
			SC5->C5_YSTATUS	:= 'B'
			SC5->C5_YMSGNF	:= SUA->UA_YOBS
			SC5->C5_YOBS	:= SUA->UA_YOBS2
			SC5->C5_TIPLIB	:= CriaVar("C5_TIPLIB")
			SC5->C5_TPCARGA	:= CriaVar("C5_TPCARGA")
			SC5->C5_GERAWMS	:= CriaVar("C5_GERAWMS")
			SC5->C5_YHRINC	:= TIME()
			SC5->(MsUnlock())
			
			If SC5->(FieldPos("C5_YEMPFOR"))  > 0 .and. cEmpAnt == "08"
				
				SC6->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
					
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
						
						ZZL->(dbSetOrder(1))
						If ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC))
							
							Reclock("SC5",.f.)
							SC5->C5_YEMPFOR := ZZL->ZZL_EMPFOR+ZZL->ZZL_FILFOR
							SC5->(MsUnlock())
							
						EndIf
						
					EndIf
					
				EndIf
				
				If Empty(SC5->C5_YEMPFOR)
					
					Reclock("SC5",.f.)
					SC5->C5_YEMPFOR := cEmpAnt+cFilAnt
					SC5->(MsUnlock())
					
				EndIf
				
			EndIf
			
			//MARCA FLAG PARA ROTINA DE PAGAMENTO DE CARTÃO
			If cEmpAnt <> "08" .and. SUA->(FieldPos("UA_YCONDPG"))  > 0
				
				If AllTrim(SUA->UA_FORMPG) $ "R$/CD/DC/CC" .or. !Empty(SUA->UA_YCONDPG)
					
					//ATUALIZA CAMPO
					RecLock("SUA",.f.)
					SUA->UA_YCONDPG := "OK"
					SUA->(msUnLock())
					
					lContPag := .t.
					
				Else
					
					//Atualiza o call center como pago, caso tenha o campo para controle
					RecLock("SUA",.F.)
					SUA->UA_YCONDPG	:= "PAG"
					SUA->(msUnLock())
				EndIf
				
			EndIf
			
			If cEmpAnt == "09"
				
				//CHAMA ROTINA PARA FATURAMENTO ENTRE GRUPOS
				u_VIXA180Ped(lContPag)
				
			Else
				
				//Chama ponto de entrada
				U_M410STTS()
				
			EndIf
			
			//CASO NÃO PRECISE DE CONTROLE DE PAGAMENTO SERA LIBERADO O PEDIDO
			If	!lContPag
				
				SC5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SUA->UA_NUMSC5))
					
					Reclock("SC5",.f.)
					SC5->C5_YSTATUS	:= '1'
					SC5->(MsUnlock())
					
				EndIf
				
			EndIF
			
		EndIf
		RestArea(aAreaSC5)
		
	EndIf
	
	DbSelectArea("SC6")
	aAreaSC6 := GetArea()
	x		:= 1
	DbSetOrder(1)
	If DbSeek(xFilial("SC6")+SUA->UA_NUMSC5)
		
		Do while !Eof() .and. C6_FILIAL == xFilial("SC6") .and. C6_NUM == SUA->UA_NUMSC5
			
			If !GDDeleted(x)
				
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
				
				Reclock("SC6",.f.)
				SC6->C6_YDECRES	:= GdFieldget("UB_YDECRES",x)
				SC6->C6_YACRESC	:= GdFieldget("UB_YACRESC",x)
				SC6->C6_QTDLIB	:= SC6->C6_QTDVEN
				SC6->C6_QTDLIB2	:= SC6->C6_UNSVEN
				SC6->C6_PRUNIT	:= Round(GdFieldget("UB_VRUNIT",x),2)				
				
				IF GdFieldPos("UB_YPILOT") > 0
					SC6->C6_YPILOT	:= GdFieldget( "UB_YPILOT",x)
				EndIf
				
				IF GdFieldPos("UB_YCUSTO") > 0
					SC6->C6_YCUSTO	:= GdFieldget( "UB_YCUSTO",x) 	
				EndIf
				
				IF GdFieldPos("UB_YCMV") > 0
					SC6->C6_YCMV	:= GdFieldget( "UB_YCMV",x)
				EndIf
				
				IF GdFieldPos("UB_YLUCRO") > 0 	
					SC6->C6_YLUCRO	:= GdFieldget( "UB_YLUCRO",x)
				EndIf
				
				SC6->C6_YTABPRC	:= GdFieldget( "UB_TABELA",x)

				
					SC6->C6_YPRCTBO	:= GdFieldget( "UB_PRCTAB",x)					
					//=====================================================				
					If AllTrim(SC6->C6_YPILOT) == ''
						SC6->C6_YPILOT	:= U_PILOTO(GdFieldget( "UB_PRODUTO",x))                                                                             
					EndIf
					
					If SC6->C6_YCUSTO == 0
						SC6->C6_YCUSTO	:= POSICIONE('SB1', 1, xFilial("SB1")+GdFieldget( "UB_PRODUTO",x), 'SB1->B1_CUSTD')                                                                                       
					EndIf
					
					If SC6->C6_YCMV == 0
						SC6->C6_YCMV	:= POSICIONE('SB2', 1, xFilial("SB2")+GdFieldget( "UB_PRODUTO",x), 'SB2->B2_CM1')					                                                            
					EndIf
					
					If SC6->C6_YLUCRO == 0
						SC6->C6_YLUCRO	:= U_RENTAB(GdFieldget( "UB_PRODUTO",x))
					EndIf					
					//====================================================
				
				
				If SB1->B1_COMIS > 0
					SC6->C6_COMIS1 := SB1->B1_COMIS
				EndIf
				
				//Inclui o tipo de serviço WMS no pedido do call center
				SB5->(dbSetOrder(1))
				If SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD)) .and. !Empty(SB5->B5_SERVSAI)
					
					SC6->C6_SERVIC 	:= SB5->B5_SERVSAI
					SC6->C6_ENDPAD	:= AllTrim(GetNewPar("MV_YENDPAS","DOCA SAIDA"))
					SC6->C6_TPESTR	:= AllTrim(GetNewPar("MV_YTPESTS","000024"))
					
				EndIf
				
				If SUB->(FieldPos("UB_YNUMPCO")) > 0 .And. SUB->(FieldPos("UB_YITEMPC")) > 0
					
					If SC6->(FieldPos("C6_NUMPCOM")) > 0 .And. SC6->(FieldPos("C6_ITEMPC")) > 0
						
						SC6->C6_NUMPCOM	:= GdFieldget("UB_YNUMPCO",x)
						SC6->C6_ITEMPC	:= GdFieldget("UB_YITEMPC",x)
						
					EndIf
					
				EndIf
				
				/*
				//Tratamento para alteração do valor unitario para calculo de vendas REOA
				//Variavel private para o ponto de entrada
				QUANTITEM	:= SC6->C6_QTDVEN
				aSolid 	:= u_M460SOLI()
				
				If aSolid[2] > 0
					
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
					
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
					
					If SF4->(FieldPos("F4_YTESIRE")) > 0 .and. !Empty(SF4->F4_YTESIRE)
						
						SF4->(DbSetOrder(1))
						If SF4->(DbSeek(xFilial("SF4")+SF4->F4_YTESIRE))
							
							SC6->C6_TES 	:= SF4->F4_CODIGO
							SC6->C6_CLASFIS	:= CodSitTri()
							SC6->C6_PRCVEN	:= Round(SC6->C6_PRCVEN-(aSolid[2]/SC6->C6_QTDVEN),TamSX3("C6_PRCVEN")[2])
							SC6->C6_PRUNIT	:= Round(SC6->C6_PRUNIT-(aSolid[2]/SC6->C6_QTDVEN),TamSX3("C6_PRUNIT")[2])
							SC6->C6_VALOR	:= Round(SC6->C6_QTDVEN*SC6->C6_PRCVEN,TamSX3("C6_VALOR")[2])
							
						EndIf
						
					EndIf
					
				EndIf
				*/
				
				SC6->(MsUnlock())
				
				SC6->(DbSkip())
				
			EndIf
			
			x := x + 1
			
		EndDo
		
	EndIF
	
	SC5->(DbSetOrder(1))
	If M->UA_OPER <> "2".and. SC5->(DbSeek(xFilial("SC5")+SUA->UA_NUMSC5))
		//Liberacao de pedido
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	EndIf
	
	RestArea(aAreaSC6)
	RestArea(aArea)
	
	If Alltrim(SUA->UA_VEND) == "0001"
		If SM0->M0_CODIGO $ '08'
			ExecBlock("FATPEDIDO",.F.,.F.,)
		Else
			ExecBlock("PEDIDO",.F.,.F.,)
		EndIf
	EndIf
	 
		
	/*/{Protheus.doc} Static Function Neurotech()
	@description  DEIXAR SEMPRE ESSA FUNÇÃO POR ULTIMO POIS VALIDA CENÁRIOS PARA APROVAÇÃO DO PEDIDO NA NEUROTECH
	@author FILIPE VIEIRA / Facile Sistemas
	@since 28/12/2018
	@version 1.0
	/*/
	If !Empty(M->UA_YRNEGOC)
		FWMsgRun(, {|| Neurotech()}, "Aguarde!", "Processando a rotina NEUROTECH...")
	EndIF	


Return()

Static Function VerifRegraLog
	
	Local nQuant	:= 0
	Local nQtdTotal	:= 0
	Local lRet		:= .f.
	Local i
	
	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
		
		While SC6->(!Eof()) .and. SC6->C6_FILIAL+SC6->C6_NUM ==  xFilial("SC6")+SC5->C5_NUM
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
			
			nQtdTotal++
			
			ZZL->(dbSetOrder(1))
			If ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC))
				
				nQuant++
				
			EndIf
			
			SC6->(dbSkip())
			
		EndDo
		
	EndIf
	
	If nQuant > 0
		
		lRet := .t.
		
	EndIf
	
Return(lRet)


Static Function AtualSUB()
	Local aArea 	:= GetArea()
	Local aAreaSUB 	:= SUB->(GetArea())
	
	DbSelectArea('SUB')
	SUB->(DbSetOrder(1))

	if SUB->(DbSeek(xFilial('SUB')+SUA->UA_NUM))
		While !SUB->(Eof()) .and. SUB->UB_NUM == SUA->UA_NUM
			RecLock('SUB', .F.)
				SUB->UB_YPILOT 	:= U_PILOTO(SUB->UB_PRODUTO) 
				SUB->UB_YCUSTO 	:= POSICIONE('SB1', 1, xFilial("SB1")+SUB->UB_PRODUTO, 'SB1->B1_CUSTD') 
				SUB->UB_YCMV 	:= POSICIONE('SB2', 1, xFilial("SB2")+SUB->UB_PRODUTO, 'SB2->B2_CM1')  
				SUB->UB_YLUCRO	:= U_RENTAB(SUB->UB_PRODUTO)
			SUB->(MsUnLock())
			SUB->(DbSkip())
		EndDo 
	EndIf

	RestArea(aAreaSUB)
	RestArea(aArea)
	
Return


Static Function Neurotech()

	Local aArea := SC9->(GetArea())
	Local oNeurotM    := TINNeurotechModel():New()
	Local oWSClient   := TINNeurotechRequest():New()
	Local oLogC := TINLogController():New()
	Local oLogM := TINLogModel():New()
	Local oElimiResC := TINEliminaResiduoPVController():New()
	Local lRet := .F.
	Local nW := 1
	Local cStatus :=  "ERRO"
	Local nNumProp := GETSXENUM("ZZ8","ZZ8_CNTNEU") 
	Local oClienteC  	:= TINClienteController():New() // Instancia o controller
	Local oClienteM  	:= oClienteC:GetCliLoja(XFilial("SA1"),M->UA_CLIENTE,M->UA_LOJA)	 // Recuperar o modelo do negócio


	

	oNeurotM:oCliente   := oClienteM
	oNeurotM:nNumProp   := nNumProp
	oNeurotM:nVlrTotVen := SUA->UA_VLRLIQ //MaFisRet(,"NF_TOTAL")
	oNeurotM:cObserv    := M->UA_YOBS3


	oLogM:dDtEnvNeu  := DATE()
	oLogM:cHrEnvNeu  := SubStr(Time(),1,5)

	oWSClient:PostRequest(oNeurotM)

	oLogM:dDtResNeu  := DATE()
	oLogM:cHrResNeu  := SubStr(Time(),1,5)

	If !EMPTY(oWSClient:oRetorno:NCDOPERACAO)

		//Caso dê erro na NEUROTECH
		oLogM:cCodNeu  := oWSClient:oRetorno:NCDOPERACAO		
		oLogM:cErroNeu := ""
		If (oWSClient:oRetorno:CCDMENSAGEM != "0100")
			oLogM:cErroNeu :=  cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - ("+oWSClient:oRetorno:CCDMENSAGEM+") " + cValToChar(oWSClient:oRetorno:CDsMensagem)
			oLogM:cStatus  := "" //  Vazio - Erro preto 
			cStatus :=  "ERRO"		
			lRet := .F.
			oElimiResC:ElimiResid(SC5->C5_NUM)
		Else
			
			If (oWSClient:oRetorno:CCDMENSAGEM == "0100" .AND. cValToChar(oWSClient:oRetorno:CRESULTADO) == "APROVADO")				
				oLogM:cStatus := "3" //Retonro liberado - azul
				cStatus :=  "LIBERADO"
				lRet := .T.

			ElseIf (oWSClient:oRetorno:CCDMENSAGEM == "0100" .AND. cValToChar(oWSClient:oRetorno:CRESULTADO) == "PENDENTE")							    
				oLogM:cMotivNeu  := cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - "+cValToChar(oWSClient:oRetorno:CRESULTADO)
				oLogM:cStatus := "5" //Pendente -  Laranja
				cStatus :=  "PENDENTE"
				lRet := .F.
			Else
				oLogM:cMotivNeu  := cValToChar(oWSClient:oRetorno:NCDOPERACAO)+" - "+cValToChar(oWSClient:oRetorno:CRESULTADO)
				oLogM:cStatus := "2" // Retorno com bloqueio - vermelho
				cStatus :=  "BLOQUEADO/CANCELADO"
				lRet := .F.
				oElimiResC:ElimiResid(SC5->C5_NUM)
				
			EndIf

		EndIf

		If(lRet)	

			RecLock("SC5", .F.)
			SC5->C5_YSTATUS := "1"
			SC5->(MsUnLock())

			SC9->(DbSetOrder(2)) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM, R_E_C_N_O_, D_E_L_E_T_
			SC9->(DbGoTop())
			If( SC9->(DbSeek(XFilial("SC9")+oClienteM:cCodigo+oClienteM:cLoja+SC5->C5_NUM)))
				While ( SC9->(!EOF()) .AND. (SC9->C9_FILIAL+SC9->C9_CLIENTE+SC9->C9_LOJA+SC5->C5_NUM == XFilial("SC9")+oClienteM:cCodigo+oClienteM:cLoja+SC5->C5_NUM))
					RecLock("SC9", .F.) 
					SC9->C9_BLCRED := ""
					SC9->(MsUnlock())
					SC9->(dbSkip())		
				EndDo	
				RestArea(aArea) 
			EndIf

		Else
				
			If (oLogM:cStatus == "2")
				MsgInfo("O pedido <b>"+cValToChar(SC5->C5_NUM)+"</b> foi criado, porém o mesmo foi <b>BLOQUEADO</b> por regras administrativas. Acompanhar o status do pedido na tela do log.", "Aviso" )		
			Else
				RecLock("SC5", .F.)
				SC5->C5_YSTATUS := "X"
				SC5->(MsUnLock())	
				MsgInfo("O pedido <b>"+cValToChar(SC5->C5_NUM)+"</b> foi criado, e está em análise pela mesa de crédito. Acompanhar o status do pedido na tela do log.", "Aviso" )
			EndIf

		EndIf

		//Atualizar dados do cliente mediante ao retorno da NEUROTECH	 
		if(LEN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo) > 0)
			
			For nW := 1 To LEN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo)

				if (oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CNMPARAMETRO == "RET_DATA_VENCIMENTO_LIMITE" .AND. oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO != "")
					
					RecLock("SA1", .F.)					
					SA1->A1_VENCLC := CTOD(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO) //SUBSTR(STRTRAN(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO, "-", ""),0,8)   					
					SA1->(MsUnLock())

				EndIf
				
				if (oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CNMPARAMETRO == "RET_LIMITE_CREDITO"  .AND.  VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO) > 0)
					
					RecLock("SA1", .F.)					 
					SA1->A1_LC := VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO)					
					SA1->(MsUnLock())	
					oLogM:nVlrNeu := VAL(oWSClient:oRetorno:oWSLsRetorno:oWSParametrofluxo[nW]:CVLPARAMETRO)				

				EndIf

			Next nW

		EndIf

	Else

		lRet := .F.
		oElimiResC:ElimiResid(SC5->C5_NUM)
		oLogM:cErroNeu := "Um erro inesperado ocorreu, a conexão não foi estabelecida com a neurotech."
	   	MsgInfo("O pedido <b>"+cValToChar(SC5->C5_NUM)+"</b> foi criado, porém ocorreu um erro inesperado e a conexão não foi estabelecida com a neurotech. Com isso o pedido foi excluído.", "Aviso" )		

	EndIf

	


	//LOG
	oLogM:cFilialx   := XFilial("ZZ8")
	oLogM:cOutXML    := oWSClient:cOutXML
	oLogM:cInXML     := oWSClient:cInXML
	oLogM:cNumNeu    := nNumProp
	oLogM:cNumPedido := SC5->C5_NUM
	oLogM:cCodVend   := M->UA_VEND
	oLogM:cCodOper   := M->UA_OPERADO
	oLogM:cCodCli    := oClienteM:cCodigo
	oLogM:cCliLoja   := oClienteM:cLoja
	oLogM:cCliNome   := oClienteM:cNome
	oLogM:cCliCGC    := oClienteM:cCGC
	oLogM:cRotina    := FunName()	    
	oLogM:cLimitNeu  := SUA->UA_VLRLIQ //MaFisRet(,"NF_TOTAL")  //VALOR DO PEDIDO	

	oLogC:Insert(oLogM)	
 
	
	
	// COLOCANCO STATUS NO PEDIDO DO CALL CENTER
	SUA->(DbSetOrder(8)) //UA_FILIAL, UA_NUMSC5, R_E_C_N_O_, D_E_L_E_T_
	SUA->(DbGoTop())
	If(SUA->(DbSeek(XFilial("SUA")+SC5->C5_NUM)))			 
		RecLock("SUA", .F.)
		SUA->UA_YNEUROT := cStatus
		SUA->(MsUnLock())
	EndIf

Return  lRet
