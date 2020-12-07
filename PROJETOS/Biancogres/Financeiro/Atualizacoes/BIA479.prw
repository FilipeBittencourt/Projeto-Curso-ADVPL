#include "TOTVS.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"

User Function BIA479()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Wanisay
Programa  := BIA479
Empresa   := Biancogres Cerâmica S/A
Data      := 30/01/13
Uso       := Faturamento
Aplicação := Apuração das Comissões Variáveis
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private nFlag

Processa({|| fPRINCIPAL()})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fPRINCIPAL ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦  Cria arquivos de trabalho e processa dados                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPRINCIPAL()

local _ni

cHInicio := Time()
fPerg := "BIA479"
If !Pergunte(fPerg,.T.)
	Return
EndIf

MsAguarde({|| Comissao()},"Realizando o cálculo da Comissão Variável","Atualizando")

RETURN

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fPRINCIPAL ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Comissao()
Private nEmp := ""
Private cLogo := ""

If cEmpAnt == '05'
	cLogo := "LOGOPRI05.BMP"	
EndIf

fCabec   := "Comissão Variável"
fCabec2  := " "
wnPag    := 0
nRow1    := 3000
Enter1   := CHR(13)+CHR(10)

//TABELA TEMPORARIA 
nNomeTMP := "##BIA479TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

//Define limpeza da Comissão variavel na tabela SD2 e SD1 
lFlag	 := .T. 
      
If cEmpAnt <> "05" .AND. cEmpAnt <> "07"
   MsgBox("Este relatório deve ser emitido apenas na empresa Incesa","STOP")
   Return
EndIf   

If cEmpAnt == "01"

ElseIf cEmpAnt == "05"
	Do Case
		Case MV_PAR05 == 1 	//INCESA
			nEmp	:= "0501"
			nSeq  	:= "02'
		Case MV_PAR05 == 2 	//BELLACASA
			nEmp	:= "0599"
			nSeq  	:= "03'
		Case MV_PAR05 == 3 	//MUNDIALLI
			nEmp	:= "1399"
			nSeq  	:= "04'
	EndCase           
ElseIf cEmpAnt == "07"
	Do Case
		Case MV_PAR05 == 1 	//BIANCOGRES
			nEmp	:= "0101"
			nSeq  	:= "01'
		Case MV_PAR05 == 2 	//INCESA
			nEmp	:= "0501"
			nSeq  	:= "02'
		Case MV_PAR05 == 3 	//BELLACASA
			nEmp	:= "0599"
			nSeq  	:= "03'
		Case MV_PAR05 == 4 	//MUNDIALLI
			nEmp	:= "1399"
			nSeq  	:= "04'
	EndCase           			
ElseIf cEmpAnt == "13"
EndIf

nEmp     := U_MontaSQLIN(nEmp,'/',4)

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)
oPrint:Setup()

IF cEmpAnt == "07" .AND. nEmp == "1399"
   nEmp == "0501"
ENDIF

cPar07 := fFormatPar(MV_PAR07)

//Executa Stored Procedure                                                         
A00 := "EXEC SP_BIA479 '"+nNomeTMP+"',"+nEmp+",'"+MV_PAR03+"','"+MV_PAR04+"','"+DTOS(MV_PAR01)+"','"+DTOS(MV_PAR02)+"','"+cPar07+"' "

U_BIAMsgRun("Aguarde... Gerando Base do Relatório...",,{|| TcSQLExec(A00)})

IF cEmpAnt == "07" .AND. nEmp == "0501"
   nEmp == "1399"
ENDIF

//(Thiago Dantas - 03/03/15)
// Verifica os totais da Empresa de Faturamento e Devolucao
nTotFatEmp := 0.0
nTotDevEmp := 0.0
nTotMeta   := 0.0		
lMetaAting := .F.

If AllTrim(nEmp) == "'1399'"
	
	//Meta 
	cSql := cTotalMeta()

	If chkfile("MET")
		DbSelectArea("MET")
		DbCloseArea()
	EndIf
	TcQuery cSql New Alias "MET"
	
	nTotMeta := MET->TOTAL
	MET->(DbCloseArea())
    
	//Faturado
	cSql := cTotalFat()
	
	If chkfile("FAT")
		DbSelectArea("FAT")
		DbCloseArea()
	EndIf
	TcQuery cSql New Alias "FAT"
	
	nTotFatEmp := FAT->TOTAL
	FAT->(DbCloseArea())
	
	//Devolvido
	cSql := cTotalDev() 
	
	If chkfile("DEV")
		DbSelectArea("DEV")
		DbCloseArea()
	EndIf                                                                                                                                                 
	TcQuery cSql New Alias "DEV"
	
	nTotDevEmp := DEV->TOTAL
	DEV->(DbCloseArea())
	
	//Verifica se Atingiu a Meta da Empresa
	lMetaAting := ((nTotFatEmp + nTotDevEmp) >= nTotMeta .And. nTotMeta > 0.0)
	
