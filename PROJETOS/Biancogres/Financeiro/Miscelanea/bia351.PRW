#Include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BIA351    �Autor  �Microsiga           � Data �  02/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclusao de titulos de bordero de pagamentos               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������͹��
���Manutencao�                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BIA351  
Private lop,cnum,ocheck,cmarkbr
//�����������������������������������������������������������Ŀ
//� Solicita perguntas                                        �
//�������������������������������������������������������������
lop := Pergunte("BIA351",.T.)
If lop == .F.
   Return
EndIf
cnum  := mv_par01                   
DbSelectArea("SEA")               
DbSetOrder(1)
If !DbSeek(xFilial("SEA")+cnum)
   MsgBox("Atencao, o bordero solicitado nao foi encontrado, favor verificar!","Atencao","ALERT")
   Return
EndIf   
//�����������������������������������������������������������Ŀ
//� Processa arquivo                                          �
//�������������������������������������������������������������
Processa({|| fgera() },"Processando...")
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fgera    � Autor � Nilton Cesar          � Data � 02.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processando titulos                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RDMAKE                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fgera()
_aCampos := {  {"_OK",        "C",02,0}    ,;
                {"CPREFIXO",   "C",03,0}    ,;
                {"CNUMERO",    "C",06,0}    ,;
                {"CPARC",      "C",01,0}    ,;
                {"CFORNECE",   "C",06,0}    ,;
                {"CLOJA",      "C",02,0}    ,;
                {"CNOME",      "C",40,0}    ,;
                {"NVALOR",     "N",12,2}    ,;
                {"CVALOR",     "C",14,0}    ,;
                {"CBCO",       "C",03,0}    ,;
                {"CAGEN",      "C",05,0}    ,;
                {"CCONTA",     "C",10,0}    ,;
                {"CTIPO",      "C",03,0}    ,;                
                {"CCART",      "C",01,0}     }

_trabalho := CriaTrab(_aCampos)
dbUseArea(.T.,,_trabalho,"_trabalho",.t.)  //.F.->Exclusivo
dbCreateInd(_trabalho,"CPREFIXO+CNUMERO",{||CPREFIXO+CNUMERO})
//��������������������������������������������������������������������������Ŀ
//� Montar arquivos                                                          �
//����������������������������������������������������������������������������
DbSelectArea("SEA")
ProcRegua(RecCount())
Do while .not. eof() .and. SEA->EA_FILIAL == xFilial("SEA") .and. SEA->EA_NUMBOR==cnum 
   Incproc()
   //��������������������������������������������������������������������������Ŀ
   //� Bypassa se titulo nao for da carteira a pagar                            �
   //����������������������������������������������������������������������������
   If SEA->EA_CART # "P"
      DbSkip()
      Loop
   EndIf
   //��������������������������������������������������������������������������Ŀ
   //� Bypassa se titulo estiver baixado                                        �
   //����������������������������������������������������������������������������
   DbSelectArea("SE2")
   DbSetOrder(1)
   If DbSeek(xFilial("SE2")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA)
      If SE2->E2_SALDO == 0 .or. !Empty(SE2->E2_BAIXA)
         DbSelectArea("SEA")
         DbSkip()           
      EndIf
   Else       
      DbSelectArea("SEA")
      DbSkip()           
   EndIf   
   //��������������������������������������������������������������������������Ŀ
   //� Gravar titulos no arquivo de trabalho                                    �
   //����������������������������������������������������������������������������
   While !RecLock("_trabalho",.t.);EndDo
   _trabalho->CPREFIXO     :=SEA->EA_PREFIXO
   _trabalho->CNUMERO      :=SEA->EA_NUM
   _trabalho->CPARC        :=SEA->EA_PARCELA
   _trabalho->NVALOR       :=SE2->E2_VALOR
   _trabalho->CVALOR       :=Transform(SE2->E2_VALOR,"@e 999,999,999.99")
   _trabalho->CFORNECE     :=SEA->EA_FORNECE
   _trabalho->CLOJA        :=SEA->EA_LOJA
   _trabalho->CBCO         :=SEA->EA_PORTADO
   _trabalho->CAGEN        :=SEA->EA_AGEDEP
   _trabalho->CCONTA       :=SEA->EA_NUMCON 
   _trabalho->CTIPO        :=SEA->EA_TIPO   
   _trabalho->CCART        :=SEA->EA_CART      
   MsUnlock()                  
   DbSelectArea("SEA")
   DbSkip()
