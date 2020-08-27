#INCLUDE "TOTVS.CH"

/*
Data: 13-09-17
Autor: Pedro Palaoro
Desc: Faz a Impressão dos pedidos do site e pendentes
*/

USER FUNCTION FCOFRE11()

  RPCSetType(3)
  
  RPCSetEnv('01', '01', , , "SC5", , {})  
  
  CONOUT("FCOFRE11::Starting: "+cEmpAnt+"/"+cFilAnt+" - " + TIME())
  
	//ABRE UM SEMAFORO PARA NAO DEIXAR CHAMAR A ROTINA MAIS DE UMA VEZ
	If !LockByName("U_FCOFRE11",.F.,.F.,.T.)
		conout("A ROTINA FCOFRE11(IMPRESSAO PICKING PORTAL) AINDA ESTA RODANDO!")
		Return
	EndIf
  
  ImpPickA()
	
  RPCClearEnv()
  
	//LIBERA O SEMAFORO PARA QUE SEJA USADO NOVAMENTE A ROTINA
	UnLockByName("U_FCOFRE11",.F.,.F.,.T.)
  
  CONOUT("FCOFRE11::Finish: " + TIME())      
	
Return(Nil)

Static Function ImpPickA

LOCAL cAliasP := GETNEXTALIAS()
LOCAL cAliasA := GETNEXTALIAS()
LOCAL aAreaSC5 := GETAREA("SC5")


/*------------------------------------------------------------------------------
	IMPRIME OS PEDIDOS COM ESTOQUE TOTAL - CASO NAO TENHA ESTOQUE COLOCA COMO PENDENTE
-------------------------------------------------------------------------------*/	
	BEGINSQL ALIAS cAliasP
		SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO, C5_EMISSAO, C5_YHEMISS FROM SC5010 SC5 (NOLOCK)
		WHERE C5_YPICK = 'N' AND C5_YSTATUS <> '6'  AND C5_NOTA = '' AND D_E_L_E_T_ = ''
		//AND C5_EMISSAO = CONVERT(VARCHAR, GETDATE(), 112)
		AND C5_YOPCARM <> ''
		GROUP BY C5_FILIAL,C5_NUM,C5_EMISSAO,C5_YHEMISS
		ORDER BY C5_YHEMISS
	ENDSQL
	
	DbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	
	//PASSA NO ALIAS E POSICIONA NO PEDIDO NA SC5 PARA QUE O FONTE DE IMPRESSAO FUNCIONE
	While (cAliasP)->(!Eof())
		
		//VAI AO TOPO DA TABELA
		SC5->(dbGoTop())
		
		//FAZ A BUSCA DO PEDIDO NA SC5
		IF SC5->(DBSEEK(ALLTRIM((cAliasP)->(FILIAL+PEDIDO))))
		
			//AQUI VERIFICA SE O PEDIDO EM QUESTAO JA FOI MARCADO PELO PORTAL COMO SEM ESTOQUE
			//CASO POSITIVO, MARCA O MESMO COMO PENDENTE E NAO TENTA IMPRIMIR
			BEGINSQL ALIAS cAliasA
		
				SELECT ESTOQUE FROM PORTAL.DBO.ITEMPEDIDO IT
				INNER JOIN PORTAL.DBO.PEDIDO PED ON PED.IDPEDIDO = IT.IDPEDIDO
				WHERE PED.C5_FILIAL = %EXP:(cAliasP)->FILIAL% AND PED.C5_NUM = %EXP:(cAliasP)->PEDIDO%
				AND ESTOQUE = 'N'
			
			ENDSQL
			
			IF (cAliasA)->(!Eof())
			
				//SE NAO TEM ESTOQUE MARCA COMO PENDENTE CASO NAO JA ESTEJA
				IF SC5->C5_YSTATUS <> 6
				
					RecLock("SC5", .F.)
					SC5->C5_YSTATUS = 6
					SC5->(MsUnlock())
				
				ENDIF
				
			ELSE
		
			
				//FAZ O TESTE PARA VERIFICAR SE O PEDIDO CONTINUA COM ESTOQUE EM TODOS OS ITENS
				cAlias := GETNEXTALIAS()
		
				BEGINSQL ALIAS cAlias
				%NOPARSER%
				
					EXEC COF_PED_EST_TOTAL %EXP:(cAliasP)->(FILIAL+PEDIDO)%
					
				ENDSQL
				
					//PROCURA O PEDIDO JA FEITO SE O MESMO TIVER ESTOQUE
					IF !EMPTY((cAlias)->PEDIDO)
				
						//SE TEM ESTOQUE FAZ A IMPRESSAO
						IF (cAlias)->(!Eof())
					
							U_FCOFRE01(.T.)
						
						ENDIF
					
					
					ELSE	
						//SE NAO TEM ESTOQUE MARCA COMO PENDENTE CASO NAO JA ESTEJA
						IF SC5->C5_YSTATUS <> 6
						
							RecLock("SC5", .F.)
							SC5->C5_YSTATUS = 6
							SC5->(MsUnlock())
						
						ENDIF
						
					ENDIF
					
				(cAlias)->(DbCloseArea())
					
			ENDIF
			
			//FECHA E ABRE O ALIAS PARA NOVA CONSULTA
			(cAliasA)->(DbCloseArea())
			cAliasA := GETNEXTALIAS()
			
		ENDIF
		
		(cAliasP)->(DBSKIP())
		
	ENDDO
	