EndIf 

	
	// Tiago Rossini Coradini - 26/05/2017 - OS: 4308-16
		
	A00 := " SELECT MES, A3_COD AS CT_VEND, A3_NOME, A3_NREDUZ, A3_EST, SUM(VLR_META)META , SUM(QTD_META) CT_QUANT, SUM(VLR_REAL) D2_TOTAL, SUM(QTD_REAL) D2_QUANT "
	A00 += " FROM "+ nNomeTMP 
	A00 += " INNER JOIN "+ RetSQLName("SA3")
	A00 += " ON A3_COD = VEND1 "
	A00 += " WHERE A3_FILIAL = "+ ValToSQL(xFilial("SA3")) 
	A00 += " AND A3_COD IN "
	A00 += " ( "
	A00 += " 		SELECT Z92_CODVEN " 
	A00 += " 		FROM "+ RetSQLName("Z92")
	A00 += " 		WHERE Z92_FILIAL = "+ ValToSQL(xFilial("Z92"))	
	A00 += " 		AND Z92_CODEMP = "+ ValToSQL(If (cEmpAnt == "05", "1", "2"))			
	A00 += "		AND Z92_CODMAR = "+ ValToSQL(fGetMarca(.F.))
	A00 += "		AND Z92_CODPAC IN (SELECT ITEMS FROM FN_SPLIT_STRING("+ ValToSQL(cPar07) +", ','))
	A00 += "		AND D_E_L_E_T_ = '' "
	A00 += "		GROUP BY Z92_CODVEN "
	A00 += " ) "
	A00 += " AND A3_YATIVO = 'S' "
	A00 += " AND A3_MSBLQL <> '1' "
	A00 += " AND D_E_L_E_T_ = '' "
	A00 += " GROUP BY A3_COD, MES, A3_NOME, A3_NREDUZ, A3_EST "
	A00 += " ORDER BY D2_TOTAL DESC "
	
If chkfile("A00")
	DbSelectArea("A00")
	DbCloseArea()
EndIf
TcQuery A00 New Alias "A00"

fImpCabec()

DbSelectArea("A00")
DbGoTop()
ProcRegua(RecCount())

cVendAnt := A00->CT_VEND

