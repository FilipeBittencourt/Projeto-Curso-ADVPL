#INCLUDE "TOTVS.CH" 
#INCLUDE "TBICONN.CH"  
#include "Rwmake.ch"                   

#define TOT_ITENS   6 // itens por pagina
#define IT_ITEM     1
#define IT_CODPRO   2
#define IT_DESCRI   3
#define IT_QTDPEND  4
#define IT_LOCALIZ  5
#define IT_LOTE		6
#define IT_SERIE	7
#define IT_PACIENTE	8

#define IT_CODPROC   1
#define IT_DESCRIC   2
#define IT_QTDPENDC  3

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

 @Title     : FCOFRE01
 @Owner     : FACILE - Facile Sistemas
 @CopyRight : Central Oftalmica (c) 2015
 @Author    : Gabriel Rossi Mafioletti                
 @Version   : P11 - Protheus 11      
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : SIGAFAT - Faturamento
 @DCT       : 

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

 @Descriptions

RelatÛrio de Impressao de Picking List

 Descriptions@                                                                  

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/ 



User Function FCOFRE01( lPick, cFilOri )
      
Local cPedido	:=	""
Local aItens	:=	{}		//Itens Totais do Pedido
Local aItFalt	:=	{}      //Itens Sem Estoque Para Atender
Local aItAtend	:=	{}      //Itens Atendidos Pelo Estoque
Local nIdx		:=	1
Local nCaixa	:=	0
Local nItem		:=	1
//Local nTotal	:=	0
Local nPags		:=	0
Local nPagina	:=	0
Local nItens	:=	0
Local cHora		:=	Left(Time(),5) 
Local cImp	:= ""
Local cLocal	:= SC5->C5_YOPCARM

//===============================================================================================
// Realiza-se o backup da filial corrente a fim de que as consultas sejam referente as mesmas
//===============================================================================================
Local bckFilAnt  := cFilAnt  

PRIVATE nTotal	:=	0

Private nRet  	 := .T.

Private lNewImp   := .F.
Private cFilPick  := "" 

//CONEXAO
PRIVATE oObj  := tSocketClient():New()
PRIVATE nPort := 9100

PRIVATE cSendDados := ""

//========================================================================
// Autor : JessÈ ||  Data : 17/11/2015   
//========================================================================
// Vari·cel que controla a incidÍncia de Impress„/Reimpress„o dos Picking
//========================================================================
Default lPick   := .F.
Default cFilOri := ""  

/*
	//VERIFICA SE A FUNCAO CHAMADA FOI PELA DE REMESSA
	IF PROCNAME(9) == "U_PEDRO"

		RETURN()
	
	ENDIF

	*/
    //=======================================================================================================================
    // Vari·vel que controla a incidÍncia de Impress„/Reimpress„o dos Picking.
    // Uma vez que a opÁ„o de impress„o tenha sido INCLUIR/ALTERAR, o Picking ser· IMPRESSO.Caso contr·rio, ser· REIMPRESSO.
    //=======================================================================================================================
	lNewImp := lPick  
	                                              
	aItens := GetItPick()
	
	//SIGNIFICA QUE O PEDIDO TEM VISION DE ENCOMENDA E NAO IMPRIME O PICKING
	IF nRet == .T.
	
			If Len(aItens) > 0                           
				FCleanEnd()
				GetInfoIt(aItens,aItFalt,aItAtend)
		/*	Else
				MsgInfo("N„o H· Itens DisponÌveis no Pedido para RealizaÁ„o de Picking!")*/
			EndIf
			
		If Len(aItAtend) > 0
			
					nPags   := ceiling(len(aItAtend)/TOT_ITENS)
					
					If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
						ljmsgrun("Iniciando a confeccao do picking em ("+cvaltochar(nPags)+" paginas)")
					ENDIF
		
				
					nTotal := Len(aItAtend)
					nIdx := 1
					For nPagina := 1 to nPags
					
						//imprime saldo contrato
						IF nPagina == 1
							Contrat()
						ENDIF
					
						// imprime cabecalho
						nItens := 0
						printHead(nPagina, nPags, cHora)
						For nItem := 1 to TOT_ITENS       
							if nIdx <= len(aItAtend)
								nItens ++
								printItem(aItAtend[nIdx])
								nIdx++                
							else
								printClear()                    
							endif
						Next nItem
						
						// impressao do rodape
						printFoot(nItens, nTotal,nPagina,nPags)  
						
					Next nPagina
					//MsClosePort(@nHandle)
					//msginfo("Fim da impressao!"+CRLF+"("+cvaltoChar(nPags)+") paginas impressas.")
					
					//PEDRO PALAORO
					//07/07/2015
					//ALTERA CAMPO SE FOR A PRIMEIRA IMPRESSAO DO PICKING
					IF SC5->C5_YPICK == 'N'
						RECLOCK("SC5",.F.)
							SC5->C5_YPICK := 'S'
							SC5->C5_YDTPICK := DATE()
							SC5->C5_YHRPICK := Left(Time(),5)
						SC5->(MSUnlock())
					ENDIF	
					/*------------------------------------------------------*/
					
			// INICIA A IMPRESSAO DO PROTOCOLO DE ENTREGA
				
				If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
					ljmsgrun("Iniciando a confeccao do PROTOCOLO DE ENTREGA")
				endif
				
				aItens := {}
				aItens := GetItPickC()
				nTotal	:=	0
			
				If Len(aItens) > 0
				
					nIdx := 1
						// imprime cabecalho
						nItens := 0
						printHeadC(cHora)
						For nItem := 1 to len(aItens)
							if nIdx <= len(aItens)
								nItens ++
								printItemC(aItens[nIdx])
								nIdx++                
							else
								printClear()                    
							endif
						Next nItem
						// impressao do rodape
						printFootC(nItens, nTotal)
				
				ENDIF
				
			IF  !(cUserName $ 'pedropalaoro') 
				
					IF cLocal = "01"
					
						If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
							LjMsgRun("Conectando a impressora em ES")
						endif
						
						cIP   := "192.168.1.153"
						nRet  := oObj:Connect( nPort, cIp, 10 )
					
					ENDIF
					
					IF cLocal = "02"
						
						If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
							LjMsgRun("Conectando a impressora MP4200 em SP")
						endif
						
						cIP   := "192.168.4.151"
						//cIP   := "201.6.128.239"
						nRet  := oObj:Connect( nPort, cIp, 10 )
					
					ENDIF
					
					IF cLocal = "03"
						
						If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
							LjMsgRun("Conectando a impressora MP4200 em MG")
						endif
						
						cIP   := "192.168.3.151"
						nRet  := oObj:Connect( nPort, cIp, 10 )
					
					ENDIF
					
				ELSE
				
					If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
						LjMsgRun("Ola Pedro, Conectando a impressora MP4200")
					endif
					
					cIP   := "192.168.1.151"
					nRet  := oObj:Connect( nPort, cIp, 10 )
					
				ENDIF
					
			If oObj:IsConnected()
			
				oObj:Send(cSendDados)
				
				oObj:CloseConnection()
				
			else
					If !IsBlind() //VERIFICA SE A TELA NAO FOI CHAMADA AUTOMATICA
						LjMsgRun("Erro na Conexao!")
					endif
					
					If lNewImp
						RECLOCK("SC5",.F.)
							SC5->C5_YPICK := 'N'
							SC5->C5_YDTPICK := CTOD(SPACE(8))
							SC5->C5_YHRPICK := ''
						SC5->(MSUnlock())
					Endif 
					
				EndIf
		Else
				
				
			If lNewImp
			
				RECLOCK("SC5",.F.)
				SC5->C5_YPICK := 'N'
				SC5->C5_YDTPICK := CTOD(SPACE(8))
				SC5->C5_YHRPICK := ''
				SC5->(MSUnlock())    
			Endif  
				
				
		EndIf
		
	ENDIF
	