/*------------------------------------------------------------------------------
	FAZ A IMPRESSAO DOS PEDIDOS QUE TEM ESTOQUE QUE ESTAO PENDENTES
-------------------------------------------------------------------------------*/
	
	//ZERA O ALIAS PARA PODER PEGAR A NOVA QUERY
	(cAliasP)->(DbCloseArea())
	
	//Tabela PedPend eh criada por uma SP que eh chamada por Job no SQL
	BEGINSQL ALIAS cAliasP
		SELECT C5_FILIAL FILIAL, C5_NUM PEDIDO, C5_EMISSAO, C5_YHEMISS FROM PedPend 
		INNER JOIN SC5010 SC5 (NOLOCK) ON SUBSTRING(FILIAL,1,4) = C5_FILIAL AND PEDIDO = C5_NUM AND SC5.D_E_L_E_T_ = '' 
		WHERE C5_YPICK = 'N' AND SC5.C5_NOTA = '' AND D_E_L_E_T_ = ''
		AND ARMAZEM <> ''
		GROUP BY C5_FILIAL,C5_NUM,C5_EMISSAO,C5_YHEMISS
		ORDER BY C5_EMISSAO,C5_YHEMISS
	ENDSQL
	
	//PASSA NO ALIAS E POSICIONA NO PEDIDO NA SC5 PARA QUE O FONTE DE IMPRESSAO FUNCIONE
	While (cAliasP)->(!Eof())
	
		//VAI AO TOPO DA TABELA
		SC5->(dbGoTop())
		
		//FAZ A BUSCA DO PEDIDO NA SC5
		IF SC5->(DBSEEK(ALLTRIM((cAliasP)->(FILIAL+PEDIDO))))
		
			//FAZ O TESTE PARA VERIFICAR SE O PEDIDO CONTINUA COM ESTOQUE EM TODOS OS ITENS
			cAlias := GETNEXTALIAS()
	
			BEGINSQL ALIAS cAlias
			%NOPARSER%
			
				EXEC COF_PED_EST_TOTAL %EXP:(cAliasP)->(FILIAL+PEDIDO)%
				
			ENDSQL
			
				//PROCURA O PEDIDO JA FEITO SE O MESMO TIVER ESTOQUE
				IF !EMPTY((cAlias)->PEDIDO)
			
					//SE TEM ESTOQUE FAZ A IMPRESSAO
					IF (cAlias)->(!Eof())
				
						U_FCOFRE01(.T.)
					
					ENDIF
				
				
				ELSE	
					//SE NAO TEM ESTOQUE MARCA COMO PENDENTE CASO NAO JA ESTEJA
					IF SC5->C5_YSTATUS <> 6
					
						RecLock("SC5", .F.)
						SC5->C5_YSTATUS = 6
						SC5->(MsUnlock())
					
					ENDIF
					
				ENDIF
			
		ENDIF
		
		(cAlias)->(DbCloseArea())
		
		(cAliasP)->(DBSKIP())
		
	ENDDO

	//FECHA A TABELA E DEVOLVE A AREA
	SC5->(DbCloseArea())
	RestArea(aAreaSC5)

RETURN
