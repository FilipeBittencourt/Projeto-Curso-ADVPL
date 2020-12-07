#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

User Function BIA514()        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetPrvt("_PERG,_CLIENTE,_LOJA,AHEADER,ACOLS,XACHOU")
SetPrvt("NQTE,WSNOMECLI,")

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё BIA514     Ё Autor Ё MICROSIGA VITORIA     Ё Data Ё 230101   Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Apresenta itens da NF de saida do cliente solicitado         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Interpretador x Base                                         Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
_perg := Pergunte("BIA514",.T.)
If _perg == .F.
   Return
EndIf
Processa( {|| Tela1() } )// Substituido pelo assistente de conversao do AP5 IDE em 23/04/01 ==> Processa( {|| Execute(Tela1) } )

// Substituido pelo assistente de conversao do AP5 IDE em 23/04/01 ==> Function tela1
Static Function tela1()
_cliente := mv_par01
_loja    := mv_par02
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+_cliente+_loja))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader - Cabecalho do MultiLine                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHeader := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa SX3                                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("SX3")
DbSetOrder(2)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aHeader com campos do SX3                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSeek("D2_NOTA")     ; AADD(aHeader,{ "Nota" , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("B1_COD")      ; AADD(aHeader,{ "Produto"     , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("B1_DESC")     ; AADD(aHeader,{ "Descricao"   , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("D2_QUANT")    ; AADD(aHeader,{ "Quantidade" , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("F2_YAGREG")   ; AADD(aHeader,{ "Romaneio" , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
DbSeek("D2_EMISSAO")  ; AADD(aHeader,{ "Emissao" , X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO } )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aCols - Linhas da Coluna                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCols  := {}
xAchou := .F.
nQte   := 0
DbSelectArea("SF2")
ProcRegua(RecCount())
DbSetOrder(2)
DbSeek(xFilial("SF2")+_cliente+_loja)
While F2_FILIAL==xFilial("SF2") .and. SF2->F2_CLIENTE == _cliente .and. SF2->F2_LOJA==_loja
      IncProc()
      If !Empty(F2_YDES)
         DbSkip()
         Loop
      EndIf
      DbSelectArea("SD2")
      DbSetOrder(3)
      DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
      Do while .not. eof() .and. D2_FILIAL==xFilial("SD2") .and. D2_DOC+D2_SERIE==SF2->F2_DOC+SF2->F2_SERIE
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
         Aadd(aCols,{SD2->D2_DOC,SD2->D2_COD,SB1->B1_DESC,SD2->D2_QUANT,Subs(SF2->F2_YAGREG,5,4),SD2->D2_EMISSAO})
         nqte := nqte + SD2->D2_QUANT
         DbSkip()
      EndDo
      DbSelectArea("SF2")
      DbSkip()
EndDo
aCols := Asort(aCols,,, { |x, y| x[6] < y[6] })
If nqte > 0
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta Dialogo                                                       Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   @ 038,000 to 400,700 Dialog oDlg1 Title "Consulta nf sem data de saida"
   @ 010,010 Say "Cliente: "
   @ 010,040 Get _cliente When Empty(_cliente)
   wsNomeCli := Subs(SA1->A1_NOME,1,40)
   @ 010,080 Get wsNomeCli When Empty(wsNomeCli)
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Executa o MultiLine                                                 Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   @ 030,010 TO 135,330 MULTILINE 
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta Botoes                                                        Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   @ 150,300 BmpButton Type 2 Action Close(oDlg1)
   Activate Dialog oDlg1
Else
   MsgAlert("Cliente nao possui NF sem data de saida ...")
EndIf
Return
