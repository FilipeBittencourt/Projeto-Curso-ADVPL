#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#Include "TopConn.ch"

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
  Private aStatus := {'A=Não enviados','P=Um Envio sem resposta','S=Dois Envios sem resposta','R=Resposta enviada','N=Fechada sem resposta','T=Todos'}
  
  
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
  SetPrvt("oGet4","oGet5","oGet6","oGet7","oGet8","oGet9","oBtn1","oBtn2","oBtn3","oBtn4","oBtn5","oBrw1")


  /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  ±± Definicao do Dialog e todos os seus componentes.                        ±±
  Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
  oDlg1      := MSDialog():New( 092,232,685,1257,"Pesquisa de Satisfação",,,.F.,,,,,,.T.,,,.T. )
  oGrp1      := TGroup():New( 003,004,072,500,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
  oSay1      := TSay():New( 010,025,{||"Cliente De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay2      := TSay():New( 026,025,{||"Cliente Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay3      := TSay():New( 042,025,{||"Emissão De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay4      := TSay():New( 056,025,{||"Emissão Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)  
  oSay5      := TSay():New( 010,167,{||"Filial De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay6      := TSay():New( 026,167,{||"Filial Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay7      := TSay():New( 042,168,{||"Doc. De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oSay8      := TSay():New( 056,168,{||"Doc. Até:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)  
  oSay9      := TSay():New( 010,300,{||"Status:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
  oGet1      := TGet():New( 010,064,{|u| If(PCount()>0,cCliIni:=u,cCliIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cCliIni",,)
  oGet2      := TGet():New( 026,064,{|u| If(PCount()>0,cCliFinal:=u,cCliFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cCliFinal",,)  
  oGet3      := TGet():New( 041,065,{|u| If(PCount()>0,dEmisIni:=u,dEmisIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dEmisIni",,)
  oGet4      := TGet():New( 055,065,{|u| If(PCount()>0,dEmisFinal:=u,dEmisFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dEmisFinal",,)  
  oGet5      := TGet():New( 010,203,{|u| If(PCount()>0,cFilIni:=u,cFilIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"XM0","cFilIni",,)
  oGet6      := TGet():New( 026,203,{|u| If(PCount()>0,cFilFinal:=u,cFilFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"XM0","cFilFinal",,)  
  oGet7      := TGet():New( 041,204,{|u| If(PCount()>0,cDocIni:=u,cDocIni)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF2","cDocIni",,)
  oGet8      := TGet():New( 055,204,{|u| If(PCount()>0,cDocFinal:=u,cDocFinal)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF2","cDocFinal",,)
  oGet9      := TComboBox():New(010,325,{|u| if(PCount()>0,cStatus:=u,cStatus)},aStatus,080,010,oGrp1,,/*{||Alert(cStatus)}*/,,,,.T.,,,,,,,,,"cStatus")

  oBtn1      := TButton():New( 010,450,"Filtrar",oGrp1,{||fFiltra()},040,015,,,,.T.,,"",,,,.F. )
  oBtn2      := TButton():New( 030,450,"Sair",oGrp1,{||fFechar()},040,015,,,,.T.,,"",,,,.F. )
  oBtn3      := TButton():New( 050,450,"Legenda",oGrp1,{||Legenda()},040,015,,,,.T.,,"",,,,.F. )
  oBtn4      := TButton():New( 050,325,"Sincronizar Tudo",oGrp1,{|| fSincAll() },080,015,,,,.T.,,"",,,,.F. )

  oBtn5      := TButton():New( 030,325,"Exportar para excel",oGrp1,{|| ExpExcel() },080,015,,,,.T.,,"",,,,.F. )
  
  
         

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
  


cQuery += " UNION ALL  " + CRLF
  
cQuery += "  SELECT  TOP 100          " + CRLF  
cQuery += "  'SCJ' AS ORIGEM,           " + CRLF
cQuery += "  SCJ.CJ_FILIAL AS FILIAL,  " + CRLF
cQuery += "  SCJ.CJ_NUM AS DOC,        " + CRLF
cQuery += "  '' AS F2_SERIE,            " + CRLF
cQuery += "  (SA1.A1_COD+'/'+SA1.A1_LOJA+' - '+SA1.A1_NOME) AS A1_CLIENTE,  " + CRLF
cQuery += "  SCJ.CJ_EMISSAO AS EMISSAO,     " + CRLF
cQuery += "  SUBSTRING(SCJ.CJ_EMISSAO, 7, 2)+'/'+SUBSTRING(SCJ.CJ_EMISSAO, 5, 2)+'/'+SUBSTRING(SCJ.CJ_EMISSAO, 1, 4) AS CJ_EMISSAO2  ,      " + CRLF
cQuery += "  SUM(SCK.CK_VALOR) AS VALBRUT,	" + CRLF
cQuery += " 'Orcamento' AS CJ_YCATEGO, 	" + CRLF
cQuery += "  SCJ.CJ_YSTAZAP,   	" + CRLF
cQuery += " SA3.A3_COD+' - '+SA3.A3_NOME AS VENDENDOR  	" + CRLF

cQuery += " FROM " + RetSqlName("SCJ") + " SCJ              " + CRLF
cQuery += " INNER JOIN " + RetSqlName("SCK") + " SCK ON SCJ.CJ_FILIAL = SCK.CK_FILIAL AND SCJ.CJ_NUM = SCK.CK_NUM AND SCK.D_E_L_E_T_ = '' 		" + CRLF
cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SCJ.CJ_CLIENTE = SA1.A1_COD   AND SCJ.CJ_LOJA = SA1.A1_LOJA  AND SCJ.D_E_L_E_T_ = ''  " + CRLF
cQuery += " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.A3_COD = SCJ.CJ_YVEND1     AND SA3.D_E_L_E_T_ = '' " + CRLF
cQuery += " WHERE  SCJ.D_E_L_E_T_ = ''	  " + CRLF
 

  cQuery	+= "  AND SCJ.CJ_CLIENTE    BETWEEN " +ValToSql(cCliIni)+"  AND " +ValToSql(cCliFinal)+" " + CRLF
  cQuery	+= "  AND SCJ.CJ_EMISSAO    BETWEEN " +ValToSql(dEmisIni)+" AND " +ValToSql(dEmisFinal)+" " + CRLF  
  cQuery	+= "  AND SCJ.CJ_FILIAL     BETWEEN " +ValToSql(cFilIni)+" AND " +ValToSql(cFilFinal)+" " + CRLF
  cQuery	+= "  AND SCJ.CJ_NUM        BETWEEN " +ValToSql(cDocIni)+" AND " +ValToSql(cDocFinal)+" " + CRLF
  
  
 
  If cStatus == "A" //"1=Não Enviados"
    cQuery	+= "  AND (SCJ.CJ_YSTAZAP = " +ValToSql(cStatus)+" OR  SCJ.CJ_YSTAZAP = '' )  " + CRLF
  ENDIF

  If cStatus != "T" .AND.  cStatus != "A"
    cQuery	+= "  AND SCJ.CJ_YSTAZAP = " +ValToSql(cStatus)+" " + CRLF      
    //cQuery	+= "  AND SF2.F2_EMISSAO BETWEEN " +ValToSql(DTOS(DATE()))+" AND " +ValToSql(DTOS(DATE()))+" " + CRLF    
  EndIf

cQuery += " GROUP BY           " + CRLF
cQuery += " SCJ.CJ_FILIAL,     " + CRLF
cQuery += " SCJ.CJ_NUM,        " + CRLF
cQuery += " A1_NOME,           " + CRLF
cQuery += " A1_COD,            " + CRLF
cQuery += " SA1.A1_LOJA,       " + CRLF 
cQuery += " SCJ.CJ_EMISSAO,    " + CRLF
cQuery += " SCK.CK_PRCVEN,     " + CRLF
cQuery += " SCJ.CJ_YCATEGO,    " + CRLF
cQuery += " SA3.A3_COD,        " + CRLF
cQuery += " SCJ.CJ_YSTAZAP,  " + CRLF
cQuery += " SA3.A3_NOME,       " + CRLF
cQuery += " SCK.CK_NUM         " + CRLF


  cQuery	+= "  ORDER BY SF2.F2_EMISSAO DESC      " + CRLF

  If Select("__TRB") > 0
    __TRB->(dbCloseArea())
  EndIf

  
  

    TcQuery cQuery New Alias "__TRB"
    __TRB->(dbGoTop())

  If !EMPTY(__TRB->F2_FILIAL)

    While ! __TRB->(EoF())
        
      If AllTrim(__TRB->F2_YSTAZAP) == "P" //P=1 Envio sem resposta
          oCorLeg     := LoadBitmap( GetResources(), "BR_AZUL")      
      ElseIf AllTrim(__TRB->F2_YSTAZAP) == "S" //S=2 Envio sem resposta
          oCorLeg     := LoadBitmap( GetResources(), "BR_AMARELO")      
      ElseIf AllTrim(__TRB->F2_YSTAZAP) == "R" //R=Resposta enviada
          oCorLeg     := LoadBitmap( GetResources(), "BR_VERDE") 
      ElseIf AllTrim(__TRB->F2_YSTAZAP) == "N" //N=Fechada sem resposta
          oCorLeg     := LoadBitmap( GetResources(), "BR_PRETO")               
      Else
          oCorLeg     := LoadBitmap( GetResources(), "BR_VERMELHO")
      EndIf
    
        aAdd(aCols, {oCorLeg ,__TRB->F2_FILIAL,__TRB->C5_YCATEGO,__TRB->F2_DOC,__TRB->F2_SERIE,__TRB->A1_CLIENTE,__TRB->VENDENDOR,__TRB->F2_EMISSAO2,__TRB->F2_VALBRUT,.F.})  

        __TRB->(DbSkip())
    EndDo
      __TRB->(DbCloseArea()) 

  else
    
    /*
    If cAlertIN == .T.
        MSGALERT("Dados não encontrados, por favor refaça os filtros.", "Aviso" )         
    EndIf
    cAlertIN := .T. // para não alertar que nao existe dados ao iniciar a tela
    */

  EndIf



RETURN aCols

Static Function DbClick(nNumPos)

  Local oDlgInfo := Nil
  Local cNomeCli := SPACE(50)
  Local cYTELZAP := SPACE(19)
  Local cFilialx := ""
  Local cDoc     := ""
  Local cSerie   := ""
  Local aCols    := {}
  Local cCodUser :=  RetCodUsr()
  Local cNomUser :=  UsrRetName(cCodUser)
  Local cUsers   :=  SuperGetMv("MV_YUPQSAT",.F.,"") // usuarios que podem excluir pesquisa
  Local cDocSer  := ""

  If  Len(oBrw1:Acols) > 0 .AND. !Empty(oBrw1:Acols[1,2])

    cFilialx := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Filial"})]
    cDoc     := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Documento"})]
    cSerie   := oBrw1:Acols[nNumPos][aScan(aHeader, {|x| AllTrim(x[2]) == "Serie"})]
    aCols := QueryZap(cFilialx,cDoc, cSerie)

    cNomeCli   := aCols[1,4] /*YNOMZAP*/
    cYTELZAP   := aCols[1,5] /*YTELZAP*/
    cDocSer    := AllTrim(aCols[1,11]) //Doc

    If !Empty(aCols[1,12])
      cDocSer += "/"+AllTrim(aCols[1,12]) //serie
    EndIf

    oDlgInfo := MSDialog():New( 100,232,485,650,"Informativo para o DOC.: "+Space(10)+cDocSer+"",,,.F.,,,,,,.T.,,,.T. )

    TSay():New( 010,015,{||"ID:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 008,050,{|u| aCols[1,2]/*F2_YIDZAP*/},oDlgInfo,0120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 025,015,{||"STATUS:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 023,050,{|u| aCols[1,3]/*F2_YSTAZAP*/},oDlgInfo,0120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 040,015,{||"NOME:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 038,050,{|u|  If(PCount()>0,cNomeCli:=u,cNomeCli)  /*F2_YNOMZAP*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNomeCli",,)

    TSay():New( 055,015,{||"TELEFONE:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 053,050,{|u| If(PCount()>0,cYTELZAP:=u,cYTELZAP)/*F2_YTELZAP*/ },oDlgInfo,120,008,'@R (99) 99999-9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cYTELZAP",,)

    TSay():New( 070,015,{||"DT. ENVIO:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 068,050,{|u| aCols[1,6]/*F2_YDTEZAP2*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 085,015,{||"RESPOSTA:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TGet():New( 083,050,{|u| aCols[1,7]/*F2_YRSPZAP*/ },oDlgInfo,120,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

    TSay():New( 0100,015,{||"OBS PV:"},oDlgInfo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,0120,008)
    TMultiget():new( 098, 050, {| u | aCols[1,8]/*C5_YOBS*/ }, oDlgInfo, 0120,050, , , , , , .T., , , , , , .T. )

    If aCols[1,9] $ "P/S/R/N" .AND. Lower(cNomUser) $ Lower(cUsers)  /* YSTAZAP */
      TButton():New( 160,050,"Exlcuir pesquisa",oDlgInfo,{|| fCancela(cFilialx,cDoc, cSerie, aCols[1,2]/* YIDZAP */, aCols[1,10]/*ROTIGEM*/, cNomeCli, cYTELZAP, oDlgInfo) },050,015,,,,.T.,,"",,,,.F. )
    EndIf

    If aCols[1,9] $ "P"   /* YSTAZAP */
      TButton():New( 160,130,"Reenviar Pesq.",oDlgInfo,{||EnvPesq("S", cFilialx,cDoc, cSerie, aCols[1,2]/* YIDZAP */, aCols[1,10]/*ROTIGEM*/, cNomeCli,cYTELZAP, oDlgInfo)},040,015,,,,.T.,,"",,,,.F. )
    EndIf

    If aCols[1,9] $ "A" .OR. EMPTY(aCols[1,9]) /* YSTAZAP */
      TButton():New( 160,130,"Enviar Pesq.",oDlgInfo,{||EnvPesq("N", cFilialx,cDoc, cSerie, aCols[1,2]/* YIDZAP */, aCols[1,10]/*ROTIGEM*/, cNomeCli,cYTELZAP, oDlgInfo)},040,015,,,,.T.,,"",,,,.F. )
    EndIf

    oDlgInfo:Activate(,,,.T.)

  EndIf


Return

Static Function EnvPesq(cReenvio, cFilialx,cDoc, cSerie, cYIDZAP , cORIGEM, cNomeCli, cYTELZAP, oDlgInfo)

  Local lRet    := .T.
  Local cNewTel := cYTELZAP

  if EMPTY(cNomeCli)
    ALERT("O campo nome precisa ser preenchido.")
    lRet := .F.
  Else
    cYTELZAP := StrTran( cYTELZAP, "(", "")
    cYTELZAP := StrTran( cYTELZAP, ")", "")
    cYTELZAP := StrTran( cYTELZAP, "-", "")
    cNewTel := StrTran( cYTELZAP, " ", "")
    if Len(cNewTel)  < 11 .OR. EMPTY(cNewTel)
      ALERT("O campo Telefone precisa ser preenchido.")
      lRet := .F.
    EndIf
  EndIf

  If lRet
    cNewTel := cNewTel
    If (cReenvio == "N")
      FWMsgRun(, {||  WSWAPOST(cFilialx,cDoc, cSerie, cORIGEM, cNomeCli, cNewTel) }, "Aguarde!", "Preparando dados para envio da pesquisa.")
    Else
      FWMsgRun(, {||  WSWAPUT(cFilialx,cDoc, cSerie, cYIDZAP, cORIGEM, cNomeCli, cNewTel) }, "Aguarde!", "Preparando dados para reenvio da pesquisa.")
    EndIf
    oDlgInfo:End()
  EndIf
  fFiltra()

Return lRet

Static Function fSincAll()

  FWMsgRun(, {||  U_WSWAGET() }, "Aguarde!", "Sincronizando..."  + CRLF + CRLF)
  fFiltra()
  FwAlertSuccess(" Sincronizado! ")

Return .T.

Static Function fCancela(cFilialx,cDoc, cSerie, cYIDZAP , cORIGEM, cNomeCli, cYTELZAP, oDlgInfo)

  If MsgYesNo("Tem certeza que deseja DELETAR a pesquisa ?","ATENÇÃO","YES NO")
    If .T.
      FWMsgRun(, {|| WSDELL(cFilialx,cDoc, cSerie, cYIDZAP, cORIGEM, cNomeCli, cYTELZAP,"") }, "Aguarde!", "Verificando resposta antes do reenvio.")
      oDlgInfo:End()
    endif
  EndIf
  fFiltra()

Return .T.


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
  AADD(aLegenda,{"BR_AZUL"    	 ,"   P = Um envio sem resposta" }) //P=1 Envio sem resposta'
  AADD(aLegenda,{"BR_AMARELO"    ,"   S = Dois envios sem resposta" }) //S=2 Envios sem resposta'
  AADD(aLegenda,{"BR_VERDE"    	 ,"   R = Resposta enviada" })     //R= Resposta Enviada'
  AADD(aLegenda,{"BR_PRETO"    	 ,"   N = Fechada sem resposta" })     //R= Fechada sem resposta

  BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil

Static function QueryZap(cFilialx, cDoc, cSerie)


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
  cQuery += "     SF2.F2_YTELZAP,            				      " + CRLF
  cQuery += "     SF2.F2_YRSPZAP,           				      " + CRLF
  cQuery += "     SF2.F2_YDTEZAP,           				      " + CRLF
  cQuery += "     SF2.F2_YIDZAP,           				      " + CRLF
  cQuery += "     FORMAT(CONVERT(datetime, SF2.F2_YDTEZAP, 121), 'dd/MM/yyyy HH:mm:ss', 'en-US' ) AS F2_YDTEZAP2   	" + CRLF
  cQuery += " FROM " + RetSqlName("SF2") + "  SF2    " + CRLF
  cQuery += "     INNER JOIN  							              " + CRLF
  cQuery += "        " + RetSqlName("SD2") + " SD2        " + CRLF
  cQuery += "        ON SF2.F2_FILIAL = SD2.D2_FILIAL   	" + CRLF
  cQuery += "        AND SF2.F2_DOC = SD2.D2_DOC   		    " + CRLF
  cQuery += "        AND SF2.F2_SERIE = SD2.D2_SERIE      " + CRLF
  cQuery += "     INNER JOIN                              " + CRLF
  cQuery += "        " + RetSqlName("SC5") + " SC5        " + CRLF
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
  cQuery += "     SF2.F2_YTELZAP,                          " + CRLF
  cQuery += "     SF2.F2_YRSPZAP,                         " + CRLF
  cQuery += "     SF2.F2_YDTEZAP,                         " + CRLF
  cQuery += "     SF2.F2_YIDZAP,						                " + CRLF
  cQuery += "     SF2.F2_YIDZAP						                " + CRLF

  cQuery += "  UNION ALL                 					        " + CRLF

  cQuery += "  SELECT                    					        " + CRLF
  cQuery += "     'SC5' AS ORIGEM, 					              " + CRLF
  cQuery += "     SC5B.C5_FILIAL,        					        " + CRLF
  cQuery += "     SC5B.C5_NUM,           					        " + CRLF
  cQuery += "     '' AS F2_SERIE,        					        " + CRLF
  cQuery += "     SC5B.C5_YSTAZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_YNOMZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_YTELZAP,        					        " + CRLF
  cQuery += "     SC5B.C5_YRSPZAP,       					        " + CRLF
  cQuery += "     SC5B.C5_YDTEZAP,	   					          " + CRLF
  cQuery += "     SC5B.C5_YIDZAP,           				        " + CRLF
  cQuery += "     FORMAT(CONVERT(datetime, SC5B.C5_YDTEZAP, 121), 'dd/MM/yyyy HH:mm:ss', 'en-US' ) AS C5_YDTEZAP2   	" + CRLF
  cQuery += "  FROM                                 		  " + CRLF
  cQuery += "     " + RetSqlName("SC5") + " SC5B     		  " + CRLF
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
  cQuery += "     SC5B.C5_YTELZAP,                   		  " + CRLF
  cQuery += "     SC5B.C5_YRSPZAP,                  		  " + CRLF
  cQuery += "     SC5B.C5_YDTEZAP,				  		          " + CRLF
  cQuery += "     SC5B.C5_YIDZAP,           				        " + CRLF
  cQuery += "     SC5B.C5_YDTEZAP           				        " + CRLF


  cQuery += "  UNION ALL                 					        " + CRLF

  cQuery += "  SELECT                    					        " + CRLF
  cQuery += "     'SCJ' AS ORIGEM, 					              " + CRLF
  cQuery += "     SCJ.CJ_FILIAL,        					        " + CRLF
  cQuery += "     SCJ.CJ_NUM,           					        " + CRLF
  cQuery += "     '' AS F2_SERIE,        					        " + CRLF
  cQuery += "     SCJ.CJ_YSTAZAP,       					        " + CRLF
  cQuery += "     SCJ.CJ_YNOMZAP,       					        " + CRLF
  cQuery += "     SCJ.CJ_YTELZAP,        					        " + CRLF
  cQuery += "     SCJ.CJ_YRSPZAP,       					        " + CRLF
  cQuery += "     SCJ.CJ_YDTEZAP,	   					          " + CRLF
  cQuery += "     SCJ.CJ_YIDZAP,           				        " + CRLF
  cQuery += "      FORMAT(CONVERT(datetime, SCJ.CJ_EMISSAO, 121), 'dd/MM/yyyy HH:mm:ss', 'en-US' ) AS F2_YDTEZAP2   	" + CRLF
  cQuery += "  FROM                                 		  " + CRLF
  cQuery += "     " + RetSqlName("SCJ") + " SCJ     		  " + CRLF
  cQuery += "  WHERE                                		  " + CRLF
  cQuery += "     SCJ.D_E_L_E_T_ = ''              		  " + CRLF

  If !EMPTY(cFilialx) .AND. !EMPTY(cDoc)
    cQuery += "     AND SCJ.CJ_FILIAL = "+ValToSql(cFilialx)+"  " + CRLF
    cQuery += "     AND SCJ.CJ_NUM = "+ValToSql(cDoc)+"        " + CRLF
  Else
    cQuery += "     AND SCJ.CJ_YSTAZAP IN ('P','S')                " + CRLF   //PARA O JOBS
  EndIf

  cQuery += "  GROUP BY                             		  " + CRLF
  cQuery += "     SCJ.CJ_FILIAL,                   		  " + CRLF
  cQuery += "     SCJ.CJ_NUM,                      		  " + CRLF
  cQuery += "     SCJ.CJ_YSTAZAP,                  		  " + CRLF
  cQuery += "     SCJ.CJ_YNOMZAP,                  		  " + CRLF
  cQuery += "     SCJ.CJ_YTELZAP,                   		  " + CRLF
  cQuery += "     SCJ.CJ_YRSPZAP,                  		  " + CRLF
  cQuery += "     SCJ.CJ_YDTEZAP,				  		          " + CRLF
  cQuery += "     SCJ.CJ_YIDZAP,           				        " + CRLF
  cQuery += "     SCJ.CJ_EMISSAO           				        " + CRLF




  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  While ! __TRZ->(EoF())

    cObs := ""

    If __TRZ->ORIGEM == "SC5"
      cObs := Posicione("SC5", 1, __TRZ->F2_FILIAL+__TRZ->F2_DOC, "C5_YOBS")
    EndIf

    cDate := AllTrim(__TRZ->F2_YDTEZAP2)

    If cDate == "01/01/1900 00:00:00"
      cDate := ""
    EndIf

    If __TRZ->F2_YSTAZAP == "P"
      cStatus  := "P = Um envio sem resposta"
    ElseIf __TRZ->F2_YSTAZAP == "S" //S=2 Envio sem resposta
      cStatus  := "S = Dois envios sem resposta"
    ElseIf __TRZ->F2_YSTAZAP == "R" //R=Resposta enviada
      cStatus  := "R = Resposta enviada"
    ElseIf __TRZ->F2_YSTAZAP == "N" //N=Fechada sem resposta
      cStatus  := "N = Fechada sem resposta"
    Else
      cStatus  := "A = Não enviada"
    EndIf

    //                        1               2              3            4                  5                 6                  7          8             9                10            11              12              13                   14
    aAdd(aColsZap, {__TRZ->F2_FILIAL, __TRZ->F2_YIDZAP,  cStatus, __TRZ->F2_YNOMZAP, __TRZ->F2_YTELZAP,   AllTrim(cDate), __TRZ->F2_YRSPZAP, cObs, __TRZ->F2_YSTAZAP, __TRZ->ORIGEM, __TRZ->F2_DOC, __TRZ->F2_SERIE, __TRZ->F2_YNOMZAP, __TRZ->F2_YTELZAP })
    __TRZ->(DbSkip())
  EndDo
  __TRZ->(DbCloseArea())


Return aColsZap


///// SERVICES //////

// POST  LOGIN
Static Function PLOGIN()

  Local aHeader   := {"Content-Type: application/json"}
  Local cHostWS	  := ""
  Local cLogin	  := ""
  Local cPass	    := ""
  Local oJson     := JsonObject():New()
  Local oSession  := Nil
  Local cStringJS := ""
  Local oRest     := Nil
  Local cMsg      := ""

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  cHostWS	  := SuperGetMV("MV_YCAHWS",.F.,"") // HOST DO SERVICO DE MSG VIA WHATSAPP
  cLogin	  := SuperGetMV("MV_YCALOG",.F.,"") // EMAIL DO USER QUE IRA CONSUMIR O SERVIÇO DE MSG VIA WHATSAAP
  cPass	    := SuperGetMV("MV_YCAPSW",.F.,"")	// SENHA DO USER QUE IRA CONSUMIR O SERVIÇO DE MSG VIA WHATSAAP

  oRest     := FWRest():New(cHostWS)
  oJson['email']       := AllTrim(cLogin)
  oJson['password']    := AllTrim(cPass)
  oJson['branch_key']  := SM0->M0_CGC

  oRest:setPath("/sessions")
  oRest:SetPostParams(oJson:ToJson())

  If oRest:Post(aHeader ) .OR. !Empty( oRest:GetResult() )
    If (oRest:ORESPONSEH:CSTATUSCODE == "200")
      cStringJS :=  oRest:GetResult()
      FWJsonDeserialize(cStringJS, @oSession)
      Aadd(aHeader,"Authorization:bearer "+oSession:token:token+"")
    else
      cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
      cMsg += "<b>Detalhes</b>: "+oRest:GetResult()+" "  + CRLF + CRLF
      Alert(cMsg)
    EndIf
  Else
    conout(oRest:GetLastError())
    cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
    cMsg += "<b>Detalhes</b>: "+oRest:GetLastError()+" "  + CRLF + CRLF
    Alert(cMsg)
  Endif

Return aHeader


// POST
Static Function WSWAPOST(cFilialx,cDoc, cSerie, cORIGEM, cNomeCli, cTelCli)


  Local aHeader   := {}
  Local aDados    := {}
  Local cYTLOZAP  := ""
  Local oJson     := JsonObject():New()
  Local oJBodyP   := Nil
  Local oRest     := Nil
  Local cHostWS	  := ""
  Local cMsg      := ""
  Local oResult   := Nil

  aDados := FindPesq(cFILIALx, cDOC, cSERIE,  cNomeCli, cTelCli)
  If Len(aDados) > 0 .AND. (ALLTRIM(aDados[1,3])+ALLTRIM(aDados[1,4]) != ALLTRIM(cDOC)+ALLTRIM(cSERIE))

    cMsg := "O cliente com número: <b>"+cValToChar(cTelCli)+"</b> ."
    cMsg += "Possui uma pesquisa pelo doc <b>"+cValToChar(aDados[1,3])+" "+cValToChar(aDados[1,4])+"</b>. "
    cMsg += "sem resposta. <b>Caso prossiga, a mesma será fechada por falta de resposta.</b>" + CRLF + CRLF
    cMsg += "Deseja prosseguir ? "
    If MsgYesNo(cMsg,"ATENÇÃO","YES NO")
      WSDELL(cFilialx,aDados[1,3], aDados[1,4], aDados[1,5], aDados[1,1] , cNomeCli, cTelCli, "N")
    Else
      Return .F.
    EndIf
  EndIf

  aHeader  := PLOGIN()
  If Len(aHeader) > 0

    cHostWS	  := SuperGetMV("MV_YCAHWS",.F.,"") // HOST DO SERVICO DE MSG VIA WHATSAPP
    cYIDQZAP  := SuperGetMV("MV_YIDQ001",.F.,"") // ID DO QUIZ QUE É O ID DA PERGUNTA DO CHAT DO WHATSAAP
    cYTLOZAP  := SuperGetMV("MV_YTLO001",.F.,"") // TEL. DE ORIGEM DO ENVIO PARA O WHATSAAP


    AADD(aHeader,"Branch-Number:"+AllTrim(cYTLOZAP)+"")
    oRest                     := FWRest():New(AllTrim(cHostWS))
    oJson['quiz_id_ref']      := cYIDQZAP
    oJson['customer_number']  := "55"+AllTrim(cTelCli)
    oJBodyP                   := JsonObject():New()
    oJBodyP['nome']           := AllTrim(cNomeCli)
    oJBodyP['nota']           := AllTrim(cDoc)+"/"+AllTrim(cSerie)

    If Empty(cSerie)
      oJBodyP['nota']         := AllTrim(cDoc)
    EndIf

    oJson['arguments']        := oJBodyP
    oRest:setPath("/chats")
    oRest:SetPostParams(oJson:ToJson())


    If oRest:Post(aHeader ) .OR. !Empty( oRest:GetResult() )
      If (oRest:ORESPONSEH:CSTATUSCODE == "200")
        FWJsonDeserialize(oRest:GetResult(), @oResult)
        If cOrigem == "SF2"
          //cF2FILIAL, cF2DOC, cF2SERIE, cRESP, cYIDZAP,    cStatus, cNomeCli,  cTelCli
          UpdtSF2(cFilialx,   cDoc,   cSerie,   "",   oResult:_id, "P", cNomeCli, cTelCli)
        ElseIf cOrigem == "SC5"
          //cF2FILIAL, cF2DOC, cRESP  , cYIDZAP,    cStatus, cNomeCli,  cTelCli
          UpdtSC5(cFilialx , cDoc    , ""    , oResult:_id, "P"  , cNomeCli, cTelCli)
        Else
          //cF2FILIAL, cF2DOC, cRESP  , cYIDZAP,    cStatus, cNomeCli,  cTelCli
          UpdtSCJ(cFilialx , cDoc    , ""    , oResult:_id, "P"  , cNomeCli, cTelCli)
        EndIf

        oBrw1:ACOLS  := GetaCols()
        oBrw1:Refresh()

      else
        FWJsonDeserialize(oRest:GetResult(), @oResult)
        cMsg := " Ops! "+AllTrim(DecodeUTF8(oResult:message, "WINDOWS-1252"))+" "  + CRLF + CRLF
        FwAlertWarning(cMsg , "Atenção")
      EndIf
    Else
      FWJsonDeserialize(oRest:GetResult(), @oResult)
      conout(oResult)
      cMsg := " Ops! "+oResult+" "  + CRLF + CRLF
      FwAlertWarning(cMsg , "Atenção")
    Endif

  EndIf

Return .T.

// REEENVIO PUT  
Static Function WSWAPUT(cFilialx,cDoc, cSerie, cYIDZAP , cORIGEM, cNomeCli, cTelCli)


  Local aHeader  := {}
  Local aDados  := {}
  Local cYTLOZAP  := ""
  Local oJson     := JsonObject():New()
  Local oJBodyP   := Nil
  Local oRest     := Nil
  Local cHostWS	  := ""
  Local cMsg      := ""
  Local oResult   := Nil

  aDados := FindPesq(cFILIALx, cDOC, cSERIE,  cNomeCli, cTelCli)
  If Len(aDados) > 0 .AND. (ALLTRIM(aDados[1,3])+ALLTRIM(aDados[1,4]) != ALLTRIM(cDOC)+ALLTRIM(cSERIE))

    cMsg := "O cliente com número: <b>"+cValToChar(cTelCli)+"</b> ."
    cMsg += "Possui uma pesquisa pelo doc <b>"+cValToChar(aDados[1,3])+" "+cValToChar(aDados[1,4])+"</b>. "
    cMsg += "sem resposta. <b>Caso prossiga, a mesma será fechada por falta de resposta.</b>" + CRLF + CRLF
    cMsg += "Deseja prosseguir ? "
    If MsgYesNo(cMsg,"ATENÇÃO","YES NO")
      WSDELL(cFilialx,aDados[1,3], aDados[1,4], aDados[1,5], aDados[1,1] , cNomeCli, cTelCli,"N")
    Else
      Return .F.
    EndIf
  EndIf

  aHeader  := PLOGIN()

  If Len(aHeader) > 0

    cHostWS	  := SuperGetMV("MV_YCAHWS",.F.,"") // HOST DO SERVICO DE MSG VIA WHATSAPP
    cYIDQZAP  := SuperGetMV("MV_YIDQ001",.F.,"") // ID DO QUIZ QUE É O ID DA PERGUNTA DO CHAT DO WHATSAAP
    cYTLOZAP  := SuperGetMV("MV_YTLO001",.F.,"") // TEL. DE ORIGEM DO ENVIO PARA O WHATSAAP


    AADD(aHeader,"Branch-Number:"+AllTrim(cYTLOZAP)+"")
    oRest                     := FWRest():New(AllTrim(cHostWS))
    oJson['quiz_id_ref']      := AllTrim(cYIDQZAP)
    oJson['customer_number']  := "55"+AllTrim(cTelCli)
    oJBodyP                   := JsonObject():New()
    oJBodyP['nome']           := AllTrim(cNomeCli)
    oJBodyP['nota']           := AllTrim(cDoc)+"/"+AllTrim(cSerie)

    If Empty(cSerie)
      oJBodyP['nota']         := AllTrim(cDoc)
    EndIf

    oJson['arguments']        := oJBodyP


    oRest:setPath("/chats/"+cYIDZAP+"")
    If oRest:Put(aHeader, oJson:ToJson() ) .OR. !Empty( oRest:GetResult() )
      If (oRest:ORESPONSEH:CSTATUSCODE == "200")
        cStringJS :=  oRest:GetResult()
        FWJsonDeserialize(cStringJS, @oResult)
        If oResult:is_open == .T.

          If cOrigem == "SF2"
            //cF2FILIAL, cF2DOC, cF2SERIE, cRESP, cYIDZAP,    cStatus, cNomeCli,  cTelCli
            UpdtSF2(cFilialx,   cDoc,   cSerie,   "",   oResult:_id, "S", cNomeCli, cTelCli)
          ElseIf cOrigem == "SC5"
            //cF2FILIAL, cF2DOC, cRESP  , cYIDZAP,    cStatus, cNomeCli,  cTelCli
            UpdtSC5(cFilialx , cDoc    , ""    , oResult:_id, "S"  , cNomeCli, cTelCli)
          Else
            //cF2FILIAL, cF2DOC, cRESP  , cYIDZAP,    cStatus, cNomeCli,  cTelCli
            UpdtSCJ(cFilialx , cDoc    , ""    , oResult:_id, "S"  , cNomeCli, cTelCli)
          EndIf

          oBrw1:ACOLS  := GetaCols()
          oBrw1:Refresh()

        EndIf
      else

        FWJsonDeserialize(oRest:GetResult(), @oResult)
        // cMsg := " Ops! "+AllTrim(DecodeUTF8(oResult:message, "WINDOWS-1252"))+" "  + CRLF + CRLF
        cMsg := " Por favor, clique no botão 'Sincronizar Todos' para atualizar os status. "
        FwAlertWarning(cMsg , "Atenção")
      EndIf
    Else
      FWJsonDeserialize(oRest:GetResult(), @oResult)
      conout(oResult)
      cMsg := " Ops! "+oResult+" "  + CRLF + CRLF
      FwAlertWarning(cMsg , "Atenção")
    Endif

  EndIf



Return .T.

// DELETE / Cancelar 
Static Function WSDELL(cFilialx,cDoc, cSerie, cIdResZp,cOrigem , cNomeCli, cTelCli,cYSTATUS)

  Local aHeader   := PLOGIN()
  Local cMsg      := ""
  Local lRet      := .F.
  Local oRest     := Nil
  Local cHostWS   := ""
  Local cYTLOZAP  := ""
  Local oResult   := ""

  If Len(aHeader) > 0

    cHostWS	  := SuperGetMV("MV_YCAHWS",.F.,"") // HOST DO SERVICO DE MSG VIA WHATSAPP
    cYTLOZAP  := SuperGetMV("MV_YTLO001",.F.,"") // TEL. DE ORIGEM DO ENVIO PARA O WHATSAAP

    AADD(aHeader,"Branch-Number:"+AllTrim(cYTLOZAP)+"")
    oRest     := FWRest():New(AllTrim(cHostWS))
    oRest:setPath("/chats/"+AllTrim(cIdResZp)+"")
    If oRest:DELETE(aHeader) .or. oRest:LCHKSTATUSCODE



      If cOrigem == "SF2"

        dbSelectArea("SF2")
        SF2->(dbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
        If SF2->(dbSeek( cFilialx + cDoc + cSerie ))
          RecLock("SF2",.F.)
          SF2->F2_YIDZAP	:= ""
          SF2->F2_YSTAZAP	:= cYSTATUS
          SF2->F2_YDTEZAP	:= ""
          SF2->F2_YRSPZAP	:= ""
          SF2->F2_YNOMZAP	:= ""
          SF2->F2_YTELZAP	:= ""
          SF2->(MsUnLock())
        EndIf

      ElseIf cOrigem == "SC5"

        dbSelectArea("SC5")
        SC5->(dbSetOrder(1)) //C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
        If SC5->(dbSeek( cFilialx + cDoc))
          RecLock("SC5",.F.)
          SC5->C5_YIDZAP	:=  ""
          SC5->C5_YSTAZAP	:= cYSTATUS
          SC5->C5_YDTEZAP	:= ""
          SC5->C5_YRSPZAP	:= ""
          SC5->C5_YNOMZAP	:= ""
          SC5->C5_YTELZAP	:= ""
          SC5->(MsUnLock())
        EndIf

      Else

        dbSelectArea("SCJ")
        SCJ->(dbSetOrder(1)) //CJ_FILIAL, CJ_NUM, CJ_CLIENTE, CJ_LOJA, R_E_C_N_O_, D_E_L_E_T_
        If SCJ->(dbSeek( cFilialx + AllTrim(cDoc)))
          RecLock("SCJ",.F.)
          SCJ->CJ_YIDZAP	:= ""
          SCJ->CJ_YSTAZAP	:= cYSTATUS
          SCJ->CJ_YDTEZAP	:= ""
          SCJ->CJ_YRSPZAP	:= ""
          SCJ->CJ_YNOMZAP	:= ""
          SCJ->CJ_YTELZAP	:= ""
          SCJ->(MsUnLock())
        EndIf

      EndIf
    Else
      conout(oRest:GetLastError())
      cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
      cMsg += "<b>Detalhes</b>: "+oRest:GetLastError()+" "  + CRLF + CRLF
      Alert(cMsg)
    EndIf
  EndIf

Return lRet

// GET  JOBS u_WSWAGET
User Function WSWAGET()

  Local aHeader   := PLOGIN()
  Local aDados    := {}
  Local cYIDZAP    := ""
  Local cMsg      := ""
  Local oRest     := Nil
  Local cHostWS   := ""
  Local cStringJS := ""
  Local cYTLOZAP  := ""
  Local oResult   := ""
  Local nW        := 0
  Local nK        := 0
  Local nI        := 0



  If Len(aHeader) > 0

    aDados := QueryZap()

    If Len(aDados) > 0

      cHostWS	  := SuperGetMV("MV_YCAHWS",.F.,"") // HOST DO SERVICO DE MSG VIA WHATSAPP
      cYTLOZAP  := SuperGetMV("MV_YTLO001",.F.,"") // TEL. DE ORIGEM DO ENVIO PARA O WHATSAAP

      For nW := 1 To Len(aDados)
        cYIDZAP += AllTrim(cValToChar(aDados[nW,2]))+","
      Next nW

      cYIDZAP :=  SUBSTR(cYIDZAP, 0, (LEN(cYIDZAP)-1))
      AADD(aHeader,"Branch-Number:"+AllTrim(cYTLOZAP)+"")
      oRest     := FWRest():New(AllTrim(cHostWS))
      oRest:setPath("/chats?chat_ids="+cYIDZAP+"")
      If oRest:Get(aHeader) .OR. !Empty( oRest:GetResult() )
        If (oRest:ORESPONSEH:CSTATUSCODE == "200")
          cStringJS :=  oRest:GetResult()
          FWJsonDeserialize(cStringJS, @oResult)

          If Len(oResult) > 0

            For nW := 1 To Len(oResult)
              If Len(oResult[nW]:messages) > 1 .AND. oResult[nW]:is_open == .F.
                For nK := 1 To Len(oResult[nW]:messages)
                  For nI := 1 To Len(aDados)
                    If aDados[nI,10] == "SF2"
                      //cF2FILIAL,         cF2DOC,     cF2SERIE   ,                              cRESP                        , cYIDZAP      , cStatus, cNomeCli,         cTelCli
                      UpdtSF2(aDados[nI,1], aDados[nI,11], aDados[nI,12], oResult[nW]:messages[Len(oResult[nW]:messages)-1]:body, oResult[nW]:_id, "R", aDados[nI,13], aDados[nI,14])
                    ElseIf aDados[nI,10] == "SC5"
                      UpdtSC5(aDados[nI,1], aDados[nI,11], oResult[nW]:messages[Len(oResult[nW]:messages)-1]:body, oResult[nW]:_id, "R", aDados[nI,13], aDados[nI,14])
                    Else
                      UpdtSCJ(aDados[nI,1], aDados[nI,11], oResult[nW]:messages[Len(oResult[nW]:messages)-1]:body, oResult[nW]:_id, "R", aDados[nI,13], aDados[nI,14])
                    EndIf
                  Next nI
                Next nK
              EndIf
            Next nW
          EndIf

        else
          cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
          cMsg += "<b>Detalhes</b>: "+oRest:GetResult()+" "  + CRLF + CRLF
          Alert(cMsg)
        EndIf
      Else
        conout(oRest:GetLastError())
        cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
        cMsg += "<b>Detalhes</b>: "+oRest:GetLastError()+" "  + CRLF + CRLF
        Alert(cMsg)
      Endif

    EndIf

  EndIf

Return

Static Function UpdtSF2(cF2FILIAL, cF2DOC, cF2SERIE, cRESP, cYIDZAP, cStatus, cNomeCli, cTelCli )

  Local cDtHrZap := StrTran( FWTimeStamp(3,Date(), Time()), "T", " ") // aaaa-mm-dd hh:mm:ss

  dbSelectArea("SF2")
  SF2->(dbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
  If SF2->(dbSeek( cF2FILIAL + cF2DOC + cF2SERIE ))

    If Empty(SF2->F2_YIDZAP)  .OR. AllTrim(SF2->F2_YIDZAP) == AllTrim(cYIDZAP) .OR. cStatus == "S"
      RecLock("SF2",.F.)
      SF2->F2_YIDZAP	:= cYIDZAP
      SF2->F2_YSTAZAP	:= cStatus
      SF2->F2_YDTEZAP	:= cDtHrZap
      SF2->F2_YRSPZAP	:= cRESP
      SF2->F2_YNOMZAP	:= cNomeCli
      SF2->F2_YTELZAP	:= cTelCli
      SF2->(MsUnLock())
    EndIf
  EndIf

Return .T.

Static Function UpdtSC5(cC5FILIAL, cC5NUM, cRESP, cYIDZAP, cStatus, cNomeCli, cTelCli )

  Local cDtHrZap := StrTran( FWTimeStamp(3,Date(), Time()), "T", " ") // aaaa-mm-dd hh:mm:ss

  dbSelectArea("SC5")
  SC5->(dbSetOrder(1)) //C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
  If SC5->(dbSeek( cC5FILIAL + AllTrim(cC5NUM) ))

    If Empty(SC5->C5_YIDZAP) .OR. AllTrim(SC5->C5_YIDZAP) == AllTrim(cYIDZAP) .OR. cStatus == "S"
      RecLock("SC5",.F.)
      SC5->C5_YIDZAP	:= cYIDZAP
      SC5->C5_YSTAZAP	:= cStatus
      SC5->C5_YDTEZAP	:= cDtHrZap
      SC5->C5_YRSPZAP	:= cRESP
      SC5->C5_YNOMZAP	:= cNomeCli
      SC5->C5_YTELZAP	:= cTelCli
      SC5->(MsUnLock())
    EndIf

  EndIf

Return .T.


Static Function UpdtSCJ(cCJFILIAL, cCJNUM, cRESP, cYIDZAP, cStatus, cNomeCli, cTelCli )

  Local cDtHrZap := StrTran( FWTimeStamp(3,Date(), Time()), "T", " ") // aaaa-mm-dd hh:mm:ss

  dbSelectArea("SCJ")
  SCJ->(dbSetOrder(1)) //CJ_FILIAL, CJ_NUM, CJ_CLIENTE, CJ_LOJA, R_E_C_N_O_, D_E_L_E_T_
  If SCJ->(dbSeek( cCJFILIAL + AllTrim(cCJNUM) ))

    If Empty(SCJ->CJ_YIDZAP) .OR. AllTrim(SCJ->CJ_YIDZAP) == AllTrim(cYIDZAP) .OR. cStatus == "S"
      RecLock("SCJ",.F.)
      SCJ->CJ_YIDZAP	:= cYIDZAP
      SCJ->CJ_YSTAZAP	:= cStatus
      SCJ->CJ_YDTEZAP	:= cDtHrZap
      SCJ->CJ_YRSPZAP	:= cRESP
      SCJ->CJ_YNOMZAP	:= cNomeCli
      SCJ->CJ_YTELZAP	:= cTelCli
      SCJ->(MsUnLock())
    EndIf

  EndIf

Return .T.


Static Function FindPesq(cFILIALx, cDOC, cSERIE,  cNomeCli, cTelCli )

  Local cQuery := ""
  Local aDados := {}

  cQuery += " SELECT                              " + CRLF
  cQuery += " 'SF2' AS ORIGEM                     " + CRLF
  cQuery += " ,SF2.F2_FILIAL                          " + CRLF
  cQuery += " ,SF2.F2_DOC                             " + CRLF
  cQuery += " ,SF2.F2_SERIE AS SERIE                  " + CRLF
  cQuery += " ,SF2.F2_YIDZAP                           " + CRLF
  cQuery += " ,SF2.F2_YSTAZAP                         " + CRLF
  cQuery += " ,SF2.F2_YDTEZAP                         " + CRLF
  cQuery += " ,SF2.F2_YRSPZAP                         " + CRLF
  cQuery += " ,SF2.F2_YNOMZAP                         " + CRLF
  cQuery += " ,SF2.F2_YTELZAP                          " + CRLF

  cQuery += " FROM " + RetSqlName("SF2") + " SF2  " + CRLF
  cQuery += " WHERE SF2.F2_FILIAL = "+ValToSql(cFILIALx)+"        " + CRLF
  cQuery += " AND SF2.F2_YTELZAP = "+ValToSql(cTelCli)+"        " + CRLF
  cQuery += " AND SF2.F2_YSTAZAP not in('R','N')               " + CRLF
  cQuery += " AND SF2.D_E_L_E_T_ = ''                 " + CRLF

  cQuery += " UNION ALL		                      " + CRLF

  cQuery += " SELECT                              " + CRLF
  cQuery += " 'SC5' AS ORIGEM                     " + CRLF
  cQuery += " ,SC5B.C5_FILIAL                          " + CRLF
  cQuery += " ,SC5B.C5_NUM                             " + CRLF
  cQuery += " ,'' AS SERIE                        " + CRLF
  cQuery += " ,SC5B.C5_YIDZAP                           " + CRLF
  cQuery += " ,SC5B.C5_YSTAZAP                         " + CRLF
  cQuery += " ,SC5B.C5_YDTEZAP                         " + CRLF
  cQuery += " ,SC5B.C5_YRSPZAP                         " + CRLF
  cQuery += " ,SC5B.C5_YNOMZAP                         " + CRLF
  cQuery += " ,SC5B.C5_YTELZAP                          " + CRLF

  cQuery += " FROM " + RetSqlName("SC5") + " SC5B  "   + CRLF

  cQuery += " WHERE SC5B.C5_FILIAL = "+ValToSql(cFILIALx)+"        " + CRLF
  cQuery += " AND SC5B.C5_YTELZAP = "+ValToSql(cTelCli)+"        " + CRLF
  cQuery += " AND SC5B.C5_YSTAZAP not in('R','N')	              " + CRLF
  cQuery += " AND SC5B.D_E_L_E_T_ = ''                 " + CRLF


  cQuery += " UNION ALL		                      " + CRLF

  cQuery += " SELECT                              " + CRLF
  cQuery += " 'SCJ' AS ORIGEM                     " + CRLF
  cQuery += " ,SCJ.CJ_FILIAL                          " + CRLF
  cQuery += " ,SCJ.CJ_NUM                             " + CRLF
  cQuery += " ,'' AS SERIE                        " + CRLF
  cQuery += " ,SCJ.CJ_YIDZAP                           " + CRLF
  cQuery += " ,SCJ.CJ_YSTAZAP                         " + CRLF
  cQuery += " ,SCJ.CJ_YDTEZAP                         " + CRLF
  cQuery += " ,SCJ.CJ_YRSPZAP                         " + CRLF
  cQuery += " ,SCJ.CJ_YNOMZAP                         " + CRLF
  cQuery += " ,SCJ.CJ_YTELZAP                          " + CRLF

  cQuery += " FROM " + RetSqlName("SCJ") + " SCJ  "   + CRLF

  cQuery += " WHERE SCJ.CJ_FILIAL = "+ValToSql(cFILIALx)+"        " + CRLF
  cQuery += " AND SCJ.CJ_YTELZAP = "+ValToSql(cTelCli)+"        " + CRLF
  cQuery += " AND SCJ.CJ_YSTAZAP not in('R','N')	              " + CRLF
  cQuery += " AND SCJ.D_E_L_E_T_ = ''                 " + CRLF



  TcQuery cQuery New Alias "__TRW"
  __TRW->(dbGoTop())

  While ! __TRW->(EoF())
    aAdd(aDados, {__TRW->ORIGEM, __TRW->F2_FILIAL, __TRW->F2_DOC, __TRW->SERIE, __TRW->F2_YIDZAP})
    __TRW->(DbSkip())
  EndDo
  __TRW->(DbCloseArea())

Return aDados


Static Function ExpExcel()

  Local   aCab    := aHeader // aHeader é private
  Local   alinha  := GetaCols()
  Local   nI      := 1

  If alinha != Nil
    If Len(alinha) > 0

      For nI := 1 To Len(alinha)

        If alinha[nI][1]:CNAME == "BR_VERMELHO"
          alinha[nI][1]  := "Não enviados"
        ElseIf alinha[nI][1]:CNAME == "BR_AZUL"
          alinha[nI][1]  := "Um envio sem resposta"
        ElseIf alinha[nI][1]:CNAME == "BR_AMARELO"
          alinha[nI][1]  := "Dois envios sem resposta"
        ElseIf alinha[nI][1]:CNAME == "BR_VERDE"
          alinha[nI][1]  := "Resposta enviada"
        Else
          alinha[nI][1]  := "Fechada sem resposta"
        EndIf

      Next nI

      MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
        {||DlgToExcel({{"GETDADOS",;
        "Pesquisa de satisfação",;
        aCab,alinha}})})
    Else
      FwAlertWarning('Não há dados para ser exportado0','Warning')
    EndIf
  EndIf


Return .T.