Return

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para verificar saldos dos itens nos pedidos

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   


Static Function GetItPick()

Local _aRet	:=	{}
Local _cAlias	:=	GetNextAlias()


BeginSql Alias _cAlias

	SELECT * FROM (
	SELECT  C6_ITEM, 
			C6_PRODUTO, 
			C6_LOTECTL, 
			C6_QTDVEN - (SELECT ISNULL(SUM(B.C9_QTDLIB),0) 
							FROM SC9010 B 
							WHERE B.C9_FILIAL = A.C6_FILIAL 
									and B.C9_PEDIDO = A.C6_NUM 
									AND B.C9_ITEM = A.C6_ITEM 
									AND B.C9_BLEST = '10'  
									and B.%NotDel% ) As QTDPEND,
		   C6_YPACI
	from SC6010 A
	where A.C6_FILIAL = %Exp:SC5->C5_FILIAL%     // AlteraÁ„o que posiciona sobre a filial do Pedido posicionado     
	and A.C6_NUM = %Exp:SC5->C5_NUM%
	AND (SUBSTRING(A.C6_PRODUTO,5,6) <> '000000' OR SUBSTRING(A.C6_PRODUTO,1,4) IN ('E211','E210') //PARA NAO SAIR GENERICO MAS DEIXAR SAIR DE ESTOJO
			OR C6_PRODUTO = 'SV0000000000033') //PARA SAIR RECLASSIFICACAO (SOLICITACAO DA TELMA)
	AND A.C6_BLQ <> 'R'
	and A.%NotDel%
	) A
	WHERE A.QTDPEND > 0

EndSql

If (_cAlias)->(!EOF())

	IF ALLTRIM((_cAlias)->C6_PRODUTO) == '160E999999' .and. !(ALLTRIM(cUserName) $ (GETMV("COF_USRENC")))
		nRet := .F.
		
		RETURN
	ENDIF
	
	While (_cAlias)->(!EOF()) 
	    
		//========================================================================================
		// Autor     : JessÈ Augusto   Data : 01 / 02 / 2016
		//========================================================================================
        // DescriÁ„o : AlteraÁ„o que inclui o Paciente na listagem dos itens do Pedido de Venda.
		//========================================================================================
	   
		aAdd(		_aRet					,;												 // 
					{(_cAlias)->C6_ITEM		,;                                               // Item do Pedido
					(_cAlias)->C6_PRODUTO	,;                                               // Produto
					POSICIONE("SB1", 1, xFilial("SB1") + (_cAlias)->C6_PRODUTO, "B1_DESC"),; // DescriÁ„o do Produto
					(_cAlias)->QTDPEND		,;  											 // Quantidade
					""						,;  											 //
					""						,;  											 //
					""						,;  											 //
					(_cAlias)->C6_YPACI })      											 // Paciente 
					
		           (_cAlias)->(DbSkip())
	
	 EndDo
