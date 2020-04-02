COOPEAVI\facile.analista
@Fac8759K

SLQ - ORÇAMENTO  - 
LQ_YTROCA,  
LQ_YQTDTRO (Quantidade de troca , para pedidos criados com produtos essa finalidade LQ_YTROCA)
LQ_YPRETRO (Preço unitário do produto para troca)


SLR - ITENS DO ORÇAMENTO - 
LR_YTROCA, 
LR_YQTDTRO (Quantidade de troca , para pedidos criados com produtos essa finalidade LQ_YTROCA)
LR_YPRETRO (Preço unitário do produto para troca)

SL1 - ORÇAMENTO - L1_YTROCA ,  
L1_YQTDTRO (Quantidade de troca , para pedidos criados com produtos essa finalidade L1_YTROCA)
L1_YPRETRO (Preço unitário do produto para troca)

SL2 - ITENS DO ORÇAMENTO - L2_YTROCA, 
L2_YQTDTRO (Quantidade de troca , para pedidos criados com produtos essa finalidade L2_YTROCA)
L2_YPRETRO (Preço unitário do produto para troca)

   

Gatilho: LR_YTROCA 

Parametro:   MV_YBARTER : Condiçao de pagamento BARTER, caso tenha mais de um
Parametro:   MV_YFILBAR : eEscolhas das Filiais que estarão no processo BARTER
FORMULA PP5  = IIF(M->LQ_YCOND $ SUPERGETMV('MV_YBARTER',.T.,'251') .AND. SM0->M0_CODFIL $ SUPERGETMV('MV_YFILBAR',.T.,'01'),.T.,.F.)
** COLOCAR FORMULA NO MODO DE EXIBIÇÃO DO CAMPO LQ_YTROCA


LQ_YAFERIC



LR_PRODUTO
LR_QUANT
LR_VRUNIT
LR_VRITEM
LR_DESC
LR_VALDESC




//1 - Criação de condição de pagamento específica para BARTER; - ok

/*
2 - Campo customizado no cabeçalho do orçamento (venda assistida) para informar o produto Café (combobox ou F3) 
filtrando somente os produtos elegíveis para troca em insumos; - OK
*/

/*
3 - Campo customizado no cabeçalho do orçamento para mostrar a quantidade do produto informado no campo 1 
que deverá ser entregue pelo cliente em troca do insumos (itens) do orçamento. A conversão será a soma do 
valor dos itens no orçamento dividido pelo preço do produto informado no campo 1; ok
*/

//4 - Os campos customizados só ficarão habilitados quando for selecionada a condição de pagamento BARTER criada no item 1 ; - OK

5 - Cada orçamento fará exclusivamente a troca (BARTER) de um tipo de café;

/* 
6 - A cada item incluído ou alterado (produto, qtd ou preço) na grid de itens do orçamento, o campo criado no item 3 
deverá ser atualizado em tempo real com a quantidade convertida; - ok
*/

/*
7 - Deverão ser armazenados na confirmação do orçamento os dados referente a troca, ou seja, preço de venda no momento da operação,
 quantidade de SACAS, produto(s), quantidade(s) e preços;
 */

8 - O escopo acima deverá ser realizado considerando as customizações já existentes na rotina mantendo-as em pleno funcionamento; 

9 - Os campos customizados e regras de barter deverão estar:
        Alteráveis somente nas filiais onde o processo do barter estiver ativo.
        Criar parâmetro para configurar o processo nas filiais. 
        Informar o produto filtrando somente os produtos elegíveis para troca em insumos;

