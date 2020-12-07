#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BIA439()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA439   ºAutor  ³ Wanisay William    º Data ³  28/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tabela de Preco.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private nDesconto := 0

cHInicio := Time()
fPerg := "BIA439"
//ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

Processa({|| RptDet_1()})

Return

Static Function RptDet_1()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Regras de Desconto - Representantes."
fCabec2  := " "
lFlag    := '1'
wnPag    := 0
nRow1    := 0

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

fImpCabec()

cSelect1 := "SELECT * "
cSelect1 += "From " + RETSQLNAME("SA3") + " SA3 "
cSelect1 += "Where 	SA3.A3_FILIAL 	= '" + xFilial("SA3") + "' And "
cSelect1 += "	SA3.A3_MSBLQL  	<> '1'               		   And "
cSelect1 += "	SA3.A3_COD  	>= '" + MV_PAR01 +"'		   And "
cSelect1 += "	SA3.A3_COD   	<= '" + MV_PAR02 +"'		   And "
IF cEmpAnt == '01'
	cSelect1 += "	SA3.A3_COMIS  	> 0               		   And "
ELSE
	cSelect1 += "	SA3.A3_YCOMISI 	> 0               		   And "
ENDIF
cSelect1 += "	SA3.D_E_L_E_T_	= ''		                       "
cSelect1 += "ORDER BY SA3.A3_NOME       	                       "
If chkfile("X1")
	dbSelectArea("X1")
	dbCloseArea()
EndIf
TCQUERY cSelect1 ALIAS "X1" NEW

WHILE !X1->(Eof())

	nDesconto := 0
	nTipo     := 'S'
	
    cSelect2 := "SELECT ACO_CODREG, ACO_DESCRI, ACP_CODPRO, ACO_CODCLI, ACO_GRPVEN, ACO_CODREG, ACP_YTPDES, ACP_ITEM, ACP_YDATDE, ACP_YDATAT, ISNULL(CONVERT(VARCHAR(500),CONVERT(BINARY(500),ACO_YOBS)),'') AS ACO_YOBS, ACP_PERDES, ACP_YSEGME, "
	cSelect2 += "		SEGMENTO =	CASE "
	cSelect2 += "						WHEN ACP_YSEGME = '' THEN '-' "
	cSelect2 += "						ELSE ISNULL((SELECT X5_DESCRI FROM "+RETSQLNAME("SX5")+" WHERE D_E_L_E_T_ = '' AND X5_TABELA = 'T3' AND X5_CHAVE = ACP_YSEGME),'VERIFIQUE CADASTRO') "
	cSelect2 += "					END "
	cSelect2 += "From " + RETSQLNAME("ACO") + " ACO, " + RETSQLNAME("ACP") + " ACP "
	cSelect2 += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' And "
	cSelect2 += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' And "
	cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	>= ACP.ACP_YDATDE  And "
	cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	<= ACP.ACP_YDATAT  And "
	cSelect2 += "   ACP.ACP_CODREG	= ACO.ACO_CODREG               And "
	cSelect2 += "	ACP.ACP_YVEND	= '" + X1->A3_COD +"'		   And "
	cSelect2 += "	ACP.ACP_CODPRO	= '" + "R"+SUBSTR(X1->A3_COD,2,5)+"'		   And "    
	cSelect2 += "	ACP.D_E_L_E_T_	= ''		                   And "
	cSelect2 += "	ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' "
	If chkfile("X2")
		dbSelectArea("X2")
		dbCloseArea()
	EndIf
	TCQUERY cSelect2 ALIAS "X2" NEW
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf

	While !X2->(Eof())
		IF X2->ACP_PERDES > 0
			nDesconto := X2->ACP_PERDES
		ENDIF
		xf_Item := +;
		Padr(X1->A3_COD+"-"+SUBSTR(X1->A3_NOME,1,30)     ,40)+"  "+;
		Padr(SUBSTR(X2->SEGMENTO,1,20)					 ,20)+"  "+;
		Padl(Transform(nDesconto,  "@E 999.99")          ,15)+"  "+;
		Padl(nTipo                                       ,04)+"  "+;     
		Padl(X2->ACP_ITEM                                ,04)+"  "+;	 	
		Padl(X2->ACO_CODREG                              ,06)+"  "+;	 
		Padl(X2->ACO_DESCRI                              ,20)+"  "+;		
		Padl(STOD(X2->ACP_YDATDE)                        ,10)+"  "+;		 
		Padl(STOD(X2->ACP_YDATAT)                        ,10)+"  "+;		 	
		Padl(SUBSTR(X2->ACO_YOBS,1,50)                   ,50)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
	//	oPrint:Say  (nRow1 ,0010 ,Replicate("-",190) ,oFont8)
	//	nRow1 += 025
		X2->(DbSkip())
	End
	
	DbSelectArea("X1")
	X1->(DbSkip())
