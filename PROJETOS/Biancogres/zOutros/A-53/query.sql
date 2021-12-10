SELECT  * FROM BZINTEGRACAO_CLASSEVALOR


CREATE TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR](

[ID][int] IDENTITY(1,1) NOT NULL,
[CV_EMPRESA] [varchar](2) NOT NULL,
[CV_FILIAL] [varchar](2) NOT NULL,
[CV_CLVL][varchar](9) NOT NULL,
[CV_CLASSE][varchar](1) NOT NULL,
[CV_DESCRCLVL][varchar](40) NOT NULL,

[CV_CATEGORIAPPR][varchar](1) NOT NULL,
[CV_CRITERIOCUSTO][varchar](3) NOT NULL,
[CV_QUADRORH][varchar](15) NOT NULL,   
[CV_UN][varchar](2) NOT NULL,         
[CV_CC][varchar](9) NOT NULL,
[CV_APLICACUSTO][varchar](1) NOT NULL,
[CV_CONTROLATAG][varchar](1) NOT NULL,
[CV_ATRIBUICONTA][varchar](1) NOT NULL,
[CV_CLVLGMCD][varchar](4) NOT NULL,
[CV_ENTIDADEGMCD][varchar](4) NOT NULL,

[CV_SETORGMCD][varchar](4) NOT NULL,
[CV_CODIGOAPROVADOR][varchar](6) NOT NULL,
[CV_IDUSERAPROVADOR][varchar](6) NOT NULL,
[CV_APROVADORTEMP][varchar](6) NOT NULL,
[CV_LOGINAPROVADOR][varchar](50) NOT NULL,
[CV_CODIGOPERFIL][varchar](6) NOT NULL,

[CV_VALMIN][float] NOT NULL,
[CV_VALMAX][float] NOT NULL,

[BZNUMPROC] [varchar](15) NOT NULL,
[BZGUID] [varchar](50) NOT NULL,
[STATUS] [varchar](1) NOT NULL,
[BZDTINTEGRACAO] [varchar](30) NULL,
[DTINTEGRA] [varchar](8) NULL,
[HRINTEGRA] [varchar](8) NULL,
[LOG] [varchar](max) NULL,

)

ALTER TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR] ADD CONSTRAINT [DF_BZINTEGRACAO_CLASSEVALOR] DEFAULT ('') FOR [BZGUID]



Integração de Cadastro de Classe de Valor:


Verificar se a Classe de Valor já está cadastrada e está ativa (CTH) Caso não exista, incluir Classe de Valor (CTH)


Caso exista, alterar o status da integradora para Erro e Log de Classe de Valor já existe 


Em caso de erro, finaliza a validação desta Classe de Valor e  verifica o proximo registro com outra classe de valor


Após incluir a Classe de Valor com sucesso:


Verificar se existem os aprovadores cadastrados em SAKVerificar se existem os perfis de aprovador em DHL


Verificar se existe e está ativa a alçada de aprovação da CV em SAL


Caso não exista, incluir a alçada de aprovação (SAL)


