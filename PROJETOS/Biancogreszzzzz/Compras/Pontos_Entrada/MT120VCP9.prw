#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120VCP9  Autor  ³Microsiga           º Data ³  20/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alterar a condicao de pagamento.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT120VCP9()

LOCAL cCond2 := "   " 

Local oButton1
Static oDlg
Static oWBrowse1
Static aWBrowse1 := {} 
Static cFornOld := '' 

//Pergunte("MT120V",.T.)
//cCondicao := MV_PAR01

//Busca condicao do fornecedor



IF UPPER(ALLTRIM(FUNNAME())) == "MATA121"
	//Busca a condicao do fornecedor
	//DbselectArea("SA2")
	//DbSetOrder(1)
	//DbSeek(xFilial("SA2")+cA120Forn+cA120Loj)
	//cCond1 := SA2->A2_COND

//PERMITIR ESCOLHER OUTRA OPCAO SEM SER A QUE FOI LISTADA NA TELA	
	If (Len(aWBrowse1)>=1) .And. (Alltrim(cFornOld) == Alltrim(cA120Forn))
	     return
	EndIf
	cFornOld := cA120Forn
	
	//Busca condicao da Tabela de Precos
	cQUERY := "SELECT AIA_CODFOR, AIA_LOJFOR, AIA_CONDPG, E4_DESCRI    "	
	cQUERY += "FROM "+RETSQLNAME("AIA")+" AIA " 
	cQUERY += " INNER JOIN "+RETSQLNAME("SE4")+" SE4 ON E4_CODIGO = AIA_CONDPG AND SE4.D_E_L_E_T_=''
	cQUERY += " WHERE AIA_CODFOR  = '"+cA120Forn+"' "
	cQUERY += "AND   AIA_LOJFOR  = '"+cA120Loj+"' "
	cQUERY += "AND   AIA_DATDE  <= '"+DTOS(dDatabase)+"' "
	cQUERY += "AND   AIA_DATATE >= '"+DTOS(dDatabase)+"' "
	cQUERY += "AND AIA.D_E_L_E_T_ = ''  "
	cQUERY += " GROUP BY AIA_CODFOR,AIA_LOJFOR,AIA_CONDPG,E4_DESCRI "
	cQUERY += " ORDER BY AIA_CONDPG DESC "
	If chkfile("_Trab")
		dbSelectArea("_Trab")                               
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_Trab" NEW 
	
	aWBrowse1 := {}
	IF !_Trab->(EOF())
//		aWBrowse1 := {}
		Aadd(aWBrowse1,{"   ", "NENHUMA DAS OPÇÕES"})

		While !_Trab->(EOF())
		    Aadd(aWBrowse1,{_Trab->AIA_CONDPG, _Trab->E4_DESCRI})
    
 			_trab->(dbskip())
		enddo
	EndIf

   If(Len(aWBrowse1)> 1)
	  DEFINE MSDIALOG oDlg TITLE "Condições de Pagamento Disponiveis" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL
	
	 	@ 026, 000 LISTBOX oWBrowse1 Fields HEADER "CODIGO", "DESCRICAO" SIZE 249, 060 OF oDlg PIXEL ColSizes 40,50
	    oWBrowse1:SetArray(aWBrowse1)
	       oWBrowse1:bLine := {|| {;
		      aWBrowse1[oWBrowse1:nAt,1],;
		      aWBrowse1[oWBrowse1:nAt,2];
		    }}
	    // DoubleClick event
	    oWBrowse1:bLDblClick := {|| Selecione()}
	     
	
	    //@ 104, 095 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
	    @ 104, 060	Button "Selecionar" Size 037,12 Action Selecione()
	    @ 104, 125	Button "Fechar" Size 037,12 Action oDlg:End()
	
	  ACTIVATE MSDIALOG oDlg CENTERED   
	Else
		msgstop("Não Existe Tabela de Preço para esse Fornecedor"," MT120VCP9")
	   //	cCondicao := "   " 
	EndIf
  
EndIf


Return 

Static Function Selecione()
      
cCondicao := aWBrowse1[oWBrowse1:nAt,1]
A120DescCnd(cCondicao,,@cDescCond)

oDlg:End()

Return()