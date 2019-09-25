#Include "Totvs.ch"
#Include "TopConn.ch"

User Function FIB0934(cLanPad,cSeq)

Local cConta := ""
cTipo    := Posicione("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"E2_CONTA")
cTipo    := Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE,"A2_CONTA")


IF( SA2->A2_TIPO=="X" .AND. SUBSTRING(SA2->A2_CONTA,1,6)="210101" ,"2101010002", 
		IIF(SUBSTRING(SA2->A2_CONTA,1,6)<>"210101",SA2->A2_CONTA,  "2101010001") ) 
		
		USER FUNCTION RETTABLE(_cCTA)
	_cCTA := LEFT(_cCTA,10)
	
	DO CASE
		CASE SED->ED_NATUREZ=='IRF'
			IF _cCTA == '2101030003'
			ENDIF
				 
		CASE SED->ED_NATUREZ=='ICMS'
			IF _cCTA == '2101030001'
			ENDIF 
		
		CASE SED->ED_NATUREZ=='IPI'
			IF _cCTA == '2101030002'
			ENDIF
	
		CASE SED->ED_NATUREZ=='ICMS DIFAL'
			IF _cCTA == '2101030019'
			ENDIF			
		
		CASE SED->ED_NATUREZ=='PIS'
			IF _cCTA == '2101030018'
			ENDIF
		         
		CASE SED->ED_NATUREZ=='COFINS'
			IF _cCTA == '2101030018'
			ENDIF
		
		CASE SED->ED_NATUREZ=='CSLL'
			IF _cCTA == '2101030018'
			ENDIF
					
	ENDCASE
RETURN(_cTable)


//Contabilizacao Baixa Impostos Retidos ( IRRF, ICMS, DIFAL, IPI, PIS/COFINS/CSLL )
If cLanPad = "530" .And. cSeq $ "001" //AND cFilAnt ="01"     

DO CASE
    CASE   SED->E2_NATUREZ ="IRF"
                 cConta := "2101030003"
                 
                CASE SED->E2_NATUREZ ="ICMS" 
                 cConta := "2101030001"
                 
                CASE SED->E2_NATUREZ ="IPI" 
                 cConta := "2101030002"
                 
                CASE SED->E2_NATUREZ ="ICMS DIFAL" 
                 cConta := "2101030001" 
                                       
                CASE SED->E2_NATUREZ ="PIS" 
                 cConta := "2101030018"
                                       
    			CASE SED->E2_NATUREZ ="COFINS" 
                 cConta := "2101030018"      
                 
                 CASE SED->E2_NATUREZ ="CSLL" 
                 cConta := "2101030018"
                
                
                OTHERWISE
                cConta := "yYYYYYYYYYYYYYY"
ENDCASE    

cConta := "CVSC"


cConta :=    ( IIF((SUBSTR(SED->ED_NATUREZ,1,3) $ "IRF", "2101030003", "") )) .OR.
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "ICMS" ="2101030001")) .OR. 
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "IPI" ="2101030002")) .OR.
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "ICMS DIFAL" ="2101030019")) .OR.
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "PIS" ="2101030018")) .OR.
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "COFINS" ="2101030018")) .OR.
                                 ((SUBSTR(SED->ED_NATUREZ,1,3) $ "CSLL" ="2101030018"))  
    
IF(SA2->A2_TIPO=="X" .AND. SED->ED_NATUREZ $ "IRF"   = "2101030003" 
					   .OR. SED->ED_NATUREZ $ "ICMS" = "2101030001" 
					   .OR. SED->ED_NATUREZ $ "IPI" = "2101030002" 
                       .OR. SED->ED_NAUREZ $ "ICMS DIFAL" = "2101030019" 
                       .OR. SED->ED_NATUREZ $ "PIS" = "2101030018" 
                       .OR. SED->ED_NATUREZ $ 'COFINS" = "2101030018" 
                       .OR. SED->ED_NATUREZ $ 'CSLL" = "2101030018"  

                                                                                        

EndIf
                

Return {cConta}