EndIf

(_cAlias)->(DbCloseArea())	

Return _aRet

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para separar os itens que atendem ao pedido e os que n„o atendem

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   



Static Function GetInfoIt(aItens,aItFalt,aItAtend)

Local _nI	:=	0
Local _nJ	:=	0

For _nI := 1 to Len(aItens)
	For _nJ := 1 to aItens[_nI,IT_QTDPEND]
	
		GetItLoc(aItens[_nI],aItAtend,aItFalt,aItens[_nI,IT_CODPRO])
	
	Next _nJ    
	                
Next _nI

Return

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para procurar a localizaÁ„o do item no estoque

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   


Static Function GetItLoc(aItem,aItAtend,aItFalt,_cProd)

Local _cAlias := GetNextAlias()
Local _cLocal	:= SC5->C5_YOPCARM




//ALTERADO QUERY PARA NAO MOSTRAR PRODUTOS VENCIDOS
//PEDRO PALAORO
//25-04-16

	//PARA PEGAR AS VISION ANTIGAS COM PROBLEMA DE LEITURA DO LOTE
	IF !(SubStr(_cProd,4,1) = '160E')
	
		//SE FOR BLISTER ENTAO VENCIMENTO ACIMA DE 5 DIAS DE VENCIMENTO
		IF SubStr(_cProd,4,1) = 'T'
		
			BeginSql Alias _cAlias
			
				SELECT TOP 1 BF_LOTECTL, B8_DTVALID, BF_LOCALIZ, BF_NUMSERI, A.R_E_C_N_O_ as NRREC
				FROM %Table:SBF% A
				JOIN %Table:SB8% B ON B.B8_FILIAL = A.BF_FILIAL AND B.B8_LOCAL = A.BF_LOCAL AND B.B8_PRODUTO = A.BF_PRODUTO AND B.B8_LOTECTL = A.BF_LOTECTL
				WHERE BF_FILIAL = '9001'                
					AND BF_LOCAL = %Exp:_cLocal%
					AND BF_PRODUTO = %Exp:_cProd%
					AND BF_YPEDVEN	<> %Exp:SC5->C5_NUM%
					AND BF_YDTPICK = ' ' 
					AND BF_EMPENHO = 0
					AND BF_LOCALIZ NOT IN ('CAIXADAE','DAE_SP01','DAE_MG01','CAIXAVEN','SPTEMP01','MGTEMP01')
					AND BF_QUANT > 0
					AND A.%NotDel%
					AND B.%NotDel%
					AND B.B8_DTVALID >= CONVERT(VARCHAR(10),CAST(DATEADD(DAY,5, getdate()) AS DATETIME),112)
				ORDER BY B8_DTVALID, BF_LOTECTL
			
			EndSql
		
		ELSE
			
			//QUALQUER OUTRO ACIMA DE 1 ANO DE VENCIMENTO
			
			BeginSql Alias _cAlias
			
				SELECT TOP 1 BF_LOTECTL, B8_DTVALID, BF_LOCALIZ, BF_NUMSERI, A.R_E_C_N_O_ as NRREC
				FROM %Table:SBF% A
				JOIN %Table:SB8% B ON B.B8_FILIAL = A.BF_FILIAL AND B.B8_LOCAL = A.BF_LOCAL AND B.B8_PRODUTO = A.BF_PRODUTO AND B.B8_LOTECTL = A.BF_LOTECTL
				WHERE BF_FILIAL = '9001'                
					AND BF_LOCAL = %Exp:_cLocal%
					AND BF_PRODUTO = %Exp:_cProd%
					AND BF_YPEDVEN	<> %Exp:SC5->C5_NUM%
					AND BF_YDTPICK = ' ' 
					AND BF_EMPENHO = 0
					AND BF_LOCALIZ NOT IN ('CAIXADAE','DAE_SP01','DAE_MG01','CAIXAVEN','SPTEMP01','MGTEMP01')
					AND BF_QUANT > 0
					AND A.%NotDel%
					AND B.%NotDel%
					AND B.B8_DTVALID >= CONVERT(VARCHAR(10),CAST(DATEADD(YEAR,1, getdate()) AS DATETIME),112)
				ORDER BY B8_DTVALID, BF_LOTECTL
				
			EndSql
			
		ENDIF
		
	ELSE
	
		BeginSql Alias _cAlias
			
				SELECT TOP 1 BF_LOTECTL, B8_DTVALID, BF_LOCALIZ, BF_NUMSERI, A.R_E_C_N_O_ as NRREC
				FROM %Table:SBF% A
				JOIN %Table:SB8% B ON B.B8_FILIAL = A.BF_FILIAL AND B.B8_LOCAL = A.BF_LOCAL AND B.B8_PRODUTO = A.BF_PRODUTO AND B.B8_LOTECTL = A.BF_LOTECTL
				WHERE BF_FILIAL = '9001'                
					AND BF_LOCAL = %Exp:_cLocal%
					AND BF_PRODUTO = %Exp:_cProd%
					AND BF_YPEDVEN	<> %Exp:SC5->C5_NUM%
					AND BF_YDTPICK = ' ' 
					AND BF_EMPENHO = 0
					AND BF_LOCALIZ NOT IN ('CAIXADAE','DAE_SP01','DAE_MG01','CAIXAVEN','SPTEMP01','MGTEMP01')
					AND BF_QUANT > 0
					AND A.%NotDel%
					AND B.%NotDel%
					//AND (B.B8_DTVALID >= CONVERT(VARCHAR(10),CAST(DATEADD(YEAR,1, getdate()) AS DATETIME),112))
				ORDER BY B8_DTVALID, BF_LOTECTL
				
			EndSql
			
	ENDIF

