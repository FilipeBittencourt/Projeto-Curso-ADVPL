using Facile.BusinessPortal.BusinessRules.ResquestToPay.Atendimento;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class AtendimentoDAO
    {
     
        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Atendimento> ListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var post in ListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var validResults = new List<ValidationResult>();

                        var queryFornecedor = from Model.Fornecedor o in db.Fornecedor
                                                where o.CPFCNPJ == post.FornecedorCPFCNPJ && o.EmpresaID == Params.Unidade.EmpresaID
                                                select o;

                        if (!queryFornecedor.Any())//caso fornecedor não estiver cadastrado
                        {
                            tran.Rollback();
                            string Msg = "Fornecedor (Atendimento): " + post.FornecedorCPFCNPJ + " não encontrado.";
                            result.Add(SaveDataReturn.ReturnError(post.ChaveUnica, Msg));
                            continue;
                        }
                        

                        var query = from Model.Atendimento o in db.Atendimento.ByParams(Params)
                                    where o.Numero.Equals(post.Numero)
                                    select o;

                        Model.Atendimento Atendimento;

                        if (query.Any())
                        {
                            Atendimento = query.First();
                            db.Entry(Atendimento).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            Atendimento = new BaseDAO<Model.Atendimento>().Novo(Params);
                            Atendimento.Numero = post.Numero;
                            db.Atendimento.Add(Atendimento);
                        }

                        Atendimento.FornecedorID                = queryFornecedor.First().ID;          
                        Atendimento.NumeroContrato              = post.NumeroContrato ;
                        Atendimento.Item                        = post.Item;
                        Atendimento.CodigoProduto               = post.CodigoProduto;
                        Atendimento.NomeProduto                 = post.NomeProduto;
                        Atendimento.QuantidadeProduto           = post.QuantidadeProduto;
                        Atendimento.ValorProduto                = post.ValorProduto;
                        Atendimento.Contato                     = post.Contato;
                        Atendimento.Email                       = post.Email;
                        Atendimento.Observacao                  = post.Observacao;
                        Atendimento.DataLiberacao               = post.DataLiberacao;
                        Atendimento.NumeroControleParticipante  = post.NumeroControleParticipante ;

                        Atendimento.NomeReclamante              = post.NomeReclamante;
                        Atendimento.CepReclamante               = post.CepReclamante;
                        Atendimento.EnderecoReclamante          = post.EnderecoReclamante;
                        Atendimento.EstadoReclamante            = post.EstadoReclamante;
                        Atendimento.BairroReclamante            = post.BairroReclamante;
                        Atendimento.CidadeReclamante            = post.CidadeReclamante;
                        Atendimento.TelefoneReclamante          = post.TelefoneReclamante;
                        Atendimento.ContatoReclamante           = post.ContatoReclamante;
                        Atendimento.HorarioContatoReclamante    = post.HorarioContatoReclamante;
                        Atendimento.Termo                       = post.Termo;


                        var validation = new ValidationContext(Atendimento, null, null);
                        Validator.TryValidateObject(Atendimento, validation, validResults);


                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }
                        await db.SaveChangesAsync();
                        var ResultMail = AtendimentoMail.NovoAtendimentoSendMail(db, Atendimento.ID);
                        if (!ResultMail.Status)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }

                       

                        /*if (post.CriarUsuario)
                        {
                            var qUser = db.UsuarioPessoa.Where(u => u.PessoaID == transportadora.ID && u.Tipo == Library.TipoUsuario.Transportadora);
                            if (!qUser.Any())
                            {
                                try
                                {
                                    var grupo = db.GrupoUsuario.EmpData(Params.Unidade.EmpresaID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Transportadora);

                                    if (grupo == null)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "GRUPO PORTAL DE TRANSPORTADORA NAO ENCONTRADO."));
                                        continue;
                                    }

                                    var usermodel = new Library.Structs.Post.CreateUserModel()
                                    {
                                        IsFirstAdmin = true,
                                        GrupoID = grupo.ID,
                                        Tipo = TipoUsuario.Transportadora,
                                        EntidadeID = transportadora.ID,
                                        UserName = transportadora.CPFCNPJ,
                                        Nome = transportadora.Nome,
                                        Email = transportadora.Email,
                                        Password = "123456",
                                        ClientAuth = new ClientAuth()
                                        {
                                            Client_Key = Params.Unidade.Empresa.Client_Key.ToString(),
                                            Secret_Key = Params.Unidade.Secret_Key,
                                            CNPJ = Params.Unidade.CNPJ
                                        }
                                    };

                                    var resUser = await UsuarioDAO.ApiCreateUserAsync(usermodel, _siteBaseURL);
                                    if (!resUser.Ok)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na criacao de Usuario Base: " + resUser.Message));
                                        continue;
                                    }
                                    else
                                    {
                                        var userBase = db.Usuario.FirstOrDefault(u => u.UserId == resUser.Id);
                                        if (userBase != null)
                                        {
                                            var utransportadora = new BaseDAO<UsuarioPessoa>().Novo(Params, true);
                                            utransportadora.UsuarioID = userBase.ID;
                                            utransportadora.PessoaID = transportadora.ID;
                                            db.UsuarioPessoa.Add(utransportadora);
                                        }
                                        else
                                        {
                                            tran.Rollback();
                                            result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na alteracao de Status de Usuario Base: " + resUser.Message));
                                            continue;
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    throw new Exception("Erro na criacao de Usuario Base.", ex);
                                }
                            }
                            else
                            {
                                var user = qUser.First();
                                user.Habilitado = post.Habilitado;

                                var usermodel = new Library.Structs.Post.ChangeUserModel()
                                {
                                    UserName = transportadora.CPFCNPJ,
                                    Email = transportadora.Email,
                                    IsLocked = !post.Habilitado,
                                    ClientAuth = new ClientAuth()
                                    {
                                        Client_Key = Params.Unidade.Empresa.Client_Key.ToString(),
                                        Secret_Key = Params.Unidade.Secret_Key,
                                        CNPJ = Params.Unidade.CNPJ
                                    }
                                };

                                var resUser = await UsuarioDAO.ApiSetUserStatusAsync(usermodel, _siteBaseURL);
                                if (!resUser.Ok)
                                {
                                    tran.Rollback();
                                    result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na alteracao de Status de Usuario Base: " + resUser.Message));
                                    continue;
                                }
                            }

                            await db.SaveChangesAsync();
                        }*/
                        
                        tran.Commit();
                        result.Add(SaveDataReturn.ReturnOk(post.ChaveUnica));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(post.ChaveUnica, ex));
                        continue;
                    }
                }
            }
       
            return result;     
        }

        public static async Task<List<Library.Structs.Post.Atendimento>> GetAsync(ContextParams Params, string _siteBaseURL)
        {
            var db = Params.Database;
            var query = from Model.Atendimento o in db.Atendimento.ByParams(Params).Include(x => x.AtendimentoMedicao)
                        where o.StatusIntegracao == StatusIntegracao.Pendente &&
                        o.Status == StatusAtendimento.Aprovada
                        select o;


            List<Library.Structs.Post.Atendimento> List = new List<Library.Structs.Post.Atendimento>();

            foreach (var item in query.ToList())
            {
                var Atendimento = new Library.Structs.Post.Atendimento();
                PropertyCopier<Model.Atendimento, Library.Structs.Post.Atendimento>.Copy(item, Atendimento);
                Atendimento.FornecedorCPFCNPJ = item.Fornecedor.CPFCNPJ;

                List<Library.Structs.Post.AtendimentoMedicao> ListItem = new List<Library.Structs.Post.AtendimentoMedicao>();

                foreach (var item_o in item.AtendimentoMedicao)
                {
                    var atendimentoMedicao = new Library.Structs.Post.AtendimentoMedicao();
                    atendimentoMedicao.ID = item_o.ID;
                    atendimentoMedicao.AtendimentoID = item_o.AtendimentoID;
                    atendimentoMedicao.Arquivo = item_o.Arquivo;
                    atendimentoMedicao.Descricao = item_o.Descricao;
                    atendimentoMedicao.Tipo = item_o.Tipo;
                    atendimentoMedicao.Nome = item_o.Nome;

                    ListItem.Add(atendimentoMedicao);
                }
                Atendimento.AtendimentoMedicao = ListItem;
                
                List.Add(Atendimento);
            }

            return List;
        }

        public static async Task<List<SaveDataReturn>> UpdateStatusIntegracaoAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Atendimento> ListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var post in ListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var query = from Model.Atendimento o in db.Atendimento.ByParams(Params)
                                    where o.NumeroControleParticipante == post.NumeroControleParticipante
                                    select o;

                        Model.Atendimento Atendimento;

                        if (query.Any())
                        {
                            Atendimento = query.First();
                            db.Entry(Atendimento).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            Atendimento.StatusIntegracao = StatusIntegracao.Sucesso;
                            Atendimento.DataHoraIntegracao = DateTime.Now;
                        }
                        await db.SaveChangesAsync();


                        tran.Commit();
                        result.Add(SaveDataReturn.ReturnOk(post.ChaveUnica));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(post.ChaveUnica, ex));
                        continue;
                    }
                }
            }

            return result;
        }
    }
}
