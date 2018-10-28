//Bibliotecas
#Include "Protheus.ch"
 
//Constantes usadas na cria��o dos campos
#Define _X3_USADO         "�������������� "
#Define _X3_USFILIAL     "���������������"
#Define _X3_RESERV         "�A"
#Define _X3_OBRIGA         "�"
#Define _X3_NAO_OBRIGA     ""
 
/*/{Protheus.doc} zCriaTab
Fun��o para cria��o das tabelas e/ou campos
@author Atilio
@since 06/08/2015
@version 1.0
    @param aSX2, Array, Dados do Dicion�rio
    @param aSX3, Array, Dados dos Campos
    @param aSIX, Array, Dados da SIX
    @example
    u_zCriaTab()
    @obs Abaixo a estrutura dos arrays:
    SX2:
        [01] - Chave
        [02] - Descri��o
        [03] - Modo
        [04] - Modo Un.
        [05] - Modo Emp.
    SX3:
        [nLinha][01] - Campo
        [nLinha][02] - Filial?
        [nLinha][03] - Tamanho
        [nLinha][04] - Decimais
        [nLinha][05] - Tipo
        [nLinha][06] - T�tulo
        [nLinha][07] - Descri��o
        [nLinha][08] - M�scara
        [nLinha][09] - N�vel
        [nLinha][10] - Vld.User
        [nLinha][11] - Usado?
        [nLinha][12] - Ini.Padr.
        [nLinha][13] - Cons.F3
        [nLinha][14] - Visual
        [nLinha][15] - Contexto
        [nLinha][16] - Browse
        [nLinha][17] - Obrigat�rio?
        [nLinha][18] - Lista Op��es
        [nLinha][19] - Modo de Edi��o
        [nLinha][20] - Ini Browse
        [nLinha][21] - Pasta
    SIX:
        [nLinha][01] - �ndice
        [nLinha][02] - Ordem
        [nLinha][03] - Chave
        [nLinha][04] - Descri��o
        [nLinha][05] - Propriedade
        [nLinha][06] - NickName
        [nLinha][07] - Mostr.Pesq
/*/
 