If (_cAlias)->(!EOF())
	aAdd(aItAtend,aClone(aItem))
	aItAtend[Len(aItAtend),IT_LOCALIZ]	:=	(_cAlias)->BF_LOCALIZ
	aItAtend[Len(aItAtend),IT_LOTE]		:=	(_cAlias)->BF_LOTECTL
	aItAtend[Len(aItAtend),IT_SERIE]	:=	(_cAlias)->BF_NUMSERI
	aItAtend[Len(aItAtend),IT_QTDPEND]	:=	1
	SBF->(DbGoTo((_cAlias)->NRREC))
	Reclock("SBF",.F.)
	SBF->BF_YPEDVEN	:=	SC5->C5_NUM
	SBF->BF_YDTPICK := 	Date()
	SBF->BF_YFILPED :=  SC5->C5_FILIAL
	SBF->(MsUnlock())
Else
	aAdd(aItAtend,aClone(aItem))
	aItAtend[Len(aItAtend),IT_LOCALIZ]	:=	""
	aItAtend[Len(aItAtend),IT_LOTE]		:=	""
	aItAtend[Len(aItAtend),IT_SERIE]	:=	""
	aItAtend[Len(aItAtend),IT_QTDPEND]	:=	0
//	aAdd(aItFalt,aClone(aItem))    	
//	aItFalt[Len(aItFalt),IT_QTDPEND]	:=	1
EndIf                  
               
(_cAlias)->(DbCloseArea())

Return


//Comandos Impressora

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para impress„o de cabeÁalho de picking

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   

Static function printHead(nPagina, nPags, cHora)
    local cPagina := strzero(nPagina,3)
    local cPags   := strzero(nPags,3)
    local lFound  := posicione("sa1",1,xfilial("sa1")+sc5->(c5_cliente+c5_lojacli),"found()")
    local cNome   := Alltrim(SC5->C5_CLIENTE) +'-'+ alltrim(upper(sa1->a1_nome))   
    local cRota   := TAMSX3("DA8_DESC")[1]
	local cObs	  :=	PADR("Obs: " + ALLTRIM(SC5->C5_YOBS)	,144)
    Local aObs	  :=	{Substr(cObs,1,48),Substr(cObs,49,96),Substr(cObs,97,144)}
    Local cFilName:= ""
	Local _ni	                          
    Local _aEnd	 :=	{}                 
    Local _aEmps := {}                                        
    
    Local cTpImp   :=""
    Local cCaption := ""	            
    Local cFilPed  := SC5->C5_FILIAL
	Local cPed := SC5->C5_NUM
	Local cAlias := GetNextAlias()
	LOCAL cSend := printQR(SC5->(C5_FILIAL+C5_NUM))

		//IMPRIME O QRCODE
    	cSendDados += ( cSend )
	
	
	//PREENCHE A ROTA NO PICKING
	cRota := SA1->A1_YROTA
	
	cRota := ALLTRIM(POSICIONE("DA8",1,xFilial("DA8")+cRota,"DA8_COD"))
	
	cRota := SA1->(iif(empty(cRota),"SEM ROTA", cRota)) 
	
	IF cRota <> "SEM ROTA"
	
		cRota := POSICIONE("DA8",1,xFilial("DA8")+cRota,"DA8_DESC")
		
	ENDIF
	
	BEGINSQL ALIAS cAlias
	
		SELECT TOP 1 C9_PEDIDO FROM SC9010 SC9 
			WHERE SC9.C9_FILIAL = %EXP:cFilPed%
			and SC9.C9_PEDIDO = %EXP:cPed%
			and SC9.C9_BLEST = '10' 
			and SC9.D_E_L_E_T_ = ''
	
	ENDSQL
	
    //|Pontin - Busca informacoes da empresa e filial |
    cFilName	:= Alltrim(FWFilName( cEmpAnt, cFilAnt))
    
    //==========================================================================================
    // Autor : JessÈ  DescriÁ„o: ObtÈm o nome da empresa conforme o Pedido informado na seleÁ„o
    //==========================================================================================
    If !lNewImp     
    
    	_aEmps := FWLoadSM0()  
    	
    	_nPos := aScan(_aEmps,{|x| Alltrim(x[2])==Alltrim(cFilPed)})
    	
    	If _nPos > 0 
    		cFilName := Alltrim(_aEmps[_nPos][7])
    	Endif 
    		
    	
    Endif 
    
	cSendDados += (chr(27)+chr(64)) 			// ESC @
	cSendDados += (chr(27)+chr(72)) 			// ESC H
	cSendDados += (chr(27)+chr(87)+chr(49)) 	// ESC W 1
	cSendDados += (chr(27)+chr(69))		// ESC E  
    
	
    cCaption := Iif( lNewImp, "Picking", "Picking - REIMPRESSAO")
    
    cSendDados += (padc(cCaption,24)+chr(10))    
	
	//==================================================================================================================
    // Atualiza o conte˙do do campo para efeito de controle de impress„o do Picking.
    //==================================================================================================================
	If SC5->C5_YPICK == 'N' 
		RECLOCK("SC5",.F.)
		   SC5->C5_YPICK := 'S'
		   SC5->C5_YDTPICK := DATE()
		   SC5->C5_YHRPICK := Left(Time(),5)
		SC5->(MSUnlock())
    Endif    
		
	cSendDados += (chr(27)+chr(64)) 								// ESC @
    cSendDados += (chr(27)+chr(72)) 								// ESC H  
	
	cSendDados += (padr("Rota"+PADL(SC5->C5_YOPCARM+" - "+cRota,40,"."),48)+chr(10))
	cSendDados += (padr(cNome,48)+chr(10)) 
	cSendDados += (padr("PEDIDO:"+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"-DATA/HORA:"+dtoc(Date())+"-"+cHora+"H",48)+chr(10))
	IF SC5->C5_YPORTAL <> 0
		cSendDados += (padr("PORTAL:"+cValtoChar(SC5->C5_YPORTAL)+"-User:"+PADL(ALLTRIM(SC5->C5_YNOMVEN)+"-PAG:"+cPagina+"/"+cPags,28,"."),48)+chr(10))
	ELSE
		cSendDados += (padr("User:"+PADL(ALLTRIM(SC5->C5_YNOMVEN)+" - PAG:"+cPagina+"/"+cPags,40,"."),48)+chr(10))      
	ENDIF
                                    
    For _nI	:=	1 to Len(aObs)                       
   	    cSendDados += (padr(aObs[_nI],48)+chr(10))
   	Next
	
	
	IIF(ALLTRIM((cAlias)->C9_PEDIDO) <> '',cSendDados += (padr("--- PEDIDO PARCIALMENTE ATENDIDO ---",37)+chr(10)),.F.)
	
	cSendDados += (replicate(chr(196),48)+chr(10))

	
	/*
    cSendDados += (chr(27)+chr(64)) 					// ESC @
    cSendDados += (chr(27)+chr(72)) 					// ESC H
	*/
	(cAlias)->(DbCloseArea())

