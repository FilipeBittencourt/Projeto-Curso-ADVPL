#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia010()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("ARETURN,NOMEPROG,ALINHA,TITULO,NLASTKEY,CPERG")
SetPrvt("WNREL,WNUMBER,WTOTGCX,WTOTGM2,WTOTGPT,WPRAZO")
SetPrvt("CABEC1,CABEC2,C15,CBTXT,CBCONT,LI")
SetPrvt("WCOLUNA,M_PAG,_ACAMPOS,_CTRAB,WPROD,WCODVEND")
SetPrvt("WVENDEDOR,WPRODUTO,WPRECO,WTOT2UM,WTOT1UM,WTOTPRECO")
SetPrvt("WMEDPRAZO,WSOMAPRAZO,WQTDEPRAZO,WPRECOMED,WSOMPREMED,WQTPREMED")
SetPrvt("WTOTVD1UM,WTOTVD2UM,WTOTVDPRV,WSOMPRETOT,WQTPRETOT,WPREMEDTOT")
SetPrvt("WMEDPRZVEND,WSOMPRZVEND,WQTDPRZVEND,WMEDPRZTOT,WSOMPRZTOT,WQTDPRZTOT")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � BIA010   � Autor � MICROSIGA Vitoria     � Data � 22.04.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri놹o � Relat줿io de Posicao dos Produtos por Vendedor             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � SIGAFAT                                                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌ltera놹o � Luana Poltronieri de Souza em 17.05.99                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cDesc1   := "Este programa tem como objetivo emitir um relat줿io dos" 
cDesc2   := "produtos vendidos por Vendedor"                
cDesc3   := ""
tamanho  := "M"
limite   := 132 
cString  := "SA3"
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "BIA010"
aLinha   := { }
titulo   := "Posicao de Vendas p/ Vendedor"
nLastKey := 0
cPerg    := "BIA010"
wnrel    := "BIA010"
wNumber  := 0
wTotGcx  := 0         
wTotGm2  := 0         
wTotGpt  := 0
wPrazo   := 0
Cabec1   := "PRODUTO                                   PRECO               MEDIA               M2              CAIXAS                    PRECO" 
Cabec2   := "                                          UNIT.               PRAZO                                                         TOTAL"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Vari쟶eis utilizadas para Impress꼘 do Cabe놹lho e Rodap�                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
c15      := 15
cbtxt    := space(10)
cbcont   := 0
li       := 01
wColuna  := 00
m_pag    := 1
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
pergunte("BIA010",.F.)
If nLastKey == 27
   Return
End
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao dos Parametros                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//mv_par01  Do Vendedor
//mv_par02  Ate o Vendedor
//mv_par03  Da Emissao
//mv_par04  Ate a Emissao
//mv_par05  Aberto/Faturado
//mv_par06  Analitico/Sintetico
//mv_par07  Serie da Nota Fiscal
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica Posicao do Formulario na Impressora                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetDefault(aReturn,cString)
If nLastKey == 27
   Return
