#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECFAT01  บAutor  ณMicrosiga           บ Data ณ  06/20/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNota Fiscal Locacao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMenu faturamento                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TECFAT01()
	
	Private oDlg := NIL
//	Private cLogo    := '\SYSTEM\LGRL'+cEmpAnt+'.BMP'
	Private cLogo 	  	:= GetSrvProfString("Startpath","")+"Logo\NFlogo.bmp"
	
	Private cAlias1	  	:= GetNextAlias()	
	Private oPrn	
	Private oFont8   	:= TFont():New("Times New Roman",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont8N   	:= TFont():New("Times New Roman",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont9N   	:= TFont():New("Times New Roman",9,9,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont9   	:= TFont():New("Times New Roman",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont12   	:= TFont():New("Times New Roman",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont10N  	:= TFont():New("Times New Roman",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont12N  	:= TFont():New("Times New Roman",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont16N  	:= TFont():New("Times New Roman",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont24N  	:= TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont10   	:= TFont():New("Times New Roman",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont11   	:= TFont():New("Times New Roman",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont11N  	:= TFont():New("Times New Roman",9,12,.T.,.T.,5,.T.,5,.T.,.F.)	
	
	CRIASX1()
	PERGUNTE("TECFAT01",.T.)
	
	DEFINE FONT oFont6 NAME "Courier New" BOLD
	    
	oPrn := TMSPrinter():New("Tecnocryo - Nota De Cobranca")
	oPrn:SetPortrait()
	oPrn:StartPage()
	
	Imprimir()
	
	oPrn:EndPage()
	
	oPrn:End()
	
	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE "Tecnocryo - Nota De Cobranca" OF oDlg PIXEL
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL	
	@ 015,017 SAY "Esta rotina tem por objetivo imprimir" OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 030,017 SAY "os boletos para formar o carn๊ de    " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 045,017 SAY "pagamento da dํvida ativa do estado. " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE	
	@ 6,167 BUTTON "&Imprime" SIZE 036,012 ACTION oPrn:Print()  OF oDlg PIXEL
	@ 28,167 BUTTON "&Setup"   SIZE 036,012 ACTION oPrn:Setup()   OF oDlg PIXEL
	@ 49,167 BUTTON "Pre&view" SIZE 036,012 ACTION oPrn:Preview() OF oDlg PIXEL
	@ 70,167 BUTTON "Sai&r"    SIZE 036,012 ACTION ODLG:END()    OF oDlg PIXEL	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	oPrn:End()
		                           
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHFAT002  บAutor  ณMicrosiga           บ Data ณ  08/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnalise de Parcelas  Gerando no Maximo at้ 5x no Carne      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Imprimir()
	
	Private nRow1     	:= 100
	Private nRow2     	:= 0
	Private nRow3     	:= 0
	Private nRow4     	:= 0
	Private nRow5     	:= 0
	Private nCol1       := 100						
          
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados da Nota Fiscal de Saidaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	LjMsgRun("Buscando Informacoes da Nota Fiscal",, {|| fDados()})

	cPedido := (cAlias1)->D2_PEDIDO    
	nMenosLin := 200
	//Criando Box da Pagina Total
	oPrn:Box(nRow1, 100, 1100-nMenosLin, 2380 )         
    
    //Box Intemediario cabecalho
    oPrn:Box(nRow1,1000,800-nMenosLin,1800 )    		

    //Logo Marca
//	oPrn:SayBitmap(nRow1+50,nCol1+600,cLogo,1100,190)
	oPrn:SayBitmap(nRow1+50,150,cLogo,780,110) 

	nRow1 := 450-nMenosLin	    

//    oPrn:Say(nRow1+10,110  ,"IDENTIFICAวรO DO EMITENTE:",oFont8)	
	oPrn:Say(nRow1+60,110  ,SM0->M0_NOMECOM,oFont8N)		
	oPrn:Say(nRow1+120,110 ,SM0->M0_ENDENT,oFont9)		
	oPrn:Say(nRow1+170,110 ,SM0->M0_BAIRENT +' - '+ TRANSFORM(Alltrim(SM0->M0_CEPENT),"@R 99.999-999"),oFont9)		
	oPrn:Say(nRow1+220,110 ,ALLTRIM(SM0->M0_CIDENT )+" - "+ALLTRIM(SM0->M0_ESTENT) ,oFont9)		
	oPrn:Say(nRow1+270,110 ,'Fone: '+TRANSFORM('2732256533',"@R (99)9999.9999"),oFont9)			  
	//NOTA DE COBRANCA
	nRow1 := 100

	oPrn:Say(nRow1+310-nMenosLin,1350 ,"NOTA",oFont16N)
	oPrn:Say(nRow1+410-nMenosLin,1370 ,"DE",oFont16N)
	oPrn:Say(nRow1+510-nMenosLin,1250 ,"COBRANวA",oFont16N)
		
	//Numero
	oPrn:Say(nRow1+450-nMenosLin,2000 ,"VIA UNICA" ,oFont11)
	oPrn:Say(nRow1+500-nMenosLin,2000 ,MV_PAR01 ,oFont11N)	
		
	nRow2 := 800-nMenosLin
	//Dados Da Tecnocryo
	oPrn:Line (nRow2+0,nCol1+0,nRow2+0,2380)
	
	//Box Intemediario cabecalho
    //oPrn:Box(nRow2+0,1700,950,2380)    			
	oPrn:Line (nRow2+150,nCol1+0,nRow2+150,2380)
	
	oPrn:Say(nRow2+10,110 ,'NATUREZA DE OPERAวรO:',oFont8)		
	oPrn:Say(nRow2+60,110 ,'LOCAวรO DE BENS MOVษIS',oFont8)			

	oPrn:Say(nRow2+10,1850 ,'DATA DE EMISSรO',oFont8)			    
	oPrn:Say(nRow2+60,1850 ,DTOC(STOD((cAlias1)->D2_EMISSAO)),oFont8)			    

	oPrn:Line (nRow2+300,nCol1+0,nRow2+300,2380)
	//oPrn:Box(nRow2+150,1500,1100,2380)    			

	nRow2:= 950	-nMenosLin
	oPrn:Say(nRow2+10,110 ,'INCRICAO ESTADUAL: ',oFont8)		
	oPrn:Say(nRow2+60,110 ,SM0->M0_INSC,oFont8)		

	oPrn:Say(nRow2+10,1510 ,'CNPJ: ',oFont8)				        
	oPrn:Say(nRow2+60,1510 ,TRANSFORM(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99"),oFont8)    
	
	//DESTINATARIO / REMETENTE
	oPrn:Say(nRow2+170,110 ,'DESTINATARIO / REMETENTE ',oFont8)				        		

	//Criando Box Cliente
	nRow3 := 1180	-nMenosLin
	oPrn:Box(nRow3+0, 100, 1520-nMenosLin, 2380 )         	
	oPrn:Box(nRow3+0, 100, 1410-nMenosLin, 2380 )         	
	oPrn:Box(nRow3+0, 100, 1290-nMenosLin, 2380 )         	
	oPrn:Box(nRow3+0, 1500,1520-nMenosLin, 1950 )

	oPrn:Box(1410-nMenosLin   , 100, 1520-nMenosLin, 1000 )
	
	oPrn:Say(nRow3+10,110  ,'NOME / RAZAO SOCIAL',oFont8)		
	oPrn:Say(nRow3+60,110  ,(cAlias1)->A1_NOME ,oFont8)			 
	
	oPrn:Say(nRow3+10,1530  ,'CNJP / CPF',oFont8)		
	oPrn:Say(nRow3+60,1530  ,(cAlias1)->A1_CGC ,oFont8)			
	
	oPrn:Say(nRow3+10,2000  ,'DATA DE VENCIMENTO',oFont8)		
	oPrn:Say(nRow3+60,2000  ,DTOC(Posicione("SE1",2,xFilial("SE1")+(cAlias1)->A1_COD+(cAlias1)->A1_LOJA+MV_PAR02+MV_PAR01,"E1_VENCTO")) ,oFont8)

	oPrn:Say(nRow3+120,110 ,'ENDERECO' ,oFont8)			
	oPrn:Say(nRow3+120,1530 ,'BAIRRO' ,oFont8)			
	oPrn:Say(nRow3+120,2000 ,'CEP' ,oFont8)				
	oPrn:Say(nRow3+170,110 ,ALLTRIM((cAlias1)->A1_END) ,oFont8)			
	oPrn:Say(nRow3+170,1530 ,ALLTRIM((cAlias1)->A1_BAIRRO) ,oFont8)			
	oPrn:Say(nRow3+170,2000 ,TRANSFORM((cAlias1)->A1_CEP,"@R 99.999-999") ,oFont8)			

	oPrn:Say(nRow3+230,110 ,'MUNICIPIO' ,oFont8)			
	oPrn:Say(nRow3+230,1050 ,'FONE/FAX' ,oFont8)			
	oPrn:Say(nRow3+230,1530 ,'ESTADO' ,oFont8)				
	oPrn:Say(nRow3+230,2000 ,'INSC. ESTADUAL' ,oFont8)				
	oPrn:Say(nRow3+280,110 ,ALLTRIM((cAlias1)->A1_MUN) ,oFont8)			
	oPrn:Say(nRow3+280,1050 ,ALLTRIM((cAlias1)->A1_TEL)+"/"+ALLTRIM((cAlias1)->A1_FAX) ,oFont8)			
	oPrn:Say(nRow3+280,1530 ,ALLTRIM((cAlias1)->A1_EST) ,oFont8)			
	oPrn:Say(nRow3+280,2000 ,ALLTRIM((cAlias1)->A1_INSCR) ,oFont8)			
	 		
	//Informacoes sobre produto
	nRow4 := 1600	-nMenosLin
	oPrn:Say(nRow4-50 ,110,'DADOS DO PRODUTO',oFont8)				
	oPrn:Box(nRow4+0  ,100, 2520-nMenosLin, 2380 )
	
	//box intermediario
	oPrn:Box(nRow4+0, 2050,2520-nMenosLin, 2380 )
	oPrn:Box(nRow4+0, 1400,2520-nMenosLin, 1750 )
	
	oPrn:Line (nRow4+80,nCol1+0,nRow4+80,2380)
	oPrn:Line (nRow4+160,nCol1+0,nRow4+160,2380)
	oPrn:Line (nRow4+240,nCol1+0,nRow4+240,2380)
	oPrn:Line (nRow4+320,nCol1+0,nRow4+320,2380)
	oPrn:Line (nRow4+400,nCol1+0,nRow4+400,2380)
	oPrn:Line (nRow4+480,nCol1+0,nRow4+480,2380)
	oPrn:Line (nRow4+560,nCol1+0,nRow4+560,2380)
	oPrn:Line (nRow4+640,nCol1+0,nRow4+640,2380)
	oPrn:Line (nRow4+720,nCol1+0,nRow4+720,2380)
	oPrn:Line (nRow4+800,nCol1+0,nRow4+800,2380)
    
	
	oPrn:Say(nRow4+10,600  ,'DESCRIวรO DO PRODUTO ',oFont8)	   		
	oPrn:Say(nRow4+10,1440 ,'QUANTIDADE',oFont8)	   
	oPrn:Say(nRow4+10,1800 ,'VALOR UNITARIO',oFont8)	   
	oPrn:Say(nRow4+10,2100 ,'VALOR TOTAL ',oFont8)	   	
	oPrn:Say(nRow4+810,2100,'TOTAL DA NOTA ',oFont8)	   	
    	
	DbSelectarea(cAlias1)
	(cAlias1)->(DbGotop())
	nRow45 := nRow4
	nRow4 +=  25
	nTotalNF := 0
	While .not. (cAlias1)->(EOF())	
	
		nRow4 +=  80
		
		fItens(nRow4)
		nTotalNF += (cAlias1)->D2_TOTAL

    	(cAlias1)->(DbSkip())
	Enddo

	oPrn:Say(nRow45+810+50,2090 ,Transform(nTotalNF,"@E 999,999.99"),oFont12n)			   
	
	nRow5 := 2600-nMenosLin
	oPrn:Say(nRow5-50 ,110,'DADOS ADICIONAIS',oFont8)

//	oPrn:Box(nRow5+0, 100, 2900, 2380 )    
	oPrn:Box(nRow5+0, 100, 2750-nMenosLin, 2380 )
	cMenNota := POSICIONE("SC5",1,xFilial("SC5")+cPedido,"C5_MENNOTA")    
	oPrn:Say(nRow5+25,0110 ,cMenNota,oFont10)		   	       
	
	nTiraLin := 350-nMenosLin
//	oPrn:Say(nRow5+380,110 ,"OPERACAO NAO SUJEITA AO I.S.S DE ACORDO COM A LEI COMPLEMENTAR 116/03",oFont12)		   
	oPrn:Say(nRow5+380-nTiraLin,110 ,"OPERACAO NAO SUJEITA AO I.S.S DE ACORDO COM A LEI COMPLEMENTAR 116/03",oFont12)		   

	oPrn:Box(nRow5+500-nTiraLin, 100, 3320-nTiraLin-nMenosLin, 2380 )       
	oPrn:Line(nRow5+610-nTiraLin,nCol1+0,nRow5+610-nTiraLin,1800)		
	oPrn:Say(nRow5+515-nTiraLin,110 ,"ATESTAMOS QUE OS DADOS ACIMA CONFEREM COM OS BENS CEDIDOS EM LOCACAO ",oFont8)		   
	oPrn:Say(nRow5+555-nTiraLin,110 ,"PELA TECNOCRYO COMERCIO, SERVICOS E MANUTENCOES LTDA.",oFont8)		   

	oPrn:Box(nRow5+500-nTiraLin, 1800 , 3320-nTiraLin-nMenosLin, 2380 )         	
	oPrn:Box(nRow5+610-nTiraLin, 1200, 3320-nTiraLin-nMenosLin, 1800 )         	
	oPrn:Box(nRow5+610-nTiraLin, 500, 3320-nTiraLin-nMenosLin,  1200 )         	

	//Assinatura
	nRow6 := 3050-nTiraLin-nMenosLin
	oPrn:Say(nRow6+165,110 ,"DATA DE RECEBIMENTO",oFont8) //Criar parametro
	oPrn:Say(nRow6+165,510 ,"IDENTIFICACAO E ASSINATURA DO RECEBEDOR",oFont8) //Criar parametro
	oPrn:Say(nRow6+165,1210 ,"NOME LEGIVEL",oFont8) //Criar parametro
	oPrn:Say(nRow6+80,1900 ,"NOTA DE COBRANCA",oFont8) //Criar parametro
	oPrn:Say(nRow6+165,1900 ,MV_PAR01 ,oFont11N)	
        	
	oPrn:EndPage()
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDados    บAutor  ณMicrosiga           บ Data ณ  06/20/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca dados do Cliente		                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDados()       

	cLoja := Posicione("SF2",1,xFilial("SF2")+MV_PAR01+MV_PAR02,"F2_LOJA") 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados do Nota Fiscalณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BEGINSQL ALIAS cAlias1
		
		SELECT A1_COD, A1_LOJA, A1_NOME, A1_END, A1_EST, A1_INSCR, A1_MUN,  
		A1_BAIRRO, A1_CGC,  A1_CEP, D2_EMISSAO, A1_TEL, A1_FAX, D2_PEDIDO,
		D2_ITEM,B1_COD, B1_DESC, D2_PRCVEN, D2_TOTAL AS D2_TOTAL, D2_QUANT
		FROM %table:SD2% SD2 JOIN  %table:SA1%  SA1 ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
		JOIN  %table:SB1% SB1 ON D2_COD = B1_COD
		WHERE D2_DOC = %Exp:MV_PAR01% AND D2_SERIE = %Exp:MV_PAR02% AND D2_LOJA = %Exp:cLoja%
		AND SD2.D_E_L_E_T_ <> '*'
		AND SB1.D_E_L_E_T_ <> '*'
		AND SA1.D_E_L_E_T_ <> '*'
		AND A1_FILIAL = %Exp:xFilial("SA1")% 
		AND B1_FILIAL = %Exp:xFilial("SB1")% 

	ENDSQL

Return                                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECFAT01  บAutor  ณbrittes             บ Data ณ  06/23/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGERA PERGUNTAS                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CRIASX1()

Local aSX1           := {}
Local aESTRUT        := {}
Local i              := 0
Local j              := 0
Local lSX1	         := .F.
Local cTexto         := ''
Local cAlias         := ''

aEstrut := {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VAR01","X1_DEF01","X1_DEF02","X1_F3"}

Aadd(aSX1,{"TECFAT01","01","N Nota Fiscal ?  	",".",".","MV_CH1","C",9,0,0,"G","MV_PAR01","","","SF2VEI"})
Aadd(aSX1,{"TECFAT01","02","Serie ?  	",".",".","MV_CH2","C",3,0,0,"G","MV_PAR02","","",""})
//Aadd(aSX1,{"TECFAT01","02","Mes?  	",".",".","MV_CH3","C",2,0,0,"G","MV_PAR3","","",""})
//Aadd(aSX1,{"TECFAT01","02","Ano?  	",".",".","MV_CH4","C",4,0,0,"G","MV_PAR04","","",""})

ProcRegua(Len(aSX1))
SX1->(DbSetOrder(1))

If  !SX1->(DbSeek("TECFAT01"))
	
	For i:= 1 To Len(aSX1)
		If !Empty(aSX1[i][1])                                  		
			lSX1	:= .T.
			If !(aSX1[i,1]$cAlias)
				cAlias += aSX1[i,1]+"/"
			EndIf
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If FieldPos(aEstrut[j])>0 .And. aSX1[i,j] != NIL
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	Next i
	
EndIf

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECFAT01  บAutor  ณMicrosiga           บ Data ณ  06/21/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fitens(nRow)
	
	oPrn:Say(nRow,0110 ,(cAlias1)->B1_DESC,oFont10)		   	       
	oPrn:Say(nRow,1450 ,Transform((cAlias1)->D2_QUANT,"@E 999,999.99"),oFont10)		   	       
	oPrn:Say(nRow,1800 ,Transform((cAlias1)->D2_PRCVEN,"@E 999,999.99"),oFont10)			   
	oPrn:Say(nRow,2090 ,Transform((cAlias1)->D2_TOTAL,"@E 999,999.99"),oFont10)			   

Return()