END

fImpRoda()

fCabec   := "Regras de Desconto - Clientes."
lFlag    := '2'

cSelect2 := "SELECT ACO_CODREG, ACO_DESCRI, ACP_CODPRO, ACO_CODCLI, ACO_GRPVEN, ACO_CODREG, ACP_YTPDES, ACP_ITEM, ACP_YDATDE, ACP_YDATAT, ISNULL(CONVERT(VARCHAR(500),CONVERT(BINARY(500),ACO_YOBS)),'') AS ACO_YOBS, ACP_PERDES, ACP_YSEGME "
cSelect2 += "From " + RETSQLNAME("ACO") + " ACO, " + RETSQLNAME("ACP") + " ACP "
cSelect2 += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' And "
cSelect2 += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' And "
cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	>= ACP.ACP_YDATDE  And "
cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	<= ACP.ACP_YDATAT  And "
cSelect2 += "   ACP.ACP_CODREG	= ACO.ACO_CODREG               And "
cSelect2 += "	(ACO.ACO_CODCLI	<> ' '		                   Or  "
cSelect2 += "	 ACO.ACO_GRPVEN	<> ' ')		                   And "
cSelect2 += "	ACP.D_E_L_E_T_	= ''		                   And "
cSelect2 += "	ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' "
cSelect2 += "ORDER BY ACO_DESCRI " 

If chkfile("X2")
	dbSelectArea("X2")
	dbCloseArea()
EndIf
TCQUERY cSelect2 ALIAS "X2" NEW

WHILE !Eof()
	
	IF !EMPTY(X2->ACO_CODCLI)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+X2->ACO_CODCLI)
		cCod  := SA1->A1_COD+"C"
		cNome := SA1->A1_NOME
	ELSE
		DbSelectArea("ACY")
		DbSetOrder(1)
		DbSeek(xFilial("ACY")+X2->ACO_GRPVEN)
		cCod  := ACY->ACY_GRPVEN+"G"
		cNome := ACY->ACY_DESCRI
	ENDIF
	
	nDesconto := 0
	IF X2->ACP_PERDES > 0
		nDesconto := X2->ACP_PERDES
	ENDIF
	
	nTipo := 'S'
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	xf_Item := +;
	Padr(cCod+"-"+SUBSTR(cNome,1,30)                 ,40)+"  "+;
	Padl(Transform(nDesconto,  "@E 999.99")          ,15)+"  "+;
	Padl(nTipo                                       ,04)+"  "+;
	Padl(X2->ACP_ITEM                                ,04)+"  "+;	 		
	Padl(X2->ACO_CODREG                              ,06)+"  "+;		
	Padl(X2->ACO_DESCRI                              ,20)+"  "+;			
	Padl(STOD(X2->ACP_YDATDE)                        ,10)+"  "+;		 
	Padl(STOD(X2->ACP_YDATAT)                        ,10)+"  "+;		 
	Padl(SUBSTR(X2->ACO_YOBS,1,50)                   ,50)	
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	//oPrint:Say  (nRow1 ,0010 ,Replicate("-",190) ,oFont8)
	//nRow1 += 050
	
	DbSelectArea("X2")
	DbSkip()
END

fImpRoda()

fCabec   := "Regras de Desconto - Produtos."
lFlag    := '3'

