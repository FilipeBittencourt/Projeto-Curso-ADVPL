#Include "Protheus.ch"
#Include "Totvs.ch"

User Function ReadSPED() 
Local cArq      := "\@Append\SPED_DEZ2015.txt" 
Local c0300     := ""//:= "SPED0300"
Local cG125     := ""
Local cInd0300  := ""
Local cIndG125  := ""
Local aStru0300 := {} 
Local aStruG125 := {} 
Local nHandle   := -1 
Local cLinha    := ""
Local aLinha    := {}

	If !File(cArq)
		Return
	End If

	nHandle := FT_FUse(cArq)	
	
	If nHandle == -1
		FT_FUse()
		Return
	End If

	aAdd(aStru0300, {"REG0300"   , "C", 004, 0})	
	aAdd(aStru0300, {"CODINDBEM" , "C", 060, 0})		
	aAdd(aStru0300, {"IDENTMERC" , "C", 001, 0})    
	aAdd(aStru0300, {"DESCRITEM" , "C", 254, 0})
	aAdd(aStru0300, {"CODPRNC"   , "C", 060, 0})
	aAdd(aStru0300, {"CODCTA"    , "C", 060, 0})   
	aAdd(aStru0300, {"NRPARC"    , "N", 003, 0})    
	aAdd(aStru0300, {"REG0305"   , "C", 004, 0})
	aAdd(aStru0300, {"CODCCUS"   , "C", 060, 0})
	aAdd(aStru0300, {"FUNCAO"    , "C", 254, 0})   
	aAdd(aStru0300, {"VIDAUTIL"  , "N", 003, 0})	
	
	aAdd(aStruG125, {"REGG125"   , "C", 004, 0})	
	aAdd(aStruG125, {"CODINDBEM" , "C", 060, 0})		
	aAdd(aStruG125, {"DTMOV"     , "D", 008, 0})    
	aAdd(aStruG125, {"TIPOMOV"   , "C", 002, 0})
	aAdd(aStruG125, {"VLICMSOP"  , "N", 009, 2})
	aAdd(aStruG125, {"VLICMSST"  , "N", 009, 2})   
	aAdd(aStruG125, {"VLICMSFRT" , "N", 009, 2})    
	aAdd(aStruG125, {"VLICMSDIF" , "N", 009, 2})
	aAdd(aStruG125, {"NUMPARC"   , "N", 003, 0})
	aAdd(aStruG125, {"VLPARCPASS", "N", 009, 2})  
	aAdd(aStruG125, {"REGG130"   , "C", 004, 0})	
	aAdd(aStruG125, {"INDEMIT"   , "C", 001, 0})		
	aAdd(aStruG125, {"CODPART"   , "C", 060, 0})    
	aAdd(aStruG125, {"CODMOD"    , "C", 002, 0})
	aAdd(aStruG125, {"SERIE"     , "C", 003, 0})
	aAdd(aStruG125, {"NUMDOC"    , "C", 009, 0})   
	aAdd(aStruG125, {"CHVNFECTE" , "C", 044, 0})    
	aAdd(aStruG125, {"DTDOC"     , "D", 008, 0})	
	aAdd(aStruG125, {"REGG140"   , "C", 004, 0})	
	aAdd(aStruG125, {"NUMITEM"   , "N", 003, 0})		
	aAdd(aStruG125, {"CODITEM"   , "C", 060, 0})   	

	If Select("S0300") > 0
		DbSelectArea("S0300")
		DbCloseArea()
	End If	
	
	If Select("SG125") > 0
		DbSelectArea("SG125")
		DbCloseArea()
	End If		
	
	c0300    := CriaTrab(aStru0300)
	cInd0300 := CriaTrab(Nil,.F.)
	cG125    := CriaTrab(aStruG125)	
	cIndG125 := CriaTrab(Nil,.F.)
	
	Use (c0300) Alias S0300 New	
	IndRegua("S0300",cInd0300,"CODINDBEM",,,.F.)		
	
	Use (cG125) Alias SG125 New	
	IndRegua("SG125",cIndG125,"CODINDBEM",,,.F.)	
	
	DbSelectArea("S0300")
	DbSetOrder(1)
	DbSelectArea("SG125")	
	DbSetOrder(1)	

	FT_FGoTop()
	
	While !FT_FEof()
		cLinha := FT_FReadLn()	
		
		If !Empty(cLinha)
			Do Case
				Case SubStr(cLinha, 1, 5) ==   "|0300"
					aLinha := StrTokArr2(cLinha, "|", .T.)  
					
					If Len(aLinha) >= 9
						RecLock("S0300",.T.)
							S0300->REG0300   := aLinha[2]
							S0300->CODINDBEM := aLinha[3]
							S0300->IDENTMERC := aLinha[4]
							S0300->DESCRITEM := aLinha[5]     
							S0300->CODPRNC   := aLinha[6]
							S0300->CODCTA    := aLinha[7]
							S0300->NRPARC    := If(!Empty(aLinha[8]), Val(aLinha[8]), 0)
						S0300->(MsUnlock())
					End If					
				Case SubStr(cLinha, 1, 5) ==   "|0305"				
					aLinha := StrTokArr2(cLinha, "|", .T.)  
					
					If Len(aLinha) >= 6 .And. S0300->(!Eof())
						RecLock("S0300", .F.)
							S0300->REG0305  := aLinha[2]
							S0300->CODCCUS  := aLinha[3]
							S0300->FUNCAO   := aLinha[4]
							S0300->VIDAUTIL := If(!Empty(aLinha[5]), Val(aLinha[5]), 0)   
						S0300->(MsUnlock())					
					End If	
				Case SubStr(cLinha, 1, 5) ==   "|G125"				
					aLinha := StrTokArr2(cLinha, "|", .T.)  
					
					If Len(aLinha) >= 12 
						RecLock("SG125", .T.)
							SG125->REGG125    := aLinha[2]
							SG125->CODINDBEM  := aLinha[3]
							SG125->DTMOV      := Stod(SubStr(aLinha[4],5,4) + SubStr(aLinha[4],3,2) + SubStr(aLinha[4],1,2))      //01122015
							SG125->TIPOMOV    := aLinha[5]
							SG125->VLICMSOP   := Val(StrTran(aLinha[6],",","."))
							SG125->VLICMSST   := Val(StrTran(aLinha[7],",","."))
							SG125->VLICMSFRT  := Val(StrTran(aLinha[8],",","."))
							SG125->VLICMSDIF  := Val(StrTran(aLinha[9],",","."))
							SG125->NUMPARC    := Val(aLinha[10])
							SG125->VLPARCPASS := Val(StrTran(aLinha[11],",","."))
						SG125->(MsUnlock())					
					End If	
				Case SubStr(cLinha, 1, 5) == "|G130"				
					aLinha := StrTokArr2(cLinha, "|", .T.)  
					
					If Len(aLinha) >= 10 .And. SG125->(!Eof())
						RecLock("SG125", .F.)
							SG125->REGG130   := aLinha[2]
							SG125->INDEMIT   := aLinha[3]
							SG125->CODPART   := aLinha[4]
							SG125->CODMOD    := aLinha[5]
							SG125->SERIE     := aLinha[6]
							SG125->NUMDOC    := aLinha[7]
							SG125->CHVNFECTE := aLinha[8]
							SG125->DTDOC     := Stod(SubStr(aLinha[9],5,4) + SubStr(aLinha[9],3,2) + SubStr(aLinha[9],1,2))
						SG125->(MsUnlock())					
					End If	
				Case SubStr(cLinha, 1, 5) == "|G140"				
					aLinha := StrTokArr2(cLinha, "|", .T.)  
					
					If Len(aLinha) >= 5 .And. SG125->(!Eof())
						RecLock("SG125", .F.)
							SG125->REGG140   := aLinha[2]
							SG125->NUMITEM   := Val(aLinha[3])
							SG125->CODITEM   := aLinha[4]						
						SG125->(MsUnlock())					
					End If						
			End Case
		End If
		
		FT_FSkip()	
	End Do

	FT_FUse()
	
	DbSelectArea("SF9")
	DbSetOrder(1)
	
	DbSelectArea("SG125")
	DbSetOrder(1)	

	DbSelectArea("S0300")
	DbSetOrder(1)
	DbGoTop()
	
	While !S0300->(Eof())
		If !SF9->(DbSeek( xFilial("SF9") + SubStr(S0300->CODINDBEM, 1, 6)))
			RecLock("SF9", .T.)			
			SF9->F9_FILIAL := xFilial("SF9")
			SF9->F9_CODIGO := SubStr(S0300->CODINDBEM, 1, 6)
		Else
			RecLock("SF9", .F.)		
		End If
		
		SF9->F9_TIPO    := If(S0300->IDENTMERC == "1", "01", "03")
		SF9->F9_DESCRI  := Alltrim(S0300->DESCRITEM)
		SF9->F9_CODBAIX := If(Empty(S0300->CODPRNC),"",SubStr(S0300->CODPRNC,1,6))
		SF9->F9_PLACON  := Alltrim(SubStr(S0300->CODCTA,1,20))
		SF9->F9_QTDPARC := S0300->NRPARC
		SF9->F9_FUNCIT  := Alltrim(S0300->FUNCAO)
		
		SG125->(DbGoTop())
		
		If SG125->(DbSeek( AllTrim(S0300->CODINDBEM) ))
			SF9->F9_VLICMSO := SG125->VLICMSOP
			SF9->F9_VALICCO := SG125->VLICMSST
			SF9->F9_VLICMSF := SG125->VLICMSFRT
			SF9->F9_ICMSDIF := SG125->VLICMSDIF
			SF9->F9_SLDPARC := SF9->F9_QTDPARC - SG125->NUMPARC
			SF9->F9_FORNECE := SubStr(SG125->CODPART, 08, 09)
			SF9->F9_LOJAFOR := SubStr(SG125->CODPART, 17, 04)
			SF9->F9_PROPRIO := "N"
			SF9->F9_SERNFE  := AllTrim(SG125->SERIE)
			SF9->F9_DOCNFE  := Alltrim(SG125->NUMDOC)
			SF9->F9_DTENTNE := SG125->DTDOC
			SF9->F9_DTEMINE := SG125->DTDOC
			SF9->F9_VALICMS := SG125->(VLICMSOP + VLICMSST + VLICMSFRT + VLICMSDIF)
		End If
		
		SF9->(MsUnlock())
	
		S0300->(DbSkip())
	End Do
	
	S0300->(DbCloseArea())
	SG125->(DbCloseArea())
	
	If File("\@Append\S0300.dbf")
		FErase("\@Append\S0300.dbf")
	End If
	
	If File("\@Append\SG125.dbf")
		FErase("\@Append\SG125.dbf")
	End If	
	
	FRename(c0300 + ".dbf", "\@Append\S0300.dbf")	
	FRename(cG125 + ".dbf", "\@Append\SG125.dbf")		
	
	If File(c0300 + ".dbf")
		FErase(c0300 + ".dbf")
	End If	
	
	If File(cG125 + ".dbf")
		FErase(cG125 + ".dbf")
	End If	

	FErase(cInd0300 + OrdBagExt()) 	
	FErase(cIndG125 + OrdBagExt()) 		
Return