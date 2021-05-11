using Facile.BusinessPortal.StageArea.Model;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Extensions.Logging;
using Facile.BusinessPortal.Library.Util;

namespace Facile.BusinessPortal.StageArea.Interface.Fornecedor
{
    public class TituloPagarInterface : CommonInterface<Library.Structs.Post.TituloPagar, Model.TituloPagar>
    {
        public TituloPagarInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "TituloPagar/SetTituloPagar";
        }

        public TituloPagarInterface(FBSAContext _db,  string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "TituloPagar/SetTituloPagar";
        }

        public async Task Sync()
        {
            try
            {
                var qpendentes = (from Model.TituloPagar o in db.TituloPagar
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID}
                                  join Model.Fornecedor f in db.Fornecedor on new { o.EmpresaID, CPFCNPJ = o.FornecedorCPFCNPJ } equals new { f.EmpresaID, f.CPFCNPJ }
                                  where
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente &&
                                  f.StatusIntegracao == StatusIntegracao.Sucesso
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.TituloPagar>();

                foreach (var f in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("TituloPagarInterface => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.TituloPagar
                    {
                        ChaveUnica = f.ChaveUnica,
                        DocumentoPagar = new Library.Structs.Post.DocumentoPagar {
                            Fornecedor = f.FornecedorCPFCNPJ,
                            DataEmissao = f.DataEmissao,
                            NumeroDocumento = f.NumeroDocumento,
                            Serie = f.Serie
                        },
                        //FaturaPagamento = f.FaturaPagamento,
                        NumeroDocumento = f.NumeroDocumento,
                        Parcela = !string.IsNullOrEmpty(f.Parcela.Trim())? f.Parcela.Trim() : "",
                        DataEmissao = f.DataEmissao,
                        DataVencimento = f.DataVencimento,
                        DataBaixa = f.DataBaixa,
                        FormaPagamento = Library.Structs.Post.FormaPagamento.Fatura,//f.FormaPagamento,
                        DataPagamento = f.DataPagamento,
                        ValorTitulo = f.ValorTitulo,
                        Saldo = f.Saldo,
                        NumeroControleParticipante = f.NumeroControleParticipante,
                        Deletado = f.Deletado,
                        TipoDocumento = f.TipoDocumento
                    };


                    //PropertyCopier<Model.TituloPagar, Library.Structs.Post.TituloPagar>.Copy(f, post);

                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("TituloPagar", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("TituloPagar", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("FornecedorInterface => Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}