nTotMet := 0
nTotVol := 0
nTotRec := 0
nTotCom := 0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	IF A00->D2_TOTAL > 0
		nComVol := 0.00
		/*
		DO CASE
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) < 90.00
				nComVol := 0.35
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 90.00  .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 95.00
				nComVol := 0.42
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 95.00  .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 100.00
				nComVol := 0.56
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 100.00 .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 110.00
				nComVol := 0.70
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 110.00 .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 120.00
				nComVol := 0.77
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 120.00 .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 130.00
				nComVol := 0.84
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 130.00 .AND. (A00->D2_QUANT/A00->CT_QUANT*100) < 140.00
				nComVol := 0.91
			CASE (A00->D2_QUANT/A00->CT_QUANT*100) >= 140.00
				nComVol := 0.98
			OTHERWISE
				nComVol := 0.00
		ENDCASE
		*/
		nComPrc := 0.00
		/*
		DO CASE
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 100.00
				nComPrc := 0.27
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 100.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 102.00
				nComPrc := 0.30
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 102.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 104.00
				nComPrc := 0.33
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 104.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 106.00
				nComPrc := 0.36
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 106.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 108.00
				nComPrc := 0.42
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 108.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 110.00
				nComPrc := 0.48
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 110.00  .AND. (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 < 112.00
				nComPrc := 0.60
			CASE (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 112.00
				nComPrc := 0.90
			OTHERWISE
				nComPrc := 0.00
		ENDCASE              
		*/             
		nComRec := 0.00		
        
        If nEmp == "'1399'"
			If (ALLTRIM(A00->CT_VEND) $ '000411/000422/000414/000415/000420/000421/000423/000430/000435/000437' .AND. SUBSTR(DTOS(MV_PAR02),1,6) >= '201309') .OR. SUBSTR(DTOS(MV_PAR02),1,6) >= '201401'
    	       
    	       If (A00->D2_TOTAL)/(A00->META)*100 >= 100.00 .And. A00->META > 0.0
				   nComRec := 1.00
			   EndIf
			   
			   // Se atingiu a meta na Mundialli, + 1.0
			   If lMetaAting
			       nComRec++
			   EndIf
			   
			EndIf
		
	     Else

			//Alterado por Wanisay conforme OS 0196-14		
			If (ALLTRIM(A00->CT_VEND) $ '000411/000422/000414/000415/000420/000421/000423/000430/000435/000437' .AND. SUBSTR(DTOS(MV_PAR02),1,6) >= '201309') .OR. SUBSTR(DTOS(MV_PAR02),1,6) >= '201401'
	 			If (A00->D2_QUANT/A00->CT_QUANT*100) >= 100.00
	 		 		nComVol := 0.50
	 		   Else
	 		      	nComVol := 0
	 		   EndIf
			EndIf
	
			If (ALLTRIM(A00->CT_VEND) $ '000411/000422/000414/000415/000420/000421/000423/000430/000435/000437' .AND. SUBSTR(DTOS(MV_PAR02),1,6) >= '201309') .OR. SUBSTR(DTOS(MV_PAR02),1,6) >= '201401'
	           If (A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100 >= 100.00
					nComPrc := 0.50
			   Else
			       	nComPrc := 0
			   EndIf
			EndIf
        EndIf
		
		If nEmp == "'1399'" 
			xf_Item := ""
			xf_Item += Padc(A00->CT_VEND + SPACE(06 - LEN(A00->CT_VEND))                                            		      ,06, " ") + "|"
			xf_Item += Padr(AllTrim(SUBSTR(A00->A3_NOME,1,20)) + SPACE(20 - LEN(AllTrim(SUBSTR(A00->A3_NOME,1,20))))              ,20, " ") + "|"
			xf_Item += Padr(AllTrim(SUBSTR(A00->A3_NREDUZ,1,17)) + SPACE(17 - LEN(AllTrim(SUBSTR(A00->A3_NREDUZ,1,17))))          ,17, " ") + "|"
			xf_Item += Padc(AllTrim(A00->A3_EST)	                                                            			      ,02, " ") + "|"
			xf_Item += Padc(Transform(A00->META,"@E 999,999,999.99")                                                              ,14, " ")
			xf_Item += Padc(Transform(A00->D2_TOTAL,"@E 999,999,999.99")                      	      	                          ,14, " ")
			xf_Item += Padc(Transform((A00->D2_TOTAL)/(A00->META)*100,"@E 999,999,999.99")                                        ,14, " ")
			xf_Item += Padc(Transform(Iif((A00->D2_TOTAL)/(A00->META)*100>100, 1.00, 0.00),  "@E 999,999,999.99")                 ,14, " ")
			xf_Item += Padc(Transform(Iif(lMetaAting, 1.00, 0.00),"@E 999,999,999.99")                                            ,14, " ")
			xf_Item += Padc(Transform(nComRec,"@E 999,999,999.99")                       						                  ,14, " ")
			xf_Item += Padc(Transform(Iif(nComRec > 0.00, A00->D2_TOTAL * nComRec/100, 0.00),  "@E 999,999,999.99")               ,14, " ")
			
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
			nRow1 += 025
	
			//Padl(Transform(nComRec,  "@E 99,999.99")                              							    ,09, " ")+" "+;		
			
			nTotMet := nTotMet + ROUND(A00->META,2)
			nTotRec := nTotRec + ROUND(A00->D2_TOTAL,2)
			nTotVol := 0.00
			nTotCom := nTotCom + ROUND(Iif(nComRec > 0.00, A00->D2_TOTAL * nComRec/100, 0.00),2)
		Else		
			xf_Item := ""
			xf_Item += Padc(A00->CT_VEND          	                                                              			,06, " ")+" "
			xf_Item += Padr(AllTrim(SUBSTR(A00->A3_NOME,1,20))                                                    			,20, " ")+" "
			xf_Item += Padr(AllTrim(SUBSTR(A00->A3_NREDUZ,1,17))                                          				    ,17, " ")+" "
			xf_Item += Padc(AllTrim(A00->A3_EST)	                                                            			,02, " ")+" "
			xf_Item += Padc(Transform(A00->META/A00->CT_QUANT,"@E 99,999.99")                                        		,14, " ")
			xf_Item += Padc(Transform(A00->D2_TOTAL/A00->D2_QUANT,"@E 99,999.99")                      	      	        	,14, " ")
			xf_Item += Padc(Transform((A00->D2_TOTAL/A00->D2_QUANT)/(A00->META/A00->CT_QUANT)*100,"@E 99,999.99")           ,14, " ")
			xf_Item += Padc(Transform(nComPrc,  "@E 99,999.99")                							                	,14, " ")
			xf_Item += Padc(Transform(A00->CT_QUANT,"@E 999,999,999.99")                                        			,14, " ")
			xf_Item += Padc(Transform(A00->D2_QUANT,"@E 999,999,999.99")                       					        	,14, " ")
			xf_Item += Padc(Transform(A00->D2_QUANT/A00->CT_QUANT*100,  "@E 99,999.99")                                     ,14, " ")
			xf_Item += Padc(Transform(nComVol,  "@E 99,999.99")                              							    ,14, " ")
			xf_Item += Padc(Transform(nComRec,  "@E 999,999,999.99")                                           				,14, " ")
			xf_Item += Padc(Transform(nComPrc+nComVol+nComRec,  "@E 99,999.99")                                    			,14, " ")
			xf_Item += Padc(Transform(A00->D2_TOTAL,  "@E 999,999,999.99")                                           		,14, " ")
			xf_Item += Padc(Transform((nComPrc+nComVol+nComRec)/100*A00->D2_TOTAL,  "@E 999,999,999.99")                    ,14, " ")
			
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
			nRow1 += 050
	
			//Padl(Transform(nComRec,  "@E 99,999.99")                              							    ,09, " ")+" "+;		
			
			nTotMet := nTotMet + A00->CT_QUANT
			nTotVol := nTotVol + A00->D2_QUANT
			nTotRec := nTotRec + A00->D2_TOTAL
			nTotCom := nTotCom + ((nComPrc+nComVol)/100*A00->D2_TOTAL)
		EndIf
		
		//Grava informações na tabela de Comissão (SE3)

		IF MV_PAR06 == 1
            
          	//Apaga registro no SE3 para nova gravação
			A01 := "  UPDATE "+RetSqlName("SE3")  "
			A01 += "  SET D_E_L_E_T_ = '*' "
			A01 += "  WHERE SUBSTRING(E3_DATA,1,6) = '"+SUBSTR(DTOS(MV_PAR02),1,6)+"' "
			A01 += "  AND E3_VEND   = '"+A00->CT_VEND+"' "
			A01 += "  AND E3_CODCLI = '999998' "
			A01 += "  AND E3_PROCCOM IN ( "+nEmp+" )  "
			A01 += "  AND E3_USERLGA = '' "
			A01 += "  AND D_E_L_E_T_ = '' "
			TCSQLExec(A01)
			
			DbSelectArea("SE3")
			DbSetOrder(3)
			IF DbSeek(xFilial("SE3")+A00->CT_VEND+'999998'+'01'+'9  '+SUBSTR(DTOS(MV_PAR02),3,2)+SUBSTR(DTOS(MV_PAR02),5,2)+SUBSTR(DTOS(MV_PAR02),7,2)+' '+'NF '+nSeq)
				//SE3->E3_BASE    := A00->D2_TOTAL
				//SE3->E3_PORC    := nComPrc+nComVol
				//SE3->E3_COMIS   := (nComPrc+nComVol)/100*A00->D2_TOTAL
			ELSE
				RecLock("SE3",.T.)
				SE3->E3_FILIAL  := xFilial("SE3")
				SE3->E3_VEND    := A00->CT_VEND
				SE3->E3_NUM     := SUBSTR(DTOS(MV_PAR02),3,2)+SUBSTR(DTOS(MV_PAR02),5,2)+SUBSTR(DTOS(MV_PAR02),7,2)
				SE3->E3_EMISSAO := MV_PAR02
				SE3->E3_SERIE   := '9'
				SE3->E3_CODCLI  := '999998'
				SE3->E3_LOJA    := '01'
				SE3->E3_BASE    := A00->D2_TOTAL
				SE3->E3_PORC    := nComPrc+nComVol+nComRec
				SE3->E3_COMIS   := (nComPrc+nComVol+nComRec)/100*A00->D2_TOTAL
				SE3->E3_PREFIXO := '9'
				SE3->E3_PARCELA := ' '
				SE3->E3_PEDIDO  := ' '
				SE3->E3_TIPO    := 'NF '
				SE3->E3_BAIEMI  := 'E'
				SE3->E3_PROCCOM := nEmp
				SE3->E3_SEQ     := nSeq
				SE3->E3_ORIGEM  := 'E'
				SE3->E3_VENCTO  := MV_PAR02+15
				MsUnLock()
			ENDIF
			

			//Limpando % Comissão Variavel ja gravado - Executa apenas uma unica vez
			If lFlag 	   
				If nEmp == "'0101'"
					A01 := "UPDATE SD2010 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(A01)})
				
					A01 := "UPDATE SD2070 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})		
	
					A01 := "UPDATE SD1010 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Biancogres...",,{|| TcSQLExec(A01)})

					A01 := "UPDATE SD1070 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})
     			ElseIf nEmp == "'0501'"
					A01 := "UPDATE SD2050 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '1' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(A01)})

					A01 := "UPDATE SD2070 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})
	
					A01 := "UPDATE SD1050 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '1' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(A01)})
		
					A01 := "UPDATE SD1070 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})
     			ElseIf nEmp == "'0599'"
					A01 := "UPDATE SD2050 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '2' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(A01)})

					A01 := "UPDATE SD2070 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '3' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})
	
					A01 := "UPDATE SD1050 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '2' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros Incesa...",,{|| TcSQLExec(A01)})
		
					A01 := "UPDATE SD1070 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '3' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})
				ElseIf nEmp == "'1399'"
					A01 := "UPDATE SD2070 SET D2_YCOMVAR = 0 WHERE D2_FILIAL = '01' AND D2_SERIE  = '4' AND D2_EMISSAO >= '"+DTOS(MV_PAR01)+"' AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"' AND D2_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})

					A01 := "UPDATE SD1070 SET D1_YCOMVAR = 0 WHERE D1_FILIAL = '01' AND D1_SERIORI  = '4' AND D1_DTDIGIT >= '"+DTOS(MV_PAR01)+"' AND D1_DTDIGIT <= '"+DTOS(MV_PAR02)+"' AND D1_YCOMVAR <> 0 AND D_E_L_E_T_ = ''  "
					U_BIAMsgRun("Limpando registros LM...",,{|| TcSQLExec(A01)})     			
     			EndIf
				
				lFlag := .F.
			EndIf

			//Atualiza % Comissao Variavel nos registros SD2 - Itens NF Saida
			A01 := " UPDATE SD2010 SET D2_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD2010 "
			A01 += " WHERE 	TABELA		= 'SD2' AND "
			A01 += "		EMP		 	= '01'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D2_EMISSAO	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "  
			U_BIAMsgRun("Atualizando registros Biancogres...",,{|| TcSQLExec(A01)})

			A01 := " UPDATE SD2050 SET D2_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD2050 "
			A01 += " WHERE 	TABELA		= 'SD2' AND "
			A01 += "		EMP		 	= '05'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D2_EMISSAO	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "
			U_BIAMsgRun("Atualizando registros Incesa...",,{|| TcSQLExec(A01)})
			
			A01 := " UPDATE SD2070 SET D2_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD2070 "
			A01 += " WHERE 	TABELA		= 'SD2' AND "
			A01 += "		EMP		 	= '07'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D2_EMISSAO	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "
			U_BIAMsgRun("Atualizando registros LM...",,{|| TcSQLExec(A01)})	

			//Atualiza % Comissao Variavel nos registros SD1 - Itens NF de Entrada (Devolução)
			A01 := " UPDATE SD1010 SET D1_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD1010 "
			A01 += " WHERE 	TABELA		= 'SD1' AND "
			A01 += "		EMP		 	= '01'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D1_DTDIGIT	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "  
			U_BIAMsgRun("Atualizando registros Biancogres...",,{|| TcSQLExec(A01)})

			A01 := " UPDATE SD1050 SET D1_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD1050 "
			A01 += " WHERE 	TABELA		= 'SD1' AND "
			A01 += "		EMP		 	= '05'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D1_DTDIGIT	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "
			U_BIAMsgRun("Atualizando registros Incesa...",,{|| TcSQLExec(A01)})
			
			A01 := " UPDATE SD1070 SET D1_YCOMVAR = '"+Alltrim(Str(nComPrc+nComVol+nComRec))+"' "
			A01 += " FROM "+nNomeTMP+", SD1070 "
			A01 += " WHERE 	TABELA		= 'SD1' AND "
			A01 += "		EMP		 	= '07'  AND "
			A01 += "	    VEND1      	= '"+A00->CT_VEND+"' AND "
			A01 += "	  	D1_DTDIGIT	>= '"+DTOS(MV_PAR01)+"' AND "
			A01 += "	  	R_E_C_N_O_ 	= RECNO "
			U_BIAMsgRun("Atualizando registros LM...",,{|| TcSQLExec(A01)})	

		ENDIF
	ENDIF
	
	DbSelectArea("A00")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