EndDo                                  
DbSelectArea("_trabalho")
DbGotop()
If Eof()
   MsgAlert("Atencao, o bordero "+cnum+" nao possui nenhum titulo em aberto.","Atencao","ALERT")
   DbCloseArea()
   Ferase(_trabalho+".DBF")
   Ferase(_trabalho+".CDX")
   Return
EndIf
//��������������������������������������������������������������������������Ŀ
//� Montar array com os campos                                               �
//����������������������������������������������������������������������������
aCampos := {}  
AADD(aCampos,{"_OK"," " ,2})
AADD(aCampos,{"CPREFIXO", "Prefixo" ,3})
AADD(aCampos,{"CNUMERO",  "Numero" ,6})
AADD(aCampos,{"CPARC",    "Parcela",1})
AADD(aCampos,{"CVALOR",   "Valor",12 })
AADD(aCampos,{"CFORNECE", "Fornecedor",6})
AADD(aCampos,{"CLOJA",    "Loja" ,2})
AADD(aCampos,{"CBCO",     "Banco" ,3})
AADD(aCampos,{"CAGEN",    "Agencia",5})
AADD(aCampos,{"CCONTA",   "Conta" ,10})
//���������������������������������������������������������������������Ŀ
//� tela markbrow                                                       �
//�����������������������������������������������������������������������
nMarcados := 0                            
lInverte  := .F.
cMarca    := GetMark()
@ 20,10   to 450,750 Dialog oDlg1 Title "Titulos do Bordero "+cnum 
@180,250   BmpButton Type 1 Action fProcOk()
@180,300   BmpButton Type 2 Action Close(oDlg1)
lCheck := .T.
oCheck := IW_CheckBox(005,070,"Marca/Desmarca Todos","lCheck") 
oCheck:bChange := {|| MsAguarde( {|| A470Mark() } ) } 
//��������������������������������������������������������������������������Ŀ
//� Monta MarkBrowse...                                                      �
//����������������������������������������������������������������������������
oBrowse := IW_Browse(020,020,160,360,"_trabalho","_OK",,acampos)
oBrowse:oBrowse:bAllMark := {|| MsAguarde( {|| A470Mark() } ) }
ACTIVATE DIALOG oDlg1 ON INIT Eval({|| MsAguarde( {|| cMarkBr := ThisMark(), A470Mark() } ), _trabalho->(DbGoTop()), oBrowse:oBrowse:Refresh(), })
DbSelectArea("_trabalho")
DbCloseArea()
Ferase(_trabalho+".DBF")
Ferase(_trabalho+".CDX")
Return
/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Funcao   � A470MARK� Autor �....................  � Data � 06.06.2000 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca todos os itens do Browse...                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A470Mark()
MsProcTXT(If(lCheck,"Marcando","Desmarcando"))
_trabalho->(DbGoTop())
While ! _trabalho->(Eof())
      _trabalho->(RecLock("_trabalho",.F.))
      If lCheck
         _trabalho->_OK := ''
      Else
         _trabalho->_OK := cMarkBr
      Endif 
      _trabalho->(MsUnLock())      
     _trabalho->(DbSkip())
Enddo
_trabalho->(DbCommit())
_trabalho->(DbGoTop())
oBrowse:oBrowse:Refresh()
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Liberar os titulos selecionados                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fProcOK()
DbSelectArea("_trabalho")
ProcRegua(RecCount())
DbGotop()
Do while .not. eof() 
   IncProc()
   If Marked("_OK")
      DbSelectArea("SEA")
      DbSetOrder(1)
      If DbSeek(xFilial("SEA")+cnum+_trabalho->CPREFIXO+_trabalho->CNUMERO+_trabalho->CPARC+_trabalho->CTIPO+_trabalho->CFORNECE+_Trabalho->CLOJA) 
         DbSelectArea("SE2")
         DbSetOrder(1)
         If DbSeek(xFilial("SE2")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA)
            While !Reclock("SE2",.f.);EndDo
            SE2->E2_NUMBOR := Space(6)
            MsUnlock()
         EndIf
         DbSelectArea("SEA")
         While !Reclock("SEA",.f.);EndDo
         Delete
         MsUnlock()
      EndIf      
   EndIf   
   DbSelectArea("_Trabalho")
   DbSkip()
EndDo   
Close(oDlg1)
Return