return

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para impress„o de rodapÈ de Picking

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   


static function printFoot(nItens, nTotal,nPagina,nPags)
    local cItens := cvaltochar(nItens)
    local cTotal := cvaltochar(nTotal)
    
    sleep(800)
     
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H

      
    /*
    inicio teste impressao codigo de barras PDF-417
    */
    //cSendDados += (chr(29)+ chr(107)+ chr(128)+"84422"+"05"+"000001"+SC5->C5_NUM+SC5->(C5_CLIENTE+C5_LOJACLI)+ chr(10))
    /*
    fim teste impressao codigo de barras PDF-417
    */

    cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1                   
    cSendDados += (chr(27)+chr(69)) // ESC E
    cSendDados += (padr("ITENS NESTA PAGINA:",19)+padl(cItens,5)+chr(10))
    cSendDados += (padr("TOTAL DO PEDIDO:",19)+padl(nTotal,5)+chr(10))
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H

    // salto de 2 linhas
    cSendDados += (chr(10))
    // picote
    cSendDados += (chr(27))

	If nPagina <> nPags
		//PARCIAL
	    cSendDados += (chr(109))
	Else
		//TOTAL
		cSendDados += (chr(109))
		//PRICKINK JA IMPRESSO, ENTAO IMPRIME PROTOCOLO DE ENTREGA
		//PEDRO PALAORO
		//oObj:CloseConnection()
		//U_FCOFRE04()
	    //cSendDados += (chr(119))	
	EndIf    
    
    cSendDados += (chr(27)+chr(64)) // ESC @
return


/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
FunÁ„o para Imprimir os Itens do Picking

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   



static function printItem(aItem)     

    Local cItem   	:= aItem[IT_ITEM]
    Local cProduto	:= SubStr(aItem[IT_DESCRI],1,40) 
    Local nQtdVen 	:= aItem[IT_QTDPEND]
    Local cLocaliz  := aItem[IT_LOCALIZ]
    Local cLote  	:= aItem[IT_LOTE]
    Local cSerie    := aItem[IT_SERIE]
    Local cQtdVen 	:= cValToChar(nQtdVen)
    Local cCodPro	:= aItem[IT_CODPRO]
    Local cPaciente := aItem[IT_PACIENTE] 
    
    
    //cSendDados += (padr("COD:"+Alltrim(cCodPro)+" - Pac: "+Alltrim(cPaciente) ,48)+chr(10))	
    cSendDados += (padr(cItem+"> "+cProduto+" x "+cQtdVen,48)+chr(10))
	//cSendDados += (cItem+">"+ALLTRIM(cProduto)+" x "+cQtdVen+chr(10))
    cSendDados += (padr("END: "+Alltrim(cLocaliz) + '-' + Alltrim(cSerie)+" / PAC: "+Alltrim(cPaciente)  ,48)+chr(10))
        	
    
	//cSendDados += (padr("LOTE: "+cLote,48)+chr(10))
	//cSendDados += (padr("SERIE: "+cSerie,48)+chr(10))
    cSendDados += (replicate(chr(196),48)+chr(10))
