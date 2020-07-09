#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PESQSATS

  /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  ±± Declaração de cVariable dos componentes                                 ±±
  Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
  Private cCliFinal  := Nil
  Private cCliIni    := Nil
  Private cDocFinal  := Nil
  Private cDocIni    := Nil
  Private cFilFinal  := Nil
  Private cFilIni    := Nil
  Private cStatus    := Nil
  Private dEmisFinal := CtoD(" ")
  Private dEmisIni   := CtoD(" ")
  Private aHeader    := GetHead()
  Private aCols      := Nil
  Private aColsDEF   := Nil
  Private cAlertIN    := .F.
  Private aStatus := {'A=Não enviados','P=Um Envio sem resposta','S=Dois Envios sem resposta','R=Resposta enviada','T=Todos'}
  
  
  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  
  cCliIni    := SPACE(TamSX3("F2_CLIENTE")[01])   
  cCliFinal  := PadL( cCliFinal, TamSX3("F2_CLIENTE")[01], "Z" ) 
  cDocIni    := SPACE(TamSX3("F2_DOC")[01]) 
  cDocFinal  := PadL( cDocFinal, TamSX3("F2_DOC")[01], "Z" )   
  cFilIni    := SPACE(TamSX3("F2_FILIAL")[01])
  cFilFinal  := PadL( cFilFinal, TamSX3("F2_FILIAL")[01], "Z" ) 
  dEmisIni   := FirstDate(Date()) //CToD("01/01/19")
  dEmisFinal := LastDate(Date()) //CToD("31/01/19")
  


  /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  ±± Declaração de Variaveis Private dos Objetos                             ±±
  Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
  SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay8","oGet1","oGet2")
  SetPrvt("oGet4","oGet5","oGet6","oGet7","oGet8","oGet9","oBtn1","oBtn2","oBtn3","oBrw1")


  /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  ±± Definicao do Dialog e todos os seus componentes.                        ±±
  Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
  oDlg1      := MSDialog():New( 092,232,685,1257,"Pesquisa de Satisfação",,,.F.,,,,,,.T.,,,.T. )
  oGrp1      := TGroup():New( 003,004,072,500,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
  oSay1      := TSay():New( 008,024,{||"Cliente De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay2      := TSay():New( 022,024,{||"Cliente Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay3      := TSay():New( 042,025,{||"Emissão De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay4      := TSay():New( 056,025,{||"Emissão Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)  
  oSay5      := TSay():New( 008,167,{||"Filial De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay6      := TSay():New( 022,167,{||"Filial Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay7      := TSay():New( 042,168,{||"Doc. De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay8      := TSay():New( 056,168,{||"Doc. Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)  
  oSay9      := TSay():New( 008,300,{||"Status:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oGet1      := TGet():New( 007,064,{|u| If(PCount()>0,cCliIni:=u,cCliIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cCliIni",,)
  oGet2      := TGet():New( 021,064,{|u| If(PCount()>0,cCliFinal:=u,cCliFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cCliFinal",,)  
  oGet3      := TGet():New( 041,065,{|u| If(PCount()>0,dEmisIni:=u,dEmisIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dEmisIni",,)
  oGet4      := TGet():New( 055,065,{|u| If(PCount()>0,dEmisFinal:=u,dEmisFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dEmisFinal",,)  
  oGet5      := TGet():New( 007,203,{|u| If(PCount()>0,cFilIni:=u,cFilIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"XM0","cFilIni",,)
  oGet6      := TGet():New( 021,203,{|u| If(PCount()>0,cFilFinal:=u,cFilFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"XM0","cFilFinal",,)  
  oGet7      := TGet():New( 041,204,{|u| If(PCount()>0,cDocIni:=u,cDocIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF2","cDocIni",,)
  oGet8      := TGet():New( 055,204,{|u| If(PCount()>0,cDocFinal:=u,cDocFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF2","cDocFinal",,)
  oGet9      := TComboBox():New(007,325,{|u| if(PCount()>0,cStatus:=u,cStatus)},aStatus,080,010,oGrp1,,/*{||Alert(cStatus)}*/,,,,.T.,,,,,,,,,"cStatus")

  oBtn1      := TButton():New( 005,450,"Filtrar",oGrp1,{||fFiltra()},040,015,,,,.T.,,"",,,,.F. )
  oBtn2      := TButton():New( 027,450,"Sair",oGrp1,{||fFechar()},040,015,,,,.T.,,"",,,,.F. )
  oBtn3      := TButton():New( 050,450,"Legenda",oGrp1,{||Legenda()},040,015,,,,.T.,,"",,,,.F. )


  //Monta o browser  
  oBrw1 :=   MsNewGetDados():New(;
  074,;                //nTop      - Linha Inicial
  004,;                //nLeft     - Coluna Inicial
  290,;                //nBottom   - Linha Final
  500,;                //nRight    - Coluna Final
  ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
  "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
  ,;                   //cTudoOk   - Validação de todas as linhas
  "",;                 //cIniCpos  - Função para inicialização de campos
  {},;                 //aAlter    - Colunas que podem ser alteradas
  ,;                   //nFreeze   - Número da coluna que será congelada
  9999,;               //nMax      - Máximo de Linhas
  ,;                   //cFieldOK  - Validação da coluna
  ,;                   //cSuperDel - Validação ao apertar '+'
  ,;                   //cDelOk    - Validação na exclusão da linha
  oGrp1,;              //oWnd      - Janela que é a dona da grid
  aHeader,;            //aHeader   - Cabeçalho da Grid
  aCols)               //aCols     - Dados da Grid


  //oBrw1:oBrowse:bLDblClick := {|| Iif(oBrw1:oBrowse:nColPos == 1 ,(DbClick(),oBrw1:oBrowse:Refresh()),oBrw1:EditCell()) }
  oBrw1:oBrowse:bLDblClick := {|| DbClick(oBrw1:nAt) }   // duplo click
  //oBrw1:lActive := .T. //Desativa as manipulações
  aColsDEF := oBrw1:ACOLS
  fFiltra()
  oDlg1:Activate(,,,.T.)


Return


Static Function GetHead()

  Local aHeader     := {}   
  aAdd(aHeader, {""            ,    "Legenda"   ,  "@BMP"             ,  3  ,     0,     ".T.",    ".T.", "C",  "",    ""} )  
  aAdd(aHeader, {"Filial"      ,    "Filial"    ,  ""                 ,  4  ,     0,     ".T.",    ".T.", "C",  "",    ""} )
  aAdd(aHeader, {"Categoria"   ,    "Categoria" ,  ""                 ,  10 ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Documento"   ,    "Documento" ,  ""                 ,  10 ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Serie"       ,    "Serie"     ,  ""                 ,  3  ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Cliente"     ,    "Cliente"   ,  ""                 ,  35 ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Atendente"   ,    "Atendente" ,  ""                 ,  28 ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Emissao"     ,    "Emissao"   ,  ""                 ,  10 ,     0,     ".T.",     "T",  "C",  "",    ""} )
  aAdd(aHeader, {"Valor"       ,    "Valor"     , "@E 999,999,999.99" ,  10 ,     0,     ".T.",     "T",  "N",  "",    ""} )
  


RETURN aHeader

Static Function GetaCols()

  Local aCols    := {}  
  Local	cQuery   := ""  
  Local lQuery   := .F.
  Local oCorLeg  := Nil

   
  cQuery += " SELECT   top 100 'SF2' AS ORIGEM ,   " + CRLF
  cQuery += " SF2.F2_FILIAL,  " + CRLF         
  cQuery += " SF2.F2_DOC,     " + CRLF      
  cQuery += " SF2.F2_SERIE,   " + CRLF        
  cQuery += " (SA1.A1_COD+'/'+SA1.A1_LOJA+' - '+SA1.A1_NOME) AS A1_CLIENTE,  " + CRLF
  cQuery += " SF2.F2_EMISSAO,    " + CRLF        
  cQuery += " SUBSTRING(SF2.F2_EMISSAO, 7, 2)+'/'+SUBSTRING(SF2.F2_EMISSAO, 5, 2)+'/'+SUBSTRING(SF2.F2_EMISSAO, 1, 4) AS F2_EMISSAO2  ,     " + CRLF      
  cQuery += " SF2.F2_VALBRUT , " + CRLF
  cQuery += " CASE  	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '1' THEN 'Revenda'	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '2' THEN 'Servicos'	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '3' THEN 'Comissao'	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '4' THEN 'Venda Direta'	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '5' THEN 'Revenda Equipamento'	" + CRLF	
  cQuery += " WHEN SC5.C5_YCATEGO = '6' THEN 'Locacao'  	" + CRLF	
  cQuery += " END as C5_YCATEGO,	" + CRLF
  cQuery += " SF2.F2_YSTAZAP,   	" + CRLF
  cQuery += " SA3.A3_COD+' - '+SA3.A3_NOME AS VENDENDOR  	" + CRLF	
  
  cQuery += " FROM " + RetSqlName("SF2") + "  SF2    " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC  = SD2.D2_DOC     AND SF2.F2_SERIE = SD2.D2_SERIE  AND SD2.D_E_L_E_T_ = ''  " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = SD2.D2_FILIAL AND SC5.C5_NUM  = SD2.D2_PEDIDO  AND SC5.C5_YCATEGO NOT IN ('4')   AND SC5.D_E_L_E_T_ = ''  " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SF2.F2_CLIENTE = SA1.A1_COD   AND SF2.F2_LOJA = SA1.A1_LOJA  " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.A3_COD = SC5.C5_VEND1     AND SA3.D_E_L_E_T_ = '' " + CRLF
  cQuery += " WHERE SF2.D_E_L_E_T_ = ''     " + CRLF      
  cQuery += " AND SA1.D_E_L_E_T_ = ''       " + CRLF
  cQuery += " AND SF2.F2_SERIE IN ('RPS','1')   " + CRLF 

  cQuery	+= "  AND SA1.A1_COD     BETWEEN " +ValToSql(cCliIni)+"  AND " +ValToSql(cCliFinal)+" " + CRLF    
  cQuery	+= "  AND SF2.F2_EMISSAO BETWEEN " +ValToSql(dEmisIni)+" AND " +ValToSql(dEmisFinal)+" " + CRLF        
  cQuery	+= "  AND SF2.F2_FILIAL  BETWEEN " +ValToSql(cFilIni)+" AND " +ValToSql(cFilFinal)+" " + CRLF    
  cQuery	+= "  AND SF2.F2_DOC     BETWEEN " +ValToSql(cDocIni)+" AND " +ValToSql(cDocFinal)+" " + CRLF     

  
  If cStatus == "A" /*"1=Não Enviados"*/
    cQuery	+= "  AND (SF2.F2_YSTAZAP = " +ValToSql(cStatus)+" OR  SF2.F2_YSTAZAP = '' )  " + CRLF
  ENDIF

  If cStatus != "T" .AND.  cStatus != "A"
    cQuery	+= "  AND SF2.F2_YSTAZAP = " +ValToSql(cStatus)+" " + CRLF      
    //cQuery	+= "  AND SF2.F2_EMISSAO BETWEEN " +ValToSql(DTOS(DATE()))+" AND " +ValToSql(DTOS(DATE()))+" " + CRLF    
  EndIf

   

  
  
  cQuery += " GROUP BY   SF2.F2_FILIAL,     " + CRLF      
  cQuery += " SF2.F2_DOC,                   " + CRLF
  cQuery += " SF2.F2_SERIE,      			      " + CRLF
  cQuery += " A1_NOME,                      " + CRLF
  cQuery += " A1_COD,                       " + CRLF
  cQuery += " SA1.A1_LOJA,                  " + CRLF
  cQuery += " SF2.F2_EMISSAO,               " + CRLF
  cQuery += " SC5.C5_YCATEGO,               " + CRLF
  cQuery += " SA3.A3_COD,                   " + CRLF
  cQuery += " SA3.A3_NOME,                  " + CRLF  
  cQuery += " SF2.F2_YSTAZAP,                " + CRLF  
  cQuery += " SF2.F2_VALBRUT                " + CRLF


  cQuery += " UNION ALL " + CRLF

  cQuery += "  SELECT  TOP 100            " + CRLF
  cQuery += "  'SC5' AS ORIGEM,           " + CRLF  
  cQuery += "  SC5B.C5_FILIAL AS FILIAL,  " + CRLF
  cQuery += "  SC5B.C5_NUM AS DOC,        " + CRLF
  cQuery += "  '' AS F2_SERIE,            " + CRLF 
  cQuery += "  (SA1.A1_COD+'/'+SA1.A1_LOJA+' - '+SA1.A1_NOME) AS A1_CLIENTE,  " + CRLF
  cQuery += "  SC5B.C5_EMISSAO AS EMISSAO,     " + CRLF       
  cQuery += "  SUBSTRING(SC5B.C5_EMISSAO, 7, 2)+'/'+SUBSTRING(SC5B.C5_EMISSAO, 5, 2)+'/'+SUBSTRING(SC5B.C5_EMISSAO, 1, 4) AS C5_EMISSAO2  ,      " + CRLF
  cQuery += "  SUM(SC6.C6_VALOR) AS VALBRUT,	" + CRLF	
  cQuery += " CASE  	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '1' THEN 'Revenda'	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '2' THEN 'Servicos'	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '3' THEN 'Comissao'	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '4' THEN 'Venda Direta'	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '5' THEN 'Revenda Equipamento'	" + CRLF	
  cQuery += " WHEN SC5B.C5_YCATEGO = '6' THEN 'Locacao'  	" + CRLF	
  cQuery += " END as C5_YCATEGO, 	" + CRLF	
  cQuery += " SC5B.C5_YSTAZAP,   	" + CRLF
  cQuery += " SA3.A3_COD+' - '+SA3.A3_NOME AS VENDENDOR  	" + CRLF	

  cQuery += " FROM " + RetSqlName("SC5") + " SC5B              " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC5B.C5_FILIAL = SC6.C6_FILIAL AND SC5B.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' 		" + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SC5B.C5_CLIENTE = SA1.A1_COD   AND SC5B.C5_LOJACLI = SA1.A1_LOJA  AND SC5B.D_E_L_E_T_ = ''  " + CRLF
  cQuery += " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.A3_COD = SC5B.C5_VEND1     AND SA3.D_E_L_E_T_ = '' " + CRLF
  cQuery += " WHERE  SC5B.D_E_L_E_T_ = ''	  " + CRLF
  cQuery += " AND SC5B.C5_YCATEGO ='4'      " + CRLF
  cQuery += " AND SC5B.C5_NOTA = ''         " + CRLF
    
  cQuery	+= "  AND SC5B.C5_CLIENTE     BETWEEN " +ValToSql(cCliIni)+"  AND " +ValToSql(cCliFinal)+" " + CRLF
  cQuery	+= "  AND SC5B.C5_EMISSAO BETWEEN " +ValToSql(dEmisIni)+" AND " +ValToSql(dEmisFinal)+" " + CRLF  
  cQuery	+= "  AND SC5B.C5_FILIAL  BETWEEN " +ValToSql(cFilIni)+" AND " +ValToSql(cFilFinal)+" " + CRLF
  cQuery	+= "  AND SC5B.C5_NOTA     BETWEEN " +ValToSql(cDocIni)+" AND " +ValToSql(cDocFinal)+" " + CRLF
  
  
 
  If cStatus == "A" /*"1=Não Enviados"*/
    cQuery	+= "  AND (SC5B.C5_YSTAZAP = " +ValToSql(cStatus)+" OR  SC5B.C5_YSTAZAP = '' )  " + CRLF
  ENDIF

  If cStatus != "T" .AND.  cStatus != "A"
    cQuery	+= "  AND SC5B.C5_YSTAZAP = " +ValToSql(cStatus)+" " + CRLF      
    //cQuery	+= "  AND SF2.F2_EMISSAO BETWEEN " +ValToSql(DTOS(DATE()))+" AND " +ValToSql(DTOS(DATE()))+" " + CRLF    
  EndIf
  
  cQuery += " GROUP BY         " + CRLF
  cQuery += " SC5B.C5_FILIAL,  " + CRLF
  cQuery += " SC5B.C5_NUM,     " + CRLF
  cQuery += " A1_NOME,         " + CRLF  
  cQuery += " A1_COD,          " + CRLF
  cQuery += " SA1.A1_LOJA,     " + CRLF  
  cQuery += " SC5B.C5_EMISSAO, " + CRLF  
  cQuery += " SC6.C6_PRCVEN,   " + CRLF
  cQuery += " SC5B.C5_YCATEGO, " + CRLF
  cQuery += " SA3.A3_COD,      " + CRLF
  cQuery += " SC5B.C5_YSTAZAP,  " + CRLF  
  cQuery += " SA3.A3_NOME,     " + CRLF  
  cQuery += " SC6.C6_NOTA      " + CRLF
  
  cQuery	+= "  ORDER BY SF2.F2_EMISSAO DESC      " + CRLF

  If Select("__TRB") > 0
    __TRB->(dbCloseArea())
  EndIf

  
  

    TcQuery cQuery New Alias "__TRB"
    __TRB->(dbGoTop())

  If !EMPTY(__TRB->F2_FILIAL)

    While ! __TRB->(EoF())
        
      If __TRB->F2_YSTAZAP == "P" //P=1 Envio sem resposta
          oCorLeg     := LoadBitmap( GetResources(), "BR_AZUL")      
      ElseIf __TRB->F2_YSTAZAP == "S" //S=2 Envio sem resposta
          oCorLeg     := LoadBitmap( GetResources(), "BR_AMARELO")      
      ElseIf __TRB->F2_YSTAZAP == "R" //R=Resposta enviada
          oCorLeg     := LoadBitmap( GetResources(), "BR_VERDE")      
      Else
          oCorLeg     := LoadBitmap( GetResources(), "BR_VERMELHO")
      EndIf
    
        aAdd(aCols, {oCorLeg ,__TRB->F2_FILIAL,__TRB->C5_YCATEGO,__TRB->F2_DOC,__TRB->F2_SERIE,__TRB->A1_CLIENTE,__TRB->VENDENDOR,__TRB->F2_EMISSAO2,__TRB->F2_VALBRUT,.F.})  

        __TRB->(DbSkip())
    EndDo
      __TRB->(DbCloseArea()) 

  else

    If cAlertIN == .T.
        MSGALERT("Dados não encontrados, por favor refaça os filtros.", "Aviso" )         
    EndIf
    cAlertIN := .T. // para não alertar que nao existe dados ao iniciar a tela

  EndIf

 

RETURN aCols

Static Function DbClick(nNumPos)

  Local oDlgInfo := Nil
  Local cNomeCli := SPACE(50)
  Local cTelZap  := SPACE(19)  
  Local cFilialx := ""
  Local cDoc     := ""
  Local cSerie   := ""
  Local aCols    := {}
 
  
  If  Len(oBrw1:Acols) > 0 .AND. !Empty(oBrw1:Acols[1,2])

    cFilialx := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Filial"})] 
    cDoc     := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Documento"})] 
    cSerie   := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Serie"})] 
    aCols := QueryZap(cFilialx,cDoc, cSerie)

    cNomeCli  := aCols[1,4] /*YNOMZAP*/
    cTelZap   := aCols[1,5] /*TELZAP*/ 

    oDlgInfo := MSDialog():New( 100,232,485,650,"Informativo:",,,.F.,,,,,,.T.,,,.T. )

    TSay():New( 010,015,{||"ID:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 008,050,{|u| aCols[1,2]/*F2_IDZAP*/},oDlgInfo,0120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 025,015,{||"STAUS:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 023,050,{|u| aCols[1,3]/*F2_YSTAZAP*/},oDlgInfo,0120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 040,015,{||"NOME:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 038,050,{|u|  If(PCount()>0,cNomeCli:=u,cNomeCli)  /*F2_YNOMZAP*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNomeCli",,)

    TSay():New( 055,015,{||"TELEFONE:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 053,050,{|u| If(PCount()>0,cTelZap:=u,cTelZap)/*F2_TELZAP*/ },oDlgInfo,120,008,'@R (99) 99999-9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cTelZap",,)

    TSay():New( 070,015,{||"DT. ENVIO:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 068,050,{|u| aCols[1,6]/*F2_DTEVZAP2*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 085,015,{||"RESPOSTA:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 083,050,{|u| aCols[1,7]/*F2_RESPZAP*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 0100,015,{||"OBS PV:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TMultiget():new( 098, 050, {| u | aCols[1,8]/*C5_YOBS*/ }, oDlgInfo, 0120,050, , , , , , .T., , , , , , .T. )

    If aCols[1,9] $ "P/S"   /* YSTAZAP */
      TButton():New( 160,050,"Sincronizar",oDlgInfo,{|| MSGALERT("(EM DESENV) Sincronismos com todos as pesquisas listadas em tela, caso existam.", "Aviso" ) },040,015,,,,.T.,,"",,,,.F. )
    EndIf
    
    If aCols[1,9] $ "A/P" .OR. EMPTY(aCols[1,9]) /* YSTAZAP */
      TButton():New( 160,130,"Enviar Pesq.",oDlgInfo,{||VldInfo(cNomeCli,cTelZap, cFilialx,cDoc,cSerie, oDlgInfo)},040,015,,,,.T.,,"",,,,.F. )
    EndIf

    oDlgInfo:Activate(,,,.T.)

  EndIf
   

Return

Static Function VldInfo(cNomeCli, cTelZap, cFilialx, cDoc, cSerie, oDlgInfo)

  Local lRet    := .T.
  Local cNewTel := cTelZap

  if EMPTY(cNomeCli)
    ALERT("O campo nome precisa ser preenchido.")
    lRet := .F.
  Else
    cTelZap := StrTran( cTelZap, "(", "")
    cTelZap := StrTran( cTelZap, ")", "")
    cTelZap := StrTran( cTelZap, "-", "")
    cNewTel := StrTran( cTelZap, " ", "")
    if Len(cNewTel)  < 11 .OR. EMPTY(cNewTel)
      ALERT("O campo Telefone precisa ser preenchido.")
      lRet := .F.
    EndIf
  EndIf

  If lRet
  MSGALERT("(EM DESENV). Preparando dados para envio...", "Aviso" )
  oDlgInfo:End()
  EndIf
  

Return lRet

Static Function fFiltra()

  Local aColsF := {}   
 
  FWMsgRun(, {|| aColsF := GetaCols() }, "Aguarde!", "Carregando informações...")   
  
  If Len(aColsF) > 0
      oBrw1:ACOLS := aColsF 
  else
      oBrw1:ACOLS := aColsDEF 
  EndIf
    
    oBrw1:Refresh()  

Return .T.


Static Function fFechar()
  
  If MsgYesNo("Tem certeza que deseja sair da função?","ATENÇÃO","YES NO")
    If .T.
         oDlg1:End()
    endif
  EndIf
  
Return .T.

Static function Legenda()

  Local aLegenda := {}

  AADD(aLegenda,{"BR_VERMELHO" 	 ,"   A = Não enviados" })         //A=Não Enviada'
  AADD(aLegenda,{"BR_AZUL"    	 ,"   P = Um Envio sem resposta" }) //P=1 Envio sem resposta'
  AADD(aLegenda,{"BR_AMARELO"    ,"   S = Dois Envio sem resposta" }) //S=2 Envios sem resposta'
  AADD(aLegenda,{"BR_VERDE"    	 ,"   R = Resposta enviada" })     //R= Resposta Enviada'
  BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil

Static function QueryZap(cFilialx, cDoc, cSerie)Ã


  Local aColsZap   := {}
  Local cQuery     := ""
  Local cObs       := ""
  Local cDate      := ""
  Local cStatus    := ""
  DEFAULT cFilialx := ""
  DEFAULT cDoc     := ""
  DEFAULT cSerie   := ""

  cQuery += "  SELECT  	                    			        " + CRLF
  cQuery += "     'SF2' AS ORIGEM,    				      " + CRLF
  cQuery += "     SF2.F2_FILIAL,            				      " + CRLF
  cQuery += "     SF2.F2_DOC,               				      " + CRLF
  cQuery += "     SF2.F2_SERIE,             				      " + CRLF
  cQuery += "     SF2.F2_YSTAZAP,           				      " + CRLF
  cQuery += "     SF2.F2_YNOMZAP,           				      " + CRLF
  cQuery += "     SF2.F2_TELZAP,            				      " + CRLF
  cQuery += "     SF2.F2_RESPZAP,           				      " + CRLF
  cQuery += "     SF2.F2_DTEVZAP,           				      " + CRLF
  
  cQuery += "     SF2.F2_IDZAP,           				      " + CRLF
  cQuery += "     FORMAT(CONVERT(datetime, SF2.F2_DTEVZAP, 121), 'dd/MM/yyyy HH:mm:ss', 'en-US' ) AS F2_DTEVZAP2   	" + CRLF
  cQuery += "  FROM   									                  " + CRLF
  cQuery += "     SF2010 SF2   							              " + CRLF
  cQuery += "     INNER JOIN  							              " + CRLF
  cQuery += "        SD2010 SD2   					              " + CRLF
  cQuery += "        ON SF2.F2_FILIAL = SD2.D2_FILIAL   	" + CRLF
  cQuery += "        AND SF2.F2_DOC = SD2.D2_DOC   		    " + CRLF
  cQuery += "        AND SF2.F2_SERIE = SD2.D2_SERIE      " + CRLF
  cQuery += "     INNER JOIN                              " + CRLF
  cQuery += "        SC5010 SC5                           " + CRLF
  cQuery += "        ON SC5.C5_FILIAL = SD2.D2_FILIAL     " + CRLF
  cQuery += "        AND SC5.C5_NUM = SD2.D2_PEDIDO       " + CRLF
  cQuery += "        AND SC5.D_E_L_E_T_ = ''              " + CRLF
  cQuery += "        AND SC5.C5_YCATEGO NOT IN ('4')      " + CRLF
  cQuery += "  WHERE                                      " + CRLF
  cQuery += "     SF2.D_E_L_E_T_ = ''                     " + CRLF
  cQuery += "     AND SF2.F2_SERIE IN ('RPS', '1')        " + CRLF
  
  If !EMPTY(cFilialx) .AND. !EMPTY(cDoc)
    cQuery += "     AND SF2.F2_FILIAL = "+ValToSql(cFilialx)+"  " + CRLF
    cQuery += "     AND SF2.F2_DOC = "+ValToSql(cDoc)+"        " + CRLF
    cQuery += "     AND SF2.F2_SERIE = "+ValToSql(cSerie)+"    " + CRLF
  Else
    cQuery += "     AND SF2.F2_YSTAZAP IN ('P','S')                " + CRLF // PARA O JOB
  EndIf

  cQuery += "  GROUP BY                                   " + CRLF
  cQuery += "     SF2.F2_FILIAL,                          " + CRLF
  cQuery += "     SF2.F2_DOC,                             " + CRLF
  cQuery += "     SF2.F2_SERIE,                           " + CRLF
  cQuery += "     SF2.F2_YSTAZAP,                         " + CRLF
  cQuery += "     SF2.F2_YNOMZAP,                         " + CRLF
  cQuery += "     SF2.F2_TELZAP,                          " + CRLF
  cQuery += "     SF2.F2_RESPZAP,                         " + CRLF
  cQuery += "     SF2.F2_DTEVZAP,                         " + CRLF  
  cQuery += "     SF2.F2_IDZAP,						                " + CRLF
  
  cQuery += "     ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), SC5.C5_YOBS)), '')    	  	" + CRLF
  cQuery += "  UNION ALL                 					        " + CRLF
  cQuery += "  SELECT                    					        " + CRLF
  cQuery += "     'SC5' AS ORIGEM, 					              " + CRLF
  cQuery += "     SC5B.C5_FILIAL,        					        " + CRLF
  cQuery += "     SC5B.C5_NUM,           					        " + CRLF
  cQuery += "     '' AS F2_SERIE,        					        " + CRLF
  cQuery += "     SC5B.C5_YSTAZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_YNOMZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_TELZAP,        					        " + CRLF
  cQuery += "     SC5B.C5_RESPZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_DTEVZAP,	   					          " + CRLF  
  cQuery += "     SC5B.C5_IDZAP,           				        " + CRLF
  cQuery += "     FORMAT(CONVERT(datetime, SC5B.C5_DTEVZAP, 121), 'dd/MM/yyyy HH:mm:ss', 'en-US' ) AS C5_DTEVZAP2   	" + CRLF  
  cQuery += "  FROM                                 		  " + CRLF
  cQuery += "     SC5010 SC5B                       		  " + CRLF
  cQuery += "  WHERE                                		  " + CRLF
  cQuery += "     SC5B.D_E_L_E_T_ = ''              		  " + CRLF
  cQuery += "     AND SC5B.C5_YCATEGO = '4'         		  " + CRLF
  cQuery += "     AND SC5B.C5_NOTA = ''             		  " + CRLF 

  If !EMPTY(cFilialx) .AND. !EMPTY(cDoc)
    cQuery += "     AND SC5B.C5_FILIAL = "+ValToSql(cFilialx)+"  " + CRLF
    cQuery += "     AND SC5B.C5_NUM = "+ValToSql(cDoc)+"        " + CRLF    
  Else
    cQuery += "     AND SC5B.C5_YSTAZAP IN ('P','S')                " + CRLF   //PARA O JOBS
  EndIf

  cQuery += "  GROUP BY                             		  " + CRLF
  cQuery += "     SC5B.C5_FILIAL,                   		  " + CRLF
  cQuery += "     SC5B.C5_NUM,                      		  " + CRLF
  cQuery += "     SC5B.C5_YSTAZAP,                  		  " + CRLF
  cQuery += "     SC5B.C5_YNOMZAP,                  		  " + CRLF
  cQuery += "     SC5B.C5_TELZAP,                   		  " + CRLF
  cQuery += "     SC5B.C5_RESPZAP,                  		  " + CRLF
  cQuery += "     SC5B.C5_DTEVZAP,				  		          " + CRLF
  cQuery += "     SC5B.C5_IDZAP,           				        " + CRLF
  cQuery += "  ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), SC5B.C5_YOBS)), '')   	" + CRLF

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  While ! __TRZ->(EoF())
    
    cObs := Posicione("SC5", 1, __TRZ->F2_FILIAL+__TRZ->F2_DOC, "C5_YOBS") 
    cDate := AllTrim(__TRZ->F2_DTEVZAP2)
    
    If cDate == "01/01/1900 00:00:00"
      cDate := ""
    EndIf

    If __TRZ->F2_YSTAZAP == "P"
      cStatus  := "P = Um envio sem resposta"
    ElseIf __TRZ->F2_YSTAZAP == "S" //S=2 Envio sem resposta
      cStatus  := "S = Dois envios sem resposta"
    ElseIf __TRZ->F2_YSTAZAP == "R" //R=Resposta enviada
      cStatus  := "R = Resposta enviada"
    Else
      cStatus  := "A = Não enviada"
    EndIf

    aAdd(aColsZap, {__TRZ->F2_FILIAL, __TRZ->F2_IDZAP,  cStatus, __TRZ->F2_YNOMZAP, __TRZ->F2_TELZAP,   AllTrim(cDate), __TRZ->F2_RESPZAP, cObs, __TRZ->F2_YSTAZAP, __TRZ->ORIGEM, __TRZ->F2_DOC, __TRZ->F2_SERIE })
    __TRZ->(DbSkip())
  EndDo
  __TRZ->(DbCloseArea()) 


  /*If EMPTY(cFilialx) .AND. EMPTY(cDoc) //JOBS - IRÁ CHAMAR A API PARA VINDA DO JOB
    //CHAMA API'S DO ZAP
    aColsZap := {}
     
EndIf*/
Return aColsZap


///// SERVICES //////

// POST
User Function WSWAPOST(cFilialx, cDoc, cSerie)

  Local cYIDQZAP  := SuperGetMV("MV_YIDQZAP",.F.,"") // ID DO CHAT DO ZAP
  Local cYTLOZAP  := SuperGetMV("MV_YTLOZAP",.F.,"") // TEL. DE ORIGEM DO ZAP
  Local cYLOGZAP  := SuperGetMV("MV_YLOGZAP",.F.,"") // LOGIN NO ZAP CODE AUTH
  Local cYPSWZAP  := SuperGetMV("MV_YPSWZAP",.F.,"") // PSW NO ZAP CODE AUTH
  Local aDados    := QueryZap(cFilialx, cDoc, cSerie)
  Local lRet      := .F.
  Local oJson     := JsonObject():New()
  Local oJBodyP   := Nil 

  oJson['quiz']   := "Token"
  oJson['customer_number']  := "5527999999999"
  oJBodyP  := JsonObject():New()
  oJBodyP['nome'] := "Luiz Soto"
  oJson['arguments']  := oJBodyP
  oJson:ToJson()

Return aColsZap


// GET  JOBS u_WSWAGET
User Function WSWAGET()

  Local lRet   := .T.
  Local aDados := {}  
  Local nW     := 0 

  RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"}) 
  
  aDados := QueryZap()

  If Len(aDados) > 0

    For nW := 1 To Len(aDados)

      If aDados[nW,10] == "SF2"

        dbSelectArea("SF2")
        SF2->(dbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
        If SF2->(dbSeek( aDados[nW,1] + aDados[nW,11] + aDados[nW,12] ))
          RecLock("SF2",.F.)    
            SF2->F2_YSTAZAP	:= "R"
          SF2->(MsUnLock())
        EndIf

      Else

        dbSelectArea("SC5")   
        SC5->(dbSetOrder(1)) //C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
        If SC5->(dbSeek( aDados[nW,1] + aDados[nW,11] ))
          RecLock("SC5",.F.)    
            SC5->C5_YSTAZAP	:= "R"
          SC5->(MsUnLock())
        EndIf

      EndIf

    Next nW

  EndIf

Return lRet