User Function zCriaTab(aSX2, aSX3, aSIX)
    Local aArea := GetArea()
    Local aAreaX2 := SX2->(GetArea())
    Local aAreaX3 := SX3->(GetArea())
    Local aAreaIX := SIX->(GetArea())
    Local cTabAux := aSX2[1]
    Local lTabCriada := .F.
    Local lTemAltera := .F.
    Local cMsgAux := ""
    Local nAtual := 0
    Local cOrdemAux := ""
     
    //Setando os �ndices
    SX2->(dbSetOrder(1)) // X2_CHAVE
    SX3->(dbSetOrder(2)) // X3_CAMPO
    SIX->(dbSetOrder(1)) // INDICE+ORDEM
     
    //Se n�o conseguir posicionar na tabela, ir� cri�-la
    SX2->(DbSetOrder(1))
    If !SX2->(DbSeek(cTabAux))
        RecLock("SX2", .T.)
            SX2->X2_CHAVE        :=    cTabAux
            SX2->X2_PATH        :=    "\data\"
            SX2->X2_ARQUIVO    :=    cTabAux+SM0->M0_CODIGO+"0"
            SX2->X2_NOME        :=    aSX2[2]
            SX2->X2_NOMESPA    :=    aSX2[2]
            SX2->X2_NOMEENG    :=    aSX2[2]
            SX2->X2_ROTINA    :=    ""
            SX2->X2_MODO        :=    aSX2[3]
            SX2->X2_MODOUN    :=    aSX2[4]   
            SX2->X2_MODOEMP    :=    aSX2[5]
            SX2->X2_DELET        :=    0
            SX2->X2_TTS        :=    ""
            SX2->X2_UNICO        :=    ""
            SX2->X2_PYME        :=    ""
            SX2->X2_MODULO    :=    0
        SX2->(MsUnlock())
     
        lTabCriada := .T.
    Else
        lTabCriada := .T.
    EndIf
     
    //Se a tabela tiver sido criada
    If lTabCriada
        //Percorrendo os campos
        For nAtual := 1 To Len(aSX3)
            If !SX3->(DbSeek(aSX3[nAtual][01]))
                fProxSX3(cTabAux, @cOrdemAux)
                                 
                //Se for campo de filial, trata de forma diferente
                If aSX3[nAtual][02]
                    RecLock("SX3", .T.)
                        SX3->X3_ARQUIVO    :=    cTabAux
                        SX3->X3_ORDEM        :=    cOrdemAux
                        SX3->X3_CAMPO        :=    aSX3[nAtual][01]
                        SX3->X3_TIPO        :=    aSX3[nAtual][05]
                        SX3->X3_TAMANHO    :=    aSX3[nAtual][03]
                        SX3->X3_DECIMAL    :=    aSX3[nAtual][04]
                        SX3->X3_TITULO    :=    aSX3[nAtual][06]
                        SX3->X3_TITSPA    :=    aSX3[nAtual][06]
                        SX3->X3_TITENG    :=    aSX3[nAtual][06]
                        SX3->X3_DESCRIC    :=    aSX3[nAtual][07]
                        SX3->X3_DESCSPA    :=    aSX3[nAtual][07]
                        SX3->X3_DESCENG    :=    aSX3[nAtual][07]
                        SX3->X3_PICTURE    :=    aSX3[nAtual][08]
                        SX3->X3_USADO        :=    _X3_USFILIAL
                        SX3->X3_RESERV    :=    "��"
                        SX3->X3_GRPSXG    :=    "033"
                        SX3->X3_PYME        :=    "S"
                        SX3->X3_IDXSRV    :=    "N"
                        SX3->X3_ORTOGRA    :=    "N"
                        SX3->X3_IDXFLD    :=    "N"
                        SX3->X3_BROWSE    :=    "N"
                        SX3->X3_NIVEL        :=    aSX3[nAtual][09]
                    SX3->(MsUnlock())
                     
                //Sen�o cria o campo
                Else
                    RecLock("SX3", .T.)
                        SX3->X3_ARQUIVO    :=    cTabAux
                        SX3->X3_ORDEM        :=    cOrdemAux
                        SX3->X3_CAMPO        :=    aSX3[nAtual][01]
                        SX3->X3_TIPO        :=    aSX3[nAtual][05]
                        SX3->X3_TAMANHO    :=    aSX3[nAtual][03]
                        SX3->X3_DECIMAL    :=    aSX3[nAtual][04]
                        SX3->X3_TITULO    :=    aSX3[nAtual][06]
                        SX3->X3_TITSPA    :=    aSX3[nAtual][06]
                        SX3->X3_TITENG    :=    aSX3[nAtual][06]
                        SX3->X3_DESCRIC    :=    aSX3[nAtual][07]
                        SX3->X3_DESCSPA    :=    aSX3[nAtual][07]
                        SX3->X3_DESCENG    :=    aSX3[nAtual][07]
                        SX3->X3_PICTURE    :=    aSX3[nAtual][08]
                        SX3->X3_VLDUSER    :=    aSX3[nAtual][10]
                        SX3->X3_VALID        :=    ""
                        SX3->X3_USADO        :=    Iif(aSX3[nAtual][11], _X3_USADO, _X3_USFILIAL)
                        SX3->X3_RELACAO    :=    aSX3[nAtual][12]
                        SX3->X3_F3            :=    aSX3[nAtual][13]
                        SX3->X3_NIVEL        :=    aSX3[nAtual][09]
                        SX3->X3_RESERV    :=    _X3_RESERV
                        SX3->X3_CHECK        :=    ""
                        SX3->X3_TRIGGER    :=    ""
                        SX3->X3_PROPRI    :=    "U"
                        SX3->X3_VISUAL    :=    aSX3[nAtual][14]
                        SX3->X3_CONTEXT    :=    aSX3[nAtual][15]
                        SX3->X3_BROWSE    :=    aSX3[nAtual][16]
                        SX3->X3_OBRIGAT    :=    Iif(aSX3[nAtual][17], _X3_OBRIGA, _X3_NAO_OBRIGA)
                        SX3->X3_CBOX        :=    aSX3[nAtual][18]
                        SX3->X3_CBOXSPA    :=    aSX3[nAtual][18]
                        SX3->X3_CBOXENG    :=    aSX3[nAtual][18]
                        SX3->X3_PICTVAR    :=    ""
                        SX3->X3_WHEN        :=    aSX3[nAtual][19]
                        SX3->X3_INIBRW    :=    aSX3[nAtual][20]
                        SX3->X3_GRPSXG    :=    ""
                        SX3->X3_FOLDER    :=    aSX3[nAtual][21]
                        SX3->X3_PYME        :=    "S"
                        SX3->X3_CONDSQL    :=    ""
                        SX3->X3_IDXSRV    :=    "N"
                        SX3->X3_ORTOGRA    :=    "N"
                        SX3->X3_IDXFLD    :=    "N"  
                        SX3->X3_TELA        :=    ""
                    SX3->(msUnlock()) 
                EndIf
                lTemAltera := .T.
            EndIf
        Next
         
        //Percorrendo os �ndices
        For nAtual := 1 To Len(aSIX)
            //Se n�o conseguir posicionar, quer dizer que n�o existe o �ndice, logo ser� criado
            If ! SIX->(DbSeek(aSIX[nAtual][1] + aSIX[nAtual][2]))
                RecLock("SIX", .T.)
                    SIX->INDICE        :=    aSIX[nAtual][1]
                    SIX->ORDEM            :=    aSIX[nAtual][2]
                    SIX->CHAVE            :=    aSIX[nAtual][3]
                    SIX->DESCRICAO    :=    aSIX[nAtual][4]
                    SIX->DESCSPA        :=    aSIX[nAtual][4]
                    SIX->DESCENG        :=    aSIX[nAtual][4]
                    SIX->PROPRI        :=    aSIX[nAtual][5]
                    SIX->F3            :=    ""
                    SIX->NICKNAME        :=    aSIX[nAtual][6]
                    SIX->SHOWPESQ        :=    aSIX[nAtual][7]
                SIX->(MsUnlock())
                lTemAltera := .T.
            EndIf
        Next
         
        //Se tiver altera��es em campo e/ou �ndices
        if lTemAltera
            //Bloqueia altera��es no Dicion�rio
            __SetX31Mode(.F.)
             
            //Se a tabela tiver aberta nessa se��o, fecha
            If Select(cTabAux) > 0
                (cTabAux)->(DbCloseArea())
            EndIf
         
            //Atualiza o Dicion�rio
            X31UpdTable(cTabAux)
             
            //Se houve Erro na Rotina
            If __GetX31Error()
                cMsgAux := "Houveram erros na atualiza��o da tabela "+cTabAux+":"+Chr(13)+Chr(10)
                cMsgAux += __GetX31Trace()
                Aviso('Aten��o', cMsgAux, {'OK'}, 03)
            EndIf                                                        
             
            //Abrindo a tabela para criar dados no sql
            DbSelectArea(cTabAux)
             
            //Desbloqueando altera��es no dicion�rio
            __SetX31Mode(.T.)
        endif
    EndIf
     
    RestArea(aAreaIX)
    RestArea(aAreaX3)
    RestArea(aAreaX2)
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fProxSX3                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  06/08/2015                                                   |
 | Desc:  Fun��o que pega a pr�xima sequencia da SX3                   |
 *---------------------------------------------------------------------*/
 