return

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Imprime Item em Branco para padronizar o tamanho dos Pickings

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   
      

static function printClear()
    cSendDados += (chr(10)+chr(10)+chr(10))
return

//Limpa os registros
//Retirado ExecuÁ„o via tcsqlexec pois o mesmo trava o sistema em tabela de processo
//Pedro Palaoro
Static Function FCleanEnd()

LOCAL cAlias := GetNextAlias()
LOCAL sArea := GetArea()

/*Local _cQuery	:=	"UPDATE " + RETSQLNAME('SBF') + " SET BF_YPEDVEN = '', BF_YDTPICK = '' WHERE BF_FILIAL = '9001' AND BF_YPEDVEN = '" + SC5->C5_NUM + "' "
TcSqlExec(_cQuery)
*/
	BEGINSQL alias cAlias
		SELECT BF_FILIAL,BF_NUMSERI FROM %TABLE:SBF% WHERE BF_FILIAL = '9001' AND BF_YFILPED = %EXP:SC5->C5_FILIAL% AND BF_YPEDVEN = %EXP:SC5->C5_NUM%
	ENDSQL
	
	SBF->(DbSelectArea("SBF"))
	SBF->(DbSetOrder(3))
	SBF->(DBGOTOP())
	
	WHILE (cAlias)->(!Eof())
		
		lFound := SBF->(DbSeek((cAlias)->(BF_FILIAL+BF_NUMSERI)))
		
		IF lFound
			Reclock("SBF",.F.)
			SBF->BF_YPEDVEN	:=	""
			SBF->BF_YDTPICK := 	ctod("")
			SBF->BF_YFILPED := ""
			SBF->(MsUnlock())
		ENDIF
		
		SBF->(DBGOTOP())
		
		(cAlias)->(dbSkip())
		
	ENDDO
	
	DBCLOSEAREA("SBF")
	RestArea(sArea)
	

Return

STATIC FUNCTION Contrat()

local cAlias := GetNextAlias()
local nIdx := 1
local nItem := 1
local _aCont := {}

	BEGINSQL alias cAlias
	
		SELECT 
			B1_DESC DESCRICAO,
			SUM(ADB_QUANT) - SUM(ADB_QTDEMP) SALDO
		FROM ADB010 ADB
			INNER JOIN ADA010 ADA ON ADA_FILIAL = ADB_FILIAL AND ADA_NUMCTR = ADB_NUMCTR AND ADA.D_E_L_E_T_ = ''
			INNER JOIN SB1010 SB1 ON B1_COD = ADB_CODPRO AND SB1.D_E_L_E_T_ = ''
		WHERE 
			ADB_CODCLI = %EXP:SC5->C5_CLIENTE%
			AND ADB_LOJCLI = %EXP:SC5->C5_LOJACLI%
			AND ADA_STATUS IN ('B','C')
			/*SOMENTE PEGA OS QUE TEM SALDO REAL*/
			AND (SELECT SUM(ADB_QUANT) - SUM(ADB_QTDEMP) 
					FROM ADB010 A 
					WHERE ADB.ADB_FILIAL = A.ADB_FILIAL 
					AND ADB.ADB_NUMCTR = A.ADB_NUMCTR
					AND ADB.ADB_CODPRO = A.ADB_CODPRO
					AND A.D_E_L_E_T_ = '') >0
			AND ADB.D_E_L_E_T_ = ''
		GROUP BY SUBSTRING(ADB_CODPRO,1,4),B1_DESC,ADB_CODCLI, ADB_LOJCLI
		ORDER BY 1,2
		
	ENDSQL
	
	If (cAlias)->(!EOF())
		While (cAlias)->(!EOF()) 
			aAdd(_aCont,{(cAlias)->DESCRICAO,(cAlias)->SALDO})
			(cAlias)->(DbSkip())
		EndDo
	EndIf

			cSendDados += (replicate(chr(196),48)+chr(10))
			cSendDados += (padc('SALDO DOS CONTRATOS',48)+chr(10))
			cSendDados += ('*JA DEDUZIDOS DOS PEDIDOS PENDENTES'+chr(10))
	nIdx := 1
	
	nItens := 0
	For nItem := 1 to len(_aCont)
		if nIdx <= len(_aCont)
			nItens ++
			cSendDados += (padr(ALLTRIM(_aCont[nItem][1])+PADL(cValToChar(_aCont[nItem][2]),48-(LEN(ALLTRIM(_aCont[nItem][1]))+LEN(cValToChar(_aCont[nItem][2]))),"."),48)+chr(10))
			nIdx++                
		else
			printClear()                    
		endif
	Next nItem
	

		cSendDados += (replicate(chr(196),48)+chr(10))
		// salto de 6 linhas
    	cSendDados += (chr(10))
		cSendDados += (chr(10))
		cSendDados += (chr(10))
		// picote
		cSendDados += (chr(27))

Return

