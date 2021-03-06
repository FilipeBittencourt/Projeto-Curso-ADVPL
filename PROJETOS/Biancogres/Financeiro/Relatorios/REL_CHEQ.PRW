#include "rwMake.ch"
#include "Topconn.ch"
/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  � PREVDES        �Autor  � HARLEY DIAS KOEHLER� Data �  21/12/07   ���
�������������������������������������������������������������������������������͹��
���Desc.     � RELATORIO DE CHEQUES                                             ���
�������������������������������������������������������������������������������͹��
���Uso       � AP 7                                                             ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function REL_CHEQ()
	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Comparativo de Pesos "
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "REL_CHEQ"
	cPerg      := "REL_CH"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Rela��o de Cheques"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "REL_CHEQ"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t. 


	//������������������������������������������������������������������������Ŀ
	//� Cria parametros se nao existir e chama os parametros na tela           �
	//��������������������������������������������������������������������������
	//ValidPerg()

	//��������������������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT.								     �
	//� Verifica Posicao do Formulario na Impressora.				             �
	//� Solicita os parametros para a emissao do relatorio			             |
	//����������������������������������������������������������������������������
	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	cSQL := ""
	cSQL += "ALTER VIEW VW_REL_CHEQ AS  " + Enter                        
	cSQL += "SELECT SA2.A2_COD, SA2.A2_NOME,SA2.A2_LOJA,SA2.A2_BANCO,SA2.A2_AGENCIA,SA2.A2_YDVAG,SA2.A2_NUMCON,SA2.A2_YDVCTA, " + Enter
	cSQL += "SEF.EF_DATA,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUM,SEF.EF_VALOR,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA " + Enter
	cSQL += "FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("SEF") + " SEF " + Enter
	cSQL += "WHERE SA2.D_E_L_E_T_ = '' " + Enter
	cSQL += "AND   SEF.D_E_L_E_T_ = '' " + Enter
	cSQL += "AND   SA2.A2_COD     = SEF.EF_FORNECE " + Enter
	cSQL += "AND   SEF.EF_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
	cSQL += "AND   SA2.A2_BANCO  <> '' AND  SA2.A2_LOJA = SEF.EF_LOJA" + Enter  
	cSql += "AND   SEF.EF_BANCO='" + MV_PAR03 +"' " + Enter
	cSql += "AND SEF.EF_AGENCIA='" + MV_PAR04 +"' " + Enter
	cSql += "AND SEF.EF_CONTA='"   + MV_PAR05 +"' " + Enter
	cSql += "AND SEF.EF_NUM BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' " + Enter



	////////
	TcSQLExec(cSQL)                    	
	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao...          �
	//�����������������������������������������������������������������������
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif
	//AtivaRel()
	callcrys("REL_CHEQ",cempant,cOpcao)
Return

//+
/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao	 �ValidPerg    � Autor � MAGNAGO                                ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Cria as perguntas no SX1                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ValidPerg()
	Local _j, _i
	Private _aPerguntas := {}

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return