#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SPDFIS001 �Autor  �Microsiga           � Data �  28/09/09   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SPDFIS001()

Local aTipo := ParamIXB[1]

aTipo    :=    { {"MR","00"},;    //Mercadoria para Revenda
                 {"MP","01"},;    //Materia Prima
                 {"EM","02"},;    //Embalagem
                 {"ME","02"},;    //Embalagem
                 {"PP","03"},;    //Produto em Processo
                 {"PA","04"},;    //Produto Acabado
                 {"SP","05"},;    //Subproduto
                 {"PI","06"},;    //Produto Intermediario                  
                 {"MC","07"},;    //Material de Uso e Consumo
                 {"MD","07"},;    //Material de Uso e Consumo
                 {"IM","08"},;    //Ativo Imobilizado
                 {"MO","09"},;    //Servicos
                 {"OI","10"},;    //Outros Insumos  
                 {"GG","99"},;    //Outras               
                 {"MD","99"} }    //Outras
Return aTipo