static function printQR(cText)
	local aChars := {}
	local nIdx   := ""
	local cBuffer:= ""
	
	// alinhamento centro
	aadd(aChars, chr(27))
	aadd(aChars, chr(97))
	aadd(aChars, chr(1))
	// fim alinhamento
	
	// inicio QRCODE
	aadd(aChars, chr(29))
	aadd(aChars, chr(107))
	aadd(aChars, chr(81))
	aadd(aChars, chr(2))
	aadd(aChars, chr(8))
	aadd(aChars, chr(4))
	aadd(aChars, chr(1))
	aadd(aChars, chr(len(cText)))
	//aadd(aChars, chr(36)) //tamanho
	aadd(aChars, chr(0))
	for nIdx := 1 to len(cText)
		aadd(aChars, chr(asc(substr(cText,nIdx,1))))	
	next nIdx
	// fim QRCODE
	
	for nIdx := 1 to len(aChars)
		cBuffer += aChars[nIdx] 
	next nIdx
	
	//cBuffer += "TESTE DE IMPRESSAO DO QRCODE"
return cBuffer


//--------------------------------------------
//DAQUI PRA BAIXO FUNCOES DO PROTOCOLO
Static Function GetItPickC()

Local _aRet	:=	{}
Local _cAlias	:=	GetNextAlias()


BeginSql Alias _cAlias

	SELECT GRUPO, SUM(QTDPEND) QTDPEND FROM (
	SELECT 	SUBSTRING(C6_PRODUTO,1,4) GRUPO,
			C6_QTDVEN - (SELECT ISNULL(SUM(B.C9_QTDLIB),0) 
							FROM SC9010 B 
							WHERE B.C9_FILIAL = A.C6_FILIAL 
									and B.C9_PEDIDO = A.C6_NUM 
									AND B.C9_ITEM = A.C6_ITEM 
									AND B.C9_BLEST = '10'  
									and B.%NotDel% ) As QTDPEND
	from SC6010 A
	where A.C6_FILIAL = %Exp:SC5->C5_FILIAL%    
	and A.C6_NUM = %Exp:SC5->C5_NUM%
	AND A.C6_BLQ <> 'R'
	and A.%NotDel%
	) A
	WHERE A.QTDPEND > 0
	GROUP BY GRUPO

EndSql

If (_cAlias)->(!EOF())
	While (_cAlias)->(!EOF()) 
		aAdd(_aRet,{(_cAlias)->GRUPO,POSICIONE("SBM", 1, xFilial("SBM") + (_cAlias)->GRUPO, "BM_DESC"),(_cAlias)->QTDPEND})
		(_cAlias)->(DbSkip())
	EndDo
EndIf

(_cAlias)->(DbCloseArea())	

Return _aRet




//Comandos Impressora

/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
 	Static Function para impress„o de cabeÁalho de picking

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   