cSelect2 := "SELECT ACO_CODREG, ACO_DESCRI, ACP_CODPRO, ACO_CODCLI, ACO_GRPVEN, ACO_CODREG, ACP_YTPDES, ACP_ITEM, ACP_YDATDE, ACP_YDATAT, ISNULL(CONVERT(VARCHAR(500),CONVERT(BINARY(500),ACO_YOBS)),'') AS ACO_YOBS, ACP_PERDES, ACP_YSEGME "
cSelect2 += "From " + RETSQLNAME("ACO") + " ACO, " + RETSQLNAME("ACP") + " ACP "
cSelect2 += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' And "
cSelect2 += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' And "
cSelect2 += "   ACP.ACP_CODREG	= ACO.ACO_CODREG               And "
cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	>= ACP.ACP_YDATDE  And "
cSelect2 += "	'" + DTOS(MV_PAR03) +"' 	<= ACP.ACP_YDATAT  And "
cSelect2 += "	ACP.ACP_CODPRO	<> ' '		                   And "
cSelect2 += "	ACP.ACP_CODPRO	<> ACP.ACP_YVEND               And " 
cSelect2 += "	SUBSTRING(ACP.ACP_CODPRO,1,1) <> 'R'           And "
cSelect2 += "	ACP.D_E_L_E_T_	= ''		                   And "
cSelect2 += "	ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' "
If chkfile("X2")
	dbSelectArea("X2")
	dbCloseArea()
EndIf
TCQUERY cSelect2 ALIAS "X2" NEW

WHILE !Eof()
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+X2->ACP_CODPRO)
	cCod  := SB1->B1_COD
	cNome := SB1->B1_DESC
	
	nDesconto := 0
	IF X2->ACP_PERDES > 0
		nDesconto := X2->ACP_PERDES
	ENDIF
	
	IF X2->ACP_YTPDES == 'S'
		nTipo := 'S'
	ELSE
		nTipo := 'A'
	ENDIF
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	xf_Item := +;
	Padr(SUBSTR(cCod,1,8)+"-"+SUBSTR(cNome,1,30)     ,40)+"  "+;
	Padl(Transform(nDesconto,  "@E 999.99")          ,15)+"  "+;
	Padl(nTipo                                       ,04)+"  "+;
	Padl(X2->ACP_ITEM                                ,04)+"  "+;	 		
	Padl(X2->ACO_CODREG                              ,06)+"  "+;		
	Padl(X2->ACO_DESCRI                              ,20)+"  "+;			
	Padl(STOD(X2->ACP_YDATDE)                        ,10)+"  "+;		 
	Padl(STOD(X2->ACP_YDATAT)                        ,10)+"  "+;		 	
	Padl(SUBSTR(X2->ACO_YOBS,1,50)                   ,50)		
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	//oPrint:Say  (nRow1 ,0010 ,Replicate("-",190) ,oFont8)
	//nRow1 += 050
	
	DbSelectArea("X2")
	DbSkip()
END

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

DO CASE
	CASE lFlag == '1'
		xf_Titu := +;
		Padc("Representante"              ,40)+"  "+;
		Padc("Segmento"		              ,20)+"  "+;
		Padl("% Desconto"                 ,15)+"  "+; 
		Padc("Tipo"                       ,04)+"  "+;  				 
		Padl("Item"                       ,04)+"  "+;  						
		Padc("Regra"                      ,06)+"  "+; 
		Padc("Descrição"                  ,20)+"  "+;		
		Padl("Data Ini."                  ,10)+"  "+;		 
		Padl("Data Final"                 ,10)+"  "+;       
		Padc("Observacao"                 ,50)						
	CASE lFlag == '2'
		xf_Titu := +;
		Padc("Cliente      "              ,40)+"  "+;
		Padl("% Desconto"                 ,15)+"  "+;  
		Padc("Tipo"                       ,04)+"  "+;  				 
		Padl("Item"                       ,04)+"  "+;  						
		Padc("Regra"                      ,06)+"  "+; 
		Padc("Descrição"                  ,20)+"  "+;		
		Padl("Data Ini."                  ,10)+"  "+;		 
		Padl("Data Final"                 ,10)+"  "+;		
		Padc("Observacao"                 ,50)						
	CASE lFlag == '3'
		xf_Titu := +;
		Padc("Produto      "              ,40)+"  "+;
		Padl("% Desconto"                 ,15)+"  "+;  
		Padc("Tipo"                       ,04)+"  "+;  				 
		Padl("Item"                       ,04)+"  "+;  						
		Padc("Regra"                      ,06)+"  "+; 
		Padc("Descrição"                  ,20)+"  "+;		
		Padl("Data Ini."                  ,10)+"  "+;		 
		Padl("Data Final"                 ,10)+"  "+;		 
		Padc("Observacao"                 ,50)				
ENDCASE

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

nRow1 += 075

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (2300, 010, 2300, 3550)
oPrint:Say  (2300+30 , 010,"Prog.: BIA439"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 12.08.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local j,i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,6)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Do  Representante       ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Representante       ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"03","Data de Referencia      ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)

Return