xf_Item := +;
Padc(""             	     	                                                             ,06)+"  "+;
Padc("Total Geral"   	     	                                                             ,35)+"  "+;
Padc(""             	     	                                                             ,04)+;
Padc(Transform(nTotMet,  "@E 999,999,999.99")                                                ,14)+;
Padc(Transform(nTotRec,  "@E 999,999,999.99")                                                ,14)+;
Padc(""             	     	                                                             ,56)+;
Padc(Transform(nTotCom,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
nRow1 += 050

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

// Rotina implementada por Marcos Alberto Soprani em 30/01/13 para atender ao projeto PROVISÃO DE COMISSÃO.
If MV_PAR06 == 1
	
	If MsgNOYES("Deseja efetuar a contabilização desta COMISSÃO VARIÁVEL?")
		
		// Foi necessário repetir esta regra porque da forma foi montado acima inviabiliza a leitura. Por Marcos Alberto Soprani em 31/01/13
		rrnEmp := ""
		If cEmpAnt == "01"
			Do Case
				Case MV_PAR05 == 1 	//BIANCOGRES
					rrnEmp	:= "0101"
				Case MV_PAR05 == 2 	//INCESA
					rrnEmp	:= "0501"
				Case MV_PAR05 == 3 	//BELLACASA
					rrnEmp  := "0599"
			EndCase
		ElseIf cEmpAnt == "05"
			Do Case
				Case MV_PAR05 == 1 	//INCESA
					rrnEmp	:= "0501"
				Case MV_PAR05 == 2 	//BELLACASA
					rrnEmp	:= "0599"
				Case MV_PAR05 == 3 	//MUNDIALLI
					rrnEmp	:= "1399"
			EndCase
		ElseIf cEmpAnt == "07"
			Do Case
				Case MV_PAR05 == 1 	//BIANCOGRES
					rrnEmp	:= "0101"
				Case MV_PAR05 == 2 	//INCESA
					rrnEmp	:= "0501"
				Case MV_PAR05 == 3 	//BELLACASA
					rrnEmp	:= "0599"
				Case MV_PAR05 == 4 	//MUNDIALLI
					rrnEmp	:= "1399"
			EndCase
		EndIf
				
		fgLanPad := "C01"
		fgLotCtb := "007777"
		fgVetCtb := {}
		fgPermDg := .T.
		
		AQ004 := " SELECT E3_NUM,
		AQ004 += "        E3_PREFIXO,
		AQ004 += "        E3_VEND,
		AQ004 += "        E3_COMIS,
		AQ004 += "        E3_YVLEMP1
		AQ004 += "   FROM " + RetSqlName("SE3")
		AQ004 += "  WHERE E3_FILIAL = '"+xFilial("SE3")+"'
		AQ004 += "    AND E3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		AQ004 += "    AND E3_CODCLI = '999998'
		AQ004 += "    AND E3_PREFIXO = '9'
		AQ004 += "    AND E3_PROCCOM LIKE '%"+rrnEmp+"%'
		AQ004 += "    AND E3_DATA = '        '
		AQ004 += "    AND D_E_L_E_T_ = ' '
		AQ004 += "  ORDER BY E3_NUM
		TCQUERY AQ004 New Alias "AQ04"
		dbSelectArea("AQ04")
		dbGoTop()
		While !Eof()
			
			// A definição da classe de valor deve estar sempre em conformidade com a rotina BCt5ClVl.
			// Qualquer alteralção feita aqui deverá refletir lá e vice-versa
			xcCLVL := ""
			If cEmpAnt == "01"
				xcCLVL := "2100"
				
			ElseIf cEmpAnt == "05"
				If MV_PAR05 == 1
					xcCLVL := "2200"
				ElseIf MV_PAR05 == 2
					xcCLVL := "2210"
				ElseIf MV_PAR05 == 3
					xcCLVL := "2250"
				EndIf
								
			ElseIf cEmpAnt == "07"
				
				/*If AQ04->E3_PREFIXO == "1  "
					xcCLVL := "2100"
				ElseIf AQ04->E3_PREFIXO == "2  "
					xcCLVL := "2200"
				ElseIf AQ04->E3_PREFIXO == "3  "
					xcCLVL := "2210"
				EndIf*/
				
				/*
				//(Thiago Dantas - 25/02/15) -> OS 0866-15
				If AllTrim(AQ04->E3_PREFIXO) == "1"
					xcCLVL := "2150"
				ElseIf AllTrim(AQ04->E3_PREFIXO) $ "2_4"
					xcCLVL := "2250"
				ElseIf AllTrim(AQ04->E3_PREFIXO) $ "3"
					xcCLVL := "2251"
				EndIf
				*/

				If MV_PAR05 == 1
					xcCLVL := "2150"
				Else
					xcCLVL := "2250"
				EndIf							

			EndIf
			If AQ04->E3_VEND == "200005"
				xcCLVL := "2113"
			EndIf
			
			// Vetor ==>> Debito, Credito, ClVl_D, ClVl_C, Item_Contab_D, Item_Contab_C, Valor, Histórico
			If AQ04->E3_COMIS > AQ04->E3_YVLEMP1
				Aadd(fgVetCtb, { "31403001", "21106003", xcCLVL, xcCLVL, "", "COM"+AQ04->E3_VEND, AQ04->E3_COMIS-AQ04->E3_YVLEMP1, "PROV COMIS VARIAVEL S/ NF "+AQ04->E3_PREFIXO+AQ04->E3_NUM })
			Else
				Aadd(fgVetCtb, { "21106003", "31403001", xcCLVL, xcCLVL, "COM"+AQ04->E3_VEND, "", AQ04->E3_YVLEMP1-AQ04->E3_COMIS, "EXCL. PROV VARIAVEL COM. S/NF "+AQ04->E3_NUM })
			EndIf
			
			dbSelectArea("AQ04")
			dbSkip()
		End
		AQ04->(dbCloseArea())
		
		U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

	EndIf

EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

fCabec  := 'Comissão Variável - Mês de Referência ' + SUBSTRING(SUBSTRING(ALLTRIM(U_MES(MV_PAR02)),3,9),1, IIF(AT(' ',SUBSTRING(ALLTRIM(U_MES(MV_PAR02)),3,9))==0, 10, AT(' ',SUBSTRING(ALLTRIM(U_MES(MV_PAR02)),3,9))) - 1) + '/' + STR(YEAR(MV_PAR02),4)

// Tiago Rossini Coradini - 02/05/2017 - OS: 0507-17
fCabec2 := 'Marca: ' + fGetMarca() 

oPrint:StartPage()
wnPag ++
nRow1 := 050

If cEmpAnt == "07"
	
	oPrint:Say(nRow1, 0050, "LM Comércio LTDA", oFont16)
	
ElseIf File(cLogo)
	
	oPrint:SayBitmap(nRow1, 0050, cLogo, 0500, 0150)
	
EndIf

nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)

If nEmp == "'1399'"
	nRow1 += 80
	cLinAux := 'Meta Receita Empresa = ' + Transform(nTotMeta,"@E 999,999,999.99")
	oPrint:Say  (nRow1   , 0050 ,Padr(cLinAux,133)                       ,oFont8)
	nRow1 += 40
	cLinAux := 'Receita Realizada =    ' + Transform(nTotFatEmp + nTotDevEmp,"@E 999,999,999.99")
	oPrint:Say  (nRow1   , 0050 ,Padr(cLinAux,133)                       ,oFont8)
	nRow1 += 40
	cLinAux := 'Meta da Empresa Atingida = ' + IIF(lMetaAting,'SIM','NÃO' )
	oPrint:Say  (nRow1   , 0050 ,Padr(cLinAux,133)                       ,oFont8)
	nRow1 += 065
	
	//Rep.	Nome	Nome Reduzido	Meta Receita	Receita Real.	%Ating. 	%Com. Var. Representante	%Com. Var. Empresa	%Com. Var. Total	Valor comissão
	
	xf_Titu := Padc("Rep."                       ,06, " ") + "|"
	xf_Titu2:= Padc(""                           ,06, " ") + "|"
	
	xf_Titu += Padr("Nome"                       ,20, " ") + "|"
	xf_Titu2+= Padr(""                           ,20, " ") + "|"
	
	xf_Titu += Padr("Nome Reduzido"              ,17, " ") + "|"
	xf_Titu2+= Padr(""                           ,17, " ") + "|"
	
	xf_Titu += Padc("UF" 				         ,02, " ") + "|"
	xf_Titu2+= Padc(""                           ,02, " ") + "|"
	
	xf_Titu += Padc("          Meta"  		     ,14, " ")
	xf_Titu2+= Padc("       Receita"             ,14, " ")
	
	xf_Titu += Padc("       Receita"             ,14, " ")
	xf_Titu2+= Padc("          Real"             ,14, " ")
	
	xf_Titu += Padc("       %Ating."             ,14, " ")
	xf_Titu2+= Padc("         Total"             ,14, " ")
	
	xf_Titu += Padc("     %Com.Var."             ,14, " ")
	xf_Titu2+= Padc("       Repres."             ,14, " ")
	
	xf_Titu += Padc("     %Com.Var."             ,14, " ")
	xf_Titu2+= Padc("       Empresa"             ,14, " ")
	
	xf_Titu += Padc("     %Com.Var."             ,14, " ")
	xf_Titu2+= Padc("         Total"             ,14, " ")
	
	xf_Titu += Padc("         Valor"             ,14, " ")
	xf_Titu2+= Padc("      Comissão"             ,14, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
	nRow1 += 025
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont7)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	
	nRow1 += 075
Else
	nRow1 += 150
	
	xf_Titu := Padc("Rep."                       ,06, " ")+" "
	xf_Titu2:= Padc(""                           ,06, " ")+" "
	
	xf_Titu += Padr("Nome"                       ,20, " ")+" "
	xf_Titu2+= Padr(""                           ,20, " ")+" "
	
	xf_Titu += Padr("Nome Reduzido"              ,17, " ")+" "
	xf_Titu2+= Padr(""                           ,17, " ")+" "
	
	xf_Titu += Padc("UF" 				         ,02, " ")+" "
	xf_Titu2+= Padc(""                           ,02, " ")+" "
	
	xf_Titu += Padc("Meta"                       ,14, " ")
	xf_Titu2+= Padc("Prç Médio"                  ,14, " ")
	
	xf_Titu += Padc("Prç.Médio"                  ,14, " ")
	xf_Titu2+= Padc("Real"                       ,14, " ")
	
	xf_Titu += Padc("%Ating."                    ,14, " ")
	xf_Titu2+= Padc("Preço"                      ,14, " ")
	
	xf_Titu += Padc("%Com.Var."                  ,14, " ")
	xf_Titu2+= Padc("Preço"                      ,14, " ")
	
	xf_Titu += Padc("Meta"                       ,14, " ")
	xf_Titu2+= Padc("Volume"                     ,14, " ")
	
	xf_Titu += Padc("Volume"                     ,14, " ")
	xf_Titu2+= Padc("Real"                       ,14, " ")
	
	xf_Titu += Padc("%Ating."                    ,14, " ")
	xf_Titu2+= Padc("Volume"                     ,14, " ")
	
	xf_Titu += Padc("%Com.Var."                  ,14, " ")
	xf_Titu2+= Padc("Volume"                     ,14, " ")
	
	xf_Titu += Padc("%Com"                    	 ,14, " ")
	xf_Titu2+= Padc("Receita"                    ,14, " ")
	
	xf_Titu += Padc("%Com."                  	 ,14, " ")
	xf_Titu2+= Padc("Var."                   	 ,14, " ")
	
	xf_Titu += Padc("Receita"                    ,14, " ")
	xf_Titu2+= Padc("Real"                       ,14, " ")
	
	xf_Titu += Padc("Valor"                      ,14, " ")
	xf_Titu2+= Padc("Comissão"                   ,14, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
	nRow1 += 075
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont7)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	
	nRow1 += 075
EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (2300, 010, 2300, 3350)
oPrint:Say  (2300+30 , 010,"Prog.: BIA479"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return
//----------------------------------------------------------------------------------------------
Static Function cTotalFat()
Local cSqlFat := ""

cSqlFat += " SELECT  ISNULL(SUM(ISNULL(VLR_REAL,0)),0.0) AS TOTAL"
cSqlFat += " FROM " + nNomeTMP 
cSqlFat += " WHERE TABELA = 'SD2'"
cSqlFAt += " 	AND VEND1<>'999999'"
cSqlFAt += " 	AND VEND1 IN (SELECT A3_COD FROM SA3010"
cSqlFAt += " 		WHERE	A3_COD 		= VEND1 		AND"
//cSqlFAt += " 				A3_YCOMVAR 	= 'S'           AND"
cSqlFAt += " 				A3_YATIVO  	= 'S'           AND"
//cSqlFAt += " 				A3_MSBLQL  	<> '1'          AND"
cSqlFAt += " 				D_E_L_E_T_ 	= '')"

Return cSqlFat

//----------------------------------------------------------------------------------------------
Static Function cTotalDev() 
Local cSqlDev := ""

cSqlDev += " SELECT  ISNULL(SUM(ISNULL(VLR_REAL,0)),0.0) AS TOTAL
cSqlDev += " FROM "+nNomeTMP+" 
cSqlDev += " WHERE TABELA = 'SD1'
cSqlDev += " 	AND VEND1<>'999999'"
cSqlDev += " 	AND VEND1 IN (SELECT A3_COD FROM SA3010"
cSqlDev += " 		WHERE	A3_COD 		= VEND1 		AND"
//cSqlDev += " 				A3_YCOMVAR 	= 'S'           AND"
cSqlDev += " 				A3_YATIVO  	= 'S'           AND"
//cSqlDev += " 				A3_MSBLQL  	<> '1'          AND"
cSqlDev += " 				D_E_L_E_T_ 	= '')"

Return cSqlDev
//----------------------------------------------------------------------------------------------
Static Function cTotalMeta() 
Local cSqlMeta := ""

cSqlMeta += " SELECT  SUM(ISNULL(VLR_META,0)) AS TOTAL "
cSqlMeta += " FROM "+nNomeTMP
cSqlMeta += " WHERE VEND1<>'999999'"
cSqlMeta += " 	AND VEND1 IN (SELECT A3_COD FROM SA3010"
cSqlMeta += " 		WHERE	A3_COD 		= VEND1 		AND"
//cSqlMeta += " 				A3_YCOMVAR 	= 'S'           AND"
cSqlMeta += " 				A3_YATIVO  	= 'S'           AND"
//cSqlMeta += " 				A3_MSBLQL  	<> '1'          AND"
cSqlMeta += " 				D_E_L_E_T_ 	= '')"

Return cSqlMeta
//----------------------------------------------------------------------------------------------z

Static Function fFormatPar(cPar)
Local aArea := SX5->(GetArea())
Local cRet := ""
Local nCount := 1
	
	cPar := AllTrim(StrTran(cPar, "*"))
	
	If !Empty(cPar)
	
		cRet := StrTran(StrTran(StrTran(FormatIn(cPar,,1), "'"), "("), ")")
		
	Else

		DbSelectArea("SX5")
		DbSetOrder(1)		
		If SX5->(DbSeek(cFilial+"ZH"))
			
			While !SX5->(Eof()) .And. AllTrim(SX5->X5_TABELA) == "ZH"
				
				cRet += Left(SX5->X5_CHAVE, 1) + ","
				
				SX5->(DbSkip())
			
			EndDo()
			
		EndIf
	
	EndIf
	
	RestArea(aArea)
		
Return(cRet)


Static Function fGetMarca(lDesc)
Local cRet := ""

	Default lDesc := .T. 

	If cEmpAnt == "05"
		
		If MV_PAR05 == 1
			
			cRet := If (lDesc, "INCESA", "2")
			
		ElseIf MV_PAR05 == 2
			
			cRet := If (lDesc, "BELLACASA", "3")
			
		ElseIf MV_PAR05 == 3
			
			cRet := If (lDesc, "MUNDIALLI", "4")
			
		EndIf
		           
	ElseIf cEmpAnt == "07"

		If MV_PAR05 == 1
			
			cRet := If (lDesc, "BIANCOGRES", "1")
			
		ElseIf MV_PAR05 == 2
			
			cRet := If (lDesc, "INCESA", "2")
			
		ElseIf MV_PAR05 == 3
			
			cRet := If (lDesc, "BELLACASA", "3")
			
		ElseIf MV_PAR05 == 4
			
			cRet := If (lDesc, "MUNDIALLI", "4")
		
		EndIf
		
	EndIf
	
Return(cRet)