static function printHeadC(cHora)
    local lFound  := posicione("sa1",1,xfilial("sa1")+sc5->(c5_cliente+c5_lojacli),"found()")
    local cNome   := Alltrim(SC5->C5_CLIENTE) +'-'+ alltrim(upper(sa1->a1_nome))   
    local cRota   := TAMSX3("DA8_DESC")[1] 
	local cObs	  :=	PADR("Obs: " + SC5->C5_YOBS,144)
    Local aObs	  :=	{Substr(cObs,1,48),Substr(cObs,49,96),Substr(cObs,97,144)}
    Local cFilName	:= ""
	Local _ni	                          
    Local _aEnd	:=	{}
	LOCAL cMunEnt := ''
	LOCAL cTipo := ''
	LOCAL cSend := printQR(SC5->(C5_FILIAL+C5_NUM))

		//IMPRIME O QRCODE
    	cSendDados += ( cSend )
	
	IF SC5->C5_YTIPO == 'T'
		cTipo := 'PEDIDO DE TROCA'
	ENDIF
	IF SC5->C5_YTIPO == 'C'
		cTipo := 'PEDIDO DE REMESSA'
	ENDIF
	IF SC5->C5_YTIPO == 'A'
		cTipo := 'PEDIDO DE VENDA AVULSA'
	ENDIF
	
	//PREENCHE A ROTA
	cRota := SA1->A1_YROTA
	
	cRota := ALLTRIM(POSICIONE("DA8",1,xFilial("DA8")+cRota,"DA8_COD"))
	
	cRota := SA1->(iif(empty(cRota),"SEM ROTA", cRota)) 
	
	IF cRota <> "SEM ROTA"
	
		cRota := POSICIONE("DA8",1,xFilial("DA8")+cRota,"DA8_DESC")
		
	ENDIF
	
    
    //|Pontin - Busca informacoes da empresa e filial |
    cFilName	:= FWFilName( cEmpAnt, cFilAnt )
    
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H
    cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1                   
    cSendDados += (chr(27)+chr(69)) // ESC E
	cSendDados += (padc("PROTOCOLO DE ENTREGA",24)+chr(10))    
	cSendDados += (	padr("Rota"+PADL(SC5->C5_YOPCARM+" - "+cRota,20,"."),24)+chr(10))
    cSendDados += (padc(cTipo,24)+chr(10))
	cSendDados += (padc(SUBSTRING(cNome,1,24),24)+chr(10))
	cSendDados += (padr(SUBSTRING(cNome,25,24),24)+chr(10))
	
	cSendDados += (chr(27)+chr(64)) // ESC @
	cSendDados += (chr(27)+chr(72)) // ESC H 
	
	IF ALLTRIM(SA1->A1_ENDENT) <> ''
		cSendDados += (padr(Alltrim(SA1->A1_ENDENT),48)+chr(10))
		cSendDados += (padr("Complemento: "+Alltrim(SA1->A1_COMPLEM),48)+chr(10))
		cSendDados += (padr("Bairro.....: "+Alltrim(SA1->A1_BAIRROE),48)+chr(10))
		cSendDados += (padr("CEP........: "+Alltrim(SA1->A1_CEPE),48)+chr(10))
		cMunEnt := POSICIONE("CC2",1,xFilial("CC2")+SA1->(A1_ESTE+A1_CODMUNE),"CC2_MUN")
		cSendDados += (padr("Municipio..: "+Alltrim(cMunEnt),48)+chr(10))
	ELSE
		cSendDados += (padr(Alltrim(SA1->A1_END),48)+chr(10))
		cSendDados += (padr("Complemento: "+Alltrim(SA1->A1_COMPLEM),48)+chr(10))
		cSendDados += (padr("Bairro.....: "+Alltrim(SA1->A1_BAIRRO),48)+chr(10))
		cSendDados += (padr("CEP........: "+Alltrim(SA1->A1_CEP),48)+chr(10))
		cSendDados += (padr("Municipio..: "+Alltrim(SA1->A1_MUN),48)+chr(10))
	ENDIF
	
	cSendDados += (padr("TEL........: ("+Alltrim(SA1->A1_DDD)+")"+Alltrim(SA1->A1_TEL),48)+chr(10))
    For _nI	:=	1 to Len(aObs)                       
   	    cSendDados += (padr(aObs[_nI],48)+chr(10))
    Next

    cSendDados += (padr("Pedido:"+SC5->C5_FILIAL+"-"+SC5->C5_NUM+" / Data/Hora:"+dtoc(SC5->C5_EMISSAO)+"-"+SC5->C5_YHEMISS+"H",48)+chr(10))
	//cSendDados += (padr("User:"+ALLTRIM(SC5->C5_YNOMVEN)+" - Impres:"+dtoc(Date())+"-"+cHora+"H",48)+chr(10))
	
	IF SC5->C5_YPORTAL <> 0
		cSendDados += (padr("PORTAL:"+cValtoChar(SC5->C5_YPORTAL)+"-User:"+ALLTRIM(SC5->C5_YNOMVEN)+"-Imp:"+dtoc(Date())+"-"+cHora+"H",48)+chr(10))
	ELSE
		cSendDados += (padr("User:"+ALLTRIM(SC5->C5_YNOMVEN)+" - Impres:"+dtoc(Date())+"-"+cHora+"H",48)+chr(10))      
	ENDIF
	
	// salto de linha
    cSendDados += (chr(10))
    	
	
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H
    cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1                   
    cSendDados += (chr(27)+chr(69)) // ESC E
    cSendDados += (replicate(chr(196),24)+chr(10))
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H
return
                                                                              


static function printFootC(nItens, nTotal)
    local cItens := cvaltochar(nItens)
    local cTotal := cvaltochar(nTotal)
    
    sleep(800)
	

     
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H

    cSendDados += (chr(27)+chr(87)+chr(49)) // ESC W 1                   
    cSendDados += (chr(27)+chr(69)) // ESC E
    cSendDados += (padr("ITENS NO PEDIDO:",19)+padl(nTotal,5)+chr(10))
	// salto de 2 linhas
    cSendDados += (chr(10))
	cSendDados += (padr("",48)+chr(10))
	cSendDados += (padr("Recebi os Produtos Acima Citados em __/__/____",48)+chr(10))
	cSendDados += (padr("",48)+chr(10))
	cSendDados += (padr("------------------------",48)+chr(10))
	cSendDados += (padr("------Nome Legivel------",48)+chr(10))
    cSendDados += (chr(27)+chr(64)) // ESC @
    cSendDados += (chr(27)+chr(72)) // ESC H

    // salto de 2 linhas
    cSendDados += (chr(10))
    // picote
    cSendDados += (chr(27))


	cSendDados += (chr(119))	
	    
    
    cSendDados += (chr(27)+chr(64)) // ESC @
return


/*/
€Source Detail€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
 

 @Owner     : Central Oft·lmica
 @CopyRight : Facile Sistemas (c) 2015
 @Author    : Gabriel Rossi Mafioletti
 @Version   : P11 - Protheus 11
 @Date      : 11/03/2015
 @Engine    : AdvPl
 @Module    : FAT-SIGAFAT

ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
                            
 @Descriptions
 
FunÁ„o para Imprimir os Itens do Picking

 Descriptions@                                                                  
  
€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Source Detail€       
/*/                                                                                   



static function printItemC(aItem)     
    local cProduto	:= aItem[IT_DESCRIC] 
    local nQtdVen 	:= aItem[IT_QTDPENDC]
    local cQtdVen 	:= cValToChar(nQtdVen)
    local cCodPro	:= aItem[IT_CODPROC]
    
    cSendDados += (+ALLTRIM(cProduto)+" x "+padl(cQtdVen,3)+chr(10))
    cSendDados += (replicate(chr(196),48)+chr(10))
	
	nTotal += nQtdVen
return