Static Function fProxSX3(cTabela, cOrdem)
    Local aArea := GetArea()
    Local aAreaX3 := SX3->(GetArea())
    Default cOrdem := ""
     
    //Se n�o vir ordem, ir� percorrer a SX3 para encontrar a ordem atual
    If Empty(cOrdem)
        SX3->(DBSetOrder(1)) //TABELA
         
        //Se conseguir posicionar na tabela
        If SX3->(DBSeek(cTabela))
            //Enquanto houver registros e for a mesma tabela
            While !SX3->(EoF()) .AND. SX3->X3_ARQUIVO == cTabela
                cOrdem := SX3->X3_ORDEM
 
                SX3->(DBSkip())
            EndDo
        Else
            cOrdem := "00"
        EndIf
        cOrdem := Soma1(cOrdem)
         
    //Sen�o, ir� somar 1, pois a tabela n�o tem nenhuma ordem
    Else
        cOrdem := Soma1(cOrdem)
    EndIf
     
    RestArea(aAreaX3)
    RestArea(aArea)
Return
 
/*/{Protheus.doc} zExistSIX
Fun��o que verifica se o indice j� existe, setando a �ltima sequencia dispon�vel
@author Atilio
@since 31/08/2015
@version 1.0
    @param cTabela, Caracter, Tabela buscada
    @param cNickName, Caracter, NickName do �ndice buscado
    @param cSequen, Caracter, �ltima sequencia dispon�vel dos �ndices
    @return lExist, Retorna se o �ndice j� existe ou n�o
    @example
    u_zExistSIX('SB1', 'CAMPO', @cOrdem)
/*/
 
User Function zExistSIX(cTabela, cNickName, cSequen)
    Local aAreaSIX := SIX->(GetArea())
    Local lExist := .F.
    Local cSequen := "1"
     
    SIX->(DbSetOrder(1)) //Indice + Ordem
    SIX->(DbGoTop())
     
    //Se conseguir posicionar na tabela
    If SIX->(DbSeek(cTabela))
        //Enquanto n�o for fim da tabela e for o mesmo �ndice
        While ! SIX->(EoF()) .And. SIX->INDICE == cTabela
            //Se tiver o mesmo apelido, j� existe o �ndice
            If Alltrim(SIX->NICKNAME) == Alltrim(cNickName)
                lExist := .T.
            EndIf
         
            cSequen := SIX->ORDEM
            SIX->(DbSkip())
        EndDo
        cSequen := Soma1(cSequen)
    EndIf
 
    RestArea(aAreaSIX)
Return lExist