End
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta arquivo de trabalho                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Processa( {|| fMonta_Arq() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Processa( {|| Execute(fMonta_Arq) } )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Emite relatorio                                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Processa( {|| fImpressao() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Processa( {|| Execute(fImpressao) } )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Rodape                                                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Roda(cbcont,cbtxt,tamanho)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Apaga arquivo de trabalho                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("_cTrab")
USE
If  File(_cTrab+".DBF")
    Ferase(_cTrab+".DBF")
    Ferase(_cTrab+".cdx")
End
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera impressao                                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If  aReturn[5] == 1
    Set Printer To
    Ourspool(wnrel)
End
MS_FLUSH()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim do programa                                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑un눯o    � fMonta_Arq                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri눯o � Monta arquivo de trabalho                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fMonta_Arq
Static Function fMonta_Arq()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria arquivo de trabalho                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
_aCampos := { {"VENDEDOR","C",06, 0},;
              {"NOMEVEND","C",40, 0},;            
              {"PRODUTO ","C",30, 0},;
              {"PRECO   ","N",12, 2},;
              {"PRAZO   ","N",03, 0},;
              {"QTD1UM  ","N",11, 2},;
              {"QTD2UM  ","N",11, 2} }
_cTrab := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cTrab,"_cTrab")
DbCreateInd(_cTrab,"1",{||VENDEDOR+PRODUTO+Str(PRECO,17,2)})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wProd := "  "
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta regua                                                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ProcRegua(IIF((mv_par04  - mv_par03)==0,1,(mv_par04  - mv_par03)))
If mv_par05 == 1
   titulo   := "Carteira de Pedido por Vendedor"
   DbSelectArea("SC5")
   DbSetOrder(2)
   DbSeek(xFilial("SC5")+Dtos(mv_par03),.T.)
   While ! Eof() .and. SC5->C5_EMISSAO <= mv_par04
      IncProc("Processando Pedidos")
      If SC5->C5_VEND1 < mv_par01 .or. SC5->C5_VEND1 > mv_par02
         DbSkip()
         Loop
      Endif
      /*/
      DbSelectArea("SX5")
      DbSetOrder(1)
      If DbSeek(xFilial("SX5")+"91"+SC5->C5_CONDPAG,.F.)
         wPrazo := Subs( SX5->X5_DESCRI, 1, AT( " ", SX5->X5_DESCRI ) )
      Else
         wPrazo := 000
         MsgBox("Condicao de Pagamento "+SC5->C5_CONDPAG+"  nao cadastrada na tabela 91."+;
                " Sera considerado 000","Mensagem do Sistema","ALERT")
      EndIf
      /*/
      DbSelectArea("SE4")
      DbSetOrder(1)
      If DbSeek(xFilial("SE4")+SC5->C5_CONDPAG,.F.)
         wPrazo := SE4->E4_YMEDIA
      Else
         wPrazo := 000
         MsgBox("Media da Cond.Pagto "+SC5->C5_CONDPAG+"  nao cadastrada no SE4."+;
                " Sera considerado 000","Mensagem do Sistema","ALERT")
      EndIf
      DbSelectArea("SA3")
      DbSetOrder(1)
      If DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.)
         wCodVend  := SA3->A3_COD
         wVendedor := SA3->A3_NOME
      Else
         wCodVend  := " " 
         wVendedor := "Vendedor nao cadastrado" 
      Endif
      DbSelectArea("SC6")  
      DbSetOrder(1)
      DbSeek(xFilial("SC6")+SC5->C5_NUM)
      While SC6->C6_NUM == SC5->C5_NUM .and. ! Eof()
         If SC6->C6_CF == "511" .or. SC6->C6_CF == "611" .or. SC6->C6_CF == "512" .or.;
            SC6->C6_CF == "612" .or. SC6->C6_CF == "711" .or. SC6->C6_CF == "711"
            If EMPTY(SC6->C6_NOTA)
               DbSelectArea("_cTrab")
               RecLock("_cTrab",.T.)
               _cTrab->VENDEDOR  := wCodVend
               _cTrab->NOMEVEND  := wVendedor
               _cTrab->PRODUTO   := SC6->C6_DESCRI
               _cTrab->PRECO     := SC6->C6_PRCVEN
               _cTrab->PRAZO     := wPrazo
               _cTrab->QTD1UM    := SC6->C6_QTDVEN - SC6->C6_QTDENT
               _cTrab->QTD2UM    := SC6->C6_UNSVEN
               msUnLock()
            Elseif SC6->C6_QTDVEN - SC6->C6_QTDENT > 0
               DbSelectArea("_cTrab")
               RecLock("_cTrab",.T.)
               _cTrab->VENDEDOR  := wCodVend
               _cTrab->NOMEVEND  := wVendedor
               _cTrab->PRODUTO   := SC6->C6_DESCRI
               _cTrab->PRECO     := SC6->C6_PRCVEN
               _cTrab->PRAZO     := wPrazo
               _cTrab->QTD1UM    := SC6->C6_QTDVEN - SC6->C6_QTDENT
               _cTrab->QTD2UM    := SC6->C6_UNSVEN
               msUnLock()
            Endif
         Endif
         DbSelectArea("SC6")
         DbSkip()
      End
      DbSelectArea("SC5")
      DbSkip()
   end
Elseif mv_par05 == 2
   titulo := "Posicao do Faturamento por Vendedor"
   DbSelectArea("SF2")
   DbSetOrder(4)
   DbSeek(xFilial("SF2")+mv_par07+Dtos(mv_par03),.T.)
   While ! Eof() .and. SF2->F2_EMISSAO <= mv_par04
      IncProc("Processando Notas Fiscais")
      If SF2->F2_SERIE <> mv_par07
         DbSkip()
         Loop
      Endif
      If SF2->F2_VEND1 < mv_par01 .or. SF2->F2_VEND1 > mv_par02
         DbSkip()
         Loop
      Endif
      /*/
      DbSelectArea("SX5")
      DbSetOrder(1)
      If DbSeek(xFilial("SX5")+"91"+SF2->F2_COND,.F.)
         wPrazo := Subs( SX5->X5_DESCRI, 1, AT( " ", SX5->X5_DESCRI ) )
      Else
         wPrazo := "000"
         MsgBox("Condicao de Pagamento "+SF2->F2_COND+"  nao cadastrada na tabela 91."+;
                " Sera considerado 000","Mensagem do Sistema","ALERT")
      EndIf
      /*/
      DbSelectArea("SE4")
      DbSetOrder(1)
      If DbSeek(xFilial("SE4")+SF2->F2_COND,.F.)
         wPrazo := SE4->E4_YMEDIA
      Else
         wPrazo := 000
         MsgBox("Media da Cond.Pagto "+SF2->F2_COND+"  nao cadastrada no SE4."+;
                " Sera considerado 000","Mensagem do Sistema","ALERT")
      EndIf
      DbSelectArea("SA3")  
      DbSetOrder(1)
      If DbSeek(xFilial("SA3")+SF2->F2_VEND1,.F.)
         wCodVend  := SA3->A3_COD
         wVendedor := SA3->A3_NOME
      Else
         wCodVend  := " " 
         wVendedor := "Vendedor nao cadastrado" 
      Endif
      DbSelectArea("SD2")  
      DbSetOrder(3)
      DbSeek(xFilial("SD2")+SF2->F2_DOC,.T.)
      While SD2->D2_DOC == SF2->F2_DOC .and. ! Eof()
         If ALLTRIM(SD2->D2_CF) $ "511_611_512_612_711_712"
            DbSelectArea("SB1")
            DbSetOrder(1)
            If DbSeek(xFilial("SB1")+SD2->D2_COD,.F.)
               wProd := SB1->B1_DESC
            Else
               wProd := "Produto nao cadastrado" 
            Endif
            DbSelectArea("_cTrab")
            RecLock("_cTrab",.T.) 
            _cTrab->VENDEDOR  := wCodVend
            _cTrab->NOMEVEND  := wVendedor
            _cTrab->PRODUTO   := wProd
            _cTrab->PRECO     := SD2->D2_PRUNIT
            _cTrab->PRAZO     := wPrazo
            _cTrab->QTD1UM    := SD2->D2_QUANT
            _cTrab->QTD2UM    := SD2->D2_QTSEGUM
            msUnLock()
         Endif
         DbSelectArea("SD2")
         DbSkip()
      End
      DbSelectArea("SF2")
      DbSkip()
   end
Endif
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑un눯o    � fImpressao                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri눯o � Emite relatorio                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fImpressao
Static Function fImpressao()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta regua                                                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ProcRegua(_cTrab->(RecCount()))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Posiciona arquivo de trabalho                                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("_cTrab")
dbGoTop()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis normais e de quebra                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wCodVend    := _cTrab->VENDEDOR
wVendedor   := _cTrab->NOMEVEND
wProduto    := _cTrab->PRODUTO
wPreco      := _cTrab->PRECO
wTot2UM     := 0
wTot1UM     := 0
wTotPreco   := 0
wMedPrazo   := 0
wSomaPrazo  := 0
wQtdePrazo  := 0
wPrecoMed   := 0
wSomPreMed  := 0
wQtPreMed   := 0
wTotVd1UM   := 0
wTotVd2UM   := 0
wTotVdPrV   := 0
wSomPreTot  := 0
wQtPreTot   := 0
wPreMedTot  := 0
wMedPrzVend := 0
wSomPrzVend := 0
wQtdPrzVend := 0
wMedPrzTot  := 0
wSomPrzTot  := 0
wQtdPrzTot  := 0
li          := 80
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Processa arquivo de trabalho                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
While !eof()
  //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  //� Incrementa regua                                                      �
  //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  IncProc()
  If li >= 56
     Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
     fCabVend()
  Endif
  //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  //� Quebra do Vendedor                                                    �
  //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  If _cTrab->VENDEDOR <> wCodVend
     wTotVd1UM   := wTotVd1UM + wTot1UM
     wTotVd2UM   := wTotVd2UM + wTot2UM
     wTotVdPrV   := wTotVdPrV + wTotPreco
     wMedPrazo   := wSomaPrazo/wQtdePrazo
     wPrecoMed   := wSomPreMed/wQtPreMed
     If mv_par06 == 1
        @ li,000 PSAY wProduto
        @ li,031 PSAY wPreco    Picture "@E 999,999,999.99"
        If wMedPrazo <= 7
           @ li,060 PSAY "A VISTA"
        Else
           @ li,060 PSAY wMedPrazo Picture "@E 999"
        Endif
        @ li,073 PSAY wTot1UM   Picture "@E 9,999,999.99"
        @ li,092 PSAY wTot2UM   Picture "@E 9,999,999.99"
        @ li,117 PSAY wTotPreco Picture "@E 999,999,999.99"
        wProduto   := _cTrab->PRODUTO
        wPreco     := _cTrab->PRECO
     Endif
     li := li + 1
     wMedPrzVend := wSomPrzVend/wQtdPrzVend
     @ li,000 PSAY Repl("-",Limite)
     li := li + 1
     @ li,000 PSAY "TOTAL VENDEDOR: "+wCodVend
     @ li,029 PSAY "PR.MED:" 
     @ li,037 PSAY wPrecoMed Picture "@E 9,999.99"
     If wMedPrzVend <= 7
        @ li,060 PSAY "A VISTA"
     Else
        @ li,060 PSAY wMedPrzVend Picture "@E 999"
     Endif
     @ li,073 PSAY wTotVd1UM Picture "@E 9,999,999.99"
     @ li,092 PSAY wTotVd2UM Picture "@E 9,999,999.99"
     @ li,117 PSAY wTotVdPrV Picture "@E 999,999,999.99"
     li := li + 1
     @ li,000 PSAY Repl("-",Limite)
     li          := li + 2
     wTotGm2     := wTotGm2 + wTotVd1UM
     wTotGcx     := wTotGcx + wTotVd2UM
     wTotGpt     := wTotGpt + wTotVdPrV
     wTotVd1UM   := wTotVd1UM + wTot1UM
     wTotVd2UM   := wTotVd2UM + wTot2UM
     wTotVdPrV   := wTotVdPrV + wTotPreco
     wCodVend    := _cTrab->VENDEDOR
     wVendedor   := _cTrab->NOMEVEND
     wProduto    := _cTrab->PRODUTO
     wPreco      := _cTrab->PRECO
     wSomPreTot  := wSomPreTot
     wQtPreTot   := wQtPreTot
     wTotVd1UM   := 0
     wTotVd2UM   := 0
     wTotVdPrV   := 0
     wTot2UM     := 0
     wTot1UM     := 0
     wTotPreco   := 0
     wMedPrazo   := 0
     wSomaPrazo  := 0
     wQtdePrazo  := 0
     wSomPreMed  := 0
     wQtPreMed   := 0
     wPrecoMed   := 0
     wSomPrzVend := 0
     wQtdPrzVend := 0
     fCabVend()
     Loop
  Else
     If _cTrab->PRODUTO <> wProduto
        wMedPrazo := wSomaPrazo/wQtdePrazo
        If mv_par06 == 1
           @ li,000 PSAY wProduto
           @ li,031 PSAY wPreco    Picture "@E 999,999,999.99"
           If wMedPrazo <= 7
              @ li,060 PSAY "A VISTA"
           Else
              @ li,060 PSAY wMedPrazo Picture "@E 999"
           Endif
           @ li,073 PSAY wTot1UM   Picture "@E 9,999,999.99"
           @ li,092 PSAY wTot2UM   Picture "@E 9,999,999.99"
           If wTot1UM == 0
              wTotPreco := wPreco
           EndIf
           @ li,117 PSAY wTotPreco Picture "@E 999,999,999.99"
           li := li + 1
        Endif
        wTotVd1UM  := wTotVd1UM + wTot1UM
        wTotVd2UM  := wTotVd2UM + wTot2UM
        wTotVdPrV  := wTotVdPrV + wTotPreco
        wTot2UM    := 0
        wTot1UM    := 0
        wTotPreco  := 0
        wMedPrazo  := 0
        wSomaPrazo := 0
        wQtdePrazo := 0
        wProduto   := _cTrab->PRODUTO
        wPreco     := _cTrab->PRECO
        Loop
     Else
        If _cTrab->PRECO <> wPreco
           wMedPrazo := wSomaPrazo/wQtdePrazo
           If mv_par06 == 1
              @ li,000 PSAY wProduto
              @ li,031 PSAY wPreco Picture "@E 999,999,999.99"
              If wMedPrazo <= 7
                 @ li,060 PSAY "A VISTA"
              Else
                 @ li,060 PSAY wMedPrazo Picture "@E 999"
              Endif
              @ li,073 PSAY wTot1UM   Picture "@E 9,999,999.99"
              @ li,092 PSAY wTot2UM   Picture "@E 9,999,999.99"
              If wTot1UM == 0
                 wTotPreco := wPreco
              EndIf
              @ li,117 PSAY wTotPreco Picture "@E 999,999,999.99"
              li := li + 1
           Endif
           wTotVd1UM  := wTotVd1UM + wTot1UM
           wTotVd2UM  := wTotVd2UM + wTot2UM
           wTotVdPrV  := wTotVdPrV + wTotPreco
           wTot2UM    := 0
           wTot1UM    := 0
           wTotPreco  := 0
           wMedPrazo  := 0
           wSomaPrazo := 0
           wQtdePrazo := 0
           wPreco     := _cTrab->PRECO
           Loop
        Else
           wTot2UM     := wTot2UM + _cTrab->QTD2UM
           wTot1UM     := wTot1UM + _cTrab->QTD1UM
           wTotPreco   := wTotPreco   + (_cTrab->PRECO * _cTrab->QTD1UM)
           wSomaPrazo  := wSomaPrazo  + _cTrab->PRAZO
           wQtdePrazo  := wQtdePrazo  + 1
           wSomPreMed  := wSomPreMed  + (_cTrab->PRECO*_cTrab->QTD1UM)
           wQtPreMed   := wQtPreMed   + _cTrab->QTD1UM
           wSomPrzTot  := wSomPrzTot  + _cTrab->PRAZO
           wQtdPrzTot  := wQtdPrzTot  + 1
           wSomPrzVend := wSomPrzVend + _cTrab->PRAZO
           wQtdPrzVend := wQtdPrzVend + 1
           wSomPreTot  := wSomPreTot  + (_cTrab->PRECO*_cTrab->QTD1UM)
           wQtPreTot   := wQtPreTot   + _cTrab->QTD1UM
        EndIf
     Endif      
  Endif
  //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
  //� Acessa proximo registro                                                �
  //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
  dbSelectArea("_cTrab")
  dbSkip()
End
If mv_par06 == 1
   @ li,000 PSAY wProduto
   @ li,031 PSAY wPreco Picture "@E 999,999,999.99"
   If wMedPrazo <= 7
      @ li,060 PSAY "A VISTA"
   Else
      @ li,060 PSAY wMedPrazo Picture "@E 999"
   Endif
   @ li,073 PSAY wTot1UM   Picture "@E 9,999,999.99"
   @ li,092 PSAY wTot2UM   Picture "@E 9,999,999.99"
   @ li,117 PSAY wTotPreco Picture "@E 999,999,999.99"
   li := li + 1
Endif

wTotVd1UM  := wTotVd1UM + wTot1UM
wTotVd2UM  := wTotVd2UM + wTot2UM
wTotVdPrV  := wTotVdPrV + wTotPreco

wPrecoMed   := wSomPreMed/wQtPreMed
wMedPrzVend := wSomPrzVend/wQtdPrzVend
li := li + 1
@ li,000 PSAY Repl("-",Limite)
li := li + 1
@ li,000 PSAY "TOTAL VENDEDOR: "+wCodVend
@ li,029 PSAY "PR.MED:"
@ li,037 PSAY wPrecoMed Picture "@E 9,999.99"
If wMedPrzVend <= 7
   @ li,060 PSAY "A VISTA"
Else
   @ li,060 PSAY wMedPrzVend Picture "@E 999"
Endif
@ li,073 PSAY wTotVd1UM Picture "@E 9,999,999.99"
@ li,092 PSAY wTotVd2UM Picture "@E 9,999,999.99"
@ li,117 PSAY wTotVdPrV Picture "@E 999,999,999.99"
wTotGm2 := wTotGm2 + wTotVd1UM
wTotGcx := wTotGcx + wTotVd2UM
wTotGpt := wTotGpt + wTotVdPrV
li      := li + 1
@ li,000 PSAY Repl("-",Limite)
li      := li + 2
wPreMedTot := wSomPreTot/wQtPreTot
wMedPrzTot := wSomPrzTot/wQtdPrzTot
@ li,000 PSAY "TOTAL GERAL:"
@ li,037 PSAY wPreMedTot Picture "@E 9,999.99"
If wMedPrzTot <= 7
   @ li,060 PSAY "A VISTA"
Else
   @ li,060 PSAY wMedPrzTot Picture "@E 999"
Endif
@ li,073 PSAY wTotGm2    Picture "@E 9,999,999.99"
@ li,092 PSAY wTotGcx    Picture "@E 9,999,999.99"
@ li,117 PSAY wTotGpt    Picture "@E 999,999,999.99"
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑un눯o    � fCabVend                                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escri눯o � Monta o cabecalho do Vendedor                              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fCabVend
Static Function fCabVend()
@ li,000 PSAY "VENDEDOR: " + _cTrab->VENDEDOR + "  " + _cTrab->NOMEVEND
li := li + 2
Return

