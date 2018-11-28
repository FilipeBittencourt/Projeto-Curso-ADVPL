#include "protheus.ch"
#include "msmgadd.ch" 
#INCLUDE "TOTVS.CH"                                                        
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH

//u_viewContatos()
User Function FT001()    

 Local aArea       := GetArea() 
 Local oBrowse     := nil
 private aRotina   := fMenuDef()
 private cCadastro := "Contatos"    

 oBrowse := FWMBrowse():New()
 oBrowse:SetAlias('SA1')
 oBrowse:SetDescription(cCadastro)
 //oBrowse:AddLegend("ZXV_STATUS = 'N'", "GREEN", "Novo") 
 //oBrowse:AddLegend("ZXV_STATUS = 'A'", "RED"  , "Aprovado")
 oBrowse:Activate() 
 RestArea(aArea)
 
Return 

//menu
Static Function fMenuDef()
 local aRotina := {} 
 aRotina := {{"Pesquisar"    ,"AxPesqui"   , 0, 1},;     
 {"Visualizar" ,"U_fActMenu" , 0, 2},; 
 {"Incluir"  ,"U_fActMenu" , 0, 3},;
 {"Alterar"  ,"U_fActMenu" , 0, 4},;
 {"Excluir"  ,"U_fActMenu" , 0, 5},;
 {"Aprovar"  ,"U_fActMenu" , 0, 2},;
 {"Legenda"    ,"U_fActMenu" , 0, 2}}
return aRotina


//Acoes do menu
User Function fActMenu(cAlias,nReg,nOpc)

 do case
  case nOpc == 3   
      fMontaTela(cAlias,nReg,nOpc)           
  case nOpc == 2   
   MsgStop("Operação não permitida, contrato já aprovado!") 
 endcase  
return   


//Monta Tela
Static Function fMontaTela(cAlias,nReg,nOpc)
 Local oDlgLocal
 Local oEnch
 Local lMemoria  := .T.
 Local lCreate := .T.
 Local lSX3 := .T. //verifica se irá criar a enchoice a partir do SX3 ou a partir de um vetor.
 Local aPos  := {000,000,400,600}        //posição da enchoice na tela
 Local aCpoEnch := {"A1_COD", "A1_NOME"}  //campos que serão mostrados na enchoice
 Local aAlterEnch := {}//{"A1_COD", "A1_NOME"}//{"ZXV_NOME", "ZXV_CPF"}  //habilita estes campos para edição
 Local aField := {}     
 Local aFolder := {}     
 Local cSvAlias  := Alias()
 
 /*Estrutura do vetor aField 
 [1] - Titulo 
 [2] - campo 
 [3] - Tipo //C-Char D-Data N-Numeric M-Memo
 [4] - Tamanho 
 [5] - Decimal 
 [6] - Picture 
 [7] - Valid 
 [8] - Obrigat 
 [9] - Nivel 
 [10]- Inicializador Padrão 
 [11]- F3          
 [12]- when 
 [13]- visual 
 [14]- chave 
 [15]- box 
 [16]- folder 
 [17]- nao alteravel 
 [18]- pictvar              
 [19]- gatilho */       

 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("SA1")
 While !Eof() .And. SX3->X3_ARQUIVO == "SA1" 
 If X3Uso(SX3->X3_USADO)  
  AADD(aAlterEnch, SX3->X3_CAMPO) 
 EndIf            
 DbSkip()
 EndDo 


 DbSelectArea("SA1")
 DbSetOrder(1)
 MsSeek("SA1")
 


 
 DEFINE MSDIALOG oDlg TITLE "Cadastrar Contato" FROM 0,0 TO 355,600 PIXEL  
  oDlg:lMaximized := .T.   
  RegToMemory("SA1", If(nOpc==3,.T.,.F.))  
  
    
  oEnch := MsmGet():New( "SA1", 0,3,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnch,aPos,aAlterEnch,; 
    /*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg,/*lF3*/,lMemoria,/*lColumn*/,; 
    /*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/,/*aFolder*/,/*lCreate*/,;
    /*lNoMDIStretch*/, /*cTela*/ )   
    
  oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT  
  ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,,,.F.,.F.) 
  
  If !Empty(cSvAlias) 
   DbSelectArea(cSvAlias)
  EndIf
  
return